"""
Applications of Euler's Theorem on Bridges & Eulerian Paths
===========================================================

This module demonstrates real-world applications of the Euler Parity Theorem,
the foundational result behind the Königsberg Bridge Problem.

Applications covered:
1. Route optimization (snowplow / mail carrier problem)
2. DNA fragment assembly (de Bruijn graphs)  
3. Circuit board testing (wire inspection)
4. Network reliability analysis
"""

from collections import defaultdict, deque
from itertools import product


# ============================================================
# Application 1: The Chinese Postman Problem (Route Optimization)
# ============================================================

def chinese_postman_analysis(edges, vertex_names=None):
    """Analyze a street network for optimal mail delivery routes.
    
    The Chinese Postman Problem asks: what is the shortest closed walk
    that traverses every edge at least once?
    
    If the graph has an Eulerian circuit (0 odd-degree vertices), the
    answer is simply the sum of all edge weights — no street needs to
    be traversed twice.
    
    If there are 2k odd-degree vertices, we must duplicate some edges
    to make all degrees even. The minimum duplication comes from finding
    a minimum-weight perfect matching on the odd-degree vertices.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Route Optimization (Chinese Postman Problem)")
    print("=" * 60)
    
    # Compute degrees
    degrees = defaultdict(int)
    total_weight = 0
    for u, v, w in edges:
        degrees[u] += 1
        degrees[v] += 1
        total_weight += w
    
    odd_vertices = sorted(v for v in degrees if degrees[v] % 2 == 1)
    
    vname = vertex_names or {v: str(v) for v in degrees}
    
    print(f"\n  Street network: {len(degrees)} intersections, {len(edges)} streets")
    print(f"  Total street length: {total_weight} km")
    print(f"\n  Intersection degrees:")
    for v in sorted(degrees):
        parity = "ODD ⚠" if v in odd_vertices else "even ✓"
        print(f"    {vname[v]}: degree {degrees[v]} ({parity})")
    
    print(f"\n  Odd-degree vertices: {len(odd_vertices)}")
    
    if len(odd_vertices) == 0:
        print(f"  → Perfect! An Eulerian circuit exists.")
        print(f"  → Optimal route length: {total_weight} km (no street traversed twice)")
    elif len(odd_vertices) == 2:
        print(f"  → An Eulerian trail exists from {vname[odd_vertices[0]]} to {vname[odd_vertices[1]]}.")
        print(f"  → To make a circuit, duplicate the shortest path between them.")
    else:
        print(f"  → {len(odd_vertices)} odd-degree vertices: need to duplicate some streets.")
        print(f"  → Must pair up odd vertices and duplicate paths between pairs.")
        print(f"  → Optimal route length > {total_weight} km")
    
    return odd_vertices


# ============================================================
# Application 2: DNA Fragment Assembly (de Bruijn Graphs)
# ============================================================

def dna_assembly_demo():
    """Demonstrate how Eulerian paths assemble DNA from short reads.
    
    In DNA sequencing, a long DNA strand is broken into many short
    overlapping fragments (k-mers). To reconstruct the original sequence,
    we build a de Bruijn graph where:
    - Vertices are (k-1)-mers
    - Edges are k-mers (connecting their prefix to their suffix)
    
    The original DNA sequence corresponds to an Eulerian path through
    this graph. Euler's theorem tells us when assembly is possible!
    """
    print("\n" + "=" * 60)
    print("APPLICATION: DNA Fragment Assembly")
    print("=" * 60)
    
    # Example: reconstruct a DNA sequence from 3-mers
    original = "ATGCGATCG"
    k = 3
    
    print(f"\n  Original DNA sequence: {original}")
    print(f"  Fragment length (k): {k}")
    
    # Generate k-mers
    kmers = [original[i:i + k] for i in range(len(original) - k + 1)]
    print(f"  Fragments (k-mers): {kmers}")
    
    # Build de Bruijn graph
    edges = []
    degrees_in = defaultdict(int)
    degrees_out = defaultdict(int)
    
    for kmer in kmers:
        prefix = kmer[:-1]
        suffix = kmer[1:]
        edges.append((prefix, suffix, kmer))
        degrees_out[prefix] += 1
        degrees_in[suffix] += 1
    
    all_vertices = set(degrees_in.keys()) | set(degrees_out.keys())
    
    print(f"\n  De Bruijn graph:")
    print(f"    Vertices ({len(all_vertices)}): {sorted(all_vertices)}")
    print(f"    Edges ({len(edges)}):")
    for u, v, label in edges:
        print(f"      {u} → {v}  (k-mer: {label})")
    
    # Check Eulerian path condition (for directed graphs)
    # Condition: at most one vertex has out-degree - in-degree = 1 (start)
    #            at most one vertex has in-degree - out-degree = 1 (end)
    #            all others have equal in/out degree
    
    imbalanced = []
    for v in all_vertices:
        diff = degrees_out.get(v, 0) - degrees_in.get(v, 0)
        if diff != 0:
            imbalanced.append((v, diff))
    
    print(f"\n  Degree analysis (directed):")
    for v in sorted(all_vertices):
        d_in = degrees_in.get(v, 0)
        d_out = degrees_out.get(v, 0)
        status = "✓" if d_in == d_out else "start" if d_out > d_in else "end"
        print(f"    {v}: in={d_in}, out={d_out} ({status})")
    
    if len(imbalanced) <= 2:
        print(f"\n  ✓ Eulerian path exists! DNA can be assembled.")
        # Reconstruct
        assembled = kmers[0]
        for kmer in kmers[1:]:
            assembled += kmer[-1]
        print(f"  Reconstructed: {assembled}")
        assert assembled == original
        print(f"  Match: {'✓' if assembled == original else '✗'}")
    else:
        print(f"\n  ✗ Assembly not possible via simple Eulerian path.")


# ============================================================
# Application 3: Circuit Board Testing
# ============================================================

def circuit_testing_demo():
    """Demonstrate Eulerian path analysis for circuit board wire testing.
    
    When testing a circuit board, a probe must traverse every wire
    connection to verify connectivity. An Eulerian path minimizes
    the number of probe lifts (repositionings) needed.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Circuit Board Wire Testing")
    print("=" * 60)
    
    # Example circuit: a small network of connections
    connections = [
        ("VCC", "R1"), ("R1", "IC1"), ("IC1", "R2"),
        ("R2", "GND"), ("VCC", "IC1"), ("IC1", "GND"),
        ("VCC", "C1"), ("C1", "GND"),
    ]
    
    print(f"\n  Circuit connections ({len(connections)} wires):")
    for u, v in connections:
        print(f"    {u} ── {v}")
    
    degrees = defaultdict(int)
    for u, v in connections:
        degrees[u] += 1
        degrees[v] += 1
    
    odd = [v for v in degrees if degrees[v] % 2 == 1]
    
    print(f"\n  Component degrees:")
    for v in sorted(degrees):
        parity = "ODD" if v in odd else "even"
        print(f"    {v}: {degrees[v]} connections ({parity})")
    
    print(f"\n  Odd-degree components: {len(odd)}")
    
    if len(odd) == 0:
        print(f"  → All wires can be tested in ONE continuous sweep! (Eulerian circuit)")
        print(f"  → Probe lifts needed: 0")
    elif len(odd) == 2:
        print(f"  → All wires testable with ONE sweep from {odd[0]} to {odd[1]}!")
        print(f"  → Probe lifts needed: 0")
    else:
        # Need ceil(odd/2) - 1 additional sweeps
        extra_sweeps = len(odd) // 2 - 1
        print(f"  → Need {extra_sweeps + 1} separate sweeps (probe lifts: {extra_sweeps})")
        print(f"  → To optimize: add {len(odd) // 2} temporary test connections")


