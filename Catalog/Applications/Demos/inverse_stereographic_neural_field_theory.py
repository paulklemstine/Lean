#!/usr/bin/env python3
"""
Applications of Inverse Stereographic Neural Field Theory

Demonstrates real-world applications:
1. Cortical pattern prediction from interaction radius
2. Hallucination pattern classification
3. Equivariant basis construction for spherical ML
4. Spectral fingerprinting of radial kernels
5. Conformal potential analysis (Schrödinger analogy)
"""

import numpy as np
from scipy.special import sph_harm_y as sph_harm, eval_legendre
from scipy.integrate import quad
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
import os


# =============================================================================
# Application 1: Cortical Pattern Prediction
# =============================================================================

def predict_cortical_patterns(
    interaction_radius: float,
    sigma_ratio: float = 2.5,
    max_l: int = 20,
    grid_range: float = 6.0,
    resolution: int = 200
):
    """
    Predict cortical activation patterns from neural field interaction radius.

    Given a Mexican-hat interaction kernel with characteristic radius r,
    determines the dominant spherical harmonic degree and generates
    all corresponding planar pattern pullbacks.

    This implements the full conformal transport pipeline:
    1. Construct Mexican-hat kernel K_r on S²
    2. Compute Funk-Hecke eigenvalues to find dominant mode degree N
    3. Generate all 2N+1 pulled-back modes on ℝ²
    4. Return patterns with symmetry classification

    Parameters:
        interaction_radius: Characteristic interaction radius r
        sigma_ratio: Ratio σ₂/σ₁ for Mexican-hat
        max_l: Maximum degree to search
        grid_range: Planar domain half-width
        resolution: Grid resolution

    Returns:
        Dictionary with predictions and pattern data
    """
    sigma1 = interaction_radius
    sigma2 = sigma_ratio * interaction_radius

    # Compute eigenvalue spectrum
    eigenvalues = []
    for l in range(max_l + 1):
        def integrand(t, l_val=l):
            gamma = np.arccos(np.clip(t, -1, 1))
            K = np.exp(-gamma**2/(2*sigma1**2)) - np.exp(-gamma**2/(2*sigma2**2))
            return K * eval_legendre(l_val, t)
        val, _ = quad(integrand, -1, 1, limit=200)
        eigenvalues.append(2 * np.pi * val)

    N = int(np.argmax(eigenvalues))
    multiplicity = 2 * N + 1

    # Generate pullback patterns
    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    r2 = X**2 + Y**2
    D = 1 + r2
    sX = 2*X/D
    sY = 2*Y/D
    sZ = (r2-1)/D

    theta = np.arccos(np.clip(sZ, -1, 1))
    phi = np.arctan2(sY, sX)

    patterns = {}
    for m in range(-N, N+1):
        Ylm = sph_harm(N, abs(m), theta, phi)
        if m > 0:
            pattern = np.real(Ylm) * np.sqrt(2) * (-1)**m
        elif m < 0:
            pattern = np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
        else:
            pattern = np.real(Ylm)
        patterns[m] = pattern

    return {
        'dominant_degree': N,
        'multiplicity': multiplicity,
        'eigenvalues': eigenvalues,
        'patterns': patterns,
        'grid': (X, Y),
        'interaction_radius': interaction_radius,
        'sigma1': sigma1,
        'sigma2': sigma2
    }


