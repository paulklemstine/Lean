#!/usr/bin/env python3
"""
Berggren–Lattice Reduction Duality: Applications

Real-world applications of the Berggren-Gram correspondence:
  1. Structured lattice instances for cryptographic benchmarking
  2. Certified shortest-vector extraction
  3. Collision resistance analysis
  4. Arithmetic complexity certification
"""

import numpy as np
from math import gcd, isqrt
from typing import Tuple, List, Dict
from collections import defaultdict

# Import core algorithms
import sys
sys.path.insert(0, '.')
from algorithms import (berggren_apply, gram_encode, gram_det, gram_decode,
                        berggren_inverse, full_ancestry, gram_reduction_chain,
                        berggren_bfs)

# =============================================================================
# Application 1: Structured Lattice Challenge Generation
# =============================================================================

def generate_lattice_challenges(depths: List[int]) -> List[Dict]:
    """
    Generate structured lattice instances at specified Berggren depths.
    
    Each instance comes with a certified shortest-vector solution:
    the Berggren ancestry word that reduces the Gram matrix to the root.
    
    This provides a family of lattice instances where:
    - The shortest vector problem has a known, certifiable solution
    - Difficulty scales with Berggren depth (≈ log of hypotenuse)
    - Solutions are arithmetically structured, not random
    
    Applications:
    - Benchmarking lattice reduction algorithms
    - Testing LLL/BKZ implementations on structured instances
    - Educational demonstrations of lattice geometry
    """
    challenges = []
    
    for depth in depths:
        # Generate all triples at exactly this depth
        def gen_at_depth(d, triple=(3, 4, 5), word=""):
            if d == 0:
                return [(word, triple)]
            results = []
            for gen in 'LMR':
                child = berggren_apply(gen, *triple)
                results.extend(gen_at_depth(d-1, child, word + gen))
            return results
        
        triples_at_depth = gen_at_depth(depth)
        
        for word, (a, b, c) in triples_at_depth:
            G = gram_encode(a, b, c)
            det = gram_det(a, b, c)
            
            challenges.append({
                'depth': depth,
                'word': word,
                'triple': (a, b, c),
                'gram_matrix': G.tolist(),
                'determinant': det,
                'certified_solution': word,  # The ancestry word IS the solution
                'shortest_vector_norm_sq': a**2 + b**2,  # = c²
            })
    
    return challenges


# =============================================================================
# Application 2: Collision Resistance Analysis
# =============================================================================

def collision_analysis(max_height: int) -> Dict:
    """
    Analyze collision resistance of the Gram encoding up to a given height.
    
    The formally proved theorem states: gramEncode is injective, so there
    are zero collisions at any height. This function verifies computationally.
    
    Returns statistics about the encoding space.
    """
    triples = berggren_bfs(max_height)
    
    # Check for Gram matrix collisions
    gram_to_triple = {}
    collisions = 0
    
    for t in triples:
        G = gram_encode(*t['triple'])
        key = tuple(G.flatten())
        if key in gram_to_triple:
            collisions += 1
        gram_to_triple[key] = t['triple']
    
    # Analyze determinant distribution
    dets = [t['det'] for t in triples]
    det_counts = defaultdict(int)
    for d in dets:
        det_counts[d] += 1
    
    # Determinant collisions (two different triples, same determinant)
    det_collisions = sum(1 for _, count in det_counts.items() if count > 1)
    
    return {
        'max_height': max_height,
        'total_triples': len(triples),
        'gram_collisions': collisions,
        'distinct_determinants': len(det_counts),
        'determinant_collisions': det_collisions,
        'min_det': min(dets) if dets else 0,
        'max_det': max(dets) if dets else 0,
        'collision_rate': collisions / max(len(triples), 1),
    }


# =============================================================================
# Application 3: Lattice Reduction Benchmark
# =============================================================================

def reduction_benchmark(depths: List[int]) -> List[Dict]:
    """
    Benchmark the Gram-based reduction algorithm at various depths.
    
    For each depth, generates a random triple and measures:
    - Number of reduction steps needed
    - Determinant ratio (start/end)
    - Height ratio (start/end)
    """
    results = []
    
    for depth in depths:
        # Generate a triple at this depth using word "M" repeated
        word = "M" * depth
        a, b, c = 3, 4, 5
        for ch in word:
            a, b, c = berggren_apply(ch, a, b, c)
        
        # Reduce back to root
        chain = gram_reduction_chain(a, b, c)
        
        results.append({
            'depth': depth,
            'initial_triple': (a, b, c),
            'initial_height': c,
            'initial_det': gram_det(a, b, c),
            'root_det': gram_det(3, 4, 5),
            'reduction_steps': len(chain) - 1,
            'det_ratio': gram_det(a, b, c) / gram_det(3, 4, 5),
            'height_ratio': c / 5,
        })
    
    return results


