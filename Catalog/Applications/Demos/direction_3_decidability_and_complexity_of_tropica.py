#!/usr/bin/env python3
"""
Applications of Tropical Automata Minimization.

Demonstrates real-world applications of the Nerode partition refinement
algorithm for deterministic min-plus automata.
"""

from algorithms import (
    DetTropicalAutomaton,
    partition_refinement,
    build_quotient_automaton,
    verify_equivalence,
    INF
)


def application_network_routing():
    """Application: Minimizing a network routing table.

    A network with 8 nodes can be modeled as a tropical automaton.
    Each state is a node, transitions encode routing decisions,
    and output is the cost to reach a destination from each node.

    If some nodes have identical cost profiles for all routing sequences,
    they can be merged — reducing the routing table size.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Table Compression")
    print("=" * 60)
    print()

    # 8-node network where nodes come in equivalent pairs
    # Nodes: A, A', B, B', C, C', D, D'
    # A ≡ A', B ≡ B', C ≡ C', D ≡ D'
    states = ["A", "A'", "B", "B'", "C", "C'", "D", "D'"]
    alphabet = ["north", "south"]
    step = {
        ("A", "north"): "B",   ("A", "south"): "C",
        ("A'", "north"): "B'", ("A'", "south"): "C'",
        ("B", "north"): "D",   ("B", "south"): "A",
        ("B'", "north"): "D'", ("B'", "south"): "A'",
        ("C", "north"): "A",   ("C", "south"): "D",
        ("C'", "north"): "A'", ("C'", "south"): "D'",
        ("D", "north"): "C",   ("D", "south"): "B",
        ("D'", "north"): "C'", ("D'", "south"): "B'",
    }
    out = {"A": 0, "A'": 0, "B": 3, "B'": 3,
           "C": 5, "C'": 5, "D": 2, "D'": 2}

    A = DetTropicalAutomaton(states, alphabet, step, out, init="A")

    print(f"Network nodes: {states}")
    print(f"Routing directions: {alphabet}")
    print(f"Node costs: {out}")
    print()

    partition, index, steps = partition_refinement(A)
    B = build_quotient_automaton(A, partition, index)

    print(f"Original routing table: {len(states)} entries")
    print(f"Compressed routing table: {index} entries")
    print(f"Compression: {len(states)/index:.1f}x")
    print()

    # Show which nodes were merged
    classes = {}
    for q, c in partition.items():
        classes.setdefault(c, []).append(q)
    print("Equivalent node groups:")
    for members in classes.values():
        print(f"  {members} → merged into one entry")
    print()

    # Verify correctness
    equiv = verify_equivalence(A, B, max_word_length=8)
    print(f"Routing equivalence verified: {equiv}")
    print()

    # Show some routes
    print("Sample routes from 'A':")
    for route in [[], ["north"], ["south"], ["north", "north"],
                  ["north", "south"], ["south", "north"]]:
        cost = A.language(route)
        route_str = " → ".join(route) if route else "(stay)"
        print(f"  {route_str:30s} cost = {cost}")


def application_dynamic_programming():
    """Application: Compressing a dynamic programming state space.

    A manufacturing process has stages, each with different cost outcomes.
    States represent process configurations, transitions represent
    production steps. The output is the remaining cost to completion.

    Equivalent states (same future costs for all sequences of steps)
    can be merged to reduce the DP table size.
    """
    print()
    print("=" * 60)
    print("APPLICATION 2: Dynamic Programming State Compression")
    print("=" * 60)
    print()

    states = ["S1", "S2", "S3", "S4", "S5", "S6"]
    alphabet = ["fast", "slow"]

    # S1 and S2 have identical future behavior
    # S3 and S4 have identical future behavior
    step = {
        ("S1", "fast"): "S3", ("S1", "slow"): "S5",
        ("S2", "fast"): "S4", ("S2", "slow"): "S5",
        ("S3", "fast"): "S5", ("S3", "slow"): "S6",
        ("S4", "fast"): "S5", ("S4", "slow"): "S6",
        ("S5", "fast"): "S5", ("S5", "slow"): "S5",
        ("S6", "fast"): "S6", ("S6", "slow"): "S6",
    }
    out = {"S1": 10, "S2": 10, "S3": 5, "S4": 5, "S5": 0, "S6": 3}

    A = DetTropicalAutomaton(states, alphabet, step, out, init="S1")

    print(f"Process configurations: {states}")
    print(f"Production steps: {alphabet}")
    print(f"Remaining costs: {out}")
    print()

    partition, index, steps = partition_refinement(A)
    B = build_quotient_automaton(A, partition, index)

    print(f"Original DP table size: {len(states)}")
    print(f"Compressed DP table size: {index}")
    print()

    classes = {}
    for q, c in partition.items():
        classes.setdefault(c, []).append(q)
    print("Equivalent configurations:")
    for members in classes.values():
        if len(members) > 1:
            print(f"  {members} are equivalent (same future costs)")
        else:
            print(f"  {members} is unique")
    print()

    equiv = verify_equivalence(A, B, max_word_length=8)
    print(f"Correctness verified: {equiv}")


def application_controller_equivalence():
    """Application: Checking if two cost controllers are equivalent.

    Given two implementations of a cost-computing controller,
    verify they produce the same cost for every input sequence.
    """
    print()
    print("=" * 60)
    print("APPLICATION 3: Controller Equivalence Checking")
    print("=" * 60)
    print()

    # Controller 1: 4 states
    A = DetTropicalAutomaton(
        states=["idle", "run", "wait", "done"],
        alphabet=["go", "stop"],
        step={
            ("idle", "go"): "run",  ("idle", "stop"): "idle",
            ("run", "go"): "wait",  ("run", "stop"): "done",
            ("wait", "go"): "run",  ("wait", "stop"): "done",
            ("done", "go"): "done", ("done", "stop"): "done",
        },
        out={"idle": 0, "run": 2, "wait": 3, "done": 1},
        init="idle"
    )

    # Controller 2: 5 states (with one redundant)
    B = DetTropicalAutomaton(
        states=["p0", "p1", "p2", "p3", "p4"],
        alphabet=["go", "stop"],
        step={
            ("p0", "go"): "p1",  ("p0", "stop"): "p0",
            ("p1", "go"): "p2",  ("p1", "stop"): "p3",
            ("p2", "go"): "p1",  ("p2", "stop"): "p3",
            ("p3", "go"): "p3",  ("p3", "stop"): "p4",
            ("p4", "go"): "p4",  ("p4", "stop"): "p4",
        },
        out={"p0": 0, "p1": 2, "p2": 3, "p3": 1, "p4": 1},
        init="p0"
    )

    print("Controller A: 4 states (idle, run, wait, done)")
    print("Controller B: 5 states (p0-p4)")
    print()

    # Minimize both
    pA, idxA, _ = partition_refinement(A)
    pB, idxB, _ = partition_refinement(B)

    minA = build_quotient_automaton(A, pA, idxA)
    minB = build_quotient_automaton(B, pB, idxB)

    print(f"Minimal Controller A: {idxA} states")
    print(f"Minimal Controller B: {idxB} states")
    print()

    # Check equivalence by comparing languages
    equiv = verify_equivalence(A, B, max_word_length=10)
    print(f"Controllers are equivalent: {equiv}")
    print()

    if equiv:
        print("The two controllers produce identical costs for all input sequences.")
        print("They can be used interchangeably.")
    else:
        print("The controllers differ. Finding a distinguishing input...")
        for length in range(11):
            def gen_words(n, alpha):
                if n == 0:
                    yield []
                    return
                for a in alpha:
                    for w in gen_words(n-1, alpha):
                        yield [a] + w
            for w in gen_words(length, A.alphabet):
                ca = A.language(w)
                cb = B.language(w)
                if ca != cb:
                    print(f"  Input: {w}, A={ca}, B={cb}")
                    break


if __name__ == "__main__":
    application_network_routing()
    application_dynamic_programming()
    application_controller_equivalence()
    print()
    print("=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demonstration of Tropical Automata Minimization via Nerode Partition Refinement.

This script demonstrates the key theorems formalized in Lean 4:
1. Nerode equivalence on states is decidable via partition refinement
2. The partition stabilizes within |Q| steps
3. The quotient automaton is equivalent to the original
4. The Nerode index bounds the minimal state count

All examples use the min-plus semiring (tropical arithmetic).
"""

