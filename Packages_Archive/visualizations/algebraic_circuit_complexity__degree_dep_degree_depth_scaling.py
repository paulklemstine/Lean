import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Degree-Depth Tradeoff
ax1 = axes[0]
depths = list(range(11))
max_degrees = [2**d for d in depths]
ax1.semilogy(depths, max_degrees, 'b-o', linewidth=2, markersize=8, label='2^depth (upper bound)')
ax1.semilogy(depths, max_degrees, 'r--s', linewidth=1.5, markersize=6, label='Iterated squaring (tight)')
# Add example of non-tight: addition chains
add_degrees = [1] * len(depths)  # x+x+...+x always has degree 1
ax1.semilogy(depths, add_degrees, 'g-.^', linewidth=1.5, markersize=6, label='Addition chain (degree 1)')
ax1.set_xlabel('Circuit Depth', fontsize=13)
ax1.set_ylabel('Degree Bound', fontsize=13)
ax1.set_title('Degree-Depth Tradeoff\n(Theorem: degree ≤ 2^depth)', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Work-Span Inequality
ax2 = axes[1]
sizes = list(range(1, 51))
min_depths = [s - 1 for s in sizes]  # depth ≤ size - 1
ax2.plot(sizes, min_depths, 'b-', linewidth=2, label='depth = size - 1 (chain)')
ax2.fill_between(sizes, 0, [s-1 for s in sizes], alpha=0.15, color='blue', label='Feasible region')
balanced_depths = [max(0, int(np.log2(max(s,1)))) for s in sizes]
ax2.plot(sizes, balanced_depths, 'r--', linewidth=2, label='depth ≈ log₂(size) (balanced)')
ax2.set_xlabel('Circuit Size (total gates)', fontsize=13)
ax2.set_ylabel('Circuit Depth', fontsize=13)
ax2.set_title('Work-Span Inequality\n(Theorem: size ≥ depth + 1)', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('degree_depth_visualization.png', dpi=150, bbox_inches='tight')
print('Saved degree_depth_visualization.png')