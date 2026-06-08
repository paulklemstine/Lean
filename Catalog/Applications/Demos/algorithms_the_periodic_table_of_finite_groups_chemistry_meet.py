#!/usr/bin/env python3
"""
Algorithms for the Periodic Table of Finite Groups.

Implements group-theoretic classification algorithms with type hints.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional


@dataclass
class GroupPeriodicEntry:
    """A periodic table entry for a finite group."""
    name: str
    order: int
    family: str
    derived_depth: Optional[int]
    nilpotency_class: Optional[int]
    center_order: int
    valence: Optional[int]
    info_dimension: int
    is_solvable: bool
    is_nilpotent: bool
    is_abelian: bool
    composition_factors: list[int]


def prime_factorization(n: int) -> list[tuple[int, int]]:
    """Return prime factorization as list of (prime, exponent) pairs."""
    factors: list[tuple[int, int]] = []
    d = 2
    while d * d <= n:
        exp = 0
        while n % d == 0:
            exp += 1
            n //= d
        if exp > 0:
            factors.append((d, exp))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def omega_function(n: int) -> int:
    """Ω(n) — total number of prime factors with multiplicity.
    
    This is the group-theoretic "atomic mass number."
    
    Algorithm: Factor n and sum exponents.
    Time: O(√n)
    """
    return sum(e for _, e in prime_factorization(n))


def classify_by_order(n: int) -> list[str]:
    """Classify possible group families for order n.
    
    Algorithm:
    1. If n = 1: only the trivial group
    2. If n is prime: only Z/nZ (cyclic, simple, abelian)
    3. If n = p^k: all groups are nilpotent (p-groups)
    4. If n is squarefree: all groups are solvable (Burnside)
    5. General: need full enumeration
    
    Returns list of possible families.
    """
    if n == 1:
        return ["Trivial"]
    
    factors = prime_factorization(n)
    
    if len(factors) == 1 and factors[0][1] == 1:
        return ["Noble Gas (Cyclic, Simple, Abelian)"]
    
    if len(factors) == 1:
        p, k = factors[0]
        return [f"Noble Gas (p-group, p={p}, k={k})"]
    
    is_squarefree = all(e == 1 for _, e in factors)
    
    families = ["Noble Gas (Abelian)"]
    
    if not is_squarefree:
        families.append("Noble Gas (Nilpotent non-abelian)")
    
    families.append("Alkali (Solvable non-nilpotent)")
    
    if not is_squarefree and n >= 60:
        families.append("Transition Metal (Simple non-abelian)")
        families.append("Halogen (Non-solvable)")
    
    return families


def derived_depth_upper_bound(n: int) -> int:
    """Upper bound on derived depth for solvable groups of order n.
    
    By the Quantitative Periodic Law: derivedDepth ≤ Ω(n).
    Each step of the derived series produces a nontrivial abelian quotient
    of order ≥ 2, so at most Ω(n) = log₂(n) steps are possible.
    """
    return omega_function(n)


def nilpotency_class_bound(n: int) -> Optional[int]:
    """Upper bound on nilpotency class for groups of order n.
    
    For p-groups of order p^k: class ≤ k-1.
    For general nilpotent groups: class ≤ max class of Sylow subgroups.
    """
    factors = prime_factorization(n)
    if not factors:
        return 0
    return max(e - 1 for _, e in factors) if max(e for _, e in factors) > 0 else 0


def predict_group_properties(n: int) -> dict[str, object]:
    """Predict properties of groups of order n using the periodic table.
    
    This is the "Mendeleev prediction" algorithm.
    """
    factors = prime_factorization(n)
    
    predictions: dict[str, object] = {
        "order": n,
        "info_dimension": omega_function(n),
        "prime_factorization": factors,
        "possible_families": classify_by_order(n),
        "max_derived_depth": derived_depth_upper_bound(n),
        "max_nilpotency_class": nilpotency_class_bound(n),
    }
    
    # Specific predictions
    is_prime = len(factors) == 1 and factors[0][1] == 1
    is_prime_power = len(factors) == 1
    is_squarefree = all(e == 1 for _, e in factors)
    
    predictions["all_groups_cyclic"] = is_prime
    predictions["all_groups_abelian"] = is_prime  # only for prime order
    predictions["all_groups_nilpotent"] = is_prime_power
    predictions["all_groups_solvable"] = all(
        e <= 2 or (p == 2 and e <= 3) for p, e in factors
    ) or n < 60  # Burnside's theorem for specific cases
    predictions["may_contain_simple"] = n >= 60 and not is_squarefree
    
    return predictions


def composition_factor_multiset(n: int) -> list[int]:
    """Return the composition factors of a cyclic group of order n.
    
    For Z/nZ, the composition factors are the primes in the factorization,
    each repeated according to multiplicity.
    """
    result: list[int] = []
    for p, e in prime_factorization(n):
        result.extend([p] * e)
    return sorted(result)


def periodic_table_row(derived_depth: int) -> str:
    """Map derived depth to periodic table row name."""
    rows = {
        0: "Period 0 (Trivial)",
        1: "Period 1 (Abelian)",
        2: "Period 2 (Metabelian)",
        3: "Period 3 (3-step solvable)",
    }
    return rows.get(derived_depth, f"Period {derived_depth}")


def periodic_table_column(family: str) -> int:
    """Map group family to periodic table column number."""
    columns = {
        "abelian": 1,
        "nilpotent": 2,
        "solvable": 3,
        "non-solvable": 4,
        "simple": 5,
    }
    return columns.get(family.lower(), 0)


# --- Main demonstration ---
if __name__ == "__main__":
    print("Periodic Table Predictions for Selected Orders")
    print("=" * 60)
    
    for n in [1, 2, 3, 4, 5, 6, 8, 12, 16, 24, 60, 120, 168]:
        pred = predict_group_properties(n)
        print(f"\nOrder {n}: {pred['prime_factorization']}")
        print(f"  Ω = {pred['info_dimension']}")
        print(f"  Max derived depth: {pred['max_derived_depth']}")
        print(f"  Max nilpotency class: {pred['max_nilpotency_class']}")
        print(f"  Families: {', '.join(pred['possible_families'])}")
        print(f"  All nilpotent: {pred['all_groups_nilpotent']}")
        print(f"  Composition factors (cyclic): {composition_factor_multiset(n)}")
