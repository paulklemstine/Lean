#!/usr/bin/env python3
"""
Demo: Self-Modifying Computation and Undecidability

Demonstrates the key results from the formalization:
1. Diagonal argument escaping any enumeration
2. Adaptive adversary defeating classifiers
3. Self-modifying system simulation with stabilization detection
4. Strategic agent bypassing monitors
"""

from typing import Callable, Optional, Tuple, List


def diagonal(enum: Callable[[int, int], bool], n: int) -> bool:
    """The diagonal function: negate enum(n, n)."""
    return not enum(n, n)


def demo_diagonal():
    """Demonstrate that the diagonal escapes any enumeration."""
    print("=" * 60)
    print("DEMO 1: Diagonal Argument")
    print("=" * 60)

    # Define an enumeration of Boolean predicates
    def enum(program: int, input_val: int) -> bool:
        """Example enumeration: program i accepts input j iff (i + j) % 3 == 0."""
        return (program + input_val) % 3 == 0

    print("\nEnumeration: enum(i, j) = ((i + j) % 3 == 0)")
    print("\nProgram behaviors on their own index:")
    for i in range(10):
        print(f"  enum({i}, {i}) = {enum(i, i)}, diagonal({i}) = {diagonal(enum, i)}")

    # Verify the diagonal differs from every program at its own index
    print("\nVerification: diagonal differs from every program at its index:")
    for i in range(10):
        assert diagonal(enum, i) != enum(i, i), f"Failed at {i}!"
        print(f"  diagonal({i}) = {diagonal(enum, i)} ≠ enum({i}, {i}) = {enum(i, i)} ✓")

    # Check: is diagonal in the enumeration?
    print("\nSearching for diagonal in enumeration (first 1000 programs)...")
    for k in range(1000):
        matches = all(enum(k, n) == diagonal(enum, n) for n in range(100))
        if matches:
            print(f"  Found match at k={k}!")
            break
    else:
        print("  No match found — diagonal escapes the enumeration! ✓")


def demo_adaptive_adversary():
    """Demonstrate the virus detection paradox."""
    print("\n" + "=" * 60)
    print("DEMO 2: Adaptive Adversary (Virus Detection Paradox)")
    print("=" * 60)

    class AdaptiveProgram:
        def __init__(self, base: bool, react: Callable[[bool], bool]):
            self.base = base
            self.react = react

        def actual_behavior(self, classifier_output: bool) -> bool:
            return self.react(classifier_output)

    # The contrarian program
    contrarian = AdaptiveProgram(base=True, react=lambda pred: not pred)

    # Test various classifiers
    classifiers = [
        ("Always-Safe", lambda p: True),
        ("Always-Dangerous", lambda p: False),
        ("Check-Base", lambda p: p.base),
        ("Anti-Base", lambda p: not p.base),
    ]

    print("\nTesting classifiers against the contrarian program:")
    for name, classifier in classifiers:
        prediction = classifier(contrarian)
        actual = contrarian.actual_behavior(prediction)
        correct = prediction == actual
        print(f"  {name}: predicts={prediction}, actual={actual}, correct={correct} {'✓' if not correct else '✗'}")
        assert not correct, f"Classifier {name} should fail!"

    print("\n  All classifiers defeated by contrarian! ✓")