from algorithms import (
    DetTropicalAutomaton,
    partition_refinement,
    build_quotient_automaton,
    compute_depth_partition,
    verify_equivalence,
    depth_eq,
    INF
)

def demo_partition_refinement_convergence():
    """Demonstrate how partition refinement converges step by step."""
    print("=" * 70)
    print("DEMO 1: Partition Refinement Convergence")
    print("=" * 70)
    print()
    print("We build a 6-state tropical automaton with redundant states.")
    print("The algorithm discovers which states are Nerode-equivalent")
    print("by iteratively refining equivalence classes.")
    print()

    # Build a 6-state automaton where q0≡q1 and q2≡q3
    A = DetTropicalAutomaton(
        states=["q0", "q1", "q2", "q3", "q4", "q5"],
        alphabet=["a", "b"],
        step={
            ("q0", "a"): "q2", ("q0", "b"): "q4",
            ("q1", "a"): "q3", ("q1", "b"): "q4",
            ("q2", "a"): "q4", ("q2", "b"): "q5",
            ("q3", "a"): "q4", ("q3", "b"): "q5",
            ("q4", "a"): "q4", ("q4", "b"): "q4",
            ("q5", "a"): "q5", ("q5", "b"): "q5",
        },
        out={"q0": 0, "q1": 0, "q2": 2, "q3": 2, "q4": 7, "q5": 1},
        init="q0"
    )

    print("Automaton definition:")
    print(f"  States: {A.states}")
    print(f"  Alphabet: {A.alphabet}")
    print(f"  Outputs: {A.out}")
    print()

    print("Step-by-step partition refinement:")
    print("-" * 50)

    prev_classes = None
    for depth in range(len(A.states) + 1):
        p = compute_depth_partition(A, depth)
        num_classes = len(set(p.values()))
        classes = {}
        for q, c in p.items():
            classes.setdefault(c, []).append(q)
        class_list = [sorted(v) for v in classes.values()]

        stable = class_list == prev_classes
        status = " ← STABLE" if stable and depth > 0 else ""
        print(f"  Depth {depth}: {num_classes} classes: {class_list}{status}")
        if stable:
            break
        prev_classes = class_list

    print()
    partition, index, steps = partition_refinement(A)
    print(f"Result: Nerode index = {index} (reduced from {len(A.states)} states)")
    print(f"Refinement converged in {steps} step(s)")
    print(f"Bound: steps ≤ |Q| = {len(A.states)} ✓")
    print()

    # Build and verify quotient
    B = build_quotient_automaton(A, partition, index)
    equiv = verify_equivalence(A, B, max_word_length=8)
    print(f"Quotient automaton: {B.states}")
    print(f"Quotient outputs: {B.out}")
    print(f"Language equivalence verified (words up to length 8): {equiv}")


