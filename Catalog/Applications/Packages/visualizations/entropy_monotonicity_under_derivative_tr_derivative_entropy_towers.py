#!/usr/bin/env python3
"""
Visualization 1: Derivative Entropy Tower

Visualizes the monotonically decreasing entropy tower for several
polynomial families, showing how differentiation progressively
compresses the information content of coefficient distributions.

Self-contained — all functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log
from typing import Dict, Tuple, List


def generate_multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in generate_multi_indices(n - 1, d - k):
            result.append((k,) + rest)
    return result


def shannon_entropy(c: np.ndarray) -> float:
    total = np.sum(c)
    if total <= 0:
        return 0.0
    p = c / total
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


def derivative_transport(coeffs: Dict[Tuple[int, ...], float], var: int) -> Dict[Tuple[int, ...], float]:
    new_coeffs: Dict[Tuple[int, ...], float] = {}
    for alpha, c in coeffs.items():
        if alpha[var] > 0:
            beta = list(alpha)
            beta[var] -= 1
            bt = tuple(beta)
            new_coeffs[bt] = new_coeffs.get(bt, 0.0) + alpha[var] * c
    return new_coeffs


def entropy_tower(coeffs: Dict[Tuple[int, ...], float], d: int, var: int = 0) -> List[float]:
    tower = []
    current = coeffs.copy()
    for k in range(d + 1):
        vals = np.array(list(current.values()))
        if np.sum(vals) <= 0:
            break
        tower.append(shannon_entropy(vals))
        if k < d:
            current = derivative_transport(current, var)
            if not current:
                break
    return tower


def complete_homogeneous(n: int, d: int) -> Dict[Tuple[int, ...], float]:
    indices = generate_multi_indices(n, d)
    coeffs = {}
    for alpha in indices:
        c = factorial(d)
        for a in alpha:
            c //= factorial(a)
        coeffs[alpha] = float(c)
    return coeffs


def random_lorentzian(n: int, d: int) -> Dict[Tuple[int, ...], float]:
    coeffs: Dict[Tuple[int, ...], float] = {(0,) * n: 1.0}
    for _ in range(d):
        linear = np.random.exponential(1.0, n)
        new_c: Dict[Tuple[int, ...], float] = {}
        for alpha, c in coeffs.items():
            for i in range(n):
                beta = list(alpha)
                beta[i] += 1
                bt = tuple(beta)
                new_c[bt] = new_c.get(bt, 0.0) + c * linear[i]
        coeffs = new_c
    return coeffs


# ─────────────────────────────────────────────────────────────
# Create visualization
# ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Entropy towers for (x₁+...+xₙ)^d with varying n
ax1 = axes[0]
d = 5
colors = plt.cm.viridis(np.linspace(0.2, 0.9, 5))
for idx, n in enumerate([2, 3, 4, 5, 6]):
    coeffs = complete_homogeneous(n, d)
    tower = entropy_tower(coeffs, d)
    levels = list(range(len(tower)))
    ax1.plot(levels, tower, 'o-', color=colors[idx], label=f'n={n}', 
             markersize=8, linewidth=2)

ax1.set_xlabel('Derivative Level k', fontsize=12)
ax1.set_ylabel('Shannon Entropy H (nats)', fontsize=12)
ax1.set_title(f'Entropy Towers: $(x_1+\\cdots+x_n)^{d}$', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Entropy towers for fixed n, varying d
ax2 = axes[1]
n = 3
colors2 = plt.cm.plasma(np.linspace(0.2, 0.9, 5))
for idx, d in enumerate([2, 3, 4, 5, 6]):
    coeffs = complete_homogeneous(n, d)
    tower = entropy_tower(coeffs, d)
    levels = list(range(len(tower)))
    ax2.plot(levels, tower, 's-', color=colors2[idx], label=f'd={d}',
             markersize=8, linewidth=2)

ax2.set_xlabel('Derivative Level k', fontsize=12)
ax2.set_ylabel('Shannon Entropy H (nats)', fontsize=12)
ax2.set_title(f'Entropy Towers: $(x+y+z)^d$', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Random Lorentzian polynomials
ax3 = axes[2]
np.random.seed(42)
n, d = 3, 5
colors3 = plt.cm.Set2(np.linspace(0, 1, 8))
for trial in range(6):
    coeffs = random_lorentzian(n, d)
    tower = entropy_tower(coeffs, d)
    levels = list(range(len(tower)))
    ax3.plot(levels, tower, 'D-', color=colors3[trial], alpha=0.7,
             markersize=6, linewidth=1.5, label=f'Random {trial+1}')

# Add the symmetric one for reference
coeffs = complete_homogeneous(n, d)
tower = entropy_tower(coeffs, d)
levels = list(range(len(tower)))
ax3.plot(levels, tower, 'o-', color='black', markersize=8, linewidth=2.5,
         label='$(x+y+z)^5$', zorder=10)

ax3.set_xlabel('Derivative Level k', fontsize=12)
ax3.set_ylabel('Shannon Entropy H (nats)', fontsize=12)
ax3.set_title('Random Lorentzian Polynomials', fontsize=13)
ax3.legend(fontsize=8, ncol=2)
ax3.grid(True, alpha=0.3)

plt.suptitle('Derivative Entropy Towers: Differentiation Compresses Information',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('entropy_towers.png', dpi=150, bbox_inches='tight')
print("Saved entropy_towers.png")
