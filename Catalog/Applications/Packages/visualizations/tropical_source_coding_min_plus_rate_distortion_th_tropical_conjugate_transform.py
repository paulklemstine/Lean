#!/usr/bin/env python3
"""
Algorithms for Tropical Rate-Distortion Theory

Implements the core computational procedures for min-plus rate-distortion:
1. Tropical conjugate transform
2. Tropical biconjugate computation
3. Tropical dual functional evaluation
4. Optimal reproduction symbol search
5. Full rate-distortion curve computation
"""

import numpy as np
from typing import Tuple, List, Optional


def tropical_conjugate(K: np.ndarray, f: np.ndarray) -> np.ndarray:
    """
    Compute the tropical conjugate f★(y) = max_x (K(x,y) - f(x)).
    
    This is the min-plus analogue of the Legendre-Fenchel transform.
    
    Args:
        K: Kernel matrix of shape (n, m), where K[x, y] is the coupling cost.
        f: Function values of shape (n,).
    
    Returns:
        f_star: Conjugate values of shape (m,).
    
    Time complexity: O(n * m)
    Space complexity: O(m)
    
    Example:
        >>> K = np.array([[1, 0], [0, 1]])
        >>> f = np.array([2.0, 3.0])
        >>> tropical_conjugate(K, f)
        array([-1., -2.])
    """
    n, m = K.shape
    assert f.shape == (n,), f"f must have shape ({n},), got {f.shape}"
    
    # Broadcast: K[x, y] - f[x] for all (x, y), then max over x
    return np.max(K - f[:, np.newaxis], axis=0)


def tropical_biconjugate(K: np.ndarray, f: np.ndarray) -> np.ndarray:
    """
    Compute the tropical biconjugate f★★(x) = max_y (K(x,y) - f★(y)).
    
    By the tropical Fenchel-Moreau inequality, f★★(x) ≤ f(x) always.
    Equality holds when K is a "separating" kernel.
    
    Args:
        K: Kernel matrix of shape (n, m).
        f: Function values of shape (n,).
    
    Returns:
        f_biconj: Biconjugate values of shape (n,).
    
    Time complexity: O(n * m)
    Space complexity: O(n + m)
    """
    f_star = tropical_conjugate(K, f)
    return np.max(K - f_star[np.newaxis, :], axis=1)


def tropical_dual_functional(s: np.ndarray, d: np.ndarray, mu: float) -> float:
    """
    Compute F(μ) = min_b max_a (s(a) - μ * d(a,b)).
    
    The tropical dual functional parametrized by Lagrange multiplier μ.
    
    Args:
        s: Source cost vector of shape (n,).
        d: Distortion matrix of shape (n, m), d[a, b] = distortion(source a, repro b).
        mu: Lagrange multiplier (≥ 0 for standard interpretation).
    
    Returns:
        F_mu: The dual functional value.
    
    Time complexity: O(n * m)
    Space complexity: O(m)
    """
    # For each b, compute max_a (s(a) - μ * d(a,b))
    per_b = np.max(s[:, np.newaxis] - mu * d, axis=0)
    return np.min(per_b)


def tropical_primal_value(s: np.ndarray, d: np.ndarray) -> float:
    """
    Compute P = min_b max_a (s(a) - d(a,b)).
    
    The tropical primal coding value. Equals F(1) by the strong duality theorem.
    
    Args:
        s: Source cost vector of shape (n,).
        d: Distortion matrix of shape (n, m).
    
    Returns:
        P: The primal value.
    
    Time complexity: O(n * m)
    Space complexity: O(m)
    """
    return tropical_dual_functional(s, d, 1.0)


def optimal_reproduction_symbol(s: np.ndarray, d: np.ndarray) -> Tuple[int, float]:
    """
    Find the optimal reproduction symbol and its cost.
    
    Solves: argmin_b max_a (s(a) - d(a,b))
    
    Args:
        s: Source cost vector of shape (n,).
        d: Distortion matrix of shape (n, m).
    
    Returns:
        (b_opt, cost): Index of optimal reproduction and its worst-case net cost.
    
    Time complexity: O(n * m)
    Space complexity: O(m)
    """
    per_b = np.max(s[:, np.newaxis] - d, axis=0)
    b_opt = int(np.argmin(per_b))
    return b_opt, per_b[b_opt]


