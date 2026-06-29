#!/usr/bin/env python3
"""
Max-Plus Spectral Theory: Interactive Demonstrations

Demonstrates the core results of tropical Perron-Frobenius theory:
1. Max-plus matrix multiplication and eigenvectors
2. Spectral radius = maximal cycle mean
3. Asymptotic growth of tropical matrix powers
4. EML spectral duality via tropical characters
5. Karp's algorithm for efficient spectral radius computation
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import permutations
from typing import List, Tuple
import os

# ============================================================
# Core max-plus operations
# ============================================================

def max_plus_mul(M, x):
    """Max-plus matrix-vector multiplication: (M ⊗ x)_i = max_j(M_ij + x_j)"""
    n = M.shape[0]
    result = np.full(n, -np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = max(result[i], M[i, j] + x[j])
    return result

def max_plus_mat_mul(A, B):
    """Max-plus matrix-matrix multiplication."""
    n = A.shape[0]
    C = np.full((n, n), -np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C

def max_plus_pow(M, k):
    """Compute the k-th tropical power of M (k >= 1)."""
    result = M.copy()
    for _ in range(k - 1):
        result = max_plus_mat_mul(M, result)
    return result

# ============================================================
# Cycle mean computation
# ============================================================

def all_simple_cycles(n):
    """Generate all simple directed cycles in complete graph on n vertices."""
    cycles = []
    for i in range(n):
        cycles.append([i])  # Self-loops
    for length in range(2, n + 1):
        for perm in permutations(range(n), length):
            if perm[0] == min(perm):
                cycles.append(list(perm))
    return cycles

def cycle_weight(M, cycle):
    """Weight of a directed cycle."""
    w = 0.0
    for k in range(len(cycle)):
        i, j = cycle[k], cycle[(k + 1) % len(cycle)]
        w += M[i, j]
    return w

def cycle_mean(M, cycle):
    return cycle_weight(M, cycle) / len(cycle)

def max_cycle_mean(M):
    """Compute maximal cycle mean and critical cycle."""
    n = M.shape[0]
    cycles = all_simple_cycles(n)
    best_mean, best_cycle = -np.inf, []
    for c in cycles:
        mu = cycle_mean(M, c)
        if mu > best_mean:
            best_mean, best_cycle = mu, c
    return best_mean, best_cycle

# ============================================================
# Eigenvector computation
# ============================================================

def compute_eigenvector_simple(M, mu, max_iter=500):
    """Simple iterative eigenvector computation with normalization."""
    n = M.shape[0]
    W = M - mu
    v = np.zeros(n)
    for _ in range(max_iter):
        v_new = np.full(n, -np.inf)
        for i in range(n):
            for j in range(n):
                v_new[i] = max(v_new[i], W[i, j] + v[j])
        v_new -= v_new[0]  # Normalize
        # Check eigenvector equation
        Mv = max_plus_mul(M, v_new)
        residual = np.max(np.abs(Mv - (mu + v_new)))
        if residual < 1e-10:
            return v_new
        # Damped update to handle oscillation
        # Take componentwise max of v and v_new (tropical sum)
        v = np.maximum(v, v_new)
        v -= v[0]
    return v

def compute_eigenvector(M, mu):  
    """Compute eigenvector via Howard's policy iteration.
    
    Given μ = max cycle mean, find v with max_j(M[i,j] + v[j]) = μ + v[i].
    Uses policy iteration: pick argmax columns, solve the linear system,
    and iterate until stable.
    """
    n = M.shape[0]
    W = M - mu  # Reduced weights: all cycles have weight ≤ 0
    
    # Initialize policy: each row picks the argmax column
    sigma = np.argmax(W, axis=1)
    
    for _ in range(n * n + 10):
        # Solve the system: v[i] - v[sigma[i]] = W[i, sigma[i]]
        # with normalization v[0] = 0
        # This is a system on the functional graph of sigma.
        # Solve by following chains from each vertex.
        v = np.zeros(n)
        # Build the functional graph and solve for each component
        visited = np.full(n, False)
        for start in range(n):
            if visited[start]:
                continue
            # Follow the chain from start until we find a cycle
            chain = []
            current = start
            while current not in chain and not visited[current]:
                chain.append(current)
                current = sigma[current]
            if visited[current]:
                # Chain connects to an already-solved component
                # Solve backwards from the connection point
                for idx in reversed(range(len(chain))):
                    node = chain[idx]
                    v[node] = W[node, sigma[node]] + v[sigma[node]]
                    visited[node] = True
            else:
                # Found a new cycle
                cycle_start = chain.index(current)
                cycle = chain[cycle_start:]
                # In the cycle, set v values by accumulating weights
                # The cycle sum should be 0 (since mu = max cycle mean)
                v[cycle[0]] = 0
                for k in range(1, len(cycle)):
                    v[cycle[k]] = v[cycle[k-1]] - W[cycle[k-1], sigma[cycle[k-1]]]
                    # Actually: v[cycle[k-1]] = W[..] + v[sigma[cycle[k-1]]] = W[..] + v[cycle[k]]
                # Redo: from the relation v[i] = W[i, sigma[i]] + v[sigma[i]]
                v[cycle[0]] = 0
                for k in range(len(cycle)):
                    node = cycle[k]
                    next_node = sigma[node]
                    if next_node in cycle:
                        next_idx = cycle.index(next_node)
                        if next_idx > k:  # Not yet set
                            v[next_node] = v[node] - W[node, sigma[node]]
                # Better: traverse the cycle and set relative values
                v[cycle[0]] = 0
                for k in range(len(cycle) - 1):
                    v[sigma[cycle[k]]] = v[cycle[k]] - W[cycle[k], sigma[cycle[k]]]
                for node in cycle:
                    visited[node] = True
                # Solve the chain before the cycle
                for idx in reversed(range(cycle_start)):
                    node = chain[idx]
                    v[node] = W[node, sigma[node]] + v[sigma[node]]
                    visited[node] = True
        
        # Normalize
        v = v - v[0]
        
        # Check if this v is actually an eigenvector
        # Update policy: for each row, pick the new argmax
        new_sigma = np.zeros(n, dtype=int)
        is_eigenvector = True
        for i in range(n):
            best_val = -np.inf
            best_j = 0
            for j in range(n):
                val = W[i, j] + v[j]
                if val > best_val:
                    best_val = val
                    best_j = j
            new_sigma[i] = best_j
            if abs(best_val - v[i]) > 1e-10:
                is_eigenvector = False
        
        if is_eigenvector:
            break
        sigma = new_sigma
    
    return v

def compute_eigenvector_best(M, mu):
    """Try multiple methods and return the best eigenvector."""
    v1 = compute_eigenvector_simple(M, mu)
    e1 = verify_eigenvector(M, mu, v1)
    if e1 < 1e-10:
        return v1
    v2 = compute_eigenvector(M, mu)
    e2 = verify_eigenvector(M, mu, v2)
    return v1 if e1 < e2 else v2

def verify_eigenvector(M, mu, v):
    """Returns max absolute error of eigenvector equation."""
    Mv = max_plus_mul(M, v)
    return np.max(np.abs(Mv - (mu + v)))

# ============================================================
# Karp's algorithm
# ============================================================

def karp_max_cycle_mean(M):
    """O(n³) computation of max cycle mean via Karp's algorithm."""
    n = M.shape[0]
    D = np.full((n + 1, n), -np.inf)
    D[0, :] = 0
    for k in range(1, n + 1):
        for j in range(n):
            for i in range(n):
                D[k, j] = max(D[k, j], D[k-1, i] + M[i, j])
    mu = -np.inf
    for j in range(n):
        local_min = np.inf
        for k in range(n):
            if D[n, j] > -np.inf and D[k, j] > -np.inf:
                val = (D[n, j] - D[k, j]) / (n - k)
                local_min = min(local_min, val)
        if local_min < np.inf:
            mu = max(mu, local_min)
    return mu

