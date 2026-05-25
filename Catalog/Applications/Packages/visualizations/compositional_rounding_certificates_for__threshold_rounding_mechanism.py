"""
Visualization: Threshold Rounding Mechanism
=============================================

Illustrates the pigeonhole argument: if the sum over an edge is >= 1
and the edge has <= d vertices, then at least one vertex has value >= 1/d.
Shows how threshold rounding selects vertices.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Pigeonhole illustration ----
ax = axes[0]
np.random.seed(42)

# Example edge with d=4 vertices, sum >= 1
d = 4
values = np.array([0.35, 0.10, 0.40, 0.20])  # sum = 1.05
threshold = 1.0 / d

bars = ax.bar(range(d), values, color=['#e74c3c' if v >= threshold else '#3498db'
                                        for v in values],
              edgecolor='black', linewidth=1.5, width=0.6)

ax.axhline(y=threshold, color='red', linestyle='--', linewidth=2,
           label=f'Threshold = 1/d = {threshold:.2f}')

# Annotate
for i, v in enumerate(values):
    ax.text(i, v + 0.02, f'{v:.2f}', ha='center', fontsize=12, fontweight='bold')

ax.set_xticks(range(d))
ax.set_xticklabels([f'v{i}' for i in range(d)], fontsize=12)
ax.set_ylabel('x(v)', fontsize=13)
ax.set_title(f'Pigeonhole: d={d}, Σx = {sum(values):.2f} ≥ 1', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_ylim(0, 0.55)
ax.grid(True, alpha=0.2, axis='y')

# ---- Panel 2: Threshold sweep ----
ax = axes[1]

# Generate a fractional transversal
np.random.seed(123)
n = 15
x_vals = np.sort(np.random.exponential(0.3, n))[::-1]
x_vals = np.clip(x_vals, 0, 1)

# Sweep thresholds
thresholds = np.linspace(0.05, 0.8, 50)
selected_counts = [np.sum(x_vals >= t) for t in thresholds]
costs = [np.sum(x_vals) * (1.0/t) if t > 0 else n for t in thresholds]

ax.plot(thresholds, selected_counts, 'b-', linewidth=2.5, label='|S| (selected)')
ax.fill_between(thresholds, selected_counts, alpha=0.15, color='blue')

# Mark specific thresholds for d=2,3,4,5
for d_val in [2, 3, 4, 5]:
    t = 1.0 / d_val
    cnt = int(np.sum(x_vals >= t))
    ax.plot(t, cnt, 'ro', markersize=10, zorder=5)
    ax.annotate(f'd={d_val}\n|S|={cnt}', (t, cnt),
               textcoords='offset points', xytext=(10, 5), fontsize=10,
               fontweight='bold')

ax.set_xlabel('Threshold (1/d)', fontsize=13)
ax.set_ylabel('Vertices Selected', fontsize=13)
ax.set_title('Threshold Rounding: Selected Set Size', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.legend(fontsize=11)

# ---- Panel 3: Cost bound verification ----
ax = axes[2]

# For various d, compare |S| to d * Σx
d_values = range(1, 8)
frac_cost = np.sum(x_vals)
actual_costs = []
bound_costs = []

for d_val in d_values:
    t = 1.0 / d_val
    S_size = np.sum(x_vals >= t)
    actual_costs.append(S_size)
    bound_costs.append(d_val * frac_cost)

ax.bar(np.array(list(d_values)) - 0.15, actual_costs, width=0.3,
       color='#2ecc71', edgecolor='black', label='|S| (actual)', zorder=3)
ax.bar(np.array(list(d_values)) + 0.15, bound_costs, width=0.3,
       color='#e74c3c', edgecolor='black', alpha=0.6, label='d · Σx (bound)', zorder=3)

ax.set_xlabel('Max Edge Size d', fontsize=13)
ax.set_ylabel('Cost', fontsize=13)
ax.set_title(f'Cost Bound: |S| ≤ d · Σx  (Σx = {frac_cost:.2f})', fontsize=13, fontweight='bold')
ax.legend(fontsize=11)
ax.set_xticks(list(d_values))
ax.grid(True, alpha=0.2, axis='y')

# Verify all satisfy bound
for i, d_val in enumerate(d_values):
    satisfied = actual_costs[i] <= bound_costs[i] + 1e-9
    marker = '✓' if satisfied else '✗'
    ax.text(d_val, max(actual_costs[i], bound_costs[i]) + 0.5,
            marker, ha='center', fontsize=14, color='green' if satisfied else 'red')

plt.suptitle('Threshold Rounding: The Pigeonhole Principle at Work',
            fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_threshold.png', dpi=150, bbox_inches='tight')
print("Saved viz_threshold.png")
