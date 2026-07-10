"""
Numerical demonstrations for:

    Conservation, Boundary Topology, and Symmetry in Jigsaw Assembly

Every piece is modelled by the shapes on its four edges, each of which is one of
three values: 'flat', 'tab', or 'blank'. Two edges interlock when they are
complementary (tab <-> blank; flat is self-complementary and only appears on the
outer border). We assign a signed potential w(tab) = +1, w(blank) = -1,
w(flat) = 0, and demonstrate:

  1. Complementation negates the potential.
  2. The telescoping conservation law: valid rows and rectangles have total
     potential zero, so exposed tabs balance exposed blanks.
  3. Corner pieces of a valid grid are doubly flat.
  4. The handshake identity 2*(interior interfaces) + (border edges) = 4*(pieces).
  5. The interlocking symmetry group is Z/2 (exactly two edge-relabellings
     commute with complementation).

Run with:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations
from typing import Callable, Dict, List, Tuple

Edge = str  # one of 'flat', 'tab', 'blank'
EDGES: Tuple[Edge, ...] = ("flat", "tab", "blank")


def comp(e: Edge) -> Edge:
    """Complementation involution: swaps tab and blank, fixes flat."""
    return {"flat": "flat", "tab": "blank", "blank": "tab"}[e]


def wt(e: Edge) -> int:
    """Signed edge potential: tab -> +1, blank -> -1, flat -> 0."""
    return {"flat": 0, "tab": 1, "blank": -1}[e]


def enc(b: bool) -> Edge:
    """Truth encoding: True -> tab (+1), False -> blank (-1)."""
    return "tab" if b else "blank"


@dataclass(frozen=True)
class Piece:
    """A puzzle piece described by its (top, right, bottom, left) edges."""
    top: Edge
    right: Edge
    bottom: Edge
    left: Edge

    def edges(self) -> Tuple[Edge, Edge, Edge, Edge]:
        return (self.top, self.right, self.bottom, self.left)

    def potential(self) -> int:
        return sum(wt(e) for e in self.edges())


# ---------------------------------------------------------------------------
# 1. Complementation negates the potential; potential detects the boundary.
# ---------------------------------------------------------------------------
def check_edge_algebra() -> None:
    print("=" * 68)
    print("1. Edge algebra: complementation negates potential")
    print("=" * 68)
    for e in EDGES:
        print(f"   e = {e:6s}  w(e) = {wt(e):+d}   "
              f"comp(e) = {comp(e):6s}  w(comp e) = {wt(comp(e)):+d}   "
              f"(-w(e) = {-wt(e):+d})")
        assert wt(comp(e)) == -wt(e)
        assert (wt(e) == 0) == (e == "flat")
        assert comp(comp(e)) == e  # involution
    print("   -> w(comp e) = -w(e), and w(e)=0 iff e=flat.  [verified]\n")


# ---------------------------------------------------------------------------
# 2. Rows and the 1D conservation law.
# ---------------------------------------------------------------------------
def row_is_valid(row: List[Piece]) -> bool:
    """A row is valid: flat top/bottom on every piece, flat far-left/far-right,
    and each interior left edge complements the previous right edge."""
    n = len(row)
    if n == 0:
        return True
    if any(p.top != "flat" or p.bottom != "flat" for p in row):
        return False
    if row[0].left != "flat" or row[-1].right != "flat":
        return False
    return all(row[i + 1].left == comp(row[i].right) for i in range(n - 1))


def count_tabs(pieces: List[Piece]) -> int:
    return sum(e == "tab" for p in pieces for e in p.edges())


def count_blanks(pieces: List[Piece]) -> int:
    return sum(e == "blank" for p in pieces for e in p.edges())


def build_valid_row(interior_rights: List[Edge]) -> List[Piece]:
    """Build a valid row realising a chosen sequence of interior right-edges.

    Piece i has right edge r_i (last piece's right forced flat) and left edge
    complementing the previous right edge (first piece's left is flat).
    """
    n = len(interior_rights) + 1
    rights = interior_rights + ["flat"]
    lefts = ["flat"] + [comp(r) for r in interior_rights]
    return [Piece("flat", rights[i], "flat", lefts[i]) for i in range(n)]


def check_row_conservation() -> None:
    print("=" * 68)
    print("2. Row conservation: exposed tabs balance exposed blanks")
    print("=" * 68)
    samples = [
        ["tab"],
        ["tab", "blank", "tab"],
        [enc(b) for b in (True, False, False, True, True)],
    ]
    for interior in samples:
        row = build_valid_row(interior)
        pot = sum(p.potential() for p in row)
        t, b = count_tabs(row), count_blanks(row)
        assert row_is_valid(row)
        assert pot == 0 and t == b
        print(f"   {len(row)}-piece row, interior rights={interior}")
        print(f"      total potential = {pot},  tabs = {t},  blanks = {b}  "
              f"-> balanced\n")


# ---------------------------------------------------------------------------
# 3 & 4. Grids: conservation, corner flatness, handshake identity.
# ---------------------------------------------------------------------------
def build_valid_grid(rows: int, cols: int,
                     h: Callable[[int, int], Edge],
                     v: Callable[[int, int], Edge]) -> List[List[Piece]]:
    """Build a valid rows x cols grid from chosen interior interface shapes.

    h(i, j) is the right edge of cell (i, j) for j < cols-1 (horizontal seam);
    v(i, j) is the bottom edge of cell (i, j) for i < rows-1 (vertical seam).
    Border edges are forced flat; interior neighbours complement each other.
    """
    grid: List[List[Piece]] = []
    for i in range(rows):
        line: List[Piece] = []
        for j in range(cols):
            top = "flat" if i == 0 else comp(v(i - 1, j))
            bottom = "flat" if i == rows - 1 else v(i, j)
            left = "flat" if j == 0 else comp(h(i, j - 1))
            right = "flat" if j == cols - 1 else h(i, j)
            line.append(Piece(top, right, bottom, left))
        grid.append(line)
    return grid


def grid_is_valid(grid: List[List[Piece]]) -> bool:
    rows, cols = len(grid), len(grid[0]) if grid else 0
    for j in range(cols):
        if grid[0][j].top != "flat" or grid[rows - 1][j].bottom != "flat":
            return False
    for i in range(rows):
        if grid[i][0].left != "flat" or grid[i][cols - 1].right != "flat":
            return False
    for i in range(rows):
        for j in range(cols):
            if j + 1 < cols and grid[i][j + 1].left != comp(grid[i][j].right):
                return False
            if i + 1 < rows and grid[i + 1][j].top != comp(grid[i][j].bottom):
                return False
    return True


def check_grid_conservation() -> None:
    print("=" * 68)
    print("3. Grid conservation, corner flatness, handshake identity")
    print("=" * 68)
    rows, cols = 3, 4
    # Arbitrary interior interface choices (tab/blank), deterministically mixed.
    h = lambda i, j: "tab" if (i + j) % 2 == 0 else "blank"
    v = lambda i, j: "blank" if (i * j) % 2 == 0 else "tab"
    grid = build_valid_grid(rows, cols, h, v)
    flat_pieces = [p for line in grid for p in line]

    assert grid_is_valid(grid)
    total = sum(p.potential() for p in flat_pieces)
    t, b = count_tabs(flat_pieces), count_blanks(flat_pieces)
    assert total == 0 and t == b
    print(f"   {rows}x{cols} grid: total potential = {total}, "
          f"tabs = {t}, blanks = {b}  -> balanced")

    corners = [grid[0][0], grid[0][cols - 1],
               grid[rows - 1][0], grid[rows - 1][cols - 1]]
    for c in corners:
        flats = sum(e == "flat" for e in c.edges())
        assert flats >= 2
    print("   every corner piece exposes >= 2 flat edges  [verified]")

    # Handshake identity with rows = r+1, cols = c+1.
    r, c = rows - 1, cols - 1
    interior = (r + 1) * c + r * (c + 1)
    border = 2 * ((r + 1) + (c + 1))
    pieces = (r + 1) * (c + 1)
    assert 2 * interior + border == 4 * pieces
    print(f"   handshake: 2*{interior} + {border} = {2*interior+border} "
          f"= 4*{pieces}  [verified]\n")


# ---------------------------------------------------------------------------
# 5. The interlocking symmetry group is Z/2.
# ---------------------------------------------------------------------------
def commutes_with_comp(sigma: Dict[Edge, Edge]) -> bool:
    return all(sigma[comp(e)] == comp(sigma[e]) for e in EDGES)


def preserves_fitting(sigma: Dict[Edge, Edge]) -> bool:
    """sigma preserves 'a fits b' <=> b == comp(a) for all a, b."""
    for a in EDGES:
        for b in EDGES:
            lhs = (b == comp(a))
            rhs = (sigma[b] == comp(sigma[a]))
            if lhs != rhs:
                return False
    return True


def check_symmetry_group() -> None:
    print("=" * 68)
    print("4. Symmetry group of interlocking is Z/2")
    print("=" * 68)
    commuting = []
    for perm in permutations(EDGES):
        sigma = dict(zip(EDGES, perm))
        c = commutes_with_comp(sigma)
        assert c == preserves_fitting(sigma)  # the characterization theorem
        if c:
            commuting.append(sigma)
    print(f"   permutations of edge alphabet: {len(list(permutations(EDGES)))}")
    print(f"   permutations commuting with complementation: {len(commuting)}")
    for sigma in commuting:
        print("      ", {k: v for k, v in sigma.items()})
    assert len(commuting) == 2
    print("   -> automorphism group has order 2 (identity + tab<->blank).  "
          "[verified]\n")


def main() -> None:
    check_edge_algebra()
    check_row_conservation()
    check_grid_conservation()
    check_symmetry_group()
    print("All demonstrations verified successfully.")


if __name__ == "__main__":
    main()
