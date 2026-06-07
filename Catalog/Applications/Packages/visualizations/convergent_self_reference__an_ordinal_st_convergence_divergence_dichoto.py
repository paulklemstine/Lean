import matplotlib.pyplot as plt
import numpy as np

def iterate(f, x0, steps):
    vals = [x0]
    x = x0
    for _ in range(steps):
        x = f(x)
        vals.append(x)
    return vals

fns = {
    'const False': lambda b: 0,
    'identity': lambda b: b,
    'NOT (liar)': lambda b: 1-b,
    'const True': lambda b: 1,
}

fig, axes = plt.subplots(2, 2, figsize=(12, 8))
for ax, (name, f) in zip(axes.flat, fns.items()):
    vals = iterate(f, 0, 15)
    ax.step(range(len(vals)), vals, where='mid', linewidth=2, color='#2196F3' if vals[-1]==vals[-2] else '#F44336')
    ax.set_ylim(-0.1, 1.1)
    ax.set_title(name, fontsize=13)
    ax.set_xlabel('Step')
    ax.set_ylabel('Value')
    ax.set_yticks([0, 1])
    ax.set_yticklabels(['False', 'True'])
    status = 'CONVERGES' if vals[-1]==vals[-2] else 'DIVERGES'
    ax.text(0.95, 0.5, status, transform=ax.transAxes, ha='right', fontsize=11, fontweight='bold', color='green' if 'CONV' in status else 'red')

plt.suptitle('Bool Convergence-Divergence Dichotomy', fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('bool_dichotomy.png', dpi=150)
plt.show()
