#!/usr/bin/env python3
"""
Transfinite Cellular Automata Demo
===================================
Demonstrates cellular automata evolution with transfinite-style limit rules.
Since we cannot literally compute at ordinal ω in finite time, we simulate
the "limit behavior" by running a CA for many steps and applying the
eventual-value / limsup rule when the sequence stabilizes.
"""

def rule110(left: bool, center: bool, right: bool) -> bool:
    """Rule 110 cellular automaton."""
    idx = (int(left) << 2) | (int(center) << 1) | int(right)
    # Rule 110 = binary 01101110
    return bool((110 >> idx) & 1)

def apply_ca_rule(rule_fn, config: list[bool]) -> list[bool]:
    """Apply a CA rule to a configuration (with wraparound boundary)."""
    n = len(config)
    return [rule_fn(config[(i-1) % n], config[i], config[(i+1) % n]) for i in range(n)]

def run_ca(rule_fn, init: list[bool], steps: int) -> list[list[bool]]:
    """Run a CA for a given number of steps, returning all configurations."""
    history = [init]
    current = init
    for _ in range(steps):
        current = apply_ca_rule(rule_fn, current)
        history.append(current)
    return history

def eventual_value_limit(history: list[list[bool]], cell: int) -> bool:
    """Compute the eventual-value limit rule for a cell.
    Returns True if the cell is eventually always True."""
    n = len(history)
    for start in range(n):
        if all(history[t][cell] for t in range(start, n)):
            return True
    return False

