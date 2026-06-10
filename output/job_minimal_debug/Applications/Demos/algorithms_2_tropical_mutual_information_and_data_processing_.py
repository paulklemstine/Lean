#!/usr/bin/env python3
"""
Tropical Mutual Information — Algorithms

Complete implementations of the core algorithms from the research paper,
with docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Callable, Tuple, List, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Compute Tropical Mutual Information
# ═══════════════════════════════════════════════════════════════════

def compute_tropical_mi(pXY: np.ndarray) -> dict:
    """
    Compute tropical mutual information and all intermediate quantities.
    
    Given a joint distribution p(x,y) as a 2D array, computes:
    - V(X): marginal vulnerability (max probability)
    - V(X|Y): conditional vulnerability (adversarial guess mass)
    - H∞(X): min-entropy of X
    - H∞(X|Y): conditional min-entropy
    - I∞(X;Y): tropical mutual information
    
    Time complexity: O(|α| · |β|)
    Space complexity: O(|α| + |β|)
    
    Args:
        pXY: Joint probability matrix of shape (|α|, |β|), nonneg, summing to 1.
    
    Returns:
        Dictionary with all computed quantities.
    
    Example:
        >>> pXY = np.array([[0.3, 0.1], [0.2, 0.4]])
        >>> result = compute_tropical_mi(pXY)
        >>> print(f"I∞ = {result['tropical_mi']:.4f} bits")
    """
    assert pXY.ndim == 2
    assert np.all(pXY >= -1e-15)
    assert abs(pXY.sum() - 1.0) < 1e-10
    
    # Marginal p_X(x) = ∑_y p(x,y)
    pX = pXY.sum(axis=1)
    
    # Vulnerability V(X) = max_x p_X(x)
    v_x = float(np.max(pX))
    
    # Conditional vulnerability V(X|Y) = ∑_y max_x p(x,y)
    v_xy = float(np.sum(np.max(pXY, axis=0)))
    
    # Min-entropy H∞(X) = -log2(V(X))
    h_x = -np.log2(v_x)
    
    # Conditional min-entropy H∞(X|Y) = -log2(V(X|Y))
    h_xy = -np.log2(v_xy)
    
    # Tropical mutual information I∞(X;Y) = H∞(X) - H∞(X|Y)
    mi = h_x - h_xy
    
    return {
        'marginal_X': pX,
        'vulnerability_X': v_x,
        'cond_vulnerability': v_xy,
        'min_entropy_X': h_x,
        'cond_min_entropy': h_xy,
        'tropical_mi': mi,
    }


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Deterministic Pushforward
# ═══════════════════════════════════════════════════════════════════

def pushforward_second(
    pXY: np.ndarray, 
    f: Callable[[int], int], 
    n_output: int
) -> np.ndarray:
    """
    Compute the pushforward of a joint distribution under f on the 2nd coordinate.
    
    For p(x,y), computes p'(x,c) = ∑_{y: f(y)=c} p(x,y).
    
    Time complexity: O(|α| · |β|)
    Space complexity: O(|α| · |γ|) for the output
    
    Args:
        pXY: Joint distribution, shape (|α|, |β|).
        f: Deterministic function β → γ, given as int → int.
        n_output: Size of the output space |γ|.
    
    Returns:
        Pushforward distribution of shape (|α|, |γ|).
    
    Example:
        >>> pXY = np.array([[0.3, 0.1, 0.1], [0.2, 0.2, 0.1]])
        >>> f = lambda y: y % 2  # merge y=0,2 and keep y=1
        >>> p_new = pushforward_second(pXY, f, 2)
    """
    n_x, n_y = pXY.shape
    result = np.zeros((n_x, n_output))
    for y in range(n_y):
        result[:, f(y)] += pXY[:, y]
    return result


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Verify DPI for a Given Distribution and Function
# ═══════════════════════════════════════════════════════════════════

@dataclass
class DPIResult:
    """Result of a DPI verification."""
    mi_original: float
    mi_processed: float
    info_loss: float
    relative_loss: float
    dpi_satisfied: bool
    vulnerability_original: float
    vulnerability_processed: float

def verify_dpi(
    pXY: np.ndarray, 
    f: Callable[[int], int], 
    n_output: int,
    tol: float = 1e-10
) -> DPIResult:
    """
    Verify the data-processing inequality for a specific distribution and function.
    
    Checks that I∞(X; f(Y)) ≤ I∞(X; Y) and reports the information loss.
    
    Time complexity: O(|α| · (|β| + |γ|))
    Space complexity: O(|α| · max(|β|, |γ|))
    
    Args:
        pXY: Joint distribution, shape (|α|, |β|).
        f: Deterministic function β → γ.
        n_output: Size of output space |γ|.
        tol: Numerical tolerance for violation check.
    
    Returns:
        DPIResult with all quantities and verification outcome.
    """
    result_orig = compute_tropical_mi(pXY)
    pXfY = pushforward_second(pXY, f, n_output)
    result_proc = compute_tropical_mi(pXfY)
    
    mi_orig = result_orig['tropical_mi']
    mi_proc = result_proc['tropical_mi']
    info_loss = mi_orig - mi_proc
    
    return DPIResult(
        mi_original=mi_orig,
        mi_processed=mi_proc,
        info_loss=info_loss,
        relative_loss=info_loss / mi_orig if mi_orig > tol else 0.0,
        dpi_satisfied=mi_proc <= mi_orig + tol,
        vulnerability_original=result_orig['cond_vulnerability'],
        vulnerability_processed=result_proc['cond_vulnerability'],
    )


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Optimal Adversarial Strategy
# ═══════════════════════════════════════════════════════════════════

def optimal_adversary(pXY: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Compute the optimal adversarial guessing strategy and success probability.
    
    For each observation y, the optimal guess is g*(y) = argmax_x p(x,y).
    The success probability is V(X|Y) = ∑_y max_x p(x,y).
    
    Time complexity: O(|α| · |β|)
    Space complexity: O(|β|) for the strategy
    
    Args:
        pXY: Joint distribution, shape (|α|, |β|).
    
    Returns:
        Tuple of (strategy, success_probability) where strategy[y] is the
        optimal guess for observation y.
    
    Example:
        >>> pXY = np.array([[0.3, 0.05], [0.1, 0.25], [0.15, 0.15]])
        >>> strategy, prob = optimal_adversary(pXY)
        >>> print(f"Strategy: {strategy}, Success: {prob:.2%}")
    """
    strategy = np.argmax(pXY, axis=0)
    success = float(np.sum(np.max(pXY, axis=0)))
    return strategy, success


