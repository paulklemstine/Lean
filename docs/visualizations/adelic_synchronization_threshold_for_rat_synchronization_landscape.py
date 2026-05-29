"""
Visualization 3: Synchronization Landscape

Plots the sync score as a function of the parameter c, scanning a range
of integer values. Peaks correspond to exceptional (preperiodic) parameters.

This is the "order parameter" landscape — the adelic synchronization
phase diagram for the quadratic family.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import Counter


def quad_map_mod(x, c, p):
    return (x * x + c) % p

def find_preperiod_and_period(c, p):
    seen = {}
    x = 0
    for i in range(p + 2):
        if x in seen:
            return seen[x], i - seen[x]
        seen[x] = i
        x = quad_map_mod(x, c, p)
    return p, 1

def prime_sync_score(invariants):
    counts = Counter(invariants)
    return sum(v * v for v in counts.values())

def sieve(n):
    if n < 2:
        return []
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n**0.5) + 1):
        if s[i]:
            for j in range(i*i, n + 1, i):
                s[j] = False
    return [i for i in range(2, n + 1) if s[i]]

def is_preperiodic_over_Q(c, max_iter=200):
    seen = {0: 0}
    x = 0
    for i in range(1, max_iter + 1):
        x = x * x + c
        if x in seen:
            return True
        if abs(x) > 10**15:
            return False
        seen[x] = i
    return False


primes = [p for p in sieve(200) if p > 2]
n_primes = len(primes)
max_score = n_primes ** 2

c_range = range(-30, 31)
scores = []
is_exc = []

for c in c_range:
    invariants = [find_preperiod_and_period(c, p) for p in primes]
    score = prime_sync_score(invariants)
    scores.append(score / max_score)
    is_exc.append(is_preperiodic_over_Q(c))

c_list = list(c_range)

fig, ax = plt.subplots(figsize=(14, 6))
fig.suptitle("Adelic Synchronization Landscape\nSync score vs parameter c for f(x) = x² + c",
             fontsize=14, fontweight='bold')

# Plot all scores as bars
colors = ['#d62728' if exc else '#1f77b4' for exc in is_exc]
ax.bar(c_list, scores, color=colors, alpha=0.7, width=0.8)

# Highlight exceptional parameters
exc_cs = [c for c, e in zip(c_list, is_exc) if e]
exc_scores = [s for s, e in zip(scores, is_exc) if e]
ax.scatter(exc_cs, exc_scores, color='red', s=80, zorder=5,
           label='Preperiodic over ℚ', edgecolors='black', linewidth=1)

# Add labels for exceptional parameters
for c, s in zip(exc_cs, exc_scores):
    ax.annotate(f'c={c}', (c, s), textcoords="offset points",
                xytext=(0, 10), ha='center', fontsize=8, color='red')

ax.set_xlabel("Parameter c", fontsize=12)
ax.set_ylabel("Synchronization ratio (score / max)", fontsize=12)
ax.legend(fontsize=10)
ax.grid(alpha=0.3, axis='y')
ax.set_xlim(c_list[0] - 1, c_list[-1] + 1)

plt.tight_layout()
plt.savefig("sync_landscape.png", dpi=150, bbox_inches='tight')
print("Saved sync_landscape.png")
