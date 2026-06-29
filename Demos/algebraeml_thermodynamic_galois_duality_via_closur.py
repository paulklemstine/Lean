#!/usr/bin/env python3
"""
Algorithms for Thermodynamic Galois Duality

Implements the core computational algorithms arising from the
thermodynamic Galois duality theory for finite closure systems.

Algorithms:
1. Transfer matrix construction from closure generators
2. Pressure computation via matrix powers
3. Equilibrium functional computation (Perron eigenvector)
4. Galois connection computation (kernel setoid, quotient face)
5. Phase detection via character decomposition
6. Canonical quotient computation
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass


@dataclass
class ClosureSystem:
    """A finite weighted closure dynamical system.

    Attributes:
        n_states: Number of states |X|
        n_generators: Number of generators |Gen|
        step: step[g] is a set of (source, target) pairs for generator g
        weights: weight[g] is the real weight for generator g
        state_labels: Optional labels for states
    """
    n_states: int
    n_generators: int
    step: List[Set[Tuple[int, int]]]
    weights: List[float]
    state_labels: Optional[List[str]] = None


@dataclass
class EquilibriumData:
    """Result of equilibrium computation.

    Attributes:
        eigenvalue: The Perron eigenvalue (spectral radius)
        pressure: The thermodynamic pressure log(eigenvalue)
        functional: The normalized left Perron eigenvector
        kernel_classes: Equivalence classes of the kernel setoid
    """
    eigenvalue: float
    pressure: float
    functional: np.ndarray
    kernel_classes: List[List[int]]


@dataclass
class GaloisData:
    """Result of Galois connection computation.

    Attributes:
        quotient_classes: Equivalence classes of the quotient
        face_functionals: Equilibrium functionals in the face
        preserves_pressure: Whether the quotient preserves pressure
    """
    quotient_classes: List[List[int]]
    face_functionals: List[np.ndarray]
    preserves_pressure: bool


def build_transfer_matrix(system: ClosureSystem) -> np.ndarray:
    """Build the weighted transfer matrix A from a closure system.

    Complexity: O(|X|^2 * |Gen|) time, O(|X|^2) space

    The matrix A has entries:
        A[x, y] = sum_{g in Gen} exp(w(g)) * [step(g, y, x)]

    where [step(g, y, x)] indicates whether generator g maps y to x.

    Args:
        system: The finite weighted closure system

    Returns:
        Transfer matrix A as numpy array of shape (n_states, n_states)
    """
    n = system.n_states
    A = np.zeros((n, n))

    for g in range(system.n_generators):
        w = np.exp(system.weights[g])
        for (src, tgt) in system.step[g]:
            A[tgt, src] += w

    return A


def compute_partition_sums(A: np.ndarray, max_n: int) -> np.ndarray:
    """Compute partition sums Z_0, Z_1, ..., Z_{max_n}.

    Complexity: O(max_n * |X|^3) time (naive matrix power)

    Z_n = sum of all entries of A^n.

    Args:
        A: Transfer matrix
        max_n: Maximum path length

    Returns:
        Array of partition sums [Z_0, Z_1, ..., Z_{max_n}]
    """
    n = A.shape[0]
    Zs = np.zeros(max_n + 1)
    An = np.eye(n)
    for k in range(max_n + 1):
        Zs[k] = An.sum()
        if k < max_n:
            An = An @ A
    return Zs


def compute_pressure_sequence(
    A: np.ndarray, max_n: int = 100
) -> Tuple[np.ndarray, float]:
    """Compute the pressure sequence P_n = (1/n) log Z_n.

    Also returns the limit pressure = log(spectral_radius(A)).

    Complexity: O(max_n * |X|^3) time

    Args:
        A: Transfer matrix
        max_n: Maximum path length for convergence analysis

    Returns:
        (pressure_sequence, limit_pressure)
    """
    Zs = compute_partition_sums(A, max_n)
    pressures = np.zeros(max_n)
    for n in range(1, max_n + 1):
        if Zs[n] > 0:
            pressures[n-1] = np.log(Zs[n]) / n
        else:
            pressures[n-1] = float('-inf')

    # Compute limit pressure from spectral radius
    eigenvalues = np.linalg.eigvals(A)
    rho = max(abs(eigenvalues))
    limit_pressure = np.log(rho) if rho > 0 else float('-inf')

    return pressures, limit_pressure


def compute_equilibrium(A: np.ndarray, tol: float = 1e-12) -> EquilibriumData:
    """Compute the equilibrium functional (Perron eigenvector).

    For a nonnegative irreducible matrix, the Perron-Frobenius theorem
    guarantees a unique positive left eigenvector for the spectral radius.

    Complexity: O(|X|^3) time (eigendecomposition)

    Args:
        A: Transfer matrix (nonneg)
        tol: Tolerance for equivalence class detection

    Returns:
        EquilibriumData with eigenvalue, pressure, functional, kernel classes
    """
    # Left eigenvectors = right eigenvectors of A^T
    eigenvalues, eigenvectors = np.linalg.eig(A.T)

    # Find the Perron eigenvalue (largest real)
    real_parts = eigenvalues.real
    idx = np.argmax(real_parts)
    eigval = real_parts[idx]

    # Extract and normalize eigenvector
    eigvec = np.abs(eigenvectors[:, idx].real)
    eigvec = eigvec / eigvec.sum()

    # Compute kernel equivalence classes
    n = len(eigvec)
    visited = [False] * n
    classes = []
    for i in range(n):
        if visited[i]:
            continue
        cls = [i]
        visited[i] = True
        for j in range(i + 1, n):
            if not visited[j] and abs(eigvec[i] - eigvec[j]) < tol:
                cls.append(j)
                visited[j] = True
        classes.append(cls)

    return EquilibriumData(
        eigenvalue=eigval,
        pressure=np.log(eigval) if eigval > 0 else float('-inf'),
        functional=eigvec,
        kernel_classes=classes,
    )


def compute_galois_maps(
    A: np.ndarray,
    equilibrium: EquilibriumData,
    quotient_classes: List[List[int]],
) -> GaloisData:
    """Compute the Galois connection maps.

    Given a quotient (equivalence relation as partition) and equilibrium
    data, compute:
    - Phi(Q) = face of functionals factoring through Q
    - Psi(F) = kernel of functionals in F
    - Whether the quotient preserves pressure

    Complexity: O(|X|^3) time

    Args:
        A: Transfer matrix
        equilibrium: Precomputed equilibrium data
        quotient_classes: Partition representing the quotient

    Returns:
        GaloisData with quotient classes, face functionals, pressure preservation
    """
    n = A.shape[0]
    mu = equilibrium.functional

    # Check if mu factors through the quotient
    factors_through = True
    for cls in quotient_classes:
        vals = [mu[i] for i in cls]
        if max(vals) - min(vals) > 1e-10:
            factors_through = False
            break

    # Build quotient matrix
    k = len(quotient_classes)
    class_map = np.zeros(n, dtype=int)
    for ci, cls in enumerate(quotient_classes):
        for s in cls:
            class_map[s] = ci

    A_quot = np.zeros((k, k))
    for ci, cls_i in enumerate(quotient_classes):
        for cj, cls_j in enumerate(quotient_classes):
            total = 0.0
            for s in cls_i:
                for t in cls_j:
                    total += A[s, t]
            A_quot[ci, cj] = total / len(cls_i)

    # Check pressure preservation
    rho_orig = max(abs(np.linalg.eigvals(A)))
    rho_quot = max(abs(np.linalg.eigvals(A_quot)))
    preserves = abs(np.log(rho_orig) - np.log(rho_quot)) < 1e-8

    face_functionals = []
    if factors_through:
        face_functionals.append(mu)

    return GaloisData(
        quotient_classes=quotient_classes,
        face_functionals=face_functionals,
        preserves_pressure=preserves,
    )


def detect_phases(
    A: np.ndarray, tol: float = 1e-8
) -> Dict:
    """Detect thermodynamic phases via eigenvalue analysis.

    Multiple eigenvalues with the same modulus as the spectral radius
    indicate phase coexistence or periodic structure.

    Complexity: O(|X|^3) time

    Args:
        A: Transfer matrix
        tol: Tolerance for eigenvalue comparison

    Returns:
        Dictionary with phase information
    """
    eigenvalues = np.linalg.eigvals(A)
    rho = max(abs(eigenvalues))

    # Find eigenvalues on the spectral circle
    spectral_circle = [
        ev for ev in eigenvalues if abs(abs(ev) - rho) < tol
    ]

    # Determine periodicity
    if len(spectral_circle) == 1:
        phase_type = "aperiodic (unique equilibrium)"
        period = 1
    else:
        period = len(spectral_circle)
        phase_type = f"periodic with period {period}"

    return {
        'spectral_radius': rho,
        'pressure': np.log(rho) if rho > 0 else float('-inf'),
        'spectral_circle_eigenvalues': spectral_circle,
        'period': period,
        'phase_type': phase_type,
        'n_phases': len(spectral_circle),
    }


def find_canonical_quotient(
    A: np.ndarray, tol: float = 1e-8
) -> List[List[int]]:
    """Find the canonical quotient preserving equilibrium data.

    The canonical quotient is the kernel of the equilibrium functional:
    states receiving equal equilibrium weight are identified.

    Complexity: O(|X|^3) time

    Args:
        A: Transfer matrix
        tol: Tolerance for equivalence

    Returns:
        Partition of states (canonical quotient classes)
    """
    eq_data = compute_equilibrium(A, tol)
    return eq_data.kernel_classes


def verify_submultiplicativity(
    A: np.ndarray, max_n: int = 20
) -> bool:
    """Verify Z_{m+n} <= Z_m * Z_n for all m, n up to max_n.

    Complexity: O(max_n^2 * |X|^3) time

    Args:
        A: Transfer matrix (must have nonneg entries)
        max_n: Maximum path length to check

    Returns:
        True if submultiplicativity holds for all tested (m, n)
    """
    Zs = compute_partition_sums(A, max_n)
    for m in range(max_n + 1):
        for n in range(max_n - m + 1):
            if Zs[m + n] > Zs[m] * Zs[n] * (1 + 1e-10):
                return False
    return True


# ─── Example usage ───

def example_three_state():
    """Run a complete analysis of a 3-state closure system."""
    system = ClosureSystem(
        n_states=3,
        n_generators=4,
        step=[
            {(0, 1), (1, 2)},      # generator 0: rotation-like
            {(2, 0)},              # generator 1: return
            {(0, 0), (1, 1), (2, 2)},  # generator 2: self-loops
            {(0, 2), (1, 0)},      # generator 3: cross-links
        ],
        weights=[0.5, 0.3, 0.1, 0.4],
        state_labels=['A', 'B', 'C'],
    )

    print("Building transfer matrix...")
    A = build_transfer_matrix(system)
    print(f"A =\n{np.round(A, 4)}")

    print("\nComputing equilibrium...")
    eq = compute_equilibrium(A)
    print(f"Eigenvalue: {eq.eigenvalue:.6f}")
    print(f"Pressure:   {eq.pressure:.6f}")
    print(f"Functional: {np.round(eq.functional, 6)}")
    print(f"Kernel:     {eq.kernel_classes}")

    print("\nDetecting phases...")
    phases = detect_phases(A)
    print(f"Phase type: {phases['phase_type']}")

    print("\nVerifying submultiplicativity...")
    ok = verify_submultiplicativity(A)
    print(f"Submultiplicativity verified: {ok}")

    print("\nCanonical quotient:")
    quot = find_canonical_quotient(A)
    print(f"Classes: {quot}")

    return system, A, eq


if __name__ == "__main__":
    example_three_state()


#!/usr/bin/env python3
"""
Applications of Thermodynamic Galois Duality