# ═══════════════════════════════════════════════════════════════════
# Algorithm 5: Leakage Profile Analysis
# ═══════════════════════════════════════════════════════════════════

def leakage_profile(
    pXY: np.ndarray,
    functions: List[Tuple[str, Callable[[int], int], int]]
) -> List[dict]:
    """
    Analyze information leakage under multiple post-processing functions.
    
    For a joint distribution p(x,y), computes I∞(X; f(Y)) for each f
    and verifies the DPI ordering.
    
    Args:
        pXY: Joint distribution, shape (|α|, |β|).
        functions: List of (name, function, output_size) tuples.
    
    Returns:
        List of dictionaries with leakage analysis for each function.
    
    Example:
        >>> pXY = np.array([[0.3, 0.1, 0.1], [0.2, 0.2, 0.1]])
        >>> funcs = [
        ...     ("identity", lambda y: y, 3),
        ...     ("parity", lambda y: y % 2, 2),
        ...     ("constant", lambda y: 0, 1),
        ... ]
        >>> profile = leakage_profile(pXY, funcs)
    """
    base_mi = compute_tropical_mi(pXY)['tropical_mi']
    results = []
    
    for name, f, n_out in functions:
        pXfY = pushforward_second(pXY, f, n_out)
        mi = compute_tropical_mi(pXfY)['tropical_mi']
        results.append({
            'name': name,
            'output_size': n_out,
            'tropical_mi': mi,
            'info_loss': base_mi - mi,
            'relative_loss': (base_mi - mi) / base_mi if base_mi > 1e-10 else 0,
            'dpi_satisfied': mi <= base_mi + 1e-10,
        })
    
    return results


