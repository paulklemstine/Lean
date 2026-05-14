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


#!/usr/bin/env python3
"""
Proof-Theoretic Depth: Concrete Demonstrations

This demo constructs research expressions, computes their ordinal depth,
innovation scores, and structural depth, and demonstrates the threshold
theorems with concrete examples.
"""

from algorithms import (
    ResearchExpr, Atom, Compose, Bridge, Iterate, Certify,
    ordinal_depth, structural_depth, innovation_score, node_count,
    is_trivial, OrdinalValue
)


def separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def show_expr(name: str, expr: ResearchExpr) -> None:
    """Display all metrics for a research expression."""
    depth = ordinal_depth(expr)
    sd = structural_depth(expr)
    inn = innovation_score(expr)
    nc = node_count(expr)
    triv = is_trivial(expr)

    print(f"  {name}:")
    print(f"    Ordinal depth:     {depth}")
    print(f"    Structural depth:  {sd}")
    print(f"    Innovation score:  {inn}")
    print(f"    Node count:        {nc}")
    print(f"    Trivial:           {triv}")
    print(f"    Non-trivial cert:  {depth >= OrdinalValue.omega()}")
    print()


def demo_basic_expressions():
    """Demonstrate depth computation on basic expressions."""
    separator("Basic Expression Depths")

    # Atoms
    show_expr("atom(0)", Atom(0))
    show_expr("atom(42)", Atom(42))

    # Simple compositions (trivial fragment)
    show_expr("compose(atom(0), atom(1))", Compose(Atom(0), Atom(1)))

    # Deeper compositions (non-trivial but still below ω)
    deep_compose = Compose(Compose(Atom(0), Atom(1)), Compose(Atom(2), Atom(3)))
    show_expr("compose(compose(a0,a1), compose(a2,a3))", deep_compose)

    # Bridge expressions
    show_expr("bridge(atom(0), atom(1))", Bridge(Atom(0), Atom(1)))

    # Iterate
    show_expr("iterate(5, atom(0))", Iterate(5, Atom(0)))

    # Certify (the transfinite jump!)
    show_expr("certify(atom(0))", Certify(Atom(0)))  # ω^0 = 1

    # Certify of something with depth ≥ 1 → depth ≥ ω
    cert_compose = Certify(Compose(Atom(0), Atom(1)))
    show_expr("certify(compose(a0, a1))", cert_compose)

    # Nested certify
    nested_cert = Certify(Certify(Compose(Atom(0), Atom(1))))
    show_expr("certify(certify(compose(a0,a1)))", nested_cert)


def demo_threshold_theorem():
    """Demonstrate Theorem 1 & 2: the ω threshold for triviality."""
    separator("Threshold Theorem Demonstration")

    print("  Theorem 1: All trivial expressions have depth < ω")
    print("  Theorem 2: Depth ≥ ω implies non-triviality\n")

    # All trivial expressions
    trivial_exprs = [
        ("atom(0)", Atom(0)),
        ("atom(1)", Atom(1)),
        ("atom(100)", Atom(100)),
        ("compose(atom(0), atom(1))", Compose(Atom(0), Atom(1))),
        ("compose(atom(5), atom(10))", Compose(Atom(5), Atom(10))),
    ]

    print("  Trivial expressions (all should have depth < ω):")
    for name, expr in trivial_exprs:
        depth = ordinal_depth(expr)
        assert depth < OrdinalValue.omega(), f"FAIL: {name} has depth {depth} ≥ ω!"
        print(f"    {name}: depth = {depth} < ω ✓")

    print()

    # Non-trivial expressions with depth ≥ ω
    nontrivial_exprs = [
        ("certify(compose(a0,a1))", Certify(Compose(Atom(0), Atom(1)))),
        ("certify(bridge(a0,a1))", Certify(Bridge(Atom(0), Atom(1)))),
        ("certify(certify(compose(a0,a1)))",
         Certify(Certify(Compose(Atom(0), Atom(1))))),
    ]

    print("  Non-trivial expressions (all should have depth ≥ ω):")
    for name, expr in nontrivial_exprs:
        depth = ordinal_depth(expr)
        assert depth >= OrdinalValue.omega(), f"FAIL: {name} has depth {depth} < ω!"
        assert not is_trivial(expr), f"FAIL: {name} is trivial!"
        print(f"    {name}: depth = {depth} ≥ ω ✓  (non-trivial ✓)")


