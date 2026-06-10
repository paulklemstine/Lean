#!/usr/bin/env python3
"""
Applications of Polynomial Width Theory to Obstruction Search

This module demonstrates practical applications of the polynomial width
theory for bounded certificate-family posets, focusing on:

1. Obstruction search frontier estimation
2. Parallel search budget allocation
3. Profile-based family classification
4. Width growth prediction
"""

from math import comb, log2, log, exp, sqrt, pi
from typing import List, Tuple, Dict
from algorithms import (
    polynomial_width_bound, polynomial_exponent, profile_dim,
    bounded_cert_universe_size, rank_level_size, max_rank_level_size,
    compute_profile, enumerate_certificates
)


# ============================================================
# Application 1: Obstruction Search Frontier Estimation
# ============================================================

def estimate_search_frontier(n: int, t: int) -> Dict[str, float]:
    """Estimate the size of the obstruction search frontier.

    In obstruction search for monotone properties, the "frontier" is
    the set of minimal obstructions at a given level. The polynomial
    width theorem bounds this frontier size.

    Args:
        n: Problem size (number of vertices/variables)
        t: Certificate size bound

    Returns:
        Dictionary with frontier size estimates under different models

    Example:
        >>> result = estimate_search_frontier(10, 2)
        >>> result['polynomial_bound'] > 0
        True
    """
    poly_bound = polynomial_width_bound(n, t)
    exp_bound_log2 = bounded_cert_universe_size(n, t)

    # Profile-based estimate (polynomial)
    d = polynomial_exponent(t)

    # Sharp profile bound using rank-level analysis
    pdim = profile_dim(t)
    N = (n + 1) ** (2 * t)
    sharp_bound = max_rank_level_size(pdim, N) if pdim <= 5 and N <= 20 else None

    return {
        'n': n,
        't': t,
        'polynomial_bound': poly_bound,
        'exponential_bound_log2': exp_bound_log2,
        'polynomial_exponent': d,
        'profile_dimension': pdim,
        'sharp_profile_bound': sharp_bound,
    }


# ============================================================
# Application 2: Parallel Search Budget Allocation
# ============================================================

def parallel_budget_allocation(
    n_values: List[int],
    t: int,
    total_cores: int
) -> Dict[int, int]:
    """Allocate parallel processing cores based on polynomial width bounds.

    The polynomial width theorem tells us that the frontier size grows
    as O(n^{d(t)}), so we should allocate cores proportionally to
    n^{d(t)} for each problem size n.

    Args:
        n_values: List of problem sizes to process
        t: Certificate size bound
        total_cores: Total available processing cores

    Returns:
        Dictionary mapping problem size to allocated cores

    Example:
        >>> parallel_budget_allocation([5, 10, 20], 1, 100)
        {5: ..., 10: ..., 20: ...}
    """
    d = polynomial_exponent(t)
    weights = {n: (n + 1) ** d for n in n_values}
    total_weight = sum(weights.values())

    allocation = {}
    remaining = total_cores
    for i, n in enumerate(n_values):
        if i == len(n_values) - 1:
            allocation[n] = remaining
        else:
            cores = max(1, int(total_cores * weights[n] / total_weight))
            allocation[n] = cores
            remaining -= cores

    return allocation


# ============================================================
# Application 3: Width Growth Prediction
# ============================================================

def predict_width_growth(t: int, n_range: range) -> List[Dict]:
    """Predict width growth for certificate families using the polynomial model.

    Produces data for log-log regression and growth rate analysis.

    Args:
        t: Certificate size bound
        n_range: Range of problem sizes

    Returns:
        List of dictionaries with growth data

    Example:
        >>> data = predict_width_growth(1, range(3, 8))
        >>> len(data) == 5
        True
    """
    d = polynomial_exponent(t)
    results = []

    for n in n_range:
        poly = polynomial_width_bound(n, t)
        exp_log = bounded_cert_universe_size(n, t)

        results.append({
            'n': n,
            'polynomial_bound': poly,
            'log_polynomial_bound': log2(poly) if poly > 0 else 0,
            'exponential_bound_log2': exp_log,
            'predicted_exponent': d,
            'effective_exponent': (
                log(poly) / log(n) if n > 1 and poly > 0 else d
            ),
        })

    return results


# ============================================================
# Application 4: Profile Collision Analysis
# ============================================================

