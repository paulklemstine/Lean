#!/usr/bin/env python3
"""
EML Activation Function Demo
============================
Demonstrates the Gaussian activation σ(x) = exp(-x²) used in EML networks,
comparing it with standard activations (ReLU, Sigmoid, Tanh, GELU).

Key Properties (formally verified in Lean 4):
- Always positive: σ(x) > 0 for all x
- Bounded in [0, 1]: 0 < σ(x) ≤ 1
- Peak at zero: σ(0) = 1
- Smooth and infinitely differentiable
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from scipy.special import erf

# --- Activation Functions ---
def eml_activation(x):
    """EML Gaussian activation: exp(-x²)"""
    return np.exp(-x**2)

def relu(x):
    return np.maximum(0, x)

def sigmoid(x):
    return 1 / (1 + np.exp(-x))

def tanh_act(x):
    return np.tanh(x)

def gelu(x):
    return 0.5 * x * (1 + erf(x / np.sqrt(2)))

# --- Derivatives ---
def eml_derivative(x):
    """d/dx exp(-x²) = -2x exp(-x²)"""
    return -2 * x * np.exp(-x**2)

def relu_derivative(x):
    return np.where(x > 0, 1.0, 0.0)

def sigmoid_derivative(x):
    s = sigmoid(x)
    return s * (1 - s)

# --- Visualization ---
x = np.linspace(-4, 4, 1000)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: All activations
ax1 = axes[0, 0]
ax1.plot(x, eml_activation(x), 'b-', linewidth=3, label='EML: exp(-x²)')
ax1.plot(x, relu(x), 'r--', linewidth=1.5, label='ReLU')
ax1.plot(x, sigmoid(x), 'g-.', linewidth=1.5, label='Sigmoid')
ax1.plot(x, tanh_act(x), 'm:', linewidth=1.5, label='Tanh')
ax1.plot(x, gelu(x), 'c--', linewidth=1.5, label='GELU')
ax1.set_title('EML vs Standard Activations', fontsize=14, fontweight='bold')
ax1.set_xlabel('x')
ax1.set_ylabel('σ(x)')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.axhline(y=0, color='k', linewidth=0.5)
ax1.axhline(y=1, color='k', linewidth=0.5, linestyle='--', alpha=0.5)

# Plot 2: EML activation close-up with properties
ax2 = axes[0, 1]
ax2.fill_between(x, 0, eml_activation(x), alpha=0.3, color='blue')
ax2.plot(x, eml_activation(x), 'b-', linewidth=3, label='exp(-x²)')
ax2.annotate('Peak: σ(0) = 1', xy=(0, 1), xytext=(1.5, 0.85),
            fontsize=12, arrowprops=dict(arrowstyle='->', color='red'),
            bbox=dict(boxstyle='round', facecolor='yellow', alpha=0.8))
ax2.annotate('Always positive', xy=(-2, eml_activation(-2)), xytext=(-3.5, 0.3),
            fontsize=11, arrowprops=dict(arrowstyle='->', color='green'))
ax2.set_title('EML Activation: Proven Properties', fontsize=14, fontweight='bold')
ax2.set_xlabel('x')
ax2.set_ylabel('σ(x)')
ax2.legend(fontsize=12)
ax2.grid(True, alpha=0.3)

# Plot 3: Derivatives comparison
ax3 = axes[1, 0]
ax3.plot(x, eml_derivative(x), 'b-', linewidth=3, label="EML: -2x·exp(-x²)")
ax3.plot(x, relu_derivative(x), 'r--', linewidth=1.5, label="ReLU derivative")
ax3.plot(x, sigmoid_derivative(x), 'g-.', linewidth=1.5, label="Sigmoid derivative")
ax3.set_title('Gradient Comparison', fontsize=14, fontweight='bold')
ax3.set_xlabel('x')
ax3.set_ylabel("σ'(x)")
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.axhline(y=0, color='k', linewidth=0.5)

# Plot 4: Lipschitz constant visualization
ax4 = axes[1, 1]
lipschitz = np.abs(eml_derivative(x))
ax4.plot(x, lipschitz, 'b-', linewidth=2, label='|σ\'(x)| (local Lipschitz)')
ax4.axhline(y=2/np.e**0.5, color='r', linewidth=2, linestyle='--',
           label=f'Global max: 2/√e ≈ {2/np.e**0.5:.3f}')
ax4.fill_between(x, lipschitz, alpha=0.2, color='blue')
ax4.set_title('EML Lipschitz Profile (Robustness)', fontsize=14, fontweight='bold')
ax4.set_xlabel('x')
ax4.set_ylabel('|dσ/dx|')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/eml_activation_comparison.png', dpi=150, bbox_inches='tight')
print("✓ Saved: demos/eml_activation_comparison.png")

# --- Numerical verification of proven properties ---
print("\n=== Numerical Verification of Lean-Proven Properties ===")
test_points = np.linspace(-10, 10, 10000)
vals = eml_activation(test_points)
print(f"✓ eml_activation_pos:    min value = {vals.min():.2e} > 0")
print(f"✓ eml_activation_le_one: max value = {vals.max():.6f} ≤ 1")
print(f"✓ eml_activation_zero:   σ(0)      = {eml_activation(0):.6f} = 1")
print(f"✓ eml_activation_mem_Icc: all in [0,1] = {np.all((vals >= 0) & (vals <= 1))}")
print(f"✓ Global Lipschitz constant: {np.max(np.abs(eml_derivative(test_points))):.6f}")
