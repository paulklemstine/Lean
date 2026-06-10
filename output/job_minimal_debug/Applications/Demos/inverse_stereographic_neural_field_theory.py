"""
Inverse Stereographic Neural Field Theory — Demonstration

Numerical examples showcasing the key results from the theory.
"""

from algorithms import (
    conformal_factor,
    spherical_eigenvalue,
    spherical_harmonic_dim,
    pattern_count,
    mexican_hat_pattern_count,
    mode_energy,
    total_harmonics_up_to,
    eigenvalue_gap,
    conformal_decay_bound,
    verify_pattern_count_conjecture,
    inverse_stereographic_projection,
    stereographic_projection,
)


def demo_conformal_factor():
    print("=" * 60)
    print("DEMO 1: Conformal Factor Properties")
    print("=" * 60)
    print(f"σ(0) = {conformal_factor(0):.4f}  (should be 2.0)")
    print(f"σ(1) = {conformal_factor(1):.4f}  (should be 1.0)")
    print(f"σ(3) = {conformal_factor(3):.4f}  (should be 0.5)")

    print("\nMonotonicity (decreasing):")
    for r_sq in [0, 0.5, 1, 2, 5, 10, 100]:
        print(f"  σ({r_sq:6.1f}) = {conformal_factor(r_sq):.6f}")

    print("\nDecay bound: σ(r²) ≤ 2/r² for r² ≥ 1")
    for r_sq in [1, 2, 5, 10, 100]:
        sigma = conformal_factor(r_sq)
        bound = 2.0 / r_sq
        print(f"  r² = {r_sq:4d}: σ = {sigma:.6f}, 2/r² = {bound:.6f}, "
              f"σ ≤ 2/r²? {sigma <= bound + 1e-15}")
    print()


def demo_spherical_harmonics():
    print("=" * 60)
    print("DEMO 2: Spherical Harmonic Dimensions on S²")
    print("=" * 60)
    print("Degree l | dim H_l | 2l+1 | Match?")
    print("-" * 40)
    for l in range(11):
        dim = spherical_harmonic_dim(2, l)
        expected = 2 * l + 1
        print(f"   {l:2d}     |   {dim:3d}   | {expected:3d}  |  {'✓' if dim == expected else '✗'}")

    print(f"\nTotal harmonics up to degree 5: {total_harmonics_up_to(2, 5)} = (5+1)² = 36")
    print(f"Total harmonics up to degree 10: {total_harmonics_up_to(2, 10)} = (10+1)² = 121")
    print()


def demo_eigenvalues():
    print("=" * 60)
    print("DEMO 3: Laplace-Beltrami Eigenvalues on S²")
    print("=" * 60)
    print("Degree l | Eigenvalue λ_l | Gap Δλ")
    print("-" * 42)
    for l in range(11):
        ev = spherical_eigenvalue(2, l)
        gap = eigenvalue_gap(2, l)
        print(f"   {l:2d}     |     {ev:4d}       |  {gap:3d} = 2×{l + 1}")
    print()


def demo_pattern_count():
    print("=" * 60)
    print("DEMO 4: Mexican-Hat Pattern Count Conjecture")
    print("=" * 60)
    print("\nFor r = 1/k, Mexican-hat selects degree k → 2k+1 patterns:")
    print("k | 1/k     | Patterns | Description")
    print("-" * 50)
    for k in range(1, 8):
        r = 1.0 / k
        n_patterns = mexican_hat_pattern_count(r)
        desc = f"l={k} harmonics (Y_{{{k},m}}, m=-{k}..{k})"
        print(f"{k} | {r:.4f}  |   {n_patterns:3d}    | {desc}")

    print("\nConjecture verification (k=1 to 20):")
    results = verify_pattern_count_conjecture(20)
    all_match = all(r[3] for r in results)
    print(f"  All dim(H_k) = 2k+1 for k=1..20? {'✓ YES' if all_match else '✗ NO'}")
    print()


def demo_mode_energy():
    print("=" * 60)
    print("DEMO 5: Neural Field Mode Energy")
    print("=" * 60)
    amplitude = 1.0
    print(f"\nMode energies at unit amplitude (a = {amplitude}):")
    print("Degree l | E_l(1) = l(l+1)·(2l+1)")
    print("-" * 35)
    for l in range(1, 8):
        E = mode_energy(l, amplitude)
        print(f"   {l:2d}     |   {E:8.1f}")

    print("\nQuadratic scaling: E_l(ca) = c² · E_l(a)")
    l, a = 3, 2.0
    for c in [0.5, 1.0, 2.0, 3.0]:
        E_ca = mode_energy(l, c * a)
        c2_E_a = c ** 2 * mode_energy(l, a)
        print(f"  c={c:.1f}: E_3({c * a:.1f}) = {E_ca:.2f}, "
              f"c²·E_3({a:.1f}) = {c2_E_a:.2f}, match? {'✓' if abs(E_ca - c2_E_a) < 1e-10 else '✗'}")
    print()


