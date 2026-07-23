def klry_h22(h11: int, h31: int, h21: int) -> int:
    """KLRY Chern-class relation forcing the central Hodge number."""
    return 2 * (22 + 2 * h11 + 2 * h31 - h21)

def ftheory_euler(h11: int, h31: int, h21: int) -> int:
    """F-theory Euler characteristic chi = 6(8 + h11 + h31 - h21)."""
    return 6 * (8 + h11 + h31 - h21)

def klry_consistency(h11: int, h31: int, h21: int) -> bool:
    """Cross-check: combinatorial chi equals the F-theory formula under KLRY."""
    h22 = klry_h22(h11, h31, h21)
    combinatorial = 4 + 2 * h11 + 2 * h31 + h22 - 4 * h21
    return combinatorial == ftheory_euler(h11, h31, h21)
