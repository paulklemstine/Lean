from __future__ import annotations
import numpy as np

def betti_by_rank_nullity(d: np.ndarray, e: np.ndarray, tol: float = 1e-9) -> int:
    """k-th Betti number  b = dim ker d - rank e  for a two-step complex
    U --e--> V --d--> W  with d @ e = 0.  Equals dim ker(d*d + e e*)."""
    assert np.allclose(d @ e, 0.0, atol=1e-8), "chain condition d e = 0 violated"
    n_cols_d = d.shape[1]
    rank_d = int(np.linalg.matrix_rank(d, tol=tol))
    dim_ker_d = n_cols_d - rank_d
    rank_e = int(np.linalg.matrix_rank(e, tol=tol))
    return dim_ker_d - rank_e
