#!/usr/bin/env python3
"""
Ultrametric Neural Realization Duality — Computational Demonstrations

This module demonstrates the key constructions and theorems from the
ultrametric neural realization theory:
1. Ultrametric predictor signatures
2. Observer indistinguishability testing
3. Nerode equivalence classes
4. Minimal realization construction
5. Visualization of ultrametric state geometry
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple, Callable, Optional, Set
import json
import base64
from io import BytesIO


# ============================================================
# §1. Core Data Structures
# ============================================================

class UltrametricPredictorSig:
    """An ultrametric predictor signature over finite types.

    Attributes:
        states: list of state labels
        inputs: list of input symbols
        observers: list of observer labels
        init: initial state
        step: dict mapping (input, state) -> state
        output: dict mapping (observer, state) -> output_value
        udist: dict mapping (state, state) -> float (ultrametric distance)
    """

    def __init__(self, states, inputs, observers, init, step, output, udist=None):
        self.states = list(states)
        self.inputs = list(inputs)
        self.observers = list(observers)
        self.init = init
        self.step = step  # (x, q) -> q'
        self.output = output  # (o, q) -> s
        if udist is None:
            # Default: discrete ultrametric
            self.udist = lambda q1, q2: 0.0 if q1 == q2 else 1.0
        else:
            self.udist = udist

    def apply_word(self, word: list, q=None):
        """Apply a word (list of inputs) starting from state q."""
        if q is None:
            q = self.init
        for x in word:
            q = self.step(x, q)
        return q

    def response_kernel(self, word: list, observer, q=None):
        """Compute the response kernel: output after processing word from q."""
        q_final = self.apply_word(word, q)
        return self.output(observer, q_final)

    def kernel(self, word: list, observer):
        """The kernel from the initial state."""
        return self.response_kernel(word, observer)


def verify_ultrametric(sig: UltrametricPredictorSig) -> bool:
    """Verify the ultrametric inequality for all state triples."""
    for a in sig.states:
        for b in sig.states:
            for c in sig.states:
                d_ac = sig.udist(a, c)
                d_ab = sig.udist(a, b)
                d_bc = sig.udist(b, c)
                if d_ac > max(d_ab, d_bc) + 1e-10:
                    return False
    return True


def verify_nonexpanding(sig: UltrametricPredictorSig) -> bool:
    """Verify that all transitions are nonexpanding."""
    for x in sig.inputs:
        for q1 in sig.states:
            for q2 in sig.states:
                d_before = sig.udist(q1, q2)
                d_after = sig.udist(sig.step(x, q1), sig.step(x, q2))
                if d_after > d_before + 1e-10:
                    return False
    return True


# ============================================================
# §2. Observer Indistinguishability
# ============================================================

def are_observer_indistinguishable(
    sig: UltrametricPredictorSig,
    q1, q2,
    max_word_length: int = 5
) -> bool:
    """Test if two states are observer-indistinguishable up to a word length bound."""
    for length in range(max_word_length + 1):
        for word in product(sig.inputs, repeat=length):
            for o in sig.observers:
                if sig.response_kernel(list(word), o, q1) != \
                   sig.response_kernel(list(word), o, q2):
                    return False
    return True


def compute_indistinguishability_classes(
    sig: UltrametricPredictorSig,
    max_word_length: int = 5
) -> List[Set]:
    """Compute the equivalence classes of observer indistinguishability."""
    classes = []
    assigned = set()
    for q in sig.states:
        if q in assigned:
            continue
        cls = {q}
        for q2 in sig.states:
            if q2 not in assigned and are_observer_indistinguishable(sig, q, q2, max_word_length):
                cls.add(q2)
        classes.append(cls)
        assigned |= cls
    return classes


# ============================================================
# §3. Nerode Equivalence
# ============================================================

def nerode_equivalent(
    K: Callable,  # K(word, observer) -> value
    w1: list, w2: list,
    inputs: list, observers: list,
    max_suffix_length: int = 4
) -> bool:
    """Test if two words are Nerode-equivalent."""
    for length in range(max_suffix_length + 1):
        for suffix in product(inputs, repeat=length):
            for o in observers:
                if K(w1 + list(suffix), o) != K(w2 + list(suffix), o):
                    return False
    return True


def compute_nerode_classes(
    K: Callable,
    inputs: list,
    observers: list,
    max_word_length: int = 3,
    max_suffix_length: int = 3
) -> Dict[int, List[tuple]]:
    """Compute Nerode equivalence classes for words up to a length."""
    words = []
    for length in range(max_word_length + 1):
        for word in product(inputs, repeat=length):
            words.append(list(word))

    classes = {}
    class_id = 0
    word_to_class = {}

    for w in words:
        w_key = tuple(w)
        found = False
        for cid, rep in classes.items():
            if nerode_equivalent(K, w, list(rep[0]), inputs, observers, max_suffix_length):
                classes[cid].append(w_key)
                word_to_class[w_key] = cid
                found = True
                break
        if not found:
            classes[class_id] = [w_key]
            word_to_class[w_key] = class_id
            class_id += 1

    return classes, word_to_class


# ============================================================
# §4. Example: Parity Automaton
# ============================================================

def make_parity_automaton() -> UltrametricPredictorSig:
    """The two-state parity automaton from the formal proof."""
    return UltrametricPredictorSig(
        states=[0, 1],
        inputs=[False, True],
        observers=['val'],
        init=0,
        step=lambda b, q: (q + 1) % 2 if b else q,
        output=lambda o, q: q,
    )


def make_modular_automaton(n: int) -> UltrametricPredictorSig:
    """A modular counting automaton with n states."""
    return UltrametricPredictorSig(
        states=list(range(n)),
        inputs=[0, 1],
        observers=['val', 'parity'],
        init=0,
        step=lambda x, q: (q + x) % n,
        output=lambda o, q: q if o == 'val' else q % 2,
    )


def make_redundant_automaton() -> UltrametricPredictorSig:
    """A 4-state automaton with redundant states (non-minimal).
    States 0,2 are indistinguishable, and states 1,3 are indistinguishable."""
    return UltrametricPredictorSig(
        states=[0, 1, 2, 3],
        inputs=[0, 1],
        observers=['out'],
        init=0,
        step=lambda x, q: {
            (0, 0): 0, (0, 1): 2, (0, 2): 0, (0, 3): 2,
            (1, 0): 1, (1, 1): 3, (1, 2): 1, (1, 3): 3,
        }[(x, q)],
        output=lambda o, q: q % 2,
    )


# ============================================================
# §5. Visualization
# ============================================================

def plot_ultrametric_distance_matrix(sig: UltrametricPredictorSig, title=""):
    """Plot the ultrametric distance matrix between states."""
    n = len(sig.states)
    D = np.zeros((n, n))
    for i, q1 in enumerate(sig.states):
        for j, q2 in enumerate(sig.states):
            D[i, j] = sig.udist(q1, q2)

    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(D, cmap='YlOrRd', interpolation='nearest')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xticklabels([str(s) for s in sig.states])
    ax.set_yticklabels([str(s) for s in sig.states])
    ax.set_xlabel('State')
    ax.set_ylabel('State')
    ax.set_title(title or 'Ultrametric Distance Matrix')
    plt.colorbar(im, ax=ax, label='Distance')
    plt.tight_layout()
    return fig


def plot_nerode_classes(classes, title=""):
    """Visualize Nerode equivalence classes."""
    fig, ax = plt.subplots(figsize=(10, 4))
    colors = plt.cm.Set3(np.linspace(0, 1, len(classes)))

    y_pos = 0
    for cid, words in sorted(classes.items()):
        for i, w in enumerate(words[:8]):  # Show at most 8 per class
            word_str = ''.join(str(x) for x in w) if w else 'ε'
            ax.barh(y_pos, 1, color=colors[cid % len(colors)], edgecolor='black', linewidth=0.5)
            ax.text(0.5, y_pos, word_str, ha='center', va='center', fontsize=9)
            y_pos += 1
        y_pos += 0.5  # Gap between classes

    ax.set_xlim(0, 1)
    ax.set_xlabel('')
    ax.set_title(title or 'Nerode Equivalence Classes')
    ax.set_yticks([])
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.axvline(x=1, color='gray', linewidth=0.5)

    # Add legend
    for cid in sorted(classes.keys()):
        ax.barh(-1, 0, color=colors[cid % len(colors)], label=f'Class {cid}')
    ax.legend(loc='upper right', fontsize=8)
    plt.tight_layout()
    return fig


def plot_state_transition_diagram(sig: UltrametricPredictorSig, title=""):
    """Plot a state transition diagram."""
    fig, ax = plt.subplots(figsize=(8, 6))
    n = len(sig.states)

    # Position states in a circle
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = {s: (np.cos(a), np.sin(a)) for s, a in zip(sig.states, angles)}

    # Draw transitions
    for x in sig.inputs:
        for q in sig.states:
            q_next = sig.step(x, q)
            x1, y1 = positions[q]
            x2, y2 = positions[q_next]
            if q == q_next:
                # Self-loop
                ax.annotate('', xy=(x1, y1 + 0.15), xytext=(x1 + 0.1, y1 + 0.15),
                           arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
            else:
                dx, dy = x2 - x1, y2 - y1
                ax.annotate('', xy=(x2 - 0.1*dx, y2 - 0.1*dy),
                           xytext=(x1 + 0.1*dx, y1 + 0.1*dy),
                           arrowprops=dict(arrowstyle='->', color='blue', lw=1.5))
                mid_x, mid_y = (x1 + x2) / 2, (y1 + y2) / 2
                ax.text(mid_x + 0.05, mid_y + 0.05, str(x), fontsize=8, color='blue')

    # Draw states
    for q in sig.states:
        x, y = positions[q]
        circle = plt.Circle((x, y), 0.1, fill=True, facecolor='lightblue',
                           edgecolor='black', linewidth=2)
        ax.add_patch(circle)
        ax.text(x, y, str(q), ha='center', va='center', fontsize=12, fontweight='bold')

    # Mark initial state
    ix, iy = positions[sig.init]
    ax.annotate('', xy=(ix - 0.1, iy), xytext=(ix - 0.3, iy),
               arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.5, 1.5)
    ax.set_aspect('equal')
    ax.set_title(title or 'State Transition Diagram')
    ax.axis('off')
    plt.tight_layout()
    return fig


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 data URI."""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