Demonstrates real-world applications of the thermodynamic Galois duality
framework to problems in state-space minimization, semantic compression,
and phase transition detection.
"""

import numpy as np
from algorithms import (
    ClosureSystem, build_transfer_matrix, compute_equilibrium,
    detect_phases, find_canonical_quotient, compute_galois_maps,
    compute_pressure_sequence, compute_partition_sums
)


def application_state_minimization():
    """Application: Automaton state-space minimization via equilibrium kernels.

    Given a weighted finite automaton, the canonical quotient (kernel of the
    equilibrium functional) identifies states that are thermodynamically
    indistinguishable — they can be merged without affecting the asymptotic
    behavior of the system.
    """
    print("=" * 70)
    print("APPLICATION 1: State-Space Minimization")
    print("=" * 70)

    # A 6-state system with hidden redundancy
    # States 0,1 are equivalent, states 3,4 are equivalent
    n = 6
    A = np.array([
        [0.0, 0.0, 1.5, 0.0, 0.0, 0.5],
        [0.0, 0.0, 1.5, 0.0, 0.0, 0.5],  # same as row 0
        [0.8, 0.8, 0.0, 0.7, 0.7, 0.0],
        [0.5, 0.5, 0.0, 0.0, 0.0, 1.2],
        [0.5, 0.5, 0.0, 0.0, 0.0, 1.2],  # same as row 3
        [0.0, 0.0, 1.0, 0.6, 0.6, 0.0],
    ])

    print(f"\nOriginal system: {n} states")
    eq = compute_equilibrium(A)
    print(f"Equilibrium functional: {np.round(eq.functional, 6)}")
    print(f"Pressure: {eq.pressure:.6f}")

    # Canonical quotient
    classes = find_canonical_quotient(A)
    print(f"\nCanonical quotient classes: {classes}")
    print(f"Reduced system: {len(classes)} states")
    print(f"Compression ratio: {n}/{len(classes)} = {n/len(classes):.1f}x")

    # Verify pressure preservation
    galois = compute_galois_maps(A, eq, classes)
    print(f"Pressure preserved: {galois.preserves_pressure}")


def application_semantic_compression():
    """Application: Semantic compression of language models.

    In a closure-based language dynamics, states represent semantic
    configurations. The Galois connection identifies which semantic
    distinctions matter for asymptotic behavior and which can be
    safely compressed away.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Semantic Compression")
    print("=" * 70)

    # 8-state system modeling semantic transitions
    # Represents a simplified model of topic transitions in text
    np.random.seed(42)
    n = 8
    topics = ['Science', 'Tech', 'Math', 'Physics',
              'Art', 'Music', 'Film', 'Theater']

    # Create transition matrix with semantic clusters
    A = np.zeros((n, n))
    # STEM cluster (0-3): strong internal connections
    for i in range(4):
        for j in range(4):
            A[i, j] = np.exp(np.random.uniform(0.3, 0.8))
    # Arts cluster (4-7): strong internal connections
    for i in range(4, 8):
        for j in range(4, 8):
            A[i, j] = np.exp(np.random.uniform(0.3, 0.8))
    # Weak cross-cluster connections
    for i in range(4):
        for j in range(4, 8):
            A[i, j] = np.exp(np.random.uniform(-1.0, -0.3))
            A[j, i] = np.exp(np.random.uniform(-1.0, -0.3))

    print(f"\nOriginal system: {n} topics")
    for i, t in enumerate(topics):
        print(f"  State {i}: {t}")

    eq = compute_equilibrium(A)
    classes = find_canonical_quotient(A)

    print(f"\nEquilibrium functional: {np.round(eq.functional, 4)}")
    print(f"Pressure: {eq.pressure:.6f}")
    print(f"\nCanonical quotient ({len(classes)} classes):")
    for i, cls in enumerate(classes):
        names = [topics[s] for s in cls]
        weights = [f"{eq.functional[s]:.4f}" for s in cls]
        print(f"  Class {i}: {names} (weights: {weights})")


