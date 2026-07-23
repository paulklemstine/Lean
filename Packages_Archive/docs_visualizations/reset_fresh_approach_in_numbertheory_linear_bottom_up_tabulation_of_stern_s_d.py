from typing import List


def stern_table(limit: int) -> List[int]:
    """Tabulate s(0..limit) in O(limit) time and space."""
    s: List[int] = [0] * (limit + 1)
    if limit >= 1:
        s[1] = 1
    for k in range(1, limit // 2 + 1):
        if 2 * k <= limit:
            s[2 * k] = s[k]
        if 2 * k + 1 <= limit:
            s[2 * k + 1] = s[k] + s[k + 1]
    return s
