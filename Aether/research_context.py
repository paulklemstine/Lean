#!/usr/bin/env python3
"""ResearchContext: Accumulates discoveries across cycles and feeds them back
into Pi-Agent's concept generation and prompt writing.

This closes the feedback loop: after Aristotle returns results and they're
organized into the Catalog, the discoveries (theorems proved, open problems,
remaining sorries, domains touched) are stored here. On the next cycle,
Pi-Agent sees what was recently discovered and can build on it.

The context is persisted to JSON so it survives across orchestrator restarts.
"""

import json
import time
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Dict, List, Optional, Any


@dataclass
class CycleDiscovery:
    """Findings from a single completed cycle."""
    exp_id: str
    cycle_n: int
    concept_title: str
    domain: str
    research_mode: str
    quality: str  # "trivial" | "partial" | "substantial"
    timestamp: float = 0.0

    # From ARISTOTLE_SUMMARY.md
    key_theorems: List[str] = field(default_factory=list)
    domains_touched: List[str] = field(default_factory=list)
    sorries_remaining: int = 0
    files_created: List[str] = field(default_factory=list)

    # From quality evaluation
    quality_score: float = 0.0

    # Open problems or future directions mentioned in the summary
    open_problems_found: List[str] = field(default_factory=list)
    future_directions: List[str] = field(default_factory=list)

    # Raw summary excerpt (first 500 chars for context)
    summary_excerpt: str = ""

    def to_dict(self) -> Dict[str, Any]:
        return asdict(self)

    @classmethod
    def from_dict(cls, d: Dict[str, Any]) -> "CycleDiscovery":
        return cls(**{k: v for k, v in d.items() if k in cls.__dataclass_fields__})


