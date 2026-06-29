#!/usr/bin/env python3
"""
Applications of the Canonical Path Poincaré Inequality

Shows how the certified spectral gap bound can be used for:
1. Random walk mixing time estimates
2. Expansion certification  
3. MCMC convergence guarantees
"""

import itertools
import math
from algorithms import compute_spectral_certificate, canonical_path, compose_perm, adj_transposition


def random_walk_simulation(n: int, steps: int = 1000, trials: int = 100) -> list:
    """
    Simulate the random walk on S_n with adjacent transpositions.
    Returns total variation distance from uniform at each step.
    """
    import random
    G_card = math.factorial(n)
    perms = list(itertools.permutations(range(n)))
    perm_index = {p: i for i, p in enumerate(perms)}
    
    visit_counts = [0] * G_card
    
    for _ in range(trials):
        current = tuple(range(n))  # Start at identity
        for step in range(steps):
            j = random.randint(0, n - 2)
            t = adj_transposition(n, j)
            current = compose_perm(t, current)
            visit_counts[perm_index[current]] += 1
    
    # Compute empirical distribution at each step
    total = trials * steps
    empirical = [c / total for c in visit_counts]
    uniform = 1.0 / G_card
    tv = 0.5 * sum(abs(e - uniform) for e in empirical)
    
    return tv


def expansion_certificate_demo():
    """Demonstrate expansion certification for small groups."""
    print("=" * 60)
    print("EXPANSION CERTIFICATION via Canonical Paths")
    print("=" * 60)
    
    for n in [3, 4, 5]:
        cert = compute_spectral_certificate(n)
        gap = cert['spectral_gap_lower']
        
        print(f"\nS_{n}: Certified spectral gap ≥ {gap:.4f}")
        print(f"  This guarantees:")
        print(f"  - For any subset A ⊆ S_{n} with |A| ≤ |S_{n}|/2:")
        print(f"    |∂A|/|A| ≥ {gap/2:.4f} (Cheeger-type expansion)")
        print(f"  - Random walk mixes in ≤ {cert['mixing_time_upper']:.0f} steps")
        print(f"  - L² contraction rate: ‖Af - f̄‖₂ ≤ (1-gap/|S|)·‖f - f̄‖₂")
        contraction = 1 - gap / cert['num_generators']
        print(f"    = {contraction:.6f} · ‖f - f̄‖₂")


def poincare_inequality_demo():
    """Numerically verify the Poincaré inequality for several test functions."""
    print("\n" + "=" * 60)
    print("POINCARÉ INEQUALITY VERIFICATION")
    print("=" * 60)
    
    n = 5
    cert = compute_spectral_certificate(n)
    C = cert['poincare_constant']
    perms = list(itertools.permutations(range(n)))
    
    test_functions = {
        "inversions": lambda p: sum(1 for i in range(n) for j in range(i+1,n) if p[i] > p[j]),
        "fixed_points": lambda p: sum(1 for i in range(n) if p[i] == i),
        "descent_count": lambda p: sum(1 for i in range(n-1) if p[i] > p[i+1]),
        "position_of_1": lambda p: p.index(1),
    }
    
    print(f"\nS_{n}: Poincaré constant C = {C:.6f}")
    print(f"Theorem: Var(f) ≤ C · E_S(f) for all f\n")
    
    for name, func in test_functions.items():
        f_vals = {p: float(func(p)) for p in perms}
        
        vals = list(f_vals.values())
        mean = sum(vals) / len(vals)
        var = sum((v - mean)**2 for v in vals) / len(vals)
        
        energy = 0.0
        for x in perms:
            for j in range(n - 1):
                t = adj_transposition(n, j)
                sx = compose_perm(t, x)
                energy += (f_vals[sx] - f_vals[x]) ** 2
        
        if energy > 0:
            actual_ratio = var / energy
            print(f"  f = {name}:")
            print(f"    Var(f) = {var:.4f}, E_S(f) = {energy:.4f}")
            print(f"    Var/E = {actual_ratio:.6f} ≤ C = {C:.6f}: {actual_ratio <= C + 1e-10}")


if __name__ == "__main__":
    expansion_certificate_demo()
    poincare_inequality_demo()


#!/usr/bin/env python3
"""
Canonical Path Poincaré Inequality: Interactive Demonstration

Demonstrates the Jerrum–Sinclair canonical path method applied to the
symmetric group S_n with adjacent transpositions and bubble-sort paths.

Computes:
- Maximum path length L
- Directed-edge congestion κ
- Certified spectral gap lower bound
"""