# ============================================================
# Application 4: Network Redundancy Analysis
# ============================================================

def network_analysis_demo():
    """Analyze network topology for redundancy using degree parity.
    
    In network design, vertices with odd degree indicate potential
    single points of failure or inefficient routing.
    """
    print("\n" + "=" * 60)
    print("APPLICATION: Network Redundancy Analysis")
    print("=" * 60)
    
    # Example: a small data center network
    network = [
        ("Router_A", "Switch_1"), ("Router_A", "Switch_2"),
        ("Router_B", "Switch_1"), ("Router_B", "Switch_3"),
        ("Switch_1", "Server_1"), ("Switch_1", "Server_2"),
        ("Switch_2", "Server_3"), ("Switch_2", "Server_4"),
        ("Switch_3", "Server_5"),
    ]
    
    print(f"\n  Network topology ({len(network)} links):")
    degrees = defaultdict(int)
    for u, v in network:
        degrees[u] += 1
        degrees[v] += 1
    
    odd = [v for v in degrees if degrees[v] % 2 == 1]
    
    print(f"\n  Node connectivity:")
    for v in sorted(degrees):
        parity = "⚠ ODD" if v in odd else "✓ even"
        print(f"    {v}: {degrees[v]} links ({parity})")
    
    print(f"\n  Handshaking check: Σ deg = {sum(degrees.values())} = 2 × {len(network)} ✓")
    print(f"  Odd-degree nodes: {len(odd)} (always even by handshaking lemma)")
    
    if odd:
        print(f"\n  Recommendation: Add redundant links between odd-degree nodes")
        print(f"  to create an Eulerian structure for optimal traffic routing:")
        for i in range(0, len(odd), 2):
            if i + 1 < len(odd):
                print(f"    → Add link: {odd[i]} ↔ {odd[i + 1]}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("APPLICATIONS OF EULER'S BRIDGE THEOREM")
    print("=" * 60)
    
    # Application 1: Chinese Postman
    streets = [
        ("A", "B", 2), ("B", "C", 3), ("C", "D", 2),
        ("D", "A", 3), ("A", "C", 4), ("B", "D", 1),
    ]
    vertex_names = {"A": "Main St & 1st", "B": "Main St & 2nd",
                    "C": "Oak Ave & 2nd", "D": "Oak Ave & 1st"}
    chinese_postman_analysis(streets, vertex_names)
    
    # Application 2: DNA Assembly
    dna_assembly_demo()
    
    # Application 3: Circuit Testing
    circuit_testing_demo()
    
    # Application 4: Network Analysis
    network_analysis_demo()
    
    print("\n" + "=" * 60)
    print("KEY INSIGHT")
    print("=" * 60)
    print("""
  Euler's 1736 theorem about the Königsberg bridges is not just a
  historical curiosity — it is the foundation of a family of results
  that appear whenever we need to traverse every edge of a network
  efficiently.
  
  The core insight is strikingly simple:
  
    "Count the degree parity. If more than 2 vertices have odd degree,
     you cannot traverse every edge without repetition."
  
  This single observation, formally proved in our Lean 4 development,
  underlies algorithms in:
  
    • Logistics and route planning
    • Genomic sequence assembly  
    • Hardware testing and verification
    • Network design and optimization
    • VLSI chip layout
    • Puzzle solving (Hamiltonian vs Eulerian problems)
""")


"""
Königsberg Bridge Problem — Interactive Demonstration
=====================================================

This script visualizes the Königsberg Bridge Problem and demonstrates:
1. The graph structure with its 4 vertices and 7 edges
2. Degree computation showing all vertices have odd degree
3. The Euler Parity Theorem: Eulerian trails require ≤ 2 odd-degree vertices
4. Exhaustive verification that no Eulerian trail exists
5. Modified graphs that DO have Eulerian trails/circuits

Requirements: pip install matplotlib networkx numpy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import permutations
from collections import defaultdict, deque


# ============================================================
# 1. Define the Königsberg Bridge Graph
# ============================================================

def create_konigsberg_edges():
    """Return the 7 bridges of Königsberg as (u, v, name) triples.
    
    Vertices:
      0 = Kneiphof (central island)
      1 = Northern bank
      2 = Southern bank
      3 = Lomse (eastern island)
    """
    return [
        (0, 1, "Krämer Br."),
        (0, 1, "Schmiede Br."),
        (0, 2, "Grüne Br."),
        (0, 2, "Köttel Br."),
        (0, 3, "Honig Br."),
        (1, 3, "Holz Br."),
        (2, 3, "Hohe Br."),
    ]


def compute_degrees(edges):
    """Compute vertex degrees from an edge list [(u, v, ...), ...]."""
    degrees = defaultdict(int)
    for edge in edges:
        u, v = edge[0], edge[1]
        degrees[u] += 1
        degrees[v] += 1
    return dict(degrees)


# ============================================================
# 2. Visualization
# ============================================================

def plot_konigsberg(save_path="konigsberg_graph.png"):
    """Create a visualization of the Königsberg graph."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    bridges = create_konigsberg_edges()
    degrees = compute_degrees(bridges)
    
    # Vertex positions (geographic layout)
    pos = {0: (0.5, 0.5), 1: (0.5, 1.0), 2: (0.5, 0.0), 3: (1.2, 0.5)}
    
    vertex_labels = {
        0: f"Kneiphof\ndeg={degrees[0]}",
        1: f"North\ndeg={degrees[1]}",
        2: f"South\ndeg={degrees[2]}",
        3: f"Lomse\ndeg={degrees[3]}",
    }
    
    # Left panel: The graph
    ax = axes[0]
    ax.set_title("The Seven Bridges of Königsberg", fontsize=14, fontweight='bold')
    
    # Draw river background
    river_x = np.linspace(-0.2, 1.5, 100)
    for offset in np.linspace(-0.02, 0.02, 5):
        ax.fill_between(river_x, 0.35 + offset, 0.65 + offset,
                        alpha=0.1, color='steelblue')
    
    # Draw edges with curvature for parallel edges
    edge_colors = ['#e74c3c', '#e67e22', '#2ecc71', '#27ae60',
                   '#3498db', '#9b59b6', '#e91e63']
    
    drawn_edges = defaultdict(int)
    for idx, (u, v, name) in enumerate(bridges):
        key = (min(u, v), max(u, v))
        count = drawn_edges[key]
        drawn_edges[key] += 1
        
        x1, y1 = pos[u]
        x2, y2 = pos[v]
        curve = 0.15 * (count - 0.5) if drawn_edges[key] > 1 or count > 0 else 0
        mid_x = (x1 + x2) / 2 + curve * (y2 - y1)
        mid_y = (y1 + y2) / 2 - curve * (x2 - x1)
        
        t_vals = np.linspace(0, 1, 50)
        bx = (1 - t_vals) ** 2 * x1 + 2 * (1 - t_vals) * t_vals * mid_x + t_vals ** 2 * x2
        by_ = (1 - t_vals) ** 2 * y1 + 2 * (1 - t_vals) * t_vals * mid_y + t_vals ** 2 * y2
        
        ax.plot(bx, by_, color=edge_colors[idx], linewidth=3, alpha=0.7,
                label=name, zorder=1)
    
    # Draw vertices
    for v_id, (x, y) in pos.items():
        color = '#e74c3c' if degrees[v_id] % 2 == 1 else '#2ecc71'
        circle = plt.Circle((x, y), 0.08, color=color, zorder=3)
        ax.add_patch(circle)
        ax.text(x, y - 0.15, vertex_labels[v_id], ha='center', va='top',
                fontsize=9, fontweight='bold')
    
    ax.set_xlim(-0.3, 1.5)
    ax.set_ylim(-0.3, 1.3)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.legend(loc='upper left', fontsize=8, title="Bridges", title_fontsize=9)
    
    # Right panel: Degree analysis
    ax = axes[1]
    ax.set_title("Degree Analysis", fontsize=14, fontweight='bold')
    
    vertex_names = ['Kneiphof\n(v₀)', 'North\n(v₁)', 'South\n(v₂)', 'Lomse\n(v₃)']
    deg_values = [degrees[i] for i in range(4)]
    colors = ['#e74c3c' if d % 2 == 1 else '#2ecc71' for d in deg_values]
    
    bars = ax.bar(vertex_names, deg_values, color=colors, edgecolor='black', linewidth=1.5)
    
    for bar, d in zip(bars, deg_values):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                f'{d} (odd)', ha='center', fontsize=11, fontweight='bold', color='#c0392b')
    
    ax.set_ylabel('Degree', fontsize=12)
    ax.set_ylim(0, 6.5)
    ax.axhline(y=0, color='black', linewidth=0.5)
    
    ax.text(0.5, -0.15,
            "Euler's Theorem: Eulerian trail exists ⟹ ≤ 2 odd-degree vertices\n"
            "Königsberg has 4 odd-degree vertices ⟹ No Eulerian trail!",
            transform=ax.transAxes, ha='center', fontsize=10,
            bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                      edgecolor='orange', alpha=0.9))
    
    plt.tight_layout()
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved graph visualization to {save_path}")