# ============================================================
# Demonstrations
# ============================================================

def demo_eigenvector():
    print("=" * 60)
    print("DEMO 1: Max-Plus Eigenvectors")
    print("=" * 60)

    examples = [
        ("2×2 symmetric", np.array([[3, 1], [1, 3]], dtype=float)),
        ("2×2 asymmetric", np.array([[3, 1], [0, 2]], dtype=float)),
        ("2×2 off-diagonal", np.array([[0, 5], [5, 0]], dtype=float)),
        ("3×3 matrix", np.array([[1, 3, 0], [2, 0, 4], [3, 1, 2]], dtype=float)),
        ("4×4 Hamiltonian", np.array([
            [0, 2, -1, 3], [1, 0, 4, -2],
            [3, -1, 0, 2], [-2, 1, 3, 0]], dtype=float)),
    ]

    for name, M in examples:
        mu, cc = max_cycle_mean(M)
        v = compute_eigenvector_best(M, mu)
        err = verify_eigenvector(M, mu, v)
        Mv = max_plus_mul(M, v)
        print(f"\n{name}:")
        print(f"  μ = {mu:.4f}, critical cycle = {cc}")
        print(f"  v = {np.round(v, 4)}")
        print(f"  M⊗v = {np.round(Mv, 4)}")
        print(f"  μ+v = {np.round(mu + v, 4)}")
        print(f"  error = {err:.2e}")


