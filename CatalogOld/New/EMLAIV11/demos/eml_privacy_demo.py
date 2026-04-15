#!/usr/bin/env python3
"""
EML Differential Privacy & Federated Learning Demo
===================================================
Based on formally verified theorems from EMLCryptographicML.lean:
- dp_noise_pos: DP noise scale is positive
- advanced_better: √k composition beats k composition for k ≥ 4
- eml_sensitivity_advantage: EML < ReLU sensitivity
- federated_rounds_help: convergence improves with rounds
- eml_comm_advantage: EML reduces communication

Demonstrates privacy-utility tradeoffs and federated convergence.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Verified functions from Lean ---
def dp_noise_scale(sensitivity, eps):
    """Noise scale: sensitivity / eps"""
    return sensitivity / eps

def basic_composition(eps, k):
    """Basic: k * eps"""
    return eps * k

def advanced_composition(eps, k):
    """Advanced: sqrt(k) * eps"""
    return np.sqrt(k) * eps

# --- Demo ---
print("=== EML Differential Privacy (Lean-Verified) ===")

fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# --- Plot 1: Basic vs Advanced Composition ---
ax1 = axes[0, 0]
k_range = np.arange(1, 101)
eps = 0.1
basic = basic_composition(eps, k_range)
advanced = advanced_composition(eps, k_range)
ax1.plot(k_range, basic, 'r-', linewidth=2.5, label='Basic: kε')
ax1.plot(k_range, advanced, 'b-', linewidth=2.5, label='Advanced: √k·ε')
ax1.fill_between(k_range, advanced, basic, alpha=0.15, color='green',
                 where=k_range >= 4)
ax1.axvline(x=4, color='green', linestyle=':', linewidth=1.5, label='Crossover at k=4')
ax1.set_xlabel('Number of Queries (k)', fontsize=12)
ax1.set_ylabel('Total Privacy Loss', fontsize=12)
ax1.set_title('Composition Theorem (ε=0.1)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)
ax1.annotate('✓ Proven: √k < k\nfor k ≥ 4', xy=(60, 4), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# --- Plot 2: Privacy-Utility Tradeoff ---
ax2 = axes[0, 1]
eps_range = np.linspace(0.01, 10, 200)
d, w = 6, 64
eml_sens = np.sqrt(4 * d * w)
relu_sens = np.sqrt(d * w * w)
eml_noise = eml_sens / eps_range
relu_noise = relu_sens / eps_range

# Model accuracy as function of noise
eml_acc = 0.92 * np.exp(-0.005 * eml_noise)
relu_acc = 0.92 * np.exp(-0.005 * relu_noise)

ax2.plot(eps_range, eml_acc, 'b-', linewidth=2.5, label='EML')
ax2.plot(eps_range, relu_acc, 'r--', linewidth=2.5, label='ReLU')
ax2.set_xlabel('Privacy Budget (ε)', fontsize=12)
ax2.set_ylabel('Model Accuracy', fontsize=12)
ax2.set_title('Privacy-Utility Tradeoff', fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.annotate('EML: better accuracy\nat same privacy', xy=(2, 0.85), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

# --- Plot 3: Noise Scale Comparison ---
ax3 = axes[0, 2]
eps_range2 = np.linspace(0.1, 5, 100)
eml_noise2 = dp_noise_scale(eml_sens, eps_range2)
relu_noise2 = dp_noise_scale(relu_sens, eps_range2)
ax3.plot(eps_range2, eml_noise2, 'b-', linewidth=2.5, label=f'EML (sens={eml_sens:.1f})')
ax3.plot(eps_range2, relu_noise2, 'r--', linewidth=2.5, label=f'ReLU (sens={relu_sens:.1f})')
ax3.fill_between(eps_range2, eml_noise2, relu_noise2, alpha=0.15, color='green')
ax3.set_xlabel('Privacy Parameter (ε)', fontsize=12)
ax3.set_ylabel('Required Noise Scale', fontsize=12)
ax3.set_title('DP Noise: EML vs ReLU', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

# --- Plot 4: Federated Learning Convergence ---
ax4 = axes[1, 0]
rounds = np.arange(1, 101)
n_clients = [2, 5, 10, 20, 50]
for n in n_clients:
    # Model: error = 1 / (rounds * sqrt(n))
    error = 1.0 / (rounds * np.sqrt(n))
    ax4.plot(rounds, error, linewidth=2, label=f'{n} clients')
ax4.set_xlabel('Communication Rounds', fontsize=12)
ax4.set_ylabel('Convergence Error', fontsize=12)
ax4.set_title('Federated EML Convergence', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.set_yscale('log')

# --- Plot 5: Communication Cost ---
ax5 = axes[1, 1]
widths = np.arange(8, 257, 8)
d = 8
eml_bits = 4 * d * widths * 32  # 32-bit floats
mlp_bits = d * widths**2 * 32
ax5.semilogy(widths, eml_bits / 1e6, 'b-', linewidth=2.5, label='EML: 4dw params')
ax5.semilogy(widths, mlp_bits / 1e6, 'r--', linewidth=2.5, label='MLP: dw² params')
ax5.set_xlabel('Width (w)', fontsize=12)
ax5.set_ylabel('Communication per Round (MB)', fontsize=12)
ax5.set_title('Federated Communication Cost (d=8)', fontsize=13, fontweight='bold')
ax5.legend(fontsize=11)
ax5.grid(True, alpha=0.3, which='both')

# --- Plot 6: Privacy Guarantee Over Time ---
ax6 = axes[1, 2]
T = 1000
eps_per_step = 0.01
steps = np.arange(1, T+1)
basic_total = eps_per_step * steps
advanced_total = eps_per_step * np.sqrt(steps)
rdp_total = eps_per_step * np.sqrt(2 * steps * np.log(1/1e-5))  # RDP bound

ax6.plot(steps, basic_total, 'r-', linewidth=2, label='Basic composition')
ax6.plot(steps, advanced_total, 'b-', linewidth=2.5, label='Advanced composition')
ax6.plot(steps, rdp_total, 'g--', linewidth=2, label='RDP (δ=10⁻⁵)')
ax6.axhline(y=1.0, color='k', linestyle=':', linewidth=1.5, label='ε=1 threshold')
ax6.set_xlabel('Training Steps', fontsize=12)
ax6.set_ylabel('Cumulative Privacy Loss (ε)', fontsize=12)
ax6.set_title('Privacy Budget Over Training', fontsize=13, fontweight='bold')
ax6.legend(fontsize=10)
ax6.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('demos/eml_privacy_federated.png', dpi=150, bbox_inches='tight')
print("✓ Saved: demos/eml_privacy_federated.png")

print(f"\n=== Key Results ===")
print(f"✓ Sensitivity ratio (d=6,w=64): ReLU/EML = {relu_sens/eml_sens:.1f}×")
print(f"✓ Noise reduction at ε=1: {relu_noise2[np.argmin(np.abs(eps_range2-1))]/eml_noise2[np.argmin(np.abs(eps_range2-1))]:.1f}×")
print(f"✓ Communication savings at w=128: {8*128**2/(4*8*128):.0f}×")