def profile_collision_analysis(n: int, t: int) -> Dict:
    """Analyze profile collisions among bounded certificate families.

    Profile collisions occur when distinct families share the same
    profile vector. The polynomial width bound applies to
    profile-injective antichains; collision analysis reveals how
    tight this assumption is in practice.

    Args:
        n: Size of ambient set (small values only)
        t: Certificate size bound

    Returns:
        Collision statistics

    Example:
        >>> result = profile_collision_analysis(2, 1)
        >>> result['collision_rate'] >= 0
        True
    """
    from algorithms import enumerate_families

    families = enumerate_families(n, t)
    profile_map: Dict[Tuple, List] = {}

    for family in families:
        profile = compute_profile(family, t)
        if profile not in profile_map:
            profile_map[profile] = []
        profile_map[profile].append(family)

    collision_sizes = [len(v) for v in profile_map.values()]
    total_families = len(families)
    distinct_profiles = len(profile_map)

    # Find maximum antichain among families with same profile
    max_collision_antichain = 0
    for profile, fams in profile_map.items():
        if len(fams) > 1:
            # Check for incomparable pairs
            antichain = []
            for f in fams:
                if all(not (f <= g or g <= f) for g in antichain):
                    antichain.append(f)
            max_collision_antichain = max(max_collision_antichain, len(antichain))

    return {
        'total_families': total_families,
        'distinct_profiles': distinct_profiles,
        'collision_rate': 1 - distinct_profiles / total_families if total_families > 0 else 0,
        'max_collision_size': max(collision_sizes),
        'max_collision_antichain': max_collision_antichain,
        'polynomial_bound': polynomial_width_bound(n, t),
    }


# ============================================================
# Application 5: Complexity Regime Classification
# ============================================================

def classify_complexity_regime(n: int, t: int) -> str:
    """Classify the computational complexity regime for obstruction search.

    Based on the polynomial width bounds, classify whether brute-force
    search, profile-guided search, or polynomial-time methods are appropriate.

    Args:
        n: Problem size
        t: Certificate size bound

    Returns:
        Classification string

    Example:
        >>> classify_complexity_regime(5, 1)
        'polynomial-feasible'
    """
    d = polynomial_exponent(t)
    poly = polynomial_width_bound(n, t)
    exp_log = bounded_cert_universe_size(n, t)

    if poly <= 10**6:
        return "polynomial-feasible"
    elif poly <= 10**12:
        return "profile-guided"
    elif exp_log <= 100:
        return "exponential-feasible"
    else:
        return "intractable-without-structure"


# ============================================================
# Main: Demonstration
# ============================================================

def main():
    print("=" * 60)
    print("APPLICATIONS OF POLYNOMIAL WIDTH THEORY")
    print("=" * 60)

    # Application 1: Frontier estimation
    print("\n--- Application 1: Search Frontier Estimation ---\n")
    for t in [1, 2]:
        print(f"Certificate size bound t = {t}:")
        for n in [5, 10, 20, 50]:
            result = estimate_search_frontier(n, t)
            print(f"  n={n}: poly_bound ≈ 10^{log2(result['polynomial_bound']):.0f} bits, "
                  f"exp_bound ≈ 2^{result['exponential_bound_log2']}")
        print()

    # Application 2: Budget allocation
    print("--- Application 2: Parallel Budget Allocation ---\n")
    n_values = [5, 10, 20, 50]
    for t in [1, 2]:
        alloc = parallel_budget_allocation(n_values, t, 1000)
        print(f"t={t}, 1000 cores: {alloc}")
    print()

    # Application 3: Growth prediction
    print("--- Application 3: Width Growth Prediction ---\n")
    for t in [1, 2]:
        data = predict_width_growth(t, range(3, 11))
        print(f"t={t}, theoretical exponent = {polynomial_exponent(t)}:")
        for d in data:
            print(f"  n={d['n']}: log2(bound)={d['log_polynomial_bound']:.1f}, "
                  f"effective_exp={d['effective_exponent']:.1f}")
        print()

    # Application 4: Profile collisions (small case)
    print("--- Application 4: Profile Collision Analysis ---\n")
    for n in [2, 3]:
        for t in [0, 1]:
            result = profile_collision_analysis(n, t)
            print(f"n={n}, t={t}: {result['total_families']} families, "
                  f"{result['distinct_profiles']} profiles, "
                  f"collision rate={result['collision_rate']:.2%}")
    print()

    # Application 5: Complexity classification
    print("--- Application 5: Complexity Regime Classification ---\n")
    for t in [1, 2, 3]:
        for n in [3, 5, 10, 20]:
            regime = classify_complexity_regime(n, t)
            print(f"  n={n}, t={t}: {regime}")
        print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration: Polynomial Width Bounds for Certificate-Family Posets

This script demonstrates the key results from the polynomial width theory
for bounded certificate families, comparing the new polynomial profile-based
bounds against the existing exponential bounds from the catalog.

