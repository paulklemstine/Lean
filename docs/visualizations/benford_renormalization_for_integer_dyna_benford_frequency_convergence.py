#!/usr/bin/env python3
"""
Visualization 1: Benford Frequency Convergence

Shows how empirical leading-digit frequencies converge to Benford's law
predictions as the orbit length increases, for different dynamical maps.
Illustrates the frequency partition of unity theorem and the telescoping
sum of theoretical frequencies.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def leading_digit(n, base=10):
    if base <= 1 or n <= 0:
        return 0
    while n >= base:
        n //= base
    return n


def benford_theoretical(base, digit):
    return math.log(1 + 1/digit) / math.log(base)


def compute_freq_evolution(sequence, base=10, checkpoints=None):
    """Compute empirical frequencies at various sequence lengths."""
    if checkpoints is None:
        checkpoints = [10, 50, 100, 500, 1000, 2000, 5000]
    
    results = {}
    for cp in checkpoints:
        if cp > len(sequence):
            break
        subseq = sequence[:cp]
        freqs = {}
        for d in range(1, base):
            count = sum(1 for x in subseq if leading_digit(x, base) == d)
            freqs[d] = count / cp
        results[cp] = freqs
    return results


# Generate sequences
base = 10
N = 5000

# 2^k sequence (Benford, irrational log_10(2))
seq_2k = [2**k for k in range(1, N + 1)]

# 3^k sequence (Benford, irrational log_10(3))
seq_3k = [3**k for k in range(1, N + 1)]

# 10^k sequence (NOT Benford, rational obstruction)
seq_10k = [10**k for k in range(1, N + 1)]

checkpoints = [10, 25, 50, 100, 200, 500, 1000, 2000, 5000]

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# --- Panel 1: 2^k convergence ---
ax = axes[0, 0]
evo = compute_freq_evolution(seq_2k, base, checkpoints)
for d in range(1, base):
    y_vals = [evo[cp][d] for cp in checkpoints if cp in evo]
    x_vals = [cp for cp in checkpoints if cp in evo]
    ax.plot(x_vals, y_vals, 'o-', markersize=4, label=f'd={d}', alpha=0.8)
    ax.axhline(y=benford_theoretical(base, d), color='gray', alpha=0.3, linestyle='--')

ax.set_xlabel('Orbit Length N')
ax.set_ylabel('Frequency')
ax.set_title('$2^k$: Convergence to Benford (irrational $\\log_{10} 2$)')
ax.set_xscale('log')
ax.legend(ncol=3, fontsize=7)
ax.grid(True, alpha=0.3)

# --- Panel 2: 10^k non-convergence ---
ax = axes[0, 1]
evo10 = compute_freq_evolution(seq_10k, base, checkpoints)
for d in range(1, base):
    y_vals = [evo10[cp][d] for cp in checkpoints if cp in evo10]
    x_vals = [cp for cp in checkpoints if cp in evo10]
    ax.plot(x_vals, y_vals, 'o-', markersize=4, label=f'd={d}', alpha=0.8)
    ax.axhline(y=benford_theoretical(base, d), color='gray', alpha=0.3, linestyle='--')

ax.set_xlabel('Orbit Length N')
ax.set_ylabel('Frequency')
ax.set_title('$10^k$: Rational Obstruction (digit always 1)')
ax.set_xscale('log')
ax.legend(ncol=3, fontsize=7)
ax.grid(True, alpha=0.3)

# --- Panel 3: Theoretical vs Empirical (bar chart, 2^k) ---
ax = axes[1, 0]
digits = list(range(1, base))
empirical = [evo[5000][d] for d in digits]
theoretical = [benford_theoretical(base, d) for d in digits]

x = np.arange(len(digits))
width = 0.35
bars1 = ax.bar(x - width/2, empirical, width, label='Empirical ($2^k$, N=5000)', color='steelblue')
bars2 = ax.bar(x + width/2, theoretical, width, label='Benford Prediction', color='coral')
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Frequency')
ax.set_title('Frequency Partition of Unity: Empirical vs Theory')
ax.set_xticks(x)
ax.set_xticklabels(digits)
ax.legend()
ax.grid(True, alpha=0.3, axis='y')

# Annotate sum = 1
ax.text(0.95, 0.95, f'∑ empirical = {sum(empirical):.4f}\n∑ theory = {sum(theoretical):.4f}',
        transform=ax.transAxes, ha='right', va='top', fontsize=9,
        bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

# --- Panel 4: Telescoping sum visualization ---
ax = axes[1, 1]
cumulative = [0]
for d in range(1, base):
    cumulative.append(cumulative[-1] + benford_theoretical(base, d))

for d in range(1, base):
    ax.barh(0, benford_theoretical(base, d), left=cumulative[d-1], 
            height=0.5, label=f'd={d}', alpha=0.8)

# Show telescoping structure
y_tel = -0.8
for d in range(1, base + 1):
    log_val = math.log(d) / math.log(base)
    ax.plot(log_val, y_tel, 'k^', markersize=8)
    ax.annotate(f'$\\log_{{10}}({d})$', (log_val, y_tel - 0.15), 
                ha='center', fontsize=7, rotation=45)

ax.set_xlim(-0.05, 1.05)
ax.set_ylim(-1.5, 1)
ax.set_xlabel('Cumulative Frequency')
ax.set_title('Telescoping: $\\sum \\log_b(1+1/d) = 1$')
ax.legend(ncol=3, fontsize=7, loc='upper left')
ax.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='Sum = 1')
ax.set_yticks([])
ax.grid(True, alpha=0.3, axis='x')

plt.suptitle('Benford Renormalization: Frequency Analysis', fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_benford_frequencies.png', dpi=150, bbox_inches='tight')
print("Saved viz_benford_frequencies.png")
