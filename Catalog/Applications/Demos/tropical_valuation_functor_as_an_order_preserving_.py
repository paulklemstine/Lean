#!/usr/bin/env python3
"""
Tropical Valuation Functor — Demo

Demonstrates the key results:
1. p-adic tropical valuation properties
2. Bridge theorem verification
3. Tropical convex hull membership
4. Surjectivity conjecture testing
"""

from algorithms import (
    padic_valuation,
    coord_valuation,
    tropical_lincomb_bound,
    verify_bridge_theorem,
    tropical_convex_hull_membership,
)
from math import inf


def demo_valuation_properties():
    """Demonstrate the four tropical valuation axioms."""
    print("=" * 60)
    print("§1. Tropical Valuation Properties (p=2)")
    print("=" * 60)

    p = 2
    print(f"\n  v(0) = {padic_valuation(p, 0)} (should be ∞)")
    print(f"  v(1) = {padic_valuation(p, 1)} (should be 0)")

    # Multiplicativity
    a, b = 12, 20
    print(f"\n  Multiplicativity: v({a}·{b}) = v({a*b})")
    print(f"    v({a*b}) = {padic_valuation(p, a*b)}")
    print(f"    v({a}) + v({b}) = {padic_valuation(p, a)} + {padic_valuation(p, b)} = {padic_valuation(p, a) + padic_valuation(p, b)}")
    assert padic_valuation(p, a*b) == padic_valuation(p, a) + padic_valuation(p, b)
    print("    ✓ Multiplicativity holds!")

    # Ultrametric inequality
    a, b = 12, 20
    v_sum = padic_valuation(p, a + b)
    v_min = min(padic_valuation(p, a), padic_valuation(p, b))
    print(f"\n  Ultrametric: v({a}+{b}) = v({a+b}) = {v_sum}")
    print(f"    min(v({a}), v({b})) = min({padic_valuation(p, a)}, {padic_valuation(p, b)}) = {v_min}")
    assert v_sum >= v_min
    print(f"    {v_sum} ≥ {v_min} ✓ Ultrametric holds!")

    # Demonstrate strict inequality case (cancellation!)
    a, b = 4, 4
    v_sum = padic_valuation(p, a + b)
    v_min = min(padic_valuation(p, a), padic_valuation(p, b))
    print(f"\n  Cancellation case: v({a}+{b}) = v({a+b}) = {v_sum}")
    print(f"    min(v({a}), v({b})) = {v_min}")
    print(f"    Strict: {v_sum} > {v_min} (cancellation increases valuation!)")


def demo_bridge_theorem():
    """Demonstrate the bridge theorem with concrete examples."""
    print("\n" + "=" * 60)
    print("§2. Bridge Theorem: Algebra → Tropical Convexity")
    print("=" * 60)

    p = 2
    # Two generators in ℤ²
    generators = [[6, 10], [12, 5]]
    coeffs = [3, 4]

    print(f"\n  Prime p = {p}")
    print(f"  Generators: x₁ = {generators[0]}, x₂ = {generators[1]}")
    print(f"  Coefficients: c = {coeffs}")
    print(f"  Linear combination: {coeffs[0]}·{generators[0]} + {coeffs[1]}·{generators[1]}")

    combo = [coeffs[0]*generators[0][j] + coeffs[1]*generators[1][j] for j in range(2)]
    print(f"    = {combo}")

    actual, bound = tropical_lincomb_bound(p, coeffs, generators)
    print(f"\n  Coordinatewise valuation: v₂({combo}) = {actual}")
    print(f"  Tropical bound:          inf_i(v(cᵢ) + v(xᵢⱼ)) = {bound}")

    ok = verify_bridge_theorem(p, coeffs, generators)
    for j in range(2):
        sym = "≥" if actual[j] >= bound[j] else "<"
        print(f"    Coord {j}: {actual[j]} {sym} {bound[j]}")
    print(f"  Bridge theorem verified: {ok} ✓")


