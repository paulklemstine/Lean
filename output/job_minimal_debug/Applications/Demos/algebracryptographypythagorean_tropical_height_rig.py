#!/usr/bin/env python3
"""
Tropical Height Rigidity for Berggren Tree — Demo & Visualization

Demonstrates the decidable rigidity/collision classification of
tropical observables on the Berggren tree of primitive Pythagorean triples.
"""

import numpy as np
from itertools import product
from collections import defaultdict
import json
import base64
import io

# ============================================================
# §1. Berggren Generator Matrices
# ============================================================

A = np.array([[1, -2, 2],
              [2, -1, 2],
              [2, -2, 3]], dtype=np.int64)

B = np.array([[1, 2, 2],
              [2, 1, 2],
              [2, 2, 3]], dtype=np.int64)

C = np.array([[-1, 2, 2],
              [-2, 1, 2],
              [-2, 2, 3]], dtype=np.int64)

GENERATORS = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=np.int64)

def eval_word(word):
    """Evaluate a word (string of A/B/C) to its matrix product."""
    M = np.eye(3, dtype=np.int64)
    for ch in word:
        M = GENERATORS[ch] @ M
    return M

def triple_of_word(word):
    """Compute the Pythagorean triple for a Berggren word."""
    return eval_word(word) @ ROOT

# ============================================================
# §2. Observable Functions
# ============================================================

def padic_val(p, n):
    """p-adic valuation of a positive integer n."""
    if n == 0:
        return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def arch_height(t):
    """Archimedean height: max of absolute values."""
    return max(abs(int(x)) for x in t)

def obs_vec(t):
    """Observable vector: (arch, v2x, v2y, v2z, v3x, v3y, v3z)."""
    x, y, z = [abs(int(c)) for c in t]
    return (max(x, y, z),
            padic_val(2, x), padic_val(2, y), padic_val(2, z),
            padic_val(3, x), padic_val(3, y), padic_val(3, z))

def aug_obs_vec(t):
    """Augmented observable: base obs + mod 5 and mod 7 residues."""
    x, y, z = [int(c) for c in t]
    base = obs_vec(t)
    return base + (x % 5, y % 5, z % 5, x % 7, y % 7, z % 7)

def theta(word):
    """Observable map theta: word -> ObsVec."""
    return obs_vec(triple_of_word(word))

def theta_aug(word):
    """Augmented observable map."""
    return aug_obs_vec(triple_of_word(word))

# ============================================================
# §3. Word Enumeration
# ============================================================

def words_up_to(d):
    """All words of length <= d over {A, B, C}."""
    words = ['']
    for length in range(1, d + 1):
        for combo in product('ABC', repeat=length):
            words.append(''.join(combo))
    return words

# ============================================================
# §4. Fiber Analysis
# ============================================================

def compute_fibers(d, use_augmented=False):
    """Compute all fibers of theta (or theta_aug) at depth <= d."""
    obs_fn = theta_aug if use_augmented else theta
    words = words_up_to(d)
    fibers = defaultdict(list)
    for w in words:
        o = obs_fn(w)
        fibers[o].append(w)
    return fibers

def classify_fibers(fibers):
    """Classify fibers into rigid (singleton) and collision-bearing."""
    rigid = {}
    collisions = {}
    for o, ws in fibers.items():
        if len(ws) == 1:
            rigid[o] = ws[0]
        else:
            collisions[o] = ws
    return rigid, collisions

# ============================================================
# §5. Main Demo
# ============================================================

def demo_basic():
    """Demonstrate basic Berggren tree triples and observables."""
    print("=" * 70)
    print("TROPICAL HEIGHT RIGIDITY — BERGGREN TREE DEMO")
    print("=" * 70)
    print()
    
    # Show depth-1 triples
    print("§1. Depth-1 Pythagorean Triples")
    print("-" * 40)
    for name in ['A', 'B', 'C']:
        t = triple_of_word(name)
        print(f"  Word '{name}': triple = ({t[0]}, {t[1]}, {t[2]})")
        assert t[0]**2 + t[1]**2 == t[2]**2, "Not Pythagorean!"
        print(f"    Check: {t[0]}² + {t[1]}² = {t[0]**2 + t[1]**2} = {t[2]}² ✓")
        o = obs_vec(t)
        print(f"    θ = arch:{o[0]}, v₂:({o[1]},{o[2]},{o[3]}), v₃:({o[4]},{o[5]},{o[6]})")
    print()
    
    # Root triple
    t0 = triple_of_word('')
    print(f"  Root (empty word): ({t0[0]}, {t0[1]}, {t0[2]})")
    print()

