import numpy as np

def trop_mat_dist(M: np.ndarray, N: np.ndarray) -> float:
    """Tropical (L-infinity) matrix distance. O(n^2)."""
    return float(np.max(np.abs(M - N)))

def trop_spec_radius(M: np.ndarray) -> float:
    """Tropical spectral radius. O(n)."""
    return float(np.max(np.diag(M)))

# Verify charge-reversal distance invariance
np.random.seed(42)
n = 4
W = np.random.randn(n, n)
W = (W + W.T) / 2
A = np.random.randn(n, n)
B = np.random.randn(n, n)

def charged_weight(W, A, q):
    return W + q * (A - A.T)

for q in [0.5, 1.0, 2.0, 5.0]:
    d_pos = trop_mat_dist(charged_weight(W, A, q), charged_weight(W, B, q))
    d_neg = trop_mat_dist(charged_weight(W, A, -q), charged_weight(W, B, -q))
    print(f'q={q:4.1f}: d(q)={d_pos:.6f}, d(-q)={d_neg:.6f}, diff={abs(d_pos-d_neg):.2e}')