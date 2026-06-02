#!/usr/bin/env python3
"""
Cellular Automata as Algebraic Geometry: Demonstration
=====================================================

This script demonstrates the core results:
1. Zhegalkin polynomial representation of ECA rules
2. Fixed-point variety analysis across all 256 rules
3. Correlation between algebraic degree and Wolfram complexity class
4. Complement duality theorem verification
"""

import numpy as np
from algorithms import (
    eca_local_rule, eca_update, find_fixed_points,
    zhegalkin_coefficients, polynomial_degree,
    is_linear_rule, is_affine_rule,
    complement_rule, wolfram_class_heuristic,
    fixed_point_dimension, gf2_rank, fixed_point_matrix
)


def demo_zhegalkin_representation():
    """Demonstrate the Zhegalkin polynomial representation theorem."""
    print("=" * 70)
    print("THEOREM: Zhegalkin Polynomial Representation")
    print("Every function GF(2)^3 → GF(2) has a unique multilinear polynomial.")
    print("=" * 70)

    notable_rules = {
        0: "Zero (all outputs 0)",
        30: "Wolfram's favorite chaotic rule",
        90: "Sierpinski triangle generator",
        110: "Turing-complete rule",
        150: "XOR rule (linear)",
        184: "Traffic flow model",
        204: "Identity rule",
        255: "All-ones rule",
    }

    monomial_names = {
        '1': '1', 'a': 'a', 'b': 'b', 'c': 'c',
        'ab': 'ab', 'ac': 'ac', 'bc': 'bc', 'abc': 'abc'
    }

    for r, desc in notable_rules.items():
        coeffs = zhegalkin_coefficients(r)
        terms = [monomial_names[k] for k, v in coeffs.items() if v]
        poly = ' + '.join(terms) if terms else '0'
        deg = polynomial_degree(r)
        print(f"\n  Rule {r:3d} ({desc}):")
        print(f"    g(a,b,c) = {poly}")
        print(f"    Degree: {deg}, Linear: {is_linear_rule(r)}, Affine: {is_affine_rule(r)}")

    # Verify faithfulness for all 256 rules
    all_correct = True
    for r in range(256):
        coeffs = zhegalkin_coefficients(r)
        for a in [0, 1]:
            for b in [0, 1]:
                for c in [0, 1]:
                    # Evaluate polynomial
                    val = (coeffs['1'] + coeffs['a']*a + coeffs['b']*b + coeffs['c']*c
                           + coeffs['ab']*a*b + coeffs['ac']*a*c + coeffs['bc']*b*c
                           + coeffs['abc']*a*b*c) % 2
                    if val != eca_local_rule(r, a, b, c):
                        all_correct = False

    print(f"\n  Verification: Zhegalkin representation correct for all 256 rules: {all_correct}")


def demo_fixed_point_analysis():
    """Analyze fixed-point varieties for all 256 rules."""
    print("\n" + "=" * 70)
    print("FIXED-POINT VARIETY ANALYSIS")
    print("V(f) = { s ∈ GF(2)^n : f(s) = s } — the algebraic fixed-point set")
    print("=" * 70)

    n_values = [4, 6, 8, 10]

    # Focus on notable rules
    notable = [0, 30, 90, 110, 150, 184, 204, 255]

    for n in n_values:
        print(f"\n  n = {n} cells:")
        print(f"  {'Rule':>6s}  {'|Fix|':>6s}  {'dim':>6s}  {'deg':>4s}  {'linear':>7s}")
        print(f"  {'----':>6s}  {'-----':>6s}  {'---':>6s}  {'---':>4s}  {'------':>7s}")
        for r in notable:
            fps = find_fixed_points(r, n)
            count = len(fps)
            dim = np.log2(count) if count > 0 else -1
            deg = polynomial_degree(r)
            lin = is_linear_rule(r)
            print(f"  {r:6d}  {count:6d}  {dim:6.1f}  {deg:4d}  {str(lin):>7s}")


def demo_linear_subspace_theorem():
    """Demonstrate that linear rules have power-of-2 fixed point counts."""
    print("\n" + "=" * 70)
    print("THEOREM: Linear Rules Have GF(2)-Subspace Fixed Points")
    print("If g is additive, then Fix(f) is a GF(2)-vector space ⇒ |Fix| = 2^k")
    print("=" * 70)

    # Find all linear rules
    linear_rules = [r for r in range(256) if is_linear_rule(r)]
    affine_rules = [r for r in range(256) if is_affine_rule(r)]

    print(f"\n  Linear rules (degree ≤ 1, no constant): {len(linear_rules)}")
    print(f"  Affine rules (degree ≤ 1):               {len(affine_rules)}")
    print(f"  Linear rules: {linear_rules}")

    print(f"\n  Verification: |Fix| is a power of 2 for linear rules:")
    for n in [4, 6, 8]:
        all_power_of_2 = True
        for r in linear_rules:
            fps = find_fixed_points(r, n)
            count = len(fps)
            if count > 0 and (count & (count - 1)) != 0:
                all_power_of_2 = False
                print(f"    FAIL: Rule {r}, n={n}: |Fix| = {count}")
        print(f"    n = {n}: all linear rules have |Fix| = 2^k: {all_power_of_2}")


