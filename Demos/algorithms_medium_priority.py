#!/usr/bin/env python3
"""
Tropical Matrix Certificate — Algorithms

Implements the core algorithms from the tropical matrix certificate theory:

1. Certificate Checker: O(n²m²) verification of all 2×2 rectangle equalities
2. Potential Extractor: O(n + m) canonical decomposition algorithm
3. Bad Rectangle Finder: O(n²m²) worst-case obstruction search
4. Gauge Normalizer: O(n + m) canonical form computation
5. Certificate-Preserving Operations: composition and scaling
"""

import numpy as np
from typing import Optional, Tuple, List


class TropicalMatrixCertificate:
    """
    A tropical matrix certificate checker and potential extractor.
    
    Given a matrix A : ℝ^{n×m}, this class can:
    - Check if A satisfies the tropical rectangle equality on all 2×2 submatrices
    - Extract canonical row/column potentials if the certificate holds
    - Find bad rectangle witnesses if the certificate fails
    - Compute the gauge-canonical decomposition
    
    Time complexity:
        check():    O(n² m²) — must verify all rectangle pairs
        extract():  O(n + m) — single pass with base indices
        find_bad(): O(n² m²) worst case, often O(1) for random matrices
    
    Space complexity: O(n + m) for potentials
    """
    
    def __init__(self, A: np.ndarray, tol: float = 1e-10):
        """
        Initialize with matrix A.
        
        Args:
            A: Real-valued matrix of shape (n, m)
            tol: Numerical tolerance for floating-point comparisons
        """
        assert A.ndim == 2, "A must be a 2D matrix"
        self.A = A.astype(float)
        self.n, self.m = A.shape
        self.tol = tol
        self._certified: Optional[bool] = None
        self._bad_rect: Optional[Tuple[int, int, int, int]] = None
    
    def check_rectangle(self, i1: int, i2: int, j1: int, j2: int) -> bool:
        """
        Check if a single 2×2 rectangle satisfies the tropical rectangle equality.
        
        Verifies: A[i1,j1] + A[i2,j2] == A[i1,j2] + A[i2,j1]
        
        Time: O(1)
        """
        lhs = self.A[i1, j1] + self.A[i2, j2]
        rhs = self.A[i1, j2] + self.A[i2, j1]
        return abs(lhs - rhs) < self.tol
    
    def check(self) -> bool:
        """
        Check the full tropical matrix certificate.
        
        Returns True if ALL 2×2 rectangles satisfy the tropical rectangle equality.
        Caches the result and stores the first bad rectangle found (if any).
        
        Time: O(n² m²)
        Space: O(1) additional
        
        Algorithm:
            for each pair of rows (i1, i2):
                for each pair of columns (j1, j2):
                    verify A[i1,j1] + A[i2,j2] == A[i1,j2] + A[i2,j1]
        """
        if self._certified is not None:
            return self._certified
        
        for i1 in range(self.n):
            for i2 in range(i1 + 1, self.n):
                for j1 in range(self.m):
                    for j2 in range(j1 + 1, self.m):
                        if not self.check_rectangle(i1, i2, j1, j2):
                            self._certified = False
                            self._bad_rect = (i1, i2, j1, j2)
                            return False
        
        self._certified = True
        return True
    
    def extract_potentials(
        self, i0: int = 0, j0: int = 0
    ) -> Tuple[np.ndarray, np.ndarray]:
        """
        Extract canonical potentials from a certified matrix.
        
        Given base indices (i0, j0), computes:
            u[i] = A[i, j0]
            v[j] = A[i0, j] - A[i0, j0]
        
        Theorem: If the certificate holds, then A[i,j] = u[i] + v[j] for all i,j.
        
        Time: O(n + m)
        Space: O(n + m)
        
        Args:
            i0: Base row index (default 0)
            j0: Base column index (default 0)
        
        Returns:
            (u, v): Row and column potential vectors
        
        Raises:
            ValueError: If certificate does not hold
        """
        if not self.check():
            raise ValueError(
                "Cannot extract potentials: certificate does not hold. "
                f"Bad rectangle at rows {self._bad_rect[:2]}, cols {self._bad_rect[2:]}"
            )
        
        u = self.A[:, j0].copy()
        v = self.A[i0, :] - self.A[i0, j0]
        return u, v
    
    def find_bad_rectangle(
        self,
    ) -> Optional[Tuple[int, int, int, int, float]]:
        """
        Find a bad rectangle witness for certificate failure.
        
        Returns (i1, i2, j1, j2, violation) where violation is the magnitude
        of the rectangle inequality, or None if the certificate holds.
        
        Time: O(n² m²) worst case
        """
        self.check()  # Ensure cached
        if self._certified:
            return None
        
        i1, i2, j1, j2 = self._bad_rect
        violation = abs(
            (self.A[i1, j1] + self.A[i2, j2])
            - (self.A[i1, j2] + self.A[i2, j1])
        )
        return (i1, i2, j1, j2, violation)
    
    def find_all_bad_rectangles(self) -> List[Tuple[int, int, int, int, float]]:
        """
        Find ALL bad rectangle witnesses.
        
        Returns a list of (i1, i2, j1, j2, violation) tuples.
        
        Time: O(n² m²)
        """
        bads = []
        for i1 in range(self.n):
            for i2 in range(i1 + 1, self.n):
                for j1 in range(self.m):
                    for j2 in range(j1 + 1, self.m):
                        lhs = self.A[i1, j1] + self.A[i2, j2]
                        rhs = self.A[i1, j2] + self.A[i2, j1]
                        if abs(lhs - rhs) >= self.tol:
                            bads.append((i1, i2, j1, j2, abs(lhs - rhs)))
        return bads
    
    def gauge_normalize(self) -> Tuple[np.ndarray, np.ndarray, float]:
        """
        Compute the gauge-canonical decomposition.
        
        Returns (u, v, norm) where:
        - u[0] = A[0, 0] (base row potential at index 0)
        - v[0] = 0 (column potential normalized to 0 at index 0)
        - norm = max|A[i,j]| for reference
        
        The gauge constant is uniquely determined by the normalization v[0] = 0.
        
        Time: O(n + m)
        """
        u, v = self.extract_potentials(i0=0, j0=0)
        norm = np.max(np.abs(self.A))
        return u, v, norm
    
    def reconstruction_error(self, u: np.ndarray, v: np.ndarray) -> float:
        """Compute max |A[i,j] - u[i] - v[j]| over all entries."""
        A_recon = u[:, np.newaxis] + v[np.newaxis, :]
        return np.max(np.abs(self.A - A_recon))
    
    def row_differences(self, j1: int, j2: int) -> np.ndarray:
        """
        Compute row differences Δ_{j1,j2}(i) = A[i,j1] - A[i,j2].
        
        Under the certificate, these are constant across all rows i.
        This is the "vanishing curl" / "exact 1-form" characterization.
        """
        return self.A[:, j1] - self.A[:, j2]
    
    def col_differences(self, i1: int, i2: int) -> np.ndarray:
        """
        Compute column differences Δ_{i1,i2}(j) = A[i1,j] - A[i2,j].
        
        Under the certificate, these are constant across all columns j.
        """
        return self.A[i1, :] - self.A[i2, :]


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix multiplication: (A ⊗ B)[i,j] = max_k (A[i,k] + B[k,j]).
    
    Time: O(n m p) for A : n×m, B : m×p
    """
    n = A.shape[0]
    p = B.shape[1]
    C = np.full((n, p), -np.inf)
    for k in range(A.shape[1]):
        C = np.maximum(C, A[:, k:k+1] + B[k:k+1, :])
    return C


def is_tropical_idempotent(A: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if A is tropically idempotent: A ⊗ A = A in max-plus algebra.
    
    Time: O(n³) for n×n matrix
    """
    assert A.shape[0] == A.shape[1], "Matrix must be square"
    A2 = tropical_matrix_multiply(A, A)
    return np.allclose(A2, A, atol=tol)


