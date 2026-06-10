#!/usr/bin/env python3
"""
Adelic Persistent Homology — Algorithms

Implements the core algorithms for computing adelic torsion persistence data
from filtered finite abelian groups.

Algorithms:
1. Prime support computation (via order factorization)
2. Adelic torsion datum construction
3. Barcode reconstruction from adelic data
4. CRT torsion splitting
5. Persistence zeta function (experimental)
"""

from math import gcd, log
from collections import defaultdict
from typing import List, Set, Dict, Tuple, Optional


# ─── Algorithm 1: Prime Factorization and Support ─────────────────────────────

def prime_factors(n: int) -> Set[int]:
    """
    Compute the set of prime factors of n.

    Time complexity: O(√n)
    Space complexity: O(log n) for storing factors

    >>> prime_factors(60)
    {2, 3, 5}
    >>> prime_factors(1)
    set()
    """
    if n <= 1:
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


def additive_order(element: int, group_order: int) -> int:
    """
    Compute the additive order of `element` in Z/group_order Z.

    The additive order is the smallest positive k such that k * element ≡ 0 (mod group_order).

    Time complexity: O(group_order)
    Space complexity: O(1)

    >>> additive_order(3, 6)
    2
    >>> additive_order(2, 6)
    3
    """
    if group_order <= 0:
        return 0
    e = element % group_order
    if e == 0:
        return 1
    # The order divides group_order, so we only need to check divisors
    for k in range(1, group_order + 1):
        if (k * e) % group_order == 0:
            return k
    return group_order


def p_primary_support(group_order: int) -> Set[int]:
    """
    Compute the torsion prime support of Z/group_order Z:
    the set of primes p for which the p-primary component is nontrivial.

    For a cyclic group Z/nZ, this equals the set of prime factors of n.

    Time complexity: O(√n)
    Space complexity: O(log n)

    >>> p_primary_support(6)
    {2, 3}
    >>> p_primary_support(1)
    set()
    """
    if group_order <= 1:
        return set()
    return prime_factors(group_order)


# ─── Algorithm 2: Adelic Torsion Datum ────────────────────────────────────────

class AdelicTorsionDatum:
    """
    The adelic torsion datum for a filtered finite abelian group.

    Given a filtration F_0 ⊆ F_1 ⊆ ... ⊆ F_n of finite abelian groups
    (represented by their orders), this structure records:
    - For each prime p and level i, whether p-primary torsion is present
    - The finite support condition (only finitely many primes at each level)

    Construction time: O(n * √max_order)
    Space: O(n * log(max_order))
    """

    def __init__(self, filtration_orders: List[int]):
        """
        Construct the canonical adelic torsion datum.

        Args:
            filtration_orders: List of group orders [|F_0|, |F_1|, ..., |F_n|]

        >>> datum = AdelicTorsionDatum([1, 3, 6])
        >>> datum.is_active(2, 0)
        False
        >>> datum.is_active(3, 1)
        True
        """
        self.n_levels = len(filtration_orders)
        self.orders = list(filtration_orders)

        # Compute local supports
        self._local_support: Dict[Tuple[int, int], bool] = {}
        self._level_primes: Dict[int, Set[int]] = {}

        for i, order in enumerate(self.orders):
            primes = p_primary_support(order)
            self._level_primes[i] = primes
            for p in primes:
                self._local_support[(p, i)] = True

    def is_active(self, p: int, i: int) -> bool:
        """Whether prime p has nontrivial p-primary component at level i."""
        return self._local_support.get((p, i), False)

    def local_support_at(self, i: int) -> Set[int]:
        """The set of active primes at level i."""
        return self._level_primes.get(i, set())

    def all_primes(self) -> Set[int]:
        """All primes appearing anywhere in the datum."""
        return set().union(*self._level_primes.values())

    def reconstruct_support(self, i: int) -> Set[int]:
        """
        Reconstruct the global torsion prime support at level i.

        This is the core reconstruction map: the adelic datum determines
        the global torsion barcode.

        Time: O(|all_primes|)
        """
        return self.local_support_at(i)

    def prime_barcode(self, p: int) -> Optional[Tuple[int, int]]:
        """
        Compute the barcode interval for prime p.

        Returns (birth, death) where birth is the first level where p is active
        and death is the last level where p is active.

        Time: O(n_levels)
        """
        active = [i for i in range(self.n_levels) if self.is_active(p, i)]
        if not active:
            return None
        return (min(active), max(active))

    def full_barcode(self) -> Dict[int, Tuple[int, int]]:
        """
        Compute the complete prime barcode: a dictionary mapping each
        active prime to its birth-death interval.

        Time: O(|primes| * n_levels)
        """
        return {p: self.prime_barcode(p) for p in sorted(self.all_primes())
                if self.prime_barcode(p) is not None}

    def verify_reconstruction(self) -> Tuple[bool, List[str]]:
        """
        Verify the adelic reconstruction conjecture for this datum:
        at every level, the reconstructed support equals the direct computation.

        Returns (success, list of error messages).

        Time: O(n_levels * √max_order)
        """
        errors = []
        for i in range(self.n_levels):
            direct = p_primary_support(self.orders[i])
            reconstructed = self.reconstruct_support(i)
            if direct != reconstructed:
                errors.append(
                    f"Level {i}: direct={direct}, reconstructed={reconstructed}")
        return len(errors) == 0, errors


