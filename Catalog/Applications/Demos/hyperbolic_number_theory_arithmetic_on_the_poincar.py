"""
Applications of Hyperbolic Number Theory
==========================================

Real-world applications connecting hyperbolic geometry,
number theory, and spectral theory.
"""

import math
from typing import List, Tuple


class SL2R:
    """Minimal SL(2,R) matrix class for applications."""
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = float(a), float(b), float(c), float(d)

    @staticmethod
    def identity():
        return SL2R(1, 0, 0, 1)

    def mul(self, other):
        return SL2R(
            self.a*other.a + self.b*other.c, self.a*other.b + self.b*other.d,
            self.c*other.a + self.d*other.c, self.c*other.b + self.d*other.d)

    def inv(self):
        return SL2R(self.d, -self.b, -self.c, self.a)

    def trace(self):
        return self.a + self.d

    def translation_length(self):
        t = abs(self.trace()) / 2
        return 2 * math.acosh(t) if t > 1 else 0.0


# ═══════════════════════════════════════════════════════════════
# Application 1: Cryptographic Key Exchange on Hyperbolic Groups
# ═══════════════════════════════════════════════════════════════

def hyperbolic_key_exchange():
    """
    Demonstrates a Diffie-Hellman-like key exchange using SL(2,Z).

    The discrete logarithm problem in SL(2,Z) — given M^n, find n —
    is believed to be computationally hard, making it suitable for
    cryptographic protocols.

    This is related to the conjugacy search problem in hyperbolic groups.
    """
    print("Application 1: Cryptographic Key Exchange via SL(2,Z)")
    print("=" * 55)

    # Public parameters: generators of SL(2,Z)
    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)

    # Create a "hard" public element
    G = S.mul(T).mul(T).mul(S).mul(T)
    print(f"Public generator G: trace = {G.trace():.6f}")

    # Alice's secret: n_A = 7
    n_A = 7
    # Bob's secret: n_B = 11
    n_B = 11

    # Alice computes G^n_A
    GA = G
    for _ in range(n_A - 1):
        GA = GA.mul(G)
    print(f"Alice sends G^{n_A}: trace = {GA.trace():.6f}")

    # Bob computes G^n_B
    GB = G
    for _ in range(n_B - 1):
        GB = GB.mul(G)
    print(f"Bob sends G^{n_B}: trace = {GB.trace():.6f}")

    # Shared secret: G^(n_A * n_B)
    # Alice computes (G^n_B)^n_A
    shared_A = GB
    for _ in range(n_A - 1):
        shared_A = shared_A.mul(GB)

    # Bob computes (G^n_A)^n_B
    shared_B = GA
    for _ in range(n_B - 1):
        shared_B = shared_B.mul(GA)

    print(f"\nAlice's shared key trace: {shared_A.trace():.6f}")
    print(f"Bob's shared key trace:   {shared_B.trace():.6f}")
    print(f"Keys match: {abs(shared_A.trace() - shared_B.trace()) < 1e-6}")

    # The trace is the same because matrix multiplication is associative
    # and (G^a)^b = G^(ab) = (G^b)^a


# ═══════════════════════════════════════════════════════════════
# Application 2: Network Routing in Hyperbolic Space
# ═══════════════════════════════════════════════════════════════

def hyperbolic_routing():
    """
    Greedy routing in hyperbolic space.

    Many real-world networks (internet, social networks, biological networks)
    have a hidden hyperbolic geometry. The Poincaré disk model provides
    efficient greedy routing: always forward to the neighbor closest to
    the destination in hyperbolic distance.

    The hyperbolic integers Z_H provide a natural grid for routing.
    """
    print("\n\nApplication 2: Network Routing in Hyperbolic Space")
    print("=" * 55)

    # Simulate nodes as orbit points of PSL(2,Z) acting on the disk
    # Use the Cayley graph structure

    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)
    Ti = SL2R(1, -1, 0, 1)

    # Build a small Cayley graph
    nodes = {}
    node_list = [SL2R.identity()]
    nodes[(1, 0, 0, 1)] = 0

    def key(M):
        return (round(M.a), round(M.b), round(M.c), round(M.d))

    # BFS
    queue = [SL2R.identity()]
    for _ in range(4):
        next_q = []
        for M in queue:
            for g in [S, T, Ti]:
                N = M.mul(g)
                k = key(N)
                if k not in nodes:
                    nodes[k] = len(node_list)
                    node_list.append(N)
                    next_q.append(N)
        queue = next_q

    # Build adjacency using generators
    edges = set()
    for M in node_list:
        i = nodes[key(M)]
        for g in [S, T, Ti]:
            N = M.mul(g)
            k = key(N)
            if k in nodes:
                j = nodes[k]
                edges.add((min(i, j), max(i, j)))

    print(f"Network: {len(node_list)} nodes, {len(edges)} edges")

    # Greedy routing: from node 0 to a distant node
    target = len(node_list) - 1
    target_trace = abs(node_list[target].trace())
    current = 0
    path = [current]
    max_steps = 20

    for _ in range(max_steps):
        if current == target:
            break
        # Find neighbor closest to target in trace distance
        M_current = node_list[current]
        best_next = current
        best_dist = float('inf')
        for g in [S, T, Ti]:
            N = M_current.mul(g)
            k = key(N)
            if k in nodes:
                j = nodes[k]
                dist = abs(abs(node_list[j].trace()) - target_trace)
                if dist < best_dist:
                    best_dist = dist
                    best_next = j
        if best_next == current:
            break
        current = best_next
        path.append(current)

    print(f"Routing from node 0 to node {target}:")
    print(f"  Path length: {len(path) - 1} hops")
    print(f"  Path: {path[:10]}{'...' if len(path) > 10 else ''}")


