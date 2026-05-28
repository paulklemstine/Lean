"""
Visualization: Compression Convergence on the Integer Simplex

Animates the (i,j)-compression process on a degree-3 family in 3 variables,
showing how the family migrates toward the lex-initial segment. Plots energy
decrease and shadow evolution.

CRITICAL: Fully self-contained. No local imports.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import Set, Tuple, List


def degree_slice(n: int, d: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in degree_slice(n - 1, d - k):
            result.append((k,) + rest)
    return result


def shadow(family: Set[Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    result = set()
    for alpha in family:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                result.add(tuple(beta))
    return result


def shift(i: int, j: int, alpha: Tuple[int, ...]) -> Tuple[int, ...]:
    if i == j or alpha[j] == 0:
        return alpha
    beta = list(alpha)
    beta[i] += 1
    beta[j] -= 1
    return tuple(beta)


def compress(i: int, j: int, family: Set[Tuple[int, ...]]) -> Set[Tuple[int, ...]]:
    result = set()
    for alpha in family:
        shifted = shift(i, j, alpha)
        if shifted in family:
            result.add(alpha)
        else:
            result.add(shifted)
    return result


def energy(family: Set[Tuple[int, ...]]) -> int:
    return sum(sum(k * alpha[k] for k in range(len(alpha))) for alpha in family)


# Run compression on a specific example
n, d = 3, 4
slc = degree_slice(n, d)

# Start with a "spread" family
start_family = {(1, 1, 2), (0, 2, 2), (1, 2, 1), (0, 3, 1), (1, 0, 3)}

# Record compression history
history = [set(start_family)]
energies = [energy(start_family)]
shadow_sizes = [len(shadow(start_family))]
labels = ["Start"]

current = set(start_family)
step = 0
max_steps = 50
while step < max_steps:
    changed = False
    for i in range(n):
        for j in range(i + 1, n):
            G = compress(i, j, current)
            if G != current:
                current = G
                step += 1
                history.append(set(current))
                energies.append(energy(current))
                shadow_sizes.append(len(shadow(current)))
                labels.append(f"C({i},{j})")
                changed = True
    if not changed:
        break

# Create figure
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Energy over time
ax = axes[0, 0]
ax.plot(range(len(energies)), energies, 'b-o', markersize=4)
ax.set_xlabel('Compression step')
ax.set_ylabel('Energy Σ k·αₖ')
ax.set_title('Energy Decrease Under Compression')
ax.grid(True, alpha=0.3)
for i, label in enumerate(labels):
    if i % max(1, len(labels) // 6) == 0 or i == len(labels) - 1:
        ax.annotate(label, (i, energies[i]), fontsize=7, ha='center', va='bottom')

# Plot 2: Shadow size over time
ax = axes[0, 1]
ax.plot(range(len(shadow_sizes)), shadow_sizes, 'r-o', markersize=4)
ax.set_xlabel('Compression step')
ax.set_ylabel('Shadow size |∂F|')
ax.set_title('Shadow Evolution Under Compression')
ax.grid(True, alpha=0.3)

# Plot 3: Initial family on simplex (barycentric coords)
ax = axes[1, 0]
# Project to 2D using barycentric coordinates for n=3
def bary_to_xy(alpha):
    """Convert multi-index to 2D point using barycentric coordinates."""
    x = alpha[1] + 0.5 * alpha[2]
    y = alpha[2] * np.sqrt(3) / 2
    return x / d, y / d

# Draw simplex outline
corners = np.array([[0, 0], [1, 0], [0.5, np.sqrt(3)/2], [0, 0]])
ax.plot(corners[:, 0], corners[:, 1], 'k-', linewidth=1.5)

# Draw all lattice points
for alpha in slc:
    x, y = bary_to_xy(alpha)
    ax.plot(x, y, 'o', color='lightgray', markersize=8, zorder=1)

# Highlight initial family
for alpha in history[0]:
    x, y = bary_to_xy(alpha)
    ax.plot(x, y, 'o', color='blue', markersize=12, zorder=2)
    ax.annotate(str(alpha), (x, y), fontsize=6, ha='center', va='bottom',
                xytext=(0, 5), textcoords='offset points')

ax.set_title(f'Initial Family (d={d})\nBlue = family elements')
ax.set_aspect('equal')
ax.axis('off')

# Plot 4: Final compressed family
ax = axes[1, 1]
ax.plot(corners[:, 0], corners[:, 1], 'k-', linewidth=1.5)

for alpha in slc:
    x, y = bary_to_xy(alpha)
    ax.plot(x, y, 'o', color='lightgray', markersize=8, zorder=1)

# Highlight final family
for alpha in history[-1]:
    x, y = bary_to_xy(alpha)
    ax.plot(x, y, 'o', color='red', markersize=12, zorder=2)
    ax.annotate(str(alpha), (x, y), fontsize=6, ha='center', va='bottom',
                xytext=(0, 5), textcoords='offset points')

# Also show lex-initial segment
lex_seg = set(sorted(slc)[:len(history[-1])])
for alpha in lex_seg:
    x, y = bary_to_xy(alpha)
    ax.plot(x, y, 's', color='green', markersize=14, zorder=0, alpha=0.3)

ax.set_title(f'Final Compressed Family (d={d})\nRed = compressed, Green □ = lex-initial')
ax.set_aspect('equal')
ax.axis('off')

plt.suptitle('Multi-Index Compression Convergence', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_compression.png', dpi=150, bbox_inches='tight')
print("Saved viz_compression.png")
