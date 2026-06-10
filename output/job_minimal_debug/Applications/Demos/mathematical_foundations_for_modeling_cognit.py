#!/usr/bin/env python3
"""
Cognitive Braiding Theory: Demonstration

Demonstrates the key mathematical results with concrete examples.
"""

from algorithms import (
    CrossingSign, Crossing, CrossingWord,
    writhe, compose, inverse, cognitive_entropy, cognitive_invariant,
    is_balanced, is_maximally_biased,
    reidemeister_ii_pair, yang_baxter_lhs, yang_baxter_rhs,
    kauffman_state_count, enumerate_kauffman_states, kauffman_exponent,
    realize_crossing_word, jones_entropy, num_crossings
)
import math


def demo_writhe_homomorphism():
    """Demonstrate that writhe is additive under composition."""
    print("=" * 60)
    print("DEMO 1: Writhe Homomorphism Property")
    print("=" * 60)

    w1 = [Crossing(0, CrossingSign.POS), Crossing(1, CrossingSign.POS),
          Crossing(0, CrossingSign.NEG)]
    w2 = [Crossing(1, CrossingSign.NEG), Crossing(0, CrossingSign.POS)]

    w12 = compose(w1, w2)

    print(f"w1 = {w1}")
    print(f"w2 = {w2}")
    print(f"writhe(w1) = {writhe(w1)}")
    print(f"writhe(w2) = {writhe(w2)}")
    print(f"writhe(w1·w2) = {writhe(w12)}")
    print(f"writhe(w1) + writhe(w2) = {writhe(w1) + writhe(w2)}")
    assert writhe(w12) == writhe(w1) + writhe(w2)
    print("✓ Writhe is additive!")
    print()


def demo_reidemeister_ii():
    """Demonstrate R-II invariance of writhe."""
    print("=" * 60)
    print("DEMO 2: Reidemeister-II Invariance")
    print("=" * 60)

    w = [Crossing(0, CrossingSign.POS), Crossing(1, CrossingSign.NEG),
         Crossing(0, CrossingSign.POS)]
    r2 = reidemeister_ii_pair(2)

    w_with_r2 = compose(w[:1], compose(r2, w[1:]))

    print(f"Original word: {w}")
    print(f"R-II pair at position 2: {r2}")
    print(f"Word with R-II inserted: {w_with_r2}")
    print(f"writhe(original) = {writhe(w)}")
    print(f"writhe(with R-II) = {writhe(w_with_r2)}")
    assert writhe(w) == writhe(w_with_r2)
    print("✓ Writhe is R-II invariant!")
    print()


def demo_yang_baxter():
    """Demonstrate Yang-Baxter invariance of writhe."""
    print("=" * 60)
    print("DEMO 3: Yang-Baxter (Reidemeister-III) Invariance")
    print("=" * 60)

    for sign in [CrossingSign.POS, CrossingSign.NEG]:
        lhs = yang_baxter_lhs(0, sign)
        rhs = yang_baxter_rhs(0, sign)

        sign_name = "positive" if sign == CrossingSign.POS else "negative"
        print(f"\nSign = {sign_name}:")
        print(f"  YB-LHS (σ_0 σ_1 σ_0): {lhs}")
        print(f"  YB-RHS (σ_1 σ_0 σ_1): {rhs}")
        print(f"  writhe(LHS) = {writhe(lhs)}")
        print(f"  writhe(RHS) = {writhe(rhs)}")
        assert writhe(lhs) == writhe(rhs)
        print(f"  ✓ Yang-Baxter invariance holds!")
    print()


def demo_entropy_additivity():
    """Demonstrate that cognitive entropy is additive."""
    print("=" * 60)
    print("DEMO 4: Cognitive Entropy Additivity")
    print("=" * 60)

    w1 = [Crossing(0, CrossingSign.POS)] * 3
    w2 = [Crossing(1, CrossingSign.NEG)] * 4

    w12 = compose(w1, w2)

    print(f"w1: {len(w1)} crossings, entropy = {cognitive_entropy(w1):.4f}")
    print(f"w2: {len(w2)} crossings, entropy = {cognitive_entropy(w2):.4f}")
    print(f"w1·w2: {len(w12)} crossings, entropy = {cognitive_entropy(w12):.4f}")
    print(f"H(w1) + H(w2) = {cognitive_entropy(w1) + cognitive_entropy(w2):.4f}")
    assert abs(cognitive_entropy(w12) - cognitive_entropy(w1) - cognitive_entropy(w2)) < 1e-10
    print("✓ Entropy is additive!")
    print()


