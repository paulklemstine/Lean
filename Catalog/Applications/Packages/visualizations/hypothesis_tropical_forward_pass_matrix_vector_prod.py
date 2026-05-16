import numpy as np

def tropical_matmul(W: np.ndarray, x: np.ndarray) -> np.ndarray:
    """Tropical matrix-vector product: y_j = max_i (x_i + W_{ij}).
    Time: O(m*n), Space: O(n)"""
    return np.max(x[:, None] + W, axis=0)

# Example
W = np.array([[1.0, 3.0], [2.0, 0.0]])
x = np.array([1.0, 2.0])
print(f"W = {W.tolist()}")
print(f"x = {x.tolist()}")
print(f"tropical_matmul(W, x) = {tropical_matmul(W, x).tolist()}")
