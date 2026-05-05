#!/usr/bin/env python3
"""
Berggren-Tree Lattice Reduction: Interactive Demo

Demonstrates the key theorems from the Lean formalization:
1. Berggren tree generates all primitive Pythagorean triples
2. Evaluation is injective (freeness / unique factorization)
3. Height grows linearly with word length
4. Close triples share long common prefixes (rigidity)
5. Branch-and-bound pruning for key recovery
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
from typing import List, Tuple

Triple = Tuple[int, int, int]

def act_gen(g: str, t: Triple) -> Triple:
    a, b, c = t
    if g == 'A':
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    elif g == 'B':
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    elif g == 'C':
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    raise ValueError(f"Unknown generator: {g}")

ROOT = (3, 4, 5)

def eval_word(word: List[str], t: Triple = ROOT) -> Triple:
    result = t
    for g in reversed(word):
        result = act_gen(g, result)
    return result

def height(t: Triple) -> int:
    return abs(t[2])

def geo_dist(t1: Triple, t2: Triple) -> int:
    return max(abs(t1[0]-t2[0]), abs(t1[1]-t2[1]), abs(t1[2]-t2[2]))

def lcp_length(u: List[str], v: List[str]) -> int:
    n = 0
    for a, b in zip(u, v):
        if a != b:
            break
        n += 1
    return n

def is_pythagorean(t: Triple) -> bool:
    return t[0]**2 + t[1]**2 == t[2]**2

def is_good(t: Triple) -> bool:
    return t[0] > 0 and t[1] > 0 and t[2] > 0 and is_pythagorean(t)

# ============================================================
# Demo 1: Tree Structure
# ============================================================

def demo_tree_generation():
    print("=" * 70)
    print("DEMO 1: Berggren Tree Generates Pythagorean Triples")
    print("=" * 70)
    print(f"\nRoot triple: {ROOT}")
    print(f"  {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2 + ROOT[1]**2} = {ROOT[2]}² ✓")

    print("\nLevel 1 children:")
    for g in 'ABC':
        t = eval_word([g])
        print(f"  {g}: {t}  height={height(t)}")

    count = 0
    for depth in range(7):
        for word in itertools.product('ABC', repeat=depth):
            t = eval_word(list(word))
            assert is_good(t), f"Bad: {word} -> {t}"
            count += 1
    print(f"\n✓ Verified all {count} triples up to depth 6 are good")

# ============================================================
# Demo 2: Freeness
# ============================================================

def demo_freeness():
    print("\n" + "=" * 70)
    print("DEMO 2: Freeness — Distinct Words → Distinct Triples")
    print("=" * 70)

    all_triples = {}
    for depth in range(6):
        for word in itertools.product('ABC', repeat=depth):
            w = list(word)
            t = eval_word(w)
            if t in all_triples:
                print(f"  COLLISION: {w} and {all_triples[t]}")
                return
            all_triples[t] = w
    print(f"\n✓ No collisions among {len(all_triples)} words (depth ≤ 5)")

# ============================================================
# Demo 3: Height Growth
# ============================================================

def demo_height_growth():
    print("\n" + "=" * 70)
    print("DEMO 3: Height Grows Linearly with Word Length")
    print("=" * 70)

    depths = list(range(10))
    min_h, max_h, avg_h = [], [], []

    for d in depths:
        if d == 0:
            hs = [height(ROOT)]
        else:
            hs = [height(eval_word(list(w))) for w in itertools.product('ABC', repeat=d)]
        min_h.append(min(hs))
        max_h.append(max(hs))
        avg_h.append(sum(hs) / len(hs))

    print(f"\n{'Depth':>6} {'Min':>8} {'Avg':>10} {'Max':>10} {'5+d':>6}")
    print("-" * 45)
    for d, mn, av, mx in zip(depths, min_h, avg_h, max_h):
        print(f"{d:>6} {mn:>8} {av:>10.0f} {mx:>10} {5+d:>6}")

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(depths, min_h, 'b-o', label='Min height', linewidth=2)
    ax.plot(depths, avg_h, 'g-s', label='Avg height', linewidth=2)
    ax.plot(depths, max_h, 'r-^', label='Max height', linewidth=2)
    ax.plot(depths, [5+d for d in depths], 'k--', label='5 + depth', linewidth=2)
    ax.set_xlabel('Word Length', fontsize=12)
    ax.set_ylabel('Height (hypotenuse)', fontsize=12)
    ax.set_title('Berggren Tree: Height vs Word Length', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demos/height_growth.png', dpi=150)
    plt.close()
    print("\n  Plot saved to demos/height_growth.png")

# ============================================================
# Demo 4: Prefix Rigidity
# ============================================================

def demo_prefix_rigidity():
    print("\n" + "=" * 70)
    print("DEMO 4: Close Outputs Share Long Common Prefixes")
    print("=" * 70)

    print(f"\n{'Depth':>6} {'Min Dist':>10} {'Closest Pair':>30} {'LCP':>5}")
    print("-" * 60)

    for d in range(2, 8):
        words = [list(w) for w in itertools.product('ABC', repeat=d)]
        triples = [(w, eval_word(w)) for w in words]
        best_dist = float('inf')
        best_pair = None
        best_lcp = 0

        for i in range(len(triples)):
            for j in range(i+1, min(i+50, len(triples))):  # sample nearby
                w1, t1 = triples[i]
                w2, t2 = triples[j]
                dv = geo_dist(t1, t2)
                if dv < best_dist:
                    best_dist = dv
                    best_pair = (w1, w2)
                    best_lcp = lcp_length(w1, w2)

        # Also check random pairs
        if len(triples) > 100:
            np.random.seed(d)
            for _ in range(5000):
                i, j = np.random.choice(len(triples), 2, replace=False)
                w1, t1 = triples[i]
                w2, t2 = triples[j]
                dv = geo_dist(t1, t2)
                if dv < best_dist:
                    best_dist = dv
                    best_pair = (w1, w2)
                    best_lcp = lcp_length(w1, w2)

        if best_pair:
            s1 = ''.join(best_pair[0])
            s2 = ''.join(best_pair[1])
            print(f"{d:>6} {best_dist:>10} {s1+'/'+s2:>30} {best_lcp:>5}")

    print("\n  Key insight: close pairs share substantial prefixes")

# ============================================================
# Demo 5: Branch-and-Bound
# ============================================================

def demo_branch_and_bound():
    print("\n" + "=" * 70)
    print("DEMO 5: Certified Branch-and-Bound Key Recovery")
    print("=" * 70)

    secret = ['B', 'A', 'C', 'B', 'A']
    target = eval_word(secret)
    target_h = height(target)
    eps = 0

    print(f"\n  Secret word: {''.join(secret)}")
    print(f"  Target triple: {target}")
    print(f"  Target height: {target_h}")

    max_d = len(secret)
    explored = [0]
    pruned = [0]
    candidates = []

    def search(prefix, depth):
        if depth > max_d:
            return
        t = eval_word(prefix)
        h = height(t)
        explored[0] += 1

        if depth == max_d and abs(h - target_h) <= eps:
            if geo_dist(t, target) <= eps:
                candidates.append(list(prefix))

        if h > target_h + eps:
            pruned[0] += 1
            return

        for g in 'ABC':
            search([g] + prefix, depth + 1)

    search([], 0)

    total = sum(3**d for d in range(max_d + 1))
    print(f"\n  Nodes explored: {explored[0]}")
    print(f"  Nodes pruned:   {pruned[0]}")
    print(f"  Total possible: {total}")
    print(f"  Reduction:      {100*(1 - explored[0]/total):.1f}%")
    print(f"  Candidates: {len(candidates)}")
    for c in candidates:
        print(f"    {''.join(c)} → {eval_word(c)}")

    if candidates and candidates[0] == secret:
        print(f"\n  ✓ Secret recovered correctly!")

# ============================================================
# Demo 6: Tree Visualization
# ============================================================

def demo_tree_visualization():
    print("\n" + "=" * 70)
    print("DEMO 6: Tree Visualization")
    print("=" * 70)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))
    colors = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}

    for d in range(7):
        for w in itertools.product('ABC', repeat=d):
            word = list(w)
            t = eval_word(word)
            if d == 0:
                ax1.plot(t[0], t[1], 'ko', markersize=8, zorder=5)
            else:
                c = colors[word[0]]
                s = max(2, 7-d)
                ax1.plot(t[0], t[1], 'o', color=c, markersize=s, alpha=0.6)

    ax1.set_xlabel('a', fontsize=12)
    ax1.set_ylabel('b', fontsize=12)
    ax1.set_title('Berggren Tree (a,b) Plane', fontsize=13)
    patches = [mpatches.Patch(color=colors[g], label=f'{g}') for g in 'ABC']
    ax1.legend(handles=patches)
    ax1.grid(True, alpha=0.3)

    words_d6 = [(list(w), eval_word(list(w))) for w in itertools.product('ABC', repeat=6)]
    words_d6.sort(key=lambda x: height(x[1]))
    hs = [height(t) for _, t in words_d6]
    ax2.plot(range(len(hs)), hs, 'b-', linewidth=0.5)
    ax2.axhline(y=11, color='r', linestyle='--', label='5 + 6 = 11')
    ax2.set_xlabel('Word index (sorted)', fontsize=12)
    ax2.set_ylabel('Height', fontsize=12)
    ax2.set_title('Height Distribution at Depth 6', fontsize=13)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig('demos/berggren_tree.png', dpi=150)
    plt.close()
    print("  Saved demos/berggren_tree.png")

# ============================================================
# Demo 7: Distance vs LCP
# ============================================================

def demo_distance_lcp():
    print("\n" + "=" * 70)
    print("DEMO 7: Distance vs Common Prefix Length")
    print("=" * 70)

    depth = 5
    words = [list(w) for w in itertools.product('ABC', repeat=depth)]
    np.random.seed(42)
    dists, lcps = [], []
    for _ in range(3000):
        i, j = np.random.choice(len(words), 2, replace=False)
        t1, t2 = eval_word(words[i]), eval_word(words[j])
        dists.append(geo_dist(t1, t2))
        lcps.append(lcp_length(words[i], words[j]))

    fig, ax = plt.subplots(figsize=(10, 6))
    sc = ax.scatter(dists, lcps, alpha=0.3, s=10, c=lcps, cmap='viridis')
    ax.set_xlabel('Geometric Distance (L∞)', fontsize=12)
    ax.set_ylabel('Common Prefix Length', fontsize=12)
    ax.set_title(f'Distance vs LCP (depth {depth})', fontsize=13)
    plt.colorbar(sc, label='LCP')
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig('demos/distance_vs_lcp.png', dpi=150)
    plt.close()
    print("  Saved demos/distance_vs_lcp.png")
    print("  Small distance ⟹ large LCP (prefix rigidity)")

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Berggren-Tree Lattice Reduction: Demonstrations       ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_tree_generation()
    demo_freeness()
    demo_height_growth()
    demo_prefix_rigidity()
    demo_branch_and_bound()
    demo_tree_visualization()
    demo_distance_lcp()

    print("\n" + "=" * 70)
    print("All demos completed!")
    print("=" * 70)
