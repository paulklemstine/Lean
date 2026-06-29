#!/usr/bin/env python3
"""
Tropical Proof-Net Realization Duality — Demonstration

This script demonstrates the core mathematical concepts:
1. Weighted consequence systems with tropical (min-plus) costs
2. Entailment kernel computation
3. Residual equivalence and quotient construction
4. Minimal realization via profile-based compression

All computations use ℕ∞ = {0, 1, 2, ...} ∪ {∞} with min as ⊕ and + as ⊗.
"""

import itertools
from typing import Dict, List, Optional, Set, Tuple
import math

INF = float('inf')


# ============================================================
# §1. Core Definitions
# ============================================================

class WeightedHornRule:
    """A weighted Horn rule: premises ⟹ conclusion with cost weight."""
    def __init__(self, premises: Set[int], conclusion: int, weight: float):
        self.premises = premises
        self.conclusion = conclusion
        self.weight = weight

    def __repr__(self):
        prems = ", ".join(str(p) for p in sorted(self.premises))
        return f"{{{prems}}} ⟹ {self.conclusion} [cost={self.weight}]"


class WeightedConsequenceSystem:
    """A weighted consequence system over a finite formula set.

    The closure operator is computed as the least fixed point of applying
    Horn rules: for each rule A ⟹ b with weight w, if all premises in A
    have finite cost, then b gets cost min(current, sum_of_premise_costs + w).
    """
    def __init__(self, num_formulas: int, rules: List[WeightedHornRule]):
        self.n = num_formulas
        self.formulas = list(range(num_formulas))
        self.rules = rules

    def closure(self, x: List[float], max_iter: int = 100) -> List[float]:
        """Compute the closure C(x) by iterating rule application to fixed point.

        The closure satisfies:
        - Extensiveness: C(x)[f] ≤ x[f]
        - Monotonicity: x ≤ y ⟹ C(x) ≤ C(y)
        - Idempotency: C(C(x)) = C(x)
        """
        result = list(x)
        for _ in range(max_iter):
            changed = False
            for rule in self.rules:
                # Cost to fire this rule: sum of premise costs + rule weight
                premise_cost = sum(result[p] for p in rule.premises)
                if premise_cost < INF:
                    new_cost = premise_cost + rule.weight
                    if new_cost < result[rule.conclusion]:
                        result[rule.conclusion] = new_cost
                        changed = True
            if not changed:
                break
        return result

    def singleton_cost(self, p: int) -> List[float]:
        """δ_p: cost ⊥=0 at p, cost ⊤=∞ elsewhere."""
        return [0.0 if i == p else INF for i in range(self.n)]

    def entailment_kernel(self) -> List[List[float]]:
        """Compute K(p,q) = C(δ_p)(q) for all p, q."""
        return [self.closure(self.singleton_cost(p)) for p in self.formulas]

    def residual_classes(self, K: List[List[float]]) -> Dict[Tuple, List[int]]:
        """Group formulas by their kernel row (residual profile)."""
        classes: Dict[Tuple, List[int]] = {}
        for p in self.formulas:
            row = tuple(K[p])
            if row not in classes:
                classes[row] = []
            classes[row].append(p)
        return classes


# ============================================================
# §2. Example Systems
# ============================================================

def example_identity():
    """Identity closure: no rules, so C(x) = x."""
    print("=" * 60)
    print("Example 1: Identity Closure on {0, 1}")
    print("=" * 60)
    sys = WeightedConsequenceSystem(2, [])
    K = sys.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K, sys.n)
    classes = sys.residual_classes(K)
    print(f"\nResidual classes: {len(classes)}")
    for profile, members in classes.items():
        print(f"  {members} → profile {format_profile(profile)}")
    print(f"\nQuotient size: {len(classes)} (= original size {sys.n})")
    print("→ No compression possible (identity closure).")
    return K, classes


def example_linear_chain():
    """Linear chain: 0→1 (cost 2), 1→2 (cost 3), 2→3 (cost 5)."""
    print("\n" + "=" * 60)
    print("Example 2: Linear Chain {0 → 1 → 2 → 3}")
    print("=" * 60)
    rules = [
        WeightedHornRule({0}, 1, 2),
        WeightedHornRule({1}, 2, 3),
        WeightedHornRule({2}, 3, 5),
    ]
    sys = WeightedConsequenceSystem(4, rules)
    print("\nRules:")
    for r in rules:
        print(f"  {r}")
    K = sys.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K, sys.n)
    classes = sys.residual_classes(K)
    print(f"\nResidual classes: {len(classes)}")
    for profile, members in classes.items():
        print(f"  {members} → profile {format_profile(profile)}")

    # Verify properties
    print("\nProperty verification:")
    print(f"  Self-entailment = ⊥: {all(K[p][p] == 0 for p in range(sys.n))}")
    print(f"  Triangle inequality: {check_triangle(K, sys.n)}")
    return K, classes


