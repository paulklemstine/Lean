#!/usr/bin/env python3
"""
Demo: Markov-Trace Dynamics — Numerical Examples

Demonstrates the key mathematical results:
1. Chebyshev trace recurrence and exponential growth
2. Markov tree enumeration and the Vieta involution
3. Fricke-Vogt identity verification
4. Trace orbit signatures and commitment scheme
5. Chebyshev invariant verification
"""

from algorithms import (
    cheb_trace, cheb_trace_fast, SL2Matrix, 
    enumerate_markov_triples, verify_fricke_vogt,
    trace_orbit_signature, trace_orbit_signature_fast,
    generate_distinct_matrices, verify_markov_equation
)


def demo_chebyshev_growth():
    """Demonstrate exponential growth of Chebyshev traces."""
    print("=" * 60)
    print("DEMO 1: Chebyshev Trace Growth")
    print("=" * 60)
    print()

    for t in [3, 5, 10]:
        print(f"Trace t = {t}:")
        print(f"  {'n':>4}  {'chebTrace(t,n)':>20}  {'(t-1)^n':>20}  {'ratio':>10}")
        print(f"  {'─'*4}  {'─'*20}  {'─'*20}  {'─'*10}")
        for n in range(10):
            ct = cheb_trace(t, n)
            lower = (t - 1) ** n
            ratio = ct / lower if lower > 0 else float('inf')
            print(f"  {n:4d}  {ct:20d}  {lower:20d}  {ratio:10.4f}")
        print()

    # Verify the invariant: chebTrace(n+1)^2 + chebTrace(n)^2 - t*chebTrace(n)*chebTrace(n+1) = 4 - t^2
    print("Chebyshev Invariant Verification:")
    for t in [3, 5, 7, -4]:
        for n in range(15):
            cn = cheb_trace(t, n)
            cn1 = cheb_trace(t, n + 1)
            invariant = cn1**2 + cn**2 - t * cn * cn1
            expected = 4 - t**2
            assert invariant == expected, f"FAILED at t={t}, n={n}"
        print(f"  t = {t:3d}: invariant = {4 - t**2:6d} ✓ (verified for n=0..14)")
    print()


def demo_markov_tree():
    """Demonstrate Markov tree enumeration."""
    print("=" * 60)
    print("DEMO 2: Markov Tree Enumeration")
    print("=" * 60)
    print()

    triples = enumerate_markov_triples(1000)
    print(f"Markov triples with z ≤ 1000: {len(triples)}")
    print()
    
    # Extract Markov numbers
    markov_numbers = sorted(set(z for _, _, z in triples))
    print(f"Markov numbers ≤ 1000: {markov_numbers}")
    print()

    # Verify Vieta involution
    print("Vieta involution examples:")
    for x, y, z in triples[:5]:
        z_new = 3 * x * y - z
        print(f"  ({x}, {y}, {z}) → ({x}, {y}, {z_new})")
        if z_new > 0:
            assert verify_markov_equation(x, y, z_new)
            print(f"    Verified: {x}² + {y}² + {z_new}² = 3·{x}·{y}·{z_new}")
    print()

    # Verify uniqueness conjecture up to our bound
    print("Markov Uniqueness Conjecture verification:")
    z_counts = {}
    for x, y, z in triples:
        if z not in z_counts:
            z_counts[z] = []
        z_counts[z].append((x, y))
    
    duplicates = {z: v for z, v in z_counts.items() if len(v) > 1}
    if duplicates:
        print(f"  COUNTEREXAMPLE FOUND: {duplicates}")
    else:
        print(f"  Verified: each z ≤ 1000 appears exactly once ✓")
    print()


