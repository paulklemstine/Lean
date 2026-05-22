#!/usr/bin/env python3
"""ArxivMiner: Fetch ArXiv papers and mine future research directions.

Orchestrates the pipeline:
1. Fetch a recent ArXiv paper (domain-specific or general query)
2. Get Catalog context (key theorems, breakthrough analysis)
3. Ask Pi-Agent to analyze the paper and propose a novel future direction
   combining ArXiv ideas with Catalog results
4. Parse the response into a FutureDirection and add to research_memory
"""

import json
import re
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Any

from arxiv_provider import ArxivTexProvider, ArxivPaper, DOMAIN_QUERIES, GENERAL_QUERY
from research_memory import FutureDirection, FutureDirectionsManager

# _infer_domains is a static method on FutureDirectionsManager

# Prompt for mining ideas from ArXiv papers
_MINING_SYSTEM_PROMPT = (
    "You are a mathematical research strategist analyzing recent ArXiv papers "
    "to identify novel research directions. Your goal is to find ideas from "
    "the paper that could be combined with existing formalized results to "
    "create genuinely new mathematics. Focus on cross-pollination: taking "
    "techniques or results from one area and applying them to another. "
    "Output ONLY valid JSON."
)

_MINING_USER_PROMPT_TEMPLATE = """A recent ArXiv paper introduces new mathematics that could create novel
research directions when combined with existing results in our formal theorem catalog.

## ArXiv Paper: {title}
ArXiv ID: {arxiv_id}
Authors: {authors}
Categories: {categories}

### Paper Content (excerpts)
{paper_content}

## Our Catalog State
{catalog_summary}

## Key Theorems Available
{theorem_listing}

## Task
Propose ONE research direction that:
1. Takes a specific result or technique from the ArXiv paper
2. Combines it with a specific theorem or structure from our Catalog
3. States a precise, falsifiable conjecture that could be formalized in Lean 4
4. Identifies which Catalog theorems to build on (cite file paths)
5. Names the domain bridges this creates (e.g., "Algebra <-> Tropical")

Output JSON:
{{
  "title": "Short descriptive title (not generic like 'Study of X')",
  "description": "Conjecture: [precise statement]. Test: [how to verify]. Impact: [what this opens up].",
  "domain": "One of: Pythagorean, Tropical, Cryptography, Algebra, EML, MachineLearning, Physics, Logic, Computation, Bridges, Speculative, Geometry",
  "catalog_references": ["Algebra/Berggren.lean", "Tropical/TropicalSemiring.lean"],
  "domain_bridges": ["Algebra <-> Tropical"],
  "ambition_level": "grand_challenge" or "extension",
  "proof_strategy": "Brief proof approach: key lemmas needed, techniques to use.",
  "arxiv_id": "{arxiv_id}"
}}"""


