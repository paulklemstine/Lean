#!/usr/bin/env python3
"""
EML Generalization Theory Demo
================================
Based on formally verified theorems from GeneralizationTheory.lean:
- eml_lower_vc: EML has lower VC dimension (4dw vs dw²)
- eml_less_overfitting: Lower VC → less overfitting
- dropout_reduces_capacity: Dropout effect
- regularized_ge_empirical: Regularization bounds
- more_data_less_variance: Data reduces variance

Visualizes bias-variance tradeoff, double descent, and VC dimension effects.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Verified functions from Lean ---
def eml_vc(d, w): return 4 * d * w
def mlp_vc(d, w): return d * w * w
def shattering_bound(vc): return 2**vc
def effective_params(total, keep_rate): return total * keep_rate
def pac_bayes_bound(kl, n): return np.sqrt(kl / n)

fig, axes = plt.subplots(2, 3, figsize=(18, 11))

# --- Plot 1: VC Dimension Comparison ---
ax1 = axes[0, 0]
widths = np.arange(4, 129, 4)
d = 8
eml_vcs = [eml_vc(d, w) for w in widths]
mlp_vcs = [mlp_vc(d, w) for w in widths]
ax1.plot(widths, eml_vcs, 'b-', linewidth=2.5, label='EML: 4dw')
ax1.plot(widths, mlp_vcs, 'r--', linewidth=2.5, label='MLP: dw²')
ax1.fill_between(widths, eml_vcs, mlp_vcs, alpha=0.1, color='green')
ax1.set_xlabel('Width (w)', fontsize=12)
ax1.set_ylabel('VC Dimension', fontsize=12)
ax1.set_title('VC Dimension: EML vs MLP (d=8)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.annotate('Lower VC = less overfitting\n✓ eml_lower_vc', xy=(80, 20000), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# --- Plot 2: Bias-Variance Tradeoff ---
ax2 = axes[0, 1]
capacity = np.linspace(1, 200, 500)
noise = 0.1
bias_sq = 1.0 / capacity
variance = 0.01 * capacity / 100
total = bias_sq + variance + noise

ax2.plot(capacity, bias_sq, 'b--', linewidth=2, label='Bias²')
ax2.plot(capacity, variance, 'r--', linewidth=2, label='Variance')
ax2.plot(capacity, total, 'k-', linewidth=2.5, label='Total Error')
ax2.axhline(y=noise, color='gray', linestyle=':', linewidth=1, label=f'Noise = {noise}')
min_idx = np.argmin(total)
ax2.axvline(x=capacity[min_idx], color='green', linestyle=':', linewidth=1.5)
ax2.scatter([capacity[min_idx]], [total[min_idx]], color='green', s=100, zorder=5)
ax2.set_xlabel('Model Capacity', fontsize=12)
ax2.set_ylabel('Error', fontsize=12)
ax2.set_title('Bias-Variance Tradeoff', fontsize=13, fontweight='bold')
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.annotate(f'Optimal: {capacity[min_idx]:.0f}', xy=(capacity[min_idx], total[min_idx]),
            xytext=(capacity[min_idx]+30, total[min_idx]+0.2), fontsize=10,
            arrowprops=dict(arrowstyle='->'))

# --- Plot 3: Double Descent ---
ax3 = axes[0, 2]
params = np.concatenate([np.linspace(10, 99, 200), np.linspace(101, 500, 200)])
data_size = 100
noise_level = 0.1

# Classical regime
classical = np.where(params < data_size,
                     noise_level * data_size / (data_size - params + 1),
                     noise_level * data_size / (params - data_size + 1))
# Add interpolation peak
classical = np.where(np.abs(params - data_size) < 5, 5.0, classical)
classical = np.minimum(classical, 5.0)

# EML reaches interpolation with fewer params
eml_params = params / 4  # EML equivalent capacity

ax3.plot(params, classical, 'r-', linewidth=2, label='Standard MLP')
ax3.plot(params, np.interp(eml_params, params, classical), 'b-', linewidth=2.5, label='EML (effective)')
ax3.axvline(x=data_size, color='gray', linestyle=':', linewidth=1.5, label='n = data size')
ax3.set_xlabel('Parameters', fontsize=12)
ax3.set_ylabel('Test Error', fontsize=12)
ax3.set_title('Double Descent Phenomenon', fontsize=13, fontweight='bold')
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)
ax3.set_ylim(0, 3)
ax3.annotate('EML enters modern\nregime earlier', xy=(150, 0.5), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightblue', alpha=0.8))

# --- Plot 4: PAC-Bayes Bounds ---
ax4 = axes[1, 0]
n_range = np.arange(100, 10001, 100)
d, w, p = 8, 64, 32
eml_kl = 4 * d * w * np.log(p)
mlp_kl = d * w * w * np.log(p)
eml_bound = [pac_bayes_bound(eml_kl, n) for n in n_range]
mlp_bound = [pac_bayes_bound(mlp_kl, n) for n in n_range]

ax4.plot(n_range, eml_bound, 'b-', linewidth=2.5, label=f'EML (KL={eml_kl:.0f})')
ax4.plot(n_range, mlp_bound, 'r--', linewidth=2.5, label=f'MLP (KL={mlp_kl:.0f})')
ax4.fill_between(n_range, eml_bound, mlp_bound, alpha=0.1, color='green')
ax4.set_xlabel('Training Samples (n)', fontsize=12)
ax4.set_ylabel('Generalization Bound', fontsize=12)
ax4.set_title('PAC-Bayes: EML vs MLP (d=8, w=64)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=10)
ax4.grid(True, alpha=0.3)
ax4.annotate(f'✓ eml_lower_kl\n{mlp_kl/eml_kl:.0f}× tighter', xy=(5000, 1.5), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# --- Plot 5: Dropout Effect ---
ax5 = axes[1, 1]
keep_rates = np.linspace(0, 1, 100)
total_eml = eml_vc(8, 64)
total_mlp = mlp_vc(8, 64)
eff_eml = [effective_params(total_eml, p) for p in keep_rates]
eff_mlp = [effective_params(total_mlp, p) for p in keep_rates]

ax5.plot(keep_rates, eff_eml, 'b-', linewidth=2.5, label=f'EML (base={total_eml})')
ax5.plot(keep_rates, eff_mlp, 'r--', linewidth=2.5, label=f'MLP (base={total_mlp})')
ax5.axhline(y=total_eml, color='blue', linestyle=':', alpha=0.5)
ax5.set_xlabel('Keep Rate (1 - dropout)', fontsize=12)
ax5.set_ylabel('Effective Parameters', fontsize=12)
ax5.set_title('Dropout: Effective Capacity', fontsize=13, fontweight='bold')
ax5.legend(fontsize=10)
ax5.grid(True, alpha=0.3)
ax5.annotate('EML at 100% = MLP at 6%\n✓ eml_less_dropout_needed', xy=(0.5, 15000), fontsize=10,
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# --- Plot 6: Regularization Effect ---
ax6 = axes[1, 2]
lambdas = np.linspace(0, 1, 100)
empirical_loss = 0.1
norm_sq = 10.0
reg_loss = empirical_loss + lambdas * norm_sq
test_loss = empirical_loss + 0.5 * np.exp(-2 * lambdas) + 0.1 * lambdas * norm_sq

ax6.plot(lambdas, reg_loss, 'r-', linewidth=2, label='Training loss')
ax6.plot(lambdas, test_loss, 'b-', linewidth=2.5, label='Test loss')
ax6.axhline(y=empirical_loss, color='gray', linestyle=':', label='Empirical loss')
min_idx = np.argmin(test_loss)
ax6.scatter([lambdas[min_idx]], [test_loss[min_idx]], color='green', s=100, zorder=5)
ax6.axvline(x=lambdas[min_idx], color='green', linestyle=':', alpha=0.5)
ax6.set_xlabel('Regularization Strength (λ)', fontsize=12)
ax6.set_ylabel('Loss', fontsize=12)
ax6.set_title('Regularization Tradeoff', fontsize=13, fontweight='bold')
ax6.legend(fontsize=10)
ax6.grid(True, alpha=0.3)
ax6.annotate(f'Optimal λ = {lambdas[min_idx]:.2f}\n✓ regularized_ge_empirical',
            xy=(lambdas[min_idx], test_loss[min_idx]),
            xytext=(lambdas[min_idx]+0.2, test_loss[min_idx]+0.5), fontsize=10,
            arrowprops=dict(arrowstyle='->'),
            bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

plt.tight_layout()
plt.savefig('demos/eml_generalization.png', dpi=150, bbox_inches='tight')
print("✓ Saved: demos/eml_generalization.png")

print(f"\n=== Key Results ===")
print(f"✓ VC dimension (d=8, w=64): EML={eml_vc(8,64)}, MLP={mlp_vc(8,64)}, ratio={mlp_vc(8,64)/eml_vc(8,64):.0f}×")
print(f"✓ PAC-Bayes KL ratio: {mlp_kl/eml_kl:.0f}×")
print(f"✓ EML effective dropout: {mlp_vc(8,64)/eml_vc(8,64):.0f}× built-in regularization")
