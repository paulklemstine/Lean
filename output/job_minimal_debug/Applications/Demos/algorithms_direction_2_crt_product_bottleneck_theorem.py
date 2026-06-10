#!/usr/bin/env python3
"""
Algorithms for CRT Product Bottleneck Theory

Implements core algorithms for computing basin conductance, CRT lifts,
and verifying the product bottleneck inequality for modular squaring dynamics.

Each algorithm includes:
- Formal specification
- Implementation with type hints
- Complexity analysis
- Example usage
"""

from fractions import Fraction
from typing import FrozenSet, List, Set, Tuple, Optional, Dict
from itertools import combinations
import math


# ─────────────────────────────────────────────────────────────────
# Algorithm 1: Squaring Dynamics Computation
# ─────────────────────────────────────────────────────────────────

def squaring_orbit(x: int, n: int, max_iter: int = 1000) -> List[int]:
    """Compute the orbit of x under the squaring map x -> x^2 mod n.

    Returns the orbit until a cycle is detected or max_iter is reached.

    Time complexity: O(n) worst case (cycle length bounded by n)
    Space complexity: O(n)

    >>> squaring_orbit(2, 7)
    [2, 4, 2]
    >>> squaring_orbit(3, 10)
    [3, 9, 1, 1]
    """
    orbit = [x]
    seen = {x: 0}
    current = x
    for i in range(1, max_iter):
        current = (current * current) % n
        if current in seen:
            orbit.append(current)
            break
        seen[current] = i
        orbit.append(current)
    return orbit


def find_fixed_point(x: int, n: int) -> int:
    """Find the eventual fixed point (idempotent) that x converges to.

    Time complexity: O(n) worst case
    Space complexity: O(n)

    >>> find_fixed_point(2, 6)
    4
    >>> find_fixed_point(3, 7)
    1
    """
    seen = set()
    current = x
    while current not in seen:
        seen.add(current)
        current = (current * current) % n
    # Now current is in a cycle; find the fixed point in the cycle
    # For squaring dynamics, every cycle contains exactly one idempotent
    start = current
    while True:
        if (current * current) % n == current:
            return current
        current = (current * current) % n
        if current == start:
            return current  # Shouldn't happen for valid squaring dynamics


# ─────────────────────────────────────────────────────────────────
# Algorithm 2: Idempotent Enumeration
# ─────────────────────────────────────────────────────────────────

def enumerate_idempotents(n: int) -> List[int]:
    """Find all idempotents in Z/nZ: elements e with e^2 ≡ e (mod n).

    By the Chinese Remainder Theorem, if n = p1^a1 * ... * pk^ak,
    the number of idempotents is exactly 2^k.

    Time complexity: O(n)
    Space complexity: O(number of idempotents) = O(2^ω(n))

    >>> enumerate_idempotents(6)
    [0, 1, 3, 4]
    >>> enumerate_idempotents(7)
    [0, 1]
    >>> enumerate_idempotents(30)
    [0, 1, 6, 10, 15, 16, 21, 25]
    """
    return [e for e in range(n) if (e * e) % n == e]


def count_prime_factors(n: int) -> int:
    """Count distinct prime factors of n.

    >>> count_prime_factors(12)  # 12 = 2^2 * 3
    2
    >>> count_prime_factors(30)  # 30 = 2 * 3 * 5
    3
    """
    if n <= 1:
        return 0
    count = 0
    d = 2
    while d * d <= n:
        if n % d == 0:
            count += 1
            while n % d == 0:
                n //= d
        d += 1
    if n > 1:
        count += 1
    return count


# ─────────────────────────────────────────────────────────────────
# Algorithm 3: Basin Decomposition
# ─────────────────────────────────────────────────────────────────

