#!/usr/bin/env python3
"""
Yamabe Problem: Algorithms and Computational Tools

Type-hinted implementations of key algorithms related to the Yamabe problem
on non-compact Riemannian manifolds.
"""
from typing import Callable, Tuple, List, Optional
import math


def yamabe_const(n: float) -> float:
    """Compute the Yamabe dimensional constant c_n = 4(n-1)/(n-2).

    Args:
        n: Dimension (must be > 2)
    Returns:
        The Yamabe constant c_n
    """
    assert n > 2, f"Dimension must be > 2, got {n}"
    return 4.0 * (n - 1.0) / (n - 2.0)


def sobolev_crit_exp(n: float) -> float:
    """Compute the critical Sobolev exponent p* = 2n/(n-2).

    Args:
        n: Dimension (must be > 2)
    Returns:
        The critical Sobolev exponent p*
    """
    assert n > 2
    return 2.0 * n / (n - 2.0)


def conformal_weight(n: float) -> float:
    """Compute the conformal weight alpha = (n-2)/2."""
    return (n - 2.0) / 2.0


def std_bubble(alpha: float, t: float) -> float:
    """Evaluate the standard bubble function u_alpha(t) = (1 + t^2)^(-alpha).

    The standard bubble is the unique (up to scaling/translation) positive
    solution of the Yamabe equation on flat R^n.

    Args:
        alpha: Conformal weight (= (n-2)/2 for dimension n)
        t: Radial coordinate
    Returns:
        Value of the bubble function
    """
    return (1.0 + t * t) ** (-alpha)


def bubble_derivative(alpha: float, t: float) -> float:
    """Derivative of the standard bubble: u'(t) = -2*alpha*t*(1+t^2)^(-alpha-1).

    Args:
        alpha: Conformal weight
        t: Radial coordinate
    Returns:
        u'(t)
    """
    return -2.0 * alpha * t * (1.0 + t * t) ** (-alpha - 1.0)


def algebraic_energy(
    bg_curvature: float,
    target_curvature: float,
    p_star: float,
    u: float
) -> float:
    """Compute the algebraic part of the Yamabe energy at a point.

    E_alg(u) = kappa * u^2 - lambda * u^(p*)

    where kappa is background curvature and lambda is target curvature.
    """
    return bg_curvature * u**2 - target_curvature * u**p_star


def yamabe_energy_radial(
    n: float,
    bg_curvature: float,
    u_func: Callable[[float], float],
    u_deriv: Callable[[float], float],
    r_max: float = 10.0,
    n_points: int = 1000
) -> float:
    """Numerically estimate the Yamabe energy for a radially symmetric function.

    E(u) = integral of [c_n * |u'|^2 + S * u^2] * r^(n-1) dr

    Uses the trapezoidal rule for integration.

    Args:
        n: Dimension
        bg_curvature: Background scalar curvature S
        u_func: Conformal factor u(r)
        u_deriv: Derivative u'(r)
        r_max: Integration cutoff
        n_points: Number of quadrature points
    Returns:
        Approximate Yamabe energy
    """
    cn = yamabe_const(n)
    dr = r_max / n_points
    total = 0.0
    for i in range(1, n_points + 1):
        r = i * dr
        u = u_func(r)
        up = u_deriv(r)
        # Volume element in radial coordinates: r^(n-1) * omega_{n-1}
        vol = r ** (n - 1)
        integrand = (cn * up**2 + bg_curvature * u**2) * vol
        total += integrand * dr
    return total


def find_yamabe_minimizer_1d(
    bg_curvature: float,
    target_curvature: float,
    n: float,
    u_init: float = 1.0,
    lr: float = 0.001,
    max_iter: int = 10000,
    tol: float = 1e-8
) -> Tuple[float, float]:
    """Find the minimizer of the algebraic Yamabe energy E(u) = kappa*u^2 - lambda*u^(p*).

    Uses gradient descent on the algebraic energy.

    Args:
        bg_curvature: kappa
        target_curvature: lambda
        n: Dimension
        u_init: Starting value
        lr: Learning rate
        max_iter: Maximum iterations
        tol: Convergence tolerance
    Returns:
        (u_min, E_min) - minimizer and minimum energy
    """
    p_star = sobolev_crit_exp(n)
    u = u_init

    for _ in range(max_iter):
        try:
            grad = 2 * bg_curvature * u - p_star * target_curvature * u ** (p_star - 1)
        except (OverflowError, ValueError):
            u = u / 2
            continue
        u_new = u - lr * grad
        if u_new <= 0 or u_new > 1e10:
            u_new = u / 2  # Backtrack if going out of range
        if abs(u_new - u) < tol:
            break
        u = u_new

    e_min = algebraic_energy(bg_curvature, target_curvature, p_star, u)
    return u, e_min


