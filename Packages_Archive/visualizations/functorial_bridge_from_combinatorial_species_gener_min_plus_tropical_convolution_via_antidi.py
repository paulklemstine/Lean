import math
from typing import List, Sequence

def trop_conv(u: Sequence[float], w: Sequence[float], n: int) -> float:
    """Min-plus convolution coefficient tropConv(u, w)(n)."""
    best: float = math.inf
    for k in range(n + 1):
        uk: float = u[k] if k < len(u) else math.inf
        wnk: float = w[n - k] if (n - k) < len(w) else math.inf
        best = min(best, uk + wnk)
    return best

def trop_conv_profile(u: Sequence[float], w: Sequence[float], n_max: int) -> List[float]:
    """Full tropical convolution profile up to degree n_max (O(n_max^2))."""
    return [trop_conv(u, w, n) for n in range(n_max + 1)]
