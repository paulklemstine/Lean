#!/usr/bin/env python3
"""
Probabilistic Method: Numerical Demonstrations

Demonstrates key results from the Erdős probabilistic method:
1. Erdős's R(k,k) > 2^{k/2} bound
2. Turán graph edge counts
3. Lovász Local Lemma conditions
4. Tropical cost verification
"""

from math import comb, factorial, log2, exp, floor
from itertools import combinations
import random

def erdos_bound(k: int) -> int:
    """Compute the Erdős lower bound on R(k,k): floor(2^{k/2})."""
    return floor(2 ** (k / 2))

def erdos_criterion(n: int, k: int) -> bool:
    """Check if the Erdős criterion holds: 2 * C(n,k) < 2^C(k,2)."""
    return 2 * comb(n, k) < 2 ** comb(k, 2)

def turan_edge_count(n: int, r: int) -> int:
    """Compute the number of edges in the Turán graph T(n,r)."""
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if i % r != j % r:
                count += 1
    return count

def turan_formula(n: int, r: int) -> float:
    """Compute the Turán edge count formula: (1 - 1/r) * n^2 / 2."""
    return (1 - 1/r) * n**2 / 2

def check_triangle_free(n: int, r: int = 2) -> bool:
    """Verify that T(n,r) is triangle-free (for r=2)."""
    for a in range(n):
        for b in range(a + 1, n):
            for c in range(b + 1, n):
                if (a % r != b % r) and (b % r != c % r) and (a % r != c % r):
                    return False
    return True

def lll_symmetric_check(p: float, d: int) -> bool:
    """Check the symmetric LLL condition: e * p * (d+1) <= 1."""
    return exp(1) * p * (d + 1) <= 1

def count_monochromatic_cliques(n: int, k: int, coloring: list) -> int:
    """Count monochromatic k-cliques in a 2-coloring of K_n."""
    vertices = list(range(n))
    count = 0
    for S in combinations(vertices, k):
        # Check if S is monochromatic (all edges same color)
        colors = set()
        for i in range(len(S)):
            for j in range(i + 1, len(S)):
                colors.add(coloring[S[i]][S[j]])
        if len(colors) <= 1:
            count += 1
    return count