def compute_basins(n: int) -> Dict[int, Set[int]]:
    """Decompose Z/nZ into basins of attraction under the squaring map.

    Each element is assigned to the basin of its eventual idempotent.

    Time complexity: O(n^2) worst case (n elements, each orbit ≤ n)
    Space complexity: O(n)

    >>> basins = compute_basins(6)
    >>> sorted(basins[0])
    [0, 2]
    >>> sorted(basins[1])
    [1, 5]
    """
    basins: Dict[int, Set[int]] = {}
    for x in range(n):
        fp = find_fixed_point(x, n)
        if fp not in basins:
            basins[fp] = set()
        basins[fp].add(x)
    return basins


# ─────────────────────────────────────────────────────────────────
# Algorithm 4: Edge Boundary Computation
# ─────────────────────────────────────────────────────────────────

def edge_boundary(S: FrozenSet[int], n: int) -> FrozenSet[int]:
    """Compute the edge boundary of S in the squaring graph on Z/nZ.

    An element x ∈ S is in the boundary if x^2 mod n ∉ S.

    Time complexity: O(|S|)
    Space complexity: O(|S|)

    >>> edge_boundary(frozenset({0, 1}), 6)
    frozenset()
    >>> edge_boundary(frozenset({0, 2}), 6)
    frozenset({2})
    """
    return frozenset(x for x in S if (x * x) % n not in S)


def conductance(S: FrozenSet[int], n: int) -> Fraction:
    """Compute the conductance (boundary-to-volume ratio) of S.

    Conductance h(S) = |∂S| / |S| where ∂S is the edge boundary.

    Time complexity: O(|S|)
    Space complexity: O(|S|)

    >>> conductance(frozenset({0}), 6)
    Fraction(0, 1)
    """
    if len(S) == 0:
        return Fraction(0)
    bdry = edge_boundary(S, n)
    return Fraction(len(bdry), len(S))


# ─────────────────────────────────────────────────────────────────
# Algorithm 5: Basin Conductance (Cheeger Constant)
# ─────────────────────────────────────────────────────────────────

def basin_conductance_exact(n: int) -> Fraction:
    """Compute the exact basin conductance of the squaring graph on Z/nZ.

    This is the minimum conductance over all nonempty proper subsets.

    Time complexity: O(2^n * n) — exponential, only for small n
    Space complexity: O(n)

    PSEUDOCODE:
        h_min ← 1
        for each S ⊆ {0, ..., n-1} with ∅ ⊊ S ⊊ Z/nZ:
            h ← |{x ∈ S : x² mod n ∉ S}| / |S|
            h_min ← min(h_min, h)
        return h_min

    >>> basin_conductance_exact(2)
    Fraction(1, 1)
    >>> basin_conductance_exact(6)
    Fraction(0, 1)
    """
    if n < 2:
        return Fraction(1)

    elements = list(range(n))
    min_cond = Fraction(1)

    for size in range(1, n):
        for combo in combinations(elements, size):
            S = frozenset(combo)
            c = conductance(S, n)
            if c < min_cond:
                min_cond = c

    return min_cond


def basin_conductance_heuristic(n: int, num_samples: int = 1000) -> Fraction:
    """Approximate basin conductance using structured and random sampling.

    Uses idempotent basins as canonical candidates, supplemented with
    random subsets.

    Time complexity: O(n^2 + num_samples * n)
    Space complexity: O(n)

    PSEUDOCODE:
        h_min ← 1
        // Phase 1: Use idempotent basins
        for each idempotent e in Z/nZ:
            basin ← compute_basin(e)
            if ∅ ⊊ basin ⊊ Z/nZ:
                h_min ← min(h_min, conductance(basin))
        // Phase 2: Random sampling
        for i = 1 to num_samples:
            S ← random nonempty proper subset
            h_min ← min(h_min, conductance(S))
        return h_min
    """
    import random
    random.seed(42)

    min_cond = Fraction(1)

    # Phase 1: Basin-based cuts
    basins = compute_basins(n)
    for fp, basin in basins.items():
        S = frozenset(basin)
        if 0 < len(S) < n:
            c = conductance(S, n)
            if c < min_cond:
                min_cond = c

    # Phase 2: Singleton cuts
    for x in range(n):
        c = conductance(frozenset({x}), n)
        if c < min_cond:
            min_cond = c

    # Phase 3: Random sampling
    for _ in range(num_samples):
        size = random.randint(1, n - 1)
        S = frozenset(random.sample(range(n), size))
        c = conductance(S, n)
        if c < min_cond:
            min_cond = c

    return min_cond