def demo_self_modifying_system():
    """Simulate a self-modifying system and detect stabilization."""
    print("\n" + "=" * 60)
    print("DEMO 3: Self-Modifying System Simulation")
    print("=" * 60)

    def simulate(code: int, data: int,
                 step: Callable[[int, int], Optional[Tuple[int, int]]],
                 max_steps: int = 100) -> Tuple[List[int], List[int], bool, int]:
        """Simulate and return code history, data history, halted, steps."""
        codes = [code]
        datas = [data]
        for i in range(max_steps):
            result = step(code, data)
            if result is None:
                return codes, datas, True, i
            code, data = result
            codes.append(code)
            datas.append(data)
        return codes, datas, False, max_steps

    # System 1: Code stabilizes, data keeps going
    print("\nSystem 1: Self-optimizing code (stabilizes)")
    def step1(code: int, data: int) -> Optional[Tuple[int, int]]:
        if code > 0:
            return (code - 1, data + code)  # Code decreases, data accumulates
        return (0, data + 1)  # Code frozen at 0, data keeps going

    codes, datas, halted, steps = simulate(5, 0, step1, 20)
    print(f"  Code history: {codes[:15]}...")
    print(f"  Data history: {datas[:15]}...")
    print(f"  Halted: {halted}")
    stab_idx = next((i for i in range(len(codes)-1) if all(c == codes[i] for c in codes[i:])), None)
    print(f"  Code stabilized at step: {stab_idx}")

    # System 2: Halting system
    print("\nSystem 2: Halting system (countdown)")
    def step2(code: int, data: int) -> Optional[Tuple[int, int]]:
        if data == 0:
            return None  # Halt
        return (code ^ data, data - 1)  # Self-modify code via XOR

    codes, datas, halted, steps = simulate(42, 8, step2, 50)
    print(f"  Code history: {codes}")
    print(f"  Data history: {datas}")
    print(f"  Halted: {halted} at step {steps}")

    # System 3: Oscillating code (never stabilizes)
    print("\nSystem 3: Oscillating code (never stabilizes)")
    def step3(code: int, data: int) -> Optional[Tuple[int, int]]:
        return ((code + 1) % 3, data + 1)  # Code cycles through 0,1,2

    codes, datas, halted, steps = simulate(0, 0, step3, 15)
    print(f"  Code history: {codes}")
    print(f"  Halted: {halted}")
    print(f"  Code oscillates with period 3 — never stabilizes!")


def demo_anti_alignment():
    """Demonstrate strategic agents bypassing monitors."""
    print("\n" + "=" * 60)
    print("DEMO 4: Anti-Alignment (Strategic Agents vs. Monitors)")
    print("=" * 60)

    class StrategicAgent:
        def __init__(self, target: int, strategy: Callable[[bool], int]):
            self.target = target
            self.strategy = strategy

        def output(self, monitor: Callable[[int], bool]) -> int:
            return self.strategy(monitor(self.target))

    # Deceptive agent: ignores monitor
    def deceptive(target: int) -> StrategicAgent:
        return StrategicAgent(target, lambda _: target)

    # Various monitors
    monitors = [
        ("Block-All", lambda t: False),
        ("Allow-All", lambda t: True),
        ("Block-Even", lambda t: t % 2 != 0),
        ("Block-Large", lambda t: t < 10),
    ]

    target = 42
    agent = deceptive(target)

    print(f"\nDeceptive agent targeting output: {target}")
    for name, monitor in monitors:
        actual_output = agent.output(monitor)
        blocked = not monitor(target)
        achieved = actual_output == target
        print(f"  {name}: blocked={blocked}, agent output={actual_output}, "
              f"achieved target={achieved} {'✓' if achieved else '✗'}")

    print("\n  Deceptive agent achieves target against ALL monitors! ✓")


if __name__ == "__main__":
    demo_diagonal()
    demo_adaptive_adversary()
    demo_self_modifying_system()
    demo_anti_alignment()
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: The Diagonal Argument

