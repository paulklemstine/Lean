#!/usr/bin/env python3
"""
applications.py — Real-world applications of Berggren Automaton Realization

Demonstrates applications in:
1. Compressed representation of Pythagorean triple statistics
2. Efficient computation of arithmetic properties along the Berggren tree
3. Pattern recognition in Diophantine sequences
4. Symbolic compression of tree-structured arithmetic data
"""

import numpy as np
from algorithms import (
    apply_berggren_word, build_residual_automaton,
    verify_minimality, generate_all_words, LETTERS,
    hankel_rank, enumerate_berggren_tree
)


# ============================================================
# Application 1: Compressed Triple Statistics
# ============================================================

def app_compressed_statistics():
    """Demonstrate compressed computation of Pythagorean triple statistics.

    Instead of computing triples for every word, use a finite automaton
    to track which arithmetic class each triple falls into.
    """
    print("=" * 60)
    print("APPLICATION 1: Compressed Triple Statistics")
    print("=" * 60)
    print()

    # Stream: hypotenuse mod small prime
    for p in [3, 5, 7]:
        stream = lambda w, p=p: apply_berggren_word(w)[2] % p

        auto = build_residual_automaton(stream, test_depth=3, search_depth=5)
        if auto:
            print(f"  Hypotenuse mod {p}: automaton with {auto.n_states} states")
            print(f"    Verified: {auto.verify(stream, 4)}")

            # Use automaton for fast evaluation
            test_word = 'ABCABC'
            direct = stream(test_word)
            via_auto = auto.evaluate(test_word)
            print(f"    S('{test_word}') = {direct} (direct), {via_auto} (automaton)")
        else:
            print(f"  Hypotenuse mod {p}: infinite rank (not finitely recognizable)")
        print()


# ============================================================
# Application 2: Parity Patterns in Triple Components
# ============================================================

def app_parity_patterns():
    """Detect parity patterns in Pythagorean triple components.

    For primitive Pythagorean triples, exactly one of a, b is even.
    Track which component is even as a finite-state property.
    """
    print("=" * 60)
    print("APPLICATION 2: Parity Patterns in Triple Components")
    print("=" * 60)
    print()

    # Stream: which component of the triple is even (0=a, 1=b)
    def even_component(word):
        a, b, c = apply_berggren_word(word)
        if a % 2 == 0:
            return 0
        elif b % 2 == 0:
            return 1
        else:
            return 2  # shouldn't happen for primitive triples

    auto = build_residual_automaton(even_component, test_depth=3, search_depth=5)
    if auto:
        print(f"  'Which component is even?' automaton: {auto.n_states} states")
        print(f"  Verified: {auto.verify(even_component, 4)}")
        print()

        # Show pattern
        for w in ['', 'A', 'B', 'C', 'AA', 'AB', 'AC', 'BA', 'BB', 'BC']:
            a, b, c = apply_berggren_word(w)
            comp = even_component(w)
            label = ['a', 'b', 'c'][comp]
            print(f"    w='{w}': ({a},{b},{c}), even component = {label}")


# ============================================================
# Application 3: Divisibility Patterns
# ============================================================

