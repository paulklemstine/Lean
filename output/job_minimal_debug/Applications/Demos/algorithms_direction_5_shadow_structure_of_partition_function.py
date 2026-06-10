"""
Algorithms for computing partition function shadow structure.

Implements the core mathematical objects from the formal Lean theory:
- Partition functions with multivariate observables
- Gibbs probability measures
- Covariance matrices of observables under Gibbs weighting
- Active second shadows (support of the covariance matrix)
"""

import numpy as np
from typing import List, Tuple, Set, Dict, Optional


class PartitionModel:
    """A finite partition model with states, weights, and observable vectors.

    Represents Z(y) = ∑_s w(s) * exp(⟨y, a(s)⟩) where:
    - states are indexed by range(num_states)
    - w[s] > 0 are Boltzmann weights
    - a[s] ∈ ℕ^n are observable/exponent vectors
    - y ∈ ℝ^n is the external field parameter

    Attributes:
        weights: array of shape (num_states,) with positive entries
        observables: array of shape (num_states, n) with non-negative integer entries
        n: dimension of observable space
    """

    def __init__(self, weights: np.ndarray, observables: np.ndarray):
        """Initialize partition model.

        Args:
            weights: positive weights w(s), shape (num_states,)
            observables: observable vectors a(s), shape (num_states, n)
        """
        assert weights.ndim == 1
        assert observables.ndim == 2
        assert len(weights) == len(observables)
        assert np.all(weights > 0), "All weights must be strictly positive"
        self.weights = weights.astype(float)
        self.observables = observables.astype(float)
        self.n = observables.shape[1]
        self.num_states = len(weights)

    def log_linear(self, y: np.ndarray) -> np.ndarray:
        """Compute log-linear energies ⟨y, a(s)⟩ for all states.

        Args:
            y: external field, shape (n,)

        Returns:
            array of shape (num_states,) with ⟨y, a(s)⟩
        """
        return self.observables @ y

    def partition_function(self, y: np.ndarray) -> float:
        """Compute Z(y) = ∑_s w(s) * exp(⟨y, a(s)⟩).

        Args:
            y: external field, shape (n,)

        Returns:
            partition function value (positive real)
        """
        ll = self.log_linear(y)
        # Use log-sum-exp trick for numerical stability
        max_ll = np.max(ll)
        return float(np.sum(self.weights * np.exp(ll - max_ll)) * np.exp(max_ll))

    def gibbs_probabilities(self, y: np.ndarray) -> np.ndarray:
        """Compute Gibbs probabilities μ_y(s) = w(s)*exp(⟨y,a(s)⟩)/Z(y).

        Args:
            y: external field, shape (n,)

        Returns:
            probability array of shape (num_states,), sums to 1
        """
        ll = self.log_linear(y)
        max_ll = np.max(ll)
        unnormalized = self.weights * np.exp(ll - max_ll)
        return unnormalized / np.sum(unnormalized)

    def gibbs_mean(self, y: np.ndarray) -> np.ndarray:
        """Compute Gibbs means E_μ[a_i] for all coordinates.

        Args:
            y: external field, shape (n,)

        Returns:
            mean vector of shape (n,)
        """
        mu = self.gibbs_probabilities(y)
        return mu @ self.observables

    def covariance_matrix(self, y: np.ndarray) -> np.ndarray:
        """Compute covariance matrix Cov_μ(a_i, a_j).

        This is the Hessian of log Z, which equals the susceptibility matrix.

        Args:
            y: external field, shape (n,)

        Returns:
            covariance matrix of shape (n, n), positive semidefinite
        """
        mu = self.gibbs_probabilities(y)
        mean = mu @ self.observables  # shape (n,)
        # E[a_i * a_j] - E[a_i] * E[a_j]
        second_moment = (self.observables.T * mu) @ self.observables
        return second_moment - np.outer(mean, mean)

    def variance_vector(self, y: np.ndarray) -> np.ndarray:
        """Compute variance Var_μ(a_i) for each coordinate.

        Args:
            y: external field, shape (n,)

        Returns:
            variance vector of shape (n,)
        """
        return np.diag(self.covariance_matrix(y))

    def active_shadow2(self, y: np.ndarray, threshold: float = 1e-12) -> Set[Tuple[int, int]]:
        """Compute the active second shadow: {(i,j) | Cov(a_i, a_j) ≠ 0}.

        Args:
            y: external field, shape (n,)
            threshold: numerical threshold for nonzero detection

        Returns:
            set of (i,j) pairs with nonzero covariance
        """
        cov = self.covariance_matrix(y)
        shadow = set()
        for i in range(self.n):
            for j in range(self.n):
                if abs(cov[i, j]) > threshold:
                    shadow.add((i, j))
        return shadow

    def active_shadow2_density(self, y: np.ndarray, threshold: float = 1e-12) -> float:
        """Compute |ActSh₂(Z,y)| / n².

        Args:
            y: external field, shape (n,)
            threshold: numerical threshold for nonzero detection

        Returns:
            shadow density in [0, 1]
        """
        if self.n == 0:
            return 0.0
        return len(self.active_shadow2(y, threshold)) / (self.n ** 2)

    def quad_form_covariance(self, y: np.ndarray, v: np.ndarray) -> float:
        """Compute v^T Cov v = Var_μ(⟨v, a⟩).

        This is the thermodynamic response in direction v, always ≥ 0.

        Args:
            y: external field, shape (n,)
            v: direction vector, shape (n,)

        Returns:
            quadratic form value (non-negative)
        """
        cov = self.covariance_matrix(y)
        return float(v @ cov @ v)