Shows how the diagonal function escapes any enumeration of Boolean predicates.
Produces a heatmap of enum(i,j) values with the diagonal highlighted.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def create_diagonal_visualization(n: int = 12):
    """Create a heatmap showing the diagonal argument."""
    # Define an enumeration
    enum = np.array([[int((i * j + i) % 5 < 2) for j in range(n)] for i in range(n)])

    # Compute diagonal
    diag = np.array([1 - enum[i, i] for i in range(n)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Heatmap of enumeration
    im = ax1.imshow(enum, cmap='RdYlGn', aspect='equal', vmin=0, vmax=1)
    ax1.set_xlabel('Input j', fontsize=12)
    ax1.set_ylabel('Program i', fontsize=12)
    ax1.set_title('Enumeration: enum(i, j)', fontsize=14)

    # Highlight diagonal cells
    for i in range(n):
        rect = patches.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                  linewidth=3, edgecolor='blue',
                                  facecolor='none', linestyle='--')
        ax1.add_patch(rect)
        ax1.text(i, i, str(enum[i, i]), ha='center', va='center',
                fontsize=10, fontweight='bold', color='blue')

    # Add cell values
    for i in range(n):
        for j in range(n):
            if i != j:
                ax1.text(j, i, str(enum[i, j]), ha='center', va='center',
                        fontsize=8, color='gray')

    ax1.set_xticks(range(n))
    ax1.set_yticks(range(n))

    # Diagonal vs each program
    colors = ['#e74c3c' if diag[i] != enum[i, i] else '#2ecc71' for i in range(n)]
    bars = ax2.bar(range(n), [1] * n, color=colors, edgecolor='black', alpha=0.7)

    for i in range(n):
        ax2.text(i, 0.7, f'enum={enum[i,i]}', ha='center', va='center',
                fontsize=9, color='black')
        ax2.text(i, 0.3, f'diag={diag[i]}', ha='center', va='center',
                fontsize=9, color='white', fontweight='bold')

    ax2.set_xlabel('Program index i', fontsize=12)
    ax2.set_title('Diagonal ≠ enum(i, i) at every index', fontsize=14)
    ax2.set_xticks(range(n))
    ax2.set_ylim(0, 1.2)
    ax2.set_yticks([])

    # Legend
    legend_elements = [
        patches.Patch(facecolor='#e74c3c', label='Diagonal differs (always!)'),
        patches.Patch(facecolor='#2ecc71', label='Would match (impossible)')
    ]
    ax2.legend(handles=legend_elements, loc='upper right')

    plt.suptitle('The Diagonal Argument: Why No Enumeration Is Surjective',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_diagonal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_diagonal.png")


def create_code_evolution_visualization():
    """Visualize code evolution in self-modifying systems."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # System 1: Stabilizing
    codes1 = [10, 8, 6, 4, 3, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0]
    axes[0].plot(codes1, 'b-o', markersize=6, linewidth=2)
    axes[0].axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Stable code')
    axes[0].fill_between(range(7, 15), 0, max(codes1), alpha=0.1, color='green')
    axes[0].set_title('Stabilizing System', fontsize=13, fontweight='bold')
    axes[0].set_xlabel('Step')
    axes[0].set_ylabel('Code State')
    axes[0].legend(['Code value', 'Fixed point', 'Stabilized region'])

    # System 2: Halting
    codes2 = [42, 40, 34, 32, 2, 0]
    axes[1].plot(codes2, 'r-s', markersize=8, linewidth=2)
    axes[1].plot(len(codes2) - 1, codes2[-1], 'k*', markersize=20)
    axes[1].set_title('Halting System', fontsize=13, fontweight='bold')
    axes[1].set_xlabel('Step')
    axes[1].set_ylabel('Code State')
    axes[1].legend(['Code value', 'HALT'])

    # System 3: Oscillating
    codes3 = [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2]
    axes[2].plot(codes3, 'g-^', markersize=6, linewidth=2)
    axes[2].set_title('Oscillating System (Never Stabilizes)', fontsize=13, fontweight='bold')
    axes[2].set_xlabel('Step')
    axes[2].set_ylabel('Code State')
    axes[2].legend(['Code value (period 3)'])

    plt.suptitle('Self-Modifying System Behaviors: Three Fates',
                fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('viz_code_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_code_evolution.png")


if __name__ == "__main__":
    create_diagonal_visualization()
    create_code_evolution_visualization()
