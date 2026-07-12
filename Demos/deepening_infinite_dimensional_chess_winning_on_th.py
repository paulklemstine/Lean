"""
Winning on the Hilbert Board: King Escape in Every Dimension
============================================================

Numerical demonstrations of the lone-rook fortress on the d-dimensional
board Z^{d+2}. Everything below is self-contained standard-library Python.

Model (all coordinates are integers):
  * A "square" is a tuple of `dim` integers.
  * Squares p, q are KING-ADJACENT when p != q and |p_i - q_i| <= 1 for all i
    (the punctured Chebyshev unit ball; 3^dim - 1 neighbours).
  * A rook at r ATTACKS s when s != r and s agrees with r in all-but-one
    coordinate (r sweeps one axis-parallel line).
  * An army R checkmates the king at k when R attacks k and attacks every
    king-adjacent square.

Key results demonstrated:
  1. king_escape_step: an explicit safe king move against a lone rook.
  2. escape_run: iterating it gives an infinite (here: arbitrarily long) run.
  3. find_safe_square: any finite army leaves an unattacked square.
  4. no lone-rook mate in dimension >= 2.
  5. two rooks mate on the one-dimensional line (the boundary case).
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, List, Optional, Sequence, Tuple

Square = Tuple[int, ...]


# ----------------------------------------------------------------------
# Core model
# ----------------------------------------------------------------------

def king_adjacent(p: Square, q: Square) -> bool:
    """True iff q is a legal king move from p (Chebyshev distance exactly 1)."""
    if p == q:
        return False
    return all(abs(a - b) <= 1 for a, b in zip(p, q))


def rook_attacks(r: Square, s: Square) -> bool:
    """True iff a rook on r attacks s: s != r and they agree in all but one axis."""
    if s == r:
        return False
    disagreements = sum(1 for a, b in zip(r, s) if a != b)
    return disagreements == 1


def attacked_by(army: Sequence[Square], s: Square) -> bool:
    """True iff some rook of `army` attacks square s."""
    return any(rook_attacks(r, s) for r in army)


def neighbours(p: Square) -> List[Square]:
    """All 3^dim - 1 king-adjacent squares of p."""
    result: List[Square] = []
    for delta in product((-1, 0, 1), repeat=len(p)):
        if all(d == 0 for d in delta):
            continue
        result.append(tuple(a + d for a, d in zip(p, delta)))
    return result


def checkmated(army: Sequence[Square], k: Square) -> bool:
    """True iff army delivers checkmate to the king at k."""
    if not attacked_by(army, k):
        return False
    return all(attacked_by(army, s) for s in neighbours(k))


# ----------------------------------------------------------------------
# 1-2. The explicit escape map and infinite run
# ----------------------------------------------------------------------

def esc_coord(a: int, c: int) -> int:
    """One-coordinate escape: step away from the rook coordinate c.

    Lands on a-1 or a+1, never equal to a, never equal to c.
    """
    return a - 1 if c == a + 1 else a + 1


def king_escape_step(rook: Square, king: Square) -> Square:
    """The explicit safe king step g(r, p): move away in EVERY coordinate."""
    return tuple(esc_coord(p_i, r_i) for p_i, r_i in zip(king, rook))


def escape_run(rook: Square, king: Square, steps: int) -> List[Square]:
    """Iterate the escape step to produce a legal, never-in-check king run."""
    run = [king]
    current = king
    for _ in range(steps):
        current = king_escape_step(rook, current)
        run.append(current)
    return run


# ----------------------------------------------------------------------
# 3. Finitely many rooks leave a safe square
# ----------------------------------------------------------------------

def find_safe_square(army: Sequence[Square], dim: int) -> Square:
    """Return a square unattacked by the finite `army`.

    Pick x avoiding all first coordinates and y avoiding all second
    coordinates; the square (x, y, 0, ..., 0) disagrees with every rook in
    TWO axes, so no single axis-line can reach it.
    """
    used_x = {r[0] for r in army}
    used_y = {r[1] for r in army}
    x = next(t for t in range(0, len(used_x) + 1) if t not in used_x)
    y = next(t for t in range(0, len(used_y) + 1) if t not in used_y)
    return (x, y) + (0,) * (dim - 2)


# ----------------------------------------------------------------------
# 5. The one-dimensional boundary
# ----------------------------------------------------------------------

def rook_attacks_line(r: int, s: int) -> bool:
    """On Z, a rook attacks every square except its own."""
    return s != r


def checkmated_line(army: Sequence[int], k: int) -> bool:
    """Checkmate on the 1-D line Z."""
    if not any(rook_attacks_line(r, k) for r in army):
        return False
    for s in (k - 1, k + 1):
        if not any(rook_attacks_line(r, s) for r in army):
            return False
    return True


# ----------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------

def demo_escape(dim: int, rook: Square, king: Square) -> None:
    print(f"[dim {dim}]  rook={rook}  king={king}")
    step = king_escape_step(rook, king)
    print(f"  escape step -> {step}")
    print(f"    king-adjacent to king?  {king_adjacent(king, step)}")
    print(f"    attacked by rook?       {rook_attacks(rook, step)}  (want False)")


def demo_run(dim: int, rook: Square, king: Square, steps: int) -> None:
    run = escape_run(rook, king, steps)
    ok = all(
        king_adjacent(run[n], run[n + 1]) and not rook_attacks(rook, run[n + 1])
        for n in range(len(run) - 1)
    )
    print(f"[dim {dim}]  {steps}-move escape run legal and never in check?  {ok}")
    print(f"    trajectory: {run}")


def demo_safe_square(dim: int, army: Sequence[Square]) -> None:
    s = find_safe_square(army, dim)
    print(f"[dim {dim}]  army of {len(army)} rooks -> safe square {s}")
    print(f"    attacked by army?  {attacked_by(army, s)}  (want False)")


def demo_no_lone_mate(dim: int, rook: Square, king: Square) -> None:
    print(f"[dim {dim}]  lone rook {rook} checkmates king {king}?  "
          f"{checkmated([rook], king)}  (want False)")


def demo_line_mate(k: int) -> None:
    army = [k - 1, k + 1]
    print(f"[dim 1]  rooks {army} checkmate king at {k}?  "
          f"{checkmated_line(army, k)}  (want True)")


def main() -> None:
    print("=" * 68)
    print("1. Explicit one-move escape against a lone rook (every dimension)")
    print("=" * 68)
    demo_escape(2, (0, 0), (0, 0))
    demo_escape(3, (5, -2, 7), (1, 1, 1))
    demo_escape(5, (0, 0, 0, 0, 0), (2, 2, 2, 2, 2))

    print("\n" + "=" * 68)
    print("2. The infinite escape run (shown to 6 moves)")
    print("=" * 68)
    demo_run(2, (0, 0), (0, 0), 6)
    demo_run(3, (1, 1, 1), (0, 0, 0), 6)

    print("\n" + "=" * 68)
    print("3. Any finite army leaves an unattacked square")
    print("=" * 68)
    demo_safe_square(2, [(0, 0), (1, 3), (2, -1), (5, 5)])
    demo_safe_square(3, [(0, 0, 0), (1, 1, 1), (2, 2, 2), (0, 1, 2)])

    print("\n" + "=" * 68)
    print("4. A lone rook never checkmates (dimension >= 2)")
    print("=" * 68)
    demo_no_lone_mate(2, (0, 0), (0, 0))
    demo_no_lone_mate(3, (4, 4, 4), (1, 2, 3))

    print("\n" + "=" * 68)
    print("5. Boundary: two rooks DO mate on the one-dimensional line")
    print("=" * 68)
    demo_line_mate(0)
    demo_line_mate(7)


if __name__ == "__main__":
    main()