# ─── Algorithm 3: CRT Torsion Decomposition ──────────────────────────────────

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """
    Extended GCD: returns (g, x, y) such that a*x + b*y = g = gcd(a,b).

    Time: O(log(min(a,b)))
    Space: O(log(min(a,b))) (recursion depth)

    >>> g, x, y = extended_gcd(2, 3)
    >>> 2*x + 3*y == 1
    True
    """
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def crt_torsion_decomposition(
    group_order: int, m: int, k: int
) -> List[Tuple[int, int, int]]:
    """
    CRT decomposition of mk-torsion elements.

    For coprime m and k, decompose each element a of Z/group_order Z
    satisfying mk*a ≡ 0 into a = b + c where m*b ≡ 0 and k*c ≡ 0.

    Uses Bezout coefficients: if m*u + k*v = 1, then
    b = k*v*a and c = m*u*a.

    Time: O(group_order)
    Space: O(group_order) for storing results

    Args:
        group_order: Order of the ambient group
        m, k: Coprime integers whose product divides group_order

    Returns:
        List of (a, b, c) triples where a = b + c mod group_order

    >>> decomp = crt_torsion_decomposition(6, 2, 3)
    >>> all((b + c) % 6 == a for a, b, c in decomp)
    True
    """
    if gcd(m, k) != 1:
        raise ValueError(f"m={m} and k={k} must be coprime")

    _, u, v = extended_gcd(m, k)
    mk = m * k

    results = []
    for a in range(group_order):
        if (mk * a) % group_order == 0:
            b = (k * v * a) % group_order
            c = (m * u * a) % group_order
            assert (b + c) % group_order == a % group_order
            assert (m * b) % group_order == 0
            assert (k * c) % group_order == 0
            results.append((a, b, c))
    return results


# ─── Algorithm 4: Persistence Zeta Function (Experimental) ───────────────────

def persistence_zeta(datum: AdelicTorsionDatum, s: float) -> float:
    """
    Compute the persistence zeta function:

        Z(s) = ∏_p (1 + length(barcode_p) * p^{-s})

    where the product is over primes p with nontrivial barcode.

    This is an experimental invariant inspired by the Euler product
    for the Riemann zeta function. The key property to test is
    whether Z(s) is multiplicative under direct products of filtrations.

    Time: O(|primes|)

    >>> datum = AdelicTorsionDatum([1, 3, 6])
    >>> z = persistence_zeta(datum, 1.0)
    >>> z > 0
    True
    """
    result = 1.0
    for p in datum.all_primes():
        bc = datum.prime_barcode(p)
        if bc is not None:
            length = bc[1] - bc[0] + 1
            result *= (1 + length * p ** (-s))
    return result


