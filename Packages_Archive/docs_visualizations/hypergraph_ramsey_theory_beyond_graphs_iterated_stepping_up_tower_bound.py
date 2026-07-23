from math import log2
from typing import List, Tuple

def stepping_up_tower(r0: int, k0: int, N0: int, h: int) -> List[Tuple[int, int, float]]:
    """Trace of (uniformity, clique_size, log2 ground_set) over h stepping-up steps."""
    r, k, logN = r0, k0, log2(N0)
    trace: List[Tuple[int, int, float]] = [(r, k, logN)]
    for _ in range(h):
        logN = 2 ** logN
        r += 1
        k += 1
        trace.append((r, k, logN))
    return trace