# ═══════════════════════════════════════════════════════════════
# Application 3: Spectral Analysis of Modular Surfaces
# ═══════════════════════════════════════════════════════════════

def spectral_analysis():
    """
    The Selberg trace formula connects the spectrum of the Laplacian
    on a hyperbolic surface to the lengths of closed geodesics.

    For PSL(2,Z)\H, the closed geodesics correspond to conjugacy classes
    of hyperbolic elements. Their lengths are translation_length(M).

    This gives a "spectrum" of the modular surface.
    """
    print("\n\nApplication 3: Geodesic Length Spectrum of the Modular Surface")
    print("=" * 55)

    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)
    Ti = SL2R(1, -1, 0, 1)

    # Collect hyperbolic elements and their translation lengths
    elements = [SL2R.identity()]
    seen_keys = {(1, 0, 0, 1)}

    def key(M):
        return (round(M.a), round(M.b), round(M.c), round(M.d))

    queue = [SL2R.identity()]
    for _ in range(6):
        next_q = []
        for M in queue:
            for g in [S, T, Ti, S.inv()]:
                N = M.mul(g)
                k = key(N)
                if k not in seen_keys:
                    seen_keys.add(k)
                    elements.append(N)
                    next_q.append(N)
        queue = next_q

    # Extract translation lengths of hyperbolic elements
    lengths = sorted(set(
        round(M.translation_length(), 6)
        for M in elements
        if abs(M.trace()) > 2.01
    ))

    print(f"\nFound {len(lengths)} distinct geodesic lengths from {len(elements)} group elements")
    print(f"\nShortest closed geodesics (length spectrum):")
    for i, l in enumerate(lengths[:15]):
        print(f"  ℓ_{i+1} = {l:.6f}")

    # Weyl's law: #{ℓ_j ≤ L} ~ e^L / L
    if lengths:
        L = lengths[-1]
        actual_count = len(lengths)
        weyl_prediction = math.exp(L) / L if L > 0 else 0
        print(f"\nWeyl's law comparison (L = {L:.2f}):")
        print(f"  Actual count: {actual_count}")
        print(f"  Weyl prediction (e^L/L): {weyl_prediction:.1f}")


# ═══════════════════════════════════════════════════════════════
# Application 4: Hyperbolic Error-Correcting Codes
# ═══════════════════════════════════════════════════════════════

def hyperbolic_codes():
    """
    Regular tilings of the hyperbolic plane give rise to
    LDPC (Low-Density Parity-Check) codes with excellent properties.

    The {p,q} tiling (p-gons, q meeting at each vertex) is hyperbolic
    when (p-2)(q-2) > 4. The adjacency structure gives a parity check matrix.
    """
    print("\n\nApplication 4: Hyperbolic Tiling Codes")
    print("=" * 55)

    # Check which tilings are hyperbolic
    print("\nTiling classification (p-gons, q at each vertex):")
    print(f"{'p':>3} {'q':>3} | {'(p-2)(q-2)':>10} | {'Type':>12} | Rate bound")
    print("-" * 55)
    for p in range(3, 9):
        for q in range(3, 9):
            val = (p - 2) * (q - 2)
            if val > 4:
                ttype = "hyperbolic"
                # Rate ~ 1 - 2/p - 2/q + 2/(p*q) for large codes
                rate = max(0, 1 - 2/p - 2/q + 2/(p*q))
                print(f"{p:>3} {q:>3} | {val:>10} | {ttype:>12} | {rate:.4f}")
            elif val == 4:
                ttype = "Euclidean"
            else:
                ttype = "spherical"


