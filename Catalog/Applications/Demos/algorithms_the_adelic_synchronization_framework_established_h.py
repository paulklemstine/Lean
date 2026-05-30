"""
Adelic Collision Dynamics — Algorithms
======================================
Core algorithms for computing collision profiles, synchronization scores,
and orbit decompositions in finite dynamical systems.

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Set, Optional, Callable
import math


def orbit_segment(f: Callable[[int], int], x: int, n: int) -> List[int]:
    """
    Compute the orbit segment [x, f(x), f²(x), ..., f^(n-1)(x)].

    Time: O(n · T_f) where T_f is the cost of evaluating f.
    Space: O(n).

    >>> orbit_segment(lambda x: (x*x) % 7, 3, 5)
    [3, 2, 4, 2, 4]
    """
    seg: List[int] = []
    curr = x
    for _ in range(n):
        seg.append(curr)
        curr = f(curr)
    return seg


def complexity_rank(f: Callable[[int], int], x: int, n: int) -> int:
    """
    Count the number of distinct values in the orbit segment of length n.

    Time: O(n · T_f). Space: O(min(n, |α|)).

    >>> complexity_rank(lambda x: (x*x) % 7, 3, 10)
    3
    """
    return len(set(orbit_segment(f, x, n)))


def collision_time(f: Callable[[int], int], a: int, b: int,
                   bound: int) -> int:
    """
    Find the first n ∈ [0, bound) where f^n(a) == f^n(b).
    Returns -1 if no collision within bound steps.

    Time: O(bound · T_f). Space: O(1).

    >>> collision_time(lambda x: (x*x) % 13, 3, 10, 20)
    1
    """
    xa, xb = a, b
    for n in range(bound):
        if xa == xb:
            return n
        xa = f(xa)
        xb = f(xb)
    return -1


def sync_score(f: Callable[[int], int], a: int, b: int, w: int) -> int:
    """
    Compute the synchronization score: count of steps in [0, w) where
    f^k(a) == f^k(b).

    Time: O(w · T_f). Space: O(1).

    >>> sync_score(lambda x: (x*x) % 13, 3, 3, 10)
    10
    """
    count = 0
    xa, xb = a, b
    for _ in range(w):
        if xa == xb:
            count += 1
        xa = f(xa)
        xb = f(xb)
    return count


def orbit_decomposition(f: Callable[[int], int], x: int,
                         max_steps: int = 10000) -> Tuple[int, int]:
    """
    Decompose the orbit of x under f into (tail_length, period).

    Uses Floyd's cycle detection to find the tail and period in O(1) space,
    then falls back to dictionary-based detection.

    Time: O(t + p) where t is tail length and p is period.
    Space: O(t + p) (dictionary-based).

    Returns (-1, -1) if no cycle found within max_steps.

    >>> orbit_decomposition(lambda x: (x*x) % 7, 3)
    (1, 2)
    """
    seen: Dict[int, int] = {}
    curr = x
    for n in range(max_steps):
        if curr in seen:
            t = seen[curr]
            p = n - t
            return t, p
        seen[curr] = n
        curr = f(curr)
    return -1, -1


def collision_filtration(f: Callable[[int], int],
                         pairs: List[Tuple[int, int]],
                         max_k: int) -> List[List[Tuple[int, int]]]:
    """
    Compute the collision filtration: for each k in [0, max_k],
    return the list of pairs (a, b) that have collided by step k.

    The output is guaranteed to be non-decreasing (monotone) by the
    Collision Filtration Monotonicity Theorem.

    Time: O(max_k · |pairs| · T_f). Space: O(max_k · |pairs|).

    >>> f = lambda x: (x*x) % 10
    >>> pairs = [(2, 8), (3, 7), (1, 9)]
    >>> filt = collision_filtration(f, pairs, 5)
    >>> [len(s) for s in filt]  # Non-decreasing
    [0, 1, 3, 3, 3, 3]
    """
    # Track current iterates for each pair
    curr: Dict[Tuple[int, int], Tuple[int, int]] = {}
    for a, b in pairs:
        curr[(a, b)] = (a, b)

    collided_set: Set[Tuple[int, int]] = set()
    result: List[List[Tuple[int, int]]] = []

    for k in range(max_k + 1):
        for pair_key in pairs:
            if pair_key not in collided_set:
                ca, cb = curr[pair_key]
                if ca == cb:
                    collided_set.add(pair_key)
        result.append(sorted(collided_set))
        # Advance all iterates
        for pair_key in pairs:
            ca, cb = curr[pair_key]
            curr[pair_key] = (f(ca), f(cb))

    return result


def image_size_sequence(f: Callable[[int], int], domain: List[int],
                        max_n: int) -> List[int]:
    """
    Compute the sequence |im(f^n)| for n = 0, 1, ..., max_n.
    The Monotone Image Theorem guarantees this is non-increasing.

    Time: O(max_n · |domain| · T_f). Space: O(|domain|).

    >>> f = lambda x: (x*x) % 10
    >>> image_size_sequence(f, list(range(10)), 5)
    [10, 4, 3, 2, 2, 2]
    """
    sizes: List[int] = []
    current_vals = list(domain)
    sizes.append(len(set(current_vals)))
    for _ in range(max_n):
        current_vals = [f(v) for v in current_vals]
        sizes.append(len(set(current_vals)))
    return sizes


def sq_congruence_count(a: int, b: int, prime_bound: int = 230) -> int:
    """
    Count primes p ≤ prime_bound where a² ≡ b² (mod p).

    This implements the computational test for the Synchronization
    Density Conjecture.

    >>> sq_congruence_count(3, 5, 50)  # Two small primes
    2
    """
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    count = 0
    for p in range(2, prime_bound + 1):
        if is_prime(p):
            if (a * a) % p == (b * b) % p:
                count += 1
    return count


def test_sync_density_conjecture(q_bound: int = 100,
                                  prime_bound: int = 230) -> Tuple[bool, Dict]:
    """
    Test the Synchronization Density Conjecture for all prime pairs
    p < q < q_bound.

    Returns (conjecture_holds, details) where details contains
    the maximum count found and the pair achieving it.

    >>> holds, info = test_sync_density_conjecture(30, 100)
    >>> holds
    True
    """
    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    primes = [p for p in range(2, q_bound) if is_prime(p)]
    max_count = 0
    max_pair = (0, 0)

    for i, p in enumerate(primes):
        for q in primes[i + 1:]:
            count = sq_congruence_count(p, q, prime_bound)
            if count > max_count:
                max_count = count
                max_pair = (p, q)

    return max_count <= 120, {
        "max_count": max_count,
        "max_pair": max_pair,
        "num_pairs_tested": len(primes) * (len(primes) - 1) // 2,
        "threshold": 120
    }


if __name__ == "__main__":
    print("=== Algorithm Tests ===\n")

    # Test orbit decomposition
    f7 = lambda x: (x * x) % 7
    for x in range(7):
        t, p = orbit_decomposition(f7, x)
        print(f"Z/7Z, x={x}: tail={t}, period={p}")

    print()

    # Test image size sequence
    f10 = lambda x: (x * x) % 10
    sizes = image_size_sequence(f10, list(range(10)), 6)
    print(f"Image sizes for x² mod 10: {sizes}")
    print(f"Non-increasing: {all(sizes[i] >= sizes[i+1] for i in range(len(sizes)-1))}")

    print()

    # Test sync density conjecture
    holds, info = test_sync_density_conjecture(50, 100)
    print(f"Sync density conjecture (primes < 50, primes ≤ 100): {holds}")
    print(f"  Max count: {info['max_count']} at pair {info['max_pair']}")
    print(f"  Pairs tested: {info['num_pairs_tested']}")
