#!/usr/bin/env python3
"""
algorithms.py — Verified Algorithms for Primewise Persistence Stability

Implements the core algorithms from the research paper:
1. Primewise derived upper bound computation
2. Support pruning optimization
3. Strictness witness search
4. Interval-decomposability testing

All algorithms have corresponding formal correctness theorems in Lean 4.
"""

from typing import Dict, List, Tuple, Optional
import random


# ===========================================================================
# Algorithm 1: Primewise Derived Upper Bound
# ===========================================================================

def nat_dist(a: int, b: int) -> int:
    """Natural distance |a - b|.

    Corresponds to `natDist` in Lean.
    Time: O(1), Space: O(1)
    """
    return abs(a - b)


def primewise_derived_upper_bound(
    betti_M: Dict[int, Dict[int, int]],
    betti_N: Dict[int, Dict[int, int]],
    primes: List[int],
    t: int
) -> int:
    """Compute the primewise derived upper bound at time t.

    Given two primewise Betti profiles M, N with shared prime support,
    returns max_p |beta_{M,p}(t) - beta_{N,p}(t)|.

    This is the certified upper bound for the global Betti distance,
    proven correct by `global_dist_le_primewiseDerivedUpperBound`.

    Args:
        betti_M: {prime: {time: value}} for profile M
        betti_N: {prime: {time: value}} for profile N
        primes: list of supported primes
        t: time parameter

    Returns:
        The max-envelope upper bound (a natural number)

    Time: O(|primes|), Space: O(1)
    """
    if not primes:
        return 0
    return max(
        nat_dist(
            betti_M.get(p, {}).get(t, 0),
            betti_N.get(p, {}).get(t, 0)
        )
        for p in primes
    )


def global_betti_curve(
    betti: Dict[int, Dict[int, int]],
    primes: List[int],
    t: int
) -> int:
    """Compute the global Betti curve at time t.

    Returns max_p beta_p(t), the sup-envelope of primewise Betti curves.

    Corresponds to `globalBettiCurve` in Lean.

    Time: O(|primes|), Space: O(1)
    """
    if not primes:
        return 0
    return max(betti.get(p, {}).get(t, 0) for p in primes)


def global_betti_dist(
    betti_M: Dict[int, Dict[int, int]],
    betti_N: Dict[int, Dict[int, int]],
    primes: List[int],
    t: int
) -> int:
    """Compute the global Betti distance at time t.

    Time: O(|primes|), Space: O(1)
    """
    return nat_dist(
        global_betti_curve(betti_M, primes, t),
        global_betti_curve(betti_N, primes, t)
    )


# ===========================================================================
# Algorithm 2: Support Pruning
# ===========================================================================

def support_pruned_upper_bound(
    betti_M: Dict[int, Dict[int, int]],
    betti_N: Dict[int, Dict[int, int]],
    support_M: List[int],
    support_N: List[int],
    t: int
) -> int:
    """Compute the upper bound using only the union of supports.

    Proven correct by `primewiseDerivedUpperBound_eq_union`:
    only primes in support(M) ∪ support(N) need to be checked.

    Optimization: primes outside both supports contribute zero,
    proven by `finite_prime_derived_envelope_suffices`.

    Args:
        betti_M, betti_N: Betti data
        support_M, support_N: prime supports
        t: time parameter

    Returns:
        The pruned upper bound

    Time: O(|support_M ∪ support_N|), Space: O(|support_M ∪ support_N|)
    """
    active_primes = sorted(set(support_M) | set(support_N))
    if not active_primes:
        return 0
    return max(
        nat_dist(
            betti_M.get(p, {}).get(t, 0),
            betti_N.get(p, {}).get(t, 0)
        )
        for p in active_primes
    )


# ===========================================================================
# Algorithm 3: Strictness Witness Search
# ===========================================================================

def find_strictness_witness(
    betti_M: Dict[int, Dict[int, int]],
    betti_N: Dict[int, Dict[int, int]],
    primes: List[int],
    max_t: int = 20
) -> Optional[Tuple[int, int, int]]:
    """Search for a time t where the max-envelope bound is strict.

    Returns (t, global_dist, upper_bound) if a strict gap is found,
    or None if the bound is tight everywhere.

    This implements the search behind `exists_strict_betti_gap`.

    Time: O(|primes| * max_t), Space: O(1)
    """
    for t in range(max_t + 1):
        gd = global_betti_dist(betti_M, betti_N, primes, t)
        ub = primewise_derived_upper_bound(betti_M, betti_N, primes, t)
        if gd < ub:
            return (t, gd, ub)
    return None


