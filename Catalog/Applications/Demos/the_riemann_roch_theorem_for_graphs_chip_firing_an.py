#!/usr/bin/env python3
"""
Chip-Firing and the Riemann-Roch Theorem for Graphs: Demo

Demonstrates the Baker-Norine theory on complete graphs K_n,
including chip-firing, the canonical divisor, genus computation,
and verification of the Riemann-Roch formula.
"""

import itertools
from typing import Dict, List, Tuple, Optional

def complete_graph_edges(n: int) -> List[Tuple[int, int]]:
    """Return all edges of K_n."""
    return [(i, j) for i in range(n) for j in range(i+1, n)]

def degree_kn(n: int) -> int:
    """Every vertex of K_n has degree n-1."""
    return n - 1

def genus_kn(n: int) -> int:
    """Genus of K_n: g = (n-1)(n-2)/2."""
    return (n - 1) * (n - 2) // 2

def canonical_divisor_kn(n: int) -> Dict[int, int]:
    """Canonical divisor of K_n: K(v) = n-3 for all v."""
    return {v: n - 3 for v in range(n)}

def canonical_degree_kn(n: int) -> int:
    """Degree of canonical divisor: n(n-3) = 2g - 2."""
    return n * (n - 3)

def chip_fire(n: int, divisor: Dict[int, int], vertex: int) -> Dict[int, int]:
    """Fire vertex in K_n: send 1 chip to each neighbor."""
    D = divisor.copy()
    D[vertex] -= (n - 1)  # lose degree-many chips
    for w in range(n):
        if w != vertex:
            D[w] += 1
    return D

def divisor_degree(D: Dict[int, int]) -> int:
    """Total number of chips."""
    return sum(D.values())

def is_effective(D: Dict[int, int]) -> bool:
    """Check if all entries are non-negative."""
    return all(v >= 0 for v in D.values())

def all_firing_sequences(n: int, D: Dict[int, int], max_steps: int = 10) -> bool:
    """Check if D can reach an effective divisor via chip-firing (BFS)."""
    from collections import deque
    visited = set()
    queue = deque()
    key = tuple(D[v] for v in range(n))
    queue.append((key, 0))
    visited.add(key)
    
    while queue:
        state, steps = queue.popleft()
        D_curr = {v: state[v] for v in range(n)}
        if is_effective(D_curr):
            return True
        if steps >= max_steps:
            continue
        for v in range(n):
            D_next = chip_fire(n, D_curr, v)
            key_next = tuple(D_next[w] for w in range(n))
            if key_next not in visited:
                visited.add(key_next)
                queue.append((key_next, steps + 1))
    return False

def compute_rank(n: int, D: Dict[int, int], max_search: int = 8) -> int:
    """Compute divisor rank r(D) by definition (small graphs only).
    
    r(D) = -1 if D is not equivalent to effective;
    otherwise max k such that for all effective E with deg(E)=k,
    D-E is equivalent to effective.
    """
    if not all_firing_sequences(n, D):
        return -1
    
    rank = 0
    for k in range(1, divisor_degree(D) + 1):
        if k > max_search:
            break
        # Check all effective divisors of degree k on n vertices
        # (compositions of k into n parts)
        all_ok = True
        for combo in compositions(k, n):
            E = {v: combo[v] for v in range(n)}
            D_minus_E = {v: D[v] - E[v] for v in range(n)}
            if not all_firing_sequences(n, D_minus_E, max_steps=12):
                all_ok = False
                break
        if all_ok:
            rank = k
        else:
            break
    return rank

def compositions(k: int, n: int):
    """Generate all weak compositions of k into n parts."""
    if n == 1:
        yield [k]
        return
    for i in range(k + 1):
        for rest in compositions(k - i, n - 1):
            yield [i] + rest

def riemann_roch_verify(n: int, D: Dict[int, int]) -> dict:
    """Verify the Riemann-Roch formula for a divisor on K_n."""
    g = genus_kn(n)
    K = canonical_divisor_kn(n)
    K_minus_D = {v: K[v] - D[v] for v in range(n)}
    
    r_D = compute_rank(n, D)
    r_KD = compute_rank(n, K_minus_D)
    deg_D = divisor_degree(D)
    
    lhs = r_D - r_KD
    rhs = deg_D + 1 - g
    
    return {
        'D': D,
        'K-D': K_minus_D,
        'r(D)': r_D,
        'r(K-D)': r_KD,
        'deg(D)': deg_D,
        'genus': g,
        'LHS (r(D)-r(K-D))': lhs,
        'RHS (deg(D)+1-g)': rhs,
        'RR holds': lhs == rhs,
    }