def demo_complement_duality():
    """Demonstrate the complement duality theorem."""
    print("\n" + "=" * 70)
    print("THEOREM: Complement Duality")
    print("s ∈ Fix(g) ⟺ complement(s) ∈ Fix(complement(g))")
    print("=" * 70)

    print("\n  Complement rule pairs:")
    seen = set()
    for r in range(256):
        cr = complement_rule(r)
        if r not in seen and cr not in seen:
            if r != cr:
                print(f"    Rule {r:3d} ↔ Rule {cr:3d}")
            else:
                print(f"    Rule {r:3d} (self-complementary)")
            seen.add(r)
            seen.add(cr)

    # Verify the theorem
    print("\n  Verification for n = 6:")
    n = 6
    verified = 0
    for r in range(256):
        cr = complement_rule(r)
        fps_r = set(find_fixed_points(r, n))
        fps_cr = set(find_fixed_points(cr, n))

        # Check bijection via complement
        for s in fps_r:
            s_comp = tuple(1 - x for x in s)
            assert s_comp in fps_cr, f"Duality fails: Rule {r}, state {s}"
            verified += 1

    print(f"    Verified {verified} fixed-point ↔ complement pairs across all 256 rules. ✓")


def demo_degree_vs_complexity():
    """Analyze correlation between polynomial degree and Wolfram class."""
    print("\n" + "=" * 70)
    print("ANALYSIS: Polynomial Degree vs. Wolfram Complexity Class")
    print("=" * 70)

    # Classify all rules
    degree_class = {0: [], 1: [], 2: [], 3: []}
    for r in range(256):
        deg = polynomial_degree(r)
        degree_class[deg].append(r)

    print(f"\n  Rules by polynomial degree:")
    for d in range(4):
        print(f"    Degree {d}: {len(degree_class[d])} rules")

    # Compute fixed-point dimensions for each degree class
    n = 8
    print(f"\n  Average fixed-point dimension (n={n}):")
    for d in range(4):
        dims = []
        for r in degree_class[d]:
            fp_dim = fixed_point_dimension(r, n)
            if fp_dim > float('-inf'):
                dims.append(fp_dim)
            else:
                dims.append(0)
        if dims:
            print(f"    Degree {d}: mean dim = {np.mean(dims):.2f} "
                  f"(min={min(dims):.1f}, max={max(dims):.1f})")

    # Wolfram class estimation for notable rules
    print(f"\n  Wolfram class estimates for notable rules:")
    for r in [0, 30, 90, 110, 150, 184, 204, 255]:
        wc = wolfram_class_heuristic(r)
        deg = polynomial_degree(r)
        fp_dim = fixed_point_dimension(r, n)
        print(f"    Rule {r:3d}: degree={deg}, Wolfram class≈{wc}, "
              f"fixpoint dim={fp_dim:.1f}")


def demo_rule150_structure():
    """Detailed analysis of Rule 150 (XOR) fixed points."""
    print("\n" + "=" * 70)
    print("THEOREM: Rule 150 Fixed-Point Structure")
    print("Fixed points satisfy s_{i-1} = s_{i+1}, so even/odd positions agree.")
    print("=" * 70)

    for n in range(2, 13):
        fps = find_fixed_points(150, n)
        count = len(fps)
        dim = int(np.log2(count)) if count > 0 else -1
        parity = "even" if n % 2 == 0 else "odd"
        print(f"  n = {n:2d} ({parity}): |Fix| = {count:4d}, dim = {dim}")
        if n <= 6 and fps:
            for s in fps:
                print(f"    {list(s)}")

    print("\n  Pattern: For even n, dim = 2 (4 fixed points).")
    print("           For odd n, dim = 1 (2 fixed points).")
    print("  This matches the theorem: s_{i-1} = s_{i+1} forces")
    print("  even-indexed cells to agree and odd-indexed cells to agree.")


