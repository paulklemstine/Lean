"""
Numerical demonstrations for:

    "Birkhoff polytopes have the clique-face property only in dimensions n <= 2"

Main result reproduced computationally (birkhoff_cliqueFace_iff):

    B_n has the clique-face property  <=>  n <= 2.

This script is fully self-contained (standard library only) and verifies:

  1. Permutation matrices satisfy the Birkhoff-von Neumann row/column-sum conditions.
  2. The Brualdi-Gibson adjacency criterion: P_sigma ~ P_tau  <=>  sigma^{-1} tau is a single cycle.
  3. The 1-skeleton of B_3 is the complete graph K_6.
  4. The three-transposition counterexample (not_cliqueFace_fin_of_three):
     {(1 2), (1 3), (2 3)} is a clique whose support union is the full grid, so the
     identity is supported inside it -> the clique is NOT a face vertex set.
  5. IsFaceVertexSet (support-closedness) holds for all cliques of B_1, B_2 and fails at
     the transposition triangle for B_3, B_4.
  6. A scan over n in {1,2,3,4} reproducing the iff.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import combinations, permutations
from typing import Dict, FrozenSet, List, Set, Tuple

Perm = Tuple[int, ...]  # perm p means i (0-indexed) maps to p[i]
Cell = Tuple[int, int]


# --------------------------------------------------------------------------------------
# Permutations and permutation matrices
# --------------------------------------------------------------------------------------

def all_perms(n: int) -> List[Perm]:
    """All permutations of {0, ..., n-1} as image tuples."""
    return [tuple(p) for p in permutations(range(n))]


def perm_matrix(p: Perm) -> List[List[int]]:
    """The 0/1 permutation matrix P with P[i][p[i]] = 1."""
    n = len(p)
    return [[1 if p[i] == j else 0 for j in range(n)] for i in range(n)]


def is_doubly_stochastic_01(p: Perm) -> bool:
    """Verify the permutation matrix has every row and column summing to 1."""
    m = perm_matrix(p)
    n = len(p)
    rows_ok = all(sum(m[i][j] for j in range(n)) == 1 for i in range(n))
    cols_ok = all(sum(m[i][j] for i in range(n)) == 1 for j in range(n))
    return rows_ok and cols_ok


def compose(a: Perm, b: Perm) -> Perm:
    """Composition (a after b): i -> a[b[i]]."""
    return tuple(a[b[i]] for i in range(len(a)))


def inverse(p: Perm) -> Perm:
    """Inverse permutation."""
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


# --------------------------------------------------------------------------------------
# Brualdi-Gibson adjacency: sigma^{-1} tau is a single cycle
# --------------------------------------------------------------------------------------

def cycle_type_nontrivial(p: Perm) -> List[int]:
    """Lengths (>= 2) of the nontrivial cycles of p."""
    n = len(p)
    seen = [False] * n
    lengths: List[int] = []
    for start in range(n):
        if seen[start]:
            continue
        length = 0
        j = start
        while not seen[j]:
            seen[j] = True
            j = p[j]
            length += 1
        if length >= 2:
            lengths.append(length)
    return lengths


def is_single_cycle(p: Perm) -> bool:
    """True iff p has exactly one nontrivial cycle (a single cycle)."""
    return len(cycle_type_nontrivial(p)) == 1


def adjacent(sigma: Perm, tau: Perm) -> bool:
    """Brualdi-Gibson edge criterion on the Birkhoff polytope."""
    if sigma == tau:
        return False
    return is_single_cycle(compose(inverse(sigma), tau))


# --------------------------------------------------------------------------------------
# Support, support union, and IsFaceVertexSet (support-closedness)
# --------------------------------------------------------------------------------------

def support(p: Perm) -> FrozenSet[Cell]:
    """Cells (i, p[i]) occupied by the permutation matrix."""
    return frozenset((i, p[i]) for i in range(len(p)))


def support_union(perms: List[Perm]) -> Set[Cell]:
    """Union of supports = the face-defining cell pattern."""
    u: Set[Cell] = set()
    for p in perms:
        u |= support(p)
    return u


def face_closure(n: int, perms: List[Perm]) -> Set[Perm]:
    """All permutations of [n] supported within the support union of `perms`."""
    u = support_union(perms)
    return {p for p in all_perms(n) if support(p) <= u}


def is_face_vertex_set(n: int, perms: List[Perm]) -> bool:
    """IsFaceVertexSet: the set equals its own support closure."""
    return set(perms) == face_closure(n, perms)


# --------------------------------------------------------------------------------------
# Cliques of the 1-skeleton and the clique-face property
# --------------------------------------------------------------------------------------

def all_cliques(n: int) -> List[List[Perm]]:
    """All cliques (pairwise-adjacent subsets) of the skeleton of B_n, sizes >= 1."""
    verts = all_perms(n)
    cliques: List[List[Perm]] = []
    for size in range(1, len(verts) + 1):
        for subset in combinations(verts, size):
            if all(adjacent(a, b) for a, b in combinations(subset, 2)):
                cliques.append(list(subset))
    return cliques


def has_clique_face_property(n: int, max_size: int = 3) -> Tuple[bool, List[Perm]]:
    """Search cliques up to `max_size` for a non-face; return (holds, witness_if_failed).

    Searching by increasing size and stopping at the first failure keeps the scan
    tractable: the obstruction (a transposition triangle) always appears at size 3,
    so a cap of 3 already certifies failure for every n >= 3, while n <= 2 has no
    cliques larger than its vertex count.
    """
    verts = all_perms(n)
    upper = min(max_size, len(verts))
    for size in range(1, upper + 1):
        for subset in combinations(verts, size):
            clique = list(subset)
            if all(adjacent(a, b) for a, b in combinations(clique, 2)):
                if not is_face_vertex_set(n, clique):
                    return False, clique
    return True, []


def perm_label(p: Perm) -> str:
    """Human-readable 1-indexed image tuple, with 'id' for the identity."""
    if all(p[i] == i for i in range(len(p))):
        return "id"
    return "(" + " ".join(str(p[i] + 1) for i in range(len(p))) + ")"


# --------------------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------------------

def demo_birkhoff_von_neumann() -> None:
    print("=" * 78)
    print("1. Birkhoff-von Neumann: permutation matrices are doubly stochastic")
    print("=" * 78)
    for n in (1, 2, 3):
        ok = all(is_doubly_stochastic_01(p) for p in all_perms(n))
        print(f"  n={n}: all {len(all_perms(n))} permutation matrices doubly stochastic -> {ok}")
    print()


def demo_skeleton_k6() -> None:
    print("=" * 78)
    print("2-3. Skeleton of B_3 via Brualdi-Gibson; it is the complete graph K_6")
    print("=" * 78)
    verts = all_perms(3)
    edges = [(a, b) for a, b in combinations(verts, 2) if adjacent(a, b)]
    full = len(verts) * (len(verts) - 1) // 2
    print(f"  vertices = {len(verts)} (= 3!),  edges = {len(edges)},  K_6 edges = {full}")
    print(f"  skeleton of B_3 is complete (K_6): {len(edges) == full}")
    print()


def demo_three_transpositions() -> None:
    print("=" * 78)
    print("4. The three-transposition counterexample (not_cliqueFace_fin_of_three)")
    print("=" * 78)
    n = 3
    t12: Perm = (1, 0, 2)  # (1 2)
    t13: Perm = (2, 1, 0)  # (1 3)
    t23: Perm = (0, 2, 1)  # (2 3)
    clique = [t12, t13, t23]
    print(f"  swaps: {[perm_label(p) for p in clique]}")
    print(f"  pairwise adjacent (clique): {all(adjacent(a, b) for a, b in combinations(clique, 2))}")
    u = support_union(clique)
    print(f"  support union has {len(u)} cells out of {n * n} (full grid: {len(u) == n * n})")
    idn: Perm = tuple(range(n))
    print(f"  identity supported inside the union: {support(idn) <= u}")
    closure = face_closure(n, clique)
    print(f"  smallest enclosing face has {len(closure)} vertices (clique has {len(clique)})")
    print(f"  IsFaceVertexSet(clique): {is_face_vertex_set(n, clique)}  <-- FALSE means not a face")
    print()


def demo_face_checks() -> None:
    print("=" * 78)
    print("5. IsFaceVertexSet across cliques: holds for n<=2, fails for n>=3")
    print("=" * 78)
    for n in (1, 2):
        ok = all(is_face_vertex_set(n, c) for c in all_cliques(n))
        print(f"  n={n}: every clique is a face vertex set -> {ok}")
    for n in (3, 4):
        t12 = tuple([1, 0] + list(range(2, n)))
        t13 = tuple([2, 1, 0] + list(range(3, n)))
        t23 = tuple([0, 2, 1] + list(range(3, n)))
        triangle = [t12, t13, t23]
        is_clq = all(adjacent(a, b) for a, b in combinations(triangle, 2))
        print(f"  n={n}: transposition triangle is a clique={is_clq}, "
              f"is a face={is_face_vertex_set(n, triangle)}")
    print()


def demo_main_iff() -> None:
    print("=" * 78)
    print("6. Main theorem birkhoff_cliqueFace_iff:  property  <=>  n <= 2")
    print("=" * 78)
    results: Dict[int, bool] = {}
    for n in (1, 2, 3, 4):
        holds, witness = has_clique_face_property(n)
        results[n] = holds
        tag = "HOLDS" if holds else "FAILS"
        extra = "" if holds else f"   witness clique = {[perm_label(p) for p in witness]}"
        print(f"  n={n}: clique-face property {tag}{extra}")
    print()
    verified = all((results[n] == (n <= 2)) for n in results)
    print(f"  Reproduces 'property <=> n <= 2' on n in {{1,2,3,4}}: {verified}")
    print()


def main() -> None:
    demo_birkhoff_von_neumann()
    demo_skeleton_k6()
    demo_three_transpositions()
    demo_face_checks()
    demo_main_iff()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
