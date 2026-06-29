#!/usr/bin/env python3
"""
Algorithms for Lorentz-Orthogonal Spectral Gap Analysis

Implements the key algorithms from the research paper:
1. Lorentz form computations
2. Orthogonal projection and averaging operators
3. Spectral gap estimation
4. Transfer operator construction for finite quotients
"""
import numpy as np
from typing import List, Tuple, Optional


class LorentzForm:
    """
    The standard Lorentz quadratic form on R^(n+1) with signature (n,1).
    
    Q_n(x) = x_1^2 + ... + x_n^2 - x_{n+1}^2
    
    Args:
        n: Spatial dimension (total dimension is n+1)
    """
    
    def __init__(self, n: int):
        self.n = n
        self.dim = n + 1
        # Metric matrix: diag(1,...,1,-1)
        self.eta = np.diag([1.0] * n + [-1.0])
    
    def quadratic(self, x: np.ndarray) -> float:
        """Compute Q_n(x) = x_1^2 + ... + x_n^2 - x_{n+1}^2.
        
        Args:
            x: Vector in R^(n+1)
        Returns:
            Value of the Lorentz quadratic form
        """
        return float(x @ self.eta @ x)
    
    def bilinear(self, x: np.ndarray, y: np.ndarray) -> float:
        """Compute B_n(x,y) = x_1*y_1 + ... + x_n*y_n - x_{n+1}*y_{n+1}.
        
        Args:
            x, y: Vectors in R^(n+1)
        Returns:
            Value of the Lorentz bilinear form
        """
        return float(x @ self.eta @ y)
    
    def classify(self, x: np.ndarray) -> str:
        """Classify a vector as spacelike, timelike, or lightlike.
        
        Args:
            x: Vector in R^(n+1)
        Returns:
            Classification string
        """
        q = self.quadratic(x)
        if abs(q) < 1e-10:
            return "lightlike"
        return "spacelike" if q > 0 else "timelike"
    
    def is_forward_cone(self, x: np.ndarray) -> bool:
        """Check if x is on the forward light cone.
        
        Args:
            x: Vector in R^(n+1)
        Returns:
            True if lightlike with positive time component
        """
        return abs(self.quadratic(x)) < 1e-10 and x[-1] > 0
    
    def reflection(self, v: np.ndarray, x: np.ndarray) -> np.ndarray:
        """Lorentz reflection of x in hyperplane Q-orthogonal to v.
        
        Assumes Q(v) != 0.
        
        Args:
            v: Spacelike vector defining the reflection
            x: Vector to reflect
        Returns:
            Reflected vector
        """
        qv = self.quadratic(v)
        if abs(qv) < 1e-15:
            raise ValueError("Cannot reflect through a lightlike vector")
        return x - 2 * self.bilinear(x, v) / qv * v


class OrthogonalAveragingOperator:
    """
    Constructs and analyzes the averaging operator T = (1/k) Σ g_i
    for orthogonal reflections.
    
    Args:
        vectors: List of pairwise-orthogonal unit vectors defining reflections
    """
    
    def __init__(self, vectors: List[np.ndarray]):
        self.vectors = vectors
        self.k = len(vectors)
        self.dim = len(vectors[0])
        self._verify_orthogonality()
    
    def _verify_orthogonality(self, tol: float = 1e-8):
        """Verify pairwise orthogonality of the input vectors."""
        for i in range(self.k):
            for j in range(i + 1, self.k):
                ip = np.dot(self.vectors[i], self.vectors[j])
                if abs(ip) > tol:
                    print(f"Warning: vectors {i} and {j} not orthogonal: "
                          f"inner product = {ip:.2e}")
    
    def reflection_matrix(self, i: int) -> np.ndarray:
        """Get the matrix of the i-th reflection R_i = I - 2 v_i v_i^T.
        
        Args:
            i: Index of the reflection
        Returns:
            Reflection matrix
        """
        v = self.vectors[i].reshape(-1, 1)
        norm_sq = float(v.T @ v)
        return np.eye(self.dim) - 2 * v @ v.T / norm_sq
    
    def averaging_matrix(self) -> np.ndarray:
        """Compute T = (1/k) Σ R_i.
        
        Returns:
            Averaging operator matrix
        """
        T = np.zeros((self.dim, self.dim))
        for i in range(self.k):
            T += self.reflection_matrix(i)
        return T / self.k
    
    def operator_norm(self) -> float:
        """Compute ‖T‖ (operator norm = largest singular value).
        
        Returns:
            Operator norm of the averaging matrix
        """
        T = self.averaging_matrix()
        return np.linalg.norm(T, ord=2)
    
    def spectral_gap(self) -> float:
        """Compute gap(T) = 1 - ‖T‖.
        
        Returns:
            Spectral gap
        """
        return 1 - self.operator_norm()
    
    def eigenvalues(self) -> np.ndarray:
        """Compute eigenvalues of T.
        
        Returns:
            Sorted eigenvalues (descending by absolute value)
        """
        T = self.averaging_matrix()
        eigvals = np.linalg.eigvalsh(T)
        return np.sort(eigvals)[::-1]
    
    def apply(self, x: np.ndarray) -> np.ndarray:
        """Apply the averaging operator to a vector.
        
        Args:
            x: Input vector
        Returns:
            T(x)
        """
        return self.averaging_matrix() @ x
    
    def contraction_ratio(self, x: np.ndarray) -> float:
        """Compute ‖T(x)‖/‖x‖.
        
        Args:
            x: Input vector
        Returns:
            Contraction ratio
        """
        nx = np.linalg.norm(x)
        if nx < 1e-15:
            return 0.0
        return np.linalg.norm(self.apply(x)) / nx


