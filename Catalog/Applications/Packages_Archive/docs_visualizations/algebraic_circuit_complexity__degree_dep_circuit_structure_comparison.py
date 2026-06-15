import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# Circuit structures for computing x^8
structures = {
    'Left chain\n((((x·x)·x)·x)·...)': {'size': 15, 'depth': 7, 'degree': 8, 'mul_gates': 7},
    'Right chain\n(x·(x·(x·(x·...))))': {'size': 15, 'depth': 7, 'degree': 8, 'mul_gates': 7},
    'Balanced tree\n((x·x)·(x·x))·...': {'size': 7, 'depth': 3, 'degree': 8, 'mul_gates': 3},
    'Iterated squaring\nx→x²→x⁴→x⁸': {'size': 7, 'depth': 3, 'degree': 8, 'mul_gates': 3},
}

fig, ax = plt.subplots(figsize=(12, 6))
x_pos = np.arange(len(structures))
width = 0.2
metrics = ['size', 'depth', 'degree', 'mul_gates']
colors = ['#2196F3', '#FF9800', '#4CAF50', '#9C27B0']
labels = ['Size', 'Depth', 'Degree Bound', 'Mul Gates']

for i, (metric, color, label) in enumerate(zip(metrics, colors, labels)):
    values = [s[metric] for s in structures.values()]
    ax.bar(x_pos + i*width, values, width, color=color, label=label, alpha=0.85)

ax.set_xticks(x_pos + 1.5*width)
ax.set_xticklabels(structures.keys(), fontsize=10)
ax.set_ylabel('Value', fontsize=13)
ax.set_title('Circuit Architecture Comparison for x⁸', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('circuit_comparison.png', dpi=150, bbox_inches='tight')
print('Saved circuit_comparison.png')