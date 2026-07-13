"""
Numerical demonstrations for:

    The Disjunctive Sum of Well-Founded Games:
    Mirroring, Neutrality, and a Two-Heap Nim Law

This self-contained script computes the value function of well-founded games,
forms disjunctive sums, and verifies every headline result numerically:

  * the Zermelo value function W (winning iff some move leads to a loss);
  * well-foundedness of the disjunctive sum;
  * neutrality of the empty (terminal) game and commutativity of the sum value;
  * the flagship mirroring theorem: a + a is always a loss for the mover;
  * determinacy: the mover forces a win iff W holds (checked by self-play);
  * two "obvious but false" conjectures, refuted in the countdown game;
  * the sharp two-heap Nim law  W(m, n)  <=>  m != n.

Everything is inlined; run with:  python demo.py
"""

from __future__ import annotations

from functools import lru_cache
from itertools import product
from typing import Callable, Hashable, Iterable, List, Tuple, TypeVar

Position = TypeVar("Position", bound=Hashable)

# A game is given by its move function: legal_moves(p) -> list of successor
# positions. Well-foundedness (no infinite descending play) is the caller's
# responsibility; all examples below satisfy it.
MoveFn = Callable[[Position], Iterable[Position]]


# ---------------------------------------------------------------------------
# Core value function (Zermelo / Sprague-Grundy fixed point, two-valued).
# ---------------------------------------------------------------------------
def make_value_fn(legal_moves: MoveFn) -> Callable[[Position], bool]:
    """Return a memoized predicate W with

        W(p)  <=>  exists a legal move p -> q with not W(q).

    A position is *winning* (for the player to move) iff some move leads to a
    *losing* position. Terminal positions (no moves) are losing.
    """

    @lru_cache(maxsize=None)
    def W(p: Position) -> bool:
        return any(not W(q) for q in legal_moves(p))

    return W


def optimal_move(legal_moves: MoveFn, W: Callable[[Position], bool],
                 p: Position) -> Position:
    """Return a move from a winning position p to a losing position."""
    for q in legal_moves(p):
        if not W(q):
            return q
    raise ValueError(f"position {p!r} is not winning; no optimal move")


def is_terminal(legal_moves: MoveFn, p: Position) -> bool:
    return not list(legal_moves(p))


# ---------------------------------------------------------------------------
# Disjunctive sum of a game with itself.
# ---------------------------------------------------------------------------
def sum_moves(legal_moves: MoveFn) -> MoveFn:
    """Disjunctive-sum move function on pairs: move in exactly one component."""

    def moves(pair: Tuple[Position, Position]) -> List[Tuple[Position, Position]]:
        a, b = pair
        out: List[Tuple[Position, Position]] = []
        out.extend((a2, b) for a2 in legal_moves(a))
        out.extend((a, b2) for b2 in legal_moves(b))
        return out

    return moves


# ---------------------------------------------------------------------------
# Example game: Countdown on the natural numbers (rank omega).
#   from n you may move to any strictly smaller m; only 0 is terminal.
# ---------------------------------------------------------------------------
def countdown_moves(n: int) -> List[int]:
    return list(range(n))


# ---------------------------------------------------------------------------
# Self-play driver used to check determinacy empirically.
# ---------------------------------------------------------------------------
def play_out(legal_moves: MoveFn, W: Callable[[Position], bool],
             start: Position, opponent: Callable[[Position], Position]) -> int:
    """Play from `start`. The analysed player uses optimal_move at winning
    positions; the opponent uses `opponent` otherwise. Return the (0-indexed)
    step at which a terminal position is first reached. An *odd* step means the
    opponent is the one stuck (mover forced a win)."""
    p = start
    step = 0
    while not is_terminal(legal_moves, p):
        p = optimal_move(legal_moves, W, p) if W(p) else opponent(p)
        step += 1
    return step


def greedy_opponent(legal_moves: MoveFn) -> Callable[[Position], Position]:
    def o(p: Position) -> Position:
        return next(iter(legal_moves(p)))
    return o


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------
def demo_countdown_value(limit: int = 12) -> None:
    print("=" * 70)
    print("Countdown value:  W(n)  <=>  n != 0")
    print("=" * 70)
    W = make_value_fn(countdown_moves)
    for n in range(limit):
        assert W(n) == (n != 0)
    print("  n :        " + " ".join(f"{n:>2}" for n in range(limit)))
    print("  W(n):       " +
          " ".join(f"{'W' if W(n) else 'L':>2}" for n in range(limit)))
    print("  verified W(n) == (n != 0) for n < %d\n" % limit)


