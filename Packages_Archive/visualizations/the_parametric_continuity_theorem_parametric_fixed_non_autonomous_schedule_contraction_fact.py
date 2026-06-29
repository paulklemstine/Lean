from typing import Sequence

def schedule_contraction_factor(Ks: Sequence[float]) -> float:
    """Certified contraction factor of a composed schedule g_{n-1} o ... o g_0.

    Given per-step contraction constants K_0, ..., K_{n-1} (each >= 0), the
    composition contracts distances by at most the product of the constants.
    """
    factor = 1.0
    for k in Ks:
        assert k >= 0.0
        factor *= k
    return factor