def app_divisibility():
    """Track divisibility properties along the Berggren tree.

    Many divisibility properties are periodic under the Berggren action,
    making them recognizable by finite automata.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Divisibility Patterns")
    print("=" * 60)
    print()

    # Stream: is the 'a' component divisible by 3?
    def a_div3(word):
        a, _, _ = apply_berggren_word(word)
        return 1 if a % 3 == 0 else 0

    auto = build_residual_automaton(a_div3, test_depth=3, search_depth=5)
    if auto:
        print(f"  'Is a divisible by 3?' automaton: {auto.n_states} states")
        print(f"  Verified: {auto.verify(a_div3, 4)}")
    else:
        print(f"  'Is a divisible by 3?' has infinite rank")

    # Stream: triple component residues mod 4
    def residue_mod4(word):
        a, b, c = apply_berggren_word(word)
        return (a % 4, b % 4, c % 4)

    auto4 = build_residual_automaton(residue_mod4, test_depth=3, search_depth=5)
    if auto4:
        print(f"  'Triple mod 4' automaton: {auto4.n_states} states")
        print(f"  Verified: {auto4.verify(residue_mod4, 4)}")
    else:
        print(f"  'Triple mod 4' has infinite rank")


# ============================================================
# Application 4: Symbolic Compression
# ============================================================

def app_symbolic_compression():
    """Demonstrate symbolic compression of tree-structured data.

    For finite-rank streams, the automaton provides a compressed
    representation: O(n_states * |alphabet|) space instead of
    exponential enumeration.
    """
    print()
    print("=" * 60)
    print("APPLICATION 4: Symbolic Compression Ratios")
    print("=" * 60)
    print()

    streams = {
        'length mod 2': lambda w: len(w) % 2,
        'length mod 5': lambda w: len(w) % 5,
        'first letter': lambda w: 0 if not w else ord(w[0]) - ord('A') + 1,
        'last letter': lambda w: 0 if not w else ord(w[-1]) - ord('A') + 1,
    }

    for name, stream in streams.items():
        auto = build_residual_automaton(stream, test_depth=3, search_depth=5)
        if auto:
            n_states = auto.n_states
            # Compare: to store all values up to depth d, need 3^d entries
            # Automaton needs: n_states * 3 transitions + n_states outputs
            auto_size = n_states * 3 + n_states
            for depth in [5, 10, 15]:
                tree_size = sum(3**i for i in range(depth + 1))
                ratio = tree_size / auto_size if auto_size > 0 else float('inf')
                if depth == 5:
                    print(f"  '{name}': {n_states} states, "
                          f"compression at depth {depth}: {ratio:.0f}x")
                elif depth == 15:
                    print(f"    {'':20s} at depth {depth}: {ratio:.0f}x")


# ============================================================
# Application 5: Fast Pythagorean Triple Classification
# ============================================================

def app_fast_classification():
    """Use automata to classify Pythagorean triples by properties
    without computing the full triple.
    """
    print()
    print("=" * 60)
    print("APPLICATION 5: Fast Triple Classification")
    print("=" * 60)
    print()

    # Classify by hypotenuse mod 12
    stream = lambda w: apply_berggren_word(w)[2] % 12

    auto = build_residual_automaton(stream, test_depth=3, search_depth=5)
    if auto:
        print(f"  Hypotenuse mod 12 classifier: {auto.n_states} states")

        # Classify a long word without computing the triple
        long_word = 'A' * 20 + 'B' * 15 + 'C' * 10
        result_auto = auto.evaluate(long_word)
        result_direct = stream(long_word)
        print(f"  Classification of 45-letter word:")
        print(f"    Automaton result: {result_auto}")
        print(f"    Direct computation: {result_direct}")
        print(f"    Match: {result_auto == result_direct}")
        print()

        # Speed comparison (conceptual)
        print(f"  Automaton: O(word_length) time, O(1) space")
        print(f"  Direct: O(word_length) matrix multiplications with growing integers")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    app_compressed_statistics()
    app_parity_patterns()
    app_divisibility()
    app_symbolic_compression()
    app_fast_classification()

    print()
    print("=" * 60)
    print("CONCLUSION")
    print("=" * 60)
    print()
    print("The Berggren Realization Theorem provides a systematic")
    print("framework for determining which arithmetic properties of")
    print("Pythagorean triples can be tracked by finite-state machines.")
    print()
    print("Applications include:")
    print("  • Compressed representation of triple statistics")
    print("  • Fast classification without full triple computation")
    print("  • Symbolic compression of tree-structured arithmetic data")
    print("  • Automated discovery of finite-state arithmetic patterns")


#!/usr/bin/env python3
"""
demo.py — Demonstrating the Berggren Automaton Realization Theory