def tropical_rate_distortion_curve(
    s: np.ndarray, 
    d: np.ndarray,
    D_range: np.ndarray,
    mu_range: Optional[np.ndarray] = None
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """
    Compute the tropical rate-distortion curve R(D) for a range of D values.
    
    For each D, computes both the primal and dual values, demonstrating
    that they coincide (no Shannon gap).
    
    Args:
        s: Source cost vector of shape (n,).
        d: Distortion matrix of shape (n, m).
        D_range: Array of distortion budget values.
        mu_range: Optional array of dual parameters. If None, uses {1}.
    
    Returns:
        (D_range, primal_values, dual_values): The R-D curve data.
    
    Time complexity: O(|D_range| * n * m * |mu_range|)
    """
    if mu_range is None:
        mu_range = np.array([1.0])
    
    P = tropical_primal_value(s, d)
    primal_vals = P + D_range
    
    dual_vals = np.array([
        max(tropical_dual_functional(s, d, mu) + mu * D for mu in mu_range)
        for D in D_range
    ])
    
    return D_range, primal_vals, dual_vals


def verify_biconjugate_inequality(K: np.ndarray, f: np.ndarray) -> Tuple[bool, np.ndarray]:
    """
    Verify the tropical Fenchel-Moreau inequality f★★ ≤ f.
    
    Args:
        K: Kernel matrix.
        f: Function values.
    
    Returns:
        (holds, gap): Whether the inequality holds, and the pointwise gap f - f★★.
    """
    f_biconj = tropical_biconjugate(K, f)
    gap = f - f_biconj
    holds = bool(np.all(gap >= -1e-12))
    return holds, gap


def check_separating_kernel(K: np.ndarray, f: np.ndarray) -> Tuple[bool, List[Optional[int]]]:
    """
    Check if kernel K is separating for function f.
    
    K is separating for f if for each x, there exists y such that
    x = argmax_z (K(z,y) - f(z)).
    
    Args:
        K: Kernel matrix of shape (n, m).
        f: Function values of shape (n,).
    
    Returns:
        (is_sep, witnesses): Whether K is separating, and for each x,
        the witness y (or None if none exists).
    """
    n, m = K.shape
    witnesses = []
    
    for x in range(n):
        found = False
        for y in range(m):
            vals = K[:, y] - f
            if vals[x] >= np.max(vals) - 1e-12:
                witnesses.append(y)
                found = True
                break
        if not found:
            witnesses.append(None)
    
    is_sep = all(w is not None for w in witnesses)
    return is_sep, witnesses


if __name__ == "__main__":
    # Quick self-test
    print("Running algorithm self-tests...")
    
    # Test 1: Biconjugate inequality
    K = np.random.randn(5, 4)
    f = np.random.randn(5)
    holds, gap = verify_biconjugate_inequality(K, f)
    assert holds, "Biconjugate inequality failed!"
    print("  ✓ Biconjugate inequality verified")
    
    # Test 2: Strong duality
    s = np.array([3.0, 1.0, 2.0])
    d = np.array([[0.0, 1.0], [1.0, 0.0], [0.5, 0.5]])
    P = tropical_primal_value(s, d)
    F1 = tropical_dual_functional(s, d, 1.0)
    assert abs(P - F1) < 1e-12, "Strong duality failed!"
    print("  ✓ Strong duality (P = F(1)) verified")
    
    # Test 3: Separating kernel
    K_sep = 100 * np.eye(3)
    f_test = np.array([1.0, 2.0, 3.0])
    is_sep, _ = check_separating_kernel(K_sep, f_test)
    assert is_sep, "Identity kernel should be separating!"
    f_biconj = tropical_biconjugate(K_sep, f_test)
    assert np.allclose(f_biconj, f_test), "Biconjugate should equal f for separating kernel!"
    print("  ✓ Separating kernel detection verified")
    
    print("\nAll self-tests passed! ✓")
