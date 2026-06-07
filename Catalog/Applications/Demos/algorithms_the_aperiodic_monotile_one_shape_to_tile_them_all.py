#!/usr/bin/env python3
"""
Algorithms for Inflation Algebra Analysis

Type-hinted implementations of the key algorithms from the inflation
algebra framework for aperiodic substitution tilings.
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class InflationAlgebra:
    """An inflation algebra over n prototile types.
    
    Attributes:
        M: Non-negative integer substitution matrix (n × n)
        tile_names: Optional names for the prototile types
    """
    M: np.ndarray
    tile_names: Optional[List[str]] = None
    
    def __post_init__(self) -> None:
        assert self.M.ndim == 2, "M must be 2-dimensional"
        assert self.M.shape[0] == self.M.shape[1], "M must be square"
        assert np.all(self.M >= 0), "All entries must be non-negative"
    
    @property
    def n(self) -> int:
        """Number of prototile types."""
        return self.M.shape[0]
    
    def compose(self, other: 'InflationAlgebra') -> 'InflationAlgebra':
        """Compose two inflation algebras (matrix product)."""
        assert self.n == other.n, "Dimension mismatch"
        return InflationAlgebra(M=self.M @ other.M)
    
    def iterate(self, k: int) -> 'InflationAlgebra':
        """k-fold iteration of the substitution."""
        return InflationAlgebra(M=np.linalg.matrix_power(self.M, k).astype(int))
    
    def tile_count(self, k: int) -> np.ndarray:
        """Tile count matrix after k substitutions: entry (i,j) = count of 
        tile j after k substitutions of tile i."""
        return np.linalg.matrix_power(self.M, k)
    
    def total_count(self, k: int) -> np.ndarray:
        """Total tiles after k substitutions for each starting tile type."""
        return self.tile_count(k).sum(axis=1)
    
    def complexity(self, k: int) -> int:
        """Complexity trace function c(k) = Tr(M^k)."""
        return int(np.trace(np.linalg.matrix_power(self.M, k)))


def check_aperiodicity(alg: InflationAlgebra) -> Tuple[bool, int]:
    """Check algebraic aperiodicity: det(M - I) ≠ 0.
    
    Returns:
        (is_aperiodic, determinant_value)
    """
    M_minus_I = alg.M - np.eye(alg.n, dtype=int)
    det_val = int(round(np.linalg.det(M_minus_I)))
    return det_val != 0, det_val


def check_strong_aperiodicity(alg: InflationAlgebra, max_k: int = 100) -> Tuple[bool, Optional[int]]:
    """Check strong aperiodicity: det(M^k - I) ≠ 0 for all k in [1, max_k].
    
    This is equivalent to checking that no eigenvalue is a root of unity.
    
    Returns:
        (is_strongly_aperiodic, first_failing_k or None)
    """
    for k in range(1, max_k + 1):
        Mk = np.linalg.matrix_power(alg.M, k)
        det_val = np.linalg.det(Mk - np.eye(alg.n))
        if abs(det_val) < 0.5:  # integer matrix, so det is integer
            return False, k
    return True, None


def check_primitivity(alg: InflationAlgebra, max_k: int = 100) -> Tuple[bool, Optional[int]]:
    """Check primitivity: some M^k has all strictly positive entries.
    
    Returns:
        (is_primitive, primitivity_index or None)
    """
    for k in range(1, max_k + 1):
        Mk = np.linalg.matrix_power(alg.M, k)
        if np.all(Mk > 0):
            return True, k
    return False, None


def compute_eigenvalues(alg: InflationAlgebra) -> np.ndarray:
    """Compute eigenvalues of the substitution matrix."""
    return np.linalg.eigvals(alg.M.astype(float))


def compute_perron_eigenvalue(alg: InflationAlgebra) -> float:
    """Compute the Perron (largest real) eigenvalue."""
    evs = compute_eigenvalues(alg)
    return float(max(np.real(evs)))


def compute_frequencies(alg: InflationAlgebra, iterations: int = 50) -> np.ndarray:
    """Compute limiting tile type frequencies via power iteration.
    
    Returns normalized Perron eigenvector.
    """
    v = np.ones(alg.n, dtype=float)
    for _ in range(iterations):
        v = alg.M.astype(float) @ v
        v = v / np.sum(v)
    return v


def compute_substitution_entropy(alg: InflationAlgebra) -> float:
    """Compute substitution entropy h = log(Perron eigenvalue)."""
    return float(np.log(compute_perron_eigenvalue(alg)))


def find_cyclotomic_obstructions(alg: InflationAlgebra, max_order: int = 50) -> List[int]:
    """Find roots of unity among eigenvalues.
    
    Returns list of orders m such that some eigenvalue λ satisfies λ^m ≈ 1.
    """
    evs = compute_eigenvalues(alg)
    obstructions = []
    for m in range(1, max_order + 1):
        for ev in evs:
            if abs(ev**m - 1) < 1e-8 and abs(ev) > 1e-10:
                obstructions.append(m)
                break
    return obstructions


def certify_aperiodicity(alg: InflationAlgebra) -> dict:
    """Full aperiodicity certification.
    
    Returns a dictionary with all algebraic invariants.
    """
    aperiodic, det_MI = check_aperiodicity(alg)
    strong_aperiodic, failing_k = check_strong_aperiodicity(alg)
    primitive, prim_index = check_primitivity(alg)
    evs = compute_eigenvalues(alg)
    perron = compute_perron_eigenvalue(alg)
    entropy = compute_substitution_entropy(alg)
    freqs = compute_frequencies(alg)
    obstructions = find_cyclotomic_obstructions(alg)
    
    return {
        'n': alg.n,
        'trace': int(np.trace(alg.M)),
        'det': int(round(np.linalg.det(alg.M))),
        'det_M_minus_I': det_MI,
        'algebraically_aperiodic': aperiodic,
        'strongly_aperiodic': strong_aperiodic,
        'failing_iterate': failing_k,
        'primitive': primitive,
        'primitivity_index': prim_index,
        'eigenvalues': sorted(np.real(evs), reverse=True),
        'perron_eigenvalue': perron,
        'entropy': entropy,
        'frequencies': freqs.tolist(),
        'cyclotomic_obstructions': obstructions,
        'symmetric': bool(np.array_equal(alg.M, alg.M.T)),
        'row_sums': alg.M.sum(axis=1).tolist(),
    }


# Predefined inflation algebras
HAT_ALGEBRA = InflationAlgebra(
    M=np.array([[2, 1, 1, 0],
                [1, 2, 0, 1],
                [1, 0, 2, 1],
                [0, 1, 1, 2]]),
    tile_names=['H (Hat)', 'T (Thin)', 'P (Para)', 'F (Flipped)']
)


if __name__ == "__main__":
    print("=== Hat Algebra Certification ===\n")
    cert = certify_aperiodicity(HAT_ALGEBRA)
    for key, value in cert.items():
        print(f"  {key}: {value}")
