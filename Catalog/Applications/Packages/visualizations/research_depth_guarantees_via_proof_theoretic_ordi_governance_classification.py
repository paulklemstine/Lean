#!/usr/bin/env python3
"""
Proof-Theoretic Depth: Applications

Demonstrates real-world applications of ordinal depth theory to:
1. Automated proof triage — routing conjectures by complexity
2. Research novelty filtering — detecting non-trivial outputs
3. Quality governance — escalation policies for research cycles
"""

from algorithms import (
    ResearchExpr, Atom, Compose, Bridge, Iterate, Certify,
    ordinal_depth, structural_depth, innovation_score, node_count,
    is_trivial, classify_cycle, should_escalate, OrdinalValue
)
from typing import List, Tuple


# ─────────────────────────────────────────────────────────
# Application 1: Proof Triage System
# ─────────────────────────────────────────────────────────

class ProofTriageSystem:
    """
    Routes proof obligations by structural depth.

    Shallow proofs → fast tactics (decide, simp, omega)
    Medium proofs → intermediate tactics (ring, linarith, norm_num)
    Deep proofs   → full proof search (aesop, exact?, apply?)

    This mirrors how human mathematicians triage problems:
    routine calculations vs. novel arguments.
    """

    def __init__(self):
        self.shallow_threshold = OrdinalValue.from_nat(3)
        self.deep_threshold = OrdinalValue.omega()
        self.log: List[Tuple[str, str, OrdinalValue]] = []

    def triage(self, name: str, expr: ResearchExpr) -> str:
        """Classify a proof obligation and route it."""
        depth = ordinal_depth(expr)

        if depth < self.shallow_threshold:
            route = "FAST_TACTIC"
        elif depth < self.deep_threshold:
            route = "INTERMEDIATE"
        else:
            route = "FULL_SEARCH"

        self.log.append((name, route, depth))
        return route

    def report(self) -> str:
        lines = ["Proof Triage Report", "=" * 50]
        for name, route, depth in self.log:
            lines.append(f"  {name:<30} → {route:<15} (depth: {depth})")
        lines.append("")
        counts = {}
        for _, route, _ in self.log:
            counts[route] = counts.get(route, 0) + 1
        lines.append("Summary:")
        for route, count in sorted(counts.items()):
            lines.append(f"  {route}: {count}")
        return "\n".join(lines)


# ─────────────────────────────────────────────────────────
# Application 2: Novelty Filter
# ─────────────────────────────────────────────────────────

class NoveltyFilter:
    """
    Filters research outputs by novelty certification.

    Uses two criteria:
    1. Ordinal depth ≥ ω (non-triviality certificate from Theorem 2)
    2. Innovation score > threshold (cross-domain content)

    Outputs are classified as:
    - TRIVIAL: below both thresholds
    - ROUTINE: non-trivial depth but low innovation
    - NOVEL: high depth and high innovation
    """

    def __init__(self, innovation_threshold: int = 2):
        self.innovation_threshold = innovation_threshold

    def classify(self, expr: ResearchExpr) -> str:
        depth = ordinal_depth(expr)
        inn = innovation_score(expr)

        if depth < OrdinalValue.omega():
            return "TRIVIAL"
        elif inn < self.innovation_threshold:
            return "ROUTINE"
        else:
            return "NOVEL"

    def batch_classify(self, exprs: List[Tuple[str, ResearchExpr]]) -> dict:
        results = {"TRIVIAL": [], "ROUTINE": [], "NOVEL": []}
        for name, expr in exprs:
            category = self.classify(expr)
            results[category].append((name, ordinal_depth(expr), innovation_score(expr)))
        return results


# ─────────────────────────────────────────────────────────
# Application 3: Research Governance Dashboard
# ─────────────────────────────────────────────────────────

