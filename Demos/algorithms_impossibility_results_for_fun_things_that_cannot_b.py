#!/usr/bin/env python3
"""
Algorithms for Impossibility Theory

Type-hinted implementations of the key algorithms from the
equivariant impossibility framework.
"""

from typing import TypeVar, Callable, Optional
from dataclasses import dataclass
from itertools import product


T = TypeVar('T')


@dataclass
class GroupAction:
    """A finite group action on a finite set."""
    group_elements: list[int]
    domain: list[int]
    action: Callable[[int, int], int]
    identity: int

    def is_free(self) -> bool:
        """Check if the action is free (no non-identity stabilizer)."""
        for g in self.group_elements:
            if g == self.identity:
                continue
            for x in self.domain:
                if self.action(g, x) == x:
                    return False
        return True

    def is_transitive(self) -> bool:
        """Check if the action is transitive (single orbit)."""
        if not self.domain:
            return True
        x0 = self.domain[0]
        orbit = {self.action(g, x0) for g in self.group_elements}
        return orbit == set(self.domain)

    def fixed_points(self, subgroup: list[int]) -> list[int]:
        """Compute fixed points of a subgroup."""
        return [x for x in self.domain
                if all(self.action(g, x) == x for g in subgroup)]

    def stabilizer(self, x: int) -> list[int]:
        """Compute the stabilizer of a point."""
        return [g for g in self.group_elements if self.action(g, x) == x]

    def orbit(self, x: int) -> set[int]:
        """Compute the orbit of a point."""
        return {self.action(g, x) for g in self.group_elements}


@dataclass
class ImpossibilityAnalysis:
    """Complete impossibility analysis of a group action."""
    is_free: bool
    is_transitive: bool
    is_nontrivial: bool
    spectrum: list[list[int]]
    spectrum_minimal: list[list[int]]
    impossibility_degree: int
    verdict: str


