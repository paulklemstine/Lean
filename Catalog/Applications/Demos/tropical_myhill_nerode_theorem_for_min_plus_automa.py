#!/usr/bin/env python3
"""
Tropical Myhill–Nerode: Applications

Real-world applications of the tropical Myhill–Nerode theorem:
1. Shortest-path compression in network routing
2. Cost automata for resource-bounded computation
3. Dynamic programming state compression
4. Weighted pattern matching optimization
"""

from algorithms import NerodeAutomaton, TropicalDFA, generate_words
from typing import List, Dict, Tuple

INF = float('inf')


# ===========================================================================
# Application 1: Network Routing Cost Compression
# ===========================================================================

def network_routing_demo():
    """
    Application: Shortest-path cost compression.

    Consider a network where paths are labeled by sequences of link types.
    The cost of a path is the sum of link costs with possible discounts.

    The tropical Myhill–Nerode theorem tells us: if the cost function has
    finitely many distinct "future cost profiles" (residuals), then there
    exists a minimal finite-state cost computer.
    """
    print("=" * 70)
    print("APPLICATION 1: Network Routing Cost Compression")
    print("=" * 70)

    # Link types: 'f' = fiber (cost 1), 'w' = wireless (cost 3), 's' = satellite (cost 5)
    alphabet = ['f', 'w', 's']
    costs = {'f': 1, 'w': 3, 's': 5}

    # Cost = sum of link costs, but capped at 10 (max observable cost)
    def routing_cost(path: List[str]) -> float:
        return min(sum(costs[c] for c in path), 10)

    nerode = NerodeAutomaton(routing_cost, alphabet, max_word_len=5, probe_len=4)

    print(f"\nMinimal states needed for cost computation: {nerode.num_states()}")
    print("(Each state represents a distinct 'remaining cost profile'.)")

    print("\nSample path costs:")
    test_paths = [
        [], ['f'], ['w'], ['s'],
        ['f', 'f', 'f'], ['w', 'w', 'w'],
        ['f', 'w', 's'], ['s', 's'],
    ]
    for path in test_paths:
        cost = nerode.evaluate(path)
        path_str = '→'.join(path) if path else '(start)'
        print(f"  Path {path_str}: cost = {cost}")

    print(f"\nA naive router might track full path history.")
    print(f"The Myhill–Nerode theorem proves {nerode.num_states()} states suffice.")


# ===========================================================================
# Application 2: Resource-Bounded Computation
# ===========================================================================

