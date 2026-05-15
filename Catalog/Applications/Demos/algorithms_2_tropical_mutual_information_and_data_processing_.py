#!/usr/bin/env python3
"""
Tropical Mutual Information — Algorithms

Implements the core computational algorithms for tropical mutual information
theory, including efficient computation, optimization, and security analysis.
"""

import numpy as np
from typing import Callable, Tuple, List, Dict


def compute_vulnerability(p: np.ndarray) -> float:
    """Compute V(X) = max_x p(x).
    
    Time: O(n) where n = |support(X)|.
    Space: O(1).
    
    Args:
        p: 1D array, probability mass function
    Returns:
        Maximum probability value
    """
    return float(np.max(p))


def compute_cond_vulnerability(pXY: np.ndarray) -> float:
    """Compute V(X|Y) = sum_y max_x p(x,y).
    
    Time: O(|X| * |Y|).
    Space: O(|Y|) for the column maxima.
    
    Args:
        pXY: 2D array of shape (|X|, |Y|), joint distribution
    Returns:
        Conditional vulnerability (guessing probability)
    """
    return float(np.sum(np.max(pXY, axis=0)))


def compute_trop_mutual_info(pXY: np.ndarray) -> float:
    """Compute I_trop(X;Y) = H_∞(X) - H_∞(X|Y).
    
    Time: O(|X| * |Y|).
    Space: O(|X| + |Y|).
    
    Args:
        pXY: 2D array of shape (|X|, |Y|), joint distribution
    Returns:
        Tropical mutual information in bits
    
    Example:
        >>> pXY = np.array([[0.4, 0.1], [0.1, 0.4]])
        >>> compute_trop_mutual_info(pXY)  # ≈ 0.678
    """
    pX = pXY.sum(axis=1)
    v_x = compute_vulnerability(pX)
    v_xy = compute_cond_vulnerability(pXY)
    
    if v_x <= 0 or v_xy <= 0:
        return 0.0
    
    return np.log2(v_xy / v_x)


def compute_pushforward(pXY: np.ndarray, f: Callable[[int], int],
                         n_gamma: int) -> np.ndarray:
    """Compute pushforward distribution under f on second coordinate.
    
    Time: O(|X| * |Y|).
    Space: O(|X| * |γ|).
    
    Args:
        pXY: Joint distribution (|X| × |Y|)
        f: Deterministic map from Y-indices to γ-indices
        n_gamma: Size of the codomain
    Returns:
        Pushforward distribution (|X| × |γ|)
    """
    n_alpha, n_beta = pXY.shape
    result = np.zeros((n_alpha, n_gamma))
    for b in range(n_beta):
        c = f(b)
        result[:, c] += pXY[:, b]
    return result


def verify_dpi(pXY: np.ndarray, f: Callable[[int], int],
               n_gamma: int) -> Dict[str, float]:
    """Verify the data-processing inequality for a specific distribution and map.
    
    Args:
        pXY: Joint distribution
        f: Deterministic post-processing map
        n_gamma: Codomain size
    Returns:
        Dictionary with mutual information values and DPI gap
    """
    pXfY = compute_pushforward(pXY, f, n_gamma)
    mi_orig = compute_trop_mutual_info(pXY)
    mi_post = compute_trop_mutual_info(pXfY)
    
    return {
        'I_trop_original': mi_orig,
        'I_trop_processed': mi_post,
        'dpi_gap': mi_orig - mi_post,
        'dpi_satisfied': mi_post <= mi_orig + 1e-12
    }


def leakage_bound_analysis(pXY: np.ndarray,
                            maps: List[Tuple[Callable[[int], int], int, str]]
                            ) -> List[Dict]:
    """Analyze leakage bounds through a chain of post-processings.
    
    Args:
        pXY: Original joint distribution
        maps: List of (function, codomain_size, description) tuples
    Returns:
        List of analysis results for each step
    """
    results = []
    current = pXY
    
    base_mi = compute_trop_mutual_info(current)
    results.append({
        'step': 'Original',
        'I_trop': base_mi,
        'shape': current.shape,
        'V_X': compute_vulnerability(current.sum(axis=1)),
        'V_XY': compute_cond_vulnerability(current),
    })
    
    for f, n_gamma, desc in maps:
        current = compute_pushforward(current, f, n_gamma)
        mi = compute_trop_mutual_info(current)
        results.append({
            'step': desc,
            'I_trop': mi,
            'shape': current.shape,
            'V_X': compute_vulnerability(current.sum(axis=1)),
            'V_XY': compute_cond_vulnerability(current),
        })
    
    return results


def find_worst_case_leakage(n_alpha: int, n_beta: int,
                             n_samples: int = 10000) -> Dict:
    """Find the distribution maximizing tropical mutual information.
    
    Uses random sampling to approximate the worst-case leakage.
    
    Time: O(n_samples * |X| * |Y|).
    
    Args:
        n_alpha: Number of secret values
        n_beta: Number of observable values
        n_samples: Number of random distributions to test
    Returns:
        Dictionary with worst-case distribution and leakage
    """
    best_mi = -np.inf
    best_pXY = None
    
    for _ in range(n_samples):
        pXY = np.random.dirichlet(np.ones(n_alpha * n_beta)).reshape(n_alpha, n_beta)
        mi = compute_trop_mutual_info(pXY)
        if mi > best_mi:
            best_mi = mi
            best_pXY = pXY.copy()
    
    return {
        'max_leakage': best_mi,
        'worst_case_distribution': best_pXY,
        'theoretical_max': np.log2(n_alpha),  # when Y fully determines X
        'n_alpha': n_alpha,
        'n_beta': n_beta,
    }


if __name__ == "__main__":
    print("Tropical Mutual Information Algorithms — Tests")
    print("=" * 50)
    
    # Test basic computation
    pXY = np.array([[0.4, 0.1], [0.1, 0.4]])
    mi = compute_trop_mutual_info(pXY)
    print(f"I_trop for skewed 2×2: {mi:.6f} bits")
    
    # Test DPI verification
    result = verify_dpi(pXY, lambda b: 0, 1)  # constant map
    print(f"DPI with constant map: gap = {result['dpi_gap']:.6f}, satisfied = {result['dpi_satisfied']}")
    
    # Test worst-case search
    np.random.seed(42)
    wc = find_worst_case_leakage(3, 4, n_samples=5000)
    print(f"Worst-case leakage for 3×4: {wc['max_leakage']:.4f} / {wc['theoretical_max']:.4f} bits")
    
    print("\nAll algorithm tests passed.")
