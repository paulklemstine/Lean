"""
Visualization: Chromatic Polynomial Landscape

Plots the chromatic polynomial χ(G, k) as a function of k for several
graph families (complete, cycle, path, empty), revealing how graph
structure constrains the number of valid emotion assignments.
"""

import matplotlib.pyplot as plt
import numpy as np

def falling_factorial(k, n):
    """k^(n) = k(k-1)...(k-n+1)"""
    result = 1
    for i in range(n):
        result *= max(k - i, 0)
    return result

def chi_complete(n, k):
    return falling_factorial(k, n)

def chi_cycle(n, k):
    if n < 3:
        return 0
    return (k - 1)**n + ((-1)**n) * (k - 1)

def chi_path(n, k):
    if n < 1:
        return 1
    return k * (k - 1)**(n - 1)

def chi_empty(n, k):
    return k**n

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

k_vals = np.arange(1, 9)

# Plot 1: Complete graphs
ax = axes[0, 0]
for n in [2, 3, 4, 5, 6]:
    y = [chi_complete(n, k) for k in k_vals]
    ax.plot(k_vals, y, 'o-', label=f'$K_{{{n}}}$', linewidth=2, markersize=6)
ax.set_xlabel('Number of colors k', fontsize=12)
ax.set_ylabel('χ(G, k)', fontsize=12)
ax.set_title('Complete Graphs: χ(K_n, k) = k⁽ⁿ⁾', fontsize=13)
ax.legend(fontsize=10)
ax.set_yscale('log')
ax.set_ylim(0.5, 50000)
ax.grid(True, alpha=0.3)
ax.axvline(x=6, color='red', linestyle='--', alpha=0.5, label='k=6 (Ekman)')

# Plot 2: Cycle graphs
ax = axes[0, 1]
for n in [3, 4, 5, 6, 7, 8]:
    y = [chi_cycle(n, k) for k in k_vals]
    parity = "even" if n % 2 == 0 else "odd"
    ax.plot(k_vals, y, 'o-', label=f'$C_{{{n}}}$ ({parity})', linewidth=2, markersize=6)
ax.set_xlabel('Number of colors k', fontsize=12)
ax.set_ylabel('χ(G, k)', fontsize=12)
ax.set_title('Cycle Graphs: χ(C_n, k) = (k-1)ⁿ + (-1)ⁿ(k-1)', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Plot 3: Emotional diversity comparison
ax = axes[1, 0]
n = 5
for graph_name, chi_func in [('Empty $E_5$', chi_empty),
                               ('Path $P_5$', chi_path),
                               ('Cycle $C_5$', chi_cycle),
                               ('Complete $K_5$', chi_complete)]:
    diversity = []
    for k in range(1, 9):
        c = chi_func(n, k)
        d = c / (k**n) if k > 0 else 0
        diversity.append(d)
    ax.plot(range(1, 9), diversity, 's-', label=graph_name, linewidth=2, markersize=7)
ax.set_xlabel('Number of emotions k', fontsize=12)
ax.set_ylabel('Emotional Diversity D(G, k)', fontsize=12)
ax.set_title('Emotional Diversity: χ(G,k)/k^n for n=5 vertices', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(-0.05, 1.05)
ax.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax.grid(True, alpha=0.3)

# Plot 4: Channel capacity comparison
ax = axes[1, 1]
k = 6
n_vals = range(2, 9)
for graph_name, chi_func in [('Empty', chi_empty),
                               ('Path', chi_path),
                               ('Cycle', chi_cycle),
                               ('Complete', chi_complete)]:
    capacity = []
    for n in n_vals:
        c = chi_func(n, k)
        if c > 0:
            cap = np.log2(c) / n
        else:
            cap = 0
        capacity.append(cap)
    ax.plot(list(n_vals), capacity, 'D-', label=graph_name, linewidth=2, markersize=6)
ax.set_xlabel('Number of vertices n', fontsize=12)
ax.set_ylabel('Bits per vertex', fontsize=12)
ax.set_title(f'Information Capacity with k={k} Emotions', fontsize=13)
ax.legend(fontsize=10)
ax.axhline(y=np.log2(6), color='gray', linestyle=':', alpha=0.5, label='Max (log₂6)')
ax.grid(True, alpha=0.3)

plt.suptitle('Chromatic Polynomial Landscape: Graph Structure Constrains Emotional Diversity',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('chromatic_landscape.png', dpi=150, bbox_inches='tight')
print("Saved chromatic_landscape.png")
