from typing import List
import numpy as np

def signed_adjacency(n: int) -> np.ndarray:
    """Recursively assemble the 2^n x 2^n signed adjacency matrix A_n."""
    if n == 0:
        return np.zeros((1, 1), dtype=np.int64)
    a: np.ndarray = signed_adjacency(n - 1)
    size: int = a.shape[0]
    identity: np.ndarray = np.eye(size, dtype=np.int64)
    top: np.ndarray = np.hstack([a, identity])
    bot: np.ndarray = np.hstack([identity, -a])
    return np.vstack([top, bot])