if __name__ == "__main__":
    hyperbolic_key_exchange()
    hyperbolic_routing()
    spectral_analysis()
    hyperbolic_codes()
    print("\n\nAll applications demonstrated successfully!")


"""
Hyperbolic Number Theory: Arithmetic on the Poincaré Disk
=========================================================

Demonstrates the core concepts:
1. SL(2,R) matrix operations and trace classification
2. Hyperbolic lattice point counting
3. Chebyshev-trace recurrence verification
4. Hyperbolic zeta function computation
"""

import numpy as np
from typing import Tuple, List

# ═══════════════════════════════════════════════════════════════
# Part 1: SL(2,R) Matrices
# ═══════════════════════════════════════════════════════════════

class SL2R:
    """A 2x2 real matrix with determinant 1."""

    def __init__(self, a: float, b: float, c: float, d: float):
        self.a, self.b, self.c, self.d = a, b, c, d
        det = a * d - b * c
        if abs(det - 1.0) > 1e-10:
            raise ValueError(f"Determinant is {det}, not 1")

    @staticmethod
    def identity() -> 'SL2R':
        return SL2R(1, 0, 0, 1)

    def __mul__(self, other: 'SL2R') -> 'SL2R':
        return SL2R(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inv(self) -> 'SL2R':
        return SL2R(self.d, -self.b, -self.c, self.a)

    def trace(self) -> float:
        return self.a + self.d

    def classify(self) -> str:
        t = abs(self.trace())
        if t > 2: return "hyperbolic"
        elif t < 2: return "elliptic"
        else: return "parabolic"

    def displacement(self) -> float:
        return abs(self.trace()) - 2

    def pow(self, n: int) -> 'SL2R':
        if n == 0:
            return SL2R.identity()
        result = self
        for _ in range(n - 1):
            result = result * self
        return result

    def __repr__(self) -> str:
        return f"SL2R({self.a:.4f}, {self.b:.4f}, {self.c:.4f}, {self.d:.4f})"


# ═══════════════════════════════════════════════════════════════
# Part 2: Demonstrations
# ═══════════════════════════════════════════════════════════════

def demo_sl2r_group():
    """Demonstrate SL(2,R) group properties."""
    print("=" * 60)
    print("Demo 1: SL(2,R) Group Structure")
    print("=" * 60)

    # Standard generators of PSL(2,Z)
    S = SL2R(0, -1, 1, 0)   # S: z -> -1/z
    T = SL2R(1, 1, 0, 1)    # T: z -> z+1

    print(f"\nS = {S}, trace = {S.trace():.4f}, type = {S.classify()}")
    print(f"T = {T}, trace = {T.trace():.4f}, type = {T.classify()}")

    # Verify group axioms
    I = SL2R.identity()
    print(f"\nS * S^(-1) = {S * S.inv()}")
    print(f"T * T^(-1) = {T * T.inv()}")

    # S has order 4 in SL(2,Z), order 2 in PSL(2,Z)
    S2 = S * S
    print(f"\nS^2 = {S2}, trace = {S2.trace():.4f}")
    S4 = S2 * S2
    print(f"S^4 = {S4}, trace = {S4.trace():.4f} (= identity)")

    # Classification
    print("\n--- Classification Examples ---")
    examples = [
        ("Identity", I),
        ("S (rotation)", S),
        ("T (translation)", T),
        ("T^2", T * T),
        ("ST", S * T),
        ("STS", S * T * S),
    ]
    for name, M in examples:
        print(f"  {name}: trace={M.trace():.4f}, |trace|={abs(M.trace()):.4f}, type={M.classify()}")


def demo_chebyshev_recurrence():
    """Verify the Chebyshev trace recurrence: tr(M^{n+2}) = tr(M)*tr(M^{n+1}) - tr(M^n)."""
    print("\n" + "=" * 60)
    print("Demo 2: Chebyshev-Trace Recurrence")
    print("=" * 60)

    M = SL2R(2, 1, 1, 1)  # A hyperbolic element
    print(f"\nM = {M}, trace = {M.trace():.6f}")
    print(f"\nVerifying: tr(M^{{n+2}}) = tr(M) * tr(M^{{n+1}}) - tr(M^n)")
    print(f"{'n':>3} | {'tr(M^n)':>14} | {'tr(M)*tr(M^{n-1})-tr(M^{n-2})':>30} | {'Match':>5}")
    print("-" * 60)

    traces = [M.pow(i).trace() for i in range(12)]
    t = M.trace()
    for n in range(2, 12):
        predicted = t * traces[n-1] - traces[n-2]
        actual = traces[n]
        match = abs(predicted - actual) < 1e-8
        print(f"{n:>3} | {actual:>14.6f} | {predicted:>30.6f} | {'✓' if match else '✗':>5}")


def demo_conjugation_invariance():
    """Verify trace conjugation invariance: tr(NMN^{-1}) = tr(M)."""
    print("\n" + "=" * 60)
    print("Demo 3: Trace Conjugation Invariance")
    print("=" * 60)

    M = SL2R(3, 1, 2, 1)
    conjugators = [
        ("S", SL2R(0, -1, 1, 0)),
        ("T", SL2R(1, 1, 0, 1)),
        ("T^3", SL2R(1, 3, 0, 1)),
        ("ST^2S", SL2R(0, -1, 1, 0) * SL2R(1, 2, 0, 1) * SL2R(0, -1, 1, 0)),
    ]

    print(f"\nM = {M}, tr(M) = {M.trace():.6f}")
    for name, N in conjugators:
        conj = N * M * N.inv()
        print(f"  tr({name} · M · {name}^(-1)) = {conj.trace():.6f}  ✓" if abs(conj.trace() - M.trace()) < 1e-10 else "  ✗")


def demo_trace_product_identity():
    """Verify tr(MN) + tr(MN^{-1}) = tr(M) * tr(N)."""
    print("\n" + "=" * 60)
    print("Demo 4: Trace Product Identity")
    print("=" * 60)

    pairs = [
        (SL2R(2, 1, 1, 1), SL2R(1, 1, 0, 1)),
        (SL2R(3, 1, 2, 1), SL2R(0, -1, 1, 0)),
        (SL2R(5, 2, 2, 1), SL2R(3, 1, 2, 1)),
    ]

    for M, N in pairs:
        lhs = (M * N).trace() + (M * N.inv()).trace()
        rhs = M.trace() * N.trace()
        print(f"  tr(MN) + tr(MN⁻¹) = {lhs:.6f}, tr(M)·tr(N) = {rhs:.6f}  {'✓' if abs(lhs-rhs)<1e-10 else '✗'}")


def demo_hyperbolic_counting():
    """Count lattice points in hyperbolic balls of increasing radius."""
    print("\n" + "=" * 60)
    print("Demo 5: Hyperbolic Lattice Point Counting")
    print("=" * 60)

    # Generate orbit points of PSL(2,Z) acting on i in the upper half-plane
    # Use generators S and T to build words up to length L
    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)
    Ti = T.inv()

    # BFS to find orbit elements
    visited = {}  # trace -> element
    queue = [SL2R.identity()]
    generators = [S, T, Ti, S.inv()]

    for _ in range(6):  # depth
        next_queue = []
        for M in queue:
            for g in generators:
                N = M * g
                t = round(N.trace(), 8)
                if t not in visited:
                    visited[t] = N
                    next_queue.append(N)
        queue = next_queue

    # Collect displacement values
    displacements = sorted(set(abs(t) - 2 for t in visited.keys() if abs(t) >= 2))

    print(f"\nFound {len(visited)} distinct trace values")
    print(f"\nCounting non-elliptic elements by displacement threshold:")
    for threshold in [0, 1, 2, 5, 10, 20]:
        count = sum(1 for d in displacements if d <= threshold)
        print(f"  displacement ≤ {threshold:>3}: {count:>5} elements")


