#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Primewise Persistence Stability

Demonstrates practical applications of the max-envelope stability principle:
1. Arithmetic-sensitive topological data analysis
2. Signal decomposition by prime channels
3. Robust distance computation for persistence summaries
"""

from typing import Dict, List, Tuple
import math


# ===========================================================================
# Application 1: Arithmetic TDA — Analyzing Integer-Valued Data
# ===========================================================================

def factorize_small(n: int) -> Dict[int, int]:
    """Return prime factorization of n as {prime: exponent}.

    >>> factorize_small(60)
    {2: 2, 3: 1, 5: 1}
    """
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def arithmetic_filtration(values: List[int], primes: List[int],
                            max_level: int = 20) -> Dict[int, Dict[int, int]]:
    """Build an arithmetic filtration from integer data.

    For each prime p, construct a Betti-like curve: at level t,
    count how many values have p-adic valuation >= t.

    This creates a primewise persistence profile from raw integer data,
    enabling arithmetic-sensitive topological analysis.

    Args:
        values: list of positive integers
        primes: primes to decompose by
        max_level: maximum filtration level

    Returns:
        {prime: {level: count}} Betti-like profile

    Example:
        >>> arithmetic_filtration([4, 6, 8, 9, 12], [2, 3])
        {2: {0: 5, 1: 4, 2: 2, 3: 1}, 3: {0: 5, 1: 3, 2: 1}}
    """
    betti = {}
    for p in primes:
        betti[p] = {}
        for level in range(max_level):
            count = sum(1 for v in values if v > 0 and p_adic_val(v, p) >= level)
            betti[p][level] = count
    return betti


def p_adic_val(n: int, p: int) -> int:
    """Compute the p-adic valuation of n."""
    if n == 0 or p < 2:
        return 0
    v = 0
    while n % p == 0:
        v += 1
        n //= p
    return v


def arithmetic_tda_demo():
    """Demonstrate arithmetic TDA on sample datasets."""
    print("=" * 70)
    print("Application 1: Arithmetic Topological Data Analysis")
    print("=" * 70)

    # Dataset A: numbers with rich 2-structure
    data_A = [2, 4, 8, 16, 32, 6, 12, 24, 48, 96]
    # Dataset B: numbers with rich 3-structure
    data_B = [3, 9, 27, 81, 243, 6, 18, 54, 162, 486]

    primes = [2, 3, 5]

    betti_A = arithmetic_filtration(data_A, primes)
    betti_B = arithmetic_filtration(data_B, primes)

    print(f"\nDataset A (2-heavy): {data_A}")
    print(f"Dataset B (3-heavy): {data_B}")

    print("\n--- Primewise Betti Profiles ---")
    for p in primes:
        print(f"  Prime {p}:")
        for t in range(6):
            vA = betti_A.get(p, {}).get(t, 0)
            vB = betti_B.get(p, {}).get(t, 0)
            d = abs(vA - vB)
            bar_A = "█" * vA
            bar_B = "█" * vB
            print(f"    t={t}: A={vA:2d} {bar_A:<12s}  "
                  f"B={vB:2d} {bar_B:<12s}  dist={d}")

    print("\n--- Global vs Primewise Distances ---")
    for t in range(6):
        gA = max(betti_A.get(p, {}).get(t, 0) for p in primes)
        gB = max(betti_B.get(p, {}).get(t, 0) for p in primes)
        gd = abs(gA - gB)
        pw = max(abs(betti_A.get(p, {}).get(t, 0) -
                      betti_B.get(p, {}).get(t, 0)) for p in primes)
        gap = "STRICT GAP" if gd < pw else "TIGHT"
        print(f"  t={t}: global_dist={gd}, max_primewise={pw}  [{gap}]")


# ===========================================================================
# Application 2: Signal Decomposition by Prime Channels
# ===========================================================================

def prime_channel_decomposition(signal: List[int],
                                  primes: List[int]) -> Dict[int, List[float]]:
    """Decompose a signal into prime channels.

    Each channel p captures the p-primary component of the signal:
    the p-adic valuation at each position, normalized.

    This is analogous to a Fourier decomposition, but using prime
    factorization instead of frequencies.
    """
    channels = {}
    for p in primes:
        channels[p] = [p_adic_val(abs(x), p) if x != 0 else 0
                        for x in signal]
    return channels


def signal_demo():
    """Demonstrate prime channel decomposition."""
    print("\n" + "=" * 70)
    print("Application 2: Signal Decomposition by Prime Channels")
    print("=" * 70)

    # A signal with periodic arithmetic structure
    signal = [2**k * 3**(4-k) for k in range(5)] + \
             [5 * 2**k for k in range(5)]
    print(f"\nSignal: {signal}")

    primes = [2, 3, 5]
    channels = prime_channel_decomposition(signal, primes)

    print("\n--- Prime Channel Decomposition ---")
    print(f"{'Position':>10s}", end="")
    for i, v in enumerate(signal):
        print(f" {i:4d}", end="")
    print()
    print(f"{'Value':>10s}", end="")
    for v in signal:
        print(f" {v:4d}", end="")
    print()
    for p in primes:
        print(f"{'v_' + str(p):>10s}", end="")
        for v in channels[p]:
            print(f" {v:4.0f}", end="")
        print()

    # Compute which channel dominates at each position
    print(f"\n{'Dominant':>10s}", end="")
    for i in range(len(signal)):
        vals = {p: channels[p][i] for p in primes}
        dom = max(vals, key=vals.get) if max(vals.values()) > 0 else "-"
        print(f" {dom:>4}", end="")
    print()


# ===========================================================================
# Application 3: Robust Distance Computation
# ===========================================================================

def robust_persistence_distance(
    data_A: List[int], data_B: List[int],
    primes: List[int], max_level: int = 10
) -> Dict:
    """Compute a robust distance between two integer datasets.

    Uses the primewise max-envelope bound as a certified distance
    that is provably an upper bound for the global Betti distance.

    Returns:
        Dictionary with global distance, primewise distances,
        upper bound, and which prime is the bottleneck.
    """
    betti_A = arithmetic_filtration(data_A, primes, max_level)
    betti_B = arithmetic_filtration(data_B, primes, max_level)

    # Compute distances at each level
    global_dists = []
    primewise_maxes = []
    bottleneck_primes = []

    for t in range(max_level):
        gA = max(betti_A.get(p, {}).get(t, 0) for p in primes) if primes else 0
        gB = max(betti_B.get(p, {}).get(t, 0) for p in primes) if primes else 0
        gd = abs(gA - gB)
        global_dists.append(gd)

        pw_dists = {p: abs(betti_A.get(p, {}).get(t, 0) -
                           betti_B.get(p, {}).get(t, 0)) for p in primes}
        pw_max = max(pw_dists.values()) if pw_dists else 0
        primewise_maxes.append(pw_max)

        bp = max(pw_dists, key=pw_dists.get) if pw_dists else None
        bottleneck_primes.append(bp)

    sup_global = max(global_dists) if global_dists else 0
    sup_primewise = max(primewise_maxes) if primewise_maxes else 0

    return {
        "global_sup_dist": sup_global,
        "primewise_sup_bound": sup_primewise,
        "gap": sup_primewise - sup_global,
        "bottleneck_prime": max(set(bottleneck_primes),
                                 key=bottleneck_primes.count)
                             if bottleneck_primes else None,
        "level_details": list(zip(global_dists, primewise_maxes,
                                   bottleneck_primes))
    }


def robust_distance_demo():
    """Demonstrate robust distance computation."""
    print("\n" + "=" * 70)
    print("Application 3: Robust Persistence Distance Computation")
    print("=" * 70)

    datasets = {
        "Highly 2-divisible": [2, 4, 8, 16, 32, 64, 128],
        "Highly 3-divisible": [3, 9, 27, 81, 243, 729, 2187],
        "Mixed 2,3": [6, 12, 18, 24, 36, 48, 72],
        "Primes only": [2, 3, 5, 7, 11, 13, 17],
        "Powers of 6": [6, 36, 216, 1296, 7776, 46656, 279936],
    }

    primes = [2, 3, 5, 7]
    names = list(datasets.keys())

    print(f"\n{'':20s}", end="")
    for name in names:
        print(f" {name[:8]:>10s}", end="")
    print()

    for i, name_i in enumerate(names):
        print(f"{name_i[:20]:20s}", end="")
        for j, name_j in enumerate(names):
            if i == j:
                print(f" {'---':>10s}", end="")
            else:
                result = robust_persistence_distance(
                    datasets[name_i], datasets[name_j], primes)
                d = result["global_sup_dist"]
                b = result["primewise_sup_bound"]
                print(f" {d:3d}≤{b:<5d}", end="")
        print()

    print("\n--- Detailed Analysis: '2-heavy' vs '3-heavy' ---")
    result = robust_persistence_distance(
        datasets["Highly 2-divisible"],
        datasets["Highly 3-divisible"],
        primes
    )
    print(f"  Global sup distance: {result['global_sup_dist']}")
    print(f"  Primewise sup bound: {result['primewise_sup_bound']}")
    print(f"  Gap: {result['gap']}")
    print(f"  Bottleneck prime: {result['bottleneck_prime']}")
    print("  Level details (global_dist, primewise_max, bottleneck_p):")
    for t, (gd, pm, bp) in enumerate(result['level_details'][:8]):
        print(f"    t={t}: global={gd}, max_pw={pm}, bottleneck_p={bp}")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    arithmetic_tda_demo()
    signal_demo()
    robust_distance_demo()
    print("\n" + "=" * 70)
    print("All applications demonstrated successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
demo.py — Primewise Completeness for Derived Persistence Invariants

Interactive demonstration of the max-envelope stability principle for
prime-indexed Betti curves. Shows:
1. Construction of small prime-supported persistence examples
2. Computation of primewise Betti curves and diagram proxies
3. Display of the certified max-envelope upper bound
4. Search for strictness examples (where the bound is not tight)
5. Testing of the interval-decomposability conjecture
"""

