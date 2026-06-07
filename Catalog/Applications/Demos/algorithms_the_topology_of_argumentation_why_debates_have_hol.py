#!/usr/bin/env python3
"""
Algorithms for argumentation topology.
Type-hinted implementations of core computational procedures.
"""

from itertools import combinations
from typing import Set, FrozenSet, List, Tuple, Optional, Dict
from collections import defaultdict


def conflict_free_sets(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> List[FrozenSet[int]]:
    """
    Compute all conflict-free subsets of an argumentation framework.

    Algorithm: Generate all subsets and filter by conflict-freeness.
    Complexity: O(2^n * n^2) where n = |args|.

    Args:
        args: Set of argument identifiers.
        attacks: Set of (attacker, target) pairs.

    Returns:
        List of all conflict-free subsets, ordered by size.
    """
    attack_set = set(attacks)
    result: List[FrozenSet[int]] = []
    args_list = sorted(args)

    for r in range(len(args_list) + 1):
        for combo in combinations(args_list, r):
            S = frozenset(combo)
            conflict = False
            for a in S:
                for b in S:
                    if (a, b) in attack_set:
                        conflict = True
                        break
                if conflict:
                    break
            if not conflict:
                result.append(S)

    return result


def admissible_sets(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> List[FrozenSet[int]]:
    """
    Compute all admissible subsets.

    A set S is admissible if:
    1. It is conflict-free.
    2. For every attacker b of any a ∈ S, some c ∈ S attacks b.

    Args:
        args: Set of argument identifiers.
        attacks: Set of (attacker, target) pairs.

    Returns:
        List of all admissible subsets.
    """
    # Build attack maps
    attacked_by: Dict[int, Set[int]] = defaultdict(set)
    for a, b in attacks:
        attacked_by[b].add(a)

    attack_set = set(attacks)
    cf_sets = conflict_free_sets(args, attacks)
    result: List[FrozenSet[int]] = []

    for S in cf_sets:
        admissible = True
        for a in S:
            for b in attacked_by.get(a, set()):
                # b attacks a; need some c in S that attacks b
                if not any((c, b) in attack_set for c in S):
                    admissible = False
                    break
            if not admissible:
                break
        if admissible:
            result.append(S)

    return result


def preferred_extensions(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> List[FrozenSet[int]]:
    """
    Compute preferred extensions (maximal admissible sets).

    Algorithm: Compute all admissible sets, then filter for maximality.
    """
    adm = admissible_sets(args, attacks)
    result: List[FrozenSet[int]] = []
    for S in adm:
        if not any(S < T for T in adm):
            result.append(S)
    return result


def grounded_extension(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> FrozenSet[int]:
    """
    Compute the grounded extension via least fixed point iteration.

    Start with ∅ and repeatedly add arguments that are defended
    by the current set, until convergence.
    """
    attacked_by: Dict[int, Set[int]] = defaultdict(set)
    for a, b in attacks:
        attacked_by[b].add(a)

    attack_set = set(attacks)
    current: Set[int] = set()
    changed = True

    while changed:
        changed = False
        for a in args:
            if a not in current:
                # Check if current defends a
                defended = True
                for b in attacked_by.get(a, set()):
                    if not any((c, b) in attack_set for c in current):
                        defended = False
                        break
                if defended:
                    current.add(a)
                    changed = True

    return frozenset(current)


def euler_characteristic(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> int:
    """
    Compute the Euler characteristic of the conflict-free complex.

    χ = Σ_{d=-1}^{max_dim} (-1)^d * f_d

    where f_d = number of faces of dimension d.
    """
    faces = conflict_free_sets(args, attacks)
    if not faces:
        return 0

    max_dim = max(len(f) for f in faces) - 1
    chi = 0
    for d in range(-1, max_dim + 1):
        count = sum(1 for f in faces if len(f) == d + 1)
        chi += ((-1) ** d) * count
    return chi


def f_vector(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> List[int]:
    """
    Compute the f-vector of the conflict-free complex.

    f_i = number of faces of dimension i, starting from i = -1 (empty face).
    """
    faces = conflict_free_sets(args, attacks)
    if not faces:
        return []

    max_dim = max(len(f) for f in faces) - 1
    return [sum(1 for f in faces if len(f) == d + 1) for d in range(-1, max_dim + 1)]


def is_cone(
    args: Set[int],
    attacks: Set[Tuple[int, int]]
) -> Optional[int]:
    """
    Check if the conflict-free complex is a cone. If so, return the apex vertex.

    A complex is a cone over vertex v if v appears in every maximal face.
    This happens when v is isolated (no attacks to/from v, no self-attack).
    """
    for v in args:
        # Check if v is isolated
        if any(a == v or b == v for a, b in attacks):
            continue
        return v
    return None
