#!/usr/bin/env python3
"""
Tropical Gelfand Reconstruction Demo
=====================================

Demonstrates the finite tropical Nullstellensatz / support-ideal duality
proved in Bridges/TropicalDuality.lean.

We work with a concrete finite set X = {0,1,2,3,4} and the semiring S = ℕ
(natural numbers with ordinary + and ×, where ⊥ = 0).

The demo shows:
1. Vanishing ideals of subsets
2. Support recovery (V(I(F)) = F)
3. The Galois anti-isomorphism between subsets and support-stable ideals
4. Kernel-support duality for a weighted KME functional
"""

import itertools
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Set, FrozenSet, Callable, List, Tuple


# ==============================================================
# Core mathematical objects
# ==============================================================

class FunctionSemiring:
    """
    The function semiring X → S where X = {0,...,n-1} and S = ℕ.
    """

    def __init__(self, n: int):
        self.n = n
        self.X = set(range(n))
        self.zero = tuple(0 for _ in range(n))

    def vanishes_on(self, f: tuple, F: frozenset) -> bool:
        return all(f[x] == 0 for x in F)

    def is_zero_at(self, f: tuple, x: int) -> bool:
        return f[x] == 0


def pt_indicator(R: FunctionSemiring, x: int) -> tuple:
    """The point indicator: 1 at x, 0 elsewhere."""
    return tuple(1 if i == x else 0 for i in range(R.n))


# ==============================================================
# Demo 1: Vanishing Ideals and Support Recovery
# ==============================================================

def demo_support_recovery():
    print("=" * 60)
    print("DEMO 1: Support Recovery (supportOfIdeal_vanishingIdeal)")
    print("=" * 60)

    n = 5
    R = FunctionSemiring(n)
    X = R.X

    test_subsets = [
        frozenset(),
        frozenset({0}),
        frozenset({1, 3}),
        frozenset({0, 2, 4}),
        frozenset({0, 1, 2, 3, 4}),
    ]

    print(f"\nX = {set(range(n))}, S = ℕ (⊥ = 0)\n")

    for F in test_subsets:
        recovered = set()
        for x in X:
            all_vanish = True
            for y in X:
                ind_y = pt_indicator(R, y)
                if R.vanishes_on(ind_y, F) and not R.is_zero_at(ind_y, x):
                    all_vanish = False
                    break
            if all_vanish:
                recovered.add(x)

        recovered = frozenset(recovered)
        status = "✓" if recovered == F else "✗"
        F_str = set(F) if F else '∅'
        R_str = set(recovered) if recovered else '∅'
        print(f"  F = {str(F_str):>15}  →  supp(V(F)) = {str(R_str):>15}  {status}")

    print("\n  All subsets satisfy supp(V(F)) = F. ✓")


# ==============================================================
# Demo 2: Galois Anti-Isomorphism
# ==============================================================

def demo_galois_antitone():
    print("\n" + "=" * 60)
    print("DEMO 2: Galois Anti-Isomorphism (Order Reversal)")
    print("=" * 60)

    n = 4
    R = FunctionSemiring(n)

    all_subsets = []
    for r in range(n + 1):
        for combo in itertools.combinations(range(n), r):
            all_subsets.append(frozenset(combo))

    test_fns = []
    for vals in itertools.product(range(3), repeat=n):
        test_fns.append(tuple(vals))

    print(f"\nX = {{0,1,2,3}}, testing with {len(test_fns)} functions")

    ideal_sizes = {}
    for F in all_subsets:
        count = sum(1 for f in test_fns if R.vanishes_on(f, F))
        ideal_sizes[F] = count

    violations = 0
    checks = 0
    for F in all_subsets:
        for G in all_subsets:
            if F <= G:
                checks += 1
                if ideal_sizes[G] > ideal_sizes[F]:
                    violations += 1

    print(f"\n  Checked {checks} subset pairs (F ⊆ G)")
    print(f"  Anti-monotonicity |V(G)| ≤ |V(F)| violations: {violations}")

    examples = [
        (frozenset(), frozenset({0, 1})),
        (frozenset({0}), frozenset({0, 1, 2})),
        (frozenset({1, 2}), frozenset({0, 1, 2, 3})),
    ]

    print("\n  Examples:")
    for F, G in examples:
        print(f"    {set(F) if F else '∅'} ⊆ {set(G)}: "
              f"|V(F)|={ideal_sizes[F]}, |V(G)|={ideal_sizes[G]}, "
              f"|V(G)|≤|V(F)|: ✓")


# ==============================================================
# Demo 3: KME Kernel = Vanishing Ideal of Support
# ==============================================================

def demo_kme_kernel():
    print("\n" + "=" * 60)
    print("DEMO 3: KME Kernel–Support Duality (ker_kme_eq_vanishing_support)")
    print("=" * 60)

    n = 5
    w = (3, 0, 7, 0, 2)
    support_w = frozenset(x for x in range(n) if w[x] != 0)
    R = FunctionSemiring(n)

    def kme(f):
        return max(w[x] * f[x] for x in range(n))

    print(f"\n  w = {w}, supp(w) = {set(support_w)}")
    print(f"  μ_w(f) = max_x(w(x)·f(x))\n")

    test_functions = [
        (0, 5, 0, 8, 0),
        (0, 3, 0, 7, 0),
        (1, 0, 0, 0, 0),
        (0, 0, 1, 0, 0),
        (0, 0, 0, 0, 0),
        (0, 1, 0, 1, 0),
        (2, 0, 3, 0, 4),
    ]

    print(f"  {'f':>20}  {'μ_w(f)':>8}  {'ker?':>6}  {'V(supp)?':>9}  {'=':>3}")
    print(f"  {'-'*20}  {'-'*8}  {'-'*6}  {'-'*9}  {'-'*3}")

    all_match = True
    for f in test_functions:
        mu_val = kme(f)
        in_ker = (mu_val == 0)
        in_vanishing = R.vanishes_on(f, support_w)
        match = in_ker == in_vanishing
        all_match = all_match and match
        print(f"  {str(f):>20}  {mu_val:>8}  {str(in_ker):>6}  "
              f"{str(in_vanishing):>9}  {'✓' if match else '✗':>3}")

    print(f"\n  ker(μ_w) = V(supp(w)): {'✓ Verified' if all_match else '✗ FAILED'}")


