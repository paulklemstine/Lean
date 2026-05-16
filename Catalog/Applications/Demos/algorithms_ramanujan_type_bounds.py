#!/usr/bin/env python3
"""
Algorithms for Berggren Spectral Dynamics

Implements the core algorithms from the spectral theory of the Berggren tree:
1. Berggren triple generation and tree traversal
2. Sibling transition operator and spectral decomposition
3. Observable averaging and discrepancy computation
4. Mixing time estimation
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


# ============================================================================
# Core Data Structures
# ============================================================================

@dataclass
class BerggrenTriple:
    """A primitive Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int
    depth: int = 0
    word: str = ""

    def is_pythagorean(self) -> bool:
        return self.a**2 + self.b**2 == self.c**2

    def as_vector(self) -> np.ndarray:
        return np.array([self.a, self.b, self.c])

    def lorentz_form(self) -> int:
        return self.a**2 + self.b**2 - self.c**2

    def ratio(self) -> float:
        """The ratio a/c, a key projective coordinate."""
        return self.a / self.c if self.c != 0 else 0.0


# ============================================================================
# Algorithm 1: Berggren Tree Generation
# ============================================================================

# Generator matrices
GENERATORS = {
    'A': np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    'B': np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    'C': np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
}

ROOT = BerggrenTriple(3, 4, 5, depth=0, word="")


def generate_berggren_tree(max_depth: int) -> List[BerggrenTriple]:
    """
    Generate all Berggren triples up to a given depth.

    Algorithm: BFS traversal of the ternary Berggren tree.
    Time complexity: O(3^d) where d = max_depth.
    Space complexity: O(3^d).

    Each node has exactly 3 children (one per generator A, B, C).
    The tree is a complete ternary tree, so depth d produces 3^d leaves.

    Args:
        max_depth: Maximum depth to generate.

    Returns:
        List of all BerggrenTriple objects at depth ≤ max_depth.
    """
    all_triples = [ROOT]
    current_layer = [ROOT]

    for depth in range(1, max_depth + 1):
        next_layer = []
        for parent in current_layer:
            v = parent.as_vector()
            for name, gen in GENERATORS.items():
                child_v = gen @ v
                child = BerggrenTriple(
                    a=int(child_v[0]), b=int(child_v[1]), c=int(child_v[2]),
                    depth=depth,
                    word=parent.word + name
                )
                next_layer.append(child)
                all_triples.append(child)
        current_layer = next_layer

    return all_triples


def generate_depth_n_triples(n: int) -> List[BerggrenTriple]:
    """Generate only the triples at exact depth n."""
    if n == 0:
        return [ROOT]

    current = [ROOT]
    for depth in range(1, n + 1):
        next_layer = []
        for parent in current:
            v = parent.as_vector()
            for name, gen in GENERATORS.items():
                child_v = gen @ v
                child = BerggrenTriple(
                    a=int(child_v[0]), b=int(child_v[1]), c=int(child_v[2]),
                    depth=depth,
                    word=parent.word + name
                )
                next_layer.append(child)
        current = next_layer
    return current


# ============================================================================
# Algorithm 2: Sibling Transition Operator
# ============================================================================

def sibling_transition_matrix(n: int = 3) -> np.ndarray:
    """
    Construct the sibling transition matrix for the K_n random walk.

    The matrix T has T[i,j] = 1/(n-1) for i ≠ j and T[i,i] = 0.
    This is the random walk on the complete graph K_n.

    For Berggren dynamics (n=3):
    - Eigenvalue 1 with eigenvector (1,1,1)/√3
    - Eigenvalue -1/(n-1) = -1/2 with multiplicity n-1 = 2

    Spectral gap: ρ = 1/(n-1) = 1/2.

    Args:
        n: Number of vertices (default 3 for Berggren siblings).

    Returns:
        n×n transition matrix.
    """
    T = np.ones((n, n)) / (n - 1)
    np.fill_diagonal(T, 0)
    return T


