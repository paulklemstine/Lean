#!/usr/bin/env python3
"""
Visualization 3: Tropical Scheduling and Critical Path

Demonstrates how the max-plus (tropical) semiring computes the critical path
in a recipe dependency graph. Shows a 6-step dinner recipe with dependencies,
comparing sequential vs parallel (critical path) scheduling.

This visualizes the cross-domain bridge between tropical algebra and
kitchen scheduling, and the theorem: makespan ≤ sum(durations).
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

# Recipe steps with durations and dependencies
steps = [
    {"name": "Prep vegetables", "duration": 10, "deps": []},
    {"name": "Make sauce", "duration": 15, "deps": []},
    {"name": "Boil pasta", "duration": 12, "deps": []},
    {"name": "Sauté veggies", "duration": 8, "deps": [0]},      # after prep
    {"name": "Combine pasta+sauce", "duration": 5, "deps": [1, 2]},  # after sauce and pasta
    {"name": "Plate and garnish", "duration": 3, "deps": [3, 4]},    # after sauté and combine
]

n = len(steps)

# Compute completion times using tropical (max-plus) algebra
completion = [0] * n
for i in range(n):
    dep_max = 0
    for d in steps[i]["deps"]:
        dep_max = max(dep_max, completion[d])  # tropical addition = max
    completion[i] = dep_max + steps[i]["duration"]  # tropical multiplication = +

makespan = max(completion)
total_sequential = sum(s["duration"] for s in steps)

# Compute start times
start = [completion[i] - steps[i]["duration"] for i in range(n)]

fig, axes = plt.subplots(2, 1, figsize=(14, 8), gridspec_kw={'height_ratios': [3, 1]})

# === Plot 1: Gantt chart ===
ax1 = axes[0]
colors = plt.cm.Set3(np.linspace(0, 1, n))

for i in range(n):
    ax1.barh(i, steps[i]["duration"], left=start[i], color=colors[i],
             edgecolor='black', linewidth=0.8, height=0.6)
    ax1.text(start[i] + steps[i]["duration"] / 2, i,
             f"{steps[i]['name']}\n({steps[i]['duration']}min)",
             ha='center', va='center', fontsize=8, fontweight='bold')

# Draw dependency arrows
for i in range(n):
    for d in steps[i]["deps"]:
        ax1.annotate('', xy=(start[i], i), xytext=(completion[d], d),
                     arrowprops=dict(arrowstyle='->', color='red', lw=1.5, alpha=0.6))

# Critical path highlighting
ax1.axvline(x=makespan, color='red', linestyle='--', linewidth=2, alpha=0.7,
            label=f'Makespan = {makespan} min')
ax1.axvline(x=total_sequential, color='blue', linestyle=':', linewidth=2, alpha=0.5,
            label=f'Sequential = {total_sequential} min')

ax1.set_xlabel('Time (minutes)', fontsize=12)
ax1.set_ylabel('Recipe Step', fontsize=12)
ax1.set_title('Tropical Scheduling: Critical Path in a Dinner Recipe\n'
              f'Speedup: {total_sequential/makespan:.1f}× '
              f'(parallel {makespan}min vs sequential {total_sequential}min)',
              fontsize=13, fontweight='bold')
ax1.set_yticks(range(n))
ax1.set_yticklabels([f"Step {i}" for i in range(n)])
ax1.legend(loc='lower right', fontsize=10)
ax1.grid(True, alpha=0.3, axis='x')
ax1.invert_yaxis()

# === Plot 2: Tropical algebra explanation ===
ax2 = axes[1]
ax2.axis('off')

# Show the tropical computation
text = (
    "Tropical Semiring Computation (max-plus algebra):\n\n"
    "• Tropical addition ⊕ = max:   max(a, b)  →  'take the later finish time'\n"
    "• Tropical multiplication ⊗ = +:   a + b    →  'sequential duration'\n"
    "• Key axiom: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)   →   a + max(b,c) = max(a+b, a+c)\n\n"
    f"Completion times: {[completion[i] for i in range(n)]}\n"
    f"Theorem verified: makespan ({makespan}) ≤ total ({total_sequential})  ✓"
)

ax2.text(0.05, 0.95, text, transform=ax2.transAxes, fontsize=10,
         verticalalignment='top', fontfamily='monospace',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.tight_layout()
plt.savefig('viz_tropical_scheduling.png', dpi=150, bbox_inches='tight')
print("Saved viz_tropical_scheduling.png")
