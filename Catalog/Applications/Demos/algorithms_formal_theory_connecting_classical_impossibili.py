#!/usr/bin/env python3
"""
Equivariant Impossibility Theory — Algorithms

Type-hinted implementations of the core algorithms for computing
impossibility spectra, verifying equivariance, and analyzing orbit structures.
"""

from __future__ import annotations
from itertools import product as cartesian_product
from typing import Callable, TypeVar, Optional
from dataclasses import dataclass, field

T = TypeVar('T')


@dataclass
class GroupAction:
    """A finite group acting on a finite set.

    Attributes:
        group_elements: List of group elements (integers for simplicity)
        set_size: Size of the set being acted on
        action: Function (g, x) -> g.x mapping group element and set index to set index
        identity: The identity element of the group
    """
    group_elements: list[int]
    set_size: int
    action: Callable[[int, int], int]
    identity: int = 0

    def orbit(self, x: int) -> frozenset[int]:
        """Compute the orbit of point x."""
        return frozenset(self.action(g, x) for g in self.group_elements)

    def all_orbits(self) -> list[frozenset[int]]:
        """Compute all orbits of the action."""
        remaining = set(range(self.set_size))
        orbits: list[frozenset[int]] = []
        while remaining:
            x = min(remaining)
            orb = self.orbit(x)
            orbits.append(orb)
            remaining -= orb
        return orbits

    def stabilizer(self, x: int) -> list[int]:
        """Compute the stabilizer of point x."""
        return [g for g in self.group_elements if self.action(g, x) == x]

    def is_free(self) -> bool:
        """Check if the action is free (all stabilizers are trivial)."""
        for x in range(self.set_size):
            for g in self.group_elements:
                if g != self.identity and self.action(g, x) == x:
                    return False
        return True

    def fixed_points(self) -> list[int]:
        """Return all fixed points of the action."""
        fps: list[int] = []
        for x in range(self.set_size):
            if all(self.action(g, x) == x for g in self.group_elements):
                fps.append(x)
        return fps

    def restrict_to_subgroup(self, subgroup: list[int]) -> GroupAction:
        """Restrict the action to a subgroup."""
        return GroupAction(
            group_elements=subgroup,
            set_size=self.set_size,
            action=self.action,
            identity=self.identity
        )


@dataclass
class Subgroup:
    """A subgroup of a finite group."""
    elements: list[int]
    name: str
    parent_order: int

    def order(self) -> int:
        return len(self.elements)


def check_equivariance(
    f: dict[int, int],
    source: GroupAction,
    target: GroupAction
) -> bool:
    """Check if function f is equivariant: f(g.x) = g.f(x) for all g, x.

    Args:
        f: Function represented as dict mapping source indices to target indices
        source: Group action on the source set
        target: Group action on the target set

    Returns:
        True if f is equivariant
    """
    for g in source.group_elements:
        for x in range(source.set_size):
            lhs = f[source.action(g, x)]
            rhs = target.action(g, f[x])
            if lhs != rhs:
                return False
    return True


def find_equivariant_map(
    source: GroupAction,
    target: GroupAction
) -> Optional[dict[int, int]]:
    """Find an equivariant map from source to target, or None if impossible.

    Uses brute-force enumeration over all functions. For small sets only.

    Args:
        source: Group action on source set
        target: Group action on target set

    Returns:
        An equivariant map as a dict, or None if no such map exists
    """
    for assignment in cartesian_product(
        range(target.set_size), repeat=source.set_size
    ):
        f = {i: assignment[i] for i in range(source.set_size)}
        if check_equivariance(f, source, target):
            return f
    return None


def compute_impossibility_spectrum(
    full_group: GroupAction,
    target: GroupAction,
    subgroups: list[Subgroup]
) -> list[Subgroup]:
    """Compute the impossibility spectrum.

    The impossibility spectrum is the set of subgroups H such that
    no H-equivariant map from source to target exists.

    Args:
        full_group: The group action on the source set
        target: The group action on the target set
        subgroups: All subgroups to check

    Returns:
        List of subgroups in the impossibility spectrum
    """
    spectrum: list[Subgroup] = []
    for sg in subgroups:
        restricted_source = full_group.restrict_to_subgroup(sg.elements)
        restricted_target = target.restrict_to_subgroup(sg.elements)
        equivariant_map = find_equivariant_map(restricted_source, restricted_target)
        if equivariant_map is None:
            spectrum.append(sg)
    return spectrum


