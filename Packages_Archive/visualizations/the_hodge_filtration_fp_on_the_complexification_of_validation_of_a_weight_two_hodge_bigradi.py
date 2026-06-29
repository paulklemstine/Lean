from __future__ import annotations
import numpy as np

def _rank(A: np.ndarray, tol: float = 1e-9) -> int:
    if A.size == 0:
        return 0
    s = np.linalg.svd(A, compute_uv=False)
    return int(np.sum(s > tol * max(1.0, s[0])))

def _join(*bs: np.ndarray) -> np.ndarray:
    return np.hstack(bs) if bs else np.zeros((0, 0), dtype=complex)

def _dim_meet(A: np.ndarray, B: np.ndarray) -> int:
    # dim(A cap B) = dim A + dim B - dim(A + B)
    return _rank(A) + _rank(B) - _rank(_join(A, B))

def is_hodge(H20: np.ndarray, H11: np.ndarray, H02: np.ndarray, n: int) -> bool:
    """True iff (H20, H11, H02) is a valid weight-two Hodge bigrading of C^n."""
    span_ok = _rank(_join(H20, H11, H02)) == n
    dir20 = _dim_meet(H20, _join(H11, H02)) == 0
    dir11 = _dim_meet(H11, _join(H20, H02)) == 0
    dir02 = _dim_meet(H02, _join(H20, H11)) == 0
    return bool(span_ok and dir20 and dir11 and dir02)
