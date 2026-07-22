from __future__ import annotations
import numpy as np

def predicted_cube_change(S: np.ndarray, a: int, b: int, c: float = 2.0) -> float:
    """Predicted change in tr(S^3) under the weight-c flip at {a,b}.

    Uses the closed form  delta tr(S^3) = 6 c (S^2)_ab, valid for any real
    symmetric zero-diagonal S. For a Seidel edge deletion, c = 2, giving
    12 (S^2)_ab. Cost O(n) once S^2 is known (one dot product)."""
    S2_ab = float(S[a, :] @ S[:, b])
    return 6.0 * c * S2_ab

def apply_flip(S: np.ndarray, a: int, b: int, c: float = 2.0) -> np.ndarray:
    """Return S + c(E^ab + E^ba), the symmetric rank-two flip at {a,b}."""
    T = S.copy()
    T[a, b] += c; T[b, a] += c
    return T