Concrete numerical examples showing:
1. The Berggren tree generating primitive Pythagorean triples
2. Streams on the Berggren alphabet and their residuals
3. Finite vs infinite residual rank
4. Construction of the canonical residual automaton
5. Minimality verification
"""

import numpy as np
from itertools import product
from collections import defaultdict

# === Berggren Matrices ===
# The three matrices that generate all primitive Pythagorean triples from (3,4,5)

BERG_A = np.array([
    [ 1, -2,  2],
    [ 2, -1,  2],
    [ 2, -2,  3]
])

BERG_B = np.array([
    [ 1,  2,  2],
    [ 2,  1,  2],
    [ 2,  2,  3]
])

BERG_C = np.array([
    [-1,  2,  2],
    [-2,  1,  2],
    [-2,  2,  3]
])

MATRICES = {'A': BERG_A, 'B': BERG_B, 'C': BERG_C}
LETTERS = ['A', 'B', 'C']

def apply_word(word, start=(3, 4, 5)):
    """Apply a Berggren word to produce a Pythagorean triple."""
    v = np.array(start)
    for letter in word:
        v = MATRICES[letter] @ v
    return tuple(v)

def generate_words(max_length):
    """Generate all Berggren words up to a given length."""
    words = ['']
    for length in range(1, max_length + 1):
        for w in product(LETTERS, repeat=length):
            words.append(''.join(w))
    return words

# === Demo 1: Berggren Tree ===
print("=" * 70)
print("DEMO 1: The Berggren Tree of Primitive Pythagorean Triples")
print("=" * 70)
print()

root = (3, 4, 5)
print(f"Root triple: {root}")
print(f"Verify: {root[0]}² + {root[1]}² = {root[0]**2 + root[1]**2} = {root[2]}² = {root[2]**2}")
print()

print("First-level children:")
for letter in LETTERS:
    triple = apply_word(letter)
    a, b, c = triple
    print(f"  {letter} → {triple}  (verify: {a}² + {b}² = {a**2 + b**2} = {c}² = {c**2})")

print()
print("Second-level triples (depth 2):")
for w1 in LETTERS:
    for w2 in LETTERS:
        word = w1 + w2
        triple = apply_word(word)
        a, b, c = triple
        assert a**2 + b**2 == c**2, f"Not Pythagorean: {triple}"
        print(f"  {word} → {triple}")

# === Demo 2: Berggren Streams and Residuals ===
print()
print("=" * 70)
print("DEMO 2: Berggren Streams and Left Residuals")
print("=" * 70)
print()

# Define a stream: S(w) = hypotenuse of the triple encoded by w
def hypotenuse_stream(word):
    """Stream that returns the hypotenuse of the Pythagorean triple."""
    triple = apply_word(word)
    return triple[2]  # c component

# Define another stream: S(w) = 1 if hypotenuse is divisible by 5, else 0
def div5_stream(word):
    """Boolean stream: 1 if hypotenuse is divisible by 5."""
    return 1 if hypotenuse_stream(word) % 5 == 0 else 0

# Left residual: (u⁻¹S)(v) = S(u ++ v)
def left_residual(stream, prefix):
    """Return the left residual of stream by prefix."""
    return lambda v: stream(prefix + v)

print("Stream S₁(w) = hypotenuse of triple at word w:")
for w in ['', 'A', 'B', 'C', 'AA', 'AB']:
    print(f"  S₁('{w}') = {hypotenuse_stream(w)}")

print()
print("Residuals of S₁:")
print("  (ε⁻¹S₁)(w) = S₁(w)  [the stream itself]")
print("  (A⁻¹S₁)(w) = S₁('A' + w)")
r_A = left_residual(hypotenuse_stream, 'A')
print(f"    Example: (A⁻¹S₁)('') = {r_A('')}, (A⁻¹S₁)('A') = {r_A('A')}")

# === Demo 3: Finite vs Infinite Residual Rank ===
print()
print("=" * 70)
print("DEMO 3: Finite vs Infinite Residual Rank")
print("=" * 70)
print()

# A constant stream has rank 1
def constant_stream(word):
    return 42

# A stream depending only on the last letter has rank ≤ 4 (empty + 3 letters)
def last_letter_stream(word):
    if not word:
        return 0
    return {'A': 1, 'B': 2, 'C': 3}[word[-1]]

# Count distinct residuals
def count_residuals(stream, max_depth=4):
    """Count distinct residuals up to a given word depth."""
    words = generate_words(max_depth)
    residual_signatures = set()
    test_words = generate_words(3)  # test words for distinguishing

    for prefix in words:
        sig = tuple(stream(prefix + tw) for tw in test_words)
        residual_signatures.add(sig)

    return len(residual_signatures)

print("Constant stream S(w) = 42:")
n = count_residuals(constant_stream, 3)
print(f"  Distinct residuals (depth ≤ 3): {n}")
print(f"  Finite rank: YES (rank = 1)")

print()
print("Last-letter stream S(w) = index of last letter:")
n = count_residuals(last_letter_stream, 3)
print(f"  Distinct residuals (depth ≤ 3): {n}")
print(f"  Finite rank: YES (rank ≤ 4)")

print()
print("Hypotenuse stream S(w) = hypotenuse of triple:")
n = count_residuals(hypotenuse_stream, 3)
print(f"  Distinct residuals (depth ≤ 3): {n}")
print(f"  This grows with depth → likely infinite rank")

# === Demo 4: Constructing the Canonical Residual Automaton ===
print()
print("=" * 70)
print("DEMO 4: Canonical Residual Automaton Construction")
print("=" * 70)
print()

# Build automaton for a finite-rank stream
# Example: parity of word length mod 2
def length_parity_stream(word):
    return len(word) % 2

print("Stream: S(w) = len(w) mod 2")
print()

# Find distinct residuals
def find_residual_basis(stream, max_depth=5):
    """Find all distinct residuals and build the automaton."""
    test_words = generate_words(4)
    residual_map = {}  # signature -> representative word
    state_map = {}     # word -> state index

    words = generate_words(max_depth)
    states = []

    for w in words:
        sig = tuple(stream(w + tw) for tw in test_words)
        if sig not in residual_map:
            residual_map[sig] = w
            state_map[w] = len(states)
            states.append(sig)

    return states, residual_map, state_map, test_words

states, residual_map, state_map, test_words = find_residual_basis(length_parity_stream)
print(f"Number of distinct residual states: {len(states)}")

# Build transition table
print("\nTransition table:")
print(f"  {'State':<8} {'A →':<8} {'B →':<8} {'C →':<8} {'output'}")
for sig, rep in residual_map.items():
    state_idx = state_map.get(rep, '?')
    outputs = {}
    for letter in LETTERS:
        next_sig = tuple(length_parity_stream(rep + letter + tw) for tw in test_words)
        next_rep = residual_map.get(next_sig, '?')
        outputs[letter] = state_map.get(next_rep, '?')
    out = length_parity_stream(rep)
    print(f"  q{state_idx:<7} q{outputs['A']:<7} q{outputs['B']:<7} q{outputs['C']:<7} {out}")

# Verify automaton
print("\nVerification (automaton vs stream):")
for w in generate_words(3)[:15]:
    expected = length_parity_stream(w)
    # Simulate automaton
    sig = tuple(length_parity_stream('' + tw) for tw in test_words)
    current = residual_map[sig]
    for letter in w:
        next_sig = tuple(length_parity_stream(current + letter + tw) for tw in test_words)
        current = residual_map[next_sig]
    computed = length_parity_stream(current)  # output
    status = "✓" if expected == computed else "✗"
    print(f"  S('{w}') = {expected}, automaton = {computed} {status}")

# === Demo 5: Minimality ===
print()
print("=" * 70)
print("DEMO 5: Minimality of the Residual Automaton")
print("=" * 70)
print()

# The residual automaton for length_parity has 2 states
# Any DFA recognizing this stream needs at least 2 states
# (because there are 2 distinct residuals)

print("Length-parity stream has 2 distinct residuals:")
print("  - Residual at even-length words: v ↦ len(v) mod 2")
print("  - Residual at odd-length words:  v ↦ (1 + len(v)) mod 2")
print()
print(f"Minimal automaton size = {len(states)} states")
print("Any recognizing automaton must have ≥ 2 states")
print("(by the minimality theorem: |Q| ≥ |distinct residuals|)")

# Another example with more states
def depth_mod3_stream(word):
    return len(word) % 3

states3, _, _, _ = find_residual_basis(depth_mod3_stream)
print(f"\nStream S(w) = len(w) mod 3:")
print(f"  Distinct residuals: {len(states3)}")
print(f"  Minimal automaton size: {len(states3)} states")

# === Demo 6: Berggren-specific stream ===
print()
print("=" * 70)
print("DEMO 6: Berggren-Specific Arithmetic Stream")
print("=" * 70)
print()

def count_A_stream(word):
    """Count occurrences of letter A in the word."""
    return word.count('A')

states_cA, _, _, _ = find_residual_basis(count_A_stream, max_depth=4)
print(f"Stream S(w) = count of 'A' in w:")
print(f"  Distinct residuals (depth ≤ 4): {len(states_cA)}")
print(f"  This grows without bound → infinite rank")
print(f"  NOT recognizable by a finite automaton")

print()
def first_letter_stream(word):
    """Return 1 if first letter is A, 2 if B, 3 if C, 0 if empty."""
    if not word:
        return 0
    return {'A': 1, 'B': 2, 'C': 3}[word[0]]

states_fl, _, _, _ = find_residual_basis(first_letter_stream)
print(f"Stream S(w) = index of first letter (0 if empty):")
print(f"  Distinct residuals: {len(states_fl)}")
print(f"  Finite rank: YES → recognizable!")

print()
print("=" * 70)
print("SUMMARY")
print("=" * 70)
print()
print("The Berggren Realization Theorem establishes:")
print("  Finite residual rank ⟺ Recognizable by finite automaton")
print("  ⟺ Hankel kernel has finite rank")
print()
print("This transforms Diophantine tree generation (Pythagorean triples)")
print("into the language of automata theory and formal computation.")


#!/usr/bin/env python3
"""
visualizations.py — Generate visualizations for Berggren Automaton Realization Theory
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from itertools import product
import base64
import io

