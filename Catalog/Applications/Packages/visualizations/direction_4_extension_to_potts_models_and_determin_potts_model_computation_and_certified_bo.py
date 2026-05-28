#!/usr/bin/env python3
"""
Algorithms for Potts Model Partition Function Computation and Robustness Certification

Implements:
1. Exact enumeration of the Potts partition function
2. Certified log-Lipschitz bound computation
3. Centered simplex perturbation analysis
4. Determinantal spin system computation
"""

import numpy as np
from itertools import product
from typing import Tuple, List, Optional


class PottsModel:
    """A q-state Potts model on n sites with coupling matrix J.

    Parameters
    ----------
    n : int
        Number of sites.
    q : int
        Number of spin states (q ≥ 2).
    J : np.ndarray
        Symmetric n×n coupling matrix.
    beta : float
        Inverse temperature.

    Examples
    --------
    >>> model = PottsModel(3, 2, np.ones((3,3)) - np.eye(3), 1.0)
    >>> Z = model.partition_function()
    >>> print(f"Z = {Z:.4f}")
    """

    def __init__(self, n: int, q: int, J: np.ndarray, beta: float):
        assert n >= 1, "Need at least 1 site"
        assert q >= 2, "Need at least 2 states"
        assert J.shape == (n, n), f"J must be {n}×{n}"
        self.n = n
        self.q = q
        self.J = J
        self.beta = beta

    def energy(self, sigma: np.ndarray) -> float:
        """Compute E(σ) = β * Σ_{i,j} J(i,j) * δ(σ_i, σ_j).

        Parameters
        ----------
        sigma : np.ndarray
            Configuration array of length n with values in {0, ..., q-1}.

        Returns
        -------
        float
            The Potts energy of the configuration.

        Time complexity: O(n²)
        Space complexity: O(1)
        """
        total = 0.0
        for i in range(self.n):
            for j in range(self.n):
                if sigma[i] == sigma[j]:
                    total += self.J[i, j]
        return self.beta * total

    def partition_function(self) -> float:
        """Compute Z = Σ_σ exp(E(σ)) by exact enumeration.

        Returns
        -------
        float
            The exact partition function.

        Time complexity: O(q^n * n²)
        Space complexity: O(n)

        Warning: Exponential in n. Only feasible for n ≤ ~10 and q ≤ ~5.
        """
        Z = 0.0
        for sigma in product(range(self.q), repeat=self.n):
            Z += np.exp(self.energy(np.array(sigma)))
        return Z

    def log_partition_function(self) -> float:
        """Compute log Z with numerical stability.

        Uses the log-sum-exp trick to avoid overflow.

        Returns
        -------
        float
            log Z.

        Time complexity: O(q^n * n²)
        """
        energies = []
        for sigma in product(range(self.q), repeat=self.n):
            energies.append(self.energy(np.array(sigma)))
        max_E = max(energies)
        return max_E + np.log(sum(np.exp(E - max_E) for E in energies))

    def weighted_monochromatic_sum(self, sigma: np.ndarray) -> float:
        """Compute Σ_{i,j} J(i,j) * δ(σ_i, σ_j).

        Returns
        -------
        float
            The weighted monochromatic pair count.
        """
        total = 0.0
        for i in range(self.n):
            for j in range(self.n):
                if sigma[i] == sigma[j]:
                    total += self.J[i, j]
        return total


class CertifiedPottsBound:
    """Certified log-Lipschitz bound for Potts partition functions.

    Given two coupling matrices J and K, computes the certified upper bound:
        |log Z(J) - log Z(K)| ≤ |β| * n² * ‖J - K‖∞

    And the refined centered bound:
        |log Z(J) - log Z(K)| ≤ |β| * (q-1) * n² * ‖J - K‖_centered

    Parameters
    ----------
    n : int
        Number of sites.
    q : int
        Number of states.
    beta : float
        Inverse temperature.
    """

    def __init__(self, n: int, q: int, beta: float):
        self.n = n
        self.q = q
        self.beta = beta

    def coupling_sup_norm(self, J: np.ndarray, K: np.ndarray) -> float:
        """Compute ‖J - K‖∞ = max_{i,j} |J(i,j) - K(i,j)|.

        Time complexity: O(n²)
        """
        return float(np.max(np.abs(J - K)))

    def basic_bound(self, J: np.ndarray, K: np.ndarray) -> float:
        """Certified basic bound: |β| * n² * ‖J - K‖∞.

        This is the bound from Theorem 3 (log_pottsPartition_lipschitz).

        Time complexity: O(n²)
        """
        return abs(self.beta) * self.n**2 * self.coupling_sup_norm(J, K)

    def centered_bound(self, J: np.ndarray, K: np.ndarray) -> float:
        """Certified centered bound: |β| * (q-1) * n² * ‖J - K‖∞.

        This is the bound from Theorem 4 (log_pottsPartition_centered_bound).
        The (q-1) factor reflects that only (q-1)-dimensional fluctuations matter.

        Time complexity: O(n²)
        """
        return abs(self.beta) * (self.q - 1) * self.n**2 * self.coupling_sup_norm(J, K)

    def verify_bound(self, J: np.ndarray, K: np.ndarray) -> dict:
        """Compute exact partition functions and verify the certified bounds.

        Returns
        -------
        dict
            Contains empirical difference, basic bound, centered bound,
            and whether each bound holds.

        Time complexity: O(q^n * n²)
        """
        model_J = PottsModel(self.n, self.q, J, self.beta)
        model_K = PottsModel(self.n, self.q, K, self.beta)

        log_ZJ = model_J.log_partition_function()
        log_ZK = model_K.log_partition_function()
        empirical = abs(log_ZJ - log_ZK)

        basic = self.basic_bound(J, K)
        centered = self.centered_bound(J, K)

        return {
            'log_Z_J': log_ZJ,
            'log_Z_K': log_ZK,
            'empirical_diff': empirical,
            'basic_bound': basic,
            'centered_bound': centered,
            'basic_holds': empirical <= basic + 1e-10,
            'centered_holds': empirical <= centered + 1e-10,
            'basic_ratio': empirical / basic if basic > 0 else 0,
            'centered_ratio': empirical / centered if centered > 0 else 0,
        }