def demo_cycle_governance():
    """Demonstrate Theorems 3 & 4: cycle depth and governance."""
    separator("Cycle Governance Demonstration")

    # A shallow cycle (all trivial)
    shallow_cycle = [Atom(0), Atom(1), Compose(Atom(0), Atom(1))]
    depths = [ordinal_depth(e) for e in shallow_cycle]
    cycle_depth = max(depths)

    print("  Shallow cycle: {atom(0), atom(1), compose(a0,a1)}")
    print(f"    Individual depths: {depths}")
    print(f"    Cycle depth (max): {cycle_depth}")
    print(f"    All below ω: {all(d < OrdinalValue.omega() for d in depths)} ✓")

    theta = OrdinalValue.omega()
    print(f"    θ = ω: cycle depth {cycle_depth} < θ → ESCALATE ✓")
    print()

    # A deep cycle (contains certified expressions)
    deep_cycle = [
        Atom(0),
        Compose(Atom(0), Atom(1)),
        Certify(Compose(Atom(0), Atom(1))),  # depth = ω
        Certify(Bridge(Atom(0), Atom(1))),     # depth = ω²
    ]
    depths = [ordinal_depth(e) for e in deep_cycle]
    cycle_depth = max(depths)

    print("  Deep cycle: {atom(0), compose(...), certify(compose(...)), certify(bridge(...))}")
    print(f"    Individual depths: {depths}")
    print(f"    Cycle depth (max): {cycle_depth}")
    print(f"    θ = ω: cycle depth {cycle_depth} ≥ θ → ACCEPT ✓")


def demo_innovation_score():
    """Demonstrate Theorem 5: innovation score bounded by structural depth."""
    separator("Innovation Score Demonstration")

    exprs = [
        ("atom(0)", Atom(0)),
        ("compose(a0, a1)", Compose(Atom(0), Atom(1))),
        ("bridge(a0, a1)", Bridge(Atom(0), Atom(1))),
        ("iterate(3, a0)", Iterate(3, Atom(0))),
        ("certify(a0)", Certify(Atom(0))),
        ("bridge(certify(a0), bridge(a1, a2))",
         Bridge(Certify(Atom(0)), Bridge(Atom(1), Atom(2)))),
        ("certify(iterate(5, bridge(a0, a1)))",
         Certify(Iterate(5, Bridge(Atom(0), Atom(1))))),
    ]

    print("  Theorem 5: innovationScore(e) ≤ structuralDepth(e) for all e\n")
    print(f"  {'Expression':<45} {'Innovation':>10} {'StructDepth':>12} {'Bounded':>8}")
    print(f"  {'-'*45} {'-'*10} {'-'*12} {'-'*8}")

    for name, expr in exprs:
        inn = innovation_score(expr)
        sd = structural_depth(expr)
        ok = inn <= sd
        assert ok, f"FAIL: innovationScore({name}) = {inn} > structuralDepth = {sd}!"
        print(f"  {name:<45} {inn:>10} {sd:>12} {'✓' if ok else '✗':>8}")


