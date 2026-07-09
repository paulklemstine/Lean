from typing import List, Tuple


def strict_witness(n: int, length: int) -> Tuple[Tuple[int, ...], bool, bool]:
    """Produce the indicator e_n witnessing I_n ( I_{n+1}, and verify separation.

    Returns (e_n, e_n in I_{n+1}, e_n in I_n).  For a genuine staircase we must
    have (True, False).  Runs in O(length).
    """
    e = tuple(1 if i == n else 0 for i in range(length))
    in_next = all(e[i] == 0 for i in range(n + 1, length))
    in_curr = all(e[i] == 0 for i in range(n, length))
    return e, in_next, in_curr
