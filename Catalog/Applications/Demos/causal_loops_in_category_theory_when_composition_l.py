"""
Demo: Causal Loops in Category Theory

Demonstrates the key concepts from the research:
1. Almost-monoid construction and verification
2. Pentagon coherence checking
3. Binary tree reassociation
4. Associahedron structure
"""

from algorithms import (
    AlmostMonoid, BinTree, LEAF,
    left_assoc, right_assoc, all_trees,
    catalan, check_pentagon_coherence,
    make_strict_monoid, verify_all_theorems
)


def demo_binary_trees():
    """Show all parenthesizations for small n."""
    print("=" * 60)
    print("BINARY TREES AND PARENTHESIZATIONS")
    print("=" * 60)

    for n in range(1, 6):
        trees = all_trees(n)
        print(f"\nn = {n}: {len(trees)} parenthesization(s) (C({n-1}) = {catalan(n-1)})")
        for i, t in enumerate(trees):
            marker = ""
            if t == left_assoc(n):
                marker = " ← left-associated"
            elif t == right_assoc(n):
                marker = " ← right-associated"
            print(f"  {i+1}. {t}{marker}")


def demo_almost_monoid():
    """Demonstrate almost-monoid construction."""
    print("\n" + "=" * 60)
    print("ALMOST-MONOID EXAMPLES")
    print("=" * 60)

    # Z/3Z under addition
    n = 3
    z3_mul = lambda a, b: (a + b) % n
    z3 = make_strict_monoid(n, z3_mul, 0)

    print(f"\nZ/{n}Z under addition:")
    print(f"  Identity element: {z3.one}")
    print(f"  Operation table:")
    for a in range(n):
        row = [z3.mul(a, b) for b in range(n)]
        print(f"    {a}: {row}")
    print(f"  Is strict: {z3.is_strict()}")
    print(f"  Satisfies identity: {z3.verify_identity()}")
    print(f"  Satisfies controlled assoc: {z3.verify_controlled_assoc()}")
    print(f"  Pentagon coherent: {check_pentagon_coherence(z3)}")
    print(f"  Total defect: {z3.total_defect()}")


def demo_pentagon():
    """Demonstrate the pentagon identity."""
    print("\n" + "=" * 60)
    print("THE PENTAGON IDENTITY")
    print("=" * 60)

    # Show the 5 parenthesizations of 4 elements
    trees4 = all_trees(4)
    print(f"\n5 parenthesizations of a·b·c·d (|trees| = {len(trees4)}):")
    labels = ['a', 'b', 'c', 'd']

    def label_tree(t: BinTree, idx: list) -> str:
        if t.is_leaf:
            return labels[idx[0]]
            idx[0] += 1  # noqa
        left_str = label_tree(t.left, idx)
        right_str = label_tree(t.right, idx)
        return f"({left_str}·{right_str})"

    for i, t in enumerate(trees4):
        idx = [0]
        def label(tree, start=[0]):
            if tree.is_leaf:
                l = labels[start[0]]
                start[0] += 1
                return l
            return f"({label(tree.left, start)}·{label(tree.right, start)})"
        print(f"  {i+1}. {label(t)}")

    print("\nPentagon coherence asserts: going around the pentagon")
    print("of reassociations always returns to the starting point.")
    print("This is verified computationally for Z/nZ (n=2,3,4):")

    for n in [2, 3, 4]:
        zn = make_strict_monoid(n, lambda a, b, n=n: (a + b) % n, 0)
        ok = check_pentagon_coherence(zn)
        print(f"  Z/{n}Z: {'✓ coherent' if ok else '✗ NOT coherent'}")


def demo_catalan():
    """Demonstrate Catalan numbers."""
    print("\n" + "=" * 60)
    print("CATALAN NUMBERS AND ASSOCIAHEDRA")
    print("=" * 60)

    print("\nC(n) = number of binary trees with n+1 leaves")
    print("     = number of vertices of associahedron K_{n+2}")
    print()
    print("n  | C(n) | Trees | Polytope")
    print("---|------|-------|----------")
    polytopes = ["point", "interval", "pentagon", "3D assocahedron",
                 "4D assocahedron", "5D assocahedron"]
    for n in range(6):
        trees = all_trees(n + 1)
        poly = polytopes[n] if n < len(polytopes) else f"{n}D"
        print(f"{n}  | {catalan(n):4d} | {len(trees):5d} | K_{n+2} = {poly}")


