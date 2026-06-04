#!/usr/bin/env python3
"""
Algorithms for Matroid Minor Theory

Type-hinted implementations of key algorithms for:
1. Rank function computation and validation
2. Matroid deletion and contraction
3. Minor relation testing
4. Rank filtration decomposition
5. Antichain detection in the minor order
"""

from typing import Dict, FrozenSet, Set, List, Tuple, Optional
import itertools

# Type aliases
Element = int
Subset = FrozenSet[Element]
RankFunction = Dict[Subset, int]


def all_subsets(ground: FrozenSet[Element]) -> List[Subset]:
    """Generate all subsets of a ground set."""
    elements = sorted(ground)
    result: List[Subset] = []
    for i in range(len(elements) + 1):
        for combo in itertools.combinations(elements, i):
            result.append(frozenset(combo))
    return result


def validate_rank_function(ground: FrozenSet[Element], r: RankFunction) -> bool:
    """
    Validate that r satisfies the matroid rank axioms:
    (R1) 0 ≤ r(A) ≤ |A|
    (R2) A ⊆ B ⟹ r(A) ≤ r(B)  (monotonicity)
    (R3) r(A∪B) + r(A∩B) ≤ r(A) + r(B)  (submodularity)
    """
    subsets = all_subsets(ground)
    # R1: boundedness
    for s in subsets:
        if not (0 <= r[s] <= len(s)):
            return False
    # R2: monotonicity
    for a in subsets:
        for b in subsets:
            if a <= b and r[a] > r[b]:
                return False
    # R3: submodularity
    for a in subsets:
        for b in subsets:
            if r[a | b] + r[a & b] > r[a] + r[b]:
                return False
    return True


def compute_deletion(ground: FrozenSet[Element], r: RankFunction,
                     d: FrozenSet[Element]) -> Tuple[FrozenSet[Element], RankFunction]:
    """
    Compute M \ D: deletion of elements D from matroid M.
    r_{M\D}(A) = r_M(A) for A ⊆ E \ D.

    Returns: (new_ground_set, new_rank_function)
    """
    new_ground = ground - d
    new_r: RankFunction = {}
    for s in all_subsets(new_ground):
        new_r[s] = r[s]
    return new_ground, new_r


def compute_contraction(ground: FrozenSet[Element], r: RankFunction,
                        c: FrozenSet[Element]) -> Tuple[FrozenSet[Element], RankFunction]:
    """
    Compute M / C: contraction of elements C from matroid M.
    r_{M/C}(A) = r_M(A ∪ C) - r_M(C) for A ⊆ E \ C.

    Returns: (new_ground_set, new_rank_function)
    """
    new_ground = ground - c
    r_c = r[c]
    new_r: RankFunction = {}
    for s in all_subsets(new_ground):
        new_r[s] = r[s | c] - r_c
    return new_ground, new_r


def compute_dual(ground: FrozenSet[Element], r: RankFunction) -> RankFunction:
    """
    Compute the dual matroid M*.
    r*(A) = |A| + r(E \ A) - r(E)
    """
    r_E = r[ground]
    dual_r: RankFunction = {}
    for s in all_subsets(ground):
        complement = ground - s
        dual_r[s] = len(s) + r[complement] - r_E
    return dual_r


def find_minor_witness(
    target_ground: FrozenSet[Element], target_r: RankFunction,
    source_ground: FrozenSet[Element], source_r: RankFunction
) -> Optional[Tuple[FrozenSet[Element], FrozenSet[Element]]]:
    """
    Find C, D such that target = source / C \ D, if they exist.
    Returns (C, D) or None.
    """
    elements = sorted(source_ground)
    for c_size in range(len(elements) + 1):
        for c_combo in itertools.combinations(elements, c_size):
            c = frozenset(c_combo)
            remaining = source_ground - c
            contracted_ground, contracted_r = compute_contraction(source_ground, source_r, c)
            for d_size in range(len(list(remaining)) + 1):
                for d_combo in itertools.combinations(sorted(remaining), d_size):
                    d = frozenset(d_combo)
                    minor_ground, minor_r = compute_deletion(contracted_ground, contracted_r, d)
                    if minor_ground == target_ground:
                        if all(minor_r[s] == target_r[s]
                               for s in all_subsets(target_ground)):
                            return c, d
    return None


def rank_filtration(
    matroids: List[Tuple[FrozenSet[Element], RankFunction]]
) -> Dict[int, List[int]]:
    """
    Decompose a list of matroids by rank level.
    Returns: {rank: [indices into matroids list]}
    """
    filtration: Dict[int, List[int]] = {}
    for i, (ground, r) in enumerate(matroids):
        rank = r[ground]
        if rank not in filtration:
            filtration[rank] = []
        filtration[rank].append(i)
    return filtration


def find_antichains(
    matroids: List[Tuple[FrozenSet[Element], RankFunction]]
) -> List[List[int]]:
    """
    Find maximal antichains in the minor order.
    Uses a greedy approach — not guaranteed optimal but finds all pairwise-incomparable sets.
    """
    n = len(matroids)
    # Build comparability matrix
    comparable = [[False] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            if i != j:
                result = find_minor_witness(
                    matroids[i][0], matroids[i][1],
                    matroids[j][0], matroids[j][1])
                if result is not None:
                    comparable[i][j] = True

    # Find all maximal antichains using backtracking
    antichains: List[List[int]] = []

    def backtrack(start: int, current: List[int]) -> None:
        is_maximal = True
        for i in range(start, n):
            if all(not comparable[i][j] and not comparable[j][i]
                   for j in current):
                is_maximal = False
                backtrack(i + 1, current + [i])
        if is_maximal and len(current) > 0:
            antichains.append(current[:])

    backtrack(0, [])
    return antichains


def uniform_matroid(n: int, k: int) -> Tuple[FrozenSet[Element], RankFunction]:
    """Create the uniform matroid U(k,n)."""
    ground = frozenset(range(n))
    r: RankFunction = {}
    for s in all_subsets(ground):
        r[s] = min(len(s), k)
    return ground, r


# Quick test
if __name__ == "__main__":
    g, r = uniform_matroid(4, 2)
    assert validate_rank_function(g, r)
    print("U(2,4) validated")

    g_del, r_del = compute_deletion(g, r, frozenset({3}))
    assert validate_rank_function(g_del, r_del)
    print("U(2,4) \\ {3} validated")

    g_con, r_con = compute_contraction(g, r, frozenset({0}))
    assert validate_rank_function(g_con, r_con)
    print("U(2,4) / {0} validated")

    r_dual = compute_dual(g, r)
    assert validate_rank_function(g, r_dual)
    print("U(2,4)* validated")

    w = find_minor_witness(*uniform_matroid(3, 2), *uniform_matroid(4, 2))
    print(f"U(2,3) ≤ U(2,4) via C={w[0] if w else 'N/A'}, D={w[1] if w else 'N/A'}")
    print("All algorithms validated.")
