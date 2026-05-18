import numpy as np
from numpy.linalg import norm, solve

def rayleigh_quotient_iteration(A, max_iter=100, tol=1e-14):
    n = A.shape[0]
    x = np.random.randn(n) + 1j * np.random.randn(n)
    x /= norm(x)
    sigma = np.real(x.conj() @ A @ x)
    for i in range(max_iter):
        try:
            y = solve(A - sigma * np.eye(n), x)
        except:
            return sigma, x, i + 1
        x = y / norm(y)
        sigma_new = np.real(x.conj() @ A @ x)
        if abs(sigma_new - sigma) < tol:
            return sigma_new, x, i + 1
        sigma = sigma_new
    return sigma, x, max_iter

# Example
n = 6
B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
A = (B + B.conj().T) / 2
ev, vec, iters = rayleigh_quotient_iteration(A)
print(f"Eigenvalue: {ev:.14f}, iterations: {iters} (cubic convergence!)")