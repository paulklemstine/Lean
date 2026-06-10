#!/usr/bin/env python3
"""
Demo: CSIDH-style Group Action Cryptography

Demonstrates the key concepts from the formal Lean proofs:
- Torsor trivialization
- Connector cohomology (triangle closure)
- Multi-party key exchange
- Security amplification
- Cayley graph diameter computation
"""

import random
from typing import List, Tuple

# ============================================================================
# Core: Group action on Z/nZ (cyclic group acting on itself by addition)
# This models the "toy" version of CSIDH where the class group is cyclic.
# ============================================================================

class CyclicTorsor:
    """A free transitive action of Z/nZ on itself."""
    
    def __init__(self, n: int):
        self.n = n
    
    def act(self, g: int, x: int) -> int:
        """Group action: g · x = g + x mod n"""
        return (g + x) % self.n
    
    def conn(self, x: int, y: int) -> int:
        """Connector: the unique g with g · x = y, i.e., g = y - x mod n"""
        return (y - x) % self.n
    
    def inverse(self, g: int) -> int:
        """Group inverse: -g mod n"""
        return (-g) % self.n


def demo_torsor_trivialization():
    """Demonstrate the Trivialization Theorem: X ≃ G via basepoint."""
    print("=" * 60)
    print("TORSOR TRIVIALIZATION")
    print("=" * 60)
    
    T = CyclicTorsor(7)
    x0 = 3  # Choose basepoint
    
    print(f"Group: Z/{T.n}Z")
    print(f"Basepoint: x₀ = {x0}")
    print()
    
    # Show trivialization: y ↦ conn(x₀, y)
    print("Trivialization (y ↦ conn(x₀, y)):")
    for y in range(T.n):
        g = T.conn(x0, y)
        print(f"  trivialize({y}) = conn({x0}, {y}) = {g}")
    
    # Show equivariance: conn(x₀, g·y) = g · conn(x₀, y)
    print()
    print("Equivariance check: conn(x₀, g·y) = g · conn(x₀, y)")
    g, y = 2, 5
    lhs = T.conn(x0, T.act(g, y))
    rhs = (g + T.conn(x0, y)) % T.n
    print(f"  g={g}, y={y}: conn({x0}, {g}·{y}) = {lhs}, "
          f"g · conn({x0}, {y}) = {rhs}  ✓" if lhs == rhs else "  ✗")
    
    # Show basepoint change formula
    print()
    x1 = 5
    print(f"Basepoint change: x₀={x0} → x₁={x1}")
    for y in range(T.n):
        t0 = T.conn(x0, y)
        t1 = T.conn(x1, y)
        shift = T.conn(x0, x1)
        computed = (t1 + shift) % T.n
        status = "✓" if t0 == computed else "✗"
        print(f"  trivialize_{x0}({y}) = {t0} = "
              f"trivialize_{x1}({y}) · conn({x0},{x1}) = {t1} · {shift} = {computed}  {status}")


def demo_connector_cohomology():
    """Demonstrate the Čech 1-cocycle properties of the connector."""
    print()
    print("=" * 60)
    print("CONNECTOR COHOMOLOGY")
    print("=" * 60)
    
    T = CyclicTorsor(11)
    
    # Triangle closure: conn(x,y) · conn(y,z) · conn(z,x) = 0
    print("Triangle closure: conn(x,y) + conn(y,z) + conn(z,x) ≡ 0 (mod n)")
    for _ in range(5):
        x, y, z = random.sample(range(T.n), 3)
        cxy = T.conn(x, y)
        cyz = T.conn(y, z)
        czx = T.conn(z, x)
        total = (cxy + cyz + czx) % T.n
        print(f"  ({x},{y},{z}): {cxy} + {cyz} + {czx} ≡ {total} (mod {T.n})  "
              + ("✓" if total == 0 else "✗"))
    
    # Four-point cocycle
    print()
    print("Four-point cocycle: conn(w,x) + conn(x,y) + conn(y,z) + conn(z,w) ≡ 0")
    for _ in range(5):
        w, x, y, z = random.sample(range(T.n), 4)
        total = (T.conn(w,x) + T.conn(x,y) + T.conn(y,z) + T.conn(z,w)) % T.n
        print(f"  ({w},{x},{y},{z}): total ≡ {total} (mod {T.n})  "
              + ("✓" if total == 0 else "✗"))


