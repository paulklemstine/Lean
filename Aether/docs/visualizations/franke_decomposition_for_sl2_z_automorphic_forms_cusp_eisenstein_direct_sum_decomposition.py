from __future__ import annotations
from typing import Tuple
import numpy as np

def is_complementary(cusp_basis: np.ndarray, eis_basis: np.ndarray) -> bool:
    """Check cusp (+) Eis fills the ambient space with trivial intersection."""
    stacked = np.hstack([cusp_basis, eis_basis])
    d = stacked.shape[0]
    return np.linalg.matrix_rank(stacked) == d == stacked.shape[1]

def decompose(cusp_basis: np.ndarray, eis_basis: np.ndarray,
              f: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Return the unique (cusp_part, eisenstein_part) of f."""
    stacked = np.hstack([cusp_basis, eis_basis])
    coords = np.linalg.solve(stacked, f)
    p = cusp_basis.shape[1]
    return cusp_basis @ coords[:p], eis_basis @ coords[p:]

if __name__ == "__main__":
    rng = np.random.default_rng(1)
    cb = rng.standard_normal((4, 2)); eb = rng.standard_normal((4, 2))
    f = rng.standard_normal(4)
    print("complementary:", is_complementary(cb, eb))
    c, e = decompose(cb, eb, f)
    print("reconstruction error:", np.linalg.norm(c + e - f))