def demo_stereographic_roundtrip():
    print("=" * 60)
    print("DEMO 6: Stereographic Projection Round-trip")
    print("=" * 60)
    test_points = [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0), (3.0, -2.0)]
    for x in test_points:
        sphere = inverse_stereographic_projection(x)
        back = stereographic_projection(sphere)
        err = sum((a - b) ** 2 for a, b in zip(x, back)) ** 0.5
        print(f"  R² → S² → R²: {x} → ({', '.join(f'{s:.4f}' for s in sphere)}) → "
              f"({', '.join(f'{b:.4f}' for b in back)})  error = {err:.2e}")
    print()


def demo_conformal_decay():
    print("=" * 60)
    print("DEMO 7: Projected Pattern Decay at Infinity")
    print("=" * 60)
    print("\nσ(r²)^l ≤ 2^l / r²^l  for r² ≥ 1:")
    for l in [1, 2, 3, 5]:
        print(f"\n  l = {l}:")
        for r_sq in [1.0, 4.0, 9.0, 25.0, 100.0]:
            actual = conformal_factor(r_sq) ** l
            bound = conformal_decay_bound(l, r_sq)
            print(f"    r²={r_sq:5.0f}: σ^l = {actual:.2e}, bound = {bound:.2e}, "
                  f"ratio = {actual / bound:.4f}")
    print()


def demo_higher_dimensions():
    print("=" * 60)
    print("DEMO 8: Spherical Harmonics in Higher Dimensions")
    print("=" * 60)
    for n in [1, 2, 3, 4, 5]:
        dims = [spherical_harmonic_dim(n, l) for l in range(8)]
        total = total_harmonics_up_to(n, 5)
        print(f"  S^{n}: dim H_l for l=0..7: {dims}")
        print(f"       Total up to l=5: {total}")
        if n == 2:
            print(f"       (= (5+1)² = 36)")
    print()


