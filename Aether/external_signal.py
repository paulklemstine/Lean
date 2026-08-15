#!/usr/bin/env python3
"""ExternalSignalFeed: pull research directions from outside sources.

Sources:
  - ArXiv: mine recent abstracts and LaTeX source via arxiv_provider + Pi-Agent
  - OEIS: fetch recent / interesting sequences
  - LMFDB: fetch interesting elliptic curves / number fields

Directions are converted into FutureDirection objects with category
"cross_domain_bridge" by default.
"""

import json
import re
import urllib.parse
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional

from research_memory import FutureDirection, FutureDirectionsManager


class ExternalSignalFeed:
    """Aggregate external signals into future directions."""

    def __init__(
        self,
        pi_agent: Any,
        fd_manager: FutureDirectionsManager,
        workspace: Optional[Path] = None,
    ):
        self.pi_agent = pi_agent
        self.fd_manager = fd_manager
        self.workspace = workspace or getattr(fd_manager, "workspace", Path("."))

        # Lazy arxiv provider import to avoid circular deps
        try:
            from arxiv_provider import ArxivTexProvider, GENERAL_QUERY
            self.arxiv_provider = ArxivTexProvider(query=GENERAL_QUERY, batch_size=10, rate_limit=3)
        except Exception as e:
            print(f"[ExternalSignal] ArXiv provider unavailable: {e}")
            self.arxiv_provider = None

    def refresh(self, domain: str = "", count_per_source: int = 2) -> int:
        """Fetch signals from all sources and add directions. Returns number added."""
        # Re-sync the manager from disk before touching anything. The feed's
        # manager is constructed at extractor init and otherwise holds a stale
        # snapshot; if integration marked directions completed mid-tick, saving
        # against that snapshot would clobber the newer state (re-publish loop).
        self.fd_manager = FutureDirectionsManager(self.workspace)
        added = 0
        try:
            added += self._add_directions(self.fetch_arxiv_directions(domain, count=count_per_source))
        except Exception as e:
            print(f"[ExternalSignal] ArXiv refresh failed: {e}")
        try:
            added += self._add_directions(self.fetch_oeis_directions(count=count_per_source))
        except Exception as e:
            print(f"[ExternalSignal] OEIS refresh failed: {e}")
        return added

    def _add_directions(self, directions: List[FutureDirection]) -> int:
        added = 0
        # Guard against stale-manager clobber even when _add_directions is
        # called directly: always write against the current on-disk state.
        self.fd_manager = FutureDirectionsManager(self.workspace)
        for d in directions:
            if not d.title or not d.description:
                continue
            d.category = d.category or "cross_domain_bridge"
            self.fd_manager.add_direction(d)
            print(f"[ExternalSignal] -> Added {getattr(d, 'source', 'external')} direction: {d.title[:100]}")
            print(f"[ExternalSignal]    {d.description[:150]}...")
            added += 1
        return added

    # ── ArXiv ──

    def fetch_arxiv_directions(self, domain: str = "", count: int = 2) -> List[FutureDirection]:
        """Mine up to `count` future directions from recent ArXiv papers."""
        if not self.arxiv_provider or not self.pi_agent:
            return []

        from arxiv_provider import DOMAIN_QUERIES

        directions: List[FutureDirection] = []
        if domain and domain in DOMAIN_QUERIES:
            if hasattr(self.arxiv_provider, "set_query"):
                self.arxiv_provider.set_query(DOMAIN_QUERIES[domain])
        attempts = 0
        while len(directions) < count and attempts < count * 3:
            attempts += 1
            paper = self.arxiv_provider.get_next_paper()
            if not paper:
                break
            fd = self._mine_paper(paper)
            if fd:
                directions.append(fd)
        return directions[:count]

    def _mine_paper(self, paper) -> Optional[FutureDirection]:
        system = (
            "You are a mathematical research strategist. Given an ArXiv paper, propose "
            "ONE precise, falsifiable conjecture that could be formalized in Lean 4. "
            "Respond with valid JSON only:\n"
            "{\"title\": string, \"description\": string, \"domain\": string, "
            "\"catalog_references\": [string], \"domain_bridges\": [string], "
            "\"ambition_level\": \"grand_challenge\" or \"extension\", "
            "\"proof_strategy\": string, \"lean_theorem_stub\": string}"
        )
        content = f"Title: {paper.title}\nAbstract: {paper.abstract}\nCategories: {paper.categories}\n"
        if getattr(paper, "tex_content", ""):
            content += f"\nExcerpt:\n{paper.tex_content[:4000]}"
        try:
            raw = self.pi_agent._call_ollama(system, content, timeout=120)
            data = self.pi_agent._parse_json_response(raw)
            if data is None:
                raise ValueError(f"No JSON found. Raw response snippet: {raw[:100]}")
        except Exception as e:
            print(f"[ExternalSignal] ArXiv mining parse failed: {e}")
            return None

        if isinstance(data, dict) and data.get("title") in ("Bypassed", "Bypassed Direction"):
            data["title"] = f"ArXiv paper: {paper.title}"
            data["description"] = f"Investigate the ArXiv paper '{paper.title}' and formalize its key results. Abstract: {paper.abstract[:2000]}"
            data["proof_strategy"] = "Analyze the paper's main theorem and construct a formal Lean 4 proof."

        if not isinstance(data, dict) or not data.get("title") or not data.get("description"):
            return None

        domains = self.fd_manager._infer_domains(
            str(data.get("title", "")) + " " + str(data.get("description", ""))
        )
        return FutureDirection(
            id=self.fd_manager._next_id(),
            title=str(data["title"])[:200],
            description=str(data["description"])[:3000],
            source_exp_id=getattr(paper, "paper_id", "arxiv"),
            source_path=getattr(paper, "source_url", "arxiv"),
            domains=domains,
            proof_strategy=str(data.get("proof_strategy", ""))[:1000],
            depth_estimate=3,
            priority_score=0.80,
            catalog_references=data.get("catalog_references") or [],
            ambition_level=str(data.get("ambition_level", "extension")),
            domain_bridges=data.get("domain_bridges") or [],
            lean_theorem_stub=str(data.get("lean_theorem_stub", ""))[:1000],
            category="cross_domain_bridge",
            timestamp=datetime.now(timezone.utc).isoformat(),
        )

    # ── OEIS ──

    def fetch_oeis_directions(self, count: int = 2) -> List[FutureDirection]:
        """Fetch interesting OEIS sequences and turn them into directions."""
        directions: List[FutureDirection] = []
        try:
            queries = ["nice", "core", "dumb", "look"]
            for q in queries:
                url = f"https://oeis.org/search?fmt=json&q={urllib.parse.quote(q)}"
                data = self._fetch_json(url, timeout=30)
                if not data:
                    continue
                parsed = self._parse_oeis_results(data)
                directions.extend(parsed)
                if len(directions) >= count:
                    break
        except Exception as e:
            print(f"[ExternalSignal] OEIS fetch error: {e}")
        return directions[:count]

    def _parse_oeis_results(self, data: Any) -> List[FutureDirection]:
        directions: List[FutureDirection] = []
        if isinstance(data, list):
            results = data
        elif isinstance(data, dict):
            results = data.get("results", []) or []
        else:
            results = []
        for r in results[:3]:
            if not isinstance(r, dict):
                continue
            name = r.get("name", "")
            seq_data = r.get("data", "")
            if not name or not seq_data:
                continue
            title = f"OEIS sequence: {name}"
            description = (
                f"Investigate the sequence {name} with terms {seq_data[:100]}. "
                f"Find a closed form, recurrence, or asymptotic and formalize it in Lean 4."
            )
            domains = self.fd_manager._infer_domains(title + " " + description)
            directions.append(FutureDirection(
                id=self.fd_manager._next_id(),
                title=title[:200],
                description=description[:3000],
                source_exp_id=f"oeis:{r.get('number', '')}",
                source_path="https://oeis.org/",
                domains=domains,
                depth_estimate=2,
                priority_score=0.70,
                category="cross_domain_bridge",
                timestamp=datetime.now(timezone.utc).isoformat(),
            ))
        return directions

    # ── Utilities ──

    @staticmethod
    def _fetch_json(url: str, timeout: int = 30) -> Optional[dict]:
        try:
            req = urllib.request.Request(url, headers={
                "User-Agent": "Aether-Research-Engine/3.0 (mailto:aether@mathresearch.org)"
            })
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                return json.loads(resp.read().decode("utf-8", errors="ignore"))
        except Exception as e:
            print(f"[ExternalSignal] JSON fetch failed for {url}: {e}")
            return None

    @staticmethod
    def _strip_markdown(raw: str) -> str:
        cleaned = raw.strip()
        if cleaned.startswith("```"):
            cleaned = re.sub(r"^```(?:json)?\s*", "", cleaned)
            cleaned = re.sub(r"\s*```$", "", cleaned)
        return cleaned
