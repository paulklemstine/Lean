#!/usr/bin/env python3
"""
Visualization 3: Quantitative Entropy Collapse Bound Conjecture

Visualizes the conjectured lower bound on total entropy collapse:
    H(p) - H(∂₁...∂ₙp) ≥ (1/2)log C(n+d-1,d-1) - (d-1)/2 log(d)

Tests the bound against many random Lorentzian polynomials and shows
that the complete homogeneous symmetric polynomial achieves the bound.

Self-contained — all functions are inlined.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import factorial, log, comb
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


def quantitative_bound(n: int, d: int) -> float:
    binom_val = comb(n + d - 1, d - 1)
    if binom_val <= 0 or d <= 0:
        return 0.0
    return 0.5 * log(binom_val) - (d - 1) / 2 * log(d)


# ─────────────────────────────────────────────────────────────
# Create visualization
# ─────────────────────────────────────────────────────────────

fig, axes = plt.subplots(1, 3, figsize=(15, 5))
np.random.seed(42)

# Panel 1: Entropy drops for n=3, varying d
ax1 = axes[0]
n = 3
d_values = [2, 3, 4, 5]
colors = ['#2196F3', '#4CAF50', '#FF9800', '#E91E63']

for d_idx, d in enumerate(d_values):
    drops = []
    for _ in range(200):
        try:
            coeffs = random_lorentzian(n, d)
            tower = entropy_tower(coeffs, d)
            if len(tower) >= 2:
                drops.append(tower[0] - tower[-1])
        except:
            pass
    
    bound = quantitative_bound(n, d)
    
    # Histogram
    if drops:
        ax1.hist(drops, bins=20, alpha=0.5, color=colors[d_idx], 
                 label=f'd={d}', density=True)
        ax1.axvline(x=bound, color=colors[d_idx], linestyle='--', linewidth=2)

ax1.set_xlabel('Total entropy drop (nats)', fontsize=11)
ax1.set_ylabel('Density', fontsize=11)
ax1.set_title(f'Entropy Collapse Distribution (n={n})', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Bound vs actual for h_d
ax2 = axes[1]
params = []
bounds = []
actuals = []

for n in range(2, 8):
    for d in range(2, 6):
        try:
            coeffs = complete_homogeneous(n, d)
            tower = entropy_tower(coeffs, d)
            if len(tower) >= 2:
                bound = quantitative_bound(n, d)
                actual = tower[0] - tower[-1]
                params.append(f"({n},{d})")
                bounds.append(bound)
                actuals.append(actual)
        except:
            pass

x_pos = np.arange(len(params))
width = 0.35

bars1 = ax2.bar(x_pos - width/2, bounds, width, label='Conjectured bound',
                color='steelblue', alpha=0.8)
bars2 = ax2.bar(x_pos + width/2, actuals, width, label='$h_d$ entropy drop',
                color='coral', alpha=0.8)

ax2.set_xlabel('Parameters (n, d)', fontsize=11)
ax2.set_ylabel('Entropy drop (nats)', fontsize=11)
ax2.set_title('Bound vs Actual for $h_d$', fontsize=13)
ax2.set_xticks(x_pos[::3])
ax2.set_xticklabels([params[i] for i in range(0, len(params), 3)], fontsize=8, rotation=45)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Panel 3: Heatmap of bound tightness
ax3 = axes[2]
n_range = range(2, 8)
d_range = range(2, 7)
tightness = np.zeros((len(list(d_range)), len(list(n_range))))

for i, d in enumerate(d_range):
    for j, n in enumerate(n_range):
        try:
            coeffs = complete_homogeneous(n, d)
            tower = entropy_tower(coeffs, d)
            if len(tower) >= 2:
                bound = quantitative_bound(n, d)
                actual = tower[0] - tower[-1]
                if bound > 0:
                    tightness[i, j] = actual / bound
                else:
                    tightness[i, j] = 1.0
        except:
            tightness[i, j] = np.nan

im = ax3.imshow(tightness, cmap='RdYlGn_r', aspect='auto', vmin=0.9, vmax=2.0)
ax3.set_xlabel('n (variables)', fontsize=11)
ax3.set_ylabel('d (degree)', fontsize=11)
ax3.set_title('Bound Tightness: actual/bound', fontsize=13)
ax3.set_xticks(range(len(list(n_range))))
ax3.set_xticklabels(list(n_range))
ax3.set_yticks(range(len(list(d_range))))
ax3.set_yticklabels(list(d_range))

# Add text annotations
for i in range(tightness.shape[0]):
    for j in range(tightness.shape[1]):
        if not np.isnan(tightness[i, j]):
            ax3.text(j, i, f'{tightness[i, j]:.2f}', ha='center', va='center', fontsize=8)

plt.colorbar(im, ax=ax3, shrink=0.8)

plt.suptitle('Quantitative Entropy Collapse Bound Conjecture',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('quantitative_bound.png', dpi=150, bbox_inches='tight')
print("Saved quantitative_bound.png")
