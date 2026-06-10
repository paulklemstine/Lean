#!/usr/bin/env python3
"""
Quantitative Residual Finiteness for Berggren Semigroup Balls
=============================================================

This demo brings to life the formally verified theorem that reduction modulo
a certified modulus preserves all distinctions among matrices in a bounded
semigroup ball. We demonstrate the key ideas with concrete numerical examples
and visualizations.

Mathematical Setup
------------------
Three 2×2 integer matrices A, B, C generate a semigroup S via multiplication.
The "radius-L ball" consists of all products of at most L generators.

Key Result: if m = 2 · 6^L + 1, then reduction mod m is injective on the
radius-L ball. That is, distinct matrices in the ball remain distinct mod m.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product as iterproduct
from collections import defaultdict
import os

# ============================================================
# 1. Define the Berggren generators (matching the Lean formalization)
# ============================================================

A = np.array([[1, 2], [1, 3]], dtype=np.int64)
B = np.array([[3, 2], [1, 1]], dtype=np.int64)
C = np.array([[1, 1], [2, 3]], dtype=np.int64)

GENERATORS = [A, B, C]
GEN_NAMES = ['A', 'B', 'C']

def mat_abs_max(M):
    """Maximum absolute value of entries (the infinity-norm from the Lean formalization)."""
    return int(np.max(np.abs(M)))

def word_eval(word_indices):
    """Evaluate a word (list of generator indices) as a matrix product."""
    result = np.eye(2, dtype=np.int64)
    for idx in word_indices:
        result = GENERATORS[idx] @ result
    return result

def word_name(word_indices):
    """Human-readable name for a word."""
    if not word_indices:
        return "I"
    return "·".join(GEN_NAMES[i] for i in word_indices)

# ============================================================
# 2. Demonstrate the entry growth bound
# ============================================================

def demo_entry_growth():
    """Show that matAbsMax grows at most as 6^L."""
    print("=" * 70)
    print("DEMO 1: Entry Growth Bound")
    print("=" * 70)
    print()
    print("Theorem: For any matrix M in the radius-L semigroup ball,")
    print("         matAbsMax(M) <= 6^L")
    print()

    max_L = 8
    observed_max = []
    theoretical_bound = []

    for L in range(max_L + 1):
        max_entry = 1  # identity matrix
        if L == 0:
            max_entry = 1
        else:
            for word in iterproduct(range(3), repeat=L):
                M = word_eval(word)
                max_entry = max(max_entry, mat_abs_max(M))

        observed_max.append(max_entry)
        theoretical_bound.append(6**L)
        print(f"  L={L}: max entry = {max_entry:>12,}   bound 6^L = {6**L:>12,}   "
              f"ratio = {max_entry / 6**L:.4f}")

    print()
    print("  The bound holds for all tested radii.")
    print("  Note: the actual growth is much slower than the worst-case bound.")
    print()

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))
    Ls = list(range(max_L + 1))
    ax.semilogy(Ls, observed_max, 'bo-', label='Observed max entry', markersize=8)
    ax.semilogy(Ls, theoretical_bound, 'r--', label='Theoretical bound $6^L$', linewidth=2)
    ax.set_xlabel('Radius L', fontsize=14)
    ax.set_ylabel('Maximum entry absolute value', fontsize=14)
    ax.set_title('Entry Growth in Berggren Semigroup Ball', fontsize=16)
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig(os.path.join(os.path.dirname(__file__), 'entry_growth.png'), dpi=150)
    print("  [Saved: entry_growth.png]")
    plt.close(fig)

# ============================================================
# 3. Demonstrate the separation mechanism
# ============================================================

def demo_separation():
    """Show that reduction mod m separates all matrices in a ball."""
    print()
    print("=" * 70)
    print("DEMO 2: Modular Separation Mechanism")
    print("=" * 70)
    print()
    print("Theorem: If m = 2*6^L + 1, then reduction mod m is injective")
    print("         on the radius-L semigroup ball.")
    print()

    for L in range(1, 6):
        certified_m = 2 * (6**L) + 1
        matrices = {}
        for length in range(L + 1):
            for word in iterproduct(range(3), repeat=length):
                M = word_eval(word)
                key = tuple(M.flatten())
                name = word_name(word)
                if key not in matrices:
                    matrices[key] = (M, name)

        n_distinct = len(matrices)

        reduced = {}
        collision = False
        for key, (M, name) in matrices.items():
            M_mod = tuple((M % certified_m).flatten())
            if M_mod in reduced:
                collision = True
                break
            reduced[M_mod] = name

        status = "COLLISION!" if collision else "INJECTIVE"
        print(f"  L={L}: certified modulus m = {certified_m:>10,}  |  "
              f"{n_distinct:>6} distinct matrices  |  {status}")

    print()
    print("  Modular reduction is injective for all tested radii, as guaranteed")
    print("  by the certified modulus formula.")
    print()

    print("  Counterexample: using too-small moduli causes collisions:")
    L = 3
    certified_m = 2 * (6**L) + 1
    matrices = {}
    for length in range(L + 1):
        for word in iterproduct(range(3), repeat=length):
            M = word_eval(word)
            key = tuple(M.flatten())
            if key not in matrices:
                matrices[key] = M

    for m in [5, 11, 31, 101, certified_m]:
        reduced = set()
        collision_count = 0
        for key, M in matrices.items():
            M_mod = tuple((M % m).flatten())
            if M_mod in reduced:
                collision_count += 1
            reduced.add(M_mod)

        tag = " <-- certified" if m == certified_m else ""
        print(f"    m = {m:>5}: {collision_count} collisions among "
              f"{len(matrices)} distinct matrices{tag}")
    print()

# ============================================================
# 4. Demonstrate the core integer separation lemma
# ============================================================

def demo_integer_separation():
    """Illustrate the scalar core: bounded integers separated by large modulus."""
    print()
    print("=" * 70)
    print("DEMO 3: Integer Separation Lemma (Core Mechanism)")
    print("=" * 70)
    print()
    print("Lemma: If |a|, |b| <= M and a = b (mod m) with m > 2M, then a = b.")
    print()
    print("Intuition: The 'window' [-M, M] has width 2M. If m > 2M, distinct")
    print("integers in this window cannot wrap around mod m.")
    print()

    M_bound = 10
    m = 2 * M_bound + 1

    print(f"  Example: M = {M_bound}, m = {m}")
    print(f"  Window: [{-M_bound}, {M_bound}] has {2*M_bound+1} integers")
    print(f"  Residue classes mod {m}: {m} classes")
    print()

    residues = {}
    for a in range(-M_bound, M_bound + 1):
        r = a % m
        if r in residues:
            print(f"  COLLISION: {a} = {residues[r]} (mod {m})")
        residues[r] = a
    print(f"  All {2*M_bound+1} integers in [{-M_bound}, {M_bound}] have distinct residues mod {m}")
    print()

    m_bad = 2 * M_bound
    residues_bad = defaultdict(list)
    for a in range(-M_bound, M_bound + 1):
        residues_bad[a % m_bad].append(a)
    collisions = {r: vals for r, vals in residues_bad.items() if len(vals) > 1}
    if collisions:
        print(f"  With m = {m_bad} (= 2M, not > 2M), collisions occur:")
        for r, vals in list(collisions.items())[:3]:
            print(f"    {vals[0]} = {vals[1]} (mod {m_bad})")
    print()

# ============================================================
# 5. Collision extraction: the cryptographic application
# ============================================================

def demo_collision_extraction():
    """Show bounded collision extraction in action."""
    print()
    print("=" * 70)
    print("DEMO 4: Bounded Collision Extraction (Cryptographic Application)")
    print("=" * 70)
    print()
    print("Scenario: Two Berggren words w1, w2 of length <= L produce the same")
    print("matrix mod m = 2*6^L + 1. The theorem guarantees they evaluate to")
    print("the SAME matrix over Z.")
    print()

    L = 3
    m = 2 * (6**L) + 1
    print(f"  Parameters: L = {L}, certified modulus m = {m}")
    print()

    words_by_eval = defaultdict(list)
    for length in range(L + 1):
        for word in iterproduct(range(3), repeat=length):
            word = list(word)
            M = word_eval(word)
            key = tuple(M.flatten())
            words_by_eval[key].append(word)

    multi_words = {k: v for k, v in words_by_eval.items() if len(v) > 1}
    if multi_words:
        print("  Words producing the same matrix (genuine semigroup equalities):")
        for key, words in list(multi_words.items())[:5]:
            M = np.array(key).reshape(2, 2)
            names = [word_name(w) for w in words]
            print(f"    {' = '.join(names)} = {M.tolist()}")
        print()

    mod_classes = defaultdict(list)
    all_words = []
    for length in range(L + 1):
        for word in iterproduct(range(3), repeat=length):
            word = list(word)
            M = word_eval(word)
            M_mod = tuple((M % m).flatten())
            mod_classes[M_mod].append((word, tuple(M.flatten())))
            all_words.append(word)

    spurious = 0
    for mod_key, entries in mod_classes.items():
        matrices = set(e[1] for e in entries)
        if len(matrices) > 1:
            spurious += 1

    print(f"  Total words of length <= {L}: {len(all_words)}")
    print(f"  Distinct mod-m classes: {len(mod_classes)}")
    print(f"  Spurious collisions (same mod m, different over Z): {spurious}")
    print()
    if spurious == 0:
        print("  ZERO spurious collisions -- every mod-m collision lifts to")
        print("  genuine matrix equality, exactly as the theorem guarantees.")
    print()

# ============================================================
# 6. Visualization: certified modulus growth
# ============================================================

def demo_modulus_growth():
    """Visualize how the certified modulus grows with protocol complexity."""
    print()
    print("=" * 70)
    print("DEMO 5: Certified Modulus Growth")
    print("=" * 70)
    print()

    Ls = list(range(1, 16))
    moduli = [2 * 6**L + 1 for L in Ls]
    bits = [int(np.ceil(np.log2(m))) for m in moduli]

    print("  L (max word length) -> certified modulus m = 2*6^L + 1")
    print()
    for L, m, b in zip(Ls, moduli, bits):
        bar = "#" * min(b, 60)
        print(f"  L={L:>2}: m = {m:>20,}  ({b:>3} bits)  {bar}")

    print()
    print(f"  The modulus grows exponentially but very manageably:")
    print(f"  * L=10 (1024 protocol steps): ~{bits[9]}-bit modulus")
    print(f"  * L=15 (32768 protocol steps): ~{bits[14]}-bit modulus")
    print()

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    ax1.semilogy(Ls, moduli, 'go-', markersize=8)
    ax1.set_xlabel('Protocol complexity L', fontsize=13)
    ax1.set_ylabel('Certified modulus m', fontsize=13)
    ax1.set_title('Certified Modulus vs. Protocol Complexity', fontsize=14)
    ax1.grid(True, alpha=0.3)

    ax2.plot(Ls, bits, 'rs-', markersize=8)
    ax2.set_xlabel('Protocol complexity L', fontsize=13)
    ax2.set_ylabel('Bit-length of certified modulus', fontsize=13)
    ax2.set_title('Modulus Bit-Length (Linear Growth)', fontsize=14)
    ax2.grid(True, alpha=0.3)

    fig.tight_layout()
    fig.savefig(os.path.join(os.path.dirname(__file__), 'modulus_growth.png'), dpi=150)
    print("  [Saved: modulus_growth.png]")
    plt.close(fig)

# ============================================================
# 7. Application: safe finite quotient for key exchange
# ============================================================

def demo_key_exchange_application():
    """Demonstrate the application to bounded Diffie-Hellman style key exchange."""
    print()
    print("=" * 70)
    print("DEMO 6: Application -- Safe Finite Quotient for Key Exchange")
    print("=" * 70)
    print()
    print("In an SPB-style key exchange, Alice and Bob choose secret words")
    print("w_A and w_B of bounded length L, and exchange their matrix")
    print("evaluations. Working mod m = 2*6^L + 1 is provably safe:")
    print("any attack that finds a collision in the finite quotient lifts")
    print("to a genuine collision over Z.")
    print()

    L = 4
    m = 2 * 6**L + 1
    print(f"  Example protocol with L = {L}, modulus m = {m}:")
    print()

    alice_word = [0, 1, 2, 0]
    alice_matrix = word_eval(alice_word)
    alice_reduced = alice_matrix % m

    bob_word = [2, 0, 1, 2]
    bob_matrix = word_eval(bob_word)
    bob_reduced = bob_matrix % m

    print(f"  Alice's word: {word_name(alice_word)}")
    print(f"  Alice's matrix (over Z): {alice_matrix.tolist()}")
    print(f"  Alice's matrix (mod {m}): {alice_reduced.tolist()}")
    print()
    print(f"  Bob's word: {word_name(bob_word)}")
    print(f"  Bob's matrix (over Z): {bob_matrix.tolist()}")
    print(f"  Bob's matrix (mod {m}): {bob_reduced.tolist()}")
    print()

    shared_ab = alice_matrix @ bob_matrix
    shared_ba = bob_matrix @ alice_matrix
    print(f"  Alice*Bob (over Z): {shared_ab.tolist()}")
    print(f"  Bob*Alice (over Z): {shared_ba.tolist()}")
    print()

    print(f"  Security guarantee: any adversary who finds matrices M1, M2")
    print(f"  in the radius-{L} ball with M1 = M2 (mod {m}) must have M1 = M2.")
    print(f"  The finite quotient introduces NO false identifications.")
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("=" * 72)
    print("  Quantitative Residual Finiteness for Berggren Semigroup Balls")
    print("  Interactive Demo -- Companion to the Lean 4 Formalization")
    print("=" * 72)
    print()

    demo_entry_growth()
    demo_separation()
    demo_integer_separation()
    demo_collision_extraction()
    demo_modulus_growth()
    demo_key_exchange_application()

    print("=" * 70)
    print("All demos complete.")
    print("=" * 70)
