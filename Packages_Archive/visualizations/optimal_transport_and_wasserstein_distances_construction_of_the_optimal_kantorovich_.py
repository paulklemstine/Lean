from typing import List, Sequence

def optimal_potential(p: Sequence[float], q: Sequence[float]) -> List[float]:
    """Explicit optimal 1-Lipschitz dual potential: phi(0)=0 and
    phi(k+1)-phi(k) = -sign(F_p(k)-F_q(k)). Attains the Kantorovich maximum."""
    fp = [0.0]; fq = [0.0]
    ap = aq = 0.0
    phi: List[float] = [0.0]
    for k in range(len(p) - 1):
        ap += p[k]; aq += q[k]
        gap = ap - aq
        step = (gap < 0) - (gap > 0)
        phi.append(phi[-1] + step)
    return phi
