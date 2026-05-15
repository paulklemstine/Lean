import numpy as np

def charged_weight(W: np.ndarray, A: np.ndarray, q: float) -> np.ndarray:
    """Charged weight matrix. O(n^2) time and space."""
    return W + q * (A - A.T)

def charge_reverse(W, A, q):
    """Charge reversal: equivalent to transpose by the main theorem."""
    return charged_weight(W, A, -q)

# Example
W = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]], dtype=float)
W = (W + W.T) / 2
A = np.array([[0, 1, -1], [2, 0, 1], [-1, 3, 0]], dtype=float)
q = 1.5

cw = charged_weight(W, A, q)
print('chargedWeight(W, A, q):')
print(cw)
print('\nchargedWeight(W, A, -q):')
print(charge_reverse(W, A, q))
print('\ncw^T:')
print(cw.T)
print('\ncw^T == chargedWeight(W, A, -q)?', np.allclose(cw.T, charge_reverse(W, A, q)))