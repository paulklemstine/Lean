from typing import Tuple

Mat = Tuple[int, int, int, int]

def in_center_of_SL2(M: Mat, p: int) -> bool:
    """Return True iff M lies in Z(SL_2(F_p)) = ker(pi) = mu_2."""
    m00, m01, m10, m11 = (x % p for x in M)
    is_scalar = (m01 == 0 and m10 == 0 and m00 == m11)
    is_mu2 = (m00 * m00) % p == 1
    return is_scalar and is_mu2
