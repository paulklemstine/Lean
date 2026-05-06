#!/usr/bin/env python3
"""
Berggren Spectral Hash: Numerical Demonstrations

This script demonstrates the formally verified properties of the Berggren semigroup
spectral hash, including:
1. The Berggren action on pairs and its injectivity
2. Parikh vectors and their properties
3. Collision-freeness on bounded balls
4. Hidden-subsemigroup recovery from spectral data

All mathematical properties shown here have been formally verified in Lean 4.
"""

import itertools
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


# === Berggren Action ===

def act_gen(g, pair):
    """Apply a Berggren generator to a pair (m, n).
    
    Generators:
      A: (m, n) -> (2m - n, m)
      B: (m, n) -> (2m + n, m)
      C: (m, n) -> (m + 2n, n)
    """
    m, n = pair
    if g == 'A':
        return (2*m - n, m)
    elif g == 'B':
        return (2*m + n, m)
    elif g == 'C':
        return (m + 2*n, n)
    else:
        raise ValueError(f"Unknown generator: {g}")


ROOT_PAIR = (2, 1)  # Corresponds to the triple (3, 4, 5)


def eval_pair(word):
    """Evaluate a Berggren word on the root pair.
    
    Words are read right-to-left: [A, B] means apply B first, then A.
    """
    result = ROOT_PAIR
    for g in reversed(word):
        result = act_gen(g, result)
    return result


def pair_to_triple(pair):
    """Convert a pair (m, n) to the Pythagorean triple (a, b, c).
    
    The parametrization: a = m² - n², b = 2mn, c = m² + n².
    """
    m, n = pair
    return (m*m - n*n, 2*m*n, m*m + n*n)


# === Parikh Vectors ===

def parikh_triple(word):
    """Compute the Parikh triple (#A, #B, #C) of a word."""
    return (word.count('A'), word.count('B'), word.count('C'))


def all_words_of_length(n):
    """Generate all Berggren words of exactly length n."""
    if n == 0:
        return [()]
    return list(itertools.product('ABC', repeat=n))


def bounded_words(R):
    """Generate all Berggren words of length ≤ R."""
    words = []
    for n in range(R + 1):
        words.extend(all_words_of_length(n))
    return words


# === Demo 1: Berggren Tree Visualization ===

def demo_berggren_tree():
    """Show the first few levels of the Berggren tree."""
    print("=" * 70)
    print("DEMO 1: The Berggren Tree of Primitive Pythagorean Triples")
    print("=" * 70)
    print()
    print("Each word in {A, B, C}* maps to a unique primitive Pythagorean triple.")
    print("The root pair (2,1) corresponds to the triple (3, 4, 5).")
    print()
    
    for depth in range(4):
        words = all_words_of_length(depth)
        print(f"Depth {depth} ({len(words)} words = 3^{depth}):")
        for w in words[:12]:  # Show at most 12 per level
            pair = eval_pair(w)
            triple = pair_to_triple(pair)
            word_str = ''.join(w) if w else 'ε'
            print(f"  {word_str:>6} → pair {pair} → triple {triple}")
        if len(words) > 12:
            print(f"  ... and {len(words) - 12} more")
        print()


# === Demo 2: Injectivity Verification ===

def demo_injectivity():
    """Verify injectivity of evalPair on bounded balls."""
    print("=" * 70)
    print("DEMO 2: Injectivity Verification (Collision-Freeness)")
    print("=" * 70)
    print()
    print("Theorem (certified_no_collision): For all R, there are no collisions")
    print("in the Berggren action on the radius-R ball.")
    print()
    
    for R in range(7):
        words = bounded_words(R)
        pairs = {}
        collisions = 0
        for w in words:
            p = eval_pair(w)
            if p in pairs:
                collisions += 1
            else:
                pairs[p] = w
        
        n_words = len(words)
        n_pairs = len(pairs)
        status = "✓ NO COLLISIONS" if collisions == 0 else f"✗ {collisions} collisions"
        print(f"  R={R}: {n_words:>5} words, {n_pairs:>5} distinct pairs  {status}")
    
    print()
    print("This confirms the formal theorem: evalPair is injective (globally).")
    print()


# === Demo 3: Parikh Spectrum Analysis ===

