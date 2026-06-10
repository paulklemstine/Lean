#!/usr/bin/env python3
"""
Algorithms for Berggren dynamics on finite quadratic shells.

Implements the core spectral analysis algorithms and provides
tools for computing shell sizes, orbit structures, and spectral gaps.
"""

import numpy as np
from itertools import product
from typing import List, Tuple, Dict, Optional, Set

# ============================================================
# Berggren Generators
# ============================================================

BERGGREN_GENERATORS: List[np.ndarray] = [
    np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),   # B₁
    np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),       # B₂
    np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),    # B₃
]

BERGGREN_INVERSES: List[np.ndarray] = [
    np.array([[1, 2, -2], [-2, -1, 2], [-2, -2, 3]]),   # B₁⁻¹
    np.array([[1, 2, -2], [2, 1, -2], [-2, -2, 3]]),     # B₂⁻¹
    np.array([[-1, -2, 2], [2, 1, -2], [-2, -2, 3]]),    # B₃⁻¹
]

LORENTZ_METRIC = np.diag([1, 1, -1])


def quadratic_form(v: Tuple[int, ...], q: int) -> int:
    """Compute Q(v) = v₀² + v₁² - v₂² mod q."""
    return (v[0]**2 + v[1]**2 - v[2]**2) % q


def mulvec_mod(M: np.ndarray, v: Tuple[int, ...], q: int) -> Tuple[int, ...]:
    """Matrix-vector product mod q."""
    result = M @ np.array(v)
    return tuple(int(x) % q for x in result)


# ============================================================
# Shell Computation
# ============================================================

def compute_shell(q: int) -> List[Tuple[int, ...]]:
    """Compute Shell(q) = {v ∈ (Z/qZ)³ : Q(v) = 0, v ≠ 0}.
    
    Time: O(q³)
    Space: O(|Shell(q)|) = O(q²)
    """
    shell = []
    for x, y, z in product(range(q), repeat=3):
        v = (x, y, z)
        if v != (0, 0, 0) and quadratic_form(v, q) == 0:
            shell.append(v)
    return shell


def compute_orbits(q: int, shell: List[Tuple[int, ...]]) -> List[List[Tuple[int, ...]]]:
    """Compute orbits of the Berggren action on Shell(q).
    
    Uses BFS through generators and their inverses.
    
    Time: O(|Shell(q)| · 6)  per orbit expansion
    Space: O(|Shell(q)|)
    """
    shell_set = set(shell)
    visited: Set[Tuple[int, ...]] = set()
    orbits: List[List[Tuple[int, ...]]] = []
    
    all_matrices = [M % q for M in BERGGREN_GENERATORS + BERGGREN_INVERSES]
    
    for start in shell:
        if start in visited:
            continue
        orbit = []
        queue = [start]
        while queue:
            v = queue.pop()
            if v in visited:
                continue
            visited.add(v)
            orbit.append(v)
            for M in all_matrices:
                w = mulvec_mod(M, v, q)
                if w in shell_set and w not in visited:
                    queue.append(w)
        orbits.append(orbit)
    
    return orbits


# ============================================================
# Averaging Operator & Spectral Analysis
# ============================================================

def build_averaging_matrix(
    q: int, 
    points: List[Tuple[int, ...]]
) -> np.ndarray:
    """Build the Berggren averaging matrix T_q on a given point set.
    
    T_q f(x) = (1/3) Σᵢ f(Bᵢ⁻¹ x)
    
    Args:
        q: modulus
        points: list of points (subset of Shell(q))
    
    Returns:
        n×n matrix T where n = len(points)
    
    Time: O(n · 3) where n = len(points)
    """
    n = len(points)
    idx = {v: i for i, v in enumerate(points)}
    T = np.zeros((n, n))
    
    inv_mats = [M % q for M in BERGGREN_INVERSES]
    
    for i, v in enumerate(points):
        for Minv in inv_mats:
            w = mulvec_mod(Minv, v, q)
            if w in idx:
                T[i, idx[w]] += 1.0 / 3.0
    
    return T


