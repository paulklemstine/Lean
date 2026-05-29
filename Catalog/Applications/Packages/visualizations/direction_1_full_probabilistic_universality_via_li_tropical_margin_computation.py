import numpy as np

def tropical_margin(W):
    """Compute tropical margin in O(n^2)."""
    n = W.shape[0]
    if n < 2:
        return 0.0
    diag = np.diag(W)
    slack = 2 * W - diag[:, None] - diag[None, :]
    np.fill_diagonal(slack, np.inf)
    return float(np.min(slack))

# Example
W = np.array([[1.0, 3.0, 2.0], [3.0, 1.0, 2.0], [2.0, 2.0, 1.0]])
print(f"tropMargin = {tropical_margin(W)}")