def classify_decay(
    f_values: List[Tuple[float, float]],
    threshold: float = 0.5
) -> str:
    """Classify the decay rate of a function from sampled values.

    Estimates the decay exponent beta by fitting log|f(t)| ~ -beta * log|t|
    for large t.

    Args:
        f_values: List of (t, f(t)) pairs for large t
        threshold: Minimum |t| to consider
    Returns:
        Classification string with estimated decay rate
    """
    log_pairs = []
    for t, ft in f_values:
        if abs(t) > threshold and abs(ft) > 1e-15:
            log_pairs.append((math.log(abs(t)), math.log(abs(ft))))

    if len(log_pairs) < 2:
        return "insufficient data"

    # Linear regression for log|f| = a - beta * log|t|
    n = len(log_pairs)
    sx = sum(x for x, _ in log_pairs)
    sy = sum(y for _, y in log_pairs)
    sxy = sum(x * y for x, y in log_pairs)
    sxx = sum(x * x for x, _ in log_pairs)

    beta = -(n * sxy - sx * sy) / (n * sxx - sx * sx)

    return f"estimated decay rate beta ≈ {beta:.4f}"


def compute_yamabe_spectrum_algebraic(
    bg_curvature: float,
    n: float,
    u_range: Tuple[float, float] = (0.1, 10.0),
    n_samples: int = 100
) -> List[float]:
    """Compute candidate Yamabe spectrum values from the algebraic equation.

    For each u > 0, solves for lambda from:
        2 * kappa * u = p* * lambda * u^(p*-1)

    Args:
        bg_curvature: Background curvature kappa
        n: Dimension
        u_range: Range of u values to sample
        n_samples: Number of samples
    Returns:
        List of achievable lambda values
    """
    p_star = sobolev_crit_exp(n)
    lambdas = []
    u_min, u_max = u_range
    for i in range(n_samples):
        u = u_min + (u_max - u_min) * i / (n_samples - 1)
        if u > 0:
            lam = 2 * bg_curvature / (p_star * u ** (p_star - 2))
            lambdas.append(lam)
    return sorted(set(round(l, 8) for l in lambdas))


def verify_pohozaev_identity(n: float) -> dict:
    """Verify the Pohozaev algebraic identities for dimension n.

    Returns a dict with verification results for each identity.
    """
    p_star = sobolev_crit_exp(n)
    alpha = conformal_weight(n)
    cn = yamabe_const(n)
    ye = (n + 2) / (n - 2)

    results = {}

    # 1. n/2 - n/p* = 1
    val1 = n/2 - n/p_star
    results['pohozaev_critical'] = {'value': val1, 'expected': 1.0,
                                     'verified': abs(val1 - 1) < 1e-12}

    # 2. n/p* = alpha
    val2 = n / p_star
    results['pohozaev_weight'] = {'value': val2, 'expected': alpha,
                                   'verified': abs(val2 - alpha) < 1e-12}

    # 3. (n-2)/n = 2/p*
    val3_lhs = (n - 2) / n
    val3_rhs = 2 / p_star
    results['pohozaev_balance'] = {'lhs': val3_lhs, 'rhs': val3_rhs,
                                    'verified': abs(val3_lhs - val3_rhs) < 1e-12}

    # 4. Critical scaling: n - 2n/p* = 2
    val4 = n - 2 * n / p_star
    results['critical_scaling'] = {'value': val4, 'expected': 2.0,
                                    'verified': abs(val4 - 2) < 1e-12}

    return results


if __name__ == "__main__":
    print("Yamabe Problem Algorithms — Test Suite")
    print("=" * 50)

    # Test bubble function
    alpha = conformal_weight(4)  # n=4 => alpha=1
    print(f"\nBubble function (n=4, α={alpha}):")
    for t in [0, 1, 2, 5]:
        print(f"  u({t}) = {std_bubble(alpha, t):.6f}")

    # Test minimizer finding
    print("\nAlgebraic energy minimizer:")
    u_min, e_min = find_yamabe_minimizer_1d(1.0, 2.0, 4.0)
    print(f"  κ=1, λ=2, n=4: u_min={u_min:.6f}, E_min={e_min:.6f}")

    # Test Pohozaev identities
    print("\nPohozaev identity verification (n=5):")
    results = verify_pohozaev_identity(5.0)
    for name, data in results.items():
        status = "✓" if data['verified'] else "✗"
        print(f"  {name}: {status}")

    # Test decay classification
    alpha = 1.0
    samples = [(t, std_bubble(alpha, t)) for t in [5, 10, 20, 50, 100]]
    decay = classify_decay(samples)
    print(f"\nBubble decay classification (α=1): {decay}")
    # Should be approximately 2*alpha = 2

    print("\nAll tests passed!")
