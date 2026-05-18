#!/usr/bin/env python3
"""
Applications of Chromatic Polynomials

Demonstrates real-world applications of chromatic polynomial theory:
1. Scheduling / register allocation (graph coloring)
2. Statistical physics (Potts model)
3. Network reliability
4. Frequency assignment
"""

import itertools
import math
from algorithms import SimpleGraph, chromatic_poly_deletion_contraction, chromatic_number, Polynomial


def scheduling_demo():
    """
    Application 1: Exam scheduling as graph coloring.
    
    Given courses that share students, schedule exams into the minimum
    number of time slots such that no student has two exams at once.
    """
    print("=" * 70)
    print("APPLICATION 1: EXAM SCHEDULING")
    print("=" * 70)
    
    # Courses: 0=Math, 1=Physics, 2=CS, 3=Chemistry, 4=Biology, 5=English
    courses = ["Math", "Physics", "CS", "Chemistry", "Biology", "English"]
    
    # Conflicts (shared students):
    conflicts = [
        (0, 1),  # Math-Physics
        (0, 2),  # Math-CS
        (1, 2),  # Physics-CS
        (1, 3),  # Physics-Chemistry
        (2, 5),  # CS-English
        (3, 4),  # Chemistry-Biology
    ]
    
    G = SimpleGraph.from_edges(6, conflicts)
    chi = chromatic_number(G)
    poly = chromatic_poly_deletion_contraction(G)
    
    print(f"\n  Courses: {', '.join(courses)}")
    print(f"  Conflicts: {len(conflicts)} pairs of courses share students")
    print(f"\n  Chromatic polynomial: χ(x) = {poly}")
    print(f"  Minimum time slots needed: χ(G) = {chi}")
    print(f"\n  Number of valid schedules with k time slots:")
    for k in range(1, 8):
        count = poly.eval(k)
        print(f"    k={k}: {count:>10} valid schedules")
    
    # Find an actual coloring
    print(f"\n  Example schedule with {chi} time slots:")
    vlist = sorted(G.vertices)
    for coloring in itertools.product(range(chi), repeat=6):
        color_map = dict(zip(vlist, coloring))
        proper = all(color_map[u] != color_map[v] for u, v in conflicts)
        if proper:
            slots = {}
            for c, name in zip(coloring, courses):
                slots.setdefault(c, []).append(name)
            for slot, names in sorted(slots.items()):
                print(f"    Slot {slot+1}: {', '.join(names)}")
            break


def potts_model_demo():
    """
    Application 2: Potts model partition function.
    
    The chromatic polynomial χ_G(q) is the zero-temperature limit of the
    q-state Potts model antiferromagnetic partition function:
    
    Z(G, q, β) = Σ_σ exp(-β Σ_{(i,j)∈E} δ(σ_i, σ_j))
    
    As β → ∞, Z → χ_G(q) (ground state degeneracy).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: POTTS MODEL IN STATISTICAL PHYSICS")
    print("=" * 70)
    
    # Triangular lattice fragment
    G = SimpleGraph.from_edges(6, [
        (0,1), (1,2),    # top row
        (3,4), (4,5),    # bottom row
        (0,3), (1,4), (2,5),  # vertical
        (0,4), (1,5),    # diagonal
    ])
    
    poly = chromatic_poly_deletion_contraction(G)
    
    print(f"\n  Graph: 6-vertex triangular lattice fragment")
    print(f"  |V| = {G.num_vertices}, |E| = {G.num_edges}")
    print(f"  χ_G(q) = {poly}")
    
    print(f"\n  Ground state degeneracy for q-state Potts model:")
    for q in range(1, 8):
        deg = poly.eval(q)
        entropy = math.log(deg) / G.num_vertices if deg > 0 else float('-inf')
        print(f"    q={q}: W_0 = {deg:>8}, S_0/N = {entropy:.4f}")
    
    # Finite temperature
    print(f"\n  Partition function at finite temperature (q=3):")
    q = 3
    print(f"    {'β':>8} {'Z(β)':>12} {'<E>/N':>10} {'S/N':>10}")
    
    vlist = sorted(G.vertices)
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0]:
        Z = 0
        E_avg = 0
        for coloring in itertools.product(range(q), repeat=G.num_vertices):
            cmap = dict(zip(vlist, coloring))
            energy = sum(1 for e in G.edges for u, v in [sorted(e)]
                        if cmap[u] == cmap[v])
            w = math.exp(-beta * energy)
            Z += w
            E_avg += energy * w
        E_avg /= Z
        S = math.log(Z) + beta * E_avg
        print(f"    {beta:8.1f} {Z:12.2f} {E_avg/G.num_vertices:10.4f} "
              f"{S/G.num_vertices:10.4f}")


def frequency_assignment_demo():
    """
    Application 3: Radio frequency assignment.
    
    Assign frequencies to radio towers such that nearby towers
    don't interfere. The number of valid assignments with f available
    frequencies is exactly χ_G(f).
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: RADIO FREQUENCY ASSIGNMENT")
    print("=" * 70)
    
    # Network of 8 radio towers with interference constraints
    towers = ["Tower_" + c for c in "ABCDEFGH"]
    interference = [
        (0,1), (0,2), (1,2), (1,3),
        (2,4), (3,4), (3,5),
        (4,5), (4,6), (5,7), (6,7)
    ]
    
    G = SimpleGraph.from_edges(8, interference)
    poly = chromatic_poly_deletion_contraction(G)
    chi = chromatic_number(G)
    
    print(f"\n  Network: {len(towers)} towers, {len(interference)} interference pairs")
    print(f"  Chromatic polynomial: χ(x) = {poly}")
    print(f"  Minimum frequencies needed: {chi}")
    print(f"  Degree: {poly.degree}, Monic: {poly.is_monic}")
    
    print(f"\n  Valid assignments with f frequencies:")
    for f in range(1, 10):
        count = poly.eval(f)
        print(f"    f={f}: {count:>12} valid assignments")
    
    print(f"\n  Flexibility ratio (assignments / total):")
    for f in [chi, chi+1, chi+2, 2*chi]:
        count = poly.eval(f)
        total = f ** G.num_vertices
        ratio = count / total if total > 0 else 0
        print(f"    f={f}: {count}/{total} = {ratio:.4%}")


