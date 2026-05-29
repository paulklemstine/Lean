#!/usr/bin/env python3
"""
Visualization 3: Projector Idempotence and Spectral Convergence

Demonstrates that the packet projector P satisfies P² = P (idempotence),
visualized by showing how repeated application of P converges in one step.
Also shows the spectral energy landscape as a function on the group.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# --- Inline infrastructure ---
def cf_inner(f, g, n):
    return np.sum(f * np.conj(g)) / n

def cyclic_chars(n):
    w = np.exp(2j * np.pi / n)
    return [np.array([w**(j*k) for j in range(n)]) for k in range(n)]

def packet_projector(f, basis, n):
    result = np.zeros_like(f)
    for chi in basis:
        c = cf_inner(f, chi, n)
        result += c * chi
    return result

def spectral_energy(f, basis, n):
    return sum(abs(cf_inner(f, chi, n))**2 for chi in basis)

# --- Setup ---
n = 8
basis = cyclic_chars(n)
np.random.seed(17)
f = np.random.randn(n) + 1j * np.random.randn(n)

# Apply projector repeatedly
max_iters = 6
iterates = [f.copy()]
for _ in range(max_iters):
    iterates.append(packet_projector(iterates[-1], basis, n))

# Compute errors relative to P(f)
Pf = iterates[1]
errors = [np.max(np.abs(it - Pf)) for it in iterates]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Panel 1: Real parts of iterates
ax1 = axes[0, 0]
x = np.arange(n)
colors = plt.cm.plasma(np.linspace(0, 0.9, max_iters + 1))
for k, it in enumerate(iterates[:4]):
    label = f'P^{k}(f)' if k > 0 else 'f'
    ax1.plot(x, it.real, 'o-', color=colors[k], label=label,
             markersize=8, linewidth=2, alpha=0.8)
ax1.set_xlabel('Group element', fontsize=12)
ax1.set_ylabel('Re(f)', fontsize=12)
ax1.set_title('Projector Iterates (Real Part)', fontsize=13, fontweight='bold')
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Convergence plot
ax2 = axes[0, 1]
ax2.semilogy(range(len(errors)), [max(e, 1e-16) for e in errors],
             'o-', color='#E91E63', markersize=10, linewidth=2.5)
ax2.axhline(y=1e-14, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlabel('Iteration k', fontsize=12)
ax2.set_ylabel('‖Pᵏ(f) - P(f)‖∞', fontsize=12)
ax2.set_title('Idempotence: P² = P', fontsize=13, fontweight='bold')
ax2.grid(alpha=0.3)
ax2.text(0.5, 0.7, 'Converges in\n1 step!',
         transform=ax2.transAxes, fontsize=14, ha='center',
         bbox=dict(boxstyle='round', facecolor='#FCE4EC', alpha=0.8))

# Panel 3: Spectral energy at each iterate
ax3 = axes[1, 0]
iter_energies = [spectral_energy(it, basis, n) for it in iterates]
ax3.bar(range(len(iter_energies)), iter_energies,
        color=['#FF5722' if k == 0 else '#4CAF50' for k in range(len(iter_energies))],
        alpha=0.8, edgecolor='black')
ax3.set_xlabel('Iteration k', fontsize=12)
ax3.set_ylabel('Spectral Energy E(Pᵏf)', fontsize=12)
ax3.set_title('Energy Stabilization', fontsize=13, fontweight='bold')
ax3.grid(axis='y', alpha=0.3)

# Panel 4: Fourier coefficient magnitudes before and after projection
ax4 = axes[1, 1]
c_before = np.array([abs(cf_inner(f, chi, n)) for chi in basis])
c_after = np.array([abs(cf_inner(Pf, chi, n)) for chi in basis])

width = 0.35
ax4.bar(x - width/2, c_before, width, label='Before P', color='#2196F3', alpha=0.8)
ax4.bar(x + width/2, c_after, width, label='After P', color='#FF9800', alpha=0.8)
ax4.set_xlabel('Frequency k', fontsize=12)
ax4.set_ylabel('|⟨·, χₖ⟩|', fontsize=12)
ax4.set_title('Coefficient Preservation', fontsize=13, fontweight='bold')
ax4.set_xticks(x)
ax4.set_xticklabels([f'χ_{k}' for k in range(n)])
ax4.legend(fontsize=10)
ax4.grid(axis='y', alpha=0.3)

fig.suptitle('Packet Projector: Idempotence and Energy Conservation',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_projector_idempotence.png', dpi=150, bbox_inches='tight')
print("Saved viz_projector_idempotence.png")
