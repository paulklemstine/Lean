#!/usr/bin/env python3
"""
Fitness Landscape Demo — Ecological Niche Theory of Mathematics

Demonstrates the core concepts:
1. Fitness landscapes with local optima (mathematical "styles")
2. Valley crossing between optima
3. Mediant composition of proof modules
4. Max-min tropical algebra for bottleneck paths
"""

import random
import math

# ─── 1. Fitness Landscape on a Graph ────────────────────────────────────────

def make_path_landscape(n, fitnesses):
    """Create a path graph P_n with given fitness values."""
    adj = {i: [] for i in range(n)}
    for i in range(n - 1):
        adj[i].append(i + 1)
        adj[i + 1].append(i)
    return adj, fitnesses

def find_local_optima(adj, fitness):
    """Find all local optima (vertices better than all neighbors)."""
    optima = []
    for v in adj:
        if all(fitness[v] >= fitness[u] for u in adj[v]):
            optima.append(v)
    return optima

def find_strict_local_optima(adj, fitness):
    """Find all strict local optima (vertices strictly better than all neighbors)."""
    return [v for v in adj if all(fitness[v] > fitness[u] for u in adj[v])]

def walk_min_fitness(fitness, walk):
    """Compute the minimum fitness along a walk."""
    return min(fitness[v] for v in walk)

def valley_depth(fitness, walk):
    """Compute the valley depth: how far below min(f(start), f(end)) the walk dips."""
    if len(walk) < 2:
        return 0
    endpoint_min = min(fitness[walk[0]], fitness[walk[-1]])
    return endpoint_min - walk_min_fitness(fitness, walk)


print("=" * 60)
print("DEMO 1: Fitness Landscape — Path Graph P₅")
print("=" * 60)

# Path graph with 5 vertices: algebraic, transitional, analytic, transitional, combinatorial
labels = ["Algebraic", "Trans-1", "Analytic", "Trans-2", "Combinatorial"]
fitnesses = {0: 8.0, 1: 3.0, 2: 7.0, 3: 2.0, 4: 9.0}
adj, fit = make_path_landscape(5, fitnesses)

print("\nLandscape: A — T₁ — An — T₂ — C")
for i in range(5):
    print(f"  {labels[i]:15s}: fitness = {fit[i]:.1f}")

optima = find_local_optima(adj, fit)
strict = find_strict_local_optima(adj, fit)
print(f"\nLocal optima: {[labels[i] for i in optima]}")
print(f"Strict local optima: {[labels[i] for i in strict]}")

# Walk from Algebraic to Combinatorial
walk = [0, 1, 2, 3, 4]
wmin = walk_min_fitness(fit, walk)
vd = valley_depth(fit, walk)
print(f"\nWalk A → T₁ → An → T₂ → C:")
print(f"  Min fitness along walk: {wmin:.1f}")
print(f"  min(f(A), f(C)) = min({fit[0]:.1f}, {fit[4]:.1f}) = {min(fit[0], fit[4]):.1f}")
print(f"  Valley depth: {vd:.1f}")
print(f"  Valley crossing theorem confirmed: {wmin} < {min(fit[0], fit[4])} → {wmin < min(fit[0], fit[4])}")


# ─── 2. Module Composition ──────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 2: Mediant Inequality & Module Composition")
print("=" * 60)

class ProofModule:
    def __init__(self, name, theorems, complexity):
        self.name = name
        self.theorems = theorems
        self.complexity = complexity
        self.fitness = theorems / complexity

    def __repr__(self):
        return f"{self.name}(thms={self.theorems}, loc={self.complexity}, f={self.fitness:.4f})"

def compose(m1, m2, shared_thms=0, shared_code=0):
    t = m1.theorems + m2.theorems - shared_thms
    c = m1.complexity + m2.complexity - shared_code
    return ProofModule(f"{m1.name}⊕{m2.name}", t, c)


# Example: Two mathematical libraries
algebra = ProofModule("Algebra", theorems=150, complexity=2000)
analysis = ProofModule("Analysis", theorems=120, complexity=3000)

print(f"\n{algebra}")
print(f"{analysis}")

naive = compose(algebra, analysis)
print(f"\nNaive composition (no sharing): {naive}")
print(f"  min fitness = {min(algebra.fitness, analysis.fitness):.4f}")
print(f"  composite fitness = {naive.fitness:.4f}")
print(f"  max fitness = {max(algebra.fitness, analysis.fitness):.4f}")
print(f"  Mediant bound holds: {min(algebra.fitness, analysis.fitness) <= naive.fitness <= max(algebra.fitness, analysis.fitness)}")

shared = compose(algebra, analysis, shared_code=800)
print(f"\nWith shared infrastructure (800 LOC): {shared}")
print(f"  Fitness improvement: {shared.fitness:.4f} > {naive.fitness:.4f} → {shared.fitness > naive.fitness}")


# ─── 3. Max-Min Tropical Algebra ────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 3: Max-Min Tropical Algebra for Bottleneck Paths")
print("=" * 60)