def demo_tropical_hull():
    """Demonstrate tropical convex hull membership."""
    print("\n" + "=" * 60)
    print("§3. Tropical Convex Hull Membership")
    print("=" * 60)

    p = 2
    # Generator valuations
    generators = [[6, 10], [12, 5]]
    v_gens = [coord_valuation(p, g) for g in generators]
    print(f"\n  Generator valuations:")
    for i, (g, vg) in enumerate(zip(generators, v_gens)):
        print(f"    v₂({g}) = {vg}")

    # The valuation of a linear combination
    coeffs = [3, 4]
    combo = [coeffs[0]*generators[0][j] + coeffs[1]*generators[1][j] for j in range(2)]
    v_combo = coord_valuation(p, combo)
    print(f"\n  Linear combination: {combo}")
    print(f"  Its valuation: v₂({combo}) = {v_combo}")

    # Check hull membership
    is_member, lambdas = tropical_convex_hull_membership(v_combo, v_gens)
    print(f"\n  Is v₂(combination) in tropConvHull(v₂(generators))?")
    print(f"    Answer: {is_member}")
    if lambdas:
        print(f"    Tropical coefficients: λ = {lambdas}")
        print(f"    (Compare with v₂(c) = {coord_valuation(p, coeffs)})")


def demo_iterated_ultrametric():
    """Demonstrate the iterated ultrametric inequality."""
    print("\n" + "=" * 60)
    print("§4. Iterated Ultrametric Inequality")
    print("=" * 60)

    p = 3
    values = [9, 27, 6, 15, 81]
    print(f"\n  Prime p = {p}")
    print(f"  Values: {values}")
    v_vals = [padic_valuation(p, x) for x in values]
    print(f"  Valuations: {v_vals}")

    total = sum(values)
    v_total = padic_valuation(p, total)
    v_inf = min(v_vals)

    print(f"\n  Sum = {total}")
    print(f"  v₃(sum) = {v_total}")
    print(f"  inf(v₃(values)) = {v_inf}")
    print(f"  {v_total} ≥ {v_inf}: {'✓' if v_total >= v_inf else '✗'}")


def demo_product_formula():
    """Demonstrate v(∏ aᵢ) = ∑ v(aᵢ)."""
    print("\n" + "=" * 60)
    print("§5. Product Formula: v(∏ aᵢ) = ∑ v(aᵢ)")
    print("=" * 60)

    p = 2
    values = [6, 10, 14, 3]
    print(f"\n  Prime p = {p}")
    print(f"  Values: {values}")

    product = 1
    for v in values:
        product *= v

    v_product = padic_valuation(p, product)
    sum_v = sum(padic_valuation(p, x) for x in values)

    print(f"  Product = {product}")
    print(f"  v₂(product) = {v_product}")
    print(f"  ∑ v₂(values) = {sum_v}")
    print(f"  Equal: {v_product == sum_v} ✓")


def demo_surjectivity_test():
    """Test the surjectivity conjecture."""
    print("\n" + "=" * 60)
    print("§6. Surjectivity Conjecture Test")
    print("=" * 60)

    p = 2
    generators = [[2, 3], [4, 5]]
    max_c = 30

    v_gens = [coord_valuation(p, g) for g in generators]
    print(f"\n  Prime p = {p}")
    print(f"  Generators: {generators}")
    print(f"  Valuation images: {v_gens}")

    achieved = set()
    for c1 in range(max_c + 1):
        for c2 in range(max_c + 1):
            combo = [c1*generators[0][j] + c2*generators[1][j] for j in range(2)]
            v = tuple(int(padic_valuation(p, x)) if padic_valuation(p, x) != inf else 999 for x in combo)
            achieved.add(v)

    print(f"\n  Achieved valuation pairs (c₁,c₂ ∈ {{0,...,{max_c}}}):")
    achieved_finite = sorted([a for a in achieved if 999 not in a])
    print(f"    {len(achieved_finite)} distinct finite pairs")
    print(f"    Sample: {achieved_finite[:15]}...")

    # Check what the tropical hull predicts
    print(f"\n  Tropical hull of {v_gens}:")
    print(f"    {{(min(λ₁+{v_gens[0][0]}, λ₂+{v_gens[1][0]}), min(λ₁+{v_gens[0][1]}, λ₂+{v_gens[1][1]})) : λ₁,λ₂ ∈ ℕ∞}}")
    print(f"    This is a large set; comparing coverage...")

    # Check a specific target point
    target = (0, 0)
    print(f"\n  Is {target} achievable?")
    found = target in achieved_finite
    print(f"    {found}")
    if found:
        # Find a witness
        for c1 in range(max_c + 1):
            for c2 in range(max_c + 1):
                combo = [c1*generators[0][0] + c2*generators[1][0],
                         c1*generators[0][1] + c2*generators[1][1]]
                if combo[0] > 0 and combo[1] > 0:
                    v = (int(padic_valuation(p, combo[0])), int(padic_valuation(p, combo[1])))
                    if v == target:
                        print(f"    Witness: c=({c1},{c2}), combination={combo}, v₂={v}")
                        break
            else:
                continue
            break


