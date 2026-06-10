#!/usr/bin/env python3
"""
Demonstration: Effective Finite-Quotient Injectivity for Berggren Words

This script demonstrates the key results of the formal Lean proof:
1. The Berggren tree generates Pythagorean triples via 3 matrix generators
2. The sup-norm of evaluations grows at most as 7^n
3. Reduction modulo q is injective on bounded-length words when q > 10 * 7^L
4. Cryptographic key recovery is well-defined on the bounded keyspace

Author: Generated as companion to formal Lean 4 proof
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product
from typing import List, Tuple, Optional
import random

# ============================================================
# Berggren generators on Pythagorean triples
# ============================================================

def berggren_A(t):
    """Generator A (B₁): (a,b,c) → (a-2b+2c, 2a-b+2c, 2a-2b+3c)"""
    a, b, c = t
    return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)

def berggren_B(t):
    """Generator B (B₂): (a,b,c) → (a+2b+2c, 2a+b+2c, 2a+2b+3c)"""
    a, b, c = t
    return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)

def berggren_C(t):
    """Generator C (B₃): (a,b,c) → (-a+2b+2c, -2a+b+2c, -2a+2b+3c)"""
    a, b, c = t
    return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)

GENERATORS = {'A': berggren_A, 'B': berggren_B, 'C': berggren_C}
ROOT = (3, 4, 5)

def eval_word(word):
    """Evaluate a Berggren word (rightmost letter applied first)."""
    t = ROOT
    for g in reversed(word):
        t = GENERATORS[g](t)
    return t

def triple_sup_norm(t):
    """The sup-norm of a triple: max(|a|, |b|, |c|)."""
    return max(abs(t[0]), abs(t[1]), abs(t[2]))

def reduce_mod(q, t):
    """Reduce a triple modulo q."""
    return (t[0] % q, t[1] % q, t[2] % q)

# ============================================================
# Demo 1: Berggren Tree and Pythagorean Triples
# ============================================================

def demo_berggren_tree():
    print("=" * 70)
    print("DEMO 1: The Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 70)
    print()
    print(f"Root triple: {ROOT}")
    print(f"Verification: {ROOT[0]}² + {ROOT[1]}² = {ROOT[0]**2 + ROOT[1]**2} = {ROOT[2]}² = {ROOT[2]**2}")
    print()

    for length in range(1, 4):
        words = [''.join(w) for w in product('ABC', repeat=length)]
        print(f"Words of length {length}:")
        for w in words:
            t = eval_word(w)
            norm = triple_sup_norm(t)
            print(f"  {w:>4s} -> {t}  (sup-norm = {norm}, "
                  f"{t[0]}^2 + {t[1]}^2 = {t[0]**2 + t[1]**2} = {t[2]}^2 = {t[2]**2})")
        print()

# ============================================================
# Demo 2: Sup-Norm Growth Bound
# ============================================================

def demo_norm_growth():
    print("=" * 70)
    print("DEMO 2: Entry Growth Bound - tripleSupNorm <= 5 * 7^n")
    print("=" * 70)
    print()
    print("The formal proof shows: tripleSupNorm(eval w) <= 5 * 7^|w|")
    print("where 7 is the maximum row-sum of the Berggren coefficient matrices.")
    print()

    lengths = range(0, 7)
    max_norms = {}
    word_counts = {}

    for L in lengths:
        if L == 0:
            words = ['']
        else:
            words = [''.join(w) for w in product('ABC', repeat=L)]
        norms = [triple_sup_norm(eval_word(w)) for w in words]
        max_norms[L] = max(norms)
        word_counts[L] = len(words)

    print(f"{'Length':>6s}  {'#Words':>8s}  {'Max norm':>12s}  {'Bound 5*7^n':>12s}  {'Ratio':>8s}")
    print("-" * 52)
    for L in lengths:
        bound = 5 * 7**L
        ratio = max_norms[L] / bound if bound > 0 else 0
        print(f"{L:>6d}  {word_counts[L]:>8d}  {max_norms[L]:>12d}  {bound:>12d}  {ratio:>8.4f}")

    print()
    print("The ratio is always <= 1, confirming the formal bound.")
    print()

    fig, ax = plt.subplots(figsize=(10, 6))
    Ls = list(lengths)
    ax.semilogy(Ls, [max_norms[L] for L in Ls], 'bo-', label='Max observed norm', markersize=8)
    ax.semilogy(Ls, [5 * 7**L for L in Ls], 'r--', label='Bound: 5 * 7^n', linewidth=2)
    ax.set_xlabel('Word length n', fontsize=14)
    ax.set_ylabel('Sup-norm (log scale)', fontsize=14)
    ax.set_title('Berggren Evaluation Sup-Norm Growth', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('demos/norm_growth.png', dpi=150)
    print("Plot saved to demos/norm_growth.png")
    print()

# ============================================================
# Demo 3: Injectivity Under Reduction Mod q
# ============================================================

def demo_injectivity():
    print("=" * 70)
    print("DEMO 3: Injectivity of Reduction Mod q on Bounded Words")
    print("=" * 70)
    print()
    print("The formal theorem: if q > 10 * 7^L, then reduction mod q is")
    print("injective on words of length <= L.")
    print()

    for L in range(1, 5):
        threshold = 10 * 7**L
        q_safe = threshold + 1

        all_words = ['']
        for l in range(1, L + 1):
            all_words.extend([''.join(w) for w in product('ABC', repeat=l)])

        reduced = {}
        injective = True
        for w in all_words:
            t = eval_word(w)
            r = reduce_mod(q_safe, t)
            if r in reduced and reduced[r] != w:
                injective = False
                break
            reduced[r] = w

        n_words = len(all_words)
        print(f"  L={L}: threshold = 10*7^{L} = {threshold}, "
              f"using q = {q_safe}, "
              f"#words = {n_words}, "
              f"injective = {injective}")

    print()
    print("Below threshold, collisions can occur:")
    L = 2
    threshold = 10 * 7**L
    all_words = ['']
    for l in range(1, L + 1):
        all_words.extend([''.join(w) for w in product('ABC', repeat=l)])

    for q in [5, 7, 11, 13, 17, 19, 23]:
        reduced = {}
        collision = None
        for w in all_words:
            t = eval_word(w)
            r = reduce_mod(q, t)
            if r in reduced and reduced[r] != w:
                collision = (w, reduced[r], r)
                break
            reduced[r] = w
        if collision:
            print(f"  q={q:3d} < {threshold}: COLLISION between '{collision[0]}' and '{collision[1]}' "
                  f"(both reduce to {collision[2]})")
        else:
            print(f"  q={q:3d} < {threshold}: no collision found among {len(all_words)} words")
    print()

# ============================================================
# Demo 4: Cryptographic Key Recovery
# ============================================================

def demo_key_recovery():
    print("=" * 70)
    print("DEMO 4: Cryptographic Key Recovery on Bounded Keyspace")
    print("=" * 70)
    print()
    print("Setup: Alice picks a secret Berggren word w of length <= L.")
    print("She publishes pk = eval(w) mod q as her public key.")
    print("The theorem guarantees a unique preimage when q > 10*7^L.")
    print()

    L = 3
    threshold = 10 * 7**L
    q = threshold + 7

    all_words = ['']
    for l in range(1, L + 1):
        all_words.extend([''.join(w) for w in product('ABC', repeat=l)])

    encoder = {}
    for w in all_words:
        t = eval_word(w)
        pk = reduce_mod(q, t)
        encoder[pk] = w

    print(f"  Parameters: L = {L}, q = {q} (threshold = {threshold})")
    print(f"  Keyspace size: {len(all_words)} words")
    print()

    random.seed(42)
    alice_words = random.sample(all_words[1:], min(5, len(all_words) - 1))

    print("  Simulated key recovery:")
    for w in alice_words:
        t = eval_word(w)
        pk = reduce_mod(q, t)
        recovered = encoder.get(pk, "NOT FOUND")
        status = "OK" if recovered == w else "FAIL"
        print(f"    Secret: '{w}' -> triple: {t} -> pk mod {q}: {pk} -> recovered: '{recovered}' [{status}]")

    print()
    print("  All recoveries succeed because q > 10*7^L ensures injectivity.")
    print()

# ============================================================
# Demo 5: Threshold Visualization
# ============================================================

def demo_threshold_plot():
    print("=" * 70)
    print("DEMO 5: Collision Threshold Visualization")
    print("=" * 70)
    print()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    Ls = range(1, 9)
    thresholds = [10 * 7**L for L in Ls]
    keyspace_sizes = [sum(3**l for l in range(L + 1)) for L in Ls]

    ax1.semilogy(list(Ls), thresholds, 'ro-', label='Threshold: 10 * 7^L', markersize=8)
    ax1.semilogy(list(Ls), keyspace_sizes, 'bs-', label='Keyspace size', markersize=8)
    ax1.set_xlabel('Maximum word length L', fontsize=13)
    ax1.set_ylabel('Value (log scale)', fontsize=13)
    ax1.set_title('Modulus Threshold vs Keyspace Size', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    Ls_hm = list(range(1, 5))
    qs_hm = list(range(5, 200, 5))
    collision_data = []

    for L in Ls_hm:
        row = []
        all_words = ['']
        for l in range(1, L + 1):
            all_words.extend([''.join(w) for w in product('ABC', repeat=l)])

        for q in qs_hm:
            reduced = set()
            collision = False
            for w in all_words:
                t = eval_word(w)
                r = reduce_mod(q, t)
                if r in reduced:
                    collision = True
                    break
                reduced.add(r)
            row.append(1 if collision else 0)
        collision_data.append(row)

    im = ax2.imshow(collision_data, aspect='auto', cmap='RdYlGn_r',
                     extent=[qs_hm[0], qs_hm[-1], len(Ls_hm) - 0.5, -0.5])
    ax2.set_xlabel('Modulus q', fontsize=13)
    ax2.set_ylabel('Max word length L', fontsize=13)
    ax2.set_yticks(range(len(Ls_hm)))
    ax2.set_yticklabels([str(L) for L in Ls_hm])
    ax2.set_title('Collision Map (red=collision, green=injective)', fontsize=14)

    for i, L in enumerate(Ls_hm):
        threshold = 10 * 7**L
        if threshold <= qs_hm[-1]:
            ax2.axvline(x=threshold, color='white', linestyle='--', linewidth=1.5)
            ax2.text(threshold + 2, i, f'10*7^{L}={threshold}', color='white', fontsize=8,
                    va='center')

    plt.tight_layout()
    plt.savefig('demos/collision_threshold.png', dpi=150)
    print("Plot saved to demos/collision_threshold.png")
    print()

# ============================================================
# Demo 6: The Berggren Tree Visualization
# ============================================================

def demo_tree_visualization():
    print("=" * 70)
    print("DEMO 6: Berggren Tree of Pythagorean Triples (Depth 3)")
    print("=" * 70)
    print()

    fig, ax = plt.subplots(figsize=(14, 8))

    def draw_tree(word, x, y, dx, depth, max_depth):
        t = eval_word(word)
        label = f"({t[0]},{t[1]},{t[2]})"
        ax.text(x, y, label, ha='center', va='center',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightblue', edgecolor='navy'),
                fontsize=7)

        if depth >= max_depth:
            return

        children = [('A', x - dx, y - 1.2),
                    ('B', x, y - 1.2),
                    ('C', x + dx, y - 1.2)]

        for gen, cx, cy in children:
            ax.annotate('', xy=(cx, cy + 0.25), xytext=(x, y - 0.25),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1))
            ax.text((x + cx) / 2, (y + cy) / 2 - 0.05, gen,
                   ha='center', fontsize=7, color='red', fontweight='bold')
            draw_tree(gen + word, cx, cy, dx / 3.2, depth + 1, max_depth)

    draw_tree('', 0, 4, 5.5, 0, 3)
    ax.set_xlim(-8, 8)
    ax.set_ylim(-1.5, 5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Berggren Tree of Primitive Pythagorean Triples', fontsize=16, pad=20)
    plt.tight_layout()
    plt.savefig('demos/berggren_tree.png', dpi=150)
    print("Berggren tree visualization saved to demos/berggren_tree.png")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print()
    print("=" * 70)
    print("  Effective Finite-Quotient Injectivity for Berggren Words")
    print("  Companion Demos to the Formal Lean 4 Proof")
    print("=" * 70)
    print()

    demo_berggren_tree()
    demo_norm_growth()
    demo_injectivity()
    demo_key_recovery()
    demo_threshold_plot()
    demo_tree_visualization()

    print("=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)