import random
from typing import Dict, List, Tuple

# ===========================================================================
# Core Data Structures
# ===========================================================================

class PrimewiseBettiProfile:
    """A prime-indexed family of Betti curves with finite prime support.

    Each prime p has a Betti function beta_p : N -> N, representing
    the p-primary persistence counting invariant at each filtration level.
    """

    def __init__(self, betti: Dict[int, Dict[int, int]], primes: List[int]):
        """
        Args:
            betti: {prime: {time: value}} dictionary
            primes: list of supported primes
        """
        self.betti = betti
        self.primes = sorted(primes)

    def betti_at(self, p: int, t: int) -> int:
        """Return beta_p(t). Zero outside support."""
        if p not in self.betti:
            return 0
        return self.betti[p].get(t, 0)

    def global_betti(self, t: int) -> int:
        """Global Betti curve: max over primes of beta_p(t)."""
        if not self.primes:
            return 0
        return max(self.betti_at(p, t) for p in self.primes)

    def __repr__(self):
        lines = [f"PrimewiseBettiProfile(primes={self.primes})"]
        for p in self.primes:
            vals = {t: v for t, v in self.betti.get(p, {}).items() if v > 0}
            if vals:
                lines.append(f"  p={p}: {vals}")
        return "\n".join(lines)


