from math import comb, log2
from typing import List, Optional, Tuple

def select_parameters(m: int, target_bits: float,
                      candidates: List[Tuple[int, int, int]]
                      ) -> Optional[Tuple[int, int, int, int]]:
    """Smallest-key (n,k,t) over GF(2^m) meeting target_bits ISD security."""
    best: Optional[Tuple[int, int, int, int]] = None
    for n, k, t in candidates:
        if k < n - m * t:
            continue                       # Goppa rate constraint
        work = log2(comb(n, t)) - log2(comb(n - k, t))
        if work < target_bits:
            continue
        pk_bytes = (k * (n - k) + 7) // 8
        if best is None or pk_bytes < best[3]:
            best = (n, k, t, pk_bytes)
    return best