import numpy as np
from numpy.linalg import eigh

def functional_calculus(A, f):
    eigenvalues, U = eigh(A)
    f_eigenvalues = np.array([f(lam) for lam in eigenvalues])
    return U @ np.diag(f_eigenvalues) @ U.conj().T

# Example: matrix square root of PSD matrix
n = 4
B = np.random.randn(n, n)
A = B @ B.T  # PSD
sqrt_A = functional_calculus(A, np.sqrt)
print(f"||sqrt(A)^2 - A|| = {np.linalg.norm(sqrt_A @ sqrt_A - A):.2e}")

# Matrix exponential
H = np.random.randn(n, n)
H = (H + H.T) / 2
exp_H = functional_calculus(H, np.exp)
print(f"exp(H) is symmetric? {np.allclose(exp_H, exp_H.T)}")