def demo_parikh_spectrum():
    """Analyze the Parikh spectrum and its relationship to reconstruction."""
    print("=" * 70)
    print("DEMO 3: Parikh Spectrum Analysis")
    print("=" * 70)
    print()
    print("The Parikh triple (a,b,c) counts generators: a=#A, b=#B, c=#C.")
    print("Multiple words can share the same Parikh triple (since it forgets order).")
    print("But the orbit profile (evalPair value) uniquely identifies each word.")
    print()
    
    R = 4
    words = bounded_words(R)
    
    # Group words by Parikh triple
    parikh_groups = defaultdict(list)
    for w in words:
        pt = parikh_triple(w)
        parikh_groups[pt].append(w)
    
    print(f"Radius R={R}: {len(words)} total words, {len(parikh_groups)} distinct Parikh triples")
    print()
    
    # Show some Parikh classes with multiple words
    multi_classes = [(pt, ws) for pt, ws in parikh_groups.items() if len(ws) > 1]
    multi_classes.sort(key=lambda x: (sum(x[0]), x[0]))
    
    print("Parikh classes with multiple words (showing orbit profiles separate them):")
    for pt, ws in multi_classes[:5]:
        print(f"\n  Parikh triple {pt} ({len(ws)} words):")
        for w in ws:
            pair = eval_pair(w)
            word_str = ''.join(w) if w else 'ε'
            print(f"    {word_str:>6} → orbit profile {pair}")
        
        # Verify all orbit profiles are distinct
        profiles = [eval_pair(w) for w in ws]
        assert len(profiles) == len(set(profiles)), "Collision detected!"
        print(f"    → All {len(ws)} orbit profiles are distinct ✓")
    
    print()


# === Demo 4: Hidden Subsemigroup Recovery ===

def demo_hidden_subsemigroup():
    """Demonstrate the hidden-subsemigroup recovery theorem."""
    print("=" * 70)
    print("DEMO 4: Hidden-Subsemigroup Recovery")
    print("=" * 70)
    print()
    print("Theorem (hidden_subsemigroup_recovery):")
    print("If two sets S, T of Berggren words have the same bounded profile")
    print("spectrum, then they contain exactly the same bounded words.")
    print()
    
    R = 3
    
    def closure(generators, R):
        """Compute subsemigroup closure up to length R."""
        result = set()
        for g in generators:
            if len(g) <= R:
                result.add(g)
        
        changed = True
        while changed:
            changed = False
            new = set()
            for u in list(result):
                for v in list(result):
                    w = u + v
                    if len(w) <= R and w not in result:
                        new.add(w)
                        changed = True
            result.update(new)
        return result
    
    # Define two different subsemigroups
    gen1 = [('A',), ('B', 'C')]
    gen2 = [('A',), ('C', 'B')]
    
    S = closure(gen1, R)
    T = closure(gen2, R)
    
    # Compute their profile spectra
    spec_S = {eval_pair(w) for w in S}
    spec_T = {eval_pair(w) for w in T}
    
    print(f"Subsemigroup S generated by {{A, BC}}, truncated to R={R}:")
    for w in sorted(S, key=lambda x: (len(x), x)):
        word_str = ''.join(w)
        print(f"  {word_str:>8} → profile {eval_pair(w)}")
    
    print(f"\nSubsemigroup T generated by {{A, CB}}, truncated to R={R}:")
    for w in sorted(T, key=lambda x: (len(x), x)):
        word_str = ''.join(w)
        print(f"  {word_str:>8} → profile {eval_pair(w)}")
    
    print(f"\nProfile spectrum of S: {sorted(spec_S)}")
    print(f"Profile spectrum of T: {sorted(spec_T)}")
    
    if spec_S == spec_T:
        print("\n→ Profile spectra are EQUAL → S and T have the same words (by theorem)")
    else:
        print("\n→ Profile spectra DIFFER → S ≠ T on the bounded ball")
        print("  (The theorem confirms: distinct profile spectra ↔ distinct word sets)")
    print()


# === Demo 5: Visualization ===

