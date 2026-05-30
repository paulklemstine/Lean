#!/usr/bin/env python3
"""
Visualization 2: Fixed-Point Convergence of Proof Operators

Visualizes how Kleene iteration converges to a fixed point
for proof operators, showing the proof approximation lattice
evolving over iterations.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def proof_operator_step(approx, axiom_set, rules):
    """Apply one step of a proof operator."""
    result = dict(approx)
    # Axioms get evidence
    for p in axiom_set:
        result[p] = max(result.get(p, 0), 1)
    # Apply deduction rules
    for (premise, conclusion) in rules:
        if result.get(premise, 0) > 0:
            result[conclusion] = max(result.get(conclusion, 0),
                                     result.get(premise, 0))
    return result


# Set up proof system
num_props = 8
axioms = {0, 1}
rules = [(0, 2), (1, 3), (2, 4), (3, 5), (4, 6), (5, 7), (2, 5)]

# Run Kleene iteration
history = []
approx = {p: 0 for p in range(num_props)}
history.append(list(approx.values()))

for _ in range(10):
    approx = proof_operator_step(approx, axioms, rules)
    history.append(list(approx.values()))

history = np.array(history)

# Create visualization
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Fixed-Point Convergence of Proof Operators',
             fontsize=14, fontweight='bold')

# Plot 1: Heatmap of iterations
im = ax1.imshow(history.T, aspect='auto', cmap='YlOrRd',
                interpolation='nearest')
ax1.set_xlabel('Iteration', fontsize=11)
ax1.set_ylabel('Proposition', fontsize=11)
ax1.set_title('Proof Status per Iteration', fontsize=12)
ax1.set_yticks(range(num_props))
ax1.set_yticklabels([f'P{i}' for i in range(num_props)])
plt.colorbar(im, ax=ax1, label='Evidence Level')

# Mark convergence point
for p in range(num_props):
    for i in range(len(history) - 1):
        if history[i, p] == history[-1, p] and history[i, p] > 0:
            ax1.plot(i, p, 'g*', markersize=8, zorder=5)
            break

# Plot 2: Convergence curves
colors = plt.cm.tab10(np.linspace(0, 1, num_props))
for p in range(num_props):
    ax2.plot(range(len(history)), history[:, p], 'o-',
             color=colors[p], label=f'P{p}', linewidth=2, markersize=4)
ax2.set_xlabel('Iteration', fontsize=11)
ax2.set_ylabel('Evidence Level', fontsize=11)
ax2.set_title('Convergence Trajectories', fontsize=12)
ax2.legend(ncol=2, fontsize=8)
ax2.grid(True, alpha=0.3)

# Plot 3: Deductive closure growth
closure_sizes = [sum(1 for v in row if v > 0) for row in history]
ax3.bar(range(len(closure_sizes)), closure_sizes, color='#2196F3', alpha=0.7)
ax3.plot(range(len(closure_sizes)), closure_sizes, 'r-o', linewidth=2)
ax3.set_xlabel('Iteration', fontsize=11)
ax3.set_ylabel('|Deductive Closure|', fontsize=11)
ax3.set_title('Growth of Deductive Closure', fontsize=12)
ax3.set_ylim(0, num_props + 0.5)
ax3.grid(True, alpha=0.3, axis='y')

# Add annotation for fixed point
final_size = closure_sizes[-1]
ax3.axhline(y=final_size, color='green', linestyle='--', alpha=0.5)
ax3.text(len(closure_sizes) - 1, final_size + 0.3, f'Fixed point: {final_size} props',
         ha='right', fontsize=9, color='green')

plt.tight_layout()
plt.savefig('viz_fixed_point.png', dpi=150, bbox_inches='tight')
print("Saved viz_fixed_point.png")