def resource_bounded_computation():
    """
    Application: Resource monitors for bounded computation.

    Model a system where operations consume resources (CPU cycles, memory).
    The "cost" of an operation sequence is the total resource consumption.
    The Nerode automaton gives the minimal monitor.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Resource-Bounded Computation Monitor")
    print("=" * 70)

    # Operations: 'r' = read (1 unit), 'w' = write (2 units), 'c' = compute (3 units)
    alphabet = ['r', 'w', 'c']
    op_costs = {'r': 1, 'w': 2, 'c': 3}
    BUDGET = 8

    def resource_usage(ops: List[str]) -> float:
        """Cost = min(total resource usage, budget). Over-budget = budget."""
        return min(sum(op_costs[op] for op in ops), BUDGET)

    nerode = NerodeAutomaton(resource_usage, alphabet, max_word_len=5, probe_len=4)

    print(f"\nResource budget: {BUDGET} units")
    print(f"Minimal monitor states: {nerode.num_states()}")
    print("(Each state tracks a distinct 'remaining budget profile'.)")

    # Syntactic monoid
    monoid = nerode.compute_syntactic_monoid(max_word_len=4)
    print(f"Syntactic monoid size: {len(monoid)}")

    print("\nSample operation sequences:")
    sequences = [
        [], ['r'], ['c'], ['r', 'w', 'c'],
        ['c', 'c', 'c'], ['r'] * 8,
    ]
    for seq in sequences:
        cost = nerode.evaluate(seq)
        seq_str = '→'.join(seq) if seq else '(idle)'
        print(f"  {seq_str}: resource usage = {cost}")


# ===========================================================================
# Application 3: Dynamic Programming State Compression
# ===========================================================================

def dp_state_compression():
    """
    Application: Dynamic programming state compression.

    In DP, the "state" after processing a prefix determines the optimal
    cost-to-go for any suffix. The tropical Nerode equivalence identifies
    prefixes with identical cost-to-go functions — compressing the DP table.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Dynamic Programming State Compression")
    print("=" * 70)

    # A DP problem: sequence alignment-like cost
    alphabet = ['0', '1']

    def alignment_cost(seq: List[str]) -> float:
        """Cost = number of transitions (0→1 or 1→0) in the sequence."""
        if len(seq) <= 1:
            return 0
        transitions = sum(1 for i in range(len(seq)-1) if seq[i] != seq[i+1])
        return transitions

    nerode = NerodeAutomaton(alignment_cost, alphabet, max_word_len=7, probe_len=5)

    print(f"Minimal DP states: {nerode.num_states()}")

    # Show equivalence classes
    classes = nerode.get_classes()
    print(f"\nEquivalence classes (prefixes with same cost-to-go):")
    for rep, members in classes.items():
        shown = members[:6]
        print(f"  State [{rep}]: {', '.join(shown)}{'...' if len(members) > 6 else ''}")

    print(f"\nOriginal DP table: exponentially many prefix states")
    print(f"Compressed table: {nerode.num_states()} states")
    print(f"Compression ratio for 7-symbol sequences: "
          f"{sum(2**k for k in range(8))} → {nerode.num_states()}")


# ===========================================================================
# Application 4: Weighted Pattern Matching
# ===========================================================================

def weighted_pattern_matching():
    """
    Application: Optimal pattern matching with costs.

    Given a text over {a, b, c}, compute the minimum edit distance to
    a target pattern, modeled as a weighted language.
    The Nerode automaton gives an optimal streaming matcher.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 4: Streaming Weighted Pattern Matching")
    print("=" * 70)

    alphabet = ['a', 'b']
    target = ['a', 'b', 'a']

    def match_score(text: List[str]) -> float:
        """
        Cost = length of text minus length of longest suffix matching
        a prefix of the target. Lower is better matching.
        """
        if not text:
            return 0

        # Longest suffix of text that is a prefix of target
        best = 0
        for k in range(1, min(len(text), len(target)) + 1):
            if text[-k:] == target[:k]:
                best = k
        return len(text) - best

    nerode = NerodeAutomaton(match_score, alphabet, max_word_len=6, probe_len=5)

    print(f"Target pattern: {''.join(target)}")
    print(f"Minimal streaming matcher states: {nerode.num_states()}")

    print("\nStreaming match scores:")
    text = ['a', 'b', 'a', 'b', 'a', 'a', 'b', 'a']
    for i in range(len(text) + 1):
        prefix = text[:i]
        score = nerode.evaluate(prefix)
        prefix_str = ''.join(prefix) if prefix else 'ε'
        print(f"  After reading '{prefix_str}': score = {score}")


if __name__ == '__main__':
    network_routing_demo()
    resource_bounded_computation()
    dp_state_compression()
    weighted_pattern_matching()


#!/usr/bin/env python3
"""
Tropical Myhill–Nerode Theorem: Demonstrations