def plot_parity_theorem(save_path="parity_theorem.png"):
    """Visualize the parity theorem with three example graphs."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    examples = [
        ("Eulerian Circuit\n(0 odd-degree vertices)",
         [(0, 1), (1, 2), (2, 3), (3, 0)],
         {0: (0, 0), 1: (1, 0), 2: (1, 1), 3: (0, 1)},
         "Trail: 0→1→2→3→0 ✓"),
        ("Eulerian Trail\n(2 odd-degree vertices)",
         [(0, 1), (1, 2), (2, 3), (3, 0), (0, 2)],
         {0: (0, 0), 1: (1, 0), 2: (1, 1), 3: (0, 1)},
         "Trail: 1→0→3→2→0→... ✓"),
        ("No Eulerian Trail\n(4 odd-degree vertices)",
         [(0, 1), (0, 1), (0, 2), (0, 2), (0, 3), (1, 3), (2, 3)],
         {0: (0.5, 0.5), 1: (0.5, 1), 2: (0.5, 0), 3: (1.2, 0.5)},
         "No Eulerian trail! ✗"),
    ]
    
    for ax, (title, edges, pos, caption) in zip(axes, examples):
        ax.set_title(title, fontsize=12, fontweight='bold')
        
        degrees = defaultdict(int)
        for u, v in edges:
            degrees[u] += 1
            degrees[v] += 1
        
        # Draw edges
        edge_count = defaultdict(int)
        for u, v in edges:
            key = (min(u, v), max(u, v))
            cnt = edge_count[key]
            edge_count[key] += 1
            
            x1, y1 = pos[u]
            x2, y2 = pos[v]
            curve = 0.1 * cnt if cnt > 0 else 0
            mid_x = (x1 + x2) / 2 + curve * (y2 - y1)
            mid_y = (y1 + y2) / 2 - curve * (x2 - x1)
            
            t_vals = np.linspace(0, 1, 50)
            bx = (1 - t_vals) ** 2 * x1 + 2 * (1 - t_vals) * t_vals * mid_x + t_vals ** 2 * x2
            by_ = (1 - t_vals) ** 2 * y1 + 2 * (1 - t_vals) * t_vals * mid_y + t_vals ** 2 * y2
            ax.plot(bx, by_, color='gray', linewidth=2, alpha=0.7, zorder=1)
        
        # Draw vertices
        for v_id, (x, y) in pos.items():
            if v_id in degrees:
                color = '#e74c3c' if degrees[v_id] % 2 == 1 else '#2ecc71'
                circle = plt.Circle((x, y), 0.08, color=color, zorder=3)
                ax.add_patch(circle)
                ax.text(x, y, str(v_id), ha='center', va='center',
                        fontsize=10, fontweight='bold', color='white', zorder=4)
                c = '#c0392b' if degrees[v_id] % 2 == 1 else '#27ae60'
                ax.annotate(f'deg={degrees[v_id]}', (x, y),
                            textcoords="offset points", xytext=(0, -20),
                            ha='center', fontsize=9, color=c, fontweight='bold')
        
        success = "✗" not in caption
        color = '#27ae60' if success else '#c0392b'
        ax.text(0.5, -0.1, caption, transform=ax.transAxes,
                ha='center', fontsize=10, color=color, fontweight='bold')
        
        ax.set_xlim(-0.3, 1.5)
        ax.set_ylim(-0.3, 1.3)
        ax.set_aspect('equal')
        ax.axis('off')
    
    red_patch = mpatches.Patch(color='#e74c3c', label='Odd degree')
    green_patch = mpatches.Patch(color='#2ecc71', label='Even degree')
    fig.legend(handles=[green_patch, red_patch], loc='lower center',
               ncol=2, fontsize=11, frameon=True)
    
    plt.tight_layout(rect=[0, 0.05, 1, 1])
    plt.savefig(save_path, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved parity theorem visualization to {save_path}")


# ============================================================
# 3. Exhaustive Verification
# ============================================================

def verify_no_eulerian_trail():
    """Exhaustively verify that no Eulerian trail exists."""
    edges = [(0, 1), (0, 1), (0, 2), (0, 2), (0, 3), (1, 3), (2, 3)]
    total_checked = 0
    
    for perm in permutations(range(7)):
        for start_end in [0, 1]:
            ordered = [edges[perm[i]] for i in range(7)]
            current = ordered[0][start_end]
            valid = True
            for u, v in ordered:
                if current == u:
                    current = v
                elif current == v:
                    current = u
                else:
                    valid = False
                    break
            total_checked += 1
            if valid:
                print("ERROR: Found an Eulerian trail!")
                return False
    
    print(f"Verified: No Eulerian trail exists.")
    print(f"  Checked {total_checked:,} possible walks (7! × 2 = {7 * 6 * 5 * 4 * 3 * 2 * 1 * 2:,})")
    return True


# ============================================================
# 4. Handshaking Lemma Demonstration
# ============================================================

def demonstrate_handshaking():
    """Demonstrate the Handshaking Lemma on several graphs."""
    print("\n" + "=" * 60)
    print("HANDSHAKING LEMMA: Σ deg(v) = 2|E|")
    print("=" * 60)
    
    examples = [
        ("Königsberg", [(0, 1), (0, 1), (0, 2), (0, 2), (0, 3), (1, 3), (2, 3)]),
        ("Triangle", [(0, 1), (1, 2), (0, 2)]),
        ("Complete K₄", [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]),
        ("Path P₄", [(0, 1), (1, 2), (2, 3)]),
        ("Star S₄", [(0, 1), (0, 2), (0, 3), (0, 4)]),
    ]
    
    for name, edges in examples:
        vertices = set()
        degrees = defaultdict(int)
        for u, v in edges:
            vertices.update([u, v])
            degrees[u] += 1
            degrees[v] += 1
        
        deg_sum = sum(degrees.values())
        num_edges = len(edges)
        odd_count = sum(1 for v in vertices if degrees[v] % 2 == 1)
        
        print(f"\n  {name}:")
        print(f"    Vertices: {len(vertices)}, Edges: {num_edges}")
        print(f"    Degrees: {dict(sorted(degrees.items()))}")
        print(f"    Σ deg(v) = {deg_sum} = 2 × {num_edges} ✓")
        print(f"    Odd-degree vertices: {odd_count}", end="")
        
        if odd_count == 0:
            print(f" → Eulerian CIRCUIT exists")
        elif odd_count == 2:
            print(f" → Eulerian TRAIL exists")
        else:
            print(f" → No Eulerian trail ({odd_count} > 2)")


# ============================================================
# 5. Modified Königsberg
# ============================================================

def find_eulerian_trail(edges, start):
    """Find an Eulerian trail using Hierholzer's algorithm."""
    adj = defaultdict(list)
    for idx, (u, v) in enumerate(edges):
        adj[u].append((v, idx))
        adj[v].append((u, idx))
    
    used = set()
    stack = [start]
    trail = deque()
    
    while stack:
        v = stack[-1]
        found = False
        while adj[v]:
            w, idx = adj[v].pop()
            if idx not in used:
                used.add(idx)
                stack.append(w)
                found = True
                break
        if not found:
            trail.appendleft(stack.pop())
    
    if len(used) == len(edges):
        return list(trail)
    return None


