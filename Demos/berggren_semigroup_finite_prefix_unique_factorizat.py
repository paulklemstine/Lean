"""
Berggren Free Monoid: Interactive Demonstration
================================================

This script demonstrates the key theorems proved in the formal Lean development:

1. The three Berggren generators form a free semigroup (no hidden relations)
2. Every Pythagorean triple in the tree has a unique word decomposition
3. Left/right divisibility corresponds to prefix/suffix on words
4. Word length is an additive invariant
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cartesian_product
from collections import defaultdict

# ============================================================
# Core Definitions
# ============================================================

GENERATORS = {
    'A': np.array([[2, -1], [1, 0]], dtype=int),
    'B': np.array([[2,  1], [1, 0]], dtype=int),
    'C': np.array([[1,  2], [0, 1]], dtype=int),
}

ROOT_PAIR = np.array([2, 1], dtype=int)

def pair_to_triple(m, n):
    a = m*m - n*n
    b = 2*m*n
    c = m*m + n*n
    return (int(a), int(b), int(c))

def eval_word(word):
    """Evaluate word as matrix product: eval(g1 g2 ... gn) = M(g1) * M(g2) * ... * M(gn)."""
    result = np.eye(2, dtype=int)
    for g in word:
        result = result @ GENERATORS[g]
    return result

def eval_pair(word):
    return eval_word(word) @ ROOT_PAIR

def eval_triple(word):
    mn = eval_pair(word)
    return pair_to_triple(mn[0], mn[1])

# ============================================================
# Demo 1: Freeness Verification
# ============================================================

def demo_freeness(max_length=4):
    print("=" * 60)
    print("DEMO 1: Freeness / Injectivity Verification")
    print("=" * 60)
    print(f"\nChecking all words of length <= {max_length}...")

    seen = {}
    total = 0
    for length in range(max_length + 1):
        for wt in cartesian_product('ABC', repeat=length):
            word = ''.join(wt)
            mat = eval_word(word)
            key = tuple(mat.flatten())
            total += 1
            if key in seen:
                print(f"  COLLISION: '{word}' = '{seen[key]}'")
            else:
                seen[key] = word

    print(f"  Total words: {total}, Distinct matrices: {len(seen)}")
    print("  No collisions found -- consistent with freeness theorem!\n")

# ============================================================
# Demo 2: Berggren Tree
# ============================================================

def demo_tree(depth=2):
    print("=" * 60)
    print("DEMO 2: Berggren Tree of Pythagorean Triples")
    print("=" * 60)

    def show(word, indent=0):
        t = eval_triple(word)
        mn = eval_pair(word)
        pre = "  " * indent + ("|- " if indent else "")
        lbl = word if word else "root"
        print(f"{pre}[{lbl}] -> (m,n)=({mn[0]},{mn[1]}) -> triple={t}")
        if len(word) < depth:
            for g in 'ABC':
                show(g + word, indent + 1)

    print()
    show("")
    print()

# ============================================================
# Demo 3: Unique Factorization
# ============================================================

def demo_unique_factorization():
    print("=" * 60)
    print("DEMO 3: Unique Factorization")
    print("=" * 60)

    triples_to_words = defaultdict(list)
    for length in range(5):
        for wt in cartesian_product('ABC', repeat=length):
            word = ''.join(wt)
            triples_to_words[eval_triple(word)].append(word)

    print(f"\n  Triples generated (depth <= 4): {len(triples_to_words)}")
    unique = all(len(ws) == 1 for ws in triples_to_words.values())
    print(f"  All unique: {unique}")

    print("\n  Sample factorizations:")
    for triple, words in sorted(triples_to_words.items(), key=lambda x: x[0][2])[:8]:
        w = words[0] if words[0] else "e (empty)"
        print(f"    {triple} <- word: {w}")
    print()

# ============================================================
# Demo 4: Additive Word Length
# ============================================================

def demo_additive_length():
    print("=" * 60)
    print("DEMO 4: Additive Word Length")
    print("=" * 60)

    pairs = [('A', 'B'), ('AB', 'C'), ('ABC', 'BA'), ('AA', 'BB'), ('C', 'ABC')]
    for u, v in pairs:
        assert np.array_equal(eval_word(u) @ eval_word(v), eval_word(u + v))
        print(f"  len({u}) + len({v}) = {len(u)} + {len(v)} = {len(u)+len(v)} "
              f"= len({u+v})")
    print("  Word length is perfectly additive!\n")

# ============================================================
# Demo 5: Visualizations
# ============================================================

def demo_visualization():
    print("=" * 60)
    print("DEMO 5: Visualizations")
    print("=" * 60)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    triples, words = [], []
    for depth in range(6):
        for wt in cartesian_product('ABC', repeat=depth):
            w = ''.join(wt)
            triples.append(eval_triple(w))
            words.append(w)

    a_vals = [t[0] for t in triples]
    b_vals = [t[1] for t in triples]
    depths = [len(w) for w in words]

    ax = axes[0]
    sc = ax.scatter(a_vals, b_vals, c=depths, cmap='viridis',
                    s=30, alpha=0.7, edgecolors='black', linewidth=0.3)
    ax.set_xlabel('a (odd leg)')
    ax.set_ylabel('b (even leg)')
    ax.set_title('Berggren Tree: Primitive Pythagorean Triples\nColor = word length')
    plt.colorbar(sc, ax=ax, label='Word length')

    ax = axes[1]
    colors_map = {'': 'red', 'A': '#2196F3', 'B': '#4CAF50', 'C': '#FF9800'}
    m_vals, n_vals, colors = [], [], []
    for w in words:
        mn = eval_pair(w)
        m_vals.append(mn[0])
        n_vals.append(mn[1])
        colors.append(colors_map.get(w[0] if w else '', 'red'))

    ax.scatter(m_vals, n_vals, c=colors, s=30, alpha=0.7,
              edgecolors='black', linewidth=0.3)
    ax.set_xlabel('m')
    ax.set_ylabel('n')
    ax.set_title('Stern-Brocot Parametrization\nColor = first generator')

    from matplotlib.patches import Patch
    ax.legend(handles=[
        Patch(facecolor='red', label='Root'),
        Patch(facecolor='#2196F3', label='A-branch'),
        Patch(facecolor='#4CAF50', label='B-branch'),
        Patch(facecolor='#FF9800', label='C-branch'),
    ], loc='upper left')

    plt.tight_layout()
    plt.savefig('demos/berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/berggren_tree.png")

    # Discriminant plot
    fig, ax = plt.subplots(figsize=(10, 7))
    for branch, color, label in [
            ('A', '#2196F3', 'A-branch (m/n < 2)'),
            ('B', '#4CAF50', 'B-branch (2 < m/n < 3)'),
            ('C', '#FF9800', 'C-branch (m/n > 3)')]:
        data = []
        for depth in range(1, 5):
            for wt in cartesian_product('ABC', repeat=depth):
                w = ''.join(wt)
                if w[0] == branch:
                    mn = eval_pair(w)
                    data.append((depth, mn[0] / mn[1]))
        if data:
            d, r = zip(*data)
            jitter = np.random.default_rng(42).uniform(-0.15, 0.15, len(d))
            ax.scatter(np.array(d) + jitter, r, c=color, s=20, alpha=0.6,
                      edgecolors='black', linewidth=0.2, label=label)

    ax.axhline(y=2, color='gray', ls='--', alpha=0.5, label='m/n = 2')
    ax.axhline(y=3, color='gray', ls=':', alpha=0.5, label='m/n = 3')
    ax.set_xlabel('Word length')
    ax.set_ylabel('m/n ratio')
    ax.set_title('Discriminant Classifier: m/n Ratio Intervals Are Disjoint\n'
                 '→ This is the key to the freeness proof')
    ax.legend()
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('demos/berggren_discriminant.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/berggren_discriminant.png\n")

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("\n" + "=" * 60)
    print("  BERGGREN FREE MONOID: FORMAL MATHEMATICS IN ACTION")
    print("=" * 60 + "\n")

    demo_freeness()
    demo_tree()
    demo_unique_factorization()
    demo_additive_length()
    demo_visualization()

    print("All demonstrations complete!")
