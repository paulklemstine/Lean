#!/usr/bin/env python3
"""
Algorithms for Tropical Incidence Geometry

Implements the algorithms from the research paper:
1. Tropical defect computation
2. Incidence reconstruction from defect data
3. Fano plane verification
4. Defect matrix analysis
5. Margin optimization
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class TropicalConfig:
    """A tropical incidence configuration."""
    points: np.ndarray  # shape (n_points, 3)
    lines: np.ndarray   # shape (n_lines, 3)
    
    @property
    def n_points(self) -> int:
        return self.points.shape[0]
    
    @property
    def n_lines(self) -> int:
        return self.lines.shape[0]


def trop_eval(line: np.ndarray, point: np.ndarray) -> np.ndarray:
    """Evaluate the tropical affine functional.
    
    Args:
        line: coefficients in R^3
        point: coordinates in R^3
    
    Returns:
        v[i] = line[i] + point[i] for i = 0, 1, 2
    
    Complexity: O(d) where d = dimension (3 in our case)
    """
    return line + point


def trop_defect(line: np.ndarray, point: np.ndarray) -> float:
    """Compute the tropical defect (Algorithm 6.1).
    
    The defect is the gap between the second-smallest and smallest
    values of the evaluation vector. It equals:
        median(v) - min(v) = (sum - min - max) - min
    
    Args:
        line: coefficients in R^3
        point: coordinates in R^3
    
    Returns:
        Nonneg real number; 0 iff the point is incident to the line.
    
    Complexity: O(1) time, O(1) space
    """
    v = trop_eval(line, point)
    s = v.min()
    L = v.max()
    median = v.sum() - s - L
    return median - s


def trop_incident(line: np.ndarray, point: np.ndarray) -> bool:
    """Check tropical incidence.
    
    A point lies on a tropical line when the minimum of the evaluation
    is attained at least twice.
    
    Args:
        line: coefficients in R^3
        point: coordinates in R^3
    
    Returns:
        True iff the point is incident to the line.
    
    Complexity: O(1)
    """
    return np.isclose(trop_defect(line, point), 0.0)


def defect_matrix(config: TropicalConfig) -> np.ndarray:
    """Compute the full defect matrix of a configuration.
    
    Args:
        config: tropical incidence configuration
    
    Returns:
        D[p, l] = tropDefect(config.lines[l], config.points[p])
        Shape: (n_points, n_lines)
    
    Complexity: O(n_points * n_lines)
    """
    D = np.zeros((config.n_points, config.n_lines))
    for p in range(config.n_points):
        for l in range(config.n_lines):
            D[p, l] = trop_defect(config.lines[l], config.points[p])
    return D


def incidence_matrix(config: TropicalConfig) -> np.ndarray:
    """Compute the incidence matrix of a configuration.
    
    Args:
        config: tropical incidence configuration
    
    Returns:
        I[p, l] = 1 if point p is incident to line l, 0 otherwise
        Shape: (n_points, n_lines)
    
    Complexity: O(n_points * n_lines)
    """
    D = defect_matrix(config)
    return (np.isclose(D, 0.0)).astype(int)


def security_margin(config: TropicalConfig) -> float:
    """Compute the security margin γ of a configuration.
    
    The security margin is the minimum defect among all non-incident pairs.
    
    Args:
        config: tropical incidence configuration
    
    Returns:
        γ ≥ 0; positive iff the configuration has certified separation
    
    Complexity: O(n_points * n_lines)
    """
    D = defect_matrix(config)
    I = incidence_matrix(config)
    non_incident_defects = D[I == 0]
    if len(non_incident_defects) == 0:
        return float('inf')
    return non_incident_defects.min()


def reconstruct_incidence(
    D: np.ndarray, 
    tolerance: float = 0.0
) -> np.ndarray:
    """Reconstruct incidence from defect data (Algorithm 6.2).
    
    Args:
        D: defect matrix, shape (n_points, n_lines)
        tolerance: threshold for zero (default 0, use > 0 for noisy data)
    
    Returns:
        Binary incidence matrix
    
    Complexity: O(n_points * n_lines)
    
    Correctness: By Theorem 4.2, if the configuration has certified
    separation with margin γ and noise < γ, setting tolerance between
    the noise level and γ recovers the exact incidence relation.
    """
    return (D <= tolerance).astype(int)


def verify_fano_axioms(I: np.ndarray) -> Tuple[bool, List[str]]:
    """Verify Fano axioms on a 7×7 incidence matrix (Algorithm 6.3).
    
    Args:
        I: binary incidence matrix, shape (7, 7)
    
    Returns:
        (valid, violations): whether all axioms hold, and list of violations
    
    Complexity: O(1) (fixed 7×7 matrix)
    """
    violations = []
    
    if I.shape != (7, 7):
        violations.append(f"Wrong shape: {I.shape}, expected (7, 7)")
        return False, violations
    
    # Check 3 points per line
    col_sums = I.sum(axis=0)
    if not np.all(col_sums == 3):
        violations.append(f"Points per line: {col_sums} (expected all 3)")
    
    # Check 3 lines per point
    row_sums = I.sum(axis=1)
    if not np.all(row_sums == 3):
        violations.append(f"Lines per point: {row_sums} (expected all 3)")
    
    # Check unique line through two points
    from itertools import combinations
    for i, j in combinations(range(7), 2):
        common = np.sum(I[i] & I[j])
        if common != 1:
            violations.append(f"Points {i},{j} share {common} lines (expected 1)")
    
    # Check unique point on two lines
    for i, j in combinations(range(7), 2):
        common = np.sum(I[:, i] & I[:, j])
        if common != 1:
            violations.append(f"Lines {i},{j} share {common} points (expected 1)")
    
    return len(violations) == 0, violations


def tropical_perturbation_robustness(
    config: TropicalConfig,
    n_trials: int = 1000,
    noise_levels: Optional[np.ndarray] = None
) -> dict:
    """Test robustness of incidence reconstruction under perturbation.
    
    Args:
        config: base tropical configuration
        n_trials: number of random perturbation trials per noise level
        noise_levels: array of noise standard deviations to test
    
    Returns:
        Dictionary mapping noise level to reconstruction accuracy
    """
    if noise_levels is None:
        gamma = security_margin(config)
        if gamma == float('inf') or gamma <= 0:
            noise_levels = np.array([0.0, 0.01, 0.1, 1.0])
        else:
            noise_levels = np.array([0, gamma*0.1, gamma*0.3, gamma*0.5, 
                                      gamma*0.9, gamma*1.0, gamma*1.5, gamma*2.0])
    
    I_exact = incidence_matrix(config)
    results = {}
    
    for sigma in noise_levels:
        accuracies = []
        for _ in range(n_trials):
            # Perturb point and line coordinates
            pts_noisy = config.points + np.random.randn(*config.points.shape) * sigma
            lns_noisy = config.lines + np.random.randn(*config.lines.shape) * sigma
            noisy_config = TropicalConfig(pts_noisy, lns_noisy)
            I_noisy = incidence_matrix(noisy_config)
            acc = np.mean(I_noisy == I_exact)
            accuracies.append(acc)
        results[float(sigma)] = {
            'mean_accuracy': np.mean(accuracies),
            'std_accuracy': np.std(accuracies),
            'min_accuracy': np.min(accuracies),
        }
    
    return results


# ─── Example Usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Incidence Geometry: Algorithm Demonstrations")
    print("=" * 60)
    
    # Create a simple configuration
    np.random.seed(42)
    config = TropicalConfig(
        points=np.random.randn(5, 3),
        lines=np.random.randn(5, 3)
    )
    
    print("\n--- Defect Matrix ---")
    D = defect_matrix(config)
    print(np.round(D, 4))
    
    print("\n--- Incidence Matrix ---")
    I = incidence_matrix(config)
    print(I)
    
    print(f"\n--- Security Margin ---")
    gamma = security_margin(config)
    print(f"γ = {gamma:.6f}")
    
    print("\n--- Reconstruction from Noisy Data ---")
    noise = 0.01
    D_noisy = D + np.random.randn(*D.shape) * noise
    D_noisy = np.maximum(D_noisy, 0)
    I_recon = reconstruct_incidence(D_noisy, tolerance=noise * 3)
    print(f"Noise level: {noise}")
    print(f"Reconstructed incidence matches exact: {np.array_equal(I_recon, I)}")
    
    print("\n--- Fano Axiom Verification ---")
    # Classical Fano plane
    fano = np.array([
        [1,1,0,1,0,0,0],
        [1,0,1,0,1,0,0],
        [0,1,1,0,0,1,0],
        [1,0,0,0,0,1,1],
        [0,1,0,0,1,0,1],
        [0,0,1,1,0,0,1],
        [0,0,0,1,1,1,0],
    ])
    valid, violations = verify_fano_axioms(fano)
    print(f"Fano axioms satisfied: {valid}")
    if violations:
        for v in violations:
            print(f"  Violation: {v}")
    
    print("\n--- Perturbation Robustness ---")
    results = tropical_perturbation_robustness(config, n_trials=100)
    for sigma, stats in results.items():
        print(f"  σ={sigma:.4f}: accuracy={stats['mean_accuracy']*100:.1f}% "
              f"± {stats['std_accuracy']*100:.1f}%")
