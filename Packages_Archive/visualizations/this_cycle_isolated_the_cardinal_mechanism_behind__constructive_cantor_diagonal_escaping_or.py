from typing import List


def diagonal_escape(descriptions: List[List[int]], a: int) -> List[int]:
    """Cantor-diagonal escaping oracle: g[i] = (descriptions[i][i] + 1) % a.

    Requires a >= 2.  Runs in O(N) to build; O(N^2) to certify against all rows.
    """
    assert a >= 2
    n = len(descriptions)
    return [(descriptions[i][i] + 1) % a for i in range(n)]


def certifies_escape(descriptions: List[List[int]], g: List[int]) -> bool:
    """True iff g equals none of the descriptions (escapes all of them)."""
    return all(descriptions[i] != g for i in range(len(descriptions)))
