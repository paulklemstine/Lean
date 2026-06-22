from typing import Sequence

def scale_separation(eta: float, lam: Sequence[float], v: Sequence[float],
                     i: int, j: int, k: int) -> float:
    """Amplitude ratio |x_i(k)|/|x_j(k)| of a fast mode i to a slow mode j."""
    g_i = abs(1.0 - eta * lam[i])
    g_j = abs(1.0 - eta * lam[j])
    assert g_i < g_j, 'mode i must contract strictly faster than mode j'
    base = g_i / g_j
    return base ** k * (abs(v[i]) / abs(v[j]))
