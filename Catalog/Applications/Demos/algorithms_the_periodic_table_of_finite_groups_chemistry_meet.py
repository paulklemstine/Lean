#!/usr/bin/env python3
"""
Algorithms for the Periodic Table of Finite Groups.

Type-hinted implementations of the core algorithms used in the
group-theoretic periodic table classification.
"""

from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass
from math import gcd, factorial
from collections import Counter
from enum import Enum


# ============================================================
# Core Types
# ============================================================

class ChemicalSeries(Enum):
    """Chemical series classification for finite groups."""
    VACUUM = "Vacuum"           # Trivial group
    NOBLE_GAS = "Noble Gas"     # Cyclic groups
    ALKALINE_EARTH = "Alkaline Earth"  # Abelian non-cyclic
    ALKALI_METAL = "Alkali Metal"      # Nilpotent non-abelian
    COMPOUND = "Compound"       # Solvable non-nilpotent
    RADIOACTIVE = "Radioactive" # Non-solvable


@dataclass
class ReactivityProfile:
    """Chemical fingerprint of a finite group.

    Captures the center-commutator interaction that determines
    a group's 'chemical type' in the periodic table analogy.
    """
    name: str
    group_order: int
    center_order: int
    commutator_order: int
    duality_defect: int  # |Z(G) ∩ [G,G]|
    is_solvable: bool
    is_nilpotent: bool
    nilpotency_class: int
    derived_depth: int

    @property
    def abelian_defect(self) -> int:
        """|G|/|Z(G)| — measures non-commutativity."""
        return self.group_order // self.center_order

    @property
    def join_order(self) -> int:
        """|Z(G)·[G,G]| = |Z|·|[G,G]|/|Z∩[G,G]|."""
        return (self.center_order * self.commutator_order) // self.duality_defect

    @property
    def duality_ratio(self) -> float:
        """ρ(G) = |Z(G)·[G,G]|/|G| — coverage ratio."""
        return self.join_order / self.group_order

    @property
    def chemical_series(self) -> ChemicalSeries:
        """Classify group into chemical series."""
        if self.group_order == 1:
            return ChemicalSeries.VACUUM
        if self.center_order == self.group_order:
            return ChemicalSeries.NOBLE_GAS  # Abelian
        if self.is_nilpotent:
            return ChemicalSeries.ALKALI_METAL
        if self.is_solvable:
            return ChemicalSeries.COMPOUND
        return ChemicalSeries.RADIOACTIVE


# ============================================================
# Number-Theoretic Utilities
# ============================================================

def prime_factorization(n: int) -> Dict[int, int]:
    """Return prime factorization as {prime: exponent} dict.

    Algorithm: Trial division up to √n.
    Time complexity: O(√n).
    """
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


def omega_big(n: int) -> int:
    """Ω(n) — number of prime factors with multiplicity.

    This is the 'atomic weight' in the periodic table analogy.
    The quantitative periodic law states: derivedDepth(G) ≤ Ω(|G|).
    """
    return sum(prime_factorization(n).values())


def omega_small(n: int) -> int:
    """ω(n) — number of distinct prime divisors.

    This determines the 'valence' of cyclic groups with squarefree order.
    """
    return len(prime_factorization(n))


def euler_totient(n: int) -> int:
    """Euler's totient φ(n) = |Aut(ℤ/nℤ)|.

    For prime p: φ(p) = p-1, giving automorphism density (p-1)/p.
    """
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


# ============================================================
# Group Classification Algorithms
# ============================================================

def classify_group(profile: ReactivityProfile) -> Dict[str, any]:
    """Classify a group and compute all periodic table invariants.

    Returns a dictionary with:
    - chemical_series: The group's chemical family
    - abelian_defect: |G|/|Z(G)|
    - omega: Ω(|G|) — upper bound on derived depth
    - duality_ratio: coverage of center-commutator join
    - periodic_law_satisfied: whether derivedDepth ≤ Ω(|G|)
    """
    o = omega_big(profile.group_order)
    return {
        'chemical_series': profile.chemical_series.value,
        'abelian_defect': profile.abelian_defect,
        'omega': o,
        'duality_ratio': profile.duality_ratio,
        'periodic_law_satisfied': profile.derived_depth <= o,
        'aut_density': euler_totient(profile.group_order) / profile.group_order
            if profile.center_order == profile.group_order else None,
    }


