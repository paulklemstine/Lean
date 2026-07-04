"""Numerical demonstrations for the single-theater escalation game.

The single-theater escalation game with granularity ``m`` is the subtraction
game with subtraction set ``{1, ..., m}``: a position is a number ``r`` of
remaining rungs, and a move descends by ``s in {1, ..., min(m, r)}`` rungs.

Two endgame conventions:

* misere  -- the player who arrives at position 0 (the opponent was forced to
             complete the final escalation) WINS;
* normal  -- the player who arrives at position 0 (cannot move) LOSES.

Main facts demonstrated here:

* misere P-positions (player to move loses):  r ≡ 1 (mod m+1)
* normal P-positions (player to move loses):  r ≡ 0 (mod m+1)
* the misere class is a "shift by one" of the normal class;
* the characterization is EXACT (holds for every r, threshold T(m) = 0);
* the literal conjecture (misere P-positions ≡ 0 mod m+1) is FALSE.
"""

from __future__ import annotations

from typing import List


def solve_wins(m: int, r_max: int, misere: bool = True) -> List[bool]:
    """Dynamic-programming oracle for the escalation game.

    Returns a list ``wins`` of length ``r_max + 1`` where ``wins[r]`` is True
    iff the player to move at position ``r`` has a winning strategy.

    Base case: ``wins[0] = True`` under misere (arriving at 0 wins), or
    ``False`` under normal play (arriving at 0 loses). For r >= 1, the mover
    wins iff some legal descent lands the opponent on a losing position.
    """
    wins: List[bool] = [False] * (r_max + 1)
    wins[0] = misere  # True for misere, False for normal
    for r in range(1, r_max + 1):
        wins[r] = any((not wins[r - s]) for s in range(1, min(m, r) + 1))
    return wins


def p_positions(m: int, r_max: int, misere: bool = True) -> List[int]:
    """Return the P-positions (player to move loses) up to ``r_max``."""
    wins = solve_wins(m, r_max, misere)
    return [r for r in range(r_max + 1) if not wins[r]]


def closed_form_is_p(m: int, r: int, misere: bool = True) -> bool:
    """Closed-form P-position test: r ≡ 1 (misere) or r ≡ 0 (normal) mod m+1."""
    target = 1 if misere else 0
    return r % (m + 1) == target


def optimal_move(m: int, r: int, misere: bool = True) -> int | None:
    """Return an optimal step size from position ``r``, or None if r is a
    P-position (no winning move) or terminal."""
    if r == 0 or closed_form_is_p(m, r, misere):
        return None
    target = 1 if misere else 0
    s = (r - target) % (m + 1)
    if s == 0:
        s = m + 1  # should not occur for a genuine N-position, guard anyway
    assert 1 <= s <= m and s <= r
    assert (r - s) % (m + 1) == target
    return s


def verify_closed_form(m: int, r_max: int, misere: bool = True) -> bool:
    """Check that the DP oracle and the closed form agree on every position."""
    wins = solve_wins(m, r_max, misere)
    return all(
        (not wins[r]) == closed_form_is_p(m, r, misere) for r in range(r_max + 1)
    )


def main() -> None:
    r_max = 40

    print("=" * 68)
    print("Single-theater escalation game: misere P-positions")
    print("=" * 68)
    for m in (1, 2, 3, 4):
        ps = p_positions(m, 20, misere=True)
        print(f"  m = {m}  (mod {m+1}):  misere P-positions <= 20:  {ps}")
        print(f"           predicted r ≡ 1 (mod {m+1}):        "
              f"{[r for r in range(21) if r % (m+1) == 1]}")

    print()
    print("=" * 68)
    print("Normal-play companion: P-positions ≡ 0 (mod m+1)")
    print("=" * 68)
    for m in (1, 2, 3, 4):
        ps = p_positions(m, 20, misere=False)
        print(f"  m = {m}  (mod {m+1}):  normal  P-positions <= 20:  {ps}")

    print()
    print("=" * 68)
    print("The 'shift by one': misere = normal + 1")
    print("=" * 68)
    for m in (1, 2, 3):
        mis = p_positions(m, 20, misere=True)
        nor = p_positions(m, 20, misere=False)
        shifted = [x + 1 for x in nor if x + 1 <= 20]
        print(f"  m = {m}:  normal+1 = {shifted}")
        print(f"          misere   = {mis}   match: {shifted == mis}")

    print()
    print("=" * 68)
    print("Exactness: closed form matches oracle for ALL r up to", r_max)
    print("=" * 68)
    for m in range(1, 8):
        ok_mis = verify_closed_form(m, r_max, misere=True)
        ok_nor = verify_closed_form(m, r_max, misere=False)
        print(f"  m = {m}:  misere exact = {ok_mis},  normal exact = {ok_nor}")

    print()
    print("=" * 68)
    print("The literal conjecture (misere P-positions ≡ 0 mod m+1) is FALSE")
    print("=" * 68)
    for m in (1, 2, 3):
        wins = solve_wins(m, r_max, misere=True)
        # r = 0 is claimed a P-position by the false conjecture but is a WIN.
        conj_says_p = (0 % (m + 1) == 0)
        actually_p = not wins[0]
        print(f"  m = {m}:  r=0  conjecture-says-P={conj_says_p}, "
              f"actually-P={actually_p}  ->  counterexample: "
              f"{conj_says_p != actually_p}")

    print()
    print("=" * 68)
    print("Sample optimal play (m = 2), starting r = 8")
    print("=" * 68)
    m, r = 2, 8
    turn = "First"
    while r > 0:
        s = optimal_move(m, r, misere=True)
        if s is None:
            print(f"  position r = {r}: {turn} player to move is LOSING "
                  f"(a P-position); any move loses.")
            # make an arbitrary forced move to continue illustration
            s = 1
        else:
            print(f"  position r = {r}: {turn} player descends {s} -> {r - s}")
        r -= s
        turn = "Second" if turn == "First" else "First"
    print(f"  position r = 0 reached; the player to move here WINS (misere).")


if __name__ == "__main__":
    main()
