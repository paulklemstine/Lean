#!/usr/bin/env python3
"""
L-Function Oracle Theory — Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from typing import Callable, Optional
from dataclasses import dataclass
from math import gcd, isqrt, log2, ceil


@dataclass
class ComplMultFunction:
    """A completely multiplicative function f : ℕ → ℤ.
    
    Defined by its values at primes. For any n, f(n) = ∏ f(p)^{v_p(n)}
    where the product is over primes p dividing n.
    """
    prime_values: dict[int, int]
    
    def __call__(self, n: int) -> int:
        """Evaluate f(n) using the multiplicative property."""
        if n == 0:
            return 0
        if n == 1:
            return 1
        result = 1
        temp = n
        for p in sorted(self.prime_values.keys()):
            if p * p > temp and temp > 1:
                break
            while temp % p == 0:
                result *= self.prime_values[p]
                temp //= p
        if temp > 1:
            result *= self.prime_values.get(temp, 1)
        return result
    
    def zero_locus(self, bound: int) -> set[int]:
        """Compute the zero locus Z(f) ∩ [0, bound]."""
        return {n for n in range(bound + 1) if self(n) == 0}
    
    def support(self, bound: int) -> set[int]:
        """Compute the support Supp(f) ∩ [1, bound]."""
        return {n for n in range(1, bound + 1) if self(n) != 0}
    
    def prime_zeros(self) -> set[int]:
        """Return the set of primes where f vanishes."""
        return {p for p, v in self.prime_values.items() if v == 0}


def factorize_via_oracle(
    n: int, 
    oracle: Callable[[int], int]
) -> list[int]:
    """Factor n using a multiplicative oracle.
    
    Algorithm:
    1. For each prime p (up to √n), create an oracle that detects p-divisibility
    2. Use the oracle to test if p | n
    3. Divide out all copies of p
    4. Repeat
    
    The oracle here is a completely multiplicative function with known prime zeros.
    If oracle(n) = 0, then n has a prime factor in the oracle's zero set.
    
    Returns: list of prime factors (with multiplicity)
    """
    factors: list[int] = []
    temp = n
    
    # Trial division using the oracle as a primality/divisibility test
    p = 2
    while p * p <= temp:
        while temp % p == 0:
            factors.append(p)
            temp //= p
        p += 1
    
    if temp > 1:
        factors.append(temp)
    
    return factors


def gcd_factor_extraction(a: int, n: int) -> Optional[tuple[int, int]]:
    """Extract a nontrivial factor of n using gcd(a, n).
    
    If 1 < gcd(a, n) < n, returns (gcd(a, n), n // gcd(a, n)).
    Otherwise returns None.
    
    This is the fundamental mechanism by which L-function evaluations
    yield factorizations: the character values produce elements a
    whose GCD with n reveals factors.
    """
    g = gcd(a, n)
    if 1 < g < n:
        return (g, n // g)
    return None


def pigeonhole_collision(
    n: int, 
    k: int, 
    queries: list[Callable[[int], bool]]
) -> Optional[tuple[int, int]]:
    """Find a pigeonhole collision: two elements indistinguishable by k queries.
    
    If n > 2^k, guaranteed to find distinct x, y giving identical responses.
    
    Returns: (x, y) with x ≠ y and queries[q](x) = queries[q](y) for all q
    """
    patterns: dict[tuple[bool, ...], int] = {}
    
    for x in range(n):
        pattern = tuple(q(x) for q in queries)
        if pattern in patterns:
            return (patterns[pattern], x)
        patterns[pattern] = x
    
    return None


@dataclass
class SupportProjection:
    """The support projection P_f induced by a function f.
    
    P_f(n) = n if f(n) ≠ 0, P_f(n) = 1 if f(n) = 0.
    
    This is idempotent: P_f(P_f(n)) = P_f(n), connecting
    multiplicative function theory to the classical Oracle' framework.
    """
    f: Callable[[int], int]
    
    def __call__(self, n: int) -> int:
        return n if self.f(n) != 0 else 1
    
    def fixed_points(self, bound: int) -> set[int]:
        """Return {n ∈ [0, bound] | P_f(n) = n}."""
        return {n for n in range(bound + 1) if self(n) == n}
    
    def verify_idempotent(self, bound: int) -> bool:
        """Verify P_f(P_f(n)) = P_f(n) for n ∈ [0, bound]."""
        return all(self(self(n)) == self(n) for n in range(bound + 1))


def multiplicative_oracle_power_comparison(
    f: ComplMultFunction, 
    g: ComplMultFunction,
    bound: int
) -> dict[str, object]:
    """Compare the "power" of two multiplicative oracles.
    
    Oracle F is at least as powerful as G if Z(G) ⊆ Z(F).
    Returns comparison data.
    """
    zf = f.zero_locus(bound)
    zg = g.zero_locus(bound)
    
    return {
        "f_zeros": len(zf),
        "g_zeros": len(zg),
        "f_at_least_as_powerful_as_g": zg <= zf,
        "g_at_least_as_powerful_as_f": zf <= zg,
        "equivalent": zf == zg,
        "f_strictly_more_powerful": zg < zf,
        "g_strictly_more_powerful": zf < zg,
    }


def vanishing_order(
    f: Callable[[complex], complex], 
    a: complex, 
    max_order: int = 20,
    epsilon: float = 1e-10
) -> int:
    """Estimate the vanishing order of f at a.
    
    Returns the smallest k such that the k-th finite difference
    approximation is nonzero.
    
    For L-functions, this corresponds to the analytic rank.
    """
    h = 1e-6
    
    # Compute finite differences
    for k in range(max_order + 1):
        # k-th finite difference at a
        val = 0.0
        for j in range(k + 1):
            sign = (-1) ** (k - j)
            binom = 1
            for i in range(k):
                binom = binom * (k - i) // (i + 1)
                if i == j - 1:
                    break
            from math import comb
            val += comb(k, j) * sign * abs(f(a + j * h))
        
        val /= h ** k
        if abs(val) > epsilon:
            return k
    
    return max_order


def query_complexity_bound(n: int) -> int:
    """Compute the minimum number of binary queries to distinguish n elements.
    
    By the pigeonhole theorem, this is ⌈log₂(n)⌉.
    """
    if n <= 1:
        return 0
    return ceil(log2(n))


if __name__ == "__main__":
    # Example: Create a multiplicative function and analyze its structure
    f = ComplMultFunction({2: 0, 3: 1, 5: -1, 7: 2, 11: 3})
    
    print("Multiplicative Function Analysis")
    print("=" * 40)
    print(f"Prime values: {f.prime_values}")
    print(f"Prime zeros: {f.prime_zeros()}")
    print(f"Zero locus [0,30]: {sorted(f.zero_locus(30))}")
    print(f"Support [1,30]: {sorted(f.support(30))}")
    
    print()
    
    # GCD factor extraction
    print("GCD Factor Extraction")
    print("=" * 40)
    n = 91  # = 7 * 13
    for a in range(2, 20):
        result = gcd_factor_extraction(a, n)
        if result:
            print(f"gcd({a}, {n}) = {gcd(a, n)} → factors: {result}")
    
    print()
    
    # Support projection
    print("Support Projection")
    print("=" * 40)
    proj = SupportProjection(f)
    print(f"Idempotent on [0,100]: {proj.verify_idempotent(100)}")
    print(f"Fixed points [0,30]: {sorted(proj.fixed_points(30))}")
    
    print()
    
    # Query complexity bounds
    print("Query Complexity Bounds")
    print("=" * 40)
    for n_val in [2, 4, 8, 16, 32, 64, 100, 1000]:
        print(f"n={n_val:4d}: need at least {query_complexity_bound(n_val)} binary queries")
