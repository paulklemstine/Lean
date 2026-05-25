"""
algorithms.py — Certificate-to-Preparation Compilation Algorithms

Implements the core algorithms from the research on quantum ground-state
preparation via Lorentzian polynomial certificates.

Key algorithms:
1. CoefficientState normalization
2. PreparationTree construction and evaluation
3. Certificate compilation from weight vectors
4. Stoquastic Hamiltonian construction and ground-state extraction
"""

import numpy as np
from typing import List, Tuple, Optional, Dict, Any
from dataclasses import dataclass, field


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class CertificatePreparation:
    """A preparation object with depth and amplitude vector.

    Corresponds to the Lean structure:
        structure CertificatePreparation (ι : Type*) where
          depth : ℕ
          amplitudes : ι → ℝ
    """
    depth: int
    amplitudes: np.ndarray

    def __repr__(self):
        return f"CertificatePreparation(depth={self.depth}, dim={len(self.amplitudes)})"


class PreparationTree:
    """Recursive preparation tree for amplitude synthesis.

    Corresponds to the Lean inductive type:
        inductive PreparationTree (ι : Type*) where
          | leaf : (ι → ℝ) → PreparationTree ι
          | branch : ℝ → PreparationTree ι → PreparationTree ι → PreparationTree ι
    """
    pass


class LeafNode(PreparationTree):
    """Base case: explicit amplitude vector."""
    def __init__(self, amplitudes: np.ndarray):
        self.amplitudes = amplitudes.copy()

    def output(self) -> np.ndarray:
        return self.amplitudes

    def depth(self) -> int:
        return 0

    def __repr__(self):
        return f"Leaf(dim={len(self.amplitudes)})"


class BranchNode(PreparationTree):
    """Branching node: convex combination of two sub-preparations.

    output(i) = alpha * left.output(i) + (1 - alpha) * right.output(i)
    """
    def __init__(self, alpha: float, left: PreparationTree, right: PreparationTree):
        self.alpha = alpha
        self.left = left
        self.right = right

    def output(self) -> np.ndarray:
        return self.alpha * self.left.output() + (1 - self.alpha) * self.right.output()

    def depth(self) -> int:
        return max(self.left.depth(), self.right.depth()) + 1

    def __repr__(self):
        return f"Branch(α={self.alpha:.4f}, depth={self.depth()})"


# ============================================================
# Algorithm 1: Coefficient State Normalization
# ============================================================

def coeff_norm(w: np.ndarray) -> float:
    """Compute the L² norm of a weight vector: √(∑ wᵢ²).

    Corresponds to: def coeffNorm (w : ι → ℝ) := Real.sqrt (∑ i, w i ^ 2)

    Args:
        w: Weight vector

    Returns:
        L² norm of w

    Example:
        >>> coeff_norm(np.array([3.0, 4.0]))
        5.0
    """
    return np.sqrt(np.sum(w ** 2))


def coeff_state(w: np.ndarray) -> np.ndarray:
    """Compute the normalized coefficient state: ψᵢ = wᵢ / ‖w‖₂.

    This is the quantum state whose amplitudes are the normalized
    polynomial coefficients.

    Corresponds to: def coeffState (w : ι → ℝ) := fun i => w i / coeffNorm w

    Args:
        w: Weight vector (must have at least one positive entry)

    Returns:
        Normalized amplitude vector with ∑ ψᵢ² = 1

    Raises:
        ValueError: If w is the zero vector

    Example:
        >>> psi = coeff_state(np.array([3.0, 4.0]))
        >>> np.sum(psi**2)  # Should be 1.0
        1.0
    """
    norm = coeff_norm(w)
    if norm == 0:
        raise ValueError("Cannot normalize zero vector")
    return w / norm


# ============================================================
# Algorithm 2: Certificate Compilation
# ============================================================

def compile_preparation(w: np.ndarray, d: int) -> CertificatePreparation:
    """Compile a weight vector into a certificate preparation.

    This is the main compilation function: given nonneg weights from a
    Lorentzian polynomial's coefficients, produce a preparation object.

    Corresponds to:
        def compilePreparation (w : ι → ℝ) (d : ℕ) : CertificatePreparation ι :=
          ⟨certificateDepth d, coeffState w⟩

    Args:
        w: Nonneg weight vector
        d: Polynomial degree

    Returns:
        CertificatePreparation with depth = max(0, d-2) and normalized amplitudes

    Example:
        >>> prep = compile_preparation(np.array([1.0, 2.0, 1.0]), d=3)
        >>> prep.depth
        1
        >>> np.sum(prep.amplitudes**2)  # Unit norm
        1.0
    """
    depth = max(0, d - 2)  # certificateDepth
    amplitudes = coeff_state(w)
    return CertificatePreparation(depth=depth, amplitudes=amplitudes)