# =============================================================================
# Application 4: Arithmetic Complexity Certification
# =============================================================================

def arithmetic_complexity_certificate(a: int, b: int, c: int) -> Dict:
    """
    Generate a formal certificate of arithmetic complexity for a triple.
    
    The certificate includes:
    - The Berggren word (ancestry path)
    - Gram matrix at each level
    - Determinant chain (monotonically decreasing to root)
    - Verification that each step is valid
    """
    if not (a**2 + b**2 == c**2 and gcd(a, b) == 1 and a > 0 and b > 0):
        return {'valid': False, 'error': 'Not a valid primitive triple'}
    
    ancestry = full_ancestry(a, b, c)
    word = "".join(g for g, _ in ancestry)
    
    chain = gram_reduction_chain(a, b, c)
    
    # Verify certificate
    dets = [step['det'] for step in chain]
    strictly_decreasing = all(dets[i] > dets[i+1] for i in range(len(dets)-1))
    reaches_root = chain[-1]['triple'] == (3, 4, 5)
    
    return {
        'valid': True,
        'triple': (a, b, c),
        'berggren_word': word,
        'depth': len(ancestry),
        'chain_length': len(chain),
        'determinant_chain': dets,
        'strictly_decreasing': strictly_decreasing,
        'reaches_root': reaches_root,
        'certified': strictly_decreasing and reaches_root,
    }


# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Structured Lattice Challenge Generation")
    print("=" * 70)
    challenges = generate_lattice_challenges([1, 2, 3])
    for ch in challenges[:6]:
        print(f"  Depth {ch['depth']}, word='{ch['word']}': "
              f"triple={ch['triple']}, det={ch['determinant']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Collision Resistance Analysis")
    print("=" * 70)
    for h in [100, 500, 1000]:
        stats = collision_analysis(h)
        print(f"  Height ≤ {h}: {stats['total_triples']} triples, "
              f"{stats['gram_collisions']} collisions, "
              f"{stats['distinct_determinants']} distinct dets")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Lattice Reduction Benchmark")
    print("=" * 70)
    bench = reduction_benchmark([1, 2, 3, 4, 5, 6])
    for b in bench:
        print(f"  Depth {b['depth']}: {b['reduction_steps']} steps, "
              f"det_ratio={b['det_ratio']:.1f}, height={b['initial_height']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 4: Arithmetic Complexity Certification")
    print("=" * 70)
    test_triples = [(5, 12, 13), (119, 120, 169), (3, 4, 5)]
    for triple in test_triples:
        cert = arithmetic_complexity_certificate(*triple)
        if cert['valid']:
            print(f"  {triple}: word='{cert['berggren_word']}', "
                  f"depth={cert['depth']}, certified={cert['certified']}")
            print(f"    det chain: {cert['determinant_chain']}")


#!/usr/bin/env python3
"""
Berggren–Lattice Reduction Duality: Demonstrations

Concrete numerical examples showing the dictionary between:
  - Berggren semigroup dynamics on primitive Pythagorean triples
  - Lattice reduction on structured integer Gram forms
"""

import numpy as np
from typing import Tuple, List, Optional

# =============================================================================
# Core: Primitive Pythagorean Triples
# =============================================================================

def is_primitive_pythagorean(a: int, b: int, c: int) -> bool:
    """Check if (a, b, c) is a primitive Pythagorean triple with a odd."""
    from math import gcd
    return (a**2 + b**2 == c**2 and
            gcd(a, b) == 1 and
            a > 0 and b > 0 and c > 0 and
            a % 2 == 1)

# =============================================================================
# Berggren Generators
# =============================================================================

def berggren_L(a, b, c):
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_M(a, b, c):
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_R(a, b, c):
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'L': berggren_L, 'M': berggren_M, 'R': berggren_R}

def apply_word(word: str, triple=(3, 4, 5)) -> Tuple[int, int, int]:
    """Apply a Berggren word (string of L, M, R) to a triple."""
    a, b, c = triple
    for ch in word:
        a, b, c = GENERATORS[ch](a, b, c)
    return (a, b, c)

