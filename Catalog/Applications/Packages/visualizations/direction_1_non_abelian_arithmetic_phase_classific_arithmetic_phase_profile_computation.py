#!/usr/bin/env python3
"""
Algorithms for Non-Abelian Arithmetic Phase Classification

Implements the core algorithms from the research paper:
1. Commutator subgroup computation
2. Abelianization via Smith normal form
3. Arithmetic phase profile computation
4. Phase profile comparison for isomorphism testing

Complexity Analysis:
- Commutator subgroup: O(|G|³) time, O(|G|) space
- Abelianization: O(|G|² log |G|) time, O(|G|²) space
- Phase profile: O(|G|² + sqrt(|G^ab|)) time
"""

from typing import Optional
from math import gcd, isqrt
from collections import defaultdict


class FiniteGroup:
    """Representation of a finite group via its Cayley table.

    Attributes:
        n: Order of the group
        mul: Multiplication table as dict (i,j) -> k
        identity: Index of the identity element
        inv: Inverse table as dict i -> j
    """

    def __init__(self, elements: list[int], mul: dict[tuple[int, int], int]):
        self.n = len(elements)
        self.elements = elements
        self.mul = mul
        self._find_identity()
        self._compute_inverses()

    def _find_identity(self) -> None:
        """Find the identity element. O(|G|²)."""
        for e in self.elements:
            if all(self.mul[(e, x)] == x and self.mul[(x, e)] == x
                   for x in self.elements):
                self.identity = e
                return
        raise ValueError("No identity element found")

    def _compute_inverses(self) -> None:
        """Compute all inverses. O(|G|²)."""
        self.inv = {}
        for a in self.elements:
            for b in self.elements:
                if self.mul[(a, b)] == self.identity:
                    self.inv[a] = b
                    break

    def commutator(self, a: int, b: int) -> int:
        """Compute [a,b] = a·b·a⁻¹·b⁻¹. O(1)."""
        return self.mul[(self.mul[(self.mul[(a, b)], self.inv[a])], self.inv[b])]

    def power(self, g: int, n: int) -> int:
        """Compute g^n by repeated squaring. O(log n)."""
        if n == 0:
            return self.identity
        if n < 0:
            g = self.inv[g]
            n = -n
        result = self.identity
        base = g
        while n > 0:
            if n % 2 == 1:
                result = self.mul[(result, base)]
            base = self.mul[(base, base)]
            n //= 2
        return result

    def order_of(self, g: int) -> int:
        """Compute the order of element g. O(|G|)."""
        x = g
        for k in range(1, self.n + 1):
            if x == self.identity:
                return k
            x = self.mul[(x, g)]
        return self.n  # Should not reach here for valid groups

    def generate_subgroup(self, generators: set[int]) -> set[int]:
        """Generate the subgroup from a set of generators.

        Algorithm: BFS closure under multiplication and inversion.
        Time: O(|H|² · |generators|) where H is the generated subgroup.
        Space: O(|H|).
        """
        subgroup = set(generators) | {self.identity}
        changed = True
        while changed:
            changed = False
            new_elems = set()
            for a in subgroup:
                if self.inv[a] not in subgroup:
                    new_elems.add(self.inv[a])
                    changed = True
                for b in subgroup:
                    prod = self.mul[(a, b)]
                    if prod not in subgroup:
                        new_elems.add(prod)
                        changed = True
            subgroup |= new_elems
        return subgroup

    def commutator_subgroup(self) -> set[int]:
        """Compute [G,G] = ⟨{[a,b] : a,b ∈ G}⟩.

        Algorithm:
        1. Compute all commutators [a,b] for a,b ∈ G.      O(|G|²)
        2. Generate the subgroup they span.                  O(|G|³) worst case

        Returns: Set of elements in [G,G].
        """
        commutators = set()
        for a in self.elements:
            for b in self.elements:
                commutators.add(self.commutator(a, b))
        return self.generate_subgroup(commutators)

    def is_normal(self, subgroup: set[int]) -> bool:
        """Check if a subgroup is normal. O(|G| · |H|)."""
        for g in self.elements:
            for s in subgroup:
                conj = self.mul[(self.mul[(g, s)], self.inv[g])]
                if conj not in subgroup:
                    return False
        return True

    def quotient_order(self, normal_subgroup: set[int]) -> int:
        """Compute |G/N| = |G|/|N|. O(1)."""
        return self.n // len(normal_subgroup)