def example_diamond():
    """Diamond: 0→1 (cost 2), 0→2 (cost 2), 1→3 (cost 3), 2→3 (cost 3)."""
    print("\n" + "=" * 60)
    print("Example 3: Diamond System")
    print("     0")
    print("    / \\")
    print("   1   2   (both edges cost 2)")
    print("    \\ /")
    print("     3     (both edges cost 3)")
    print("=" * 60)
    rules = [
        WeightedHornRule({0}, 1, 2),
        WeightedHornRule({0}, 2, 2),
        WeightedHornRule({1}, 3, 3),
        WeightedHornRule({2}, 3, 3),
    ]
    sys = WeightedConsequenceSystem(4, rules)
    K = sys.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K, sys.n)
    classes = sys.residual_classes(K)
    print(f"\nResidual classes: {len(classes)}")
    for profile, members in classes.items():
        print(f"  {members} → profile {format_profile(profile)}")
    print(f"\nOriginal: {sys.n}, Quotient: {len(classes)}")
    print("→ No compression: although symmetric, formulas 1 and 2")
    print("  differ because K(1,1)=0 ≠ K(1,2)=∞ and vice versa.")
    print("  Self-derivation cost distinguishes every formula.")
    return K, classes


def example_conjunction():
    """Conjunction rule: {0,1}→2 (cost 1), showing multi-premise rules."""
    print("\n" + "=" * 60)
    print("Example 4: Multi-premise (Conjunction) Rules")
    print("  {0, 1} ⟹ 2 [cost 1]")
    print("  {2} ⟹ 3 [cost 4]")
    print("=" * 60)
    rules = [
        WeightedHornRule({0, 1}, 2, 1),
        WeightedHornRule({2}, 3, 4),
    ]
    sys = WeightedConsequenceSystem(4, rules)
    K = sys.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K, sys.n)
    classes = sys.residual_classes(K)
    print(f"\nResidual classes: {len(classes)}")
    for profile, members in classes.items():
        print(f"  {members} → profile {format_profile(profile)}")
    print("\nNote: The conjunction rule {0,1}⟹2 requires BOTH premises.")
    print("Since singleton cost δ_0 assigns ∞ to formula 1, the rule")
    print("cannot fire from premise 0 alone. K(0,2) = ∞.")
    return K, classes


def example_asymmetric():
    """Asymmetric system showing non-trivial quotient."""
    print("\n" + "=" * 60)
    print("Example 5: Asymmetric System with Non-trivial Quotient")
    print("  0→1 [cost 2], 0→2 [cost 2]")
    print("  1→3 [cost 1], 2→3 [cost 1]")
    print("  1→4 [cost 5], 2→4 [cost 5]")
    print("=" * 60)
    rules = [
        WeightedHornRule({0}, 1, 2),
        WeightedHornRule({0}, 2, 2),
        WeightedHornRule({1}, 3, 1),
        WeightedHornRule({2}, 3, 1),
        WeightedHornRule({1}, 4, 5),
        WeightedHornRule({2}, 4, 5),
    ]
    sys = WeightedConsequenceSystem(5, rules)
    K = sys.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K, sys.n)
    classes = sys.residual_classes(K)
    print(f"\nResidual classes: {len(classes)}")
    for profile, members in classes.items():
        print(f"  {members} → profile {format_profile(profile)}")
    print(f"\nOriginal formulas: {sys.n}, Quotient size: {len(classes)}")
    return K, classes


# ============================================================
# §3. Utility Functions
# ============================================================

def format_val(v: float) -> str:
    return "∞" if v == INF else str(int(v))


def format_profile(profile: Tuple) -> str:
    return "(" + ", ".join(format_val(v) for v in profile) + ")"


def print_kernel(K: List[List[float]], n: int):
    # Header
    header = "     " + "  ".join(f"{q:>4}" for q in range(n))
    print(header)
    print("     " + "  ".join("----" for _ in range(n)))
    for p in range(n):
        row = " ".join(f"{format_val(K[p][q]):>5}" for q in range(n))
        print(f"  {p}: {row}")


def check_triangle(K: List[List[float]], n: int) -> bool:
    """Check tropical triangle inequality: K(p,r) ≤ K(p,q) + K(q,r)."""
    for p in range(n):
        for q in range(n):
            for r in range(n):
                if K[p][r] > K[p][q] + K[q][r] + 1e-10:
                    return False
    return True


