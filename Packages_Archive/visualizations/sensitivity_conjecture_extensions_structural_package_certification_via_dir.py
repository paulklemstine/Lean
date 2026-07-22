from typing import Dict
import numpy as np

def verify_structural_package(n: int) -> Dict[str, bool]:
    """Numerically certify every structural theorem for A_n."""
    from math import isclose
    def build(k: int) -> np.ndarray:
        if k == 0:
            return np.zeros((1, 1), dtype=np.int64)
        a = build(k - 1); s = a.shape[0]; i = np.eye(s, dtype=np.int64)
        return np.vstack([np.hstack([a, i]), np.hstack([i, -a])])
    a: np.ndarray = build(n)
    size: int = a.shape[0]
    eig: np.ndarray = np.linalg.eigvalsh(a.astype(float))
    det: float = float(np.linalg.det(a.astype(float)))
    return {
        "spectral_identity": bool(np.array_equal(a @ a, n * np.eye(size, dtype=np.int64))),
        "symmetric": bool(np.array_equal(a.T, a)),
        "zero_trace": int(np.trace(a)) == 0,
        "entries_pm1_0": bool(np.all(np.isin(a, (-1, 0, 1)))),
        "n_regular": bool(np.all(np.count_nonzero(a, axis=1) == n)),
        "spectral_gap": bool(np.all(np.abs(eig ** 2 - n) < 1e-7 * max(1, n))),
        "det_squared": isclose(det * det, float(n) ** size, rel_tol=1e-6) if n >= 1 else abs(det) < 1e-6,
    }
