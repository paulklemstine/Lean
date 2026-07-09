from typing import Optional


def optimal_step(m: int, r: int, misere: bool = True) -> Optional[int]:
    """Return an optimal descent size from position r, or None if r is a
    P-position (losing to move) or terminal.

    Strategy: move to the nearest lower position on the target residue class
    (1 for misere, 0 for normal). The required step is (r - target) mod (m+1),
    which lies in {1,...,m} exactly when r is an N-position.
    """
    target = 1 if misere else 0
    if r == 0 or r % (m + 1) == target:
        return None
    s = (r - target) % (m + 1)
    return s