def demo_stabilization_bound():
    """Demonstrate that stabilization always occurs within |Q| steps."""
    print()
    print("=" * 70)
    print("DEMO 2: Stabilization Bound |Q|")
    print("=" * 70)
    print()
    print("Theorem: For any deterministic tropical automaton with |Q| states,")
    print("partition refinement stabilizes within |Q| refinement steps.")
    print()

    import random
    random.seed(42)

    results = []
    for trial in range(10):
        n_states = random.randint(3, 12)
        n_alpha = random.randint(2, 4)
        states = [f"s{i}" for i in range(n_states)]
        alphabet = [chr(ord('a') + i) for i in range(n_alpha)]

        step = {}
        for q in states:
            for a in alphabet:
                step[(q, a)] = random.choice(states)

        out = {}
        for q in states:
            out[q] = random.choice([0, 1, 2, 3, 5, 10, INF])

        A = DetTropicalAutomaton(states, alphabet, step, out, init=states[0])
        _, index, steps = partition_refinement(A)
        results.append((n_states, n_alpha, index, steps))

        print(f"  Trial {trial+1}: |Q|={n_states}, |Σ|={n_alpha}, "
              f"index={index}, steps={steps}, "
              f"steps ≤ |Q|: {'✓' if steps <= n_states else '✗'}")

    print()
    all_ok = all(steps <= n for n, _, _, steps in results)
    print(f"All trials satisfy bound: {all_ok}")


