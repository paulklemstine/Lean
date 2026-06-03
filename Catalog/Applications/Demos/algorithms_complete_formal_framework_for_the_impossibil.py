"""
Algorithms for computing impossibility spectra of finite group actions.

This module provides implementations of:
1. Subgroup enumeration for finite groups
2. Fixed-point set computation
3. Impossibility spectrum computation
4. Obstruction filter verification
"""

from typing import List, Set, Tuple, Dict, FrozenSet, Callable, Optional
from itertools import product, combinations
from functools import reduce


# --- Group representation ---

class FiniteGroup:
    """A finite group represented by its multiplication table."""

    def __init__(self, elements: List[int], mult: Callable[[int, int], int],
                 inv: Callable[[int], int], identity: int):
        self.elements = elements
        self.mult = mult
        self.inv = inv
        self.identity = identity
        self.order = len(elements)

    def conjugate(self, g: int, h: int) -> int:
        """Compute g * h * g^{-1}."""
        return self.mult(self.mult(g, h), self.inv(g))


class GSet:
    """A finite G-set: a set with a group action."""

    def __init__(self, group: FiniteGroup, points: List[int],
                 action: Callable[[int, int], int]):
        self.group = group
        self.points = points
        self.action = action
        self.size = len(points)


# --- Core algorithms ---

def fixed_point_set(gset: GSet, subgroup: FrozenSet[int]) -> Set[int]:
    """Compute X^H = {x ∈ X | h·x = x for all h ∈ H}.

    Args:
        gset: The G-set X.
        subgroup: A subgroup H ≤ G as a frozenset of elements.

    Returns:
        The set of fixed points of H in X.
    """
    fixed = set()
    for x in gset.points:
        if all(gset.action(h, x) == x for h in subgroup):
            fixed.add(x)
    return fixed


def enumerate_subgroups(group: FiniteGroup) -> List[FrozenSet[int]]:
    """Enumerate all subgroups of a finite group.

    Uses a brute-force approach: for each subset, check if it forms a subgroup.
    Suitable for small groups (order ≤ 20).

    Args:
        group: The finite group.

    Returns:
        List of subgroups, each as a frozenset of elements.
    """
    subgroups = []
    n = group.order
    elts = group.elements

    for size in range(1, n + 1):
        if n % size != 0:  # Lagrange's theorem
            continue
        for subset in combinations(elts, size):
            subset_set = frozenset(subset)
            if group.identity not in subset_set:
                continue
            # Check closure and inverses
            is_subgroup = True
            for a in subset:
                if group.inv(a) not in subset_set:
                    is_subgroup = False
                    break
                for b in subset:
                    if group.mult(a, b) not in subset_set:
                        is_subgroup = False
                        break
                if not is_subgroup:
                    break
            if is_subgroup:
                subgroups.append(subset_set)

    return subgroups


def conjugate_subgroup(group: FiniteGroup, subgroup: FrozenSet[int],
                       g: int) -> FrozenSet[int]:
    """Compute gHg^{-1} for a subgroup H and element g.

    Args:
        group: The ambient group.
        subgroup: The subgroup H.
        g: The conjugating element.

    Returns:
        The conjugate subgroup gHg^{-1}.
    """
    return frozenset(group.conjugate(g, h) for h in subgroup)


def has_equivariant_map(source: GSet, target: GSet,
                        subgroup: FrozenSet[int]) -> bool:
    """Check if an H-equivariant map X → Y exists.

    Uses backtracking search over all possible assignments.

    Args:
        source: The source G-set X.
        target: The target G-set Y.
        subgroup: The subgroup H.

    Returns:
        True if an H-equivariant map exists, False otherwise.
    """
    if source.size == 0:
        return True  # Empty function is vacuously equivariant

    assignment: Dict[int, int] = {}

    def backtrack(idx: int) -> bool:
        if idx == source.size:
            return True

        x = source.points[idx]
        for y in target.points:
            # Check if assigning f(x) = y is consistent
            consistent = True
            for h in subgroup:
                hx = source.action(h, x)
                hy = target.action(h, y)
                if hx in assignment and assignment[hx] != hy:
                    consistent = False
                    break
            if not consistent:
                continue

            # Try this assignment
            forced: Dict[int, int] = {}
            valid = True
            for h in subgroup:
                hx = source.action(h, x)
                hy = target.action(h, y)
                if hx in assignment:
                    if assignment[hx] != hy:
                        valid = False
                        break
                elif hx in forced:
                    if forced[hx] != hy:
                        valid = False
                        break
                else:
                    forced[hx] = hy

            if not valid:
                continue

            old_assign = dict(assignment)
            assignment[x] = y
            assignment.update(forced)

            if backtrack(idx + 1):
                return True

            assignment.clear()
            assignment.update(old_assign)

        return False

    return backtrack(0)