def demo_fricke_vogt():
    """Demonstrate the Fricke-Vogt identity."""
    print("=" * 60)
    print("DEMO 3: Fricke-Vogt Identity")
    print("=" * 60)
    print()

    S = SL2Matrix(0, -1, 1, 0)
    T = SL2Matrix(1, 1, 0, 1)

    test_pairs = [
        ("S", "T", S, T),
        ("S", "ST", S, S * T),
        ("T", "T²", T, T * T),
        ("S²", "T", S * S, T),
    ]

    for name_a, name_b, A, B in test_pairs:
        tA = A.trace()
        tB = B.trace()
        AB = A * B
        tAB = AB.trace()
        comm = A * B * A.inv() * B.inv()
        tComm = comm.trace()

        lhs = tA**2 + tB**2 + tAB**2
        rhs = tA * tB * tAB + tComm + 2

        verified = verify_fricke_vogt(A, B)
        print(f"  ({name_a}, {name_b}): tr(A)={tA}, tr(B)={tB}, tr(AB)={tAB}, tr([A,B])={tComm}")
        print(f"    LHS = {tA}² + {tB}² + {tAB}² = {lhs}")
        print(f"    RHS = {tA}·{tB}·{tAB} + {tComm} + 2 = {rhs}")
        print(f"    Verified: {verified} ✓")
        print()

    # Show when commutator trace = -2 (Markov case)
    print("Markov case (tr([A,B]) = -2):")
    # STS^{-1} and T give commutator trace -2
    A = SL2Matrix(1, 1, 1, 2)
    B = SL2Matrix(2, 1, 1, 1)
    comm = A * B * A.inv() * B.inv()
    tComm = comm.trace()
    print(f"  A = {A}, B = {B}")
    print(f"  tr([A,B]) = {tComm}")
    if tComm == -2:
        tA, tB, tAB = A.trace(), B.trace(), (A * B).trace()
        print(f"  Markov equation: {tA}² + {tB}² + {tAB}² = {tA}·{tB}·{tAB}")
        print(f"  LHS = {tA**2 + tB**2 + tAB**2}, RHS = {tA * tB * tAB}")
    print()


def demo_trace_signatures():
    """Demonstrate trace orbit signatures."""
    print("=" * 60)
    print("DEMO 4: Trace Orbit Signatures")
    print("=" * 60)
    print()

    # Two matrices with the same trace should have the same signature
    A = SL2Matrix(3, 1, 2, 1)  # trace = 4
    B = SL2Matrix(2, 1, 3, 2)  # trace = 4

    print(f"A = {A}, tr(A) = {A.trace()}")
    print(f"B = {B}, tr(B) = {B.trace()}")
    print()

    sig_A = trace_orbit_signature(A, 8)
    sig_B = trace_orbit_signature(B, 8)
    sig_fast = trace_orbit_signature_fast(A.trace(), 8)

    print("  n  | tr(Aⁿ) | tr(Bⁿ) | chebTrace(4,n)")
    print("  ---|--------|--------|---------------")
    for n in range(8):
        print(f"  {n}  | {sig_A[n]:6d} | {sig_B[n]:6d} | {sig_fast[n]:13d}")

    print()
    print(f"  Signatures equal: {sig_A == sig_B} (same trace → same signature)")
    print(f"  Fast matches:     {sig_A == sig_fast} ✓")
    print()


def demo_commitment():
    """Demonstrate the trace commitment scheme."""
    print("=" * 60)
    print("DEMO 5: Trace Commitment Scheme")
    print("=" * 60)
    print()

    # Generate 5 distinct matrices with trace 10
    t = 10
    n = 5
    matrices = generate_distinct_matrices(t, n)

    print(f"Hiding: {n} distinct matrices with trace {t}:")
    for i, m in enumerate(matrices):
        det = m.a * m.d - m.b * m.c
        print(f"  M_{i} = [[{m.a},{m.b}],[{m.c},{m.d}]], trace = {m.trace()}, det = {det}")

    print()
    print("Binding: any two openings must agree on trace.")
    for i in range(len(matrices)):
        for j in range(i + 1, len(matrices)):
            assert matrices[i].trace() == matrices[j].trace()
    print(f"  All {n*(n-1)//2} pairs verified ✓")
    print()


def demo_hyperbolic_dichotomy():
    """Demonstrate the hyperbolic dichotomy."""
    print("=" * 60)
    print("DEMO 6: Hyperbolic Dichotomy")
    print("=" * 60)
    print()

    for t in [3, 5, -4, -7]:
        print(f"Trace t = {t} ({'hyperbolic' if t**2 > 4 else 'not hyperbolic'}):")
        for n in range(1, 8):
            ct = cheb_trace(t, n)
            disc = ct**2 - 4
            status = "hyp" if disc > 0 else ("par" if disc == 0 else "ell")
            print(f"  n={n}: chebTrace = {ct:8d}, disc = {disc:12d} [{status}]")
        print()


if __name__ == "__main__":
    demo_chebyshev_growth()
    demo_markov_tree()
    demo_fricke_vogt()
    demo_trace_signatures()
    demo_commitment()
    demo_hyperbolic_dichotomy()
    print("All demos completed successfully!")