def product_profile(
    g1: ReactivityProfile,
    g2: ReactivityProfile,
    name: Optional[str] = None
) -> ReactivityProfile:
    """Compute reactivity profile of G₁ × G₂.

    Uses the proven multiplicativity theorems:
    - |Z(G×H)| = |Z(G)|·|Z(H)|  (center_card_prod)
    - |[G×H,G×H]| = |[G,G]|·|[H,H]|  (commutator_card_prod)
    - abelianDefect(G×H) = abelianDefect(G)·abelianDefect(H)
    - derivedDepth(G×H) = max(derivedDepth(G), derivedDepth(H))
    """
    return ReactivityProfile(
        name=name or f"{g1.name}×{g2.name}",
        group_order=g1.group_order * g2.group_order,
        center_order=g1.center_order * g2.center_order,
        commutator_order=g1.commutator_order * g2.commutator_order,
        duality_defect=g1.duality_defect * g2.duality_defect,
        is_solvable=g1.is_solvable and g2.is_solvable,
        is_nilpotent=g1.is_nilpotent and g2.is_nilpotent,
        nilpotency_class=max(g1.nilpotency_class, g2.nilpotency_class),
        derived_depth=max(g1.derived_depth, g2.derived_depth),
    )


def build_periodic_table(
    profiles: List[ReactivityProfile]
) -> Dict[str, List[ReactivityProfile]]:
    """Organize groups into a periodic table by chemical series.

    Algorithm:
    1. Classify each group by its chemical series
    2. Within each series, sort by group order (atomic number)
    3. Return a dictionary mapping series names to sorted lists

    Pseudocode:
        table = {}
        for each group G:
            series = classify(G)
            table[series].append(G)
        for each series in table:
            sort table[series] by order
        return table
    """
    table: Dict[str, List[ReactivityProfile]] = {}
    for p in profiles:
        series = p.chemical_series.value
        if series not in table:
            table[series] = []
        table[series].append(p)

    for series in table:
        table[series].sort(key=lambda p: p.group_order)

    return table


def verify_periodic_law(profiles: List[ReactivityProfile]) -> Tuple[int, int]:
    """Verify quantitative periodic law for a list of profiles.

    Returns (passed, total) counts.
    The law states: derivedDepth(G) ≤ Ω(|G|) for solvable groups.
    """
    passed = 0
    total = 0
    for p in profiles:
        if p.is_solvable and p.group_order > 1:
            total += 1
            if p.derived_depth <= omega_big(p.group_order):
                passed += 1
    return passed, total


# ============================================================
# Automorphism Density Analysis
# ============================================================

def automorphism_density_sequence(
    max_prime: int = 1000
) -> List[Tuple[int, float]]:
    """Compute automorphism density (p-1)/p for primes up to max_prime.

    The sequence converges to 1 (noble gas inertness in the limit).
    """
    result = []
    for n in range(2, max_prime + 1):
        if all(n % d != 0 for d in range(2, int(n**0.5) + 1)):
            result.append((n, (n - 1) / n))
    return result


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    # Build profiles for small groups
    profiles = [
        ReactivityProfile("Z_1", 1, 1, 1, 1, True, True, 0, 0),
        ReactivityProfile("Z_2", 2, 2, 1, 1, True, True, 1, 1),
        ReactivityProfile("Z_3", 3, 3, 1, 1, True, True, 1, 1),
        ReactivityProfile("Z_4", 4, 4, 1, 1, True, True, 1, 1),
        ReactivityProfile("Z_2²", 4, 4, 1, 1, True, True, 1, 1),
        ReactivityProfile("Z_5", 5, 5, 1, 1, True, True, 1, 1),
        ReactivityProfile("S_3", 6, 1, 3, 1, True, False, 0, 2),
        ReactivityProfile("Z_6", 6, 6, 1, 1, True, True, 1, 1),
        ReactivityProfile("D_4", 8, 2, 2, 2, True, True, 2, 2),
        ReactivityProfile("Q_8", 8, 2, 2, 2, True, True, 2, 2),
        ReactivityProfile("A_4", 12, 1, 4, 1, True, False, 0, 3),
        ReactivityProfile("S_4", 24, 1, 12, 1, True, False, 0, 3),
        ReactivityProfile("A_5", 60, 1, 60, 1, False, False, 0, 0),
    ]

    # Build and display periodic table
    table = build_periodic_table(profiles)
    for series, groups in table.items():
        print(f"\n{series}:")
        for g in groups:
            info = classify_group(g)
            print(f"  {g.name:8s}  |G|={g.group_order:4d}  "
                  f"defect={info['abelian_defect']:3d}  "
                  f"Ω={info['omega']:2d}  "
                  f"ρ={info['duality_ratio']:.3f}")

    # Verify periodic law
    passed, total = verify_periodic_law(profiles)
    print(f"\nQuantitative Periodic Law: {passed}/{total} solvable groups verified")

    # Product multiplicativity demo
    s3 = profiles[6]  # S_3
    z2 = profiles[1]  # Z_2
    prod = product_profile(s3, z2)
    print(f"\nProduct: defect({s3.name})={s3.abelian_defect}, "
          f"defect({z2.name})={z2.abelian_defect}, "
          f"defect({prod.name})={prod.abelian_defect} "
          f"= {s3.abelian_defect}×{z2.abelian_defect}")