def spectral_analysis(
    T: np.ndarray
) -> Dict:
    """Perform full spectral analysis of an averaging matrix.
    
    Returns eigenvalues, spectral gap, and contraction rate.
    
    Time: O(n³) for eigenvalue computation
    """
    n = T.shape[0]
    if n == 0:
        return {'n': 0, 'eigenvalues': [], 'lambda2': 0, 'gap': 1}
    
    eigenvalues = np.linalg.eigvals(T)
    abs_eigs = sorted([abs(e) for e in eigenvalues], reverse=True)
    
    lambda1 = abs_eigs[0]
    lambda2 = abs_eigs[1] if len(abs_eigs) > 1 else 0
    
    # Mean-zero eigenvalues (all except the largest)
    mean_zero_eigs = sorted(eigenvalues, key=lambda x: -abs(x))[1:]
    max_mean_zero = max([abs(e) for e in mean_zero_eigs]) if mean_zero_eigs else 0
    
    return {
        'n': n,
        'eigenvalues': sorted(eigenvalues, key=lambda x: -abs(x)),
        'lambda1': lambda1,
        'lambda2': lambda2,
        'max_mean_zero': max_mean_zero,
        'gap': 1 - max_mean_zero,
        'rho': max_mean_zero**2,
    }


def mixing_simulation(
    T: np.ndarray,
    f0: np.ndarray,
    steps: int = 20
) -> List[float]:
    """Simulate mixing: compute ‖T^k f‖²/‖f‖² for k = 0, ..., steps.
    
    Args:
        T: averaging matrix
        f0: initial mean-zero function
        steps: number of iterations
    
    Returns:
        list of ratios ‖T^k f‖²/‖f‖²
    
    Time: O(steps · n²)
    """
    f = f0.copy()
    norm0_sq = np.sum(f**2)
    ratios = []
    for _ in range(steps + 1):
        ratios.append(np.sum(f**2) / norm0_sq if norm0_sq > 0 else 0)
        f = T @ f
    return ratios


# ============================================================
# Variance Formula
# ============================================================

def compute_variance(
    q: int,
    points: List[Tuple[int, ...]],
    f: np.ndarray
) -> float:
    """Compute the Berggren variance: Δ(f) = l2sq(f) - l2sq(T_q f).
    
    By the variance formula:
    Δ(f) = (1/9) Σ_x Σ_{i<j} ‖f(B_i⁻¹x) - f(B_j⁻¹x)‖²
    
    Time: O(n · 3)
    """
    idx = {v: i for i, v in enumerate(points)}
    inv_mats = [M % q for M in BERGGREN_INVERSES]
    
    variance = 0.0
    for x_idx, v in enumerate(points):
        vals = []
        for Minv in inv_mats:
            w = mulvec_mod(Minv, v, q)
            if w in idx:
                vals.append(f[idx[w]])
            else:
                vals.append(0)
        
        for i in range(3):
            for j in range(i+1, 3):
                variance += abs(vals[i] - vals[j])**2
    
    return variance / 9.0


# ============================================================
# Shell Size Formulas
# ============================================================

def shell_size_formula(p: int) -> int:
    """For odd prime p, |Shell(p)| = p² - 1.
    
    The isotropic cone of Q = x² + y² - z² over F_p has:
    - p² points including the origin
    - Minus 1 for the origin
    So |Shell(p)| = p² - 1.
    """
    return p * p - 1


def verify_shell_sizes():
    """Verify |Shell(p)| = p² - 1 for small odd primes."""
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    print("Verification: |Shell(p)| = p² - 1")
    print(f"{'p':>5} {'computed':>10} {'formula':>10} {'match':>6}")
    for p in primes:
        shell = compute_shell(p)
        expected = shell_size_formula(p)
        print(f"{p:>5} {len(shell):>10} {expected:>10} {'✓' if len(shell) == expected else '✗':>6}")


if __name__ == "__main__":
    verify_shell_sizes()
    
    print("\n=== Orbit-level Spectral Analysis ===")
    for q in [5, 7, 11, 13]:
        shell = compute_shell(q)
        orbits = compute_orbits(q, shell)
        print(f"\nq = {q}: |Shell| = {len(shell)}, {len(orbits)} orbit(s)")
        
        for oi, orbit in enumerate(orbits):
            T = build_averaging_matrix(q, orbit)
            result = spectral_analysis(T)
            print(f"  Orbit {oi+1}: size={len(orbit)}, "
                  f"λ₂={result['lambda2']:.4f}, "
                  f"mean-zero max={result['max_mean_zero']:.4f}, "
                  f"gap={result['gap']:.4f}")
