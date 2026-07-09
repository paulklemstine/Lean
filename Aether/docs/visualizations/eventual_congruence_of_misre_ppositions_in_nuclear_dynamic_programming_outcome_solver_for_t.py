from typing import List


def escalation_outcomes(m: int, r_max: int, misere: bool = True) -> List[bool]:
    """Dynamic-programming solver for the single-theater escalation game.

    wins[r] is True iff the player to move at r wins. Base case encodes the
    endgame convention; the recurrence marks r a win iff some legal descent
    lands the opponent on a loss.
    """
    wins: List[bool] = [False] * (r_max + 1)
    wins[0] = misere
    for r in range(1, r_max + 1):
        wins[r] = any((not wins[r - s]) for s in range(1, min(m, r) + 1))
    return wins
