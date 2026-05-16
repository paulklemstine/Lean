import numpy as np

def tropical_backward(W: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Tropical residual: x_i = min_j (y_j - W_{ij}).
    Time: O(m*n), Space: O(m)"""
    return np.min(y[None, :] - W, axis=1)

# Example
W = np.array([[1.0, 3.0], [2.0, 0.0]])
y = np.array([5.0, 6.0])
print(f"W = {W.tolist()}")
print(f"y = {y.tolist()}")
print(f"tropical_backward(W, y) = {tropical_backward(W, y).tolist()}")
