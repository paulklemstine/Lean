#!/usr/bin/env python3
"""
Arithmetic Phase Classification — Algorithms
=============================================

Core algorithms for computing arithmetic phase profiles of finite groups.

Algorithm 1: Abelianization Order Computation
  Input:  Finite group G (Cayley table)
  Output: |G^ab| = |G/[G,G]|
  Time:   O(|G|³) for commutator closure
  Space:  O(|G|²) for the Cayley table

Algorithm 2: Arithmetic Phase Profile
  Input:  Finite group G
  Output: Set of primes visible to abelian probes
  Time:   O(|G|³ + √|G^ab|) for abelianization + factorization

Algorithm 3: Profile Comparison
  Input:  Two finite groups G₁, G₂
  Output: Whether their profiles match
  Correctness: By Theorem B, profiles match iff abelianizations are isomorphic
"""

from typing import List, Set, Tuple, Dict, Callable, Optional
from dataclasses import dataclass
from math import gcd, isqrt


@dataclass
class FiniteGroup:
    """
    A finite group represented by its Cayley table.
    
    Elements are integers 0, 1, ..., n-1.
    Identity is element 0.
    """
    name: str
    order: int
    cayley_table: List[List[int]]
    
    def mult(self, a: int, b: int) -> int:
        """Multiply two elements."""
        return self.cayley_table[a][b]
    
    def inverse(self, a: int) -> int:
        """Find the inverse of an element."""
        for b in range(self.order):
            if self.cayley_table[a][b] == 0:
                return b
        raise ValueError(f"No inverse found for element {a}")
    
    def element_order(self, a: int) -> int:
        """Compute the order of an element."""
        if a == 0:
            return 1
        current = a
        k = 1
        while current != 0:
            current = self.mult(current, a)
            k += 1
        return k


def compute_commutator_subgroup(G: FiniteGroup) -> Set[int]:
    """
    Algorithm 1a: Compute [G,G] = <ghg⁻¹h⁻¹ | g,h ∈ G>.
    
    Generates all commutators and closes under multiplication.
    
    Time:  O(|G|³) worst case for closure
    Space: O(|G|) for the subgroup
    
    Returns:
        Set of elements in the commutator subgroup.
    """
    # Step 1: Generate all commutators ghg⁻¹h⁻¹
    commutators: Set[int] = {0}  # identity always in [G,G]
    for g in range(G.order):
        g_inv = G.inverse(g)
        for h in range(G.order):
            h_inv = G.inverse(h)
            # ghg⁻¹h⁻¹
            c = G.mult(g, G.mult(h, G.mult(g_inv, h_inv)))
            commutators.add(c)
    
    # Step 2: Close under multiplication and inverse
    subgroup = set(commutators)
    changed = True
    while changed:
        changed = False
        new_elements: Set[int] = set()
        elements_list = list(subgroup)
        for a in elements_list:
            for b in elements_list:
                ab = G.mult(a, b)
                if ab not in subgroup:
                    new_elements.add(ab)
                    changed = True
        subgroup.update(new_elements)
    
    return subgroup