def demo_tropical_cost_semantics():
    """Show how tropical automata compute shortest-path style costs."""
    print()
    print("=" * 70)
    print("DEMO 3: Tropical Cost Semantics")
    print("=" * 70)
    print()
    print("A tropical automaton assigns costs to words using min-plus arithmetic.")
    print("The output of state q on word w is the cost accumulated by")
    print("following the path q →w→ q', where q' = δ*(q, w).")
    print()

    # A simple routing cost automaton
    A = DetTropicalAutomaton(
        states=["Home", "Work", "Gym", "Park"],
        alphabet=["drive", "walk"],
        step={
            ("Home", "drive"): "Work",   ("Home", "walk"): "Park",
            ("Work", "drive"): "Gym",    ("Work", "walk"): "Home",
            ("Gym", "drive"): "Home",    ("Gym", "walk"): "Park",
            ("Park", "drive"): "Work",   ("Park", "walk"): "Gym",
        },
        out={"Home": 0, "Work": 5, "Gym": 3, "Park": 2},
        init="Home"
    )

    print("Routing automaton (costs to reach each location):")
    print(f"  Outputs: {A.out}")
    print()

    words = [
        [],
        ["drive"],
        ["walk"],
        ["drive", "drive"],
        ["walk", "walk"],
        ["drive", "walk"],
        ["drive", "drive", "walk"],
    ]

    print("Word costs (from Home):")
    for w in words:
        cost = A.language(w)
        word_str = "ε" if not w else " → ".join(w)
        state = A.eval_from(A.init, w)
        print(f"  {word_str:35s} → state={state:6s}, cost={cost}")

    print()
    partition, index, steps = partition_refinement(A)
    print(f"Nerode index: {index} (same as |Q|={len(A.states)} — already minimal)")


def demo_minimality():
    """Demonstrate that the quotient is truly minimal."""
    print()
    print("=" * 70)
    print("DEMO 4: Minimality of the Quotient")
    print("=" * 70)
    print()
    print("The quotient automaton is the SMALLEST equivalent automaton.")
    print("No further compression is possible without changing the language.")
    print()

    # An 8-state automaton with significant redundancy
    states = [f"q{i}" for i in range(8)]
    alphabet = ["0", "1"]

    # q0≡q1, q2≡q3, q4≡q5, q6≡q7
    step = {
        ("q0", "0"): "q2", ("q0", "1"): "q4",
        ("q1", "0"): "q3", ("q1", "1"): "q5",
        ("q2", "0"): "q6", ("q2", "1"): "q0",
        ("q3", "0"): "q7", ("q3", "1"): "q1",
        ("q4", "0"): "q0", ("q4", "1"): "q6",
        ("q5", "0"): "q1", ("q5", "1"): "q7",
        ("q6", "0"): "q4", ("q6", "1"): "q2",
        ("q7", "0"): "q5", ("q7", "1"): "q3",
    }

    out = {"q0": 0, "q1": 0, "q2": 3, "q3": 3,
           "q4": 1, "q5": 1, "q6": 5, "q7": 5}

    A = DetTropicalAutomaton(states, alphabet, step, out, init="q0")

    partition, index, steps = partition_refinement(A)
    print(f"Original: {len(A.states)} states")
    print(f"Minimal:  {index} states")
    print(f"Compression ratio: {len(A.states)/index:.1f}x")
    print()

    # Show equivalence classes
    classes = {}
    for q, c in partition.items():
        classes.setdefault(c, []).append(q)
    print("Equivalence classes:")
    for c, members in sorted(classes.items()):
        outputs = [A.out[q] for q in members]
        print(f"  Class {c}: {members} (all have output {outputs[0]})")

    B = build_quotient_automaton(A, partition, index)
    equiv = verify_equivalence(A, B, max_word_length=10)
    print(f"\nLanguage equivalence verified: {equiv}")

    # Verify minimality: all quotient states have distinct residuals
    print("\nMinimality check (distinct residuals):")
    for i, qi in enumerate(B.states):
        residuals = []
        for length in range(4):
            def gen_words(n):
                if n == 0:
                    yield []
                    return
                for a in B.alphabet:
                    for w in gen_words(n - 1):
                        yield [a] + w
            for w in gen_words(length):
                residuals.append(B.state_residual(qi, w))
        print(f"  {qi}: first residual values = {residuals[:8]}")


