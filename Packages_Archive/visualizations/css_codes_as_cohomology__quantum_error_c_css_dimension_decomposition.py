import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

examples = [
    ('Square Q₂', 4, 1, 0),
    ('Cube Q₃', 12, 5, 7),
    ('Torus 3×3', 18, 2, 8),
    ('K₃ filled', 3, 0, 1),
    ('Q₄', 32, 17, 15),
]

names = [e[0] for e in examples]
n_vals = [e[1] for e in examples]
betti = [e[2] for e in examples]
boundaries = [e[3] for e in examples]
cycles = [b + bd for b, bd in zip(betti, boundaries)]

fig, ax = plt.subplots(figsize=(10, 6))
x = np.arange(len(names))
width = 0.6

ax.bar(x, boundaries, width, label='dim(B₁) — boundaries', color='#FF9800', edgecolor='black')
ax.bar(x, betti, width, bottom=boundaries, label='β₁ — logical qubits', color='#4CAF50', edgecolor='black')

for i in range(len(names)):
    ax.text(i, cycles[i] + 0.3, f'Z₁={cycles[i]}', ha='center', fontsize=10)
    if betti[i] > 0:
        ax.text(i, boundaries[i] + betti[i]/2, f'k={betti[i]}', ha='center', va='center', fontweight='bold', color='white', fontsize=11)

ax.set_xticks(x)
ax.set_xticklabels(names)
ax.set_ylabel('Dimension')
ax.set_title('CSS Dimension Formula: β₁ + dim(B₁) = dim(Z₁)')
ax.legend(loc='upper left')

plt.tight_layout()
plt.savefig('css_dimension_decomposition.png', dpi=150, bbox_inches='tight')
print('Saved css_dimension_decomposition.png')