"""
Numerical demonstrations for:

    Young Conjugation as a Measure-Preserving Klein Four-Group
    on the Natural Extension of the Triangle Map

This self-contained script verifies, numerically and combinatorially:

  1. The bridge identity  c in lambda'  <=>  swap(c) in lambda
     (Young conjugation is coordinate exchange at the cell level).

  2. The unit-square natural-extension model split into four half-open cells
     D1, D2, D3, D4, each of Lebesgue measure exactly 1/4.

  3. The three non-identity symmetries
         sigma (transpose)          (x, y) -> (y, x)
         tau   (point reflection)   (x, y) -> (1 - x, 1 - y)
         alpha (anti-transpose)     (x, y) -> (1 - y, 1 - x)
     are measure-preserving involutions permuting the four cells, and that
     {id, sigma, tau, alpha} is the Klein four-group (Z/2)^2.

No third-party dependencies are required (only the standard library).
"""

from __future__ import annotations

import random
from typing import Callable, Dict, List, Optional, Set, Tuple

Cell = Tuple[int, int]           # a Young-diagram cell (row, col), 0-indexed
Point = Tuple[float, float]      # a point of the unit square


# ---------------------------------------------------------------------------
# 1. Young diagrams and conjugation
# ---------------------------------------------------------------------------

def diagram_cells(partition: List[int]) -> Set[Cell]:
    """Return the set of cells (i, j) of the Young diagram of `partition`.

    `partition` is a weakly decreasing list of positive integers; row i has
    `partition[i]` cells in columns j = 0 .. partition[i]-1.
    """
    cells: Set[Cell] = set()
    for i, row_len in enumerate(partition):
        for j in range(row_len):
            cells.add((i, j))
    return cells


def conjugate_partition(partition: List[int]) -> List[int]:
    """Return the conjugate (transpose) partition via column counting."""
    if not partition:
        return []
    width = partition[0]
    return [sum(1 for r in partition if r > j) for j in range(width)]


def swap(c: Cell) -> Cell:
    """Coordinate exchange -- the cell-level action of Young conjugation."""
    return (c[1], c[0])


def verify_bridge_identity(partition: List[int], bound: int = 12) -> bool:
    """Check  c in lambda'  <=>  swap(c) in lambda  over an exhaustive grid."""
    lam = diagram_cells(partition)
    lam_conj = diagram_cells(conjugate_partition(partition))
    for i in range(bound):
        for j in range(bound):
            c = (i, j)
            lhs = c in lam_conj
            rhs = swap(c) in lam
            if lhs != rhs:
                return False
    return True


# ---------------------------------------------------------------------------
# 2. The four-cell natural-extension model
# ---------------------------------------------------------------------------

def classify_cell(p: Point) -> Optional[str]:
    """Classify a point of [0,1]^2 into D1, D2, D3 or D4 (half-open cells).

        D1 = [0,1/2) x [0,1/2)      (bottom-left,  diagonal)
        D2 = [0,1/2) x [1/2,1]      (top-left,     anti-diagonal)
        D3 = [1/2,1] x [1/2,1]      (top-right,    diagonal)
        D4 = [1/2,1] x [0,1/2)      (bottom-right, anti-diagonal)
    """
    x, y = p
    left = x < 0.5
    bottom = y < 0.5
    if left and bottom:
        return "D1"
    if left and not bottom:
        return "D2"
    if not left and not bottom:
        return "D3"
    if not left and bottom:
        return "D4"
    return None


# ---------------------------------------------------------------------------
# 3. The Klein four-group of symmetries
# ---------------------------------------------------------------------------

def identity(p: Point) -> Point:
    return p


def sigma(p: Point) -> Point:
    """Transpose: reflection across the main diagonal (== Young conjugation)."""
    x, y = p
    return (y, x)


def tau(p: Point) -> Point:
    """Point reflection through the center (1/2, 1/2)."""
    x, y = p
    return (1.0 - x, 1.0 - y)


def alpha(p: Point) -> Point:
    """Anti-transpose: reflection across the anti-diagonal (== sigma o tau)."""
    x, y = p
    return (1.0 - y, 1.0 - x)


GROUP: Dict[str, Callable[[Point], Point]] = {
    "id": identity, "sigma": sigma, "tau": tau, "alpha": alpha,
}


