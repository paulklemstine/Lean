"""
Inverse Stereographic Neural Field Theory — Core Algorithms

Type-hinted implementations of the key mathematical objects and algorithms
for neural field equations on S² via stereographic projection.
"""

from typing import Callable, Tuple, List
import numpy as np


def conformal_factor_2d(x1: float, x2: float) -> float:
    """Conformal factor σ(x) = 2/(1 + |x|²) for stereographic projection S² → ℝ²."""
    return 2.0 / (1.0 + x1**2 + x2**2)


def conformal_weight(n: int, r_sq: float) -> float:
    """n-dimensional conformal weight (2/(1 + r²))^n."""
    return (2.0 / (1.0 + r_sq)) ** n


def inverse_stereo_2d(x1: float, x2: float) -> Tuple[float, float, float]:
    """Inverse stereographic projection ℝ² → S² ⊂ ℝ³.
    
    Maps (x1, x2) to the point on the unit sphere obtained by
    projecting from the north pole (0, 0, 1).
    """
    r_sq = x1**2 + x2**2
    denom = 1.0 + r_sq
    return (2 * x1 / denom, 2 * x2 / denom, (r_sq - 1) / denom)


def stereo_forward_2d(X: float, Y: float, Z: float) -> Tuple[float, float]:
    """Forward stereographic projection S² → ℝ².
    
    Projects from north pole (0, 0, 1). Undefined at north pole itself.
    """
    denom = 1.0 - Z
    return (X / denom, Y / denom)


def spherical_harmonic_multiplicity(l: int) -> int:
    """Number of independent spherical harmonics of degree l on S²: 2l + 1."""
    return 2 * l + 1


def total_harmonics_up_to(L: int) -> int:
    """Total spherical harmonics up to degree L: (L+1)²."""
    return (L + 1) ** 2


def laplace_beltrami_eigenvalue(l: int) -> int:
    """Eigenvalue λ_l = l(l+1) of -Δ_{S²} on degree-l harmonics."""
    return l * (l + 1)


def pattern_decay_exponent(l: int) -> int:
    """Decay rate of degree-l pattern in stereographic coordinates: 2l."""
    return 2 * l


def mexican_hat_kernel_1d(r: float, sigma_e: float, sigma_i: float) -> float:
    """Mexican-hat (difference of Gaussians) kernel in 1D.
    
    w(r) = exp(-r²/2σ_e²) - exp(-r²/2σ_i²)
    
    Parameters:
        r: distance
        sigma_e: excitatory width (short range)
        sigma_i: inhibitory width (long range), must satisfy sigma_i > sigma_e
    """
    return np.exp(-r**2 / (2 * sigma_e**2)) - np.exp(-r**2 / (2 * sigma_i**2))


def mexican_hat_legendre_coefficients(
    sigma_e: float, sigma_i: float, L_max: int, n_quad: int = 1000
) -> np.ndarray:
    """Compute Fourier-Legendre coefficients of the Mexican-hat kernel on S².
    
    w_l = (2l+1)/2 ∫₋₁¹ w(arccos(t)) P_l(t) dt
    
    Uses Gauss-Legendre quadrature.
    
    Parameters:
        sigma_e: excitatory Gaussian width
        sigma_i: inhibitory Gaussian width  
        L_max: maximum degree to compute
        n_quad: number of quadrature points
    
    Returns:
        Array of coefficients [w_0, w_1, ..., w_L_max]
    """
    from numpy.polynomial.legendre import leggauss
    
    nodes, weights = leggauss(n_quad)
    coeffs = np.zeros(L_max + 1)
    
    # Evaluate kernel at quadrature nodes
    gamma = np.arccos(np.clip(nodes, -1, 1))
    kernel_vals = np.exp(-gamma**2 / (2 * sigma_e**2)) - np.exp(-gamma**2 / (2 * sigma_i**2))
    
    # Compute Legendre polynomials via recurrence
    P_prev = np.ones_like(nodes)  # P_0
    P_curr = nodes.copy()         # P_1
    
    coeffs[0] = 0.5 * np.sum(weights * kernel_vals * P_prev)
    if L_max >= 1:
        coeffs[1] = 1.5 * np.sum(weights * kernel_vals * P_curr)
    
    for l in range(2, L_max + 1):
        P_next = ((2 * l - 1) * nodes * P_curr - (l - 1) * P_prev) / l
        coeffs[l] = (2 * l + 1) / 2 * np.sum(weights * kernel_vals * P_next)
        P_prev = P_curr
        P_curr = P_next
    
    return coeffs


def find_peak_degree(coeffs: np.ndarray) -> int:
    """Find the degree with the largest Fourier-Legendre coefficient."""
    return int(np.argmax(coeffs))


def predicted_pattern_count(peak_degree: int) -> int:
    """Predicted number of stable patterns: 2N + 1."""
    return 2 * peak_degree + 1


