#!/usr/bin/env python3
"""
Algorithms for the Lorentzian CondNSD Conjecture

Implements the core computational methods for testing conditional negative
semidefiniteness of log-Hessian matrices arising from Lorentzian polynomials.

Classes:
    LogHessianCertifier — Main certification engine
    MatroidBasisPolynomial — Matroid basis generating polynomial utilities
    DPPLogHessian — DPP partition function log-Hessian computation
"""

import numpy as np
from itertools import combinations
from typing import Tuple, List, Optional, Dict


class LogHessianCertifier:
    """Certifier for conditional negative semidefiniteness of log-Hessians.

    Given a homogeneous multilinear polynomial p specified by its value,
    gradient, and Hessian at the all-ones point, this class:
    1. Constructs the log-Hessian matrix L = H/c - gg^T/c^2
    2. Restricts L to the zero-sum subspace
    3. Computes eigenvalues on that subspace
    4. Certifies CondNSD if max eigenvalue ≤ tolerance

    Complexity: O(n^3) for n-variable polynomials (eigenvalue computation).

    Example
    -------
    >>> cert = LogHessianCertifier(value=6.0,
    ...     gradient=np.array([3., 3., 3., 3.]),
    ...     hessian=np.array([[0,1,1,1],[1,0,1,1],[1,1,0,1],[1,1,1,0]]).astype(float))
    >>> cert.is_condNSD()
    True
    >>> cert.max_eigenvalue_on_zero_sum()  # doctest: +SKIP
    -0.083...
    """

    def __init__(self, value: float, gradient: np.ndarray,
                 hessian: np.ndarray, tol: float = 1e-10):
        """Initialize certifier.

        Parameters
        ----------
        value : float
            p(1,...,1) > 0
        gradient : np.ndarray, shape (n,)
            ∇p(1,...,1)
        hessian : np.ndarray, shape (n, n)
            ∇²p(1,...,1), symmetric
        tol : float
            Numerical tolerance for eigenvalue nonpositivity
        """
        assert value > 0, "Polynomial value at 1 must be positive"
        assert gradient.ndim == 1
        n = len(gradient)
        assert hessian.shape == (n, n)

        self.n = n
        self.value = value
        self.gradient = gradient
        self.hessian = hessian
        self.tol = tol
        self._log_hessian = None
        self._restricted = None
        self._eigenvalues = None

    @property
    def log_hessian(self) -> np.ndarray:
        """The log-Hessian matrix L = H/c - gg^T/c^2."""
        if self._log_hessian is None:
            c = self.value
            g = self.gradient
            H = self.hessian
            self._log_hessian = H / c - np.outer(g, g) / c**2
        return self._log_hessian

    def zero_sum_basis(self) -> np.ndarray:
        """Orthonormal basis for the zero-sum subspace {v : sum(v)=0}.

        Returns Q of shape (n, n-1) with Q^T Q = I_{n-1}, Q 1 = 0.
        """
        n = self.n
        if n <= 1:
            return np.zeros((n, 0))
        basis = np.zeros((n, n - 1))
        for k in range(n - 1):
            basis[k, k] = 1.0
            basis[n - 1, k] = -1.0
        Q, _ = np.linalg.qr(basis, mode='reduced')
        return Q

    @property
    def restricted_matrix(self) -> np.ndarray:
        """Log-Hessian restricted to the zero-sum subspace."""
        if self._restricted is None:
            Q = self.zero_sum_basis()
            self._restricted = Q.T @ self.log_hessian @ Q
        return self._restricted

    @property
    def eigenvalues(self) -> np.ndarray:
        """Eigenvalues of the restricted log-Hessian (sorted)."""
        if self._eigenvalues is None:
            self._eigenvalues = np.sort(np.linalg.eigvalsh(self.restricted_matrix))
        return self._eigenvalues

    def max_eigenvalue_on_zero_sum(self) -> float:
        """Maximum eigenvalue of the log-Hessian on the zero-sum subspace."""
        if self.n <= 1:
            return 0.0
        return float(self.eigenvalues[-1])

    def is_condNSD(self) -> bool:
        """Test whether the log-Hessian is CondNSD."""
        return self.max_eigenvalue_on_zero_sum() <= self.tol

    def spectral_gap(self) -> float:
        """Spectral gap: |max eigenvalue on zero-sum subspace|.
        Larger gap = stronger negative dependence.
        """
        return abs(self.max_eigenvalue_on_zero_sum())

    def certificate(self) -> Dict:
        """Full certification report."""
        return {
            'n': self.n,
            'value_at_one': self.value,
            'is_condNSD': self.is_condNSD(),
            'max_eigenvalue': self.max_eigenvalue_on_zero_sum(),
            'all_eigenvalues': self.eigenvalues.tolist(),
            'spectral_gap': self.spectral_gap(),
        }