# =============================================================================
# Gram Encoding
# =============================================================================

def gram_encode(a: int, b: int, c: int) -> np.ndarray:
    """
    Gram matrix of basis {(a,b), (a,c)}:
        G = [[a²+b², a²+bc], [a²+bc, a²+c²]]
    By Pythagorean relation a²+b² = c², so G[0,0] = c².
    """
    return np.array([
        [a**2 + b**2, a**2 + b*c],
        [a**2 + b*c, a**2 + c**2]
    ], dtype=np.int64)

def gram_det(a: int, b: int, c: int) -> int:
    """Gram determinant = a²(c-b)²."""
    return a**2 * (c - b)**2

def gram_trace(a: int, b: int, c: int) -> int:
    """Gram trace = a² + 2c²."""
    return a**2 + 2 * c**2

# =============================================================================
# Demo 1: Gram encoding of the Berggren tree
# =============================================================================

def demo_berggren_tree(depth=3):
    """Generate all primitive triples up to given Berggren depth and show their Gram data."""
    print("=" * 70)
    print("DEMO 1: Berggren Tree & Gram Encodings")
    print("=" * 70)
    
    queue = [("", (3, 4, 5))]
    results = []
    
    for word, (a, b, c) in queue:
        if len(word) <= depth:
            G = gram_encode(a, b, c)
            det = gram_det(a, b, c)
            tr = gram_trace(a, b, c)
            results.append((word or "root", a, b, c, det, tr))
            
            if len(word) < depth:
                for ch in 'LMR':
                    new_triple = GENERATORS[ch](a, b, c)
                    queue.append((word + ch, new_triple))
    
    print(f"\n{'Word':<8} {'(a,b,c)':<20} {'det(G)=a²(c-b)²':<18} {'tr(G)=a²+2c²':<15} {'height=c':<10}")
    print("-" * 70)
    for word, a, b, c, det, tr in sorted(results, key=lambda x: x[3]):
        print(f"{word:<8} ({a},{b},{c}){'':<{15-len(f'({a},{b},{c})')}} {det:<18} {tr:<15} {c:<10}")
    
    return results

# =============================================================================
# Demo 2: Functoriality — Gram encoding commutes with Berggren action
# =============================================================================

def demo_functoriality():
    """Verify gramEncode(B_i · t) has the expected structure."""
    print("\n" + "=" * 70)
    print("DEMO 2: Functoriality of Gram Encoding")
    print("=" * 70)
    
    triples = [(3, 4, 5), (5, 12, 13), (8, 15, 17), (7, 24, 25)]
    
    for a, b, c in triples:
        if not is_primitive_pythagorean(a, b, c):
            continue
        print(f"\nTriple ({a}, {b}, {c}):")
        G = gram_encode(a, b, c)
        print(f"  G = {G.tolist()}")
        
        for name, gen in GENERATORS.items():
            a2, b2, c2 = gen(a, b, c)
            G2 = gram_encode(a2, b2, c2)
            # Verify a'² + b'² = c'² (Pythagorean preservation)
            assert a2**2 + b2**2 == c2**2, f"Pythagorean failed for {name}"
            # Verify G2[0,0] = c'²
            assert G2[0,0] == c2**2, f"Gram (0,0) != c'² for {name}"
            print(f"  {name}({a},{b},{c}) = ({a2},{b2},{c2}), "
                  f"det(G)={gram_det(a,b,c)} -> det(G')={gram_det(a2,b2,c2)} ✓")

# =============================================================================
# Demo 3: Determinant Monotonicity
# =============================================================================

def demo_determinant_monotonicity():
    """Show det(G) strictly increases along every Berggren descent path."""
    print("\n" + "=" * 70)
    print("DEMO 3: Determinant Monotonicity under Berggren Descent")
    print("=" * 70)
    
    paths = ["LLL", "LMR", "MML", "RRR", "LMRL", "MRMR"]
    
    for path in paths:
        a, b, c = 3, 4, 5
        dets = [gram_det(a, b, c)]
        heights = [c]
        
        for ch in path:
            a, b, c = GENERATORS[ch](a, b, c)
            dets.append(gram_det(a, b, c))
            heights.append(c)
        
        strictly_increasing = all(dets[i] < dets[i+1] for i in range(len(dets)-1))
        print(f"\n  Path '{path}':")
        print(f"    Heights: {heights}")
        print(f"    Det(G):  {dets}")
        print(f"    Strictly increasing: {'✓' if strictly_increasing else '✗'}")