def compile_preparation_tree(w: np.ndarray) -> PreparationTree:
    """Compile a weight vector into a preparation tree (leaf node).

    For a direct compilation, this creates a single leaf node.
    For recursive compilations, branching nodes combine child
    preparations.

    Args:
        w: Weight vector

    Returns:
        PreparationTree (leaf) with normalized amplitudes
    """
    return LeafNode(coeff_state(w))


def compile_branching_tree(weights_list: List[np.ndarray],
                           mixing_weights: List[float]) -> PreparationTree:
    """Compile multiple weight vectors into a branching preparation tree.

    Given k weight vectors and k-1 mixing weights, constructs a
    binary tree of branching nodes. This models the recursive structure
    of a Lorentzian certificate.

    Args:
        weights_list: List of k weight vectors
        mixing_weights: List of k-1 mixing weights in [0, 1]

    Returns:
        PreparationTree with k-1 branching nodes

    Example:
        >>> w1 = np.array([1.0, 0.0])
        >>> w2 = np.array([0.0, 1.0])
        >>> tree = compile_branching_tree([w1, w2], [0.5])
        >>> tree.depth()
        1
    """
    if len(weights_list) == 1:
        return compile_preparation_tree(weights_list[0])

    trees = [compile_preparation_tree(w) for w in weights_list]
    result = trees[0]
    for i, alpha in enumerate(mixing_weights):
        result = BranchNode(alpha, result, trees[i + 1])
    return result


# ============================================================
# Algorithm 3: Stoquastic Hamiltonian Construction
# ============================================================

def transverse_field_ising(n: int, J: float = 1.0, h: float = 1.0) -> np.ndarray:
    """Construct the transverse-field Ising model Hamiltonian.

    H = -J ∑ σᶻᵢ σᶻⱼ - h ∑ σˣᵢ

    This is a canonical stoquastic Hamiltonian (off-diagonal ≤ 0 in
    the computational basis when h ≥ 0).

    Args:
        n: Number of sites (qubits), must be ≤ 12
        J: Ising coupling strength
        h: Transverse field strength

    Returns:
        2ⁿ × 2ⁿ Hamiltonian matrix
    """
    dim = 2 ** n
    H = np.zeros((dim, dim))

    for state in range(dim):
        # Diagonal: -J ∑ σᶻᵢ σᶻⱼ for nearest neighbors
        for i in range(n - 1):
            si = 1 - 2 * ((state >> i) & 1)
            sj = 1 - 2 * ((state >> (i + 1)) & 1)
            H[state, state] -= J * si * sj

        # Off-diagonal: -h ∑ σˣᵢ (bit flips)
        for i in range(n):
            flipped = state ^ (1 << i)
            H[state, flipped] -= h

    return H


def xx_model(n: int, J: float = 1.0) -> np.ndarray:
    """Construct the XX model Hamiltonian.

    H = -J ∑ (σˣᵢ σˣⱼ + σʸᵢ σʸⱼ) = -2J ∑ (σ⁺ᵢ σ⁻ⱼ + σ⁻ᵢ σ⁺ⱼ)

    This is stoquastic in the computational basis.

    Args:
        n: Number of sites
        J: Coupling strength

    Returns:
        2ⁿ × 2ⁿ Hamiltonian matrix
    """
    dim = 2 ** n
    H = np.zeros((dim, dim))

    for state in range(dim):
        for i in range(n - 1):
            j = i + 1
            bi = (state >> i) & 1
            bj = (state >> j) & 1
            if bi != bj:
                flipped = state ^ (1 << i) ^ (1 << j)
                H[state, flipped] -= 2 * J

    return H


def is_stoquastic(H: np.ndarray) -> bool:
    """Check if a Hamiltonian is stoquastic (off-diagonal ≤ 0).

    Args:
        H: Square matrix

    Returns:
        True if all off-diagonal entries are ≤ 0
    """
    n = H.shape[0]
    for i in range(n):
        for j in range(n):
            if i != j and H[i, j] > 1e-12:
                return False
    return True


def ground_state(H: np.ndarray) -> Tuple[float, np.ndarray]:
    """Compute the ground state of a Hamiltonian via exact diagonalization.

    Returns the lowest eigenvalue and corresponding eigenvector,
    normalized and with nonneg entries (by Perron-Frobenius for
    stoquastic Hamiltonians, the ground state can be chosen nonneg).

    Args:
        H: Square Hermitian matrix

    Returns:
        (eigenvalue, eigenvector) tuple
    """
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    idx = np.argmin(eigenvalues)
    psi = eigenvectors[:, idx]

    # Ensure nonneg entries (Perron-Frobenius)
    if np.sum(psi) < 0:
        psi = -psi

    return eigenvalues[idx], psi