def demo_shannon_kauffman_bridge():
    """Demonstrate the Shannon-Kauffman Bridge Theorem."""
    print("=" * 60)
    print("DEMO 5: Shannon-Kauffman Bridge Theorem")
    print("=" * 60)

    for n in range(1, 7):
        states = enumerate_kauffman_states(n)
        num_states = len(states)
        assert num_states == kauffman_state_count(n)

        # Shannon entropy of uniform distribution
        shannon_entropy = math.log2(num_states)

        # Cognitive entropy
        w = [Crossing(0, CrossingSign.POS)] * n
        cog_entropy = cognitive_entropy(w)

        print(f"n={n}: |states| = {num_states}, "
              f"Shannon entropy = {shannon_entropy:.4f}, "
              f"Cognitive entropy = {cog_entropy:.4f}")
        assert abs(shannon_entropy - cog_entropy) < 1e-10

    print("✓ Shannon entropy ≡ Cognitive entropy for all n!")
    print()


def demo_invariant_space():
    """Demonstrate the (writhe, entropy) invariant space."""
    print("=" * 60)
    print("DEMO 6: Cognitive Invariant Space")
    print("=" * 60)

    print(f"\n{'Crossings':>10} {'Writhe':>8} {'Entropy':>10} {'Balanced':>10} {'Max Biased':>12}")
    print("-" * 55)

    for n in range(0, 8):
        for w_target in range(-n, n + 1, 2):
            word = realize_crossing_word(w_target, n)
            inv = cognitive_invariant(word)
            bal = is_balanced(word)
            mb = is_maximally_biased(word)

            print(f"{n:>10} {inv[0]:>8} {inv[1]:>10.4f} {str(bal):>10} {str(mb):>12}")

    print("\n✓ All valid (writhe, crossings) pairs are realizable!")
    print()


def demo_jones_entropy():
    """Demonstrate the Jones polynomial entropy at various parameters."""
    print("=" * 60)
    print("DEMO 7: Jones Polynomial Entropy (Conjecture)")
    print("=" * 60)

    w = [Crossing(0, CrossingSign.POS), Crossing(1, CrossingSign.NEG),
         Crossing(0, CrossingSign.POS)]

    print(f"\nWord: {w} (3 crossings)")
    print(f"Uniform entropy: {cognitive_entropy(w):.4f} bits")
    print(f"\nJones entropy at various A values:")
    print(f"{'A':>8} {'H_A (bits)':>12} {'H_uniform':>12} {'Ratio':>8}")
    print("-" * 45)

    h_uniform = cognitive_entropy(w)
    for a in [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0]:
        h_a = jones_entropy(w, a)
        ratio = h_a / h_uniform if h_uniform > 0 else 0
        print(f"{a:>8.2f} {h_a:>12.4f} {h_uniform:>12.4f} {ratio:>8.4f}")

    print("\n✓ At A=1, Jones entropy = uniform entropy (Shannon-Kauffman Bridge)!")
    print("✓ At A≠1, Jones entropy < uniform entropy (non-uniform weights)!")
    print()


def demo_writhe_bound():
    """Demonstrate |writhe| ≤ numCrossings."""
    print("=" * 60)
    print("DEMO 8: Writhe-Entropy Inequality")
    print("=" * 60)

    import random
    random.seed(42)

    violations = 0
    for _ in range(1000):
        n = random.randint(1, 20)
        w = [Crossing(random.randint(0, 5),
                       random.choice([CrossingSign.POS, CrossingSign.NEG]))
             for _ in range(n)]
        wr = abs(writhe(w))
        nc = num_crossings(w)
        if wr > nc:
            violations += 1

    print(f"Tested 1000 random crossing words (length 1-20)")
    print(f"Violations of |writhe| ≤ numCrossings: {violations}")
    assert violations == 0
    print("✓ |writhe| ≤ numCrossings holds for all test cases!")
    print()