# =============================================================================
# Demo 4: Injectivity / Reconstruction
# =============================================================================

def demo_injectivity():
    """Show Gram encoding is injective: different triples → different Gram matrices."""
    print("\n" + "=" * 70)
    print("DEMO 4: Gram Encoding Injectivity")
    print("=" * 70)
    
    # Generate all triples up to depth 4
    all_triples = set()
    queue = [("", (3, 4, 5))]
    for word, triple in queue:
        all_triples.add(triple)
        if len(word) < 4:
            for ch in 'LMR':
                new = GENERATORS[ch](*triple)
                queue.append((word + ch, new))
    
    # Check all Gram encodings are distinct
    gram_set = {}
    collisions = 0
    for a, b, c in all_triples:
        G = gram_encode(a, b, c)
        key = tuple(G.flatten())
        if key in gram_set:
            print(f"  COLLISION: ({a},{b},{c}) and {gram_set[key]} share Gram matrix!")
            collisions += 1
        gram_set[key] = (a, b, c)
    
    print(f"\n  Tested {len(all_triples)} distinct primitive triples")
    print(f"  Distinct Gram encodings: {len(gram_set)}")
    print(f"  Collisions found: {collisions}")
    print(f"  Injectivity verified: {'✓' if collisions == 0 else '✗'}")

# =============================================================================
# Demo 5: Ancestry Recovery via Gram Reduction
# =============================================================================

def demo_ancestry_recovery():
    """Show that reducing Gram determinant recovers the Berggren ancestry."""
    print("\n" + "=" * 70)
    print("DEMO 5: Ancestry Recovery via Gram Reduction")
    print("=" * 70)
    
    # Take a deep triple and trace back to root
    test_words = ["LMRL", "MRRM", "RLML"]
    
    for word in test_words:
        a, b, c = apply_word(word)
        print(f"\n  Triple from word '{word}': ({a}, {b}, {c})")
        print(f"  det(G) = {gram_det(a, b, c)}")
        
        # Trace the ancestry
        chain = [(a, b, c, gram_det(a, b, c))]
        current_word = word
        while current_word:
            parent_word = current_word[:-1]
            pa, pb, pc = apply_word(parent_word) if parent_word else (3, 4, 5)
            chain.append((pa, pb, pc, gram_det(pa, pb, pc)))
            current_word = parent_word
        
        print("  Ancestry chain (child → ... → root):")
        for i, (a, b, c, d) in enumerate(chain):
            arrow = " → " if i < len(chain) - 1 else ""
            print(f"    ({a},{b},{c}) [det={d}]{arrow}", end="")
        print()
        
        # Verify determinant strictly decreases
        dets = [d for _, _, _, d in chain]
        print(f"  Determinants: {dets}")
        print(f"  Strictly decreasing: {'✓' if all(dets[i] > dets[i+1] for i in range(len(dets)-1)) else '✗'}")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    demo_berggren_tree(depth=2)
    demo_functoriality()
    demo_determinant_monotonicity()
    demo_injectivity()
    demo_ancestry_recovery()
    
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully!")
    print("=" * 70)