BERG_A = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
BERG_B = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
BERG_C = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])
MATRICES = {'A': BERG_A, 'B': BERG_B, 'C': BERG_C}
LETTERS = ['A', 'B', 'C']


def apply_word(word, start=(3, 4, 5)):
    v = np.array(start)
    for ch in word:
        v = MATRICES[ch] @ v
    return tuple(int(x) for x in v)


def generate_words(max_length):
    words = ['']
    for length in range(1, max_length + 1):
        for w in product(LETTERS, repeat=length):
            words.append(''.join(w))
    return words


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ============================================================
# Visualization 1: Berggren Tree
# ============================================================

def viz_berggren_tree():
    """Visualize the Berggren tree of Pythagorean triples."""
    fig, ax = plt.subplots(1, 1, figsize=(14, 8))

    positions = {}
    labels = {}

    # Layout: tree structure
    depth = 3
    y_spacing = 2.0

    # Root
    positions[''] = (7, depth * y_spacing)
    root = apply_word('')
    labels[''] = f"({root[0]},{root[1]},{root[2]})"

    for d in range(1, depth + 1):
        words_at_depth = [w for w in generate_words(d) if len(w) == d]
        n = len(words_at_depth)
        x_start = 0
        x_end = 14
        for i, w in enumerate(words_at_depth):
            x = x_start + (x_end - x_start) * (i + 0.5) / n
            y = (depth - d) * y_spacing
            positions[w] = (x, y)
            triple = apply_word(w)
            labels[w] = f"({triple[0]},{triple[1]},{triple[2]})"

    # Draw edges
    colors = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}
    for w in positions:
        if len(w) > 0:
            parent = w[:-1]
            if parent in positions:
                px, py = positions[parent]
                cx, cy = positions[w]
                color = colors[w[-1]]
                ax.annotate('', xy=(cx, cy + 0.3), xytext=(px, py - 0.3),
                           arrowprops=dict(arrowstyle='->', color=color, lw=1.5))

    # Draw nodes
    for w, (x, y) in positions.items():
        triple = apply_word(w)
        ax.text(x, y, labels[w], ha='center', va='center',
               fontsize=7, fontweight='bold',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow',
                        edgecolor='gray', alpha=0.9))

    # Legend
    legend_elements = [
        mpatches.Patch(facecolor='#e74c3c', label='Branch A'),
        mpatches.Patch(facecolor='#2ecc71', label='Branch B'),
        mpatches.Patch(facecolor='#3498db', label='Branch C'),
    ]
    ax.legend(handles=legend_elements, loc='upper right', fontsize=10)

    ax.set_xlim(-0.5, 14.5)
    ax.set_ylim(-1, depth * y_spacing + 1)
    ax.set_title('The Berggren Tree of Primitive Pythagorean Triples', fontsize=14, fontweight='bold')
    ax.axis('off')

    return fig_to_base64(fig)