# ============================================================
# §6. Main Demonstrations
# ============================================================

def demo_parity():
    """Demonstrate the parity automaton."""
    print("=" * 60)
    print("Demo 1: Parity Automaton (2 states)")
    print("=" * 60)

    sig = make_parity_automaton()

    print(f"\nStates: {sig.states}")
    print(f"Inputs: {sig.inputs}")
    print(f"Initial state: {sig.init}")
    print(f"Ultrametric verified: {verify_ultrametric(sig)}")
    print(f"Nonexpanding verified: {verify_nonexpanding(sig)}")

    # Test responses
    test_words = [[], [True], [False], [True, True], [True, False]]
    print("\nResponse kernel (from init):")
    for w in test_words:
        resp = sig.kernel(w, 'val')
        w_str = ''.join('T' if x else 'F' for x in w) if w else 'ε'
        print(f"  K({w_str}, val) = {resp}")

    # Check indistinguishability
    classes = compute_indistinguishability_classes(sig, max_word_length=4)
    print(f"\nIndistinguishability classes: {classes}")
    print(f"Number of classes: {len(classes)} (should be 2 for minimal)")

    return sig


def demo_redundant():
    """Demonstrate a non-minimal automaton with redundant states."""
    print("\n" + "=" * 60)
    print("Demo 2: Redundant Automaton (4 states, non-minimal)")
    print("=" * 60)

    sig = make_redundant_automaton()

    print(f"\nStates: {sig.states}")
    print(f"Ultrametric verified: {verify_ultrametric(sig)}")
    print(f"Nonexpanding verified: {verify_nonexpanding(sig)}")

    classes = compute_indistinguishability_classes(sig, max_word_length=4)
    print(f"\nIndistinguishability classes: {classes}")
    print(f"Number of classes: {len(classes)} (should be 2, < 4 states)")
    print("→ States 0,2 are indistinguishable; states 1,3 are indistinguishable")
    print("→ Minimal realization has only 2 states!")

    return sig


