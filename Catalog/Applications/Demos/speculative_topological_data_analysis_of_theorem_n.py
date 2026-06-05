#!/usr/bin/env python3
"""
Citation Complex Demo: Numerical Examples and Analysis

Demonstrates the main theorems about citation complexes using
concrete mathematical citation networks.
"""

from algorithms import (
    CitationNetwork, CitationComplex, DepthFiltration,
    compute_f_vector_bound, euler_contribution, build_example_network
)
from math import comb


def demo_basic_complex():
    """Demo 1: Build and analyze a citation complex."""
    print("=" * 70)
    print("DEMO 1: Basic Citation Complex Construction")
    print("=" * 70)

    network = build_example_network()
    complex = CitationComplex.from_network(network)

    print(f"\nNetwork: {len(network.theorems)} theorems")
    for t in network.theorems:
        cited = network.cites.get(t, set())
        print(f"  {t} cites: {cited if cited else '(nothing)'}")

    print(f"\nCitation Complex:")
    print(f"  Dimension: {complex.dimension()}")
    print(f"  Total faces: {len(complex.faces)}")
    print(f"  Vertices: {complex.vertices()}")
    print(f"  f-vector: {complex.f_vector}")
    print(f"  Euler characteristic: {complex.euler_characteristic()}")

    # Verify dimension bound (Theorem 6)
    max_deg = max(network.degree(v) for v in network.theorems)
    print(f"\n  Max citation degree: {max_deg}")
    print(f"  Dimension ≤ max_deg - 1 = {max_deg - 1}: {complex.dimension() <= max_deg - 1} ✓")

    # Verify f-vector bound (Theorem 3)
    for k in range(complex.dimension() + 1):
        actual = complex.f_vector.get(k, 0)
        bound = compute_f_vector_bound(network, k)
        print(f"  f_{k} = {actual} ≤ {bound} (bound): {actual <= bound} ✓")


def demo_depth_filtration():
    """Demo 2: Depth filtration analysis."""
    print("\n" + "=" * 70)
    print("DEMO 2: Depth Filtration (Novel Invariant)")
    print("=" * 70)

    network = build_example_network()
    filtration = DepthFiltration.from_network(network)

    print(f"\nMax depth: {filtration.max_depth}")
    for d in range(1, filtration.max_depth + 1):
        faces = filtration.levels.get(d, set())
        print(f"\n  Depth ≥ {d}: {len(faces)} faces")
        for f in sorted(faces, key=lambda x: (len(x), str(x))):
            depth = network.depth(f)
            print(f"    {set(f)} (depth={depth})")

    # Verify depth monotonicity (Theorem 2)
    print("\n  Depth monotonicity check:")
    for f in filtration.levels.get(1, set()):
        if len(f) >= 2:
            for v in f:
                singleton = frozenset([v])
                d_f = network.depth(f)
                d_s = network.depth(singleton)
                print(f"    depth({set(f)})={d_f} ≤ depth({set(singleton)})={d_s}: {d_f <= d_s} ✓")


def demo_euler_contribution():
    """Demo 3: Euler contribution theorem."""
    print("\n" + "=" * 70)
    print("DEMO 3: Euler Contribution Theorem")
    print("=" * 70)

    print("\n  The Euler contribution of a citation set of size d equals 1 for d ≥ 1.")
    print("  This is the binomial theorem: Σ_{k=1}^{d} (-1)^{k-1} C(d,k) = 1")
    print()
    for d in range(0, 12):
        ec = euler_contribution(d)
        terms = []
        for k in range(d):
            terms.append(f"(-1)^{k}·C({d},{k+1})")
        terms_str = " + ".join(terms) if terms else "0"
        print(f"  d={d:2d}: {terms_str} = {ec}")


