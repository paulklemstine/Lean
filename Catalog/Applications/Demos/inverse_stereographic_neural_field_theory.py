"""
Inverse Stereographic Neural Field Theory — Interactive Demo

Demonstrates:
1. Conformal factor properties and visualization
2. Mexican-hat kernel Fourier-Legendre analysis
3. Pattern counting predictions for various interaction radii
4. Neural field simulation on stereographic grid
"""

import numpy as np
from algorithms import (
    conformal_factor_2d,
    conformal_weight,
    inverse_stereo_2d,
    spherical_harmonic_multiplicity,
    total_harmonics_up_to,
    laplace_beltrami_eigenvalue,
    mexican_hat_legendre_coefficients,
    find_peak_degree,
    predicted_pattern_count,
    build_stereo_grid,
    stereo_to_spherical,
    sigmoid,
)


def demo_conformal_factor():
    """Demonstrate properties of the conformal factor."""
    print("=" * 60)
    print("DEMO 1: Conformal Factor Properties")
    print("=" * 60)
    
    # Positivity
    print("\n--- Positivity ---")
    test_points = [(0, 0), (1, 0), (0, 1), (3, 4), (100, 200)]
    for x1, x2 in test_points:
        sigma = conformal_factor_2d(x1, x2)
        print(f"  σ({x1}, {x2}) = {sigma:.6f} > 0 ✓")
    
    # Boundedness
    print("\n--- Boundedness (σ ≤ 2) ---")
    print(f"  σ(0, 0) = {conformal_factor_2d(0, 0):.6f} = 2 (maximum)")
    
    # Unit circle property
    print("\n--- Unit Circle Property (σ = 1) ---")
    for angle_name, theta in [("0", 0), ("π/4", np.pi/4), ("π/2", np.pi/2), ("π", np.pi)]:
        sigma = conformal_factor_2d(np.cos(theta), np.sin(theta))
        print(f"  σ(cos {angle_name}, sin {angle_name}) = {sigma:.10f}")
    
    # Decay
    print("\n--- Decay at Infinity ---")
    for R in [1, 2, 5, 10, 50, 100]:
        sigma = conformal_factor_2d(R, 0)
        bound = 2.0 / R**2
        print(f"  σ({R}, 0) = {sigma:.8f} < 2/R² = {bound:.8f}")
    
    # Laplacian identity
    print("\n--- Laplacian Identity: σ²·(1+r²)² = 4 ---")
    for r_sq in [0, 0.5, 1, 2, 5, 100]:
        sigma = 2.0 / (1.0 + r_sq)
        result = sigma**2 * (1 + r_sq)**2
        print(f"  r² = {r_sq:6.1f}: σ²·(1+r²)² = {result:.12f}")


def demo_spherical_harmonics():
    """Demonstrate spherical harmonic multiplicity and sum formula."""
    print("\n" + "=" * 60)
    print("DEMO 2: Spherical Harmonic Counting")
    print("=" * 60)
    
    print("\n--- Multiplicity Formula: dim(H_l) = 2l + 1 ---")
    print(f"  {'l':>3} {'2l+1':>6} {'Cumulative':>12} {'(l+1)²':>8}")
    print(f"  {'---':>3} {'-----':>6} {'----------':>12} {'------':>8}")
    
    cumulative = 0
    for l in range(11):
        mult = spherical_harmonic_multiplicity(l)
        cumulative += mult
        total = total_harmonics_up_to(l)
        assert cumulative == total
        print(f"  {l:3d} {mult:6d} {cumulative:12d} {total:8d}")
    
    print("\n--- Eigenvalues λ_l = l(l+1) ---")
    print(f"  {'l':>3} {'λ_l':>6} {'l²':>6} {'Casimir':>12}")
    for l in range(8):
        lam = laplace_beltrami_eigenvalue(l)
        l_sq = l**2
        casimir = (l + 0.5)**2 - 0.25
        print(f"  {l:3d} {lam:6d} {l_sq:6d} {casimir:12.4f}")


def demo_mexican_hat():
    """Demonstrate Mexican-hat kernel mode selection."""
    print("\n" + "=" * 60)
    print("DEMO 3: Mexican-Hat Kernel Mode Selection")
    print("=" * 60)
    
    configs = [
        (0.5, 1.0, "Broad"),
        (0.3, 0.6, "Medium"),
        (0.2, 0.5, "Narrow"),
        (0.15, 0.4, "Very narrow"),
        (0.1, 0.3, "Ultra narrow"),
    ]
    
    for sigma_e, sigma_i, label in configs:
        coeffs = mexican_hat_legendre_coefficients(sigma_e, sigma_i, 25)
        peak = find_peak_degree(coeffs)
        count = predicted_pattern_count(peak)
        
        print(f"\n  {label} kernel (σ_e={sigma_e}, σ_i={sigma_i}):")
        print(f"    Peak degree N = {peak}")
        print(f"    Pattern count = 2·{peak} + 1 = {count}")
        print(f"    Top coefficients: ", end="")
        sorted_idx = np.argsort(coeffs)[::-1][:5]
        for idx in sorted_idx:
            print(f"w_{idx}={coeffs[idx]:.4f} ", end="")
        print()


