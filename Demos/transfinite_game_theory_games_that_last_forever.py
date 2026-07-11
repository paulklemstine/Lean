"""
Determinacy of Well-Founded Transfinite Games -- numerical demonstrations.

This self-contained script illustrates the theory of two-player, normal-play
games whose move relation is well-founded (no play lasts forever, though there is
no fixed finite bound on play length).  It computes:

  * the value function W(p)  (True iff the player to move wins), via the
    Zermelo fixed-point equation  W(p) <-> exists q. (p -> q) and not W(q);
  * the canonical greedy optimal strategy;
  * full game trajectories under that strategy against an arbitrary legal
    opponent, verifying that every play terminates and that the decisive
    terminal position is reached on the opponent's (odd) turn;
  * three worked games of increasing ordinal rank:
        - Countdown on N               (rank omega),
        - Lexicographic countdown N x N (rank omega^2),
        - Subtraction game (a Nim-like impartial game, rank omega).

Every function is inlined and uses only the Python standard library.
"""

from __future__ import annotations

from functools import lru_cache
from typing import Callable, Hashable, Iterable, List, Optional, Tuple, TypeVar

Position = TypeVar("Position", bound=Hashable)


# ---------------------------------------------------------------------------
# Core engine: value function and canonical strategy for a well-founded game.
# ---------------------------------------------------------------------------
def make_value_function(
    moves: Callable[[Position], Iterable[Position]],
) -> Callable[[Position], bool]:
    """Return W, the value function for a well-founded move relation.

    `moves(p)` yields all q with a legal move p -> q.  W(p) is True iff the
    player to move at p has a winning strategy, defined by the Zermelo
    fixed-point equation:  W(p)  <->  exists q in moves(p) with not W(q).

    Well-foundedness guarantees the recursion terminates.
    """

    @lru_cache(maxsize=None)
    def W(p: Position) -> bool:
        return any(not W(q) for q in moves(p))

    return W


def is_terminal(moves: Callable[[Position], Iterable[Position]], p: Position) -> bool:
    """A position is terminal iff the player to move has no legal move."""
    for _ in moves(p):
        return False
    return True


def optimal_move(
    moves: Callable[[Position], Iterable[Position]],
    W: Callable[[Position], bool],
    p: Position,
) -> Optional[Position]:
    """The canonical greedy optimal move from a winning position p.

    Returns a q with p -> q and W(q) == False (a move handing the opponent a
    losing position), or None if p is losing/terminal.
    """
    if not W(p):
        return None
    for q in moves(p):
        if not W(q):
            return q
    return None


def play(
    moves: Callable[[Position], Iterable[Position]],
    W: Callable[[Position], bool],
    start: Position,
    opponent: Callable[[Position], Position],
) -> List[Position]:
    """Play out the game from `start`.

    The analysed player uses the canonical greedy strategy at winning
    positions; the opponent moves at losing positions.  Returns the full
    trajectory ending at the first terminal position.
    """
    trajectory: List[Position] = [start]
    p = start
    while not is_terminal(moves, p):
        if W(p):
            nxt = optimal_move(moves, W, p)
            assert nxt is not None
            p = nxt
        else:
            p = opponent(p)
        trajectory.append(p)
    return trajectory


def first_legal_opponent(
    moves: Callable[[Position], Iterable[Position]],
) -> Callable[[Position], Position]:
    """A concrete legal opponent strategy: take the first available legal move."""

    def opp(p: Position) -> Position:
        for q in moves(p):
            return q
        return p  # terminal: stay put (never actually reached during play)

    return opp


# ---------------------------------------------------------------------------
# Game 1: Countdown on N  (rank omega).
#   From a, move to any b < a.  Terminal position: 0.
#   Theory predicts  W(n)  <->  n != 0.
# ---------------------------------------------------------------------------
def countdown_moves(a: int) -> Iterable[int]:
    return range(a)  # 0, 1, ..., a-1  (all b < a)


def demo_countdown() -> None:
    print("=" * 70)
    print("GAME 1: Countdown on N  (ordinal rank omega)")
    print("  From a, move to any b < a.  0 is the unique terminal position.")
    print("=" * 70)
    W = make_value_function(countdown_moves)
    opp = first_legal_opponent(countdown_moves)

    print("\n  Value function  W(n)  vs  the closed form  (n != 0):")
    all_ok = True
    for n in range(11):
        predicted = n != 0
        ok = W(n) == predicted
        all_ok = all_ok and ok
        print(f"    n = {n:2d}:  W = {str(W(n)):5s}   n!=0 = {str(predicted):5s}   {'OK' if ok else 'MISMATCH'}")
    print(f"\n  Closed form W(n) <-> n != 0 verified for n <= 10: {all_ok}")

    for start in (7, 1, 0):
        traj = play(countdown_moves, W, start, opp)
        term_turn = len(traj) - 1
        parity = "odd (opponent stuck -> mover wins)" if term_turn % 2 == 1 else "even (mover stuck -> mover loses)"
        print(f"\n  Trajectory from {start}: {traj}")
        print(f"    terminal reached on turn {term_turn} = {parity}")


