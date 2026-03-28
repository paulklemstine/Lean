#!/usr/bin/env python3
"""
Demo 4: Tropical Geometry of Neural Networks (Direction C1-C3)

ReLU networks compute tropical polynomials: max(0, x) is the tropical
semiring operation. This demo visualizes:
1. ReLU functions as tropical polynomials
2. Decision boundaries as tropical varieties
3. Tropical proof compression ratios
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
import matplotlib
matplotlib.use('Agg')

np.random.seed(42)

def relu(x):
    return np.maximum(0, x)

def tropical_polynomial_1d(x, coeffs, shifts):
    """
    Tropical polynomial: max_i(a_i + b_i * x)
    This is what a 1-hidden-layer ReLU network computes.
    """
    terms = np.array([a + b * x for a, b in zip(coeffs, shifts)])
    return np.max(terms, axis=0)

def tropical_polynomial_2d(x, y, weights, biases):
    """
    2D tropical polynomial: max_i(w1_i * x + w2_i * y + b_i)
    Decision boundaries are where two terms are equal = tropical variety.
    """
    terms = np.array([w[0]*x + w[1]*y + b for w, b in zip(weights, biases)])
    return np.max(terms, axis=0)

# ─── Figure 1: 1D ReLU = Tropical Polynomial ───
fig = plt.figure(figsize=(16, 14))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(-3, 3, 500)

# A 2-layer ReLU network with 4 hidden units
w1 = np.array([1.5, -1.0, 0.8, -0.5])
b1 = np.array([0.0, 1.0, -0.5, 2.0])
w2 = np.array([1.0, 0.7, -0.5, 0.3])
b2 = 0.2

# Network output
hidden = np.array([relu(w*x + b) for w, b in zip(w1, b1)])
output = np.sum(w2[:, None] * hidden, axis=0) + b2

ax1.plot(x, output, 'b-', linewidth=2.5, label='ReLU Network Output')

# Show individual tropical terms
for i in range(4):
    ax1.plot(x, w2[i] * hidden[i], '--', alpha=0.4, linewidth=1,
             label=f'Hidden unit {i+1}')

ax1.set_xlabel('Input x', fontsize=12)
ax1.set_ylabel('Output f(x)', fontsize=12)
ax1.set_title('ReLU Network = Tropical Polynomial\n(piecewise linear = max of affine)',
              fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)

# ─── Figure 2: 2D Tropical Variety (Decision Boundary) ───
ax2 = fig.add_subplot(gs[0, 1])

xx, yy = np.meshgrid(np.linspace(-3, 3, 300), np.linspace(-3, 3, 300))
weights = [(1.0, 0.5), (-0.5, 1.2), (0.8, -0.8), (-1.0, -0.3), (0.3, 0.9)]
biases = [0.0, 1.0, -0.5, 0.5, -1.0]

zz = tropical_polynomial_2d(xx, yy, weights, biases)

# The tropical variety is where the maximum is achieved by 2+ terms
terms = np.array([w[0]*xx + w[1]*yy + b for w, b in zip(weights, biases)])
max_val = np.max(terms, axis=0)
# Find where two terms are close to the maximum (ridge lines)
close_to_max = np.sum(np.abs(terms - max_val[None, :, :]) < 0.1, axis=0)
variety = close_to_max >= 2

ax2.contourf(xx, yy, zz, levels=30, cmap='viridis', alpha=0.6)
ax2.contour(xx, yy, close_to_max.astype(float), levels=[1.5], colors='red',
            linewidths=2)
ax2.set_xlabel('x₁', fontsize=12)
ax2.set_ylabel('x₂', fontsize=12)
ax2.set_title('Tropical Variety = Decision Boundary\n(red lines = where max switches)',
              fontsize=13, fontweight='bold')
ax2.set_aspect('equal')

# ─── Figure 3: Tropical vs Classical Proof Compression ───
ax3 = fig.add_subplot(gs[1, 0])

# Model: classical proof has L redundant conjunctions,
# tropical version collapses them via idempotency
classical_lengths = np.arange(10, 500, 5)
# Tropical compression: L → C·√L (idempotent collapse of nested operations)
tropical_lengths = 3.0 * np.sqrt(classical_lengths)
# With logarithmic overhead for encoding
tropical_actual = tropical_lengths + 5 * np.log2(classical_lengths)

ax3.plot(classical_lengths, classical_lengths, 'k--', alpha=0.4,
         linewidth=1, label='No compression (L)')
ax3.plot(classical_lengths, tropical_actual, '-', color='#E91E63',
         linewidth=2.5, label='Tropical compression (C√L + 5·log L)')
ax3.fill_between(classical_lengths, tropical_actual, classical_lengths,
                 alpha=0.15, color='#E91E63')
ax3.set_xlabel('Classical Proof Length L', fontsize=12)
ax3.set_ylabel('Proof Length', fontsize=12)
ax3.set_title('Tropical Proof Compression\n(shaded = savings)',
              fontsize=13, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

# Annotate compression ratio
ratio_point = 300
tropical_at_300 = 3.0 * np.sqrt(300) + 5 * np.log2(300)
ax3.annotate(f'Compression: {300/tropical_at_300:.1f}×',
             xy=(300, tropical_at_300), xytext=(350, 200),
             arrowprops=dict(arrowstyle='->', color='red'),
             fontsize=11, color='red', fontweight='bold')

# ─── Figure 4: ReLU Network Depth vs Tropical Degree ───
ax4 = fig.add_subplot(gs[1, 1])

depths = np.arange(1, 11)
# Tropical degree = product of widths per layer
# For uniform width w: degree = w^(depth-1)
for width, color, marker in [(2, '#2196F3', 'o'), (3, '#FF9800', 's'),
                               (4, '#4CAF50', '^'), (8, '#E91E63', 'D')]:
    degrees = width ** (depths - 1)
    ax4.semilogy(depths, degrees, f'-{marker}', color=color, linewidth=2,
                 markersize=7, label=f'Width w = {width}')

ax4.set_xlabel('Network Depth d', fontsize=12)
ax4.set_ylabel('Tropical Polynomial Degree', fontsize=12)
ax4.set_title('Depth-Degree Correspondence\n(degree = w^{d-1})',
              fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

fig.suptitle('Directions C1-C3: Tropical Geometry of Neural Networks',
             fontsize=15, fontweight='bold', y=0.98)
plt.savefig('/workspace/request-project/Research/demos/fig7_tropical_neural.png',
            dpi=150, bbox_inches='tight', facecolor='white')
plt.close()
print("✅ Figure 7 saved: fig7_tropical_neural.png")