def demo_pattern_construction():
    """Demonstrate pattern construction via spherical harmonics on stereographic grid."""
    print("\n" + "=" * 60)
    print("DEMO 4: Pattern Construction (Stereographic Projection)")
    print("=" * 60)
    
    from scipy.special import sph_harm
    
    L = 5.0  # Grid extent
    N = 50   # Grid resolution
    x1, x2, sigma = build_stereo_grid(L, N)
    theta, phi = stereo_to_spherical(x1, x2)
    
    for l in [1, 2, 3]:
        print(f"\n  Degree l = {l}: {2*l+1} independent patterns")
        for m in range(-l, l + 1):
            # Compute real spherical harmonic
            if m > 0:
                Y = np.real(sph_harm(m, l, phi, theta) + (-1)**m * sph_harm(-m, l, phi, theta)) / np.sqrt(2)
            elif m < 0:
                Y = np.imag(sph_harm(-m, l, phi, theta) - (-1)**m * sph_harm(m, l, phi, theta)) / np.sqrt(2)
            else:
                Y = np.real(sph_harm(0, l, phi, theta))
            
            # Conformally weighted pattern on ℝ²
            pattern = Y * sigma**l
            max_val = np.max(np.abs(pattern))
            energy = np.sum(pattern**2 * sigma**2) * (2 * L / N)**2
            
            print(f"    Y_{l}^{m:+d}: max|u| = {max_val:.4f}, "
                  f"energy = {energy:.4f}, "
                  f"decay ~ |x|^{-2*l}")


def demo_energy_functional():
    """Demonstrate the energy functional for neural field patterns."""
    print("\n" + "=" * 60)
    print("DEMO 5: Neural Field Energy Functional")
    print("=" * 60)
    
    # Discrete energy with positive weights
    n_modes = 10
    weights = np.array([1.0 / (l + 1)**2 for l in range(n_modes)])
    
    print("\n  Weights (w_l = 1/(l+1)²):", 
          ", ".join(f"{w:.4f}" for w in weights))
    
    # Zero field: energy = 0
    u_zero = np.zeros(n_modes)
    E_zero = np.sum(weights * u_zero**2)
    print(f"\n  E[0] = {E_zero:.6f} (zero field)")
    
    # Random fields
    rng = np.random.default_rng(42)
    for trial in range(5):
        u = rng.standard_normal(n_modes)
        E = np.sum(weights * u**2)
        print(f"  E[u_{trial+1}] = {E:.6f} ≥ 0 ✓")


def demo_conformal_n_dim():
    """Demonstrate n-dimensional conformal weight."""
    print("\n" + "=" * 60)
    print("DEMO 6: n-Dimensional Conformal Weight")
    print("=" * 60)
    
    print("\n  σ_n(r²) = (2/(1+r²))^n")
    print(f"\n  {'n':>3} {'σ_n(0)':>10} {'σ_n(1)':>10} {'σ_n(4)':>10} {'2^n':>8}")
    for n in range(1, 7):
        s0 = conformal_weight(n, 0)
        s1 = conformal_weight(n, 1)
        s4 = conformal_weight(n, 4)
        print(f"  {n:3d} {s0:10.4f} {s1:10.4f} {s4:10.6f} {2**n:8d}")


if __name__ == "__main__":
    demo_conformal_factor()
    demo_spherical_harmonics()
    demo_mexican_hat()
    demo_pattern_construction()
    demo_energy_functional()
    demo_conformal_n_dim()
    
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


"""
Visualization 1: Conformal Factor and Stereographic Projection

Plots the conformal factor σ(x) = 2/(1+|x|²) as a 2D heatmap
and shows the decay profile along the x-axis.
"""

import numpy as np
import matplotlib.pyplot as plt


