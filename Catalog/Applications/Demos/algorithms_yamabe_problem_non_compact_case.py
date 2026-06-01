"""
Algorithms for the Yamabe Problem on Non-Compact Manifolds.

Implements key computational procedures:
1. Yamabe bubble evaluation and energy computation
2. Bubble decomposition analysis
3. Volume growth classification
4. Yamabe flow simulation (radial case)
"""

from typing import List, Tuple, Optional
import math


def yamabe_bubble(n: int, lam: float, r: float) -> float:
    """
    Evaluate the Yamabe bubble U_λ(r) = (λ/(λ²+r²))^((n-2)/2).

    Args:
        n: Dimension (must be ≥ 3)
        lam: Scale parameter (must be > 0)
        r: Radial coordinate

    Returns:
        Value of the bubble at radius r
    """
    if n < 3:
        raise ValueError("Dimension must be at least 3")
    if lam <= 0:
        raise ValueError("Scale parameter must be positive")
    base = lam / (lam**2 + r**2)
    exponent = (n - 2) / 2.0
    return base**exponent


def yamabe_critical_exponent(n: int) -> float:
    """
    Compute the Yamabe critical exponent p*(n) = 2n/(n-2).

    Args:
        n: Dimension (must be ≥ 3)

    Returns:
        Critical Sobolev exponent
    """
    if n < 3:
        raise ValueError("Dimension must be at least 3")
    return 2.0 * n / (n - 2)


def conformal_dimension_constant(n: int) -> float:
    """
    Compute the conformal dimension constant c_n = (n-2)/(4(n-1)).

    Args:
        n: Dimension (must be ≥ 2)

    Returns:
        Conformal dimension constant
    """
    if n < 2:
        raise ValueError("Dimension must be at least 2")
    return (n - 2) / (4.0 * (n - 1))


def yamabe_nonlinear_exponent(n: int) -> float:
    """
    Compute the Yamabe nonlinear exponent q(n) = (n+2)/(n-2).

    Args:
        n: Dimension (must be ≥ 3)

    Returns:
        Nonlinear exponent
    """
    if n < 3:
        raise ValueError("Dimension must be at least 3")
    return (n + 2.0) / (n - 2)


def stereo_conformal_factor(r: float) -> float:
    """
    Evaluate the stereographic conformal factor φ(r) = 2/(1+r²).

    Args:
        r: Radial coordinate

    Returns:
        Conformal factor value
    """
    return 2.0 / (1.0 + r**2)


def bubble_energy_radial(n: int, lam: float, num_points: int = 10000,
                         r_max: float = 100.0) -> float:
    """
    Numerically compute the Yamabe energy of the bubble using radial integration.

    E = ∫₀^∞ [|u'|² + c_n R u²] r^{n-1} ω_n dr

    For flat space (R=0), this reduces to the Dirichlet integral.

    Args:
        n: Dimension
        lam: Scale parameter
        num_points: Number of quadrature points
        r_max: Upper integration limit

    Returns:
        Approximate energy (without the angular volume factor ω_n)
    """
    dr = r_max / num_points
    energy = 0.0
    exp = (n - 2) / 2.0

    for i in range(1, num_points):
        r = i * dr
        # Numerical derivative
        u_plus = yamabe_bubble(n, lam, r + dr / 2)
        u_minus = yamabe_bubble(n, lam, r - dr / 2)
        u_prime = (u_plus - u_minus) / dr
        # Integrand: |u'|² r^{n-1}
        energy += u_prime**2 * r**(n - 1) * dr

    return energy


def bubble_lp_norm_radial(n: int, lam: float, p: float,
                          num_points: int = 10000,
                          r_max: float = 100.0) -> float:
    """
    Numerically compute the Lp norm of the bubble: (∫ |u|^p r^{n-1} dr)^{1/p}.

    Args:
        n: Dimension
        lam: Scale parameter
        p: Exponent
        num_points: Number of quadrature points
        r_max: Upper limit

    Returns:
        Approximate Lp norm (without angular factor)
    """
    dr = r_max / num_points
    integral = 0.0

    for i in range(1, num_points):
        r = i * dr
        u = yamabe_bubble(n, lam, r)
        integral += u**p * r**(n - 1) * dr

    return integral**(1.0 / p)


def classify_yamabe_sign(yamabe_constant: float) -> str:
    """
    Classify the Yamabe sign based on the Yamabe constant.

    Args:
        yamabe_constant: The Yamabe constant Y(M, [g])

    Returns:
        'positive', 'zero', or 'negative'
    """
    if yamabe_constant > 1e-10:
        return "positive"
    elif yamabe_constant < -1e-10:
        return "negative"
    else:
        return "zero"


