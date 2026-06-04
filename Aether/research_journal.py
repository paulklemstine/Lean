#!/usr/bin/env python3
"""ResearchJournal: Accumulates key findings across cycles for cross-cycle memory.

After each cycle, the journal records:
  - Key theorems proved (highest quality, most novel)
  - Conceptual insights (from insight_extractor)
  - Open questions / unfinished work (sorries, partial proofs)

Before each new cycle, the journal provides a compact summary of
Aether's accumulated discoveries, so each cycle starts with context
about what Aether has already found — not just catalog theorems but
conceptual insights and research threads.

Persistence: .aether_workspace/research_journal.json
"""

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional


class ResearchJournal:
    """Cross-cycle research memory — accumulates key findings and insights."""

    MAX_ENTRIES = 200  # Cap journal entries
    MAX_SUMMARY_CHARS = 3000  # Max chars for prompt injection

    def __init__(self, workspace: Path):
        self.workspace = workspace
        self.journal_file = workspace / "research_journal.json"
        self._data: Dict[str, Any] = self._load()

    def _load(self) -> Dict[str, Any]:
        if self.journal_file.exists():
            try:
                return json.loads(self.journal_file.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                pass
        return {
            "entries": [],  # List of journal entries
            "key_theorems": [],  # Best theorems across all cycles
            "open_questions": [],  # Unfinished work / sorries
            "research_threads": {},  # domain -> list of thread summaries
            "last_updated": "",
        }

    def _save(self) -> None:
        self.workspace.mkdir(parents=True, exist_ok=True)
        # Cap list sizes
        self._data["entries"] = self._data["entries"][-self.MAX_ENTRIES:]
        self._data["key_theorems"] = self._data["key_theorems"][-50:]
        self._data["open_questions"] = self._data["open_questions"][-30:]
        self._data["last_updated"] = datetime.now(timezone.utc).isoformat()[:19]
        self.journal_file.write_text(
            json.dumps(self._data, indent=2, ensure_ascii=False, sort_keys=True),
            encoding="utf-8",
        )

    def record_cycle(self, job, quality_score: float = 0.0) -> None:
        """Record key findings from a completed cycle into the journal."""
        if not job or quality_score < 0.3:
            return  # Don't journal low-quality cycles

        concept = getattr(job, "concept", None)
        domain = ""
        title = ""
        if concept:
            domain = getattr(concept, "domain", "") or ""
            if isinstance(concept, dict):
                domain = concept.get("domain", "")
            title = getattr(concept, "title", "") if not isinstance(concept, dict) else concept.get("title", "")
            if isinstance(concept, dict):
                title = concept.get("title", "")

        # Journal entry
        entry = {
            "cycle_id": getattr(job, "job_id", "")[:8],
            "domain": domain,
            "title": title[:100],
            "quality_score": quality_score,
            "theorem_count": getattr(job, "theorem_count", 0),
            "sorry_count": getattr(job, "sorry_count", 0),
            "timestamp": datetime.now(timezone.utc).isoformat()[:19],
            "key_insight": "",  # Filled below if possible
        }

        # Extract key insight from future directions (if the cycle produced any)
        fd_text = getattr(job, "result_future_directions", "") or ""
        if fd_text:
            # Take first 200 chars of future directions as the insight
            entry["key_insight"] = fd_text[:200].strip()

        self._data["entries"].append(entry)

        # Record key theorems for high-quality cycles
        if quality_score >= 0.7 and getattr(job, "theorem_count", 0) >= 5:
            lean_code = getattr(job, "result_lean", "") or ""
            # Extract top theorem names
            import re
            theorems = re.findall(r'(?:theorem|lemma)\s+(\w+)', lean_code[:5000])
            for thm in theorems[:3]:  # Top 3 theorems from this cycle
                self._data["key_theorems"].append({
                    "name": thm,
                    "domain": domain,
                    "quality": quality_score,
                    "cycle_id": getattr(job, "job_id", "")[:8],
                })

        # Track open questions (sorries)
        sorry_count = getattr(job, "sorry_count", 0)
        if sorry_count > 0:
            lean_code = getattr(job, "result_lean", "") or ""
            sorry_lines = []
            for line in lean_code.split('\n'):
                if 'sorry' in line.lower():
                    # Get the theorem name from context
                    sorry_lines.append(line.strip()[:100])
                    if len(sorry_lines) >= 3:
                        break
            self._data["open_questions"].append({
                "domain": domain,
                "cycle_id": getattr(job, "job_id", "")[:8],
                "sorry_count": sorry_count,
                "context": "; ".join(sorry_lines)[:200],
                "timestamp": datetime.now(timezone.utc).isoformat()[:19],
            })

        # Track research threads per domain
        threads = self._data.setdefault("research_threads", {})
        if domain:
            domain_threads = threads.setdefault(domain, [])
            domain_threads.append({
                "title": title[:80],
                "quality": quality_score,
                "theorems": getattr(job, "theorem_count", 0),
                "cycle_id": getattr(job, "job_id", "")[:8],
            })
            # Keep only last 10 entries per domain
            threads[domain] = domain_threads[-10:]

        self._save()

    def build_journal_summary(self, domain: str = "", max_chars: int = None) -> str:
        """Build a compact summary of Aether's accumulated research for the prompt.

        This gives each new cycle context about what Aether has already
        discovered — conceptual insights and research threads, not just
        catalog theorems.
        """
        max_chars = max_chars or self.MAX_SUMMARY_CHARS
        lines = ["## Aether Research Journal", ""]

        # Recent key findings
        entries = self._data.get("entries", [])
        recent_high = sorted(
            [e for e in entries if e.get("quality_score", 0) >= 0.7],
            key=lambda e: e.get("quality_score", 0),
            reverse=True,
        )[:8]
        if recent_high:
            lines.append("### Recent High-Quality Cycles")
            for e in recent_high:
                q = e.get("quality_score", 0)
                d = e.get("domain", "?")
                t = e.get("title", "?")[:60]
                thms = e.get("theorem_count", 0)
                lines.append(f"- Q={q:.2f} [{d}] {t} ({thms} theorems)")
            lines.append("")

        # Domain research threads (prefer current domain)
        threads = self._data.get("research_threads", {})
        if threads:
            lines.append("### Active Research Threads")
            # Show current domain first
            if domain and domain in threads:
                for t in threads[domain][-3:]:
                    lines.append(f"- [{domain}] {t.get('title','?')[:50]} Q={t.get('quality',0):.2f}")
            # Then other domains (1 each)
            for dom, dom_threads in sorted(threads.items()):
                if dom == domain:
                    continue
                if dom_threads:
                    latest = dom_threads[-1]
                    lines.append(f"- [{dom}] {latest.get('title','?')[:50]} Q={latest.get('quality',0):.2f}")
            lines.append("")

        # Key theorems
        key_theorems = self._data.get("key_theorems", [])
        if key_theorems:
            lines.append("### Key Theorems Discovered")
            for thm in key_theorems[-10:]:
                lines.append(f"- {thm.get('name','?')} [{thm.get('domain','?')}] Q={thm.get('quality',0):.2f}")
            lines.append("")

        # Open questions
        open_q = self._data.get("open_questions", [])
        if open_q:
            lines.append("### Open Questions (Unfinished Proofs)")
            for oq in open_q[-5:]:
                lines.append(f"- [{oq.get('domain','?')}] {oq.get('sorry_count',0)} sorries in {oq.get('cycle_id','?')}")
            lines.append("")

        text = "\n".join(lines)
        if len(text) > max_chars:
            text = text[:max_chars - 3] + "..."
        return text

    def stats(self) -> Dict[str, int]:
        return {
            "entries": len(self._data.get("entries", [])),
            "key_theorems": len(self._data.get("key_theorems", [])),
            "open_questions": len(self._data.get("open_questions", [])),
            "active_threads": sum(len(v) for v in self._data.get("research_threads", {}).values()),
        }