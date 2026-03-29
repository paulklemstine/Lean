#!/usr/bin/env python3
"""
Demo 3: Goodhart's Law as Repulsor Theorem (Direction E3)

Simulates the "Goodhart catastrophe": when an optimizer maximizes a proxy
metric M that imperfectly correlates with true value V, iterated optimization
drives V → -∞ while M → +∞.

This is formalized as a repulsor theorem: the true value V "evades" the
optimizer through the gap between proxy and truth.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

np.random.seed(42)

def simulate_goodhart(dim=20, correlation=0.9, n_steps=100, lr=0.3):
    """
    Simulate Goodhart's Law in a linear setting.

    True value: V(x) = v · x
    Proxy metric: M(x) = m · x, where corr(v, m) = correlation
    Optimizer: gradient ascent on M
    """
    # Generate correlated value and proxy vectors
    v = np.random.randn(dim)
    v = v / np.linalg.norm(v)

    # Create proxy with specified correlation
    noise = np.random.randn(dim)
    noise = noise - np.dot(noise, v) * v  # orthogonalize
    noise = noise / np.linalg.norm(noise)
    m = correlation * v + np.sqrt(1 - correlation**2) * noise
    m = m / np.linalg.norm(m)

    # Optimize
    x = np.zeros(dim)
    V_history = [np.dot(v, x)]
    M_history = [np.dot(m, x)]

    for _ in range(n_steps):
        # Gradient ascent on M
        x = x + lr * m
        V_history.append(np.dot(v, x))
        M_history.append(np.dot(m, x))

    return np.array(V_history), np.array(M_history)

# ─── Figure 1: Goodhart Catastrophe for Different Correlations ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
correlations = [0.99, 0.9, 0.7, 0.5, 0.3]
colors = ['#4CAF50', '#2196F3', '#FF9800', '#E91E63', '#9C27B0']

for corr, color in zip(correlations, colors):
    V, M = simulate_goodhart(correlation=corr, n_steps=80)
    ax1.plot(range(len(V)), V, '-', color=color, linewidth=2,
             label=f'ρ = {corr}', alpha=0.8)

ax1.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
ax1.set_xlabel('Optimization Steps', fontsize=12)
ax1.set_ylabel('True Value V(x)', fontsize=12)
ax1.set_title("Goodhart's Catastrophe\nTrue value under proxy optimization",
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=10, title='Proxy correlation ρ')
ax1.grid(True, alpha=0.3)

# ─── Figure 2: V vs M Trajectories ───
ax2 = fig.add_subplot(gs[0, 1])

for corr, color in zip([0.95, 0.8, 0.5], ['#4CAF50', '#FF9800', '#E91E63']):
    V, M = simulate_goodhart(correlation=corr, n_steps=60)
    ax2.plot(M, V, '-', color=color, linewidth=2, label=f'ρ = {corr}', alpha=0.8)
    ax2.plot(M[0], V[0], 'o', color=color, markersize=8)
    ax2.plot(M[-1], V[-1], 's', color=color, markersize=8)
    # Arrow showing direction
    mid = len(M) // 2
    ax2.annotate('', xy=(M[mid+1], V[mid+1]), xytext=(M[mid], V[mid]),
                arrowprops=dict(arrowstyle='->', color=color, lw=2))

# Plot ideal line V = M
mx = max(abs(M).max() for corr in [0.95, 0.8, 0.5]
         for V, M in [simulate_goodhart(correlation=corr, n_steps=60)])
ax2.plot([-5, 25], [-5, 25], 'k--', alpha=0.3, label='V = M (ideal)')
ax2.set_xlabel('Proxy Metric M(x)', fontsize=12)
ax2.set_ylabel('True Value V(x)', fontsize=12)
ax2.set_title('V vs. M Trajectories\n(○ = start, □ = end)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# ─── Figure 3: The Goodhart Gap ───
ax3 = fig.add_subplot(gs[1, 0])

steps = np.arange(80)
for corr, color in zip([0.99, 0.9, 0.7, 0.5], colors[:4]):
    V, M = simulate_goodhart(correlation=corr, n_steps=79)
    gap = M - V
    ax3.plot(steps, gap, '-', color=color, linewidth=2,
             label=f'ρ = {corr}', alpha=0.8)

ax3.set_xlabel('Optimization Steps', fontsize=12)
ax3.set_ylabel('Goodhart Gap (M - V)', fontsize=12)
ax3.set_title('The Goodhart Gap: M - V over Time\n(proxy overshoot)',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=0, color='gray', linestyle=':', alpha=0.5)

# ─── Figure 4: Phase Diagram of Goodhart's Law ───
ax4 = fig.add_subplot(gs[1, 1])

corr_range = np.linspace(0.1, 0.99, 30)
lr_range = np.linspace(0.05, 0.5, 20)
divergence_map = np.zeros((len(lr_range), len(corr_range)))

for i, lr in enumerate(lr_range):
    for j, corr in enumerate(corr_range):
        V, M = simulate_goodhart(correlation=corr, n_steps=50, lr=lr)
        # Measure: ratio V_final / M_final (negative = Goodhart catastrophe)
        if abs(M[-1]) > 0.01:
            divergence_map[i, j] = V[-1] / M[-1]
        else:
            divergence_map[i, j] = 1.0

im = ax4.imshow(divergence_map, extent=[0.1, 0.99, 0.05, 0.5],
                aspect='auto', cmap='RdYlGn', origin='lower',
                vmin=-0.5, vmax=1.0)
plt.colorbar(im, ax=ax4, label='V/M ratio (green = aligned)')
ax4.set_xlabel('Proxy Correlation ρ', fontsize=12)
ax4.set_ylabel('Learning Rate', fontsize=12)
ax4.set_title("Goodhart Phase Diagram\n(red = catastrophe, green = aligned)",
              fontsize=13, fontweight='bold')

fig.suptitle("Direction E3: Goodhart's Law as Repulsor Theorem",
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig5_goodhart_repulsor.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 5 saved: fig5_goodhart_repulsor.png")

# ─── Figure 6: Multiple Realizations showing stochasticity ───
fig2, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax, corr in zip(axes, [0.95, 0.7, 0.4]):
    for trial in range(20):
        V, M = simulate_goodhart(correlation=corr, n_steps=60)
        ax.plot(range(len(V)), V, '-', alpha=0.2, color='#2196F3', linewidth=1)

    # Mean trajectory
    V_all = np.array([simulate_goodhart(correlation=corr, n_steps=60)[0]
                      for _ in range(100)])
    ax.plot(range(V_all.shape[1]), V_all.mean(axis=0), '-', color='red',
            linewidth=3, label='Mean V(x)')
    ax.axhline(y=0, color='gray', linestyle=':', alpha=0.5)
    ax.set_title(f'ρ = {corr}', fontsize=13, fontweight='bold')
    ax.set_xlabel('Steps')
    ax.set_ylabel('True Value V(x)')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

fig2.suptitle("Goodhart's Law: Ensemble of 20 Optimizer Trajectories",
              fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('/workspace/request-project/Research/demos/fig6_goodhart_ensemble.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 6 saved: fig6_goodhart_ensemble.png")
