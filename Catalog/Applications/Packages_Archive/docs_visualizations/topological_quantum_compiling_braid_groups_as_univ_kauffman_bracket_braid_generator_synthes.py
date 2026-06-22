from __future__ import annotations
import numpy as np

def jones_op(A: complex, X: np.ndarray) -> np.ndarray:
    """Kauffman-bracket braid generator  jonesOp(A,X) = A*I + A^-1*X."""
    return A * np.eye(X.shape[0], dtype=complex) + (A ** -1) * X

def jones_inv(A: complex, X: np.ndarray) -> np.ndarray:
    """Inverse generator  jonesInv(A,X) = A^-1*I + A*X."""
    return (A ** -1) * np.eye(X.shape[0], dtype=complex) + A * X

def verify_inverse(A: complex, X: np.ndarray, tol: float = 1e-10) -> bool:
    """Check jonesOp(A,X) * jonesInv(A,X) = I  (uses X^2 = delta*X internally)."""
    s, si = jones_op(A, X), jones_inv(A, X)
    I = np.eye(X.shape[0], dtype=complex)
    return bool(np.allclose(s @ si, I, atol=tol) and np.allclose(si @ s, I, atol=tol))
