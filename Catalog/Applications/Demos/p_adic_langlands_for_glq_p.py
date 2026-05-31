#!/usr/bin/env python3
"""
Demo: p-adic Langlands Correspondence for GL₂(ℚ_p)
Newton-Hodge polygon theory, slope-weight interlacing, and classification.
"""
from fractions import Fraction
from typing import NamedTuple


class HodgeTateWeights(NamedTuple):
    w1: int
    w2: int

    def tH(self) -> int:
        return self.w1 + self.w2

    def is_classical(self) -> bool:
        return self.w1 == 0 and self.w2 >= 1

    def dual(self) -> "HodgeTateWeights":
        return HodgeTateWeights(-self.w2, -self.w1)


class NewtonSlopes(NamedTuple):
    s1: Fraction
    s2: Fraction

    def tN(self) -> Fraction:
        return self.s1 + self.s2


class WeaklyAdmissibleDatum:
    def __init__(self, w: HodgeTateWeights, s: NewtonSlopes):
        assert w.w1 <= w.w2, f"Weights must be ordered: {w}"
        assert s.s1 <= s.s2, f"Slopes must be ordered: {s}"
        assert s.tN() == w.tH(), f"Endpoint mismatch: {s.tN()} != {w.tH()}"
        assert s.s1 >= w.w1, f"Newton below Hodge: {s.s1} < {w.w1}"
        self.weights = w
        self.slopes = s

    def is_ordinary(self) -> bool:
        return self.slopes.s1 == self.weights.w1 and self.slopes.s2 == self.weights.w2

    def is_supersingular(self) -> bool:
        return self.slopes.s1 == self.slopes.s2

    def monodromy_defect(self) -> Fraction:
        return self.slopes.s1 - self.weights.w1

    def classify(self) -> str:
        if self.is_ordinary():
            return "ORDINARY"
        elif self.is_supersingular():
            return "SUPERSINGULAR"
        else:
            return f"NON-ORDINARY (defect={self.monodromy_defect()})"


def breuil_mezard_multiplicity(p: int, alpha_is_pm_one: bool) -> int:
    """Breuil-Mézard multiplicity for weight 2 deformation rings."""
    return 2 if alpha_is_pm_one else 1