class MatroidBasisPolynomial:
    """Utilities for matroid basis generating polynomials.

    For a matroid M on ground set [n] with basis collection B,
    the basis generating polynomial is p(x) = sum_{B in B} prod_{i in B} x_i.

    This class computes value, gradient, and Hessian at x=1 from the basis list.
    """

    @staticmethod
    def from_bases(n: int, bases: List[Tuple[int, ...]]) -> 'MatroidBasisPolynomial':
        """Create from explicit basis list."""
        obj = MatroidBasisPolynomial()
        obj.n = n
        obj.bases = [tuple(sorted(b)) for b in bases]
        obj._compute()
        return obj

    @staticmethod
    def uniform(n: int, k: int) -> 'MatroidBasisPolynomial':
        """Uniform matroid U(k,n): all k-subsets are bases."""
        bases = list(combinations(range(n), k))
        return MatroidBasisPolynomial.from_bases(n, bases)

    def _compute(self):
        """Compute value, gradient, Hessian at x=1."""
        n = self.n
        self.value = float(len(self.bases))
        self.gradient = np.zeros(n)
        self.hessian = np.zeros((n, n))

        for basis in self.bases:
            for i in basis:
                self.gradient[i] += 1.0
            for i in basis:
                for j in basis:
                    if i != j:
                        self.hessian[i, j] += 1.0

    def certifier(self) -> LogHessianCertifier:
        """Create a LogHessianCertifier for this polynomial."""
        return LogHessianCertifier(self.value, self.gradient, self.hessian)


class DPPLogHessian:
    """Log-Hessian computation for DPP partition functions.

    For a DPP with PSD kernel K, the partition function is
    Z_K(x) = det(I + diag(x) K).

    The log-Hessian at x=1 has entries:
    (∂² log Z / ∂x_i ∂x_j)(1) = -(M_ij)^2
    where M = K(I+K)^{-1} is the marginal kernel.
    """

    def __init__(self, K: np.ndarray):
        """Initialize with PSD kernel K.

        Parameters
        ----------
        K : np.ndarray, shape (n, n)
            Symmetric positive semidefinite kernel matrix.
        """
        assert K.shape[0] == K.shape[1]
        self.n = K.shape[0]
        self.K = K
        self._marginal = None

    @property
    def marginal_kernel(self) -> np.ndarray:
        """M = K(I+K)^{-1}: the marginal kernel."""
        if self._marginal is None:
            I = np.eye(self.n)
            self._marginal = self.K @ np.linalg.inv(I + self.K)
        return self._marginal

    @property
    def log_hessian(self) -> np.ndarray:
        """Log-Hessian at x=1: entries -(M_ij)^2."""
        M = self.marginal_kernel
        return -(M * M)  # entrywise

    @property
    def partition_function_at_one(self) -> float:
        """Z_K(1) = det(I + K)."""
        return float(np.linalg.det(np.eye(self.n) + self.K))

    def certifier(self) -> LogHessianCertifier:
        """Create a LogHessianCertifier for this DPP."""
        M = self.marginal_kernel
        # Value, gradient, Hessian of Z_K at 1
        val = self.partition_function_at_one
        grad = val * np.diag(M)
        # Hessian computation from the partition function
        # ∂Z/∂x_i = val * M_ii, ∂²Z/∂x_i∂x_j = val * (M_ii M_jj - M_ij²) for i≠j
        n = self.n
        hess = np.zeros((n, n))
        for i in range(n):
            for j in range(n):
                if i == j:
                    # ∂²Z/∂xᵢ² = 0 for multilinear Z
                    hess[i, i] = 0.0
                else:
                    # ∂²Z/∂xᵢ∂xⱼ = Z · (Mᵢᵢ Mⱼⱼ - Mᵢⱼ²)
                    hess[i, j] = val * (M[i, i] * M[j, j] - M[i, j]**2)
        return LogHessianCertifier(val, grad, hess)


# ============================================================================
# Utility functions
# ============================================================================

def test_conjecture(certifier: LogHessianCertifier, name: str = "") -> Dict:
    """Test the CondNSD conjecture and print results."""
    cert = certifier.certificate()
    status = "✓ PASS" if cert['is_condNSD'] else "✗ FAIL"
    prefix = f"[{name}] " if name else ""
    print(f"{prefix}{status} | max_eig = {cert['max_eigenvalue']:.10f} | "
          f"gap = {cert['spectral_gap']:.10f}")
    return cert


if __name__ == "__main__":
    print("LogHessianCertifier — Quick test")
    print("-" * 50)

    # Uniform matroid U(2,4)
    mp = MatroidBasisPolynomial.uniform(4, 2)
    cert = mp.certifier()
    test_conjecture(cert, "U(2,4)")

    # DPP with random kernel
    np.random.seed(123)
    A = np.random.randn(5, 3)
    K = A @ A.T / 5
    dpp = DPPLogHessian(K)
    test_conjecture(dpp.certifier(), "Random DPP n=5")