# ═══════════════════════════════════════════════════════════════════
# Algorithm 6: Security Certificate
# ═══════════════════════════════════════════════════════════════════

@dataclass
class SecurityCertificate:
    """Security certificate for a tropical protocol."""
    min_entropy_secret: float
    cond_min_entropy: float
    tropical_mi: float
    max_guessing_prob: float
    security_bits: float
    post_processing_safe: bool

def compute_security_certificate(
    pXY: np.ndarray,
    post_processings: Optional[List[Tuple[str, Callable[[int], int], int]]] = None
) -> SecurityCertificate:
    """
    Compute a security certificate for a distribution.
    
    Analyzes the worst-case leakage and verifies that all listed
    post-processings preserve the security bound.
    
    Time complexity: O(|α| · |β| · (1 + #post_processings))
    Space complexity: O(|α| · max output size)
    
    Args:
        pXY: Joint distribution (secret × observation).
        post_processings: Optional list of post-processing functions to verify.
    
    Returns:
        SecurityCertificate with all security parameters.
    """
    result = compute_tropical_mi(pXY)
    
    all_safe = True
    if post_processings:
        for name, f, n_out in post_processings:
            dpi = verify_dpi(pXY, f, n_out)
            if not dpi.dpi_satisfied:
                all_safe = False
    
    return SecurityCertificate(
        min_entropy_secret=result['min_entropy_X'],
        cond_min_entropy=result['cond_min_entropy'],
        tropical_mi=result['tropical_mi'],
        max_guessing_prob=result['cond_vulnerability'],
        security_bits=result['cond_min_entropy'],
        post_processing_safe=all_safe,
    )


# ═══════════════════════════════════════════════════════════════════
# Main: Example Usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Tropical Mutual Information — Algorithm Demonstrations")
    print("=" * 60)
    
    # Example joint distribution
    pXY = np.array([
        [0.25, 0.05, 0.05],
        [0.05, 0.25, 0.05],
        [0.05, 0.05, 0.20],
    ])
    
    # Algorithm 1: Compute MI
    print("\n--- Algorithm 1: Compute Tropical MI ---")
    result = compute_tropical_mi(pXY)
    for k, v in result.items():
        if isinstance(v, np.ndarray):
            print(f"  {k}: {v}")
        else:
            print(f"  {k}: {v:.4f}")
    
    # Algorithm 4: Optimal adversary
    print("\n--- Algorithm 4: Optimal Adversary ---")
    strategy, prob = optimal_adversary(pXY)
    print(f"  Strategy: observe y, guess x = {strategy}")
    print(f"  Success probability: {prob:.4f}")
    
    # Algorithm 5: Leakage profile
    print("\n--- Algorithm 5: Leakage Profile ---")
    funcs = [
        ("identity", lambda y: y, 3),
        ("parity", lambda y: y % 2, 2),
        ("constant", lambda y: 0, 1),
    ]
    profile = leakage_profile(pXY, funcs)
    for entry in profile:
        print(f"  {entry['name']:12s}: I∞ = {entry['tropical_mi']:.4f}, "
              f"loss = {entry['relative_loss']:.1%}, "
              f"DPI: {'✓' if entry['dpi_satisfied'] else '✗'}")
    
    # Algorithm 6: Security certificate
    print("\n--- Algorithm 6: Security Certificate ---")
    cert = compute_security_certificate(pXY, funcs)
    print(f"  Min-entropy of secret: {cert.min_entropy_secret:.4f} bits")
    print(f"  Conditional min-entropy: {cert.cond_min_entropy:.4f} bits")
    print(f"  Tropical MI (leakage): {cert.tropical_mi:.4f} bits")
    print(f"  Max guessing probability: {cert.max_guessing_prob:.4f}")
    print(f"  Security bits: {cert.security_bits:.4f}")
    print(f"  Post-processing safe: {'Yes' if cert.post_processing_safe else 'No'}")
    
    print("\n" + "=" * 60)
    print("All algorithm demonstrations completed.")