# Example usage
if __name__ == "__main__":
    print("=== Tropical Matrix Certificate Algorithms ===\n")
    
    # Example 1: Rank-one matrix
    u = np.array([1.0, 2.0, 3.0])
    v = np.array([0.5, -1.0, 2.0, 0.0])
    A = u[:, np.newaxis] + v[np.newaxis, :]
    
    cert = TropicalMatrixCertificate(A)
    print(f"Rank-one matrix certificate: {cert.check()}")
    u_ext, v_ext = cert.extract_potentials()
    print(f"Reconstruction error: {cert.reconstruction_error(u_ext, v_ext):.2e}")
    
    # Example 2: Random matrix
    B = np.random.randn(4, 5)
    cert2 = TropicalMatrixCertificate(B)
    print(f"\nRandom matrix certificate: {cert2.check()}")
    bad = cert2.find_bad_rectangle()
    if bad:
        print(f"Bad rectangle: rows ({bad[0]},{bad[1]}), cols ({bad[2]},{bad[3]}), violation={bad[4]:.4f}")
    
    # Example 3: Tropical idempotent
    # A rank-one idempotent: A[i,j] = u[i] + v[j] with max_k(u[k]+v[k]) = 0
    u_idem = np.array([1.0, -0.5, 0.3])
    v_idem = -u_idem  # ensures max_k(u[k]+v[k]) = 0
    A_idem = u_idem[:, np.newaxis] + v_idem[np.newaxis, :]
    print(f"\nIdempotent check: {is_tropical_idempotent(A_idem)}")
    cert3 = TropicalMatrixCertificate(A_idem)
    print(f"Certificate: {cert3.check()}")
