"""
Demo 5: The Riemann Zeta Function — The Arithmetic North Pole
===============================================================
Visualizes the Riemann zeta function in the complex plane, showing
the critical strip, the known zeros, and the "north pole" structure.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.colors import LogNorm
from matplotlib.patches import FancyBboxPatch


def zeta_approx(s, n_terms=500):
    """
    Approximate the Riemann zeta function using the Dirichlet eta function
    and analytic continuation via Euler-Maclaurin or alternating series.
    For Re(s) > 0, uses: ζ(s) = η(s) / (1 - 2^(1-s))
    where η(s) = Σ (-1)^(n-1) / n^s (Dirichlet eta, converges for Re(s) > 0)
    """
    s = np.asarray(s, dtype=complex)
    result = np.zeros_like(s, dtype=complex)

    # Use the alternating series (eta function) for better convergence
    # with Knopp-Hasse acceleration
    for k in range(n_terms):
        inner_sum = 0.0
        for j in range(k + 1):
            binom = 1.0
            for m in range(j):
                binom *= (k - m) / (m + 1)
            inner_sum += ((-1)**j) * (j + 1)**(-s) * binom
        result += inner_sum / (2**(k + 1))

    # ζ(s) = η(s) / (1 - 2^{1-s}) where we computed a convergence-accelerated η
    factor = 1.0 - 2.0**(1.0 - s)
    # Avoid division by zero near s=1
    safe_mask = np.abs(factor) > 1e-10
    result_zeta = np.where(safe_mask, result / factor, np.nan + 0j)

    return result_zeta


def simple_zeta(s, N=200):
    """Simple partial sum approximation for visualization. Re(s) > 1."""
    result = np.zeros_like(s, dtype=complex)
    for n in range(1, N + 1):
        result += n**(-s)
    return result


def main():
    fig = plt.figure(figsize=(22, 16), facecolor='#0a0a2e')
    gs = gridspec.GridSpec(2, 3, figure=fig, hspace=0.3, wspace=0.3)

    # ===== Panel 1: |ζ(s)| heat map =====
    ax1 = fig.add_subplot(gs[0, 0], facecolor='#0a0a2e')
    ax1.set_title('|ζ(s)| in the Complex Plane\n(The Arithmetic Landscape)',
                   color='white', fontsize=12, fontweight='bold')

    sigma = np.linspace(-2, 4, 400)
    t = np.linspace(-30, 30, 400)
    S, T = np.meshgrid(sigma, t)
    Z = S + 1j * T

    # Compute |ζ| using simple partial sums where it converges,
    # and the eta function elsewhere
    zeta_vals = np.zeros_like(Z, dtype=complex)
    for i in range(Z.shape[0]):
        for j in range(Z.shape[1]):
            s = Z[i, j]
            if s.real > 1.5:
                zeta_vals[i, j] = simple_zeta(np.array([s]), N=100)[0]
            else:
                # Use accelerated series
                eta = sum((-1)**(n-1) * n**(-s) for n in range(1, 80))
                denom = 1 - 2**(1 - s)
                if abs(denom) > 1e-10:
                    zeta_vals[i, j] = eta / denom
                else:
                    zeta_vals[i, j] = np.nan

    abs_zeta = np.abs(zeta_vals)
    abs_zeta = np.clip(abs_zeta, 0.01, 50)

    im1 = ax1.pcolormesh(S, T, abs_zeta, cmap='magma',
                          norm=LogNorm(vmin=0.01, vmax=50),
                          shading='auto')
    plt.colorbar(im1, ax=ax1, label='|ζ(σ + it)|', shrink=0.8)

    # Mark critical strip
    ax1.axvline(x=0, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
    ax1.axvline(x=1, color='cyan', linewidth=1, alpha=0.5, linestyle='--')
    ax1.axvline(x=0.5, color='#ffd93d', linewidth=2, alpha=0.8,
                label='Critical line Re(s) = ½')

    # Mark pole at s=1
    ax1.plot(1, 0, '*', color='red', markersize=15, zorder=10,
             markeredgecolor='white', markeredgewidth=1)
    ax1.text(1.3, 1.5, 'Pole\n(North Pole)', color='red', fontsize=9,
             fontweight='bold')

    # Mark approximate zero locations
    known_zeros_t = [14.13, 21.02, 25.01, -14.13, -21.02, -25.01]
    for zt in known_zeros_t:
        ax1.plot(0.5, zt, 'o', color='#6bcb77', markersize=6, zorder=10,
                 markeredgecolor='white', markeredgewidth=1)

    ax1.fill_betweenx([-30, 30], 0, 1, alpha=0.08, color='cyan')
    ax1.text(0.5, -28, 'CRITICAL\nSTRIP', color='cyan', fontsize=8,
             ha='center', alpha=0.7)

    ax1.set_xlabel('σ = Re(s)', color='white')
    ax1.set_ylabel('t = Im(s)', color='white')
    ax1.tick_params(colors='white')
    ax1.legend(loc='upper right', fontsize=7, facecolor='#1a1a4e',
               edgecolor='cyan', labelcolor='white')

    # ===== Panel 2: ζ along critical line =====
    ax2 = fig.add_subplot(gs[0, 1], facecolor='#0a0a2e')
    ax2.set_title('ζ(½ + it) Along the Critical Line\n(Where the Zeros Live)',
                   color='white', fontsize=12, fontweight='bold')

    t_line = np.linspace(0, 50, 2000)
    s_line = 0.5 + 1j * t_line

    # Compute ζ along critical line
    zeta_crit = []
    for s in s_line:
        eta = sum((-1)**(n-1) * n**(-s) for n in range(1, 100))
        denom = 1 - 2**(1 - s)
        if abs(denom) > 1e-10:
            zeta_crit.append(eta / denom)
        else:
            zeta_crit.append(0)
    zeta_crit = np.array(zeta_crit)

    ax2.plot(t_line, np.real(zeta_crit), color='#4d96ff', linewidth=1,
             alpha=0.8, label='Re ζ(½+it)')
    ax2.plot(t_line, np.imag(zeta_crit), color='#ff6bd6', linewidth=1,
             alpha=0.8, label='Im ζ(½+it)')
    ax2.plot(t_line, np.abs(zeta_crit), color='#ffd93d', linewidth=1.5,
             alpha=0.9, label='|ζ(½+it)|')

    ax2.axhline(y=0, color='white', linewidth=0.5, alpha=0.3)

    # Mark zeros
    approx_zeros = [14.13, 21.02, 25.01, 30.42, 32.94, 37.59, 40.92, 43.33, 48.01]
    for z in approx_zeros:
        ax2.axvline(x=z, color='#6bcb77', linewidth=0.5, alpha=0.5)
        ax2.plot(z, 0, 'o', color='#6bcb77', markersize=5, zorder=10)

    ax2.set_xlabel('t (imaginary part)', color='white')
    ax2.set_ylabel('ζ(½ + it)', color='white')
    ax2.set_xlim([0, 50])
    ax2.set_ylim([-4, 4])
    ax2.tick_params(colors='white')
    ax2.legend(loc='upper right', fontsize=7, facecolor='#1a1a4e',
               edgecolor='cyan', labelcolor='white')
    for spine in ax2.spines.values():
        spine.set_color('#333366')

    # ===== Panel 3: Euler product convergence =====
    ax3 = fig.add_subplot(gs[0, 2], facecolor='#0a0a2e')
    ax3.set_title('Euler Product Convergence\n(Local Data from Each Prime)',
                   color='white', fontsize=12, fontweight='bold')

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
              53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

    s_values = [2.0, 1.5, 1.2, 1.05]
    colors_s = ['#6bcb77', '#4d96ff', '#ffd93d', '#ff6b6b']

    for s, col in zip(s_values, colors_s):
        partial_products = []
        product = 1.0
        for p in primes:
            product *= 1.0 / (1.0 - p**(-s))
            partial_products.append(product)

        ax3.plot(range(1, len(primes) + 1), partial_products, 'o-',
                color=col, linewidth=1.5, markersize=4, alpha=0.8,
                label=f's = {s}')

        # True value
        true_val = sum(n**(-s) for n in range(1, 10000))
        ax3.axhline(y=true_val, color=col, linewidth=0.5, alpha=0.3,
                     linestyle='--')

    ax3.set_xlabel('Number of primes included', color='white')
    ax3.set_ylabel('Partial Euler product', color='white')
    ax3.tick_params(colors='white')
    ax3.legend(loc='upper left', fontsize=8, facecolor='#1a1a4e',
               edgecolor='cyan', labelcolor='white')
    for spine in ax3.spines.values():
        spine.set_color('#333366')

    # ===== Panel 4: Stereographic analogy =====
    ax4 = fig.add_subplot(gs[1, 0], facecolor='#0a0a2e')
    ax4.set_title('The Stereographic Structure of ζ(s)\n(Analogy)',
                   color='white', fontsize=12, fontweight='bold')
    ax4.set_xlim([0, 10])
    ax4.set_ylim([0, 7])
    ax4.set_axis_off()

    # Draw two regions
    # Right half: Euler product (local data)
    right = FancyBboxPatch((5.5, 1), 4, 5, boxstyle="round,pad=0.2",
                            facecolor='#4d96ff', alpha=0.1,
                            edgecolor='#4d96ff', linewidth=2)
    ax4.add_patch(right)
    ax4.text(7.5, 5.5, 'Re(s) > 1\nEuler Product', color='#4d96ff',
             fontsize=11, fontweight='bold', ha='center')
    ax4.text(7.5, 4.5, '= Π_p (1 - p^{-s})^{-1}', color='#4d96ff',
             fontsize=9, ha='center', family='monospace')
    ax4.text(7.5, 3.5, 'LOCAL DATA\n(one factor per prime)', color='#aaaacc',
             fontsize=8, ha='center', style='italic')

    # Left half: functional equation (reflected data)
    left = FancyBboxPatch((0.5, 1), 4, 5, boxstyle="round,pad=0.2",
                           facecolor='#ff6bd6', alpha=0.1,
                           edgecolor='#ff6bd6', linewidth=2)
    ax4.add_patch(left)
    ax4.text(2.5, 5.5, 'Re(s) < 0\nFunctional Equation', color='#ff6bd6',
             fontsize=11, fontweight='bold', ha='center')
    ax4.text(2.5, 4.5, 'ξ(s) = ξ(1-s)', color='#ff6bd6',
             fontsize=9, ha='center', family='monospace')
    ax4.text(2.5, 3.5, 'REFLECTED DATA\n(symmetry about ½)', color='#aaaacc',
             fontsize=8, ha='center', style='italic')

    # Critical strip in the middle
    strip = FancyBboxPatch((4.3, 1), 1.4, 5, boxstyle="round,pad=0.1",
                            facecolor='#ffd93d', alpha=0.15,
                            edgecolor='#ffd93d', linewidth=2)
    ax4.add_patch(strip)
    ax4.text(5, 5.5, 'CRITICAL\nSTRIP', color='#ffd93d',
             fontsize=10, fontweight='bold', ha='center')
    ax4.text(5, 3, 'THE\nNORTH\nPOLE', color='red',
             fontsize=14, fontweight='bold', ha='center')

    # Arrows
    ax4.annotate('', xy=(4.5, 2.5), xytext=(4, 2.5),
                 arrowprops=dict(arrowstyle='->', color='white', lw=1.5))
    ax4.annotate('', xy=(5.5, 2.5), xytext=(6, 2.5),
                 arrowprops=dict(arrowstyle='->', color='white', lw=1.5))

    ax4.text(5, 0.5, 'RH: All zeros lie on Re(s) = ½\n'
             '= the exact center of the north pole', color='white',
             fontsize=9, ha='center', style='italic')

    # ===== Panel 5: Prime counting and zeros =====
    ax5 = fig.add_subplot(gs[1, 1], facecolor='#0a0a2e')
    ax5.set_title('Prime Counting Function π(x)\nvs. Logarithmic Integral li(x)',
                   color='white', fontsize=12, fontweight='bold')

    # Sieve of Eratosthenes
    max_n = 500
    is_prime = [True] * (max_n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(max_n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, max_n + 1, i):
                is_prime[j] = False

    x_vals = np.arange(2, max_n + 1)
    pi_x = np.cumsum([1 if is_prime[n] else 0 for n in x_vals])

    # Logarithmic integral approximation
    from scipy import integrate
    li_vals = []
    for x in x_vals:
        if x > 2:
            val, _ = integrate.quad(lambda t: 1/np.log(t), 2, x)
            li_vals.append(val + 1.04516)  # li(2) ≈ 1.04516
        else:
            li_vals.append(1.04516)
    li_vals = np.array(li_vals)

    ax5.plot(x_vals, pi_x, color='#4d96ff', linewidth=1.5, label='π(x) — exact')
    ax5.plot(x_vals, li_vals, color='#ff6bd6', linewidth=1.5, alpha=0.8,
             label='li(x) — analytic approx.')
    ax5.fill_between(x_vals, pi_x, li_vals, alpha=0.15, color='#ffd93d')

    ax5.set_xlabel('x', color='white')
    ax5.set_ylabel('Count', color='white')
    ax5.tick_params(colors='white')
    ax5.legend(fontsize=8, facecolor='#1a1a4e', edgecolor='cyan', labelcolor='white')
    for spine in ax5.spines.values():
        spine.set_color('#333366')

    ax5.text(300, 30, 'The gap between\nπ(x) and li(x)\nis controlled by\nzeta zeros',
             color='#ffd93d', fontsize=8, style='italic',
             bbox=dict(boxstyle='round', facecolor='#0a0a2e', edgecolor='#ffd93d',
                        alpha=0.8))

    # ===== Panel 6: Adelic visualization =====
    ax6 = fig.add_subplot(gs[1, 2], facecolor='#0a0a2e')
    ax6.set_title('The Adelic Sphere\n(Local-Global in Number Theory)',
                   color='white', fontsize=12, fontweight='bold')
    ax6.set_xlim([-1.5, 1.5])
    ax6.set_ylim([-1.5, 1.5])
    ax6.set_aspect('equal')
    ax6.set_axis_off()

    # Draw a circle representing the "adelic sphere"
    theta = np.linspace(0, 2*np.pi, 200)
    ax6.plot(np.cos(theta), np.sin(theta), color='white', linewidth=2, alpha=0.3)

    # Mark primes around the circle
    places = [('2', '#ff6b6b'), ('3', '#ffd93d'), ('5', '#6bcb77'),
              ('7', '#4d96ff'), ('11', '#ff6bd6'), ('13', '#ff8c42'),
              ('...', '#aaaaaa')]
    n_places = len(places)
    place_angles = np.linspace(np.pi/2, np.pi/2 - 2*np.pi, n_places, endpoint=False)

    for i, (label, color) in enumerate(places):
        x = 1.0 * np.cos(place_angles[i])
        y = 1.0 * np.sin(place_angles[i])
        ax6.plot(x, y, 'o', color=color, markersize=12, zorder=5)
        lx = 1.25 * np.cos(place_angles[i])
        ly = 1.25 * np.sin(place_angles[i])
        ax6.text(lx, ly, f'ℚ_{label}' if label != '...' else '...',
                color=color, fontsize=9, ha='center', va='center',
                fontweight='bold')

    # North pole = archimedean place
    ax6.plot(0, 1.0, '*', color='red', markersize=20, zorder=10,
             markeredgecolor='white', markeredgewidth=1)
    ax6.text(0, 1.35, 'ℝ\n(archimedean\n"North Pole")', color='red',
             fontsize=9, fontweight='bold', ha='center')

    # Center label
    ax6.text(0, -0.1, 'ℚ\n(rationals)', color='white', fontsize=11,
             fontweight='bold', ha='center')

    # Product formula
    ax6.text(0, -1.35, 'Product formula: Π_v |x|_v = 1\n'
             'The archimedean place is determined\nby all finite places',
             color='#aaaacc', fontsize=8, ha='center', style='italic')

    fig.suptitle('THE RIEMANN HYPOTHESIS — The Arithmetic North Pole\n'
                 '"The zeros of ζ(s) encode the deepest secrets of the primes"',
                 color='white', fontsize=18, fontweight='bold', y=0.99)

    plt.savefig('/workspace/request-project/oracle_council/demos/demo5_zeta_critical_strip.png',
                dpi=150, bbox_inches='tight', facecolor='#0a0a2e')
    plt.close()
    print("✓ Saved: demo5_zeta_critical_strip.png")


if __name__ == '__main__':
    main()
