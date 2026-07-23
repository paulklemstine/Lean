from typing import List, Sequence

def gain(eta: float, lam: float) -> float:
    """Per-mode gain g = 1 - eta*lam (Definition 2.1)."""
    return 1.0 - eta * lam

def rg_flow(eta: float, lam: Sequence[float], v: Sequence[float], k: int) -> List[float]:
    """Residual after k training steps via the closed form g_i^k * v_i."""
    return [gain(eta, lam_i) ** k * v_i for lam_i, v_i in zip(lam, v)]