def cell_permutation(g: Callable[[Point], Point], samples: int = 20000,
                     seed: int = 0) -> Dict[str, str]:
    """Empirically determine how symmetry `g` permutes the four cells."""
    rng = random.Random(seed)
    mapping: Dict[str, str] = {}
    for _ in range(samples):
        x, y = rng.random(), rng.random()
        src = classify_cell((x, y))
        dst = classify_cell(g((x, y)))
        if src is not None and dst is not None:
            if src in mapping and mapping[src] != dst:
                mapping[src] = "MIXED"
            else:
                mapping.setdefault(src, dst)
    return mapping


def estimate_cell_masses(samples: int = 200000, seed: int = 1) -> Dict[str, float]:
    """Monte-Carlo estimate of vol(D_i); each should be ~ 1/4."""
    rng = random.Random(seed)
    counts: Dict[str, int] = {"D1": 0, "D2": 0, "D3": 0, "D4": 0}
    for _ in range(samples):
        cell = classify_cell((rng.random(), rng.random()))
        if cell is not None:
            counts[cell] += 1
    return {k: v / samples for k, v in counts.items()}


def compose(g: Callable[[Point], Point],
            h: Callable[[Point], Point]) -> Callable[[Point], Point]:
    return lambda p: g(h(p))


def group_table(seed: int = 2) -> Dict[Tuple[str, str], str]:
    """Identify each composite g o h with an element of the group by sampling."""
    rng = random.Random(seed)
    test_pts = [(rng.random(), rng.random()) for _ in range(200)]
    names = list(GROUP)
    table: Dict[Tuple[str, str], str] = {}
    for gn in names:
        for hn in names:
            comp = compose(GROUP[gn], GROUP[hn])
            match = "?"
            for cand in names:
                if all(
                    abs(comp(p)[0] - GROUP[cand](p)[0]) < 1e-9
                    and abs(comp(p)[1] - GROUP[cand](p)[1]) < 1e-9
                    for p in test_pts
                ):
                    match = cand
                    break
            table[(gn, hn)] = match
    return table


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("1. Bridge identity:  c in lambda'  <=>  swap(c) in lambda")
    print("=" * 70)
    for part in ([4, 2, 1], [3, 3, 1], [5, 1, 1, 1], [2, 2], [6, 4, 4, 2, 1]):
        conj = conjugate_partition(part)
        ok = verify_bridge_identity(part)
        print(f"  lambda={part!s:20}  lambda'={conj!s:20}  identity holds: {ok}")

    print("\n" + "=" * 70)
    print("2. Cell masses (Monte Carlo, each should be ~ 0.25)")
    print("=" * 70)
    for cell, mass in estimate_cell_masses().items():
        print(f"  vol({cell}) ~= {mass:.4f}")

    print("\n" + "=" * 70)
    print("3. Cell permutations induced by the symmetries")
    print("=" * 70)
    print("  Expected:")
    print("    sigma : D1->D1, D3->D3, D2<->D4   (fixes diagonal cells)")
    print("    tau   : D1<->D3, D2<->D4          (double transposition)")
    print("    alpha : D1<->D3, D2->D2, D4->D4   (fixes anti-diagonal cells)")
    print()
    for name in ("sigma", "tau", "alpha"):
        perm = cell_permutation(GROUP[name])
        pretty = ", ".join(f"{k}->{perm[k]}" for k in sorted(perm))
        print(f"    {name:6}: {pretty}")

    print("\n" + "=" * 70)
    print("4. Group table of {id, sigma, tau, alpha}  (Klein four-group)")
    print("=" * 70)
    table = group_table()
    names = list(GROUP)
    header = "        " + "".join(f"{n:>8}" for n in names)
    print(header)
    for gn in names:
        row = "".join(f"{table[(gn, hn)]:>8}" for hn in names)
        print(f"  {gn:>6} {row}")

    is_klein = all(table[(n, n)] == "id" for n in names) and \
        table[("sigma", "tau")] == "alpha" and \
        table[("tau", "sigma")] == "alpha"
    print(f"\n  Every element is an involution and sigma o tau = tau o sigma = alpha")
    print(f"  => group is the Klein four-group (Z/2)^2 : {is_klein}")


if __name__ == "__main__":
    main()
