"""
Visualization: Mixing Convergence for Expander Walks
=====================================================
Shows how random walks on Cayley graphs of symplectic groups converge
to the uniform distribution. The exponential decay rate is controlled
by the spectral gap, which is the central quantity in our certificate
framework.
"""

import numpy as np
import matplotlib.pyplot as plt

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Mixing decay for different gaps
ax = axes[0]
steps = np.arange(0, 30)
gap_values = [0.1, 0.2, 0.3, 0.5, 0.7, 0.9]
colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(gap_values)))

for gap, color in zip(gap_values, colors):
    mixing = (1.0 - gap) ** steps
    ax.semilogy(steps, mixing, color=color, linewidth=2, label=f'ε = {gap}')

ax.axhline(y=0.01, color='red', linestyle='--', alpha=0.5, label='target = 0.01')
ax.set_xlabel('Steps t', fontsize=12)
ax.set_ylabel('Mixing bound (1-ε)^t', fontsize=12)
ax.set_title('Exponential Mixing Decay', fontsize=14)
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-5, 2)

# Panel 2: TV distance bounds for specific groups
ax2 = axes[1]
groups = [
    ("Sp₂(𝔽₇)", 1, 7),
    ("Sp₄(𝔽₁₁)", 2, 11),
    ("Sp₆(𝔽₁₃)", 3, 13),
    ("Sp₈(𝔽₉₇)", 4, 97),
]
colors2 = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']

for (name, n, q), color in zip(groups, colors2):
    gap = 1.0 - (n + 1) / q
    n_vertices = q ** 3  # simplified
    tv = [np.sqrt(n_vertices) * (1.0 - gap) ** t for t in steps]
    ax2.semilogy(steps, tv, color=color, linewidth=2, label=name)

ax2.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax2.set_xlabel('Steps t', fontsize=12)
ax2.set_ylabel('TV distance bound', fontsize=12)
ax2.set_title('Total Variation Distance Decay', fontsize=14)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# Panel 3: Mixing time vs rank
ax3 = axes[2]
import math

q_values = [7, 11, 13, 31, 97]
colors3 = plt.cm.Set1(np.linspace(0, 0.8, len(q_values)))

for q, color in zip(q_values, colors3):
    ranks_range = range(1, min(q - 1, 15))
    mix_times = []
    for n in ranks_range:
        gap = 1.0 - (n + 1) / q
        if gap > 0:
            t_mix = math.ceil(math.log(0.01) / math.log(1.0 - gap))
            mix_times.append(t_mix)
        else:
            mix_times.append(None)
    
    valid_ranks = [r for r, t in zip(ranks_range, mix_times) if t is not None]
    valid_times = [t for t in mix_times if t is not None]
    ax3.plot(valid_ranks, valid_times, 'o-', color=color, linewidth=2, 
             markersize=5, label=f'q = {q}')

ax3.set_xlabel('Rank n', fontsize=12)
ax3.set_ylabel('Mixing time (steps)', fontsize=12)
ax3.set_title('Mixing Time vs Rank', fontsize=14)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved: mixing_convergence.png")