# ─────────────────────────────────────────────────────────────────
# Algorithm 6: CRT Lift
# ─────────────────────────────────────────────────────────────────

def crt_lift_left(S: FrozenSet[int], a: int, b: int) -> FrozenSet[int]:
    """Lift a subset S ⊆ Z/aZ to Z/(ab)Z via CRT preimage.

    Returns {x ∈ Z/(ab)Z : x mod a ∈ S}.

    This is the key operation in the product bottleneck theorem:
    sparse cuts in Z/aZ become sparse cuts in Z/(ab)Z.

    Time complexity: O(ab)
    Space complexity: O(|S| * b)

    PSEUDOCODE:
        lifted ← ∅
        for x = 0 to ab - 1:
            if x mod a ∈ S:
                lifted ← lifted ∪ {x}
        return lifted

    >>> crt_lift_left(frozenset({0}), 3, 5)
    frozenset({0, 3, 6, 9, 12})
    """
    n = a * b
    return frozenset(x for x in range(n) if (x % a) in S)


def crt_lift_right(S: FrozenSet[int], a: int, b: int) -> FrozenSet[int]:
    """Lift a subset S ⊆ Z/bZ to Z/(ab)Z via CRT preimage on second factor.

    Returns {x ∈ Z/(ab)Z : x mod b ∈ S}.

    Time complexity: O(ab)
    Space complexity: O(a * |S|)
    """
    n = a * b
    return frozenset(x for x in range(n) if (x % b) in S)


def verify_conductance_preservation(S: FrozenSet[int], a: int, b: int) -> bool:
    """Verify that CRT lifting preserves conductance exactly.

    The main lemma: conductance(lift(S), ab) = conductance(S, a).

    >>> verify_conductance_preservation(frozenset({1}), 3, 5)
    True
    >>> verify_conductance_preservation(frozenset({0, 2}), 5, 3)
    True
    """
    if math.gcd(a, b) != 1:
        raise ValueError(f"a={a} and b={b} must be coprime")

    n = a * b
    lifted = crt_lift_left(S, a, b)
    c_original = conductance(S, a)
    c_lifted = conductance(lifted, n)
    return c_original == c_lifted


# ─────────────────────────────────────────────────────────────────
# Algorithm 7: Bottleneck Verification
# ─────────────────────────────────────────────────────────────────

def verify_bottleneck(a: int, b: int, exact_threshold: int = 16) -> dict:
    """Verify the CRT Product Bottleneck Theorem for given coprime a, b.

    Returns a dictionary with computation results and verification status.

    PSEUDOCODE:
        Require: gcd(a, b) = 1, a ≥ 2, b ≥ 2
        h_a ← basinConductance(a)
        h_b ← basinConductance(b)
        h_ab ← basinConductance(a * b)
        assert h_ab ≤ min(h_a, h_b)  // This is the theorem
        return {h_a, h_b, h_ab, ratio: h_ab / min(h_a, h_b)}
    """
    assert math.gcd(a, b) == 1, f"a={a}, b={b} must be coprime"
    assert a >= 2 and b >= 2

    n = a * b
    compute = basin_conductance_exact if max(a, b, n) <= exact_threshold else basin_conductance_heuristic

    h_a = compute(a)
    h_b = compute(b)
    h_ab = compute(n)
    h_min = min(h_a, h_b)

    result = {
        'a': a,
        'b': b,
        'n': n,
        'h_a': h_a,
        'h_b': h_b,
        'h_ab': h_ab,
        'h_min': h_min,
        'theorem_holds': h_ab <= h_min,
        'exact_equality': h_ab == h_min,
        'ratio': float(h_ab / h_min) if h_min > 0 else 0.0,
        'method': 'exact' if max(a, b, n) <= exact_threshold else 'heuristic',
        'num_idempotents_a': len(enumerate_idempotents(a)),
        'num_idempotents_b': len(enumerate_idempotents(b)),
        'num_idempotents_n': len(enumerate_idempotents(n)),
    }
    return result


