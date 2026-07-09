from typing import Callable, List
import numpy as np

def gram_psd_verify(
    phi: Callable[[float], np.ndarray], points: List[float],
) -> np.ndarray:
    cols = [phi(p) for p in points]
    Phi = np.column_stack(cols)
    M = Phi.T @ Phi
    assert np.max(np.abs(M - M.T)) < 1e-8, 'not symmetric'
    n = len(points)
    for i in range(n):
        for j in range(i + 1, n):
            assert M[i, i] * M[j, j] - M[i, j] ** 2 >= -1e-9
    eigs = np.linalg.eigvalsh(M)
    assert eigs.min() >= -1e-9, 'not PSD'
    return eigs
