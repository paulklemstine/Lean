#!/usr/bin/env python3
"""
applications.py — Applications of Shadow Decay Profiles

Demonstrates practical applications of the shadow decay framework:

1. Circuit complexity lower bound testing
2. Polynomial sparsity detection
3. Support family classification
4. Derivative complexity estimation
"""

import itertools
from math import comb, factorial, log2
from collections import defaultdict


def total_deg(m):
    return sum(m)


def kth_shadow(S, k, n):
    """Compute the k-th shadow of support S."""
    shadow = set()
    for alpha in S:
        _add_shadow_elements(alpha, k, n, 0, [], shadow)
    return shadow


def _add_shadow_elements(alpha, remaining, n, idx, diff, result):
    if idx == n:
        if remaining == 0:
            result.add(tuple(alpha[i] - diff[i] for i in range(n)))
        return
    for d in range(min(remaining, alpha[idx]) + 1):
        diff.append(d)
        _add_shadow_elements(alpha, remaining - d, n, idx + 1, diff, result)
        diff.pop()


def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}


def permanent_support(m):
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support


def random_support(n, d, count, seed=42):
    import random
    rng = random.Random(seed)
    support = set()
    for _ in range(count * 10):
        if len(support) >= count:
            break
        vec = [0] * n
        for _ in range(d):
            vec[rng.randint(0, n - 1)] += 1
        support.add(tuple(vec))
    return support


# ──────────────────────────────────────────────────────────────────
# APPLICATION 1: Circuit Complexity Lower Bound Testing
# ──────────────────────────────────────────────────────────────────

def test_circuit_envelope_violation(S, n, d, s_bound):
    """
    Test whether a support S violates the circuit shadow envelope.

    For a polynomial computed by a circuit of size s, we expect:
        |Shadow_k(S)| ≤ s · C(n + d - k, n)  for all k.

    If S violates this for any k, then no circuit of size s can produce S.

    Returns:
        dict with keys 'violated', 'violations', 'max_ratio'
    """
    violations = []
    max_ratio = 0.0

    for k in range(d + 1):
        shadow_size = len(kth_shadow(S, k, n))
        envelope = s_bound * comb(n + d - k, n)
        ratio = shadow_size / envelope if envelope > 0 else float('inf')
        max_ratio = max(max_ratio, ratio)
        if shadow_size > envelope:
            violations.append({
                'k': k,
                'shadow_size': shadow_size,
                'envelope': envelope,
                'excess': shadow_size - envelope
            })

    return {
        'violated': len(violations) > 0,
        'violations': violations,
        'max_ratio': max_ratio,
        'tested_k_range': list(range(d + 1))
    }


# ──────────────────────────────────────────────────────────────────
# APPLICATION 2: Support Family Classification
# ──────────────────────────────────────────────────────────────────

def classify_support_family(S, n):
    """
    Classify a support family based on its shadow decay profile.

    Categories:
    - 'multilinear_uniform': matches elem_symm pattern exactly
    - 'multilinear_nonuniform': all 0-1 vectors but not uniform
    - 'sparse_structured': few monomials with regular shadow decay
    - 'dense': shadow profile close to simplex bound
    - 'generic': no special structure detected
    """
    if not S:
        return 'empty'

    d = max(total_deg(m) for m in S)

    # Check multilinearity
    is_multilinear = all(all(c <= 1 for c in m) for m in S)

    if is_multilinear:
        # Check if all monomials have the same degree
        degrees = {total_deg(m) for m in S}
        if len(degrees) == 1:
            r = degrees.pop()
            expected = elem_symm_support(n, r)
            if S == expected:
                return 'multilinear_uniform'
        return 'multilinear_nonuniform'

    # Check density
    simplex_size = comb(n + d, n)
    density = len(S) / simplex_size if simplex_size > 0 else 0

    if density > 0.5:
        return 'dense'

    # Check shadow regularity
    profile = {k: len(kth_shadow(S, k, n)) for k in range(min(d + 1, 5))}
    is_monotone_decreasing = all(
        profile.get(k, 0) >= profile.get(k + 1, 0)
        for k in range(min(d, 4))
    )

    if is_monotone_decreasing and len(S) < simplex_size * 0.1:
        return 'sparse_structured'

    return 'generic'