def demo_defect():
    """Demonstrate associator defect."""
    print("\n" + "=" * 60)
    print("ASSOCIATOR DEFECT ANALYSIS")
    print("=" * 60)

    # Create a non-trivial almost-monoid on {0, 1}
    # XOR is associative, so the strict version has zero defect
    xor_am = make_strict_monoid(2, lambda a, b: a ^ b, 0)
    print(f"\nXOR on {{0,1}}:")
    print(f"  Is strict: {xor_am.is_strict()}")
    print(f"  Total defect: {xor_am.total_defect()}")

    # Show defect table
    print(f"  Defect table δ(a,b,c):")
    for a in range(2):
        for b in range(2):
            for c in range(2):
                d = xor_am.defect(a, b, c)
                print(f"    δ({a},{b},{c}) = {d}")


def demo_verification():
    """Run all computational verifications."""
    print("\n" + "=" * 60)
    print("COMPUTATIONAL VERIFICATION OF THEOREMS")
    print("=" * 60)

    results = verify_all_theorems()
    all_ok = True
    for name, passed in results.items():
        status = "✓" if passed else "✗"
        if not passed:
            all_ok = False
        print(f"  {status} {name}")

    print(f"\n{'All verifications passed!' if all_ok else 'SOME VERIFICATIONS FAILED!'}")


if __name__ == "__main__":
    demo_binary_trees()
    demo_almost_monoid()
    demo_pentagon()
    demo_catalan()
    demo_defect()
    demo_verification()


