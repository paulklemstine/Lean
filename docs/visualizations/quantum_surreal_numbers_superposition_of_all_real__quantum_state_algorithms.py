"""
Quantum Surreal Numbers: Algorithms
====================================

Algorithms for quantum state manipulation, measurement simulation,
tropical cost computation, and standard-part filtering.

Soli Deo Gloria
"""

import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class MeasurementResult:
    """Result of a quantum measurement"""
    outcome: int
    probability: float
    post_state: 'QuantumStateAlg'
    tropical_cost: float


class QuantumStateAlg:
    """
    Quantum state with complex amplitudes over n basis states.

    Implements the Born rule, density matrix construction,
    standard-part filtering, and tropical cost mapping.

    Time complexity for n basis states:
    - Construction: O(n)
    - Probability computation: O(1) per outcome
    - Total probability: O(n)
    - Density matrix: O(n²)
    - Shannon entropy: O(n)
    - Tropical cost vector: O(n)
    - Standard-part filter: O(n)
    """

    def __init__(self, amplitudes: List[complex]):
        self.amp = np.array(amplitudes, dtype=complex)
        self.n = len(amplitudes)

    def prob(self, i: int) -> float:
        """Born rule: P(i) = |α_i|². O(1)"""
        return abs(self.amp[i]) ** 2

    def prob_vector(self) -> np.ndarray:
        """Full probability vector. O(n)"""
        return np.abs(self.amp) ** 2

    def total_prob(self) -> float:
        """Sum of all probabilities. O(n)"""
        return float(np.sum(self.prob_vector()))

    def normalize(self) -> 'QuantumStateAlg':
        """Return normalized version. O(n)"""
        norm = np.sqrt(self.total_prob())
        if norm < 1e-15:
            raise ValueError("Cannot normalize zero state")
        return QuantumStateAlg((self.amp / norm).tolist())

    def density_matrix(self) -> np.ndarray:
        """Density matrix ρ = |ψ⟩⟨ψ|. O(n²)"""
        return np.outer(self.amp, np.conj(self.amp))

    def shannon_entropy(self) -> float:
        """Shannon entropy H(ψ) = -Σ p_i log(p_i). O(n)"""
        pv = self.prob_vector()
        H = 0.0
        for p in pv:
            if p > 1e-15:
                H -= p * np.log(p)
        return H

    def tropical_cost_vector(self) -> np.ndarray:
        """Map probabilities to tropical costs: -log(p). O(n)"""
        pv = self.prob_vector()
        costs = np.full(self.n, np.inf)
        mask = pv > 1e-15
        costs[mask] = -np.log(pv[mask])
        return costs

    def standard_part_filter(self, epsilon: float) -> np.ndarray:
        """
        Standard-part filtering: set probabilities below ε to 0.

        This models the collapse of infinitesimal probabilities in
        quantum surreal number measurement.

        Algorithm:
        1. Compute probability vector p
        2. For each p_i: if p_i < ε, set to 0
        3. Return filtered vector

        Properties (proved in Lean):
        - Idempotent: filter(filter(p)) = filter(p)
        - Preserves nonnegativity
        - Monotone: preserves ordering of surviving probabilities

        O(n) time, O(n) space
        """
        pv = self.prob_vector()
        return np.where(pv < epsilon, 0.0, pv)

    def measure(self, rng: Optional[np.random.Generator] = None) -> MeasurementResult:
        """
        Simulate quantum measurement.

        Algorithm:
        1. Compute probability vector
        2. Sample outcome from distribution
        3. Collapse to basis state
        4. Compute tropical cost of outcome

        O(n) time
        """
        if rng is None:
            rng = np.random.default_rng()

        pv = self.prob_vector()
        pv = pv / pv.sum()  # Normalize for numerical stability

        outcome = rng.choice(self.n, p=pv)

        # Post-measurement state (collapse)
        post_amp = np.zeros(self.n, dtype=complex)
        post_amp[outcome] = 1.0
        post_state = QuantumStateAlg(post_amp.tolist())

        # Tropical cost
        tc = -np.log(pv[outcome]) if pv[outcome] > 0 else np.inf

        return MeasurementResult(
            outcome=int(outcome),
            probability=float(pv[outcome]),
            post_state=post_state,
            tropical_cost=tc
        )

    def expectation_value(self, observable: np.ndarray) -> complex:
        """
        Compute ⟨ψ|A|ψ⟩ for observable A.

        For Hermitian A, the result is guaranteed real
        (proved: hermitian_expectation_real).

        O(n²) time
        """
        return complex(np.conj(self.amp) @ observable @ self.amp)

    def inner_product(self, other: 'QuantumStateAlg') -> complex:
        """Inner product ⟨self|other⟩. O(n)"""
        return complex(np.conj(self.amp) @ other.amp)