if __name__ == '__main__':
    demo_zhegalkin_representation()
    demo_fixed_point_analysis()
    demo_linear_subspace_theorem()
    demo_complement_duality()
    demo_degree_vs_complexity()
    demo_rule150_structure()

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Fixed-Point Landscape of All 256 ECA Rules
=========================================================
Standalone matplotlib script — all functions inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def eca_local_rule(rule_number, a, b, c):
    idx = 4 * a + 2 * b + c
    return (rule_number >> idx) & 1


def eca_update(rule_number, state):
    n = len(state)
    return [eca_local_rule(rule_number, state[(i-1)%n], state[i], state[(i+1)%n])
            for i in range(n)]


def count_fixed_points(rule_number, n):
    count = 0
    for s in range(2**n):
        state = [(s >> i) & 1 for i in range(n)]
        if eca_update(rule_number, state) == state:
            count += 1
    return count


def polynomial_degree(rule_number):
    g = lambda a, b, c: eca_local_rule(rule_number, a, b, c)
    c0 = g(0,0,0)
    c1 = (g(1,0,0)+g(0,0,0))%2
    c2 = (g(0,1,0)+g(0,0,0))%2
    c3 = (g(0,0,1)+g(0,0,0))%2
    c4 = (g(1,1,0)+g(1,0,0)+g(0,1,0)+g(0,0,0))%2
    c5 = (g(1,0,1)+g(1,0,0)+g(0,0,1)+g(0,0,0))%2
    c6 = (g(0,1,1)+g(0,1,0)+g(0,0,1)+g(0,0,0))%2
    c7 = (g(1,1,1)+g(1,1,0)+g(1,0,1)+g(0,1,1)+g(1,0,0)+g(0,1,0)+g(0,0,1)+g(0,0,0))%2
    if c7: return 3
    if c4 or c5 or c6: return 2
    if c1 or c2 or c3: return 1
    return 0


def main():
    n = 8  # number of cells
    rules = list(range(256))

    # Compute fixed-point counts and dimensions
    fp_counts = []
    fp_dims = []
    degrees = []
    for r in rules:
        c = count_fixed_points(r, n)
        fp_counts.append(c)
        fp_dims.append(np.log2(c) if c > 0 else -0.5)
        degrees.append(polynomial_degree(r))

    fp_counts = np.array(fp_counts)
    fp_dims = np.array(fp_dims)
    degrees = np.array(degrees)

    # Create figure with 3 subplots
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    fig.suptitle(f'Fixed-Point Varieties of All 256 ECA Rules (n={n} cells)',
                 fontsize=14, fontweight='bold')

    # 1. Heatmap: 16x16 grid of rule numbers, colored by fixed-point dimension
    ax1 = axes[0]
    dim_grid = fp_dims.reshape(16, 16)
    im = ax1.imshow(dim_grid, cmap='viridis', aspect='equal')
    ax1.set_title('Fixed-Point Dimension\n(log₂ |Fix(f)|)')
    ax1.set_xlabel('Rule number mod 16')
    ax1.set_ylabel('Rule number ÷ 16')
    plt.colorbar(im, ax=ax1, label='Dimension')

    # Annotate notable rules
    for r in [0, 30, 90, 110, 150, 204, 255]:
        row, col = divmod(r, 16)
        ax1.annotate(str(r), (col, row), color='white', fontsize=6,
                    ha='center', va='center', fontweight='bold')

    # 2. Scatter: polynomial degree vs fixed-point dimension
    ax2 = axes[1]
    colors = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    for d in range(4):
        mask = degrees == d
        ax2.scatter(degrees[mask] + np.random.uniform(-0.15, 0.15, mask.sum()),
                   fp_dims[mask],
                   c=colors[d], alpha=0.5, s=20, label=f'Degree {d}')
    ax2.set_xlabel('Zhegalkin Polynomial Degree')
    ax2.set_ylabel('Fixed-Point Dimension')
    ax2.set_title('Algebraic Degree vs.\nFixed-Point Dimension')
    ax2.legend()

    # 3. Histogram of fixed-point dimensions by degree
    ax3 = axes[2]
    for d in range(4):
        mask = degrees == d
        ax3.hist(fp_dims[mask], bins=np.arange(-1, n+1, 0.5),
                alpha=0.5, color=colors[d], label=f'Degree {d}', edgecolor='black')
    ax3.set_xlabel('Fixed-Point Dimension')
    ax3.set_ylabel('Count')
    ax3.set_title('Distribution of Fixed-Point\nDimension by Degree')
    ax3.legend()

    plt.tight_layout()
    plt.savefig('fixed_point_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved: fixed_point_landscape.png")


if __name__ == '__main__':
    main()