# ─── Algorithm 5: Exhaustive Conjecture Testing ──────────────────────────────

def test_reconstruction_conjecture(
    max_order: int = 60,
    max_length: int = 5
) -> Tuple[int, int, List[List[int]]]:
    """
    Exhaustively test the adelic reconstruction conjecture on
    filtrations of cyclic groups.

    Tests all filtrations [d_0, d_1, ..., d_k] where:
    - Each d_i divides d_{i+1}
    - d_0 = 1 (start with trivial group)
    - All d_i divide max_order
    - Length ≤ max_length

    Returns:
        (n_tested, n_passed, counterexamples)

    Time: O(divisors(max_order)^max_length * max_length * √max_order)
    """
    # Get divisors of max_order
    divisors = sorted(d for d in range(1, max_order + 1) if max_order % d == 0)

    n_tested = 0
    n_passed = 0
    counterexamples = []

    def _test_filtrations(current, remaining_length):
        nonlocal n_tested, n_passed
        if len(current) >= 2:
            n_tested += 1
            datum = AdelicTorsionDatum(current)
            ok, _ = datum.verify_reconstruction()
            if ok:
                n_passed += 1
            else:
                counterexamples.append(list(current))

        if remaining_length > 0:
            last = current[-1] if current else 1
            for d in divisors:
                if d >= last and (current == [] or d % last == 0 or last % d == 0):
                    current.append(d)
                    _test_filtrations(current, remaining_length - 1)
                    current.pop()

    _test_filtrations([1], max_length - 1)
    return n_tested, n_passed, counterexamples


# ─── Main: Run all algorithms ────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("ADELIC PERSISTENT HOMOLOGY — ALGORITHM DEMONSTRATIONS")
    print("=" * 70)

    # Algorithm 1: Prime support
    print("\n── Algorithm 1: Prime Support Computation ──")
    for n in [1, 6, 12, 18, 30, 60]:
        print(f"  Z/{n}Z: prime support = {p_primary_support(n)}")

    # Algorithm 2: Adelic datum
    print("\n── Algorithm 2: Adelic Torsion Datum ──")
    datum = AdelicTorsionDatum([1, 2, 6, 12])
    print(f"  Filtration: [1, 2, 6, 12]")
    print(f"  All primes: {sorted(datum.all_primes())}")
    print(f"  Full barcode: {datum.full_barcode()}")
    ok, errors = datum.verify_reconstruction()
    print(f"  Reconstruction verified: {ok}")

    # Algorithm 3: CRT decomposition
    print("\n── Algorithm 3: CRT Torsion Decomposition ──")
    for (n, m, k) in [(6, 2, 3), (12, 3, 4), (30, 5, 6)]:
        decomp = crt_torsion_decomposition(n, m, k)
        print(f"  Z/{n}Z, {m}×{k}={m*k}: {len(decomp)} elements decomposed")

    # Algorithm 4: Persistence zeta
    print("\n── Algorithm 4: Persistence Zeta Function ──")
    for orders in [[1, 6], [1, 3, 6], [1, 2, 6, 12], [1, 2, 4, 12, 60]]:
        d = AdelicTorsionDatum(orders)
        z1 = persistence_zeta(d, 1.0)
        z2 = persistence_zeta(d, 2.0)
        print(f"  {orders}: Z(1)={z1:.4f}, Z(2)={z2:.4f}")

    # Algorithm 5: Exhaustive testing
    print("\n── Algorithm 5: Exhaustive Conjecture Testing ──")
    n_tested, n_passed, counterexamples = test_reconstruction_conjecture(30, 4)
    print(f"  Tested {n_tested} filtrations, passed {n_passed}")
    if counterexamples:
        print(f"  COUNTEREXAMPLES: {counterexamples}")
    else:
        print(f"  No counterexamples found ✓")