def demo_hyperbolic_zeta():
    """Compute the partial hyperbolic zeta function."""
    print("\n" + "=" * 60)
    print("Demo 6: Partial Hyperbolic Zeta Function")
    print("=" * 60)

    # Use displacement values as "norms"
    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)

    norms = []
    for a in range(-5, 6):
        for b in range(-5, 6):
            for c in range(-5, 6):
                d_val = (1 + b * c)
                if a != 0 and d_val % a == 0:
                    d = d_val // a
                    if a * d - b * c == 1:
                        disp = abs(a + d) - 2
                        if disp > 0.01:
                            norms.append(disp)

    norms = sorted(set(norms))[:50]  # Take first 50 distinct norms

    print(f"\nUsing {len(norms)} positive displacement values")
    print(f"\n{'s':>6} | {'ζ_H(s)':>14}")
    print("-" * 25)
    for s in [0.5, 1.0, 1.5, 2.0, 2.5, 3.0]:
        zeta = sum(1.0 / n ** (2 * s) for n in norms if n > 0)
        print(f"{s:>6.1f} | {zeta:>14.6f}")


if __name__ == "__main__":
    demo_sl2r_group()
    demo_chebyshev_recurrence()
    demo_conjugation_invariance()
    demo_trace_product_identity()
    demo_hyperbolic_counting()
    demo_hyperbolic_zeta()
    print("\n" + "=" * 60)
    print("All demonstrations complete!")
    print("=" * 60)


