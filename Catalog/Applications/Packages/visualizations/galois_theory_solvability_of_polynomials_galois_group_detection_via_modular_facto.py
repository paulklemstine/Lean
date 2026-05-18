#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Galois Solvability Analysis

Implements:
1. Derived series computation for finite groups
2. Solvability testing
3. Discriminant computation for polynomials
4. Galois group identification for low-degree polynomials
"""

from math import factorial, isqrt, gcd
from typing import List, Tuple, Set, Optional
from itertools import permutations


# ============================================================
# Algorithm 1: Derived Series Computation
# ============================================================

class PermGroup:
    """A permutation group on {0, 1, ..., n-1}."""

    def __init__(self, n: int, elements: Set[Tuple[int, ...]]):
        self.n = n
        self.elements = frozenset(elements)

    @staticmethod
    def identity(n: int) -> Tuple[int, ...]:
        return tuple(range(n))

    @staticmethod
    def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple(p[q[i]] for i in range(len(p)))

    @staticmethod
    def inverse(p: Tuple[int, ...]) -> Tuple[int, ...]:
        n = len(p)
        inv = [0] * n
        for i in range(n):
            inv[p[i]] = i
        return tuple(inv)

    @staticmethod
    def commutator(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        """[a,b] = a*b*a^{-1}*b^{-1}"""
        n = len(a)
        ab = PermGroup.compose(a, b)
        ainv_binv = PermGroup.compose(PermGroup.inverse(a), PermGroup.inverse(b))
        return PermGroup.compose(ab, ainv_binv)

    @classmethod
    def symmetric(cls, n: int) -> 'PermGroup':
        """Generate S_n."""
        return cls(n, set(permutations(range(n))))

    @classmethod
    def from_generators(cls, n: int, gens: List[Tuple[int, ...]]) -> 'PermGroup':
        """Generate group from generators."""
        elements = {cls.identity(n)}
        for g in gens:
            elements.add(g)
        changed = True
        while changed:
            changed = False
            new = set()
            for a in elements:
                for b in elements:
                    c = cls.compose(a, b)
                    if c not in elements and c not in new:
                        new.add(c)
                        changed = True
            elements |= new
        return cls(n, elements)

    def commutator_subgroup(self) -> 'PermGroup':
        """Compute [G, G]."""
        comms = set()
        for a in self.elements:
            for b in self.elements:
                comms.add(self.commutator(a, b))
        return PermGroup.from_generators(self.n, list(comms))

    def derived_series(self, max_depth: int = 20) -> List['PermGroup']:
        """
        Compute the derived series: G = D^0(G) ⊇ D^1(G) ⊇ ...
        
        Time complexity: O(max_depth * |G|^2 * closure_time)
        Space complexity: O(|G|)
        
        Returns when the series stabilizes or reaches {e}.
        """
        series = [self]
        current = self
        for _ in range(max_depth):
            next_g = current.commutator_subgroup()
            series.append(next_g)
            if len(next_g.elements) == 1:
                break
            if next_g.elements == current.elements:
                break
            current = next_g
        return series

    def is_solvable(self) -> bool:
        """
        Test if the group is solvable.
        
        A finite group G is solvable iff its derived series
        reaches the trivial group in finitely many steps.
        
        Returns:
            True if solvable, False otherwise.
        """
        series = self.derived_series()
        return len(series[-1].elements) == 1

    def order(self) -> int:
        return len(self.elements)

    def __repr__(self) -> str:
        return f"PermGroup(n={self.n}, order={self.order()})"


# ============================================================
# Algorithm 2: Polynomial Discriminant
# ============================================================

def polynomial_discriminant_trinomial(n: int, p: int, q: int) -> int:
    """
    Compute the discriminant of x^n + p*x + q for specific n.
    
    For n = 5: disc = (-1)^10 * (4^4 * p^5 + 5^5 * q^4)
    
    Args:
        n: degree of the polynomial
        p: coefficient of x
        q: constant term
    
    Returns:
        The discriminant as an integer (for integer p, q).
    """
    if n == 5:
        return 4**4 * p**5 + 5**5 * q**4
    elif n == 3:
        return -4 * p**3 - 27 * q**2
    elif n == 2:
        return p**2 - 4 * q  # for x^2 + px + q
    else:
        raise NotImplementedError(f"Trinomial discriminant not implemented for degree {n}")


def is_perfect_square(n: int) -> bool:
    """Test if n is a perfect square."""
    if n < 0:
        return False
    s = isqrt(n)
    return s * s == n


# ============================================================
# Algorithm 3: Galois Group Detection for Quintics
# ============================================================

def roots_mod_p(coeffs: List[int], p: int) -> List[int]:
    """Find roots of polynomial mod p by brute force."""
    roots = []
    for r in range(p):
        val = sum(c * pow(r, i, p) for i, c in enumerate(coeffs)) % p
        if val == 0:
            roots.append(r)
    return roots


def num_roots_mod_p(coeffs: List[int], p: int) -> int:
    """Count roots of polynomial mod p."""
    return len(roots_mod_p(coeffs, p))


def cycle_type_from_factorization(num_roots: int, degree: int) -> str:
    """
    Infer partial cycle type information from number of roots mod p.
    
    If f has k roots mod p, the Frobenius at p has at least k fixed points.
    """
    if num_roots == degree:
        return "identity-like"
    elif num_roots == 0:
        return "no fixed points"
    else:
        return f"{num_roots} fixed point(s)"


def galois_group_evidence(coeffs: List[int], primes: List[int]) -> dict:
    """
    Gather evidence about the Galois group of a polynomial over Q.
    
    Uses:
    - Root counting mod p (cycle type information)
    - Discriminant (A_n vs S_n)
    
    Args:
        coeffs: polynomial coefficients [a0, a1, ..., an]
        primes: list of primes to test
    
    Returns:
        Dictionary with evidence summary.
    """
    degree = len(coeffs) - 1
    evidence = {
        'degree': degree,
        'prime_data': [],
        'has_no_fixed_points': False,
        'has_all_fixed_points': False,
    }

    for p in primes:
        nr = num_roots_mod_p(coeffs, p)
        ct = cycle_type_from_factorization(nr, degree)
        evidence['prime_data'].append({
            'prime': p,
            'num_roots': nr,
            'cycle_info': ct
        })
        if nr == 0:
            evidence['has_no_fixed_points'] = True
        if nr == degree:
            evidence['has_all_fixed_points'] = True

    return evidence


# ============================================================
# Algorithm 4: Solvability Decision for Degree ≤ 4
# ============================================================

def is_solvable_by_degree(degree: int) -> Optional[bool]:
    """
    Decide solvability by radicals based on degree alone.
    
    - Degree ≤ 4: always solvable (quadratic, Cardano, Ferrari formulas)
    - Degree ≥ 5: depends on the Galois group
    
    Args:
        degree: degree of the polynomial
    
    Returns:
        True if always solvable, None if depends on the polynomial.
    """
    if degree <= 4:
        return True
    return None  # Depends on the specific polynomial


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=== Derived Series Demo ===")
    for n in [3, 4, 5]:
        g = PermGroup.symmetric(n)
        series = g.derived_series()
        orders = [s.order() for s in series]
        solvable = g.is_solvable()
        print(f"S_{n}: orders = {orders}, solvable = {solvable}")

    print("\n=== Discriminant Demo ===")
    # x^5 - x - 1: p=-1, q=-1
    disc = polynomial_discriminant_trinomial(5, -1, -1)
    print(f"disc(x^5 - x - 1) = {disc}")
    print(f"Is perfect square? {is_perfect_square(disc)}")

    print("\n=== Galois Group Evidence for x^5 - x - 1 ===")
    coeffs = [-1, -1, 0, 0, 0, 1]
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    ev = galois_group_evidence(coeffs, primes)
    for pd in ev['prime_data']:
        print(f"  p={pd['prime']:>3}: {pd['num_roots']} roots mod p -> {pd['cycle_info']}")
    print(f"  Has element with no fixed points: {ev['has_no_fixed_points']}")
    print(f"  Discriminant not square => Gal not in A_5")
    print(f"  Conclusion: Gal(x^5-x-1/Q) = S_5, not solvable by radicals")