def main():
    print("=" * 70)
    print("CHIP-FIRING AND THE RIEMANN-ROCH THEOREM FOR GRAPHS")
    print("=" * 70)
    
    print("\n--- Complete Graph Structure ---")
    for n in range(2, 8):
        g = genus_kn(n)
        K = canonical_divisor_kn(n)
        deg_K = canonical_degree_kn(n)
        print(f"K_{n}: genus={g}, canonical K(v)={n-3} for all v, "
              f"deg(K)={deg_K} = 2g-2={2*g-2}")
    
    print("\n--- Chip-Firing on K_4 ---")
    n = 4
    D = {0: 3, 1: 0, 2: -1, 3: 1}
    print(f"Initial divisor: {D}, degree={divisor_degree(D)}")
    
    for v in range(4):
        D_fired = chip_fire(n, D, v)
        print(f"  Fire vertex {v}: {D_fired}, degree={divisor_degree(D_fired)}")
    
    print("\n--- Riemann-Roch Verification on K_3 ---")
    n = 3
    g = genus_kn(n)
    print(f"K_3: genus = {g}")
    
    # Test several divisors
    test_divisors = [
        {0: 0, 1: 0, 2: 0},      # zero divisor
        {0: 1, 1: 0, 2: 0},      # degree 1
        {0: 1, 1: 1, 2: 0},      # degree 2
        {0: 0, 1: 0, 2: 2},      # degree 2 concentrated
        {0: 0, 1: 0, 2: -1},     # negative
        canonical_divisor_kn(3),   # canonical
    ]
    
    for D in test_divisors:
        result = riemann_roch_verify(n, D)
        status = "✓" if result['RR holds'] else "✗"
        print(f"  {status} D={D}: r(D)={result['r(D)']}, "
              f"r(K-D)={result['r(K-D)']}, "
              f"deg={result['deg(D)']}, "
              f"LHS={result['LHS (r(D)-r(K-D))']}, "
              f"RHS={result['RHS (deg(D)+1-g)']}")
    
    print("\n--- Riemann-Roch Verification on K_4 ---")
    n = 4
    g = genus_kn(n)
    print(f"K_4: genus = {g}")
    
    test_divisors_4 = [
        {0: 0, 1: 0, 2: 0, 3: 0},        # zero
        {0: 2, 1: 0, 2: 0, 3: 0},        # degree 2
        {0: 1, 1: 1, 2: 1, 3: 0},        # degree 3
        canonical_divisor_kn(4),           # canonical K(v) = 1
        {0: 2, 1: 2, 2: 0, 3: 0},        # degree 4
    ]
    
    for D in test_divisors_4:
        result = riemann_roch_verify(n, D)
        status = "✓" if result['RR holds'] else "✗"
        print(f"  {status} D={D}: r(D)={result['r(D)']}, "
              f"r(K-D)={result['r(K-D)']}, "
              f"deg={result['deg(D)']}, "
              f"LHS={result['LHS (r(D)-r(K-D))']}, "
              f"RHS={result['RHS (deg(D)+1-g)']}")
    
    print("\n--- Canonical Divisor Rank ---")
    for n in range(3, 6):
        g = genus_kn(n)
        K = canonical_divisor_kn(n)
        r_K = compute_rank(n, K)
        print(f"K_{n}: genus={g}, r(K) = {r_K}, expected g-1 = {g-1}")
    
    print("\n--- Gonality of Complete Graphs ---")
    for n in range(3, 7):
        # Test divisor 2*[v0]
        D_gon = {v: (2 if v == 0 else 0) for v in range(n)}
        r = compute_rank(n, D_gon)
        print(f"K_{n}: r(2·[v₀]) = {r}, gonality ≤ 2: {r >= 1}")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Chip-Firing Dynamics on Complete Graphs

Shows how chip configurations evolve under firing, verifies degree conservation,
and plots the canonical divisor structure across K_n for various n.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def chip_fire_kn(n, D, v):
    """Fire vertex v in K_n."""
    D_new = D.copy()
    D_new[v] -= (n - 1)
    for w in range(n):
        if w != v:
            D_new[w] += 1
    return D_new


def genus_kn(n):
    return (n - 1) * (n - 2) // 2


def canonical_kn(n):
    return {v: n - 3 for v in range(n)}


def compute_rank_simple(n, D, max_steps=12):
    """Compute rank via BFS for small graphs."""
    from collections import deque
    
    def bfs_effective(D_start):
        visited = set()
        queue = deque()
        key = tuple(D_start[v] for v in range(n))
        queue.append((key, 0))
        visited.add(key)
        while queue:
            state, steps = queue.popleft()
            D_c = {v: state[v] for v in range(n)}
            if all(D_c[v] >= 0 for v in range(n)):
                return True
            if steps >= max_steps:
                continue
            for v in range(n):
                D_next = chip_fire_kn(n, D_c, v)
                key_next = tuple(D_next[w] for w in range(n))
                if key_next not in visited:
                    visited.add(key_next)
                    queue.append((key_next, steps + 1))
        return False
    
    if not bfs_effective(D):
        return -1
    
    def weak_compositions(k, m):
        if m == 1:
            yield [k]
            return
        for i in range(k + 1):
            for rest in weak_compositions(k - i, m - 1):
                yield [i] + rest
    
    rank = 0
    deg = sum(D.values())
    for k in range(1, min(deg + 1, 6)):
        all_ok = True
        for combo in weak_compositions(k, n):
            E = {v: combo[v] for v in range(n)}
            DmE = {v: D[v] - E[v] for v in range(n)}
            if not bfs_effective(DmE):
                all_ok = False
                break
        if all_ok:
            rank = k
        else:
            break
    return rank