def compute_subgroups_cyclic(n: int) -> list[list[int]]:
    """Compute all subgroups of Z/nZ."""
    subgroups: list[list[int]] = []
    for d in range(1, n + 1):
        if n % d == 0:
            subgroup = sorted([k * (n // d) % n for k in range(d)])
            subgroups.append(subgroup)
    return subgroups


def compute_impossibility_spectrum(
    ga: GroupAction,
    subgroups: list[list[int]]
) -> list[list[int]]:
    """
    Compute the impossibility spectrum: the set of nontrivial subgroups
    with empty fixed-point set.

    Algorithm:
    1. For each subgroup H, compute X^H (fixed points).
    2. Include H in spectrum if H is nontrivial and X^H = ∅.

    Time complexity: O(|subgroups| * |H| * |X|)
    """
    spectrum: list[list[int]] = []
    for H in subgroups:
        if H == [ga.identity]:
            continue
        if len(ga.fixed_points(H)) == 0:
            spectrum.append(H)
    return spectrum


def find_minimal_spectrum(
    spectrum: list[list[int]]
) -> list[list[int]]:
    """
    Find the minimal elements of the impossibility spectrum.

    A subgroup H is minimal in the spectrum if no proper subgroup
    of H is also in the spectrum.

    Algorithm:
    1. Sort spectrum by size (ascending).
    2. For each H, check if any smaller spectrum member is a subset of H.
    3. If not, H is minimal.
    """
    minimal: list[list[int]] = []
    spectrum_sets = [set(H) for H in spectrum]

    for i, H_set in enumerate(spectrum_sets):
        is_minimal = True
        for j, K_set in enumerate(spectrum_sets):
            if j == i:
                continue
            if K_set < H_set:  # K is a proper subset of H
                is_minimal = False
                break
        if is_minimal:
            minimal.append(spectrum[i])

    return minimal


def analyze_impossibility(ga: GroupAction, subgroups: list[list[int]]) -> ImpossibilityAnalysis:
    """
    Complete impossibility analysis of a group action.

    Returns:
        ImpossibilityAnalysis with all computed invariants.
    """
    is_free = ga.is_free()
    is_transitive = ga.is_transitive()
    is_nontrivial = len(ga.group_elements) > 1

    spectrum = compute_impossibility_spectrum(ga, subgroups)
    minimal = find_minimal_spectrum(spectrum)

    degree = min(len(H) for H in spectrum) if spectrum else 0

    if is_free and is_nontrivial:
        verdict = "IMPOSSIBLE: No equivariant constant map exists"
    elif not is_free:
        verdict = "POSSIBLE: Action is not free (some stabilizers nontrivial)"
    else:
        verdict = "TRIVIAL: Group is trivial"

    return ImpossibilityAnalysis(
        is_free=is_free,
        is_transitive=is_transitive,
        is_nontrivial=is_nontrivial,
        spectrum=spectrum,
        spectrum_minimal=minimal,
        impossibility_degree=degree,
        verdict=verdict
    )


def verify_transfer_principle(
    source_ga: GroupAction,
    target_ga: GroupAction,
    phi: Callable[[int], int]
) -> dict[str, bool]:
    """
    Verify the transfer principle: if target action is impossible and
    phi is surjective, then source action (via phi) is also impossible.

    Returns dict with verification results.
    """
    # Check surjectivity
    image = {phi(h) for h in source_ga.group_elements}
    is_surjective = image == set(target_ga.group_elements)

    # Check target impossibility
    target_free = target_ga.is_free()
    target_nontrivial = len(target_ga.group_elements) > 1

    # Verify: can we find an equivariant constant map via phi?
    found_constant = False
    for c in target_ga.domain:
        valid = True
        for h in source_ga.group_elements:
            for x in target_ga.domain:
                if target_ga.action(phi(h), x) != x:
                    # f(phi(h) · x) should equal phi(h) · f(x)
                    # For constant f(y) = c: c should equal phi(h) · c
                    if target_ga.action(phi(h), c) != c:
                        valid = False
                        break
            if not valid:
                break
        if valid:
            found_constant = True
            break

    return {
        "phi_surjective": is_surjective,
        "target_free": target_free,
        "target_nontrivial": target_nontrivial,
        "transfer_applies": is_surjective and target_free and target_nontrivial,
        "found_equivariant_constant": found_constant,
        "verified": (is_surjective and target_free and target_nontrivial)
                    == (not found_constant)
    }


def verify_product_freeness(
    ga1: GroupAction, ga2: GroupAction
) -> dict[str, bool]:
    """
    Verify the product freeness theorem: if both actions are free,
    the product action is free.
    """
    free1 = ga1.is_free()
    free2 = ga2.is_free()

    # Build product action
    prod_group = [(g, h) for g in ga1.group_elements for h in ga2.group_elements]
    prod_domain = [(x, y) for x in ga1.domain for y in ga2.domain]
    prod_identity = (ga1.identity, ga2.identity)

    prod_free = True
    for gh in prod_group:
        if gh == prod_identity:
            continue
        for xy in prod_domain:
            result = (ga1.action(gh[0], xy[0]), ga2.action(gh[1], xy[1]))
            if result == xy:
                prod_free = False
                break
        if not prod_free:
            break

    return {
        "action1_free": free1,
        "action2_free": free2,
        "product_free": prod_free,
        "theorem_holds": (free1 and free2) == prod_free or not (free1 and free2)
    }


# === Main demonstration ===
if __name__ == "__main__":
    print("Impossibility Theory: Algorithm Demonstrations")
    print("=" * 50)

    # Example 1: Z/5Z on Z/5Z
    z5 = GroupAction(
        group_elements=list(range(5)),
        domain=list(range(5)),
        action=lambda g, x: (g + x) % 5,
        identity=0
    )
    subgroups_5 = compute_subgroups_cyclic(5)
    result = analyze_impossibility(z5, subgroups_5)
    print(f"\nZ/5Z on Z/5Z:")
    print(f"  {result.verdict}")
    print(f"  Spectrum size: {len(result.spectrum)}")
    print(f"  Impossibility degree: {result.impossibility_degree}")

    # Example 2: Z/6Z on Z/6Z
    z6 = GroupAction(
        group_elements=list(range(6)),
        domain=list(range(6)),
        action=lambda g, x: (g + x) % 6,
        identity=0
    )
    subgroups_6 = compute_subgroups_cyclic(6)
    result6 = analyze_impossibility(z6, subgroups_6)
    print(f"\nZ/6Z on Z/6Z:")
    print(f"  {result6.verdict}")
    print(f"  Spectrum: {result6.spectrum}")
    print(f"  Minimal: {result6.spectrum_minimal}")
    print(f"  Degree: {result6.impossibility_degree}")

    # Example 3: Transfer principle verification
    z3 = GroupAction(list(range(3)), list(range(3)),
                     lambda g, x: (g + x) % 3, 0)
    transfer = verify_transfer_principle(z6, z3, lambda h: h % 3)
    print(f"\nTransfer Z/6Z → Z/3Z:")
    for k, v in transfer.items():
        print(f"  {k}: {v}")

    # Example 4: Product freeness
    z2 = GroupAction(list(range(2)), list(range(2)),
                     lambda g, x: (g + x) % 2, 0)
    prod_result = verify_product_freeness(z2, z3)
    print(f"\nProduct Z/2Z × Z/3Z:")
    for k, v in prod_result.items():
        print(f"  {k}: {v}")
