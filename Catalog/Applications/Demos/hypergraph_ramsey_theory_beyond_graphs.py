#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Demonstrations and Computations

Demonstrates the key concepts: tower functions, counting lower bounds,
chromatic density, and the growth of Ramsey numbers across uniformities.
"""

import math
from itertools import combinations

def tower(b: int, n: int) -> int:
    """Tower function: iterated exponentiation. tower(b, 0) = 1, tower(b, n+1) = b^tower(b, n)."""
    if n == 0:
        return 1
    prev = tower(b, n - 1)
    if prev > 100000:  # avoid astronomical numbers
        return float('inf')
    return b ** prev

def ramsey_counting_lower_bound(r: int, k: int) -> int:
    """
    Probabilistic lower bound for R_r(k,k).
    Returns the largest n such that 2 * C(n,k) < 2^C(k,r).
    """
    threshold = 2 ** math.comb(k, r)
    n = k
    while 2 * math.comb(n, k) < threshold:
        n += 1
    return n - 1

def check_monochromatic(coloring: dict, vertices: list, r: int) -> bool:
    """Check if a vertex set is monochromatic (all r-subsets same color)."""
    color_set = set()
    for subset in combinations(vertices, r):
        key = tuple(sorted(subset))
        color_set.add(coloring.get(key, 0))
        if len(color_set) > 1:
            return False
    return True

def brute_force_ramsey_1(s: int, t: int) -> int:
    """Compute R_1(s,t) by brute force = s + t - 1."""
    # For 1-uniform: just pigeonhole
    return s + t - 1

def chromatic_density(coloring: dict, vertices: list, r: int) -> float:
    """Compute the chromatic density (fraction of red r-subsets)."""
    total = 0
    red = 0
    for subset in combinations(vertices, r):
        key = tuple(sorted(subset))
        total += 1
        if coloring.get(key, 0) == 1:
            red += 1
    return red / total if total > 0 else 0.5

def demo_tower_growth():
    """Demonstrate tower function growth."""
    print("=" * 60)
    print("Tower Function Growth: tower(2, n)")
    print("=" * 60)
    for n in range(8):
        val = tower(2, n)
        if val != float('inf'):
            print(f"  tower(2, {n}) = {val}")
        else:
            print(f"  tower(2, {n}) = 2^(tower(2,{n-1})) [astronomically large]")
    print()

def demo_counting_lower_bounds():
    """Demonstrate counting lower bounds for various uniformities."""
    print("=" * 60)
    print("Counting Lower Bounds for R_r(k,k)")
    print("=" * 60)
    print(f"{'r':>3} {'k':>3} {'C(k,r)':>10} {'2^C(k,r)':>15} {'Lower bound':>12}")
    print("-" * 50)
    for r in range(2, 5):
        for k in range(r + 1, min(r + 8, 15)):
            ckr = math.comb(k, r)
            if ckr <= 50:  # avoid overflow
                lb = ramsey_counting_lower_bound(r, k)
                print(f"{r:>3} {k:>3} {ckr:>10} {2**ckr:>15} {lb:>12}")
    print()

def demo_ramsey_one():
    """Demonstrate R_1(s,t) = s + t - 1."""
    print("=" * 60)
    print("1-Uniform Ramsey Numbers: R_1(s,t) = s + t - 1")
    print("=" * 60)
    for s in range(1, 8):
        for t in range(1, 8):
            print(f"  R_1({s},{t}) = {brute_force_ramsey_1(s, t)}", end="  ")
        print()
    print()

def demo_uniformity_spectrum():
    """Demonstrate how Ramsey bounds grow across uniformities."""
    print("=" * 60)
    print("Ramsey Spectrum: Growth Across Uniformities")
    print("=" * 60)
    print("For diagonal R_r(k,k), counting lower bounds:")
    print(f"{'k':>3} {'r=2 (graph)':>15} {'r=3 (3-unif)':>15} {'r=4 (4-unif)':>15}")
    print("-" * 55)
    for k in range(3, 10):
        bounds = []
        for r in range(2, 5):
            if math.comb(k, r) <= 50:
                lb = ramsey_counting_lower_bound(r, k)
                bounds.append(str(lb))
            else:
                bounds.append("huge")
        print(f"{k:>3} {bounds[0]:>15} {bounds[1]:>15} {bounds[2]:>15}")
    print()
    print("Key observation: as uniformity r increases, the lower bounds")
    print("grow dramatically (single exponential → double exponential → tower).")
    print()

def demo_density_dichotomy():
    """Demonstrate the density dichotomy for a random-ish coloring."""
    print("=" * 60)
    print("Density Dichotomy Example")
    print("=" * 60)
    n = 6
    r = 2
    vertices = list(range(n))
    # Create a biased coloring
    coloring = {}
    for pair in combinations(vertices, r):
        key = tuple(sorted(pair))
        # Color based on sum parity
        coloring[key] = 1 if sum(pair) % 3 == 0 else 0
    
    total = math.comb(n, r)
    red = sum(1 for v in coloring.values() if v == 1)
    blue = total - red
    
    print(f"  n = {n}, r = {r}")
    print(f"  Total {r}-subsets: {total}")
    print(f"  Red: {red}, Blue: {blue}")
    print(f"  Density dichotomy: max(red, blue) = {max(red, blue)} ≥ {total}/2 = {total/2}")
    print(f"  ✓ At least one color has ≥ half the subsets")
    print()

if __name__ == "__main__":
    demo_tower_growth()
    demo_counting_lower_bounds()
    demo_ramsey_one()
    demo_uniformity_spectrum()
    demo_density_dichotomy()
    
    print("=" * 60)
    print("Summary of Formalized Results")
    print("=" * 60)
    print("1. HyperRamseyProp: Ramsey property for r-uniform hypergraphs")
    print("2. Counting lower bound: 2·C(n,k) < 2^C(k,r) → ¬R_r(n,k,k)")
    print("3. R_1(s,t) = s + t - 1 (exact, with tightness proof)")
    print("4. Uniformity gap: ¬R_r(n,s,t) → ¬R_{r+1}(n,s+1,t+1)")
    print("5. Tower iteration bound: f(r+1) ≤ 2^f(r) → f(r) ≤ tower(2,r)")
    print("6. Link coloring: monochromatic preservation under link")
    print("7. Density dichotomy: pigeonhole for hypergraph colorings")


#!/usr/bin/env python3
"""
Visualization: Tower Function Growth and Ramsey Spectrum

