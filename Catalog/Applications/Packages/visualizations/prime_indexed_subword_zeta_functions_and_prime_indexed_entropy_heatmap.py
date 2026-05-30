"""
Visualization 2: Prime-Indexed Subword Entropy Heatmap

Creates a heatmap showing the subword entropy H(p) at prime-indexed lengths
for different automatic sequences. The pattern of entropies serves as a
"spectral fingerprint" distinguishing sequences — the central object of
the Prime Subword Rigidity Conjecture.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter
from math import log, sqrt

def thue_morse(n):
    return bin(n).count('1') % 2

def rudin_shapiro(n):
    bits = bin(n)[2:]
    pairs = sum(1 for i in range(len(bits)-1) if bits[i]=='1' and bits[i+1]=='1')
    return pairs % 2

def period_doubling(n):
    if n == 0:
        return 0
    m = n
    k = 0
    while m % 2 == 0:
        m //= 2
        k += 1
    return k % 2

def sieve_primes(limit):
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(sqrt(limit)) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(limit + 1) if is_prime[i]]

def subword_entropy(seq, length):
    N = len(seq) - length + 1
    if N <= 0:
        return 0.0
    counts = Counter(tuple(seq[i:i+length]) for i in range(N))
    total = sum(counts.values())
    return -sum((c/total) * log(c/total) for c in counts.values() if c > 0)

# Generate sequences
N = 2000
sequences = {
    'Thue-Morse': [thue_morse(n) for n in range(N)],
    'TM shift+1': [thue_morse(n+1) for n in range(N)],
    'TM shift+5': [thue_morse(n+5) for n in range(N)],
    'Rudin-Shapiro': [rudin_shapiro(n) for n in range(N)],
    'Period-Doubling': [period_doubling(n) for n in range(N)],
    'Constant': [0] * N,
    'Period-7': [n % 7 for n in range(N)],
}

# Compute entropy at prime lengths
primes = sieve_primes(50)
primes = [p for p in primes if p < 40]  # Keep manageable

seq_names = list(sequences.keys())
entropy_matrix = np.zeros((len(seq_names), len(primes)))

for i, name in enumerate(seq_names):
    for j, p in enumerate(primes):
        entropy_matrix[i, j] = subword_entropy(sequences[name], p)

# Normalize by maximum possible entropy for comparison
max_entropy = np.array([p * log(2) for p in primes])
normalized_matrix = entropy_matrix / max_entropy[np.newaxis, :]

# Create figure
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(12, 10))

# Raw entropy heatmap
im1 = ax1.imshow(entropy_matrix, aspect='auto', cmap='viridis', interpolation='nearest')
ax1.set_xticks(range(len(primes)))
ax1.set_xticklabels([str(p) for p in primes])
ax1.set_yticks(range(len(seq_names)))
ax1.set_yticklabels(seq_names)
ax1.set_xlabel('Prime p', fontsize=12)
ax1.set_title('Subword Entropy H(p) at Prime Lengths', fontsize=14, fontweight='bold')
plt.colorbar(im1, ax=ax1, label='Entropy (nats)')

# Add text annotations
for i in range(len(seq_names)):
    for j in range(len(primes)):
        val = entropy_matrix[i, j]
        color = 'white' if val > np.max(entropy_matrix) * 0.5 else 'black'
        ax1.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=7, color=color)

# Normalized entropy (fraction of maximum)
im2 = ax2.imshow(normalized_matrix, aspect='auto', cmap='RdYlGn', interpolation='nearest',
                  vmin=0, vmax=1)
ax2.set_xticks(range(len(primes)))
ax2.set_xticklabels([str(p) for p in primes])
ax2.set_yticks(range(len(seq_names)))
ax2.set_yticklabels(seq_names)
ax2.set_xlabel('Prime p', fontsize=12)
ax2.set_title('Normalized Entropy H(p) / H_max(p)  [Entropy Fraction]',
              fontsize=14, fontweight='bold')
plt.colorbar(im2, ax=ax2, label='Fraction of max entropy')

for i in range(len(seq_names)):
    for j in range(len(primes)):
        val = normalized_matrix[i, j]
        color = 'white' if val < 0.5 else 'black'
        ax2.text(j, i, f'{val:.2f}', ha='center', va='center',
                fontsize=7, color=color)

plt.tight_layout()
plt.savefig('viz_entropy_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_entropy_heatmap.png")