def impossibility_spectrum(source: GSet, target: GSet) -> List[FrozenSet[int]]:
    """Compute the impossibility spectrum ImpSpec(G, X, Y).

    First applies the fixed-point obstruction as a fast filter,
    then uses backtracking for remaining cases.

    Args:
        source: The source G-set X.
        target: The target G-set Y.

    Returns:
        List of subgroups H for which no H-equivariant map X → Y exists.
    """
    group = source.group
    subgroups = enumerate_subgroups(group)
    spectrum: List[FrozenSet[int]] = []

    # Precompute fixed points
    fixed_x: Dict[FrozenSet[int], Set[int]] = {}
    fixed_y: Dict[FrozenSet[int], Set[int]] = {}
    for H in subgroups:
        fixed_x[H] = fixed_point_set(source, H)
        fixed_y[H] = fixed_point_set(target, H)

    # Check each subgroup
    known_impossible: Set[FrozenSet[int]] = set()
    for H in sorted(subgroups, key=len):  # Smaller subgroups first
        if H in known_impossible:
            spectrum.append(H)
            continue

        # Fixed-point obstruction
        if fixed_x[H] and not fixed_y[H]:
            spectrum.append(H)
            known_impossible.add(H)
            # Upward closure: mark all supergroups as impossible
            for K in subgroups:
                if H.issubset(K):
                    known_impossible.add(K)
            continue

        # Full backtracking search
        if not has_equivariant_map(source, target, H):
            spectrum.append(H)
            known_impossible.add(H)
            for K in subgroups:
                if H.issubset(K):
                    known_impossible.add(K)

    return spectrum


def is_obstruction_filter(group: FiniteGroup,
                          carrier: Set[FrozenSet[int]],
                          all_subgroups: List[FrozenSet[int]]) -> Tuple[bool, str]:
    """Verify whether a set of subgroups forms an obstruction filter.

    Checks: upward closure, bottom exclusion, conjugation invariance.

    Args:
        group: The ambient group.
        carrier: The candidate obstruction filter.
        all_subgroups: All subgroups of the group.

    Returns:
        (True, "Valid") or (False, reason).
    """
    trivial = frozenset([group.identity])

    # Check bottom exclusion
    if trivial in carrier:
        return False, "Trivial subgroup is in the carrier"

    # Check upward closure
    for H in carrier:
        for K in all_subgroups:
            if H.issubset(K) and K not in carrier:
                return False, f"Upward closure violated: {H} ⊆ {K} but {K} not in carrier"

    # Check conjugation invariance
    for H in carrier:
        for g in group.elements:
            gHg_inv = conjugate_subgroup(group, H, g)
            if gHg_inv not in carrier:
                return False, f"Conjugation invariance violated: conj of {H} by {g} = {gHg_inv} not in carrier"

    return True, "Valid obstruction filter"


# --- Example: Cyclic groups ---

def cyclic_group(n: int) -> FiniteGroup:
    """Construct the cyclic group Z/nZ.

    Args:
        n: The order of the group.

    Returns:
        The cyclic group of order n.
    """
    return FiniteGroup(
        elements=list(range(n)),
        mult=lambda a, b: (a + b) % n,
        inv=lambda a: (-a) % n,
        identity=0
    )


def cyclic_regular_action(n: int) -> GSet:
    """The regular representation of Z/nZ acting on itself.

    Args:
        n: The order of the group.

    Returns:
        Z/nZ as a G-set with the left regular action.
    """
    G = cyclic_group(n)
    return GSet(G, list(range(n)), lambda g, x: (g + x) % n)


def cyclic_trivial_action(n: int, size: int) -> GSet:
    """Z/nZ acting trivially on a set of given size.

    Args:
        n: The order of the group.
        size: The number of points.

    Returns:
        A G-set with trivial action.
    """
    G = cyclic_group(n)
    return GSet(G, list(range(size)), lambda g, x: x)


# --- Symmetric group S3 ---

def symmetric_group_s3() -> FiniteGroup:
    """Construct S₃ as permutations of {0, 1, 2}.

    Elements encoded as integers 0-5:
    0 = (), 1 = (01), 2 = (02), 3 = (12), 4 = (012), 5 = (021)
    """
    # Permutation representations
    perms = [
        (0, 1, 2),  # identity
        (1, 0, 2),  # (01)
        (2, 1, 0),  # (02)
        (0, 2, 1),  # (12)
        (1, 2, 0),  # (012)
        (2, 0, 1),  # (021)
    ]

    def compose(a: int, b: int) -> int:
        pa, pb = perms[a], perms[b]
        result = tuple(pa[pb[i]] for i in range(3))
        return perms.index(result)

    def inverse(a: int) -> int:
        pa = perms[a]
        result = [0, 0, 0]
        for i in range(3):
            result[pa[i]] = i
        return perms.index(tuple(result))

    return FiniteGroup(list(range(6)), compose, inverse, 0)


if __name__ == "__main__":
    # Quick sanity check
    G = cyclic_group(4)
    subgroups = enumerate_subgroups(G)
    print(f"Z/4Z has {len(subgroups)} subgroups: {subgroups}")

    X = cyclic_regular_action(4)
    Y = cyclic_trivial_action(4, 2)
    spec = impossibility_spectrum(X, Y)
    print(f"ImpSpec(Z/4, regular, trivial(2)): {spec}")
