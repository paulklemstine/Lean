#!/usr/bin/env python3
"""
Berggren Lattice Reduction Duality: Demonstrations and Visualizations

Demonstrates the core theorems connecting Pythagorean triples, Berggren tree dynamics,
and lattice Gram matrices. Generates visualizations of trace/det monotonicity,
Gram matrix evolution, and lattice basis geometry.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List, Dict
import json
import base64
from io import BytesIO

# ============================================================================
# Core Definitions
# ============================================================================

def berggren_A(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren generator A."""
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren generator B."""
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(a: int, b: int, c: int) -> Tuple[int, int, int]:
    """Berggren generator C."""
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': berggren_A, 'B': berggren_B, 'C': berggren_C}

def gram_matrix(a: int, b: int, c: int) -> np.ndarray:
    """Gram matrix G(a,b,c) = [[a²+b², ab+bc], [ab+bc, b²+c²]]."""
    return np.array([
        [a**2 + b**2, a*b + b*c],
        [a*b + b*c, b**2 + c**2]
    ], dtype=np.int64)

def gram_trace(a: int, b: int, c: int) -> int:
    """Trace of the Gram matrix: a² + 2b² + c²."""
    return a**2 + 2*b**2 + c**2

def gram_det(a: int, b: int, c: int) -> int:
    """Determinant of the Gram matrix."""
    return (a**2 + b**2) * (b**2 + c**2) - (a*b + b*c)**2

def gram_det_formula(a: int, b: int, c: int) -> int:
    """Gram det = (ac - b²)² for Pythagorean triples."""
    return (a*c - b**2)**2

def short_norm_sq(a: int, b: int, c: int) -> int:
    """Minimum basis vector squared norm = c² for Pythagorean triples."""
    return min(a**2 + b**2, b**2 + c**2)

def is_pythagorean(a: int, b: int, c: int) -> bool:
    return a**2 + b**2 == c**2

# ============================================================================
# Berggren Tree Exploration
# ============================================================================

def generate_berggren_tree(root: Tuple[int,int,int], depth: int) -> Dict:
    """Generate the Berggren tree to a given depth."""
    a, b, c = root
    node = {
        'triple': (a, b, c),
        'trace': gram_trace(a, b, c),
        'det': gram_det(a, b, c),
        'det_formula': gram_det_formula(a, b, c),
        'short_norm': short_norm_sq(a, b, c),
        'children': {}
    }
    if depth > 0:
        for name, gen in GENERATORS.items():
            child = gen(a, b, c)
            node['children'][name] = generate_berggren_tree(child, depth - 1)
    return node

def collect_paths(tree: Dict, path: str = "") -> List[Dict]:
    """Collect all paths with their invariants."""
    result = [{
        'path': path if path else 'root',
        'triple': tree['triple'],
        'trace': tree['trace'],
        'det': tree['det'],
        'short_norm': tree['short_norm']
    }]
    for name, child in tree['children'].items():
        result.extend(collect_paths(child, path + name))
    return result

# ============================================================================
# Demonstrations
# ============================================================================

def demo_basic():
    """Demonstrate basic Gram matrix properties."""
    print("=" * 70)
    print("DEMO 1: Gram Matrix Properties at Root (3, 4, 5)")
    print("=" * 70)
    
    a, b, c = 3, 4, 5
    G = gram_matrix(a, b, c)
    print(f"\nTriple: ({a}, {b}, {c})")
    print(f"Pythagorean check: {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2} ✓")
    print(f"\nGram matrix G({a},{b},{c}):")
    print(f"  [[{G[0,0]:4d}, {G[0,1]:4d}],")
    print(f"   [{G[1,0]:4d}, {G[1,1]:4d}]]")
    print(f"\nTrace = a² + 2b² + c² = {a**2} + {2*b**2} + {c**2} = {gram_trace(a,b,c)}")
    print(f"Det = (ac - b²)² = ({a*c} - {b**2})² = ({a*c - b**2})² = {gram_det_formula(a,b,c)}")
    print(f"Det (direct) = {gram_det(a,b,c)}")
    print(f"Short norm (min basis vector²) = min({a**2+b**2}, {b**2+c**2}) = {short_norm_sq(a,b,c)} = c²")
    
    print("\n" + "=" * 70)
    print("DEMO 2: Children of (3, 4, 5)")
    print("=" * 70)
    
    for name, gen in GENERATORS.items():
        child = gen(a, b, c)
        ca, cb, cc = child
        G_child = gram_matrix(ca, cb, cc)
        print(f"\nGenerator {name}: ({a},{b},{c}) → ({ca},{cb},{cc})")
        print(f"  Pythagorean: {ca}² + {cb}² = {ca**2+cb**2} = {cc}² = {cc**2} {'✓' if is_pythagorean(ca,cb,cc) else '✗'}")
        print(f"  Trace: {gram_trace(a,b,c)} → {gram_trace(ca,cb,cc)} (increase: {gram_trace(ca,cb,cc) - gram_trace(a,b,c)})")
        print(f"  Det:   {gram_det(a,b,c)} → {gram_det(ca,cb,cc)} = ({ca*cc-cb**2})²")
        print(f"  Short norm: {short_norm_sq(a,b,c)} → {short_norm_sq(ca,cb,cc)}")

def demo_monotonicity():
    """Demonstrate trace and det monotonicity along branches."""
    print("\n" + "=" * 70)
    print("DEMO 3: Monotonicity Along Berggren Branches")
    print("=" * 70)
    
    for path_label, gens in [("AAA", [berggren_A]*3), ("BBB", [berggren_B]*3), 
                              ("CCC", [berggren_C]*3), ("ABC", [berggren_A, berggren_B, berggren_C])]:
        print(f"\nPath {path_label}:")
        a, b, c = 3, 4, 5
        traces = [gram_trace(a, b, c)]
        dets = [gram_det(a, b, c)]
        norms = [short_norm_sq(a, b, c)]
        print(f"  ({a:5d}, {b:5d}, {c:5d}) | trace={traces[-1]:10d} | det={dets[-1]:10d} | norm={norms[-1]:6d}")
        for gen in gens:
            a, b, c = gen(a, b, c)
            traces.append(gram_trace(a, b, c))
            dets.append(gram_det(a, b, c))
            norms.append(short_norm_sq(a, b, c))
            print(f"  ({a:5d}, {b:5d}, {c:5d}) | trace={traces[-1]:10d} | det={dets[-1]:10d} | norm={norms[-1]:6d}")
        
        trace_mono = all(traces[i] < traces[i+1] for i in range(len(traces)-1))
        norm_mono = all(norms[i] <= norms[i+1] for i in range(len(norms)-1))
        print(f"  Trace strictly increasing: {trace_mono}")
        print(f"  Norm nondecreasing: {norm_mono}")

def demo_gram_recognition():
    """Demonstrate the Gram recognition theorem."""
    print("\n" + "=" * 70)
    print("DEMO 4: Gram Matrix as Complete Invariant")
    print("=" * 70)
    
    # Generate several triples and show Gram determines them uniquely
    tree = generate_berggren_tree((3, 4, 5), 3)
    paths = collect_paths(tree)
    
    print(f"\nGenerated {len(paths)} triples from depth-3 Berggren tree.")
    print("\nVerifying Gram matrix uniquely determines each triple:")
    
    gram_to_triple = {}
    all_unique = True
    for p in paths:
        a, b, c = p['triple']
        G = gram_matrix(a, b, c)
        key = (G[0,0], G[0,1], G[1,1])  # Gram is symmetric, 3 entries suffice
        if key in gram_to_triple:
            print(f"  COLLISION: {p['triple']} and {gram_to_triple[key]} have same Gram!")
            all_unique = False
        gram_to_triple[key] = p['triple']
    
    if all_unique:
        print(f"  All {len(paths)} triples have distinct Gram matrices. ✓")
        print(f"  Gram matrix is a complete invariant for positive Pythagorean triples.")

def demo_det_formula():
    """Demonstrate the det = (ac-b²)² formula."""
    print("\n" + "=" * 70)
    print("DEMO 5: Gram Determinant = (ac - b²)² (Perfect Square Identity)")
    print("=" * 70)
    
    tree = generate_berggren_tree((3, 4, 5), 3)
    paths = collect_paths(tree)
    
    print(f"\nVerifying det(G(a,b,c)) = (ac - b²)² for all {len(paths)} triples:")
    all_match = True
    for p in paths:
        a, b, c = p['triple']
        d = gram_det(a, b, c)
        f = gram_det_formula(a, b, c)
        if d != f:
            print(f"  MISMATCH at ({a},{b},{c}): det={d}, formula={f}")
            all_match = False
    
    if all_match:
        print(f"  All {len(paths)} triples satisfy det = (ac-b²)². ✓")
    
    print("\n  Sample values:")
    for p in paths[:10]:
        a, b, c = p['triple']
        print(f"    ({a:5d},{b:5d},{c:5d}): ac-b² = {a*c-b**2:8d}, det = {gram_det(a,b,c):12d}")

# ============================================================================
# Visualizations
# ============================================================================

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode()

def viz_trace_monotonicity():
    """Visualize trace monotonicity along different branches."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    paths_data = {
        'Branch A (repeated)': [berggren_A]*6,
        'Branch B (repeated)': [berggren_B]*6,
        'Branch C (repeated)': [berggren_C]*6,
    }
    
    for ax, (label, gens) in zip(axes, paths_data.items()):
        a, b, c = 3, 4, 5
        traces = [gram_trace(a, b, c)]
        for gen in gens:
            a, b, c = gen(a, b, c)
            traces.append(gram_trace(a, b, c))
        
        ax.semilogy(range(len(traces)), traces, 'o-', linewidth=2, markersize=8, color='#2196F3')
        ax.set_title(label, fontsize=12, fontweight='bold')
        ax.set_xlabel('Depth', fontsize=11)
        ax.set_ylabel('Gram Trace (log scale)', fontsize=11)
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Gram Trace Monotonicity Along Berggren Branches', 
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig

