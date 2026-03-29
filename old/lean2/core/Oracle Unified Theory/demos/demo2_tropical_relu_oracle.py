"""
Demo 2: Tropical Geometry and ReLU as Oracle

Visualizes:
1. ReLU idempotency: ReLU(ReLU(x)) = ReLU(x)
2. Tropical arithmetic (min, +) vs classical (+, ×)
3. ReLU networks as tropical polynomial evaluators
4. The "band" structure of composed ReLU oracles
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ── ReLU oracle ──
def relu(x):
    return np.maximum(0, x)

def shifted_relu(x, bias):
    return np.maximum(0, x - bias)

# ── Figure 1: ReLU Idempotency ──
fig = plt.figure(figsize=(16, 12))
gs = GridSpec(2, 2, figure=fig, hspace=0.35, wspace=0.3)

x = np.linspace(-5, 5, 1000)

# Panel 1: ReLU is an oracle
ax1 = fig.add_subplot(gs[0, 0])
y1 = relu(x)
y2 = relu(relu(x))
y3 = relu(relu(relu(x)))
ax1.plot(x, x, '--', color='gray', alpha=0.5, label='Identity (x)')
ax1.plot(x, y1, 'b-', linewidth=2, label='ReLU(x)')
ax1.plot(x, y2, 'r--', linewidth=3, label='ReLU(ReLU(x))')
ax1.plot(x, y3, 'g:', linewidth=2, label='ReLU³(x)')
ax1.set_xlabel('x', fontsize=12)
ax1.set_ylabel('Output', fontsize=12)
ax1.set_title('ReLU is an Oracle: O² = O\nAll iterations collapse to the first', fontsize=13)
ax1.legend(fontsize=10)
ax1.annotate('ReLU(ReLU(x)) = ReLU(x)\n∀x ∈ ℝ',
             xy=(2, 2), xytext=(0.3, 0.75), textcoords='axes fraction',
             fontsize=13, fontweight='bold', color='darkred',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-5, 5)
ax1.set_ylim(-1, 5)

# Panel 2: Composition of shifted ReLUs (band structure)
ax2 = fig.add_subplot(gs[0, 1])
biases = [-2, -1, 0, 1, 2]
colors = plt.cm.viridis(np.linspace(0, 1, len(biases)))

for bias, color in zip(biases, colors):
    y = shifted_relu(x, bias)
    ax2.plot(x, y, color=color, linewidth=2, label=f'ReLU(x - {bias})')

# Compose two ReLUs
y_comp = shifted_relu(shifted_relu(x, -1), 1)
ax2.plot(x, y_comp, 'r--', linewidth=3, label='ReLU(ReLU(x+1) - 1)')

ax2.set_xlabel('x', fontsize=12)
ax2.set_ylabel('Output', fontsize=12)
ax2.set_title('Band Structure: Composed ReLU Oracles\nEvery composition is still idempotent', fontsize=13)
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-5, 5)
ax2.set_ylim(-1, 7)

# Panel 3: Tropical arithmetic
ax3 = fig.add_subplot(gs[1, 0])

# Show min(a,b) = tropical addition, a+b = tropical multiplication
a_vals = np.linspace(0, 5, 200)
b = 2.5

# Classical vs Tropical
classical_add = a_vals + b
classical_mul = a_vals * b
tropical_add = np.minimum(a_vals, b)
tropical_mul = a_vals + b

ax3.plot(a_vals, classical_add, 'b-', linewidth=2, label='Classical a + b')
ax3.plot(a_vals, tropical_add, 'r-', linewidth=2, label='Tropical a ⊕ b = min(a, b)')
ax3.plot(a_vals, classical_mul, 'b--', linewidth=2, label='Classical a × b')
ax3.plot(a_vals, tropical_mul, 'r--', linewidth=2, label='Tropical a ⊙ b = a + b')
ax3.axhline(y=b, color='gray', linestyle=':', alpha=0.5)
ax3.annotate(f'b = {b}', xy=(0.5, b), fontsize=10, color='gray')
ax3.set_xlabel('a', fontsize=12)
ax3.set_ylabel('Result', fontsize=12)
ax3.set_title('Classical vs. Tropical Arithmetic\n(+,×) → (min, +)', fontsize=13)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: ReLU network as tropical polynomial
ax4 = fig.add_subplot(gs[1, 1])

# A 2-layer ReLU network computes a tropical polynomial
# f(x) = max(0, w1*x + b1) + max(0, w2*x + b2) = tropical polynomial in x
def two_neuron_layer(x, w1, b1, w2, b2):
    return relu(w1 * x + b1) + relu(w2 * x + b2)

# Show how different weight configurations give piecewise-linear functions
configs = [
    (1, -1, -1, 2, 'w=(1,-1), b=(-1,2)'),
    (2, 0, -1, 3, 'w=(2,-1), b=(0,3)'),
    (0.5, -2, -0.5, 1, 'w=(0.5,-0.5), b=(-2,1)'),
]

x_dense = np.linspace(-4, 4, 1000)
for w1, b1, w2, b2, label in configs:
    y = two_neuron_layer(x_dense, w1, b1, w2, b2)
    ax4.plot(x_dense, y, linewidth=2, label=label)

ax4.set_xlabel('x', fontsize=12)
ax4.set_ylabel('f(x)', fontsize=12)
ax4.set_title('ReLU Networks = Tropical Polynomials\nPiecewise-linear functions from oracle composition', fontsize=13)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.annotate('Each kink = tropical monomial\nDepth = polynomial degree',
             xy=(0.5, 0.85), xycoords='axes fraction',
             fontsize=11, ha='center', color='darkblue',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.9))

plt.savefig('/workspace/request-project/research_output/demos/fig3_tropical_relu.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig3_tropical_relu.png")

# ── Figure 2: Tropical GCD as Oracle ──
fig2, (ax_a, ax_b) = plt.subplots(1, 2, figsize=(14, 5))

# Tropical GCD = min (idempotent)
vals = np.arange(1, 20)
a_grid, b_grid = np.meshgrid(vals, vals)
trop_gcd = np.minimum(a_grid, b_grid)
class_gcd = np.gcd(a_grid, b_grid)

im1 = ax_a.imshow(class_gcd, cmap='YlOrRd', origin='lower', extent=[0.5, 19.5, 0.5, 19.5])
ax_a.set_title('Classical GCD(a, b)', fontsize=13)
ax_a.set_xlabel('a', fontsize=12)
ax_a.set_ylabel('b', fontsize=12)
plt.colorbar(im1, ax=ax_a, label='GCD')

im2 = ax_b.imshow(trop_gcd, cmap='YlOrRd', origin='lower', extent=[0.5, 19.5, 0.5, 19.5])
ax_b.set_title('Tropical GCD(a, b) = min(a, b)', fontsize=13)
ax_b.set_xlabel('a', fontsize=12)
ax_b.set_ylabel('b', fontsize=12)
plt.colorbar(im2, ax=ax_b, label='min')

fig2.suptitle('Oracle Perspective: GCD as Idempotent Operation\n'
              'Classical GCD and Tropical GCD are both oracles (applied twice = applied once)',
              fontsize=14, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('/workspace/request-project/research_output/demos/fig4_tropical_gcd.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: fig4_tropical_gcd.png")

print("\n✅ Demo 2 complete: Tropical ReLU Oracle visualized")
