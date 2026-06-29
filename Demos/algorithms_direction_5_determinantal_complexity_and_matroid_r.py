"""
Algorithms for Determinantal Complexity of Matroid Basis Polynomials

Implements:
1. Basis polynomial computation via Cauchy-Binet
2. Determinantal representation search
3. Matroid basis enumeration
4. Complexity certificate verification
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional, Dict, Set
from dataclasses import dataclass


@dataclass
class DeterminantalRepresentation:
    """A certified determinantal representation of a basis polynomial."""
    matrix: np.ndarray          # r x n matrix
    rank: int                   # r
    ground_set_size: int        # n
    support: List[Tuple[int, ...]]  # nonzero basis subsets
    coefficients: Dict[Tuple[int, ...], float]  # S -> (det A_S)^2
    
    def verify(self, tol: float = 1e-8) -> bool:
        """Verify the representation via Cauchy-Binet."""
        w = np.random.randn(self.ground_set_size)
        gram = np.linalg.det(self.matrix @ np.diag(w) @ self.matrix.T)
        expansion = sum(
            c * np.prod(w[list(S)])
            for S, c in self.coefficients.items()
        )
        return abs(gram - expansion) < tol * (abs(gram) + 1)


def compute_basis_polynomial(
    A: np.ndarray
) -> DeterminantalRepresentation:
    """
    Compute the determinantal representation from a matrix.
    
    Time complexity: O(binom(n, r) * r^3)
    Space complexity: O(binom(n, r))
    
    Args:
        A: r x n matrix over a commutative ring (as numpy array)
    
    Returns:
        DeterminantalRepresentation with all minor data
    """
    r, n = A.shape
    coefficients = {}
    support = []
    
    for S in combinations(range(n), r):
        submatrix = A[:, list(S)]
        det_val = np.linalg.det(submatrix)
        coeff = det_val ** 2
        if abs(coeff) > 1e-14:
            coefficients[S] = coeff
            support.append(S)
    
    return DeterminantalRepresentation(
        matrix=A,
        rank=r,
        ground_set_size=n,
        support=support,
        coefficients=coefficients
    )


def evaluate_basis_polynomial(
    A: np.ndarray,
    w: np.ndarray
) -> float:
    """
    Evaluate basis polynomial at weights w via Gram determinant.
    
    Computes det(A * diag(w) * A^T), which equals
    sum_S (det A_S)^2 * prod_{i in S} w_i by Cauchy-Binet.
    
    Time complexity: O(n*r^2 + r^3) [matrix product + determinant]
    Space complexity: O(r^2)
    
    Guaranteed nonneg when all w_i >= 0 (Theorem: eval_basisPolyOfMatrix_nonneg).
    
    Args:
        A: r x n representation matrix
        w: n-dimensional weight vector
    
    Returns:
        Nonneg value det(A * D_w * A^T)
    """
    # Efficient: form the r x r Gram matrix directly
    # (A * D_w * A^T)[i][j] = sum_k A[i][k] * w[k] * A[j][k]
    B = A * np.sqrt(np.maximum(w, 0))  # r x n
    gram = B @ B.T  # r x r
    return np.linalg.det(gram)


def search_representation_gradient(
    target_coeffs: Dict[Tuple[int, ...], float],
    n: int,
    r: int,
    learning_rate: float = 0.01,
    num_iterations: int = 1000,
    num_restarts: int = 10,
    tol: float = 1e-6
) -> Optional[np.ndarray]:
    """
    Search for an r x n matrix A whose basis polynomial matches target_coeffs.
    
    Uses gradient descent on the loss:
        L(A) = sum_S (target[S] - (det A_S)^2)^2
    
    Time per iteration: O(binom(n,r) * r^3)
    
    Args:
        target_coeffs: desired polynomial coefficients
        n: ground set size
        r: target rank
        learning_rate: step size
        num_iterations: max iterations per restart
        num_restarts: number of random initializations
        tol: convergence tolerance
    
    Returns:
        Matrix A if found, None otherwise
    """
    target_support = list(target_coeffs.keys())
    
    best_loss = float('inf')
    best_A = None
    
    for restart in range(num_restarts):
        A = np.random.randn(r, n) * 0.5
        
        for iteration in range(num_iterations):
            # Compute current coefficients and loss
            loss = 0.0
            grad = np.zeros_like(A)
            
            for S in combinations(range(n), r):
                cols = list(S)
                submat = A[:, cols]
                det_val = np.linalg.det(submat)
                coeff = det_val ** 2
                target_val = target_coeffs.get(S, 0.0)
                
                residual = coeff - target_val
                loss += residual ** 2
                
                # Gradient of (det^2 - target)^2 w.r.t. A
                # d/dA[(det^2 - t)^2] = 2*(det^2 - t) * 2*det * d(det)/dA
                if abs(det_val) > 1e-15:
                    cofactors = np.linalg.det(submat) * np.linalg.inv(submat).T
                    for idx, col in enumerate(cols):
                        grad[:, col] += 4 * residual * det_val * cofactors[:, idx]
            
            if loss < tol:
                return A
            
            if loss < best_loss:
                best_loss = loss
                best_A = A.copy()
            
            A -= learning_rate * grad
            
            # Adaptive learning rate
            if iteration > 0 and iteration % 100 == 0:
                learning_rate *= 0.9
    
    return best_A if best_loss < tol * 100 else None


def block_diagonal_compose(
    A: np.ndarray,
    B: np.ndarray
) -> np.ndarray:
    """
    Compose two determinantal representations via block diagonal.
    
    Given A: r x n1 and B: s x n2,
    returns C: (r+s) x (n1+n2) block diagonal matrix.
    
    By Theorem basisPolyOfMatrix_blockDiag:
        basisPoly(C) = rename(inl)(basisPoly(A)) * rename(inr)(basisPoly(B))
    
    Time: O((r+s) * (n1+n2))
    Space: O((r+s) * (n1+n2))
    """
    r, n1 = A.shape
    s, n2 = B.shape
    
    C = np.zeros((r + s, n1 + n2))
    C[:r, :n1] = A
    C[r:, n1:] = B
    
    return C


def matroid_basis_enumeration(
    independent_oracle,
    n: int,
    r: int
) -> List[Tuple[int, ...]]:
    """
    Enumerate all bases of a matroid given an independence oracle.
    
    Time: O(binom(n, r) * T_oracle)
    
    Args:
        independent_oracle: function Set[int] -> bool
        n: ground set size
        r: rank
    
    Returns:
        List of all bases (r-element independent sets)
    """
    bases = []
    for S in combinations(range(n), r):
        if independent_oracle(set(S)):
            bases.append(S)
    return bases


def verify_representation_soundness(
    A: np.ndarray,
    target_coeffs: Dict[Tuple[int, ...], float],
    tol: float = 1e-6
) -> bool:
    """
    Verify that basisPolyOfMatrix(A) matches target polynomial.
    
    This implements the soundness check from
    searchDeterminantalRepresentations_sound:
    if the search returns A, then IsDeterminantalBasisPolynomial holds.
    
    Time: O(binom(n, r) * r^3 + K) where K = |target support|
    """
    rep = compute_basis_polynomial(A)
    
    # Check supports match
    rep_support = set(rep.coefficients.keys())
    target_support = set(target_coeffs.keys())
    
    if rep_support != target_support:
        return False
    
    # Check coefficients match (up to tolerance)
    for S in target_support:
        if abs(rep.coefficients[S] - target_coeffs[S]) > tol * max(abs(target_coeffs[S]), 1):
            return False
    
    return True


def compute_determinantal_complexity_bounds(
    target_coeffs: Dict[Tuple[int, ...], float],
    n: int
) -> Tuple[int, int]:
    """
    Compute lower and upper bounds on determinantal complexity.
    
    Lower bound: degree of the polynomial (all monomials have this degree
    in a homogeneous basis polynomial).
    
    Upper bound: n (trivially, by using an identity-like matrix).
    
    Returns: (lower_bound, upper_bound)
    """
    if not target_coeffs:
        return (0, 0)
    
    # Degree = size of any support element
    degree = len(next(iter(target_coeffs.keys())))
    
    # Lower bound from degree (Theorem: determinantal complexity >= degree for nonzero homogeneous)
    lower = degree
    
    # Upper bound: try to find representations of each size
    upper = n
    for r in range(degree, n + 1):
        result = search_representation_gradient(target_coeffs, n, r, num_restarts=3)
        if result is not None and verify_representation_soundness(result, target_coeffs):
            upper = r
            break
    
    return (lower, upper)


# Example usage
if __name__ == "__main__":
    print("=== Algorithms Demo ===\n")
    
    # Example 1: Compute basis polynomial
    A = np.array([[1, 0, 1], [0, 1, 1]], dtype=float)
    rep = compute_basis_polynomial(A)
    print(f"Matrix A:\n{A}")
    print(f"Support: {rep.support}")
    print(f"Coefficients: {rep.coefficients}")
    print(f"Verification: {rep.verify()}")
    
    # Example 2: Block diagonal composition
    B = np.array([[1, 1]], dtype=float)
    C = block_diagonal_compose(A, B)
    rep_C = compute_basis_polynomial(C)
    print(f"\nBlock diagonal A ⊕ B:\n{C}")
    print(f"Support: {rep_C.support}")
    print(f"dc ≤ {A.shape[0]} + {B.shape[0]} = {A.shape[0] + B.shape[0]}")
    
    # Example 3: Complexity bounds
    target = {(0, 1): 1.0, (0, 2): 1.0, (1, 2): 1.0}
    lower, upper = compute_determinantal_complexity_bounds(target, 3)
    print(f"\nTarget polynomial support: {list(target.keys())}")
    print(f"Complexity bounds: [{lower}, {upper}]")
