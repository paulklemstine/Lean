"""
Demo 3: Log-Sum-Exp and EML Connection

V19 establishes the connection between EML and the log-sum-exp (LSE) function:
- LSE(a,b) = log(exp(a) + exp(b))
- eml(LSE(a,b), y) = exp(a) + exp(b) - log(y)
- LSE(a,b) ≥ max(a,b) (proved)
- LSE is fundamental to softmax, attention mechanisms, and convex optimization
"""

import numpy as np
import matplotlib.pyplot as plt

def logsumexp(x, y):
    return np.log(np.exp(x) + np.exp(y))

def eml(x, y):
    return np.exp(x) - np.log(y)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: LSE vs max
ax = axes[0]
x = np.linspace(-3, 3, 200)
for b_val in [-1, 0, 1, 2]:
    ax.plot(x, logsumexp(x, b_val), label=f'LSE(x, {b_val})')
ax.plot(x, x, 'k--', alpha=0.5, label='y = x')
ax.set_xlabel('x')
ax.set_ylabel('LSE(x, b)')
ax.set_title('Log-Sum-Exp ≥ max(x, b)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 2: LSE smoothly approximates max
ax = axes[1]
y_vals = np.linspace(-3, 3, 200)
for scale in [0.5, 1, 2, 5]:
    smooth_max = logsumexp(scale*x, scale*0) / scale
    ax.plot(x, smooth_max, label=f'LSE(βx, 0)/β, β={scale}')
ax.plot(x, np.maximum(x, 0), 'k-', linewidth=2, label='max(x, 0) = ReLU')
ax.set_xlabel('x')
ax.set_ylabel('Smooth max')
ax.set_title('LSE → max (Tropical Limit)')
ax.legend()
ax.grid(True, alpha=0.3)

# Plot 3: EML(LSE(a,b), y) surface
ax = axes[2]
a_range = np.linspace(-2, 2, 50)
b_range = np.linspace(-2, 2, 50)
A, B = np.meshgrid(a_range, b_range)
Z = eml(logsumexp(A, B), 1)  # = exp(a) + exp(b)
c = ax.contourf(A, B, Z, levels=20, cmap='viridis')
plt.colorbar(c, ax=ax)
ax.set_xlabel('a')
ax.set_ylabel('b')
ax.set_title('eml(LSE(a,b), 1) = exp(a)+exp(b)')
ax.grid(True, alpha=0.3)

plt.suptitle('V19: Log-Sum-Exp ↔ EML Connection', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo3_log_sum_exp.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 3 saved: demo3_log_sum_exp.png")
