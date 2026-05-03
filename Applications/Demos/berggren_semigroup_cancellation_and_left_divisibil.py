"""
Berggren Semigroup: Divisibility, Prefix Order, and Cryptographic Reductions
=============================================================================

This demo illustrates the main theorems from the formal Lean development:
1. The Berggren tree generators and freeness
2. Left/right divisibility as prefix/suffix on normal forms
3. Longest common prefix as greatest lower bound
4. The oracle reduction: prefix recovery → secret suffix extraction
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as cart_product

# ============================================================================
# Berggren Generators as 3×3 Integer Matrices
# ============================================================================

B1 = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]], dtype=int)
B2 = np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]], dtype=int)
B3 = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]], dtype=int)

GENERATORS = {'A': B1, 'B': B2, 'C': B3}
ROOT = np.array([3, 4, 5], dtype=int)

def eval_word(word):
    result = ROOT.copy()
    for g in reversed(word):
        result = GENERATORS[g] @ result
    return result

def mat_prod(word):
    """Matrix product: mat_prod(w1 + w2) = mat_prod(w1) @ mat_prod(w2)."""
    result = np.eye(3, dtype=int)
    for g in word:
        result = result @ GENERATORS[g]
    return result

def lcp(u, v):
    result = []
    for a, b in zip(u, v):
        if a == b:
            result.append(a)
        else:
            break
    return ''.join(result)

# ============================================================================
# Demo 1: Freeness
# ============================================================================

def demo_freeness():
    print("=" * 70)
    print("DEMO 1: Freeness of the Berggren Semigroup")
    print("=" * 70)
    print()

    all_triples = {}
    for length in range(1, 4):
        for word_tuple in cart_product('ABC', repeat=length):
            word = ''.join(word_tuple)
            triple = tuple(eval_word(word))
            assert triple not in all_triples, f"Collision: {word} and {all_triples[triple]}"
            all_triples[triple] = word

    total = len(all_triples)
    expected = 3 + 9 + 27
    print(f"Generated {total} words of length 1-3 (expected {expected})")
    print(f"All triples are DISTINCT: {total == expected} ✓")
    print()

    print("Sample triples:")
    for w in ['A', 'B', 'C', 'AB', 'BA', 'ABC']:
        t = eval_word(w)
        assert t[0]**2 + t[1]**2 == t[2]**2
        print(f"  {w:>5s} → ({t[0]}, {t[1]}, {t[2]})  [Pythagorean ✓]")
    print()

# ============================================================================
# Demo 2: Left Divisibility = Prefix Order
# ============================================================================

def demo_divisibility():
    print("=" * 70)
    print("DEMO 2: Left Divisibility ↔ Prefix Order")
    print("=" * 70)
    print()

    test_cases = [
        ("A", "AB"), ("A", "ABC"), ("AB", "ABC"),
        ("B", "ABC"), ("BA", "ABC"), ("A", "A"),
    ]

    print("Word u  | Word v  | Prefix? | Matrix verification")
    print("-" * 60)
    for u, v in test_cases:
        pref = v.startswith(u)
        if pref and u != v:
            w = v[len(u):]
            check = np.array_equal(mat_prod(v), mat_prod(u) @ mat_prod(w))
            print(f"  {u:>5s} | {v:>5s}  | True    | M(v) = M(u)·M({w}): {check} ✓")
        elif u == v:
            print(f"  {u:>5s} | {v:>5s}  | True    | Equal (reflexivity) ✓")
        else:
            print(f"  {u:>5s} | {v:>5s}  | False   | No factorization exists ✗")
    print()

# ============================================================================
# Demo 3: Longest Common Prefix = Greatest Lower Bound
# ============================================================================

def demo_lcp():
    print("=" * 70)
    print("DEMO 3: Longest Common Prefix = Greatest Lower Bound")
    print("=" * 70)
    print()

    test_cases = [
        ("ABCA", "ABBC"), ("ABC", "ABB"), ("AAA", "ABB"),
        ("ABC", "BAC"), ("ABCAB", "ABCBA"),
    ]

    print("Word u    | Word v    | LCP    | GLB in divisibility order")
    print("-" * 65)
    for u, v in test_cases:
        common = lcp(u, v)
        if common:
            assert u.startswith(common) and v.startswith(common)
            print(f"  {u:>7s} | {v:>7s}  | {common:>6s} | {common} divides both ✓")
        else:
            print(f"  {u:>7s} | {v:>7s}  |      ∅ | No common divisor (no identity)")
    print()

# ============================================================================
# Demo 4: Oracle Reduction
# ============================================================================

def demo_oracle_reduction():
    print("=" * 70)
    print("DEMO 4: Oracle Reduction — Prefix Recovery Yields Secret")
    print("=" * 70)
    print()

    A_word = "AB"
    T_word = "CBA"
    AT_word = A_word + T_word

    M_A = mat_prod(A_word)
    M_AT = mat_prod(AT_word)
    M_T = mat_prod(T_word)

    assert np.array_equal(M_AT, M_A @ M_T)
    print(f"Public prefix (A):  '{A_word}'")
    print(f"Secret suffix (T):  '{T_word}'")
    print(f"Combined word (AT): '{AT_word}'")
    print(f"Matrix check: M(AT) = M(A) × M(T) ✓")
    print()

    # Verify uniqueness
    count = 0
    for length in range(1, 5):
        for w in cart_product('ABC', repeat=length):
            candidate = ''.join(w)
            if np.array_equal(M_A @ mat_prod(candidate), M_AT):
                count += 1
                assert candidate == T_word

    print(f"Uniqueness check: exactly {count} suffix matches '{T_word}' ✓")
    print()
    print("THEOREM (proven in Lean): ∃! U, nf(A*T) = nf(A) * U")
    print("The prefix oracle uniquely determines the secret suffix.")
    print()

# ============================================================================
# Demo 5: Visualization
# ============================================================================

def demo_visualization():
    print("=" * 70)
    print("DEMO 5: Generating Visualizations")
    print("=" * 70)
    print()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8))

    # Left: Berggren tree
    ax1.set_title("Berggren Pythagorean Triple Tree", fontsize=14, fontweight='bold')
    ax1.set_xlim(-1, 10)
    ax1.set_ylim(-0.5, 4)
    ax1.axis('off')

    root_pos = (4.5, 3.5)
    ax1.text(*root_pos, "(3,4,5)\nroot", ha='center', va='center',
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue'),
             fontsize=9)

    level1 = {'A': (1.5, 2.3), 'B': (4.5, 2.3), 'C': (7.5, 2.3)}
    colors1 = {'A': '#FFB3BA', 'B': '#BAFFC9', 'C': '#BAE1FF'}

    for gen, pos in level1.items():
        t = eval_word(gen)
        ax1.text(*pos, f"({t[0]},{t[1]},{t[2]})\n{gen}",
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.2', facecolor=colors1[gen]),
                fontsize=8)
        ax1.annotate('', xy=pos, xytext=root_pos,
                    arrowprops=dict(arrowstyle='->', color='gray'))

    level2_x = {
        'AA': 0.2, 'AB': 1.5, 'AC': 2.8,
        'BA': 3.5, 'BB': 4.5, 'BC': 5.5,
        'CA': 6.2, 'CB': 7.5, 'CC': 8.8
    }
    for word, x in level2_x.items():
        t = eval_word(word)
        pos = (x, 1.0)
        parent = word[0]
        ax1.text(*pos, f"({t[0]},{t[1]},{t[2]})",
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.1', facecolor=colors1[parent], alpha=0.5),
                fontsize=6)
        ax1.annotate('', xy=pos, xytext=level1[parent],
                    arrowprops=dict(arrowstyle='->', color='gray', lw=0.5))
        ax1.text(x, 0.6, word, ha='center', fontsize=6, color='gray')

    # Right: Divisibility order
    ax2.set_title("Left-Divisibility = Prefix Order\non Normal Forms", fontsize=14, fontweight='bold')
    ax2.set_xlim(-1, 8)
    ax2.set_ylim(-0.5, 4.5)
    ax2.axis('off')

    word_pos = {
        'A': (1, 3.5), 'B': (3.5, 3.5), 'C': (6, 3.5),
        'AB': (0.5, 2), 'AC': (2, 2), 'BA': (3, 2), 'BC': (4.5, 2),
        'ABC': (1, 0.5), 'ABB': (2.5, 0.5)
    }

    for w, pos in word_pos.items():
        ax2.text(*pos, f"{w}",
                ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', edgecolor='black'),
                fontsize=10, fontweight='bold')

    edges = [
        ('A', 'AB'), ('A', 'AC'),
        ('B', 'BA'), ('B', 'BC'),
        ('AB', 'ABC'), ('AB', 'ABB'),
    ]
    for u, v in edges:
        ax2.annotate('', xy=word_pos[v], xytext=word_pos[u],
                    arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))

    ax2.text(5, 1.5, "LCP(ABC, ABB) = AB\n= Greatest Lower Bound",
            fontsize=10, color='red',
            bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow', edgecolor='red'))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/berggren_tree_and_order.png',
                dpi=150, bbox_inches='tight')
    print("Saved: demos/berggren_tree_and_order.png")
    print()

# ============================================================================
# Run all demos
# ============================================================================

if __name__ == "__main__":
    demo_freeness()
    demo_divisibility()
    demo_lcp()
    demo_oracle_reduction()
    demo_visualization()
    print("All demos completed successfully! ✓")