import itertools
import math
from collections import defaultdict


def compose_perm(p, q, n):
    """Compose permutations: (p∘q)(i) = p(q(i))."""
    return tuple(p[q[i]] for i in range(n))


def inverse_perm(p, n):
    """Inverse of a permutation (given as tuple)."""
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)


def identity(n):
    return tuple(range(n))


def adj_transposition(n, j):
    """Adjacent transposition (j, j+1) as a tuple."""
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)


def bubble_sort_path(sigma, n):
    """
    Compute the canonical path from id to sigma using bubble sort.
    
    Returns a list of generator indices (into adjacent transpositions)
    such that the generators' product equals sigma.
    
    Convention: path = [g₁, g₂, ..., gₖ] where gᵢ is an index into
    {0, ..., n-2} representing the transposition (gᵢ, gᵢ+1).
    path.prod = adj(g₁) * adj(g₂) * ... * adj(gₖ) = sigma.
    
    Bubble sort: sort arr = [σ(0), ..., σ(n-1)] to [0,...,n-1]
    by swapping adjacent elements. Each swap is right-multiplication
    by a transposition: σ · τ₁ · τ₂ · ... · τₖ = id.
    So σ = τₖ · ... · τ₁, and path = [τₖ, ..., τ₁] (reversed).
    """
    arr = list(sigma)
    swaps = []  # Record swap positions
    
    for i in range(n):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swaps.append(j)
    
    # σ · τ₁ · τ₂ · ... · τₖ = id
    # σ = τₖ * ... * τ₁
    # path should be [τₖ, ..., τ₁] so that path.prod = σ
    swaps.reverse()
    return swaps


def path_product(path, n):
    """Compute the product of transpositions given by gen indices."""
    result = identity(n)
    for g in path:
        t = adj_transposition(n, g)
        result = compose_perm(t, result, n)
    return result


def canonical_path_xy(x, y, n):
    """
    Canonical path from x to y.
    Returns list of generator indices.
    
    We need path.prod * x = y, so path.prod = y * x⁻¹.
    Compute δ = y * x⁻¹ and bubble-sort it.
    """
    x_inv = inverse_perm(x, n)
    delta = compose_perm(y, x_inv, n)
    return bubble_sort_path(delta, n)


def verify_path(path, x, y, n):
    """Verify path.prod * x = y using Lean's convention.
    
    path.prod = path[0] * path[1] * ... * path[k-1]
    (path.prod * x)(i) = path[0](path[1](...(path[k-1](x(i)))...))
    
    So we apply x first, then path[k-1], ..., path[0].
    """
    current = x
    for g in reversed(path):
        t = adj_transposition(n, g)
        current = compose_perm(t, current, n)
    return current == y


def compute_congestion_and_length(n):
    """
    Compute exact congestion and max path length for S_n
    with adjacent transpositions and bubble-sort canonical paths.
    """
    perms = list(itertools.permutations(range(n)))
    num_gens = n - 1
    
    max_length = 0
    
    # edge_uses[(src_perm, gen_idx)] = count of paths using this edge
    edge_uses = defaultdict(int)
    
    for x in perms:
        for y in perms:
            path = canonical_path_xy(x, y, n)
            max_length = max(max_length, len(path))
            
            # Verify path
            if not verify_path(path, x, y, n):
                print(f"ERROR: Path verification failed for x={x}, y={y}")
                prod = path_product(path, n)
                actual = compose_perm(prod, x, n)
                print(f"  path.prod = {prod}")
                print(f"  path.prod * x = {actual}")
                print(f"  expected y = {y}")
                return None
            
            # Track edges used
            # The i-th edge has source = (path[i+1:]).prod * x
            # and generator = path[i]
            # Because path.prod * x = path[0]*...*path[k-1]*x = y
            # The walk visits: x → ... 
            # Actually for edge tracking: the intermediate vertices are:
            # v₀ = x
            # v₁ = path[k-1] * x  (last gen applied first to x)
            # v₂ = path[k-2] * path[k-1] * x
            # ...
            # vₖ = path[0] * ... * path[k-1] * x = y
            # Edge i goes from vᵢ to vᵢ₊₁ via generator path[k-1-i]
            
            current = x
            for idx in range(len(path) - 1, -1, -1):
                g = path[idx]
                edge_uses[(current, g)] += 1
                t = adj_transposition(n, g)
                current = compose_perm(t, current, n)
    
    congestion = max(edge_uses.values()) if edge_uses else 0
    
    usage_values = list(edge_uses.values())
    avg_usage = sum(usage_values) / len(usage_values) if usage_values else 0
    
    return max_length, congestion, {
        'total_edges_used': len(edge_uses),
        'avg_usage': avg_usage,
    }