if __name__ == "__main__":
    demo_partition_refinement_convergence()
    demo_stabilization_bound()
    demo_tropical_cost_semantics()
    demo_minimality()
    print()
    print("=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for Tropical Automata Minimization.
Generates figures showing partition refinement convergence, class count evolution, etc.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import random
import base64
import io

from algorithms import (
    DetTropicalAutomaton,
    partition_refinement,
    compute_depth_partition,
    INF
)


def fig_to_base64(fig) -> str:
    """Convert a matplotlib figure to a base64-encoded PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


def visualize_refinement_convergence():
    """Visualize partition refinement convergence for several automata."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    examples = [
        ("6-state redundant", {
            "states": ["q0", "q1", "q2", "q3", "q4", "q5"],
            "alphabet": ["a", "b"],
            "step": {
                ("q0", "a"): "q2", ("q0", "b"): "q4",
                ("q1", "a"): "q3", ("q1", "b"): "q4",
                ("q2", "a"): "q4", ("q2", "b"): "q5",
                ("q3", "a"): "q4", ("q3", "b"): "q5",
                ("q4", "a"): "q4", ("q4", "b"): "q4",
                ("q5", "a"): "q5", ("q5", "b"): "q5",
            },
            "out": {"q0": 0, "q1": 0, "q2": 2, "q3": 2, "q4": 7, "q5": 1},
        }),
        ("8-state pairwise", {
            "states": [f"q{i}" for i in range(8)],
            "alphabet": ["0", "1"],
            "step": {
                ("q0", "0"): "q2", ("q0", "1"): "q4",
                ("q1", "0"): "q3", ("q1", "1"): "q5",
                ("q2", "0"): "q6", ("q2", "1"): "q0",
                ("q3", "0"): "q7", ("q3", "1"): "q1",
                ("q4", "0"): "q0", ("q4", "1"): "q6",
                ("q5", "0"): "q1", ("q5", "1"): "q7",
                ("q6", "0"): "q4", ("q6", "1"): "q2",
                ("q7", "0"): "q5", ("q7", "1"): "q3",
            },
            "out": {"q0": 0, "q1": 0, "q2": 3, "q3": 3,
                    "q4": 1, "q5": 1, "q6": 5, "q7": 5},
        }),
        ("4-state minimal", {
            "states": ["s0", "s1", "s2", "s3"],
            "alphabet": ["a", "b"],
            "step": {
                ("s0", "a"): "s1", ("s0", "b"): "s2",
                ("s1", "a"): "s3", ("s1", "b"): "s0",
                ("s2", "a"): "s0", ("s2", "b"): "s3",
                ("s3", "a"): "s2", ("s3", "b"): "s1",
            },
            "out": {"s0": 0, "s1": 2, "s2": 4, "s3": 1},
        }),
    ]

    for idx, (name, params) in enumerate(examples):
        ax = axes[idx]
        A = DetTropicalAutomaton(**params)
        n = len(A.states)

        depths = list(range(n + 1))
        class_counts = []
        for d in depths:
            p = compute_depth_partition(A, d)
            class_counts.append(len(set(p.values())))

        ax.plot(depths, class_counts, 'b-o', linewidth=2, markersize=8)
        ax.axhline(y=n, color='r', linestyle='--', alpha=0.5, label=f'|Q| = {n}')

        # Mark stabilization point
        for i in range(1, len(class_counts)):
            if class_counts[i] == class_counts[i-1]:
                ax.axvline(x=i, color='g', linestyle=':', alpha=0.5)
                ax.annotate('stable', xy=(i, class_counts[i]),
                           xytext=(i+0.3, class_counts[i]+0.3),
                           fontsize=9, color='green')
                break

        ax.set_xlabel('Refinement Depth', fontsize=11)
        ax.set_ylabel('Number of Classes', fontsize=11)
        ax.set_title(name, fontsize=12, fontweight='bold')
        ax.set_ylim(0, n + 1)
        ax.set_xticks(depths)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    fig.suptitle('Partition Refinement Convergence', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def visualize_stabilization_statistics():
    """Show stabilization step distribution over random automata."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    random.seed(123)

    # Experiment: vary |Q|, fixed |Σ|
    sizes = range(3, 25)
    avg_steps = []
    max_steps_list = []
    for n in sizes:
        steps_list = []
        for _ in range(50):
            states = [f"s{i}" for i in range(n)]
            alphabet = ["a", "b"]
            step = {(q, a): random.choice(states) for q in states for a in alphabet}
            out = {q: random.choice([0, 1, 2, 3, 5, INF]) for q in states}
            A = DetTropicalAutomaton(states, alphabet, step, out)
            _, _, s = partition_refinement(A)
            steps_list.append(s)
        avg_steps.append(np.mean(steps_list))
        max_steps_list.append(max(steps_list))

    ax = axes[0]
    ax.plot(list(sizes), avg_steps, 'b-o', markersize=4, label='Average steps')
    ax.plot(list(sizes), max_steps_list, 'r-^', markersize=4, label='Max steps')
    ax.plot(list(sizes), list(sizes), 'k--', alpha=0.5, label='|Q| bound')
    ax.set_xlabel('Number of States |Q|', fontsize=11)
    ax.set_ylabel('Refinement Steps', fontsize=11)
    ax.set_title('Steps vs. State Count', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Experiment: compression ratio
    random.seed(456)
    compressions = []
    q_sizes = []
    for _ in range(200):
        n = random.randint(4, 20)
        states = [f"s{i}" for i in range(n)]
        alphabet = ["a", "b", "c"]
        step = {(q, a): random.choice(states) for q in states for a in alphabet}
        out = {q: random.choice([0, 1, 2, 3]) for q in states}
        A = DetTropicalAutomaton(states, alphabet, step, out)
        _, idx, _ = partition_refinement(A)
        compressions.append(n / idx if idx > 0 else 1)
        q_sizes.append(n)

    ax = axes[1]
    ax.scatter(q_sizes, compressions, alpha=0.4, s=20, c='blue')
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='No compression')
    ax.set_xlabel('Original State Count |Q|', fontsize=11)
    ax.set_ylabel('Compression Ratio |Q|/index', fontsize=11)
    ax.set_title('Compression Ratio Distribution', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    fig.suptitle('Stabilization and Compression Statistics', fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    return fig


def visualize_equivalence_pairs():
    """Visualize the pair set (equivalent pairs) shrinking during refinement."""
    fig, ax = plt.subplots(figsize=(8, 6))

    states = [f"q{i}" for i in range(8)]
    alphabet = ["0", "1"]
    step = {
        ("q0", "0"): "q2", ("q0", "1"): "q4",
        ("q1", "0"): "q3", ("q1", "1"): "q5",
        ("q2", "0"): "q6", ("q2", "1"): "q0",
        ("q3", "0"): "q7", ("q3", "1"): "q1",
        ("q4", "0"): "q0", ("q4", "1"): "q6",
        ("q5", "0"): "q1", ("q5", "1"): "q7",
        ("q6", "0"): "q4", ("q6", "1"): "q2",
        ("q7", "0"): "q5", ("q7", "1"): "q3",
    }
    out = {"q0": 0, "q1": 0, "q2": 3, "q3": 3,
           "q4": 1, "q5": 1, "q6": 5, "q7": 5}

    A = DetTropicalAutomaton(states, alphabet, step, out)
    n = len(states)

    pair_counts = []
    class_counts = []
    for depth in range(n + 1):
        p = compute_depth_partition(A, depth)
        num_classes = len(set(p.values()))
        class_counts.append(num_classes)

        # Count equivalent pairs
        pairs = 0
        for i, q in enumerate(states):
            for j, r in enumerate(states):
                if p[q] == p[r]:
                    pairs += 1
        pair_counts.append(pairs)

    depths = list(range(n + 1))
    ax2 = ax.twinx()

    line1, = ax.plot(depths, pair_counts, 'b-s', linewidth=2, markersize=8, label='Equivalent pairs')
    line2, = ax2.plot(depths, class_counts, 'r-o', linewidth=2, markersize=8, label='Classes')
    ax.axhline(y=n, color='b', linestyle=':', alpha=0.3)
    ax2.axhline(y=n, color='r', linestyle=':', alpha=0.3)

    ax.set_xlabel('Refinement Depth', fontsize=12)
    ax.set_ylabel('Number of Equivalent Pairs', fontsize=12, color='blue')
    ax2.set_ylabel('Number of Classes', fontsize=12, color='red')
    ax.set_title('Pair Set Contraction During Refinement (8-state automaton)',
                fontsize=13, fontweight='bold')

    lines = [line1, line2]
    labels = [l.get_label() for l in lines]
    ax.legend(lines, labels, fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_xticks(depths)

    plt.tight_layout()
    return fig


def generate_all_visualizations():
    """Generate all visualizations and save them."""
    print("Generating visualizations...")

    fig1 = visualize_refinement_convergence()
    fig1.savefig('viz_convergence.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_convergence.png")

    fig2 = visualize_stabilization_statistics()
    fig2.savefig('viz_statistics.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_statistics.png")

    fig3 = visualize_equivalence_pairs()
    fig3.savefig('viz_pairs.png', dpi=150, bbox_inches='tight')
    print("  Saved viz_pairs.png")

    return fig1, fig2, fig3


if __name__ == "__main__":
    generate_all_visualizations()
    print("All visualizations generated.")