def demo_fibers(max_depth=4):
    """Demonstrate fiber classification at various depths."""
    print("§2. Fiber Classification (Base Observable θ)")
    print("-" * 40)
    
    for d in range(1, max_depth + 1):
        fibers = compute_fibers(d, use_augmented=False)
        rigid, collisions = classify_fibers(fibers)
        total_words = sum(3**k for k in range(d + 1))
        
        print(f"  Depth ≤ {d}: {total_words} words, "
              f"{len(fibers)} distinct observables")
        print(f"    Rigid fibers (singletons): {len(rigid)}")
        print(f"    Collision fibers:          {len(collisions)}")
        
        if collisions:
            # Show first collision
            o, ws = next(iter(collisions.items()))
            print(f"    Example collision: obs = arch:{o[0]}")
            for w in ws[:3]:
                t = triple_of_word(w)
                print(f"      word '{w}' → ({t[0]}, {t[1]}, {t[2]})")
        print()

def demo_augmented(max_depth=4):
    """Demonstrate augmented observable separation."""
    print("§3. Augmented Observable θ_aug (with mod 5, mod 7)")
    print("-" * 40)
    
    for d in range(1, max_depth + 1):
        fibers_base = compute_fibers(d, use_augmented=False)
        fibers_aug = compute_fibers(d, use_augmented=True)
        _, collisions_base = classify_fibers(fibers_base)
        _, collisions_aug = classify_fibers(fibers_aug)
        
        total_words = sum(3**k for k in range(d + 1))
        
        print(f"  Depth ≤ {d}: {total_words} words")
        print(f"    Base collisions:      {len(collisions_base)}")
        print(f"    Augmented collisions: {len(collisions_aug)}")
        if len(collisions_base) > 0:
            reduction = (1 - len(collisions_aug) / len(collisions_base)) * 100
            print(f"    Collision reduction:  {reduction:.1f}%")
        print()

def demo_inversion():
    """Demonstrate certified inversion."""
    print("§4. Certified Inversion Examples")
    print("-" * 40)
    
    # Pick a specific observable and invert it
    test_words = ['A', 'BA', 'CB', 'ABC', 'CBA']
    for w in test_words:
        t = triple_of_word(w)
        o = theta_aug(w)
        
        # Search all words up to same depth for matches
        d = len(w)
        all_words = words_up_to(d)
        matches = [u for u in all_words if theta_aug(u) == o]
        
        if len(matches) == 1:
            status = "UNIQUE (rigid)"
        else:
            status = f"COLLISION ({len(matches)} preimages)"
        
        print(f"  Word '{w}' → ({t[0]}, {t[1]}, {t[2]})")
        print(f"    Inversion status: {status}")
        if len(matches) > 1:
            print(f"    Colliding words: {matches}")
        print()

def generate_visualization_data(max_depth=4):
    """Generate data for visualization."""
    depths = list(range(1, max_depth + 1))
    rigid_counts = []
    collision_counts = []
    aug_collision_counts = []
    total_words_list = []
    exceptional_ratios = []
    
    for d in depths:
        total = sum(3**k for k in range(d + 1))
        total_words_list.append(total)
        
        fibers = compute_fibers(d, use_augmented=False)
        rigid, collisions = classify_fibers(fibers)
        rigid_counts.append(len(rigid))
        collision_counts.append(len(collisions))
        
        fibers_aug = compute_fibers(d, use_augmented=True)
        _, collisions_aug = classify_fibers(fibers_aug)
        aug_collision_counts.append(len(collisions_aug))
        
        total_fibers = len(fibers_aug)
        exc_ratio = len(collisions_aug) / total_fibers if total_fibers > 0 else 0
        exceptional_ratios.append(exc_ratio)
    
    return {
        'depths': depths,
        'total_words': total_words_list,
        'rigid_counts': rigid_counts,
        'collision_counts': collision_counts,
        'aug_collision_counts': aug_collision_counts,
        'exceptional_ratios': exceptional_ratios,
    }

def create_ascii_chart(data):
    """Create a simple text-based chart."""
    print("§5. Rigidity Statistics")
    print("-" * 40)
    print(f"{'Depth':>6} {'Words':>8} {'Rigid':>8} {'Coll':>8} {'AugColl':>8} {'ExcRatio':>10}")
    print("-" * 55)
    for i, d in enumerate(data['depths']):
        print(f"{d:>6} {data['total_words'][i]:>8} "
              f"{data['rigid_counts'][i]:>8} {data['collision_counts'][i]:>8} "
              f"{data['aug_collision_counts'][i]:>8} "
              f"{data['exceptional_ratios'][i]:>10.4f}")
    print()

