#!/usr/bin/env python3
"""
Privacy-Surveillance Conservation Law: Numerical Demonstrations

Demonstrates the fundamental identity π(f) + σ(f) = n(n-1) and its
consequences through concrete examples.
"""

import itertools
from collections import Counter
from typing import Callable, List, Dict, Any


def privacy_index(f: Callable, domain: list) -> int:
    """Count ordered pairs (s1, s2) with s1 ≠ s2 and f(s1) = f(s2)."""
    count = 0
    for s1, s2 in itertools.permutations(domain, 2):
        if f(s1) == f(s2):
            count += 1
    return count


def surveillance_index(f: Callable, domain: list) -> int:
    """Count ordered pairs (s1, s2) with s1 ≠ s2 and f(s1) ≠ f(s2)."""
    count = 0
    for s1, s2 in itertools.permutations(domain, 2):
        if f(s1) != f(s2):
            count += 1
    return count


def fiber_sizes(f: Callable, domain: list) -> List[int]:
    """Compute the fiber sizes (privacy spectrum) of f."""
    counter = Counter(f(s) for s in domain)
    return sorted(counter.values(), reverse=True)


def privacy_from_fibers(fibers: List[int]) -> int:
    """Compute π(f) from fiber sizes: Σ k(k-1)."""
    return sum(k * (k - 1) for k in fibers)


def collision_probability(f: Callable, domain: list) -> float:
    """Compute the collision probability π(f) / n(n-1)."""
    n = len(domain)
    if n <= 1:
        return 0.0
    return privacy_index(f, domain) / (n * (n - 1))


def balanced_privacy(n: int, k: int) -> int:
    """Minimum privacy index for n elements in k groups (balanced partition)."""
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)


# ============================================================
# Demo 1: Conservation Law Verification
# ============================================================
print("=" * 60)
print("DEMO 1: Conservation Law π(f) + σ(f) = n(n-1)")
print("=" * 60)

domain = list(range(6))  # {0, 1, 2, 3, 4, 5}
n = len(domain)

# Example functions
functions = {
    "identity (injective)": lambda x: x,
    "constant": lambda x: 0,
    "mod 3": lambda x: x % 3,
    "mod 2": lambda x: x % 2,
    "floor(x/2)": lambda x: x // 2,
}

for name, f in functions.items():
    pi = privacy_index(f, domain)
    sigma = surveillance_index(f, domain)
    fibs = fiber_sizes(f, domain)
    print(f"\nf = {name}")
    print(f"  Fibers: {fibs}")
    print(f"  π(f) = {pi}, σ(f) = {sigma}")
    print(f"  π(f) + σ(f) = {pi + sigma} = {n}×{n-1} = {n*(n-1)} ✓" 
          if pi + sigma == n*(n-1) else f"  ERROR!")
    print(f"  Collision prob = {collision_probability(f, domain):.4f}")

# ============================================================
# Demo 2: Fiber Decomposition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Fiber Decomposition π(f) = Σ k(k-1)")
print("=" * 60)

for name, f in functions.items():
    pi = privacy_index(f, domain)
    fibs = fiber_sizes(f, domain)
    pi_from_fibs = privacy_from_fibers(fibs)
    print(f"\nf = {name}")
    print(f"  Fibers: {fibs}")
    print(f"  Σ k(k-1) = {' + '.join(f'{k}×{k-1}' for k in fibs)} = {pi_from_fibs}")
    print(f"  π(f) = {pi} = Σ k(k-1) = {pi_from_fibs} ✓"
          if pi == pi_from_fibs else f"  ERROR!")

# ============================================================
# Demo 3: Data Processing Inequality
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Data Processing Inequality")
print("=" * 60)

f = lambda x: x % 3  # base function
h = lambda y: y % 2  # post-processing

pi_f = privacy_index(f, domain)
pi_hf = privacy_index(lambda x: h(f(x)), domain)
sigma_f = surveillance_index(f, domain)
sigma_hf = surveillance_index(lambda x: h(f(x)), domain)

print(f"f = mod 3, h = mod 2")
print(f"  π(f) = {pi_f}, π(h∘f) = {pi_hf}")
print(f"  π(f) ≤ π(h∘f): {pi_f} ≤ {pi_hf} → {pi_f <= pi_hf} ✓")
print(f"  σ(h∘f) ≤ σ(f): {sigma_hf} ≤ {sigma_f} → {sigma_hf <= sigma_f} ✓")
print(f"  Post-processing only increases privacy (decreases surveillance)")

# ============================================================
# Demo 4: Balanced Partition Minimality
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Balanced Partition Minimizes Privacy")
print("=" * 60)

n_test = 12
for k in [2, 3, 4, 6]:
    bal = balanced_privacy(n_test, k)
    print(f"\nn={n_test}, k={k}: balanced minimum = {bal}")
    
    # Generate a few random partitions
    import random
    random.seed(42)
    for trial in range(3):
        parts = [1] * k
        remaining = n_test - k
        for _ in range(remaining):
            parts[random.randint(0, k-1)] += 1
        parts.sort(reverse=True)
        pi = sum(p * (p-1) for p in parts)
        print(f"  Partition {parts}: Σ k(k-1) = {pi} ≥ {bal} → {pi >= bal}")