#!/usr/bin/env python3
"""
Visualization: Markov Tree Structure

Plots the Markov tree as a graph, showing how Markov triples are
connected by the Vieta involution. Each node is a Markov triple,
and edges connect triples related by the involution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from collections import deque


def normalize_triple(x, y, z):
    return tuple(sorted([x, y, z]))


def build_markov_tree(max_z=200):
    """Build the Markov tree as an adjacency list."""
    seen = set()
    edges = []
    queue = deque()

    seed = (1, 1, 1)
    seen.add(seed)
    queue.append(seed)

    while queue:
        x, y, z = queue.popleft()
        children = [
            normalize_triple(3 * y * z - x, y, z),
            normalize_triple(x, 3 * x * z - y, z),
            normalize_triple(x, y, 3 * x * y - z),
        ]
        for child in children:
            if child[2] <= max_z and child[0] > 0 and child not in seen:
                seen.add(child)
                edges.append(((x, y, z), child))
                queue.append(child)

    return list(seen), edges


def layout_tree(nodes, edges):
    """Simple tree layout using BFS levels."""
    # Build adjacency
    adj = {n: [] for n in nodes}
    for a, b in edges:
        adj[a].append(b)
        adj[b].append(a)

    root = (1, 1, 1)
    pos = {}
    visited = {root}
    levels = [[root]]
    
    while levels[-1]:
        next_level = []
        for node in levels[-1]:
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    next_level.append(nb)
        if next_level:
            levels.append(next_level)
        else:
            break

    for depth, level in enumerate(levels):
        n = len(level)
        for i, node in enumerate(level):
            x = (i - (n - 1) / 2) * 2.5
            y = -depth * 1.8
            pos[node] = (x, y)

    return pos


def plot_markov_tree():
    """Create the Markov tree visualization."""
    nodes, edges = build_markov_tree(1000)
    pos = layout_tree(nodes, edges)

    fig, ax = plt.subplots(1, 1, figsize=(14, 10))
    
    # Draw edges
    for a, b in edges:
        if a in pos and b in pos:
            ax.plot([pos[a][0], pos[b][0]], [pos[a][1], pos[b][1]],
                    'gray', linewidth=1.5, alpha=0.6, zorder=1)

    # Draw nodes
    for node in nodes:
        if node in pos:
            x, y = pos[node]
            markov_num = node[2]
            # Color by Markov number magnitude
            color = plt.cm.viridis(min(markov_num / 1000, 1.0))
            circle = plt.Circle((x, y), 0.4, color=color, ec='black',
                              linewidth=1.5, zorder=2)
            ax.add_patch(circle)
            label = f"{node[0]},{node[1]},{node[2]}"
            fontsize = max(5, 9 - len(str(node[2])))
            ax.text(x, y, label, ha='center', va='center',
                   fontsize=fontsize, fontweight='bold', zorder=3)

    ax.set_xlim(-15, 15)
    ax.set_ylim(-12, 2)
    ax.set_aspect('equal')
    ax.set_title('The Markov Tree: x² + y² + z² = 3xyz\n'
                'Connected by Vieta involution (x,y,z) → (x,y,3xy−z)',
                fontsize=14, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('markov_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved markov_tree.png")


def plot_chebyshev_growth():
    """Plot exponential growth of Chebyshev traces."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    def cheb_trace(t, n):
        if n == 0: return 2
        if n == 1: return t
        prev2, prev1 = 2, t
        for _ in range(2, n + 1):
            curr = t * prev1 - prev2
            prev2, prev1 = prev1, curr
        return prev1

    # Left: Linear scale
    ax = axes[0]
    ns = list(range(12))
    for t in [3, 4, 5, 7]:
        values = [cheb_trace(t, n) for n in ns]
        ax.plot(ns, values, 'o-', label=f't = {t}', markersize=4)
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('chebTrace(t, n)', fontsize=12)
    ax.set_title('Chebyshev Trace Growth (Linear)', fontsize=13)
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Right: Log scale with lower bound
    ax = axes[1]
    ns = list(range(12))
    for t in [3, 4, 5, 7]:
        values = [cheb_trace(t, n) for n in ns]
        lower = [(t - 1) ** n for n in ns]
        ax.semilogy(ns, values, 'o-', label=f'chebTrace({t}, n)', markersize=4)
        ax.semilogy(ns, lower, '--', alpha=0.5, label=f'({t}-1)ⁿ')
    ax.set_xlabel('n', fontsize=12)
    ax.set_ylabel('Value (log scale)', fontsize=12)
    ax.set_title('Exponential Lower Bound: (t−1)ⁿ ≤ chebTrace(t,n)', fontsize=13)
    ax.legend(fontsize=8, ncol=2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('chebyshev_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved chebyshev_growth.png")


if __name__ == "__main__":
    plot_markov_tree()
    plot_chebyshev_growth()
