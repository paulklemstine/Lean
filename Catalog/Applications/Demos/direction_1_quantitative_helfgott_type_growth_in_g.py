#!/usr/bin/env python3
"""
Applications of Helfgott-Type Growth in SL(2, F_p)

Demonstrates real-world applications of product growth theorems:
1. Expander graph construction from SL(2) Cayley graphs
2. Mixing time estimation for random walks on groups
3. Pseudorandom generator quality assessment
4. Communication network robustness analysis

Each application connects the mathematical theory to practical computation.
"""

import math
import random
from typing import List, Set, Dict, Tuple
from collections import defaultdict


Matrix2x2 = Tuple[Tuple[int, int], Tuple[int, int]]


def mod(x, p):
    return x % p

def mat_mul(A, B, p):
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return ((mod(a1*a2+b1*c2,p), mod(a1*b2+b1*d2,p)),
            (mod(c1*a2+d1*c2,p), mod(c1*b2+d1*d2,p)))

def mat_inv(M, p):
    (a, b), (c, d) = M
    return ((mod(d,p), mod(-b,p)), (mod(-c,p), mod(a,p)))

def mat_trace(M, p):
    return mod(M[0][0] + M[1][1], p)

def identity():
    return ((1, 0), (0, 1))

def build_sl2(p):
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if mod(a*d - b*c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result

def is_irreducible_charpoly(M, p):
    t = mat_trace(M, p)
    disc = mod(t*t - 4, p)
    if disc == 0:
        return False
    return pow(disc, (p-1)//2, p) != 1


# ============================================================
# Application 1: Expander Graph Construction
# ============================================================

def cayley_graph_expansion(generators: List[Matrix2x2], p: int) -> Dict:
    """
    Analyze the expansion properties of the Cayley graph Cay(SL(2,F_p), S).

    The Helfgott growth theorem implies that if S generates SL(2,F_p) and
    is not trapped in a proper subgroup, the Cayley graph is an expander.

    We estimate expansion by computing vertex boundary ratios.

    Time: O(|SL(2,F_p)|² · |S|) for full BFS
    Space: O(|SL(2,F_p)|)

    Returns: Dictionary with expansion metrics
    """
    sl2 = build_sl2(p)
    sl2_set = set(sl2)
    N = len(sl2)

    # Make generator set symmetric with identity
    S = set(generators)
    for g in list(S):
        S.add(mat_inv(g, p))
    S.add(identity())

    # BFS to compute diameter and ball growth
    visited = {identity()}
    frontier = {identity()}
    ball_sizes = [1]

    while frontier:
        new_frontier = set()
        for g in frontier:
            for s in S:
                gs = mat_mul(g, s, p)
                if gs not in visited:
                    visited.add(gs)
                    new_frontier.add(gs)
        frontier = new_frontier
        ball_sizes.append(len(visited))
        if len(visited) >= N:
            break

    diameter = len(ball_sizes) - 1

    # Compute expansion ratio from first few levels
    expansion_ratios = []
    for i in range(1, min(len(ball_sizes), 5)):
        if ball_sizes[i-1] > 0 and ball_sizes[i-1] < N:
            ratio = ball_sizes[i] / ball_sizes[i-1]
            expansion_ratios.append(ratio)

    generates_group = len(visited) == N

    return {
        'group_size': N,
        'generator_size': len(S),
        'diameter': diameter,
        'ball_sizes': ball_sizes[:10],
        'expansion_ratios': expansion_ratios,
        'generates_group': generates_group,
        'log_diameter': math.log(diameter) / math.log(N) if N > 1 else 0,
    }


# ============================================================
# Application 2: Random Walk Mixing
# ============================================================

def random_walk_mixing(generators: List[Matrix2x2], p: int,
                       num_steps: int = 100, num_walks: int = 500) -> Dict:
    """
    Estimate mixing time of random walk on Cayley graph.

    Product growth implies rapid mixing: if |A³| ≥ |A|^(1+δ),
    then the walk mixes in O(log|G| / δ) steps.

    We estimate mixing by measuring total variation distance
    from uniform distribution at each step.

    Returns: Dictionary with mixing analysis
    """
    sl2 = build_sl2(p)
    N = len(sl2)

    # Make symmetric generating set
    S = set(generators)
    for g in list(S):
        S.add(mat_inv(g, p))
    S.add(identity())
    S_list = list(S)

    # Run random walks and collect endpoint distribution
    step_distributions = {}

    for step in [1, 2, 3, 5, 8, 13, 20, 50]:
        if step > num_steps:
            break
        endpoint_counts = defaultdict(int)
        for _ in range(num_walks):
            current = identity()
            for _ in range(step):
                s = random.choice(S_list)
                current = mat_mul(current, s, p)
            endpoint_counts[current] += 1

        # Total variation distance from uniform
        tv_distance = 0.5 * sum(
            abs(count / num_walks - 1.0 / N)
            for count in endpoint_counts.values()
        )
        # Add contribution from unvisited elements
        tv_distance += 0.5 * (N - len(endpoint_counts)) / N

        step_distributions[step] = {
            'tv_distance': tv_distance,
            'unique_endpoints': len(endpoint_counts),
            'coverage': len(endpoint_counts) / N,
        }

    return {
        'group_size': N,
        'mixing_data': step_distributions,
    }


# ============================================================
# Application 3: Pseudorandom Generation Quality
# ============================================================

def prg_quality_assessment(generators: List[Matrix2x2], p: int,
                           sequence_length: int = 200) -> Dict:
    """
    Assess quality of pseudorandom sequences generated by
    iterated matrix multiplication in SL(2, F_p).

    Product growth ensures that matrix products explore the group
    rapidly, producing high-quality pseudorandom elements.

    Returns: Dictionary with PRG quality metrics
    """
    S_list = list(set(generators))
    for g in generators:
        S_list.append(mat_inv(g, p))
    S_list.append(identity())
    S_list = list(set(S_list))

    # Generate sequence: alternate multiplying by random generators
    sequence = []
    current = identity()
    for _ in range(sequence_length):
        s = random.choice(S_list)
        current = mat_mul(current, s, p)
        sequence.append(current)

    # Metric 1: Unique elements ratio
    unique = len(set(sequence))
    uniqueness = unique / sequence_length

    # Metric 2: Trace distribution
    traces = [mat_trace(g, p) for g in sequence]
    trace_hist = defaultdict(int)
    for t in traces:
        trace_hist[t] += 1
    trace_entropy = -sum(
        (c / len(traces)) * math.log(c / len(traces))
        for c in trace_hist.values() if c > 0
    )
    max_entropy = math.log(p)

    # Metric 3: Entry distribution for (0,0) entry
    entries = [g[0][0] for g in sequence]
    entry_hist = defaultdict(int)
    for e in entries:
        entry_hist[e] += 1
    entry_chi_sq = sum(
        (c - sequence_length / p) ** 2 / (sequence_length / p)
        for c in entry_hist.values()
    )

    return {
        'sequence_length': sequence_length,
        'unique_elements': unique,
        'uniqueness_ratio': uniqueness,
        'trace_entropy': trace_entropy,
        'max_entropy': max_entropy,
        'entropy_ratio': trace_entropy / max_entropy if max_entropy > 0 else 0,
        'entry_chi_squared': entry_chi_sq,
        'chi_sq_critical_95': p - 1,  # approximate
    }


# ============================================================
# Application 4: Network Robustness via Expansion
# ============================================================

def network_robustness_analysis(generators: List[Matrix2x2], p: int) -> Dict:
    """
    Analyze robustness of a communication network modeled as
    Cayley graph Cay(SL(2,F_p), S).

    Expander graphs (which Helfgott growth guarantees for SL(2) Cayley graphs)
    have excellent connectivity properties:
    - Small diameter (O(log n))
    - High vertex connectivity
    - Rapid information dissemination

    Returns: Dictionary with network robustness metrics
    """
    expansion_data = cayley_graph_expansion(generators, p)

    N = expansion_data['group_size']
    d = expansion_data['diameter']
    k = expansion_data['generator_size']

    # Cheeger's inequality relates expansion to spectral gap
    # For expanders: λ₂ ≤ 1 - h²/(2k) where h is Cheeger constant
    # We estimate h from expansion ratios
    if expansion_data['expansion_ratios']:
        avg_expansion = sum(expansion_data['expansion_ratios']) / len(expansion_data['expansion_ratios'])
        estimated_cheeger = min(avg_expansion - 1, k)  # rough bound
    else:
        avg_expansion = 0
        estimated_cheeger = 0

    return {
        'network_size': N,
        'degree': k,
        'diameter': d,
        'diameter_to_log_ratio': d / math.log(N) if N > 1 else 0,
        'average_expansion': avg_expansion,
        'estimated_cheeger': estimated_cheeger,
        'generates_connected_graph': expansion_data['generates_group'],
        'ball_growth': expansion_data['ball_sizes'][:6],
    }


if __name__ == "__main__":
    random.seed(42)
    p = 7

    print("=" * 60)
    print(f"APPLICATIONS OF HELFGOTT GROWTH IN SL(2, F_{p})")
    print("=" * 60)

    sl2 = build_sl2(p)
    print(f"|SL(2, F_{p})| = {len(sl2)}")

    # Find good generators
    irr = [g for g in sl2 if is_irreducible_charpoly(g, p)]
    generators = [irr[0], irr[len(irr)//3]] if len(irr) >= 2 else [irr[0]]

    # Application 1: Expander graphs
    print("\n--- Application 1: Expander Graph Construction ---")
    exp_data = cayley_graph_expansion(generators, p)
    print(f"  Diameter: {exp_data['diameter']}")
    print(f"  Generates group: {exp_data['generates_group']}")
    print(f"  Ball sizes: {exp_data['ball_sizes'][:6]}")
    print(f"  Expansion ratios: {[f'{r:.2f}' for r in exp_data['expansion_ratios']]}")

    # Application 2: Random walk mixing
    print("\n--- Application 2: Random Walk Mixing ---")
    mix_data = random_walk_mixing(generators, p)
    for step, data in sorted(mix_data['mixing_data'].items()):
        print(f"  Step {step:3d}: TV dist = {data['tv_distance']:.4f}, "
              f"coverage = {data['coverage']:.4f}")

    # Application 3: PRG quality
    print("\n--- Application 3: Pseudorandom Generation Quality ---")
    prg_data = prg_quality_assessment(generators, p)
    print(f"  Uniqueness ratio: {prg_data['uniqueness_ratio']:.4f}")
    print(f"  Trace entropy ratio: {prg_data['entropy_ratio']:.4f}")
    print(f"  Entry χ²: {prg_data['entry_chi_squared']:.2f} "
          f"(critical: {prg_data['chi_sq_critical_95']})")

    # Application 4: Network robustness
    print("\n--- Application 4: Network Robustness ---")
    net_data = network_robustness_analysis(generators, p)
    print(f"  Network size: {net_data['network_size']}")
    print(f"  Degree: {net_data['degree']}")
    print(f"  Diameter: {net_data['diameter']}")
    print(f"  Diameter/log(n): {net_data['diameter_to_log_ratio']:.2f}")
    print(f"  Connected: {net_data['generates_connected_graph']}")


#!/usr/bin/env python3
"""
Helfgott-Type Growth in SL(2, F_p): Computational Demonstration

This script:
- Builds SL(2, F_p) for small primes p
- Samples random symmetric subsets containing the identity
- Computes triple products A^3
- Measures empirical growth exponents delta = log|A^3|/log|A| - 1
- Detects obstruction patterns (upper-triangular, commuting, escaped)
- Reports growth statistics and searches for anomalous families

Usage: python demo.py
"""

from itertools import product as cartesian_product
import random
import math


def build_sl2(p):
    """Build SL(2, F_p) as a list of 2x2 matrices mod p with determinant 1."""
    sl2 = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                d = (a * pow(int(c), -1, p) + b * c) if c != 0 else None
                # det = ad - bc = 1 mod p
                for d_val in range(p):
                    if (a * d_val - b * c) % p == 1:
                        sl2.append(((a, b), (c, d_val)))
    # Remove duplicates
    return list(set(sl2))


def mat_mul(A, B, p):
    """Multiply two 2x2 matrices mod p."""
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return (
        ((a1*a2 + b1*c2) % p, (a1*b2 + b1*d2) % p),
        ((c1*a2 + d1*c2) % p, (c1*b2 + d1*d2) % p)
    )


def mat_inv(M, p):
    """Inverse of a 2x2 matrix in SL(2, F_p) (det=1 so inv = [[d,-b],[-c,a]])."""
    (a, b), (c, d) = M
    return ((d % p, (-b) % p), ((-c) % p, a % p))


def mat_trace(M):
    """Trace of a 2x2 matrix."""
    (a, _), (_, d) = M
    return a + d


def is_upper_triangular(M):
    """Check if M has zero (1,0)-entry."""
    return M[1][0] == 0


def charpoly_is_irreducible(M, p):
    """Check if the characteristic polynomial X^2 - tr(M)X + det(M) is irreducible over F_p.
    For SL(2), det=1, so charpoly = X^2 - tX + 1. Irreducible iff discriminant t^2 - 4
    is a non-residue mod p."""
    t = mat_trace(M) % p
    disc = (t * t - 4) % p
    if disc == 0:
        return False
    # Check if disc is a quadratic residue
    return pow(disc, (p - 1) // 2, p) != 1


def identity_2x2():
    """Return the 2x2 identity matrix."""
    return ((1, 0), (0, 1))


def make_symmetric(subset, p):
    """Close a subset under inversion."""
    result = set(subset)
    for m in list(result):
        result.add(mat_inv(m, p))
    return result


def triple_product(A, p):
    """Compute A * A * A = {a*b*c : a,b,c in A}."""
    result = set()
    A_list = list(A)
    for a in A_list:
        for b in A_list:
            ab = mat_mul(a, b, p)
            for c in A_list:
                result.add(mat_mul(ab, c, p))
    return result


def double_product(A, p):
    """Compute A * A = {a*b : a,b in A}."""
    result = set()
    A_list = list(A)
    for a in A_list:
        for b in A_list:
            result.add(mat_mul(a, b, p))
    return result


def trace_set(A, p):
    """Compute {tr(g) mod p : g in A}."""
    return {mat_trace(g) % p for g in A}


def commutation_rate(A, p):
    """Fraction of pairs (a,b) in A x A that commute."""
    A_list = list(A)
    n = len(A_list)
    if n <= 1:
        return 1.0
    commuting = 0
    total = 0
    for i in range(n):
        for j in range(i+1, n):
            total += 1
            if mat_mul(A_list[i], A_list[j], p) == mat_mul(A_list[j], A_list[i], p):
                commuting += 1
    return commuting / total if total > 0 else 1.0


def classify_obstruction(A, p):
    """Classify a subset by obstruction type."""
    all_ut = all(is_upper_triangular(m) for m in A)
    comm_rate = commutation_rate(A, p)
    has_irr = any(charpoly_is_irreducible(m, p) for m in A)
    has_noncommuting = comm_rate < 1.0

    if all_ut:
        return "Borel-like"
    elif comm_rate > 0.8:
        return "commuting-heavy"
    elif has_irr and has_noncommuting:
        return "escaped/noncommuting"
    elif has_irr:
        return "escaped/commuting"
    else:
        return "non-escaped"


def sample_symmetric_subset(sl2, p, size):
    """Sample a random symmetric subset of SL(2, F_p) containing identity."""
    identity = identity_2x2()
    # Start with identity
    result = {identity}
    # Add random elements and their inverses
    candidates = [m for m in sl2 if m != identity]
    sample_size = min(size // 2, len(candidates))
    if sample_size > 0:
        chosen = random.sample(candidates, sample_size)
        for m in chosen:
            result.add(m)
            result.add(mat_inv(m, p))
    return result


def run_experiment(p, num_samples=20, sizes=None):
    """Run growth experiments for SL(2, F_p)."""
    print(f"\n{'='*70}")
    print(f"SL(2, F_{p})")
    print(f"{'='*70}")

    sl2 = build_sl2(p)
    print(f"|SL(2, F_{p})| = {len(sl2)}")
    print(f"Expected: p(p^2-1) = {p * (p*p - 1)}")

    if sizes is None:
        max_size = min(20, len(sl2) // 2)
        sizes = [3, 5, min(8, max_size), min(12, max_size)]
        sizes = sorted(set(s for s in sizes if s >= 3))

    results_by_class = {}

    for target_size in sizes:
        print(f"\n  --- Target subset size: ~{target_size} ---")
        for trial in range(num_samples):
            A = sample_symmetric_subset(sl2, p, target_size)
            A_size = len(A)
            if A_size < 2:
                continue

            A3 = triple_product(A, p)
            A2 = double_product(A, p)
            ts = trace_set(A, p)

            growth_ratio = len(A3) / A_size
            delta = math.log(len(A3)) / math.log(A_size) - 1 if A_size > 1 else 0

            obstruction = classify_obstruction(A, p)

            if obstruction not in results_by_class:
                results_by_class[obstruction] = []
            results_by_class[obstruction].append({
                'p': p, 'A_size': A_size, 'A2_size': len(A2),
                'A3_size': len(A3), 'trace_size': len(ts),
                'delta': delta, 'growth_ratio': growth_ratio,
                'comm_rate': commutation_rate(A, p)
            })

            if trial < 3:  # Print first few
                print(f"    |A|={A_size:3d}  |A²|={len(A2):4d}  |A³|={len(A3):5d}  "
                      f"|tr(A)|={len(ts):2d}  δ={delta:.3f}  "
                      f"class={obstruction}")

    return results_by_class


def print_summary(all_results):
    """Print summary statistics by obstruction class."""
    print(f"\n{'='*70}")
    print("SUMMARY BY OBSTRUCTION CLASS")
    print(f"{'='*70}")

    for cls, results in sorted(all_results.items()):
        deltas = [r['delta'] for r in results]
        ratios = [r['growth_ratio'] for r in results]
        print(f"\n  Class: {cls}")
        print(f"    Samples: {len(results)}")
        print(f"    δ (growth exponent - 1):")
        print(f"      min={min(deltas):.4f}  mean={sum(deltas)/len(deltas):.4f}  "
              f"max={max(deltas):.4f}")
        print(f"    Growth ratio |A³|/|A|:")
        print(f"      min={min(ratios):.2f}  mean={sum(ratios)/len(ratios):.2f}  "
              f"max={max(ratios):.2f}")

        # Check for anomalous low growth
        low_growth = [r for r in results if r['delta'] < 0.1]
        if low_growth:
            print(f"    ⚠ LOW GROWTH SAMPLES (δ < 0.1): {len(low_growth)}")
            for r in low_growth[:3]:
                print(f"      p={r['p']} |A|={r['A_size']} |A³|={r['A3_size']} "
                      f"δ={r['delta']:.4f} comm_rate={r['comm_rate']:.2f}")


def test_conjecture():
    """Test the quantitative growth conjecture:
    For p ≥ 11, symmetric A ⊆ SL(2, F_p) with 1 ∈ A,
    if A has an irreducible-charpoly witness and a noncommuting pair,
    then |A³| ≥ |A|^(1+δ₀) for some universal δ₀ > 0."""

    print(f"\n{'='*70}")
    print("TESTING QUANTITATIVE GROWTH CONJECTURE")
    print(f"{'='*70}")
    print("Conjecture: ∃ δ₀ > 0 such that for all primes p ≥ 11,")
    print("if A ⊆ SL(2, F_p) is symmetric with 1 ∈ A,")
    print("has irreducible-charpoly witness and noncommuting pair,")
    print("then |A³| ≥ |A|^(1+δ₀).")
    print()

    min_delta = float('inf')
    min_delta_info = None

    for p in [11, 13, 17, 19, 23]:
        sl2 = build_sl2(p)
        for _ in range(50):
            for target_size in [4, 6, 8, 10]:
                A = sample_symmetric_subset(sl2, p, target_size)
                if len(A) < 3:
                    continue

                # Check conditions
                has_irr = any(charpoly_is_irreducible(m, p) for m in A)
                has_nc = commutation_rate(A, p) < 1.0

                if not (has_irr and has_nc):
                    continue

                A3 = triple_product(A, p)
                delta = math.log(len(A3)) / math.log(len(A)) - 1

                if delta < min_delta:
                    min_delta = delta
                    min_delta_info = {
                        'p': p, 'A_size': len(A), 'A3_size': len(A3),
                        'delta': delta
                    }

    if min_delta_info:
        print(f"Minimum observed δ = {min_delta:.4f}")
        print(f"  at p={min_delta_info['p']}, |A|={min_delta_info['A_size']}, "
              f"|A³|={min_delta_info['A3_size']}")
        if min_delta > 0:
            print(f"\n✓ Conjecture CONSISTENT with δ₀ ≤ {min_delta:.4f}")
        else:
            print(f"\n✗ Conjecture VIOLATED!")
    else:
        print("No qualifying samples found (need irr charpoly + noncommuting)")


if __name__ == "__main__":
    random.seed(42)

    print("=" * 70)
    print("HELFGOTT-TYPE GROWTH IN SL(2, F_p)")
    print("Computational Demonstration")
    print("=" * 70)

    all_results = {}

    for p in [5, 7, 11, 13]:
        results = run_experiment(p, num_samples=15)
        for cls, data in results.items():
            if cls not in all_results:
                all_results[cls] = []
            all_results[cls].extend(data)

    print_summary(all_results)
    test_conjecture()

    print(f"\n{'='*70}")
    print("DEMO COMPLETE")
    print(f"{'='*70}")


#!/usr/bin/env python3
"""
Visualization 3: Cayley Graph Ball Growth and Mixing

Visualizes the ball growth B(k) = |{g : d(1,g) ≤ k}| in the Cayley graph
of SL(2, F_p) with different generating sets. Shows how product growth
translates to rapid expansion in the graph metric, and compares
different generator choices.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import math


def mod(x, p):
    return x % p

def mat_mul(A, B, p):
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return ((mod(a1*a2+b1*c2,p), mod(a1*b2+b1*d2,p)),
            (mod(c1*a2+d1*c2,p), mod(c1*b2+d1*d2,p)))

def mat_inv(M, p):
    (a, b), (c, d) = M
    return ((mod(d,p), mod(-b,p)), (mod(-c,p), mod(a,p)))

def mat_trace(M, p):
    return mod(M[0][0] + M[1][1], p)

def identity():
    return ((1, 0), (0, 1))

def build_sl2(p):
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if mod(a*d - b*c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result

def is_irreducible_charpoly(M, p):
    t = mat_trace(M, p)
    disc = mod(t*t - 4, p)
    if disc == 0:
        return False
    return pow(disc, (p-1)//2, p) != 1


def ball_growth(generators, p):
    """Compute ball sizes in Cayley graph."""
    sl2 = build_sl2(p)
    N = len(sl2)

    S = set(generators)
    for g in list(S):
        S.add(mat_inv(g, p))
    S.add(identity())

    visited = {identity()}
    frontier = {identity()}
    sizes = [1]

    while frontier and len(visited) < N:
        new_frontier = set()
        for g in frontier:
            for s in S:
                gs = mat_mul(g, s, p)
                if gs not in visited:
                    visited.add(gs)
                    new_frontier.add(gs)
        frontier = new_frontier
        sizes.append(len(visited))

    return sizes


random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Ball growth for different generator types in SL(2, F_7)
p = 7
sl2 = build_sl2(p)
N = len(sl2)

ax = axes[0]

# Generator set 1: Two elements with irreducible charpoly
irr_elements = [g for g in sl2 if is_irreducible_charpoly(g, p)]
gen1 = [irr_elements[0], irr_elements[len(irr_elements)//3]]
sizes1 = ball_growth(gen1, p)

# Generator set 2: Upper triangular elements only
ut_elements = [g for g in sl2 if g[1][0] == 0 and g != identity()]
gen2 = [ut_elements[0], ut_elements[len(ut_elements)//3]]
sizes2 = ball_growth(gen2, p)

# Generator set 3: Mixed (one irr, one ut)
gen3 = [irr_elements[0], ut_elements[0]]
sizes3 = ball_growth(gen3, p)

ax.plot(range(len(sizes1)), sizes1, 'o-', color='#2ecc71',
        label=f'Irr. charpoly gens (d={len(sizes1)-1})', linewidth=2, markersize=5)
ax.plot(range(len(sizes2)), sizes2, 's-', color='#e74c3c',
        label=f'Upper triang. gens (d={len(sizes2)-1})', linewidth=2, markersize=5)
ax.plot(range(len(sizes3)), sizes3, '^-', color='#3498db',
        label=f'Mixed gens (d={len(sizes3)-1})', linewidth=2, markersize=5)
ax.axhline(y=N, color='gray', linestyle='--', alpha=0.5, label=f'|SL(2,𝔽₇)| = {N}')

ax.set_xlabel("Distance from identity (k)", fontsize=12)
ax.set_ylabel("Ball size |B(k)|", fontsize=12)
ax.set_title(f"Cayley Graph Ball Growth in SL(2, 𝔽₇)", fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# Plot 2: Diameter comparison across primes
ax = axes[1]

primes_for_diam = [5, 7, 11, 13]
diameters_irr = []
diameters_ut = []
group_sizes = []

for pp in primes_for_diam:
    sl2_pp = build_sl2(pp)
    N_pp = len(sl2_pp)
    group_sizes.append(N_pp)

    irr_pp = [g for g in sl2_pp if is_irreducible_charpoly(g, pp)]
    if len(irr_pp) >= 2:
        gen_irr = [irr_pp[0], irr_pp[len(irr_pp)//3]]
        s_irr = ball_growth(gen_irr, pp)
        diameters_irr.append(len(s_irr) - 1)
    else:
        diameters_irr.append(0)

    ut_pp = [g for g in sl2_pp if g[1][0] == 0 and g != identity()]
    if len(ut_pp) >= 2:
        gen_ut = [ut_pp[0], ut_pp[min(1, len(ut_pp)-1)]]
        s_ut = ball_growth(gen_ut, pp)
        diameters_ut.append(len(s_ut) - 1)
    else:
        diameters_ut.append(0)

log_sizes = [math.log(n) for n in group_sizes]

ax.bar(np.arange(len(primes_for_diam)) - 0.15, diameters_irr, 0.3,
       color='#2ecc71', label='Irr. charpoly gens', alpha=0.8)
ax.bar(np.arange(len(primes_for_diam)) + 0.15, diameters_ut, 0.3,
       color='#e74c3c', label='Upper triang. gens', alpha=0.8)

# Add log(N) reference
ax2 = ax.twinx()
ax2.plot(range(len(primes_for_diam)), log_sizes, 'k--', marker='D',
         label='log|G|', alpha=0.6, markersize=6)
ax2.set_ylabel("log|SL(2, 𝔽ₚ)|", fontsize=11)
ax2.legend(loc='upper left', fontsize=10)

ax.set_xticks(range(len(primes_for_diam)))
ax.set_xticklabels([f"p={pp}" for pp in primes_for_diam])
ax.set_xlabel("Prime p", fontsize=12)
ax.set_ylabel("Cayley Graph Diameter", fontsize=12)
ax.set_title("Diameter vs Generator Type", fontsize=13, fontweight='bold')
ax.legend(loc='upper right', fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("cayley_graph_growth.png", dpi=150, bbox_inches='tight')
print("Saved cayley_graph_growth.png")


#!/usr/bin/env python3
"""
Visualization 1: Product Growth Exponents in SL(2, F_p)

Visualizes the empirical growth exponent δ = log|A³|/log|A| - 1
across different primes and subset sizes, colored by obstruction class.
This shows the dichotomy between Borel-trapped sets (low growth)
and escaped/noncommuting sets (high growth).
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import math


def mod(x, p):
    return x % p

def mat_mul(A, B, p):
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return ((mod(a1*a2+b1*c2,p), mod(a1*b2+b1*d2,p)),
            (mod(c1*a2+d1*c2,p), mod(c1*b2+d1*d2,p)))

def mat_inv(M, p):
    (a, b), (c, d) = M
    return ((mod(d,p), mod(-b,p)), (mod(-c,p), mod(a,p)))

def mat_trace(M, p):
    return mod(M[0][0] + M[1][1], p)

def identity():
    return ((1, 0), (0, 1))

def build_sl2(p):
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if mod(a*d - b*c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result

def is_irreducible_charpoly(M, p):
    t = mat_trace(M, p)
    disc = mod(t*t - 4, p)
    if disc == 0:
        return False
    return pow(disc, (p-1)//2, p) != 1

def is_upper_triangular(M):
    return M[1][0] == 0

def triple_product(A, p):
    result = set()
    A_list = list(A)
    A2 = set()
    for a in A_list:
        for b in A_list:
            A2.add(mat_mul(a, b, p))
    for ab in A2:
        for c in A_list:
            result.add(mat_mul(ab, c, p))
    return result

def commuting_pairs(A, p):
    A_list = list(A)
    n = len(A_list)
    total = 0
    commuting = 0
    for i in range(n):
        for j in range(i+1, n):
            total += 1
            if mat_mul(A_list[i], A_list[j], p) == mat_mul(A_list[j], A_list[i], p):
                commuting += 1
    return commuting / total if total > 0 else 1.0

def classify(A, p):
    if all(is_upper_triangular(m) for m in A):
        return "Borel-like"
    has_irr = any(is_irreducible_charpoly(m, p) for m in A)
    cr = commuting_pairs(A, p)
    if has_irr and cr < 1.0:
        return "escaped/noncommuting"
    elif has_irr:
        return "escaped/commuting"
    elif cr > 0.8:
        return "commuting-heavy"
    else:
        return "mixed"

def sample_symmetric_subset(sl2, p, size):
    I = identity()
    result = {I}
    candidates = [m for m in sl2 if m != I]
    sample_size = min(size // 2, len(candidates))
    if sample_size > 0:
        chosen = random.sample(candidates, sample_size)
        for m in chosen:
            result.add(m)
            result.add(mat_inv(m, p))
    return result


random.seed(42)

primes = [5, 7, 11, 13]
colors = {
    "Borel-like": "#e74c3c",
    "escaped/noncommuting": "#2ecc71",
    "escaped/commuting": "#3498db",
    "commuting-heavy": "#f39c12",
    "mixed": "#9b59b6",
}
markers = {
    "Borel-like": "s",
    "escaped/noncommuting": "o",
    "escaped/commuting": "^",
    "commuting-heavy": "D",
    "mixed": "v",
}

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Product Growth Exponents in SL(2, 𝔽ₚ)", fontsize=16, fontweight='bold')

for idx, p in enumerate(primes):
    ax = axes[idx // 2][idx % 2]
    sl2 = build_sl2(p)

    data_by_class = {}
    for target_size in [3, 5, 7, 9, 11]:
        for _ in range(25):
            A = sample_symmetric_subset(sl2, p, target_size)
            if len(A) < 2:
                continue
            A3 = triple_product(A, p)
            delta = math.log(len(A3)) / math.log(len(A)) - 1
            cls = classify(A, p)
            if cls not in data_by_class:
                data_by_class[cls] = ([], [])
            data_by_class[cls][0].append(len(A))
            data_by_class[cls][1].append(delta)

    for cls, (sizes, deltas) in data_by_class.items():
        ax.scatter(sizes, deltas, c=colors.get(cls, 'gray'),
                   marker=markers.get(cls, 'o'), label=cls, alpha=0.7, s=50)

    ax.set_xlabel("|A|", fontsize=12)
    ax.set_ylabel("δ = log|A³|/log|A| - 1", fontsize=12)
    ax.set_title(f"p = {p}, |SL(2, 𝔽ₚ)| = {len(sl2)}", fontsize=13)
    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.legend(fontsize=8, loc='upper right')
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("growth_exponents.png", dpi=150, bbox_inches='tight')
print("Saved growth_exponents.png")


#!/usr/bin/env python3
"""
Visualization 2: Trace Amplification in SL(2, F_p)

Visualizes how the trace set grows through iterated products:
|tr(A)| → |tr(A²)| → |tr(A³)|
Shows the amplification effect that connects group multiplication
to additive structure in the base field F_p.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
import math


def mod(x, p):
    return x % p

def mat_mul(A, B, p):
    (a1, b1), (c1, d1) = A
    (a2, b2), (c2, d2) = B
    return ((mod(a1*a2+b1*c2,p), mod(a1*b2+b1*d2,p)),
            (mod(c1*a2+d1*c2,p), mod(c1*b2+d1*d2,p)))

def mat_inv(M, p):
    (a, b), (c, d) = M
    return ((mod(d,p), mod(-b,p)), (mod(-c,p), mod(a,p)))

def mat_trace(M, p):
    return mod(M[0][0] + M[1][1], p)

def identity():
    return ((1, 0), (0, 1))

def build_sl2(p):
    result = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    if mod(a*d - b*c, p) == 1:
                        result.append(((a, b), (c, d)))
    return result

def is_irreducible_charpoly(M, p):
    t = mat_trace(M, p)
    disc = mod(t*t - 4, p)
    if disc == 0:
        return False
    return pow(disc, (p-1)//2, p) != 1


random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle("Trace Amplification Through Products in SL(2, 𝔽ₚ)",
             fontsize=15, fontweight='bold')

primes = [7, 11, 13]

for idx, p in enumerate(primes):
    ax = axes[idx]
    sl2 = build_sl2(p)

    # Run multiple trials
    results = []
    for _ in range(40):
        # Sample symmetric subset
        I = identity()
        size = random.randint(3, min(15, len(sl2) // 4))
        A_set = {I}
        candidates = [m for m in sl2 if m != I]
        chosen = random.sample(candidates, min(size, len(candidates)))
        for m in chosen:
            A_set.add(m)
            A_set.add(mat_inv(m, p))
        A_list = list(A_set)

        # Compute trace sets at each level
        tr_A = {mat_trace(g, p) for g in A_set}

        A2 = set()
        for a in A_list:
            for b in A_list:
                A2.add(mat_mul(a, b, p))
        tr_A2 = {mat_trace(g, p) for g in A2}

        A3 = set()
        for ab in A2:
            for c in A_list:
                A3.add(mat_mul(ab, c, p))
        tr_A3 = {mat_trace(g, p) for g in A3}

        has_irr = any(is_irreducible_charpoly(m, p) for m in A_set)

        results.append({
            'A_size': len(A_set),
            'tr_sizes': [len(tr_A), len(tr_A2), len(tr_A3)],
            'has_irr': has_irr,
        })

    # Plot trace amplification
    for r in results:
        color = '#2ecc71' if r['has_irr'] else '#e74c3c'
        alpha = 0.6 if r['has_irr'] else 0.4
        label = None
        ax.plot([1, 2, 3], r['tr_sizes'], '-o', color=color,
                alpha=alpha, markersize=4, linewidth=1)

    # Add reference line for p (max possible)
    ax.axhline(y=p, color='navy', linestyle='--', alpha=0.7,
               label=f'p = {p} (max)')

    # Custom legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], color='#2ecc71', marker='o', label='Has irr. charpoly'),
        Line2D([0], [0], color='#e74c3c', marker='o', label='No irr. charpoly'),
        Line2D([0], [0], color='navy', linestyle='--', label=f'p = {p}'),
    ]
    ax.legend(handles=legend_elements, fontsize=9, loc='lower right')

    ax.set_xlabel("Product level k (A, A², A³)", fontsize=11)
    ax.set_ylabel("|tr(Aᵏ)|", fontsize=11)
    ax.set_title(f"p = {p}", fontsize=13)
    ax.set_xticks([1, 2, 3])
    ax.set_xticklabels(["A", "A²", "A³"])
    ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("trace_amplification.png", dpi=150, bbox_inches='tight')
print("Saved trace_amplification.png")