def compute_abelianization_order(G: FiniteGroup) -> int:
    """
    Algorithm 1b: Compute |G^ab| = |G| / |[G,G]|.
    
    Time:  O(|G|³)
    Space: O(|G|)
    
    Returns:
        Order of the abelianization G/[G,G].
    """
    comm = compute_commutator_subgroup(G)
    return G.order // len(comm)


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.
    
    Time:  O(√n)
    Space: O(log n)
    
    Returns:
        Dictionary mapping prime factors to their multiplicities.
    """
    if n <= 1:
        return {}
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def arithmetic_phase_profile(G: FiniteGroup) -> Set[int]:
    """
    Algorithm 2: Compute the arithmetic phase profile of G.
    
    By Theorem A (primePhaseVisible_iff_hasPTorsion_abelianization):
      Profile(G) = {p prime | HasPTorsion(G^ab, p)}
                 = {p prime | p | |G^ab|}  (by Cauchy's theorem)
    
    Time:  O(|G|³ + √|G^ab|)
    Space: O(|G|)
    
    Returns:
        Set of primes in the arithmetic phase profile.
    """
    ab_order = compute_abelianization_order(G)
    return set(prime_factorization(ab_order).keys())


def profiles_match(G1: FiniteGroup, G2: FiniteGroup) -> bool:
    """
    Algorithm 3: Check if two groups have identical arithmetic phase profiles.
    
    By Theorem B (arithmeticPhaseProfile_eq_of_abelianization_equiv):
      If G₁^ab ≅ G₂^ab, then Profile(G₁) = Profile(G₂).
    
    Note: The converse is NOT necessarily true (same profile ≠ isomorphic
    abelianization). This function checks profile equality, which is
    necessary but not sufficient for abelianization isomorphism.
    
    Time:  O(|G₁|³ + |G₂|³ + √max(|G₁^ab|, |G₂^ab|))
    
    Returns:
        True if the profiles are identical.
    """
    return arithmetic_phase_profile(G1) == arithmetic_phase_profile(G2)


def product_profile(G: FiniteGroup, H: FiniteGroup) -> Set[int]:
    """
    Compute the arithmetic phase profile of G × H using the Phase-Union Law.
    
    By Theorem (primePhaseVisible_prod_iff):
      Profile(G × H) = Profile(G) ∪ Profile(H)
    
    This avoids constructing the product group (which has order |G|·|H|).
    
    Time:  O(|G|³ + |H|³)  (much better than O((|G|·|H|)³))
    
    Returns:
        Set of primes in the profile of G × H.
    """
    return arithmetic_phase_profile(G) | arithmetic_phase_profile(H)


def wrong_characteristic_test(G: FiniteGroup, p: int) -> bool:
    """
    Test whether prime p is invisible to abelian probes of G.
    
    By torsion_invisible_wrong_characteristic:
      If p ∤ |G^ab|, then G has no p-torsion visible to abelian probes.
    
    Returns:
        True if p is invisible (wrong characteristic).
    """
    ab_order = compute_abelianization_order(G)
    return ab_order % p != 0


# ─── Example usage ──────────────────────────────────────────────────────────

def make_cyclic_group(n: int) -> FiniteGroup:
    """Construct the cyclic group ℤ/nℤ."""
    table = [[(i + j) % n for j in range(n)] for i in range(n)]
    return FiniteGroup(f"Z/{n}Z", n, table)


def make_symmetric_group_3() -> FiniteGroup:
    """Construct S₃ as a Cayley table group."""
    # S₃ = {e, (12), (13), (23), (123), (132)}
    # Using indices 0-5
    # 0=e, 1=(12), 2=(13), 3=(23), 4=(123), 5=(132)
    table = [
        [0, 1, 2, 3, 4, 5],
        [1, 0, 4, 5, 2, 3],
        [2, 5, 0, 4, 3, 1],
        [3, 4, 5, 0, 1, 2],
        [4, 3, 1, 2, 5, 0],
        [5, 2, 3, 1, 0, 4],
    ]
    return FiniteGroup("S₃", 6, table)


if __name__ == '__main__':
    print("Arithmetic Phase Classification — Algorithm Demonstrations")
    print("=" * 60)
    print()
    
    # Cyclic groups
    for n in [6, 12, 30]:
        G = make_cyclic_group(n)
        profile = arithmetic_phase_profile(G)
        print(f"  ℤ/{n}ℤ: Profile = {{{', '.join(map(str, sorted(profile)))}}}")
    
    print()
    
    # S₃
    S3 = make_symmetric_group_3()
    print(f"  S₃: Profile = {{{', '.join(map(str, sorted(arithmetic_phase_profile(S3))))}}}")
    print(f"  S₃: 5 invisible? {wrong_characteristic_test(S3, 5)} (expected: True)")
    print(f"  S₃: 2 invisible? {wrong_characteristic_test(S3, 2)} (expected: False)")
    
    print()
    
    # Product profiles
    Z6 = make_cyclic_group(6)
    Z10 = make_cyclic_group(10)
    print(f"  Profile(ℤ/6 × ℤ/10) via union law = "
          f"{{{', '.join(map(str, sorted(product_profile(Z6, Z10))))}}}")
    print(f"  (Expected: {{2, 3, 5}})")