def single_bubble_criterion(total_energy: float, sphere_yamabe: float) -> bool:
    """
    Check the single-bubble criterion: is E_total < 2 Y(S^n)?

    Args:
        total_energy: Total energy of the configuration
        sphere_yamabe: Yamabe constant of the sphere

    Returns:
        True if at most one bubble can form
    """
    return total_energy < 2 * sphere_yamabe


def yamabe_flow_step(u: List[float], dr: float, dt: float,
                     n: int) -> List[float]:
    """
    One time step of the radial Yamabe flow.

    The flow equation in the conformal factor formulation is:
    ∂u/∂t = (n-1)/(n-2) [Δu - c_n R u + λ u^q]

    For flat space with target curvature 0:
    ∂u/∂t ∝ u'' + (n-1)/r · u'

    Args:
        u: Current radial profile (u[i] = u(i·dr))
        dr: Radial step size
        dt: Time step size
        n: Dimension

    Returns:
        Updated radial profile after one time step
    """
    N = len(u)
    u_new = list(u)

    for i in range(1, N - 1):
        r = i * dr
        # Laplacian in radial coordinates: u'' + (n-1)/r · u'
        u_rr = (u[i + 1] - 2 * u[i] + u[i - 1]) / dr**2
        u_r = (u[i + 1] - u[i - 1]) / (2 * dr)
        laplacian = u_rr + (n - 1) / r * u_r

        u_new[i] = u[i] + dt * laplacian

    # Boundary conditions
    u_new[0] = u_new[1]  # Neumann at origin
    u_new[-1] = u[-1]  # Fixed at boundary

    return u_new


def volume_growth_rate(volumes: List[Tuple[float, float]]) -> Tuple[str, float]:
    """
    Estimate the volume growth type from sampled data.

    Uses log-log regression to distinguish polynomial from exponential growth.

    Args:
        volumes: List of (radius, volume) pairs

    Returns:
        Tuple of (growth_type, exponent) where growth_type is
        'polynomial' or 'exponential'
    """
    if len(volumes) < 3:
        raise ValueError("Need at least 3 data points")

    # Filter to positive values
    data = [(r, v) for r, v in volumes if r > 0 and v > 0]
    n = len(data)

    # Log-log regression for polynomial: log(V) = α log(r) + C
    sum_logr = sum(math.log(r) for r, _ in data)
    sum_logv = sum(math.log(v) for _, v in data)
    sum_logr2 = sum(math.log(r)**2 for r, _ in data)
    sum_logr_logv = sum(math.log(r) * math.log(v) for r, v in data)

    poly_alpha = (n * sum_logr_logv - sum_logr * sum_logv) / \
                 (n * sum_logr2 - sum_logr**2)

    # Compute residuals for polynomial fit
    poly_C = (sum_logv - poly_alpha * sum_logr) / n
    poly_residual = sum(
        (math.log(v) - poly_alpha * math.log(r) - poly_C)**2
        for r, v in data
    )

    # Semi-log regression for exponential: log(V) = α r + C
    sum_r = sum(r for r, _ in data)
    sum_r2 = sum(r**2 for r, _ in data)
    sum_r_logv = sum(r * math.log(v) for r, v in data)

    exp_alpha = (n * sum_r_logv - sum_r * sum_logv) / \
                (n * sum_r2 - sum_r**2)

    exp_C = (sum_logv - exp_alpha * sum_r) / n
    exp_residual = sum(
        (math.log(v) - exp_alpha * r - exp_C)**2
        for r, v in data
    )

    if poly_residual < exp_residual:
        return ("polynomial", poly_alpha)
    else:
        return ("exponential", exp_alpha)


def green_function(n: int, r: float) -> float:
    """
    Evaluate the Green's function G_n(r) = r^{2-n} on ℝⁿ.

    Args:
        n: Dimension (≥ 3)
        r: Radius (> 0)

    Returns:
        Green's function value
    """
    if n < 3:
        raise ValueError("Dimension must be at least 3")
    if r <= 0:
        raise ValueError("Radius must be positive")
    return r**(2 - n)


def dual_exponent(p: float) -> float:
    """
    Compute the Hölder dual exponent p' = p/(p-1).

    Args:
        p: Exponent (> 1)

    Returns:
        Dual exponent
    """
    if p <= 1:
        raise ValueError("Exponent must be greater than 1")
    return p / (p - 1)