# ============================================================
# §4. Visualization (text-based)
# ============================================================

def visualize_quotient(n: int, classes: Dict[Tuple, List[int]]):
    """Visualize the quotient as a text diagram."""
    print("\n┌─────────────────────────────┐")
    print("│     Quotient Realization    │")
    print("├─────────────────────────────┤")
    for i, (profile, members) in enumerate(classes.items()):
        members_str = ", ".join(str(m) for m in members)
        label = "{" + members_str + "}"
        print(f"│  Class {i}: {label:>12s}         │")
    print("├─────────────────────────────┤")
    print(f"│  {n} formulas → {len(classes)} classes    │")
    ratio = len(classes) / n
    bar_len = int(ratio * 20)
    bar = "█" * bar_len + "░" * (20 - bar_len)
    print(f"│  [{bar}] {ratio:.0%}  │")
    print("└─────────────────────────────┘")


# ============================================================
# §5. Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Proof-Net Realization Duality — Demonstrations ║")
    print("║  Computing entailment kernels and minimal quotients     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    K1, c1 = example_identity()
    visualize_quotient(2, c1)

    K2, c2 = example_linear_chain()
    visualize_quotient(4, c2)

    K3, c3 = example_diamond()
    visualize_quotient(4, c3)

    K4, c4 = example_conjunction()
    visualize_quotient(4, c4)

    K5, c5 = example_asymmetric()

    # Example with actual compression
    print("\n" + "=" * 60)
    print("Example 6: Bidirectional Rules (actual compression)")
    print("  0↔1 [cost 0], 2↔3 [cost 0], 0→2 [cost 5]")
    print("=" * 60)
    rules6 = [
        WeightedHornRule({0}, 1, 0),
        WeightedHornRule({1}, 0, 0),
        WeightedHornRule({2}, 3, 0),
        WeightedHornRule({3}, 2, 0),
        WeightedHornRule({0}, 2, 5),
    ]
    sys6 = WeightedConsequenceSystem(4, rules6)
    K6 = sys6.entailment_kernel()
    print("\nEntailment Kernel K(p,q):")
    print_kernel(K6, sys6.n)
    c6 = sys6.residual_classes(K6)
    print(f"\nResidual classes: {len(c6)}")
    for profile, members in c6.items():
        print(f"  {members} → profile {format_profile(profile)}")
    print(f"\n→ Compression! 4 formulas → {len(c6)} classes")
    print("  0≋1 and 2≋3 because zero-cost bidirectional rules")
    print("  make them interchangeable in all derivation contexts.")
    visualize_quotient(4, c6)
    visualize_quotient(5, c5)

    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"  Example 1 (Identity):     2 → {len(c1)} classes (no compression)")
    print(f"  Example 2 (Chain):        4 → {len(c2)} classes")
    print(f"  Example 3 (Diamond):      4 → {len(c3)} classes")
    print(f"  Example 4 (Conjunction):  4 → {len(c4)} classes")
    print(f"  Example 5 (Asymmetric):   5 → {len(c5)} classes")
    print()
    print("Key insight: The residual quotient automatically detects")
    print("and merges formulas with identical derivation-cost profiles,")
    print("yielding the unique minimal representation of the system.")


#!/usr/bin/env python3
"""Generate visualizations for the Tropical Proof-Net Realization Duality."""

import base64
import io
import json

def create_kernel_heatmap_svg(K, n, title="Entailment Kernel"):
    """Create an SVG heatmap of the kernel matrix."""
    INF = float('inf')
    cell_size = 60
    margin = 80
    w = margin + n * cell_size + 20
    h = margin + n * cell_size + 40

    # Find finite max for color scaling
    finite_vals = [K[i][j] for i in range(n) for j in range(n) if K[i][j] < INF]
    max_val = max(finite_vals) if finite_vals else 1

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    svg += f'<text x="{w//2}" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">{title}</text>\n'

    # Column headers
    for j in range(n):
        x = margin + j * cell_size + cell_size // 2
        svg += f'<text x="{x}" y="{margin - 10}" text-anchor="middle" font-size="13" fill="#555">q={j}</text>\n'

    # Row headers
    for i in range(n):
        y = margin + i * cell_size + cell_size // 2 + 5
        svg += f'<text x="{margin - 15}" y="{y}" text-anchor="end" font-size="13" fill="#555">p={i}</text>\n'

    for i in range(n):
        for j in range(n):
            x = margin + j * cell_size
            y = margin + i * cell_size
            val = K[i][j]

            if val == INF:
                color = "#2c3e50"
                text_color = "#ecf0f1"
                label = "∞"
            elif val == 0:
                color = "#27ae60"
                text_color = "white"
                label = "0"
            else:
                intensity = 1 - (val / max_val) * 0.7
                r = int(52 + (255 - 52) * intensity)
                g = int(152 + (255 - 152) * intensity)
                b = int(219 + (255 - 219) * intensity)
                color = f"rgb({r},{g},{b})"
                text_color = "#2c3e50" if intensity > 0.5 else "white"
                label = str(int(val))

            svg += f'<rect x="{x}" y="{y}" width="{cell_size}" height="{cell_size}" fill="{color}" stroke="#bdc3c7" stroke-width="1"/>\n'
            svg += f'<text x="{x + cell_size//2}" y="{y + cell_size//2 + 5}" text-anchor="middle" font-size="14" font-weight="bold" fill="{text_color}">{label}</text>\n'

    svg += '</svg>'
    return svg