class ArxivMiner:
    """Fetch ArXiv papers and mine future research directions from them.

    Alternates between domain-specific and general queries to balance
    relevance with cross-pollination.
    """

    def __init__(self, pi_agent, catalog_analyzer, research_memory: FutureDirectionsManager,
                 config: Optional[Dict[str, Any]] = None):
        self.pi_agent = pi_agent
        self.catalog_analyzer = catalog_analyzer
        self.research_memory = research_memory
        self.config = config or {}

        # Config
        self.enabled = self.config.get("enabled", True)
        self.rate_limit = self.config.get("rate_limit_seconds", 3)
        self.max_paper_chars = self.config.get("max_paper_chars", 8000)
        self.queries = self.config.get("queries", DOMAIN_QUERIES)

        # Provider instance (will be reconfigured per cycle)
        self.provider = ArxivTexProvider(
            query=GENERAL_QUERY,
            batch_size=5,
            rate_limit=self.rate_limit,
            max_paper_chars=self.max_paper_chars,
        )

        # Track cycle parity for alternating queries
        self._cycle_count = 0

    def mine_future_direction(
        self,
        domain: str = "",
        use_domain_query: bool = True,
    ) -> Optional[FutureDirection]:
        """Fetch an ArXiv paper and mine a future direction from it.

        Args:
            domain: Current research domain (for domain-specific query)
            use_domain_query: If True, use domain-specific query;
                             if False, use general cross-pollination query

        Returns:
            A FutureDirection added to research_memory, or None on failure.
        """
        if not self.enabled:
            return None

        if not self.pi_agent:
            print("[ArXiv] No Pi-Agent available, skipping mining")
            return None

        # Set the appropriate query
        if use_domain_query and domain in self.queries:
            query = self.queries[domain]
            print(f"[ArXiv] Using domain query for {domain}: {query[:60]}...")
        else:
            query = GENERAL_QUERY
            print(f"[ArXiv] Using general cross-pollination query")

        self.provider.set_query(query)

        # Fetch a paper
        paper = self.provider.get_next_paper()
        if not paper or not paper.tex_content:
            print("[ArXiv] No paper content available, skipping mining")
            return None

        print(f"[ArXiv] Analyzing: {paper.title[:80]} (ID: {paper.paper_id})")

        # Get Catalog context
        catalog_summary = ""
        theorem_listing = ""
        if self.catalog_analyzer:
            try:
                self.catalog_analyzer.invalidate_cache()
                self.catalog_analyzer.scan()
                catalog_summary = self.catalog_analyzer.get_domain_summary_for_prompt()
                theorem_listing = self.catalog_analyzer.get_key_theorem_listing(
                    max_per_domain=3, max_total=20
                )
            except Exception as e:
                print(f"[ArXiv] Error getting catalog context: {e}")

        # Build the mining prompt
        user_prompt = _MINING_USER_PROMPT_TEMPLATE.format(
            title=paper.title[:200],
            arxiv_id=paper.paper_id,
            authors=paper.authors[:200],
            categories=paper.categories[:100],
            paper_content=paper.tex_content[:6000],
            catalog_summary=catalog_summary[:3000] if catalog_summary else "Catalog not available.",
            theorem_listing=theorem_listing[:2000] if theorem_listing else "No theorem listing available.",
        )

        # Ask Pi-Agent to mine a direction
        try:
            raw = self.pi_agent._call_ollama(
                _MINING_SYSTEM_PROMPT,
                user_prompt,
                timeout=120,
            )
        except Exception as e:
            print(f"[ArXiv] Pi-Agent call failed: {e}")
            return None

        if not raw or raw.startswith(("[API_ERROR", "[OLLAMA_ERROR", "[API_TIMEOUT")):
            print(f"[ArXiv] Pi-Agent returned error: {raw[:100]}")
            return None

        # Parse the response
        direction = self._parse_direction_response(raw, paper)
        if direction:
            # Add to research memory
            self.research_memory.add_direction(direction)
            print(f"[ArXiv] Mined direction: {direction.title}")

        return direction

    def _parse_direction_response(
        self, raw: str, paper: ArxivPaper
    ) -> Optional[FutureDirection]:
        """Parse Pi-Agent's JSON response into a FutureDirection."""
        # Extract JSON from the response
        json_match = re.search(r'\{[^{}]*\}', raw, re.DOTALL)
        if not json_match:
            # Try with nested braces (the response might have nested JSON)
            json_match = re.search(r'\{.*\}', raw, re.DOTALL)
            if not json_match:
                print("[ArXiv] Could not find JSON in Pi-Agent response")
                return None

        try:
            data = json.loads(json_match.group())
        except json.JSONDecodeError:
            print("[ArXiv] Could not parse JSON from Pi-Agent response")
            return None

        # Extract fields with defaults
        title = data.get("title", "").strip()
        if not title:
            print("[ArXiv] No title in parsed direction")
            return None

        # Reject generic titles
        generic_patterns = [
            r"^Conjecture\s+\d+$",
            r"^(Study|Analysis|Investigation|Further|Extended)\s+(of|on|into)\s+",
            r"^(A|An|The)\s+(New|Novel|Further|Extended)\s+",
        ]
        for pat in generic_patterns:
            if re.match(pat, title, re.IGNORECASE):
                # Try to make it more specific by prepending the ArXiv ID
                title = f"ArXiv-{paper.paper_id}: {title}"

        description = data.get("description", "").strip()
        if not description:
            description = f"Research direction inspired by ArXiv paper {paper.paper_id}"

        domain = data.get("domain", "").strip()
        if not domain:
            # Infer from categories
            cats = paper.categories.lower()
            if "nt" in cats:
                domain = "Pythagorean"
            elif "co" in cats or "tropical" in cats.lower():
                domain = "Tropical"
            elif "cr" in cats or "lattice" in cats.lower():
                domain = "Cryptography"
            else:
                domain = "Algebra"

        catalog_refs = data.get("catalog_references", [])
        if isinstance(catalog_refs, str):
            catalog_refs = [r.strip() for r in catalog_refs.split(",") if r.strip()]

        domain_bridges = data.get("domain_bridges", [])
        if isinstance(domain_bridges, str):
            domain_bridges = [b.strip() for b in domain_bridges.split(",") if b.strip()]

        ambition = data.get("ambition_level", "extension").strip().lower()
        if ambition not in ("grand_challenge", "extension"):
            ambition = "extension"

        proof_strategy = data.get("proof_strategy", "").strip()

        return FutureDirection(
            id=f"arxiv-{paper.paper_id}",
            title=title,
            description=description,
            source_exp_id=f"arxiv-{paper.paper_id}",
            source_path=paper.source_url,
            domains=FutureDirectionsManager._infer_domains(f"{title} {description}"),
            proof_strategy=proof_strategy,
            research_mode="prove",
            depth_estimate=3,
            priority_score=0.7,  # ArXiv-sourced directions start at high priority
            status="available",
            catalog_references=catalog_refs,
            ambition_level=ambition,
            domain_bridges=domain_bridges,
        )