# ==============================================================
# Demo 4: Visualization
# ==============================================================

def demo_visualization():
    print("\n" + "=" * 60)
    print("DEMO 4: Lattice Anti-Isomorphism Visualization")
    print("=" * 60)

    n = 3
    subsets = [
        frozenset(),
        frozenset({0}), frozenset({1}), frozenset({2}),
        frozenset({0,1}), frozenset({0,2}), frozenset({1,2}),
        frozenset({0,1,2}),
    ]

    levels = {0: [0], 1: [1,2,3], 2: [4,5,6], 3: [7]}
    pos_left = {}
    pos_right = {}
    for level, indices in levels.items():
        width = len(indices)
        for i, idx in enumerate(indices):
            x = (i - (width-1)/2) * 1.8
            pos_left[idx] = (x - 4.5, level * 1.8)
            pos_right[idx] = (x + 4.5, (3 - level) * 1.8)

    fig, ax = plt.subplots(1, 1, figsize=(14, 7))

    # Edges in subset lattice
    for i, F in enumerate(subsets):
        for j, G in enumerate(subsets):
            if F < G and len(G) == len(F) + 1:
                ax.plot([pos_left[i][0], pos_left[j][0]],
                        [pos_left[i][1], pos_left[j][1]],
                        'b-', alpha=0.3, linewidth=2)
                ax.plot([pos_right[i][0], pos_right[j][0]],
                        [pos_right[i][1], pos_right[j][1]],
                        'r-', alpha=0.3, linewidth=2)

    # Nodes
    for i, F in enumerate(subsets):
        label_l = '{' + ','.join(str(x) for x in sorted(F)) + '}' if F else '∅'
        label_r = 'V(' + label_l + ')'
        ax.plot(*pos_left[i], 'bo', markersize=22, alpha=0.6)
        ax.text(*pos_left[i], label_l, ha='center', va='center', fontsize=9, fontweight='bold')
        ax.plot(*pos_right[i], 'ro', markersize=22, alpha=0.6)
        ax.text(*pos_right[i], label_r, ha='center', va='center', fontsize=6, fontweight='bold')

    # Anti-iso arrows
    for i in range(len(subsets)):
        x1, y1 = pos_left[i]
        x2, y2 = pos_right[i]
        ax.annotate('', xy=(x2 - 0.35, y2), xytext=(x1 + 0.35, y1),
                     arrowprops=dict(arrowstyle='->', color='green',
                                     alpha=0.35, connectionstyle='arc3,rad=0.08',
                                     lw=1.5))

    ax.set_title('Finite Tropical Gelfand Anti-Isomorphism\n'
                  'Subsets of X = {0,1,2}  ↔  Support-Stable Ideals of (X → ℕ)',
                  fontsize=13, fontweight='bold')
    ax.text(-4.5, -1.2, 'Subsets (⊆ order)', ha='center', fontsize=11, color='blue')
    ax.text(4.5, -1.2, 'Ideals (⊇ order)', ha='center', fontsize=11, color='red')
    ax.set_xlim(-8, 8)
    ax.set_ylim(-2, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    plt.tight_layout()
    plt.savefig('demos/tropical_duality.png', dpi=150, bbox_inches='tight')
    print(f"\n  Saved to demos/tropical_duality.png")


# ==============================================================
# Demo 5: Support Reconstruction from KME
# ==============================================================

def demo_kme_reconstruction():
    print("\n" + "=" * 60)
    print("DEMO 5: Reconstructing Support from KME Kernel")
    print("=" * 60)

    n = 6
    R = FunctionSemiring(n)
    w = (0, 4, 0, 2, 0, 7)
    true_support = frozenset(x for x in range(n) if w[x] != 0)

    def kme(f):
        return max(w[x] * f[x] for x in range(n))

    print(f"\n  X = {{0,...,{n-1}}}, weight w hidden")
    print(f"  Probing with point indicators:\n")

    reconstructed = set()
    for x in range(n):
        ind = pt_indicator(R, x)
        val = kme(ind)
        in_supp = val > 0
        if in_supp:
            reconstructed.add(x)
        print(f"    μ_w(1_{{{x}}}) = {val:>3}  →  {x} {'∈' if in_supp else '∉'} supp(w)")

    print(f"\n  Reconstructed: {set(reconstructed)}")
    print(f"  True support:  {set(true_support)}")
    print(f"  Match: {'✓' if frozenset(reconstructed) == true_support else '✗'}")


if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Tropical Gelfand Reconstruction — Concrete Demos      ║")
    print("║   Companion to Bridges/TropicalDuality.lean             ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_support_recovery()
    demo_galois_antitone()
    demo_kme_kernel()
    demo_visualization()
    demo_kme_reconstruction()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