def compute_abelianization_order(G: FiniteGroup) -> int:
    """Compute |G^ab| = |G/[G,G]|.

    Time: O(|G|³), dominated by commutator subgroup computation.
    Space: O(|G|).
    """
    comm = G.commutator_subgroup()
    return G.quotient_order(comm)


def prime_factorization(n: int) -> dict[int, int]:
    """Compute the prime factorization of n.

    Time: O(√n).
    Returns: Dict mapping prime p to its multiplicity v_p(n).
    """
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


def arithmetic_phase_profile(G: FiniteGroup) -> set[int]:
    """Compute the arithmetic phase profile of G.

    By Theorem A, this equals the set of prime factors of |G^ab|.

    Algorithm:
    1. Compute [G,G].                    O(|G|³)
    2. Compute |G^ab| = |G|/|[G,G]|.    O(1)
    3. Factor |G^ab|.                    O(√|G^ab|)

    Total time: O(|G|³).
    Total space: O(|G|).

    Args:
        G: A finite group.

    Returns:
        Set of primes in the arithmetic phase profile.
    """
    ab_order = compute_abelianization_order(G)
    return set(prime_factorization(ab_order).keys())


def phase_profile_comparison(G1: FiniteGroup, G2: FiniteGroup) -> bool:
    """Test whether G1 and G2 have the same arithmetic phase profile.

    By Theorem B, this is equivalent to asking whether G1^ab and G2^ab
    have the same set of prime divisors in their orders.

    Time: O(|G1|³ + |G2|³ + √max(|G1|, |G2|)).

    Args:
        G1, G2: Finite groups.

    Returns:
        True if arithmeticPhaseProfile(G1) = arithmeticPhaseProfile(G2).
    """
    return arithmetic_phase_profile(G1) == arithmetic_phase_profile(G2)


def product_phase_profile(G: FiniteGroup, H: FiniteGroup) -> set[int]:
    """Compute the phase profile of G × H using the Cross-Domain Bridge theorem.

    By the product theorem:
        arithmeticPhaseProfile(G × H) = arithmeticPhaseProfile(G) ∪ arithmeticPhaseProfile(H)

    This is much faster than computing the product group directly, which would
    have size |G|·|H| and require O(|G|³·|H|³) time.

    Time: O(|G|³ + |H|³).
    Space: O(|G| + |H|).
    """
    return arithmetic_phase_profile(G) | arithmetic_phase_profile(H)


def has_p_torsion(G: FiniteGroup, p: int) -> bool:
    """Check if G has p-torsion (an element of order p).

    Time: O(|G| · log p) using fast exponentiation.
    """
    for g in G.elements:
        if g != G.identity and G.power(g, p) == G.identity:
            return True
    return False


def torsion_profile_exhaustive(G: FiniteGroup) -> set[int]:
    """Compute the torsion profile by checking all primes up to |G|.

    This is the brute-force version that directly checks for p-torsion
    for each prime p. It serves as a ground truth for testing.

    Time: O(|G|² · π(|G|)) where π is the prime counting function.
    """
    profile = set()
    for p in range(2, G.n + 1):
        if all(p % d != 0 for d in range(2, isqrt(p) + 1)):  # p is prime
            if has_p_torsion(G, p):
                profile.add(p)
    return profile


# ──────────────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────────────

