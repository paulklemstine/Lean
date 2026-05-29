"""
algorithms.py — Core algorithms for adelic synchronization in arithmetic dynamics.

Implements:
1. Orbit computation for quadratic maps mod p
2. Collision depth and profile computation
3. Prime synchronization score
4. Orbit prefix complexity
"""

from typing import List, Dict, Tuple, Optional, Set
from collections import Counter
import math


def quad_map_mod(x: int, c: int, p: int) -> int:
    """Compute x^2 + c mod p."""
    return (x * x + c) % p


def orbit_mod_p(c: int, p: int, seed: int = 0, max_steps: int = 0) -> List[int]:
    """
    Compute the orbit of `seed` under x -> x^2 + c mod p.

    Args:
        c: Parameter of the quadratic map.
        p: Prime modulus.
        seed: Starting point (default 0, the critical point).
        max_steps: Maximum number of steps (default p+1 for full cycle detection).

    Returns:
        List of orbit values [seed, f(seed), f^2(seed), ...] until first repeat
        or max_steps is reached.
    """
    if max_steps == 0:
        max_steps = p + 1
    orbit = [seed % p]
    seen = {seed % p: 0}
    x = seed % p
    for i in range(1, max_steps + 1):
        x = quad_map_mod(x, c, p)
        orbit.append(x)
        if x in seen:
            break
        seen[x] = i
    return orbit


def find_preperiod_and_period(c: int, p: int, seed: int = 0) -> Tuple[int, int]:
    """
    Find the preperiod m and period length (n-m) of the orbit of seed under x^2+c mod p.

    Returns:
        (preperiod, period): preperiod m is the smallest index where the orbit
        first enters a cycle, period is the cycle length.
    """
    orbit = orbit_mod_p(c, p, seed)
    # Find first repeated value
    seen: Dict[int, int] = {}
    for i, val in enumerate(orbit):
        if val in seen:
            return seen[val], i - seen[val]
        seen[val] = i
    return len(orbit) - 1, 1  # fallback


def collision_depth(c: int, p: int, seed_a: int = 0, seed_b: int = 0,
                    max_depth: int = 0) -> int:
    """
    Compute the collision depth: smallest N such that there exist i,j <= N
    with f^[i](a) = f^[j](b).

    For seed_a = seed_b = 0 this is always 0. More interesting for distinct seeds.
    """
    if max_depth == 0:
        max_depth = p + 1
    orbit_a = [seed_a % p]
    orbit_b = [seed_b % p]
    xa, xb = seed_a % p, seed_b % p

    # Check initial collision
    if xa == xb:
        return 0

    for n in range(1, max_depth + 1):
        xa = quad_map_mod(xa, c, p)
        xb = quad_map_mod(xb, c, p)
        orbit_a.append(xa)
        orbit_b.append(xb)
        # Check all pairs (i,j) with max(i,j) = n
        set_a = set(orbit_a)
        set_b = set(orbit_b)
        if set_a & set_b:
            return n
    return max_depth


def collision_profile(c: int, p: int, seed_a: int, seed_b: int,
                      N: int) -> Set[Tuple[int, int]]:
    """
    Compute the collision profile: all pairs (i,j) with i,j <= N
    such that f^[i](a) = f^[j](b) mod p.
    """
    # Compute orbits up to depth N
    orbit_a = [seed_a % p]
    orbit_b = [seed_b % p]
    xa, xb = seed_a % p, seed_b % p
    for _ in range(N):
        xa = quad_map_mod(xa, c, p)
        xb = quad_map_mod(xb, c, p)
        orbit_a.append(xa)
        orbit_b.append(xb)

    profile = set()
    for i in range(N + 1):
        for j in range(N + 1):
            if orbit_a[i] == orbit_b[j]:
                profile.add((i, j))
    return profile


def orbit_prefix_complexity(c: int, p: int, seed: int = 0, N: int = 0) -> int:
    """
    Count the number of distinct values in {f^[0](a), ..., f^[N](a)} mod p.

    This is the orbit prefix set cardinality — our entropy/complexity surrogate.
    """
    if N == 0:
        N = p
    values = set()
    x = seed % p
    values.add(x)
    for _ in range(N):
        x = quad_map_mod(x, c, p)
        values.add(x)
    return len(values)


