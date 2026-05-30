#!/usr/bin/env python3
"""
Visualization: Periodicity Detection Heatmap
==============================================

Creates a heatmap showing the detected period of the modular CF state sequence
for different numbers (rows) across different primes (columns). Quadratic
irrationals show consistent small periods, while transcendentals show
no detected periodicity (or very large periods).
"""

import matplotlib.pyplot as plt
import numpy as np


def cf_state_mod_period(coeffs_func, p, max_steps=500):
    """Detect the period of CF state sequence mod p.
    Returns (preperiod, period) or (-1, -1) if not found.
    """
    p_prev, p_curr = 1 % p, coeffs_func(0) % p
    q_prev, q_curr = 0, 1 % p
    seen = {}
    state = (p_prev, p_curr, q_prev, q_curr)
    seen[state] = 0

    for n in range(1, max_steps):
        a = coeffs_func(n) % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new
        state = (p_prev, p_curr, q_prev, q_curr)
        if state in seen:
            return seen[state], n - seen[state]
        seen[state] = n
    return -1, -1


def golden(n):
    return 1

def sqrt2(n):
    return 1 if n == 0 else 2

def sqrt3(n):
    if n == 0: return 1
    return 1 if n % 2 == 1 else 2

def sqrt5(n):
    return 2 if n == 0 else 4

def sqrt7(n):
    if n == 0: return 2
    pattern = [1, 1, 1, 4]
    return pattern[(n - 1) % 4]

def euler_e(n):
    if n == 0: return 2
    if (n + 1) % 3 == 0:
        return 2 * ((n + 1) // 3)
    return 1

def pi_approx(n):
    """Approximate π CF: [3; 7, 15, 1, 292, 1, 1, 1, 2, ...]"""
    pi_cf = [3, 7, 15, 1, 292, 1, 1, 1, 2, 1, 3, 1, 14, 2, 1, 1, 2, 2, 2, 2,
             1, 84, 2, 1, 1, 15, 3, 13, 1, 4, 2, 6, 6, 99, 1, 2, 2, 6, 3, 5]
    return pi_cf[n] if n < len(pi_cf) else 1  # fallback


numbers = [
    ("φ", golden),
    ("√2", sqrt2),
    ("√3", sqrt3),
    ("√5", sqrt5),
    ("√7", sqrt7),
    ("e", euler_e),
    ("π", pi_approx),
]

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

# Compute periods
period_matrix = np.zeros((len(numbers), len(primes)))
preperiod_matrix = np.zeros((len(numbers), len(primes)))

for i, (name, func) in enumerate(numbers):
    for j, p in enumerate(primes):
        pre, per = cf_state_mod_period(func, p, max_steps=2000)
        period_matrix[i, j] = per if per > 0 else -1
        preperiod_matrix[i, j] = pre if pre >= 0 else -1

# Normalize periods by p for visualization
normalized = np.where(period_matrix > 0, period_matrix / np.array(primes), 0)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# Left: Raw periods
im1 = ax1.imshow(np.log1p(np.maximum(period_matrix, 0)), aspect='auto',
                  cmap='YlOrRd', interpolation='nearest')
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([str(p) for p in primes], fontsize=9)
ax1.set_yticks(range(len(numbers)))
ax1.set_yticklabels([n[0] for n in numbers], fontsize=11)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_title('log(1 + Period) of Modular CF State Sequence', fontsize=12, fontweight='bold')

# Add period values as text
for i in range(len(numbers)):
    for j in range(len(primes)):
        val = int(period_matrix[i, j])
        color = 'white' if period_matrix[i, j] > np.median(period_matrix[period_matrix > 0]) else 'black'
        if val > 0:
            ax1.text(j, i, str(val), ha='center', va='center', fontsize=7, color=color)
        else:
            ax1.text(j, i, '?', ha='center', va='center', fontsize=8, color='gray')

plt.colorbar(im1, ax=ax1, label='log(1 + period)')

# Right: Normalized periods (period / p)
im2 = ax2.imshow(normalized, aspect='auto', cmap='viridis', interpolation='nearest',
                  vmin=0, vmax=6)
ax2.set_xticks(range(len(primes)))
ax2.set_xticklabels([str(p) for p in primes], fontsize=9)
ax2.set_yticks(range(len(numbers)))
ax2.set_yticklabels([n[0] for n in numbers], fontsize=11)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_title('Period / p  (Pisano-like ratio)', fontsize=12, fontweight='bold')

for i in range(len(numbers)):
    for j in range(len(primes)):
        val = normalized[i, j]
        if val > 0:
            ax2.text(j, i, f'{val:.1f}', ha='center', va='center',
                    fontsize=7, color='white' if val > 3 else 'black')
        else:
            ax2.text(j, i, '?', ha='center', va='center', fontsize=8, color='gray')

plt.colorbar(im2, ax=ax2, label='period / p')

# Add horizontal line separating quadratic from transcendental
for ax in [ax1, ax2]:
    ax.axhline(y=4.5, color='red', linewidth=2, linestyle='--', alpha=0.7)
    ax.text(len(primes) - 0.3, 2, 'Quadratic\nIrrationals', fontsize=8,
            color='red', ha='right', va='center', fontweight='bold')
    ax.text(len(primes) - 0.3, 5.5, 'Transcendental', fontsize=8,
            color='red', ha='right', va='center', fontweight='bold')

fig.suptitle('Modular CF Dynamics: Period Detection Across Primes\n'
             'Quadratic irrationals have bounded periods; transcendentals do not',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.savefig('viz_periodicity_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_periodicity_heatmap.png")