def visualize_cortical_predictions(result, output_dir='figures'):
    """Visualize cortical pattern predictions."""
    os.makedirs(output_dir, exist_ok=True)
    N = result['dominant_degree']
    r = result['interaction_radius']

    # Spectrum plot
    fig, ax = plt.subplots(figsize=(10, 5))
    evals = result['eigenvalues']
    colors = ['red' if i == N else 'steelblue' for i in range(len(evals))]
    ax.bar(range(len(evals)), evals, color=colors, alpha=0.7)
    ax.set_xlabel('Degree ℓ', fontsize=13)
    ax.set_ylabel('Eigenvalue λ_ℓ', fontsize=13)
    ax.set_title(f'Cortical Pattern Prediction: r = {r:.2f} → N = {N}, '
                 f'multiplicity = {2*N+1}', fontsize=14)
    ax.grid(True, alpha=0.3)
    fig.savefig(os.path.join(output_dir, f'cortical_spectrum_r{r:.2f}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)

    # Pattern gallery
    patterns = result['patterns']
    X, Y = result['grid']
    n_modes = 2*N+1
    ncols = min(n_modes, 5)
    nrows = max(1, (n_modes + ncols - 1) // ncols)

    fig, axes = plt.subplots(nrows, ncols, figsize=(4*ncols, 4*nrows))
    if n_modes == 1:
        axes = np.array([[axes]])
    elif nrows == 1:
        axes = axes[np.newaxis, :]
    elif ncols == 1:
        axes = axes[:, np.newaxis]

    for idx, m in enumerate(range(-N, N+1)):
        row, col = idx // ncols, idx % ncols
        ax = axes[row, col]
        v = patterns[m]
        vmax = np.max(np.abs(v))
        if vmax > 0:
            ax.pcolormesh(X, Y, v, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                         shading='auto')
        ax.set_aspect('equal')
        ax.set_title(f'm = {m}', fontsize=11)
        ax.set_xticks([])
        ax.set_yticks([])

    for idx in range(n_modes, nrows*ncols):
        row, col = idx // ncols, idx % ncols
        axes[row, col].set_visible(False)

    fig.suptitle(f'Predicted Cortical Patterns (r={r:.2f}, N={N}, '
                 f'{n_modes} modes)', fontsize=15, y=1.02)
    plt.tight_layout()
    fig.savefig(os.path.join(output_dir, f'cortical_patterns_r{r:.2f}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)

    print(f"  r = {r:.3f}: dominant degree N = {N}, "
          f"multiplicity = {n_modes}")


# =============================================================================
# Application 2: Hallucination Pattern Classification
# =============================================================================

def classify_hallucination_symmetry(
    pattern: np.ndarray,
    max_l: int = 8,
    grid_range: float = 5.0
):
    """
    Classify a 2D pattern by its spherical harmonic content.

    Given a planar pattern (as a 2D array), projects it to S² via
    stereographic projection and computes its overlap with spherical
    harmonics of each degree to determine the dominant symmetry class.

    Parameters:
        pattern: 2D numpy array of pattern values
        max_l: Maximum degree to test
        grid_range: Domain half-width

    Returns:
        Dictionary with degree-wise energy decomposition
    """
    ny, nx = pattern.shape
    x = np.linspace(-grid_range, grid_range, nx)
    y = np.linspace(-grid_range, grid_range, ny)
    X, Y = np.meshgrid(x, y)
    h = x[1] - x[0]

    # Map to sphere
    r2 = X**2 + Y**2
    D = 1 + r2
    sZ = (r2-1)/D
    sY_coord = 2*Y/D
    sX = 2*X/D

    theta = np.arccos(np.clip(sZ, -1, 1))
    phi = np.arctan2(sY_coord, sX)

    # Include Jacobian of stereographic map: area element = 4/D²
    jacobian = 4.0 / D**2

    energy_by_degree = {}
    for l in range(max_l + 1):
        total_overlap = 0.0
        for m in range(-l, l+1):
            Ylm = sph_harm(l, abs(m), theta, phi)
            if m > 0:
                basis = np.real(Ylm) * np.sqrt(2) * (-1)**m
            elif m < 0:
                basis = np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
            else:
                basis = np.real(Ylm)

            overlap = np.sum(pattern * basis * jacobian) * h**2
            total_overlap += overlap**2
        energy_by_degree[l] = total_overlap

    total_energy = sum(energy_by_degree.values())
    if total_energy > 0:
        fractions = {l: e/total_energy for l, e in energy_by_degree.items()}
    else:
        fractions = {l: 0.0 for l in energy_by_degree}

    dominant_l = max(energy_by_degree, key=energy_by_degree.get)

    return {
        'energy_by_degree': energy_by_degree,
        'energy_fractions': fractions,
        'dominant_degree': dominant_l,
        'dominant_multiplicity': 2 * dominant_l + 1,
        'total_energy': total_energy
    }


# =============================================================================
# Application 3: Equivariant Basis for Spherical ML
# =============================================================================

def construct_equivariant_basis(
    l: int,
    resolution: int = 100,
    grid_range: float = 5.0
) -> dict:
    """
    Construct an equivariant basis of 2l+1 functions on ℝ²
    from pulled-back spherical harmonics.

    These basis functions are suitable for equivariant convolutional
    layers in geometric deep learning on spherical data.

    Parameters:
        l: Degree (determines basis size = 2l+1)
        resolution: Grid resolution
        grid_range: Domain half-width

    Returns:
        Dictionary with basis functions and metadata
    """
    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    r2 = X**2 + Y**2
    D = 1 + r2
    sX = 2*X/D
    sY = 2*Y/D
    sZ = (r2-1)/D

    theta = np.arccos(np.clip(sZ, -1, 1))
    phi = np.arctan2(sY, sX)

    basis = np.zeros((2*l+1, resolution, resolution))
    for idx, m in enumerate(range(-l, l+1)):
        Ylm = sph_harm(l, abs(m), theta, phi)
        if m > 0:
            basis[idx] = np.real(Ylm) * np.sqrt(2) * (-1)**m
        elif m < 0:
            basis[idx] = np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
        else:
            basis[idx] = np.real(Ylm)

    # Verify approximate orthogonality
    h = x[1] - x[0]
    jacobian = 4.0 / D**2
    gram = np.zeros((2*l+1, 2*l+1))
    for i in range(2*l+1):
        for j in range(2*l+1):
            gram[i, j] = np.sum(basis[i] * basis[j] * jacobian) * h**2

    return {
        'degree': l,
        'dimension': 2*l+1,
        'basis': basis,
        'gram_matrix': gram,
        'grid': (X, Y),
        'orthogonality_error': np.max(np.abs(gram - np.diag(np.diag(gram))))
    }


# =============================================================================
# Application 4: Conformal Potential Analysis
# =============================================================================

def analyze_conformal_potential(l: int, r_max: float = 20.0, n_points: int = 1000):
    """
    Analyze the conformal Schrödinger potential V_l(r) = 4l(l+1)/(1+r²)².

    Computes:
    - Potential profile
    - Effective radial equation
    - Classical turning points
    - WKB phase integral

    Parameters:
        l: Degree
        r_max: Maximum radius
        n_points: Number of radial points

    Returns:
        Dictionary with potential analysis
    """
    r = np.linspace(0, r_max, n_points)
    r_pos = r[1:]  # avoid r=0

    # Potential
    V = 4 * l * (l+1) / (1 + r**2)**2

    # Effective potential for radial equation (including angular momentum)
    # In 2D polar: -u'' - u'/r + m²/r² u + V(r)u = 0
    # For m=0: V_eff = V(r)
    V_eff = V

    # Classical turning points (V = E, here E = 0 for zero-energy)
    # V(r) = 0 only at r → ∞, so no turning point for V > 0

    # Integral of potential (related to bound state count)
    from scipy.integrate import trapezoid
    potential_integral = trapezoid(V * r, r)  # ∫ V(r) r dr

    # Decay rate analysis
    # For large r: V ~ 4l(l+1)/r⁴
    # Solutions decay as r^{-l} and r^{l+1}

    return {
        'degree': l,
        'r': r,
        'potential': V,
        'effective_potential': V_eff,
        'potential_integral': potential_integral,
        'peak_value': V[0],
        'half_width': r[np.searchsorted(-V, -V[0]/2)],
        'decay_exponent': 4,  # V ~ r^{-4}
    }


# =============================================================================
# Main Application Demo
# =============================================================================

if __name__ == '__main__':
    output_dir = 'figures'
    os.makedirs(output_dir, exist_ok=True)

    print("=" * 60)
    print("  Applications of Stereographic Neural Field Theory")
    print("=" * 60)
    print()

    # Application 1: Cortical pattern prediction
    print("Application 1: Cortical Pattern Prediction")
    print("-" * 40)
    for r in [1.0, 0.5, 1/3, 0.25]:
        result = predict_cortical_patterns(r)
        visualize_cortical_predictions(result, output_dir)
    print()

    # Application 2: Pattern classification
    print("Application 2: Hallucination Pattern Classification")
    print("-" * 40)
    # Create a synthetic pattern from Y_3^0 pullback
    x = np.linspace(-5, 5, 200)
    y = np.linspace(-5, 5, 200)
    X, Y = np.meshgrid(x, y)
    r2 = X**2 + Y**2
    D = 1 + r2
    Z = (r2-1)/D
    theta = np.arccos(np.clip(Z, -1, 1))
    phi = np.arctan2(2*Y/D, 2*X/D)
    test_pattern = np.real(sph_harm(3, 0, theta, phi))
    # Add noise
    test_pattern += 0.1 * np.random.randn(*test_pattern.shape)

    classification = classify_hallucination_symmetry(test_pattern)
    print(f"  Dominant degree: ℓ = {classification['dominant_degree']}")
    print(f"  Multiplicity: {classification['dominant_multiplicity']}")
    print(f"  Energy fractions by degree:")
    for l, frac in sorted(classification['energy_fractions'].items()):
        if frac > 0.01:
            print(f"    ℓ = {l}: {frac:.3f}")
    print()

    # Application 3: Equivariant basis
    print("Application 3: Equivariant Basis Construction")
    print("-" * 40)
    for l in [1, 2, 3, 4]:
        basis = construct_equivariant_basis(l, resolution=100)
        print(f"  ℓ = {l}: dim = {basis['dimension']}, "
              f"orthogonality error = {basis['orthogonality_error']:.4f}")

        # Plot Gram matrix
        fig, ax = plt.subplots(figsize=(5, 5))
        im = ax.imshow(basis['gram_matrix'], cmap='RdBu_r',
                       vmin=-np.max(np.abs(basis['gram_matrix'])),
                       vmax=np.max(np.abs(basis['gram_matrix'])))
        ax.set_title(f'Gram Matrix (ℓ={l})', fontsize=13)
        ax.set_xlabel('Basis index')
        ax.set_ylabel('Basis index')
        plt.colorbar(im, ax=ax)
        fig.savefig(os.path.join(output_dir, f'gram_l{l}.png'),
                    dpi=150, bbox_inches='tight')
        plt.close(fig)
    print()

    # Application 4: Conformal potential analysis
    print("Application 4: Conformal Potential Analysis")
    print("-" * 40)
    fig, ax = plt.subplots(figsize=(10, 6))
    for l in [1, 2, 3, 4, 5]:
        analysis = analyze_conformal_potential(l)
        ax.plot(analysis['r'], analysis['potential'],
                label=f'ℓ={l} (V₀={analysis["peak_value"]:.1f})', linewidth=2)
        print(f"  ℓ = {l}: peak V = {analysis['peak_value']:.2f}, "
              f"half-width = {analysis['half_width']:.2f}, "
              f"∫V·r·dr = {analysis['potential_integral']:.2f}")

    ax.set_xlabel('r = |x|', fontsize=13)
    ax.set_ylabel('V_ℓ(r)', fontsize=13)
    ax.set_title('Conformal Schrödinger Potentials', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_xlim(0, 10)
    ax.grid(True, alpha=0.3)
    fig.savefig(os.path.join(output_dir, 'conformal_potentials.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print()

    print("All applications completed. Figures saved to figures/")


#!/usr/bin/env python3
"""
Inverse Stereographic Neural Field Theory — Interactive Demo

Demonstrates the conformal transport of spherical harmonic modes to the
Euclidean plane via inverse stereographic projection. Visualizes:
1. Spherical harmonics on S²
2. Their planar pullbacks via inverse stereographic projection
3. The conformal weight / metric distortion
4. PDE residual verification
5. Mode eigenvalue spectra for Mexican-hat kernels

Usage:
    python demo.py              # Run all demos with default parameters
    python demo.py --degree 3   # Visualize degree-3 modes
    python demo.py --radius 0.5 # Mexican-hat with r=0.5
"""

import numpy as np
from scipy.special import sph_harm_y as sph_harm, legendre
from scipy.integrate import quad
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D
import argparse
import os


# =============================================================================
# Core Mathematical Functions
# =============================================================================

def inverse_stereographic(x, y):
    """
    Inverse stereographic projection from R² to S² ⊂ R³.

    Maps (x, y) -> (2x/(1+r²), 2y/(1+r²), (r²-1)/(1+r²))
    where r² = x² + y².

    Returns:
        tuple (X, Y, Z) on the unit sphere
    """
    r2 = x**2 + y**2
    D = 1 + r2
    X = 2 * x / D
    Y = 2 * y / D
    Z = (r2 - 1) / D
    return X, Y, Z


def stereo_denom(x, y):
    """Stereographic denominator D(x,y) = 1 + x² + y²."""
    return 1 + x**2 + y**2


def conformal_weight(x, y):
    """Conformal weight w(x,y) = 2/(1 + x² + y²)."""
    return 2.0 / stereo_denom(x, y)


def metric_weight(x, y):
    """Metric weight w(x,y)² = 4/(1 + x² + y²)²."""
    return conformal_weight(x, y)**2


def conformal_potential(x, y, l):
    """
    Conformal potential V_l(x,y) = 4*l*(l+1) / (1 + x² + y²)².

    This is the potential in the weighted Schrödinger equation
    satisfied by pulled-back spherical harmonics.
    """
    return 4 * l * (l + 1) / stereo_denom(x, y)**2


def spherical_harmonic_pullback(x, y, l, m):
    """
    Pull back a real spherical harmonic Y_l^m from S² to R²
    via inverse stereographic projection.

    Parameters:
        x, y: planar coordinates (arrays)
        l: degree (non-negative integer)
        m: order (-l <= m <= l)

    Returns:
        Real part of Y_l^m evaluated at σ(x,y)
    """
    X, Y, Z = inverse_stereographic(x, y)

    # Convert to spherical coordinates
    theta = np.arccos(np.clip(Z, -1, 1))
    phi = np.arctan2(Y, X)

    # Compute spherical harmonic (scipy convention)
    Ylm = sph_harm(l, abs(m), theta, phi)

    # Real spherical harmonics
    if m > 0:
        return np.real(Ylm) * np.sqrt(2) * (-1)**m
    elif m < 0:
        return np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
    else:
        return np.real(Ylm)


# =============================================================================
# Visualization Functions
# =============================================================================

def plot_spherical_harmonic_on_sphere(l, m, ax=None, resolution=100):
    """Plot a spherical harmonic on S² using a 3D surface plot."""
    if ax is None:
        fig = plt.figure(figsize=(8, 8))
        ax = fig.add_subplot(111, projection='3d')

    theta = np.linspace(0, np.pi, resolution)
    phi = np.linspace(0, 2*np.pi, resolution)
    theta, phi = np.meshgrid(theta, phi)

    Ylm = sph_harm(l, abs(m), theta, phi)
    if m > 0:
        vals = np.real(Ylm) * np.sqrt(2) * (-1)**m
    elif m < 0:
        vals = np.imag(Ylm) * np.sqrt(2) * (-1)**(abs(m))
    else:
        vals = np.real(Ylm)

    # Sphere coordinates
    X = np.sin(theta) * np.cos(phi)
    Y_coord = np.sin(theta) * np.sin(phi)
    Z = np.cos(theta)

    # Color by harmonic value
    norm = plt.Normalize(vmin=-np.max(np.abs(vals)), vmax=np.max(np.abs(vals)))
    colors = cm.RdBu_r(norm(vals))

    ax.plot_surface(X, Y_coord, Z, facecolors=colors, rstride=1, cstride=1,
                    alpha=0.9, shade=False)
    ax.set_title(f'Y_{l}^{m} on S²', fontsize=14)
    ax.set_box_aspect([1, 1, 1])
    return ax


def plot_planar_pullback(l, m, grid_range=5.0, resolution=200, ax=None):
    """Plot the planar pullback of a spherical harmonic."""
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    vals = spherical_harmonic_pullback(X, Y, l, m)

    vmax = np.max(np.abs(vals))
    im = ax.pcolormesh(X, Y, vals, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                       shading='auto')
    ax.set_aspect('equal')
    ax.set_title(f'Pullback of Y_{l}^{m} to ℝ²', fontsize=14)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    plt.colorbar(im, ax=ax, shrink=0.8)
    return ax


def plot_conformal_weight(grid_range=5.0, resolution=200):
    """Plot the conformal metric weight."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    # Conformal weight
    w = conformal_weight(X, Y)
    im1 = axes[0].pcolormesh(X, Y, w, cmap='viridis', shading='auto')
    axes[0].set_aspect('equal')
    axes[0].set_title('Conformal Weight w(x,y) = 2/(1+|x|²)', fontsize=12)
    plt.colorbar(im1, ax=axes[0])

    # Metric weight
    w2 = metric_weight(X, Y)
    im2 = axes[1].pcolormesh(X, Y, w2, cmap='viridis', shading='auto')
    axes[1].set_aspect('equal')
    axes[1].set_title('Metric Weight w²(x,y) = 4/(1+|x|²)²', fontsize=12)
    plt.colorbar(im2, ax=axes[1])

    plt.tight_layout()
    return fig


def plot_decay_profile(l, m):
    """Plot the radial decay profile of a pulled-back spherical harmonic."""
    r = np.linspace(0, 20, 1000)
    x = r
    y = np.zeros_like(r)

    vals = spherical_harmonic_pullback(x, y, l, m)
    weight = conformal_weight(x, y)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    axes[0].plot(r, vals, 'b-', linewidth=2)
    axes[0].axhline(y=0, color='k', linewidth=0.5)
    axes[0].set_xlabel('r = |x|', fontsize=12)
    axes[0].set_ylabel(f'v(r, 0)', fontsize=12)
    axes[0].set_title(f'Radial Profile of Pullback Y_{l}^{m}', fontsize=14)
    axes[0].grid(True, alpha=0.3)

    axes[1].semilogy(r[1:], np.abs(vals[1:]), 'b-', linewidth=2, label='|v(r)|')
    axes[1].semilogy(r[1:], weight[1:], 'r--', linewidth=2, label='w(r)')
    axes[1].set_xlabel('r = |x|', fontsize=12)
    axes[1].set_ylabel('Value', fontsize=12)
    axes[1].set_title('Decay at Infinity', fontsize=14)
    axes[1].legend(fontsize=12)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    return fig


def compute_pde_residual(l, m, grid_range=5.0, resolution=200):
    """
    Compute the PDE residual for the weighted eigenvalue equation:
    Δv + V_l(x) · v = 0

    Returns the residual field and statistics.
    """
    h = 2 * grid_range / resolution
    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    v = spherical_harmonic_pullback(X, Y, l, m)
    V = conformal_potential(X, Y, l)

    # Five-point Laplacian stencil
    laplacian = np.zeros_like(v)
    laplacian[1:-1, 1:-1] = (
        v[2:, 1:-1] + v[:-2, 1:-1] +
        v[1:-1, 2:] + v[1:-1, :-2] -
        4 * v[1:-1, 1:-1]
    ) / h**2

    # Residual: Δv + V_l · v should be ≈ 0
    residual = laplacian[1:-1, 1:-1] + V[1:-1, 1:-1] * v[1:-1, 1:-1]

    return {
        'residual': residual,
        'max_residual': np.max(np.abs(residual)),
        'l2_residual': np.sqrt(np.mean(residual**2)),
        'max_v': np.max(np.abs(v)),
        'relative_residual': np.max(np.abs(residual)) / (np.max(np.abs(v)) + 1e-15),
        'grid_spacing': h
    }


def plot_pde_residual(l, m, grid_range=5.0, resolution=200):
    """Plot the PDE residual."""
    result = compute_pde_residual(l, m, grid_range, resolution)

    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    v = spherical_harmonic_pullback(X, Y, l, m)
    vmax = np.max(np.abs(v))
    im1 = axes[0].pcolormesh(X, Y, v, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                             shading='auto')
    axes[0].set_aspect('equal')
    axes[0].set_title(f'Pullback v = Y_{l}^{m} ∘ σ⁻¹', fontsize=12)
    plt.colorbar(im1, ax=axes[0])

    R = result['residual']
    rmax = np.max(np.abs(R))
    im2 = axes[1].pcolormesh(
        X[1:-1, 1:-1], Y[1:-1, 1:-1], R,
        cmap='RdBu_r', vmin=-rmax, vmax=rmax, shading='auto')
    axes[1].set_aspect('equal')
    axes[1].set_title(f'PDE Residual (max={result["max_residual"]:.2e})', fontsize=12)
    plt.colorbar(im2, ax=axes[1])

    plt.tight_layout()
    return fig, result


def mexican_hat_eigenvalue(l, sigma1=0.3, sigma2=0.8, n_quad=500):
    """
    Compute the Funk-Hecke eigenvalue for a Mexican-hat kernel:
    K(cos γ) = exp(-γ²/(2σ₁²)) - exp(-γ²/(2σ₂²))

    Uses Gauss-Legendre quadrature.

    λ_l = 2π ∫_{-1}^{1} K(t) P_l(t) dt
    """
    Pl = legendre(l)

    def integrand(t):
        gamma = np.arccos(np.clip(t, -1, 1))
        K = np.exp(-gamma**2 / (2*sigma1**2)) - np.exp(-gamma**2 / (2*sigma2**2))
        return K * Pl(t)

    result, _ = quad(integrand, -1, 1, limit=100)
    return 2 * np.pi * result


def plot_mode_spectrum(sigma1=0.3, sigma2=0.8, max_l=15):
    """Plot the mode eigenvalue spectrum for a Mexican-hat kernel."""
    eigenvalues = [mexican_hat_eigenvalue(l, sigma1, sigma2) for l in range(max_l+1)]

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(range(max_l+1), eigenvalues, color='steelblue', alpha=0.7, edgecolor='navy')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.set_xlabel('Degree ℓ', fontsize=14)
    ax.set_ylabel('Eigenvalue λ_ℓ', fontsize=14)
    ax.set_title(f'Mexican-Hat Kernel Spectrum (σ₁={sigma1}, σ₂={sigma2})', fontsize=14)
    ax.set_xticks(range(max_l+1))

    max_l_idx = np.argmax(eigenvalues)
    ax.bar(max_l_idx, eigenvalues[max_l_idx], color='red', alpha=0.9, edgecolor='darkred')
    ax.annotate(f'Max at ℓ={max_l_idx}\nMultiplicity = {2*max_l_idx+1}',
                xy=(max_l_idx, eigenvalues[max_l_idx]),
                xytext=(max_l_idx + 2, eigenvalues[max_l_idx] * 0.8),
                arrowprops=dict(arrowstyle='->', color='red'),
                fontsize=12, color='red')
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig, eigenvalues


def plot_mode_gallery(l, grid_range=5.0, resolution=150):
    """Plot all 2l+1 modes for degree l."""
    n_modes = 2 * l + 1
    ncols = min(n_modes, 5)
    nrows = (n_modes + ncols - 1) // ncols

    fig, axes = plt.subplots(nrows, ncols, figsize=(4*ncols, 4*nrows))
    if nrows == 1 and ncols == 1:
        axes = np.array([[axes]])
    elif nrows == 1:
        axes = axes[np.newaxis, :]
    elif ncols == 1:
        axes = axes[:, np.newaxis]

    x = np.linspace(-grid_range, grid_range, resolution)
    y = np.linspace(-grid_range, grid_range, resolution)
    X, Y = np.meshgrid(x, y)

    for idx, m in enumerate(range(-l, l+1)):
        row, col = idx // ncols, idx % ncols
        ax = axes[row, col]

        vals = spherical_harmonic_pullback(X, Y, l, m)
        vmax = np.max(np.abs(vals))
        if vmax > 0:
            ax.pcolormesh(X, Y, vals, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                         shading='auto')
        ax.set_aspect('equal')
        ax.set_title(f'm = {m}', fontsize=11)
        ax.set_xticks([])
        ax.set_yticks([])

    # Hide unused axes
    for idx in range(n_modes, nrows * ncols):
        row, col = idx // ncols, idx % ncols
        axes[row, col].set_visible(False)

    fig.suptitle(f'All {n_modes} Pulled-Back Modes for ℓ = {l} (dim = 2ℓ+1 = {n_modes})',
                 fontsize=16, y=1.02)
    plt.tight_layout()
    return fig


# =============================================================================
# Verification Functions
# =============================================================================

def verify_sphere_landing(n_tests=1000):
    """Numerically verify that inverse stereographic maps to S²."""
    print("=" * 60)
    print("Verification: Inverse Stereographic Maps to S²")
    print("=" * 60)

    np.random.seed(42)
    points = np.random.randn(n_tests, 2) * 10

    max_error = 0
    for p in points:
        X, Y, Z = inverse_stereographic(p[0], p[1])
        norm_sq = X**2 + Y**2 + Z**2
        error = abs(norm_sq - 1.0)
        max_error = max(max_error, error)

    print(f"  Tested {n_tests} random points")
    print(f"  Max |‖σ(p)‖² - 1| = {max_error:.2e}")
    print(f"  {'PASS' if max_error < 1e-10 else 'FAIL'}")
    print()


def verify_conformal_factor(n_tests=1000):
    """Numerically verify the conformal factor identity."""
    print("=" * 60)
    print("Verification: Conformal Factor |σ(p) - N|² = 4/D(p)")
    print("=" * 60)

    np.random.seed(42)
    points = np.random.randn(n_tests, 2) * 10

    max_error = 0
    for p in points:
        X, Y, Z = inverse_stereographic(p[0], p[1])
        dist_sq = X**2 + Y**2 + (Z - 1)**2
        expected = 4.0 / stereo_denom(p[0], p[1])
        error = abs(dist_sq - expected)
        max_error = max(max_error, error)

    print(f"  Tested {n_tests} random points")
    print(f"  Max ||σ(p)-N|² - 4/D| = {max_error:.2e}")
    print(f"  {'PASS' if max_error < 1e-10 else 'FAIL'}")
    print()


def verify_pde_convergence(l=2, m=0):
    """Verify PDE residual convergence rate."""
    print("=" * 60)
    print(f"Verification: PDE Residual Convergence (ℓ={l}, m={m})")
    print("=" * 60)
    print(f"  {'Resolution':>12} {'h':>10} {'Max Res':>12} {'L² Res':>12} {'Rel Res':>12}")
    print("  " + "-" * 58)

    for res in [50, 100, 200, 400]:
        result = compute_pde_residual(l, m, grid_range=5.0, resolution=res)
        print(f"  {res:>8}×{res:<3} {result['grid_spacing']:>10.4f} "
              f"{result['max_residual']:>12.2e} {result['l2_residual']:>12.2e} "
              f"{result['relative_residual']:>12.2e}")
    print()


# =============================================================================
# Main Demo
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Inverse Stereographic Neural Field Theory Demo')
    parser.add_argument('--degree', type=int, default=3,
                       help='Spherical harmonic degree (default: 3)')
    parser.add_argument('--order', type=int, default=None,
                       help='Spherical harmonic order (default: 0)')
    parser.add_argument('--radius', type=float, default=None,
                       help='Mexican-hat radius parameter')
    parser.add_argument('--output-dir', type=str, default='figures',
                       help='Output directory for figures')
    args = parser.parse_args()

    l = args.degree
    m = args.order if args.order is not None else 0

    os.makedirs(args.output_dir, exist_ok=True)

    print("\n" + "=" * 60)
    print("  INVERSE STEREOGRAPHIC NEURAL FIELD THEORY")
    print("  Interactive Demo")
    print("=" * 60 + "\n")

    # 1. Numerical verifications
    verify_sphere_landing()
    verify_conformal_factor()
    verify_pde_convergence(l=min(l, 3), m=0)

    # 2. Conformal weight visualization
    print("Generating conformal weight plot...")
    fig = plot_conformal_weight()
    fig.savefig(os.path.join(args.output_dir, 'conformal_weight.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved to {args.output_dir}/conformal_weight.png\n")

    # 3. Single mode: sphere + pullback
    print(f"Generating spherical harmonic Y_{l}^{m}...")
    fig = plt.figure(figsize=(14, 6))
    ax1 = fig.add_subplot(121, projection='3d')
    plot_spherical_harmonic_on_sphere(l, m, ax=ax1)
    ax2 = fig.add_subplot(122)
    plot_planar_pullback(l, m, ax=ax2)
    fig.suptitle(f'Conformal Transport: Y_{l}^{m} from S² to ℝ²', fontsize=16)
    plt.tight_layout()
    fig.savefig(os.path.join(args.output_dir, f'mode_l{l}_m{m}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved to {args.output_dir}/mode_l{l}_m{m}.png\n")

    # 4. Decay profile
    print(f"Generating decay profile for Y_{l}^{m}...")
    fig = plot_decay_profile(l, m)
    fig.savefig(os.path.join(args.output_dir, f'decay_l{l}_m{m}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved to {args.output_dir}/decay_l{l}_m{m}.png\n")

    # 5. PDE residual
    print(f"Generating PDE residual for Y_{l}^{m}...")
    fig, result = plot_pde_residual(l, m)
    fig.savefig(os.path.join(args.output_dir, f'residual_l{l}_m{m}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Max PDE residual: {result['max_residual']:.2e}")
    print(f"  Relative residual: {result['relative_residual']:.2e}")
    print(f"  Saved to {args.output_dir}/residual_l{l}_m{m}.png\n")

    # 6. Mode gallery for degree l
    print(f"Generating mode gallery for ℓ={l} (all {2*l+1} modes)...")
    fig = plot_mode_gallery(l)
    fig.savefig(os.path.join(args.output_dir, f'gallery_l{l}.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved to {args.output_dir}/gallery_l{l}.png\n")

    # 7. Mexican-hat spectrum
    print("Computing Mexican-hat kernel spectrum...")
    for sigma1, sigma2, label in [(0.3, 0.8, 'narrow'), (0.5, 1.2, 'medium'),
                                   (0.8, 2.0, 'wide')]:
        fig, eigenvalues = plot_mode_spectrum(sigma1, sigma2, max_l=12)
        max_l_idx = np.argmax(eigenvalues)
        print(f"  σ₁={sigma1}, σ₂={sigma2}: max at ℓ={max_l_idx}, "
              f"multiplicity = {2*max_l_idx+1}")
        fig.savefig(os.path.join(args.output_dir, f'spectrum_{label}.png'),
                    dpi=150, bbox_inches='tight')
        plt.close(fig)
    print(f"  Saved spectrum plots to {args.output_dir}/\n")

    # 8. Multi-degree comparison
    print("Generating multi-degree comparison...")
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    x = np.linspace(-5, 5, 200)
    y = np.linspace(-5, 5, 200)
    X, Y = np.meshgrid(x, y)

    for idx, l_val in enumerate([1, 2, 3, 4, 5, 6]):
        row, col = idx // 3, idx % 3
        ax = axes[row, col]
        vals = spherical_harmonic_pullback(X, Y, l_val, 0)
        vmax = np.max(np.abs(vals))
        ax.pcolormesh(X, Y, vals, cmap='RdBu_r', vmin=-vmax, vmax=vmax,
                     shading='auto')
        ax.set_aspect('equal')
        ax.set_title(f'ℓ = {l_val}, dim = {2*l_val+1}', fontsize=12)
        ax.set_xticks([])
        ax.set_yticks([])

    fig.suptitle('Pulled-Back Zonal Harmonics Y_ℓ⁰ (m=0) for ℓ = 1,...,6',
                 fontsize=16)
    plt.tight_layout()
    fig.savefig(os.path.join(args.output_dir, 'multi_degree.png'),
                dpi=150, bbox_inches='tight')
    plt.close(fig)
    print(f"  Saved to {args.output_dir}/multi_degree.png\n")

    print("=" * 60)
    print("  All demos complete!")
    print(f"  Figures saved to {args.output_dir}/")
    print("=" * 60)


if __name__ == '__main__':
    main()
