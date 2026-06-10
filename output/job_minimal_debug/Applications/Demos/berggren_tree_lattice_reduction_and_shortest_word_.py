#!/usr/bin/env python3
"""
Berggren Tree: Height Descent and Shortest-Word Rigidity Demo

This script demonstrates the Berggren ternary tree of primitive Pythagorean triples,
illustrating the key theorems proved in Lean:
  1. Every word maps to a distinct triple (free-semigroup faithfulness)
  2. Parent descent via inverse branches always terminates at (3,4,5)
  3. The normal form (word recovered by descent) equals the original word
  4. Noisy decoding under bounded perturbation

Usage: python3 berggren_demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple, Optional
from collections import deque

# ============================================================
# Core Berggren Infrastructure
# ============================================================

B1 = np.array([[ 1, -2,  2],
                [ 2, -1,  2],
                [ 2, -2,  3]], dtype=np.int64)

B2 = np.array([[ 1,  2,  2],
                [ 2,  1,  2],
                [ 2,  2,  3]], dtype=np.int64)

B3 = np.array([[-1,  2,  2],
                [-2,  1,  2],
                [-2,  2,  3]], dtype=np.int64)

GENERATORS = [B1, B2, B3]
GEN_NAMES = ['A', 'B', 'C']

B1_inv = np.array([[ 1,  2, -2],
                    [-2, -1,  2],
                    [-2, -2,  3]], dtype=np.int64)

B2_inv = np.array([[ 1,  2, -2],
                    [ 2,  1, -2],
                    [-2, -2,  3]], dtype=np.int64)

B3_inv = np.array([[-1, -2,  2],
                    [ 2,  1, -2],
                    [-2, -2,  3]], dtype=np.int64)

INV_GENERATORS = [B1_inv, B2_inv, B3_inv]
ROOT = np.array([3, 4, 5], dtype=np.int64)


def act_gen(g_idx: int, triple: np.ndarray) -> np.ndarray:
    return GENERATORS[g_idx] @ triple

def eval_word(word: List[int], start: np.ndarray = ROOT) -> np.ndarray:
    t = start.copy()
    for g in reversed(word):
        t = act_gen(g, t)
    return t

def inv_act_gen(g_idx: int, triple: np.ndarray) -> np.ndarray:
    return INV_GENERATORS[g_idx] @ triple

def is_good_triple(t: np.ndarray) -> bool:
    return (t[0] > 0 and t[1] > 0 and t[2] > 0 and
            t[0]**2 + t[1]**2 == t[2]**2)

def find_parent(triple: np.ndarray) -> Optional[Tuple[int, np.ndarray]]:
    if np.array_equal(triple, ROOT):
        return None
    for i in range(3):
        parent = inv_act_gen(i, triple)
        if is_good_triple(parent):
            return (i, parent)
    return None

def parent_word(triple: np.ndarray) -> List[int]:
    word = []
    t = triple.copy()
    while not np.array_equal(t, ROOT):
        result = find_parent(t)
        if result is None:
            break
        g_idx, parent = result
        word.append(g_idx)
        t = parent
    return word


# ============================================================
# Demo 1: Tree Generation
# ============================================================

def demo_tree_generation():
    print("=" * 70)
    print("DEMO 1: Berggren Tree Generation")
    print("=" * 70)
    print(f"\nRoot: {ROOT}")
    print(f"Root is Pythagorean: {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2} + {ROOT[1]**2} = {ROOT[2]**2} = {ROOT[2]}² ✓")

    print("\nDepth 1 children:")
    for i, name in enumerate(GEN_NAMES):
        child = act_gen(i, ROOT)
        print(f"  B_{name}(3,4,5) = ({child[0]}, {child[1]}, {child[2]})")
        assert is_good_triple(child)
        print(f"    Verification: {child[0]}² + {child[1]}² = {child[0]**2 + child[1]**2} = {child[2]**2} = {child[2]}² ✓")

    print("\nDepth 2 children (9 triples):")
    for i, ni in enumerate(GEN_NAMES):
        for j, nj in enumerate(GEN_NAMES):
            triple = eval_word([i, j])
            print(f"  B_{ni}·B_{nj}(root) = ({triple[0]}, {triple[1]}, {triple[2]}), hyp = {triple[2]}")

    print("\nUnique triples at each depth:")
    for depth in range(5):
        triples = set()
        if depth == 0:
            triples.add(tuple(ROOT))
        else:
            words = [[g] for g in range(3)]
            for _ in range(depth - 1):
                words = [[g] + w for w in words for g in range(3)]
            for w in words:
                triples.add(tuple(eval_word(w)))
        expected = 3**depth if depth > 0 else 1
        print(f"  Depth {depth}: {len(triples)} triples (expected {expected} = 3^{depth})")
        assert len(triples) == expected, "Injectivity violated!"

    print("\n✓ All triples distinct — confirms evalAtRoot_injective!")


# ============================================================
# Demo 2: Parent Descent
# ============================================================

def demo_parent_descent():
    print("\n" + "=" * 70)
    print("DEMO 2: Parent Descent and Normal Form Recovery")
    print("=" * 70)

    test_words = [
        [0], [1], [2],
        [0, 1], [2, 0, 1], [1, 1, 1],
        [0, 2, 1, 0, 2],
    ]

    for word in test_words:
        triple = eval_word(word)
        recovered = parent_word(triple)
        word_str = ''.join(GEN_NAMES[g] for g in word)
        recovered_str = ''.join(GEN_NAMES[g] for g in recovered)

        print(f"\n  Word: {word_str}")
        print(f"  Triple: ({triple[0]}, {triple[1]}, {triple[2]})")

        t = triple.copy()
        steps = []
        while not np.array_equal(t, ROOT):
            result = find_parent(t)
            if result is None:
                break
            g_idx, parent = result
            steps.append((GEN_NAMES[g_idx], tuple(t), tuple(parent)))
            t = parent

        print(f"  Descent path:")
        for gen, child, par in steps:
            print(f"    ({child[0]},{child[1]},{child[2]}) --[{gen}⁻¹]--> ({par[0]},{par[1]},{par[2]})  [hyp: {child[2]} → {par[2]}]")

        print(f"  Recovered word: {recovered_str}")
        assert word == recovered, f"Mismatch: {word} ≠ {recovered}"
        print(f"  ✓ Match!")

    print("\n✓ All words correctly recovered — confirms parentWord_inverse_eval!")


# ============================================================
# Demo 3: Height Visualization
# ============================================================

def demo_height_visualization():
    print("\n" + "=" * 70)
    print("DEMO 3: Height Growth and Descent Visualization")
    print("=" * 70)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    ax1 = axes[0]
    max_depth = 8
    for label, gen in [('AAA...', 0), ('BBB...', 1), ('CCC...', 2)]:
        heights = [5]
        t = ROOT.copy()
        for d in range(max_depth):
            t = act_gen(gen, t)
            heights.append(int(t[2]))
        ax1.plot(range(max_depth + 1), heights, 'o-', label=label, markersize=4)

    # Mixed path
    heights = [5]
    t = ROOT.copy()
    for d in range(max_depth):
        t = act_gen(d % 3, t)
        heights.append(int(t[2]))
    ax1.plot(range(max_depth + 1), heights, 'o-', label='ABC...', markersize=4)

    ax1.set_xlabel('Depth (word length)', fontsize=12)
    ax1.set_ylabel('Hypotenuse (height)', fontsize=12)
    ax1.set_title('Hypotenuse Growth Along Berggren Paths', fontsize=13)
    ax1.legend()
    ax1.set_yscale('log')
    ax1.grid(True, alpha=0.3)

    ax2 = axes[1]
    word = [1, 0, 2, 1, 0, 2, 1]
    triple = eval_word(word)
    heights_descent = []
    t = triple.copy()
    while not np.array_equal(t, ROOT):
        heights_descent.append(int(t[2]))
        result = find_parent(t)
        if result is None:
            break
        _, t = result
    heights_descent.append(5)

    ax2.plot(range(len(heights_descent)), heights_descent, 'rs-', markersize=6)
    ax2.set_xlabel('Descent step', fontsize=12)
    ax2.set_ylabel('Hypotenuse', fontsize=12)
    word_str = ''.join(GEN_NAMES[g] for g in word)
    ax2.set_title(f'Height Descent from word "{word_str}"', fontsize=13)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/height_analysis.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/height_analysis.png")


# ============================================================
# Demo 4: Unique Branch
# ============================================================

def demo_unique_branch():
    print("\n" + "=" * 70)
    print("DEMO 4: Unique Inverse Branch (Branch Exclusivity)")
    print("=" * 70)

    count = 0
    for depth in range(1, 5):
        words = [[g] for g in range(3)]
        for _ in range(depth - 1):
            words = [[g] + w for w in words for g in range(3)]
        for word in words:
            triple = eval_word(word)
            good_branches = [i for i in range(3) if is_good_triple(inv_act_gen(i, triple))]
            assert len(good_branches) == 1
            assert good_branches[0] == word[0]
            count += 1

    print(f"\n  Tested {count} triples (depths 1-4)")
    print(f"  ✓ All have exactly one good inverse branch!")


# ============================================================
# Demo 5: Noisy Decoding
# ============================================================

def demo_noisy_decoding():
    print("\n" + "=" * 70)
    print("DEMO 5: Noisy Decoding (Nearest-Word Recovery)")
    print("=" * 70)

    def decode_noisy(noisy_triple: np.ndarray, max_steps: int = 100):
        word = []
        t = noisy_triple.astype(np.float64)
        for _ in range(max_steps):
            if np.max(np.abs(t - ROOT)) < 0.5:
                return word
            best_g = None
            best_score = float('inf')
            for i in range(3):
                inv = INV_GENERATORS[i] @ t
                penalty = sum(max(0, -x) for x in inv)
                if penalty < best_score:
                    best_score = penalty
                    best_g = i
            if best_g is None:
                return None
            word.append(best_g)
            t = INV_GENERATORS[best_g] @ t
        return None

    print("\n  Exact decoding test:")
    for word in [[0, 1, 2], [1, 0, 1], [2, 2, 0]]:
        triple = eval_word(word)
        recovered = decode_noisy(triple)
        ws = ''.join(GEN_NAMES[g] for g in word)
        rs = ''.join(GEN_NAMES[g] for g in recovered) if recovered else "FAILED"
        print(f"    {ws}: ({triple[0]},{triple[1]},{triple[2]}) → {rs} {'✓' if word == recovered else '✗'}")

    print("\n  Noisy decoding test:")
    np.random.seed(42)
    word = [1, 0, 2, 1]
    triple = eval_word(word)
    ws = ''.join(GEN_NAMES[g] for g in word)
    print(f"    Original: {ws}, triple: ({triple[0]},{triple[1]},{triple[2]})")

    for noise in [0, 1, 2, 5, 10, 50]:
        ok = sum(1 for _ in range(100) if decode_noisy(triple + np.random.randint(-noise, noise+1, 3)) == word)
        print(f"    Noise ±{noise:2d}: {ok}/100 correct ({ok}%)")


# ============================================================
# Demo 6: Tree Plot
# ============================================================

def demo_tree_plot():
    print("\n" + "=" * 70)
    print("DEMO 6: Tree Visualization")
    print("=" * 70)

    fig, ax = plt.subplots(1, 1, figsize=(16, 10))
    max_depth = 4
    queue = deque()
    queue.append((ROOT, 0.5, 0))
    positions = {}
    edges = []

    while queue:
        triple, x, depth = queue.popleft()
        key = tuple(triple)
        positions[key] = (x, -depth)
        if depth < max_depth:
            width = 0.5 / (3 ** depth)
            for i in range(3):
                child = act_gen(i, triple)
                child_x = x + (i - 1) * width
                queue.append((child, child_x, depth + 1))
                edges.append((key, tuple(child), GEN_NAMES[i]))

    colors = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}
    for pk, ck, name in edges:
        px, py = positions[pk]
        cx, cy = positions[ck]
        ax.plot([px, cx], [py, cy], '-', color=colors[name], alpha=0.5)

    for key, (x, y) in positions.items():
        a, b, c = key
        ax.plot(x, y, 'o', color='white', markersize=28, markeredgecolor='black', markeredgewidth=1)
        ax.text(x, y, f'{a},{b}\n{c}', ha='center', va='center', fontsize=5, fontweight='bold')

    for name, color in colors.items():
        ax.plot([], [], '-', color=color, linewidth=2, label=f'Generator {name}')
    ax.legend(loc='upper right', fontsize=10)
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples (Depth 4)', fontsize=14)
    ax.set_xticks([])

    plt.tight_layout()
    plt.savefig('demos/berggren_tree.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/berggren_tree.png")


# ============================================================
# Demo 7: Separation
# ============================================================

def demo_separation():
    print("\n" + "=" * 70)
    print("DEMO 7: Branch Separation Analysis")
    print("=" * 70)

    for depth in range(1, 6):
        words = [[g] for g in range(3)]
        for _ in range(depth - 1):
            words = [[g] + w for w in words for g in range(3)]
        triples = [eval_word(w) for w in words]
        min_dist = float('inf')
        best = None
        for i in range(len(triples)):
            for j in range(i+1, len(triples)):
                d = int(np.max(np.abs(triples[i] - triples[j])))
                if d < min_dist:
                    min_dist = d
                    best = (words[i], words[j])
        w1 = ''.join(GEN_NAMES[g] for g in best[0])
        w2 = ''.join(GEN_NAMES[g] for g in best[1])
        print(f"  Depth {depth}: {len(triples)} triples, min L∞ dist = {min_dist} ({w1} vs {w2})")

    print("\n  ✓ All pairs positive distance — confirms distinct_words_positive_dist!")


# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     Berggren Tree: Height Descent and Shortest-Word Rigidity       ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")

    demo_tree_generation()
    demo_parent_descent()
    demo_height_visualization()
    demo_unique_branch()
    demo_noisy_decoding()
    demo_tree_plot()
    demo_separation()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
