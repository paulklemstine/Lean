from typing import Tuple

def eisenstein_floor_sum(q: int, p: int) -> int:
    """S_{q,p} = sum_{x=1}^{(p-1)/2} floor(x*q/p)."""
    half: int = (p - 1) // 2
    return sum((x * q) // p for x in range(1, half + 1))

def reciprocity_sign_eisenstein(p: int, q: int) -> Tuple[int, int, int]:
    """Return (lhs, rhs, S_qp+S_pq) for Eisenstein's proof."""
    s_qp: int = eisenstein_floor_sum(q, p)
    s_pq: int = eisenstein_floor_sum(p, q)
    leg_qp: int = -1 if s_qp % 2 else 1
    leg_pq: int = -1 if s_pq % 2 else 1
    exponent: int = (p // 2) * (q // 2)
    rhs: int = -1 if exponent % 2 else 1
    return leg_qp * leg_pq, rhs, s_qp + s_pq