def dirichlet_energy(f_vals, perms, n):
    """E_S(f) = ∑_x ∑_{s∈S} (f(sx) - f(x))²."""
    energy = 0.0
    for x in perms:
        for j in range(n - 1):
            t = adj_transposition(n, j)
            sx = compose_perm(t, x, n)
            energy += (f_vals[sx] - f_vals[x]) ** 2
    return energy


def variance_fn(f_vals, perms):
    """Var(f) = (1/|G|) ∑_x (f(x) - mean)²."""
    vals = [f_vals[x] for x in perms]
    N = len(vals)
    mean = sum(vals) / N
    return sum((v - mean) ** 2 for v in vals) / N


def main():
    print("=" * 70)
    print("CANONICAL PATH POINCARÉ INEQUALITY")
    print("Certified Spectral Gap via Combinatorial Routing")
    print("=" * 70)
    
    results = {}
    
    for n in [3, 4, 5]:
        print(f"\n{'─' * 70}")
        print(f"  Symmetric Group S_{n}")
        G_card = math.factorial(n)
        S_card = n - 1  # adjacent transpositions (self-inverse)
        print(f"  |S_{n}| = {G_card},  |S| = {S_card} generators")
        print(f"{'─' * 70}")
        
        result = compute_congestion_and_length(n)
        if result is None:
            continue
        
        L, kappa, stats = result
        results[n] = (L, kappa)
        
        print(f"\n  Canonical path data (bubble-sort paths):")
        print(f"    Max path length L = {L}")
        print(f"    Max inversions = {n*(n-1)//2}")
        print(f"    Directed-edge congestion κ = {kappa}")
        print(f"    Distinct edges used: {stats['total_edges_used']}")
        print(f"    Average edge usage: {stats['avg_usage']:.2f}")
        
        # Certified spectral gap lower bound
        if kappa > 0 and L > 0:
            # From Theorem 2: Var(f) ≤ (κ·L)/(2·|G|²) · E_S(f)
            poincare_const = kappa * L / (2.0 * G_card**2)
            
            # Spectral gap: E/(|S|·Var) ≥ 2|G|²/(|S|·κ·L)
            gap_lower = 2.0 * G_card**2 / (S_card * kappa * L)
            
            print(f"\n  ✓ CERTIFIED Poincaré inequality (Theorem 2):")
            print(f"    Var(f) ≤ {poincare_const:.8f} · E_S(f)")
            print(f"    = (κ·L)/(2·|G|²) · E_S(f)")
            print(f"    = ({kappa}·{L})/(2·{G_card}²) · E_S(f)")
            
            print(f"\n  ✓ CERTIFIED spectral gap (Theorem 3):")
            print(f"    E(f)/(|S|·Var(f)) ≥ {gap_lower:.6f}")
            print(f"    = 2·{G_card}²/({S_card}·{kappa}·{L})")
            
            # Mixing time
            mix_bound = kappa * L / (2.0 * G_card) * math.log(G_card)
            print(f"\n  ✓ Mixing time bound:")
            print(f"    t_mix ≤ O(κ·L/(2|G|)·log|G|) ≈ {mix_bound:.1f}")
        
        # Numerical verification
        print(f"\n  Numerical verification:")
        perms = list(itertools.permutations(range(n)))
        
        # Test function: number of inversions
        f_inv = {}
        for x in perms:
            inversions = sum(1 for i in range(n) for j in range(i+1, n) if x[i] > x[j])
            f_inv[x] = float(inversions)
        
        E = dirichlet_energy(f_inv, perms, n)
        V = variance_fn(f_inv, perms)
        
        if V > 0:
            ratio = E / (S_card * V)
            print(f"    f = number of inversions")
            print(f"    E_S(f) = {E:.4f}")
            print(f"    Var(f) = {V:.4f}")
            print(f"    E/(|S|·Var) = {ratio:.6f}")
            print(f"    Lower bound = {gap_lower:.6f}")
            satisfied = ratio >= gap_lower * 0.9999
            print(f"    Bound satisfied: {satisfied}")
    
    # Congestion conjecture
    print(f"\n{'=' * 70}")
    print("CONJECTURE: Bubble-sort congestion polynomial bound")
    print("=" * 70)
    print("\nFor S_n with adjacent transpositions, bubble-sort canonical paths:")
    print("  κ(S_n) ≤ C · n⁴  (conjectured)")
    print("\nComputed values:")
    for n_val in sorted(results.keys()):
        L_val, k_val = results[n_val]
        ratio = k_val / n_val**4 if n_val > 0 else 0
        print(f"  n={n_val}: L={L_val}, κ={k_val}, κ/n⁴={ratio:.6f}")
    
    if len(results) >= 2:
        ns = sorted(results.keys())
        n1, n2 = ns[-2], ns[-1]
        k1, k2 = results[n1][1], results[n2][1]
        if k1 > 0 and k2 > 0:
            growth = math.log(k2/k1) / math.log(n2/n1)
            print(f"\n  Estimated growth exponent: {growth:.2f}")
            print(f"  (Conjecture: exponent ≤ 4)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Edge Congestion Heatmap for Canonical Paths on S_n

Visualizes the distribution of edge congestion across different generators
and source vertices in the Cayley graph, showing how bubble-sort canonical
paths distribute load across the network.
"""

import itertools
import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def adj_transposition(n, j):
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)

def bubble_sort_path(sigma):
    n = len(sigma)
    arr = list(sigma)
    swaps = []
    for i in range(n):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swaps.append(j)
    swaps.reverse()
    return swaps

def canonical_path(x, y):
    x_inv = inverse_perm(x)
    delta = compose_perm(y, x_inv)
    return bubble_sort_path(delta)


def compute_edge_congestion_matrix(n):
    """Compute congestion matrix: rows = permutations, cols = generators."""
    perms = list(itertools.permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    num_gens = n - 1
    G_card = len(perms)
    
    matrix = np.zeros((G_card, num_gens))
    
    for x in perms:
        for y in perms:
            path = canonical_path(x, y)
            current = x
            for idx in range(len(path) - 1, -1, -1):
                g = path[idx]
                src_idx = perm_to_idx[current]
                matrix[src_idx, g] += 1
                t = adj_transposition(n, g)
                current = compose_perm(t, current)
    
    return matrix, perms


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Edge Congestion in Canonical Path Systems on Sₙ', fontsize=16, fontweight='bold')
    
    for plot_idx, n in enumerate([3, 4, 5]):
        ax = axes[plot_idx]
        matrix, perms = compute_edge_congestion_matrix(n)
        
        # Aggregate by generator (show distribution of congestion per generator)
        congestion_per_gen = matrix.max(axis=0)
        avg_per_gen = matrix.mean(axis=0)
        
        gen_labels = [f'({j},{j+1})' for j in range(n-1)]
        x_pos = np.arange(n-1)
        width = 0.35
        
        bars1 = ax.bar(x_pos - width/2, congestion_per_gen, width, label='Max congestion', color='#e74c3c', alpha=0.8)
        bars2 = ax.bar(x_pos + width/2, avg_per_gen, width, label='Avg congestion', color='#3498db', alpha=0.8)
        
        ax.set_xlabel('Generator (transposition)', fontsize=12)
        ax.set_ylabel('Edge usage count', fontsize=12)
        ax.set_title(f'S_{n} (|G|={math.factorial(n)})', fontsize=14)
        ax.set_xticks(x_pos)
        ax.set_xticklabels(gen_labels)
        ax.legend(fontsize=10)
        
        # Add text annotations
        for bar in bars1:
            height = bar.get_height()
            ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width()/2, height),
                       xytext=(0, 3), textcoords="offset points", ha='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('congestion_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved congestion_heatmap.png")
    
    # Second figure: congestion growth
    fig2, ax2 = plt.subplots(figsize=(8, 6))
    ns = [3, 4, 5]
    kappas = []
    Ls = []
    
    for n in ns:
        matrix, _ = compute_edge_congestion_matrix(n)
        kappa = int(matrix.max())
        L = n * (n - 1) // 2
        kappas.append(kappa)
        Ls.append(L)
    
    ax2.semilogy(ns, kappas, 'ro-', linewidth=2, markersize=10, label='Congestion κ')
    ax2.semilogy(ns, [n**4 * 0.3 for n in ns], 'b--', linewidth=1, label='0.3·n⁴ (reference)')
    ax2.semilogy(ns, [n**8 * 0.0001 for n in ns], 'g--', linewidth=1, label='10⁻⁴·n⁸ (reference)')
    
    ax2.set_xlabel('n', fontsize=14)
    ax2.set_ylabel('Congestion κ', fontsize=14)
    ax2.set_title('Congestion Growth for Bubble-Sort Paths on Sₙ', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('congestion_growth.png', dpi=150, bbox_inches='tight')
    print("Saved congestion_growth.png")


if __name__ == "__main__":
    main()
