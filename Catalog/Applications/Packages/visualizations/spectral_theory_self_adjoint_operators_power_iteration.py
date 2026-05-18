import numpy as np
from numpy.linalg import norm

def power_iteration(A, max_iter=1000, tol=1e-12):
    n = A.shape[0]
    x = np.random.randn(n) + 1j * np.random.randn(n)
    x /= norm(x)
    eigenvalue = 0.0
    for i in range(max_iter):
        Ax = A @ x
        eigenvalue_new = np.real(x.conj() @ Ax)
        x = Ax / norm(Ax)
        if abs(eigenvalue_new - eigenvalue) < tol:
            return eigenvalue_new, x, i + 1
        eigenvalue = eigenvalue_new
    return eigenvalue, x, max_iter

# Example
n = 5
B = np.random.randn(n, n) + 1j * np.random.randn(n, n)
A = (B + B.conj().T) / 2
ev, vec, iters = power_iteration(A)
print(f"Dominant eigenvalue: {ev:.10f}, iterations: {iters}")
print(f"Exact: {np.sort(np.linalg.eigvalsh(A))[-1]:.10f}")