if __name__ == "__main__":
    demo_valuation_properties()
    demo_bridge_theorem()
    demo_tropical_hull()
    demo_iterated_ultrametric()
    demo_product_formula()
    demo_surjectivity_test()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Tropical Valuation Bridge

Plots the achieved valuation pairs for a linear combination,
showing the bridge theorem inequality visually.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import inf


def padic_valuation(p: int, n: int) -> float:
    if n == 0:
        return inf
    if n < 0:
        n = abs(n)
    k = 0
    while n % p == 0:
        k += 1
        n //= p
    return k


def main():
    p = 2
    generators = [[2, 3], [4, 5]]
    max_c = 50

    achieved_x = []
    achieved_y = []

    for c1 in range(max_c + 1):
        for c2 in range(max_c + 1):
            combo = [c1 * generators[0][j] + c2 * generators[1][j] for j in range(2)]
            v0 = padic_valuation(p, combo[0])
            v1 = padic_valuation(p, combo[1])
            if v0 != inf and v1 != inf:
                achieved_x.append(v0)
                achieved_y.append(v1)

    # Generator valuations
    gen_vals = [[padic_valuation(p, g[j]) for j in range(2)] for g in generators]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Achieved valuation pairs
    ax = axes[0]
    ax.scatter(achieved_x, achieved_y, s=8, alpha=0.5, c='steelblue', label='Achieved v₂ pairs')
    for i, gv in enumerate(gen_vals):
        ax.plot(gv[0], gv[1], 'r*', markersize=15, label=f'Generator {i+1}: {gv}')
    ax.set_xlabel('v₂(coordinate 1)', fontsize=12)
    ax.set_ylabel('v₂(coordinate 2)', fontsize=12)
    ax.set_title(f'Achieved Valuation Pairs\np={p}, generators={generators}', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(-0.5, 10.5)
    ax.grid(True, alpha=0.3)

    # Plot 2: Bridge theorem verification
    ax = axes[1]
    # For specific coefficients, show actual vs bound
    test_cases = [(1, 0), (0, 1), (1, 1), (2, 1), (1, 2), (3, 5), (7, 3), (4, 6)]
    actual_vals = []
    bound_vals = []
    labels = []

    for c1, c2 in test_cases:
        combo = [c1 * generators[0][j] + c2 * generators[1][j] for j in range(2)]
        v_c1, v_c2 = padic_valuation(p, c1), padic_valuation(p, c2)
        for j in range(2):
            actual = padic_valuation(p, combo[j])
            bound = min(v_c1 + padic_valuation(p, generators[0][j]),
                        v_c2 + padic_valuation(p, generators[1][j]))
            if actual != inf and bound != inf:
                actual_vals.append(actual)
                bound_vals.append(bound)
                labels.append(f'c=({c1},{c2}),j={j}')

    x_pos = np.arange(len(actual_vals))
    width = 0.35
    ax.bar(x_pos - width/2, actual_vals, width, label='v(∑cᵢxᵢⱼ)', color='steelblue')
    ax.bar(x_pos + width/2, bound_vals, width, label='inf(v(cᵢ)+v(xᵢⱼ))', color='coral')
    ax.set_xlabel('Test case', fontsize=12)
    ax.set_ylabel('Valuation', fontsize=12)
    ax.set_title('Bridge Theorem: Actual ≥ Bound', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_xticks(x_pos)
    ax.set_xticklabels([f'{i}' for i in range(len(actual_vals))], fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('tropical_valuation_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved tropical_valuation_bridge.png")


if __name__ == "__main__":
    main()
