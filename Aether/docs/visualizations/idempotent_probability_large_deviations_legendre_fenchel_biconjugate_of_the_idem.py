from typing import Sequence

def idempotent_cgf(val: Sequence[float], w: Sequence[float], lam: float) -> float:
    return max(lam * v + wx for v, wx in zip(val, w))

def lf_biconjugate(val: Sequence[float], w: Sequence[float], v: float,
                   lam_lo: float = -50.0, lam_hi: float = 50.0,
                   steps: int = 200_001) -> float:
    """Legendre-Fenchel biconjugate Lambda**(v) = sup_lam (lam*v - Lambda(lam)).

    Lambda is piecewise-linear convex with at most |X| affine pieces, so the sup
    is attained at a breakpoint; a fine grid converges to the exact value.
    """
    best = float("-inf")
    for k in range(steps):
        lam = lam_lo + (lam_hi - lam_lo) * k / (steps - 1)
        cand = lam * v - idempotent_cgf(val, w, lam)
        if cand > best:
            best = cand
    return best