def conformal_factor_2d(x1, x2):
    return 2.0 / (1.0 + x1**2 + x2**2)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: 2D heatmap of conformal factor
    L = 5
    N = 200
    x = np.linspace(-L, L, N)
    X1, X2 = np.meshgrid(x, x)
    sigma = conformal_factor_2d(X1, X2)
    
    ax = axes[0]
    im = ax.pcolormesh(X1, X2, sigma, cmap='magma', shading='auto')
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    ax.set_title('Conformal Factor σ(x₁, x₂)')
    ax.set_aspect('equal')
    plt.colorbar(im, ax=ax, label='σ = 2/(1+|x|²)')
    
    # Draw unit circle
    theta = np.linspace(0, 2*np.pi, 100)
    ax.plot(np.cos(theta), np.sin(theta), 'w--', linewidth=1.5, label='Unit circle (σ=1)')
    ax.legend(loc='upper right', fontsize=8)
    
    # Panel 2: Radial profile
    ax = axes[1]
    r = np.linspace(0, 10, 500)
    sigma_r = 2.0 / (1.0 + r**2)
    bound = 2.0 / r**2
    bound[0] = np.inf
    
    ax.plot(r, sigma_r, 'b-', linewidth=2, label='σ(r) = 2/(1+r²)')
    ax.plot(r[1:], bound[1:], 'r--', linewidth=1.5, label='2/r² (upper bound for r>1)')
    ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
    ax.axvline(x=1, color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('r = |x|')
    ax.set_ylabel('σ(r)')
    ax.set_title('Radial Decay of Conformal Factor')
    ax.set_ylim(0, 2.2)
    ax.legend()
    ax.annotate('σ(0) = 2', xy=(0, 2), xytext=(1.5, 1.8),
                arrowprops=dict(arrowstyle='->', color='blue'),
                fontsize=10, color='blue')
    ax.annotate('σ(1) = 1', xy=(1, 1), xytext=(2.5, 1.2),
                arrowprops=dict(arrowstyle='->', color='gray'),
                fontsize=10, color='gray')
    
    # Panel 3: Jacobian σ² and the area identity
    ax = axes[2]
    r = np.linspace(0, 8, 500)
    jacobian = (2.0 / (1.0 + r**2))**2
    integrand = jacobian * 2 * np.pi * r  # Area element in polar coords
    
    ax.fill_between(r, integrand, alpha=0.3, color='blue')
    ax.plot(r, integrand, 'b-', linewidth=2, label='4πr/(1+r²)²')
    ax.set_xlabel('r = |x|')
    ax.set_ylabel('Area integrand')
    ax.set_title('Jacobian Integrand\n(∫ = 4π = Area of S²)')
    
    # Numerical integration check
    dr = r[1] - r[0]
    area = np.sum(integrand) * dr
    ax.legend()
    ax.annotate(f'∫₀^∞ = {area:.4f} ≈ 4π = {4*np.pi:.4f}',
                xy=(0.5, 0.7), xycoords='axes fraction', fontsize=10,
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('conformal_factor_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conformal_factor_visualization.png")


if __name__ == "__main__":
    main()


"""
Visualization 3: Mexican-Hat Kernel Mode Selection

Shows the Fourier-Legendre spectrum of the Mexican-hat kernel for
different parameter choices, demonstrating the mode selection mechanism.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.polynomial.legendre import leggauss


def mexican_hat_coefficients(sigma_e, sigma_i, L_max, n_quad=1000):
    nodes, weights = leggauss(n_quad)
    coeffs = np.zeros(L_max + 1)
    gamma = np.arccos(np.clip(nodes, -1, 1))
    kernel_vals = np.exp(-gamma**2 / (2 * sigma_e**2)) - np.exp(-gamma**2 / (2 * sigma_i**2))
    
    P_prev = np.ones_like(nodes)
    P_curr = nodes.copy()
    
    coeffs[0] = 0.5 * np.sum(weights * kernel_vals * P_prev)
    if L_max >= 1:
        coeffs[1] = 1.5 * np.sum(weights * kernel_vals * P_curr)
    
    for l in range(2, L_max + 1):
        P_next = ((2 * l - 1) * nodes * P_curr - (l - 1) * P_prev) / l
        coeffs[l] = (2 * l + 1) / 2 * np.sum(weights * kernel_vals * P_next)
        P_prev = P_curr
        P_curr = P_next
    
    return coeffs


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    L_max = 20
    ls = np.arange(L_max + 1)
    
    # Different kernel widths
    configs = [
        (0.5, 1.0, 'tab:blue'),
        (0.3, 0.6, 'tab:orange'),
        (0.2, 0.5, 'tab:green'),
        (0.15, 0.4, 'tab:red'),
    ]
    
    # Panel 1: All spectra overlaid
    ax = axes[0, 0]
    for sigma_e, sigma_i, color in configs:
        coeffs = mexican_hat_coefficients(sigma_e, sigma_i, L_max)
        peak = np.argmax(coeffs)
        ax.bar(ls + configs.index((sigma_e, sigma_i, color)) * 0.2 - 0.3,
               coeffs, width=0.2, color=color, alpha=0.7,
               label=f'σ_e={sigma_e}, σ_i={sigma_i} → N={peak}')
    
    ax.set_xlabel('Degree l')
    ax.set_ylabel('Coefficient w_l')
    ax.set_title('Fourier-Legendre Spectra of Mexican-Hat Kernels')
    ax.legend(fontsize=8)
    ax.axhline(y=0, color='k', linewidth=0.5)
    
    # Panels 2-4: Individual kernels with pattern count
    for idx, (sigma_e, sigma_i, color) in enumerate(configs[:3]):
        ax = axes[(idx + 1) // 2, (idx + 1) % 2]
        coeffs = mexican_hat_coefficients(sigma_e, sigma_i, L_max)
        peak = np.argmax(coeffs)
        count = 2 * peak + 1
        
        colors = ['lightgray'] * (L_max + 1)
        colors[peak] = color
        
        ax.bar(ls, coeffs, color=colors, edgecolor='gray', linewidth=0.5)
        ax.axhline(y=0, color='k', linewidth=0.5)
        
        ax.annotate(f'Peak: l = {peak}\n2l+1 = {count} patterns',
                   xy=(peak, coeffs[peak]),
                   xytext=(peak + 3, coeffs[peak] * 0.8),
                   arrowprops=dict(arrowstyle='->', color=color, lw=2),
                   fontsize=11, fontweight='bold', color=color,
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                            edgecolor=color, alpha=0.9))
        
        ax.set_xlabel('Degree l')
        ax.set_ylabel('Coefficient w_l')
        ax.set_title(f'Mexican-Hat Kernel (σ_e={sigma_e}, σ_i={sigma_i})')
    
    fig.suptitle('Mexican-Hat Mode Selection on S²\n'
                 'Peak degree N → 2N+1 stable pattern solutions',
                 fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('mexican_hat_mode_selection.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: mexican_hat_mode_selection.png")


if __name__ == "__main__":
    main()


"""
Visualization 2: Spherical Harmonic Patterns in Stereographic Coordinates

Shows the 2l+1 patterns for l=1,2,3 as viewed through stereographic projection,
demonstrating the pattern counting theorem.
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.special import sph_harm


def conformal_factor_2d(x1, x2):
    return 2.0 / (1.0 + x1**2 + x2**2)


def stereo_to_spherical(x1, x2):
    r_sq = x1**2 + x2**2
    theta = 2 * np.arctan(np.sqrt(r_sq))
    phi = np.arctan2(x2, x1)
    return theta, phi


def real_spherical_harmonic(l, m, theta, phi):
    if m > 0:
        return np.real(sph_harm(m, l, phi, theta) + (-1)**m * sph_harm(-m, l, phi, theta)) / np.sqrt(2)
    elif m < 0:
        return np.imag(sph_harm(-m, l, phi, theta) - (-1)**m * sph_harm(m, l, phi, theta)) / np.sqrt(2)
    else:
        return np.real(sph_harm(0, l, phi, theta))


def main():
    L = 4.0
    N = 200
    x = np.linspace(-L, L, N)
    X1, X2 = np.meshgrid(x, x)
    theta, phi = stereo_to_spherical(X1, X2)
    sigma = conformal_factor_2d(X1, X2)
    
    degrees = [1, 2, 3]
    max_m = max(degrees)
    
    fig, axes = plt.subplots(len(degrees), 2 * max_m + 1, 
                              figsize=(2.5 * (2 * max_m + 1), 2.5 * len(degrees)))
    
    for row, l in enumerate(degrees):
        for col in range(2 * max_m + 1):
            ax = axes[row, col]
            m = col - max_m
            
            if abs(m) <= l:
                Y = real_spherical_harmonic(l, m, theta, phi)
                pattern = Y * sigma  # conformally weighted
                
                vmax = np.max(np.abs(pattern))
                if vmax > 0:
                    ax.pcolormesh(X1, X2, pattern, cmap='RdBu_r',
                                 vmin=-vmax, vmax=vmax, shading='auto')
                
                # Unit circle
                t = np.linspace(0, 2*np.pi, 100)
                ax.plot(np.cos(t), np.sin(t), 'k:', linewidth=0.5, alpha=0.3)
                
                ax.set_title(f'Y_{l}^{{{m:+d}}}', fontsize=9)
            else:
                ax.axis('off')
            
            ax.set_xlim(-L, L)
            ax.set_ylim(-L, L)
            ax.set_aspect('equal')
            ax.set_xticks([])
            ax.set_yticks([])
        
        # Row label
        axes[row, 0].set_ylabel(f'l={l}\n({2*l+1} patterns)', fontsize=10)
    
    fig.suptitle('Spherical Harmonic Patterns in Stereographic Coordinates\n'
                 'Pattern Count: 2l+1 per degree l', 
                 fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('spherical_harmonic_patterns.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spherical_harmonic_patterns.png")


if __name__ == "__main__":
    main()
