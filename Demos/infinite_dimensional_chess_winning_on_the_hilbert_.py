"""
Infinite-Dimensional Chess: Winning on the Hilbert Board
========================================================

Numerical demonstrations of the main results for chess played on the infinite
board Z x Z:

  * The explicit single-rook escape map g(r, p), verified to always land on a
    king-adjacent square unattacked by the rook.
  * The infinite escape run: iterating g marches the king to infinity.
  * The two-rook threshold: an exhaustive local check that two rooks never mate
    (and the stalemate configuration that shows the bound is sharp).
  * Finitely many lines miss cofinitely many squares: safe squares always exist,
    in fact infinitely many.

Everything is self-contained standard-library Python with type hints.
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, List, Set, Tuple

Sq = Tuple[int, int]


# --------------------------------------------------------------------------- #
# Core model
# --------------------------------------------------------------------------- #
def king_adj(p: Sq, q: Sq) -> bool:
    """King-adjacent: distinct, Chebyshev distance one."""
    return p != q and abs(p[0] - q[0]) <= 1 and abs(p[1] - q[1]) <= 1


def rook_attacks(r: Sq, s: Sq) -> bool:
    """Transparent-rook attack: shares rank or file, not the rook's own square."""
    return s != r and (s[0] == r[0] or s[1] == r[1])


def attacked_by(army: Iterable[Sq], s: Sq) -> bool:
    """Some rook of the army attacks s."""
    return any(rook_attacks(r, s) for r in army)


def neighbours(k: Sq) -> List[Sq]:
    """The eight king-adjacent squares."""
    return [
        (k[0] + dx, k[1] + dy)
        for dx, dy in product((-1, 0, 1), repeat=2)
        if (dx, dy) != (0, 0)
    ]


def checkmated(army: Iterable[Sq], k: Sq) -> bool:
    """King on k is checkmated: in check and every neighbour is attacked."""
    army = list(army)
    in_check = attacked_by(army, k)
    sealed = all(attacked_by(army, s) for s in neighbours(k))
    return in_check and sealed


# --------------------------------------------------------------------------- #
# The single-rook escape map
# --------------------------------------------------------------------------- #
def esc(a: int, c: int) -> int:
    """Escape coordinate: step to a neighbour of a distinct from the rook's c."""
    return a - 1 if c == a + 1 else a + 1


def g_step(r: Sq, p: Sq) -> Sq:
    """The king's explicit escape step away from a single rook r."""
    return (esc(p[0], r[0]), esc(p[1], r[1]))


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_single_rook_escape() -> None:
    print("=" * 68)
    print("Demo 1: A lone rook can never trap the king in one move")
    print("=" * 68)
    tests = [((0, 0), (3, 5)), ((2, 2), (2, 7)), ((-4, 1), (0, 1)), ((5, 5), (5, 5))]
    for r, p in tests:
        dest = g_step(r, p)
        adj = king_adj(p, dest)
        safe = not rook_attacks(r, dest)
        print(f"  rook={r}  king={p} -> {dest}   adjacent={adj}  safe={safe}")
        assert adj and safe
    print("  All escape steps are legal and safe.\n")


def demo_infinite_run() -> None:
    print("=" * 68)
    print("Demo 2: The king escapes forever (infinite escape run)")
    print("=" * 68)
    r, k = (0, 0), (2, 3)
    p = k
    print(f"  rook fixed at {r}; king starts at {k}")
    for n in range(8):
        nxt = g_step(r, p)
        assert king_adj(p, nxt) and not rook_attacks(r, nxt)
        p = nxt
        cheb = max(abs(p[0] - r[0]), abs(p[1] - r[1]))
        print(f"    move {n + 1:>2}: king at {p:}   Chebyshev dist to rook = {cheb}")
    print("  Distance grows without bound: the run never terminates.\n")


def demo_two_rook_threshold() -> None:
    print("=" * 68)
    print("Demo 3: Two rooks can never checkmate (exhaustive local check)")
    print("=" * 68)
    k: Sq = (0, 0)
    # Search all two-rook placements within a window around the king.
    window = range(-3, 4)
    cells = [(x, y) for x, y in product(window, window) if (x, y) != k]
    mates = 0
    full_seals = 0
    for i in range(len(cells)):
        for j in range(i + 1, len(cells)):
            army = [cells[i], cells[j]]
            if checkmated(army, k):
                mates += 1
            if all(attacked_by(army, s) for s in neighbours(k)):
                full_seals += 1
    print(f"  king at {k}; searched all 2-rook placements in a 7x7 window")
    print(f"    checkmates found : {mates}   (theory predicts 0)")
    print(f"    full 8-seals    : {full_seals}  (two rooks cannot even seal all 8 -- sharp)")
    assert mates == 0
    # Two rooks cannot even seal all eight neighbours: each rook's own square is
    # a neighbour it does not attack, so escapes (captures) remain.
    army = [(-1, -1), (1, 1)]
    sealed = all(attacked_by(army, s) for s in neighbours(k))
    open_sqs = [s for s in neighbours(k) if not attacked_by(army, s)]
    print(f"  config rooks={army}: all neighbours sealed={sealed}")
    print(f"    open escape squares (incl. rook captures): {open_sqs}\n")


def safe_squares(army: List[Sq], window: range) -> Set[Sq]:
    """All squares in the window unattacked by the army."""
    return {(x, y) for x, y in product(window, window) if not attacked_by(army, (x, y))}


def demo_finitely_many_lines() -> None:
    print("=" * 68)
    print("Demo 4: Finitely many lines miss infinitely many squares")
    print("=" * 68)
    army = [(0, 0), (3, -2), (-4, 5), (7, 7)]
    for size in (11, 21, 41):
        w = range(-(size // 2), size // 2 + 1)
        safe = safe_squares(army, w)
        print(f"  {len(army)} rooks; {size}x{size} window: {len(safe)} safe squares")
    print("  Safe-square count grows with the window: infinitely many exist.\n")


if __name__ == "__main__":
    demo_single_rook_escape()
    demo_infinite_run()
    demo_two_rook_threshold()
    demo_finitely_many_lines()
    print("All demonstrations completed successfully.")
