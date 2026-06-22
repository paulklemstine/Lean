from __future__ import annotations
from typing import Dict, Tuple


def euler_char_cy4(h11: int, h21: int, h31: int, h22: int) -> int:
    """Assemble the 5x5 Calabi-Yau fourfold Hodge diamond from the four free
    Hodge numbers and return its alternating (signed) sum, the topological
    Euler characteristic. Equivalent closed form: 4 + 2h11 + 2h31 + h22 - 4h21.
    """
    table: Dict[Tuple[int, int], int] = {
        (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
        (1, 1): h11, (3, 3): h11, (3, 1): h31, (1, 3): h31,
        (2, 2): h22, (2, 1): h21, (1, 2): h21, (2, 3): h21, (3, 2): h21,
    }
    chi = 0
    for p in range(5):
        for q in range(5):
            chi += ((-1) ** (p + q)) * table.get((p, q), 0)
    return chi