# ============================================================
# Demo 5: Privacy Spectrum Analysis
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Privacy Spectrum Analysis")
print("=" * 60)

domain_large = list(range(20))
test_functions = {
    "mod 4": lambda x: x % 4,
    "mod 5": lambda x: x % 5,
    "floor(x/4)": lambda x: x // 4,
    "floor(x/5)": lambda x: x // 5,
    "x < 10": lambda x: x < 10,
}

for name, f in test_functions.items():
    fibs = fiber_sizes(f, domain_large)
    n = len(domain_large)
    pi = privacy_from_fibers(fibs)
    cp = pi / (n * (n - 1)) if n > 1 else 0
    print(f"\nf = {name}")
    print(f"  Spectrum: {fibs}")
    print(f"  Spectrum sum = {sum(fibs)} = |S| = {n} ✓" 
          if sum(fibs) == n else "  ERROR!")
    print(f"  π(f) = {pi}, σ(f) = {n*(n-1) - pi}")
    print(f"  Collision prob = {cp:.4f}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Privacy-Surveillance Conservation Law

Generates plots showing the conservation law, Pareto frontier,
and balanced partition minimality.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import Counter
import itertools


def privacy_index_from_fibers(fibers):
    return sum(k * (k - 1) for k in fibers)


def balanced_privacy(n, k):
    q, r = divmod(n, k)
    return r * (q + 1) * q + (k - r) * q * (q - 1)


# ---- Figure 1: Conservation Law Budget Diagram ----
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

n = 10
budget = n * (n - 1)

# Different observation functions on Fin(10) -> Fin(k)
functions = {
    "Injective\n(id)": list(range(10)),
    "Mod 5": [x % 5 for x in range(10)],
    "Mod 3": [x % 3 for x in range(10)],
    "Mod 2": [x % 2 for x in range(10)],
    "Floor(x/3)": [x // 3 for x in range(10)],
    "Constant": [0] * 10,
}

names = list(functions.keys())
pi_vals = []
sigma_vals = []

for name, outputs in functions.items():
    counter = Counter(outputs)
    fibers = list(counter.values())
    pi = privacy_index_from_fibers(fibers)
    pi_vals.append(pi)
    sigma_vals.append(budget - pi)

ax = axes[0]
x_pos = np.arange(len(names))
bars1 = ax.bar(x_pos, pi_vals, color='#2196F3', label='Privacy π(f)')
bars2 = ax.bar(x_pos, sigma_vals, bottom=pi_vals, color='#FF5722', label='Surveillance σ(f)')
ax.axhline(y=budget, color='black', linestyle='--', linewidth=1, label=f'Budget n(n-1)={budget}')
ax.set_xticks(x_pos)
ax.set_xticklabels(names, fontsize=8, rotation=15)
ax.set_ylabel('Pair Count')
ax.set_title(f'Conservation Law: π + σ = {budget}\n(n = {n})')
ax.legend(fontsize=8)

# ---- Figure 2: Pareto Frontier ----
ax = axes[1]
n = 20

k_values = list(range(1, n + 1))
min_privacy = [balanced_privacy(n, k) for k in k_values]
collision_prob = [mp / (n * (n-1)) for mp in min_privacy]
utility = [k / n for k in k_values]

ax.plot(collision_prob, utility, 'o-', color='#4CAF50', markersize=5, linewidth=2)
ax.fill_between(collision_prob, utility, alpha=0.1, color='#4CAF50')

# Annotate extremes
ax.annotate('Injective\n(full surveillance)', 
            xy=(0, 1), fontsize=8, ha='center',
            xytext=(0.15, 0.85), arrowprops=dict(arrowstyle='->', color='gray'))
ax.annotate('Constant\n(full privacy)', 
            xy=(1, 1/n), fontsize=8, ha='center',
            xytext=(0.7, 0.25), arrowprops=dict(arrowstyle='->', color='gray'))

ax.set_xlabel('Collision Probability (privacy)')
ax.set_ylabel('Utility (image size / n)')
ax.set_title(f'Privacy-Utility Pareto Frontier\n(n = {n}, balanced partitions)')
ax.set_xlim(-0.05, 1.05)
ax.set_ylim(0, 1.05)
ax.grid(True, alpha=0.3)

# ---- Figure 3: Balanced vs Unbalanced Privacy ----
ax = axes[2]
n = 12

for k in [2, 3, 4, 6]:
    # Generate many random partitions
    import random
    random.seed(42 + k)
    privacy_vals = []
    for _ in range(500):
        parts = [1] * k
        remaining = n - k
        for _ in range(remaining):
            parts[random.randint(0, k-1)] += 1
        privacy_vals.append(privacy_index_from_fibers(parts))
    
    bal = balanced_privacy(n, k)
    
    # Plot histogram
    bins = range(min(privacy_vals), max(privacy_vals) + 2)
    ax.hist(privacy_vals, bins=bins, alpha=0.4, label=f'k={k}')
    ax.axvline(x=bal, color='red', linestyle='--', linewidth=1)

ax.set_xlabel('Privacy Index π(f)')
ax.set_ylabel('Count')
ax.set_title(f'Balanced Partition Minimality\n(n={n}, red = balanced minimum)')
ax.legend(fontsize=8)

plt.tight_layout()
plt.savefig('conservation_law_visualization.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved conservation_law_visualization.png")
