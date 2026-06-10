#!/usr/bin/env python3
"""
applications.py — Applications of Permanent Shadow Analysis

Demonstrates connections between the shadow framework and:
1. Arithmetic circuit complexity (lower bound predictions)
2. Bipartite matching theory (near-perfect matchings)
3. Dimer/monomer models (statistical physics)
4. Rook polynomial theory (combinatorics)

Application keywords: arithmetic circuit complexity, permanent polynomial,
VP vs VNP, bipartite matchings, dimer models, rook placements
"""

from math import factorial, comb, log2
from itertools import permutations, combinations
from typing import List, Dict, Tuple


def circuit_lower_bound_prediction(n: int) -> Dict:
    """Predict arithmetic circuit lower bounds from shadow analysis.

    The shadow framework predicts:
    - |Sh₂| = C(n,2)² · (n-2)! grows super-exponentially
    - Under non-cancellation, circuit size ≥ |Sh₂| / poly(n)
    - This gives size ≥ 2^(n/2) / poly(n)

    Args:
        n: Matrix dimension

    Returns:
        Dictionary with bound predictions
    """
    shadow_size = comb(n, 2) ** 2 * factorial(n - 2)
    exp_bound = 2 ** (n // 2)

    # The non-cancellation certificate would give:
    # circuit_size ≥ shadow_size / n^O(1)
    poly_factors = [n, n**2, n**3]
    bounds = {f"Sh₂/n^{k+1}": shadow_size // (n ** (k + 1))
              for k, _ in enumerate(poly_factors)}

    return {
        'n': n,
        'shadow_size': shadow_size,
        'exponential_bound': exp_bound,
        'log2_shadow': log2(shadow_size) if shadow_size > 0 else 0,
        'predicted_bounds': bounds,
        'best_known_lower_bound': 'Ω(n²/2) [Shpilka-Wigderson type]',
        'our_conditional_bound': f'Ω({shadow_size} / poly({n}))',
    }


def matching_extension_analysis(n: int) -> Dict:
    """Analyze near-perfect matching extensions in K_{n,n}.

    Every matching of size n-2 in K_{n,n} extends to a perfect
    matching in exactly 2 ways. This is the matching-theoretic
    interpretation of completionCount_eq_two.

    Args:
        n: Number of vertices on each side

    Returns:
        Analysis results
    """
    # A matching of size n-2 misses 2 vertices on each side
    # There are C(n,2)² · (n-2)! such matchings
    num_near_perfect = comb(n, 2) ** 2 * factorial(n - 2)
    num_perfect = factorial(n)

    # Double counting: each perfect matching contains C(n,2) near-perfect matchings
    # Each near-perfect matching extends to 2 perfect matchings
    # So: n! * C(n,2) = |near-perfect| * 2
    double_count_lhs = num_perfect * comb(n, 2)
    double_count_rhs = num_near_perfect * 2

    return {
        'n': n,
        'perfect_matchings': num_perfect,
        'near_perfect_matchings': num_near_perfect,
        'extensions_per_near_perfect': 2,
        'subsets_per_perfect': comb(n, 2),
        'double_counting_verified': double_count_lhs == double_count_rhs,
        'ratio_near_to_perfect': num_near_perfect / num_perfect,
    }


def monomer_dimer_interpretation(n: int) -> Dict:
    """Statistical physics interpretation via monomer-dimer models.

    The permanent counts perfect matchings (dimers covering all vertices).
    The 2-shadow counts configurations with exactly 2 monomers on each side.

    In statistical physics:
    - Z_perfect = n! (partition function for perfect dimer covers)
    - Z_2-monomer = C(n,2)² · (n-2)! (partition function for 2-monomer configs)
    - The ratio Z_2-monomer / Z_perfect = C(n,2) / 2

    This connects circuit complexity to dimer thermodynamics.

    Args:
        n: Lattice dimension

    Returns:
        Physical interpretation data
    """
    z_perfect = factorial(n)
    z_2monomer = comb(n, 2) ** 2 * factorial(n - 2)

    return {
        'n': n,
        'Z_perfect_dimer': z_perfect,
        'Z_2_monomer': z_2monomer,
        'ratio': z_2monomer / z_perfect if z_perfect > 0 else 0,
        'free_energy_difference': log2(z_2monomer / z_perfect) if z_perfect > 0 and z_2monomer > 0 else 0,
        'interpretation': (
            f"Adding 2 monomers per side multiplies the partition function by "
            f"C({n},2)/2 = {comb(n,2)/2:.1f}"
        ),
    }


def rook_polynomial_connection(n: int) -> List[Dict]:
    """Connection to rook polynomial theory.

    The k-shadow counts (n-k)-rook placements on [n]×[n],
    i.e., placements of n-k nonattacking rooks.

    The rook polynomial R(x) = Σ_k r_k · x^k where r_k is the
    number of k-rook placements. Our formula gives:
    r_k = C(n,k)² · k!

    Args:
        n: Board size

    Returns:
        Rook placement counts for all k
    """
    results = []
    for k in range(n + 1):
        rook_count = comb(n, k) ** 2 * factorial(k)
        shadow_k = comb(n, n - k) ** 2 * factorial(k)  # Same by symmetry
        results.append({
            'rooks': k,
            'placements': rook_count,
            'shadow_level': n - k,
            'shadow_size': shadow_k,
            'formula': f"C({n},{k})² · {k}! = {rook_count}",
        })
    return results


def main():
    print("=" * 70)
    print("APPLICATIONS OF PERMANENT SHADOW ANALYSIS")
    print("=" * 70)

    # 1. Circuit complexity predictions
    print("\n" + "=" * 70)
    print("1. ARITHMETIC CIRCUIT LOWER BOUND PREDICTIONS")
    print("=" * 70)
    for n in [4, 6, 8, 10, 15, 20, 30]:
        pred = circuit_lower_bound_prediction(n)
        print(f"\n  n = {n}:")
        print(f"    |Sh₂| = {pred['shadow_size']:,}")
        print(f"    log₂|Sh₂| ≈ {pred['log2_shadow']:.1f}")
        print(f"    2^(n/2) = {pred['exponential_bound']:,}")
        for name, bound in pred['predicted_bounds'].items():
            print(f"    {name} = {bound:,}")

    # 2. Matching theory
    print("\n" + "=" * 70)
    print("2. BIPARTITE MATCHING THEORY")
    print("=" * 70)
    for n in range(3, 9):
        analysis = matching_extension_analysis(n)
        print(f"\n  K_{{{n},{n}}}:")
        print(f"    Perfect matchings: {analysis['perfect_matchings']}")
        print(f"    Near-perfect (size {n-2}): {analysis['near_perfect_matchings']}")
        print(f"    Extensions per near-perfect: {analysis['extensions_per_near_perfect']}")
        print(f"    Double counting verified: {analysis['double_counting_verified']}")

    # 3. Monomer-dimer models
    print("\n" + "=" * 70)
    print("3. MONOMER-DIMER MODEL INTERPRETATION")
    print("=" * 70)
    for n in range(3, 10):
        md = monomer_dimer_interpretation(n)
        print(f"  n={n}: Z_perfect={md['Z_perfect_dimer']:>8}, "
              f"Z_2-monomer={md['Z_2_monomer']:>8}, "
              f"ratio={md['ratio']:.2f}")

    # 4. Rook polynomial theory
    print("\n" + "=" * 70)
    print("4. ROOK POLYNOMIAL CONNECTION")
    print("=" * 70)
    for n in [4, 5, 6]:
        print(f"\n  Board size {n}×{n}:")
        for row in rook_polynomial_connection(n):
            print(f"    {row['rooks']} rooks: {row['formula']}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Shadow-Based Circuit Lower Bounds for the Permanent

Demonstrates the core theorems computationally:
1. Generates permutation support families
2. Computes 2-shadows and k-shadows
3. Verifies the exact counting formula |Sh₂| = C(n,2)² · (n-2)!
4. Tests the higher-shadow conjecture |Sh_k| = C(n,k)² · (n-k)!
5. Verifies completion multiplicity = 2 for all (n-2)-partial perm supports

Application keywords: permanent polynomial, shadow method, permutation matrices,
bipartite matchings, rook placements, support geometry, exact enumeration
"""

from itertools import permutations, combinations
from math import factorial, comb
from collections import Counter


def perm_graph(sigma):
    """Graph of a permutation: {(i, sigma[i]) for i in range(n)}."""
    return frozenset((i, sigma[i]) for i in range(len(sigma)))


def perm_support_family(n):
    """All permutation graphs on [n] x [n]."""
    return {perm_graph(sigma) for sigma in permutations(range(n))}


def is_partial_perm_support(s, n):
    """Check if s is a partial permutation support (no repeated row or column)."""
    rows = [p[0] for p in s]
    cols = [p[1] for p in s]
    return len(rows) == len(set(rows)) and len(cols) == len(set(cols))


def k_shadow(family, k):
    """Compute the k-shadow: all subsets of size (|member| - k) of some member."""
    shadow = set()
    for s in family:
        s_list = sorted(s)
        target_size = len(s_list) - k
        if target_size < 0:
            continue
        for subset in combinations(s_list, target_size):
            shadow.add(frozenset(subset))
    return shadow


def two_shadow(family):
    """Compute the 2-shadow."""
    return k_shadow(family, 2)


def completion_count(s, family):
    """Count how many members of family contain s."""
    s_set = set(s) if not isinstance(s, (set, frozenset)) else s
    return sum(1 for t in family if s_set <= set(t))


def covered_rows(s):
    return {p[0] for p in s}


def covered_cols(s):
    return {p[1] for p in s}


def defect_rows(s, n):
    return set(range(n)) - covered_rows(s)


def defect_cols(s, n):
    return set(range(n)) - covered_cols(s)


def expected_formula(n, k):
    """C(n,k)² · (n-k)!"""
    return comb(n, k) ** 2 * factorial(n - k)


# =============================================================================
# Main demonstration
# =============================================================================

def main():
    print("=" * 70)
    print("SHADOW-BASED CIRCUIT LOWER BOUNDS FOR THE PERMANENT")
    print("Computational Verification of Core Theorems")
    print("=" * 70)

    # --- 1. Basic statistics ---
    print("\n" + "=" * 70)
    print("1. PERMANENT SUPPORT FAMILY STATISTICS")
    print("=" * 70)
    for n in range(2, 8):
        family = perm_support_family(n)
        print(f"  n={n}: |permSupportFamily| = {len(family)} = {n}!")

    # --- 2. Two-shadow computation and formula verification ---
    print("\n" + "=" * 70)
    print("2. TWO-SHADOW: |Sh₂(suppPerm(n))| vs C(n,2)² · (n-2)!")
    print("=" * 70)
    print(f"  {'n':>3} {'|Sh₂|':>10} {'C(n,2)²·(n-2)!':>15} {'Match':>6}")
    print(f"  {'—'*3:>3} {'—'*10:>10} {'—'*15:>15} {'—'*6:>6}")
    for n in range(2, 8):
        family = perm_support_family(n)
        sh2 = two_shadow(family)
        expected = expected_formula(n, 2)
        match = "✓" if len(sh2) == expected else "✗"
        print(f"  {n:>3} {len(sh2):>10} {expected:>15} {match:>6}")

    # --- 3. Completion multiplicity ---
    print("\n" + "=" * 70)
    print("3. COMPLETION MULTIPLICITY (should always be 2)")
    print("=" * 70)
    for n in range(2, 7):
        family = perm_support_family(n)
        sh2 = two_shadow(family)
        counts = Counter()
        for s in sh2:
            cc = completion_count(s, family)
            counts[cc] += 1
        print(f"  n={n}: completion count distribution = {dict(counts)}")
        if all(k == 2 for k in counts.keys()):
            print(f"        ✓ All shadow elements have exactly 2 completions")
        else:
            print(f"        ✗ UNEXPECTED: some elements don't have 2 completions")

    # --- 4. Partial permutation support characterization ---
    print("\n" + "=" * 70)
    print("4. CHARACTERIZATION: Sh₂ = {partial perm supports of size n-2}")
    print("=" * 70)
    for n in range(2, 7):
        family = perm_support_family(n)
        sh2 = two_shadow(family)
        all_pps = True
        for s in sh2:
            if not is_partial_perm_support(s, n):
                all_pps = False
                break
            if len(s) != n - 2:
                all_pps = False
                break
        print(f"  n={n}: All Sh₂ elements are partial perm supports of size {n-2}: "
              f"{'✓' if all_pps else '✗'}")

    # --- 5. Higher shadow conjecture ---
    print("\n" + "=" * 70)
    print("5. HIGHER SHADOW CONJECTURE: |Sh_k| = C(n,k)² · (n-k)!")
    print("=" * 70)
    print(f"  {'n':>3} {'k':>3} {'|Sh_k|':>10} {'C(n,k)²·(n-k)!':>15} {'Match':>6}")
    print(f"  {'—'*3:>3} {'—'*3:>3} {'—'*10:>10} {'—'*15:>15} {'—'*6:>6}")
    for n in range(3, 8):
        family = perm_support_family(n)
        for k in range(0, n + 1):
            shk = k_shadow(family, k)
            expected = expected_formula(n, k)
            match = "✓" if len(shk) == expected else "✗"
            print(f"  {n:>3} {k:>3} {len(shk):>10} {expected:>15} {match:>6}")

    # --- 6. Exponential lower bound ---
    print("\n" + "=" * 70)
    print("6. EXPONENTIAL LOWER BOUND: 2^(n/2) ≤ |Sh₂|")
    print("=" * 70)
    for n in range(4, 8):
        family = perm_support_family(n)
        sh2 = two_shadow(family)
        bound = 2 ** (n // 2)
        print(f"  n={n}: 2^({n//2}) = {bound} ≤ {len(sh2)} = |Sh₂|  "
              f"{'✓' if bound <= len(sh2) else '✗'}")

    # --- 7. Double counting identity ---
    print("\n" + "=" * 70)
    print("7. DOUBLE COUNTING: n! · C(n,2) = C(n,2)² · (n-2)! · 2")
    print("=" * 70)
    for n in range(2, 10):
        lhs = factorial(n) * comb(n, 2)
        rhs = comb(n, 2) ** 2 * factorial(n - 2) * 2
        print(f"  n={n}: {lhs} = {rhs}  {'✓' if lhs == rhs else '✗'}")

    # --- 8. Defect row/column analysis ---
    print("\n" + "=" * 70)
    print("8. DEFECT ANALYSIS: missing rows and columns")
    print("=" * 70)
    for n in range(3, 6):
        family = perm_support_family(n)
        sh2 = two_shadow(family)
        print(f"  n={n}:")
        for s in list(sh2)[:3]:
            dr = defect_rows(s, n)
            dc = defect_cols(s, n)
            print(f"    s={sorted(s)}")
            print(f"      defect rows={sorted(dr)}, defect cols={sorted(dc)}")
            print(f"      |defect rows|={len(dr)}, |defect cols|={len(dc)}")

    print("\n" + "=" * 70)
    print("ALL VERIFICATIONS COMPLETE")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Completion Multiplicity and Shadow Structure

Visualizes the uniform completion multiplicity property: every partial
permutation support of size n-2 extends to exactly 2 full permutation
supports. Also shows the structure of the k-shadow hierarchy.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial, comb
from itertools import permutations, combinations
from collections import Counter


def perm_graph(sigma):
    return frozenset((i, sigma[i]) for i in range(len(sigma)))

def perm_support_family(n):
    return {perm_graph(sigma) for sigma in permutations(range(n))}

def k_shadow(family, k):
    shadow = set()
    for s in family:
        s_list = sorted(s)
        target_size = len(s_list) - k
        if target_size < 0:
            continue
        for subset in combinations(s_list, target_size):
            shadow.add(frozenset(subset))
    return shadow

def completion_count(s, family):
    s_set = set(s)
    return sum(1 for t in family if s_set <= set(t))


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Completion counts are all exactly 2
ax1 = axes[0]
for n in range(3, 7):
    family = perm_support_family(n)
    sh2 = k_shadow(family, 2)
    counts = [completion_count(s, family) for s in sh2]
    counter = Counter(counts)
    bars = ax1.bar([n + (c - 2) * 0.15 for c in counter.keys()],
                   counter.values(), width=0.12, label=f'n={n}', alpha=0.8)

ax1.set_xlabel('Completion count', fontsize=12)
ax1.set_ylabel('Number of shadow elements', fontsize=12)
ax1.set_title('Completion Multiplicity\n(always exactly 2)', fontsize=13)
ax1.legend(fontsize=9)
ax1.set_xticks(range(3, 7))
ax1.set_xticklabels([f'n={n}' for n in range(3, 7)])

# Plot 2: k-shadow hierarchy
ax2 = axes[1]
for n in range(3, 8):
    ks = list(range(n + 1))
    shadow_sizes = [comb(n, k)**2 * factorial(n - k) for k in ks]
    ax2.semilogy(ks, shadow_sizes, 'o-', linewidth=2, markersize=6, label=f'n={n}')

ax2.set_xlabel('Shadow depth k', fontsize=12)
ax2.set_ylabel('|Sh_k| (log scale)', fontsize=12)
ax2.set_title('k-Shadow Hierarchy\n|Sh_k| = C(n,k)² · (n-k)!', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Ratio of shadow to parent
ax3 = axes[2]
for n in range(4, 9):
    ks = list(range(1, n + 1))
    ratios = []
    for k in ks:
        parent = comb(n, k-1)**2 * factorial(n - k + 1) if k > 0 else factorial(n)
        child = comb(n, k)**2 * factorial(n - k)
        ratios.append(child / parent if parent > 0 else 0)
    ax3.plot(ks, ratios, 'o-', linewidth=2, markersize=6, label=f'n={n}')

ax3.set_xlabel('Shadow depth k', fontsize=12)
ax3.set_ylabel('|Sh_k| / |Sh_{k-1}|', fontsize=12)
ax3.set_title('Shadow Compression Ratio\nacross depths', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.suptitle('Permanent Support Shadow Structure', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('shadow_structure.png', dpi=150, bbox_inches='tight')
print("Saved shadow_structure.png")


#!/usr/bin/env python3
"""
Visualization: Partial Permutation Support Heatmap

Visualizes partial permutation supports (nonattacking rook placements)
on n×n boards. Shows examples of shadow elements — the partial
structures that underlie the permanent's circuit complexity.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, combinations


def perm_graph(sigma):
    return frozenset((i, sigma[i]) for i in range(len(sigma)))

def perm_support_family(n):
    return {perm_graph(sigma) for sigma in permutations(range(n))}

def k_shadow(family, k):
    shadow = set()
    for s in family:
        s_list = sorted(s)
        target_size = len(s_list) - k
        if target_size < 0:
            continue
        for subset in combinations(s_list, target_size):
            shadow.add(frozenset(subset))
    return shadow


n = 6
family = perm_support_family(n)

fig, axes = plt.subplots(2, 4, figsize=(16, 8))

# Top row: full permutation supports
axes[0, 0].set_title('Full Permutation\nSupport (n=6)', fontsize=11, fontweight='bold')
for idx, sigma in enumerate(list(permutations(range(n)))[:4]):
    ax = axes[0, idx]
    grid = np.zeros((n, n))
    for i in range(n):
        grid[i, sigma[i]] = 1
    ax.imshow(grid, cmap='Blues', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column', fontsize=9)
    if idx == 0:
        ax.set_ylabel('Row', fontsize=9)
    ax.set_title(f'σ = {list(sigma)}', fontsize=9)
    ax.grid(True, alpha=0.3)
    # Mark the cells
    for i in range(n):
        ax.text(sigma[i], i, '♜', ha='center', va='center', fontsize=14, color='darkblue')

# Bottom row: shadow elements (partial perm supports of size n-2)
sh2 = k_shadow(family, 2)
shadow_list = sorted(sh2, key=lambda s: sorted(s))

axes[1, 0].set_title('2-Shadow Element\n(size n-2=4)', fontsize=11, fontweight='bold')
for idx in range(4):
    ax = axes[1, idx]
    s = shadow_list[idx * len(shadow_list) // 4]
    grid = np.zeros((n, n))
    for (i, j) in s:
        grid[i, j] = 1

    # Find defect rows/cols
    covered_rows = {p[0] for p in s}
    covered_cols = {p[1] for p in s}
    missing_rows = set(range(n)) - covered_rows
    missing_cols = set(range(n)) - covered_cols

    ax.imshow(grid, cmap='Greens', vmin=0, vmax=1, aspect='equal')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Column', fontsize=9)
    if idx == 0:
        ax.set_ylabel('Row', fontsize=9)
    ax.grid(True, alpha=0.3)

    # Mark cells
    for (i, j) in s:
        ax.text(j, i, '♜', ha='center', va='center', fontsize=14, color='darkgreen')

    # Highlight missing rows/cols
    for r in missing_rows:
        ax.axhline(y=r, color='red', linewidth=2, alpha=0.3)
    for c in missing_cols:
        ax.axvline(x=c, color='red', linewidth=2, alpha=0.3)

    mr = sorted(missing_rows)
    mc = sorted(missing_cols)
    ax.set_title(f'Missing: rows {mr}\ncols {mc}', fontsize=9)

plt.suptitle('Permanent Support and Its 2-Shadow\n'
             'Top: Full permutations (n rooks)  |  '
             'Bottom: Shadow elements (n−2 rooks, red = gaps)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('rook_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved rook_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Growth vs Exponential Bound

Visualizes the super-exponential growth of |Sh₂(suppPerm(n))| = C(n,2)² · (n-2)!
compared to the exponential lower bound 2^(n/2). Shows how the permanent's
support shadow grows far faster than any exponential function, demonstrating
the power of the shadow-based approach to circuit lower bounds.

This is a self-contained script — no local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import factorial, comb, log2

# Compute data
ns = list(range(2, 21))
shadow_sizes = [comb(n, 2)**2 * factorial(n - 2) for n in ns]
exp_bounds = [2**(n // 2) for n in ns]
factorials = [factorial(n) for n in ns]

# Log scale values
log_shadow = [log2(s) if s > 0 else 0 for s in shadow_sizes]
log_exp = [n // 2 for n in ns]
log_fact = [log2(f) if f > 0 else 0 for f in factorials]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left plot: log₂ comparison
ax1.plot(ns, log_shadow, 'bo-', linewidth=2, markersize=8, label='log₂|Sh₂| = log₂[C(n,2)²·(n-2)!]')
ax1.plot(ns, log_exp, 'rs--', linewidth=2, markersize=7, label='n/2 (exponential bound)')
ax1.plot(ns, log_fact, 'g^:', linewidth=1.5, markersize=6, label='log₂(n!) (permanent terms)', alpha=0.7)
ax1.set_xlabel('n (matrix dimension)', fontsize=13)
ax1.set_ylabel('log₂(count)', fontsize=13)
ax1.set_title('Shadow Size vs Exponential Bound\n(logarithmic scale)', fontsize=14)
ax1.legend(fontsize=10, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(1.5, 20.5)

# Right plot: ratio |Sh₂| / 2^(n/2)
ratios = [shadow_sizes[i] / exp_bounds[i] for i in range(len(ns))]
ax2.semilogy(ns, ratios, 'ko-', linewidth=2, markersize=8, color='darkblue')
ax2.axhline(y=1, color='red', linestyle='--', linewidth=1, alpha=0.5, label='ratio = 1')
ax2.set_xlabel('n (matrix dimension)', fontsize=13)
ax2.set_ylabel('|Sh₂| / 2^(n/2)', fontsize=13)
ax2.set_title('Shadow-to-Exponential Ratio\n(grows super-exponentially)', fontsize=14)
ax2.grid(True, alpha=0.3)
ax2.legend(fontsize=10)
ax2.set_xlim(1.5, 20.5)

# Annotate key values
for i, n in enumerate(ns):
    if n in [4, 8, 12, 16, 20]:
        ax2.annotate(f'{ratios[i]:.0f}', (n, ratios[i]),
                    textcoords="offset points", xytext=(10, 5),
                    fontsize=9, color='darkblue')

plt.suptitle('Permanent Support Shadow: Super-Exponential Growth', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('shadow_growth.png', dpi=150, bbox_inches='tight')
print("Saved shadow_growth.png")
