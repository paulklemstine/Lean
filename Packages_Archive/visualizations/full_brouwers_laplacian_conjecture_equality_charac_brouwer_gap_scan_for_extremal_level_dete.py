from __future__ import annotations
import math
from typing import List, Tuple
import numpy as np

def brouwer_gap_scan(adj: np.ndarray) -> List[Tuple[int, float, float, float]]:
    """For each level k, return (k, s_k, beta_k, gap) where beta_k = m + C(k+1,2).

    A near-zero gap flags a candidate extremal (threshold) saturation level.
    """
    n = adj.shape[0]
    m = int(adj.sum() // 2)
    lap = np.diag(adj.sum(axis=1)) - adj
    eig = np.sort(np.linalg.eigvalsh(lap))[::-1]
    out: List[Tuple[int, float, float, float]] = []
    for k in range(1, n):                        # 1 <= k <= n-1
        sk = float(eig[:k].sum())
        beta = m + math.comb(k + 1, 2)
        out.append((k, sk, float(beta), float(beta - sk)))
    return out