# ============================================================
# Algorithm 4: Fidelity and Comparison Metrics
# ============================================================

def fidelity(psi: np.ndarray, phi: np.ndarray) -> float:
    """Compute the fidelity |⟨ψ|φ⟩|² between two quantum states.

    Args:
        psi, phi: Normalized state vectors

    Returns:
        Fidelity in [0, 1]
    """
    return abs(np.dot(psi, phi)) ** 2


def coefficient_polynomial_weights(psi: np.ndarray) -> np.ndarray:
    """Extract nonneg weights from a ground state vector.

    For stoquastic ground states (entrywise nonneg by Perron-Frobenius),
    the entries themselves serve as the coefficient weights.

    Args:
        psi: Ground state vector (assumed nonneg)

    Returns:
        Weight vector w such that coeffState(w) ≈ psi
    """
    w = np.abs(psi)  # Ensure nonneg
    return w


def preparation_to_circuit_depth(tree: PreparationTree) -> int:
    """Estimate circuit depth from a preparation tree.

    Each branching node corresponds to one controlled rotation layer
    in a quantum circuit. The depth is the tree depth.

    Args:
        tree: Preparation tree

    Returns:
        Estimated circuit depth
    """
    return tree.depth()


def preparation_to_gate_count(tree: PreparationTree, dim: int) -> int:
    """Estimate gate count from a preparation tree.

    Each branching node requires O(dim) gates for the controlled
    rotation. Total gates ≈ depth × dim.

    Args:
        tree: Preparation tree
        dim: Dimension of the Hilbert space

    Returns:
        Estimated gate count
    """
    return tree.depth() * dim + dim  # +dim for initial state preparation


# ============================================================
# Algorithm 5: Recursive Certificate Simulation
# ============================================================

def simulate_recursive_certificate(n: int, d: int) -> Dict[str, Any]:
    """Simulate a recursive Lorentzian certificate for benchmarking.

    For a degree-d polynomial in n variables, constructs synthetic
    coefficient weights with log-concavity structure and compiles
    them into a preparation.

    Args:
        n: Number of variables
        d: Polynomial degree

    Returns:
        Dictionary with certificate info, preparation, and metrics
    """
    # Generate synthetic log-concave weights (binomial-like)
    from math import comb
    num_monomials = comb(n + d - 1, d)

    # Use binomial-like weights (strongly log-concave)
    weights = np.array([comb(num_monomials - 1, k) for k in range(num_monomials)],
                       dtype=float)
    weights = weights / np.max(weights)  # Scale to [0, 1]
    weights = np.maximum(weights, 1e-10)  # Ensure strict positivity

    # Compile preparation
    prep = compile_preparation(weights, d)

    # Build preparation tree (with synthetic branching)
    tree = compile_preparation_tree(weights)

    return {
        'n': n,
        'd': d,
        'num_monomials': num_monomials,
        'certificate_depth': max(0, d - 2),
        'preparation_depth': prep.depth,
        'support_size': np.sum(weights > 1e-8),
        'amplitudes': prep.amplitudes,
        'tree': tree,
        'norm_check': float(np.sum(prep.amplitudes ** 2)),
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Certificate-to-Preparation Compilation Algorithms")
    print("=" * 60)

    # Example 1: Simple normalization
    w = np.array([3.0, 4.0, 0.0, 5.0])
    psi = coeff_state(w)
    print(f"\nExample 1: Coefficient state normalization")
    print(f"  Weights: {w}")
    print(f"  Normalized: {psi}")
    print(f"  Norm check: {np.sum(psi**2):.10f} (should be 1.0)")
    print(f"  Nonneg check: {all(psi >= 0)}")

    # Example 2: Compilation
    prep = compile_preparation(w, d=4)
    print(f"\nExample 2: Certificate compilation")
    print(f"  {prep}")
    print(f"  Depth: {prep.depth}")

    # Example 3: TFIM ground state
    n = 4
    H = transverse_field_ising(n, J=1.0, h=0.5)
    print(f"\nExample 3: Transverse-field Ising (n={n})")
    print(f"  Stoquastic: {is_stoquastic(H)}")
    E0, psi_gs = ground_state(H)
    print(f"  Ground energy: {E0:.6f}")
    print(f"  Ground state nonneg: {all(psi_gs >= -1e-10)}")

    w_gs = coefficient_polynomial_weights(psi_gs)
    prep_gs = compile_preparation(w_gs, d=2)
    fid = fidelity(prep_gs.amplitudes, psi_gs / np.linalg.norm(psi_gs))
    print(f"  Preparation fidelity: {fid:.10f}")
