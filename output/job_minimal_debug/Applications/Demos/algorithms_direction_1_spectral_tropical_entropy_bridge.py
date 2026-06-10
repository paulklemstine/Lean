"""
Spectral-Tropical Entropy Bridge: Core Algorithms

Implements the algorithms for computing entropy, spectral ratios,
and the tropical-spectral bridge quantities.

Time complexity: O(n^3) for eigenvalue computation, O(n^2) for entropy.
Space complexity: O(n^2) for adjacency matrix.
"""

import numpy as np
from typing import Tuple, Optional, Dict, Any


class SpectralData:
    """Captures spectral properties of a graph.

    Attributes:
        lambda1: Largest adjacency eigenvalue
        max_deg: Maximum vertex degree (Delta)
        ratio: lambda1 / Delta (spectral regularity ratio)
        all_eigenvalues: Full eigenvalue spectrum
    """

    def __init__(self, adj_matrix: np.ndarray):
        """Compute spectral data from adjacency matrix.

        Args:
            adj_matrix: Symmetric 0-1 adjacency matrix (n x n)

        Time: O(n^3) for eigenvalue decomposition
        Space: O(n^2) for the matrix, O(n) for eigenvalues
        """
        self.n = adj_matrix.shape[0]
        self.degrees = adj_matrix.sum(axis=1).astype(float)
        self.max_deg = float(self.degrees.max())

        # Compute eigenvalues (O(n^3))
        self.all_eigenvalues = np.sort(np.linalg.eigvalsh(adj_matrix))
        self.lambda1 = float(self.all_eigenvalues[-1])

        # Spectral regularity ratio
        self.ratio = self.lambda1 / self.max_deg if self.max_deg > 0 else 1.0

    def log_ratio(self) -> float:
        """Compute log(lambda_1 / Delta). Always <= 0 by Perron-Frobenius."""
        if self.ratio <= 0:
            return -np.inf
        return float(np.log(self.ratio))

    def spectral_gap(self) -> float:
        """Compute the spectral gap (difference between two largest eigenvalues)."""
        if len(self.all_eigenvalues) < 2:
            return 0.0
        return float(self.all_eigenvalues[-1] - self.all_eigenvalues[-2])


class DegreeDistribution:
    """Probability distribution from vertex degrees.

    For a graph G with degree sequence (d_1, ..., d_n),
    the degree distribution is p_v = d_v / (2m) where m = |E|.

    Attributes:
        probs: Probability vector (p_1, ..., p_n)
        degrees: Raw degree sequence
        n: Number of vertices
    """

    def __init__(self, adj_matrix: np.ndarray):
        """Construct degree distribution from adjacency matrix.

        Args:
            adj_matrix: Symmetric 0-1 adjacency matrix

        Time: O(n^2) for degree computation
        """
        self.degrees = adj_matrix.sum(axis=1).astype(float)
        self.n = len(self.degrees)
        total = self.degrees.sum()
        if total > 0:
            self.probs = self.degrees / total
        else:
            self.probs = np.ones(self.n) / self.n

    def shannon_entropy(self) -> float:
        """Compute Shannon entropy H(p) = -sum p_i * log(p_i).

        Convention: 0 * log(0) = 0 (handled by filtering).

        Time: O(n)
        Space: O(n)

        Returns:
            Non-negative real number. H = 0 iff distribution is
            concentrated on one vertex. H = log(n) iff uniform.
        """
        nonzero = self.probs[self.probs > 0]
        return float(-np.sum(nonzero * np.log(nonzero)))

    def is_uniform(self, tol: float = 1e-10) -> bool:
        """Check if distribution is approximately uniform."""
        return np.all(np.abs(self.probs - 1.0 / self.n) < tol)


def spectral_entropy_bridge(adj_matrix: np.ndarray) -> Dict[str, float]:
    """Compute all quantities in the spectral-entropy bridge.

    Given a graph's adjacency matrix, computes:
    - H(G): degree entropy
    - log(lambda_1/Delta): spectral lower bound
    - log(n): entropy upper bound
    - gap: H(G) - log(lambda_1/Delta) >= 0

    Algorithm:
        1. Compute degree distribution: O(n^2)
        2. Compute Shannon entropy: O(n)
        3. Compute eigenvalues: O(n^3)
        4. Compute spectral ratio: O(1)

    Total time: O(n^3) dominated by eigenvalue computation.

    Args:
        adj_matrix: Symmetric adjacency matrix

    Returns:
        Dictionary with bridge quantities
    """
    n = adj_matrix.shape[0]
    dd = DegreeDistribution(adj_matrix)
    sd = SpectralData(adj_matrix)

    H = dd.shannon_entropy()
    log_ratio = sd.log_ratio()
    log_n = np.log(n) if n > 0 else 0.0

    return {
        "n": n,
        "entropy": H,
        "log_ratio": log_ratio,
        "log_n": log_n,
        "gap": H - log_ratio,
        "ratio": sd.ratio,
        "lambda1": sd.lambda1,
        "max_deg": sd.max_deg,
        "spectral_gap": sd.spectral_gap(),
        "is_regular": dd.is_uniform(),
    }


def tropical_stability_constant(adj_matrix: np.ndarray) -> float:
    """Compute the tropical barcode stability constant D + 1.

    From the tropical stability theorem (Stability.lean):
    d_T(TPB(G,f), TPB(G,g)) <= (D+1) * epsilon
    where D is the maximum degree.

    Time: O(n^2) for degree computation
    """
    max_deg = adj_matrix.sum(axis=1).max()
    return float(max_deg + 1)


def entropy_regularity_measure(adj_matrix: np.ndarray) -> float:
    """Compute the entropy-based regularity measure.

    Returns H(G) / log(n), which is 1 for regular graphs
    and < 1 for irregular graphs. This normalizes the entropy
    to [0, 1] and provides a scalar measure of how "regular"
    the degree distribution is.

    Time: O(n^2)
    """
    n = adj_matrix.shape[0]
    if n <= 1:
        return 1.0
    dd = DegreeDistribution(adj_matrix)
    H = dd.shannon_entropy()
    return H / np.log(n)


def tighter_bound_test(adj_matrix: np.ndarray) -> Dict[str, float]:
    """Test the tighter spectral-entropy conjecture.

    Conjecture: H(G) >= log(n) * (1 - (1 - lambda_1/Delta)^2)

    Returns quantities for verification.
    """
    n = adj_matrix.shape[0]
    dd = DegreeDistribution(adj_matrix)
    sd = SpectralData(adj_matrix)

    H = dd.shannon_entropy()
    rhs = np.log(n) * (1 - (1 - sd.ratio) ** 2)

    return {
        "entropy": H,
        "tighter_bound": rhs,
        "gap": H - rhs,
        "holds": H >= rhs - 1e-10,
        "ratio": sd.ratio,
    }


# Example usage
if __name__ == "__main__":
    # Complete graph K_5
    n = 5
    K5 = np.ones((n, n)) - np.eye(n)
    result = spectral_entropy_bridge(K5)
    print(f"K_5 bridge: {result}")
    print(f"Tropical stability constant: {tropical_stability_constant(K5)}")
    print(f"Regularity measure: {entropy_regularity_measure(K5):.6f}")