def spectral_gap_bound(k: int) -> float:
    """Compute the spectral gap lower bound 1 - 1/√k.
    
    Args:
        k: Number of orthogonal generators
    Returns:
        Lower bound on spectral gap
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    if k < 1:
        raise ValueError("k must be positive")
    return 1 - 1 / np.sqrt(k)


def reflection_spectral_gap(k: int) -> float:
    """Compute the exact spectral gap 2/k for orthogonal reflections
    on the invariant subspace.
    
    This is the exact gap when the reflections act on span(v_1,...,v_k).
    
    Args:
        k: Number of orthogonal reflections
    Returns:
        Exact spectral gap on the invariant subspace
    
    Time complexity: O(1)
    Space complexity: O(1)
    """
    if k < 1:
        raise ValueError("k must be positive")
    return 2.0 / k


def construct_lorentz_generators(n: int, k: int) -> Tuple[LorentzForm, List[np.ndarray]]:
    """Construct k Lorentz-orthogonal spacelike generators in R^(n+1).
    
    Creates unit spacelike vectors e_1,...,e_k (first k standard basis vectors)
    which are automatically Lorentz-orthogonal and orthogonal to the timelike
    direction e_{n+1}.
    
    Args:
        n: Spatial dimension (signature (n,1))
        k: Number of generators (must be ≤ n)
    Returns:
        Tuple of (LorentzForm, list of generator vectors)
    
    Raises:
        ValueError: If k > n
    """
    if k > n:
        raise ValueError(f"Cannot have {k} orthogonal spacelike generators "
                        f"in signature ({n},1)")
    
    L = LorentzForm(n)
    generators = []
    for i in range(k):
        v = np.zeros(n + 1)
        v[i] = 1.0
        generators.append(v)
    
    return L, generators


def finite_quotient_transfer_matrix(k: int, m: int) -> np.ndarray:
    """Construct a finite quotient transfer matrix for k generators
    acting on m states.
    
    Creates a doubly stochastic matrix modeling the action of k
    orthogonal generators on a finite quotient space.
    
    Args:
        k: Number of generators
        m: Number of states in the finite quotient
    Returns:
        m × m doubly stochastic transfer matrix
    
    Time complexity: O(m²)
    Space complexity: O(m²)
    """
    # Simple model: each generator permutes states
    # Average of k random permutation matrices
    T = np.zeros((m, m))
    for _ in range(k):
        perm = np.random.permutation(m)
        P = np.zeros((m, m))
        P[np.arange(m), perm] = 1.0
        T += P
    T /= k
    return T


def analyze_transfer_operator(T: np.ndarray) -> dict:
    """Analyze a transfer operator matrix.
    
    Args:
        T: Square matrix (transfer operator)
    Returns:
        Dictionary with spectral analysis results
    
    Time complexity: O(m³) for m×m matrix
    Space complexity: O(m²)
    """
    eigvals = np.sort(np.abs(np.linalg.eigvals(T)))[::-1]
    
    return {
        "dimension": T.shape[0],
        "operator_norm": np.linalg.norm(T, ord=2),
        "spectral_radius": eigvals[0],
        "second_eigenvalue": eigvals[1] if len(eigvals) > 1 else 0,
        "spectral_gap": 1 - (eigvals[1] if len(eigvals) > 1 else 0),
        "is_doubly_stochastic": (
            np.allclose(T.sum(axis=0), 1) and np.allclose(T.sum(axis=1), 1)
        ),
        "eigenvalues": eigvals
    }


if __name__ == "__main__":
    print("Lorentz-Orthogonal Spectral Gap Algorithms")
    print("=" * 50)
    
    # Example: Construct generators in R^4, signature (3,1)
    n, k = 3, 3
    L, gens = construct_lorentz_generators(n, k)
    
    print(f"\nLorentz form in R^{n+1}, signature ({n},1)")
    for i, g in enumerate(gens):
        print(f"  Generator {i+1}: {g}, Q = {L.quadratic(g):.1f} ({L.classify(g)})")
    
    # Analyze averaging operator
    op = OrthogonalAveragingOperator(gens)
    print(f"\nAveraging operator T = (1/{k}) Σ R_i:")
    print(f"  Operator norm: {op.operator_norm():.6f}")
    print(f"  Spectral gap: {op.spectral_gap():.6f}")
    print(f"  Eigenvalues: {op.eigenvalues()}")
    print(f"  1/√k bound: {1/np.sqrt(k):.6f}")
    print(f"  2/k exact gap: {2/k:.6f}")
    
    # Finite quotient analysis
    print(f"\nFinite quotient transfer matrix (m=10):")
    T = finite_quotient_transfer_matrix(k, 10)
    analysis = analyze_transfer_operator(T)
    print(f"  Second eigenvalue: {analysis['second_eigenvalue']:.6f}")
    print(f"  Spectral gap: {analysis['spectral_gap']:.6f}")
    print(f"  Doubly stochastic: {analysis['is_doubly_stochastic']}")