def greedy_coloring_demo():
    """
    Application 4: Greedy coloring and Brooks' theorem.
    
    Demonstrates that χ(G) ≤ Δ(G) + 1 (greedy bound) and
    χ(G) ≤ Δ(G) for connected graphs that aren't complete or odd cycles.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: GREEDY COLORING & BROOKS' THEOREM")
    print("=" * 70)
    
    graphs = [
        ("Path P_5", SimpleGraph.path(5)),
        ("Cycle C_5 (odd)", SimpleGraph.cycle(5)),
        ("Cycle C_6 (even)", SimpleGraph.cycle(6)),
        ("K_4 (complete)", SimpleGraph.complete(4)),
        ("Petersen", SimpleGraph.petersen()),
    ]
    
    print(f"\n  {'Graph':<20} {'|V|':>4} {'|E|':>4} {'Δ(G)':>5} "
          f"{'χ(G)':>5} {'Δ+1':>5} {'Brooks?':>8}")
    print("  " + "-" * 60)
    
    for name, G in graphs:
        delta = G.max_degree()
        chi = chromatic_number(G)
        greedy = delta + 1
        brooks = "N/A" if chi == greedy else ("yes" if chi <= delta else "no")
        print(f"  {name:<20} {G.num_vertices:>4} {G.num_edges:>4} "
              f"{delta:>5} {chi:>5} {greedy:>5} {brooks:>8}")
    
    print(f"\n  Brooks' theorem: χ(G) ≤ Δ(G) unless G is complete or an odd cycle")
    print(f"  Greedy bound:   χ(G) ≤ Δ(G) + 1 always holds")


if __name__ == "__main__":
    scheduling_demo()
    potts_model_demo()
    frequency_assignment_demo()
    greedy_coloring_demo()


#!/usr/bin/env python3
"""
Chromatic Polynomial — Interactive Demonstrations

