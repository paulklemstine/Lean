from typing import Tuple

Mat = Tuple[int, int, int, int]  # (m00, m01, m10, m11)

def in_regular_unipotent_centralizer(M: Mat, p: int) -> bool:
    """Return True iff M is in SL_2(F_p) and commutes with u=[[1,1],[0,1]]."""
    m00, m01, m10, m11 = (x % p for x in M)
    det = (m00 * m11 - m01 * m10) % p
    if det != 1:
        return False
    return m10 == 0 and m00 == m11 and (m00 * m00) % p == 1