def plot_genus_and_canonical():
    """Plot genus and canonical divisor degree for K_n."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    ns = list(range(2, 15))
    genera = [genus_kn(n) for n in ns]
    can_degrees = [n * (n - 3) for n in ns]
    can_values = [n - 3 for n in ns]
    
    # Plot 1: Genus
    axes[0].bar(ns, genera, color='steelblue', alpha=0.8)
    axes[0].set_xlabel('n (vertices of K_n)')
    axes[0].set_ylabel('g(K_n)')
    axes[0].set_title('Genus of Complete Graphs\ng = (n-1)(n-2)/2')
    axes[0].grid(True, alpha=0.3)
    
    # Plot 2: Canonical degree
    axes[1].bar(ns, can_degrees, color='coral', alpha=0.8)
    axes[1].plot(ns, [2 * g - 2 for g in genera], 'k--', label='2g - 2')
    axes[1].set_xlabel('n')
    axes[1].set_ylabel('deg(K)')
    axes[1].set_title('Canonical Divisor Degree\ndeg(K) = n(n-3) = 2g-2')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # Plot 3: Canonical coefficient
    axes[2].bar(ns, can_values, color='seagreen', alpha=0.8)
    axes[2].axhline(y=0, color='red', linestyle='--', alpha=0.5)
    axes[2].set_xlabel('n')
    axes[2].set_ylabel('K(v)')
    axes[2].set_title('Canonical Coefficient K(v) = n-3\n(effective when n ≥ 3)')
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('genus_canonical.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved genus_canonical.png")


def plot_riemann_roch_verification():
    """Verify Riemann-Roch on K_3 and K_4 for many divisors."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    for idx, n in enumerate([3, 4]):
        g = genus_kn(n)
        K = canonical_kn(n)
        
        degrees = []
        ranks = []
        rr_line = []
        
        # Generate divisors of various degrees
        for d in range(-2, 2 * g + 1):
            # Spread chips as evenly as possible
            base = d // n
            remainder = d % n
            if remainder < 0:
                base -= 1
                remainder += n
            D = {v: base + (1 if v < remainder else 0) for v in range(n)}
            r = compute_rank_simple(n, D)
            degrees.append(d)
            ranks.append(r)
            rr_line.append(d + 1 - g)
        
        axes[idx].scatter(degrees, ranks, c='steelblue', s=40, zorder=3,
                          label='r(D)')
        axes[idx].plot(degrees, rr_line, 'r--', alpha=0.7,
                       label='deg(D) + 1 - g')
        axes[idx].axhline(y=-1, color='gray', linestyle=':', alpha=0.5)
        axes[idx].axhline(y=0, color='gray', linestyle=':', alpha=0.5)
        axes[idx].axvline(x=0, color='gray', linestyle=':', alpha=0.5)
        axes[idx].axvline(x=2*g-2, color='orange', linestyle='--', alpha=0.5,
                          label='deg = 2g-2')
        axes[idx].set_xlabel('deg(D)')
        axes[idx].set_ylabel('r(D)')
        axes[idx].set_title(f'Riemann-Roch on K_{n} (g={g})')
        axes[idx].legend(fontsize=8)
        axes[idx].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('riemann_roch_verification.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved riemann_roch_verification.png")


def plot_chipfiring_dynamics():
    """Show chip-firing dynamics on K_4."""
    fig, axes = plt.subplots(2, 3, figsize=(14, 8))
    
    n = 4
    D_init = {0: 5, 1: -1, 2: 0, 3: -1}
    
    configs = [D_init]
    labels = ['Initial']
    
    # Fire sequence
    fire_seq = [0, 0, 1, 3, 2]
    D = D_init
    for v in fire_seq:
        D = chip_fire_kn(n, D, v)
        configs.append(D)
        labels.append(f'Fire v{v}')
    
    for i, (ax, D, label) in enumerate(zip(axes.flat, configs, labels)):
        vals = [D[v] for v in range(n)]
        colors = ['steelblue' if v >= 0 else 'coral' for v in vals]
        bars = ax.bar(range(n), vals, color=colors, alpha=0.8, edgecolor='black')
        ax.axhline(y=0, color='black', linewidth=0.5)
        ax.set_xlabel('Vertex')
        ax.set_ylabel('Chips')
        ax.set_title(f'{label}\ndeg = {sum(vals)}')
        ax.set_xticks(range(n))
        ax.set_xticklabels([f'v{j}' for j in range(n)])
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-4, 6)
        
        for bar, val in zip(bars, vals):
            ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.2,
                    str(val), ha='center', va='bottom', fontweight='bold')
    
    plt.suptitle('Chip-Firing Dynamics on K₄', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('chipfiring_dynamics.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved chipfiring_dynamics.png")


if __name__ == '__main__':
    plot_genus_and_canonical()
    plot_riemann_roch_verification()
    plot_chipfiring_dynamics()
    print("All visualizations generated.")