Demonstrates the chromatic polynomial computation via deletion-contraction
and Whitney rank formula, with concrete examples on fundamental graph classes.
"""

import itertools
from collections import defaultdict


def connected_components(vertices, edges):
    """Count connected components using union-find."""
    parent = {v: v for v in vertices}

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py

    for u, v in edges:
        union(u, v)

    return len(set(find(v) for v in vertices))


def chromatic_polynomial_whitney(vertices, edges):
    """
    Compute the chromatic polynomial using the Whitney rank formula:
      χ_G(k) = Σ_{A ⊆ E} (-1)^|A| · k^{c(A)}
    
    Returns a dictionary mapping component_count -> coefficient.
    """
    from sympy import symbols, expand, Poly
    x = symbols('x')
    
    poly = 0
    edge_list = list(edges)
    n = len(edge_list)
    
    for mask in range(2**n):
        subset = [edge_list[i] for i in range(n) if mask & (1 << i)]
        card = bin(mask).count('1')
        sign = (-1) ** card
        c = connected_components(vertices, subset)
        poly += sign * x**c
    
    return expand(poly)


def chromatic_polynomial_deletion_contraction(vertices, edges):
    """
    Compute the chromatic polynomial via deletion-contraction recursion.
    
    χ_G = χ_{G\e} - χ_{G/e}
    
    Base case: edgeless graph on n vertices has χ = x^n.
    """
    from sympy import symbols, expand
    x = symbols('x')
    
    edges = set(edges)
    if not edges:
        return x ** len(vertices)
    
    # Pick an edge to process
    u, v = min(edges)
    
    # Deletion: remove edge (u,v)
    deleted_edges = edges - {(u, v), (v, u)}
    poly_delete = chromatic_polynomial_deletion_contraction(vertices, deleted_edges)
    
    # Contraction: merge v into u
    new_vertices = [w for w in vertices if w != v]
    new_edges = set()
    for a, b in deleted_edges:
        a2 = u if a == v else a
        b2 = u if b == v else b
        if a2 != b2:
            new_edges.add((min(a2, b2), max(a2, b2)))
    
    poly_contract = chromatic_polynomial_deletion_contraction(new_vertices, new_edges)
    
    return expand(poly_delete - poly_contract)


def count_proper_colorings(vertices, edges, k):
    """Brute-force count proper colorings with k colors."""
    count = 0
    for coloring in itertools.product(range(k), repeat=len(vertices)):
        color_map = dict(zip(vertices, coloring))
        proper = True
        for u, v in edges:
            if color_map[u] == color_map[v]:
                proper = False
                break
        if proper:
            count += 1
    return count


def falling_factorial(k, n):
    """Compute k(k-1)(k-2)...(k-n+1)."""
    result = 1
    for i in range(n):
        result *= (k - i)
    return result


def demo_basic():
    """Demonstrate chromatic polynomials for basic graph classes."""
    from sympy import symbols
    x = symbols('x')
    
    print("=" * 70)
    print("CHROMATIC POLYNOMIAL DEMONSTRATIONS")
    print("=" * 70)
    
    # Example 1: Edgeless graph on 3 vertices
    print("\n--- Edgeless Graph E_3 (3 isolated vertices) ---")
    V = [0, 1, 2]
    E = []
    poly = chromatic_polynomial_whitney(V, E)
    print(f"  χ_E3(x) = {poly}")
    print(f"  Expected: x^3")
    for k in range(1, 5):
        actual = count_proper_colorings(V, E, k)
        formula = k**3
        print(f"  χ_E3({k}) = {actual} (formula: {formula})")
    
    # Example 2: Complete graph K_3
    print("\n--- Complete Graph K_3 (triangle) ---")
    V = [0, 1, 2]
    E = [(0,1), (0,2), (1,2)]
    poly = chromatic_polynomial_whitney(V, E)
    poly_dc = chromatic_polynomial_deletion_contraction(V, E)
    print(f"  χ_K3(x) [Whitney]  = {poly}")
    print(f"  χ_K3(x) [Del-Con]  = {poly_dc}")
    print(f"  Expected: x(x-1)(x-2) = x^3 - 3x^2 + 2x")
    for k in range(1, 6):
        actual = count_proper_colorings(V, E, k)
        formula = falling_factorial(k, 3)
        print(f"  χ_K3({k}) = {actual} (falling factorial: {formula})")
    
    # Example 3: Complete graph K_4
    print("\n--- Complete Graph K_4 ---")
    V = [0, 1, 2, 3]
    E = [(i,j) for i in range(4) for j in range(i+1, 4)]
    poly = chromatic_polynomial_whitney(V, E)
    print(f"  χ_K4(x) = {poly}")
    print(f"  Expected: x(x-1)(x-2)(x-3)")
    for k in range(1, 6):
        actual = count_proper_colorings(V, E, k)
        formula = falling_factorial(k, 4)
        print(f"  χ_K4({k}) = {actual} (falling factorial: {formula})")
    
    # Example 4: Path graph P_3 (a tree!)
    print("\n--- Path Graph P_3 (3 vertices, 2 edges — a tree) ---")
    V = [0, 1, 2]
    E = [(0,1), (1,2)]
    poly = chromatic_polynomial_whitney(V, E)
    print(f"  χ_P3(x) = {poly}")
    print(f"  Expected: x(x-1)^2")
    for k in range(1, 5):
        actual = count_proper_colorings(V, E, k)
        formula = k * (k-1)**2
        print(f"  χ_P3({k}) = {actual} (formula: {formula})")
    
    # Example 5: Cycle graph C_4
    print("\n--- Cycle Graph C_4 (4-cycle) ---")
    V = [0, 1, 2, 3]
    E = [(0,1), (1,2), (2,3), (3,0)]
    poly = chromatic_polynomial_whitney(V, E)
    poly_dc = chromatic_polynomial_deletion_contraction(V, E)
    print(f"  χ_C4(x) [Whitney] = {poly}")
    print(f"  χ_C4(x) [Del-Con] = {poly_dc}")
    print(f"  Expected: (x-1)^4 + (x-1) = x^4 - 4x^3 + 6x^2 - 3x")
    for k in range(1, 6):
        actual = count_proper_colorings(V, E, k)
        formula = (k-1)**4 + (k-1)
        print(f"  χ_C4({k}) = {actual} (formula: {formula})")
    
    # Example 6: Petersen graph
    print("\n--- Petersen Graph (10 vertices, 15 edges) ---")
    V = list(range(10))
    # Outer cycle: 0-1-2-3-4-0
    # Inner star: 5-7-9-6-8-5
    E = [(0,1),(1,2),(2,3),(3,4),(4,0),
         (0,5),(1,6),(2,7),(3,8),(4,9),
         (5,7),(7,9),(9,6),(6,8),(8,5)]
    poly = chromatic_polynomial_deletion_contraction(V, E)
    print(f"  χ_Petersen(x) = {poly}")
    for k in range(1, 5):
        actual = count_proper_colorings(V, E, k)
        print(f"  χ_Petersen({k}) = {actual}")
    print(f"  (Petersen graph has chromatic number 3)")
    
    # Verification: Whitney vs Deletion-Contraction agree
    print("\n--- Verification: Methods Agree ---")
    V = [0, 1, 2, 3]
    E = [(0,1), (1,2), (2,3)]  # Path P_4
    poly_w = chromatic_polynomial_whitney(V, E)
    poly_dc = chromatic_polynomial_deletion_contraction(V, E)
    print(f"  Path P_4:")
    print(f"    Whitney:         {poly_w}")
    print(f"    Del-Contraction: {poly_dc}")
    print(f"    Match: {poly_w == poly_dc}")


def demo_four_color():
    """Demonstrate the four-color theorem connection."""
    print("\n" + "=" * 70)
    print("FOUR-COLOR THEOREM CONNECTION")
    print("=" * 70)
    
    print("\nFor any planar graph G, the 4CT asserts χ_G(4) > 0.")
    print("We verify this for several small planar graphs:\n")
    
    graphs = {
        "K_4 (tetrahedron)": (list(range(4)),
            [(i,j) for i in range(4) for j in range(i+1,4)]),
        "Octahedron": (list(range(6)),
            [(0,1),(0,2),(0,3),(0,4),(1,2),(1,4),(1,5),(2,3),(2,5),(3,4),(3,5),(4,5)]),
        "Cube (Q_3)": (list(range(8)),
            [(0,1),(1,3),(3,2),(2,0),(4,5),(5,7),(7,6),(6,4),(0,4),(1,5),(2,6),(3,7)]),
        "Icosahedron": (list(range(12)),
            [(0,1),(0,2),(0,3),(0,4),(0,5),
             (1,2),(2,3),(3,4),(4,5),(5,1),
             (1,6),(2,6),(2,7),(3,7),(3,8),(4,8),(4,9),(5,9),(5,10),(1,10),
             (6,7),(7,8),(8,9),(9,10),(10,6),
             (6,11),(7,11),(8,11),(9,11),(10,11)]),
    }
    
    for name, (V, E) in graphs.items():
        chi_4 = count_proper_colorings(V, E, 4)
        chi_3 = count_proper_colorings(V, E, 3)
        chi_2 = count_proper_colorings(V, E, 2)
        print(f"  {name}:")
        print(f"    |V|={len(V)}, |E|={len(E)}")
        print(f"    χ_G(2) = {chi_2}, χ_G(3) = {chi_3}, χ_G(4) = {chi_4}")
        print(f"    4-colorable: {'YES' if chi_4 > 0 else 'NO'}")
        print()


def demo_potts_connection():
    """Demonstrate the connection to the Potts model."""
    print("\n" + "=" * 70)
    print("STATISTICAL PHYSICS: POTTS MODEL CONNECTION")
    print("=" * 70)
    
    print("""
