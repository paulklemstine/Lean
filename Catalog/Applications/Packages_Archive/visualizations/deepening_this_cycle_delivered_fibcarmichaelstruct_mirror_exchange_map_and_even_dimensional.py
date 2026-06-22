from typing import Tuple

def mirror_swap(h11: int, h21: int, h31: int, h22: int
                ) -> Tuple[int, int, int, int]:
    """Mirror exchange on free Hodge data: swap h11 <-> h31."""
    return (h31, h21, h11, h22)

def is_involution(h11: int, h21: int, h31: int, h22: int) -> bool:
    """Verify swap o swap = identity."""
    return mirror_swap(*mirror_swap(h11, h21, h31, h22)) == (h11, h21, h31, h22)

def euler_invariant_under_mirror(h11: int, h21: int, h31: int, h22: int) -> bool:
    """Verify chi(mirror X) = chi(X) (even-dimensional invariance)."""
    from_x = 4 + 2 * h11 + 2 * h31 + h22 - 4 * h21
    m = mirror_swap(h11, h21, h31, h22)
    from_mx = 4 + 2 * m[0] + 2 * m[2] + m[3] - 4 * m[1]
    return from_x == from_mx
