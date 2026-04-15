#!/usr/bin/env python3
"""
EML Adversarial Robustness Demo
================================
Demonstrates certified robustness properties from EMLCryptographicML.lean:
- Certified radius = ε / L (formally proven positive)
- Smaller Lipschitz → larger radius (formally proven)
- EML sensitivity advantage over ReLU
- Network Lipschitz as product of layers

Simulates adversarial attacks and certified defense regions.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle

# --- Verified functions from Lean ---
def eml_lipschitz(a, b):
    """Lipschitz constant of EML neuron: |a| * |b|"""
    return abs(a) * abs(b)

def certified_radius(eps, L):
    """Certified radius: eps / L"""
    return eps / L

def network_lipschitz(layer_lips):
    """Product of layer Lipschitz constants"""
    result = 1.0
    for l in layer_lips:
        result *= l
    return result

def eml_sensitivity(depth, width, max_grad):
    """EML sensitivity: maxGrad * sqrt(4 * depth * width)"""
    return max_grad * np.sqrt(4 * depth * width)

def relu_sensitivity(depth, width, max_grad):
    """ReLU sensitivity: maxGrad * sqrt(depth * width²)"""
    return max_grad * np.sqrt(depth * width * width)

# --- Demo ---
print("=== EML Adversarial Robustness (Lean-Verified) ===")

# Network comparison
eml_layers = [0.5, 0.6, 0.4, 0.5]  # EML Lipschitz per layer
relu_layers = [1.2, 1.5, 1.3, 1.4]  # ReLU Lipschitz per layer

eml_L = network_lipschitz(eml_layers)
relu_L = network_lipschitz(relu_layers)
eps = 0.1

eml_r = certified_radius(eps, eml_L)
relu_r = certified_radius(eps, relu_L)

print(f"EML network Lipschitz:  {eml_L:.4f}")
print(f"ReLU network Lipschitz: {relu_L:.4f}")
print(f"EML certified radius:   {eml_r:.4f}")
print(f"ReLU certified radius:  {relu_r:.4f}")
print(f"Radius advantage:       {eml_r/relu_r:.1f}×")
print()

# Sensitivity comparison
d, w, g = 6, 64, 1.0
eml_s = eml_sensitivity(d, w, g)
relu_s = relu_sensitivity(d, w, g)
print(f"EML sensitivity (d={d}, w={w}):  {eml_s:.2f}")
print(f"ReLU sensitivity (d={d}, w={w}): {relu_s:.2f}")
print(f"Sensitivity ratio: {relu_s/eml_s:.1f}×")

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# --- Plot 1: Certified regions ---
ax1 = axes[0, 0]
np.random.seed(42)
n_points = 200
X = np.random.randn(n_points, 2) * 2
y = (X[:, 0]**2 + X[:, 1]**2 < 4).astype(int)
colors = ['blue' if yi else 'red' for yi in y]

ax1.scatter(X[:, 0], X[:, 1], c=colors, s=20, alpha=0.5)
# Show certified regions for a few points
for i in [10, 50, 100, 150]:
    circle_eml = Circle(X[i], eml_r * 10, fill=False, color='green', linewidth=2, linestyle='-')
    circle_relu = Circle(X[i], relu_r * 10, fill=False, color='orange', linewidth=1.5, linestyle='--')
    ax1.add_patch(circle_eml)
    ax1.add_patch(circle_relu)
ax1.plot([], [], 'g-', linewidth=2, label=f'EML certified (r={eml_r*10:.2f})')
ax1.plot([], [], color='orange', linestyle='--', linewidth=1.5, label=f'ReLU certified (r={relu_r*10:.2f})')
ax1.set_title('Certified Robustness Regions', fontsize=14, fontweight='bold')
ax1.set_xlabel('x₁')
ax1.set_ylabel('x₂')
ax1.legend(fontsize=10)
ax1.set_xlim(-4, 4)
ax1.set_ylim(-4, 4)
ax1.grid(True, alpha=0.3)

# --- Plot 2: Lipschitz constant vs certified radius ---
ax2 = axes[0, 1]
L_range = np.linspace(0.01, 5, 200)
for e in [0.05, 0.1, 0.2, 0.5]:
    ax2.plot(L_range, e / L_range, linewidth=2, label=f'ε = {e}')
ax2.axvline(x=eml_L, color='blue', linestyle=':', alpha=0.7, label=f'EML L={eml_L:.2f}')
ax2.axvline(x=relu_L, color='red', linestyle=':', alpha=0.7, label=f'ReLU L={relu_L:.2f}')
ax2.set_xlabel('Network Lipschitz Constant (L)', fontsize=12)
ax2.set_ylabel('Certified Radius (ε/L)', fontsize=12)
ax2.set_title('Radius vs Lipschitz (Proven: L↓ ⟹ r↑)', fontsize=14, fontweight='bold')
ax2.legend(fontsize=9)
ax2.set_ylim(0, 2)
ax2.grid(True, alpha=0.3)

# --- Plot 3: Sensitivity comparison ---
ax3 = axes[1, 0]
widths = np.arange(4, 129, 4)
d = 8
eml_sens = [eml_sensitivity(d, w, 1.0) for w in widths]
relu_sens = [relu_sensitivity(d, w, 1.0) for w in widths]
ax3.plot(widths, eml_sens, 'b-', linewidth=2.5, label='EML: √(4dw)')
ax3.plot(widths, relu_sens, 'r--', linewidth=2.5, label='ReLU: √(dw²)')
ax3.fill_between(widths, eml_sens, relu_sens, alpha=0.15, color='green')
ax3.set_xlabel('Width (w)', fontsize=12)
ax3.set_ylabel('Gradient Sensitivity', fontsize=12)
ax3.set_title('EML vs ReLU Sensitivity (d=8)', fontsize=14, fontweight='bold')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)
ax3.annotate('EML advantage\ngrows with width', xy=(80, 300), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# --- Plot 4: Attack success rate simulation ---
ax4 = axes[1, 1]
eps_attack = np.linspace(0, 0.5, 100)
# Model: attack succeeds when perturbation > certified radius
eml_success = 1 - np.exp(-((eps_attack / eml_r)**2))
relu_success = 1 - np.exp(-((eps_attack / relu_r)**2))
random_success = 1 - np.exp(-((eps_attack / 0.01)**2))

ax4.plot(eps_attack, eml_success, 'b-', linewidth=2.5, label='vs EML network')
ax4.plot(eps_attack, relu_success, 'r--', linewidth=2.5, label='vs ReLU network')
ax4.plot(eps_attack, random_success, 'gray', linewidth=1.5, alpha=0.5, label='vs undefended')
ax4.set_xlabel('Attack Budget (ε)', fontsize=12)
ax4.set_ylabel('Attack Success Rate', fontsize=12)
ax4.set_title('Adversarial Attack Resistance', fontsize=14, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0, 1.05)

plt.tight_layout()
plt.savefig('demos/eml_adversarial_robustness.png', dpi=150, bbox_inches='tight')
print("\n✓ Saved: demos/eml_adversarial_robustness.png")
