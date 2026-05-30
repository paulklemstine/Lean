"""
Visualization: ReLU as Tropical Arithmetic

Demonstrates the connection between ReLU networks and tropical geometry.
ReLU(x) = max(0, x) is tropical addition with the zero element.
Compositions of ReLU layers compute tropical rational functions,
and the number of "pieces" in the piecewise linear output corresponds
to terms in the tropical polynomial.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

x = np.linspace(-3, 3, 1000)

# Plot 1: ReLU = tropical addition
ax1 = axes[0, 0]
ax1.plot(x, np.maximum(0, x), 'b-', linewidth=2.5, label='ReLU(x) = max(0, x)')
ax1.plot(x, x, 'g--', linewidth=1, alpha=0.5, label='y = x')
ax1.plot(x, np.zeros_like(x), 'r--', linewidth=1, alpha=0.5, label='y = 0')
ax1.fill_between(x, 0, np.maximum(0, x), alpha=0.1, color='blue')
ax1.set_xlabel('x', fontsize=11)
ax1.set_ylabel('ReLU(x)', fontsize=11)
ax1.set_title('ReLU = Tropical Addition (0 ⊕ x)', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5)
ax1.axvline(x=0, color='k', linewidth=0.5)

# Plot 2: Compositions create more pieces
ax2 = axes[0, 1]

# 1-layer network with width 2: relu(x) - relu(x-1) = hat function
hat1 = np.maximum(0, x) - np.maximum(0, x - 1)
# 2-layer: compose hat functions
hat2 = np.maximum(0, hat1) - np.maximum(0, hat1 - 0.5)
# Stack multiple hat functions
multi_hat = sum(np.maximum(0, np.maximum(0, x - k*0.5) - np.maximum(0, x - (k+1)*0.5)) * ((-1)**k * 0.3 + 0.5) 
               for k in range(-4, 8))

ax2.plot(x, hat1, 'b-', linewidth=2, label='Width 2, depth 1 (2 pieces)')
ax2.plot(x, hat2, 'r-', linewidth=2, label='Width 2, depth 2 (4 pieces)')
ax2.plot(x, multi_hat, 'g-', linewidth=1.5, label='Width 4, depth 2 (16 pieces)')
ax2.set_xlabel('x', fontsize=11)
ax2.set_ylabel('f(x)', fontsize=11)
ax2.set_title('Piece Count Growth: w^L', fontsize=13)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Plot 3: Piecewise linear approximation of sin(x) (shows piece count matters)
ax3 = axes[1, 0]
sin_x = np.sin(np.pi * x)

for n_pieces in [2, 4, 8, 16]:
    # Create piecewise linear approximation with n_pieces
    breakpoints = np.linspace(-3, 3, n_pieces + 1)
    midpoints = (breakpoints[:-1] + breakpoints[1:]) / 2
    values_at_bp = np.sin(np.pi * breakpoints)
    pwl = np.interp(x, breakpoints, values_at_bp)
    error = np.max(np.abs(sin_x - pwl))
    ax3.plot(x, pwl, linewidth=1.5, alpha=0.7, 
             label=f'{n_pieces} pieces (max err={error:.3f})')

ax3.plot(x, sin_x, 'k-', linewidth=2, alpha=0.3, label='sin(πx)')
ax3.set_xlabel('x', fontsize=11)
ax3.set_ylabel('f(x)', fontsize=11)
ax3.set_title('PWL Approximation Quality vs Piece Count', fontsize=13)
ax3.legend(fontsize=9, loc='upper right')
ax3.grid(True, alpha=0.3)

# Plot 4: Piece count vs approximation error (log-log)
ax4 = axes[1, 1]
n_pieces_range = np.array([2, 4, 8, 16, 32, 64, 128, 256, 512, 1024])

# For sin(πx) on [-3, 3]: PWL error ≈ C/N² (smooth function)
sin_errors = []
for n in n_pieces_range:
    bp = np.linspace(-3, 3, n + 1)
    vals = np.sin(np.pi * bp)
    pwl = np.interp(x, bp, vals)
    sin_errors.append(np.max(np.abs(sin_x - pwl)))

# For constant approximation via Leibniz: error ≈ 4/(2N+1)
leibniz_errors = 4.0 / (2 * n_pieces_range + 1)

# Theoretical Dirichlet bound: 1/N
dirichlet = 1.0 / n_pieces_range

ax4.loglog(n_pieces_range, sin_errors, 'bo-', markersize=5, label='sin(πx) PWL error')
ax4.loglog(n_pieces_range, leibniz_errors, 'rs-', markersize=5, label='π via Leibniz: 4/(2N+1)')
ax4.loglog(n_pieces_range, dirichlet, 'g^-', markersize=5, label='Dirichlet bound: 1/N')
ax4.loglog(n_pieces_range, 1.0/n_pieces_range**2, 'k--', linewidth=1, alpha=0.5, label='1/N² reference')
ax4.set_xlabel('Number of pieces (N = w^L)', fontsize=11)
ax4.set_ylabel('Approximation error', fontsize=11)
ax4.set_title('Error vs Complexity: Functions vs Constants', fontsize=13)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)

plt.suptitle('ReLU Networks, Tropical Geometry, and Approximation Theory', 
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tropical.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical.png")