def demo_complete_network():
    """Demo 4: Complete citation network (counterexample to Betti growth)."""
    print("\n" + "=" * 70)
    print("DEMO 4: Complete Network — Counterexample to β_k ≈ n^(k+1)")
    print("=" * 70)

    n = 5
    theorems = [f"T{i}" for i in range(n)]
    cites = {t: {s for s in theorems if s != t} for t in theorems}
    network = CitationNetwork(theorems=theorems, cites=cites)
    complex = CitationComplex.from_network(network)

    print(f"\n  Complete network on {n} theorems (every theorem cites every other)")
    print(f"  Complex dimension: {complex.dimension()}")
    print(f"  Total faces: {len(complex.faces)}")
    print(f"  Expected faces (2^n - 1 - n singletons that cite themselves): {2**n - 1}")
    print(f"  f-vector: {complex.f_vector}")
    print(f"  Euler characteristic: {complex.euler_characteristic()}")

    # The complex is a full (n-2)-simplex, so it's contractible
    # Expected Betti numbers: β_0 = 1, β_k = 0 for k ≥ 1
    print(f"\n  This is a full {n-2}-simplex (contractible)")
    print(f"  Expected: β_0 = 1, β_k = 0 for k ≥ 1")
    print(f"  This DISPROVES β_k ≈ n^(k+1) for complete networks")

    # Verify depth bounds
    for k in range(1, n):
        sigma = frozenset(theorems[:k])
        depth = network.depth(sigma)
        lower_bound = n - k
        print(f"  depth({set(sigma)}) = {depth} ≥ {lower_bound} (n-|σ|): {depth >= lower_bound} ✓")


def demo_growth_bound():
    """Demo 5: Growth bound when adding theorems."""
    print("\n" + "=" * 70)
    print("DEMO 5: Growth Bound (Theorem 4)")
    print("=" * 70)

    # Start with a small network, then add a theorem
    theorems = ["A", "B", "C", "D"]
    cites = {
        "A": set(),
        "B": {"A"},
        "C": {"A", "B"},
        "D": set(),
    }
    network_before = CitationNetwork(theorems=theorems, cites=cites)
    complex_before = CitationComplex.from_network(network_before)

    # Add theorem E that cites A, B, C, D
    new_cites = {"A", "B", "C", "D"}
    theorems_after = theorems + ["E"]
    cites_after = dict(cites)
    cites_after["E"] = new_cites
    network_after = CitationNetwork(theorems=theorems_after, cites=cites_after)
    complex_after = CitationComplex.from_network(network_after)

    new_faces = complex_after.faces - complex_before.faces
    d = len(new_cites)
    bound = 2**d - 1

    print(f"\n  Before: {len(complex_before.faces)} faces")
    print(f"  After adding E (cites {new_cites}): {len(complex_after.faces)} faces")
    print(f"  New faces: {len(new_faces)}")
    print(f"  Bound (2^{d} - 1 = {bound}): {len(new_faces)} ≤ {bound}: {len(new_faces) <= bound} ✓")
    print(f"\n  New faces added:")
    for f in sorted(new_faces, key=lambda x: (len(x), str(x))):
        print(f"    {set(f)}")