"""
Visualization: Chebyshev-Trace Recurrence and Growth
=====================================================

Shows how traces of powers of SL(2,R) elements follow the Chebyshev
recurrence, exhibiting exponential growth for hyperbolic elements.
This connects hyperbolic geometry to classical approximation theory.
"""

import math
import matplotlib.pyplot as plt


def chebyshev_traces(trace_M, n_terms):
    """Compute traces via Chebyshev recurrence."""
    if n_terms <= 0:
        return []
    traces = [2.0]
    if n_terms == 1:
        return traces
    traces.append(trace_M)
    for k in range(2, n_terms):
        traces.append(trace_M * traces[k-1] - traces[k-2])
    return traces


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Trace growth for different element types
    ax = axes[0, 0]
    n = 20
    ns = list(range(n))

    # Hyperbolic: tr = 3
    traces_hyp = chebyshev_traces(3.0, n)
    ax.semilogy(ns, [abs(t) for t in traces_hyp], 'r-o', markersize=3,
                label='Hyperbolic (tr=3)')

    # Barely hyperbolic: tr = 2.1
    traces_bh = chebyshev_traces(2.1, n)
    ax.semilogy(ns, [abs(t) for t in traces_bh], 'orange', marker='s',
                markersize=3, label='Hyperbolic (tr=2.1)')

    # Parabolic: tr = 2
    traces_par = chebyshev_traces(2.0, n)
    ax.plot(ns, [abs(t) for t in traces_par], 'g-^', markersize=3,
            label='Parabolic (tr=2)')

    # Elliptic: tr = 1
    traces_ell = chebyshev_traces(1.0, n)
    ax.plot(ns, [max(abs(t), 0.01) for t in traces_ell], 'b-v', markersize=3,
            label='Elliptic (tr=1)')

    ax.set_xlabel('Power n')
    ax.set_ylabel('|tr(M^n)|')
    ax.set_title('Trace Growth by Element Type')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Chebyshev polynomial connection
    ax = axes[0, 1]
    # tr(M^n) = 2*T_n(tr(M)/2) where T_n is Chebyshev polynomial
    x = [i * 0.01 for i in range(-300, 301)]
    for n_val in [2, 3, 5, 8]:
        y = [chebyshev_traces(2*xi, n_val+1)[-1] / 2 for xi in x]
        ax.plot(x, y, label=f'T_{n_val}(x)')
    ax.set_xlabel('x = tr(M)/2')
    ax.set_ylabel('T_n(x) = tr(M^n)/2')
    ax.set_title('Chebyshev Polynomials from SL(2) Traces')
    ax.set_ylim(-3, 3)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)

    # Panel 3: Displacement spectrum
    ax = axes[1, 0]

    # Generate SL(2,Z) elements by direct enumeration
    traces_set = set()
    for a in range(-8, 9):
        for b in range(-8, 9):
            for c in range(-8, 9):
                if a == 0:
                    continue
                rem = 1 + b * c
                if rem % a == 0:
                    d = rem // a
                    if a * d - b * c == 1:
                        t = abs(a + d)
                        if t > 2:
                            traces_set.add(t)

    displacements = sorted(t - 2 for t in traces_set)[:80]
    ax.bar(range(len(displacements)), displacements, color='steelblue', alpha=0.7)
    ax.set_xlabel('Index')
    ax.set_ylabel('Displacement |tr(M)| - 2')
    ax.set_title('Displacement Spectrum of PSL(2,ℤ)')
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 4: Partial zeta function
    ax = axes[1, 1]
    if displacements:
        s_vals = [i * 0.05 for i in range(10, 80)]
        zeta_vals = []
        for s in s_vals:
            z = sum(1.0 / d**(2*s) for d in displacements if d > 0.01)
            zeta_vals.append(z)
        ax.plot(s_vals, zeta_vals, 'darkred', linewidth=2)
        ax.set_xlabel('s')
        ax.set_ylabel('ζ_H(s)')
        ax.set_title('Partial Hyperbolic Zeta Function')
        ax.grid(True, alpha=0.3)
        ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='y=1')
        ax.legend()

    fig.suptitle('Hyperbolic Number Theory: Chebyshev Connection & Spectral Data',
                 fontsize=15, fontweight='bold', y=1.01)
    plt.tight_layout()
    plt.savefig('chebyshev_traces.png', dpi=150, bbox_inches='tight')
    print("Saved chebyshev_traces.png")