def verify_upward_closure(
    spectrum: list[Subgroup],
    all_subgroups: list[Subgroup],
    containment: dict[int, list[int]]
) -> bool:
    """Verify that the spectrum is upward closed.

    Args:
        spectrum: The computed impossibility spectrum
        all_subgroups: All subgroups of the group
        containment: Map from subgroup index to indices of supergroups

    Returns:
        True if the spectrum is upward closed
    """
    spectrum_indices = {
        i for i, sg in enumerate(all_subgroups) if sg in spectrum
    }
    for idx in spectrum_indices:
        for super_idx in containment.get(idx, []):
            if super_idx not in spectrum_indices:
                return False
    return True


def spectral_gap(
    spectrum: list[Subgroup],
    containment: Callable[[Subgroup, Subgroup], bool]
) -> list[Subgroup]:
    """Compute the spectral gap: minimal elements of the spectrum.

    Args:
        spectrum: The impossibility spectrum
        containment: Function checking if first subgroup ≤ second subgroup

    Returns:
        Minimal elements of the spectrum (subgroups that are in the spectrum
        but no proper subgroup of them is)
    """
    minimal: list[Subgroup] = []
    for sg in spectrum:
        is_minimal = True
        for other in spectrum:
            if other is not sg and containment(other, sg) and not containment(sg, other):
                is_minimal = False
                break
        if is_minimal:
            minimal.append(sg)
    return minimal


def orbit_obstruction_check(
    source: GroupAction,
    target: GroupAction
) -> tuple[bool, str]:
    """Check if orbit-theoretic obstructions prevent equivariant maps.

    For free actions, every source orbit has size |G|. An equivariant
    map sends orbits onto orbits, so target orbits must have size ≥ |G|.

    Args:
        source: Group action on source
        target: Group action on target

    Returns:
        (is_obstructed, reason) tuple
    """
    if not source.is_free():
        return False, "Source action is not free; orbit obstruction not applicable"

    group_order = len(source.group_elements)
    source_orbits = source.all_orbits()
    target_orbits = target.all_orbits()

    target_orbit_sizes = sorted(len(o) for o in target_orbits)
    source_orbit_sizes = sorted(len(o) for o in source_orbits)

    # Each source orbit maps onto a target orbit. For free actions,
    # source orbits have size |G|, so target orbits must accommodate this.
    large_enough = [o for o in target_orbits if len(o) >= group_order]

    if len(large_enough) < len(source_orbits):
        return True, (
            f"Source has {len(source_orbits)} free orbits of size {group_order}, "
            f"but target has only {len(large_enough)} orbits of size ≥ {group_order}"
        )

    return False, "No orbit obstruction detected"


def fixed_point_obstruction_check(
    source: GroupAction,
    target: GroupAction
) -> tuple[bool, str]:
    """Check if fixed-point obstruction prevents equivariant maps.

    If source has a fixed point but target has none, no equivariant map exists.

    Args:
        source: Group action on source
        target: Group action on target

    Returns:
        (is_obstructed, reason) tuple
    """
    source_fps = source.fixed_points()
    target_fps = target.fixed_points()

    if source_fps and not target_fps:
        return True, (
            f"Source has fixed points {source_fps} but target has none. "
            f"By the Fixed Point Obstruction Theorem, no equivariant map exists."
        )

    return False, "No fixed-point obstruction detected"


# === Demo ===
if __name__ == "__main__":
    print("Equivariant Impossibility Theory — Algorithm Demo")
    print("=" * 60)

    # Z/2Z with swap action on {0,1}
    source = GroupAction(
        group_elements=[0, 1],
        set_size=3,
        action=lambda g, x: x if g == 0 else (0 if x == 0 else 3 - x),
        identity=0
    )

    target = GroupAction(
        group_elements=[0, 1],
        set_size=2,
        action=lambda g, y: (g + y) % 2,
        identity=0
    )

    subgroups = [
        Subgroup([0], "{1}", 2),
        Subgroup([0, 1], "Z/2Z", 2),
    ]

    print(f"\nSource fixed points: {source.fixed_points()}")
    print(f"Target fixed points: {target.fixed_points()}")

    # Check obstructions
    fp_obstructed, fp_reason = fixed_point_obstruction_check(source, target)
    print(f"\nFixed-point obstruction: {fp_obstructed}")
    print(f"  Reason: {fp_reason}")

    # Compute spectrum
    spectrum = compute_impossibility_spectrum(source, target, subgroups)
    print(f"\nImpossibility spectrum: {[sg.name for sg in spectrum]}")

    # Compute spectral gap
    def is_subgroup(a: Subgroup, b: Subgroup) -> bool:
        return set(a.elements).issubset(set(b.elements))

    gap = spectral_gap(spectrum, is_subgroup)
    print(f"Spectral gap: {[sg.name for sg in gap]}")