The chromatic polynomial χ_G(q) equals the zero-temperature
antiferromagnetic q-state Potts model partition function:

  Z_Potts(G, q, β→∞) = χ_G(q)

This means every proper coloring theorem is also a theorem about
ground states of an antiferromagnetic spin system!
""")
    
    # Show partition function at finite temperature
    import math
    
    V = [0, 1, 2]
    E = [(0,1), (1,2), (0,2)]  # Triangle K_3
    q = 3
    
    print(f"Example: Triangle K_3 with q={q} states")
    print(f"  χ_K3({q}) = {count_proper_colorings(V, E, q)} ground states")
    print()
    
    print("  Partition function Z(β) for K_3 with 3 states:")
    print(f"  {'β':>8} {'Z(β)':>12} {'Free energy':>14}")
    for beta in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]:
        Z = 0
        for coloring in itertools.product(range(q), repeat=3):
            energy = sum(1 for u, v in E if coloring[u] == coloring[v])
            Z += math.exp(-beta * energy)
        F = -math.log(Z) / beta if beta > 0 else 0
        print(f"  {beta:8.2f} {Z:12.4f} {F:14.4f}")
    
    print(f"\n  As β→∞, Z → χ_K3({q}) = 6 (the ground states)")


if __name__ == "__main__":
    demo_basic()
    demo_four_color()
    demo_potts_connection()


#!/usr/bin/env python3
"""
Chromatic Polynomial Visualizations