if __name__ == "__main__":
    main()


"""
Visualization: Poincaré Disk with Hyperbolic Lattice Points
============================================================

Visualizes the orbit of the origin under PSL(2,Z) in the Poincaré disk model,
showing how "hyperbolic integers" tile the hyperbolic plane. Points are colored
by their classification (hyperbolic/elliptic/parabolic).
"""

import math
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


class SL2R:
    """Minimal SL(2,R) for visualization."""
    def __init__(self, a, b, c, d):
        self.a, self.b, self.c, self.d = float(a), float(b), float(c), float(d)

    @staticmethod
    def identity():
        return SL2R(1, 0, 0, 1)

    def mul(self, other):
        return SL2R(
            self.a*other.a + self.b*other.c, self.a*other.b + self.b*other.d,
            self.c*other.a + self.d*other.c, self.c*other.b + self.d*other.d)

    def inv(self):
        return SL2R(self.d, -self.b, -self.c, self.a)

    def trace(self):
        return self.a + self.d

    def classify(self):
        t = abs(self.trace())
        if t > 2.01: return "hyperbolic"
        elif t < 1.99: return "elliptic"
        return "parabolic"


def mobius_to_disk(M, z_re=0.0, z_im=1.0):
    """
    Apply Möbius transformation M to z = z_re + i*z_im in the upper half-plane,
    then map to the Poincaré disk via the Cayley transform w = (z-i)/(z+i).
    """
    # M acts on upper half-plane: z -> (az+b)/(cz+d)
    denom_re = M.c * z_re + M.d
    denom_im = M.c * z_im
    denom_sq = denom_re**2 + denom_im**2

    if denom_sq < 1e-15:
        return None, None

    num_re = M.a * z_re + M.b
    num_im = M.a * z_im

    w_re = (num_re * denom_re + num_im * denom_im) / denom_sq
    w_im = (num_im * denom_re - num_re * denom_im) / denom_sq

    # Cayley transform: disk_z = (w - i) / (w + i)
    # w - i = (w_re, w_im - 1), w + i = (w_re, w_im + 1)
    plus_re = w_re
    plus_im = w_im + 1
    minus_re = w_re
    minus_im = w_im - 1

    d_sq = plus_re**2 + plus_im**2
    if d_sq < 1e-15:
        return None, None

    disk_re = (minus_re * plus_re + minus_im * plus_im) / d_sq
    disk_im = (minus_im * plus_re - minus_re * plus_im) / d_sq

    return disk_re, disk_im


def main():
    # Generate PSL(2,Z) elements
    S = SL2R(0, -1, 1, 0)
    T = SL2R(1, 1, 0, 1)
    Ti = SL2R(1, -1, 0, 1)

    elements = []
    seen = set()

    def key(M):
        return (round(M.a, 4), round(M.b, 4), round(M.c, 4), round(M.d, 4))

    queue = [SL2R.identity()]
    seen.add(key(SL2R.identity()))
    elements.append(SL2R.identity())

    for _ in range(7):
        next_q = []
        for M in queue:
            for g in [S, T, Ti, S.inv()]:
                N = M.mul(g)
                k = key(N)
                if k not in seen:
                    seen.add(k)
                    elements.append(N)
                    next_q.append(N)
        queue = next_q

    # Map to disk
    hyp_x, hyp_y = [], []
    ell_x, ell_y = [], []
    par_x, par_y = [], []

    for M in elements:
        x, y = mobius_to_disk(M)
        if x is None:
            continue
        r = math.sqrt(x**2 + y**2)
        if r >= 0.99:
            continue

        cls = M.classify()
        if cls == "hyperbolic":
            hyp_x.append(x); hyp_y.append(y)
        elif cls == "elliptic":
            ell_x.append(x); ell_y.append(y)
        else:
            par_x.append(x); par_y.append(y)

    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    # Draw disk boundary
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Draw geodesics (arcs) connecting some nearby points
    all_pts = list(zip(hyp_x + ell_x + par_x, hyp_y + ell_y + par_y))
    for i in range(len(all_pts)):
        for j in range(i+1, min(i+3, len(all_pts))):
            x1, y1 = all_pts[i]
            x2, y2 = all_pts[j]
            dist = math.sqrt((x1-x2)**2 + (y1-y2)**2)
            if dist < 0.3:
                ax.plot([x1, x2], [y1, y2], color='lightgray', linewidth=0.3, alpha=0.5)

    # Plot points
    ax.scatter(hyp_x, hyp_y, c='#e74c3c', s=15, alpha=0.7, label=f'Hyperbolic ({len(hyp_x)})', zorder=5)
    ax.scatter(ell_x, ell_y, c='#3498db', s=20, alpha=0.8, label=f'Elliptic ({len(ell_x)})', zorder=5)
    ax.scatter(par_x, par_y, c='#2ecc71', s=25, alpha=0.8, label=f'Parabolic ({len(par_x)})', zorder=5)

    # Origin
    ax.scatter([0], [0], c='gold', s=100, marker='*', zorder=10, label='Origin (i)')

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.legend(loc='upper right', fontsize=11)
    ax.set_title('Hyperbolic Integers: PSL(2,ℤ) Orbit in the Poincaré Disk',
                 fontsize=14, fontweight='bold')
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')

    # Add annotation
    ax.text(0.02, -1.08, 'Points are images of i under PSL(2,ℤ) — the "integers" of the hyperbolic plane',
            fontsize=9, style='italic', color='gray')

    plt.tight_layout()
    plt.savefig('poincare_disk_lattice.png', dpi=150, bbox_inches='tight')
    print("Saved poincare_disk_lattice.png")