def nat_dist(a: int, b: int) -> int:
    """Natural number distance |a - b|."""
    return abs(a - b)


def primewise_betti_dist(P: PrimewiseBettiProfile, Q: PrimewiseBettiProfile,
                          p: int, t: int) -> int:
    """Primewise distance at prime p and time t."""
    return nat_dist(P.betti_at(p, t), Q.betti_at(p, t))


def global_betti_dist(P: PrimewiseBettiProfile, Q: PrimewiseBettiProfile,
                       t: int) -> int:
    """Global Betti distance at time t."""
    return nat_dist(P.global_betti(t), Q.global_betti(t))


def primewise_derived_upper_bound(P: PrimewiseBettiProfile,
                                    Q: PrimewiseBettiProfile,
                                    t: int) -> int:
    """Max over primes of primewise distances at time t.

    This is the certified upper bound from the max-envelope theorem.
    """
    all_primes = sorted(set(P.primes) | set(Q.primes))
    if not all_primes:
        return 0
    return max(primewise_betti_dist(P, Q, p, t) for p in all_primes)


def sup_global_dist(P: PrimewiseBettiProfile, Q: PrimewiseBettiProfile,
                     max_t: int = 20) -> int:
    """Sup over t of global Betti distance."""
    return max(global_betti_dist(P, Q, t) for t in range(max_t + 1))


def sup_primewise_dist(P: PrimewiseBettiProfile, Q: PrimewiseBettiProfile,
                        max_t: int = 20) -> int:
    """Sup over p and t of primewise distances."""
    all_primes = sorted(set(P.primes) | set(Q.primes))
    if not all_primes:
        return 0
    return max(primewise_betti_dist(P, Q, p, t)
               for p in all_primes for t in range(max_t + 1))


# ===========================================================================
# Demo 1: Construct small prime-supported examples
# ===========================================================================

def demo_basic_examples():
    """Construct and display basic persistence profile examples."""
    print("=" * 70)
    print("DEMO 1: Basic Prime-Supported Persistence Examples")
    print("=" * 70)

    # Profile M: p=2 dominates at t=0
    M = PrimewiseBettiProfile(
        betti={2: {0: 5, 1: 3, 2: 1}, 3: {0: 3, 1: 2}},
        primes=[2, 3]
    )

    # Profile N: p=3 dominates at t=0
    N = PrimewiseBettiProfile(
        betti={2: {0: 3, 1: 2}, 3: {0: 5, 1: 3, 2: 1}},
        primes=[2, 3]
    )

    print(f"\nProfile M:\n{M}")
    print(f"\nProfile N:\n{N}")

    print("\n--- Global Betti Curves ---")
    for t in range(5):
        gM = M.global_betti(t)
        gN = N.global_betti(t)
        print(f"  t={t}: global_M={gM}, global_N={gN}, "
              f"global_dist={nat_dist(gM, gN)}")

    print("\n--- Primewise Distances ---")
    for p in [2, 3]:
        for t in range(5):
            d = primewise_betti_dist(M, N, p, t)
            if d > 0:
                print(f"  p={p}, t={t}: dist={d}")

    print("\n--- Max-Envelope Bound ---")
    for t in range(5):
        gd = global_betti_dist(M, N, t)
        ub = primewise_derived_upper_bound(M, N, t)
        status = "TIGHT" if gd == ub else f"GAP={ub - gd}"
        print(f"  t={t}: global_dist={gd} ≤ upper_bound={ub}  [{status}]")


# ===========================================================================
# Demo 2: Primewise Betti curves and diagrams
# ===========================================================================