def neural_field_stereo_step(
    u: np.ndarray,
    sigma_grid: np.ndarray,
    kernel_matrix: np.ndarray,
    activation: Callable[[np.ndarray], np.ndarray],
    dt: float,
    tau: float,
    dx: float,
) -> np.ndarray:
    """One explicit Euler step of the neural field equation in stereographic coordinates.
    
    ∂u/∂t = -u/τ + σ² · ∫ w(x,y) f(u(y)) σ(y)² dy
    
    Parameters:
        u: current field values on grid (N x N)
        sigma_grid: conformal factor values on grid (N x N)
        kernel_matrix: precomputed interaction weights (N² x N²)
        activation: sigmoidal activation function f
        dt: time step
        tau: time constant
        dx: grid spacing
        
    Returns:
        Updated field values
    """
    N = u.shape[0]
    sigma_sq = sigma_grid ** 2
    
    # Compute interaction integral
    f_u = activation(u)
    integrand = (f_u * sigma_sq).flatten()
    interaction = (kernel_matrix @ integrand).reshape(N, N) * dx**2
    
    # Euler step
    du = (-u / tau + sigma_sq * interaction) * dt
    return u + du


def build_stereo_grid(
    L: float, N: int
) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
    """Build a stereographic coordinate grid with conformal factors.
    
    Parameters:
        L: half-width of grid in stereographic coordinates
        N: number of grid points per dimension
        
    Returns:
        (x1_grid, x2_grid, sigma_grid) — coordinate meshgrids and conformal factors
    """
    x = np.linspace(-L, L, N)
    x1, x2 = np.meshgrid(x, x)
    sigma = 2.0 / (1.0 + x1**2 + x2**2)
    return x1, x2, sigma


def spherical_harmonic_real(l: int, m: int, theta: np.ndarray, phi: np.ndarray) -> np.ndarray:
    """Real spherical harmonic Y_l^m(θ, φ) using scipy.
    
    Parameters:
        l: degree (l ≥ 0)
        m: order (-l ≤ m ≤ l)
        theta: polar angle array
        phi: azimuthal angle array
        
    Returns:
        Array of Y_l^m values
    """
    from scipy.special import sph_harm
    
    if m > 0:
        return np.real(sph_harm(m, l, phi, theta) + (-1)**m * sph_harm(-m, l, phi, theta)) / np.sqrt(2)
    elif m < 0:
        return np.imag(sph_harm(-m, l, phi, theta) - (-1)**m * sph_harm(m, l, phi, theta)) / np.sqrt(2)
    else:
        return np.real(sph_harm(0, l, phi, theta))


def stereo_to_spherical(x1: np.ndarray, x2: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
    """Convert stereographic coordinates to spherical coordinates (θ, φ).
    
    Parameters:
        x1, x2: stereographic coordinates
        
    Returns:
        (theta, phi) — polar and azimuthal angles
    """
    r_sq = x1**2 + x2**2
    theta = 2 * np.arctan(np.sqrt(r_sq))
    phi = np.arctan2(x2, x1)
    return theta, phi


def sigmoid(x: np.ndarray, gain: float = 1.0, threshold: float = 0.0) -> np.ndarray:
    """Sigmoidal activation function f(x) = 1/(1 + exp(-gain*(x - threshold)))."""
    return 1.0 / (1.0 + np.exp(-gain * (x - threshold)))


if __name__ == "__main__":
    # Verify key identities
    print("=== Verification of Key Identities ===")
    
    # Conformal factor at origin
    assert abs(conformal_factor_2d(0, 0) - 2.0) < 1e-15
    print(f"σ(0,0) = {conformal_factor_2d(0, 0)} ✓")
    
    # Conformal factor on unit circle
    for theta in [0, np.pi/4, np.pi/2, np.pi]:
        val = conformal_factor_2d(np.cos(theta), np.sin(theta))
        assert abs(val - 1.0) < 1e-14, f"σ on unit circle = {val}"
    print("σ on unit circle = 1.0 ✓")
    
    # Laplacian identity
    for r_sq in [0, 0.5, 1, 2, 10]:
        lhs = (2 / (1 + r_sq))**2 * (1 + r_sq)**2
        assert abs(lhs - 4.0) < 1e-12
    print("σ² · (1+r²)² = 4 ✓")
    
    # Pattern counts
    for k in [1, 2, 3, 4, 5]:
        assert spherical_harmonic_multiplicity(k) == 2 * k + 1
    print("Multiplicity(l) = 2l+1 ✓")
    
    # Sum formula
    for L in range(10):
        s = sum(spherical_harmonic_multiplicity(l) for l in range(L + 1))
        assert s == (L + 1)**2
    print("Σ(2l+1) = (L+1)² ✓")
    
    print("\n=== Mexican-Hat Kernel Analysis ===")
    for sigma_e, sigma_i in [(0.3, 0.6), (0.2, 0.5), (0.15, 0.4)]:
        coeffs = mexican_hat_legendre_coefficients(sigma_e, sigma_i, 20)
        peak = find_peak_degree(coeffs)
        count = predicted_pattern_count(peak)
        print(f"σ_e={sigma_e}, σ_i={sigma_i}: peak degree={peak}, "
              f"pattern count={count} (={2*peak}+1)")