Concrete numerical examples showing how the tropical (min-plus) Nerode
equivalence, canonical automaton construction, and minimality theorem work
on specific weighted languages.
"""

import math
from collections import defaultdict
from typing import Dict, List, Tuple, Optional, Callable
from algorithms import TropicalDFA, NerodeAutomaton

INF = float('inf')


def example_shortest_path_language():
    """
    Example 1: Shortest-path language over {a, b}.

    L(w) = number of 'a' characters in w.
    This is a min-plus regular language recognized by a 1-state automaton.
    """
    print("=" * 70)
    print("EXAMPLE 1: Character-counting language")
    print("L(w) = number of 'a' characters in w")
    print("=" * 70)

    alphabet = ['a', 'b']

    def L(w: List[str]) -> float:
        return sum(1 for c in w if c == 'a')

    # Build Nerode automaton
    nerode = NerodeAutomaton(L, alphabet, max_word_len=5, probe_len=4)

    print(f"\nNumber of distinct residuals: {nerode.num_states()}")
    print(f"(This is the minimal number of states needed.)")

    # Show some residual classes
    print("\nResidual classes (representative → class members):")
    for rep, members in nerode.get_classes().items():
        shown = [str(m) for m in members[:5]]
        print(f"  [{rep}] : {', '.join(shown)}{'...' if len(members) > 5 else ''}")

    # Verify correctness
    print("\nVerification (word → L(w) vs automaton(w)):")
    test_words = [[], ['a'], ['b'], ['a', 'b'], ['b', 'a'], ['a', 'a'], ['a', 'b', 'a']]
    for w in test_words:
        true_val = L(w)
        auto_val = nerode.evaluate(w)
        status = "✓" if abs(true_val - auto_val) < 1e-9 else "✗"
        print(f"  {status} L({''.join(w) if w else 'ε'}) = {true_val}, automaton = {auto_val}")


def example_min_distance_language():
    """
    Example 2: Min-distance language.

    L(w) = min(|w|, 3) — a bounded cost function.
    Should have exactly 4 residual classes.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Bounded distance language")
    print("L(w) = min(|w|, 3)")
    print("=" * 70)

    alphabet = ['a', 'b']

    def L(w: List[str]) -> float:
        return min(len(w), 3)

    nerode = NerodeAutomaton(L, alphabet, max_word_len=6, probe_len=5)
    print(f"\nNumber of distinct residuals: {nerode.num_states()}")

    # Show transitions
    print("\nTransition table:")
    nerode.print_transitions()

    # Verify
    print("\nVerification:")
    for length in range(7):
        w = ['a'] * length
        true_val = L(w)
        auto_val = nerode.evaluate(w)
        status = "✓" if abs(true_val - auto_val) < 1e-9 else "✗"
        print(f"  {status} L({'a' * length if length else 'ε'}) = {true_val}, automaton = {auto_val}")


def example_edit_distance_prefix():
    """
    Example 3: Weighted language based on pattern matching.

    L(w) = number of times 'ab' appears as a substring, as a cost.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 3: Substring pattern counting")
    print("L(w) = count of 'ab' substrings in w")
    print("=" * 70)

    alphabet = ['a', 'b']

    def L(w: List[str]) -> float:
        count = 0
        for i in range(len(w) - 1):
            if w[i] == 'a' and w[i+1] == 'b':
                count += 1
        return count

    nerode = NerodeAutomaton(L, alphabet, max_word_len=6, probe_len=5)
    print(f"\nNumber of distinct residuals: {nerode.num_states()}")

    print("\nSample evaluations:")
    test_words = [[], ['a'], ['b'], ['a', 'b'], ['a', 'b', 'a', 'b'],
                  ['b', 'a'], ['a', 'a', 'b']]
    for w in test_words:
        val = nerode.evaluate(w)
        print(f"  L({''.join(w) if w else 'ε'}) = {val}")


def example_minimality_demonstration():
    """
    Example 4: Minimality theorem in action.

    We build a non-minimal automaton and show the Nerode automaton is smaller.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 4: Minimality theorem demonstration")
    print("=" * 70)

    alphabet = ['a', 'b']

    # A non-minimal 4-state automaton for L(w) = min(|w|, 2)
    class NonMinimalDFA:
        def __init__(self):
            self.num_states = 4  # States 0,1,2,3 (3 is redundant copy of 2)
            self.init = 0
            self.transitions = {
                (0, 'a'): 1, (0, 'b'): 1,
                (1, 'a'): 2, (1, 'b'): 2,
                (2, 'a'): 3, (2, 'b'): 3,  # state 3 is redundant
                (3, 'a'): 3, (3, 'b'): 3,
            }
            self.output = {0: 0, 1: 1, 2: 2, 3: 2}

        def evaluate(self, w):
            state = self.init
            for c in w:
                state = self.transitions[(state, c)]
            return self.output[state]

    non_min = NonMinimalDFA()

    def L(w):
        return non_min.evaluate(w)

    nerode = NerodeAutomaton(L, alphabet, max_word_len=5, probe_len=4)

    print(f"\nNon-minimal automaton states: {non_min.num_states}")
    print(f"Nerode (minimal) automaton states: {nerode.num_states()}")
    print(f"State reduction: {non_min.num_states} → {nerode.num_states()}")
    print(f"\nThe Nerode state count ({nerode.num_states()}) is a lower bound")
    print(f"on the states of ANY recognizing automaton (Minimality Theorem).")


