from typing import Callable, List, Tuple

def compression_audit(
    alpha: List[int],
    label: Callable[[int], int],
) -> Tuple[int, int, float]:
    """Return (k, H_rho, R_rho): resolution, collision entropy |alpha|-k,
    and compression ratio k/|alpha|. By quotientCollisionEntropy_nonneg and
    orbitCompressionRatio_le_one, H_rho >= 0 and R_rho <= 1. O(|alpha|) time."""
    k: int = len({label(a) for a in alpha})
    h: int = len(alpha) - k
    r: float = k / len(alpha)
    assert h >= 0 and r <= 1.0
    return k, h, r