def demo_nerode():
    """Demonstrate Nerode equivalence classes."""
    print("\n" + "=" * 60)
    print("Demo 3: Nerode Equivalence Classes")
    print("=" * 60)

    sig = make_parity_automaton()
    K = sig.kernel

    classes, word_map = compute_nerode_classes(
        K, sig.inputs, sig.observers,
        max_word_length=3, max_suffix_length=3
    )

    print(f"\nNerode classes for parity kernel (words up to length 3):")
    for cid, words in sorted(classes.items()):
        word_strs = [''.join('T' if x else 'F' for x in w) if w else 'ε' for w in words]
        print(f"  Class {cid}: {word_strs[:6]}{'...' if len(word_strs) > 6 else ''}")

    print(f"\nTotal classes: {len(classes)} (= minimal state count)")

    return classes


def demo_modular():
    """Demonstrate a modular counter."""
    print("\n" + "=" * 60)
    print("Demo 4: Modular Counter (mod 4)")
    print("=" * 60)

    sig = make_modular_automaton(4)

    print(f"\nStates: {sig.states}")
    print(f"Ultrametric verified: {verify_ultrametric(sig)}")
    print(f"Nonexpanding verified: {verify_nonexpanding(sig)}")

    classes = compute_indistinguishability_classes(sig, max_word_length=4)
    print(f"\nIndistinguishability classes: {classes}")
    print(f"Number of classes: {len(classes)}")

    # With both observers (val and parity), all 4 states should be distinguishable
    if len(classes) == 4:
        print("→ All states distinguishable → already minimal!")
    else:
        print(f"→ {4 - len(classes)} states can be merged")

    return sig