def application_phase_detection():
    """Application: Phase transition detection in closure dynamics.

    The number of extremal equilibrium states (equivalently, extremal
    characters) indicates the phase structure. A system with a unique
    equilibrium has a single thermodynamic phase; multiple equilibria
    indicate phase coexistence.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Phase Transition Detection")
    print("=" * 70)

    # Parameterized system with a phase transition
    # As coupling parameter beta increases, the system transitions
    # from a unique equilibrium to phase splitting

    print("\nPhase diagram as coupling β varies:")
    print(f"{'β':>6} {'ρ(A)':>10} {'P':>10} {'Period':>8} {'Phase type':>30}")
    print("-" * 70)

    for beta in [0.1, 0.5, 1.0, 1.5, 2.0, 3.0, 5.0]:
        # 4-state system with alternating coupling
        A = np.array([
            [0.0, np.exp(beta), 0.0, np.exp(-beta)],
            [np.exp(beta), 0.0, np.exp(-beta), 0.0],
            [0.0, np.exp(-beta), 0.0, np.exp(beta)],
            [np.exp(-beta), 0.0, np.exp(beta), 0.0],
        ])

        phases = detect_phases(A)
        print(f"{beta:6.1f} {phases['spectral_radius']:10.4f} "
              f"{phases['pressure']:10.4f} {phases['period']:8d} "
              f"{phases['phase_type']:>30}")


def application_convergence_analysis():
    """Application: Convergence rate of pressure estimates.

    Shows how quickly P_n = (1/n) log Z_n converges to the true
    pressure P = log(ρ(A)), demonstrating the practical utility of
    the pressure-spectral radius theorem.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Pressure Convergence Analysis")
    print("=" * 70)

    # Different matrix types and their convergence rates
    examples = {
        'Primitive (fast convergence)': np.array([
            [1.5, 0.5, 0.3],
            [0.4, 1.2, 0.6],
            [0.3, 0.5, 1.4],
        ]),
        'Nearly reducible (slow convergence)': np.array([
            [2.0, 0.01, 0.0],
            [0.0, 1.5, 0.01],
            [0.01, 0.0, 1.8],
        ]),
        'Periodic (oscillating)': np.array([
            [0.0, 2.0, 0.0],
            [0.0, 0.0, 1.5],
            [1.8, 0.0, 0.0],
        ]),
    }

    for name, A in examples.items():
        print(f"\n{name}:")
        pressures, limit = compute_pressure_sequence(A, 50)
        print(f"  True pressure P = {limit:.8f}")
        for n in [1, 5, 10, 25, 50]:
            err = abs(pressures[n-1] - limit)
            print(f"  P_{n:2d} = {pressures[n-1]:.8f}  (error: {err:.2e})")