def demo_spectral_growth():
    print("\n" + "=" * 60)
    print("DEMO 2: Spectral Growth of Tropical Powers")
    print("=" * 60)

    M = np.array([[1, 3, 0], [2, 0, 4], [3, 1, 2]], dtype=float)
    mu, cc = max_cycle_mean(M)
    print(f"M =\n{M}")
    print(f"μ = {mu:.4f}, critical cycle = {cc}")

    ks = list(range(1, 31))
    max_entries = [np.max(max_plus_pow(M, k)) for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.plot(ks, max_entries, 'b.-', label='maxEntry(M^k)', markersize=4)
    ax1.plot(ks, [k * mu for k in ks], 'r--', label=f'k·μ = k·{mu:.2f}')
    ax1.set_xlabel('k'); ax1.set_ylabel('Maximum entry')
    ax1.set_title('Growth of max entry of tropical powers')
    ax1.legend(); ax1.grid(True, alpha=0.3)

    devs = [max_entries[i] - ks[i] * mu for i in range(len(ks))]
    ax2.plot(ks, devs, 'g.-', markersize=4)
    ax2.axhline(y=0, color='k', linestyle='-', linewidth=0.5)
    ax2.set_xlabel('k'); ax2.set_ylabel('maxEntry(M^k) - k·μ')
    ax2.set_title('Bounded deviation from linear growth')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/spectral_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Bounded defect: deviations in [{min(devs):.4f}, {max(devs):.4f}]")
    print("Saved: demos/spectral_growth.png")


def demo_eigencharacter():
    print("\n" + "=" * 60)
    print("DEMO 3: Eigencharacter & Spectral Duality")
    print("=" * 60)

    M = np.array([[2, 5, 1], [3, 0, 4], [1, 3, 2]], dtype=float)
    mu, _ = max_cycle_mean(M)
    mu_T, _ = max_cycle_mean(M.T)
    w = compute_eigenvector_best(M.T, mu_T)

    print(f"M =\n{M}")
    print(f"μ = {mu:.4f}, left eigenvector w = {np.round(w, 4)}")
    print(f"\nVerifying χ(M⊗x) = μ + χ(x) for random x:")

    np.random.seed(42)
    max_error = 0
    for trial in range(10):
        x = np.random.randn(3) * 5
        chi_x = np.max(x + w)
        Mx = max_plus_mul(M, x)
        chi_Mx = np.max(Mx + w)
        expected = mu_T + chi_x
        error = abs(chi_Mx - expected)
        max_error = max(max_error, error)
        if trial < 5:
            print(f"  x={np.round(x,2)}: χ(M⊗x)={chi_Mx:.4f}, μ+χ(x)={expected:.4f}, err={error:.1e}")
    print(f"  Max error: {max_error:.2e}")

    print("\nIterate spectral law: χ(T^k x) = k·μ + χ(x)")
    x0 = np.array([1.0, 0.0, -1.0])
    chi_x0 = np.max(x0 + w)
    x = x0.copy()
    for k in range(1, 8):
        x = max_plus_mul(M, x)
        chi_k = np.max(x + w)
        print(f"  k={k}: χ(T^{k}x₀)={chi_k:.4f}, {k}·μ+χ(x₀)={k*mu_T+chi_x0:.4f}")


def demo_critical_graph():
    print("\n" + "=" * 60)
    print("DEMO 4: Critical Graph Visualization")
    print("=" * 60)

    M = np.array([
        [0, 3, -1, 2], [1, 0, 4, -2],
        [2, -1, 0, 3], [-2, 2, 1, 0]], dtype=float)
    n = M.shape[0]
    mu, cc = max_cycle_mean(M)
    v = compute_eigenvector_best(M, mu)

    print(f"M =\n{M}")
    print(f"μ = {mu:.4f}, critical cycle = {cc}")
    print(f"v = {np.round(v, 4)}, error = {verify_eigenvector(M, mu, v):.2e}")

    # Critical edges
    tol = 1e-8
    critical_edges = [(i, j) for i in range(n) for j in range(n)
                      if abs(M[i,j] + v[j] - (mu + v[i])) < tol]
    print(f"Critical edges: {critical_edges}")

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, n, endpoint=False)
    pos = {i: (np.cos(t), np.sin(t)) for i, t in enumerate(theta)}

    for i in range(n):
        for j in range(n):
            if i != j:
                is_crit = (i, j) in critical_edges
                color = 'red' if is_crit else 'lightgray'
                width = 2.5 if is_crit else 0.5
                ax.annotate('', xy=pos[j], xytext=pos[i],
                          arrowprops=dict(arrowstyle='->', color=color,
                                        lw=width, connectionstyle='arc3,rad=0.15'))
    for i in range(n):
        circle = plt.Circle(pos[i], 0.12, color='steelblue', zorder=5)
        ax.add_patch(circle)
        ax.text(*pos[i], str(i), ha='center', va='center',
               fontsize=12, fontweight='bold', color='white', zorder=6)
        ax.text(pos[i][0], pos[i][1]-0.22, f'v={v[i]:.1f}',
               ha='center', va='top', fontsize=8, color='navy')
    ax.set_xlim(-1.6, 1.6); ax.set_ylim(-1.6, 1.6)
    ax.set_aspect('equal'); ax.set_title(f'Weighted digraph (μ={mu:.2f})\nRed=critical edges'); ax.axis('off')

    ax = axes[1]
    ks = list(range(1, 20))
    for i in range(n):
        for j in range(n):
            entries = [max_plus_pow(M, k)[i, j] for k in ks]
            ax.plot(ks, entries, alpha=0.3, linewidth=0.8)
    max_es = [np.max(max_plus_pow(M, k)) for k in ks]
    ax.plot(ks, max_es, 'k-', linewidth=2, label='maxEntry(M^k)')
    ax.plot(ks, [k*mu for k in ks], 'r--', linewidth=2, label='k·μ')
    ax.set_xlabel('k'); ax.set_ylabel('Entry value')
    ax.set_title('Tropical power entries vs linear growth')
    ax.legend(); ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/critical_graph.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/critical_graph.png")


def demo_karp():
    print("\n" + "=" * 60)
    print("DEMO 5: Karp's Algorithm for Max Cycle Mean")
    print("=" * 60)

    np.random.seed(123)
    for size in [3, 4, 5, 6]:
        M = np.random.randn(size, size) * 3
        mu_brute, cycle = max_cycle_mean(M)
        mu_karp = karp_max_cycle_mean(M)
        match = '✓' if abs(mu_brute - mu_karp) < 1e-8 else '✗'
        print(f"  {size}×{size}: brute={mu_brute:.6f}, Karp={mu_karp:.6f} {match}")


if __name__ == '__main__':
    os.makedirs('demos', exist_ok=True)
    demo_eigenvector()
    demo_spectral_growth()
    demo_eigencharacter()
    demo_critical_graph()
    demo_karp()
    print("\n" + "=" * 60)
    print("All demos complete!")
    print("=" * 60)
