"""
Visualization: Quantum-Tropical Bridge
========================================

Visualizes the cross-domain bridge between quantum probability
and tropical geometry. The map p ↦ -log(p) transforms:
- Probability maximization → Tropical cost minimization
- Multiplication → Addition (tropicalCost_mul)
- The order is reversed (min_tropicalCost_iff_max_prob)
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: The tropical cost function
ax = axes[0, 0]
p = np.linspace(0.01, 1.0, 500)
tc = -np.log(p)
ax.plot(p, tc, 'b-', linewidth=2.5)
ax.fill_between(p, 0, tc, alpha=0.1, color='blue')
ax.axhline(y=0, color='gray', linestyle='-', alpha=0.3)
ax.axvline(x=1, color='green', linestyle='--', alpha=0.5, label='p=1: cost=0')
ax.set_xlabel('Probability p', fontsize=12)
ax.set_ylabel('Tropical cost = −log(p)', fontsize=12)
ax.set_title('Tropical Cost Function\n(Monotone decreasing, proved)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_xlim(0, 1.05)
ax.set_ylim(-0.2, 5)

# Plot 2: Multiplicative-to-additive property
ax = axes[0, 1]
p_vals = np.linspace(0.1, 0.9, 20)
q_vals = np.linspace(0.1, 0.9, 20)
P, Q = np.meshgrid(p_vals, q_vals)

cost_product = -np.log(P * Q)
cost_sum = -np.log(P) + (-np.log(Q))

# They should be equal
error = np.abs(cost_product - cost_sum)
im = ax.pcolormesh(p_vals, q_vals, np.log10(error + 1e-16), cmap='RdYlGn_r',
                    shading='auto', vmin=-16, vmax=-14)
ax.set_xlabel('p', fontsize=12)
ax.set_ylabel('q', fontsize=12)
ax.set_title('tropicalCost(p·q) = tropicalCost(p) + tropicalCost(q)\n'
             'Error (log₁₀ scale, ≈ machine epsilon)', fontsize=13)
plt.colorbar(im, ax=ax, label='log₁₀(error)')

# Plot 3: Order reversal demonstration
ax = axes[1, 0]
probs = np.array([0.4, 0.25, 0.2, 0.1, 0.05])
costs = -np.log(probs)
labels = [f'State {i}' for i in range(len(probs))]

x = np.arange(len(probs))
width = 0.35

ax_right = ax.twinx()
bars1 = ax.bar(x - width/2, probs, width, color='steelblue', alpha=0.8, label='Probability')
bars2 = ax_right.bar(x + width/2, costs, width, color='coral', alpha=0.8, label='Tropical cost')

ax.set_xlabel('Quantum state', fontsize=12)
ax.set_ylabel('Probability', color='steelblue', fontsize=12)
ax_right.set_ylabel('Tropical cost', color='coral', fontsize=12)
ax.set_title('Order Reversal: max prob ↔ min cost\n(min_tropicalCost_iff_max_prob)', fontsize=13)
ax.set_xticks(x)
ax.set_xticklabels(labels, fontsize=10)

lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax_right.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)

# Plot 4: Density matrix spectrum as tropical costs
ax = axes[1, 1]
# Create a 4-state quantum system
np.random.seed(42)
amp = np.random.randn(4) + 1j * np.random.randn(4)
amp = amp / np.linalg.norm(amp)
rho = np.outer(amp, np.conj(amp))
eigenvalues = np.linalg.eigvalsh(rho)
eigenvalues = eigenvalues[eigenvalues > 1e-12]

if len(eigenvalues) > 0:
    trop_evals = -np.log(eigenvalues)

    ax.stem(range(len(eigenvalues)), eigenvalues, linefmt='b-', markerfmt='bo',
            basefmt='gray', label='Eigenvalues (probabilities)')
    ax2 = ax.twinx()
    ax2.stem(range(len(trop_evals)), trop_evals, linefmt='r-', markerfmt='rs',
             basefmt='gray', label='Tropical eigenvalues')

    ax.set_xlabel('Eigenvalue index', fontsize=12)
    ax.set_ylabel('Eigenvalue λ', color='blue', fontsize=12)
    ax2.set_ylabel('Tropical cost −log(λ)', color='red', fontsize=12)
    ax.set_title('Density Matrix Spectrum\nand Tropical Transform', fontsize=13)
    lines1, labels1 = ax.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)

fig.suptitle('Quantum-Tropical Bridge: Probability ↔ Optimization',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_tropical_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_bridge.png")