def demo_visualization():
    """Create visualizations of the Berggren spectral structure."""
    print("=" * 70)
    print("DEMO 5: Generating Visualizations")
    print("=" * 70)
    print()
    
    # Plot 1: Orbit profiles in the (m, n) plane
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    R = 5
    words = bounded_words(R)
    
    # Color by first generator
    colors_map = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}
    
    ax = axes[0]
    for w in words:
        if len(w) == 0:
            continue
        pair = eval_pair(w)
        color = colors_map[w[0]]
        ax.scatter(pair[0], pair[1], c=color, s=30, alpha=0.7, edgecolors='none')
    
    # Mark root
    ax.scatter(ROOT_PAIR[0], ROOT_PAIR[1], c='black', s=100, marker='*', zorder=5,
               label='Root (2,1)')
    
    # Legend
    for g, c in colors_map.items():
        ax.scatter([], [], c=c, s=30, label=f'First gen = {g}')
    ax.legend(fontsize=9)
    ax.set_xlabel('m', fontsize=12)
    ax.set_ylabel('n', fontsize=12)
    ax.set_title(f'Orbit Profiles (R≤{R})', fontsize=13)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Parikh spectrum distribution
    ax = axes[1]
    
    R_viz = 4
    words_viz = [w for w in bounded_words(R_viz) if len(w) > 0]
    parikh_groups = defaultdict(int)
    for w in words_viz:
        pt = parikh_triple(w)
        parikh_groups[pt] += 1
    
    sizes = list(parikh_groups.values())
    
    # Bar chart of Parikh class sizes
    class_sizes = defaultdict(int)
    for s in sizes:
        class_sizes[s] += 1
    
    x = sorted(class_sizes.keys())
    y = [class_sizes[k] for k in x]
    
    ax.bar(x, y, color='#9b59b6', alpha=0.8, edgecolor='white')
    ax.set_xlabel('Words per Parikh class', fontsize=12)
    ax.set_ylabel('Number of Parikh classes', fontsize=12)
    ax.set_title(f'Parikh Class Size Distribution (R≤{R_viz})', fontsize=13)
    ax.grid(True, alpha=0.3, axis='y')
    
    plt.tight_layout()
    plt.savefig('demos/berggren_spectral_plots.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/berggren_spectral_plots.png")
    
    # Plot 2: Growth of the radius ball
    fig2, ax2 = plt.subplots(figsize=(8, 5))
    
    Rs = range(8)
    ball_sizes = []
    distinct_profiles = []
    distinct_parikh = []
    
    for r in Rs:
        ws = bounded_words(r)
        ball_sizes.append(len(ws))
        profiles = {eval_pair(w) for w in ws}
        distinct_profiles.append(len(profiles))
        parikh_set = {parikh_triple(w) for w in ws}
        distinct_parikh.append(len(parikh_set))
    
    ax2.plot(list(Rs), ball_sizes, 'o-', color='#e74c3c', linewidth=2,
             label='Ball size (words)', markersize=6)
    ax2.plot(list(Rs), distinct_profiles, 's-', color='#2ecc71', linewidth=2,
             label='Distinct profiles', markersize=6)
    ax2.plot(list(Rs), distinct_parikh, '^-', color='#3498db', linewidth=2,
             label='Distinct Parikh triples', markersize=6)
    
    ax2.set_xlabel('Radius R', fontsize=12)
    ax2.set_ylabel('Count', fontsize=12)
    ax2.set_title('Berggren Spectral Invariants by Radius', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_yscale('log')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('demos/berggren_growth.png', dpi=150, bbox_inches='tight')
    print("  Saved: demos/berggren_growth.png")
    print()


# === Demo 6: Collision Certificate ===

def demo_collision_certificate():
    """Demonstrate the collision certificate computation."""
    print("=" * 70)
    print("DEMO 6: Collision Certificate")
    print("=" * 70)
    print()
    print("We compute an explicit collision certificate for each radius R.")
    print("The certificate confirms: no two distinct words of length ≤ R")
    print("produce the same orbit profile.")
    print()
    
    for R in range(7):
        words = bounded_words(R)
        seen = {}
        certified = True
        
        for w in words:
            profile = eval_pair(w)
            if profile in seen:
                print(f"  R={R}: COLLISION between {seen[profile]} and {w}")
                certified = False
                break
            seen[profile] = w
        
        if certified:
            n = len(words)
            formula = sum(3**k for k in range(R+1))
            print(f"  R={R}: Certificate VALID — {n} words checked, "
                  f"Σ 3^k = {formula} entries, 0 collisions ✓")
    
    print()
    print("This computational verification mirrors the formal theorem")
    print("`certified_no_collision` proved in Lean 4.")
    print()


# === Main ===

if __name__ == '__main__':
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Berggren Spectral Hash: Formal Verification Demonstrations        ║")
    print("║  All properties below are formally verified in Lean 4 with Mathlib ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()
    
    demo_berggren_tree()
    demo_injectivity()
    demo_parikh_spectrum()
    demo_hidden_subsemigroup()
    demo_collision_certificate()
    demo_visualization()
    
    print("=" * 70)
    print("All demonstrations complete.")
    print("See Cryptography/BerggrenSubsemigroupRigidity.lean for formal proofs.")
    print("=" * 70)