def generate_visualizations():
    """Generate all visualization figures."""
    figs = {}

    # Distance matrix for parity automaton
    sig = make_parity_automaton()
    fig = plot_ultrametric_distance_matrix(sig, "Parity Automaton — Ultrametric Distance")
    figs['parity_distance'] = fig_to_base64(fig)

    # Transition diagram for parity automaton
    fig = plot_state_transition_diagram(sig, "Parity Automaton — Transitions")
    figs['parity_transitions'] = fig_to_base64(fig)

    # Distance matrix for redundant automaton
    sig_red = make_redundant_automaton()
    fig = plot_ultrametric_distance_matrix(sig_red, "Redundant Automaton — Distance Matrix")
    figs['redundant_distance'] = fig_to_base64(fig)

    # Nerode classes
    K = sig.kernel
    classes, _ = compute_nerode_classes(K, sig.inputs, sig.observers, 3, 3)
    fig = plot_nerode_classes(classes, "Parity Kernel — Nerode Classes")
    figs['nerode_classes'] = fig_to_base64(fig)

    # Modular counter
    sig4 = make_modular_automaton(4)
    fig = plot_ultrametric_distance_matrix(sig4, "Mod-4 Counter — Ultrametric Distance")
    figs['mod4_distance'] = fig_to_base64(fig)

    return figs


if __name__ == '__main__':
    # Run all demos
    demo_parity()
    demo_redundant()
    demo_nerode()
    demo_modular()

    print("\n" + "=" * 60)
    print("Generating visualizations...")
    print("=" * 60)
    figs = generate_visualizations()
    print(f"Generated {len(figs)} figures.")

    # Save figures
    for name, data_uri in figs.items():
        # Extract base64 data and save as PNG
        b64_data = data_uri.split(',')[1]
        with open(f'{name}.png', 'wb') as f:
            f.write(base64.b64decode(b64_data))
        print(f"  Saved {name}.png")

    print("\nAll demos complete!")