class CenteredSimplexEmbedding:
    """Centered simplex embedding for q-state Potts model.

    Embeds each state a ∈ {0, ..., q-1} into ℝ^q via:
        v_a(b) = δ(a,b) - 1/q

    This projects out the constant mode, isolating the (q-1)-dimensional
    fluctuation space.
    """

    def __init__(self, q: int):
        assert q >= 2
        self.q = q
        self.vectors = np.eye(q) - 1.0 / q

    def state_vector(self, a: int) -> np.ndarray:
        """Get the centered state vector for state a."""
        return self.vectors[a]

    def inner_product(self, a: int, b: int) -> float:
        """⟨v_a, v_b⟩ = (q-1)/q if a=b, -1/q if a≠b."""
        return float(np.dot(self.vectors[a], self.vectors[b]))

    def verify_properties(self) -> dict:
        """Verify key mathematical properties of the embedding.

        Returns
        -------
        dict
            Verification results for sum-to-zero and inner product identities.
        """
        q = self.q
        sum_zero = all(
            abs(sum(self.state_vector(a))) < 1e-12 for a in range(q)
        )
        inner_diag = all(
            abs(self.inner_product(a, a) - (q - 1) / q) < 1e-12
            for a in range(q)
        )
        inner_offdiag = all(
            abs(self.inner_product(a, b) - (-1.0 / q)) < 1e-12
            for a in range(q) for b in range(q) if a != b
        )
        kronecker = all(
            abs(
                (1.0 if a == b else 0.0)
                - (1.0 / q + self.inner_product(a, b))
            ) < 1e-12
            for a in range(q) for b in range(q)
        )

        return {
            'sum_to_zero': sum_zero,
            'inner_product_diagonal': inner_diag,
            'inner_product_offdiagonal': inner_offdiag,
            'kronecker_decomposition': kronecker,
        }


class DeterminantalSpinSystem:
    """Determinantal spin system with kernel L.

    The partition function is det(L + I), which equals the sum of
    principal minors of L.

    Parameters
    ----------
    L : np.ndarray
        Positive semidefinite kernel matrix.
    """

    def __init__(self, L: np.ndarray):
        n = L.shape[0]
        assert L.shape == (n, n), "L must be square"
        # Verify PSD
        eigvals = np.linalg.eigvalsh(L)
        assert np.all(eigvals >= -1e-10), "L must be PSD"
        self.L = L
        self.n = n

    def partition_function(self) -> float:
        """Compute det(L + I)."""
        return float(np.linalg.det(self.L + np.eye(self.n)))

    def log_partition_function(self) -> float:
        """Compute log det(L + I)."""
        return float(np.linalg.slogdet(self.L + np.eye(self.n))[1])

    @staticmethod
    def stability_test(L: np.ndarray, M: np.ndarray) -> dict:
        """Test log-Lipschitz stability between two PSD kernels.

        Returns
        -------
        dict
            Empirical difference and conjectured bound.
        """
        n = L.shape[0]
        sys_L = DeterminantalSpinSystem(L)
        sys_M = DeterminantalSpinSystem(M)

        log_ZL = sys_L.log_partition_function()
        log_ZM = sys_M.log_partition_function()
        empirical = abs(log_ZL - log_ZM)

        sup_norm = float(np.max(np.abs(L - M)))
        bound = n * sup_norm

        return {
            'log_det_L': log_ZL,
            'log_det_M': log_ZM,
            'empirical_diff': empirical,
            'conjectured_bound': bound,
            'holds': empirical <= bound + 1e-10,
            'ratio': empirical / bound if bound > 0 else 0,
        }


if __name__ == "__main__":
    # Example usage
    print("=== PottsModel Example ===")
    model = PottsModel(3, 2, np.ones((3, 3)) - np.eye(3), 1.0)
    print(f"Z = {model.partition_function():.4f}")
    print(f"log Z = {model.log_partition_function():.4f}")

    print("\n=== CertifiedPottsBound Example ===")
    cert = CertifiedPottsBound(3, 3, 0.5)
    J = np.random.randn(3, 3); J = (J + J.T) / 2
    K = J + 0.1 * np.random.randn(3, 3); K = (K + K.T) / 2
    result = cert.verify_bound(J, K)
    print(f"Empirical: {result['empirical_diff']:.6f}")
    print(f"Basic bound: {result['basic_bound']:.6f} (holds: {result['basic_holds']})")
    print(f"Centered bound: {result['centered_bound']:.6f} (holds: {result['centered_holds']})")

    print("\n=== CenteredSimplexEmbedding Example ===")
    emb = CenteredSimplexEmbedding(3)
    props = emb.verify_properties()
    print(f"Sum-to-zero: {props['sum_to_zero']}")
    print(f"Kronecker decomposition: {props['kronecker_decomposition']}")

    print("\n=== DeterminantalSpinSystem Example ===")
    A = np.random.randn(4, 4)
    L = A @ A.T
    sys = DeterminantalSpinSystem(L)
    print(f"det(L+I) = {sys.partition_function():.4f}")
    print(f"log det(L+I) = {sys.log_partition_function():.4f}")
