import numpy as np

def tropical_mat_map(A: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector map: T(x)_i = max_j(A[i,j] + x[j])."""
    return np.max(A + x[np.newaxis, :], axis=1)

# Example
A = np.array([[0.0, 3.0, -1.0], [2.0, 0.0, 1.0], [1.0, 2.0, 0.0]])
x = np.array([1.0, 0.0, 2.0])
print(f"T(x) = {tropical_mat_map(A, x)}")
