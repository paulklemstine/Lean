"""
Algorithms for the Periodic Table of Finite Groups

Type-hinted implementations of the core algorithms used in
the group classification system.
"""

from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum


class GroupFamily(Enum):
    """Chemical family classification for finite groups."""
    NOBLE_GAS = "noble_gas"           # Cyclic groups
    ALKALI_METAL = "alkali_metal"     # Nilpotent non-abelian (p-groups)
    ALKALINE_EARTH = "alkaline_earth" # Solvable non-nilpotent
    TRANSITION_METAL = "transition_metal"  # Non-abelian simple
    HALOGEN = "halogen"               # Symmetric groups


@dataclass
class GroupPeriodicEntry:
    """A periodic table entry for a finite group."""
    order: int
    family: GroupFamily
    solvability_depth: Optional[int]
    valence: int  # Number of minimal normal subgroups
    center_order: int
    is_solvable: bool
    is_nilpotent: bool
    is_abelian: bool
    spectrum: List[int]

    def __repr__(self) -> str:
        return (f"GroupEntry(|G|={self.order}, family={self.family.value}, "
                f"depth={self.solvability_depth}, valence={self.valence})")


def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the prime factorization of n.

    Algorithm: Trial division up to sqrt(n).
    Time complexity: O(sqrt(n)).

    Returns:
        Dictionary mapping primes to their exponents.
    """
    if n <= 0:
        raise ValueError(f"Expected positive integer, got {n}")
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


def omega(n: int) -> int:
    """
    Compute Ω(n), the number of prime factors with multiplicity.

    This is the upper bound for the solvability depth of any
    solvable group of order n (Quantitative Periodic Law).
    """
    return sum(prime_factorization(n).values())


def classify_group_family(
    order: int,
    is_abelian: bool,
    is_nilpotent: bool,
    is_solvable: bool,
    is_simple: bool
) -> GroupFamily:
    """
    Classify a finite group into its chemical family.

    Algorithm:
    1. If cyclic/abelian → Noble Gas
    2. If nilpotent but not abelian → Alkali Metal
    3. If solvable but not nilpotent → Alkaline Earth
    4. If simple non-abelian → Transition Metal
    5. If symmetric-like → Halogen

    Pseudocode:
        if is_abelian: return NOBLE_GAS
        if is_nilpotent: return ALKALI_METAL
        if is_simple and not is_abelian: return TRANSITION_METAL
        if is_solvable: return ALKALINE_EARTH
        return HALOGEN
    """
    if is_abelian:
        return GroupFamily.NOBLE_GAS
    if is_simple and not is_abelian:
        return GroupFamily.TRANSITION_METAL
    if is_nilpotent:
        return GroupFamily.ALKALI_METAL
    if is_solvable:
        return GroupFamily.ALKALINE_EARTH
    return GroupFamily.HALOGEN


def compute_solvability_spectrum(
    derived_series_orders: List[int]
) -> List[int]:
    """
    Compute the solvability spectrum from the derived series orders.

    The spectrum is σ_G(n) = |D_n(G)| / |D_{n+1}(G)| for each level.

    Algorithm:
        spectrum = []
        for i in range(len(orders) - 1):
            spectrum.append(orders[i] // orders[i+1])
        return spectrum

    Theorem (proved in Lean 4):
        Each entry σ_G(n) > 1 for n < solDepth(G).
    """
    spectrum: List[int] = []
    for i in range(len(derived_series_orders) - 1):
        if derived_series_orders[i + 1] == 0:
            break
        ratio = derived_series_orders[i] // derived_series_orders[i + 1]
        spectrum.append(ratio)
    return spectrum


def predict_depth_bound(order: int) -> int:
    """
    Predict the maximum solvability depth for groups of the given order.

    By the Quantitative Periodic Law (proved in the catalog for the
    existing PeriodicTableGroups file), the depth is bounded by Ω(n).

    Returns:
        Upper bound on solvability depth.
    """
    return omega(order)


def is_all_nilpotent_order(n: int) -> bool:
    """
    Check if all groups of order n are nilpotent.

    Theorem: All groups of order p^k are nilpotent (p-groups).
    Theorem: A group of squarefree order with coprime-ordered
    cyclic Sylow subgroups is cyclic (hence nilpotent).
    """
    factors = prime_factorization(n)
    # All p-groups are nilpotent
    if len(factors) == 1:
        return True
    # For general orders, non-nilpotent groups can exist
    return False


def build_periodic_table(max_order: int = 100) -> List[Dict]:
    """
    Build a periodic table of group orders with predicted properties.

    For each order n ≤ max_order, compute:
    - Prime factorization
    - Ω(n) (depth bound)
    - Whether all groups of that order are nilpotent
    - Family tendency

    Returns:
        List of dictionaries with group-order-level information.
    """
    table = []
    for n in range(1, max_order + 1):
        factors = prime_factorization(n)
        entry = {
            "order": n,
            "factorization": factors,
            "omega": omega(n),
            "all_nilpotent": is_all_nilpotent_order(n),
            "is_prime": len(factors) == 1 and list(factors.values())[0] == 1,
            "is_prime_power": len(factors) == 1,
            "depth_bound": predict_depth_bound(n),
        }
        table.append(entry)
    return table


# Known group data for small orders (for demonstration)
KNOWN_GROUPS: List[GroupPeriodicEntry] = [
    GroupPeriodicEntry(1, GroupFamily.NOBLE_GAS, 0, 0, 1, True, True, True, []),
    GroupPeriodicEntry(2, GroupFamily.NOBLE_GAS, 1, 1, 2, True, True, True, [2]),
    GroupPeriodicEntry(3, GroupFamily.NOBLE_GAS, 1, 1, 3, True, True, True, [3]),
    GroupPeriodicEntry(4, GroupFamily.NOBLE_GAS, 1, 1, 4, True, True, True, [4]),  # Z/4Z
    GroupPeriodicEntry(4, GroupFamily.NOBLE_GAS, 1, 1, 4, True, True, True, [4]),  # Z/2×Z/2
    GroupPeriodicEntry(5, GroupFamily.NOBLE_GAS, 1, 1, 5, True, True, True, [5]),
    GroupPeriodicEntry(6, GroupFamily.NOBLE_GAS, 1, 1, 6, True, True, True, [6]),  # Z/6
    GroupPeriodicEntry(6, GroupFamily.ALKALINE_EARTH, 2, 2, 1, True, False, False, [2, 3]),  # S_3
    GroupPeriodicEntry(8, GroupFamily.ALKALI_METAL, 2, 1, 2, True, True, False, [2, 2]),  # D_4
    GroupPeriodicEntry(8, GroupFamily.ALKALI_METAL, 2, 1, 2, True, True, False, [2, 2]),  # Q_8
    GroupPeriodicEntry(12, GroupFamily.ALKALINE_EARTH, 2, 1, 1, True, False, False, [3, 4]),  # A_4
    GroupPeriodicEntry(24, GroupFamily.ALKALINE_EARTH, 3, 1, 1, True, False, False, [2, 3, 4]),  # S_4
    GroupPeriodicEntry(60, GroupFamily.TRANSITION_METAL, None, 1, 1, False, False, False, []),  # A_5
]


if __name__ == "__main__":
    print("Periodic Table of Finite Groups — Algorithm Demo")
    print("=" * 60)

    table = build_periodic_table(100)
    nilpotent_orders = [e["order"] for e in table if e["all_nilpotent"]]
    non_nilpotent_capable = [e["order"] for e in table if not e["all_nilpotent"]]

    print(f"\nOrders where ALL groups are nilpotent (prime powers):")
    print(f"  {nilpotent_orders[:20]}...")

    print(f"\nOrders where non-nilpotent groups can exist:")
    print(f"  {non_nilpotent_capable[:20]}...")

    print(f"\nKnown groups in the database:")
    for g in KNOWN_GROUPS:
        print(f"  {g}")

    print(f"\nDepth bounds (Ω function):")
    for n in [6, 12, 24, 30, 60, 120, 360]:
        print(f"  Ω({n}) = {omega(n)} (max possible depth for order {n})")