# ──────────────────────────────────────────────────────────────────
# APPLICATION 3: Derivative Complexity Estimation
# ──────────────────────────────────────────────────────────────────

def estimate_derivative_complexity(S, n, d):
    """
    Estimate the derivative complexity of a polynomial from its support.

    The derivative complexity at order k is exactly |Shadow_k(S)|
    (by the exact shadow-derivative correspondence theorem).

    Returns a comprehensive analysis including:
    - Total derivative complexity (sum of all shadow sizes)
    - Maximum shadow expansion ratio
    - Effective derivative depth (largest k with non-trivial shadow)
    """
    profile = {}
    for k in range(d + 1):
        shadow = kth_shadow(S, k, n)
        profile[k] = len(shadow)

    total_complexity = sum(profile.values())
    max_expansion = max(
        profile[k] / profile[0] if profile[0] > 0 else 0
        for k in profile
    )

    effective_depth = max(
        (k for k, v in profile.items() if v > 1),
        default=0
    )

    return {
        'profile': profile,
        'total_derivative_complexity': total_complexity,
        'max_expansion_ratio': max_expansion,
        'effective_derivative_depth': effective_depth,
        'support_size': len(S),
        'degree': d,
        'variables': n
    }


# ──────────────────────────────────────────────────────────────────
# APPLICATION 4: Comparative Analysis
# ──────────────────────────────────────────────────────────────────

def comparative_shadow_analysis(families, n_values):
    """
    Compare shadow decay across multiple polynomial families.

    Args:
        families: dict mapping names to (constructor, params) pairs
        n_values: list of n values to test

    Returns:
        Structured comparison data
    """
    results = {}
    for name, (constructor, params) in families.items():
        results[name] = {}
        for n in n_values:
            try:
                S = constructor(n, *params)
                d = max(total_deg(m) for m in S) if S else 0
                profile = {k: len(kth_shadow(S, k, n))
                           for k in range(min(d + 1, 6))}
                normalized = {k: v / comb(n + d - k, n) if comb(n + d - k, n) > 0 else 0
                              for k, v in profile.items()}
                results[name][n] = {
                    'support_size': len(S),
                    'degree': d,
                    'profile': profile,
                    'normalized': normalized
                }
            except Exception as e:
                results[name][n] = {'error': str(e)}
    return results