def demo_primewise_curves():
    """Display primewise Betti curves as text diagrams."""
    print("\n" + "=" * 70)
    print("DEMO 2: Primewise Betti Curves")
    print("=" * 70)

    P = PrimewiseBettiProfile(
        betti={2: {0: 4, 1: 3, 2: 2, 3: 1},
               3: {0: 2, 1: 4, 2: 3, 3: 2, 4: 1},
               5: {1: 1, 2: 3, 3: 5, 4: 3, 5: 1}},
        primes=[2, 3, 5]
    )

    print(f"\nProfile:\n{P}")
    print("\n--- Text Diagram (height = value) ---")
    max_t = 7
    max_val = max(P.global_betti(t) for t in range(max_t + 1))

    for row in range(max_val, 0, -1):
        line = f"{row:2d} |"
        for t in range(max_t + 1):
            chars = []
            for p in P.primes:
                if P.betti_at(p, t) >= row:
                    chars.append(str(p)[0])
            if P.global_betti(t) >= row:
                line += " " + ("".join(chars) if chars else "·")
            else:
                line += "  "
        print(line)
    print(f"   +{'--' * (max_t + 1)}")
    print(f"    " + "".join(f"{t:2d}" for t in range(max_t + 1)))
    print(f"    (t = filtration level)")


# ===========================================================================
# Demo 3: Certified max-envelope upper bound
# ===========================================================================

def demo_certified_bound():
    """Display the certified max-envelope upper bound."""
    print("\n" + "=" * 70)
    print("DEMO 3: Certified Max-Envelope Upper Bound")
    print("=" * 70)

    M = PrimewiseBettiProfile(
        betti={2: {0: 5, 1: 3}, 3: {0: 3, 1: 5}},
        primes=[2, 3]
    )
    N = PrimewiseBettiProfile(
        betti={2: {0: 3, 1: 5}, 3: {0: 5, 1: 3}},
        primes=[2, 3]
    )

    print(f"\nProfile M:\n{M}")
    print(f"\nProfile N:\n{N}")

    print("\n--- Certified Bound (Theorem: betti_envelope_pointwise) ---")
    print("For each t: natDist(globalBetti_M(t), globalBetti_N(t))")
    print("           ≤ max_p natDist(betti_M(p,t), betti_N(p,t))")
    print()

    for t in range(5):
        gd = global_betti_dist(M, N, t)
        ub = primewise_derived_upper_bound(M, N, t)
        details = []
        for p in sorted(set(M.primes) | set(N.primes)):
            d = primewise_betti_dist(M, N, p, t)
            details.append(f"d_{p}={d}")
        print(f"  t={t}: {gd} ≤ max({', '.join(details)}) = {ub}  "
              f"{'✓ TIGHT' if gd == ub else '✓ STRICT GAP'}")


# ===========================================================================
# Demo 4: Search for strictness examples
# ===========================================================================

def demo_strictness_search():
    """Search for examples where the bound is strict."""
    print("\n" + "=" * 70)
    print("DEMO 4: Strictness Search")
    print("=" * 70)
    print("\nSearching for profiles where global_dist < max primewise_dist...")
    print("(This is the phenomenon proven in exists_strict_betti_gap)")

    strict_count = 0
    tight_count = 0
    total = 0

    random.seed(42)
    for trial in range(200):
        primes = [2, 3, 5]
        max_t = 5

        betti_M = {}
        betti_N = {}
        for p in primes:
            betti_M[p] = {t: random.randint(0, 8) for t in range(max_t)}
            betti_N[p] = {t: random.randint(0, 8) for t in range(max_t)}

        M = PrimewiseBettiProfile(betti_M, primes)
        N = PrimewiseBettiProfile(betti_N, primes)

        for t in range(max_t):
            gd = global_betti_dist(M, N, t)
            ub = primewise_derived_upper_bound(M, N, t)
            total += 1
            if gd < ub:
                strict_count += 1
            else:
                tight_count += 1

    print(f"\nResults over {total} (profile, time) pairs:")
    print(f"  Strict inequality (gap > 0): {strict_count} "
          f"({100*strict_count/total:.1f}%)")
    print(f"  Tight (equality):            {tight_count} "
          f"({100*tight_count/total:.1f}%)")

    # Canonical example
    print("\n--- Canonical Strictness Example ---")
    M = PrimewiseBettiProfile(
        betti={2: {0: 5}, 3: {0: 3}}, primes=[2, 3])
    N = PrimewiseBettiProfile(
        betti={2: {0: 3}, 3: {0: 5}}, primes=[2, 3])

    t = 0
    gd = global_betti_dist(M, N, t)
    ub = primewise_derived_upper_bound(M, N, t)
    print(f"  M: beta_2(0)=5, beta_3(0)=3 → global(0)={M.global_betti(0)}")
    print(f"  N: beta_2(0)=3, beta_3(0)=5 → global(0)={N.global_betti(0)}")
    print(f"  Global dist = |{M.global_betti(0)}-{N.global_betti(0)}| = {gd}")
    print(f"  Primewise: d_2={primewise_betti_dist(M,N,2,0)}, "
          f"d_3={primewise_betti_dist(M,N,3,0)}")
    print(f"  Upper bound = max(d_2, d_3) = {ub}")
    print(f"  ∴ {gd} < {ub}: STRICT GAP of {ub - gd}")


# ===========================================================================
# Demo 5: Test the interval-decomposability conjecture
# ===========================================================================

def make_interval_profile(primes: List[int],
                           intervals: Dict[int, Tuple[int, int]]):
    """Create a profile where each prime's Betti curve is an interval indicator."""
    betti = {}
    for p in primes:
        a, b = intervals.get(p, (0, -1))  # empty interval by default
        betti[p] = {t: (1 if a <= t <= b else 0) for t in range(max(b + 2, 10))}
    return PrimewiseBettiProfile(betti, primes)


