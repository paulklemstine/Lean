"""
Visualization 1: Subword Complexity Growth Curves

Visualizes the subword complexity function p(n) for different types of sequences:
- Constant (p(n) = 1)
- Periodic (p(n) ≤ period)
- Thue-Morse (automatic, linear growth)
- Random (exponential growth)

This illustrates the Morse-Hedlund theorem: non-periodic sequences have p(n) ≥ n+1.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter

def thue_morse(n):
    return bin(n).count('1') % 2

def rudin_shapiro(n):
    bits = bin(n)[2:]
    pairs = sum(1 for i in range(len(bits)-1) if bits[i]=='1' and bits[i+1]=='1')
    return pairs % 2

def subword_complexity(seq, n):
    N = len(seq) - n + 1
    if N <= 0:
        return 0
    return len(set(tuple(seq[i:i+n]) for i in range(N)))

# Generate sequences
N = 2048
tm = [thue_morse(n) for n in range(N)]
rs = [rudin_shapiro(n) for n in range(N)]
const = [0] * N
periodic = [n % 3 for n in range(N)]
np.random.seed(42)
random_seq = list(np.random.randint(0, 2, N))

# Compute complexities
max_n = 20
ns = list(range(1, max_n + 1))

complexities = {
    'Constant (p=1)': [subword_complexity(const, n) for n in ns],
    'Period-3': [subword_complexity(periodic, n) for n in ns],
    'Thue-Morse': [subword_complexity(tm, n) for n in ns],
    'Rudin-Shapiro': [subword_complexity(rs, n) for n in ns],
    'Random binary': [subword_complexity(random_seq, n) for n in ns],
}

# Create the plot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Linear scale
colors = ['#2ecc71', '#3498db', '#e74c3c', '#9b59b6', '#f39c12']
for (name, vals), color in zip(complexities.items(), colors):
    ax1.plot(ns, vals, 'o-', label=name, color=color, markersize=4, linewidth=2)

# Add Morse-Hedlund bound
ax1.plot(ns, [n + 1 for n in ns], 'k--', alpha=0.5, linewidth=1,
         label='Morse-Hedlund bound (n+1)')
ax1.plot(ns, [2**n for n in ns], 'k:', alpha=0.3, linewidth=1,
         label='Maximum (2^n)')

ax1.set_xlabel('Subword length n', fontsize=12)
ax1.set_ylabel('Complexity p(n)', fontsize=12)
ax1.set_title('Subword Complexity (Linear Scale)', fontsize=14)
ax1.legend(fontsize=9, loc='upper left')
ax1.set_ylim(0, 100)
ax1.grid(True, alpha=0.3)

# Right: Log scale
for (name, vals), color in zip(complexities.items(), colors):
    ax2.semilogy(ns, vals, 'o-', label=name, color=color, markersize=4, linewidth=2)

ax2.semilogy(ns, [n + 1 for n in ns], 'k--', alpha=0.5, linewidth=1,
             label='n+1')
ax2.semilogy(ns, [2**n for n in ns], 'k:', alpha=0.3, linewidth=1,
             label='2^n')

ax2.set_xlabel('Subword length n', fontsize=12)
ax2.set_ylabel('Complexity p(n) [log scale]', fontsize=12)
ax2.set_title('Subword Complexity (Log Scale)', fontsize=14)
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3, which='both')

fig.suptitle('The Complexity Hierarchy of Sequences',
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig('viz_complexity.png', dpi=150, bbox_inches='tight')
print("Saved viz_complexity.png")