"""
Visualization: The Associahedron and Reassociation Graphs

Generates visualizations of:
1. Binary tree parenthesizations
2. The associahedron K4 (pentagon) and K5
3. Catalan number growth
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass(frozen=True)
class BinTree:
    left: Optional['BinTree'] = None
    right: Optional['BinTree'] = None

    @property
    def is_leaf(self) -> bool:
        return self.left is None

    @property
    def leaf_count(self) -> int:
        if self.is_leaf:
            return 1
        return self.left.leaf_count + self.right.leaf_count

    def label(self, symbols: list, idx: list = None) -> str:
        if idx is None:
            idx = [0]
        if self.is_leaf:
            s = symbols[idx[0]] if idx[0] < len(symbols) else f"x{idx[0]}"
            idx[0] += 1
            return s
        return f"({self.label(symbols, idx)}·{self.label(symbols, idx)})"


LEAF = BinTree()


def all_trees(n: int) -> List[BinTree]:
    if n <= 0:
        return []
    if n == 1:
        return [LEAF]
    result = []
    for k in range(1, n):
        for left in all_trees(k):
            for right in all_trees(n - k):
                result.append(BinTree(left, right))
    return result


def catalan(n: int) -> int:
    if n <= 1:
        return 1
    return sum(catalan(k) * catalan(n - 1 - k) for k in range(n))


def trees_adjacent(t1: BinTree, t2: BinTree) -> bool:
    """Check if t1 and t2 differ by exactly one associator step."""
    if t1 == t2:
        return False
    if t1.is_leaf or t2.is_leaf:
        return False

    # Direct rotation: (a·b)·c <-> a·(b·c)
    if (not t1.is_leaf and not t1.left.is_leaf and
        t2.left == t1.left.left and
        not t2.right.is_leaf and
        t2.right.left == t1.left.right and
        t2.right.right == t1.right):
        return True
    if (not t2.is_leaf and not t2.left.is_leaf and
        t1.left == t2.left.left and
        not t1.right.is_leaf and
        t1.right.left == t2.left.right and
        t1.right.right == t2.right):
        return True

    # Rotation in left subtree
    if t1.right == t2.right and trees_adjacent(t1.left, t2.left):
        return True
    # Rotation in right subtree
    if t1.left == t2.left and trees_adjacent(t1.right, t2.right):
        return True

    return False


def plot_associahedron():
    """Plot the associahedron K4 (pentagon) and K5."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # K4: Pentagon (5 vertices)
    ax = axes[0]
    trees4 = all_trees(4)
    n4 = len(trees4)
    symbols = ['a', 'b', 'c', 'd']

    # Pentagon layout
    angles = [np.pi/2 + 2*np.pi*i/5 for i in range(5)]
    positions = [(1.8*np.cos(a), 1.8*np.sin(a)) for a in angles]

    # Draw edges
    for i in range(n4):
        for j in range(i+1, n4):
            if trees_adjacent(trees4[i], trees4[j]):
                ax.plot([positions[i][0], positions[j][0]],
                       [positions[i][1], positions[j][1]],
                       'b-', linewidth=2, alpha=0.6)

    # Draw vertices
    for i, (x, y) in enumerate(positions):
        ax.plot(x, y, 'o', markersize=15, color='#2196F3', zorder=5)
        label = trees4[i].label(symbols)
        ax.annotate(label, (x, y), textcoords="offset points",
                   xytext=(0, 20), ha='center', fontsize=8,
                   fontweight='bold',
                   bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

    ax.set_title('Associahedron K₄ (Pentagon)\n5 parenthesizations of a·b·c·d',
                fontsize=13, fontweight='bold')
    ax.set_xlim(-3, 3)
    ax.set_ylim(-2.5, 3)
    ax.set_aspect('equal')
    ax.axis('off')

    # K5 graph (14 vertices)
    ax = axes[1]
    trees5 = all_trees(5)
    n5 = len(trees5)
    symbols5 = ['a', 'b', 'c', 'd', 'e']

    # Circular layout
    angles5 = [2*np.pi*i/n5 for i in range(n5)]
    positions5 = [(3*np.cos(a), 3*np.sin(a)) for a in angles5]

    # Draw edges
    for i in range(n5):
        for j in range(i+1, n5):
            if trees_adjacent(trees5[i], trees5[j]):
                ax.plot([positions5[i][0], positions5[j][0]],
                       [positions5[i][1], positions5[j][1]],
                       'b-', linewidth=1, alpha=0.4)

    # Draw vertices
    for i, (x, y) in enumerate(positions5):
        ax.plot(x, y, 'o', markersize=8, color='#E91E63', zorder=5)

    ax.set_title(f'Associahedron K₅ Graph\n{n5} parenthesizations of a·b·c·d·e',
                fontsize=13, fontweight='bold')
    ax.set_xlim(-4.5, 4.5)
    ax.set_ylim(-4.5, 4.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('associahedron.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: associahedron.png")


def plot_catalan_growth():
    """Plot Catalan number growth."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ns = list(range(12))
    cats = [catalan(n) for n in ns]

    ax1.bar(ns, cats, color='#4CAF50', alpha=0.8, edgecolor='#2E7D32')
    ax1.set_xlabel('n', fontsize=12)
    ax1.set_ylabel('C(n)', fontsize=12)
    ax1.set_title('Catalan Numbers C(n)', fontsize=14, fontweight='bold')
    ax1.set_yscale('log')
    for i, c in enumerate(cats):
        ax1.annotate(str(c), (i, c), textcoords="offset points",
                    xytext=(0, 5), ha='center', fontsize=8)

    # Asymptotic comparison
    ns_cont = np.linspace(1, 11, 100)
    asymp = 4**ns_cont / (ns_cont**(1.5) * np.sqrt(np.pi))
    ax2.semilogy(ns[1:], cats[1:], 'o-', color='#2196F3', label='C(n)', markersize=8)
    ax2.semilogy(ns_cont, asymp, '--', color='#FF5722',
                label=r'$4^n / (n^{3/2}\sqrt{\pi})$', linewidth=2)
    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Value (log scale)', fontsize=12)
    ax2.set_title('Catalan Numbers vs Asymptotic Formula', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('catalan_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: catalan_growth.png")


def plot_defect_heatmap():
    """Plot associator defect as a heatmap for various operations."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))

    operations = [
        ("Addition mod 3", lambda a, b: (a + b) % 3),
        ("Multiplication mod 3", lambda a, b: (a * b) % 3),
        ("Max", lambda a, b: max(a, b)),
    ]

    for ax, (name, op) in zip(axes, operations):
        n = 3
        # Check if it has an identity
        identity = None
        for e in range(n):
            if all(op(e, a) == a and op(a, e) == a for a in range(n)):
                identity = e
                break

        if identity is None:
            ax.set_title(f'{name}\n(no identity)')
            ax.axis('off')
            continue

        # Compute defect: is op associative on each triple?
        defects = np.zeros((n, n*n))
        labels_y = [str(a) for a in range(n)]
        labels_x = [f"({b},{c})" for b in range(n) for c in range(n)]

        for a in range(n):
            for idx, (b, c) in enumerate((b, c) for b in range(n) for c in range(n)):
                lhs = op(op(a, b), c)
                rhs = op(a, op(b, c))
                defects[a, idx] = 0 if lhs == rhs else 1

        im = ax.imshow(defects, cmap='RdYlGn_r', vmin=0, vmax=1, aspect='auto')
        ax.set_title(f'{name}\nAssociativity failure map', fontsize=11, fontweight='bold')
        ax.set_ylabel('a')
        ax.set_xlabel('(b, c)')
        ax.set_yticks(range(n))
        ax.set_yticklabels(labels_y)

    plt.tight_layout()
    plt.savefig('defect_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: defect_heatmap.png")


if __name__ == "__main__":
    plot_associahedron()
    plot_catalan_growth()
    plot_defect_heatmap()
