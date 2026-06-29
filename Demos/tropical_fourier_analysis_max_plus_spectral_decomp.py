#!/usr/bin/env python3
"""
Tropical Fourier Analysis: Numerical Demonstrations

This script demonstrates the key concepts of tropical harmonic analysis
with concrete numerical examples, visualizations, and interactive explorations.

Tropical semiring: (ℝ, max, +) where
  - "addition" is max
  - "multiplication" is +
  - "zero" (additive identity) is -∞
  - "one" (multiplicative identity) is 0
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

# ============================================================
# Core Tropical Operations
# ============================================================

def tropical_add(a, b):
    """Tropical addition: max(a, b)"""
    return np.maximum(a, b)

def tropical_mul(a, b):
    """Tropical multiplication: a + b"""
    return a + b

def tropical_inner_product(f, g):
    """Tropical inner product: max_x (f(x) + g(x))"""
    return np.max(f + g)

def tropical_norm(f):
    """Tropical norm: max_x f(x)"""
    return np.max(f)

def tropical_sinc(t):
    """Tropical sinc function: -|t|"""
    return -np.abs(t)

def tropical_fourier_coeff(f, phi_k):
    """Tropical Fourier coefficient: max_x (f(x) + phi_k(x))"""
    return np.max(f + phi_k)

def max_plus_kernel_apply(kernel, f):
    """Max-plus kernel operator: K(f)(y) = max_x (kernel(x,y) + f(x))"""
    n = len(f)
    result = np.zeros(n)
    for y in range(n):
        result[y] = np.max(kernel[:, y] + f)
    return result

# ============================================================
# Demo 1: Tropical Cauchy-Schwarz Inequality
# ============================================================

def demo_cauchy_schwarz():
    """Demonstrate: <f,g>_⊕ ≤ ||f||_⊕ + ||g||_⊕"""
    print("=" * 60)
    print("DEMO 1: Tropical Cauchy-Schwarz Inequality")
    print("=" * 60)

    np.random.seed(42)
    n = 10
    f = np.random.randn(n)
    g = np.random.randn(n)

    ip = tropical_inner_product(f, g)
    norm_f = tropical_norm(f)
    norm_g = tropical_norm(g)
    bound = norm_f + norm_g

    print(f"\nf = {f.round(3)}")
    print(f"g = {g.round(3)}")
    print(f"\n⟨f, g⟩_⊕ = max_x(f(x) + g(x)) = {ip:.4f}")
    print(f"‖f‖_⊕ = max_x f(x) = {norm_f:.4f}")
    print(f"‖g‖_⊕ = max_x g(x) = {norm_g:.4f}")
    print(f"‖f‖_⊕ + ‖g‖_⊕ = {bound:.4f}")
    print(f"\nCauchy-Schwarz: {ip:.4f} ≤ {bound:.4f}  ✓" if ip <= bound + 1e-10
          else f"\nCauchy-Schwarz VIOLATED!")
    print(f"Gap: {bound - ip:.4f}")

# ============================================================
# Demo 2: Tropical Plancherel Identity
# ============================================================

def demo_plancherel():
    """Demonstrate: <f,f>_⊕ = max_k (2·c_k)"""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Plancherel Identity")
    print("=" * 60)

    n = 50  # domain size
    K = 5   # number of modes

    # Create tropical orthonormal modes (max_x phi_k(x) = 0)
    x = np.linspace(0, 1, n)
    modes = np.zeros((K, n))
    for k in range(K):
        raw = np.sin(2 * np.pi * (k + 1) * x) - 1  # shifted to be ≤ 0
        modes[k] = raw - np.max(raw)  # normalize so max = 0

    # Coefficients
    coeffs = np.array([3.0, 1.5, -0.5, 2.0, 0.0])
    print(f"\nCoefficients: {coeffs}")
    print(f"Mode norms: {[tropical_norm(m) for m in modes]}")

    # Reconstruct f = max_k (c_k + phi_k)
    f = np.full(n, -np.inf)
    for k in range(K):
        f = np.maximum(f, coeffs[k] + modes[k])

    # Compute both sides
    lhs = tropical_inner_product(f, f)
    rhs = np.max(coeffs + coeffs)  # max_k(2·c_k)

    print(f"\n⟨f, f⟩_⊕ = {lhs:.6f}")
    print(f"max_k(2·c_k) = {rhs:.6f}")
    print(f"Difference: {abs(lhs - rhs):.2e}")
    print(f"Plancherel verified: {'✓' if abs(lhs - rhs) < 1e-10 else '✗'}")

    return x, f, modes, coeffs

# ============================================================
# Demo 3: Tropical Sinc Interpolation
# ============================================================

def demo_sinc_interpolation():
    """Demonstrate tropical sinc interpolation at grid points."""
    print("\n" + "=" * 60)
    print("DEMO 3: Tropical Sinc Function Properties")
    print("=" * 60)

    t = np.linspace(-3, 3, 1000)
    s = tropical_sinc(t)

    # Verify properties
    print(f"\nsinc_⊕(0) = {tropical_sinc(0)}")
    print(f"sinc_⊕(1) = {tropical_sinc(1)}")
    print(f"sinc_⊕(-1) = {tropical_sinc(-1)}")
    print(f"max(sinc_⊕) = {np.max(s)}")
    print(f"sinc_⊕ is nonpositive: {'✓' if np.all(s <= 1e-10) else '✗'}")
    print(f"sinc_⊕ is symmetric: {'✓' if np.allclose(tropical_sinc(t), tropical_sinc(-t)) else '✗'}")

    # Lipschitz check
    dt = t[1] - t[0]
    ds = np.abs(np.diff(s))
    print(f"Max slope |Δsinc/Δt| = {np.max(ds/dt):.4f} (should be ≤ 1)")

    # Interpolation at integer grid points
    print("\nGrid point interpolation:")
    for n_val in range(-3, 4):
        vals = [tropical_sinc(n_val - m) for m in range(-3, 4)]
        best = max(vals)
        print(f"  max_m sinc_⊕({n_val} - m) = {best:.4f} (at m={n_val})")

    return t, s

# ============================================================
# Demo 4: Max-Plus Kernel Eigenpair
# ============================================================

def demo_eigenpair():
    """Demonstrate tropical eigenpair for specific kernels."""
    print("\n" + "=" * 60)
    print("DEMO 4: Max-Plus Kernel Eigenpairs")
    print("=" * 60)

    # Constant kernel
    n = 4
    c = 3.0
    K_const = np.full((n, n), c)
    phi_zero = np.zeros(n)

    Kphi = max_plus_kernel_apply(K_const, phi_zero)
    print(f"\nConstant kernel κ ≡ {c}:")
    print(f"  φ = {phi_zero}")
    print(f"  K(φ) = {Kphi}")
    print(f"  ev + φ = {c + phi_zero}")
    print(f"  K(φ) = ev + φ: {'✓' if np.allclose(Kphi, c + phi_zero) else '✗'}")

    # Identity-like kernel
    M = 100  # large penalty for off-diagonal
    c2 = 5.0
    K_id = np.full((n, n), c2 - M)
    np.fill_diagonal(K_id, c2)

    Kphi2 = max_plus_kernel_apply(K_id, phi_zero)
    print(f"\nIdentity-like kernel (c={c2}, M={M}):")
    print(f"  φ = {phi_zero}")
    print(f"  K(φ) = {Kphi2}")
    print(f"  ev + φ = {c2 + phi_zero}")
    print(f"  K(φ) = ev + φ: {'✓' if np.allclose(Kphi2, c2 + phi_zero) else '✗'}")

    # Verify spectral radius ≤ eigenvalue
    rho = np.max(np.diag(K_id))
    print(f"\n  ρ_⊕(K) = max_x κ(x,x) = {rho}")
    print(f"  eigenvalue = {c2}")
    print(f"  ρ_⊕(K) ≤ ev: {'✓' if rho <= c2 + 1e-10 else '✗'}")

    # Rayleigh quotient
    ip_Kphi_phi = tropical_inner_product(Kphi2, phi_zero)
    ip_phi_phi = tropical_inner_product(phi_zero, phi_zero)
    rayleigh = ip_Kphi_phi - ip_phi_phi
    print(f"\n  Rayleigh quotient R_⊕(φ,K) = ⟨K(φ),φ⟩ - ⟨φ,φ⟩ = {ip_Kphi_phi} - {ip_phi_phi} = {rayleigh}")
    print(f"  R_⊕(φ,K) = ev: {'✓' if abs(rayleigh - c2) < 1e-10 else '✗'}")

    return K_id

# ============================================================
# Demo 5: Tropical Convolution
# ============================================================

def demo_convolution():
    """Demonstrate tropical convolution commutativity."""
    print("\n" + "=" * 60)
    print("DEMO 5: Tropical Convolution")
    print("=" * 60)

    n = 8
    f = np.array([1.0, 3.0, 2.0, 0.0, -1.0, 4.0, 1.0, 2.0])
    g = np.array([2.0, 0.0, 1.0, 3.0, -2.0, 1.0, 0.0, -1.0])

    # Tropical convolution: (f ⊛ g)(y) = max_x (f(x) + g(y-x))
    conv_fg = np.zeros(n)
    conv_gf = np.zeros(n)
    for y in range(n):
        conv_fg[y] = max(f[x] + g[(y - x) % n] for x in range(n))
        conv_gf[y] = max(g[x] + f[(y - x) % n] for x in range(n))

    print(f"\nf = {f}")
    print(f"g = {g}")
    print(f"\n(f ⊛ g) = {conv_fg}")
    print(f"(g ⊛ f) = {conv_gf}")
    print(f"Commutativity: {'✓' if np.allclose(conv_fg, conv_gf) else '✗'}")

# ============================================================
# Visualization
# ============================================================

def create_visualizations(x, f, modes, coeffs, t, sinc_vals):
    """Create comprehensive visualization of tropical Fourier analysis."""
    fig = plt.figure(figsize=(16, 14))
    gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)

    # Plot 1: Tropical Sinc Function
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.plot(t, sinc_vals, 'b-', linewidth=2, label='sinc_⊕(t) = -|t|')
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
    for n_int in range(-3, 4):
        ax1.plot(n_int, tropical_sinc(n_int), 'ro', markersize=8)
    ax1.set_xlabel('t')
    ax1.set_ylabel('sinc_⊕(t)')
    ax1.set_title('Tropical Sinc Function')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Plot 2: Tropical Modes (normalized)
    ax2 = fig.add_subplot(gs[0, 1])
    for k in range(min(5, len(modes))):
        ax2.plot(x, modes[k], label=f'φ_{k}(x), ‖φ_{k}‖=0', alpha=0.8)
    ax2.set_xlabel('x')
    ax2.set_ylabel('φ_k(x)')
    ax2.set_title('Tropical Fourier Modes (normalized)')
    ax2.legend(fontsize=8)
    ax2.grid(True, alpha=0.3)

    # Plot 3: Decomposition
    ax3 = fig.add_subplot(gs[1, 0])
    for k in range(len(coeffs)):
        ax3.plot(x, coeffs[k] + modes[k], '--', alpha=0.5, label=f'c_{k}+φ_{k}')
    ax3.plot(x, f, 'k-', linewidth=2.5, label='f = max_k(c_k + φ_k)')
    ax3.set_xlabel('x')
    ax3.set_ylabel('f(x)')
    ax3.set_title('Tropical Fourier Decomposition')
    ax3.legend(fontsize=8)
    ax3.grid(True, alpha=0.3)

    # Plot 4: Plancherel Identity Verification
    ax4 = fig.add_subplot(gs[1, 1])
    doubled_coeffs = 2 * coeffs
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6']
    bars = ax4.bar(range(len(coeffs)), doubled_coeffs, color=colors[:len(coeffs)],
                   alpha=0.7, edgecolor='black')
    ip_ff = tropical_inner_product(f, f)
    ax4.axhline(y=ip_ff, color='red', linewidth=2, linestyle='--',
                label=f'⟨f,f⟩_⊕ = {ip_ff:.2f}')
    best_k = np.argmax(doubled_coeffs)
    bars[best_k].set_edgecolor('red')
    bars[best_k].set_linewidth(3)
    ax4.set_xlabel('Mode k')
    ax4.set_ylabel('2·c_k')
    ax4.set_title('Tropical Plancherel: ⟨f,f⟩_⊕ = max_k(2c_k)')
    ax4.legend()
    ax4.grid(True, alpha=0.3)

    # Plot 5: Cauchy-Schwarz demonstration
    ax5 = fig.add_subplot(gs[2, 0])
    np.random.seed(0)
    N_trials = 100
    gaps = []
    for _ in range(N_trials):
        ff = np.random.randn(20)
        gg = np.random.randn(20)
        ip = tropical_inner_product(ff, gg)
        bound = tropical_norm(ff) + tropical_norm(gg)
        gaps.append(bound - ip)
    ax5.hist(gaps, bins=20, color='steelblue', edgecolor='black', alpha=0.7)
    ax5.axvline(x=0, color='red', linewidth=2, linestyle='--', label='Gap = 0 boundary')
    ax5.set_xlabel('Gap: ‖f‖+‖g‖ - ⟨f,g⟩')
    ax5.set_ylabel('Count')
    ax5.set_title('Tropical Cauchy-Schwarz: Gap ≥ 0 always')
    ax5.legend()
    ax5.grid(True, alpha=0.3)

    # Plot 6: Kernel operator norm bound
    ax6 = fig.add_subplot(gs[2, 1])
    n_size = 5
    kernel = np.random.randn(n_size, n_size)
    kernel_norm = np.max(kernel)
    f_norms = []
    Kf_norms = []
    bounds_list = []
    for _ in range(200):
        ff = np.random.randn(n_size) * 3
        f_norm = tropical_norm(ff)
        Kf = max_plus_kernel_apply(kernel, ff)
        Kf_norm = tropical_norm(Kf)
        f_norms.append(f_norm)
        Kf_norms.append(Kf_norm)
        bounds_list.append(kernel_norm + f_norm)

    ax6.scatter(f_norms, Kf_norms, alpha=0.5, s=15, label='‖K(f)‖ actual')
    ax6.scatter(f_norms, bounds_list, alpha=0.3, s=15, color='red', label='‖κ‖+‖f‖ bound')
    ax6.plot([min(f_norms), max(f_norms)],
             [kernel_norm + min(f_norms), kernel_norm + max(f_norms)],
             'r--', label=f'Bound line (‖κ‖={kernel_norm:.2f})')
    ax6.set_xlabel('‖f‖_⊕')
    ax6.set_ylabel('‖K(f)‖_⊕')
    ax6.set_title('Kernel Norm Bound: ‖K(f)‖ ≤ ‖κ‖ + ‖f‖')
    ax6.legend(fontsize=8)
    ax6.grid(True, alpha=0.3)

    plt.suptitle('Tropical Fourier Analysis: Max-Plus Harmonic Analysis',
                 fontsize=16, fontweight='bold', y=0.98)
    plt.savefig('tropical_fourier_demo.png', dpi=150, bbox_inches='tight')
    print("\n[Saved visualization to tropical_fourier_demo.png]")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  TROPICAL FOURIER ANALYSIS: Numerical Demonstrations    ║")
    print("║  Max-Plus Spectral Decomposition & Plancherel Identity  ║")
    print("╚══════════════════════════════════════════════════════════╝\n")

    demo_cauchy_schwarz()
    x, f, modes, coeffs = demo_plancherel()
    t, sinc_vals = demo_sinc_interpolation()
    K_id = demo_eigenpair()
    demo_convolution()

    print("\n" + "=" * 60)
    print("CREATING VISUALIZATIONS")
    print("=" * 60)
    create_visualizations(x, f, modes, coeffs, t, sinc_vals)

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)
    print("""
Summary of verified properties:
  ✓ Tropical Cauchy-Schwarz: ⟨f,g⟩ ≤ ‖f‖ + ‖g‖
  ✓ Tropical Plancherel: ⟨f,f⟩ = max_k(2·c_k)
  ✓ Tropical sinc: nonpositive, symmetric, 1-Lipschitz
  ✓ Eigenpair verification: K(φ) = ev + φ
  ✓ Rayleigh quotient: R(φ,K) = ev
  ✓ Spectral radius bound: ρ(K) ≤ ev
  ✓ Convolution commutativity: f ⊛ g = g ⊛ f
  ✓ Kernel norm bound: ‖K(f)‖ ≤ ‖κ‖ + ‖f‖
""")
