"""
Visualization: Spectral Obstruction for Lorentzian Signature

Shows level curves of quadratic forms Q(x) = x^T A x for matrices with
different eigenvalue signatures, illustrating when Lorentzian signature
holds versus when it fails (two positive directions defeat it).

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt

def quadratic_form(A, x, y):
    """Compute Q_A([x, y]) = x^T A [x,y] for 2D vectors."""
    return A[0, 0] * x**2 + (A[0, 1] + A[1, 0]) * x * y + A[1, 1] * y**2

fig, axes = plt.subplots(2, 2, figsize=(12, 11))

x = np.linspace(-2, 2, 300)
y = np.linspace(-2, 2, 300)
X, Y = np.meshgrid(x, y)

# Matrix configurations
configs = [
    {
        'title': 'Lorentzian Signature\ndiag(1, -1)',
        'A': np.array([[1., 0.], [0., -1.]]),
        'description': '1 positive eigenvalue ✓',
        'color': 'green',
    },
    {
        'title': 'Positive Definite (NOT Lorentzian)\ndiag(1, 1)',
        'A': np.array([[1., 0.], [0., 1.]]),
        'description': '2 positive eigenvalues ✗',
        'color': 'red',
    },
    {
        'title': 'Negative Semidefinite (Lorentzian)\ndiag(-1, -2)',
        'A': np.array([[-1., 0.], [0., -2.]]),
        'description': '0 positive eigenvalues ✓',
        'color': 'green',
    },
    {
        'title': 'Mixed Non-Lorentzian\n[[2, 1], [1, 2]]',
        'A': np.array([[2., 1.], [1., 2.]]),
        'description': '2 positive eigenvalues ✗',
        'color': 'red',
    },
]

for idx, config in enumerate(configs):
    ax = axes[idx // 2][idx % 2]
    A = config['A']

    Z = quadratic_form(A, X, Y)

    # Level curves
    levels = np.linspace(-4, 4, 17)
    cs = ax.contour(X, Y, Z, levels=levels, cmap='RdBu_r', linewidths=0.8)
    ax.contourf(X, Y, Z, levels=levels, cmap='RdBu_r', alpha=0.3)
    ax.contour(X, Y, Z, levels=[0], colors='black', linewidths=2)

    # Mark positive region
    ax.contourf(X, Y, Z, levels=[0, 100], colors=['none'], hatches=['/'],
                alpha=0)

    # Eigenvalue info
    eigs = np.linalg.eigvalsh(A)
    eigvecs = np.linalg.eigh(A)[1]

    # Draw eigenvectors
    for i in range(2):
        ev = eigvecs[:, i]
        color_arrow = 'green' if eigs[i] > 0.01 else ('red' if eigs[i] < -0.01 else 'gray')
        ax.annotate('', xy=(ev[0] * 1.5, ev[1] * 1.5),
                    xytext=(0, 0),
                    arrowprops=dict(arrowstyle='->', color=color_arrow,
                                    lw=2.5))

    ax.set_xlim(-2, 2)
    ax.set_ylim(-2, 2)
    ax.set_aspect('equal')
    ax.set_xlabel('x₁', fontsize=11)
    ax.set_ylabel('x₂', fontsize=11)
    ax.set_title(config['title'], fontsize=11, color=config['color'],
                 fontweight='bold')
    ax.text(0.02, 0.98, config['description'],
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.2)

plt.suptitle('Spectral Obstruction: Quadratic Form Level Curves\n'
             'Green arrows = positive eigendirections, '
             'Red arrows = negative eigendirections',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_spectral_obstruction.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_obstruction.png")
