#!/usr/bin/env python3
"""
Tropical KAM Stability — Algorithms

Implements the core algorithms from the tropical KAM stability theory:
1. Tropical Diophantine checker (exact and approximate)
2. Optimal Diophantine constant computation
3. Resonance finder and classifier
4. KAM persistence radius computation
5. Resonance profile comparison
6. Tropical rotation vector computation

All algorithms include docstrings, type hints, complexity analysis, and examples.
"""

import numpy as np
import itertools
from typing import List, Tuple, Optional, Set, Dict
from dataclasses import dataclass
from fractions import Fraction


# ============================================================
# Data Structures
# ============================================================

@dataclass
class DiophantineResult:
    """Result of a Tropical Diophantine check."""
    is_diophantine: bool
    optimal_constant: float
    worst_vector: Optional[np.ndarray]
    worst_gap: float
    scale: int
    vectors_checked: int


@dataclass
class ResonanceInfo:
    """Information about a resonance."""
    vector: np.ndarray
    l1_norm: int
    inner_product: float
    is_exact: bool  # within tolerance


@dataclass
class PersistenceResult:
    """Result of a KAM persistence analysis."""
    diophantine_constant: float
    persistence_radius: float
    scale: int
    perturbed_constant: float  # C/2 for the perturbed system
    resonance_profile_preserved: bool


# ============================================================
# Algorithm 1: Lattice Vector Enumeration
# ============================================================

def enumerate_l1_ball(n: int, K: int) -> List[np.ndarray]:
    """
    Enumerate all integer vectors in Z^n with L1 norm <= K.
    
    Algorithm: Recursive generation with early pruning.
    Time complexity: O(K^n) (unavoidable for complete enumeration)
    Space complexity: O(K^n) for the result list
    
    Args:
        n: Dimension
        K: Maximum L1 norm
    
    Returns:
        List of all k in Z^n with ||k||_1 <= K
    
    Example:
        >>> vecs = enumerate_l1_ball(2, 1)
        >>> len(vecs)  # (0,0), (±1,0), (0,±1)
        5
    """
    if n == 0:
        return [np.array([], dtype=int)]
    
    results = []
    _enumerate_recursive(n, K, [], 0, results)
    return results


def _enumerate_recursive(n: int, remaining: int, prefix: list, 
                         depth: int, results: list):
    """Recursive helper for lattice vector enumeration with pruning."""
    if depth == n:
        results.append(np.array(prefix, dtype=int))
        return
    
    for val in range(-remaining, remaining + 1):
        new_remaining = remaining - abs(val)
        if new_remaining >= 0:
            prefix.append(val)
            _enumerate_recursive(n, new_remaining, prefix, depth + 1, results)
            prefix.pop()


# ============================================================
# Algorithm 2: Tropical Diophantine Checker
# ============================================================

def check_tropical_diophantine(K: int, C: float, omega: np.ndarray,
                                verbose: bool = False) -> DiophantineResult:
    """
    Check whether omega satisfies TropicalDiophantine(K, C).
    
    Algorithm:
        1. Enumerate all k in Z^n with 0 < ||k||_1 <= K
        2. For each k, compute |<k, omega>|
        3. Check C <= |<k, omega>|
        4. Track the minimizing vector
    
    Time complexity: O((2K+1)^n) for enumeration, O(n) per inner product
    Space complexity: O(n) working space (vectors generated lazily)
    
    Args:
        K: Scale parameter (maximum L1 norm)
        C: Gap constant (lower bound on |<k, omega>|)
        omega: Frequency vector in R^n
        verbose: Print details of failing vectors
    
    Returns:
        DiophantineResult with full analysis
    
    Example:
        >>> omega = np.array([1.0, (1 + np.sqrt(5)) / 2])
        >>> result = check_tropical_diophantine(5, 0.01, omega)
        >>> result.is_diophantine
        True
    """
    n = len(omega)
    min_gap = float('inf')
    worst_k = None
    vectors_checked = 0
    is_diophantine = True
    
    for k in _generate_nonzero_l1_ball(n, K):
        vectors_checked += 1
        gap = abs(float(np.dot(k.astype(float), omega)))
        
        if gap < min_gap:
            min_gap = gap
            worst_k = k.copy()
        
        if gap < C:
            is_diophantine = False
            if verbose:
                print(f"  FAIL: k={k}, |<k,ω>|={gap:.2e} < C={C}")
    
    return DiophantineResult(
        is_diophantine=is_diophantine,
        optimal_constant=min_gap,
        worst_vector=worst_k,
        worst_gap=min_gap,
        scale=K,
        vectors_checked=vectors_checked
    )