def viz_det_evolution():
    """Visualize determinant evolution along branches."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    colors = {'A': '#F44336', 'B': '#4CAF50', 'C': '#2196F3'}
    
    for name, gen in [('A', berggren_A), ('B', berggren_B), ('C', berggren_C)]:
        a, b, c = 3, 4, 5
        dets = [gram_det(a, b, c)]
        ac_b2 = [a*c - b**2]
        for _ in range(6):
            a, b, c = gen(a, b, c)
            dets.append(gram_det(a, b, c))
            ac_b2.append(a*c - b**2)
        
        ax.semilogy(range(len(dets)), dets, 'o-', linewidth=2, markersize=8, 
                    color=colors[name], label=f'Branch {name}: det = (ac-b²)²')
    
    ax.set_xlabel('Depth', fontsize=12)
    ax.set_ylabel('Gram Determinant (log scale)', fontsize=12)
    ax.set_title('Gram Determinant Growth Along Berggren Branches', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    return fig

def viz_lattice_bases():
    """Visualize the lattice bases for first few triples."""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    
    triples = [
        ((3, 4, 5), "Root: (3,4,5)"),
        ((5, 12, 13), "A-child: (5,12,13)"),
        ((21, 20, 29), "B-child: (21,20,29)"),
        ((15, 8, 17), "C-child: (15,8,17)"),
        ((7, 24, 25), "AA-child: (7,24,25)"),
        ((55, 48, 73), "AB-child: (55,48,73)"),
    ]
    
    for ax, ((a, b, c), title) in zip(axes.flat, triples):
        v1 = np.array([a, b])
        v2 = np.array([b, c])
        
        # Draw lattice points
        for i in range(-3, 4):
            for j in range(-3, 4):
                pt = i * v1 + j * v2
                ax.plot(pt[0], pt[1], 'k.', markersize=3, alpha=0.3)
        
        # Draw basis vectors
        ax.annotate('', xy=v1, xytext=(0,0),
                    arrowprops=dict(arrowstyle='->', color='#F44336', lw=2))
        ax.annotate('', xy=v2, xytext=(0,0),
                    arrowprops=dict(arrowstyle='->', color='#2196F3', lw=2))
        
        ax.plot(0, 0, 'ko', markersize=5)
        ax.set_title(f'{title}\ntr={gram_trace(a,b,c)}, det={gram_det(a,b,c)}', fontsize=10)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)
        ax.set_xlim(-max(abs(v1[0]), abs(v2[0]))*2, max(abs(v1[0]), abs(v2[0]))*3)
        ax.set_ylim(-max(abs(v1[1]), abs(v2[1]))*1, max(abs(v1[1]), abs(v2[1]))*3)
    
    fig.suptitle('Lattice Bases from Berggren Triples\n(red: v₁=(a,b), blue: v₂=(b,c))', 
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    return fig

def viz_component_growth():
    """Visualize component growth along branches."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for ax, (name, gen) in zip(axes, [('A', berggren_A), ('B', berggren_B), ('C', berggren_C)]):
        a, b, c = 3, 4, 5
        aa, bb, cc = [a], [b], [c]
        for _ in range(8):
            a, b, c = gen(a, b, c)
            aa.append(a); bb.append(b); cc.append(c)
        
        ax.semilogy(range(len(aa)), aa, 'o-', label='a', color='#F44336', markersize=6)
        ax.semilogy(range(len(bb)), bb, 's-', label='b', color='#4CAF50', markersize=6)
        ax.semilogy(range(len(cc)), cc, '^-', label='c', color='#2196F3', markersize=6)
        ax.set_title(f'Branch {name}', fontsize=12, fontweight='bold')
        ax.set_xlabel('Depth')
        ax.set_ylabel('Component value (log)')
        ax.legend()
        ax.grid(True, alpha=0.3)
    
    fig.suptitle('Component Growth Along Berggren Branches', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    # Run demos
    demo_basic()
    demo_monotonicity()
    demo_gram_recognition()
    demo_det_formula()
    
    # Generate visualizations
    print("\n" + "=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    
    fig1 = viz_trace_monotonicity()
    fig1.savefig('viz_trace_monotonicity.png', dpi=150, bbox_inches='tight')
    print("  Saved: viz_trace_monotonicity.png")
    
    fig2 = viz_det_evolution()
    fig2.savefig('viz_det_evolution.png', dpi=150, bbox_inches='tight')
    print("  Saved: viz_det_evolution.png")
    
    fig3 = viz_lattice_bases()
    fig3.savefig('viz_lattice_bases.png', dpi=150, bbox_inches='tight')
    print("  Saved: viz_lattice_bases.png")
    
    fig4 = viz_component_growth()
    fig4.savefig('viz_component_growth.png', dpi=150, bbox_inches='tight')
    print("  Saved: viz_component_growth.png")
    
    print("\nAll demos and visualizations complete.")