def enumerate_admissible_slopes(w: HodgeTateWeights, denom: int = 1):
    """Enumerate all weakly admissible slope pairs with given denominator."""
    results = []
    for num1 in range(w.w1 * denom, (w.tH() * denom) // 2 + 1):
        s1 = Fraction(num1, denom)
        s2 = Fraction(w.tH()) - s1
        if s1 <= s2 and s1 >= w.w1:
            results.append(NewtonSlopes(s1, s2))
    return results


def main():
    print("=" * 60)
    print("p-adic Langlands Correspondence: Newton-Hodge Demo")
    print("=" * 60)

    # Example 1: Weight 2 modular forms (k=2, weights (0,1))
    print("\n--- Example 1: Weight 2 (k=2, weights (0,1)) ---")
    w = HodgeTateWeights(0, 1)
    print(f"Hodge-Tate weights: {w}")
    print(f"Classical: {w.is_classical()}")
    print(f"tH = {w.tH()}")

    # Ordinary case
    s_ord = NewtonSlopes(Fraction(0), Fraction(1))
    D_ord = WeaklyAdmissibleDatum(w, s_ord)
    print(f"\nOrdinary slopes: {s_ord}")
    print(f"Classification: {D_ord.classify()}")
    print(f"Monodromy defect: {D_ord.monodromy_defect()}")

    # Supersingular case
    s_ss = NewtonSlopes(Fraction(1, 2), Fraction(1, 2))
    D_ss = WeaklyAdmissibleDatum(w, s_ss)
    print(f"\nSupersingular slopes: {s_ss}")
    print(f"Classification: {D_ss.classify()}")
    print(f"Monodromy defect: {D_ss.monodromy_defect()}")

    # Example 2: Weight 4 modular forms (k=4, weights (0,3))
    print("\n--- Example 2: Weight 4 (k=4, weights (0,3)) ---")
    w4 = HodgeTateWeights(0, 3)
    print(f"Hodge-Tate weights: {w4}")
    print(f"tH = {w4.tH()}")

    slopes = enumerate_admissible_slopes(w4, denom=1)
    print(f"\nIntegral admissible slopes:")
    for s in slopes:
        D = WeaklyAdmissibleDatum(w4, s)
        print(f"  {s} -> {D.classify()}")

    slopes_half = enumerate_admissible_slopes(w4, denom=2)
    print(f"\nHalf-integral admissible slopes:")
    for s in slopes_half:
        D = WeaklyAdmissibleDatum(w4, s)
        print(f"  ({float(s.s1):.1f}, {float(s.s2):.1f}) -> {D.classify()}")

    # Example 3: Interlacing verification
    print("\n--- Example 3: Interlacing Verification ---")
    test_cases = [
        (HodgeTateWeights(0, 5), NewtonSlopes(Fraction(1), Fraction(4))),
        (HodgeTateWeights(-2, 6), NewtonSlopes(Fraction(-1), Fraction(5))),
        (HodgeTateWeights(1, 3), NewtonSlopes(Fraction(2), Fraction(2))),
    ]
    for w, s in test_cases:
        D = WeaklyAdmissibleDatum(w, s)
        ok = (w.w1 <= s.s1 <= s.s2 <= w.w2)
        print(f"  w={w}, s=({float(s.s1)}, {float(s.s2)}): "
              f"interlacing={ok}, class={D.classify()}")

    # Example 4: Duality
    print("\n--- Example 4: Weight Duality ---")
    w_orig = HodgeTateWeights(0, 3)
    w_dual = w_orig.dual()
    w_ddual = w_dual.dual()
    print(f"Original: {w_orig}, tH={w_orig.tH()}")
    print(f"Dual:     {w_dual}, tH={w_dual.tH()}")
    print(f"Dual²:    {w_ddual}, tH={w_ddual.tH()}")
    print(f"Involution: {w_ddual == w_orig}")

    # Example 5: Breuil-Mézard multiplicities
    print("\n--- Example 5: Breuil-Mézard Multiplicities (weight 2) ---")
    for p in [5, 7, 11, 13]:
        m_gen = breuil_mezard_multiplicity(p, False)
        m_sca = breuil_mezard_multiplicity(p, True)
        print(f"  p={p}: generic={m_gen}, scalar={m_sca}")

    # Example 6: Monodromy defect symmetry
    print("\n--- Example 6: Monodromy Defect Symmetry ---")
    w6 = HodgeTateWeights(1, 7)
    for s1_num in range(1, 5):
        s1 = Fraction(s1_num)
        s2 = Fraction(w6.tH()) - s1
        if s1 <= s2:
            D = WeaklyAdmissibleDatum(w6, NewtonSlopes(s1, s2))
            delta = D.monodromy_defect()
            delta_sym = w6.w2 - s2
            print(f"  s=({s1}, {s2}): δ = {delta}, w₂-s₂ = {delta_sym}, "
                  f"symmetric: {delta == delta_sym}")

    print("\n" + "=" * 60)
    print("All examples completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Monodromy Defect Space for GL₂(ℚ_p)
Shows the space of weakly admissible data parameterized by monodromy defect.
"""
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle('Monodromy Defect and Admissible Slope Space\n'
                 'p-adic Langlands for GL₂(ℚ_p)',
                 fontsize=14, fontweight='bold')

    # Left: Admissible slope region for weights (0, k-1)
    ax = axes[0]
    for k in [2, 3, 4, 5, 6]:
        w1, w2 = 0, k - 1
        # Admissible region: w1 <= s1 <= (w1+w2)/2 (since s1 <= s2 and s1+s2=w1+w2)
        s1_range = np.linspace(w1, (w1 + w2) / 2, 100)
        s2_range = (w1 + w2) - s1_range
        defects = s1_range - w1
        ax.plot(defects, s2_range - s1_range, '-', linewidth=2, label=f'k={k}')

    ax.set_xlabel('Monodromy defect δ = s₁ - w₁', fontsize=12)
    ax.set_ylabel('Slope gap s₂ - s₁', fontsize=12)
    ax.set_title('Slope gap vs monodromy defect', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Right: Classification regions in (s1, s2) plane for k=6
    ax = axes[1]
    k = 6
    w1, w2 = 0, k - 1

    # Draw the admissible line s1 + s2 = w1 + w2
    s1_vals = np.linspace(w1, (w1 + w2) / 2, 200)
    s2_vals = (w1 + w2) - s1_vals

    # Color by classification
    colors = []
    for s1, s2 in zip(s1_vals, s2_vals):
        if abs(s1 - w1) < 0.01 and abs(s2 - w2) < 0.01:
            colors.append('green')
        elif abs(s1 - s2) < 0.01:
            colors.append('purple')
        else:
            colors.append('orange')

    ax.scatter(s1_vals, s2_vals, c=colors, s=5, zorder=3)

    # Mark special points
    ax.plot(w1, w2, 'go', markersize=12, zorder=5, label='Ordinary')
    ax.plot((w1 + w2) / 2, (w1 + w2) / 2, 'p', color='purple',
            markersize=12, zorder=5, label='Supersingular')

    # Draw boundary lines
    ax.axhline(y=w2, color='blue', linestyle='--', alpha=0.5, label=f'w₂={w2}')
    ax.axvline(x=w1, color='blue', linestyle='--', alpha=0.5, label=f'w₁={w1}')
    ax.plot([w1, w2], [w1, w2], 'k--', alpha=0.3, label='s₁=s₂')

    ax.set_xlabel('s₁ (first Newton slope)', fontsize=12)
    ax.set_ylabel('s₂ (second Newton slope)', fontsize=12)
    ax.set_title(f'Admissible slopes for k={k}\n(w₁,w₂)=({w1},{w2})', fontsize=12)
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('monodromy_defect.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved monodromy_defect.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Newton-Hodge Polygon Theory for GL₂(ℚ_p)
Shows Newton polygons above Hodge polygons with classification coloring.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from fractions import Fraction


def plot_newton_hodge(ax, w1, w2, s1, s2, title=None):
    """Plot Newton and Hodge polygons on given axes."""
    # Hodge polygon
    hp_x = [0, 1, 2]
    hp_y = [0, w1, w1 + w2]
    ax.plot(hp_x, hp_y, 'b-o', linewidth=2, markersize=8, label='Hodge polygon')
    ax.fill_between(hp_x, hp_y, alpha=0.1, color='blue')

    # Newton polygon
    np_x = [0, 1, 2]
    np_y = [0, float(s1), float(s1 + s2)]
    ax.plot(np_x, np_y, 'r-s', linewidth=2, markersize=8, label='Newton polygon')
    ax.fill_between(np_x, np_y, hp_y, alpha=0.15, color='red')

    # Classification
    if s1 == w1 and s2 == w2:
        cls = "ORDINARY"
        color = 'green'
    elif s1 == s2:
        cls = "SUPERSINGULAR"
        color = 'purple'
    else:
        cls = f"NON-ORDINARY (δ={float(s1 - w1):.2f})"
        color = 'orange'

    if title:
        ax.set_title(f"{title}\n{cls}", fontsize=11, color=color, fontweight='bold')
    else:
        ax.set_title(cls, fontsize=11, color=color, fontweight='bold')

    ax.set_xlabel('Index')
    ax.set_ylabel('Cumulative value')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_xticks([0, 1, 2])


def main():
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Newton-Hodge Polygons for GL₂(ℚ_p)\n'
                 'p-adic Langlands Correspondence',
                 fontsize=14, fontweight='bold')

    # Example 1: Weight 2, ordinary
    plot_newton_hodge(axes[0, 0], 0, 1, Fraction(0), Fraction(1),
                      "k=2, (w₁,w₂)=(0,1)")

    # Example 2: Weight 2, supersingular
    plot_newton_hodge(axes[0, 1], 0, 1, Fraction(1, 2), Fraction(1, 2),
                      "k=2, (w₁,w₂)=(0,1)")

    # Example 3: Weight 4, ordinary
    plot_newton_hodge(axes[0, 2], 0, 3, Fraction(0), Fraction(3),
                      "k=4, (w₁,w₂)=(0,3)")

    # Example 4: Weight 4, supersingular
    plot_newton_hodge(axes[1, 0], 0, 3, Fraction(3, 2), Fraction(3, 2),
                      "k=4, (w₁,w₂)=(0,3)")

    # Example 5: Weight 4, non-ordinary
    plot_newton_hodge(axes[1, 1], 0, 3, Fraction(1), Fraction(2),
                      "k=4, (w₁,w₂)=(0,3)")

    # Example 6: Non-classical weights
    plot_newton_hodge(axes[1, 2], -1, 4, Fraction(0), Fraction(3),
                      "Non-classical, (w₁,w₂)=(-1,4)")

    plt.tight_layout()
    plt.savefig('newton_hodge_polygons.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved newton_hodge_polygons.png")


if __name__ == "__main__":
    main()