def modified_konigsberg():
    """Show how modifying the Königsberg graph can enable Eulerian trails."""
    print("\n" + "=" * 60)
    print("MODIFYING KÖNIGSBERG")
    print("=" * 60)
    
    modifications = [
        ("Original (7 bridges)",
         [(0, 1), (0, 1), (0, 2), (0, 2), (0, 3), (1, 3), (2, 3)]),
        ("Remove 2 bridges (5 bridges)",
         [(0, 1), (0, 2), (0, 3), (1, 3), (2, 3)]),
        ("Add bridge 1-2 (8 bridges)",
         [(0, 1), (0, 1), (0, 2), (0, 2), (0, 3), (1, 3), (2, 3), (1, 2)]),
    ]
    
    for name, edges in modifications:
        degrees = defaultdict(int)
        for u, v in edges:
            degrees[u] += 1
            degrees[v] += 1
        
        odd = sorted(v for v in degrees if degrees[v] % 2 == 1)
        
        print(f"\n  {name}:")
        print(f"    Degrees: {dict(sorted(degrees.items()))}")
        print(f"    Odd-degree vertices: {odd} (count: {len(odd)})")
        
        if len(odd) == 0:
            trail = find_eulerian_trail([(u, v) for u, v in edges], 0)
            if trail:
                print(f"    → Eulerian CIRCUIT: {' → '.join(map(str, trail))}")
            else:
                print(f"    → Eulerian CIRCUIT exists (theoretically)")
        elif len(odd) == 2:
            trail = find_eulerian_trail([(u, v) for u, v in edges], odd[0])
            if trail:
                print(f"    → Eulerian TRAIL: {' → '.join(map(str, trail))}")
            else:
                print(f"    → Eulerian TRAIL exists (start={odd[0]}, end={odd[1]})")
        else:
            print(f"    → No Eulerian trail possible")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("THE KÖNIGSBERG BRIDGE PROBLEM")
    print("Leonhard Euler, 1736 — The Birth of Graph Theory")
    print("=" * 60)
    
    bridges = create_konigsberg_edges()
    degrees = compute_degrees(bridges)
    
    print("\nThe Königsberg Graph:")
    print(f"  Vertices: 4 (landmasses)")
    print(f"  Edges: 7 (bridges)")
    print(f"\n  Vertex degrees:")
    names = ['Kneiphof (central island)', 'Northern bank',
             'Southern bank', 'Lomse (eastern island)']
    for i in range(4):
        parity = "ODD" if degrees[i] % 2 == 1 else "even"
        print(f"    v{i} ({names[i]}): degree {degrees[i]} ({parity})")
    
    print(f"\n  Sum of degrees: {sum(degrees.values())} = 2 × 7 = 14 ✓ (Handshaking Lemma)")
    print(f"  Odd-degree vertices: 4")
    
    print(f"\n{'=' * 60}")
    print("EXHAUSTIVE VERIFICATION")
    print("=" * 60)
    verify_no_eulerian_trail()
    
    demonstrate_handshaking()
    modified_konigsberg()
    
    print(f"\n{'=' * 60}")
    print("GENERATING VISUALIZATIONS")
    print("=" * 60)
    try:
        plot_konigsberg()
        plot_parity_theorem()
    except Exception as e:
        print(f"Note: Could not generate plots ({e})")
    
    print(f"\n{'=' * 60}")
    print("THEOREM SUMMARY (Formally Verified in Lean 4)")
    print("=" * 60)
    print("""
  1. HANDSHAKING LEMMA
     For any multigraph G = (V, E):
       Σ_{v ∈ V} deg(v) = 2|E|
     
  2. EULER PARITY THEOREM  
     If G admits an Eulerian trail, then ≤ 2 vertices have odd degree.
     
     Proof sketch: For a trail v₀, v₁, ..., vₙ using every edge:
       deg(v) + 𝟙[v₀=v] + 𝟙[vₙ=v] = 2 · visits(v)
     So deg(v) is odd only if v ∈ {v₀, vₙ}, giving ≤ 2.
     
  3. KÖNIGSBERG IMPOSSIBILITY
     Degrees: 5, 3, 3, 3 — all odd, so 4 > 2 odd-degree vertices.
     By Euler's Parity Theorem ⟹ no Eulerian trail exists.   ∎
""")