# ---------------------------------------------------------------------------
# Game 2: Lexicographic countdown on N x N  (rank omega^2).
#   State (a, b).  A move either
#     * decreases b to any b' < b  (keeping a), or
#     * decreases a to any a' < a and resets b to any natural (here bounded
#       by a display cap so the demo is finite to print) -- modelled as moving
#       to (a', k) for any k < CAP.
#   Terminal: (0, 0).  This game has rank omega^2 in general.
# ---------------------------------------------------------------------------
def lex_moves(state: Tuple[int, int], cap: int = 6) -> Iterable[Tuple[int, int]]:
    a, b = state
    for b2 in range(b):          # decrease b, keep a
        yield (a, b2)
    for a2 in range(a):          # decrease a, reset b to anything < cap
        for k in range(cap):
            yield (a2, k)


def demo_lex() -> None:
    print("\n" + "=" * 70)
    print("GAME 2: Lexicographic countdown on N x N  (ordinal rank omega^2)")
    print("  Decrease b, or decrease a and reset b.  Terminal: (0, 0).")
    print("=" * 70)
    W = make_value_function(lex_moves)
    opp = first_legal_opponent(lex_moves)

    print("\n  Value table W(a, b):  (row a, column b)")
    header = "      " + "".join(f"b={b:<4d}" for b in range(6))
    print(header)
    for a in range(6):
        row = "".join(f"{str(W((a, b))):<6s}" for b in range(6))
        print(f"   a={a}  {row}")
    print("\n  Observe: (0,0) is the unique loss; every other position wins,")
    print("  because a single move to (0,0) leaves the opponent stuck.")

    for start in ((2, 3), (0, 0), (1, 0)):
        traj = play(lex_moves, W, start, opp)
        term_turn = len(traj) - 1
        parity = "odd -> mover wins" if term_turn % 2 == 1 else "even -> mover loses"
        print(f"\n  Trajectory from {start}: {traj}")
        print(f"    terminal on turn {term_turn} ({parity})")


# ---------------------------------------------------------------------------
# Game 3: Subtraction game  (impartial, Nim-like, rank omega).
#   From a pile of n tokens, remove any number in `allowed` (e.g. {1, 2, 3}).
#   Terminal: 0.  W(n) is the classic losing-positions pattern.
# ---------------------------------------------------------------------------
def subtraction_moves(n: int, allowed: Tuple[int, ...] = (1, 2, 3)) -> Iterable[int]:
    for k in allowed:
        if k <= n:
            yield n - k


def demo_subtraction() -> None:
    print("\n" + "=" * 70)
    print("GAME 3: Subtraction game, remove 1, 2, or 3 tokens (rank omega)")
    print("  Terminal: 0.  Losing positions are the multiples of 4.")
    print("=" * 70)
    W = make_value_function(subtraction_moves)
    opp = first_legal_opponent(subtraction_moves)

    print("\n  n :  W(n)   predicted-loss = (n % 4 == 0)")
    all_ok = True
    for n in range(17):
        losing = (n % 4 == 0)
        ok = (not W(n)) == losing
        all_ok = all_ok and ok
        print(f"   {n:2d} :  {str(W(n)):5s}  loss={str(losing):5s}  {'OK' if ok else 'X'}")
    print(f"\n  Losing positions == multiples of 4 verified for n <= 16: {all_ok}")

    for start in (10, 8, 5):
        traj = play(subtraction_moves, W, start, opp)
        term_turn = len(traj) - 1
        parity = "odd -> mover wins" if term_turn % 2 == 1 else "even -> mover loses"
        print(f"\n  Trajectory from {start}: {traj}")
        print(f"    terminal on turn {term_turn} ({parity})")


# ---------------------------------------------------------------------------
# Cross-check: the determinacy theorem, empirically.
#   For a winning start, the play must terminate on an ODD turn for EVERY
#   legal opponent; for a losing start, on an EVEN turn.
# ---------------------------------------------------------------------------
def demo_determinacy_check() -> None:
    print("\n" + "=" * 70)
    print("DETERMINACY CROSS-CHECK: MoverWins(p) <-> W(p)")
    print("  For several opponents, terminal-turn parity matches W(start).")
    print("=" * 70)

    def make_opponent(offset: int) -> Callable[[int], int]:
        def opp(p: int) -> int:
            opts = list(countdown_moves(p))
            if not opts:
                return p
            return opts[offset % len(opts)]
        return opp

    W = make_value_function(countdown_moves)
    for start in range(1, 8):
        parities = set()
        for offset in range(6):
            traj = play(countdown_moves, W, start, make_opponent(offset))
            parities.add((len(traj) - 1) % 2)
        # Mover wins iff every play ends on an odd turn.
        mover_wins = parities == {1}
        consistent = mover_wins == W(start)
        print(f"  start={start}: W={str(W(start)):5s}  MoverWins={str(mover_wins):5s}  "
              f"consistent={consistent}")


if __name__ == "__main__":
    demo_countdown()
    demo_lex()
    demo_subtraction()
    demo_determinacy_check()
    print("\nAll demonstrations complete.")