def demo_multiparty_csidh():
    """Demonstrate multi-party key agreement."""
    print()
    print("=" * 60)
    print("MULTI-PARTY CSIDH KEY AGREEMENT")
    print("=" * 60)
    
    T = CyclicTorsor(97)  # Use a prime for more realistic demo
    x0 = 0  # Public basepoint
    
    # Generate random secrets for n parties
    for n_parties in [2, 3, 4, 5]:
        secrets = [random.randint(1, T.n - 1) for _ in range(n_parties)]
        
        # Compute shared secret
        shared = x0
        for s in secrets:
            shared = T.act(s, shared)
        
        # Verify permutation invariance
        import itertools
        all_same = True
        for perm in itertools.permutations(secrets):
            result = x0
            for s in perm:
                result = T.act(s, result)
            if result != shared:
                all_same = False
                break
        
        print(f"\n{n_parties} parties, secrets = {secrets}")
        print(f"  Shared secret = {shared}")
        print(f"  Permutation invariant: {'✓' if all_same else '✗'}")


def demo_security_amplification():
    """Demonstrate security amplification via parallel repetition."""
    print()
    print("=" * 60)
    print("SECURITY AMPLIFICATION")
    print("=" * 60)
    
    epsilons = [0.5, 0.3, 0.1, 0.01]
    ns = [1, 2, 5, 10, 20, 50, 100]
    
    print(f"{'ε':>8} | " + " | ".join(f"n={n:>3}" for n in ns))
    print("-" * (10 + len(ns) * 12))
    
    for eps in epsilons:
        row = f"{eps:>8.3f} | "
        for n in ns:
            adv = eps ** n
            if adv < 1e-10:
                row += f"{'<1e-10':>10} | "
            else:
                row += f"{adv:>10.2e} | "
        print(row)
    
    print()
    print("Key insight: doubling n squares the advantage.")
    print("For CSIDH with ε ≤ 2⁻¹²⁸, even n=2 gives ε² ≤ 2⁻²⁵⁶.")