def limsup_limit(history: list[list[bool]], cell: int) -> bool:
    """Compute the limsup limit rule for a cell.
    Returns True if the cell is True cofinally (infinitely often)."""
    n = len(history)
    # Check if True appears in the last quarter of the history
    quarter = max(1, n // 4)
    return any(history[t][cell] for t in range(n - quarter, n))

def display_config(config: list[bool], char_true='█', char_false='·') -> str:
    """Display a configuration as a string."""
    return ''.join(char_true if c else char_false for c in config)


def demo_rule110():
    """Demonstrate Rule 110 evolution and transfinite limit behavior."""
    print("=" * 60)
    print("RULE 110 CELLULAR AUTOMATON")
    print("=" * 60)

    # Single cell initialization
    size = 40
    init = [False] * size
    init[size // 2] = True

    history = run_ca(rule110, init, 30)

    print(f"\nEvolution from single cell (size={size}, 30 steps):")
    for t, config in enumerate(history):
        print(f"  t={t:3d}: {display_config(config)}")

    # Compute limit rules
    print("\n--- Limit Behavior at 'ω' ---")
    eventual = [eventual_value_limit(history, i) for i in range(size)]
    limsup = [limsup_limit(history, i) for i in range(size)]

    print(f"  Eventual value: {display_config(eventual)}")
    print(f"  Limsup:         {display_config(limsup)}")


def demo_stabilization():
    """Demonstrate stabilization ordinals for different CA rules."""
    print("\n" + "=" * 60)
    print("STABILIZATION ORDINALS")
    print("=" * 60)

    # Identity rule (stabilizes at 0)
    def rule_identity(l, c, r):
        return c

    # XOR rule (may oscillate)
    def rule_xor(l, c, r):
        return l ^ r

    # AND rule (monotone, stabilizes quickly)
    def rule_and(l, c, r):
        return l and c and r

    size = 20
    init = [i % 3 == 0 for i in range(size)]

    rules = [
        ("Identity (stabilizes at 0)", rule_identity),
        ("Rule 110 (complex)", rule110),
        ("AND rule (monotone, fast stabilization)", rule_and),
    ]

    for name, rule_fn in rules:
        history = run_ca(rule_fn, init, 50)

        # Find stabilization step
        stab_step = None
        for t in range(len(history) - 1):
            if history[t] == history[t + 1]:
                stab_step = t
                break

        print(f"\n  {name}:")
        print(f"    Initial: {display_config(init)}")
        if stab_step is not None:
            print(f"    Stabilizes at step {stab_step}")
            print(f"    Final:   {display_config(history[stab_step])}")
        else:
            print(f"    Does NOT stabilize within 50 steps")
            print(f"    Step 50: {display_config(history[50])}")


def demo_transfinite_iteration():
    """Demonstrate the concept of transfinite iteration:
    run CA, apply limit rule, run again, apply limit rule, etc."""
    print("\n" + "=" * 60)
    print("TRANSFINITE ITERATION (ω × 3)")
    print("=" * 60)

    size = 30
    init = [False] * size
    init[size // 2] = True
    init[size // 4] = True

    current = init
    for epoch in range(3):
        print(f"\n  --- Epoch {epoch} (ordinal ω·{epoch} to ω·{epoch+1}) ---")
        history = run_ca(rule110, current, 20)

        for t in [0, 5, 10, 15, 20]:
            print(f"    t=ω·{epoch}+{t:2d}: {display_config(history[t])}")

        # Apply eventual-value limit rule
        current = [eventual_value_limit(history, i) for i in range(size)]
        print(f"    Limit (ω·{epoch+1}): {display_config(current)}")


def demo_successor_counting():
    """Demonstrate the successor counting function and its stabilization."""
    print("\n" + "=" * 60)
    print("SUCCESSOR COUNTING (Stabilization at Prescribed Ordinals)")
    print("=" * 60)

    for bound in [3, 5, 10]:
        values = [min(n, bound) for n in range(bound + 5)]
        print(f"\n  bound={bound}: {values}")
        print(f"    Stabilizes at step {bound} (value={bound})")


if __name__ == "__main__":
    demo_rule110()
    demo_stabilization()
    demo_transfinite_iteration()
    demo_successor_counting()
    print("\n" + "=" * 60)
    print("Demo complete.")


#!/usr/bin/env python3
"""
Visualization: Transfinite CA Evolution Spacetime Diagram
=========================================================
Creates a spacetime diagram showing Rule 110 evolution with
transfinite limit-rule behavior marked at epoch boundaries.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def rule110(left: bool, center: bool, right: bool) -> bool:
    idx = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> idx) & 1)


def apply_rule(config: list[bool]) -> list[bool]:
    n = len(config)
    return [rule110(config[(i-1) % n], config[i], config[(i+1) % n])
            for i in range(n)]


def eventual_value_limit(history: list[list[bool]]) -> list[bool]:
    n = len(history[0])
    result = []
    for i in range(n):
        last_false = -1
        for t in range(len(history)):
            if not history[t][i]:
                last_false = t
        result.append(last_false < len(history) - 1 and
                      all(history[t][i] for t in range(last_false + 1, len(history))))
    return result


def main():
    size = 60
    steps_per_epoch = 25
    num_epochs = 4

    init = [False] * size
    init[size // 2] = True
    init[size // 3] = True

    all_configs = []
    limit_rows = []
    current = init

    for epoch in range(num_epochs):
        epoch_history = [current]
        for _ in range(steps_per_epoch):
            current = apply_rule(current)
            epoch_history.append(current)
        all_configs.extend(epoch_history)
        limit_rows.append(len(all_configs) - 1)
        current = eventual_value_limit(epoch_history)
        all_configs.append(current)

    # Convert to numpy array
    grid = np.array([[int(c) for c in row] for row in all_configs])

    fig, ax = plt.subplots(figsize=(12, 8))
    ax.imshow(grid, cmap='binary', aspect='auto', interpolation='nearest')

    # Mark limit ordinals
    for lr in limit_rows:
        ax.axhline(y=lr + 0.5, color='red', linewidth=2, linestyle='--', alpha=0.7)

    ax.set_xlabel('Cell Position', fontsize=12)
    ax.set_ylabel('Time Step', fontsize=12)
    ax.set_title('Transfinite CA Evolution: Rule 110 with Eventual-Value Limit Rule\n'
                 'Red lines = limit ordinals (ω, 2ω, 3ω, ...)', fontsize=14)

    limit_patch = mpatches.Patch(color='red', alpha=0.7, label='Limit ordinal (ω·k)')
    ax.legend(handles=[limit_patch], loc='upper right')

    plt.tight_layout()
    plt.savefig('transfinite_ca_evolution.png', dpi=150, bbox_inches='tight')
    print("Saved transfinite_ca_evolution.png")


if __name__ == "__main__":
    main()
