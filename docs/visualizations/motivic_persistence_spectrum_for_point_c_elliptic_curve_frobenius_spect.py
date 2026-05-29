"""
Visualization: Elliptic Curve Frobenius Spectra

Shows how point counts of elliptic curves over finite fields encode
Frobenius eigenvalue data, and how the persistence profile extracts
this spectral information.

Creates a 2x2 panel:
- Top-left: Point counts for several elliptic curves over F_q extensions
- Top-right: Frobenius eigenvalues in the complex plane
- Bottom-left: Middle cohomology signals (α^r + β^r)
- Bottom-right: Recurrence residuals (Theorem 5 verification)
"""

import numpy as np
import matplotlib.pyplot as plt


def elliptic_frobenius(q, trace):
    disc = trace**2 - 4*q
    if disc >= 0:
        alpha = (trace + np.sqrt(disc)) / 2
        beta = (trace - np.sqrt(disc)) / 2
    else:
        alpha = (trace + 1j * np.sqrt(-disc)) / 2
        beta = (trace - 1j * np.sqrt(-disc)) / 2
    return alpha, beta


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Elliptic Curve Arithmetic Signals', fontsize=16, fontweight='bold')

q = 7
traces = [-4, -2, 0, 2, 4]
colors = ['#e41a1c', '#ff7f00', '#4daf4a', '#377eb8', '#984ea3']
r_max = 8

# Panel 1: Point counts
ax1 = axes[0, 0]
for trace, color in zip(traces, colors):
    a, b = elliptic_frobenius(q, trace)
    counts = [int(np.round(np.real(q**r + 1 - a**r - b**r)))
              for r in range(1, r_max + 1)]
    ax1.plot(range(1, r_max + 1), counts, 'o-', color=color,
             label=f'a={trace}', markersize=6, linewidth=1.5)
ax1.set_title(f'Point Counts |E(F_{{7^r}})| for Various Traces', fontsize=11)
ax1.set_xlabel('Extension degree r')
ax1.set_ylabel('|E(F_{7^r})|')
ax1.legend(title='Frobenius trace')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Panel 2: Frobenius eigenvalues in complex plane
ax2 = axes[0, 1]
theta = np.linspace(0, 2*np.pi, 100)
ax2.plot(np.sqrt(q) * np.cos(theta), np.sqrt(q) * np.sin(theta),
         'k--', alpha=0.3, linewidth=1, label=f'|z| = √{q}')
for trace, color in zip(traces, colors):
    a, b = elliptic_frobenius(q, trace)
    ax2.plot(np.real(a), np.imag(a), 'o', color=color, markersize=10,
             label=f'a={trace}: α={a:.2f}')
    ax2.plot(np.real(b), np.imag(b), 's', color=color, markersize=8)
ax2.set_title('Frobenius Eigenvalues in ℂ', fontsize=11)
ax2.set_xlabel('Re(α)')
ax2.set_ylabel('Im(α)')
ax2.set_aspect('equal')
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.axhline(y=0, color='k', linewidth=0.5)
ax2.axvline(x=0, color='k', linewidth=0.5)

# Panel 3: Middle cohomology signals
ax3 = axes[1, 0]
for trace, color in zip(traces, colors):
    a, b = elliptic_frobenius(q, trace)
    mid = np.real(np.array([a**r + b**r for r in range(r_max + 2)]))
    ax3.plot(range(r_max + 2), mid, 'o-', color=color,
             label=f'a={trace}', markersize=5, linewidth=1.5)
ax3.set_title('Middle Cohomology Signal αʳ + βʳ', fontsize=11)
ax3.set_xlabel('r')
ax3.set_ylabel('α^r + β^r')
ax3.legend(title='Trace')
ax3.grid(True, alpha=0.3)

# Panel 4: Recurrence residuals
ax4 = axes[1, 1]
for trace, color in zip(traces, colors):
    a, b = elliptic_frobenius(q, trace)
    s = a + b
    p = a * b
    mid = np.array([a**r + b**r for r in range(r_max + 4)], dtype=complex)
    residuals = [abs(mid[n+2] - s * mid[n+1] + p * mid[n])
                 for n in range(r_max)]
    ax4.semilogy(range(r_max), [max(r, 1e-16) for r in residuals],
                 'o-', color=color, label=f'a={trace}', markersize=5)
ax4.axhline(y=1e-13, color='gray', linestyle='--', alpha=0.5,
            label='Machine ε')
ax4.set_title('Recurrence Residual (Theorem 5)', fontsize=11)
ax4.set_xlabel('n')
ax4.set_ylabel('|a(n+2) - (α+β)a(n+1) + αβ·a(n)|')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(1e-17, 1e-10)

plt.tight_layout()
plt.savefig('vis_elliptic_curves.png', dpi=150, bbox_inches='tight')
print("Saved vis_elliptic_curves.png")