def create_quotient_diagram_svg(classes, n):
    """Create an SVG diagram showing the quotient construction."""
    num_classes = len(classes)
    w = max(400, num_classes * 120 + 100)
    h = 250

    svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}">\n'
    svg += f'<rect width="{w}" height="{h}" fill="white"/>\n'
    svg += f'<text x="{w//2}" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Residual Quotient: {n} formulas → {num_classes} classes</text>\n'

    # Draw original formulas
    svg += f'<text x="30" y="70" font-size="12" fill="#777">Original:</text>\n'
    for i in range(n):
        x = 30 + i * 50
        svg += f'<circle cx="{x + 25}" cy="100" r="18" fill="#3498db" stroke="#2980b9" stroke-width="2"/>\n'
        svg += f'<text x="{x + 25}" y="105" text-anchor="middle" font-size="13" fill="white" font-weight="bold">{i}</text>\n'

    # Arrow
    svg += f'<text x="{w//2}" y="145" text-anchor="middle" font-size="20" fill="#e74c3c">↓ quotient</text>\n'

    # Draw classes
    svg += f'<text x="30" y="180" font-size="12" fill="#777">Quotient:</text>\n'
    class_list = list(classes.values())
    spacing = min(120, (w - 80) / max(num_classes, 1))
    for idx, members in enumerate(class_list):
        x = 40 + idx * spacing
        members_str = ",".join(str(m) for m in members)
        color = "#e74c3c" if len(members) > 1 else "#9b59b6"
        svg += f'<rect x="{x}" y="190" width="{spacing - 10}" height="40" rx="8" fill="{color}" stroke="#8e44ad" stroke-width="2"/>\n'
        svg += f'<text x="{x + (spacing-10)//2}" y="215" text-anchor="middle" font-size="12" fill="white" font-weight="bold">{{{members_str}}}</text>\n'

    svg += '</svg>'
    return svg


if __name__ == "__main__":
    from demo import (WeightedHornRule, WeightedConsequenceSystem)
    INF = float('inf')

    # Example 2: Linear chain
    rules2 = [
        WeightedHornRule({0}, 1, 2),
        WeightedHornRule({1}, 2, 3),
        WeightedHornRule({2}, 3, 5),
    ]
    sys2 = WeightedConsequenceSystem(4, rules2)
    K2 = sys2.entailment_kernel()
    svg_chain = create_kernel_heatmap_svg(K2, 4, "Entailment Kernel: Linear Chain")

    # Example 6: Bidirectional (compression)
    rules6 = [
        WeightedHornRule({0}, 1, 0),
        WeightedHornRule({1}, 0, 0),
        WeightedHornRule({2}, 3, 0),
        WeightedHornRule({3}, 2, 0),
        WeightedHornRule({0}, 2, 5),
    ]
    sys6 = WeightedConsequenceSystem(4, rules6)
    K6 = sys6.entailment_kernel()
    c6 = sys6.residual_classes(K6)
    svg_bidir = create_kernel_heatmap_svg(K6, 4, "Entailment Kernel: Bidirectional")
    svg_quotient = create_quotient_diagram_svg(c6, 4)

    # Save SVGs
    with open("kernel_chain.svg", "w") as f:
        f.write(svg_chain)
    with open("kernel_bidir.svg", "w") as f:
        f.write(svg_bidir)
    with open("quotient_bidir.svg", "w") as f:
        f.write(svg_quotient)

    print("Generated: kernel_chain.svg, kernel_bidir.svg, quotient_bidir.svg")
