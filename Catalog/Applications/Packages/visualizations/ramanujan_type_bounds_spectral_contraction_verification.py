# Self-contained spectral contraction verification
import numpy as np

T = np.array([[0, 0.5, 0.5], [0.5, 0, 0.5], [0.5, 0.5, 0]])
f = np.array([1.0, -0.5, -0.5])  # Mean-zero
initial = np.sum(f**2)

current = f.copy()
for k in range(10):
    norm_sq = np.sum(current**2)
    bound = (0.25)**k * initial
    print(f'k={k}: ||T^k f||^2 = {norm_sq:.10f}, bound = {bound:.10f}, tight: {abs(norm_sq-bound)<1e-12}')
    current = T @ current