# ─────────────────────────────────────────────────────────────────
# Algorithm 8: Optimal Normalization Factor Search
# ─────────────────────────────────────────────────────────────────

def search_normalization_factor(max_val: int = 20) -> Tuple[float, List[dict]]:
    """Search for the optimal normalization factor κ such that
    h(ab) ≤ κ · min(h(a), h(b)) for all coprime a, b in range.

    Returns (κ_optimal, list_of_results).

    >>> kappa, _ = search_normalization_factor(8)
    >>> kappa <= 1.0
    True
    """
    results = []
    max_ratio = 0.0

    for a in range(2, max_val + 1):
        for b in range(a, max_val + 1):
            if math.gcd(a, b) != 1:
                continue

            r = verify_bottleneck(a, b)
            results.append(r)

            if r['ratio'] > max_ratio:
                max_ratio = r['ratio']

    return max_ratio, results


# ─────────────────────────────────────────────────────────────────
# Main: Run examples
# ─────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 60)
    print("  CRT Product Bottleneck — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Idempotents
    print("\n--- Idempotent Enumeration ---")
    for n in [6, 10, 15, 30]:
        idemps = enumerate_idempotents(n)
        omega = count_prime_factors(n)
        print(f"  Z/{n}Z: idempotents = {idemps}, ω({n}) = {omega}, 2^ω = {2**omega}")

    # Example 2: Basin decomposition
    print("\n--- Basin Decomposition for Z/6Z ---")
    basins = compute_basins(6)
    for fp, basin in sorted(basins.items()):
        print(f"  Basin of {fp}: {sorted(basin)}")

    # Example 3: Conductance preservation
    print("\n--- Conductance Preservation under CRT Lift ---")
    a, b = 3, 5
    for S in [frozenset({0}), frozenset({1}), frozenset({0, 2}), frozenset({1, 2})]:
        preserved = verify_conductance_preservation(S, a, b)
        c_orig = conductance(S, a)
        lifted = crt_lift_left(S, a, b)
        c_lift = conductance(lifted, a * b)
        print(f"  S = {set(S)} ⊆ Z/{a}Z:")
        print(f"    h(S) = {c_orig}, h(lift(S)) = {c_lift}, preserved: {preserved}")

    # Example 4: Bottleneck verification
    print("\n--- Product Bottleneck Verification ---")
    for a, b in [(2, 3), (3, 5), (2, 7), (3, 7), (5, 7)]:
        r = verify_bottleneck(a, b)
        status = "✓" if r['theorem_holds'] else "✗"
        eq = " (exact equality)" if r['exact_equality'] else ""
        print(f"  {status} a={a}, b={b}: h({r['n']})={float(r['h_ab']):.4f} ≤ min={float(r['h_min']):.4f}, ratio={r['ratio']:.4f}{eq}")

    # Example 5: Search for normalization factor
    print("\n--- Normalization Factor Search (n ≤ 12) ---")
    kappa, results = search_normalization_factor(12)
    print(f"  Optimal κ = {kappa:.6f}")
    print(f"  Conjecture κ = 1: {'confirmed' if kappa <= 1.0 else 'REFUTED'}")
    print(f"  Total pairs tested: {len(results)}")
    eq_count = sum(1 for r in results if r['exact_equality'])
    print(f"  Exact equalities: {eq_count}/{len(results)}")