def spectral_decomposition(T: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute the spectral decomposition of a symmetric transition matrix.

    Returns eigenvalues (sorted descending) and eigenvectors.
    """
    eigenvalues, eigenvectors = np.linalg.eigh(T)
    idx = np.argsort(eigenvalues)[::-1]
    return eigenvalues[idx], eigenvectors[:, idx]


def compute_spectral_gap(T: np.ndarray) -> float:
    """
    Compute the spectral gap: 1 - |λ₂| where λ₂ is the second-largest
    eigenvalue in absolute value.

    For an expander, this is strictly positive.
    """
    eigenvalues = np.linalg.eigvalsh(T)
    sorted_eigs = sorted(np.abs(eigenvalues), reverse=True)
    return 1.0 - sorted_eigs[1] if len(sorted_eigs) > 1 else 1.0


# ============================================================================
# Algorithm 3: Observable Averaging and Contraction
# ============================================================================

def apply_operator_iterate(T: np.ndarray, f: np.ndarray, k: int) -> np.ndarray:
    """
    Apply the operator T to function f exactly k times: T^k f.

    Uses repeated matrix-vector multiplication for efficiency.
    Time complexity: O(k · n²) where n = dimension.

    Args:
        T: Transition matrix.
        f: Function values (vector).
        k: Number of iterations.

    Returns:
        T^k f.
    """
    result = f.copy()
    for _ in range(k):
        result = T @ result
    return result


def l2_norm_sq(f: np.ndarray) -> float:
    """Compute ∑ f_i² (l² norm squared)."""
    return float(np.sum(f**2))


def contraction_rate(T: np.ndarray, f: np.ndarray) -> float:
    """
    Compute the contraction rate ||Tf||₂ / ||f||₂ for a given function.

    For mean-zero f on K₃ walk, this should be exactly 1/2.
    """
    norm_f = np.linalg.norm(f)
    if norm_f < 1e-15:
        return 0.0
    return np.linalg.norm(T @ f) / norm_f


def center_function(f: np.ndarray) -> np.ndarray:
    """Make a function mean-zero by subtracting its mean."""
    return f - f.mean()


# ============================================================================
# Algorithm 4: Mixing Time Estimation
# ============================================================================

def mixing_time_bound(rho: float, n_states: int, epsilon: float = 0.01) -> float:
    """
    Estimate the mixing time for a Markov chain with spectral gap 1-ρ.

    The mixing time to reach total variation distance ε from stationarity
    satisfies: t_mix(ε) ≤ log(n/ε) / log(1/ρ).

    For the Berggren sibling walk with ρ = 1/2:
    - n = 3 states
    - t_mix(0.01) ≤ log(300) / log(2) ≈ 8.2

    Args:
        rho: Spectral parameter (second eigenvalue magnitude).
        n_states: Number of states.
        epsilon: Target total variation distance.

    Returns:
        Upper bound on mixing time.
    """
    if rho >= 1.0 or rho <= 0:
        return float('inf')
    return np.log(n_states / epsilon) / np.log(1.0 / rho)


def discrepancy_bound(B: float, rho: float, k: int, n_states: int = 3) -> float:
    """
    Compute the discrepancy bound for a B-bounded observable after k steps.

    ||T^k(f - mean)||₂² ≤ ρ^(2k) · n · (2B)²

    For the Berggren walk:
    - ρ = 1/2
    - n = 3
    - bound = (1/4)^k · 12B²

    Args:
        B: Bound on the observable (|f| ≤ B).
        rho: Spectral parameter.
        k: Number of iterations.
        n_states: Number of states.

    Returns:
        Upper bound on l² norm squared of discrepancy.
    """
    return rho**(2*k) * n_states * (2*B)**2


# ============================================================================
# Algorithm 5: Lorentz Form Analysis
# ============================================================================

Q_MATRIX = np.diag([1, 1, -1])

def lorentz_form(v: np.ndarray) -> float:
    """Compute Q(v) = v₀² + v₁² - v₂²."""
    return float(v @ Q_MATRIX @ v)


def berggren_sum_lorentz_action(v: np.ndarray) -> float:
    """
    Compute Q(Sv) using the identity S^T Q S = diag(1,1,-9).

    Q(Sv) = v₀² + v₁² - 9v₂²

    For Pythagorean v (Q(v) = 0): Q(Sv) = -8v₂² = -8c².
    """
    return v[0]**2 + v[1]**2 - 9 * v[2]**2


def spatial_contraction_factor() -> float:
    """
    The spatial contraction factor of the averaged Berggren operator.

    Under the Lorentz form, the spatial components (a,b) contribute at rate 1
    while the temporal component (c) contributes at rate 9.
    The contraction factor on spatial components is 1/9.
    """
    return 1.0 / 9.0


# ============================================================================
# Algorithm 6: Depth Statistics
# ============================================================================

def depth_statistics(depth: int) -> dict:
    """
    Compute statistics of Berggren triples at a given depth.

    Returns dictionary with:
    - count: number of triples
    - mean_ratio: average a/c ratio
    - std_ratio: standard deviation of a/c
    - min_hypotenuse: smallest c
    - max_hypotenuse: largest c
    - mean_hypotenuse: average c
    """
    triples = generate_depth_n_triples(depth)

    ratios = [t.ratio() for t in triples]
    hyps = [t.c for t in triples]

    return {
        'count': len(triples),
        'mean_ratio': np.mean(ratios),
        'std_ratio': np.std(ratios),
        'min_hypotenuse': min(hyps),
        'max_hypotenuse': max(hyps),
        'mean_hypotenuse': np.mean(hyps),
        'all_pythagorean': all(t.is_pythagorean() for t in triples)
    }


# ============================================================================
# Main: Run All Algorithms
# ============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("BERGGREN SPECTRAL DYNAMICS: Algorithm Demonstrations")
    print("=" * 70)

    # Algorithm 1: Generate triples
    print("\n--- Algorithm 1: Tree Generation ---")
    triples = generate_berggren_tree(4)
    print(f"Total triples up to depth 4: {len(triples)}")
    for d in range(5):
        count = sum(1 for t in triples if t.depth == d)
        print(f"  Depth {d}: {count} triples")

    # Algorithm 2: Spectral decomposition
    print("\n--- Algorithm 2: Spectral Decomposition ---")
    T = sibling_transition_matrix(3)
    eigs, vecs = spectral_decomposition(T)
    gap = compute_spectral_gap(T)
    print(f"Eigenvalues: {eigs}")
    print(f"Spectral gap: {gap:.4f}")
    print(f"ρ = 1/2 confirmed: {np.isclose(1 - gap, 0.5)}")

    # Algorithm 3: Contraction verification
    print("\n--- Algorithm 3: Observable Contraction ---")
    f = np.array([1.0, -0.3, -0.7])  # mean-zero
    for k in range(6):
        Tkf = apply_operator_iterate(T, f, k)
        norm_sq = l2_norm_sq(Tkf)
        bound = (0.25)**k * l2_norm_sq(f)
        print(f"  k={k}: ||T^k f||² = {norm_sq:.8f}, bound = {bound:.8f}")

    # Algorithm 4: Mixing time
    print("\n--- Algorithm 4: Mixing Time ---")
    for eps in [0.1, 0.01, 0.001]:
        t_mix = mixing_time_bound(0.5, 3, eps)
        print(f"  t_mix({eps}) ≤ {t_mix:.2f}")

    # Algorithm 5: Lorentz analysis
    print("\n--- Algorithm 5: Lorentz Form ---")
    v = np.array([3.0, 4.0, 5.0])
    S = sum(GENERATORS.values())
    Sv = S @ v
    print(f"v = {v}, Q(v) = {lorentz_form(v)}")
    print(f"Sv = {Sv}, Q(Sv) = {lorentz_form(Sv)}")
    print(f"Identity: Q(Sv) = v0² + v1² - 9v2² = {berggren_sum_lorentz_action(v)}")

    # Algorithm 6: Depth statistics
    print("\n--- Algorithm 6: Depth Statistics ---")
    for d in range(6):
        stats = depth_statistics(d)
        print(f"  Depth {d}: {stats['count']} triples, "
              f"mean(a/c) = {stats['mean_ratio']:.4f}, "
              f"hyp range = [{stats['min_hypotenuse']}, {stats['max_hypotenuse']}]")