Creates plots showing:
1. Tower function vs exponential growth
2. Ramsey lower bounds across uniformities
3. Uniformity gap ratios
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def tower(b, n):
    if n == 0:
        return 1
    prev = tower(b, n - 1)
    if prev > 100:
        return float('inf')
    return b ** prev

def counting_lower_bound(r, k):
    if r > k:
        return k
    ckr = math.comb(k, r)
    if ckr > 60:
        return float('inf')
    threshold = 2 ** ckr
    n = k
    while 2 * math.comb(n, k) < threshold and n < 10**6:
        n += 1
    return n - 1

# Figure 1: Tower vs Exponential Growth
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Tower function (log scale)
ns = list(range(0, 6))
tower_vals = [tower(2, n) for n in ns]
exp_vals = [2**n for n in ns]

ax = axes[0]
valid_tower = [(n, v) for n, v in zip(ns, tower_vals) if v < float('inf')]
valid_exp = [(n, v) for n, v in zip(ns, exp_vals) if v < float('inf')]
ax.semilogy([x[0] for x in valid_tower], [x[1] for x in valid_tower], 
            'ro-', linewidth=2, markersize=8, label='tower(2, n)')
ax.semilogy([x[0] for x in valid_exp], [x[1] for x in valid_exp],
            'bs--', linewidth=2, markersize=8, label='2^n')
ax.set_xlabel('Height n', fontsize=12)
ax.set_ylabel('Value (log scale)', fontsize=12)
ax.set_title('Tower Function vs Exponential', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 2: Ramsey lower bounds
ax = axes[1]
ks = list(range(3, 12))
for r in [2, 3, 4]:
    lbs = []
    valid_ks = []
    for k in ks:
        lb = counting_lower_bound(r, k)
        if lb < float('inf') and lb < 10**6:
            lbs.append(lb)
            valid_ks.append(k)
    if valid_ks:
        ax.semilogy(valid_ks, lbs, 'o-', linewidth=2, markersize=6, 
                    label=f'r={r} ({r}-uniform)')
ax.set_xlabel('Clique size k', fontsize=12)
ax.set_ylabel('Lower bound on R_r(k,k)', fontsize=12)
ax.set_title('Counting Lower Bounds', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Plot 3: Growth rate comparison
ax = axes[2]
ks = list(range(3, 10))
ratios_2 = []
ratios_3 = []
valid_ks_2 = []
valid_ks_3 = []
for k in ks:
    lb2 = counting_lower_bound(2, k)
    lb3 = counting_lower_bound(3, k)
    if lb2 > 1 and lb2 < float('inf'):
        ratios_2.append(math.log2(lb2))
        valid_ks_2.append(k)
    if lb3 > 1 and lb3 < float('inf'):
        ratios_3.append(math.log2(lb3))
        valid_ks_3.append(k)

if valid_ks_2:
    ax.plot(valid_ks_2, ratios_2, 'ro-', linewidth=2, markersize=8, label='log₂ R₂(k,k)')
if valid_ks_3:
    ax.plot(valid_ks_3, ratios_3, 'bs-', linewidth=2, markersize=8, label='log₂ R₃(k,k)')
# Theoretical curves
k_theory = np.linspace(3, 10, 100)
ax.plot(k_theory, k_theory/2, 'r--', alpha=0.5, label='k/2 (graph theory)')
ax.plot(k_theory, k_theory**2/6, 'b--', alpha=0.5, label='k²/6 (3-uniform)')
ax.set_xlabel('Clique size k', fontsize=12)
ax.set_ylabel('log₂(lower bound)', fontsize=12)
ax.set_title('Growth Rate: Linear vs Quadratic', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('ramsey_spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ramsey_spectrum.png")
