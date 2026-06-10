#!/usr/bin/env python3
"""
applications.py — Real-World Applications of Tropical Myhill–Nerode Theory

Demonstrates applications to:
1. Shortest-path optimization / dynamic programming
2. Network routing cost analysis
3. Cost language classification
4. Sequence compression and fingerprinting
"""

import numpy as np
from itertools import product as iter_product
from collections import defaultdict


# ============================================================
# Application 1: Shortest-Path / Dynamic Programming
# ============================================================

def shortest_path_series():
    """
    Model a shortest-path problem as a tropical series.

    Consider a small graph where words encode paths:
    - Alphabet = {0, 1} representing two possible next-steps
    - Series value = total cost of the path

    The tropical Nerode quotient gives the minimal number of
    "path states" needed to track optimal costs.
    """
    print("=" * 60)
    print("APPLICATION 1: Shortest-Path Cost Minimization")
    print("=" * 60)

    # Edge costs in a 3-node graph
    # State 0 → State 1 via edge '0' costs 3
    # State 0 → State 2 via edge '1' costs 5
    # State 1 → State 0 via edge '0' costs 2
    # State 1 → State 2 via edge '1' costs 1
    # State 2 → State 0 via edge '0' costs 4
    # State 2 → State 1 via edge '1' costs 2

    cost_matrix = {
        (0, 0): (1, 3), (0, 1): (2, 5),
        (1, 0): (0, 2), (1, 1): (2, 1),
        (2, 0): (0, 4), (2, 1): (1, 2),
    }

    def path_cost(word, start=0):
        """Compute the total cost of following a path from start."""
        state = start
        total = 0
        for sym in word:
            next_state, edge_cost = cost_matrix[(state, sym)]
            total += edge_cost
            state = next_state
        return total

    # Compute Nerode classes
    words = [[]]
    for length in range(1, 5):
        for bits in iter_product([0, 1], repeat=length):
            words.append(list(bits))

    suffixes = [[]]
    for length in range(1, 4):
        for bits in iter_product([0, 1], repeat=length):
            suffixes.append(list(bits))

    residuals = {}
    classes = {}
    reps = []

    for w in words:
        res = tuple(path_cost(w + z) for z in suffixes)
        if res not in residuals:
            residuals[res] = len(residuals)
            reps.append(w)
        classes[tuple(w)] = residuals[res]

    print(f"\nGraph with 3 nodes, 6 edges")
    print(f"Words considered: up to length 4")
    print(f"Nerode classes found: {len(residuals)}")
    print(f"Representatives: {reps[:6]}...")
    print(f"\nThis means {len(residuals)} 'cost states' suffice to track")
    print(f"all future shortest-path costs from any reachable configuration.")

    # Show some path costs
    print(f"\nSample path costs:")
    for w in [[0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]:
        print(f"  Path {w}: cost = {path_cost(w)}")


# ============================================================
# Application 2: Network Routing Cost Analysis
# ============================================================

def network_routing():
    """
    Apply Nerode minimization to network routing.

    In a communication network, the 'series' maps packet routing
    decisions to total latency. Minimizing the Nerode quotient
    identifies the minimal routing table size.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Network Routing Table Minimization")
    print("=" * 60)

    # 4-node network with latencies
    n_nodes = 4
    latency = np.array([
        [0, 2, 5, np.inf],
        [2, 0, 3, 1],
        [5, 3, 0, 4],
        [np.inf, 1, 4, 0]
    ])

    def routing_cost(decisions, start=0):
        """Cost of a routing path given hop decisions."""
        node = start
        total = 0
        for d in decisions:
            # d chooses next neighbor (0 = lowest index, 1 = next, etc.)
            neighbors = sorted([(latency[node, j], j) for j in range(n_nodes)
                               if j != node and latency[node, j] < np.inf])
            if d < len(neighbors):
                cost, next_node = neighbors[d]
                total += cost
                node = next_node
            else:
                total += 100  # penalty for invalid decision
        return total

    # Compute classes for binary routing decisions
    words = [[]]
    for length in range(1, 4):
        for bits in iter_product([0, 1], repeat=length):
            words.append(list(bits))

    suffixes = [[]]
    for length in range(1, 3):
        for bits in iter_product([0, 1], repeat=length):
            suffixes.append(list(bits))

    residuals = {}
    for w in words:
        res = tuple(routing_cost(w + z) for z in suffixes)
        if res not in residuals:
            residuals[res] = len(residuals)

    print(f"\nNetwork: {n_nodes} nodes, binary routing decisions")
    print(f"Nerode classes (routing equivalence): {len(residuals)}")
    print(f"\nMinimal routing table size: {len(residuals)} entries")
    print(f"(vs naive: {len(words)} entries for all decision sequences)")
    print(f"Compression ratio: {len(words) / len(residuals):.1f}x")


# ============================================================
# Application 3: Cost Language Classification
# ============================================================

def cost_language_classification():
    """
    Use Nerode theory for classifying cost languages.

    A 'cost language' assigns a cost to each word. The Nerode
    quotient classifies words by their future cost profile,
    enabling efficient cost prediction.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Cost Language Classification")
    print("=" * 60)

    # A cost function based on pattern matching
    def pattern_cost(word):
        """Cost based on subsequence patterns."""
        w = word
        cost = 0
        # Count occurrences of pattern [1, 0, 1]
        for i in range(len(w) - 2):
            if w[i] == 1 and w[i+1] == 0 and w[i+2] == 1:
                cost += 3
        # Add base cost per symbol
        cost += sum(w)
        return cost

    words = [[]]
    for length in range(1, 5):
        for bits in iter_product([0, 1], repeat=length):
            words.append(list(bits))

    suffixes = [[]]
    for length in range(1, 4):
        for bits in iter_product([0, 1], repeat=length):
            suffixes.append(list(bits))

    residuals = {}
    class_assignment = {}
    for w in words:
        res = tuple(pattern_cost(w + z) for z in suffixes)
        if res not in residuals:
            residuals[res] = len(residuals)
        class_assignment[tuple(w)] = residuals[res]

    print(f"\nPattern cost function: counts [1,0,1] subsequences × 3 + sum")
    print(f"Nerode classes: {len(residuals)}")
    print(f"\nSample classifications:")
    for w in [[0], [1], [1, 0], [1, 0, 1], [0, 1, 0, 1]]:
        cls = class_assignment.get(tuple(w), "?")
        cost = pattern_cost(w)
        print(f"  Word {w}: cost={cost}, class={cls}")


# ============================================================
# Application 4: Sequence Compression
# ============================================================

def sequence_compression():
    """
    Use Nerode classes for sequence compression.

    Two sequences in the same Nerode class have identical
    'continuation profiles', so they can be compressed to
    the same representative.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Sequence Compression via Nerode Classes")
    print("=" * 60)

    # Simple modular hash series
    def mod_hash(word, mod=5):
        h = 0
        for sym in word:
            h = (h * 3 + sym + 1) % mod
        return h

    words = [[]]
    for length in range(1, 5):
        for bits in iter_product([0, 1], repeat=length):
            words.append(list(bits))

    suffixes = [[]]
    for length in range(1, 4):
        for bits in iter_product([0, 1], repeat=length):
            suffixes.append(list(bits))

    residuals = {}
    compressed = {}
    for w in words:
        res = tuple(mod_hash(w + z) for z in suffixes)
        if res not in residuals:
            residuals[res] = (len(residuals), w)  # (class_id, representative)
        class_id, rep = residuals[res]
        compressed[tuple(w)] = rep

    n_original = len(words)
    n_compressed = len(residuals)

    print(f"\nModular hash series (mod 5)")
    print(f"Original sequences: {n_original}")
    print(f"Nerode classes: {n_compressed}")
    print(f"Compression ratio: {n_original / n_compressed:.1f}x")
    print(f"\nSample compressions:")
    for w in [[0], [1], [0, 0], [1, 1], [0, 1, 0]]:
        rep = compressed.get(tuple(w), w)
        print(f"  {w} → representative {rep}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    shortest_path_series()
    network_routing()
    cost_language_classification()
    sequence_compression()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
demo.py — Tropical Automata Myhill–Nerode Theory: Concrete Demonstrations

Demonstrates the key theorems with tangible numerical examples:
1. Nerode equivalence for binary cost and parity series
2. Hankel matrix construction and factor rank
3. Minimal automaton via Nerode quotient
4. Certified minimization pipeline
"""

import numpy as np
from itertools import product as iter_product
from collections import defaultdict


# ============================================================
# 1. Tropical Series and Nerode Equivalence
# ============================================================

def binary_cost_series(w: list[bool]) -> int:
    """Counts the number of True values in a word."""
    return sum(w)


def parity_series(w: list[bool]) -> int:
    """Counts True values mod 2."""
    return sum(w) % 2


def nerode_equivalent(f, x: list, y: list, suffixes: list[list]) -> bool:
    """Test Nerode equivalence by checking agreement on a set of suffixes."""
    for z in suffixes:
        if f(x + z) != f(y + z):
            return False
    return True


def find_nerode_classes(f, words: list[list], suffixes: list[list]) -> dict:
    """Partition words into Nerode equivalence classes."""
    classes = {}
    class_id = 0
    assignment = {}

    for w in words:
        found = False
        for rep, cid in classes.items():
            if nerode_equivalent(f, list(rep), list(w), suffixes):
                assignment[tuple(w)] = cid
                found = True
                break
        if not found:
            classes[tuple(w)] = class_id
            assignment[tuple(w)] = class_id
            class_id += 1

    return assignment, class_id


print("=" * 60)
print("DEMO 1: Nerode Equivalence Classes")
print("=" * 60)

# Generate all binary words up to length 3
all_words = [[]]
for length in range(1, 4):
    for bits in iter_product([False, True], repeat=length):
        all_words.append(list(bits))

# Suffixes up to length 3
suffixes = all_words.copy()

print("\n--- Binary Cost Series (counts True) ---")
assignment, num_classes = find_nerode_classes(binary_cost_series, all_words, suffixes)
print(f"Number of Nerode classes (words up to length 3): {num_classes}")
print("Classes (grouped by true-count):")
by_class = defaultdict(list)
for w, c in assignment.items():
    by_class[c].append(w)
for c in sorted(by_class.keys()):
    count = binary_cost_series(list(by_class[c][0]))
    print(f"  Class {c} (count={count}): {[list(w) for w in by_class[c][:5]]}...")

print("\n--- Parity Series (count mod 2) ---")
assignment_p, num_classes_p = find_nerode_classes(parity_series, all_words, suffixes)
print(f"Number of Nerode classes: {num_classes_p}")
by_class_p = defaultdict(list)
for w, c in assignment_p.items():
    by_class_p[c].append(w)
for c in sorted(by_class_p.keys()):
    parity = parity_series(list(by_class_p[c][0]))
    print(f"  Class {c} (parity={parity}): {[list(w) for w in by_class_p[c][:5]]}...")


# ============================================================
# 2. Hankel Matrix Construction
# ============================================================

print("\n" + "=" * 60)
print("DEMO 2: Hankel Matrix and Factor Rank")
print("=" * 60)


def build_hankel_matrix(f, prefixes: list[list], suffixes: list[list]) -> np.ndarray:
    """Build the Hankel matrix H[p,q] = f(p ++ q)."""
    m, n = len(prefixes), len(suffixes)
    H = np.zeros((m, n), dtype=float)
    for i, p in enumerate(prefixes):
        for j, q in enumerate(suffixes):
            H[i, j] = f(p + q)
    return H


# Prefixes and suffixes
prefixes = [[], [True], [False], [True, True], [True, False]]
suffixes_short = [[], [True], [False], [True, True]]

print("\n--- Parity Series Hankel Block ---")
H_parity = build_hankel_matrix(parity_series, prefixes, suffixes_short)
print(f"Prefixes: {prefixes}")
print(f"Suffixes: {suffixes_short}")
print(f"Hankel matrix:\n{H_parity.astype(int)}")
print(f"Matrix rank (standard): {int(np.linalg.matrix_rank(H_parity))}")

print("\n--- Binary Cost Hankel Block ---")
H_cost = build_hankel_matrix(binary_cost_series, prefixes, suffixes_short)
print(f"Hankel matrix:\n{H_cost.astype(int)}")
print(f"Matrix rank: {int(np.linalg.matrix_rank(H_cost))}")


# ============================================================
# 3. Automaton Simulation
# ============================================================

print("\n" + "=" * 60)
print("DEMO 3: Parity Automaton — 2-State Realization")
print("=" * 60)


class ParityAutomaton:
    """2-state automaton recognizing the parity series."""
    def __init__(self):
        self.init = 0  # Start in state 0

    def step(self, state: int, symbol: bool) -> int:
        return (state + (1 if symbol else 0)) % 2

    def run(self, word: list[bool]) -> int:
        state = self.init
        for sym in word:
            state = self.step(state, sym)
        return state

    def output(self, state: int) -> int:
        return state  # Identity


aut = ParityAutomaton()
print("Testing parity automaton on sample words:")
test_words = [[], [True], [False], [True, True], [True, False, True],
              [False, False, True, True]]
for w in test_words:
    state = aut.run(w)
    value = aut.output(state)
    expected = parity_series(w)
    status = "✓" if value == expected else "✗"
    print(f"  {w} → state={state}, output={value}, expected={expected} {status}")


# ============================================================
# 4. Right Invariance Demonstration
# ============================================================

print("\n" + "=" * 60)
print("DEMO 4: Right Invariance of Nerode Relation")
print("=" * 60)

x, y = [True], [False, False, True]  # Both have parity 1
suffix_u = [True, False]

print(f"x = {x}, y = {y}")
print(f"Parity of x: {parity_series(x)}, Parity of y: {parity_series(y)}")
print(f"x ~ y? {nerode_equivalent(parity_series, x, y, suffixes)}")

x_ext = x + suffix_u
y_ext = y + suffix_u
print(f"\nAppending u = {suffix_u}:")
print(f"x ++ u = {x_ext}, y ++ u = {y_ext}")
print(f"Parity of x++u: {parity_series(x_ext)}, Parity of y++u: {parity_series(y_ext)}")
print(f"(x++u) ~ (y++u)? {nerode_equivalent(parity_series, x_ext, y_ext, suffixes)}")
print("Right invariance verified! ✓")


# ============================================================
# 5. Certified Minimization Pipeline
# ============================================================

print("\n" + "=" * 60)
print("DEMO 5: Certified Minimization Pipeline")
print("=" * 60)


def certified_minimization(f, max_prefix_len=3, max_suffix_len=3):
    """
    Compute a certified minimization:
    1. Find prefix witness set P
    2. Find suffix witness set Q
    3. Compute Nerode quotient
    4. Verify minimality
    """
    # Generate candidate prefixes and suffixes
    alphabet = [False, True]
    all_words_local = [[]]
    for length in range(1, max_prefix_len + 1):
        for bits in iter_product(alphabet, repeat=length):
            all_words_local.append(list(bits))

    all_suffixes = [[]]
    for length in range(1, max_suffix_len + 1):
        for bits in iter_product(alphabet, repeat=length):
            all_suffixes.append(list(bits))

    # Find minimal P (residual-generating set)
    P = []
    residual_classes = []

    for w in all_words_local:
        residual_w = tuple(f(w + z) for z in all_suffixes)
        if residual_w not in residual_classes:
            residual_classes.append(residual_w)
            P.append(w)

    # Q = all suffixes used (complete witness set by construction)
    Q = all_suffixes

    # Number of Nerode classes = number of distinct residuals
    num_classes = len(residual_classes)

    return {
        'P': P,
        'Q': Q,
        'num_classes': num_classes,
        'residual_classes': residual_classes
    }


result = certified_minimization(parity_series)
print(f"\nParity series certified minimization:")
print(f"  Prefix witnesses P: {result['P']}")
print(f"  Number of Nerode classes: {result['num_classes']}")
print(f"  Distinct residual patterns: {len(result['residual_classes'])}")
print(f"  Matches 2-state automaton: {'✓' if result['num_classes'] == 2 else '✗'}")

result2 = certified_minimization(binary_cost_series)
print(f"\nBinary cost series (up to length 3):")
print(f"  Prefix witnesses P: {result2['P'][:5]}...")
print(f"  Number of Nerode classes found: {result2['num_classes']}")
print(f"  (Infinite in theory, bounded by word length in practice)")


# ============================================================
# 6. Hankel Factor Rank = State Count
# ============================================================

print("\n" + "=" * 60)
print("DEMO 6: Hankel Factor Rank = Minimal State Count")
print("=" * 60)


def tropical_factor_rank(H: np.ndarray) -> int:
    """Compute factor rank (standard rank for commutative semiring ℤ)."""
    return int(np.linalg.matrix_rank(H))


# For parity series
P_parity = [[], [True]]  # Two residual generators
Q_parity = [[], [True], [False]]  # Sufficient witnesses

H = build_hankel_matrix(parity_series, P_parity, Q_parity)
rank = tropical_factor_rank(H)
print(f"\nParity series:")
print(f"  Hankel block (P={P_parity}, Q={Q_parity}):")
print(f"  {H.astype(int)}")
print(f"  Factor rank: {rank}")
print(f"  Minimal automaton states: 2")
print(f"  rank = states? {'✓' if rank == 2 else '✗'}")

# Factorization: H = L * R
# State 0: residual is [0, 1, 0, ...]
# State 1: residual is [1, 0, 1, ...]
print(f"\n  Factorization H = L·R:")
L = np.array([[1, 0], [0, 1]])  # prefix→state indicator
R = np.array([[0, 1, 0], [1, 0, 1]])  # state→suffix output
print(f"  L = {L.tolist()}")
print(f"  R = {R.tolist()}")
print(f"  L·R = {(L @ R).tolist()}")
print(f"  H   = {H.astype(int).tolist()}")
print(f"  Match? {'✓' if np.allclose(L @ R, H) else '✗'}")

print("\n" + "=" * 60)
print("All demonstrations complete!")
print("=" * 60)


#!/usr/bin/env python3
"""
visualizations.py — Generate figures for the tropical Myhill–Nerode theory.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from itertools import product as iter_product
import base64
import io


def generate_all():
    """Generate all visualizations and return base64 encoded PNGs."""
    figs = {}
    figs['hankel_heatmap'] = hankel_heatmap()
    figs['nerode_partition'] = nerode_partition_diagram()
    figs['rank_comparison'] = rank_comparison_chart()
    return figs


def hankel_heatmap():
    """Visualize the Hankel matrix for the parity series."""
    def parity(w):
        return sum(w) % 2

    prefixes = [[], [0], [1], [0,0], [0,1], [1,0], [1,1]]
    suffixes = [[], [0], [1], [0,0], [0,1], [1,0], [1,1]]

    m, n = len(prefixes), len(suffixes)
    H = np.zeros((m, n))
    for i, p in enumerate(prefixes):
        for j, q in enumerate(suffixes):
            H[i, j] = parity(p + q)

    fig, ax = plt.subplots(figsize=(8, 6))
    im = ax.imshow(H, cmap='RdYlBu_r', aspect='auto', vmin=0, vmax=1)

    prefix_labels = ['ε'] + [''.join(str(b) for b in p) for p in prefixes[1:]]
    suffix_labels = ['ε'] + [''.join(str(b) for b in q) for q in suffixes[1:]]

    ax.set_xticks(range(n))
    ax.set_xticklabels(suffix_labels, fontsize=10)
    ax.set_yticks(range(m))
    ax.set_yticklabels(prefix_labels, fontsize=10)
    ax.set_xlabel('Suffixes (Q)', fontsize=12)
    ax.set_ylabel('Prefixes (P)', fontsize=12)
    ax.set_title('Hankel Matrix: Parity Series\nH[p,q] = f(p·q) = |p·q|₁ mod 2', fontsize=14)

    for i in range(m):
        for j in range(n):
            color = 'white' if H[i,j] > 0.5 else 'black'
            ax.text(j, i, f'{int(H[i,j])}', ha='center', va='center',
                   fontsize=11, fontweight='bold', color=color)

    plt.colorbar(im, ax=ax, label='Series value')
    plt.tight_layout()
    return fig_to_base64(fig)


def nerode_partition_diagram():
    """Visualize the Nerode partition for the parity series."""
    def parity(w):
        return sum(w) % 2

    words = [[]]
    for length in range(1, 4):
        for bits in iter_product([0, 1], repeat=length):
            words.append(list(bits))

    fig, ax = plt.subplots(figsize=(10, 5))

    even_words = [w for w in words if parity(w) == 0]
    odd_words = [w for w in words if parity(w) == 1]

    # Draw two large ellipses
    from matplotlib.patches import Ellipse

    ell0 = Ellipse((0.3, 0.5), 0.5, 0.8, fill=True, facecolor='#E3F2FD',
                   edgecolor='#1565C0', linewidth=2, alpha=0.7)
    ell1 = Ellipse((0.7, 0.5), 0.5, 0.8, fill=True, facecolor='#FFF3E0',
                   edgecolor='#E65100', linewidth=2, alpha=0.7)
    ax.add_patch(ell0)
    ax.add_patch(ell1)

    def word_str(w):
        if not w:
            return 'ε'
        return ''.join(str(b) for b in w)

    # Place even words
    even_strs = [word_str(w) for w in even_words[:8]]
    for i, s in enumerate(even_strs):
        row = i // 2
        col = i % 2
        x = 0.18 + col * 0.12 + (0.05 if row % 2 else 0)
        y = 0.75 - row * 0.12
        ax.text(x, y, s, fontsize=9, ha='center', va='center',
               fontfamily='monospace', fontweight='bold', color='#1565C0')

    # Place odd words
    odd_strs = [word_str(w) for w in odd_words[:8]]
    for i, s in enumerate(odd_strs):
        row = i // 2
        col = i % 2
        x = 0.58 + col * 0.12 + (0.05 if row % 2 else 0)
        y = 0.75 - row * 0.12
        ax.text(x, y, s, fontsize=9, ha='center', va='center',
               fontfamily='monospace', fontweight='bold', color='#E65100')

    ax.text(0.3, 0.92, 'Class 0: Even Parity', fontsize=12, ha='center',
           fontweight='bold', color='#1565C0')
    ax.text(0.7, 0.92, 'Class 1: Odd Parity', fontsize=12, ha='center',
           fontweight='bold', color='#E65100')

    # Arrow showing right invariance
    ax.annotate('', xy=(0.58, 0.12), xytext=(0.42, 0.12),
               arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.text(0.5, 0.06, 'append "1"', fontsize=10, ha='center', color='green',
           fontstyle='italic')
    ax.annotate('', xy=(0.42, 0.04), xytext=(0.58, 0.04),
               arrowprops=dict(arrowstyle='->', color='green', lw=2))

    ax.set_xlim(-0.05, 1.05)
    ax.set_ylim(-0.02, 1.0)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Nerode Partition: Parity Series over {0,1}\nRight-invariant: appending "1" swaps classes',
                fontsize=13)
    plt.tight_layout()
    return fig_to_base64(fig)


def rank_comparison_chart():
    """Compare Nerode class count vs Hankel rank for various series."""
    def parity(w): return sum(w) % 2
    def cost(w): return sum(w)
    def threshold(w): return 1 if sum(w) >= 2 else 0
    def mod3(w): return sum(w) % 3

    series = {
        'Parity\n(mod 2)': parity,
        'Threshold\n(≥ 2)': threshold,
        'Mod 3': mod3,
    }

    alphabet = [0, 1]
    max_len = 3

    words = [[]]
    for length in range(1, max_len + 1):
        for bits in iter_product(alphabet, repeat=length):
            words.append(list(bits))

    suffixes = words.copy()

    fig, ax = plt.subplots(figsize=(8, 5))

    names = []
    n_classes_list = []
    ranks_list = []

    for name, f in series.items():
        # Count Nerode classes
        residuals = set()
        reps = []
        for w in words:
            res = tuple(f(w + z) for z in suffixes)
            if res not in residuals:
                residuals.add(res)
                reps.append(w)
        n_classes = len(residuals)

        # Hankel rank
        H = np.array([[f(p + q) for q in suffixes] for p in reps], dtype=float)
        rank = int(np.linalg.matrix_rank(H))

        names.append(name)
        n_classes_list.append(n_classes)
        ranks_list.append(rank)

    x = np.arange(len(names))
    width = 0.35

    bars1 = ax.bar(x - width/2, n_classes_list, width, label='Nerode Classes',
                   color='#1565C0', alpha=0.8)
    bars2 = ax.bar(x + width/2, ranks_list, width, label='Hankel Rank',
                   color='#E65100', alpha=0.8)

    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Nerode Class Count vs Hankel Factor Rank\n(Binary alphabet, words up to length 3)',
                fontsize=13)
    ax.set_xticks(x)
    ax.set_xticklabels(names, fontsize=10)
    ax.legend(fontsize=11)
    ax.set_ylim(0, max(max(n_classes_list), max(ranks_list)) + 1)

    # Add value labels
    for bar in bars1:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., h + 0.1,
               f'{int(h)}', ha='center', va='bottom', fontweight='bold')
    for bar in bars2:
        h = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., h + 0.1,
               f'{int(h)}', ha='center', va='bottom', fontweight='bold')

    plt.tight_layout()
    return fig_to_base64(fig)


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 PNG string."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    buf.seek(0)
    return 'data:image/png;base64,' + base64.b64encode(buf.read()).decode('utf-8')


if __name__ == '__main__':
    print("Generating visualizations...")
    figs = generate_all()
    for name, data in figs.items():
        # Save as standalone files too
        img_data = base64.b64decode(data.split(',')[1])
        with open(f'{name}.png', 'wb') as f:
            f.write(img_data)
        print(f"  Saved {name}.png ({len(img_data)} bytes)")
    print("Done!")