def _generate_nonzero_l1_ball(n: int, K: int):
    """Generate nonzero vectors in Z^n with L1 norm <= K."""
    ranges = [range(-K, K + 1) for _ in range(n)]
    for combo in itertools.product(*ranges):
        k = np.array(combo, dtype=int)
        norm = int(np.sum(np.abs(k)))
        if 0 < norm <= K:
            yield k


# ============================================================
# Algorithm 3: Optimal Diophantine Constant
# ============================================================

def optimal_diophantine_constant(K: int, omega: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the largest C for which omega is (K, C)-Diophantine.
    
    C*(K, omega) = min { |<k, omega>| : k in Z^n, 0 < ||k||_1 <= K }
    
    Time complexity: O((2K+1)^n · n)
    Space complexity: O(n)
    
    Args:
        K: Scale parameter
        omega: Frequency vector
    
    Returns:
        (C_star, k_star) where C_star is the optimal constant and
        k_star is the minimizing lattice vector
    
    Example:
        >>> omega = np.array([1.0, np.sqrt(2)])
        >>> C, k = optimal_diophantine_constant(5, omega)
        >>> C > 0  # irrational frequencies have positive gap
        True
    """
    result = check_tropical_diophantine(K, 0.0, omega)
    return result.optimal_constant, result.worst_vector


# ============================================================
# Algorithm 4: Resonance Finder
# ============================================================

def find_all_resonances(K: int, omega: np.ndarray, 
                        tol: float = 1e-10) -> List[ResonanceInfo]:
    """
    Find all resonance vectors of omega up to scale K.
    
    A resonance is k in Z^n with ||k||_1 <= K and |<k, omega>| < tol.
    
    Time complexity: O((2K+1)^n · n)
    Space complexity: O(R · n) where R is the number of resonances
    
    Args:
        K: Maximum L1 norm to search
        omega: Frequency vector
        tol: Numerical tolerance for identifying resonances
    
    Returns:
        List of ResonanceInfo objects
    
    Example:
        >>> omega = np.array([1.0, 0.5])  # rational, admits resonances
        >>> res = find_all_resonances(5, omega)
        >>> len(res) > 0
        True
    """
    resonances = []
    for k in _generate_nonzero_l1_ball(len(omega), K):
        inner = float(np.dot(k.astype(float), omega))
        norm = int(np.sum(np.abs(k)))
        if abs(inner) < tol:
            resonances.append(ResonanceInfo(
                vector=k.copy(),
                l1_norm=norm,
                inner_product=inner,
                is_exact=(abs(inner) < 1e-15)
            ))
    return resonances


# ============================================================
# Algorithm 5: KAM Persistence Radius
# ============================================================

def kam_persistence_radius(K: int, omega: np.ndarray) -> PersistenceResult:
    """
    Compute the KAM persistence radius for frequency omega at scale K.
    
    The persistence radius is C/(2K) where C = C*(K, omega) is the
    optimal Diophantine constant. Any perturbation smaller than this
    radius (in sup-norm) preserves the resonance profile.
    
    Time complexity: O((2K+1)^n · n) for Diophantine constant computation
    Space complexity: O(n)
    
    Args:
        K: Scale parameter
        omega: Frequency vector
    
    Returns:
        PersistenceResult with radius and related data
    
    Example:
        >>> omega = np.array([1.0, (1 + np.sqrt(5)) / 2])
        >>> result = kam_persistence_radius(5, omega)
        >>> result.persistence_radius > 0
        True
    """
    C, _ = optimal_diophantine_constant(K, omega)
    radius = C / (2 * K) if K > 0 else float('inf')
    
    return PersistenceResult(
        diophantine_constant=C,
        persistence_radius=radius,
        scale=K,
        perturbed_constant=C / 2,
        resonance_profile_preserved=True  # guaranteed within radius
    )


# ============================================================
# Algorithm 6: Resonance Profile Comparison
# ============================================================

def compare_resonance_profiles(K: int, omega1: np.ndarray, omega2: np.ndarray,
                                tol: float = 1e-10) -> Dict:
    """
    Compare resonance profiles of two frequency vectors up to scale K.
    
    Checks whether the set of resonant lattice vectors is identical,
    which is the combinatorial invariant preserved by tropical KAM.
    
    Time complexity: O((2K+1)^n · n)
    Space complexity: O(R · n) for storing resonances
    
    Args:
        K: Scale parameter
        omega1, omega2: Frequency vectors to compare
        tol: Numerical tolerance
    
    Returns:
        Dictionary with comparison results
    """
    res1 = find_all_resonances(K, omega1, tol)
    res2 = find_all_resonances(K, omega2, tol)
    
    res1_set = {tuple(r.vector) for r in res1}
    res2_set = {tuple(r.vector) for r in res2}
    
    return {
        "same_profile": res1_set == res2_set,
        "resonances_omega1": len(res1),
        "resonances_omega2": len(res2),
        "shared": len(res1_set & res2_set),
        "only_in_omega1": len(res1_set - res2_set),
        "only_in_omega2": len(res2_set - res1_set),
    }


# ============================================================
# Algorithm 7: Tropical Rotation Vector
# ============================================================

def compute_tropical_rotation_vector(orbit: List[np.ndarray], 
                                      period: int = 1) -> np.ndarray:
    """
    Compute the tropical rotation vector from a discrete orbit.
    
    The rotation vector is the average displacement per period:
        ρ = (1/T) Σ (x_{t+1} - x_t)
    
    In the tropical setting, this measures the average slope of the
    piecewise-linear trajectory, which is the combinatorial analog
    of the classical rotation number.
    
    Time complexity: O(T · n) where T is the orbit length
    Space complexity: O(n)
    
    Args:
        orbit: List of points in R^n forming the orbit
        period: Averaging period
    
    Returns:
        Rotation vector in R^n
    
    Example:
        >>> # Linear orbit with slope (1, golden ratio)
        >>> orbit = [np.array([t, t * 1.618]) for t in range(100)]
        >>> rho = compute_tropical_rotation_vector(orbit)
        >>> np.allclose(rho, [1.0, 1.618], atol=0.01)
        True
    """
    if len(orbit) < 2:
        return np.zeros(len(orbit[0]) if orbit else 0)
    
    T = len(orbit) - 1
    total_displacement = orbit[-1] - orbit[0]
    return total_displacement / T


# ============================================================
# Algorithm 8: Diophantine Constant Scaling
# ============================================================

def verify_scaling_invariance(K: int, omega: np.ndarray, 
                               scales: List[float]) -> Dict:
    """
    Verify the scaling invariance theorem:
    C*(K, λω) = |λ| · C*(K, ω)
    
    Args:
        K: Scale parameter
        omega: Base frequency vector
        scales: List of scaling factors to test
    
    Returns:
        Dictionary with verification results
    """
    C_base, _ = optimal_diophantine_constant(K, omega)
    
    results = {}
    for lam in scales:
        omega_scaled = lam * omega
        C_scaled, _ = optimal_diophantine_constant(K, omega_scaled)
        C_predicted = abs(lam) * C_base
        error = abs(C_scaled - C_predicted) / max(C_predicted, 1e-15)
        results[lam] = {
            "C_actual": C_scaled,
            "C_predicted": C_predicted,
            "relative_error": error,
            "verified": error < 1e-10
        }
    
    return results


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical KAM Stability — Algorithm Examples\n")
    
    # Example 1: Diophantine check
    phi = (1 + np.sqrt(5)) / 2
    omega = np.array([1.0, phi])
    
    print("1. Diophantine Check:")
    result = check_tropical_diophantine(5, 0.01, omega, verbose=True)
    print(f"   ω = [1, φ]: Diophantine(5, 0.01) = {result.is_diophantine}")
    print(f"   Optimal constant C* = {result.optimal_constant:.6f}")
    print(f"   Worst vector k = {result.worst_vector}")
    print(f"   Vectors checked: {result.vectors_checked}")
    print()
    
    # Example 2: KAM persistence
    print("2. KAM Persistence Radius:")
    persistence = kam_persistence_radius(5, omega)
    print(f"   C = {persistence.diophantine_constant:.6f}")
    print(f"   Persistence radius = {persistence.persistence_radius:.6f}")
    print(f"   Perturbed constant = {persistence.perturbed_constant:.6f}")
    print()
    
    # Example 3: Resonance finding
    print("3. Resonances of rational frequency [1, 3/7]:")
    omega_rat = np.array([1.0, 3.0/7.0])
    resonances = find_all_resonances(10, omega_rat)
    for r in resonances[:5]:
        print(f"   k = {r.vector}, ||k||₁ = {r.l1_norm}, <k,ω> = {r.inner_product:.2e}")
    print(f"   Total resonances up to K=10: {len(resonances)}")
    print()
    
    # Example 4: Scaling invariance
    print("4. Scaling Invariance Verification:")
    scaling = verify_scaling_invariance(5, omega, [0.5, 1.0, 2.0, 5.0])
    for lam, data in scaling.items():
        print(f"   λ={lam}: C(λω)={data['C_actual']:.6f}, "
              f"|λ|C(ω)={data['C_predicted']:.6f}, "
              f"verified={data['verified']}")
    print()
    
    # Example 5: Profile comparison
    print("5. Resonance Profile Comparison:")
    eps = 0.001
    omega_perturbed = omega + np.array([eps, -eps])
    comparison = compare_resonance_profiles(5, omega, omega_perturbed)
    print(f"   Same profile: {comparison['same_profile']}")
    print(f"   Shared resonances: {comparison['shared']}")