if __name__ == "__main__":
    demo_conformal_factor()
    demo_spherical_harmonics()
    demo_eigenvalues()
    demo_pattern_count()
    demo_mode_energy()
    demo_stereographic_roundtrip()
    demo_conformal_decay()
    demo_higher_dimensions()

    print("=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


"""
Visualization: Stereographic Neural Field Patterns on S^2

Generates plots showing:
1. Conformal factor and decay properties
2. Spherical harmonic patterns projected to R^2
3. Pattern count and eigenvalue structure
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib import cm


def conformal_factor(r_sq):
    return 2.0 / (1.0 + r_sq)


def spherical_harmonic_Y(l, m, theta, phi):
    """Simplified real spherical harmonics for low degrees."""
    if l == 0:
        return np.ones_like(theta) / (2 * np.sqrt(np.pi))
    elif l == 1:
        if m == -1:
            return np.sqrt(3 / (4 * np.pi)) * np.sin(theta) * np.sin(phi)
        elif m == 0:
            return np.sqrt(3 / (4 * np.pi)) * np.cos(theta)
        elif m == 1:
            return np.sqrt(3 / (4 * np.pi)) * np.sin(theta) * np.cos(phi)
    elif l == 2:
        if m == -2:
            return 0.5 * np.sqrt(15 / np.pi) * np.sin(theta) ** 2 * np.sin(2 * phi)
        elif m == -1:
            return 0.5 * np.sqrt(15 / np.pi) * np.sin(2 * theta) * np.sin(phi)
        elif m == 0:
            return 0.25 * np.sqrt(5 / np.pi) * (3 * np.cos(theta) ** 2 - 1)
        elif m == 1:
            return 0.5 * np.sqrt(15 / np.pi) * np.sin(2 * theta) * np.cos(phi)
        elif m == 2:
            return 0.5 * np.sqrt(15 / np.pi) * np.sin(theta) ** 2 * np.cos(2 * phi)
    return np.zeros_like(theta)


def plot_conformal_factor():
    """Plot conformal factor and its decay properties."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    # Plot 1: Conformal factor
    r_sq = np.linspace(0, 20, 200)
    sigma = conformal_factor(r_sq)
    axes[0].plot(r_sq, sigma, 'b-', linewidth=2, label=r'$\sigma(r^2) = 2/(1+r^2)$')
    axes[0].fill_between(r_sq, 0, sigma, alpha=0.1, color='blue')
    axes[0].set_xlabel(r'$r^2$')
    axes[0].set_ylabel(r'$\sigma(r^2)$')
    axes[0].set_title('Conformal Factor')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # Plot 2: Decay comparison
    r_sq_decay = np.linspace(1, 50, 200)
    sigma_d = conformal_factor(r_sq_decay)
    bound = 2.0 / r_sq_decay
    axes[1].semilogy(r_sq_decay, sigma_d, 'b-', linewidth=2, label=r'$\sigma(r^2)$')
    axes[1].semilogy(r_sq_decay, bound, 'r--', linewidth=2, label=r'$2/r^2$ bound')
    axes[1].set_xlabel(r'$r^2$')
    axes[1].set_ylabel('Value (log scale)')
    axes[1].set_title('Conformal Factor Decay')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Conformal factor power decay
    for l in [1, 2, 3, 5]:
        sigma_l = conformal_factor(r_sq_decay) ** l
        axes[2].semilogy(r_sq_decay, sigma_l, linewidth=2, label=f'$\\sigma^{l}$')
    axes[2].set_xlabel(r'$r^2$')
    axes[2].set_ylabel(r'$\sigma(r^2)^l$')
    axes[2].set_title('Pattern Decay at Infinity')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('conformal_factor_properties.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: conformal_factor_properties.png")


def plot_projected_patterns():
    """Plot spherical harmonics projected to R^2 via stereographic projection."""
    fig, axes = plt.subplots(2, 5, figsize=(20, 8))
    fig.suptitle('Spherical Harmonics Projected to R² via Stereographic Projection',
                 fontsize=14, fontweight='bold')

    x = np.linspace(-4, 4, 300)
    y = np.linspace(-4, 4, 300)
    X, Y = np.meshgrid(x, y)
    r_sq = X ** 2 + Y ** 2

    # Convert from R^2 to spherical coordinates via inverse stereographic
    sigma = conformal_factor(r_sq)
    # Sphere coordinates: (sigma*X, sigma*Y, 1 - sigma)
    z_sphere = 1 - sigma
    # theta = arccos(z), phi = atan2(y, x)
    rho = np.sqrt((sigma * X) ** 2 + (sigma * Y) ** 2 + z_sphere ** 2)
    rho = np.maximum(rho, 1e-10)
    theta = np.arccos(np.clip(z_sphere / rho, -1, 1))
    phi = np.arctan2(Y, X)

    idx = 0
    for l in [1, 2]:
        for m in range(-l, l + 1):
            row = 0 if l == 1 else 1
            col = m + l if l == 1 else m + l
            if l == 1:
                col = m + 1
            ax = axes[row][col]

            Y_lm = spherical_harmonic_Y(l, m, theta, phi)
            # Apply conformal weight
            pattern = Y_lm * sigma

            vmax = np.percentile(np.abs(pattern), 99)
            im = ax.pcolormesh(X, Y, pattern, cmap='RdBu_r',
                              vmin=-vmax, vmax=vmax, shading='auto')
            ax.set_xlim(-4, 4)
            ax.set_ylim(-4, 4)
            ax.set_aspect('equal')
            ax.set_title(f'$Y_{{{l}}}^{{{m}}}$', fontsize=12)
            ax.set_xlabel(r'$x_1$')
            ax.set_ylabel(r'$x_2$')
            plt.colorbar(im, ax=ax, fraction=0.046)
            idx += 1

    # Hide unused axes
    for j in range(3, 5):
        axes[0][j].set_visible(False)

    plt.tight_layout()
    plt.savefig('projected_spherical_harmonics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: projected_spherical_harmonics.png")


def plot_pattern_count_eigenvalues():
    """Plot pattern count and eigenvalue structure."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Pattern count
    L = np.arange(0, 16)
    dims = 2 * L + 1
    axes[0].bar(L, dims, color='steelblue', alpha=0.8)
    axes[0].set_xlabel('Degree $l$')
    axes[0].set_ylabel('Pattern Count $2l+1$')
    axes[0].set_title('Pattern Solutions per Degree on $S^2$')
    axes[0].grid(True, alpha=0.3, axis='y')

    # Cumulative patterns
    cumulative = np.cumsum(dims)
    expected = (L + 1) ** 2
    axes[1].plot(L, cumulative, 'bo-', label='$\\sum (2l+1)$', markersize=6)
    axes[1].plot(L, expected, 'r--', label='$(L+1)^2$', linewidth=2)
    axes[1].set_xlabel('Maximum degree $L$')
    axes[1].set_ylabel('Total patterns')
    axes[1].set_title("Gauss's Sum: $\\sum_{l=0}^{L}(2l+1) = (L+1)^2$")
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)

    # Eigenvalue structure
    eigenvals = L * (L + 1)
    axes[2].plot(L, eigenvals, 'go-', label='$\\lambda_l = l(l+1)$', markersize=6)
    for i in range(len(L) - 1):
        gap = eigenvals[i + 1] - eigenvals[i]
        axes[2].annotate(f'{gap}', xy=(L[i] + 0.5, (eigenvals[i] + eigenvals[i + 1]) / 2),
                        fontsize=7, color='red', ha='center')
    axes[2].set_xlabel('Degree $l$')
    axes[2].set_ylabel('Eigenvalue $\\lambda_l$')
    axes[2].set_title('Laplace-Beltrami Eigenvalues on $S^2$')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('pattern_count_eigenvalues.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: pattern_count_eigenvalues.png")


if __name__ == "__main__":
    plot_conformal_factor()
    plot_projected_patterns()
    plot_pattern_count_eigenvalues()
    print("\nAll visualizations generated successfully.")