def quantum_tropical_transform(probs: np.ndarray) -> np.ndarray:
    """
    Transform a quantum probability distribution into tropical costs.

    The map p ↦ -log(p) converts:
    - Multiplication of probabilities → Addition of costs
    - Max probability → Min cost (proved: min_tropicalCost_iff_max_prob)

    This is the fundamental bridge between quantum measurement
    and tropical optimization.

    Args:
        probs: Probability vector (positive entries)

    Returns:
        Tropical cost vector

    Complexity: O(n) time, O(n) space
    """
    costs = np.full_like(probs, np.inf)
    mask = probs > 1e-15
    costs[mask] = -np.log(probs[mask])
    return costs


def inverse_tropical_transform(costs: np.ndarray) -> np.ndarray:
    """
    Inverse transform: tropical costs → probabilities.
    c ↦ exp(-c)

    Complexity: O(n)
    """
    probs = np.zeros_like(costs)
    mask = np.isfinite(costs)
    probs[mask] = np.exp(-costs[mask])
    return probs


def spectral_decomposition_check(matrix: np.ndarray) -> Tuple[bool, np.ndarray, np.ndarray]:
    """
    Check if a matrix is Hermitian and compute its spectral decomposition.

    For a density matrix ρ = |ψ⟩⟨ψ|, the eigenvalues are the measurement
    probabilities and the eigenvectors are the measurement basis states.

    Returns:
        (is_hermitian, eigenvalues, eigenvectors)

    Complexity: O(n³) using standard eigenvalue algorithms
    """
    is_hermitian = np.allclose(matrix, matrix.conj().T)
    eigenvalues, eigenvectors = np.linalg.eigh(matrix)
    return is_hermitian, eigenvalues, eigenvectors


if __name__ == "__main__":
    print("Quantum Surreal Numbers: Algorithm Demonstrations")
    print("=" * 50)

    # Create state
    psi = QuantumStateAlg([1/np.sqrt(3), 1j/np.sqrt(3), -1/np.sqrt(3)])
    print(f"\nState: {psi.amp}")
    print(f"Probabilities: {psi.prob_vector()}")
    print(f"Total prob: {psi.total_prob():.6f}")
    print(f"Entropy: {psi.shannon_entropy():.6f}")
    print(f"Tropical costs: {psi.tropical_cost_vector()}")

    # Standard part filtering
    print(f"\nStandard-part filter (ε=0.4):")
    print(f"  Filtered probs: {psi.standard_part_filter(0.4)}")

    # Measurement simulation
    print(f"\nMeasurement simulation (1000 trials):")
    rng = np.random.default_rng(42)
    counts = [0] * 3
    for _ in range(1000):
        result = psi.measure(rng)
        counts[result.outcome] += 1
    print(f"  Counts: {counts}")
    print(f"  Frequencies: {[c/1000 for c in counts]}")
    print(f"  Expected: {psi.prob_vector().tolist()}")

    # Tropical bridge
    print(f"\nTropical bridge:")
    probs = np.array([0.5, 0.3, 0.2])
    costs = quantum_tropical_transform(probs)
    recovered = inverse_tropical_transform(costs)
    print(f"  Probs: {probs}")
    print(f"  Costs: {costs}")
    print(f"  Recovered: {recovered}")
    print(f"  Round-trip: {np.allclose(probs, recovered)}")

    # Spectral decomposition
    rho = psi.density_matrix()
    is_herm, evals, evecs = spectral_decomposition_check(rho)
    print(f"\nSpectral decomposition of ρ:")
    print(f"  Hermitian: {is_herm}")
    print(f"  Eigenvalues: {evals}")
    print(f"  All ≥ 0: {all(ev >= -1e-12 for ev in evals)}")
