#!/usr/bin/env python3
"""
Visualization 1: ReLU as Tropical Addition and Decision Boundary Structure

Shows how ReLU(x) = max(x, 0) is the fundamental tropical operation,
and how composing ReLU neurons creates piecewise linear decision boundaries
with increasing complexity.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec

fig = plt.figure(figsize=(16, 12))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# --- Panel 1: ReLU = Tropical Addition ---
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(-3, 3, 500)
relu_vals = np.maximum(x, 0)
ax1.plot(x, x, '--', color='#888', alpha=0.5, label='y = x')
ax1.axhline(0, color='#888', alpha=0.5, linestyle='--')
ax1.plot(x, relu_vals, color='#e63946', linewidth=3, label='ReLU(x) = max(x, 0)')
ax1.fill_between(x, relu_vals, alpha=0.1, color='#e63946')
ax1.axvline(0, color='#457b9d', linewidth=2, linestyle=':', alpha=0.8, label='Tropical root at x=0')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('y', fontsize=12)
ax1.set_title('ReLU = Tropical Addition\nmax(x, 0) = x ⊕ 0', fontsize=14, fontweight='bold')
ax1.legend(fontsize=10)
ax1.set_xlim(-3, 3)
ax1.set_ylim(-1, 3)

# --- Panel 2: Single-Layer Network with Increasing Width ---
ax2 = fig.add_subplot(gs[0, 1])
x = np.linspace(-3, 3, 1000)

widths = [1, 2, 3, 5]
colors = ['#264653', '#2a9d8f', '#e9c46a', '#e76f51']

for idx, w in enumerate(widths):
    np.random.seed(42 + idx)
    slopes = np.random.randn(w) * 2
    intercepts = np.random.randn(w)
    weights = np.random.randn(w)
    y = np.zeros_like(x) + 0.5
    for s, b, wt in zip(slopes, intercepts, weights):
        y += wt * np.maximum(s * x + b, 0)
    ax2.plot(x, y, color=colors[idx], linewidth=2, label=f'w={w} ({w+1} regions max)')

ax2.axhline(0, color='gray', linewidth=1, linestyle='--', alpha=0.5)
ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('f(x)', fontsize=12)
ax2.set_title('Single-Layer Networks\nMore neurons → more linear regions', fontsize=14, fontweight='bold')
ax2.legend(fontsize=10)
ax2.set_ylim(-5, 8)

# --- Panel 3: Depth-Width Tradeoff ---
ax3 = fig.add_subplot(gs[1, 0])
Ls = np.arange(1, 8)
for w in [2, 3, 5]:
    deep = [(w + 1) ** L for L in Ls]
    shallow = [L * w + 1 for L in Ls]
    ax3.semilogy(Ls, deep, 'o-', linewidth=2, markersize=6, label=f'(w+1)^L, w={w}')
    ax3.semilogy(Ls, shallow, 's--', linewidth=1.5, markersize=5, alpha=0.6,
                 label=f'L·w+1, w={w}')

ax3.set_xlabel('Depth L', fontsize=12)
ax3.set_ylabel('Max linear regions', fontsize=12)
ax3.set_title('Depth-Width Tradeoff\n(w+1)^L ≥ L·w + 1 (Theorem)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=9, ncol=2)
ax3.grid(True, alpha=0.3)

# --- Panel 4: Decision Boundary of Multi-Neuron Network ---
ax4 = fig.add_subplot(gs[1, 1])
x = np.linspace(-4, 4, 2000)

# Network with 5 neurons
np.random.seed(123)
y = -0.3
for _ in range(5):
    a = np.random.randn() * 1.5
    b = np.random.randn() * 2
    w = np.random.randn()
    y = y + w * np.maximum(a * x + b, 0)

ax4.fill_between(x, y, 0, where=(y > 0), alpha=0.2, color='#2a9d8f', label='f(x) > 0 (class +)')
ax4.fill_between(x, y, 0, where=(y <= 0), alpha=0.2, color='#e76f51', label='f(x) ≤ 0 (class −)')
ax4.plot(x, y, color='#1d3557', linewidth=2)
ax4.axhline(0, color='gray', linewidth=1, linestyle='--')

# Mark decision boundary points
sign_changes = np.where(np.diff(np.sign(y)))[0]
for idx in sign_changes:
    # Linear interpolation for exact crossing
    x0 = x[idx] - y[idx] * (x[idx+1] - x[idx]) / (y[idx+1] - y[idx])
    ax4.plot(x0, 0, 'ko', markersize=10, zorder=5)
    ax4.annotate(f'x≈{x0:.2f}', (x0, 0), textcoords="offset points",
                xytext=(0, 15), ha='center', fontsize=9, fontweight='bold')

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('f(x)', fontsize=12)
ax4.set_title(f'Decision Boundary ({len(sign_changes)} zero crossings)\nβ₀ = tropical Betti number', fontsize=14, fontweight='bold')
ax4.legend(fontsize=10, loc='upper left')
ax4.set_ylim(min(y) - 1, max(y) + 1)

fig.suptitle('Algebraic Geometry of Neural Network Decision Boundaries',
             fontsize=16, fontweight='bold', y=1.02)
plt.savefig('viz_tropical_relu.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_relu.png")