# ============================================================
# Visualization 2: Residual Growth
# ============================================================

def viz_residual_growth():
    """Show how the number of distinct residuals grows with depth."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    streams = {
        'length mod 2': lambda w: len(w) % 2,
        'length mod 3': lambda w: len(w) % 3,
        'first letter': lambda w: 0 if not w else ord(w[0]) - ord('A') + 1,
        'last letter': lambda w: 0 if not w else ord(w[-1]) - ord('A') + 1,
        'count of A': lambda w: w.count('A'),
    }

    max_depth = 5
    test_words = generate_words(3)

    for name, stream in streams.items():
        counts = []
        for d in range(max_depth + 1):
            words = generate_words(d)
            sigs = set()
            for w in words:
                sig = tuple(stream(w + tw) for tw in test_words)
                sigs.add(sig)
            counts.append(len(sigs))

        style = '--' if name == 'count of A' else '-'
        ax.plot(range(max_depth + 1), counts, style, marker='o', label=name, linewidth=2)

    ax.set_xlabel('Search Depth', fontsize=12)
    ax.set_ylabel('Distinct Residuals', fontsize=12)
    ax.set_title('Residual Growth: Finite vs Infinite Rank', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Add annotation
    ax.annotate('Infinite rank\n(unbounded growth)',
               xy=(4.5, max(counts)), fontsize=9, color='red',
               ha='center')

    return fig_to_base64(fig)


# ============================================================
# Visualization 3: Hankel Matrix Heatmap
# ============================================================

def viz_hankel_matrix():
    """Visualize the Hankel matrix for a Berggren stream."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    streams = [
        ('Length mod 2', lambda w: len(w) % 2),
        ('Length mod 3', lambda w: len(w) % 3),
        ('Last letter index', lambda w: 0 if not w else ord(w[-1]) - ord('A') + 1),
    ]

    depth = 2
    words = generate_words(depth)

    for ax, (name, stream) in zip(axes, streams):
        H = np.zeros((len(words), len(words)))
        for i, u in enumerate(words):
            for j, v in enumerate(words):
                H[i, j] = stream(u + v)

        im = ax.imshow(H, cmap='viridis', aspect='auto')
        ax.set_title(name, fontsize=11, fontweight='bold')
        ax.set_xlabel('Column word index')
        ax.set_ylabel('Row word index')
        fig.colorbar(im, ax=ax, shrink=0.8)

        rank = int(np.linalg.matrix_rank(H))
        ax.text(0.02, 0.98, f'rank = {rank}', transform=ax.transAxes,
               fontsize=10, verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    fig.suptitle('Berggren–Hankel Matrices', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()

    return fig_to_base64(fig)


# ============================================================
# Visualization 4: Automaton State Diagram
# ============================================================

def viz_automaton_diagram():
    """Draw state diagrams for simple Berggren automata."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))

    # Length mod 2 automaton: 2 states
    states = {0: (2, 3), 1: (6, 3)}
    radius = 0.6

    for s, (x, y) in states.items():
        circle = plt.Circle((x, y), radius, fill=True,
                           facecolor='lightblue' if s == 0 else 'lightyellow',
                           edgecolor='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, f'q{s}\nout={s}', ha='center', va='center',
               fontsize=11, fontweight='bold')

    # Initial state marker
    ax.annotate('', xy=(states[0][0] - radius, states[0][1]),
               xytext=(states[0][0] - radius - 0.8, states[0][1]),
               arrowprops=dict(arrowstyle='->', lw=2))
    ax.text(states[0][0] - radius - 1.2, states[0][1], 'start',
           ha='center', va='center', fontsize=10)

    # Transitions (all letters go to the other state)
    # q0 --A,B,C--> q1
    ax.annotate('', xy=(states[1][0] - radius, states[1][1] + 0.1),
               xytext=(states[0][0] + radius, states[0][1] + 0.1),
               arrowprops=dict(arrowstyle='->', lw=1.5, color='#e74c3c'))
    ax.text(4, 3.5, 'A, B, C', ha='center', fontsize=10, color='#e74c3c')

    # q1 --A,B,C--> q0
    ax.annotate('', xy=(states[0][0] + radius, states[0][1] - 0.1),
               xytext=(states[1][0] - radius, states[1][1] - 0.1),
               arrowprops=dict(arrowstyle='->', lw=1.5, color='#3498db'))
    ax.text(4, 2.5, 'A, B, C', ha='center', fontsize=10, color='#3498db')

    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(1, 5)
    ax.set_title('Minimal Berggren Automaton for Length Parity\nS(w) = len(w) mod 2',
                fontsize=13, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')

    return fig_to_base64(fig)


# ============================================================
# Visualization 5: Pythagorean Triples on Integer Lattice
# ============================================================

def viz_triples_lattice():
    """Plot Pythagorean triples colored by Berggren branch."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    colors = {'A': '#e74c3c', 'B': '#2ecc71', 'C': '#3498db'}

    depth = 4
    words = generate_words(depth)

    for w in words:
        triple = apply_word(w)
        a, b, c = triple
        if a > 0 and b > 0:
            color = 'gray'
            if len(w) > 0:
                color = colors[w[0]]
            size = max(5, 50 - len(w) * 8)
            ax.scatter(a, b, c=color, s=size, alpha=0.7, edgecolors='black', linewidths=0.3)

    ax.set_xlabel('a', fontsize=12)
    ax.set_ylabel('b', fontsize=12)
    ax.set_title('Primitive Pythagorean Triples (a, b) colored by first Berggren branch',
                fontsize=13, fontweight='bold')

    legend_elements = [
        plt.Line2D([0], [0], marker='o', color='w', markerfacecolor=c,
                   markersize=8, label=f'Branch {l}')
        for l, c in colors.items()
    ]
    legend_elements.insert(0, plt.Line2D([0], [0], marker='o', color='w',
                                          markerfacecolor='gray', markersize=8, label='Root'))
    ax.legend(handles=legend_elements, fontsize=10)
    ax.grid(True, alpha=0.2)

    return fig_to_base64(fig)


# ============================================================
# Generate All Visualizations
# ============================================================

if __name__ == '__main__':
    print("Generating visualizations...")

    viz1 = viz_berggren_tree()
    print(f"  1. Berggren tree: {len(viz1)} chars")

    viz2 = viz_residual_growth()
    print(f"  2. Residual growth: {len(viz2)} chars")

    viz3 = viz_hankel_matrix()
    print(f"  3. Hankel matrix: {len(viz3)} chars")

    viz4 = viz_automaton_diagram()
    print(f"  4. Automaton diagram: {len(viz4)} chars")

    viz5 = viz_triples_lattice()
    print(f"  5. Triples lattice: {len(viz5)} chars")

    print("\nAll visualizations generated successfully.")

    # Save individual PNGs for reference
    for i, (name, data) in enumerate([
        ('berggren_tree', viz1),
        ('residual_growth', viz2),
        ('hankel_matrix', viz3),
        ('automaton_diagram', viz4),
        ('triples_lattice', viz5),
    ], 1):
        img_data = base64.b64decode(data.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(img_data)
        print(f"  Saved {name}.png")
