#!/usr/bin/env python3
"""
Visualization: Max-Envelope Stability for Primewise Betti Curves

This script visualizes the core mathematical phenomenon:
- Primewise Betti curves for different primes
- The global Betti curve (pointwise max)
- The strictness gap between global distance and primewise max distance

The visualization illustrates the main theorem (betti_envelope_pointwise):
  |globalBetti_M(t) - globalBetti_N(t)| ≤ max_p |beta_{M,p}(t) - beta_{N,p}(t)|
and the strictness result (exists_strict_betti_gap) showing the inequality
can be strict.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

# --- Inline helper functions ---
def nat_dist(a, b):
    return abs(a - b)

# --- Define two profiles that exhibit the strictness phenomenon ---
# Profile M: prime 2 dominates early, prime 3 dominates late
times = np.arange(0, 10)

betti_M = {
    2: np.array([5, 4, 3, 2, 1, 0, 0, 0, 0, 0]),
    3: np.array([2, 3, 4, 5, 4, 3, 2, 1, 0, 0]),
    5: np.array([0, 0, 1, 2, 3, 4, 3, 2, 1, 0]),
}

# Profile N: "crossed" — prime 3 dominates early, prime 2 dominates late
betti_N = {
    2: np.array([2, 3, 4, 5, 4, 3, 2, 1, 0, 0]),
    3: np.array([5, 4, 3, 2, 1, 0, 0, 0, 0, 0]),
    5: np.array([0, 1, 2, 3, 4, 3, 2, 1, 0, 0]),
}

primes = [2, 3, 5]
colors = {2: '#e74c3c', 3: '#2ecc71', 5: '#3498db'}
prime_names = {2: 'p=2', 3: 'p=3', 5: 'p=5'}

# Compute global Betti curves
global_M = np.array([max(betti_M[p][t] for p in primes) for t in range(len(times))])
global_N = np.array([max(betti_N[p][t] for p in primes) for t in range(len(times))])

# Compute distances
global_dist = np.array([nat_dist(global_M[t], global_N[t]) for t in range(len(times))])
primewise_max_dist = np.array([
    max(nat_dist(betti_M[p][t], betti_N[p][t]) for p in primes)
    for t in range(len(times))
])
gap = primewise_max_dist - global_dist

# --- Create figure ---
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Max-Envelope Stability for Primewise Persistence Invariants',
             fontsize=14, fontweight='bold')

# Panel 1: Profile M - primewise Betti curves
ax = axes[0, 0]
for p in primes:
    ax.plot(times, betti_M[p], 'o-', color=colors[p], label=prime_names[p],
            linewidth=2, markersize=5)
ax.plot(times, global_M, 'k--', linewidth=2.5, label='Global (max)',
        alpha=0.8)
ax.fill_between(times, 0, global_M, alpha=0.08, color='black')
ax.set_title('Profile M: Primewise Betti Curves', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('β(t)')
ax.legend(fontsize=9)
ax.set_ylim(-0.3, 6)
ax.grid(True, alpha=0.3)

# Panel 2: Profile N - primewise Betti curves
ax = axes[0, 1]
for p in primes:
    ax.plot(times, betti_N[p], 's-', color=colors[p], label=prime_names[p],
            linewidth=2, markersize=5)
ax.plot(times, global_N, 'k--', linewidth=2.5, label='Global (max)',
        alpha=0.8)
ax.fill_between(times, 0, global_N, alpha=0.08, color='black')
ax.set_title('Profile N: Primewise Betti Curves (Crossed)', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('β(t)')
ax.legend(fontsize=9)
ax.set_ylim(-0.3, 6)
ax.grid(True, alpha=0.3)

# Panel 3: Distances
ax = axes[1, 0]
for p in primes:
    pw_dist = np.array([nat_dist(betti_M[p][t], betti_N[p][t])
                         for t in range(len(times))])
    ax.plot(times, pw_dist, 'o--', color=colors[p], label=f'd_{prime_names[p]}',
            linewidth=1.5, markersize=4, alpha=0.7)
ax.plot(times, primewise_max_dist, 'k-', linewidth=2.5,
        label='max_p d_p (upper bound)', marker='D', markersize=4)
ax.plot(times, global_dist, 'r-', linewidth=2.5,
        label='Global distance', marker='o', markersize=5)
ax.set_title('Max-Envelope Theorem: Global ≤ max Primewise', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=8, loc='upper right')
ax.grid(True, alpha=0.3)

# Panel 4: Strictness gap
ax = axes[1, 1]
ax.bar(times, gap, color='#9b59b6', alpha=0.7, label='Gap (UB − global)')
ax.bar(times, global_dist, bottom=0, color='#e74c3c', alpha=0.5,
       label='Global distance')
ax.plot(times, primewise_max_dist, 'k-', linewidth=2, marker='D',
        markersize=4, label='Upper bound')
ax.set_title('Strictness Gap: The Inequality Is Not Tight', fontsize=11)
ax.set_xlabel('Filtration level t')
ax.set_ylabel('Distance')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Add annotation for the main theorem
ax.annotate('Gap > 0: proves\nexists_strict_betti_gap',
            xy=(0, gap[0]), xytext=(2, gap.max() + 0.5),
            arrowprops=dict(arrowstyle='->', color='purple'),
            fontsize=9, color='purple', fontweight='bold')

plt.tight_layout()
plt.savefig('max_envelope_stability.png', dpi=150, bbox_inches='tight')
print("Saved: max_envelope_stability.png")
plt.close()