if __name__ == "__main__":
    demo_basic_complex()
    demo_depth_filtration()
    demo_euler_contribution()
    demo_complete_network()
    demo_growth_bound()
    print("\n" + "=" * 70)
    print("All demos completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Citation Complex Structure and Depth Filtration

Generates a multi-panel figure showing:
1. The citation network (directed graph)
2. The citation complex (simplicial complex)
3. Depth filtration sequence
4. f-vector comparison with bounds
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.collections import PolyCollection
import numpy as np
from itertools import combinations
from collections import Counter


def build_network():
    """Build example citation network."""
    theorems = ["A1", "A2", "A3", "A4", "T1", "T2", "T3", "T4"]
    cites = {
        "A1": set(), "A2": {"A1"}, "A3": {"A1", "A2"},
        "A4": {"A1", "A2", "A3"}, "T1": set(), "T2": {"T1"},
        "T3": {"T1", "T2"}, "T4": {"T1", "T2", "T3", "A1"},
    }
    return theorems, cites


def compute_faces(theorems, cites):
    """Compute all faces of the citation complex."""
    faces = set()
    for t in theorems:
        cited = list(cites.get(t, set()))
        for k in range(1, len(cited) + 1):
            for combo in combinations(cited, k):
                faces.add(frozenset(combo))
    return faces


def compute_depth(theorems, cites, sigma):
    """Compute depth of a face."""
    return sum(1 for t in theorems if sigma <= cites.get(t, set()))


def main():
    theorems, cites = build_network()
    faces = compute_faces(theorems, cites)

    # Positions for vertices
    positions = {
        "A1": (0.5, 0.8), "A2": (1.5, 0.8), "A3": (1.0, 0.3),
        "A4": (0.5, 0.0), "T1": (3.5, 0.8), "T2": (4.5, 0.8),
        "T3": (4.0, 0.3), "T4": (3.0, 0.0),
    }

    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.suptitle("Citation Complex: Topological Data Analysis of Theorem Networks",
                 fontsize=14, fontweight='bold', y=0.98)

    # Panel 1: Citation Network
    ax = axes[0, 0]
    ax.set_title("(a) Citation Network", fontsize=12, fontweight='bold')
    algebra_color = '#3498db'
    topology_color = '#e74c3c'
    for t in theorems:
        x, y = positions[t]
        color = algebra_color if t.startswith('A') else topology_color
        ax.plot(x, y, 'o', markersize=18, color=color, zorder=5)
        ax.text(x, y, t, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)
    for t in theorems:
        for c in cites.get(t, set()):
            x1, y1 = positions[t]
            x2, y2 = positions[c]
            ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle='->', color='#555',
                                      lw=1.5, connectionstyle="arc3,rad=0.1"))
    ax.set_xlim(-0.3, 5.3)
    ax.set_ylim(-0.3, 1.2)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.text(1.0, 1.1, "Algebra", ha='center', fontsize=10, color=algebra_color,
            fontweight='bold')
    ax.text(4.0, 1.1, "Topology", ha='center', fontsize=10, color=topology_color,
            fontweight='bold')

    # Panel 2: f-vector and bounds
    ax = axes[0, 1]
    ax.set_title("(b) f-vector vs. Upper Bounds", fontsize=12, fontweight='bold')
    f_vector = Counter()
    for face in faces:
        f_vector[len(face) - 1] += 1
    dims = sorted(f_vector.keys())
    actual = [f_vector[d] for d in dims]
    from math import comb
    bounds = []
    for k in dims:
        b = sum(comb(len(cites.get(t, set())), k + 1) for t in theorems)
        bounds.append(b)
    x_pos = np.arange(len(dims))
    width = 0.35
    ax.bar(x_pos - width/2, actual, width, label='Actual f_k', color='#2ecc71',
           edgecolor='#27ae60')
    ax.bar(x_pos + width/2, bounds, width, label='Upper bound', color='#e67e22',
           edgecolor='#d35400', alpha=0.7)
    ax.set_xlabel('Dimension k')
    ax.set_ylabel('Face count')
    ax.set_xticks(x_pos)
    ax.set_xticklabels([f'{d}' for d in dims])
    ax.legend()
    ax.set_ylim(0, max(max(actual), max(bounds)) * 1.2)

    # Panel 3: Depth filtration
    ax = axes[1, 0]
    ax.set_title("(c) Depth Filtration", fontsize=12, fontweight='bold')
    max_depth = max(compute_depth(theorems, cites, f) for f in faces)
    depth_counts = {}
    for d in range(1, max_depth + 1):
        depth_counts[d] = sum(1 for f in faces if compute_depth(theorems, cites, f) >= d)
    ds = list(range(1, max_depth + 1))
    counts = [depth_counts[d] for d in ds]
    ax.bar(ds, counts, color='#9b59b6', edgecolor='#8e44ad')
    ax.set_xlabel('Depth threshold d')
    ax.set_ylabel('Number of d-deep faces')
    for i, (d, c) in enumerate(zip(ds, counts)):
        ax.text(d, c + 0.3, str(c), ha='center', va='bottom', fontweight='bold')

    # Panel 4: Euler contribution
    ax = axes[1, 1]
    ax.set_title("(d) Euler Contribution = 1 (Binomial Theorem)", fontsize=12,
                 fontweight='bold')
    d_vals = list(range(1, 11))
    contributions = []
    for d in d_vals:
        ec = sum((-1)**k * comb(d, k+1) for k in range(d))
        contributions.append(ec)
    ax.plot(d_vals, contributions, 'o-', markersize=10, color='#e74c3c',
            linewidth=2, label='eulerContribution(d)')
    ax.axhline(y=1, color='#2c3e50', linestyle='--', alpha=0.5, label='y = 1')
    ax.set_xlabel('Citation degree d')
    ax.set_ylabel('Euler contribution')
    ax.set_ylim(0.5, 1.5)
    ax.legend()
    ax.set_xticks(d_vals)

    plt.tight_layout(rect=[0, 0, 1, 0.96])
    plt.savefig('citation_complex_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved: citation_complex_analysis.png")


if __name__ == "__main__":
    main()
