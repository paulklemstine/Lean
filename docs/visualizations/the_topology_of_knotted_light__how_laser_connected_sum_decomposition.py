#!/usr/bin/env python3
"""
Visualization 3: Connected Sum and Spectral Decomposition

Shows how the OAM spectrum of a connected sum K₁ # K₂ decomposes
into the union of the individual spectra, visualizing the theorem:
  oamSpectrumReal(Δ_{K₁#K₂}) = oamSpectrumReal(Δ_{K₁}) ∪ oamSpectrumReal(Δ_{K₂})

This is a direct consequence of Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}.
"""
import numpy as np
import matplotlib.pyplot as plt


def poly_eval(coeffs, x):
    """Evaluate polynomial at real point x."""
    return sum(c * x**i for i, c in enumerate(coeffs))


def poly_multiply(p, q):
    """Multiply two polynomials."""
    result = [0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        for j, b in enumerate(q):
            result[i+j] += a * b
    return result


def complex_eval(coeffs, t):
    """Evaluate at complex point."""
    result = complex(0, 0)
    for i, c in enumerate(coeffs):
        result += c * t**i
    return result


# Knots
trefoil = [1, -1, 1]  # t² - t + 1
fig_eight = [-1, 3, -1]  # -t² + 3t - 1
connected = poly_multiply(trefoil, fig_eight)

x = np.linspace(-1, 4, 1000)
thetas = np.linspace(0, 1, 1000, endpoint=False)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

# Row 1: Real polynomial evaluations
ax1, ax2, ax3 = axes[0]

y1 = [poly_eval(trefoil, xi) for xi in x]
ax1.plot(x, y1, color='#E91E63', linewidth=2)
ax1.axhline(y=0, color='gray', linewidth=0.5)
ax1.fill_between(x, 0, y1, where=[yi > 0 for yi in y1], alpha=0.2, color='#E91E63')
ax1.fill_between(x, 0, y1, where=[yi < 0 for yi in y1], alpha=0.2, color='blue')
ax1.set_title('Trefoil: t² − t + 1', fontsize=12, fontweight='bold')
ax1.set_xlabel('t')
ax1.set_ylabel('Δ_K(t)')
ax1.set_ylim(-5, 15)
ax1.grid(True, alpha=0.3)
ax1.text(0.05, 0.95, 'No real roots\n(disc = −3)',
        transform=ax1.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

y2 = [poly_eval(fig_eight, xi) for xi in x]
ax2.plot(x, y2, color='#FF9800', linewidth=2)
ax2.axhline(y=0, color='gray', linewidth=0.5)
ax2.fill_between(x, 0, y2, where=[yi > 0 for yi in y2], alpha=0.2, color='#FF9800')
ax2.fill_between(x, 0, y2, where=[yi < 0 for yi in y2], alpha=0.2, color='blue')
# Mark real roots
roots_fig8 = [(3 + np.sqrt(5))/2, (3 - np.sqrt(5))/2]
for r in roots_fig8:
    ax2.plot(r, 0, 'ko', markersize=8, zorder=5)
    ax2.annotate(f'x={r:.3f}', xy=(r, 0), xytext=(0, 15),
                textcoords='offset points', fontsize=8, ha='center')
ax2.set_title('Figure-Eight: −t² + 3t − 1', fontsize=12, fontweight='bold')
ax2.set_xlabel('t')
ax2.set_ylabel('Δ_K(t)')
ax2.set_ylim(-5, 15)
ax2.grid(True, alpha=0.3)
ax2.text(0.05, 0.95, '2 real roots\n(disc = +5)',
        transform=ax2.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

y3 = [poly_eval(connected, xi) for xi in x]
ax3.plot(x, y3, color='#9C27B0', linewidth=2)
ax3.axhline(y=0, color='gray', linewidth=0.5)
ax3.fill_between(x, 0, y3, where=[yi > 0 for yi in y3], alpha=0.2, color='#9C27B0')
ax3.fill_between(x, 0, y3, where=[yi < 0 for yi in y3], alpha=0.2, color='blue')
for r in roots_fig8:
    ax3.plot(r, 0, 'ko', markersize=8, zorder=5)
ax3.set_title('Connected Sum: Trefoil # Figure-Eight', fontsize=12, fontweight='bold')
ax3.set_xlabel('t')
ax3.set_ylabel('Δ_{K₁#K₂}(t)')
ax3.set_ylim(-20, 40)
ax3.grid(True, alpha=0.3)
ax3.text(0.05, 0.95, 'Same 2 real roots\n(from figure-eight)',
        transform=ax3.transAxes, fontsize=9, va='top',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Row 2: OAM spectral density on unit circle
ax4, ax5, ax6 = axes[1]

for ax, coeffs, name, color in [
    (ax4, trefoil, 'Trefoil', '#E91E63'),
    (ax5, fig_eight, 'Figure-Eight', '#FF9800'),
    (ax6, connected, 'Connected Sum', '#9C27B0'),
]:
    density = [abs(complex_eval(coeffs, np.exp(2j*np.pi*t)))**2 for t in thetas]
    ax.fill_between(thetas * 360, 0, density, alpha=0.3, color=color)
    ax.plot(thetas * 360, density, color=color, linewidth=2)
    ax.set_xlabel('θ (degrees)')
    ax.set_ylabel('|Δ_K(e^{2πiθ})|²')
    ax.set_title(f'{name}: Unit Circle Spectrum', fontsize=11)
    ax.set_xlim(0, 360)
    ax.set_ylim(bottom=0)
    ax.grid(True, alpha=0.3)

    # Mark zeros
    density_arr = np.array(density)
    min_indices = np.where(density_arr < 0.01 * density_arr.max())[0]
    if len(min_indices) > 0:
        groups = np.split(min_indices, np.where(np.diff(min_indices) > 5)[0] + 1)
        for g in groups:
            center = thetas[g[len(g)//2]] * 360
            ax.axvline(x=center, color='red', linestyle='--', alpha=0.5)

fig.suptitle('Connected Sum Theorem: OAM Spectrum Decomposes as Union\n'
            'Δ_{K₁#K₂} = Δ_{K₁} · Δ_{K₂}  →  Roots(K₁#K₂) = Roots(K₁) ∪ Roots(K₂)',
            fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_connected_sum.png', dpi=150, bbox_inches='tight')
print("Saved viz_connected_sum.png")