def generate_tree_display(max_depth=3):
    """Display the Berggren tree structure."""
    print("§6. Berggren Tree Structure (first 3 levels)")
    print("-" * 40)
    
    def show_node(word, indent=0):
        t = triple_of_word(word)
        prefix = "  " * indent + ("└─ " if indent > 0 else "")
        pyth_check = "✓" if t[0]**2 + t[1]**2 == t[2]**2 else "✗"
        print(f"{prefix}[{word or 'ε'}] → ({t[0]}, {t[1]}, {t[2]}) {pyth_check}")
        if len(word) < max_depth:
            for g in 'ABC':
                show_node(word + g, indent + 1)
    
    show_node('')
    print()

if __name__ == '__main__':
    demo_basic()
    demo_fibers(max_depth=4)
    demo_augmented(max_depth=4)
    demo_inversion()
    
    data = generate_visualization_data(max_depth=5)
    create_ascii_chart(data)
    generate_tree_display(max_depth=2)
    
    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Height Rigidity on the Berggren Tree.
Generates PNG figures and base64 data URIs.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
from itertools import product
import base64
import io

# ---- Berggren setup (duplicated for self-containedness) ----

A = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=np.int64)
B_mat = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=np.int64)
C_mat = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=np.int64)
GENERATORS = {'A': A, 'B': B_mat, 'C': C_mat}
ROOT = np.array([3, 4, 5], dtype=np.int64)

def eval_word(word):
    M = np.eye(3, dtype=np.int64)
    for ch in word:
        M = GENERATORS[ch] @ M
    return M

def triple_of_word(word):
    return eval_word(word) @ ROOT

def padic_val(p, n):
    if n == 0: return float('inf')
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v

def obs_vec(t):
    x, y, z = [abs(int(c)) for c in t]
    return (max(x, y, z),
            padic_val(2, x), padic_val(2, y), padic_val(2, z),
            padic_val(3, x), padic_val(3, y), padic_val(3, z))

def aug_obs_vec(t):
    x, y, z = [int(c) for c in t]
    base = obs_vec(t)
    return base + (x % 5, y % 5, z % 5, x % 7, y % 7, z % 7)

def words_up_to(d):
    words = ['']
    for length in range(1, d + 1):
        for combo in product('ABC', repeat=length):
            words.append(''.join(combo))
    return words

def compute_fibers(d, augmented=False):
    fn = aug_obs_vec if augmented else obs_vec
    words = words_up_to(d)
    fibers = defaultdict(list)
    for w in words:
        t = triple_of_word(w)
        o = fn(t)
        fibers[o].append(w)
    return fibers

# ---- Figure 1: Rigidity statistics ----

def fig_rigidity_stats(max_depth=6):
    depths = list(range(1, max_depth + 1))
    rigid = []
    collisions = []
    aug_collisions = []
    
    for d in depths:
        fb = compute_fibers(d, False)
        r = sum(1 for ws in fb.values() if len(ws) == 1)
        c = sum(1 for ws in fb.values() if len(ws) > 1)
        rigid.append(r)
        collisions.append(c)
        
        fb_aug = compute_fibers(d, True)
        ca = sum(1 for ws in fb_aug.values() if len(ws) > 1)
        aug_collisions.append(ca)
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.bar([d - 0.2 for d in depths], rigid, 0.35, label='Rigid (singleton)', color='#2ecc71')
    ax1.bar([d + 0.2 for d in depths], collisions, 0.35, label='Collision', color='#e74c3c')
    ax1.set_xlabel('Depth bound d', fontsize=12)
    ax1.set_ylabel('Number of fibers', fontsize=12)
    ax1.set_title('Base Observable θ: Fiber Classification', fontsize=13)
    ax1.legend(fontsize=11)
    ax1.set_xticks(depths)
    
    ax2.bar([d - 0.2 for d in depths], collisions, 0.35, label='Base θ collisions', color='#e74c3c', alpha=0.7)
    ax2.bar([d + 0.2 for d in depths], aug_collisions, 0.35, label='Augmented θ_aug collisions', color='#3498db', alpha=0.7)
    ax2.set_xlabel('Depth bound d', fontsize=12)
    ax2.set_ylabel('Number of collision fibers', fontsize=12)
    ax2.set_title('Collision Reduction via Augmentation', fontsize=13)
    ax2.legend(fontsize=11)
    ax2.set_xticks(depths)
    
    plt.tight_layout()
    return fig

# ---- Figure 2: Berggren tree with height coloring ----