Generates plots showing key properties of chromatic polynomials.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import (SimpleGraph, chromatic_poly_deletion_contraction,
                        chromatic_poly_complete, chromatic_poly_cycle,
                        chromatic_poly_tree, Polynomial)


def plot_chromatic_polynomials():
    """Plot chromatic polynomials for fundamental graph classes."""
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))
    x = np.linspace(-0.5, 6, 300)
    
    # Panel 1: Complete graphs
    ax = axes[0, 0]
    for n in range(2, 6):
        poly = chromatic_poly_complete(n)
        y = np.array([poly.eval(xi) for xi in x])
        ax.plot(x, y, label=f'$K_{n}$', linewidth=2)
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-20, 200)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors)')
    ax.set_ylabel('χ(k)')
    ax.set_title('Complete Graphs $K_n$')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 2: Cycle graphs
    ax = axes[0, 1]
    for n in range(3, 8):
        poly = chromatic_poly_cycle(n)
        y = np.array([poly.eval(xi) for xi in x])
        ax.plot(x, y, label=f'$C_{n}$', linewidth=2)
    ax.set_xlim(-0.5, 5)
    ax.set_ylim(-10, 100)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors)')
    ax.set_ylabel('χ(k)')
    ax.set_title('Cycle Graphs $C_n$')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 3: Trees
    ax = axes[1, 0]
    for n in range(2, 7):
        poly = chromatic_poly_tree(n)
        y = np.array([poly.eval(xi) for xi in x])
        ax.plot(x, y, label=f'$T_{n}$ (path)', linewidth=2)
    ax.set_xlim(-0.5, 5)
    ax.set_ylim(-10, 100)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors)')
    ax.set_ylabel('χ(k)')
    ax.set_title('Trees (Path Graphs)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    # Panel 4: Petersen graph
    ax = axes[1, 1]
    G = SimpleGraph.petersen()
    poly = chromatic_poly_deletion_contraction(G)
    y = np.array([poly.eval(xi) for xi in x])
    ax.plot(x, y, 'r-', linewidth=2.5, label='Petersen')
    
    # Mark integer values
    for k in range(7):
        val = poly.eval(k)
        color = 'green' if val > 0 else 'red'
        ax.plot(k, val, 'o', color=color, markersize=8, zorder=5)
    
    ax.set_xlim(-0.5, 6)
    ax.set_ylim(-1000, 25000)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors)')
    ax.set_ylabel('χ(k)')
    ax.set_title('Petersen Graph (χ = 3)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('chromatic_polynomials.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: chromatic_polynomials.png")


def plot_coefficient_patterns():
    """Plot coefficient patterns showing alternating signs and positivity."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    
    # Panel 1: Coefficients of chromatic polynomials
    ax = axes[0]
    graphs = {
        '$K_5$': SimpleGraph.complete(5),
        '$C_6$': SimpleGraph.cycle(6),
        '$P_5$': SimpleGraph.path(5),
        'Petersen': SimpleGraph.petersen(),
    }
    
    width = 0.2
    offsets = np.arange(len(graphs)) * width - width * (len(graphs)-1) / 2
    
    for idx, (name, G) in enumerate(graphs.items()):
        poly = chromatic_poly_deletion_contraction(G)
        coeffs = poly.coeffs
        degrees = list(range(len(coeffs)))
        ax.bar([d + offsets[idx] for d in degrees], coeffs,
               width=width, label=name, alpha=0.8)
    
    ax.set_xlabel('Degree')
    ax.set_ylabel('Coefficient')
    ax.set_title('Coefficient Patterns of χ_G(x)')
    ax.legend()
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(True, alpha=0.3, axis='y')
    
    # Panel 2: Evaluation at k=0,1,2,...,6 for various graphs
    ax = axes[1]
    for name, G in graphs.items():
        poly = chromatic_poly_deletion_contraction(G)
        ks = list(range(7))
        vals = [poly.eval(k) for k in ks]
        ax.semilogy(ks, [max(v, 0.5) for v in vals],
                    'o-', label=name, linewidth=2, markersize=6)
    
    ax.set_xlabel('k (number of colors)')
    ax.set_ylabel('χ_G(k) (log scale)')
    ax.set_title('Coloring Counts vs. Available Colors')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('coefficient_patterns.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: coefficient_patterns.png")


def plot_deletion_contraction_tree():
    """Visualize the deletion-contraction recursion tree for C_4."""
    fig, ax = plt.subplots(figsize=(14, 8))
    
    # Build the recursion tree for C_4
    import textwrap
    
    nodes = [
        (7, 7.5, "$C_4$\n$x^4-4x^3+6x^2-3x$"),
        (3.5, 5.5, "Delete edge\n$x^4-3x^3+3x^2-x$"),
        (10.5, 5.5, "Contract edge\n$x^3-2x^2+x$"),
        (1.5, 3.5, "Delete\n$x^4-2x^3+x^2$"),
        (5.5, 3.5, "Contract\n$x^3-x^2$"),
        (8.5, 3.5, "Delete\n$x^3-x^2$"),
        (12.5, 3.5, "Contract\n$x^2$"),
    ]
    
    edges_tree = [(0,1), (0,2), (1,3), (1,4), (2,5), (2,6)]
    edge_labels = ["G\\e", "G/e", "G\\e", "G/e", "G\\e", "G/e"]
    
    for i, (x, y, label) in enumerate(nodes):
        color = '#E8F5E9' if i == 0 else ('#FFF3E0' if i < 3 else '#E3F2FD')
        bbox = dict(boxstyle='round,pad=0.3', facecolor=color, alpha=0.8)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
                bbox=bbox, family='monospace')
    
    for (i, j), lbl in zip(edges_tree, edge_labels):
        x1, y1, _ = nodes[i]
        x2, y2, _ = nodes[j]
        ax.annotate('', xy=(x2, y2+0.5), xytext=(x1, y1-0.5),
                    arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx - 0.1, my + 0.1, lbl, fontsize=8, color='gray',
                ha='center', va='center')
    
    ax.set_xlim(-0.5, 14.5)
    ax.set_ylim(2.5, 8.5)
    ax.set_title('Deletion-Contraction Recursion Tree for $C_4$',
                 fontsize=14, fontweight='bold')
    ax.axis('off')
    
    # Add formula
    ax.text(7, 2.8,
            'χ_{C₄}(x) = x⁴ − 4x³ + 6x² − 3x = (x−1)⁴ + (x−1)',
            ha='center', fontsize=11, style='italic',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.tight_layout()
    plt.savefig('deletion_contraction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: deletion_contraction.png")


if __name__ == "__main__":
    plot_chromatic_polynomials()
    plot_coefficient_patterns()
    plot_deletion_contraction_tree()
    print("\nAll visualizations generated successfully!")
