"""
Visualization: Benford Digit Frequency Comparison

Compares empirical leading-digit frequencies of several integer sequences
against the Benford prediction log_10(1 + 1/d). Demonstrates the dichotomy:
sequences with irrational logarithmic growth follow Benford's law,
while those with rational structure (powers of the base) deviate maximally.
"""

import math
import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def leading_digit(n, base=10):
    if n <= 0 or base <= 1:
        return 0
    while n >= base:
        n //= base
    return n


def digit_freqs(data, base=10):
    N = sum(1 for x in data if x >= 1)
    if N == 0:
        return {d: 0 for d in range(1, base)}
    counts = Counter(leading_digit(x, base) for x in data if x >= 1)
    return {d: counts.get(d, 0) / N for d in range(1, base)}


# Generate sequences
powers_of_2 = [2**k for k in range(1, 2001)]
powers_of_3 = [3**k for k in range(1, 1001)]
powers_of_10 = [10**k for k in range(1, 201)]

# Fibonacci
fib = [1, 1]
for _ in range(2000):
    fib.append(fib[-1] + fib[-2])
fibonacci = fib[2:]

# Factorials
facts = [1]
for k in range(1, 501):
    facts.append(facts[-1] * k)
factorials = facts[1:]

sequences = {
    'Powers of 2': powers_of_2,
    'Powers of 3': powers_of_3,
    'Fibonacci': fibonacci,
    'Factorials': factorials,
    'Powers of 10\n(obstructed)': powers_of_10,
}

digits = list(range(1, 10))
benford = [math.log10(1 + 1/d) for d in digits]

fig, axes = plt.subplots(2, 3, figsize=(14, 9))
axes = axes.flatten()

# Plot Benford prediction
ax = axes[0]
ax.bar(digits, benford, color='#2c3e50', alpha=0.9, edgecolor='white')
ax.set_title("Benford's Law\n(Predicted)", fontsize=11, fontweight='bold')
ax.set_xlabel('Leading Digit')
ax.set_ylabel('Frequency')
ax.set_ylim(0, 0.35)
ax.set_xticks(digits)

# Plot each sequence
colors = ['#27ae60', '#2980b9', '#8e44ad', '#e67e22', '#c0392b']
for i, (name, seq) in enumerate(sequences.items()):
    ax = axes[i + 1]
    freqs = digit_freqs(seq)
    emp = [freqs.get(d, 0) for d in digits]

    x = np.array(digits)
    width = 0.35
    ax.bar(x - width/2, emp, width, label='Empirical',
           color=colors[i], alpha=0.8, edgecolor='white')
    ax.bar(x + width/2, benford, width, label='Benford',
           color='#95a5a6', alpha=0.6, edgecolor='white')
    ax.set_title(name, fontsize=11, fontweight='bold')
    ax.set_xlabel('Leading Digit')
    ax.set_ylim(0, max(max(emp), 0.35) * 1.1)
    ax.set_xticks(digits)
    if i == 0:
        ax.legend(fontsize=8)

fig.suptitle('Benford Renormalization: Digit Frequency Dichotomy',
             fontsize=14, fontweight='bold', y=0.98)
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('viz_digit_frequencies.png', dpi=150, bbox_inches='tight')
print("Saved viz_digit_frequencies.png")