def demo_conjecture_test():
    """Test the interval-decomposability conjecture on random instances."""
    print("\n" + "=" * 70)
    print("DEMO 5: Testing Interval-Decomposability Conjecture")
    print("=" * 70)
    print("\nConjecture: Under interval-decomposability, the bound is tight.")
    print("i.e., for indicator-of-interval Betti curves,")
    print("  natDist(globalBetti_M(t), globalBetti_N(t))")
    print("  = max_p natDist(betti_M(p,t), betti_N(p,t))")

    primes = [2, 3, 5]
    max_t = 10
    counterexample_found = False

    random.seed(123)
    n_tests = 500
    for trial in range(n_tests):
        intervals_M = {p: tuple(sorted([random.randint(0, max_t),
                                          random.randint(0, max_t)]))
                        for p in primes}
        intervals_N = {p: tuple(sorted([random.randint(0, max_t),
                                          random.randint(0, max_t)]))
                        for p in primes}

        M = make_interval_profile(primes, intervals_M)
        N = make_interval_profile(primes, intervals_N)

        for t in range(max_t + 1):
            gd = global_betti_dist(M, N, t)
            ub = primewise_derived_upper_bound(M, N, t)
            if gd != ub and ub > 0:
                # Check if all primes have 0/1 indicator values
                if gd < ub:
                    counterexample_found = True
                    print(f"\n  COUNTEREXAMPLE at trial {trial}, t={t}:")
                    print(f"    M intervals: {intervals_M}")
                    print(f"    N intervals: {intervals_N}")
                    print(f"    global_dist={gd} ≠ upper_bound={ub}")
                    break
        if counterexample_found:
            break

    if counterexample_found:
        print("\n  ⚠ Conjecture REFUTED for general interval profiles!")
        print("  The max-envelope bound is not always tight even with")
        print("  indicator-of-interval Betti curves.")
    else:
        print(f"\n  ✓ Conjecture holds for all {n_tests} random instances tested.")
        print("  No counterexample found with primes {2,3,5} and intervals in [0,10].")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════════════════╗")
    print("║  Primewise Completeness for Derived Persistence Invariants       ║")
    print("║  — Interactive Demonstration —                                   ║")
    print("╚════════════════════════════════════════════════════════════════════╝")

    demo_basic_examples()
    demo_primewise_curves()
    demo_certified_bound()
    demo_strictness_search()
    demo_conjecture_test()

    print("\n" + "=" * 70)
    print("All demos complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Prime Channel Decomposition of Integer Persistence

This script visualizes how integer persistence data decomposes into
independent prime channels, and how the global Betti curve emerges
as the max-envelope of these channels.

Shows:
- Individual prime channels for sample data
- The max-envelope reconstruction
- How perturbations in one channel affect the global curve
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Build sample profiles ---
# A filtration of integer data where different primes "activate" at different levels
T = 15
times = np.arange(T)

# Profile A: a naturally occurring arithmetic filtration
# Imagine filtering integers by divisibility threshold
np.random.seed(42)

# Prime 2: early onset, gradual decay
betti_A_2 = np.array([0, 2, 5, 7, 8, 7, 5, 3, 2, 1, 0, 0, 0, 0, 0])
# Prime 3: mid onset, sharp peak
betti_A_3 = np.array([0, 0, 1, 3, 6, 8, 9, 7, 4, 2, 1, 0, 0, 0, 0])
# Prime 5: late onset, symmetric
betti_A_5 = np.array([0, 0, 0, 0, 1, 3, 5, 8, 9, 8, 5, 3, 1, 0, 0])
# Prime 7: very late, small
betti_A_7 = np.array([0, 0, 0, 0, 0, 0, 1, 2, 4, 6, 7, 6, 4, 2, 0])

global_A = np.maximum.reduce([betti_A_2, betti_A_3, betti_A_5, betti_A_7])

# Profile B: perturbed version (shifts in prime channels)
betti_B_2 = np.array([0, 3, 6, 8, 7, 5, 3, 2, 1, 0, 0, 0, 0, 0, 0])
betti_B_3 = np.array([0, 0, 0, 2, 5, 7, 8, 6, 3, 1, 0, 0, 0, 0, 0])
betti_B_5 = np.array([0, 0, 0, 0, 0, 2, 4, 7, 9, 9, 6, 4, 2, 0, 0])
betti_B_7 = np.array([0, 0, 0, 0, 0, 0, 0, 1, 3, 5, 8, 7, 5, 3, 1])

global_B = np.maximum.reduce([betti_B_2, betti_B_3, betti_B_5, betti_B_7])

# Distances
primes_data = {
    2: (betti_A_2, betti_B_2),
    3: (betti_A_3, betti_B_3),
    5: (betti_A_5, betti_B_5),
    7: (betti_A_7, betti_B_7),
}
colors = {2: '#e74c3c', 3: '#2ecc71', 5: '#3498db', 7: '#f39c12'}

# --- Create figure ---
fig = plt.figure(figsize=(16, 12))
gs = fig.add_gridspec(3, 2, hspace=0.35, wspace=0.3)

# Panel 1: Profile A decomposition
ax = fig.add_subplot(gs[0, 0])
bottom = np.zeros(T)
for p in [2, 3, 5, 7]:
    ax.fill_between(times, bottom, bottom + primes_data[p][0],
                     alpha=0.4, color=colors[p], label=f'p={p}')
    bottom += primes_data[p][0]
ax.plot(times, global_A, 'k-', linewidth=2.5, label='Max envelope')
ax.set_title('Profile A: Prime Channel Decomposition', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Betti value')
ax.legend(fontsize=8, ncol=3)
ax.grid(True, alpha=0.2)

# Panel 2: Profile B decomposition
ax = fig.add_subplot(gs[0, 1])
bottom = np.zeros(T)
for p in [2, 3, 5, 7]:
    ax.fill_between(times, bottom, bottom + primes_data[p][1],
                     alpha=0.4, color=colors[p], label=f'p={p}')
    bottom += primes_data[p][1]
ax.plot(times, global_B, 'k-', linewidth=2.5, label='Max envelope')
ax.set_title('Profile B: Perturbed Prime Channels', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Betti value')
ax.legend(fontsize=8, ncol=3)
ax.grid(True, alpha=0.2)

# Panel 3: Global curves comparison
ax = fig.add_subplot(gs[1, 0])
ax.plot(times, global_A, 'b-o', linewidth=2, markersize=5, label='Global A')
ax.plot(times, global_B, 'r-s', linewidth=2, markersize=5, label='Global B')
ax.fill_between(times, global_A, global_B, alpha=0.15, color='purple')
global_dist = np.abs(global_A.astype(int) - global_B.astype(int))
ax.set_title('Global Betti Curves (Max Envelopes)', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Global β(t)')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.2)

# Panel 4: Primewise distances vs global distance
ax = fig.add_subplot(gs[1, 1])
for p in [2, 3, 5, 7]:
    pw_dist = np.abs(primes_data[p][0].astype(int) -
                      primes_data[p][1].astype(int))
    ax.plot(times, pw_dist, '--', color=colors[p], linewidth=1.5,
            label=f'd(A,B) at p={p}', alpha=0.7)

pw_max = np.array([max(np.abs(int(primes_data[p][0][t]) -
                                int(primes_data[p][1][t]))
                        for p in [2, 3, 5, 7]) for t in range(T)])
ax.plot(times, pw_max, 'k-D', linewidth=2.5, markersize=4,
        label='max_p d_p (bound)')
ax.plot(times, global_dist, 'r-o', linewidth=2.5, markersize=5,
        label='Global distance')
ax.set_title('Max-Envelope Theorem in Action', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=8, loc='upper right')
ax.grid(True, alpha=0.2)

# Panel 5: The gap (strictness phenomenon)
ax = fig.add_subplot(gs[2, :])
gap = pw_max - global_dist

# Color bars by which prime is the bottleneck
bottleneck_colors = []
for t in range(T):
    dists = {p: abs(int(primes_data[p][0][t]) - int(primes_data[p][1][t]))
             for p in [2, 3, 5, 7]}
    bp = max(dists, key=dists.get)
    bottleneck_colors.append(colors[bp])

ax.bar(times, gap, color=bottleneck_colors, alpha=0.7, edgecolor='black',
       linewidth=0.5)
ax.plot(times, gap, 'k-', linewidth=1, alpha=0.5)

# Add legend for bottleneck primes
from matplotlib.patches import Patch
legend_elements = [Patch(facecolor=colors[p], edgecolor='black',
                          label=f'Bottleneck: p={p}')
                    for p in [2, 3, 5, 7]]
ax.legend(handles=legend_elements, fontsize=9, ncol=4, loc='upper right')

ax.set_title('Strictness Gap by Bottleneck Prime Channel', fontsize=11,
             fontweight='bold')
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Gap = upper bound − global dist')
ax.grid(True, alpha=0.2)

# Add summary text
strict_count = np.sum(gap > 0)
total = len(gap)
ax.text(0.02, 0.95, f'Strict gap at {strict_count}/{total} time points '
        f'({100*strict_count/total:.0f}%)',
        transform=ax.transAxes, fontsize=10, verticalalignment='top',
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Prime-Resolved Persistence: Decomposition, Stability, and Strictness',
             fontsize=14, fontweight='bold', y=1.01)
plt.savefig('prime_channels.png', dpi=150, bbox_inches='tight')
print("Saved: prime_channels.png")
plt.close()


#!/usr/bin/env python3
"""
Visualization: Interval-Decomposability Conjecture Test

This script tests and visualizes the conjecture that under
interval-decomposability (each prime's Betti curve is an indicator
of an interval), the max-envelope bound might be tight.

The visualization shows:
- A heatmap of the gap between global distance and primewise max distance
  across many random interval-decomposable profiles
- Distribution of gaps, showing how often strictness occurs
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random

# --- Inline helper functions ---
def nat_dist(a, b):
    return abs(a - b)

def make_interval_betti(primes, intervals, max_t=12):
    """Create Betti data with indicator-of-interval curves."""
    betti = {}
    for p in primes:
        a, b = intervals.get(p, (0, -1))
        betti[p] = {t: (1 if a <= t <= b else 0) for t in range(max_t)}
    return betti

def global_betti(betti, primes, t):
    return max(betti.get(p, {}).get(t, 0) for p in primes) if primes else 0

def primewise_max_dist_at(betti_M, betti_N, primes, t):
    return max(nat_dist(betti_M.get(p, {}).get(t, 0),
                         betti_N.get(p, {}).get(t, 0)) for p in primes)

# --- Run the experiment ---
primes = [2, 3, 5]
max_t = 12
n_trials = 500
rng = random.Random(789)

all_gaps = []
gap_by_n_primes = {1: [], 2: [], 3: []}

for trial in range(n_trials):
    intervals_M = {p: tuple(sorted([rng.randint(0, max_t-1),
                                      rng.randint(0, max_t-1)]))
                    for p in primes}
    intervals_N = {p: tuple(sorted([rng.randint(0, max_t-1),
                                      rng.randint(0, max_t-1)]))
                    for p in primes}

    betti_M = make_interval_betti(primes, intervals_M, max_t)
    betti_N = make_interval_betti(primes, intervals_N, max_t)

    for t in range(max_t):
        gM = global_betti(betti_M, primes, t)
        gN = global_betti(betti_N, primes, t)
        gd = nat_dist(gM, gN)
        pw = primewise_max_dist_at(betti_M, betti_N, primes, t)
        gap = pw - gd
        all_gaps.append(gap)

# Also test with different numbers of primes
for n_p in [1, 2, 3]:
    test_primes = primes[:n_p]
    for trial in range(200):
        intervals_M = {p: tuple(sorted([rng.randint(0, max_t-1),
                                          rng.randint(0, max_t-1)]))
                        for p in test_primes}
        intervals_N = {p: tuple(sorted([rng.randint(0, max_t-1),
                                          rng.randint(0, max_t-1)]))
                        for p in test_primes}

        betti_M = make_interval_betti(test_primes, intervals_M, max_t)
        betti_N = make_interval_betti(test_primes, intervals_N, max_t)

        max_gap = 0
        for t in range(max_t):
            gM = global_betti(betti_M, test_primes, t)
            gN = global_betti(betti_N, test_primes, t)
            gd = nat_dist(gM, gN)
            pw = primewise_max_dist_at(betti_M, betti_N, test_primes, t)
            max_gap = max(max_gap, pw - gd)
        gap_by_n_primes[n_p].append(max_gap)

# --- Create visualization ---
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Interval-Decomposability Conjecture: Computational Evidence',
             fontsize=13, fontweight='bold')

# Panel 1: Distribution of gaps
ax = axes[0]
gap_array = np.array(all_gaps)
counts_0 = np.sum(gap_array == 0)
counts_pos = np.sum(gap_array > 0)
total = len(gap_array)

ax.bar(['Gap = 0\n(Tight)', 'Gap > 0\n(Strict)'],
       [counts_0, counts_pos],
       color=['#2ecc71', '#e74c3c'], alpha=0.8, edgecolor='black')
ax.set_ylabel('Count')
ax.set_title(f'Gap Distribution\n(n={total} points)', fontsize=11)
for i, v in enumerate([counts_0, counts_pos]):
    ax.text(i, v + total*0.01, f'{v}\n({100*v/total:.1f}%)',
            ha='center', fontsize=10, fontweight='bold')

# Panel 2: Gap histogram (detailed)
ax = axes[1]
unique_gaps = sorted(set(all_gaps))
gap_counts = [all_gaps.count(g) for g in unique_gaps]
bars = ax.bar(unique_gaps, gap_counts, color='#3498db', alpha=0.8,
              edgecolor='black')
ax.set_xlabel('Gap value (upper bound − global dist)')
ax.set_ylabel('Frequency')
ax.set_title('Gap Value Distribution', fontsize=11)
ax.set_xticks(unique_gaps)

# Panel 3: Gap frequency by number of primes
ax = axes[2]
x_pos = [1, 2, 3]
strict_fracs = []
for n_p in [1, 2, 3]:
    gaps = gap_by_n_primes[n_p]
    frac = sum(1 for g in gaps if g > 0) / len(gaps) if gaps else 0
    strict_fracs.append(frac)

bars = ax.bar(x_pos, strict_fracs, color=['#f39c12', '#e74c3c', '#9b59b6'],
              alpha=0.8, edgecolor='black')
ax.set_xlabel('Number of active primes')
ax.set_ylabel('Fraction with strict gap')
ax.set_title('Strictness vs Prime Count', fontsize=11)
ax.set_xticks(x_pos)
ax.set_xticklabels(['1 prime\n{2}', '2 primes\n{2,3}', '3 primes\n{2,3,5}'])
for i, v in enumerate(strict_fracs):
    ax.text(x_pos[i], v + 0.02, f'{100*v:.1f}%',
            ha='center', fontsize=10, fontweight='bold')
ax.set_ylim(0, 1.0)

plt.tight_layout()
plt.savefig('conjecture_test.png', dpi=150, bbox_inches='tight')
print("Saved: conjecture_test.png")
plt.close()


#!/usr/bin/env python3
"""
Visualization: Max-Envelope Stability for Primewise Betti Curves

This script visualizes the core mathematical phenomenon:
- Primewise Betti curves for different primes
- The global Betti curve (pointwise max)
- The strictness gap between global distance and primewise max distance

The visualization illustrates the main theorem (betti_envelope_pointwise):
  |globalBetti_M(t) - globalBetti_N(t)| ≤ max_p |beta_{M,p}(t) - beta_{N,p}(t)|
and the strictness result (exists_strict_betti_gap) showing the inequality
can be strict.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Inline helper functions ---
def nat_dist(a, b):
    return abs(a - b)

# --- Define two profiles that exhibit the strictness phenomenon ---
# Profile M: prime 2 dominates early, prime 3 dominates late
times = np.arange(0, 10)

betti_M = {
    2: np.array([5, 4, 3, 2, 1, 0, 0, 0, 0, 0]),
    3: np.array([2, 3, 4, 5, 4, 3, 2, 1, 0, 0]),
    5: np.array([0, 0, 1, 2, 3, 4, 3, 2, 1, 0]),
}

# Profile N: "crossed" — prime 3 dominates early, prime 2 dominates late
betti_N = {
    2: np.array([2, 3, 4, 5, 4, 3, 2, 1, 0, 0]),
    3: np.array([5, 4, 3, 2, 1, 0, 0, 0, 0, 0]),
    5: np.array([0, 1, 2, 3, 4, 3, 2, 1, 0, 0]),
}

primes = [2, 3, 5]
colors = {2: '#e74c3c', 3: '#2ecc71', 5: '#3498db'}
prime_names = {2: 'p=2', 3: 'p=3', 5: 'p=5'}

# Compute global Betti curves
global_M = np.array([max(betti_M[p][t] for p in primes) for t in range(len(times))])
global_N = np.array([max(betti_N[p][t] for p in primes) for t in range(len(times))])

# Compute distances
global_dist = np.array([nat_dist(global_M[t], global_N[t]) for t in range(len(times))])
primewise_max_dist = np.array([
    max(nat_dist(betti_M[p][t], betti_N[p][t]) for p in primes)
    for t in range(len(times))
])
gap = primewise_max_dist - global_dist

# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Max-Envelope Stability for Primewise Persistence Invariants',
             fontsize=14, fontweight='bold')

# Panel 1: Profile M - primewise Betti curves
ax = axes[0, 0]
for p in primes:
    ax.plot(times, betti_M[p], 'o-', color=colors[p], label=prime_names[p],
            linewidth=2, markersize=5)
ax.plot(times, global_M, 'k--', linewidth=2.5, label='Global (max)',
        alpha=0.8)
ax.fill_between(times, 0, global_M, alpha=0.08, color='black')
ax.set_title('Profile M: Primewise Betti Curves', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('β(t)')
ax.legend(fontsize=9)
ax.set_ylim(-0.3, 6)
ax.grid(True, alpha=0.3)

# Panel 2: Profile N - primewise Betti curves
ax = axes[0, 1]
for p in primes:
    ax.plot(times, betti_N[p], 's-', color=colors[p], label=prime_names[p],
            linewidth=2, markersize=5)
ax.plot(times, global_N, 'k--', linewidth=2.5, label='Global (max)',
        alpha=0.8)
ax.fill_between(times, 0, global_N, alpha=0.08, color='black')
ax.set_title('Profile N: Primewise Betti Curves (Crossed)', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('β(t)')
ax.legend(fontsize=9)
ax.set_ylim(-0.3, 6)
ax.grid(True, alpha=0.3)

# Panel 3: Distances
ax = axes[1, 0]
for p in primes:
    pw_dist = np.array([nat_dist(betti_M[p][t], betti_N[p][t])
                         for t in range(len(times))])
    ax.plot(times, pw_dist, 'o--', color=colors[p], label=f'd_{prime_names[p]}',
            linewidth=1.5, markersize=4, alpha=0.7)
ax.plot(times, primewise_max_dist, 'k-', linewidth=2.5,
        label='max_p d_p (upper bound)', marker='D', markersize=4)
ax.plot(times, global_dist, 'r-', linewidth=2.5,
        label='Global distance', marker='o', markersize=5)
ax.set_title('Max-Envelope Theorem: Global ≤ max Primewise', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=8, loc='upper right')
ax.grid(True, alpha=0.3)

# Panel 4: Strictness gap
ax = axes[1, 1]
ax.bar(times, gap, color='#9b59b6', alpha=0.7, label='Gap (UB − global)')
ax.bar(times, global_dist, bottom=0, color='#e74c3c', alpha=0.5,
       label='Global distance')
ax.plot(times, primewise_max_dist, 'k-', linewidth=2, marker='D',
        markersize=4, label='Upper bound')
ax.set_title('Strictness Gap: The Inequality Is Not Tight', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Add annotation for the main theorem
ax.annotate('Gap > 0: proves\nexists_strict_betti_gap',
            xy=(0, gap[0]), xytext=(2, gap.max() + 0.5),
            arrowprops=dict(arrowstyle='->', color='purple'),
            fontsize=9, color='purple', fontweight='bold')

plt.tight_layout()
plt.savefig('max_envelope_stability.png', dpi=150, bbox_inches='tight')
print("Saved: max_envelope_stability.png")
plt.close()
