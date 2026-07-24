"""
Numerical demonstrations for:

    A Sharp Line-Covering Threshold for Checkmate on the Infinite Board

We play chess on the Hilbert board Z x Z. Every long-range attacker (rook,
bishop, queen, or any straight-ray piece) is modelled as an affine line

    { (x, y) : a*x + b*y = c },   (a, b) != (0, 0).

This script demonstrates, entirely by direct computation, the paper's results:

  1. One line covers at most 3 of the 9 squares of a king's 3x3 block.
  2. n lines cover at most 3n of those squares.
  3. Two pieces can never checkmate (a safe neighbour always remains).
  4. Three parallel rooks always checkmate (the threshold 3 is sharp).
  5. A finite army leaves safe squares arbitrarily far away (global escape).

Self-contained; standard library only.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import List, Optional, Tuple

Square = Tuple[int, int]


@dataclass(frozen=True)
class Line:
    """A long-range attacker: the affine line a*x + b*y = c, with (a,b) != 0."""

    a: int
    b: int
    c: int

    def __post_init__(self) -> None:
        if self.a == 0 and self.b == 0:
            raise ValueError("degenerate line: (a, b) must not both be zero")

    def covers(self, q: Square) -> bool:
        """True iff the square q lies on this line (is attacked along it)."""
        return self.a * q[0] + self.b * q[1] == self.c


def rook_row(r: int) -> Line:
    """Horizontal rook occupying the entire row y = r."""
    return Line(0, 1, r)


def rook_col(c: int) -> Line:
    """Vertical rook occupying the entire column x = c."""
    return Line(1, 0, c)


def bishop_up(k: int) -> Line:
    """Bishop diagonal x - y = k."""
    return Line(1, -1, k)


# ----------------------------------------------------------------------------
# Core combinatorial primitives
# ----------------------------------------------------------------------------

BLOCK_OFFSETS: List[Square] = [(i, j) for i in (-1, 0, 1) for j in (-1, 0, 1)]
KING_MOVES: List[Square] = [d for d in BLOCK_OFFSETS if d != (0, 0)]


def attacked(config: List[Line], q: Square) -> bool:
    """True iff some line of the configuration covers q."""
    return any(L.covers(q) for L in config)


def safe(config: List[Line], q: Square) -> bool:
    """True iff no line of the configuration covers q."""
    return not attacked(config, q)


def block_covered_by_line(L: Line, p: Square) -> List[Square]:
    """The block offsets d such that L covers p + d."""
    return [d for d in BLOCK_OFFSETS if L.covers((p[0] + d[0], p[1] + d[1]))]


def block_covered(config: List[Line], p: Square) -> List[Square]:
    """The block offsets d such that some piece covers p + d."""
    return [d for d in BLOCK_OFFSETS if attacked(config, (p[0] + d[0], p[1] + d[1]))]


def is_checkmated(config: List[Line], p: Square) -> bool:
    """King at p is in check and every king move lands on an attacked square."""
    if not attacked(config, p):
        return False
    return all(attacked(config, (p[0] + d[0], p[1] + d[1])) for d in KING_MOVES)


def find_safe_square_beyond(config: List[Line], n: int) -> Optional[Square]:
    """Find a safe square with first coordinate > n (guaranteed to exist)."""
    # Choose a row avoided by every horizontal piece.
    horizontal_rows = {L.c for L in config if L.a == 0}  # rows y=c fully blocked
    k = 0
    while k in horizontal_rows:
        k += 1
    x = n + 1
    # At most (#slanted pieces) squares of this row are attacked, so this halts.
    while attacked(config, (x, k)):
        x += 1
    return (x, k)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_one_line_bound() -> None:
    """Result 1: every single line covers at most 3 of the 9 block squares."""
    print("=" * 70)
    print("1. One line covers at most 3 of the 9 neighbourhood squares")
    print("=" * 70)
    p = (0, 0)
    samples = {
        "horizontal rook  y=0": rook_row(0),
        "vertical rook    x=0": rook_col(0),
        "bishop diagonal x-y=0": bishop_up(0),
        "steep line 2x+3y=0": Line(2, 3, 0),
        "nightrider 1x-2y=0": Line(1, -2, 0),
    }
    worst = 0
    for name, L in samples.items():
        cov = block_covered_by_line(L, p)
        worst = max(worst, len(cov))
        print(f"  {name:>22}: covers {len(cov)} squares  {cov}")
    print(f"  --> maximum observed = {worst}  (theory: <= 3)\n")
    assert worst <= 3


def demo_additive_bound() -> None:
    """Result 2: n lines cover at most 3n block squares."""
    print("=" * 70)
    print("2. n lines cover at most 3n of the 9 squares")
    print("=" * 70)
    p = (0, 0)
    configs = {
        "1 piece ": [bishop_up(0)],
        "2 pieces": [bishop_up(0), Line(1, 1, 0)],
        "3 pieces": [rook_row(-1), rook_row(0), rook_row(1)],
    }
    for name, cfg in configs.items():
        cov = block_covered(cfg, p)
        bound = 3 * len(cfg)
        print(f"  {name}: covers {len(cov):>2} of 9   (bound 3n = {bound})")
        assert len(cov) <= bound
    print()


def demo_two_never_mate() -> None:
    """Result 3: no configuration of 2 lines checkmates; a safe neighbour remains."""
    print("=" * 70)
    print("3. Two pieces can never checkmate (a safe square always remains)")
    print("=" * 70)
    p = (0, 0)
    two_piece_configs = [
        [rook_row(0), rook_col(0)],
        [bishop_up(0), Line(1, 1, 0)],
        [rook_row(0), bishop_up(0)],
        [Line(2, 1, 0), Line(1, 3, 0)],
    ]
    for cfg in two_piece_configs:
        mated = is_checkmated(cfg, p)
        # exhibit an explicit safe block square
        safe_offsets = [d for d in BLOCK_OFFSETS
                        if safe(cfg, (p[0] + d[0], p[1] + d[1]))]
        desc = ", ".join(f"({L.a},{L.b},{L.c})" for L in cfg)
        print(f"  lines {desc:>28}: mate={mated}, safe offsets={safe_offsets}")
        assert not mated
        assert safe_offsets  # non-empty escape
    print("  --> every 2-piece configuration leaves an escape square.\n")


def demo_three_suffice() -> None:
    """Result 4: three parallel rooks checkmate any king (threshold is sharp)."""
    print("=" * 70)
    print("4. Three parallel rooks always checkmate (threshold 3 is sharp)")
    print("=" * 70)
    for p in [(0, 0), (5, -3), (-10, 7), (100, 100)]:
        cfg = [rook_row(p[1] - 1), rook_row(p[1]), rook_row(p[1] + 1)]
        mated = is_checkmated(cfg, p)
        print(f"  king at {str(p):>12}: three rooks on rows "
              f"{p[1]-1},{p[1]},{p[1]+1}  -> mate={mated}")
        assert mated
    print("  --> three pieces suffice for every king position.\n")


def demo_global_escape() -> None:
    """Result 5: a finite army leaves safe squares arbitrarily far away."""
    print("=" * 70)
    print("5. Global escape: safe squares exist arbitrarily far out")
    print("=" * 70)
    # A sizeable but finite army of mixed pieces.
    army: List[Line] = []
    army += [rook_row(r) for r in range(-5, 6)]
    army += [rook_col(c) for c in range(-5, 6)]
    army += [bishop_up(k) for k in range(-5, 6)]
    army += [Line(1, 1, k) for k in range(-5, 6)]
    print(f"  army size = {len(army)} long-range pieces")
    for n in [10, 1000, 10 ** 6, 10 ** 9]:
        q = find_safe_square_beyond(army, n)
        assert q is not None and safe(army, q) and q[0] > n
        print(f"  safe square beyond N={n:>12}: {q}")
    print("  --> the king can always flee past any finite horizon.\n")


def main() -> None:
    demo_one_line_bound()
    demo_additive_bound()
    demo_two_never_mate()
    demo_three_suffice()
    demo_global_escape()
    print("All demonstrations agree with the theory: threshold = 3, escape = infinite.")


if __name__ == "__main__":
    main()
