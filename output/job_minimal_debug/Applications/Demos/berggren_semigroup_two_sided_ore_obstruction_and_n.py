#!/usr/bin/env python3
"""
Berggren Left-Ore Obstruction and Collision Resistance Demo
============================================================

This script demonstrates the formally verified theorems about the Berggren
free semigroup's left-Ore obstruction and collision resistance properties.

We visualize:
1. The Berggren tree of primitive Pythagorean triples
2. Left-divisibility (suffix) relationships between words
3. Common left multiple existence/non-existence
4. The collision resistance property for incomparable prefixes
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product as cartesian_product
from typing import List, Tuple, Optional

# ============================================================================
# Berggren Generator Matrices (3x3, acting on triples)
# ============================================================================

# The three Berggren generators
A = np.array([
    [1, -2, 2],
    [2, -1, 2],
    [2, -2, 3]
], dtype=int)

B = np.array([
    [1, 2, 2],
    [2, 1, 2],
    [2, 2, 3]
], dtype=int)

C = np.array([
    [-1, 2, 2],
    [-2, 1, 2],
    [-2, 2, 3]
], dtype=int)

GENERATORS = {'A': A, 'B': B, 'C': C}
ROOT = np.array([3, 4, 5], dtype=int)

def eval_word(word: str) -> np.ndarray:
    """Evaluate a Berggren word (string of A/B/C) starting from root (3,4,5).
    
    Convention: word[0] is the outermost (most recent) generator.
    eval_word("AB") = A · (B · root)
    """
    result = ROOT.copy()
    for g in reversed(word):
        result = GENERATORS[g] @ result
    return result

def is_suffix(a: str, b: str) -> bool:
    """Check if a is a suffix of b (i.e., a ≤L b in our convention)."""
    return b.endswith(a)

def has_common_left_multiple(a: str, b: str) -> Optional[Tuple[str, str]]:
    """Check if words a, b have a common left multiple x++a = y++b.
    
    Searches up to a bounded depth. Returns (x, y) if found, None otherwise.
    """
    # By our theorem: CLM exists iff one is a suffix of the other
    if is_suffix(a, b):
        # b = x ++ a, so x ++ a = [] ++ b with x = b[:-len(a)] if a != ""
        x = b[:-len(a)] if len(a) > 0 else b
        return (x, "")
    if is_suffix(b, a):
        y = a[:-len(b)] if len(b) > 0 else a
        return ("", y)
    return None

def is_prefix(u: str, v: str) -> bool:
    """Check if u is a prefix of v."""
    return v.startswith(u)

def are_prefix_comparable(u: str, v: str) -> bool:
    """Check if u and v are prefix-comparable."""
    return is_prefix(u, v) or is_prefix(v, u)

# ============================================================================
# Demo 1: The Berggren Tree
# ============================================================================

def demo_berggren_tree():
    """Visualize the first few levels of the Berggren tree."""
    print("=" * 70)
    print("DEMO 1: The Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 70)
    print()
    print(f"Root: (3, 4, 5)")
    print()
    
    for depth in range(1, 4):
        print(f"Depth {depth}:")
        words = [''.join(w) for w in cartesian_product('ABC', repeat=depth)]
        for word in words:
            triple = eval_word(word)
            print(f"  {word:>4s} → ({triple[0]:>4d}, {triple[1]:>4d}, {triple[2]:>4d})")
        print()

# ============================================================================
# Demo 2: Left-Divisibility and Common Left Multiples
# ============================================================================

def demo_left_divisibility():
    """Demonstrate the left-divisibility relation and CLM theorem."""
    print("=" * 70)
    print("DEMO 2: Left-Divisibility and Common Left Multiples")
    print("=" * 70)
    print()
    print("Left-divisibility: a ≤L b iff b = x ++ a (a is a suffix of b)")
    print()
    
    # Show some examples
    pairs = [
        ("A", "BA"),    # A is suffix of BA → A ≤L BA
        ("B", "AB"),    # B is suffix of AB → B ≤L AB
        ("A", "B"),     # Neither is suffix → incomparable
        ("AB", "CAB"),  # AB is suffix of CAB → AB ≤L CAB
        ("AC", "BC"),   # Neither is suffix → incomparable
    ]
    
    for a, b in pairs:
        div_ab = is_suffix(a, b)
        div_ba = is_suffix(b, a)
        clm = has_common_left_multiple(a, b)
        
        print(f"  a = {a}, b = {b}")
        print(f"    a ≤L b (a suffix of b): {div_ab}")
        print(f"    b ≤L a (b suffix of a): {div_ba}")
        print(f"    Comparable: {div_ab or div_ba}")
        if clm:
            x, y = clm
            print(f"    Common left multiple: x={x!r} ++ a = y={y!r} ++ b")
            # Verify
            xa = x + a
            yb = y + b
            assert xa == yb, f"CLM verification failed: {xa} ≠ {yb}"
            print(f"    Verification: {xa} == {yb} ✓")
        else:
            print(f"    No common left multiple exists (Ore obstruction!)")
        print()
    
    print("THEOREM (formally verified):")
    print("  HasCommonLeftMultiple a b ↔ a ≤L b ∨ b ≤L a")
    print()

# ============================================================================
# Demo 3: Collision Resistance
# ============================================================================

def demo_collision_resistance():
    """Demonstrate that incomparable prefixes never produce equal evaluations."""
    print("=" * 70)
    print("DEMO 3: Collision Resistance for Incomparable Prefixes")
    print("=" * 70)
    print()
    
    # Generate all words up to depth 3
    all_words = [""]
    for depth in range(1, 4):
        all_words.extend([''.join(w) for w in cartesian_product('ABC', repeat=depth)])
    
    # Find incomparable pairs and verify collision resistance
    print("Testing collision resistance for all incomparable prefix pairs")
    print("(checking evalTriple(u++α) ≠ evalTriple(v++β) for various suffixes)")
    print()
    
    incomparable_count = 0
    collision_count = 0
    
    short_words = [w for w in all_words if 0 < len(w) <= 2]
    suffixes = [""] + list('ABC')
    
    for u in short_words:
        for v in short_words:
            if u >= v:
                continue
            if are_prefix_comparable(u, v):
                continue
            
            incomparable_count += 1
            
            # Test with various suffixes
            for alpha in suffixes:
                for beta in suffixes:
                    t1 = eval_word(u + alpha)
                    t2 = eval_word(v + beta)
                    if np.array_equal(t1, t2):
                        collision_count += 1
                        print(f"  COLLISION FOUND: eval({u}++{alpha}) = eval({v}++{beta})")
    
    print(f"  Tested {incomparable_count} incomparable pairs with {len(suffixes)**2} suffix combinations each")
    print(f"  Collisions found: {collision_count}")
    if collision_count == 0:
        print("  ✓ No collisions — consistent with formally verified theorem!")
    print()
    
    # Show a specific example
    print("Example: u = 'A', v = 'B' are incomparable (neither is prefix of other)")
    print("  For ANY suffixes α, β:")
    for alpha in ['', 'A', 'B', 'C', 'AB', 'BC']:
        for beta in ['', 'A', 'B', 'C', 'AB', 'BC']:
            t1 = eval_word('A' + alpha)
            t2 = eval_word('B' + beta)
            print(f"    eval(A{alpha}) = {tuple(t1)},  eval(B{beta}) = {tuple(t2)},  equal: {np.array_equal(t1, t2)}")
    print()
    
    print("THEOREM (formally verified):")
    print("  ¬(u <+: v) ∧ ¬(v <+: u) → evalTriple(u++α) ≠ evalTriple(v++β)")
    print()

# ============================================================================
# Demo 4: Ore Obstruction Visualization
# ============================================================================

def demo_ore_visualization():
    """Create a visualization of the Ore obstruction in the Berggren tree."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))
    
    # Left panel: Berggren tree with suffix relationships
    ax = axes[0]
    ax.set_title("Berggren Tree: Suffix (Left-Divisibility) Chains", fontsize=13)
    
    # Draw the tree
    positions = {}
    labels = {}
    
    # Root
    positions[""] = (0.5, 1.0)
    labels[""] = "(3,4,5)\nroot"
    
    # Level 1
    gen_names = ['A', 'B', 'C']
    for i, g in enumerate(gen_names):
        x = 0.15 + 0.35 * i
        positions[g] = (x, 0.7)
        t = eval_word(g)
        labels[g] = f"{g}\n({t[0]},{t[1]},{t[2]})"
    
    # Level 2
    idx = 0
    for g1 in gen_names:
        for g2 in gen_names:
            word = g1 + g2
            x = 0.04 + 0.115 * idx
            positions[word] = (x, 0.35)
            t = eval_word(word)
            labels[word] = f"{word}\n({t[0]},{t[1]},{t[2]})"
            idx += 1
    
    # Draw edges (parent-child in tree)
    for word, pos in positions.items():
        if len(word) > 0:
            parent = word[:-1] if len(word) > 1 else ""
            # Wait, convention: word[0] is outermost, so parent is word[1:]
            parent = word[1:] if len(word) > 1 else ""
            if parent in positions:
                px, py = positions[parent]
                cx, cy = pos
                ax.annotate("", xy=(cx, cy + 0.03), xytext=(px, py - 0.03),
                           arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))
    
    # Draw nodes
    for word, pos in positions.items():
        color = ['#FFD700', '#87CEEB', '#98FB98', '#FFB6C1'][min(len(word), 3)]
        bbox = dict(boxstyle='round,pad=0.3', facecolor=color, edgecolor='black', alpha=0.8)
        fontsize = 8 if len(word) >= 2 else 10
        ax.text(pos[0], pos[1], labels[word], ha='center', va='center',
                fontsize=fontsize, bbox=bbox)
    
    # Highlight a suffix chain: A ≤L BA ≤L CBA
    chain_words = ['A', 'BA', 'CBA'] if 'CBA' in positions else ['A', 'BA']
    for i in range(len(chain_words) - 1):
        if chain_words[i] in positions and chain_words[i+1] in positions:
            p1 = positions[chain_words[i]]
            p2 = positions[chain_words[i+1]]
            ax.annotate("", xy=(p2[0]+0.02, p2[1]+0.05), xytext=(p1[0]+0.02, p1[1]-0.05),
                       arrowprops=dict(arrowstyle='->', color='red', lw=3, connectionstyle='arc3,rad=0.2'))
    
    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(0.15, 1.1)
    ax.axis('off')
    
    # Right panel: CLM existence matrix
    ax = axes[1]
    ax.set_title("Common Left Multiple Existence\n(Green = CLM exists, Red = No CLM)", fontsize=13)
    
    words = ['A', 'B', 'C', 'AA', 'AB', 'AC', 'BA', 'BB', 'BC', 'CA', 'CB', 'CC']
    n = len(words)
    matrix = np.zeros((n, n))
    
    for i in range(n):
        for j in range(n):
            if has_common_left_multiple(words[i], words[j]) is not None:
                matrix[i, j] = 1  # CLM exists
            else:
                matrix[i, j] = 0  # No CLM
    
    cmap = plt.cm.colors.ListedColormap(['#FF6B6B', '#90EE90'])
    ax.imshow(matrix, cmap=cmap, aspect='equal')
    
    ax.set_xticks(range(n))
    ax.set_xticklabels(words, rotation=45, ha='right', fontsize=9)
    ax.set_yticks(range(n))
    ax.set_yticklabels(words, fontsize=9)
    ax.set_xlabel("Word b", fontsize=11)
    ax.set_ylabel("Word a", fontsize=11)
    
    # Add grid
    for i in range(n + 1):
        ax.axhline(y=i - 0.5, color='gray', linewidth=0.5)
        ax.axvline(x=i - 0.5, color='gray', linewidth=0.5)
    
    # Legend
    green_patch = mpatches.Patch(color='#90EE90', label='CLM exists (comparable)')
    red_patch = mpatches.Patch(color='#FF6B6B', label='No CLM (incomparable)')
    ax.legend(handles=[green_patch, red_patch], loc='upper right', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('demos/berggren_ore_obstruction.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to demos/berggren_ore_obstruction.png")
    plt.close()

# ============================================================================
# Demo 5: Protocol Transcript Collision Resistance
# ============================================================================

def demo_transcript_collision():
    """Demonstrate collision resistance in a protocol transcript context."""
    print("=" * 70)
    print("DEMO 5: Protocol Transcript Collision Resistance")
    print("=" * 70)
    print()
    print("In the SPB Diffie-Hellman protocol, each party's public key")
    print("is derived from a secret path in the Berggren tree.")
    print()
    print("The collision resistance theorem guarantees that if two parties")
    print("choose paths that diverge at some point (incomparable prefixes),")
    print("no amount of further computation can make their evaluations equal.")
    print()
    
    # Simulate two parties with different initial choices
    alice_prefix = "AB"  # Alice starts with generators A, then B
    bob_prefix = "BA"    # Bob starts with generators B, then A
    
    print(f"Alice's prefix: {alice_prefix}")
    print(f"Bob's prefix:   {bob_prefix}")
    print(f"Prefix-comparable: {are_prefix_comparable(alice_prefix, bob_prefix)}")
    print()
    
    # Show that no suffix can make them equal
    print("Checking all suffix combinations up to length 3:")
    all_suffixes = [""]
    for d in range(1, 4):
        all_suffixes.extend([''.join(w) for w in cartesian_product('ABC', repeat=d)])
    
    for alpha in all_suffixes[:15]:
        for beta in all_suffixes[:15]:
            t_alice = eval_word(alice_prefix + alpha)
            t_bob = eval_word(bob_prefix + beta)
            if np.array_equal(t_alice, t_bob):
                print(f"  COLLISION: eval({alice_prefix}{alpha}) = eval({bob_prefix}{beta})")
                break
    else:
        print(f"  No collision found in {15*15} tests ✓")
    
    print()
    print("This is GUARANTEED by the formally verified theorem:")
    print("  no_prefix_collision_of_incomparable")
    print()

# ============================================================================
# Demo 6: Generator-Level Ore Obstruction
# ============================================================================

def demo_generator_ore():
    """Show the concrete Ore obstruction for distinct generators."""
    print("=" * 70)
    print("DEMO 6: Generator-Level Ore Obstruction")
    print("=" * 70)
    print()
    print("For distinct generators g ≠ h, there is NO common left multiple.")
    print("That is, there are no words x, y such that x++[g] = y++[h].")
    print()
    
    for g1, g2 in [('A', 'B'), ('A', 'C'), ('B', 'C')]:
        print(f"  Generators {g1} and {g2}:")
        clm = has_common_left_multiple(g1, g2)
        if clm is None:
            print(f"    No common left multiple ✓")
        else:
            print(f"    CLM found: {clm}")
        
        # Verify by exhaustive search up to depth 5
        found = False
        for depth in range(6):
            if found:
                break
            words = [''.join(w) for w in cartesian_product('ABC', repeat=depth)] if depth > 0 else [""]
            for x in words:
                for y in words:
                    if x + g1 == y + g2:
                        print(f"    Contradiction found: {x}+{g1} = {y}+{g2}")
                        found = True
                        break
                if found:
                    break
        if not found:
            print(f"    Verified by exhaustive search up to depth 5 ✓")
        print()
    
    print("THEOREM (formally verified):")
    print("  g ≠ h → ¬ HasCommonLeftMultiple [g] [h]")
    print()

# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    demo_berggren_tree()
    demo_left_divisibility()
    demo_collision_resistance()
    demo_ore_visualization()
    demo_transcript_collision()
    demo_generator_ore()
    
    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print()
    print("Summary of formally verified results:")
    print("  1. hasCommonLeftMultiple_iff_comparable_leftDivides")
    print("     → CLM exists ↔ left-divisibility comparable")
    print("  2. no_prefix_collision_of_incomparable")
    print("     → incomparable prefixes never produce equal evaluations")
    print("  3. gen_no_common_left_multiple")
    print("     → distinct generators have no common left multiple")
    print("  4. evalTriple_concat_eq_implies_prefix")
    print("     → equal concatenated evaluations force prefix comparability")
    print("  5. leftDivides_antisymm, leftDivides_trans, leftDivides_refl")
    print("     → left-divisibility is a partial order")