class GovernanceDashboard:
    """
    Monitors research cycles and enforces quality policies.

    Uses Theorem 4 (shallow_cycle_all_below_threshold) to certify
    that escalated cycles truly contain only bounded-complexity outputs.
    """

    def __init__(self, theta: OrdinalValue):
        self.theta = theta
        self.cycles: List[Tuple[str, List[ResearchExpr]]] = []

    def add_cycle(self, name: str, exprs: List[ResearchExpr]):
        self.cycles.append((name, exprs))

    def evaluate_all(self) -> str:
        lines = [
            "Research Governance Dashboard",
            f"Threshold: θ = {self.theta}",
            "=" * 60,
        ]

        accepted = 0
        escalated = 0

        for name, exprs in self.cycles:
            report = classify_cycle(self.theta, exprs)
            decision = "ESCALATE" if report["escalate"] else "ACCEPT"
            if report["escalate"]:
                escalated += 1
            else:
                accepted += 1

            lines.append(f"\nCycle: {name}")
            lines.append(f"  Decision: {decision}")
            lines.append(f"  Cycle depth: {report['cycle_depth']}")
            lines.append(f"  Elements: {len(report['elements'])}")

            for i, elem in enumerate(report["elements"]):
                cert = "✓ CERTIFIED" if elem["nontriviality_certified"] else "  uncertified"
                triv = " (trivial)" if elem["is_trivial"] else ""
                lines.append(
                    f"    [{i}] depth={elem['depth']}, "
                    f"inn={elem['innovation_score']}, "
                    f"sd={elem['structural_depth']}"
                    f"{triv} {cert}"
                )

        lines.append(f"\n{'='*60}")
        lines.append(f"Total: {accepted} accepted, {escalated} escalated")
        return "\n".join(lines)


# ─────────────────────────────────────────────────────────
# Demo
# ─────────────────────────────────────────────────────────

def demo_triage():
    print("\n" + "=" * 60)
    print("  APPLICATION 1: Proof Triage System")
    print("=" * 60 + "\n")

    triage = ProofTriageSystem()

    # Simulate various proof obligations
    obligations = [
        ("trivial_equality", Atom(0)),
        ("simple_composition", Compose(Atom(0), Atom(1))),
        ("bridge_argument", Bridge(Atom(0), Atom(1))),
        ("iterated_lemma", Iterate(4, Compose(Atom(0), Atom(1)))),
        ("certified_result", Certify(Compose(Atom(0), Atom(1)))),
        ("deep_bridge_cert", Certify(Bridge(Certify(Atom(0)), Bridge(Atom(1), Atom(2))))),
        ("multi_iteration", Iterate(3, Bridge(Iterate(2, Atom(0)), Atom(1)))),
    ]

    for name, expr in obligations:
        triage.triage(name, expr)

    print(triage.report())


def demo_novelty():
    print("\n" + "=" * 60)
    print("  APPLICATION 2: Novelty Filter")
    print("=" * 60 + "\n")

    nf = NoveltyFilter(innovation_threshold=2)

    outputs = [
        ("lookup_result", Atom(42)),
        ("simple_derivation", Compose(Atom(0), Atom(1))),
        ("cross_domain_link", Bridge(Atom(0), Atom(1))),
        ("certified_composition", Certify(Compose(Atom(0), Atom(1)))),
        ("novel_bridge_cert", Certify(Bridge(Atom(0), Certify(Atom(1))))),
        ("deep_novel_work",
         Certify(Bridge(
             Certify(Compose(Atom(0), Atom(1))),
             Bridge(Atom(2), Certify(Atom(3)))
         ))),
    ]

    results = nf.batch_classify(outputs)

    for category in ["NOVEL", "ROUTINE", "TRIVIAL"]:
        print(f"  {category}:")
        for name, depth, inn in results[category]:
            print(f"    {name}: depth={depth}, innovation={inn}")
        if not results[category]:
            print("    (none)")
        print()


def demo_governance():
    print("\n" + "=" * 60)
    print("  APPLICATION 3: Research Governance")
    print("=" * 60 + "\n")

    dashboard = GovernanceDashboard(theta=OrdinalValue.omega())

    # Cycle 1: All trivial — should escalate
    dashboard.add_cycle("routine_survey", [
        Atom(0), Atom(1), Compose(Atom(0), Atom(1)),
        Iterate(2, Atom(0)),
    ])

    # Cycle 2: Contains certified work — should accept
    dashboard.add_cycle("research_breakthrough", [
        Atom(0),
        Compose(Atom(0), Atom(1)),
        Certify(Compose(Atom(0), Atom(1))),
        Bridge(Certify(Atom(0)), Atom(1)),
    ])

    # Cycle 3: Deep novel work — should accept
    dashboard.add_cycle("novel_synthesis", [
        Certify(Bridge(Atom(0), Atom(1))),
        Certify(Certify(Compose(Atom(0), Atom(1)))),
        Bridge(Certify(Atom(0)), Certify(Atom(1))),
    ])

    print(dashboard.evaluate_all())


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Proof-Theoretic Depth: Applications Suite                 ║")
    print("╚════════════════════════════════════════════════════════════╝")

    demo_triage()
    demo_novelty()
    demo_governance()

    print("\n" + "=" * 60)
    print("  All applications demonstrated successfully!")
    print("=" * 60)