def random_coloring(n: int) -> list:
    """Generate a random 2-coloring of K_n."""
    c = [[0]*n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            c[i][j] = random.randint(0, 1)
            c[j][i] = c[i][j]
    return c

def demo_erdos_bounds():
    """Demonstrate Erdős's R(k,k) bounds."""
    print("=" * 60)
    print("ERDŐS'S RAMSEY LOWER BOUNDS: R(k,k) > 2^{k/2}")
    print("=" * 60)
    print(f"{'k':>4} {'2^{k/2}':>10} {'Known R(k,k)':>15} {'2*C(n,k)':>12} {'2^{C(k,2)}':>12}")
    print("-" * 60)
    known = {3: 6, 4: 18, 5: '43-48', 6: '102-165', 7: '205-540'}
    for k in range(3, 8):
        n = erdos_bound(k)
        c2 = 2 * comb(n, k)
        p2 = 2 ** comb(k, 2)
        rk = known.get(k, '?')
        print(f"{k:>4} {n:>10} {str(rk):>15} {c2:>12} {p2:>12}")
    print()

def demo_turan_graph():
    """Demonstrate Turán graph properties."""
    print("=" * 60)
    print("TURÁN GRAPH T(n,2): EDGE COUNTS AND TRIANGLE-FREENESS")
    print("=" * 60)
    print(f"{'n':>4} {'Edges':>8} {'n²/4':>8} {'⌊n²/4⌋':>8} {'Tri-free?':>10}")
    print("-" * 60)
    for n in range(2, 16):
        edges = turan_edge_count(n, 2)
        formula = turan_formula(n, 2)
        floor_formula = n * n // 4
        tri_free = check_triangle_free(n, 2)
        print(f"{n:>4} {edges:>8} {formula:>8.1f} {floor_formula:>8} {'Yes' if tri_free else 'No':>10}")
    print()

def demo_lll():
    """Demonstrate LLL conditions."""
    print("=" * 60)
    print("LOVÁSZ LOCAL LEMMA: SYMMETRIC CONDITION e*p*(d+1) ≤ 1")
    print("=" * 60)
    print(f"{'d':>4} {'max p':>10} {'(1-p)^n (n=100)':>18}")
    print("-" * 60)
    for d in [1, 2, 5, 10, 20, 50, 100]:
        p_max = 1 / (exp(1) * (d + 1))
        avoidance = (1 - p_max) ** 100
        print(f"{d:>4} {p_max:>10.6f} {avoidance:>18.10f}")
    print()

def demo_tropical_cost():
    """Demonstrate the tropical existence principle."""
    print("=" * 60)
    print("TROPICAL EXISTENCE PRINCIPLE")
    print("=" * 60)
    
    # For K_5 with k=3: find a coloring with 0 monochromatic triangles
    n, k = 5, 3
    print(f"\nSearching for triangle-free 2-coloring of K_{n}...")
    best = float('inf')
    best_coloring = None
    for trial in range(1000):
        c = random_coloring(n)
        count = count_monochromatic_cliques(n, k, c)
        if count < best:
            best = count
            best_coloring = c
        if count == 0:
            print(f"  Found in {trial + 1} trials! Zero monochromatic triangles.")
            break
    
    expected = 2 * comb(n, k) / (2 ** comb(k, 2))
    print(f"  Expected monochromatic triangles per random coloring: {expected:.3f}")
    print(f"  Best found: {best}")
    print(f"  Erdős criterion (2*C({n},{k}) < 2^C({k},2)): {erdos_criterion(n, k)}")
    print()

def demo_binomial_bound():
    """Demonstrate the choose * factorial ≤ power bound."""
    print("=" * 60)
    print("BINOMIAL BOUND: k! * C(n,k) ≤ n^k")
    print("=" * 60)
    print(f"{'n':>4} {'k':>4} {'k!*C(n,k)':>12} {'n^k':>12} {'Ratio':>10}")
    print("-" * 60)
    for n in [5, 10, 20, 50]:
        for k in [2, 3, 4]:
            lhs = comb(n, k) * factorial(k)
            rhs = n ** k
            ratio = lhs / rhs if rhs > 0 else 0
            print(f"{n:>4} {k:>4} {lhs:>12} {rhs:>12} {ratio:>10.4f}")
    print()

if __name__ == "__main__":
    random.seed(42)
    demo_erdos_bounds()
    demo_turan_graph()
    demo_lll()
    demo_tropical_cost()
    demo_binomial_bound()


#!/usr/bin/env python3
"""
Visualization: Lovász Local Lemma Conditions

Visualizes the LLL parameter space and avoidance probability.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import exp

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: LLL feasible region
ax1 = axes[0]
ds = np.arange(1, 51)
p_max = 1 / (np.e * (ds + 1))

ax1.semilogy(ds, p_max, 'b-', linewidth=2, label='p_max = 1/(e(d+1))')
ax1.fill_between(ds, 0, p_max, alpha=0.2, color='blue', label='LLL feasible region')
ax1.set_xlabel('d (dependency degree)', fontsize=14)
ax1.set_ylabel('p (probability bound)', fontsize=14)
ax1.set_title('Symmetric LLL: Feasible Region', fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_ylim(1e-4, 1)

# Plot 2: Avoidance probability lower bound
ax2 = axes[1]
ns = range(1, 201)
for d in [2, 5, 10, 20]:
    p = 1 / (exp(1) * (d + 1))
    avoidance = [(1 - p) ** n for n in ns]
    x_witness = 1 / (d + 1)
    avoidance_witness = [(1 - x_witness) ** n for n in ns]
    ax2.semilogy(list(ns), avoidance_witness, linewidth=2, 
                label=f'd={d}, x=1/(d+1)')

ax2.set_xlabel('n (number of events)', fontsize=14)
ax2.set_ylabel('∏(1 - x_i) (avoidance bound)', fontsize=14)
ax2.set_title('LLL Avoidance Probability Lower Bound', fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('lll_conditions.png', dpi=150, bbox_inches='tight')
print("Saved lll_conditions.png")


#!/usr/bin/env python3
"""
Visualization: Erdős's Ramsey Lower Bounds

Shows the exponential growth of the Erdős bound R(k,k) > 2^{k/2}
alongside known Ramsey numbers.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, floor

def erdos_bound(k):
    return floor(2 ** (k / 2))

def erdos_expected_mono(n, k):
    """Expected number of monochromatic k-cliques in random 2-coloring of K_n."""
    return 2 * comb(n, k) * 2 ** (-comb(k, 2))

# Known Ramsey numbers
known_R = {3: 6, 4: 18}
known_R_lower = {5: 43, 6: 102, 7: 205, 8: 282, 9: 565}
known_R_upper = {5: 48, 6: 165, 7: 540, 8: 1870, 9: 6588}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Erdős bound vs known values
ax1 = axes[0]
ks = range(3, 10)
erdos_bounds = [erdos_bound(k) for k in ks]
ax1.semilogy(list(ks), erdos_bounds, 'bo-', linewidth=2, markersize=8, label='Erdős bound 2^{k/2}')

# Known exact values
exact_k = [3, 4]
exact_R = [known_R[k] for k in exact_k]
ax1.semilogy(exact_k, exact_R, 'r^', markersize=12, label='Known R(k,k)')

# Known ranges
for k in range(5, 10):
    ax1.semilogy([k, k], [known_R_lower[k], known_R_upper[k]], 'g-', linewidth=3, alpha=0.7)
    ax1.semilogy(k, known_R_lower[k], 'gv', markersize=8)
    ax1.semilogy(k, known_R_upper[k], 'g^', markersize=8)

ax1.semilogy([5], [known_R_lower[5]], 'gv', markersize=8, label='Known range')

ax1.set_xlabel('k', fontsize=14)
ax1.set_ylabel('R(k,k)', fontsize=14)
ax1.set_title("Erdős's Ramsey Lower Bound", fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Expected monochromatic cliques
ax2 = axes[1]
for k in [3, 4, 5]:
    ns = range(2, 30)
    expected = [erdos_expected_mono(n, k) for n in ns]
    ax2.semilogy(list(ns), expected, linewidth=2, label=f'k={k}')
    # Mark where expected = 1
    threshold_n = erdos_bound(k)
    ax2.axvline(x=threshold_n, color='gray', linestyle='--', alpha=0.5)

ax2.axhline(y=1, color='red', linestyle='-', linewidth=1.5, alpha=0.7, label='Threshold = 1')
ax2.set_xlabel('n (number of vertices)', fontsize=14)
ax2.set_ylabel('Expected monochromatic K_k', fontsize=14)
ax2.set_title('First Moment Method: E[mono K_k] vs n', fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(1e-3, 1e8)

plt.tight_layout()
plt.savefig('ramsey_bounds.png', dpi=150, bbox_inches='tight')
print("Saved ramsey_bounds.png")


#!/usr/bin/env python3
"""
Visualization: Turán Graph Structure

Visualizes the Turán graph T(n,2) showing its bipartite structure
and the edge count approaching n²/4.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def turan_edge_count(n, r):
    count = 0
    for i in range(n):
        for j in range(i + 1, n):
            if i % r != j % r:
                count += 1
    return count

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Edge count vs n²/4
ax1 = axes[0]
ns = range(2, 31)
actual = [turan_edge_count(n, 2) for n in ns]
formula = [n*n/4 for n in ns]
floor_formula = [n*n//4 for n in ns]

ax1.plot(list(ns), actual, 'bo-', markersize=5, label='T(n,2) edge count')
ax1.plot(list(ns), formula, 'r--', linewidth=2, label='n²/4 (continuous)')
ax1.plot(list(ns), floor_formula, 'g^', markersize=4, label='⌊n²/4⌋')
ax1.set_xlabel('n', fontsize=14)
ax1.set_ylabel('Number of edges', fontsize=14)
ax1.set_title("Turán Graph T(n,2): Edge Count", fontsize=16)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Plot 2: Edge density approaching 1/2
ax2 = axes[1]
ns_large = range(2, 101)
densities = []
for n in ns_large:
    e = turan_edge_count(n, 2)
    max_edges = n * (n - 1) / 2
    densities.append(e / max_edges if max_edges > 0 else 0)

ax2.plot(list(ns_large), densities, 'b-', linewidth=2)
ax2.axhline(y=0.5, color='red', linestyle='--', linewidth=1.5, label='Density limit = 1/2')
ax2.set_xlabel('n', fontsize=14)
ax2.set_ylabel('Edge density |E|/C(n,2)', fontsize=14)
ax2.set_title("Turán Graph Density → 1/2", fontsize=16)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(0.35, 0.55)

plt.tight_layout()
plt.savefig('turan_graph.png', dpi=150, bbox_inches='tight')
print("Saved turan_graph.png")