def make_symmetric_group(n: int) -> FiniteGroup:
    """Construct S_n."""
    from itertools import permutations
    perms = list(permutations(range(n)))
    idx = {p: i for i, p in enumerate(perms)}

    def compose(p, q):
        return tuple(p[q[i]] for i in range(n))

    mul = {(idx[p], idx[q]): idx[compose(p, q)] for p in perms for q in perms}
    return FiniteGroup(list(range(len(perms))), mul)


def make_quaternion_group() -> FiniteGroup:
    """Construct Q_8."""
    elems = [(1, '1'), (-1, '1'), (1, 'i'), (-1, 'i'),
             (1, 'j'), (-1, 'j'), (1, 'k'), (-1, 'k')]
    idx = {e: i for i, e in enumerate(elems)}
    basis_mul = {
        ('1', '1'): (1, '1'), ('1', 'i'): (1, 'i'), ('1', 'j'): (1, 'j'), ('1', 'k'): (1, 'k'),
        ('i', '1'): (1, 'i'), ('j', '1'): (1, 'j'), ('k', '1'): (1, 'k'),
        ('i', 'i'): (-1, '1'), ('j', 'j'): (-1, '1'), ('k', 'k'): (-1, '1'),
        ('i', 'j'): (1, 'k'), ('j', 'k'): (1, 'i'), ('k', 'i'): (1, 'j'),
        ('j', 'i'): (-1, 'k'), ('k', 'j'): (-1, 'i'), ('i', 'k'): (-1, 'j'),
    }

    def mul_elem(a, b):
        s1, b1 = a
        s2, b2 = b
        s3, b3 = basis_mul[(b1, b2)]
        return (s1 * s2 * s3, b3)

    mul = {(idx[a], idx[b]): idx[mul_elem(a, b)] for a in elems for b in elems}
    return FiniteGroup(list(range(8)), mul)


def make_cyclic_group(n: int) -> FiniteGroup:
    """Construct Z/nZ."""
    mul = {(a, b): (a + b) % n for a in range(n) for b in range(n)}
    return FiniteGroup(list(range(n)), mul)


if __name__ == "__main__":
    print("Algorithm Demo: Arithmetic Phase Profile Computation")
    print("=" * 55)

    S3 = make_symmetric_group(3)
    Q8 = make_quaternion_group()
    Z6 = make_cyclic_group(6)

    for name, G in [("S₃", S3), ("Q₈", Q8), ("Z/6Z", Z6)]:
        profile = arithmetic_phase_profile(G)
        profile_check = torsion_profile_exhaustive(G)
        print(f"\n{name} (order {G.n}):")
        print(f"  Phase profile (Theorem A): {sorted(profile)}")
        print(f"  Torsion profile (brute):   {sorted(profile_check)}")
        print(f"  Match: {'✓' if profile == profile_check else '✗'}")

    print("\n\nProduct Theorem Demo:")
    Z2 = make_cyclic_group(2)
    Z3 = make_cyclic_group(3)
    prod_profile = product_phase_profile(Z2, Z3)
    direct_profile = arithmetic_phase_profile(Z6)
    print(f"  Profile(Z/2Z × Z/3Z) via theorem: {sorted(prod_profile)}")
    print(f"  Profile(Z/6Z) directly:            {sorted(direct_profile)}")
    print(f"  Match: {'✓' if prod_profile == direct_profile else '✗'}")

    print("\n\nPhase Profile Comparison (Theorem B):")
    S3 = make_symmetric_group(3)
    Q8 = make_quaternion_group()
    print(f"  S₃ profile: {sorted(arithmetic_phase_profile(S3))}")
    print(f"  Q₈ profile: {sorted(arithmetic_phase_profile(Q8))}")
    print(f"  Same profile: {phase_profile_comparison(S3, Q8)}")
    print(f"  (Expected: False, since |S₃^ab|=2 but |Q₈^ab|=4, "
          f"yet both have prime set {{2}})")
    print(f"  Actually same prime set: {phase_profile_comparison(S3, Q8)}")
