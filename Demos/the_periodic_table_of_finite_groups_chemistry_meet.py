#!/usr/bin/env python3
"""Numerical demonstrations for cyclic–dihedral invariant collisions.

The program uses elementary integer formulas, prints the infinite-family pattern
up to a user-selected bound, inspects the order-six witness, and counts
cyclic-group automorphisms using Euler's totient function.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import gcd
from typing import Iterable


@dataclass(frozen=True)
class GroupProfile:
    """Selected invariants and properties of a finite group."""

    name: str
    order: int
    exponent: int
    cyclic: bool
    commutative: bool
    center_order: int


def lcm(a: int, b: int) -> int:
    """Return the least common multiple of two positive integers."""
    if a <= 0 or b <= 0:
        raise ValueError("lcm inputs must be positive")
    return a // gcd(a, b) * b


def euler_totient(m: int) -> int:
    """Count integers in {1, ..., m} relatively prime to m."""
    if m <= 0:
        raise ValueError("m must be positive")
    return sum(1 for k in range(1, m + 1) if gcd(k, m) == 1)


def cyclic_profile(order: int) -> GroupProfile:
    """Return the relevant profile of the cyclic group of a given order."""
    if order <= 0:
        raise ValueError("order must be positive")
    return GroupProfile(
        name=f"C_{order}",
        order=order,
        exponent=order,
        cyclic=True,
        commutative=True,
        center_order=order,
    )


def dihedral_profile(n: int) -> GroupProfile:
    """Return the profile of the symmetry group of a regular n-gon.

    The group has order 2n. For n > 2 it is noncommutative and noncyclic.
    Its center is trivial when n > 1 is odd.
    """
    if n <= 2:
        raise ValueError("this demonstration requires n > 2")
    odd = n % 2 == 1
    center_order = 1 if odd else 2
    return GroupProfile(
        name=f"D_{2 * n}",
        order=2 * n,
        exponent=lcm(n, 2),
        cyclic=False,
        commutative=False,
        center_order=center_order,
    )


def odd_collision_pairs(max_order: int) -> Iterable[tuple[GroupProfile, GroupProfile]]:
    """Yield cyclic–dihedral collisions of order at most max_order."""
    for n in range(3, max_order // 2 + 1, 2):
        cyclic = cyclic_profile(2 * n)
        dihedral = dihedral_profile(n)
        assert cyclic.order == dihedral.order
        assert cyclic.exponent == dihedral.exponent
        yield cyclic, dihedral


def print_profile(profile: GroupProfile) -> None:
    """Print one profile as an aligned table row."""
    print(
        f"{profile.name:>6} | {profile.order:>5} | {profile.exponent:>8} | "
        f"{str(profile.cyclic):>6} | {str(profile.commutative):>11} | "
        f"{profile.center_order:>6}"
    )


def demonstrate_family(max_order: int = 50) -> None:
    """Print all theorem-family collisions through max_order."""
    print("\nCYCLIC–DIHEDRAL COLLISIONS")
    print(" group | order | exponent | cyclic | commutative | |center|")
    print("-" * 65)
    for cyclic, dihedral in odd_collision_pairs(max_order):
        print_profile(cyclic)
        print_profile(dihedral)
        print("-" * 65)


def demonstrate_order_six() -> None:
    """Inspect the smallest collision and its cyclic automorphism count."""
    cyclic = cyclic_profile(6)
    dihedral = dihedral_profile(3)
    print("\nTHE ORDER-SIX WITNESS")
    print(f"Shared coordinate pair: (order, exponent) = ({cyclic.order}, {cyclic.exponent})")
    print(f"C_6 cyclic/commutative: {cyclic.cyclic}/{cyclic.commutative}")
    print(f"D_6 cyclic/commutative: {dihedral.cyclic}/{dihedral.commutative}")
    print(f"Center orders: {cyclic.center_order} versus {dihedral.center_order}")
    print(f"|Aut(C_6)| = phi(6) = {euler_totient(6)}")


def demonstrate_feature_collision(max_order: int = 50) -> None:
    """Show that one feature key receives contradictory property labels."""
    buckets: dict[tuple[int, int], set[tuple[bool, bool]]] = {}
    for cyclic, dihedral in odd_collision_pairs(max_order):
        for profile in (cyclic, dihedral):
            key = (profile.order, profile.exponent)
            buckets.setdefault(key, set()).add((profile.cyclic, profile.commutative))
    impure = {key: labels for key, labels in buckets.items() if len(labels) > 1}
    print("\nIMPURE (ORDER, EXPONENT) FEATURE BUCKETS")
    for key, labels in impure.items():
        print(f"{key}: labels = {sorted(labels)}")


def main() -> None:
    """Run all demonstrations."""
    demonstrate_family(50)
    demonstrate_order_six()
    demonstrate_feature_collision(50)


if __name__ == "__main__":
    main()