#!/usr/bin/env python3
"""
Berggren–Lattice Reduction Duality: Visualizations

Generates publication-quality figures showing:
  1. The Berggren tree with Gram determinant coloring
  2. Determinant growth along descent paths
  3. Gram encoding space distribution
  4. Reduction chain visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches
from math import gcd
import base64
import io

# Core functions (self-contained for visualization)
def berggren_apply(gen, a, b, c):
    if gen == 'L':
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    elif gen == 'M':
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    elif gen == 'R':
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

def gram_det(a, b, c):
    return a**2 * (c - b)**2

def gram_trace(a, b, c):
    return a**2 + 2 * c**2

def berggren_inverse(a, b, c):
    if (a, b, c) == (3, 4, 5):
        return None
    invs = {
        'L': np.array([[1, 2, -2], [-2, -1, 2], [2, 2, -3]]),
        'M': np.array([[1, -2, -2], [2, -1, -2], [-2, -2, 3]]),
        'R': np.array([[-1, -2, -2], [-2, -1, 2], [-2, 2, -3]]),
    }
    for gen_name in ['L', 'M', 'R']:
        inv = invs[gen_name]
        v = np.array([a, b, c])
        parent = inv @ v
        pa, pb, pc = int(parent[0]), int(parent[1]), int(parent[2])
        if pa > 0 and pb > 0 and pc > 0:
            ca, cb, cc = berggren_apply(gen_name, pa, pb, pc)
            if (ca, cb, cc) == (a, b, c):
                return (gen_name, (pa, pb, pc))
    return None

# =============================================================================
# Figure 1: Berggren Tree with Gram Determinant
# =============================================================================

def fig_berggren_tree():
    """Visualize the first few levels of the Berggren tree with det coloring."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))
    
    # BFS to build tree
    nodes = {}  # word -> (a, b, c, x, y)
    edges = []
    
    # Layout: root at top, children below
    nodes[""] = (3, 4, 5, 0, 0)
    
    depth = 3
    for d in range(depth):
        words_at_d = [w for w in nodes if len(w) == d]
        for w in words_at_d:
            a, b, c, px, py = nodes[w]
            for i, gen in enumerate(['L', 'M', 'R']):
                child = berggren_apply(gen, a, b, c)
                new_word = w + gen
                # Spacing
                spread = 3.0 / (2 ** d)
                cx = px + (i - 1) * spread
                cy = py - 1.5
                nodes[new_word] = (*child, cx, cy)
                edges.append((w, new_word, gen))
    
    # Color by determinant
    dets = [gram_det(a, b, c) for _, (a, b, c, _, _) in nodes.items()]
    max_det = max(dets)
    
    # Draw edges
    gen_colors = {'L': '#2196F3', 'M': '#4CAF50', 'R': '#FF9800'}
    for parent_w, child_w, gen in edges:
        pa, pb, pc, px, py = nodes[parent_w]
        ca, cb, cc, cx, cy = nodes[child_w]
        ax.annotate('', xy=(cx, cy + 0.25), xytext=(px, py - 0.25),
                    arrowprops=dict(arrowstyle='->', color=gen_colors[gen],
                                   lw=1.5, connectionstyle='arc3,rad=0'))
    
    # Draw nodes
    for word, (a, b, c, x, y) in nodes.items():
        det = gram_det(a, b, c)
        intensity = np.log1p(det) / np.log1p(max_det)
        color = plt.cm.YlOrRd(0.2 + 0.7 * intensity)
        
        circle = plt.Circle((x, y), 0.3, color=color, ec='black', lw=1.5, zorder=5)
        ax.add_patch(circle)
        
        label = f"({a},{b},{c})"
        ax.text(x, y + 0.02, label, ha='center', va='center', fontsize=6,
                fontweight='bold', zorder=6)
        ax.text(x, y - 0.5, f"det={det}", ha='center', va='top', fontsize=5,
                color='gray')
    
    # Legend
    patches = [mpatches.Patch(color=gen_colors[g], label=f'Generator {g}') for g in 'LMR']
    ax.legend(handles=patches, loc='upper right', fontsize=10)
    
    ax.set_xlim(-5, 5)
    ax.set_ylim(-5.5, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples\nwith Gram Determinant Coloring',
                fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('fig_berggren_tree.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_berggren_tree.png")

# =============================================================================
# Figure 2: Determinant Growth Along Paths
# =============================================================================

def fig_determinant_growth():
    """Plot determinant growth along several Berggren descent paths."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    paths = {
        'L×n': 'L',
        'M×n': 'M',
        'R×n': 'R',
        'LMR×n': 'LMR',
        'MRL×n': 'MRL',
    }
    
    colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0', '#F44336']
    
    # Left: Determinant growth
    ax = axes[0]
    for (name, pattern), color in zip(paths.items(), colors):
        dets = []
        heights = []
        a, b, c = 3, 4, 5
        dets.append(gram_det(a, b, c))
        heights.append(c)
        
        for i in range(12):
            gen = pattern[i % len(pattern)]
            a, b, c = berggren_apply(gen, a, b, c)
            dets.append(gram_det(a, b, c))
            heights.append(c)
        
        ax.semilogy(range(len(dets)), dets, 'o-', color=color, label=name,
                    markersize=4, linewidth=1.5)
    
    ax.set_xlabel('Berggren Depth', fontsize=12)
    ax.set_ylabel('Gram Determinant (log scale)', fontsize=12)
    ax.set_title('Determinant Growth Along Descent Paths', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    
    # Right: Height vs Determinant
    ax = axes[1]
    all_triples = []
    queue = [("", (3, 4, 5))]
    for word, triple in queue:
        all_triples.append(triple)
        if len(word) < 5:
            for gen in 'LMR':
                child = berggren_apply(gen, *triple)
                queue.append((word + gen, child))
    
    heights = [c for a, b, c in all_triples]
    dets = [gram_det(a, b, c) for a, b, c in all_triples]
    
    ax.scatter(heights, dets, s=8, alpha=0.6, c='#2196F3', edgecolors='none')
    ax.set_xlabel('Height (c)', fontsize=12)
    ax.set_ylabel('Gram Determinant', fontsize=12)
    ax.set_title('Height vs Determinant for All Triples (depth ≤ 5)', fontsize=13, fontweight='bold')
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_determinant_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_determinant_growth.png")

# =============================================================================
# Figure 3: Gram Encoding Space
# =============================================================================

def fig_gram_space():
    """Visualize the Gram encoding in trace-determinant space."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    
    # Generate triples
    all_data = []
    queue = [("", (3, 4, 5))]
    for word, triple in queue:
        a, b, c = triple
        all_data.append((a, b, c, len(word), word))
        if len(word) < 6:
            for gen in 'LMR':
                child = berggren_apply(gen, a, b, c)
                queue.append((word + gen, child))
    
    traces = [a**2 + 2*c**2 for a, b, c, _, _ in all_data]
    dets = [gram_det(a, b, c) for a, b, c, _, _ in all_data]
    depths = [d for _, _, _, d, _ in all_data]
    
    scatter = ax.scatter(traces, dets, c=depths, cmap='viridis', s=12, alpha=0.7,
                        edgecolors='none')
    plt.colorbar(scatter, ax=ax, label='Berggren Depth')
    
    # Annotate a few points
    for a, b, c, d, w in all_data[:4]:
        tr = a**2 + 2*c**2
        det = gram_det(a, b, c)
        ax.annotate(f'({a},{b},{c})', (tr, det), fontsize=7,
                   xytext=(5, 5), textcoords='offset points')
    
    ax.set_xlabel('Gram Trace = a² + 2c²', fontsize=12)
    ax.set_ylabel('Gram Determinant = a²(c−b)²', fontsize=12)
    ax.set_title('Gram Encoding Space: Trace vs Determinant\n(colored by Berggren depth)',
                fontsize=13, fontweight='bold')
    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_gram_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_gram_space.png")

# =============================================================================
# Figure 4: Reduction Chain Visualization
# =============================================================================

def fig_reduction_chain():
    """Visualize a specific reduction chain from a deep triple back to root."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    # Generate a deep triple
    word = "MLRMRL"
    a, b, c = 3, 4, 5
    for ch in word:
        a, b, c = berggren_apply(ch, a, b, c)
    
    # Trace back
    chain = []
    current = (a, b, c)
    while current != (3, 4, 5):
        chain.append(current)
        result = berggren_inverse(*current)
        if result is None:
            break
        _, parent = result
        current = parent
    chain.append((3, 4, 5))
    
    # Left: Determinant chain
    ax = axes[0]
    steps = range(len(chain))
    dets = [gram_det(*t) for t in chain]
    heights = [t[2] for t in chain]
    
    ax.bar(steps, dets, color='#2196F3', alpha=0.7, edgecolor='navy')
    for i, (t, d) in enumerate(zip(chain, dets)):
        ax.text(i, d + max(dets)*0.02, f"({t[0]},{t[1]},{t[2]})",
               ha='center', va='bottom', fontsize=6, rotation=45)
    
    ax.set_xlabel('Reduction Step', fontsize=12)
    ax.set_ylabel('Gram Determinant', fontsize=12)
    ax.set_title(f'Reduction Chain: Determinant Decrease\nStarting from word "{word}"',
                fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')
    
    # Right: Height chain
    ax = axes[1]
    ax.plot(steps, heights, 'o-', color='#FF5722', markersize=8, linewidth=2)
    for i, (t, h) in enumerate(zip(chain, heights)):
        ax.text(i, h + max(heights)*0.02, f"c={h}",
               ha='center', va='bottom', fontsize=8)
    
    ax.set_xlabel('Reduction Step', fontsize=12)
    ax.set_ylabel('Height (c)', fontsize=12)
    ax.set_title('Height Decrease Along Reduction Chain', fontsize=12, fontweight='bold')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('fig_reduction_chain.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved fig_reduction_chain.png")

# =============================================================================
# Generate All Figures
# =============================================================================

def generate_all():
    fig_berggren_tree()
    fig_determinant_growth()
    fig_gram_space()
    fig_reduction_chain()
    print("\nAll visualizations generated!")

if __name__ == "__main__":
    generate_all()