class ResearchContext:
    """Accumulates discoveries across cycles and provides prompt fragments.

    Persists to JSON so the context survives across orchestrator restarts.
    The key method is `build_discoveries_prompt()` which gives Pi-Agent
    a running summary of what was discovered and what's still open.
    """

    MAX_DISCOVERIES = 50  # Keep last N discoveries for prompt context (increased from 30)
    MAX_OPEN_PROBLEMS = 30  # Track up to N distinct open problems (increased from 20)

    def __init__(self, workspace: Path):
        self.workspace = Path(workspace)
        self.workspace.mkdir(parents=True, exist_ok=True)
        self.state_path = self.workspace / "research_context.json"

        self.discoveries: List[CycleDiscovery] = []
        self.global_open_problems: List[str] = []  # Accumulated open problems
        self.global_theorems_proved: List[str] = []  # All theorems proved
        self.global_sorry_count: int = 0  # Running total of remaining sorries
        self.domain_success_rates: Dict[str, Dict[str, int]] = {}  # domain -> {success, total}

        self._load()

    def _load(self) -> None:
        """Load persisted context from JSON."""
        if self.state_path.exists():
            try:
                data = json.loads(self.state_path.read_text(encoding="utf-8"))
                self.discoveries = [
                    CycleDiscovery.from_dict(d) for d in data.get("discoveries", [])
                ]
                self.global_open_problems = data.get("global_open_problems", [])
                self.global_theorems_proved = data.get("global_theorems_proved", [])
                self.global_sorry_count = data.get("global_sorry_count", 0)
                self.domain_success_rates = data.get("domain_success_rates", {})
            except Exception:
                # Corrupted state — start fresh
                self.discoveries = []
                self.global_open_problems = []
                self.global_theorems_proved = []
                self.global_sorry_count = 0
                self.domain_success_rates = {}

    def save(self) -> None:
        """Persist context to JSON."""
        data = {
            "discoveries": [d.to_dict() for d in self.discoveries[-self.MAX_DISCOVERIES:]],
            "global_open_problems": self.global_open_problems[-self.MAX_OPEN_PROBLEMS:],
            "global_theorems_proved": self.global_theorems_proved[-100:],
            "global_sorry_count": self.global_sorry_count,
            "domain_success_rates": self.domain_success_rates,
        }
        self.state_path.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")

    def update_from_summary(
        self,
        exp_id: str,
        cycle_n: int,
        concept_title: str,
        domain: str,
        research_mode: str,
        quality: str,
        quality_score: float,
        summary_data: Optional[Dict[str, Any]] = None,
    ) -> CycleDiscovery:
        """Update context from a completed cycle's ARISTOTLE_SUMMARY data.

        Args:
            summary_data: Parsed dict from OutputOrganizer._parse_aristotle_summary(),
                         with keys: domains_touched, files_created, sorries_remaining,
                         key_theorems, raw_text.
        """
        discovery = CycleDiscovery(
            exp_id=exp_id,
            cycle_n=cycle_n,
            concept_title=concept_title,
            domain=domain,
            research_mode=research_mode,
            quality=quality,
            timestamp=time.time(),
            quality_score=quality_score,
        )

        if summary_data:
            discovery.key_theorems = summary_data.get("key_theorems", [])
            discovery.domains_touched = summary_data.get("domains_touched", [])
            discovery.sorries_remaining = summary_data.get("sorries_remaining", 0)
            discovery.files_created = summary_data.get("files_created", [])
            discovery.summary_excerpt = summary_data.get("raw_text", "")[:500]

            # Extract open problems and future directions from raw text
            raw = summary_data.get("raw_text", "")
            discovery.open_problems_found = self._extract_open_problems(raw)
            discovery.future_directions = self._extract_future_directions(raw)

            # Update global tracking
            self.global_theorems_proved.extend(discovery.key_theorems)
            for problem in discovery.open_problems_found:
                if problem not in self.global_open_problems:
                    self.global_open_problems.append(problem)
            self.global_sorry_count = discovery.sorries_remaining

        # Track domain success rates
        if domain not in self.domain_success_rates:
            self.domain_success_rates[domain] = {"success": 0, "total": 0}
        self.domain_success_rates[domain]["total"] += 1
        if quality in ("substantial", "partial"):
            self.domain_success_rates[domain]["success"] += 1

        self.discoveries.append(discovery)

        # Trim to max
        if len(self.discoveries) > self.MAX_DISCOVERIES:
            self.discoveries = self.discoveries[-self.MAX_DISCOVERIES:]

        self.save()
        return discovery

    def build_discoveries_prompt(self, limit: int = 10) -> str:
        """Build a prompt fragment describing recent discoveries for Pi-Agent.

        This gives Pi-Agent context about what was recently discovered so it
        can build on existing work instead of repeating or ignoring it.
        Includes strategic guidance for maximizing research quality.
        """
        if not self.discoveries:
            return ("No previous research cycles completed yet. "
                    "This is a cold start — prioritize sorry_fill on the "
                    "priority targets (CarmichaelComposite, Fib_gcd_identity) "
                    "to close known open problems, or target cross-domain "
                    "bridge theorems for novelty.")

        recent = self.discoveries[-limit:]
        lines = [f"## Recent Research Discoveries ({len(recent)} cycles)"]

        # Recent substantial discoveries — these are what to BUILD ON
        substantial = [d for d in recent if d.quality in ("substantial", "partial")]
        if substantial:
            lines.append("\n### Verified Theorems (build on these)")
            for d in substantial[-7:]:
                theorems_str = ", ".join(d.key_theorems[:6]) if d.key_theorems else "no theorems listed"
                lines.append(f"- **{d.concept_title}** ({d.domain}, {d.quality}): {theorems_str}")
                if d.future_directions:
                    for fd in d.future_directions[:2]:
                        lines.append(f"  → Future direction: {fd}")

        # Remaining open problems accumulated across cycles — PRIORITIZE these
        if self.global_open_problems:
            lines.append("\n### Accumulated Open Problems (prioritize these)")
            for problem in self.global_open_problems[-10:]:
                lines.append(f"  - {problem}")

        # Sorry count tracking
        if self.global_sorry_count > 0:
            lines.append(f"\n### Sorry Status\n{self.global_sorry_count} sorries remaining across the Catalog")

        # Domain success rates — guide Pi-Agent toward productive domains
        if self.domain_success_rates:
            lines.append("\n### Domain Success Rates")
            for domain, rates in sorted(
                self.domain_success_rates.items(),
                key=lambda x: x[1].get("success", 0) / max(x[1].get("total", 1), 1),
                reverse=True,
            )[:10]:
                total = rates.get("total", 0)
                success = rates.get("success", 0)
                rate = success / total if total > 0 else 0
                lines.append(f"  - {domain}: {success}/{total} successful ({rate:.0%})")

        # Recent failures — AVOID similar approaches
        trivial = [d for d in recent if d.quality == "trivial"]
        if trivial:
            lines.append("\n### Recent Unproductive Cycles (avoid similar approaches)")
            for d in trivial[-5:]:
                lines.append(f"  - {d.concept_title} ({d.domain}): trivial result — "
                             f"try a different angle, deeper concept, or sorry_fill instead")

        # Strategic guidance for maximizing quality
        lines.append("\n### Strategic Guidance")
        if len(substantial) > len(trivial):
            lines.append("- Recent cycles are productive. Keep pushing in successful domains "
                        "but also explore cross-domain bridges.")
        elif len(trivial) > len(substantial):
            lines.append("- Many recent cycles produced trivial results. Switch strategy: "
                        "use sorry_fill on priority targets, or target a different domain "
                        "entirely. Avoid vague or overly general concepts.")
        else:
            lines.append("- Mixed results. Focus on depth over breadth. "
                        "Target specific theorems with precise mathematical statements.")

        # Recommend high-value targets
        lines.append("- High-value targets: sorry_fill on CarmichaelComposite or "
                     "Fib_gcd_identity to close known open problems.")
        lines.append("- Cross-domain bridges (highest novelty): tropical geometry × "
                     "neural networks, number theory × cryptography, EML × approximation theory.")

        return "\n".join(lines)

    def build_theorem_context(self) -> str:
        """Build a compact list of all proved theorems for Aristotle prompt context.

        This gives Aristotle a running list of theorems it can reference
        in its proof work, so it builds on existing results.
        Includes file locations so Aristotle can import them.
        """
        if not self.global_theorems_proved:
            return ""

        # Map theorems to their source files for better referencing
        theorem_file_map = {
            # Our manually verified files
            'regret_nonneg': 'MachineLearning/SelfImproving/AristotleLoopVerification',
            'ucb_ge_mean': 'MachineLearning/SelfImproving/AristotleLoopVerification',
            'information_bound': 'MachineLearning/SelfImproving/AristotleLoopVerification',
            'eml_exp': 'Bridges/AlgebraEMLBridge',
            'eml_add_bridge': 'Bridges/AlgebraEMLBridge',
            'synergy_superadditivity': 'MachineLearning/SelfImproving/AristotleLoopVerification',
            # Aristotle-verified files
            'linftyNorm_nonneg': 'Tropical/NeuralNetworks/TropicalDegreeRobustness',
            'tropical_monomial_lipschitz': 'Tropical/NeuralNetworks/TropicalDegreeRobustness',
            'margin_preservation': 'Tropical/NeuralNetworks/TropicalDegreeRobustness',
            'certifiedRobustness_from_margin': 'Tropical/NeuralNetworks/TropicalDegreeRobustness',
            'tropicalLipschitzBound': 'Tropical/NeuralNetworks/TropicalDegreeRobustness',
            'satakeImage_weyl_invariant': 'Tropical/Langlands/SatakeIsomorphism',
            'satakeImage_eq_nsmul_max': 'Tropical/Langlands/SatakeIsomorphism',
            'satakeTransform_bijective': 'Tropical/Langlands/SatakeIsomorphism',
            'bridge_lemma': 'Shared/CarmichaelProof',
            'fib_carmichael_composite': 'Shared/CarmichaelProof',
            'primPart_implies_primitive': 'Shared/CarmichaelProof',
        }

        # Deduplicate and limit
        unique = list(dict.fromkeys(self.global_theorems_proved))[:40]

        lines = ["Previously proved theorems (verified, compile via `lake build`):"]
        lines.append("")
        for t in unique:
            file = theorem_file_map.get(t, "verified file")
            lines.append(f"  - {t} (from {file})")

        lines.append("")
        lines.append("These theorems can be imported and USED in new proofs.")
        lines.append("Build on them — extend verified results to new domains.")
        return "\n".join(lines)

    def get_best_domains(self, limit: int = 5) -> List[str]:
        """Return domains with highest success rates for guiding concept selection."""
        if not self.domain_success_rates:
            return []
        scored = []
        for domain, rates in self.domain_success_rates.items():
            total = rates.get("total", 0)
            success = rates.get("success", 0)
            rate = success / total if total > 0 else 0
            scored.append((domain, rate, total))
        scored.sort(key=lambda x: (-x[1], -x[2]))
        return [d for d, _, _ in scored[:limit]]

    def _extract_open_problems(self, raw_text: str) -> List[str]:
        """Extract open problem mentions from ARISTOTLE_SUMMARY raw text."""
        problems = []
        # Look for patterns like "open problem", "remaining sorry", "still unproved"
        for line in raw_text.splitlines():
            lower = line.lower().strip()
            if any(kw in lower for kw in ("open problem", "still open", "still unproved",
                                           "remaining sorry", "needs proof", "unresolved")):
                # Clean up the line
                clean = line.strip().lstrip("-•* ").strip()
                if clean and len(clean) > 10:
                    problems.append(clean[:200])
        return problems[:5]  # Cap at 5 per cycle

    def _extract_future_directions(self, raw_text: str) -> List[str]:
        """Extract future direction mentions from ARISTOTLE_SUMMARY raw text."""
        directions = []
        for line in raw_text.splitlines():
            lower = line.lower().strip()
            if any(kw in lower for kw in ("future direction", "next step", "could extend",
                                           "would be interesting", "further work")):
                clean = line.strip().lstrip("-•* ").strip()
                if clean and len(clean) > 10:
                    directions.append(clean[:200])
        return directions[:3]  # Cap at 3 per cycle