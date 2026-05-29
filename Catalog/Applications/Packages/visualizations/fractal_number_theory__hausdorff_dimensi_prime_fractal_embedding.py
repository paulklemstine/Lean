"""
Visualization 1: Prime Fractal Embedding
==========================================
Visualizes the logarithmic embedding p ↦ 1/log(p) of primes,
showing how the prime fractal metric transforms the distribution of primes.
The top panel shows primes on the number line, the bottom shows their
logarithmic embeddings. Twin primes are highlighted in red.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def sieve_primes(N):
    if N < 2:
        return []
    sieve = [True] * (N + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(N**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, N + 1, i):
                sieve[j] = False
    return [i for i in range(2, N + 1) if sieve[i]]


def log_embed(p):
    return 1.0 / math.log(p)


# Generate primes
N = 500
primes = sieve_primes(N)
embeddings = [log_embed(p) for p in primes]
prime_set = set(primes)
twins = [(p, p+2) for p in primes if p+2 in prime_set]
twin_ps = set()
for p, q in twins:
    twin_ps.add(p)
    twin_ps.add(q)

fig, axes = plt.subplots(3, 1, figsize=(14, 10), gridspec_kw={'height_ratios': [1, 1, 2]})

# Panel 1: Primes on the number line
ax1 = axes[0]
for p in primes:
    color = '#e74c3c' if p in twin_ps else '#3498db'
    ax1.axvline(p, color=color, alpha=0.6, linewidth=1.5)
ax1.set_xlim(0, N)
ax1.set_ylim(0, 1)
ax1.set_yticks([])
ax1.set_xlabel('n', fontsize=12)
ax1.set_title('Primes on the Number Line (twin primes in red)', fontsize=14, fontweight='bold')

# Panel 2: Logarithmic embeddings
ax2 = axes[1]
for i, p in enumerate(primes):
    e = embeddings[i]
    color = '#e74c3c' if p in twin_ps else '#2ecc71'
    ax2.axvline(e, color=color, alpha=0.6, linewidth=1.5)
ax2.set_xlim(0, max(embeddings) * 1.05)
ax2.set_ylim(0, 1)
ax2.set_yticks([])
ax2.set_xlabel('1/log(p)', fontsize=12)
ax2.set_title('Primes Under Logarithmic Embedding (twin primes in red)', fontsize=14, fontweight='bold')

# Panel 3: Embedding as a function
ax3 = axes[2]
colors = ['#e74c3c' if p in twin_ps else '#3498db' for p in primes]
ax3.scatter(primes, embeddings, c=colors, s=25, alpha=0.7, edgecolors='none')
ax3.set_xlabel('Prime p', fontsize=12)
ax3.set_ylabel('logEmbed(p) = 1/log(p)', fontsize=12)
ax3.set_title('Logarithmic Embedding: How the Fractal Metric Transforms Primes', fontsize=14, fontweight='bold')

# Add the curve 1/log(x)
x = np.linspace(2, N, 1000)
ax3.plot(x, 1.0 / np.log(x), 'k--', alpha=0.3, linewidth=2, label='y = 1/log(x)')
ax3.legend(fontsize=11)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_fractal_embedding.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_fractal_embedding.png")