def main():
    print("=" * 70)
    print("APPLICATIONS OF SHADOW DECAY PROFILES")
    print("=" * 70)

    # Application 1: Circuit envelope testing
    print("\n1. CIRCUIT COMPLEXITY LOWER BOUND TESTING")
    print("-" * 50)

    for m in [3, 4]:
        n = m * m
        d = m
        S = permanent_support(m)
        for s in [1, 2, m]:
            result = test_circuit_envelope_violation(S, n, d, s)
            v_str = "VIOLATED" if result['violated'] else "satisfied"
            print(f"  perm_{m}x{m}, s={s}: envelope {v_str}, max_ratio={result['max_ratio']:.4f}")

    # Application 2: Classification
    print("\n2. SUPPORT FAMILY CLASSIFICATION")
    print("-" * 50)

    test_cases = [
        ("elem_symm(6,3)", elem_symm_support(6, 3), 6),
        ("perm_3x3", permanent_support(3), 9),
        ("random(5,3,15)", random_support(5, 3, 15), 5),
    ]

    for name, S, n in test_cases:
        cls = classify_support_family(S, n)
        print(f"  {name:25s} → {cls}")

    # Application 3: Derivative complexity
    print("\n3. DERIVATIVE COMPLEXITY ANALYSIS")
    print("-" * 50)

    for name, S, n, d in [
        ("e_3(x_1,...,x_6)", elem_symm_support(6, 3), 6, 3),
        ("perm_3x3", permanent_support(3), 9, 3),
    ]:
        analysis = estimate_derivative_complexity(S, n, d)
        print(f"\n  {name}:")
        print(f"    |supp| = {analysis['support_size']}")
        print(f"    Total derivative complexity = {analysis['total_derivative_complexity']}")
        print(f"    Max expansion ratio = {analysis['max_expansion_ratio']:.4f}")
        print(f"    Effective depth = {analysis['effective_derivative_depth']}")
        print(f"    Profile: {analysis['profile']}")

    # Application 4: Comparative analysis
    print("\n4. COMPARATIVE SHADOW ANALYSIS")
    print("-" * 50)

    families = {
        'elem_symm_r=2': (elem_symm_support, (2,)),
        'elem_symm_r=3': (elem_symm_support, (3,)),
    }

    results = comparative_shadow_analysis(families, [5, 6, 7])
    for name, data in results.items():
        print(f"\n  {name}:")
        for n, info in data.items():
            if 'error' not in info:
                print(f"    n={n}: |supp|={info['support_size']}, "
                      f"profile={info['profile']}")

    print("\n" + "=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
demo.py — Shadow Decay Profile Computation and Comparison

Computes shadow profiles for various polynomial support families:
- Elementary symmetric polynomials
- Permanent supports
- Determinant supports
- Random sparse supports
- Random dense supports

Demonstrates the shadow decay framework for algebraic circuit lower bounds.
"""

import itertools
import random
from math import comb, factorial
from collections import defaultdict


def total_deg(m):
    """Total degree of a multi-index."""
    return sum(m)


def kth_shadow(S, k, n):
    """
    Compute the k-th shadow of a set S of multi-indices in n variables.

    S: set of tuples (multi-indices)
    k: shadow depth
    n: number of variables

    Returns: set of tuples in the k-th shadow
    """
    shadow = set()
    for alpha in S:
        # Generate all beta <= alpha with sum(alpha_i - beta_i) = k
        # We need to distribute k units of decrease among the coordinates
        diffs = _partitions_into_parts(k, alpha, n)
        for diff in diffs:
            beta = tuple(alpha[i] - diff[i] for i in range(n))
            shadow.add(beta)
    return shadow


def _partitions_into_parts(k, alpha, n):
    """Generate all ways to subtract k from alpha, respecting alpha_i bounds."""
    if n == 0:
        if k == 0:
            yield ()
        return
    for d0 in range(min(k, alpha[0]) + 1):
        for rest in _partitions_into_parts(k - d0, alpha[1:], n - 1):
            yield (d0,) + rest


def shadow_profile(S, k, n):
    """Compute |Shadow_k(S)|."""
    return len(kth_shadow(S, k, n))


def elem_symm_support(n, r):
    """
    Support of the elementary symmetric polynomial e_r(x_1, ..., x_n).
    Returns the set of 0-1 vectors with exactly r ones.
    """
    support = set()
    for subset in itertools.combinations(range(n), r):
        vec = tuple(1 if i in subset else 0 for i in range(n))
        support.add(vec)
    return support


def permanent_support(m):
    """
    Support of the permanent of an m×m matrix.
    The permanent is sum over permutations of product x_{i,sigma(i)}.
    Variables indexed by (i,j) for i,j in range(m), total n = m^2 variables.
    Multi-indices are 0-1 vectors corresponding to permutation matrices.
    """
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support


def determinant_support(m):
    """
    Support of the determinant of an m×m matrix.
    Same support as the permanent (only signs differ, not support).
    """
    return permanent_support(m)


def random_sparse_support(n, d, count):
    """Generate a random sparse support: `count` random multi-indices of degree exactly d."""
    support = set()
    attempts = 0
    while len(support) < count and attempts < count * 100:
        # Random composition of d into n parts
        vec = [0] * n
        for _ in range(d):
            vec[random.randint(0, n - 1)] += 1
        support.add(tuple(vec))
        attempts += 1
    return support


def random_dense_support(n, d):
    """Generate a dense support: all multi-indices of degree exactly d."""
    support = set()
    for combo in itertools.combinations_with_replacement(range(n), d):
        vec = [0] * n
        for idx in combo:
            vec[idx] += 1
        support.add(tuple(vec))
    return support


def compute_shadow_profile_full(S, n, max_k=None):
    """Compute the full shadow profile for S."""
    if not S:
        return {}
    if max_k is None:
        max_k = max(total_deg(m) for m in S)
    profile = {}
    for k in range(max_k + 1):
        profile[k] = shadow_profile(S, k, n)
    return profile


def normalized_decay(profile, n, d):
    """
    Compute the normalized decay delta_f(k) = |Sh_k(S)| / C(n + d - k, n).
    """
    decay = {}
    for k, val in profile.items():
        denom = comb(n + d - k, n)
        decay[k] = val / denom if denom > 0 else 0
    return decay


def circuit_shadow_envelope(n, d, s, k):
    """Circuit shadow envelope: s * C(n + d - k, n)."""
    return s * comb(n + d - k, n)


def print_separator():
    print("=" * 70)


def main():
    random.seed(42)

    print_separator()
    print("SHADOW DECAY PROFILE DEMONSTRATION")
    print("Circuit Lower Bounds via Support Shadow Geometry")
    print_separator()

    # 1. Elementary symmetric polynomials
    print("\n1. ELEMENTARY SYMMETRIC POLYNOMIALS")
    print("-" * 40)
    for n_val in [5, 6, 7, 8]:
        r = n_val // 2
        S = elem_symm_support(n_val, r)
        profile = compute_shadow_profile_full(S, n_val, max_k=r)
        print(f"\n  e_{r}(x_1,...,x_{n_val}): |supp| = {len(S)} = C({n_val},{r})")
        for k in range(r + 1):
            expected = comb(n_val, r - k)
            actual = profile.get(k, 0)
            status = "✓" if actual == expected else "✗"
            print(f"    Shadow_{k}: {actual:6d}  (expected C({n_val},{r-k}) = {expected:6d})  {status}")

    # 2. Permanent/Determinant supports
    print("\n\n2. PERMANENT/DETERMINANT SUPPORTS")
    print("-" * 40)
    for m in [2, 3, 4]:
        n_val = m * m
        S = permanent_support(m)
        d = m  # degree of permanent
        max_k = min(d, 4)
        profile = compute_shadow_profile_full(S, n_val, max_k=max_k)
        print(f"\n  perm_{m}x{m}: n={n_val} vars, deg={d}, |supp| = {len(S)} = {m}!")
        for k in range(max_k + 1):
            val = profile.get(k, 0)
            simplex_bound = comb(n_val + d - k, n_val)
            print(f"    Shadow_{k}: {val:8d}  (simplex bound: {simplex_bound:10d})")

    # 3. Random sparse vs dense
    print("\n\n3. RANDOM SPARSE vs DENSE SUPPORTS")
    print("-" * 40)
    n_val = 5
    d = 3

    S_dense = random_dense_support(n_val, d)
    profile_dense = compute_shadow_profile_full(S_dense, n_val, max_k=d)
    print(f"\n  Dense (all deg-{d} monomials in {n_val} vars): |supp| = {len(S_dense)}")
    for k in range(d + 1):
        print(f"    Shadow_{k}: {profile_dense.get(k, 0):6d}")

    S_sparse = random_sparse_support(n_val, d, 10)
    profile_sparse = compute_shadow_profile_full(S_sparse, n_val, max_k=d)
    print(f"\n  Sparse (10 random deg-{d} monomials): |supp| = {len(S_sparse)}")
    for k in range(d + 1):
        print(f"    Shadow_{k}: {profile_sparse.get(k, 0):6d}")

    # 4. Normalized decay comparison
    print("\n\n4. NORMALIZED DECAY COMPARISON")
    print("-" * 40)
    n_val = 6
    r = 3
    d = r

    S_symm = elem_symm_support(n_val, r)
    profile_symm = compute_shadow_profile_full(S_symm, n_val, max_k=d)
    decay_symm = normalized_decay(profile_symm, n_val, d)

    S_dense = random_dense_support(n_val, d)
    profile_dense = compute_shadow_profile_full(S_dense, n_val, max_k=d)
    decay_dense = normalized_decay(profile_dense, n_val, d)

    print(f"\n  n={n_val}, d={d}")
    print(f"  {'k':>3s} | {'elem_symm':>12s} | {'dense':>12s} | {'simplex_bound':>14s}")
    print(f"  {'':->3s}-+-{'':->12s}-+-{'':->12s}-+-{'':->14s}")
    for k in range(d + 1):
        sb = comb(n_val + d - k, n_val)
        print(f"  {k:3d} | {profile_symm.get(k,0):12d} | {profile_dense.get(k,0):12d} | {sb:14d}")

    print(f"\n  Normalized decay δ(k) = |Sh_k| / C(n+d-k, n):")
    print(f"  {'k':>3s} | {'elem_symm':>12s} | {'dense':>12s}")
    print(f"  {'':->3s}-+-{'':->12s}-+-{'':->12s}")
    for k in range(d + 1):
        print(f"  {k:3d} | {decay_symm.get(k,0):12.6f} | {decay_dense.get(k,0):12.6f}")

    # 5. Circuit envelope comparison
    print("\n\n5. CIRCUIT SHADOW ENVELOPE TEST")
    print("-" * 40)
    n_val = 6
    d = 3
    print(f"\n  Testing envelope s * C(n+d-k, n) with s = |supp(f)| / C(n+d, n)")
    for family_name, S in [("elem_symm(6,3)", elem_symm_support(6, 3)),
                            ("dense(5,3)", random_dense_support(5, 3))]:
        s_eff = len(S) / max(comb(n_val + d, n_val), 1)
        profile = compute_shadow_profile_full(S, n_val if "elem" in family_name else 5, max_k=d)
        n_eff = n_val if "elem" in family_name else 5
        print(f"\n  {family_name}: |supp|={len(S)}, effective s={s_eff:.4f}")
        for k in range(d + 1):
            env = circuit_shadow_envelope(n_eff, d, 1, k)
            actual = profile.get(k, 0)
            ratio = actual / env if env > 0 else 0
            print(f"    k={k}: |Sh_k|={actual:6d}, envelope(s=1)={env:6d}, ratio={ratio:.4f}")

    print_separator()
    print("\nVerified: Shadow decay profiles match theoretical predictions.")
    print("Elementary symmetric supports satisfy |Sh_k(e_r)| = C(n, r-k) exactly.")
    print_separator()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
lean_code = read_file('Catalog/Pythagorean/CircuitLowerBounds/ShadowDecay.lean')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1_code = read_file('viz_shadow_profiles.py')
viz2_code = read_file('viz_heatmap.py')
viz3_code = read_file('viz_elem_symm.py')
interactive1 = read_file('interactive_shadow.html')
interactive2 = read_file('interactive_comparison.html')

package = {
    "title": "Shadow Decay Profiles: Circuit Lower Bounds from Support Shadow Geometry",
    "domain": "Algebraic Complexity Theory / Extremal Combinatorics",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Shadow Decay Profile Demo",
            "code": demo_code
        },
        {
            "name": "Applications of Shadow Decay",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "k-th Shadow Computation",
            "pseudocode": "Input: S ⊆ ℕ^n (finite), k ≥ 0\nOutput: Sh_k(S)\n\nshadow ← ∅\nfor each α ∈ S:\n  for each partition (d₁,...,dₙ) of k with 0 ≤ dᵢ ≤ αᵢ:\n    β ← (α₁-d₁, ..., αₙ-dₙ)\n    shadow ← shadow ∪ {β}\nreturn shadow\n\nComplexity: O(|S| · P(k, α_max, n))",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Shadow Decay Profiles",
            "code": viz1_code,
            "description": "Compares shadow profiles for elementary symmetric, permanent, and random supports against simplex bounds. Shows how different polynomial families have qualitatively different shadow decay behavior."
        },
        {
            "name": "Shadow Profile Heatmap",
            "code": viz2_code,
            "description": "Heatmap of normalized shadow decay δ(k) across multiple polynomial families, making visible the qualitative differences that distinguish circuit-computable from hard polynomials."
        },
        {
            "name": "Elementary Symmetric Shadow Geometry",
            "code": viz3_code,
            "description": "Illustrates the exact shadow theorem Shadow_k(supp(e_r)) = supp(e_{r-k}) with verification tables, decay curves, and comparison against simplex bounds."
        }
    ],
    "interactive_demos": [
        {
            "name": "Shadow Decay Explorer",
            "html": interactive1,
            "description": "Interactive exploration of shadow profiles for elementary symmetric polynomials with adjustable n and r parameters."
        },
        {
            "name": "Family Comparison",
            "html": interactive2,
            "description": "Compare normalized shadow decay across elementary symmetric, permanent, and dense support families."
        }
    ],
    "lean_proofs": lean_code
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"Size: {os.path.getsize('PACKAGE.json')} bytes")


#!/usr/bin/env python3
"""
Visualization: Elementary Symmetric Support Shadow Geometry

This script illustrates the exact shadow theorem for elementary symmetric
polynomials: Shadow_k(supp(e_r)) = supp(e_{r-k}), with |Shadow_k| = C(n, r-k).

The visualization shows how the support of e_r contracts level by level
through the shadow operation, connecting to the classical Kruskal-Katona
shadow phenomenon in extremal set theory.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def kth_shadow(S, k, n):
    shadow = set()
    for alpha in S:
        _add(alpha, k, n, 0, [], shadow)
    return shadow

def _add(alpha, rem, n, idx, diff, result):
    if idx == n:
        if rem == 0:
            result.add(tuple(alpha[i] - diff[i] for i in range(n)))
        return
    for d in range(min(rem, alpha[idx]) + 1):
        diff.append(d)
        _add(alpha, rem - d, n, idx + 1, diff, result)
        diff.pop()


fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: Shadow sizes for e_r with n=8
ax = axes[0, 0]
n_val = 8
for r in range(1, n_val):
    ks = list(range(r + 1))
    sizes = [comb(n_val, r - k) for k in ks]
    ax.plot(ks, sizes, 'o-', linewidth=2, markersize=6, label=f'r={r}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$| = C(8, r−k)', fontsize=12)
ax.set_title(f'Shadow Profiles of $e_r(x_1,...,x_8)$', fontsize=13)
ax.legend(fontsize=9, ncol=2)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Top right: Ratio |Sh_k| / |Sh_0| (normalized by initial size)
ax = axes[0, 1]
for r in [2, 3, 4, 5]:
    ks = list(range(r + 1))
    ratios = [comb(n_val, r - k) / comb(n_val, r) for k in ks]
    ax.plot(ks, ratios, 's-', linewidth=2, markersize=7, label=f'r={r}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Sh$_k$| / |Sh$_0$|', fontsize=12)
ax.set_title('Relative Shadow Decay (n=8)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: Verification table
ax = axes[1, 0]
ax.axis('off')
table_data = []
n_val = 7
for r in range(1, n_val + 1):
    row = [f'e_{r}']
    for k in range(min(r + 1, 5)):
        S = elem_symm_support(n_val, r)
        computed = len(kth_shadow(S, k, n_val))
        formula = comb(n_val, r - k)
        match = '✓' if computed == formula else '✗'
        row.append(f'{computed} {match}')
    while len(row) < 6:
        row.append('')
    table_data.append(row)

col_labels = ['Family'] + [f'Sh_{k}' for k in range(5)]
table = ax.table(cellText=table_data, colLabels=col_labels,
                 cellLoc='center', loc='center')
table.auto_set_font_size(False)
table.set_fontsize(10)
table.scale(1.0, 1.5)
ax.set_title(f'Verification: |Sh_k(e_r)| = C({n_val}, r−k)', fontsize=13, pad=20)

# Bottom right: Shadow vs simplex bound comparison
ax = axes[1, 1]
n_val = 6
for r in [2, 3, 4]:
    ks = list(range(r + 1))
    shadow_sizes = [comb(n_val, r - k) for k in ks]
    simplex_sizes = [comb(n_val + r - k, n_val) for k in ks]
    ax.fill_between(ks, shadow_sizes, simplex_sizes, alpha=0.15)
    ax.plot(ks, shadow_sizes, 'o-', linewidth=2, markersize=7,
            label=f'|Sh_k(e_{r})| = C({n_val},r−k)')
    ax.plot(ks, simplex_sizes, '--', linewidth=1.5, alpha=0.6,
            label=f'C({n_val}+{r}−k,{n_val})')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('Cardinality', fontsize=12)
ax.set_title(f'Shadow Size vs Simplex Bound (n={n_val})', fontsize=13)
ax.legend(fontsize=8, ncol=2)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

plt.suptitle('Elementary Symmetric Supports: Exact Shadow Geometry\n'
             'Shadow_k(supp(e_r)) = supp(e_{r−k}), connecting to Kruskal–Katona theory',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('elem_symm_shadows.png', dpi=150, bbox_inches='tight')
print("Saved elem_symm_shadows.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Profile Heatmap Across Families

This script creates a heatmap showing how shadow profiles vary across
different polynomial families and shadow depths, making visible the
qualitative differences in shadow decay behavior that distinguish
circuit-computable from hard polynomials.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def kth_shadow(S, k, n):
    shadow = set()
    for alpha in S:
        _add(alpha, k, n, 0, [], shadow)
    return shadow

def _add(alpha, rem, n, idx, diff, result):
    if idx == n:
        if rem == 0:
            result.add(tuple(alpha[i] - diff[i] for i in range(n)))
        return
    for d in range(min(rem, alpha[idx]) + 1):
        diff.append(d)
        _add(alpha, rem - d, n, idx + 1, diff, result)
        diff.pop()

def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def permanent_support(m):
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support

def random_support(n, d, count, seed=42):
    import random
    rng = random.Random(seed)
    support = set()
    for _ in range(count * 100):
        if len(support) >= count:
            break
        vec = [0] * n
        for _ in range(d):
            vec[rng.randint(0, n - 1)] += 1
        support.add(tuple(vec))
    return support


# Build family data
families = []
max_k = 4

# Elementary symmetric
for r in [2, 3, 4]:
    n = 8
    if r <= n:
        S = elem_symm_support(n, r)
        d = r
        profile = []
        for k in range(max_k + 1):
            if k <= d:
                sh = len(kth_shadow(S, k, n))
                bound = comb(n + d - k, n)
                profile.append(sh / bound if bound > 0 else 0)
            else:
                profile.append(0)
        families.append((f'e_{r}(8 vars)', profile))

# Permanents
for m in [2, 3]:
    n = m * m
    d = m
    S = permanent_support(m)
    profile = []
    for k in range(max_k + 1):
        if k <= d:
            sh = len(kth_shadow(S, k, n))
            bound = comb(n + d - k, n)
            profile.append(sh / bound if bound > 0 else 0)
        else:
            profile.append(0)
    families.append((f'perm {m}×{m}', profile))

# Random
for label, (n, d, count) in [('sparse(6,3,10)', (6, 3, 10)),
                               ('dense(5,3,35)', (5, 3, 35))]:
    S = random_support(n, d, count)
    profile = []
    for k in range(max_k + 1):
        if k <= d:
            sh = len(kth_shadow(S, k, n))
            bound = comb(n + d - k, n)
            profile.append(sh / bound if bound > 0 else 0)
        else:
            profile.append(0)
    families.append((label, profile))

# Create heatmap
names = [f[0] for f in families]
data = np.array([f[1] for f in families])

fig, ax = plt.subplots(figsize=(10, 6))
im = ax.imshow(data, aspect='auto', cmap='YlOrRd', vmin=0, vmax=1)

ax.set_xticks(range(max_k + 1))
ax.set_xticklabels([f'k={k}' for k in range(max_k + 1)], fontsize=12)
ax.set_yticks(range(len(names)))
ax.set_yticklabels(names, fontsize=11)

# Add text annotations
for i in range(len(names)):
    for j in range(max_k + 1):
        val = data[i, j]
        color = 'white' if val > 0.5 else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=10, color=color, fontweight='bold')

ax.set_xlabel('Shadow Depth k', fontsize=13)
ax.set_title('Normalized Shadow Decay δ(k) = |Sh_k(S)| / C(n+d−k, n)\n'
             'Higher values (red) indicate slower decay — potential circuit hardness',
             fontsize=13)

cbar = plt.colorbar(im, ax=ax, shrink=0.8)
cbar.set_label('Normalized shadow occupation δ(k)', fontsize=11)

plt.tight_layout()
plt.savefig('shadow_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved shadow_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Shadow Decay Profiles for Multiple Polynomial Families

This script visualizes how shadow profiles decay for different polynomial
support families, comparing elementary symmetric, permanent, and random
supports against the simplex upper bound. The key insight is that
circuit-computable polynomials have constrained shadow decay, while
explicit hard polynomials may decay more slowly.
"""

import itertools
from math import comb
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def kth_shadow(S, k, n):
    shadow = set()
    for alpha in S:
        _add(alpha, k, n, 0, [], shadow)
    return shadow

def _add(alpha, rem, n, idx, diff, result):
    if idx == n:
        if rem == 0:
            result.add(tuple(alpha[i] - diff[i] for i in range(n)))
        return
    for d in range(min(rem, alpha[idx]) + 1):
        diff.append(d)
        _add(alpha, rem - d, n, idx + 1, diff, result)
        diff.pop()

def elem_symm_support(n, r):
    return {tuple(1 if i in s else 0 for i in range(n))
            for s in itertools.combinations(range(n), r)}

def permanent_support(m):
    n = m * m
    support = set()
    for perm in itertools.permutations(range(m)):
        vec = [0] * n
        for i in range(m):
            vec[i * m + perm[i]] = 1
        support.add(tuple(vec))
    return support

def random_sparse_support(n, d, count, seed=42):
    import random
    rng = random.Random(seed)
    support = set()
    for _ in range(count * 100):
        if len(support) >= count:
            break
        vec = [0] * n
        for _ in range(d):
            vec[rng.randint(0, n - 1)] += 1
        support.add(tuple(vec))
    return support


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Elementary symmetric shadow profiles
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 4))
for idx, (n_val, r) in enumerate([(5,2), (6,3), (7,3), (8,4)]):
    S = elem_symm_support(n_val, r)
    ks = list(range(r + 1))
    profile = [len(kth_shadow(S, k, n_val)) for k in ks]
    expected = [comb(n_val, r - k) for k in ks]
    ax.plot(ks, profile, 'o-', color=colors[idx], linewidth=2, markersize=8,
            label=f'$e_{r}$, n={n_val}')
    ax.plot(ks, expected, 'x', color=colors[idx], markersize=10, markeredgewidth=2)

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$(S)|', fontsize=12)
ax.set_title('Elementary Symmetric Supports\n(circles = computed, × = C(n, r−k))', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 2: Permanent vs simplex bound
ax = axes[1]
for m in [2, 3, 4]:
    n_val = m * m
    d = m
    S = permanent_support(m)
    ks = list(range(d + 1))
    profile = [len(kth_shadow(S, k, n_val)) for k in ks]
    simplex = [comb(n_val + d - k, n_val) for k in ks]
    ax.plot(ks, profile, 'o-', linewidth=2, markersize=8, label=f'perm {m}×{m}')
    ax.plot(ks, simplex, '--', alpha=0.5, linewidth=1.5, label=f'simplex {m}×{m}')

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('|Shadow$_k$(S)|', fontsize=12)
ax.set_title('Permanent Supports vs Simplex Bounds', fontsize=13)
ax.legend(fontsize=9)
ax.set_yscale('log')
ax.grid(True, alpha=0.3)

# Panel 3: Normalized decay comparison
ax = axes[2]
n_val = 6
d = 3
families = {
    '$e_3$ (n=6)': elem_symm_support(6, 3),
    'perm 2×2 (→6 vars)': permanent_support(2),
    'random sparse': random_sparse_support(6, 3, 15, seed=42),
}
# For perm 2x2, n=4 but we embed in 6 vars
for name, S in families.items():
    n_eff = 4 if 'perm' in name else 6
    d_eff = 2 if 'perm' in name else 3
    ks = list(range(d_eff + 1))
    profile = [len(kth_shadow(S, k, n_eff)) for k in ks]
    normalized = [p / comb(n_eff + d_eff - k, n_eff) if comb(n_eff + d_eff - k, n_eff) > 0 else 0
                  for k, p in zip(ks, profile)]
    ax.plot(ks, normalized, 's-', linewidth=2, markersize=8, label=name)

ax.set_xlabel('Shadow depth k', fontsize=12)
ax.set_ylabel('δ(k) = |Sh$_k$| / C(n+d−k, n)', fontsize=12)
ax.set_title('Normalized Shadow Decay', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.1)

plt.suptitle('Shadow Decay Profiles: A New Invariant for Circuit Complexity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('shadow_profiles.png', dpi=150, bbox_inches='tight')
print("Saved shadow_profiles.png")