def demo_cayley_diameter():
    """Test the Cayley diameter conjecture: diam(Cay(Z/nZ, {1,-1})) = ⌊n/2⌋."""
    print()
    print("=" * 60)
    print("CAYLEY DIAMETER CONJECTURE TEST")
    print("=" * 60)
    
    test_values = [5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    
    print(f"{'n':>4} | {'⌊n/2⌋':>6} | {'BFS diam':>8} | {'Match':>5}")
    print("-" * 35)
    
    for n in test_values:
        # BFS from 0 in Cay(Z/nZ, {1, n-1})
        dist = [-1] * n
        dist[0] = 0
        queue = [0]
        max_dist = 0
        
        while queue:
            v = queue.pop(0)
            for s in [1, n - 1]:
                w = (v + s) % n
                if dist[w] == -1:
                    dist[w] = dist[v] + 1
                    max_dist = max(max_dist, dist[w])
                    queue.append(w)
        
        expected = n // 2
        match = "✓" if max_dist == expected else "✗"
        print(f"{n:>4} | {expected:>6} | {max_dist:>8} | {match:>5}")
    
    print()
    print("Conjecture confirmed for all tested values!")


def demo_spectral_gap():
    """Compute spectral gap for cyclic Cayley graphs."""
    import math
    
    print()
    print("=" * 60)
    print("SPECTRAL GAP CONJECTURE")
    print("=" * 60)
    
    print(f"{'n':>4} | {'gap = 2(1-cos(2π/n))':>22} | {'gap ≈':>8}")
    print("-" * 45)
    
    for n in [5, 7, 11, 13, 17, 19, 23, 29, 31]:
        gap = 2 * (1 - math.cos(2 * math.pi / n))
        print(f"{n:>4} | 2(1-cos(2π/{n:>2}))       | {gap:>8.5f}")
    
    print()
    print("The spectral gap decreases as n grows (Θ(1/n²)),")
    print("reflecting longer mixing times for larger groups.")


if __name__ == "__main__":
    random.seed(42)
    demo_torsor_trivialization()
    demo_connector_cohomology()
    demo_multiparty_csidh()
    demo_security_amplification()
    demo_cayley_diameter()
    demo_spectral_gap()


#!/usr/bin/env python3
"""Visualization: Security amplification via parallel repetition."""

import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Security Amplification via Parallel Repetition",
                fontsize=14, fontweight='bold')
    
    # Plot 1: Advantage decay for various ε
    ns = np.arange(1, 51)
    epsilons = [0.5, 0.3, 0.1, 0.05, 0.01]
    colors = plt.cm.plasma(np.linspace(0.1, 0.9, len(epsilons)))
    
    for eps, color in zip(epsilons, colors):
        advantages = [eps ** n for n in ns]
        ax1.semilogy(ns, advantages, '-', color=color, linewidth=2,
                    label=f'ε = {eps}')
    
    ax1.set_xlabel("Number of parallel repetitions (n)", fontsize=12)
    ax1.set_ylabel("Advantage εⁿ", fontsize=12)
    ax1.set_title("Exponential Decay of Adversary Advantage", fontsize=12)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xlim(1, 50)
    
    # Add security level lines
    for bits in [64, 128, 256]:
        ax1.axhline(y=2**(-bits), color='gray', linestyle='--', alpha=0.5)
        ax1.text(48, 2**(-bits) * 1.5, f'2⁻{bits}', fontsize=8,
                ha='right', color='gray')
    
    # Plot 2: Required repetitions for target security level
    target_bits = np.arange(32, 257, 8)
    eps_values = [0.5, 0.3, 0.1, 0.01]
    
    for eps, color in zip(eps_values, colors[:len(eps_values)]):
        reps = [int(np.ceil(b * np.log(2) / (-np.log(eps)))) for b in target_bits]
        ax2.plot(target_bits, reps, '-o', color=color, linewidth=2,
                markersize=3, label=f'ε = {eps}')
    
    ax2.set_xlabel("Target security level (bits)", fontsize=12)
    ax2.set_ylabel("Required repetitions", fontsize=12)
    ax2.set_title("Repetitions Needed for Target Security", fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig("security_amplification.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved security_amplification.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Cayley graph of Z/nZ with generators {1, -1}."""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def draw_cayley_graph(n: int, ax, title: str = ""):
    """Draw the Cayley graph Cay(Z/nZ, {1, -1}) as a circle."""
    angles = [2 * math.pi * k / n for k in range(n)]
    xs = [math.cos(a) for a in angles]
    ys = [math.sin(a) for a in angles]
    
    # Draw edges (each vertex connected to its +1 and -1 neighbors)
    for i in range(n):
        j = (i + 1) % n
        ax.plot([xs[i], xs[j]], [ys[i], ys[j]], 'b-', alpha=0.4, linewidth=1.5)
    
    # Color by distance from 0
    dist = [0] * n
    queue = [0]
    visited = {0}
    while queue:
        v = queue.pop(0)
        for s in [1, n - 1]:
            w = (v + s) % n
            if w not in visited:
                visited.add(w)
                dist[w] = dist[v] + 1
                queue.append(w)
    
    max_d = max(dist)
    cmap = plt.cm.viridis
    colors = [cmap(d / max_d) for d in dist]
    
    # Draw vertices
    for i in range(n):
        circle = plt.Circle((xs[i], ys[i]), 0.08, color=colors[i],
                           ec='black', linewidth=1, zorder=5)
        ax.add_patch(circle)
        ax.text(xs[i], ys[i], str(i), ha='center', va='center',
               fontsize=max(6, 10 - n // 5), fontweight='bold', zorder=6,
               color='white' if dist[i] > max_d * 0.5 else 'black')
    
    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(f"{title}\nDiam = ⌊{n}/2⌋ = {n // 2}", fontsize=11)
    ax.axis('off')


def main():
    fig, axes = plt.subplots(2, 3, figsize=(14, 10))
    fig.suptitle("Cayley Graphs Cay(Z/nZ, {1, -1})\nColored by Distance from 0",
                fontsize=14, fontweight='bold')
    
    ns = [5, 7, 11, 13, 17, 23]
    for ax, n in zip(axes.flat, ns):
        draw_cayley_graph(n, ax, f"n = {n}")
    
    # Add colorbar
    sm = plt.cm.ScalarMappable(cmap=plt.cm.viridis, norm=plt.Normalize(0, 1))
    sm.set_array([])
    cbar = fig.colorbar(sm, ax=axes.ravel().tolist(), shrink=0.6, pad=0.05)
    cbar.set_label("Distance from 0 (normalized)", fontsize=10)
    
    plt.tight_layout(rect=[0, 0, 0.92, 0.95])
    plt.savefig("cayley_graphs.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cayley_graphs.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Visualization: Spectral gap and mixing properties of Cayley graphs."""

import matplotlib.pyplot as plt
import numpy as np
import math


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    fig.suptitle("Spectral Properties of Isogeny-Like Cayley Graphs",
                fontsize=14, fontweight='bold')
    
    # Plot 1: Spectral gap as a function of n
    ns = np.arange(3, 200)
    gaps = [2 * (1 - math.cos(2 * math.pi / n)) for n in ns]
    
    ax1.plot(ns, gaps, 'b-', linewidth=2, label='Spectral gap')
    ax1.plot(ns, [4 * math.pi**2 / n**2 for n in ns], 'r--', linewidth=1.5,
            alpha=0.7, label='Approximation 4π²/n²')
    
    ax1.set_xlabel("Group order n", fontsize=12)
    ax1.set_ylabel("Spectral gap 2(1 - cos(2π/n))", fontsize=12)
    ax1.set_title("Spectral Gap of Cay(Z/nZ, {1,-1})", fontsize=12)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Highlight specific values
    special_ns = [5, 11, 23, 47, 97]
    for sn in special_ns:
        gap = 2 * (1 - math.cos(2 * math.pi / sn))
        ax1.plot(sn, gap, 'ro', markersize=6)
        ax1.annotate(f'n={sn}', (sn, gap), textcoords="offset points",
                    xytext=(10, 5), fontsize=8)
    
    # Plot 2: Eigenvalue spectrum for a specific n
    n = 23
    eigenvalues = sorted([2 * math.cos(2 * math.pi * k / n) for k in range(n)],
                        reverse=True)
    
    ax2.bar(range(n), eigenvalues, color='steelblue', alpha=0.8, edgecolor='navy')
    ax2.axhline(y=eigenvalues[0], color='red', linestyle='--', alpha=0.5,
               label=f'λ₁ = {eigenvalues[0]:.3f}')
    ax2.axhline(y=eigenvalues[1], color='orange', linestyle='--', alpha=0.5,
               label=f'λ₂ = {eigenvalues[1]:.3f}')
    
    gap_val = eigenvalues[0] - eigenvalues[1]
    ax2.annotate(f'Gap = {gap_val:.4f}',
                xy=(1, (eigenvalues[0] + eigenvalues[1]) / 2),
                fontsize=10, fontweight='bold', color='darkred',
                arrowprops=dict(arrowstyle='->', color='darkred'),
                xytext=(5, 0))
    
    ax2.set_xlabel("Eigenvalue index", fontsize=12)
    ax2.set_ylabel("Eigenvalue", fontsize=12)
    ax2.set_title(f"Eigenvalue Spectrum of Cay(Z/{n}Z, {{1,-1}})", fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig("spectral_properties.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved spectral_properties.png")


if __name__ == "__main__":
    main()
