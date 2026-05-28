#!/usr/bin/env python3
"""
Visualization 2: Scaling Convergence in the Three Regimes

Shows how the wreath defect Δ(k,m(k)) and per-copy pressure β_W/m
behave as k → ∞ for subcritical, marginal, and supercritical
scaling sequences m(k). Demonstrates the main theorems:
- Theorem 1: Δ → 0 subcritically
- Theorem 2: β_W/m → β(S_k) subcritically
- Theorem 3: Δ does not → 0 with lower bound
"""

import numpy as np
import matplotlib.pyplot as plt

# === Inline functions ===

def beta_symm(k):
    """Model symmetric group pressure."""
    return k * np.log(k + 1) if k > 0 else 0.0

def wreath_defect(k, m, C=1.0, a=1, b=1):
    """Compute wreath defect."""
    return C * (m ** a) / (k ** b) if k > 0 else 0.0

def beta_wreath(k, m, C=1.0, a=1, b=1):
    """Full wreath pressure."""
    return m * beta_symm(k) + wreath_defect(k, m, C, a, b)

# === Parameters ===
C, a, b = 1.0, 1, 1
alpha_c = b / a
k_vals = np.arange(3, 200)

# Three scaling sequences
sequences = {
    r'Subcritical: $m(k) = \lfloor\sqrt{k}\rfloor$': {
        'func': lambda k: max(1, int(np.sqrt(k))),
        'color': '#2ecc71', 'style': '-'
    },
    r'Marginal: $m(k) = k$': {
        'func': lambda k: k,
        'color': '#f39c12', 'style': '-'
    },
    r'Supercritical: $m(k) = k^2$': {
        'func': lambda k: k * k,
        'color': '#e74c3c', 'style': '-'
    },
}

# === Plotting ===
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Wreath defect Δ(k, m(k))
ax1 = axes[0, 0]
for name, seq in sequences.items():
    defects = [wreath_defect(k, seq['func'](k), C, a, b) for k in k_vals]
    ax1.semilogy(k_vals, defects, color=seq['color'], linestyle=seq['style'],
                 linewidth=2, label=name)
ax1.set_xlabel('k', fontsize=12)
ax1.set_ylabel('|Δ(k, m(k))|', fontsize=12)
ax1.set_title('Wreath Defect (Theorem 1: subcritical → 0)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Panel 2: Per-copy pressure difference β_W/m - β(S_k)
ax2 = axes[0, 1]
for name, seq in sequences.items():
    diffs = []
    for k in k_vals:
        m = seq['func'](k)
        bw = beta_wreath(k, m, C, a, b)
        bs = beta_symm(k)
        diff = bw / m - bs if m > 0 else 0
        diffs.append(abs(diff))
    ax2.semilogy(k_vals, diffs, color=seq['color'], linestyle=seq['style'],
                 linewidth=2, label=name)
ax2.set_xlabel('k', fontsize=12)
ax2.set_ylabel('|β_W/m − β(S_k)|', fontsize=12)
ax2.set_title('Per-Copy Pressure Gap (Theorem 2)', fontsize=13, fontweight='bold')
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Scaling ratio m(k)^a / k^b
ax3 = axes[1, 0]
for name, seq in sequences.items():
    ratios = [(seq['func'](k) ** a) / (k ** b) for k in k_vals]
    ax3.semilogy(k_vals, ratios, color=seq['color'], linestyle=seq['style'],
                 linewidth=2, label=name)
ax3.axhline(y=1, color='gray', linestyle=':', alpha=0.5, label='Critical threshold')
ax3.set_xlabel('k', fontsize=12)
ax3.set_ylabel('m(k)ᵃ / kᵇ', fontsize=12)
ax3.set_title('Scaling Ratio (→ 0 = subcritical)', fontsize=13, fontweight='bold')
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# Panel 4: Relevance ratio |Δ| * k^b / m^a
ax4 = axes[1, 1]
for name, seq in sequences.items():
    rel_ratios = []
    for k in k_vals:
        m = seq['func'](k)
        delta = wreath_defect(k, m, C, a, b)
        if m > 0:
            rr = abs(delta) * (k ** b) / (m ** a)
        else:
            rr = 0
        rel_ratios.append(rr)
    ax4.plot(k_vals, rel_ratios, color=seq['color'], linestyle=seq['style'],
             linewidth=2, label=name)
ax4.axhline(y=C, color='gray', linestyle=':', alpha=0.5, label=f'Bound C = {C}')
ax4.set_xlabel('k', fontsize=12)
ax4.set_ylabel('|Δ| · kᵇ / mᵃ', fontsize=12)
ax4.set_title('Relevance Ratio (Bridge Theorem: bounded by C)', fontsize=13, fontweight='bold')
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(-0.1, 2.0)

plt.suptitle('Double Scaling Limit: Three Regimes of Wreath-Product Pressure',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('scaling_convergence.png', dpi=150, bbox_inches='tight')
print("Saved scaling_convergence.png")