def main():
    application_state_minimization()
    application_semantic_compression()
    application_phase_detection()
    application_convergence_analysis()

    print("\n" + "=" * 70)
    print("All applications complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Thermodynamic Galois Duality: Demonstrations

This module demonstrates the core concepts of thermodynamic Galois duality
for finite closure dynamical systems with concrete numerical examples.
"""

import numpy as np
from typing import List, Tuple, Dict, Optional

def build_transfer_matrix(
    n_states: int,
    transitions: List[Tuple[int, int, float]],
) -> np.ndarray:
    """Build a weighted transfer matrix from transitions.

    Args:
        n_states: Number of states in the system
        transitions: List of (source, target, weight) triples

    Returns:
        Transfer matrix A where A[target, source] = sum of exp(weight)
        for transitions from source to target
    """
    A = np.zeros((n_states, n_states))
    for src, tgt, w in transitions:
        A[tgt, src] += np.exp(w)
    return A


def partition_sum(A: np.ndarray, n: int) -> float:
    """Compute the partition function Z_n = sum of all entries of A^n."""
    An = np.linalg.matrix_power(A, n)
    return An.sum()


def compute_pressure(A: np.ndarray, max_n: int = 50) -> Tuple[List[float], List[float]]:
    """Compute the pressure P_n = (1/n) * log(Z_n) for n = 1, ..., max_n.

    Returns:
        (ns, pressures): Lists of n values and corresponding pressure estimates
    """
    ns = list(range(1, max_n + 1))
    pressures = []
    for n in ns:
        Zn = partition_sum(A, n)
        if Zn > 0:
            pressures.append(np.log(Zn) / n)
        else:
            pressures.append(float('-inf'))
    return ns, pressures


def spectral_radius(A: np.ndarray) -> float:
    """Compute the spectral radius (largest absolute eigenvalue)."""
    eigenvalues = np.linalg.eigvals(A)
    return max(abs(eigenvalues))


def find_equilibrium(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """Find the equilibrium functional (left Perron eigenvector).

    Returns:
        (eigenvalue, normalized_eigenvector)
    """
    eigenvalues, eigenvectors = np.linalg.eig(A.T)
    # Find the largest real eigenvalue
    real_idx = np.argmax(np.abs(eigenvalues))
    eigval = np.abs(eigenvalues[real_idx])
    eigvec = np.abs(eigenvectors[:, real_idx])
    # Normalize
    eigvec = eigvec / eigvec.sum()
    return eigval, eigvec


def galois_connection_demo(
    A: np.ndarray,
    mu: np.ndarray,
    tolerance: float = 1e-10
) -> Dict:
    """Demonstrate the Galois connection between quotients and equilibria.

    Computes the kernel setoid of the equilibrium functional and shows
    how quotients relate to equilibrium faces.
    """
    n = len(mu)
    # Compute kernel equivalence classes
    classes = {}
    for i in range(n):
        found = False
        for key, members in classes.items():
            if abs(mu[i] - mu[members[0]]) < tolerance:
                members.append(i)
                found = True
                break
        if not found:
            classes[i] = [i]

    return {
        'num_classes': len(classes),
        'classes': list(classes.values()),
        'mu_values': mu.tolist(),
    }


def submultiplicativity_demo(A: np.ndarray, max_n: int = 20) -> Dict:
    """Demonstrate Z_{m+n} <= Z_m * Z_n."""
    Zs = [partition_sum(A, n) for n in range(max_n + 1)]
    violations = []
    examples = []
    for m in range(1, max_n):
        for n in range(1, max_n - m + 1):
            if m + n <= max_n:
                lhs = Zs[m + n]
                rhs = Zs[m] * Zs[n]
                ratio = lhs / rhs if rhs > 0 else float('inf')
                if lhs > rhs * (1 + 1e-10):
                    violations.append((m, n, lhs, rhs))
                if m <= 5 and n <= 5:
                    examples.append({
                        'm': m, 'n': n,
                        'Z_m+n': lhs, 'Z_m * Z_n': rhs,
                        'ratio': ratio
                    })
    return {
        'Zs': Zs,
        'violations': violations,
        'examples': examples[:10]
    }


def character_evaluation(mu: np.ndarray, M: np.ndarray) -> float:
    """Evaluate the equilibrium-weighted sum character.

    chi_mu(M) = sum_y (sum_x M[x,y]) * mu[y]
    """
    col_sums = M.sum(axis=0)
    return np.dot(col_sums, mu)


def main():
    print("=" * 70)
    print("THERMODYNAMIC GALOIS DUALITY — NUMERICAL DEMONSTRATIONS")
    print("=" * 70)

    # Example 1: Simple 3-state closure system
    print("\n" + "─" * 70)
    print("Example 1: 3-state closure system")
    print("─" * 70)

    transitions_1 = [
        (0, 1, 0.5),  # state 0 -> state 1, weight 0.5
        (1, 2, 0.3),  # state 1 -> state 2, weight 0.3
        (2, 0, 0.4),  # state 2 -> state 0, weight 0.4
        (0, 0, 0.1),  # self-loop at state 0
        (1, 1, 0.2),  # self-loop at state 1
        (2, 2, 0.1),  # self-loop at state 2
    ]

    A1 = build_transfer_matrix(3, transitions_1)
    print(f"\nTransfer matrix A:\n{A1}")

    rho = spectral_radius(A1)
    print(f"\nSpectral radius ρ(A) = {rho:.6f}")
    print(f"log(ρ(A)) = {np.log(rho):.6f}")

    ns, pressures = compute_pressure(A1, 30)
    print(f"\nPressure estimates P_n = (1/n) log Z_n:")
    for n in [1, 5, 10, 20, 30]:
        idx = n - 1
        print(f"  n={n:3d}: P_{n} = {pressures[idx]:.6f}")
    print(f"  Limit (log ρ) = {np.log(rho):.6f}")

    eigval, mu = find_equilibrium(A1)
    print(f"\nEquilibrium functional μ = {mu}")
    print(f"Eigenvalue r = {eigval:.6f}")

    galois_info = galois_connection_demo(A1, mu)
    print(f"\nGalois connection:")
    print(f"  Kernel equivalence classes: {galois_info['classes']}")
    print(f"  Number of classes: {galois_info['num_classes']}")

    # Example 2: Symmetric 4-state system with phase structure
    print("\n" + "─" * 70)
    print("Example 2: 4-state system with symmetry (phase structure)")
    print("─" * 70)

    # Two pairs of states with internal strong coupling
    transitions_2 = [
        (0, 1, 1.0), (1, 0, 1.0),  # strong coupling within pair {0,1}
        (2, 3, 1.0), (3, 2, 1.0),  # strong coupling within pair {2,3}
        (0, 2, 0.1), (2, 0, 0.1),  # weak coupling between pairs
        (1, 3, 0.1), (3, 1, 0.1),  # weak coupling between pairs
    ]

    A2 = build_transfer_matrix(4, transitions_2)
    print(f"\nTransfer matrix A:\n{np.round(A2, 3)}")

    rho2 = spectral_radius(A2)
    print(f"\nSpectral radius ρ(A) = {rho2:.6f}")
    print(f"log(ρ(A)) = {np.log(rho2):.6f}")

    eigval2, mu2 = find_equilibrium(A2)
    print(f"\nEquilibrium functional μ = {np.round(mu2, 6)}")

    galois_info2 = galois_connection_demo(A2, mu2)
    print(f"\nGalois connection kernel:")
    print(f"  Classes: {galois_info2['classes']}")
    print(f"  (States within same class have equal equilibrium weight)")

    # Submultiplicativity demonstration
    print("\n" + "─" * 70)
    print("Example 3: Submultiplicativity Z_{m+n} ≤ Z_m · Z_n")
    print("─" * 70)

    submult = submultiplicativity_demo(A1, 15)
    print(f"\n{'m':>3} {'n':>3} {'Z_{m+n}':>14} {'Z_m·Z_n':>14} {'ratio':>10}")
    print("-" * 50)
    for ex in submult['examples'][:8]:
        print(f"{ex['m']:3d} {ex['n']:3d} {ex['Z_m+n']:14.4f} {ex['Z_m * Z_n']:14.4f} {ex['ratio']:10.6f}")
    print(f"\nViolations found: {len(submult['violations'])} (expected: 0)")

    # Character evaluation
    print("\n" + "─" * 70)
    print("Example 4: Character evaluation χ_μ(M)")
    print("─" * 70)

    # Character of A itself
    chi_A = character_evaluation(mu, A1)
    print(f"\nχ_μ(A) = {chi_A:.6f}")
    print(f"Eigenvalue r = {eigval:.6f}")
    print(f"(These should be equal: character of transfer matrix = eigenvalue)")

    # Character of A^2
    A1_sq = A1 @ A1
    chi_A2 = character_evaluation(mu, A1_sq)
    chi_A_sq = chi_A ** 2
    print(f"\nχ_μ(A²) = {chi_A2:.6f}")
    print(f"χ_μ(A)² = {chi_A_sq:.6f}")
    print(f"(Multiplicativity test: these should be approximately equal)")

    # Zero and identity
    chi_0 = character_evaluation(mu, np.zeros_like(A1))
    chi_I = character_evaluation(mu, np.eye(3))
    print(f"\nχ_μ(0) = {chi_0:.6f} (should be 0)")
    print(f"χ_μ(I) = {chi_I:.6f} (= Σ_x μ(x) = 1)")

    # Pressure convergence
    print("\n" + "─" * 70)
    print("Example 5: Pressure convergence")
    print("─" * 70)

    for name, A_mat in [("3-state", A1), ("4-state symmetric", A2)]:
        rho_val = spectral_radius(A_mat)
        ns, ps = compute_pressure(A_mat, 50)
        errors = [abs(p - np.log(rho_val)) for p in ps]
        print(f"\n{name} system:")
        print(f"  log(ρ) = {np.log(rho_val):.8f}")
        print(f"  P_10   = {ps[9]:.8f}  (error: {errors[9]:.2e})")
        print(f"  P_25   = {ps[24]:.8f}  (error: {errors[24]:.2e})")
        print(f"  P_50   = {ps[49]:.8f}  (error: {errors[49]:.2e})")

    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json with all embedded content."""

import json
import sys
import os

# Add project root to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from visualizations import generate_all_visualizations

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def main():
    # Generate visualizations
    vis = generate_all_visualizations()

    # Read all content files
    article = read_file('/workspace/request-project/ARTICLE.md')
    research_paper = read_file('/workspace/request-project/RESEARCH_PAPER.md')
    future_directions = read_file('/workspace/request-project/FUTURE_DIRECTIONS.md')

    # Read Lean proofs
    lean_files = [
        'Bridges/ThermodynamicGalois/Defs.lean',
        'Bridges/ThermodynamicGalois/TransferMatrix.lean',
        'Bridges/ThermodynamicGalois/GaloisDuality.lean',
        'Bridges/ThermodynamicGalois/Characters.lean',
    ]
    lean_proofs = ""
    for f in lean_files:
        path = f'/workspace/request-project/{f}'
        lean_proofs += f"-- ═══ {f} ═══\n\n"
        lean_proofs += read_file(path) + "\n\n"

    # Read demo code
    demo_code = read_file('/workspace/request-project/demo.py')
    algorithms_code = read_file('/workspace/request-project/algorithms.py')
    applications_code = read_file('/workspace/request-project/applications.py')

    # Build package
    package = {
        "title": "Thermodynamic Galois Duality via Closure Pressure Spectra and Equilibrium Correspondence",
        "domain": "Bridges (Algebra–EML Thermodynamic Formalism)",
        "article": article,
        "research_paper": research_paper,
        "future_directions": future_directions,
        "demos": [
            {
                "name": "Thermodynamic Galois Duality Demonstrations",
                "code": demo_code
            },
            {
                "name": "Applications: State Minimization, Compression, Phase Detection",
                "code": applications_code
            }
        ],
        "algorithms": [
            {
                "name": "Transfer Matrix Construction",
                "pseudocode": "Input: (X, Gen, step, w)\nOutput: Matrix A\n\nfor x in X:\n  for y in X:\n    A[x,y] = 0\n    for g in Gen:\n      if step(g, y, x):\n        A[x,y] += exp(w(g))\n\nComplexity: O(|X|^2 * |Gen|)"
            },
            {
                "name": "Pressure Computation via Spectral Radius",
                "pseudocode": "Input: Matrix A\nOutput: Pressure P\n\neigenvalues = eigendecomposition(A)\nrho = max(|lambda| for lambda in eigenvalues)\nP = log(rho)\n\nComplexity: O(|X|^3)"
            },
            {
                "name": "Equilibrium Functional (Perron Eigenvector)",
                "pseudocode": "Input: Nonneg matrix A\nOutput: Normalized left Perron eigenvector mu\n\neigenvalues, eigenvectors = eig(A^T)\nidx = argmax(real(eigenvalues))\nmu = |eigenvectors[:, idx]|\nmu = mu / sum(mu)\n\nComplexity: O(|X|^3)"
            },
            {
                "name": "Canonical Quotient Computation",
                "pseudocode": "Input: Equilibrium functional mu, tolerance eps\nOutput: Partition of X\n\nclasses = []\nfor x in X:\n  placed = False\n  for cls in classes:\n    if |mu[x] - mu[cls[0]]| < eps:\n      cls.append(x); placed = True; break\n  if not placed:\n    classes.append([x])\nreturn classes\n\nComplexity: O(|X|^2)"
            },
            {
                "name": "Galois Connection Maps",
                "pseudocode": "Phi(Q) = {mu : mu factors through Q}\n  = {mu : Q(x,y) => mu(x) = mu(y)}\n\nPsi(F) = intersection of ker(mu) for mu in F\n  = {(x,y) : mu(x) = mu(y) for all mu in F}\n\nGalois property: Q <= Psi(F) iff F <= Phi(Q)"
            }
        ],
        "visualizations": [
            {
                "name": "Pressure Convergence to Spectral Radius",
                "data": vis['pressure_convergence']
            },
            {
                "name": "Thermodynamic Galois Connection",
                "data": vis['galois_connection']
            },
            {
                "name": "Partition Sum Submultiplicativity",
                "data": vis['submultiplicativity']
            },
            {
                "name": "Eigenvalue Spectrum and Equilibrium Functional",
                "data": vis['equilibrium_spectrum']
            }
        ],
        "lean_proofs": lean_proofs
    }

    # Write package
    with open('/workspace/request-project/PACKAGE.json', 'w') as f:
        json.dump(package, f, indent=2, ensure_ascii=False)

    print(f"PACKAGE.json written ({os.path.getsize('/workspace/request-project/PACKAGE.json')} bytes)")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualizations for Thermodynamic Galois Duality

Generates publication-quality figures illustrating the key concepts
and results of the thermodynamic Galois duality theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.colors import LinearSegmentedColormap
import base64
import io


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"


def plot_pressure_convergence():
    """Plot pressure convergence P_n → log(ρ(A)) for different matrix types."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    examples = {
        'Primitive (Fast)': np.array([
            [1.5, 0.5, 0.3],
            [0.4, 1.2, 0.6],
            [0.3, 0.5, 1.4],
        ]),
        'Nearly Reducible (Slow)': np.array([
            [2.0, 0.01, 0.0],
            [0.0, 1.5, 0.01],
            [0.01, 0.0, 1.8],
        ]),
        'Periodic (Oscillating)': np.array([
            [0.0, 2.0, 0.0],
            [0.0, 0.0, 1.5],
            [1.8, 0.0, 0.0],
        ]),
    }

    colors = ['#2196F3', '#FF5722', '#4CAF50']

    for idx, (name, A) in enumerate(examples.items()):
        ax = axes[idx]
        rho = max(abs(np.linalg.eigvals(A)))
        limit = np.log(rho)

        ns = list(range(1, 51))
        pressures = []
        An = np.eye(A.shape[0])
        for n in ns:
            An = An @ A
            Zn = An.sum()
            pressures.append(np.log(Zn) / n if Zn > 0 else float('-inf'))

        ax.plot(ns, pressures, color=colors[idx], linewidth=2, label='$P_n$')
        ax.axhline(y=limit, color='black', linestyle='--', linewidth=1.5,
                   label=f'$\\log\\rho = {limit:.4f}$')
        ax.fill_between(ns, limit - 0.001, limit + 0.001,
                        alpha=0.1, color='gray')
        ax.set_xlabel('$n$ (path length)', fontsize=12)
        ax.set_ylabel('$P_n = \\frac{1}{n}\\log Z_n$', fontsize=12)
        ax.set_title(name, fontsize=13, fontweight='bold')
        ax.legend(fontsize=10, loc='upper right')
        ax.grid(True, alpha=0.3)

    fig.suptitle('Pressure Convergence to Spectral Radius',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    fig.savefig('/workspace/request-project/pressure_convergence.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_galois_connection():
    """Visualize the Galois connection between quotients and equilibrium faces."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Draw the two lattices
    # Left: Quotient lattice (coarse to fine)
    left_x = 2
    quotients = [
        (left_x, 7, '⊤ (all identified)', '#FFE0B2'),
        (left_x - 1, 5, '{0,1}|{2,3}', '#FFF9C4'),
        (left_x + 1, 5, '{0,2}|{1,3}', '#FFF9C4'),
        (left_x, 3, '{0}|{1}|{2}|{3}\n(discrete)', '#C8E6C9'),
    ]

    # Right: Face lattice (small to large)
    right_x = 8
    faces = [
        (right_x, 3, '∅ (empty face)', '#FFE0B2'),
        (right_x - 1, 5, 'Face α', '#FFF9C4'),
        (right_x + 1, 5, 'Face β', '#FFF9C4'),
        (right_x, 7, 'Full simplex\n(all equilibria)', '#C8E6C9'),
    ]

    # Draw nodes
    for items, label_prefix in [(quotients, 'Q'), (faces, 'F')]:
        for x, y, label, color in items:
            circle = plt.Circle((x, y), 0.6, facecolor=color,
                              edgecolor='black', linewidth=2, zorder=3)
            ax.add_patch(circle)
            ax.text(x, y, label, ha='center', va='center',
                   fontsize=8, fontweight='bold', zorder=4)

    # Draw lattice edges
    # Quotient lattice
    for x1, y1 in [(left_x, 7)]:
        for x2, y2 in [(left_x-1, 5), (left_x+1, 5)]:
            ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)
    for x1, y1 in [(left_x-1, 5), (left_x+1, 5)]:
        ax.plot([x1, left_x], [y1, 3], 'k-', linewidth=1.5, zorder=1)

    # Face lattice
    for x1, y1 in [(right_x, 3)]:
        for x2, y2 in [(right_x-1, 5), (right_x+1, 5)]:
            ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, zorder=1)
    for x1, y1 in [(right_x-1, 5), (right_x+1, 5)]:
        ax.plot([x1, right_x], [y1, 7], 'k-', linewidth=1.5, zorder=1)

    # Galois connection arrows
    arrow_style = dict(arrowstyle='->', color='#E91E63',
                       connectionstyle='arc3,rad=0.2', linewidth=2)
    arrow_style_rev = dict(arrowstyle='->', color='#3F51B5',
                           connectionstyle='arc3,rad=-0.2', linewidth=2)

    # Φ arrows (quotient → face) - order-reversing
    ax.annotate('', xy=(right_x-0.7, 7), xytext=(left_x+0.7, 7),
                arrowprops=arrow_style)
    ax.annotate('', xy=(right_x-0.7, 3), xytext=(left_x+0.7, 3),
                arrowprops=arrow_style)

    # Ψ arrows (face → quotient) - order-reversing
    ax.annotate('', xy=(left_x+0.7, 7), xytext=(right_x-0.7, 7),
                arrowprops=arrow_style_rev)
    ax.annotate('', xy=(left_x+0.7, 3), xytext=(right_x-0.7, 3),
                arrowprops=arrow_style_rev)

    # Labels
    ax.text(5, 8.5, 'Φ (quotient → face)', color='#E91E63',
           fontsize=12, ha='center', fontweight='bold')
    ax.text(5, 1.5, 'Ψ (face → quotient)', color='#3F51B5',
           fontsize=12, ha='center', fontweight='bold')

    ax.text(left_x, 9, 'Closure Quotients\n(order-reversed)',
           ha='center', fontsize=13, fontweight='bold')
    ax.text(right_x, 9, 'Equilibrium Faces',
           ha='center', fontsize=13, fontweight='bold')

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(1, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Thermodynamic Galois Connection',
                fontsize=16, fontweight='bold', pad=20)

    fig.savefig('/workspace/request-project/galois_connection.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_submultiplicativity():
    """Visualize submultiplicativity Z_{m+n} ≤ Z_m · Z_n."""
    A = np.array([
        [1.5, 0.5, 0.3],
        [0.4, 1.2, 0.6],
        [0.3, 0.5, 1.4],
    ])

    max_n = 15
    Zs = []
    An = np.eye(3)
    for n in range(max_n + 1):
        Zs.append(An.sum())
        An = An @ A

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Z_n growth
    ns = list(range(max_n + 1))
    ax1.semilogy(ns, Zs, 'o-', color='#2196F3', linewidth=2, markersize=6)
    ax1.set_xlabel('$n$', fontsize=13)
    ax1.set_ylabel('$Z_n = \\sum_{x,y} (A^n)_{xy}$', fontsize=13)
    ax1.set_title('Partition Function Growth', fontsize=14, fontweight='bold')
    ax1.grid(True, alpha=0.3)

    # Right: Submultiplicativity ratios
    ratios = np.zeros((max_n, max_n))
    for m in range(1, max_n):
        for n in range(1, max_n):
            if m + n <= max_n:
                ratios[m, n] = Zs[m + n] / (Zs[m] * Zs[n])

    im = ax2.imshow(ratios[1:max_n, 1:max_n], cmap='YlOrRd_r',
                    vmin=0, vmax=1, aspect='equal',
                    extent=[0.5, max_n-0.5, max_n-0.5, 0.5])
    ax2.set_xlabel('$n$', fontsize=13)
    ax2.set_ylabel('$m$', fontsize=13)
    ax2.set_title('$Z_{m+n} / (Z_m \\cdot Z_n) \\leq 1$',
                  fontsize=14, fontweight='bold')
    plt.colorbar(im, ax=ax2, label='Ratio', shrink=0.8)

    plt.tight_layout()
    fig.savefig('/workspace/request-project/submultiplicativity.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def plot_equilibrium_spectrum():
    """Visualize the eigenvalue spectrum and equilibrium functional."""
    A = np.array([
        [0.0, 2.718, 1.105, 0.0],
        [2.718, 0.0, 0.0, 1.105],
        [1.105, 0.0, 0.0, 2.718],
        [0.0, 1.105, 2.718, 0.0],
    ])

    eigenvalues = np.linalg.eigvals(A)
    rho = max(abs(eigenvalues))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Eigenvalue spectrum
    theta = np.linspace(0, 2*np.pi, 100)
    ax1.plot(rho * np.cos(theta), rho * np.sin(theta),
             'k--', alpha=0.3, label='Spectral circle')
    for ev in eigenvalues:
        color = '#E91E63' if abs(abs(ev) - rho) < 0.01 else '#2196F3'
        ax1.plot(ev.real, ev.imag, 'o', color=color, markersize=12,
                markeredgecolor='black', markeredgewidth=1.5)
    ax1.axhline(y=0, color='gray', linewidth=0.5)
    ax1.axvline(x=0, color='gray', linewidth=0.5)
    ax1.set_xlabel('Re(λ)', fontsize=13)
    ax1.set_ylabel('Im(λ)', fontsize=13)
    ax1.set_title('Eigenvalue Spectrum of Transfer Matrix',
                  fontsize=14, fontweight='bold')
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.2)
    ax1.legend(fontsize=10)

    # Equilibrium functional
    eigenvalues_t, eigenvectors_t = np.linalg.eig(A.T)
    idx = np.argmax(eigenvalues_t.real)
    mu = np.abs(eigenvectors_t[:, idx].real)
    mu = mu / mu.sum()

    states = ['State 0', 'State 1', 'State 2', 'State 3']
    colors = ['#2196F3', '#FF5722', '#4CAF50', '#FF9800']
    bars = ax2.bar(states, mu, color=colors, edgecolor='black', linewidth=1.5)
    ax2.set_ylabel('$\\mu(x)$', fontsize=13)
    ax2.set_title('Equilibrium Functional',
                  fontsize=14, fontweight='bold')
    ax2.set_ylim(0, max(mu) * 1.2)
    for bar, val in zip(bars, mu):
        ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.005,
                f'{val:.4f}', ha='center', fontsize=11, fontweight='bold')
    ax2.grid(True, alpha=0.2, axis='y')

    plt.tight_layout()
    fig.savefig('/workspace/request-project/equilibrium_spectrum.png',
                dpi=150, bbox_inches='tight', facecolor='white')
    b64 = fig_to_base64(fig)
    return b64


def generate_all_visualizations():
    """Generate all visualizations and return base64 data."""
    print("Generating visualizations...")

    vis = {}
    vis['pressure_convergence'] = plot_pressure_convergence()
    print("  ✓ Pressure convergence")

    vis['galois_connection'] = plot_galois_connection()
    print("  ✓ Galois connection")

    vis['submultiplicativity'] = plot_submultiplicativity()
    print("  ✓ Submultiplicativity")

    vis['equilibrium_spectrum'] = plot_equilibrium_spectrum()
    print("  ✓ Equilibrium spectrum")

    print("All visualizations generated.")
    return vis


if __name__ == "__main__":
    vis = generate_all_visualizations()
    for name, data in vis.items():
        print(f"{name}: {len(data)} chars")
