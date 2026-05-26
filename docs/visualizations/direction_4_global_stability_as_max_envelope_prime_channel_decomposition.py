#!/usr/bin/env python3
"""
Algorithms for Max-Envelope Torsion Stability Computation

Implements the prime channel decomposition algorithm for computing
stability bounds on torsion persistence.
"""

from typing import Dict, List, Optional, Set, Tuple
from fractions import Fraction


def prime_factors(n: int) -> Set[int]:
    """
    Compute the set of prime factors of n.

    Time complexity: O(sqrt(n))
    Space complexity: O(log n) for the factor set

    >>> sorted(prime_factors(60))
    [2, 3, 5]
    >>> prime_factors(1)
    set()
    >>> prime_factors(7)
    {7}
    """
    if n < 2:
        return set()
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors


def compute_active_primes(torsion_orders_F: List[int],
                           torsion_orders_G: List[int]) -> Set[int]:
    """
    Compute the set of active primes for a pair of filtrations.

    A prime p is active if it divides the torsion order of at least
    one channel in either filtration.

    Time complexity: O(sum(sqrt(n_i)))
    Space complexity: O(number of distinct primes)

    >>> sorted(compute_active_primes([6, 10], [15]))
    [2, 3, 5]
    """
    primes = set()
    for n in torsion_orders_F + torsion_orders_G:
        primes |= prime_factors(n)
    return primes


def compute_p_birth(p: int, birth_times: List[int],
                     torsion_orders: List[int]) -> Optional[int]:
    """
    Compute the p-torsion birth index for a filtration.

    Returns the earliest birth time where p divides the torsion order,
    or None if no p-torsion exists.

    Time complexity: O(n * sqrt(max_order))
    Space complexity: O(1)

    >>> compute_p_birth(2, [3, 5, 7], [6, 15, 10])
    3
    >>> compute_p_birth(7, [3, 5], [6, 15])
    """
    min_time = None
    for t, n in zip(birth_times, torsion_orders):
        if n >= 2 and n % p == 0:
            if min_time is None or t < min_time:
                min_time = t
    return min_time


def compute_prime_shift_vector(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> Dict[int, int]:
    """
    Compute the primewise shift vector for a pair of filtrations.

    Returns a dictionary mapping each active prime to its shift distance.
    Primes where one filtration has torsion but the other doesn't get
    shift = infinity (represented as -1).

    Time complexity: O(|S| * n * sqrt(max_order))
    Space complexity: O(|S|)

    >>> compute_prime_shift_vector([1], [6], [3], [6])
    {2: 2, 3: 2}
    """
    primes = compute_active_primes(F_orders, G_orders)
    shifts = {}
    for p in sorted(primes):
        pF = compute_p_birth(p, F_births, F_orders)
        pG = compute_p_birth(p, G_births, G_orders)
        if pF is not None and pG is not None:
            shifts[p] = abs(pF - pG)
        elif pF is None and pG is None:
            shifts[p] = 0
        else:
            shifts[p] = -1  # infinity
    return shifts


def compute_max_prime_envelope(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> Tuple[int, Dict[int, int]]:
    """
    Compute the max-prime-envelope: the maximum primewise shift.

    This is the certified upper bound on the global torsion birth shift.

    Returns:
        (max_envelope, prime_shifts) where max_envelope is the upper bound
        and prime_shifts is the full primewise shift dictionary.

    Algorithm:
        1. Compute active primes: O(n * sqrt(max_order))
        2. For each prime, compute birth times: O(|S| * n)
        3. Take maximum: O(|S|)
        Total: O(|S| * n * sqrt(max_order))

    >>> compute_max_prime_envelope([1, 5], [6, 10], [3, 7], [6, 10])
    (2, {2: 2, 3: 2, 5: 2})
    """
    shifts = compute_prime_shift_vector(F_births, F_orders, G_births, G_orders)
    finite_shifts = {p: d for p, d in shifts.items() if d >= 0}
    if not finite_shifts:
        return 0, shifts
    max_env = max(finite_shifts.values())
    return max_env, shifts


def compute_global_shift(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> int:
    """
    Compute the global torsion birth shift.

    Returns |globalBirth(F) - globalBirth(G)|, or infinity if one
    has torsion and the other doesn't.

    >>> compute_global_shift([1, 5], [6, 10], [3, 7], [6, 10])
    2
    """
    def global_birth(births, orders):
        min_t = None
        for t, n in zip(births, orders):
            if n >= 2:
                if min_t is None or t < min_t:
                    min_t = t
        return min_t

    gF = global_birth(F_births, F_orders)
    gG = global_birth(G_births, G_orders)
    if gF is None and gG is None:
        return 0
    if gF is None or gG is None:
        return -1  # infinity
    return abs(gF - gG)


def verify_max_envelope_bound(
    F_births: List[int], F_orders: List[int],
    G_births: List[int], G_orders: List[int]
) -> Tuple[bool, int, int, Dict[int, int]]:
    """
    Verify the max-envelope bound: globalShift ≤ maxPrimeEnvelope.

    Returns:
        (bound_holds, global_shift, max_envelope, prime_shifts)

    >>> verify_max_envelope_bound([1], [6], [3], [6])
    (True, 2, 2, {2: 2, 3: 2})
    """
    gs = compute_global_shift(F_births, F_orders, G_births, G_orders)
    me, ps = compute_max_prime_envelope(F_births, F_orders, G_births, G_orders)
    if gs < 0 or me < 0:
        return True, gs, me, ps  # infinity case
    return gs <= me, gs, me, ps


def find_determining_prime(
    births: List[int], orders: List[int]
) -> Optional[int]:
    """
    Find the prime that determines the global torsion birth.

    Returns the smallest prime p such that p-birth equals global birth.

    >>> find_determining_prime([3, 5], [6, 10])
    2
    """
    global_birth_time = None
    for t, n in zip(births, orders):
        if n >= 2:
            if global_birth_time is None or t < global_birth_time:
                global_birth_time = t

    if global_birth_time is None:
        return None

    primes = set()
    for n in orders:
        primes |= prime_factors(n)

    for p in sorted(primes):
        pb = compute_p_birth(p, births, orders)
        if pb == global_birth_time:
            return p
    return None


if __name__ == "__main__":
    import doctest
    doctest.testmod()

    print("Example: F has 6-torsion at t=1 and 10-torsion at t=5")
    print("         G has 6-torsion at t=3 and 10-torsion at t=7")
    F_b, F_o = [1, 5], [6, 10]
    G_b, G_o = [3, 7], [6, 10]

    gs = compute_global_shift(F_b, F_o, G_b, G_o)
    me, ps = compute_max_prime_envelope(F_b, F_o, G_b, G_o)

    print(f"Global shift: {gs}")
    print(f"Max prime envelope: {me}")
    print(f"Prime shifts: {ps}")
    print(f"Upper bound holds: {gs <= me}")
    print(f"Determining prime of F: {find_determining_prime(F_b, F_o)}")
    print(f"Determining prime of G: {find_determining_prime(G_b, G_o)}")
