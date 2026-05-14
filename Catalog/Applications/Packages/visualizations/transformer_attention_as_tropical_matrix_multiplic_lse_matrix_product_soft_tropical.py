import numpy as np

def lse_matrix_multiply(tau, X, Y):
    """Numerically stable log-sum-exp matrix product."""
    sums = X[:, :, np.newaxis] + Y[np.newaxis, :, :]
    max_vals = np.max(sums / tau, axis=1, keepdims=True)
    shifted = sums / tau - max_vals
    return tau * (max_vals.squeeze(1) + np.log(np.sum(np.exp(shifted), axis=1)))

# Example: compare with tropical at low temperature
X = np.array([[1.0, 2.0], [3.0, 0.0]])
Y = np.array([[0.0, 1.0], [2.0, 0.0]])
for tau in [1.0, 0.1, 0.01]:
    print(f'τ={tau}: LSE =', lse_matrix_multiply(tau, X, Y).round(4))