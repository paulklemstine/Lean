"""
Demo 2: EML Entropy Function H(p) = p - log(p)

V19 introduced the EML entropy function emlEntropy(p) = eml(log p, p) = p - log(p).
Key properties:
- H(p) ≥ 1 for all p > 0
- H(p) = 1 iff p = 1
- H is strictly convex on (0,∞)
- Connection to KL divergence: D_KL(p‖q) involves H(p/q) - 1
"""

import numpy as np
import matplotlib.pyplot as plt

def eml_entropy(p):
    return p - np.log(p)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Plot 1: EML Entropy function
p = np.linspace(0.05, 5, 500)
ax = axes[0]
ax.plot(p, eml_entropy(p), 'b-', linewidth=2, label='H(p) = p - log(p)')
ax.axhline(y=1, color='r', linestyle='--', alpha=0.7, label='H = 1 (minimum)')
ax.plot([1], [1], 'ro', markersize=10, label='Minimum at p=1')
ax.set_xlabel('p')
ax.set_ylabel('H(p)')
ax.set_title('EML Entropy: Minimum 1 at p=1')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 6)

# Plot 2: Strict convexity of H
ax = axes[1]
ax.plot(p, eml_entropy(p), 'b-', linewidth=2)
# Show tangent line at p=2
p0 = 2
h0 = eml_entropy(p0)
dh = 1 - 1/p0  # derivative of p - log(p)
tangent = h0 + dh * (p - p0)
ax.plot(p, tangent, 'r--', label=f'Tangent at p={p0}')
ax.fill_between(p, eml_entropy(p), tangent, where=eml_entropy(p)>tangent,
                alpha=0.2, color='green', label='Convexity gap')
ax.set_xlabel('p')
ax.set_ylabel('H(p)')
ax.set_title('Strict Convexity: H above every tangent')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 6)

# Plot 3: KL divergence via EML entropy
ax = axes[2]
r = np.linspace(0.1, 5, 500)
kl = r - 1 - np.log(r)  # = H(r) - 1
ax.plot(r, kl, 'b-', linewidth=2, label='D_KL = H(p/q) - 1')
ax.plot(r, eml_entropy(r) - 1, 'r--', linewidth=1, alpha=0.7, label='H(r) - 1')
ax.axhline(y=0, color='k', linestyle='-', alpha=0.3)
ax.plot([1], [0], 'go', markersize=10, label='D_KL = 0 at p=q')
ax.set_xlabel('p/q')
ax.set_ylabel('D_KL(p‖q) per unit')
ax.set_title('KL Divergence via EML Entropy')
ax.legend()
ax.grid(True, alpha=0.3)

plt.suptitle('V19: EML Entropy Function', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('demo2_entropy_function.png', dpi=150, bbox_inches='tight')
plt.close()
print("Demo 2 saved: demo2_entropy_function.png")