NEG_INF = float('-inf')

def maxmin_mul(A, B, n):
    """Max-min matrix multiplication: C[i][j] = max_k min(A[i][k], B[k][j])"""
    C = [[NEG_INF]*n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = max(C[i][j], min(A[i][k], B[k][j]))
    return C

def bottleneck_matrix(adj, fitness, n):
    """Construct the bottleneck matrix from a landscape."""
    M = [[NEG_INF]*n for _ in range(n)]
    for i in range(n):
        M[i][i] = fitness[i]
        for j in adj[i]:
            M[i][j] = min(fitness[i], fitness[j])
    return M

def print_matrix(M, n, labels=None):
    if labels:
        print("     " + "  ".join(f"{l[:4]:>4s}" for l in labels))
    for i in range(n):
        row = "  ".join(f"{M[i][j]:4.0f}" if M[i][j] != NEG_INF else " -∞ " for j in range(n))
        prefix = f"{labels[i][:4]:>4s}" if labels else f"  {i}"
        print(f"  {prefix}: [{row}]")


n = 5
B = bottleneck_matrix(adj, fit, n)
print("\nInitial bottleneck matrix B:")
print_matrix(B, n, labels=labels)

# Compute B², B³, B⁴ in max-min algebra
B2 = maxmin_mul(B, B, n)
B3 = maxmin_mul(B2, B, n)
B4 = maxmin_mul(B3, B, n)

print("\nB⁴ (converged — optimal bottleneck values):")
print_matrix(B4, n, labels=labels)

print(f"\nBest bottleneck path Algebraic → Combinatorial: {B4[0][4]:.0f}")
print(f"Best bottleneck path Analytic → Algebraic: {B4[2][0]:.0f}")
print(f"\nConvergence check (B³ = B⁴): {B3 == B4}")


# ─── 4. Distributivity Demo ─────────────────────────────────────────────────

print("\n" + "=" * 60)
print("DEMO 4: Max-Min Distributivity (Tropical Semiring Law)")
print("=" * 60)

a, b, c = 5, 3, 7

lhs = min(a, max(b, c))
rhs = max(min(a, b), min(a, c))
print(f"\nmin({a}, max({b}, {c})) = min({a}, {max(b,c)}) = {lhs}")
print(f"max(min({a},{b}), min({a},{c})) = max({min(a,b)}, {min(a,c)}) = {rhs}")
print(f"Distributivity: {lhs} = {rhs} → {lhs == rhs}")

print("\n" + "=" * 60)
print("All demos completed successfully!")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Fitness Landscape with Valley Crossing

A standalone matplotlib visualization showing:
1. A fitness landscape on a graph
2. Local optima highlighted
3. Valley crossing paths between optima
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def create_fitness_landscape_viz():
    """Create a visualization of the fitness landscape and valley crossing theorem."""

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Fitness Landscape Theory: Mathematical Styles as Ecological Niches",
                 fontsize=14, fontweight='bold')

    # ─── Panel 1: Path landscape with valley ────────────────────────────
    ax = axes[0, 0]
    labels = ["Algebraic", "Hybrid\nAlg-An", "Analytic", "Hybrid\nAn-Comb", "Combinat."]
    fitnesses = [8, 3, 7, 2, 9]
    x = np.arange(5)

    colors = ['#e74c3c' if f == max(fitnesses[max(0,i-1):min(5,i+2)]) else '#95a5a6'
              for i, f in enumerate(fitnesses)]
    # Mark local optima
    optima = []
    for i in range(5):
        neighbors = []
        if i > 0: neighbors.append(fitnesses[i-1])
        if i < 4: neighbors.append(fitnesses[i+1])
        if all(fitnesses[i] > n for n in neighbors):
            optima.append(i)
            colors[i] = '#e74c3c'
        else:
            colors[i] = '#3498db'

    bars = ax.bar(x, fitnesses, color=colors, edgecolor='black', linewidth=1.2, width=0.6)
    ax.plot(x, fitnesses, 'k--', alpha=0.3, linewidth=1)

    # Valley annotation
    valley_min = min(fitnesses)
    valley_idx = fitnesses.index(valley_min)
    ax.annotate('Valley\n(fitness dip)', xy=(valley_idx, valley_min),
                xytext=(valley_idx+0.5, valley_min+1.5),
                arrowprops=dict(arrowstyle='->', color='#e67e22', lw=2),
                fontsize=9, color='#e67e22', fontweight='bold')

    ax.set_xticks(x)
    ax.set_xticklabels(labels, fontsize=8)
    ax.set_ylabel("Fitness (theorems/LOC)")
    ax.set_title("A. Fitness Landscape on Path Graph", fontsize=11)

    red_patch = mpatches.Patch(color='#e74c3c', label='Local optima')
    blue_patch = mpatches.Patch(color='#3498db', label='Non-optima')
    ax.legend(handles=[red_patch, blue_patch], loc='upper left', fontsize=8)

    # ─── Panel 2: Mediant inequality ────────────────────────────────────
    ax = axes[0, 1]
    # Show how composition fitness lies between individual fitnesses
    modules = [
        ("Algebra", 150, 2000),
        ("Analysis", 120, 3000),
        ("Topology", 80, 1500),
    ]

    pairs = [(0, 1), (0, 2), (1, 2)]
    y_pos = np.arange(len(pairs))

    for idx, (i, j) in enumerate(pairs):
        name_i, t_i, c_i = modules[i]
        name_j, t_j, c_j = modules[j]
        f_i = t_i / c_i
        f_j = t_j / c_j
        f_med = (t_i + t_j) / (c_i + c_j)

        lo, hi = min(f_i, f_j), max(f_i, f_j)
        ax.barh(idx, hi - lo, left=lo, height=0.3, color='#ecf0f1', edgecolor='#bdc3c7')
        ax.plot(f_i, idx, 'o', color='#e74c3c', markersize=10, zorder=5)
        ax.plot(f_j, idx, 's', color='#3498db', markersize=10, zorder=5)
        ax.plot(f_med, idx, 'D', color='#2ecc71', markersize=10, zorder=5)

    ax.set_yticks(y_pos)
    ax.set_yticklabels([f"{modules[i][0][:3]}⊕{modules[j][0][:3]}" for i, j in pairs])
    ax.set_xlabel("Fitness")
    ax.set_title("B. Mediant Inequality: Composition Bounds", fontsize=11)

    legend_elements = [
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor='#e74c3c',
                   markersize=10, label='Module 1'),
        plt.Line2D([0], [0], marker='s', color='w', markerfacecolor='#3498db',
                   markersize=10, label='Module 2'),
        plt.Line2D([0], [0], marker='D', color='w', markerfacecolor='#2ecc71',
                   markersize=10, label='Composition'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=8)

    # ─── Panel 3: Sharing superadditivity ───────────────────────────────
    ax = axes[1, 0]
    base_t1, base_c1 = 150, 2000
    base_t2, base_c2 = 120, 3000
    shared_range = np.arange(0, 1500, 50)

    f_naive = (base_t1 + base_t2) / (base_c1 + base_c2)
    f_shared = [(base_t1 + base_t2) / (base_c1 + base_c2 - s)
                for s in shared_range]

    ax.plot(shared_range, f_shared, color='#2ecc71', linewidth=2, label='With sharing')
    ax.axhline(y=f_naive, color='#e74c3c', linestyle='--', label='Naive composition')
    ax.axhline(y=base_t1/base_c1, color='#3498db', linestyle=':', alpha=0.7, label='f(Algebra)')
    ax.axhline(y=base_t2/base_c2, color='#9b59b6', linestyle=':', alpha=0.7, label='f(Analysis)')

    ax.fill_between(shared_range, f_naive, f_shared, alpha=0.15, color='#2ecc71')
    ax.set_xlabel("Shared infrastructure (LOC)")
    ax.set_ylabel("Composite fitness")
    ax.set_title("C. Superadditivity from Infrastructure Sharing", fontsize=11)
    ax.legend(fontsize=8)

    # ─── Panel 4: Max-min convergence ───────────────────────────────────
    ax = axes[1, 1]

    # Simulate bottleneck convergence on a random graph
    np.random.seed(42)
    n = 6
    fitness_vals = np.random.uniform(2, 10, n)

    # Random connected graph
    adj_matrix = np.zeros((n, n))
    for i in range(n - 1):
        adj_matrix[i][i+1] = 1
        adj_matrix[i+1][i] = 1
    # Add some random edges
    for _ in range(3):
        i, j = np.random.randint(0, n, 2)
        if i != j:
            adj_matrix[i][j] = 1
            adj_matrix[j][i] = 1

    # Initial bottleneck matrix
    B = np.full((n, n), -np.inf)
    for i in range(n):
        B[i][i] = fitness_vals[i]
        for j in range(n):
            if adj_matrix[i][j]:
                B[i][j] = min(fitness_vals[i], fitness_vals[j])

    # Track convergence of B^k[0][n-1]
    powers = list(range(1, n + 2))
    values = []
    current = np.eye(n) * np.inf
    for k in powers:
        new = np.full((n, n), -np.inf)
        for i in range(n):
            for j in range(n):
                for l in range(n):
                    new[i][j] = max(new[i][j], min(current[i][l], B[l][j]))
        current = new
        values.append(current[0][n-1])

    ax.plot(powers, values, 'o-', color='#e74c3c', linewidth=2, markersize=8)
    ax.axhline(y=values[-1], color='#2ecc71', linestyle='--', alpha=0.7,
               label=f'Converged value = {values[-1]:.1f}')
    ax.set_xlabel("Matrix power k")
    ax.set_ylabel("Bottleneck value B^k[0,n-1]")
    ax.set_title("D. Tropical Matrix Power Convergence", fontsize=11)
    ax.legend(fontsize=8)
    ax.set_xticks(powers)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/fitness_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved fitness_landscape.png")


if __name__ == "__main__":
    create_fitness_landscape_viz()