def example_syntactic_monoid():
    """
    Example 5: Syntactic transformation monoid computation.

    Compute the transformations induced by each word on residual classes,
    demonstrating the finite syntactic monoid.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 5: Syntactic transformation monoid")
    print("=" * 70)

    alphabet = ['a', 'b']

    def L(w: List[str]) -> float:
        return min(len(w), 2)

    nerode = NerodeAutomaton(L, alphabet, max_word_len=4, probe_len=3)
    print(f"\nResidual states: {nerode.num_states()}")

    # Compute syntactic monoid
    monoid = nerode.compute_syntactic_monoid(max_word_len=4)
    print(f"Syntactic monoid size: {len(monoid)}")
    print("\nTransformations (word → permutation of states):")
    for word_str, transform in sorted(monoid.items(), key=lambda x: (len(x[0]), x[0])):
        print(f"  '{word_str if word_str else 'ε'}' : {transform}")

    print(f"\nThe syntactic monoid is finite ({len(monoid)} elements),")
    print(f"confirming recognizability (Theorem 6).")


def example_non_recognizable():
    """
    Example 6: A non-recognizable language (infinite residuals).

    L(w) = |w|² — each prefix length gives a distinct residual.
    """
    print("\n" + "=" * 70)
    print("EXAMPLE 6: Non-recognizable language (infinite residuals)")
    print("L(w) = |w|²")
    print("=" * 70)

    alphabet = ['a']

    def L(w: List[str]) -> float:
        return len(w) ** 2

    # Show that residuals keep growing
    print("\nResiduals at different prefixes (evaluated at suffix 'a'):")
    for n in range(8):
        prefix = ['a'] * n
        suffix = ['a']
        val = L(prefix + suffix)
        print(f"  Residual({'a'*n if n else 'ε'})(a) = L({'a'*(n+1)}) = {val}")

    print("\nAll residuals are distinct → infinite Nerode index")
    print("→ NOT tropically recognizable (by contrapositive of Myhill–Nerode).")

    # Verify distinctness
    residuals_at_a = [L(['a'] * n + ['a']) for n in range(8)]
    all_distinct = len(set(residuals_at_a)) == len(residuals_at_a)
    print(f"\nAll residual values at 'a' distinct? {all_distinct}")


if __name__ == '__main__':
    example_shortest_path_language()
    example_min_distance_language()
    example_edit_distance_prefix()
    example_minimality_demonstration()
    example_syntactic_monoid()
    example_non_recognizable()


#!/usr/bin/env python3
"""
Tropical Myhill–Nerode: Visualizations

Generate publication-quality figures illustrating the theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import base64
import io
from algorithms import NerodeAutomaton, generate_words

