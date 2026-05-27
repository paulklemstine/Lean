"""
Phase Transition Visualization for Lorentzian Recognition

Visualizes the sharp phase transition in Lorentzian signature recognition
as a function of signal-to-noise ratio ε/σ. The transition occurs at the
GOE edge constant 2, separating the easy phase (recognition succeeds)
from the hard phase (recognition fails). This is the central empirical
prediction of the complexity-theoretic phase transition theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def generate_goe_matrix(n, sigma=1.0):
    """Generate an n×n GOE matrix with variance parameter σ."""
    M = np.random.randn(n, n) * sigma / np.sqrt(n)
    return (M + M.T) / 2


def generate_signal_matrix(n, gap=1.0):
    """Generate a signal matrix with Lorentzian signature and given gap."""
    D = np.diag([-gap] * n)
    D[0, 0] = gap
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    return Q @ D @ Q.T


def has_lorentzian_signature(A, tol=1e-10):
    """Check if A has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > tol) <= 1


def run_experiment(n, sigma, ratios, n_trials):
    """Run recognition experiment for given parameters."""
    success_rates = np.zeros(len(ratios))
    for i, ratio in enumerate(ratios):
        gap = ratio * sigma
        successes = 0
        for _ in range(n_trials):
            A = generate_signal_matrix(n, gap=gap)
            E = generate_goe_matrix(n, sigma=sigma)
            if has_lorentzian_signature(A + E):
                successes += 1
        success_rates[i] = successes / n_trials
    return success_rates


# Run experiments
np.random.seed(42)
ratios = np.linspace(0.5, 4.0, 40)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# Panel 1: Phase transition for multiple dimensions
dims = [10, 30, 100]
colors = ['#e74c3c', '#3498db', '#2ecc71']
for n, color in zip(dims, colors):
    sr = run_experiment(n, 1.0, ratios, 150)
    ax1.plot(ratios, sr, '-', linewidth=2.5, color=color, label=f'n = {n}')

ax1.axvline(x=2.0, color='black', linestyle='--', linewidth=2, alpha=0.7,
            label='Predicted edge = 2')
ax1.fill_betweenx([0, 1], 0.5, 2.0, alpha=0.06, color='red')
ax1.fill_betweenx([0, 1], 2.0, 4.0, alpha=0.06, color='green')
ax1.text(1.2, 0.92, 'Hard\nPhase', fontsize=14, ha='center', color='#c0392b',
         fontweight='bold')
ax1.text(3.2, 0.92, 'Easy\nPhase', fontsize=14, ha='center', color='#27ae60',
         fontweight='bold')
ax1.set_xlabel('Signal gap / σ  (ε/σ)', fontsize=14)
ax1.set_ylabel('Recognition success probability', fontsize=14)
ax1.set_title('Phase Transition in Lorentzian Recognition', fontsize=16,
              fontweight='bold')
ax1.legend(fontsize=12, loc='center left')
ax1.set_ylim(-0.05, 1.05)
ax1.set_xlim(0.5, 4.0)
ax1.grid(True, alpha=0.3)

# Panel 2: Spectral gap proxy as function of noise
gap_values = np.linspace(0.5, 4.0, 100)
sigma = 1.0
proxy_vals = gap_values - 2 * sigma  # SpectralGapProxy(g, 2σ, 1)

ax2.plot(gap_values, proxy_vals, 'b-', linewidth=3)
ax2.axhline(y=0, color='k', linestyle='-', linewidth=0.8)
ax2.axvline(x=2.0, color='r', linestyle='--', linewidth=2, alpha=0.7)
ax2.fill_between(gap_values, proxy_vals, 0,
                 where=proxy_vals > 0, alpha=0.15, color='green')
ax2.fill_between(gap_values, proxy_vals, 0,
                 where=proxy_vals < 0, alpha=0.15, color='red')
ax2.set_xlabel('Signal gap (g)', fontsize=14)
ax2.set_ylabel('Spectral Gap Proxy  (g − 2σ)', fontsize=14)
ax2.set_title('Algorithmic Margin as Order Parameter', fontsize=16,
              fontweight='bold')
ax2.annotate('Margin > 0\n→ Certified', xy=(3.0, 1.0), fontsize=12,
             ha='center', color='#27ae60', fontweight='bold')
ax2.annotate('Margin < 0\n→ No Certificate', xy=(1.0, -1.0), fontsize=12,
             ha='center', color='#c0392b', fontweight='bold')
ax2.annotate('Critical\nPoint', xy=(2.0, 0), xytext=(2.5, -0.8),
             fontsize=11, ha='center',
             arrowprops=dict(arrowstyle='->', color='red', lw=1.5),
             color='red', fontweight='bold')
ax2.grid(True, alpha=0.3)

plt.tight_layout(pad=2.0)
plt.savefig('viz_phase_transition.png', dpi=150, bbox_inches='tight')
print("Saved viz_phase_transition.png")
