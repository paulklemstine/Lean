from typing import List

def residue_verify(a: int) -> bool:
    """Decide 5 | a^5 - a using only residue arithmetic mod 5."""
    table: List[int] = [((r ** 5 - r) % 5) for r in range(5)]
    r: int = a % 5
    return table[r] == 0
