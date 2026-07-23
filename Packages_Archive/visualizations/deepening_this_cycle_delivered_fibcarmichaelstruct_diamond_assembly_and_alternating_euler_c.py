from typing import Dict, Tuple

def diamond_entry(h11: int, h21: int, h31: int, h22: int, p: int, q: int) -> int:
    """Reconstruct h^{p,q} of a CY fourfold from its four free Hodge numbers."""
    table: Dict[Tuple[int, int], int] = {
        (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
        (1, 1): h11, (3, 3): h11,
        (3, 1): h31, (1, 3): h31,
        (2, 2): h22,
        (2, 1): h21, (1, 2): h21, (2, 3): h21, (3, 2): h21,
    }
    return table.get((p, q), 0)

def euler_characteristic(h11: int, h21: int, h31: int, h22: int) -> int:
    """Alternating double sum over the 5x5 diamond."""
    return sum(
        (-1) ** (p + q) * diamond_entry(h11, h21, h31, h22, p, q)
        for p in range(5) for q in range(5)
    )
