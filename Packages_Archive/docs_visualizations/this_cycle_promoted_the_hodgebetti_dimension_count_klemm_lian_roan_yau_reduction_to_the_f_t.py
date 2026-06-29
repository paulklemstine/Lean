def klry_h22(h11: int, h21: int, h31: int) -> int:
    """Klemm-Lian-Roan-Yau Chern relation: h22 = 2(22 + 2h11 + 2h31 - h21)."""
    return 2 * (22 + 2 * h11 + 2 * h31 - h21)

def ftheory_euler(h11: int, h21: int, h31: int) -> int:
    """F-theory Euler formula:  chi = 6(8 + h11 + h31 - h21)."""
    return 6 * (8 + h11 + h31 - h21)

def ftheory_reduction(h11: int, h21: int, h31: int) -> dict:
    """Given the three free Hodge numbers, impose KLRY and return chi and the
    three-brane tadpole chi/24. Complexity: O(1)."""
    h22 = klry_h22(h11, h21, h31)
    chi = ftheory_euler(h11, h21, h31)
    return {"h22": h22, "chi": chi, "tadpole": chi / 24}