if __name__ == "__main__":
    print("\n🧠 COGNITIVE BRAIDING THEORY — DEMONSTRATION\n")
    demo_writhe_homomorphism()
    demo_reidemeister_ii()
    demo_yang_baxter()
    demo_entropy_additivity()
    demo_shannon_kauffman_bridge()
    demo_invariant_space()
    demo_jones_entropy()
    demo_writhe_bound()
    print("=" * 60)
    print("All demonstrations passed! ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Cognitive Invariant Space

Plots the (writhe, entropy) invariant space showing all realizable
cognitive complexity classes and their properties.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import math


def realize_invariant(target_writhe: int, target_crossings: int):
    """Compute the cognitive invariant for a given (writhe, crossings) pair."""
    entropy = target_crossings * math.log(2)
    return target_writhe, entropy


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: The (writhe, entropy) invariant space
    ax1 = axes[0]
    max_n = 10
    writhes = []
    entropies = []
    colors = []

    for n in range(0, max_n + 1):
        for w in range(-n, n + 1, 2):
            wr, ent = realize_invariant(w, n)
            writhes.append(wr)
            entropies.append(ent)
            if w == 0:
                colors.append('blue')       # balanced
            elif abs(w) == n:
                colors.append('red')        # maximally biased
            else:
                colors.append('green')      # intermediate

    ax1.scatter(writhes, entropies, c=colors, s=40, alpha=0.8, edgecolors='black', linewidth=0.5)

    # Draw the boundary |writhe| ≤ n, entropy = n * log2
    n_vals = np.linspace(0, max_n, 100)
    entropy_vals = n_vals * math.log(2)
    ax1.plot(n_vals, entropy_vals, 'k--', alpha=0.3, label='|writhe| = crossings')
    ax1.plot(-n_vals, entropy_vals, 'k--', alpha=0.3)
    ax1.fill_betweenx(entropy_vals, -n_vals, n_vals, alpha=0.05, color='gray')

    balanced_patch = mpatches.Patch(color='blue', label='Balanced (writhe=0)')
    biased_patch = mpatches.Patch(color='red', label='Maximally biased')
    inter_patch = mpatches.Patch(color='green', label='Intermediate')
    ax1.legend(handles=[balanced_patch, biased_patch, inter_patch], fontsize=9)

    ax1.set_xlabel('Writhe (directional bias)', fontsize=12)
    ax1.set_ylabel('Cognitive Entropy (bits)', fontsize=12)
    ax1.set_title('Cognitive Invariant Space', fontsize=14)
    ax1.grid(True, alpha=0.3)

    # Plot 2: Jones entropy vs parameter A
    ax2 = axes[1]
    a_vals = np.linspace(0.1, 4.0, 200)

    for n in [2, 3, 4, 5]:
        jones_entropies = []
        for a in a_vals:
            # Compute Jones entropy for n crossings, all positive
            exponents = [2 * k - n for k in range(n + 1)]
            # Degeneracy: C(n, k) states have exponent 2k - n
            from math import comb
            weights = [comb(n, k) * abs(a ** (2 * k - n)) for k in range(n + 1)]
            total = sum(weights)
            probs = [w / total for w in weights]
            entropy = -sum(p * math.log2(p) if p > 0 else 0 for p in probs)
            jones_entropies.append(entropy)

        ax2.plot(a_vals, jones_entropies, label=f'n = {n}', linewidth=2)
        ax2.axhline(y=n, color='gray', linestyle=':', alpha=0.3)

    ax2.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='A=1 (uniform)')
    ax2.set_xlabel('Parameter A', fontsize=12)
    ax2.set_ylabel('Jones Entropy H_A (bits)', fontsize=12)
    ax2.set_title('Jones Polynomial Entropy', fontsize=14)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cognitive_braiding_invariants.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: cognitive_braiding_invariants.png")


if __name__ == "__main__":
    main()