def fig_tree_heights(max_depth=4):
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Layout tree with BFS
    positions = {}
    node_data = {}
    
    # Root
    positions[''] = (0.5, 1.0)
    t = triple_of_word('')
    node_data[''] = {'triple': tuple(int(c) for c in t), 'height': max(abs(int(c)) for c in t)}
    
    for depth in range(1, max_depth + 1):
        # Count nodes at this depth
        nodes_at_depth = []
        for combo in product('ABC', repeat=depth):
            w = ''.join(combo)
            nodes_at_depth.append(w)
        
        n = len(nodes_at_depth)
        for i, w in enumerate(nodes_at_depth):
            x = (i + 0.5) / n
            y = 1.0 - depth * 0.2
            positions[w] = (x, y)
            t = triple_of_word(w)
            node_data[w] = {'triple': tuple(int(c) for c in t),
                           'height': max(abs(int(c)) for c in t)}
    
    # Draw edges
    for w in positions:
        if len(w) > 0:
            parent = w[:-1]
            if parent in positions:
                px, py = positions[parent]
                cx, cy = positions[w]
                ax.plot([px, cx], [py, cy], 'k-', alpha=0.2, linewidth=0.5)
    
    # Draw nodes colored by log height
    heights = [node_data[w]['height'] for w in positions]
    max_h = max(heights)
    
    for w in positions:
        x, y = positions[w]
        h = node_data[w]['height']
        color_val = np.log(h + 1) / np.log(max_h + 1)
        color = plt.cm.viridis(color_val)
        size = 30 if len(w) > 2 else 60 if len(w) > 0 else 120
        ax.scatter(x, y, c=[color], s=size, zorder=5, edgecolors='black', linewidth=0.5)
    
    # Label root and depth-1 nodes
    for w in ['', 'A', 'B', 'C']:
        x, y = positions[w]
        t = node_data[w]['triple']
        label = f"({t[0]},{t[1]},{t[2]})"
        ax.annotate(label, (x, y), textcoords="offset points", xytext=(0, 10),
                   ha='center', fontsize=8, fontweight='bold')
    
    ax.set_title('Berggren Tree: Primitive Pythagorean Triples\n(colored by log archimedean height)', fontsize=14)
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0.1, 1.1)
    ax.axis('off')
    
    # Colorbar
    sm = plt.cm.ScalarMappable(cmap='viridis', norm=plt.Normalize(0, np.log(max_h + 1)))
    sm.set_array([])
    cbar = plt.colorbar(sm, ax=ax, shrink=0.6, label='log(height)')
    
    plt.tight_layout()
    return fig

# ---- Figure 3: Observable space scatter ----

def fig_observable_scatter(depth=4):
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    words = words_up_to(depth)
    heights = []
    v2_sums = []
    v3_sums = []
    word_lens = []
    
    for w in words:
        t = triple_of_word(w)
        o = obs_vec(t)
        heights.append(np.log(o[0] + 1))
        v2_sums.append(o[1] + o[2] + o[3])
        v3_sums.append(o[4] + o[5] + o[6])
        word_lens.append(len(w))
    
    sc1 = axes[0].scatter(heights, v2_sums, c=word_lens, cmap='plasma',
                          s=40, alpha=0.7, edgecolors='black', linewidth=0.3)
    axes[0].set_xlabel('log(archimedean height)', fontsize=12)
    axes[0].set_ylabel('Total 2-adic valuation', fontsize=12)
    axes[0].set_title(f'Observable Space (depth ≤ {depth})\nHeight vs 2-adic data', fontsize=13)
    plt.colorbar(sc1, ax=axes[0], label='Word length')
    
    sc2 = axes[1].scatter(v2_sums, v3_sums, c=word_lens, cmap='plasma',
                          s=40, alpha=0.7, edgecolors='black', linewidth=0.3)
    axes[1].set_xlabel('Total 2-adic valuation', fontsize=12)
    axes[1].set_ylabel('Total 3-adic valuation', fontsize=12)
    axes[1].set_title(f'Observable Space (depth ≤ {depth})\n2-adic vs 3-adic data', fontsize=13)
    plt.colorbar(sc2, ax=axes[1], label='Word length')
    
    plt.tight_layout()
    return fig

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    b64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{b64}"

if __name__ == '__main__':
    print("Generating visualizations...")
    
    fig1 = fig_rigidity_stats(max_depth=5)
    fig1.savefig('rigidity_stats.png', dpi=150, bbox_inches='tight')
    print("  Saved rigidity_stats.png")
    plt.close(fig1)
    
    fig2 = fig_tree_heights(max_depth=3)
    fig2.savefig('berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved berggren_tree.png")
    plt.close(fig2)
    
    fig3 = fig_observable_scatter(depth=4)
    fig3.savefig('observable_scatter.png', dpi=150, bbox_inches='tight')
    print("  Saved observable_scatter.png")
    plt.close(fig3)
    
    print("All visualizations generated.")