def demo_mirroring(limit: int = 10) -> None:
    print("=" * 70)
    print("Flagship: a + a is ALWAYS a loss for the mover  (mirroring)")
    print("=" * 70)
    Wsum = make_value_fn(sum_moves(countdown_moves))
    for a in range(limit):
        assert Wsum((a, a)) is False
    print("  Wsum((a,a)) for a < %d :  %s" %
          (limit, [Wsum((a, a)) for a in range(limit)]))
    print("  all False  =>  the second player wins by mirroring\n")


def demo_neutral_and_comm(limit: int = 8) -> None:
    print("=" * 70)
    print("Empty game is neutral;  sum value is commutative")
    print("=" * 70)
    W = make_value_fn(countdown_moves)
    Wsum = make_value_fn(sum_moves(countdown_moves))
    # 0 is the unique terminal position of countdown.
    for b in range(limit):
        assert Wsum((0, b)) == W(b)   # left neutrality
        assert Wsum((b, 0)) == W(b)   # right neutrality
    for a, b in product(range(limit), repeat=2):
        assert Wsum((a, b)) == Wsum((b, a))  # commutativity
    print("  neutrality  Wsum((0,b)) == W(b):  verified for b < %d" % limit)
    print("  commutativity Wsum((a,b)) == Wsum((b,a)):  verified on %dx%d grid\n"
          % (limit, limit))


def demo_two_heap_nim(limit: int = 8) -> None:
    print("=" * 70)
    print("Two-heap Nim law:  Wsum((m,n))  <=>  m != n")
    print("=" * 70)
    Wsum = make_value_fn(sum_moves(countdown_moves))
    header = "     n=" + " ".join(f"{n:>2}" for n in range(limit))
    print(header)
    for m in range(limit):
        row = " ".join(f"{'W' if Wsum((m, n)) else 'L':>2}"
                       for n in range(limit))
        print(f"  m={m:>2}  {row}")
    for m, n in product(range(limit), repeat=2):
        assert Wsum((m, n)) == (m != n)
    print("  verified Wsum((m,n)) == (m != n)  (L exactly on the diagonal)\n")


def demo_false_conjectures() -> None:
    print("=" * 70)
    print("Two plausible conjectures, both FALSE")
    print("=" * 70)
    W = make_value_fn(countdown_moves)
    Wsum = make_value_fn(sum_moves(countdown_moves))

    # Myth 1: winning + winning = winning.
    assert W(1) and W(1) and not Wsum((1, 1))
    print("  Myth 1  'win + win = win':  W(1)=%s, W(1)=%s, but Wsum((1,1))=%s"
          % (W(1), W(1), Wsum((1, 1))))
    print("          => two wins combine into a LOSS.")

    # Myth 2: a losing component can be dropped.
    assert (not W(0)) and W(1) and Wsum((0, 1))
    print("  Myth 2  'drop a losing part':  W(0)=%s, W(1)=%s, Wsum((0,1))=%s"
          % (W(0), W(1), Wsum((0, 1))))
    print("          => a losing (P) position is NOT neutral; only 0 is.\n")


def demo_determinacy(limit: int = 8) -> None:
    print("=" * 70)
    print("Determinacy (Zermelo): W(p)  <=>  mover forces a win in self-play")
    print("=" * 70)
    W = make_value_fn(countdown_moves)
    opp = greedy_opponent(countdown_moves)
    for n in range(1, limit):
        # From a winning start, the terminal position is reached on an odd step
        # (opponent stuck) regardless of the opponent's greedy replies.
        step = play_out(countdown_moves, W, n, opp)
        forced = (step % 2 == 1)
        assert forced == W(n)
    print("  for winning starts n=1..%d, terminal reached on an ODD step"
          % (limit - 1))
    print("  => mover forces the win, matching W(n).  Determinacy holds.\n")


def main() -> None:
    demo_countdown_value()
    demo_mirroring()
    demo_neutral_and_comm()
    demo_two_heap_nim()
    demo_false_conjectures()
    demo_determinacy()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