def preperiod_invariant(c: int, p: int, seed: int = 0) -> Tuple[int, int]:
    """
    Compute the (preperiod, period) pair as a prime-local invariant.
    This is τ_p(c) in the adelic synchronization framework.
    """
    return find_preperiod_and_period(c, p, seed)


def prime_sync_score(invariants: List) -> int:
    """
    Compute the synchronization score: number of pairs (i,j) with
    invariants[i] == invariants[j].

    This is the adelic order parameter.

    Args:
        invariants: List of invariant values, one per prime.

    Returns:
        Number of agreeing pairs (including self-pairs).
    """
    counts = Counter(invariants)
    return sum(c * c for c in counts.values())


def sync_analysis(c: int, primes: List[int], seed: int = 0) -> Dict:
    """
    Full synchronization analysis for parameter c across a set of primes.

    Returns dict with:
        - invariants: list of (preperiod, period) per prime
        - sync_score: pairwise agreement count
        - dominant_fiber: most common invariant and its count
        - complexity: average orbit prefix complexity
    """
    invariants = []
    complexities = []
    for p in primes:
        inv = preperiod_invariant(c, p, seed)
        invariants.append(inv)
        complexities.append(orbit_prefix_complexity(c, p, seed, min(p, 100)))

    score = prime_sync_score(invariants)
    counts = Counter(invariants)
    dominant = counts.most_common(1)[0] if counts else (None, 0)

    return {
        'parameter': c,
        'primes': primes,
        'invariants': invariants,
        'sync_score': score,
        'max_score': len(primes) ** 2,
        'sync_ratio': score / len(primes) ** 2 if primes else 0,
        'dominant_invariant': dominant[0],
        'dominant_count': dominant[1],
        'dominant_fraction': dominant[1] / len(primes) if primes else 0,
        'avg_complexity': sum(complexities) / len(complexities) if complexities else 0,
    }


def is_preperiodic_over_Q(c: int, max_iter: int = 100) -> Optional[Tuple[int, int]]:
    """
    Check if 0 is preperiodic for x^2 + c over Q (exact integer arithmetic).
    Returns (m, n) if f^m(0) = f^n(0) found, else None.

    Known preperiodic parameters: c = 0 (fixed), c = -1 (period 2),
    c = -2 (preperiod 1, period 1).
    """
    orbit = [0]
    seen = {0: 0}
    x = 0
    for i in range(1, max_iter + 1):
        x = x * x + c
        if x in seen:
            return (seen[x], i)
        if abs(x) > 10**15:  # orbit escaping — not preperiodic
            return None
        seen[x] = i
        orbit.append(x)
    return None


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return list of primes up to n."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


if __name__ == "__main__":
    primes = sieve_of_eratosthenes(200)
    # Remove p=2 for simplicity
    primes = [p for p in primes if p > 2]

    print("=" * 70)
    print("ADELIC SYNCHRONIZATION ANALYSIS")
    print("Family: f_c(x) = x^2 + c, critical orbit from seed 0")
    print(f"Primes: first {len(primes)} odd primes up to {primes[-1]}")
    print("=" * 70)

    # Test known preperiodic parameters
    test_params = [0, -1, -2, 1, 2, 3, -3, -4, 5, 7, 10, -5, -6, 100]

    print(f"\n{'c':>6} | {'Preperiodic?':>14} | {'Sync Score':>10} | {'Max':>6} | "
          f"{'Ratio':>6} | {'Dom Frac':>8} | {'Avg Cplx':>8}")
    print("-" * 80)

    for c in test_params:
        pp = is_preperiodic_over_Q(c)
        result = sync_analysis(c, primes)
        pp_str = f"({pp[0]},{pp[1]})" if pp else "No"
        print(f"{c:>6} | {pp_str:>14} | {result['sync_score']:>10} | "
              f"{result['max_score']:>6} | {result['sync_ratio']:>6.3f} | "
              f"{result['dominant_fraction']:>8.3f} | {result['avg_complexity']:>8.1f}")
