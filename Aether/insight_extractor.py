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
            "tactic_patterns": {},   # domain -> {tactic: count, tactic_pair: count}
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

        # Extract tactic usage patterns from this cycle's Lean code
        self.extract_tactic_patterns(job)

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

    # ─── Post-Cycle Novelty Audit ────────────────────────────────

    def audit_novelty(self, job, catalog_analyzer=None) -> Optional[float]:
        """Evaluate whether a cycle's results were genuinely novel or re-treading.

        Uses LLM to compare the cycle's theorems against existing Catalog content.
        Returns a 0-1 novelty score (0 = entirely redundant, 1 = fully novel).

        This score feeds back into direction quality scoring, so directions
        that produce novel results get boosted and those producing redundant
        work get penalized.
        """
        if not self.pi_agent:
            return None

        # Collect new theorem statements
        new_theorems = self._collect_new_theorems(job)
        if not new_theorems:
            return None

        # Get existing catalog context for comparison
        domain = getattr(job.concept, "domain", "") if hasattr(job, "concept") else ""
        existing_context = ""
        if catalog_analyzer:
            existing_context = catalog_analyzer.build_focused_context(
                domain=domain,
                concept_description=" ".join(t["statement"][:80] for t in new_theorems[:5]),
                max_theorems=10,
            )[:1500]

        # Build theorem listing
        theorem_lines = [f"{t['name']}: {t['statement'][:120]}" for t in new_theorems[:15]]
        theorem_text = "\n".join(theorem_lines)

        system_prompt = (
            "You are a mathematical novelty evaluator. Compare newly proved theorems "
            "against existing results in the Catalog. Rate how novel the new results are.\n\n"
            "Respond with JSON only: {\"novelty_score\": 0.0-1.0, \"reasoning\": \"1-2 sentences\", "
            "\"redundant_theorems\": [\"list of theorem names that duplicate known results\"]}\n\n"
            "Scoring guide:\n"
            "- 0.0-0.3: Mostly duplicates or trivial extensions of known results\n"
            "- 0.4-0.6: Some novel results mixed with known territory\n"
            "- 0.7-0.9: Mostly novel, with genuine new definitions or structures\n"
            "- 1.0: Entirely new mathematical territory, no overlap"
        )

        user_prompt = f"New theorems to evaluate (domain: {domain}):\n\n{theorem_text}"
        if existing_context:
            user_prompt += f"\n\nExisting Catalog theorems for comparison:\n{existing_context}"

        try:
            raw = self.pi_agent._call_ollama(system=system_prompt, user=user_prompt, timeout=60)
            parsed = self.pi_agent._parse_json_response(raw)
            if parsed and isinstance(parsed, dict):
                score = parsed.get("novelty_score", 0.5)
                # Clamp to 0-1
                score = max(0.0, min(1.0, float(score)))
                # Store the audit result
                audits = self._insights.setdefault("novelty_audits", [])
                audits.append({
                    "exp_id": getattr(job, "exp_id", ""),
                    "domain": domain,
                    "novelty_score": score,
                    "reasoning": parsed.get("reasoning", ""),
                    "redundant_theorems": parsed.get("redundant_theorems", []),
                })
                # Cap audit history
                self._insights["novelty_audits"] = audits[-50:]
                self._save()
                return score
        except Exception as e:
            print(f"[InsightExtractor] Novelty audit failed: {e}")

        return None

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

        # Also include tactic patterns if available
        tactic_hints = self.get_tactic_hints(domain)
        if tactic_hints:
            lines.append("")
            lines.append(tactic_hints)

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
            "tactic_domains": len(self._insights.get("tactic_patterns", {})),
        }

    # ─── Proof Complexity Patterns ───────────────────────────────

    # Tactics that indicate genuine mathematical depth
    DEEP_TACTICS = {
        "induction", "rcases", "obtain", "by_contra", "by_cases",
        "omega", "linarith", "nlinarith", "field_simp", "ring_nf",
        "push_cast", "norm_cast", "ext", "funext", "conv",
        "calc", "have", "suffices", "refine", "apply",
        "exact", "constructor", "cases", "match",
    }

    # Shallow tactics that indicate trivial/automated proofs
    SHALLOW_TACTICS = {"native_decide", "decide", "rfl", "simp", "trivial"}

    def extract_tactic_patterns(self, job) -> None:
        """Extract tactic usage patterns from a job's Lean code.

        Tracks:
        - Per-domain tactic frequency (which tactics are used most)
        - Tactic pair co-occurrence (which tactics appear together)
        - Sorry density (how many sorries per file)
        - Deep-vs-shallow ratio (genuine proofs vs automated)

        These patterns inform future Aristotle prompts about what proof
        structures work in each domain.
        """
        domain = getattr(job.concept, "domain", "Unknown") if hasattr(job, "concept") else "Unknown"
        lean_files = getattr(job, "lean_files", []) or []

        patterns = self._insights.setdefault("tactic_patterns", {})
        domain_patterns = patterns.setdefault(domain, {
            "tactic_counts": {},
            "tactic_pairs": {},
            "sorry_density": 0.0,
            "deep_ratio": 0.0,
            "total_theorems": 0,
            "total_files": 0,
        })

        for lf in lean_files:
            if not isinstance(lf, dict):
                continue
            code = lf.get("code", "")
            if not code:
                continue

            domain_patterns["total_files"] = domain_patterns.get("total_files", 0) + 1

            # Count tactics
            tactic_counts = domain_patterns.get("tactic_counts", {})
            found_tactics = set()
            for tactic in self.DEEP_TACTICS | self.SHALLOW_TACTICS:
                # Match tactic at start of line (by tac_name) or standalone
                count = len(re.findall(
                    rf'(?:^|\n)\s*(?:by\s+)?{re.escape(tactic)}\b',
                    code,
                ))
                if count > 0:
                    tactic_counts[tactic] = tactic_counts.get(tactic, 0) + count
                    found_tactics.add(tactic)
            domain_patterns["tactic_counts"] = tactic_counts

            # Track tactic pairs (co-occurrence within same file)
            tactic_pairs = domain_patterns.get("tactic_pairs", {})
            found_list = sorted(found_tactics)
            for i, t1 in enumerate(found_list):
                for t2 in found_list[i+1:]:
                    pair = f"{t1}+{t2}"
                    tactic_pairs[pair] = tactic_pairs.get(pair, 0) + 1
            domain_patterns["tactic_pairs"] = tactic_pairs

            # Count theorems and sorries
            theorem_count = len(re.findall(r'(?:theorem|lemma)\s+', code))
            sorry_count = code.count("sorry")
            domain_patterns["total_theorems"] = domain_patterns.get("total_theorems", 0) + theorem_count

            # Deep vs shallow ratio
            deep_count = sum(tactic_counts.get(t, 0) for t in self.DEEP_TACTICS)
            shallow_count = sum(tactic_counts.get(t, 0) for t in self.SHALLOW_TACTICS)
            total_tactics = deep_count + shallow_count
            if total_tactics > 0:
                domain_patterns["deep_ratio"] = round(deep_count / total_tactics, 3)

            # Sorry density
            total_theorems = domain_patterns.get("total_theorems", 1)
            if total_theorems > 0:
                domain_patterns["sorry_density"] = round(
                    sorry_count / total_theorems, 4
                )

        self._save()

    def get_tactic_hints(self, domain: str) -> str:
        """Build a compact tactic hints string for the Aristotle prompt.

        Shows the most effective tactic patterns for a domain based on
        historical data.
        """
        patterns = self._insights.get("tactic_patterns", {})
        domain_patterns = patterns.get(domain, {})
        if not domain_patterns:
            return ""

        lines = ["### Proof Approach Patterns (from past cycles)", ""]

        # Top tactics
        tactic_counts = domain_patterns.get("tactic_counts", {})
        if tactic_counts:
            top_tactics = sorted(tactic_counts.items(), key=lambda x: -x[1])[:5]
            tactic_str = ", ".join(f"{t} ({n})" for t, n in top_tactics)
            lines.append(f"Most-used tactics: {tactic_str}")

        # Deep ratio
        deep_ratio = domain_patterns.get("deep_ratio", 0)
        if deep_ratio > 0:
            depth_label = "deep" if deep_ratio > 0.6 else "mixed" if deep_ratio > 0.3 else "shallow"
            lines.append(f"Proof depth profile: {deep_ratio:.0%} deep tactics ({depth_label} domain)")

        # Top tactic pairs (co-occurring tactics)
        tactic_pairs = domain_patterns.get("tactic_pairs", {})
        if tactic_pairs:
            top_pairs = sorted(tactic_pairs.items(), key=lambda x: -x[1])[:3]
            pair_str = ", ".join(f"{p} ({n})" for p, n in top_pairs)
            lines.append(f"Common tactic combos: {pair_str}")

        text = "\n".join(lines)
        return text[:800]  # cap at 800 chars