Usage:
    python demo.py
"""

from math import comb, log2, log
from itertools import product


def bounded_cert_universe_size(n: int, t: int) -> int:
    """Number of certificate pairs (A, B) where A, B ⊆ {0,...,n-1}, |A|,|B| ≤ t."""
    count_bounded_subsets = sum(comb(n, k) for k in range(t + 1))
    return count_bounded_subsets ** 2


def exponential_bound(n: int, t: int) -> int:
    """Exponential antichain bound: 2^|universe|."""
    return 2 ** bounded_cert_universe_size(n, t)


def profile_dim(t: int) -> int:
    """Profile dimension: (t+1)^2 size classes."""
    return (t + 1) ** 2


def polynomial_bound(n: int, t: int) -> int:
    """Polynomial profile-width bound: ((n+1)^{2t} + 1)^{profileDim(t)}."""
    return ((n + 1) ** (2 * t) + 1) ** profile_dim(t)


def polynomial_exponent(t: int) -> int:
    """The exponent d(t) such that the bound is O(n^{d(t)}).
    We have d(t) = 2*t*profileDim(t) + profileDim(t) = (2t+1)*(t+1)^2."""
    return (2 * t + 1) * profile_dim(t)


def box_width_bound(m: int, N: int) -> int:
    """Width of [0,N]^m under product order: at most (N+1)^m."""
    return (N + 1) ** m


def rank_level_size(m: int, N: int, r: int) -> int:
    """Number of points in [0,N]^m with coordinate sum = r.
    Uses inclusion-exclusion on the stars-and-bars formula."""
    total = 0
    for k in range(m + 1):
        adjusted_r = r - k * (N + 1)
        if adjusted_r < 0:
            break
        sign = (-1) ** k
        total += sign * comb(m, k) * comb(adjusted_r + m - 1, m - 1)
    return max(0, total)


def max_rank_level(m: int, N: int) -> int:
    """Maximum rank-level size (sharp width bound for product of chains)."""
    return max(rank_level_size(m, N, r) for r in range(m * N + 1))


def print_separator():
    print("=" * 72)


def demo_box_width():
    """Demo 1: Width of integer boxes under product order."""
    print_separator()
    print("DEMO 1: Width of Integer Boxes [0,N]^m (Product Order)")
    print_separator()
    print()
    print("The Box Width Theorem states that any antichain in [0,N]^m has")
    print("at most (N+1)^m elements. The sharp bound equals the maximum")
    print("rank-level size under the sum-of-coordinates grading.")
    print()

    print(f"{'m':>3} {'N':>3} {'(N+1)^m':>12} {'Sharp bound':>12} {'Ratio':>8}")
    print("-" * 42)
    for m in range(2, 6):
        for N in [3, 5, 10]:
            crude = box_width_bound(m, N)
            sharp = max_rank_level(m, N)
            ratio = crude / sharp if sharp > 0 else float('inf')
            print(f"{m:>3} {N:>3} {crude:>12} {sharp:>12} {ratio:>8.1f}")
    print()
    print("Note: The sharp bound is O(N^{m-1}) vs the crude O(N^m).")
    print()


def demo_rank_levels():
    """Demo 2: Rank-level distribution in [0,N]^m."""
    print_separator()
    print("DEMO 2: Rank-Level Size Distribution in [0,N]^m")
    print_separator()
    print()
    print("Profile vectors in antichain analysis correspond to lattice")
    print("points at specific rank levels. The largest level determines width.")
    print()

    m, N = 3, 5
    print(f"Distribution for [0,{N}]^{m} (m={m}, N={N}):")
    print(f"Max rank = m*N = {m * N}")
    print()
    print(f"{'Rank r':>8} {'Level size':>12}")
    print("-" * 24)
    max_size = 0
    max_r = 0
    for r in range(m * N + 1):
        size = rank_level_size(m, N, r)
        if size > max_size:
            max_size = size
            max_r = r
        bar = "#" * min(size, 40)
        print(f"{r:>8} {size:>12} {bar}")
    print()
    print(f"Maximum level size: {max_size} at rank {max_r}")
    print(f"Total lattice points: {(N + 1) ** m}")
    print(f"Ratio (total/max): {(N + 1) ** m / max_size:.1f}")
    print()


def demo_polynomial_vs_exponential():
    """Demo 3: Polynomial vs exponential bounds for certificate families."""
    print_separator()
    print("DEMO 3: Polynomial vs Exponential Width Bounds")
    print_separator()
    print()
    print("Comparison of the exponential catalog bound 2^|universe| with")
    print("the polynomial profile-based bound ((n+1)^{2t}+1)^{(t+1)^2}.")
    print()

    for t in [2, 3]:
        print(f"Certificate size bound t = {t}")
        print(f"Profile dimension = {profile_dim(t)}")
        print(f"Polynomial exponent d(t) = {polynomial_exponent(t)}")
        print()
        print(f"{'n':>4} {'|Universe|':>12} {'log2(Exp bound)':>16} "
              f"{'log2(Poly bound)':>17} {'Improvement':>12}")
        print("-" * 65)

        for n in [3, 4, 5, 6, 8, 10]:
            u = bounded_cert_universe_size(n, t)
            exp_log = u  # log2(2^u) = u
            poly = polynomial_bound(n, t)
            poly_log = log2(poly) if poly > 0 else 0
            improvement = exp_log / poly_log if poly_log > 0 else float('inf')
            print(f"{n:>4} {u:>12} {exp_log:>16.1f} {poly_log:>17.1f} "
                  f"{improvement:>12.1f}x")
        print()


def demo_profile_structure():
    """Demo 4: Profile structure for small examples."""
    print_separator()
    print("DEMO 4: Certificate Profile Structure")
    print_separator()
    print()
    print("For small n and t, we enumerate the profile space and count")
    print("distinct achievable profiles.")
    print()

    for t in [1, 2]:
        print(f"Certificate size bound t = {t}")
        print(f"Profile dimension: {profile_dim(t)} coordinates")
        print()
        print(f"{'n':>4} {'|Universe|':>12} {'Max profiles':>14} "
              f"{'Profile bound':>14}")
        print("-" * 50)

        for n in range(1, 7):
            u = bounded_cert_universe_size(n, t)
            # Upper bound on number of achievable profiles
            max_profiles = min(2 ** u, polynomial_bound(n, t))
            poly_bound = polynomial_bound(n, t)
            print(f"{n:>4} {u:>12} {max_profiles:>14} {poly_bound:>14}")
        print()


def demo_log_log_fit():
    """Demo 5: Log-log slope analysis for width growth."""
    print_separator()
    print("DEMO 5: Log-Log Slope Analysis")
    print_separator()
    print()
    print("If width grows as n^d, then log(width) vs log(n) has slope d.")
    print("We analyze the polynomial bound's effective exponent.")
    print()

    for t in [1, 2, 3]:
        print(f"t = {t}, theoretical exponent d(t) = {polynomial_exponent(t)}")
        ns = [3, 5, 10, 20, 50, 100]
        log_ns = [log(n) for n in ns]
        log_bounds = [log(polynomial_bound(n, t)) for n in ns]

        # Compute slopes between consecutive points
        slopes = []
        for i in range(1, len(ns)):
            slope = (log_bounds[i] - log_bounds[i - 1]) / (log_ns[i] - log_ns[i - 1])
            slopes.append(slope)

        print(f"  Effective slopes (log-log): ", end="")
        print(", ".join(f"{s:.2f}" for s in slopes))
        print(f"  Expected: {2 * t * profile_dim(t):.1f} "
              f"(leading term of ((n+1)^{{2t}}+1)^{{(t+1)^2}})")
        print()


def main():
    print()
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  POLYNOMIAL WIDTH BOUNDS FOR CERTIFICATE-FAMILY POSETS          ║")
    print("║  Demonstration of Profile-Based Width Analysis                  ║")
    print("╚══════════════════════════════════════════════════════════════════╝")
    print()
    print("This demo accompanies the formally verified theorems in")
    print("Pythagorean/PolynomialWidth.lean, which establish polynomial")
    print("bounds on antichain sizes in bounded certificate-family posets")
    print("via profile compression.")
    print()

    demo_box_width()
    demo_rank_levels()
    demo_polynomial_vs_exponential()
    demo_profile_structure()
    demo_log_log_fit()

    print_separator()
    print("KEY TAKEAWAYS")
    print_separator()
    print()
    print("1. The exponential bound 2^|universe| grows as 2^{Θ(n^{2t})},")
    print("   making it useless for algorithmic obstruction search.")
    print()
    print("2. The polynomial bound ((n+1)^{2t}+1)^{(t+1)^2} grows as")
    print("   O(n^{2t(t+1)^2}), which is polynomial for fixed t.")
    print()
    print("3. For profile-injective antichains, the polynomial bound is")
    print("   exponentially tighter than the catalog's exponential bound.")
    print()
    print("4. The profile method identifies 'profile collisions' as the")
    print("   sole source of exponential antichain behavior.")
    print()


if __name__ == "__main__":
    main()