if __name__ == "__main__":
    main()


"""
Visualization: Hyperbolic Tessellation and Prime Classification
================================================================

Shows the fundamental domain tessellation of the modular group PSL(2,Z)
and classifies group elements into hyperbolic "primes" (generators) and
"composites" (products of generators).
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def mobius_uhp(a, b, c, d, z_re, z_im):
    """Apply Möbius transform (az+b)/(cz+d) in upper half-plane."""
    denom_re = c * z_re + d
    denom_im = c * z_im
    denom_sq = denom_re**2 + denom_im**2
    if denom_sq < 1e-15:
        return None, None
    num_re = a * z_re + b
    num_im = a * z_im
    w_re = (num_re * denom_re + num_im * denom_im) / denom_sq
    w_im = (num_im * denom_re - num_re * denom_im) / denom_sq
    return w_re, w_im


def cayley_to_disk(z_re, z_im):
    """Cayley transform: upper half-plane to disk."""
    plus_re, plus_im = z_re, z_im + 1
    minus_re, minus_im = z_re, z_im - 1
    d_sq = plus_re**2 + plus_im**2
    if d_sq < 1e-15:
        return None, None
    return ((minus_re*plus_re + minus_im*plus_im) / d_sq,
            (minus_im*plus_re - minus_re*plus_im) / d_sq)


def draw_geodesic_arc(ax, z1_re, z1_im, z2_re, z2_im, color='gray', alpha=0.3, lw=0.5):
    """Draw a hyperbolic geodesic between two points in the disk."""
    # Simple: just draw a straight line (approximation for nearby points)
    ax.plot([z1_re, z2_re], [z1_im, z2_im], color=color, alpha=alpha, linewidth=lw)


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # ──────────────────────────────────────────
    # Panel 1: Fundamental domain in upper half-plane
    # ──────────────────────────────────────────
    ax = axes[0]

    # Draw fundamental domain of PSL(2,Z)
    # Boundaries: Re(z) = -1/2, Re(z) = 1/2, |z| = 1
    theta = np.linspace(np.pi/3, 2*np.pi/3, 100)
    arc_x = np.cos(theta)
    arc_y = np.sin(theta)
    ax.plot(arc_x, arc_y, 'k-', linewidth=2)
    ax.plot([-0.5, -0.5], [np.sin(np.pi/3), 3], 'k-', linewidth=2)
    ax.plot([0.5, 0.5], [np.sin(np.pi/3), 3], 'k-', linewidth=2)

    # Fill fundamental domain
    fill_x = list(arc_x) + [0.5, 0.5, -0.5, -0.5] + [arc_x[0]]
    fill_y = list(arc_y) + [arc_y[-1], 3, 3, arc_y[0]] + [arc_y[0]]
    ax.fill(fill_x, fill_y, alpha=0.15, color='gold')

    # Draw translated copies
    for n in range(-3, 4):
        if n == 0:
            continue
        theta_t = np.linspace(0, np.pi, 100)
        cx = np.cos(theta_t) + n
        cy = np.sin(theta_t)
        ax.plot(cx, cy, 'gray', linewidth=0.5, alpha=0.5)
        ax.plot([n - 0.5, n - 0.5], [0, 3], 'gray', linewidth=0.3, alpha=0.3)
        ax.plot([n + 0.5, n + 0.5], [0, 3], 'gray', linewidth=0.3, alpha=0.3)

    # Mark special points
    ax.plot(0, 1, 'r*', markersize=15, zorder=10, label='i (origin)')
    ax.plot(-0.5, math.sqrt(3)/2, 'bs', markersize=8, zorder=10, label='ρ = e^{2πi/3}')
    ax.plot(0.5, math.sqrt(3)/2, 'bs', markersize=8, zorder=10)

    # Draw some images under S and T
    special_pts = [(0, 1)]  # Start at i
    # T(i) = i+1
    special_pts.append((1, 1))
    # S(i) = -1/i = i (fixed!)
    # T^{-1}(i) = i-1
    special_pts.append((-1, 1))
    # ST(i) = S(i+1) = -1/(i+1) = (-1+i)/2... compute properly
    z_re, z_im = 1, 1  # i+1
    w_re, w_im = mobius_uhp(0, -1, 1, 0, z_re, z_im)
    if w_re is not None:
        special_pts.append((w_re, w_im))

    for x, y in special_pts[1:]:
        ax.plot(x, y, 'go', markersize=6, zorder=8)

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(0, 3.5)
    ax.set_aspect('equal')
    ax.set_title('Upper Half-Plane: Fundamental Domain of PSL(2,ℤ)', fontsize=12)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.legend(loc='upper right', fontsize=9)

    # ──────────────────────────────────────────
    # Panel 2: Orbit in Poincaré disk with word length coloring
    # ──────────────────────────────────────────
    ax = axes[1]

    # Draw disk boundary
    circle = plt.Circle((0, 0), 1, fill=False, color='black', linewidth=2)
    ax.add_patch(circle)

    # Generate orbit with word length tracking
    class M:
        def __init__(self, a, b, c, d, wl=0):
            self.a, self.b, self.c, self.d = a, b, c, d
            self.wl = wl
        def mul(self, other):
            return M(self.a*other.a+self.b*other.c, self.a*other.b+self.b*other.d,
                     self.c*other.a+self.d*other.c, self.c*other.b+self.d*other.d,
                     self.wl + 1)
        def key(self):
            return (round(self.a,3), round(self.b,3), round(self.c,3), round(self.d,3))

    S_g = M(0, -1, 1, 0, 0)
    T_g = M(1, 1, 0, 1, 0)
    Ti_g = M(1, -1, 0, 1, 0)

    orbit = {}
    queue = [M(1, 0, 0, 1, 0)]
    orbit[queue[0].key()] = 0

    for _ in range(6):
        next_q = []
        for m in queue:
            for g in [S_g, T_g, Ti_g]:
                n = m.mul(g)
                k = n.key()
                if k not in orbit:
                    orbit[k] = n.wl
                    next_q.append(n)
        queue = next_q

    # Convert to disk coordinates
    pts_by_wl = {}
    for (a, b, c, d), wl in orbit.items():
        w_re, w_im = mobius_uhp(a, b, c, d, 0, 1)
        if w_re is None:
            continue
        dx, dy = cayley_to_disk(w_re, w_im)
        if dx is None:
            continue
        r = math.sqrt(dx**2 + dy**2)
        if r >= 0.99:
            continue
        if wl not in pts_by_wl:
            pts_by_wl[wl] = ([], [])
        pts_by_wl[wl][0].append(dx)
        pts_by_wl[wl][1].append(dy)

    colors = ['gold', '#e74c3c', '#3498db', '#2ecc71', '#9b59b6', '#e67e22', '#1abc9c']
    for wl in sorted(pts_by_wl.keys()):
        xs, ys = pts_by_wl[wl]
        c = colors[min(wl, len(colors)-1)]
        s = max(5, 30 - 4 * wl)
        label = f'Word length {wl}' if wl <= 5 else None
        ax.scatter(xs, ys, c=c, s=s, alpha=0.8, label=label, zorder=5+wl)

    ax.set_xlim(-1.15, 1.15)
    ax.set_ylim(-1.15, 1.15)
    ax.set_aspect('equal')
    ax.set_title('Poincaré Disk: Hyperbolic Integers by Word Length', fontsize=12)
    ax.set_xlabel('Re(z)')
    ax.set_ylabel('Im(z)')
    ax.legend(loc='upper right', fontsize=8)

    fig.suptitle('Hyperbolic Number Theory: The Modular Tessellation',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('tessellation.png', dpi=150, bbox_inches='tight')
    print("Saved tessellation.png")


if __name__ == "__main__":
    main()