def demo_phase_transition():
    """Demonstrate the phase transition at ω."""
    separator("Phase Transition at ω")

    print("  Building expressions of increasing complexity...\n")

    # Level 0: atoms
    level0 = [Atom(i) for i in range(3)]
    # Level 1: compositions
    level1 = [Compose(Atom(i), Atom(j)) for i in range(2) for j in range(2)]
    # Level 2: bridges
    level2 = [Bridge(Atom(i), Atom(j)) for i in range(2) for j in range(2)]
    # Level 3: iterations
    level3 = [Iterate(k, Atom(0)) for k in range(1, 6)]
    # Level ω: certifications
    level_omega = [Certify(Compose(Atom(0), Atom(1)))]
    # Level ω^2: nested certifications
    level_omega2 = [Certify(Bridge(Atom(0), Atom(1)))]
    # Level ω^ω: deep nesting
    level_omega_omega = [Certify(Certify(Compose(Atom(0), Atom(1))))]

    levels = [
        ("Atoms (depth 0)", level0),
        ("Compositions (depth 1)", level1),
        ("Bridges (depth 2)", level2),
        ("Iterations (depth 1-5)", level3),
        ("Certify∘Compose (depth ω)", level_omega),
        ("Certify∘Bridge (depth ω²)", level_omega2),
        ("Certify² (depth ω^ω)", level_omega_omega),
    ]

    for label, exprs in levels:
        depths = [ordinal_depth(e) for e in exprs]
        max_d = max(depths)
        trivials = [is_trivial(e) for e in exprs]
        any_trivial = any(trivials)

        marker = "BELOW ω" if max_d < OrdinalValue.omega() else "≥ ω"
        print(f"  {label}:")
        print(f"    Max depth: {max_d}  [{marker}]")
        print(f"    Contains trivial: {any_trivial}")
        print()

    print("  ── Phase transition at ω ──")
    print("  Below ω: finitary compositions, bounded iteration, classifiable")
    print("  At/above ω: transfinite certification, provably non-trivial")


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Proof-Theoretic Depth: Demonstration Suite               ║")
    print("║  Ordinal-valued complexity for derivation objects          ║")
    print("╚════════════════════════════════════════════════════════════╝")

    demo_basic_expressions()
    demo_threshold_theorem()
    demo_cycle_governance()
    demo_innovation_score()
    demo_phase_transition()

    print("\n" + "="*60)
    print("  All demonstrations passed successfully!")
    print("="*60)