def compute_active_shadow2(weights: np.ndarray, observables: np.ndarray,
                           y: np.ndarray, threshold: float = 1e-12) -> Set[Tuple[int, int]]:
    """Standalone function to compute active second shadow.

    Verified algorithm: output matches the mathematical definition
    ActSh₂(Z,y) = {(i,j) | Cov_μ(a_i, a_j) ≠ 0}.

    Args:
        weights: positive weights, shape (num_states,)
        observables: observable vectors, shape (num_states, n)
        y: external field, shape (n,)
        threshold: numerical threshold

    Returns:
        set of active coordinate pairs
    """
    model = PartitionModel(weights, observables)
    return model.active_shadow2(y, threshold)


def is_coordinate_constant(observables: np.ndarray, coord: int) -> bool:
    """Check if coordinate is constant across all states.

    By Theorem 2, Var_μ(a_i) = 0 iff a_i is constant on support.

    Args:
        observables: observable vectors, shape (num_states, n)
        coord: coordinate index

    Returns:
        True iff a(s, coord) is the same for all s
    """
    return len(np.unique(observables[:, coord])) <= 1


if __name__ == "__main__":
    # Example: 3-state system with 2 observables
    w = np.array([1.0, 2.0, 1.0])
    a = np.array([[0, 0], [1, 0], [0, 1]])
    y = np.array([0.0, 0.0])

    model = PartitionModel(w, a)
    print(f"Partition function Z(0) = {model.partition_function(y):.4f}")
    print(f"Gibbs probs: {model.gibbs_probabilities(y)}")
    print(f"Gibbs means: {model.gibbs_mean(y)}")
    print(f"Covariance matrix:\n{model.covariance_matrix(y)}")
    print(f"Active shadow: {model.active_shadow2(y)}")
    print(f"Shadow density: {model.active_shadow2_density(y):.4f}")

    v = np.array([1.0, 1.0])
    print(f"Quadratic form v=(1,1): {model.quad_form_covariance(y, v):.4f}")
    print(f"Coord 0 constant? {is_coordinate_constant(a, 0)}")
    print(f"Coord 1 constant? {is_coordinate_constant(a, 1)}")
