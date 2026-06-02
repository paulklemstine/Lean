#!/usr/bin/env python3
"""InsightExtractor: Scans Aether's own Catalog theorems for meta-insights
that can improve how Aether does science.

After each cycle, the extractor uses the LLM to classify newly proved theorems
into categories: impossibility/barrier results, proof strategy patterns,
cross-domain bridges, and cost metrics. These insights are then injected into
future Aristotle prompts as guardrails and strategy hints.

Insight persistence: .aether_workspace/insights.json
"""

import json
import re
import hashlib
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple


class InsightExtractor:
    """Extracts meta-insights from proved theorems and injects them into
    the research pipeline as guardrails, strategy hints, and cost estimates."""

    def __init__(self, workspace: Path, pi_agent=None, catalog_analyzer=None):
        self.workspace = workspace
        self.pi_agent = pi_agent
        self.catalog_analyzer = catalog_analyzer
        self.insights_file = workspace / "insights.json"
        self._insights: Dict[str, Any] = self._load()

    def _load(self) -> Dict[str, Any]:
        """Load insights from disk, or create default structure."""
        if self.insights_file.exists():
            try:
                return json.loads(self.insights_file.read_text(encoding="utf-8"))
            except (json.JSONDecodeError, OSError):
                pass
        return {
            "barriers": [],
            "strategies": [],
            "cost_estimates": {},
            "cross_domain_bridges": [],
            "last_scan_cycle": "",
            "scanned_theorems": [],  # hashes of already-scanned theorem statements
        }

    def _save(self) -> None:
        """Persist insights to disk."""
        self.workspace.mkdir(parents=True, exist_ok=True)
        self.insights_file.write_text(
            json.dumps(self._insights, indent=2, ensure_ascii=False, sort_keys=True),
            encoding="utf-8",
        )

    def _theorem_hash(self, statement: str) -> str:
        """Stable hash for dedup — avoid re-scanning the same theorem."""
        return hashlib.sha256(statement.strip().lower().encode()).hexdigest()[:16]

    # ─── Scanning ───────────────────────────────────────────────

    def scan_new_theorems(self, job) -> None:
        """After a cycle completes, scan newly proved theorems for meta-insights.

        Uses the LLM to classify theorems into: barriers, strategies,
        cross-domain bridges. Then updates cost estimates from the Catalog.
        """
        if not self.pi_agent:
            return

        # Collect new theorem statements from the job
        new_theorems = self._collect_new_theorems(job)
        if not new_theorems:
            return

        # Filter out already-scanned theorems
        scanned = set(self._insights.get("scanned_theorems", []))
        unscanned = [t for t in new_theorems if self._theorem_hash(t["statement"]) not in scanned]
        if not unscanned:
            return

        # LLM classification
        extracted = self._llm_classify_theorems(unscanned)
        if extracted:
            self._merge_extracted_insights(extracted)

        # Update scanned set
        for t in unscanned:
            h = self._theorem_hash(t["statement"])
            scanned.add(h)
        self._insights["scanned_theorems"] = list(scanned)[-500:]  # cap at 500 hashes

        # Update cost estimates from catalog
        if self.catalog_analyzer:
            self._update_cost_estimates()

        # Record scan cycle
        if hasattr(job, "exp_id") and job.exp_id:
            self._insights["last_scan_cycle"] = job.exp_id

        self._save()

    def _collect_new_theorems(self, job) -> List[Dict[str, str]]:
        """Extract theorem statements from the job's results."""
        theorems = []
        # From lean_proofs
        lean_files = getattr(job, "lean_files", []) or []
        for lf in lean_files:
            if not isinstance(lf, dict):
                continue
            code = lf.get("code", "")
            if not code:
                continue
            # Extract theorem/lemma signatures
            for match in re.finditer(
                r"(?:theorem|lemma)\s+(\w+)(?:\s*\[[^\]]*\])?\s*(?:\([^)]*\))?\s*:\s*([^\n]+)",
                code,
            ):
                name = match.group(1)
                statement = match.group(2).strip()
                if statement and len(statement) > 10:
                    theorems.append({
                        "name": name,
                        "statement": statement,
                        "domain": getattr(job.concept, "domain", ""),
                        "source_file": lf.get("name", ""),
                    })
        return theorems

    def _llm_classify_theorems(self, theorems: List[Dict[str, str]]) -> Optional[Dict[str, Any]]:
        """Use the LLM to classify theorems into meta-insight categories."""
        if not self.pi_agent or not theorems:
            return None

        # Build compact theorem listing
        theorem_lines = []
        for i, t in enumerate(theorems[:30]):  # cap at 30 theorems per scan
            theorem_lines.append(f"{i+1}. [{t['domain']}] {t['name']}: {t['statement'][:200]}")
        theorem_text = "\n".join(theorem_lines)

        system_prompt = (
            "You are a mathematical meta-reasoner. You classify theorems by their "
            "meta-mathematical significance for an automated research system.\n\n"
            "Classify each theorem into one or more categories:\n"
            "- barrier: impossibility result, no-go theorem, undecidability, or result that "
            "constrains what proofs are possible in a domain\n"
            "- strategy: proof technique or approach that could be reused in other proofs "
            "(e.g., novel induction, construction method, reduction technique)\n"
            "- bridge: result that connects two different mathematical domains\n\n"
            "Respond with JSON only: {\"barriers\": [...], \"strategies\": [...], \"bridges\": [...]}\n"
            "Each entry: {\"name\": str, \"description\": str (1-2 sentences), \"domain\": str}\n"
            "Bridges additionally: {\"source_domain\": str, \"target_domain\": str}\n"
            "Only include theorems that genuinely fit each category. Omit trivial or standard results."
        )

        user_prompt = f"Classify these newly proved theorems:\n\n{theorem_text}"

        try:
            raw = self.pi_agent._call_ollama(system=system_prompt, user=user_prompt, timeout=60)
            parsed = self.pi_agent._parse_json_response(raw)
            if parsed and isinstance(parsed, dict):
                return parsed
        except Exception as e:
            print(f"[InsightExtractor] LLM classification failed: {e}")

        return None

    def _merge_extracted_insights(self, extracted: Dict[str, Any]) -> None:
        """Merge LLM-extracted insights into the persistent store, deduplicating."""
        # Barriers
        for b in extracted.get("barriers", []):
            if isinstance(b, dict) and b.get("description"):
                # Dedup by description similarity
                desc = b["description"][:100]
                if not any(existing["description"][:100] == desc for existing in self._insights["barriers"]):
                    self._insights["barriers"].append({
                        "id": hashlib.sha256(desc.encode()).hexdigest()[:12],
                        "theorem": b.get("name", ""),
                        "domain": b.get("domain", ""),
                        "description": b["description"],
                        "source_file": b.get("source_file", ""),
                        "discovered_at": datetime.now(timezone.utc).isoformat()[:19],
                    })

        # Strategies
        for s in extracted.get("strategies", []):
            if isinstance(s, dict) and s.get("description"):
                desc = s["description"][:100]
                if not any(existing["description"][:100] == desc for existing in self._insights["strategies"]):
                    self._insights["strategies"].append({
                        "id": hashlib.sha256(desc.encode()).hexdigest()[:12],
                        "pattern": s.get("name", ""),
                        "domain": s.get("domain", ""),
                        "description": s["description"],
                        "success_rate": 0.8,  # default; updated by feedback
                        "source_file": s.get("source_file", ""),
                    })

        # Cross-domain bridges
        for b in extracted.get("bridges", []):
            if isinstance(b, dict) and b.get("source_domain") and b.get("target_domain"):
                src, tgt = b["source_domain"], b["target_domain"]
                if not any(
                    existing.get("source_domain") == src and existing.get("target_domain") == tgt
                    for existing in self._insights["cross_domain_bridges"]
                ):
                    self._insights["cross_domain_bridges"].append({
                        "source_domain": src,
                        "target_domain": tgt,
                        "theorem": b.get("name", ""),
                        "description": b.get("description", ""),
                        "source_file": b.get("source_file", ""),
                    })

        # Cap list sizes to prevent unbounded growth
        self._insights["barriers"] = self._insights["barriers"][-100:]
        self._insights["strategies"] = self._insights["strategies"][-50:]
        self._insights["cross_domain_bridges"] = self._insights["cross_domain_bridges"][-50:]

    # ─── Cost Estimation ────────────────────────────────────────

    def _update_cost_estimates(self) -> None:
        """Update domain cost estimates from catalog_analyzer statistics."""
        if not self.catalog_analyzer:
            return
        for domain, cost in self.catalog_analyzer.estimate_all_domain_costs().items():
            self._insights["cost_estimates"][domain] = cost

    def get_cost_estimate(self, domain: str) -> float:
        """Return a 0-1 cost score for a domain. Higher = more expensive to prove in."""
        estimates = self._insights.get("cost_estimates", {})
        if domain in estimates:
            return estimates[domain].get("cost_score", 0.5)
        return 0.5  # unknown domain → medium cost

    # ─── Guardrails & Strategy Injection ────────────────────────

    def get_relevant_barriers(self, domain: str, concept_keywords: List[str] = None) -> List[Dict]:
        """Return barriers relevant to a domain and optional concept keywords."""
        barriers = self._insights.get("barriers", [])
        if not barriers:
            return []

        # Score each barrier by relevance
        scored = []
        for b in barriers:
            score = 0.0
            # Domain match
            if b.get("domain", "").lower() == domain.lower():
                score += 2.0
            elif b.get("domain", "").lower() in domain.lower() or domain.lower() in b.get("domain", "").lower():
                score += 1.0
            # Keyword match
            if concept_keywords:
                desc_lower = b.get("description", "").lower()
                name_lower = b.get("theorem", "").lower()
                for kw in concept_keywords:
                    kw_lower = kw.lower()
                    if kw_lower in desc_lower or kw_lower in name_lower:
                        score += 0.5
            if score > 0:
                scored.append((score, b))

        scored.sort(key=lambda x: -x[0])
        return [b for _, b in scored[:8]]  # top 8 most relevant

    def get_relevant_strategies(self, domain: str) -> List[Dict]:
        """Return proof strategies relevant to a domain."""
        strategies = self._insights.get("strategies", [])
        if not strategies:
            return []

        scored = []
        for s in strategies:
            score = 0.0
            if s.get("domain", "").lower() == domain.lower():
                score += 2.0
            elif s.get("domain", "").lower() in domain.lower():
                score += 1.0
            score += s.get("success_rate", 0.5) * 0.5  # prefer higher success rate
            if score > 0.5:
                scored.append((score, s))

        scored.sort(key=lambda x: -x[0])
        return [s for _, s in scored[:4]]  # top 4

    def build_guardrails_section(self, concept) -> str:
        """Build the '## Known Barriers & Impossibility Results' prompt section.

        Returns up to 3000 chars of relevant impossibility/barrier results.
        Moderate steering: presented as warnings, not hard constraints.
        """
        domain = getattr(concept, "domain", "")
        # Extract keywords from concept description
        desc = getattr(concept, "concept_description", "") or getattr(concept, "description", "") or ""
        keywords = re.findall(r"[A-Za-z]{4,}", desc)[:10]

        barriers = self.get_relevant_barriers(domain, keywords)
        if not barriers:
            return ""

        lines = ["## Known Barriers & Impossibility Results", ""]
        lines.append(
            "The following theorems from Aether's Catalog constrain what proof approaches "
            "are possible. Consider these as strong warnings — they do not make the task "
            "impossible, but any approach must account for them."
        )
        lines.append("")

        for b in barriers:
            line = f"- **{b.get('theorem', 'Unknown')}** ({b.get('domain', '')}): {b.get('description', '')}"
            lines.append(line)

        text = "\n".join(lines)
        # Cap at 3000 chars
        if len(text) > 3000:
            text = text[:2997] + "..."
        return text

    def build_strategy_hints_section(self, concept) -> str:
        """Build the '## Recommended Proof Strategies' prompt section.

        Returns up to 1000 chars of relevant proof strategy suggestions.
        """
        domain = getattr(concept, "domain", "")
        strategies = self.get_relevant_strategies(domain)
        if not strategies:
            return ""

        lines = ["## Recommended Proof Strategies", ""]
        lines.append(
            "The following proof techniques have been effective in this domain. "
            "Consider using them if applicable:"
        )
        lines.append("")

        for s in strategies:
            line = f"- **{s.get('pattern', 'Pattern')}**: {s.get('description', '')}"
            lines.append(line)

        text = "\n".join(lines)
        if len(text) > 1000:
            text = text[:997] + "..."
        return text

    # ─── Statistics ──────────────────────────────────────────────

    def stats(self) -> Dict[str, int]:
        """Return insight store statistics."""
        return {
            "barriers": len(self._insights.get("barriers", [])),
            "strategies": len(self._insights.get("strategies", [])),
            "cross_domain_bridges": len(self._insights.get("cross_domain_bridges", [])),
            "cost_estimates": len(self._insights.get("cost_estimates", {})),
            "scanned_theorems": len(self._insights.get("scanned_theorems", [])),
        }