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
