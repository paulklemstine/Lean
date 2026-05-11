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