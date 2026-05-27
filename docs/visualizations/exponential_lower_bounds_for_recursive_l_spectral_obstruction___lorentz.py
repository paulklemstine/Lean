#!/usr/bin/env python3
"""
Visualization: Spectral Obstruction and Lorentzian Signature

Visualizes the spectral obstruction theorem: matrices with ≥2 positive
eigenvalues cannot have Lorentzian signature. Shows eigenvalue distributions
and the Lorentzian/non-Lorentzian boundary in spectral space.

Requires: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_random_symmetric(n, seed=None):
    """Generate a random symmetric matrix."""
    rng = np.random.RandomState(seed)
    M = rng.randn(n, n)
    return (M + M.T) / 2


def classify_signature(eigenvalues, tol=1e-10):
    """Classify the Lorentzian signature of a matrix."""
    n_pos = np.sum(eigenvalues > tol)
    n_neg = np.sum(eigenvalues < -tol)
    n_zero = len(eigenvalues) - n_pos - n_neg
    is_lorentzian = n_pos <= 1
    return n_pos, n_neg, n_zero, is_lorentzian


# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Eigenvalue spectrum examples
ax1 = axes[0, 0]
examples = [
    ("Lorentzian\n(1 pos, 4 neg)", np.diag([3, -1, -2, -1, -3])),
    ("Non-Lorentzian\n(3 pos, 2 neg)", np.diag([3, 2, 1, -1, -2])),
    ("Negative definite\n(0 pos, 5 neg)", np.diag([-1, -2, -3, -4, -5])),
    ("Positive definite\n(5 pos, 0 neg)", np.diag([1, 2, 3, 4, 5])),
]

colors = ['#2ecc71', '#e74c3c', '#3498db', '#f39c12']
for idx, (label, A) in enumerate(examples):
    eigs = np.linalg.eigvalsh(A)
    y_pos = idx * 1.5
    for e in eigs:
        color = '#2ecc71' if e > 0 else '#e74c3c' if e < 0 else '#95a5a6'
        ax1.scatter(e, y_pos, c=color, s=150, zorder=2, edgecolors='black')
    ax1.text(-6.5, y_pos, label, fontsize=10, va='center')

ax1.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
ax1.set_xlabel('Eigenvalue', fontsize=13)
ax1.set_title('Eigenvalue Spectra: Lorentzian vs Non-Lorentzian', fontsize=13)
ax1.set_yticks([])
ax1.set_xlim(-7, 7)
ax1.grid(True, alpha=0.3, axis='x')

# Panel 2: Random matrix signature distribution
ax2 = axes[0, 1]
n = 5
n_samples = 2000
pos_counts = []
rng = np.random.RandomState(42)

for _ in range(n_samples):
    M = rng.randn(n, n)
    A = (M + M.T) / 2
    eigs = np.linalg.eigvalsh(A)
    pos_counts.append(np.sum(eigs > 1e-10))

lor_frac = sum(1 for p in pos_counts if p <= 1) / n_samples

hist_data = ax2.hist(pos_counts, bins=np.arange(-0.5, n + 1.5, 1),
                      color='steelblue', alpha=0.8, edgecolor='black', density=True)
ax2.axvline(x=1.5, color='red', linestyle='--', linewidth=2,
            label=f'Lorentzian boundary\n(≤1 positive: {lor_frac:.1%})')
ax2.set_xlabel('Number of Positive Eigenvalues', fontsize=13)
ax2.set_ylabel('Density', fontsize=13)
ax2.set_title(f'Random {n}×{n} Symmetric Matrices\n'
              f'Signature Distribution (n={n})', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Spectral obstruction visualization (2D quadratic form)
ax3 = axes[1, 0]

# Lorentzian matrix: one positive eigenvalue
theta = np.linspace(0, 2 * np.pi, 200)
# Show level curves of Q(x) = x^T A x for Lorentzian A
A_lor = np.array([[2, 0], [0, -1]])
for r in [0.5, 1.0, 1.5, 2.0]:
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    Q = np.array([A_lor[0,0]*xi**2 + 2*A_lor[0,1]*xi*yi + A_lor[1,1]*yi**2
                  for xi, yi in zip(x, y)])
    c = ax3.scatter(x, y, c=Q, cmap='RdBu_r', s=3, vmin=-4, vmax=4)

ax3.set_xlabel('x₁', fontsize=13)
ax3.set_ylabel('x₂', fontsize=13)
ax3.set_title('Lorentzian Quadratic Form\nQ(x) = 2x₁² - x₂²\n(one positive direction)',
              fontsize=12)
ax3.set_aspect('equal')
ax3.grid(True, alpha=0.3)
plt.colorbar(c, ax=ax3, label='Q(x)')

# Panel 4: Non-Lorentzian matrix quadratic form
ax4 = axes[1, 1]

A_non = np.array([[2, 0], [0, 1]])
for r in [0.5, 1.0, 1.5, 2.0]:
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    Q = np.array([A_non[0,0]*xi**2 + 2*A_non[0,1]*xi*yi + A_non[1,1]*yi**2
                  for xi, yi in zip(x, y)])
    c = ax4.scatter(x, y, c=Q, cmap='RdBu_r', s=3, vmin=-4, vmax=4)

ax4.set_xlabel('x₁', fontsize=13)
ax4.set_ylabel('x₂', fontsize=13)
ax4.set_title('Non-Lorentzian Quadratic Form\nQ(x) = 2x₁² + x₂²\n'
              '(two positive directions → obstruction)',
              fontsize=12)
ax4.set_aspect('equal')
ax4.grid(True, alpha=0.3)
plt.colorbar(c, ax=ax4, label='Q(x)')

plt.tight_layout()
plt.savefig('viz_spectral.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral.png")