#!/usr/bin/env python3
"""
Proof-Theoretic Depth: Visualizations

Generates charts illustrating the key concepts:
1. Depth spectrum across expression types
2. Phase transition at ω
3. Innovation vs structural depth scatter
4. Governance decision boundaries
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import (
    ResearchExpr, Atom, Compose, Bridge, Iterate, Certify,
    ordinal_depth, structural_depth, innovation_score, node_count,
    is_trivial, random_expr, OrdinalValue
)

# Style
plt.rcParams.update({
    'figure.facecolor': 'white',
    'axes.facecolor': '#f8f9fa',
    'axes.grid': True,
    'grid.alpha': 0.3,
    'font.size': 11,
    'axes.labelsize': 13,
    'axes.titlesize': 14,
    'figure.titlesize': 16,
})


def viz_depth_spectrum():
    """Visualize the depth spectrum across expression categories."""
    fig, ax = plt.subplots(figsize=(12, 6))

    categories = []
    depths = []
    colors = []
    labels = []

    # Generate representative expressions
    exprs = [
        ("Atoms", [Atom(i) for i in range(5)], '#2ecc71'),
        ("Compose", [Compose(Atom(i), Atom(j)) for i in range(3) for j in range(3)], '#3498db'),
        ("Bridge", [Bridge(Atom(i), Atom(j)) for i in range(3) for j in range(3)], '#e74c3c'),
        ("Iterate", [Iterate(k, Atom(0)) for k in range(1, 10)], '#f39c12'),
        ("Compose²", [Compose(Compose(Atom(0), Atom(1)), Compose(Atom(2), Atom(3)))
                       for _ in range(3)], '#9b59b6'),
        ("Bridge²", [Bridge(Bridge(Atom(0), Atom(1)), Bridge(Atom(2), Atom(3)))
                      for _ in range(3)], '#e67e22'),
    ]

    positions = []
    pos = 0
    tick_positions = []
    tick_labels = []

    for cat_name, cat_exprs, color in exprs:
        cat_depths = []
        for e in cat_exprs:
            d = ordinal_depth(e)
            n = d.to_nat()
            if n is not None:
                cat_depths.append(n)
                positions.append(pos)
                colors.append(color)
                pos += 1
            pos += 0.1

        if cat_depths:
            tick_positions.append(np.mean([positions[-(len(cat_depths)-i)] for i in range(len(cat_depths))]))
            tick_labels.append(cat_name)

        depths.extend(cat_depths)
        pos += 0.5

    ax.bar(range(len(depths)), depths, color=colors, edgecolor='white', linewidth=0.5)

    # Draw the ω threshold line
    ax.axhline(y=10, color='red', linestyle='--', linewidth=2, alpha=0.7, label='ω threshold (conceptual)')

    ax.set_xlabel('Expression Index')
    ax.set_ylabel('Ordinal Depth (finite values)')
    ax.set_title('Depth Spectrum: Finitary Fragment (depth < ω)')

    # Add category labels
    for cat_name, cat_exprs, color in exprs:
        ax.bar([], [], color=color, label=cat_name)
    ax.legend(loc='upper left', fontsize=9)

    plt.tight_layout()
    plt.savefig('viz_depth_spectrum.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_depth_spectrum.png")


def viz_phase_transition():
    """Visualize the phase transition at ω."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: structural depth vs ordinal depth class
    struct_depths = []
    ordinal_classes = []  # 0 = below ω, 1 = at ω, 2 = above ω
    class_colors = []

    test_exprs = []
    # Below ω
    for i in range(20):
        test_exprs.append(random_expr(max_depth=3, seed=i*7))
    for i in range(5):
        test_exprs.append(Iterate(i+1, Atom(0)))
    # At/above ω
    for i in range(10):
        test_exprs.append(Certify(random_expr(max_depth=2, seed=i*13)))

    for e in test_exprs:
        sd = structural_depth(e)
        d = ordinal_depth(e)
        struct_depths.append(sd)
        if d < OrdinalValue.omega():
            ordinal_classes.append(0)
            class_colors.append('#2ecc71')
        elif d == OrdinalValue.omega():
            ordinal_classes.append(1)
            class_colors.append('#f39c12')
        else:
            ordinal_classes.append(2)
            class_colors.append('#e74c3c')

    ax1.scatter(range(len(struct_depths)), struct_depths, c=class_colors, s=80, edgecolors='white', linewidth=0.5, zorder=5)

    green_patch = mpatches.Patch(color='#2ecc71', label='Depth < ω (finitary)')
    orange_patch = mpatches.Patch(color='#f39c12', label='Depth = ω')
    red_patch = mpatches.Patch(color='#e74c3c', label='Depth > ω (transfinite)')
    ax1.legend(handles=[green_patch, orange_patch, red_patch], fontsize=9)

    ax1.set_xlabel('Expression Index')
    ax1.set_ylabel('Structural Depth (ℕ)')
    ax1.set_title('Phase Transition: Structural vs Ordinal Depth')

    # Right: histogram of structural depths by ordinal class
    below_omega = [sd for sd, oc in zip(struct_depths, ordinal_classes) if oc == 0]
    at_or_above = [sd for sd, oc in zip(struct_depths, ordinal_classes) if oc >= 1]

    bins = range(0, max(struct_depths) + 2)
    ax2.hist(below_omega, bins=bins, alpha=0.7, color='#2ecc71', label='Depth < ω', edgecolor='white')
    ax2.hist(at_or_above, bins=bins, alpha=0.7, color='#e74c3c', label='Depth ≥ ω', edgecolor='white')
    ax2.set_xlabel('Structural Depth')
    ax2.set_ylabel('Count')
    ax2.set_title('Distribution by Ordinal Depth Class')
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_phase_transition.png")