def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def viz_residual_classes():
    """Visualize residual equivalence classes for L(w) = min(|w|, 3)."""
    alphabet = ['a', 'b']
    L = lambda w: min(len(w), 3)

    nerode = NerodeAutomaton(L, alphabet, max_word_len=5, probe_len=4)
    classes = nerode.get_classes()

    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    colors = plt.cm.Set2(np.linspace(0, 1, len(classes)))
    y_positions = []
    labels = []

    for i, (rep, members) in enumerate(sorted(classes.items(),
                                                key=lambda x: len(x[0]))):
        y = -i * 1.5
        y_positions.append(y)
        labels.append(f"State {i}\n(rep: {rep})")

        # Draw members as dots
        for j, m in enumerate(members[:12]):
            x = j * 0.8
            circle = plt.Circle((x, y), 0.3, color=colors[i], alpha=0.7)
            ax.add_patch(circle)
            ax.text(x, y, m, ha='center', va='center', fontsize=7, fontweight='bold')

        if len(members) > 12:
            ax.text(12 * 0.8, y, '...', ha='center', va='center', fontsize=12)

    ax.set_xlim(-1, 11)
    ax.set_ylim(min(y_positions) - 1, 1.5)
    ax.set_yticks(y_positions)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_xlabel('Words in each equivalence class', fontsize=12)
    ax.set_title('Tropical Nerode Equivalence Classes\nL(w) = min(|w|, 3)',
                 fontsize=14, fontweight='bold')
    ax.set_xticks([])
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)
    ax.spines['bottom'].set_visible(False)

    fig.tight_layout()
    fig.savefig('viz_residual_classes.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_minimality_comparison():
    """Compare state counts: original vs Nerode-minimal automaton."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Different languages with known minimal state counts
    languages = {
        'min(|w|, 1)': (lambda w: min(len(w), 1), 2),
        'min(|w|, 2)': (lambda w: min(len(w), 2), 3),
        'min(|w|, 3)': (lambda w: min(len(w), 3), 4),
        'min(|w|, 4)': (lambda w: min(len(w), 4), 5),
        'min(|w|, 5)': (lambda w: min(len(w), 5), 6),
    }

    alphabet = ['a', 'b']
    names = list(languages.keys())
    nerode_counts = []
    expected_counts = []

    for name, (L, expected) in languages.items():
        nerode = NerodeAutomaton(L, alphabet, max_word_len=8, probe_len=6)
        nerode_counts.append(nerode.num_states())
        expected_counts.append(expected)

    x = np.arange(len(names))
    width = 0.35

    axes[0].bar(x - width/2, expected_counts, width, label='Expected minimum',
                color='steelblue', alpha=0.8)
    axes[0].bar(x + width/2, nerode_counts, width, label='Nerode automaton',
                color='coral', alpha=0.8)
    axes[0].set_xlabel('Language', fontsize=11)
    axes[0].set_ylabel('Number of States', fontsize=11)
    axes[0].set_title('Minimality: Nerode vs Expected', fontsize=13, fontweight='bold')
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(names, fontsize=9, rotation=15)
    axes[0].legend()

    # Syntactic monoid sizes
    monoid_sizes = []
    for name, (L, _) in languages.items():
        nerode = NerodeAutomaton(L, alphabet, max_word_len=6, probe_len=5)
        monoid = nerode.compute_syntactic_monoid(max_word_len=5)
        monoid_sizes.append(len(monoid))

    axes[1].bar(names, monoid_sizes, color='seagreen', alpha=0.8)
    axes[1].set_xlabel('Language', fontsize=11)
    axes[1].set_ylabel('Monoid Size', fontsize=11)
    axes[1].set_title('Syntactic Monoid Size', fontsize=13, fontweight='bold')
    axes[1].set_xticklabels(names, fontsize=9, rotation=15)

    fig.tight_layout()
    fig.savefig('viz_minimality.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_residual_convergence():
    """Show how the number of discovered residuals converges with exploration depth."""
    fig, ax = plt.subplots(figsize=(10, 6))

    alphabet = ['a', 'b']
    languages = {
        'min(|w|, 2)': lambda w: min(len(w), 2),
        'min(|w|, 4)': lambda w: min(len(w), 4),
        '#a mod 3': lambda w: sum(1 for c in w if c == 'a') % 3,
        'transitions': lambda w: sum(1 for i in range(len(w)-1) if w[i] != w[i+1]) if len(w) > 1 else 0,
    }

    colors = ['steelblue', 'coral', 'seagreen', 'purple']

    for (name, L), color in zip(languages.items(), colors):
        depths = range(1, 9)
        counts = []
        for depth in depths:
            nerode = NerodeAutomaton(L, alphabet, max_word_len=depth, probe_len=depth)
            counts.append(nerode.num_states())
        ax.plot(list(depths), counts, 'o-', color=color, label=name,
                linewidth=2, markersize=8)

    ax.set_xlabel('Exploration Depth (max word length)', fontsize=12)
    ax.set_ylabel('Distinct Residuals Found', fontsize=12)
    ax.set_title('Residual Discovery vs Exploration Depth\n'
                 '(Convergence = finite Nerode index = recognizable)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(range(1, 9))

    fig.tight_layout()
    fig.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


def viz_automaton_diagram():
    """Draw a state diagram of the Nerode automaton for L(w) = min(|w|, 3)."""
    fig, ax = plt.subplots(figsize=(10, 4))

    # States for min(|w|, 3): 4 states
    states = [(1.5, 2), (4, 2), (6.5, 2), (9, 2)]
    labels = ['q₀\n(cost 0)', 'q₁\n(cost 1)', 'q₂\n(cost 2)', 'q₃\n(cost 3)']

    for (x, y), label in zip(states, labels):
        circle = plt.Circle((x, y), 0.6, fill=False, linewidth=2, color='steelblue')
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=10, fontweight='bold')

    # Transitions
    for i in range(3):
        x1, y1 = states[i]
        x2, y2 = states[i+1]
        ax.annotate('', xy=(x2-0.6, y2), xytext=(x1+0.6, y1),
                    arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
        ax.text((x1+x2)/2, y2+0.5, 'a, b', ha='center', fontsize=10)

    # Self-loop on q3
    x3, y3 = states[3]
    arc = mpatches.FancyArrowPatch((x3+0.4, y3+0.5), (x3-0.4, y3+0.5),
                                     connectionstyle="arc3,rad=-0.8",
                                     arrowstyle='->', mutation_scale=15,
                                     color='black', linewidth=1.5)
    ax.add_patch(arc)
    ax.text(x3, y3+1.5, 'a, b', ha='center', fontsize=10)

    # Initial arrow
    ax.annotate('', xy=(states[0][0]-0.6, states[0][1]),
                xytext=(states[0][0]-1.5, states[0][1]),
                arrowprops=dict(arrowstyle='->', color='black', lw=1.5))
    ax.text(states[0][0]-1.8, states[0][1], 'start', ha='right', fontsize=10)

    ax.set_xlim(-0.5, 10.5)
    ax.set_ylim(0, 4)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Nerode Automaton for L(w) = min(|w|, 3)\n'
                 '(Minimal: 4 states, any recognizing automaton needs ≥ 4)',
                 fontsize=13, fontweight='bold')

    fig.tight_layout()
    fig.savefig('viz_automaton.png', dpi=150, bbox_inches='tight')
    return fig_to_base64(fig)


if __name__ == '__main__':
    print("Generating visualizations...")
    b1 = viz_residual_classes()
    print(f"  Residual classes: {len(b1)} chars")
    b2 = viz_minimality_comparison()
    print(f"  Minimality comparison: {len(b2)} chars")
    b3 = viz_residual_convergence()
    print(f"  Convergence: {len(b3)} chars")
    b4 = viz_automaton_diagram()
    print(f"  Automaton diagram: {len(b4)} chars")
    print("Done! Saved PNG files.")