def random_strictness_search(
    primes: List[int] = [2, 3, 5],
    max_val: int = 10,
    max_t: int = 10,
    n_trials: int = 1000,
    seed: int = 42
) -> Dict:
    """Search for strictness witnesses among random profiles.

    Returns statistics about the frequency of strict gaps.

    Time: O(n_trials * |primes| * max_t), Space: O(|primes| * max_t)
    """
    rng = random.Random(seed)
    strict = 0
    tight = 0
    total_points = 0
    examples = []

    for trial in range(n_trials):
        betti_M = {p: {t: rng.randint(0, max_val) for t in range(max_t)}
                    for p in primes}
        betti_N = {p: {t: rng.randint(0, max_val) for t in range(max_t)}
                    for p in primes}

        witness = find_strictness_witness(betti_M, betti_N, primes, max_t)
        if witness is not None and len(examples) < 5:
            examples.append({
                "trial": trial,
                "witness_t": witness[0],
                "global_dist": witness[1],
                "upper_bound": witness[2],
                "gap": witness[2] - witness[1]
            })

        for t in range(max_t):
            gd = global_betti_dist(betti_M, betti_N, primes, t)
            ub = primewise_derived_upper_bound(betti_M, betti_N, primes, t)
            total_points += 1
            if gd < ub:
                strict += 1
            else:
                tight += 1

    return {
        "n_trials": n_trials,
        "total_points": total_points,
        "strict_count": strict,
        "tight_count": tight,
        "strict_fraction": strict / total_points if total_points > 0 else 0,
        "examples": examples
    }


# ===========================================================================
# Algorithm 4: Interval Decomposability Conjecture Testing
# ===========================================================================

def make_interval_betti(
    primes: List[int],
    intervals: Dict[int, Tuple[int, int]]
) -> Dict[int, Dict[int, int]]:
    """Create Betti data where each prime has an indicator-of-interval curve.

    Args:
        primes: list of primes
        intervals: {prime: (start, end)} for each prime's interval

    Returns:
        Betti data dictionary
    """
    betti = {}
    max_t = max(b for _, b in intervals.values()) + 2 if intervals else 10
    for p in primes:
        a, b = intervals.get(p, (0, -1))
        betti[p] = {t: (1 if a <= t <= b else 0) for t in range(max_t)}
    return betti


def test_interval_conjecture(
    primes: List[int] = [2, 3, 5],
    max_t: int = 10,
    n_trials: int = 1000,
    seed: int = 456
) -> Dict:
    """Test the primewise bottleneck exactness conjecture.

    For interval-decomposable profiles (each prime's Betti curve is an
    indicator of an interval), test whether the max-envelope bound is tight.

    Returns statistics and any counterexamples found.
    """
    rng = random.Random(seed)
    counterexamples = []
    total_points = 0
    strict_points = 0

    for trial in range(n_trials):
        intervals_M = {p: tuple(sorted([rng.randint(0, max_t),
                                          rng.randint(0, max_t)]))
                        for p in primes}
        intervals_N = {p: tuple(sorted([rng.randint(0, max_t),
                                          rng.randint(0, max_t)]))
                        for p in primes}

        betti_M = make_interval_betti(primes, intervals_M)
        betti_N = make_interval_betti(primes, intervals_N)

        for t in range(max_t + 1):
            gd = global_betti_dist(betti_M, betti_N, primes, t)
            ub = primewise_derived_upper_bound(betti_M, betti_N, primes, t)
            total_points += 1
            if gd < ub:
                strict_points += 1
                if len(counterexamples) < 3:
                    counterexamples.append({
                        "trial": trial, "t": t,
                        "intervals_M": intervals_M,
                        "intervals_N": intervals_N,
                        "global_dist": gd,
                        "upper_bound": ub
                    })

    return {
        "conjecture_holds": len(counterexamples) == 0,
        "n_trials": n_trials,
        "total_points": total_points,
        "strict_points": strict_points,
        "counterexamples": counterexamples
    }


# ===========================================================================
# Example usage
# ===========================================================================

if __name__ == "__main__":
    print("=== Algorithm 1: Primewise Derived Upper Bound ===")
    betti_M = {2: {0: 5, 1: 3}, 3: {0: 3, 1: 5}}
    betti_N = {2: {0: 3, 1: 5}, 3: {0: 5, 1: 3}}
    primes = [2, 3]

    for t in range(4):
        gd = global_betti_dist(betti_M, betti_N, primes, t)
        ub = primewise_derived_upper_bound(betti_M, betti_N, primes, t)
        print(f"  t={t}: global_dist={gd}, upper_bound={ub}, "
              f"gap={ub-gd}")

    print("\n=== Algorithm 3: Random Strictness Search ===")
    results = random_strictness_search(n_trials=500)
    print(f"  Strict fraction: {results['strict_fraction']:.3f}")
    print(f"  First examples: {results['examples'][:3]}")

    print("\n=== Algorithm 4: Interval Conjecture Test ===")
    conj = test_interval_conjecture(n_trials=500)
    print(f"  Conjecture holds: {conj['conjecture_holds']}")
    print(f"  Strict points: {conj['strict_points']}/{conj['total_points']}")
    if conj['counterexamples']:
        print(f"  First counterexample: {conj['counterexamples'][0]}")