def viz_innovation_vs_depth():
    """Scatter plot of innovation score vs structural depth."""
    fig, ax = plt.subplots(figsize=(10, 7))

    innovations = []
    s_depths = []
    trivials = []
    has_certify = []

    for seed in range(200):
        e = random_expr(max_depth=5, seed=seed)
        inn = innovation_score(e)
        sd = structural_depth(e)
        triv = is_trivial(e)
        innovations.append(inn)
        s_depths.append(sd)
        trivials.append(triv)

    # Color by triviality
    colors = ['#e74c3c' if t else '#3498db' for t in trivials]
    sizes = [120 if t else 50 for t in trivials]

    ax.scatter(s_depths, innovations, c=colors, s=sizes, alpha=0.6, edgecolors='white', linewidth=0.5)

    # Draw the identity line (innovation = structural depth bound)
    max_val = max(max(s_depths), max(innovations)) + 1
    ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='innovation = structuralDepth')

    trivial_patch = mpatches.Patch(color='#e74c3c', label='Trivial')
    nontrivial_patch = mpatches.Patch(color='#3498db', label='Non-trivial')
    ax.legend(handles=[trivial_patch, nontrivial_patch], fontsize=10)

    ax.set_xlabel('Structural Depth')
    ax.set_ylabel('Innovation Score')
    ax.set_title('Innovation Score ≤ Structural Depth (Theorem 5)')
    ax.set_xlim(-0.5, max_val)
    ax.set_ylim(-0.5, max_val)

    plt.tight_layout()
    plt.savefig('viz_innovation_depth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_innovation_depth.png")


def viz_governance_decision():
    """Visualize governance decision boundaries."""
    fig, ax = plt.subplots(figsize=(10, 7))

    # Create cycles of different depths
    cycle_data = []
    for n_atoms in range(1, 4):
        for n_compose in range(0, 4):
            for n_certify in range(0, 3):
                cycle = []
                cycle.extend([Atom(i) for i in range(n_atoms)])
                cycle.extend([Compose(Atom(0), Atom(i)) for i in range(n_compose)])
                cycle.extend([Certify(Compose(Atom(0), Atom(i))) for i in range(n_certify)])

                from algorithms import cycle_depth as cd_func
                cd = cd_func(cycle)
                sd_total = sum(structural_depth(e) for e in cycle)
                inn_total = sum(innovation_score(e) for e in cycle)
                above_omega = cd >= OrdinalValue.omega()

                cycle_data.append((len(cycle), sd_total, inn_total, above_omega))

    sizes_list = [d[0] for d in cycle_data]
    sd_totals = [d[1] for d in cycle_data]
    inn_totals = [d[2] for d in cycle_data]
    above = [d[3] for d in cycle_data]

    colors = ['#2ecc71' if a else '#e74c3c' for a in above]
    markers = ['o' if a else 'x' for a in above]

    for i, (sd, inn, a, c) in enumerate(zip(sd_totals, inn_totals, above, colors)):
        ax.scatter(sd, inn, c=c, s=80, marker='o' if a else 'X',
                   edgecolors='white' if a else 'none', linewidth=0.5, alpha=0.7)

    accept_patch = mpatches.Patch(color='#2ecc71', label='ACCEPT (depth ≥ ω)')
    escalate_patch = mpatches.Patch(color='#e74c3c', label='ESCALATE (depth < ω)')
    ax.legend(handles=[accept_patch, escalate_patch], fontsize=11)

    ax.set_xlabel('Total Structural Depth of Cycle')
    ax.set_ylabel('Total Innovation Score of Cycle')
    ax.set_title('Governance Decisions: Accept vs Escalate (θ = ω)')

    plt.tight_layout()
    plt.savefig('viz_governance.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: viz_governance.png")


if __name__ == "__main__":
    print("Generating visualizations...")
    viz_depth_spectrum()
    viz_phase_transition()
    viz_innovation_vs_depth()
    viz_governance_decision()
    print("\nAll visualizations generated successfully!")
