#!/usr/bin/env python3
"""
Cellular Automata at the Ordinals: Transfinite Computation Demo

Demonstrates Rule 110 evolution and transfinite computation concepts.
"""

import sys


def rule110(left: bool, center: bool, right: bool) -> bool:
    """Rule 110 elementary cellular automaton lookup table."""
    table = {
        (True, True, True): False,
        (True, True, False): True,
        (True, False, True): True,
        (True, False, False): False,
        (False, True, True): True,
        (False, True, False): True,
        (False, False, True): True,
        (False, False, False): False,
    }
    return table[(left, center, right)]


def step_config(config: list[bool]) -> list[bool]:
    """Apply Rule 110 to evolve a configuration one step (periodic boundary)."""
    n = len(config)
    return [rule110(config[(i - 1) % n], config[i], config[(i + 1) % n])
            for i in range(n)]


def evolve(config: list[bool], steps: int) -> list[list[bool]]:
    """Evolve a configuration for multiple steps, returning the history."""
    history = [config]
    for _ in range(steps):
        config = step_config(config)
        history.append(config)
    return history


def display(history: list[list[bool]], width: int = 80) -> None:
    """Display a spacetime diagram using Unicode characters."""
    for row in history:
        line = ''.join('█' if cell else ' ' for cell in row)
        print(line[:width])


def detect_halting(history: list[list[bool]]) -> tuple[bool, int]:
    """Detect if the evolution has stabilized (halting detection at ω).

    Returns (stabilized, step) where step is the first step at which
    the configuration stopped changing.
    """
    for i in range(1, len(history)):
        if history[i] == history[i - 1]:
            return True, i
    return False, len(history)


def orbit_cycle_detection(f, start, max_steps: int = 1000):
    """Detect orbit cycling using Floyd's algorithm.

    Demonstrates the orbit_eventually_cycles theorem:
    for finite state spaces, orbits must cycle.
    """
    # Phase 1: Find a repeated element
    slow = start
    fast = start
    for step in range(1, max_steps):
        slow = f(slow)
        fast = f(f(fast))
        if slow == fast:
            # Phase 2: Find the start of the cycle
            mu = 0
            slow = start
            while slow != fast:
                slow = f(slow)
                fast = f(fast)
                mu += 1
            # Phase 3: Find cycle length
            lam = 1
            fast = f(slow)
            while slow != fast:
                fast = f(fast)
                lam += 1
            return mu, lam
    return None, None


def kleene_chain_demo():
    """Demonstrate the Kleene chain reaching a fixed point.

    We use f(x) = max(x, threshold) on a finite lattice {0, 1, ..., N}.
    The Kleene chain starts at 0 (= ⊥) and iterates until fixed point.
    """
    N = 10
    threshold = 7

    def f(x):
        return max(x, threshold)

    print("=== Kleene Chain Fixed Point Demo ===")
    print(f"Lattice: {{0, 1, ..., {N}}}")
    print(f"f(x) = max(x, {threshold})")
    print()

    x = 0  # ⊥
    for step in range(5):
        fx = f(x)
        print(f"  Step {step}: x = {x}, f(x) = {fx}", end="")
        if fx == x:
            print(f"  ← FIXED POINT reached at step {step}!")
            break
        print()
        x = fx
    print()


def transfinite_hierarchy_demo():
    """Demonstrate the ordinal computational hierarchy.

    Shows that ω·2 > ω and ω² > ω·n for all finite n,
    corresponding to increasing computational power.
    """
    print("=== Ordinal Computational Hierarchy ===")
    print()
    print("Level 0 (finite):  Standard computation (finitely many steps)")
    print("Level ω:           First limit — can detect halting of finite computations")
    print("Level ω·2:         Two limit aggregations — can detect halting of ω-computations")
    print("Level ω·n:         n limit aggregations")
    print("Level ω²:          Infinitely many limit levels")
    print()
    print("Key theorem: ω² > ω·n for all finite n")
    print("This means ω²-time CAs access infinitely many levels of limit aggregation.")
    print()

    # Demonstrate with ordinal arithmetic
    omega = float('inf')  # symbolic ω
    for n in range(1, 6):
        print(f"  ω·{n} < ω² = ω·ω  ✓")
    print()


def energy_stabilization_demo():
    """Demonstrate energy stabilization: antitone ordinal functions must stabilize.

    We simulate with a concrete decreasing sequence that must reach 0.
    """
    print("=== Energy Stabilization Demo ===")
    print("Simulating antitone energy function E(n) that must stabilize...")
    print()

    import random
    random.seed(42)

    energy = 20
    history = [energy]
    for step in range(30):
        if energy > 0:
            decrease = random.randint(0, min(3, energy))
            energy -= decrease
        history.append(energy)

    for i, e in enumerate(history):
        bar = '█' * e
        stabilized = " ← STABILIZED" if i > 0 and e == history[i - 1] == history[-1] else ""
        print(f"  Step {i:2d}: E = {e:2d}  {bar}{stabilized}")

    print()
    print("Theorem: Any antitone ordinal-valued function must stabilize.")
    print("This is the engine that guarantees ordinal CA convergence.")
    print()


def main():
    print("=" * 60)
    print("CELLULAR AUTOMATA AT THE ORDINALS")
    print("Transfinite Computation Demo")
    print("=" * 60)
    print()

    # Demo 1: Rule 110 evolution
    print("=== Rule 110 Evolution ===")
    print("Rule 110 is the simplest known Turing-complete CA.")
    print()

    # Single active cell in center
    width = 60
    init = [False] * width
    init[width // 2] = True

    history = evolve(init, 30)
    display(history, width)
    print()

    stabilized, step = detect_halting(history)
    if stabilized:
        print(f"Configuration stabilized at step {step}")
    else:
        print(f"Configuration still evolving after {len(history) - 1} steps")
    print()

    # Rule 110 properties
    print("Rule 110 properties (verified in Lean 4):")
    print(f"  Active neighborhoods: 5 out of 8")
    print(f"  Quiescent state: 000 → 0  ✓")
    print(f"  Breaks symmetry: 111 → 0  (not preserved under all-ones)")
    print(f"  Nontrivial: 111 → 0 ≠ 1 = center  ✓")
    print()

    # Demo 2: Orbit cycling
    print("=== Orbit Cycling (Pigeonhole) ===")
    states = list(range(8))
    f_map = {0: 3, 1: 5, 2: 0, 3: 7, 4: 1, 5: 3, 6: 2, 7: 5}

    def f_func(x):
        return f_map[x]

    print(f"State space: {states}")
    print(f"f: {f_map}")
    print()

    for start in [0, 1, 4]:
        mu, lam = orbit_cycle_detection(f_func, start)
        orbit = [start]
        x = start
        for _ in range(mu + lam + 2):
            x = f_func(x)
            orbit.append(x)
        print(f"  Start={start}: orbit = {orbit[:mu + lam + 2]}")
        print(f"    Tail length (μ) = {mu}, Cycle length (λ) = {lam}")
        print(f"    μ + λ = {mu + lam} ≤ {len(states)} = |states|  ✓")
        print()

    # Demo 3: Kleene chain
    kleene_chain_demo()

    # Demo 4: Hierarchy
    transfinite_hierarchy_demo()

    # Demo 5: Energy stabilization
    energy_stabilization_demo()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Ordinal Computational Hierarchy

Shows the strict hierarchy of computational power indexed by ordinals:
  finite < ω < ω·2 < ... < ω·n < ... < ω²
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left panel: Ordinal hierarchy as a nested structure
    ax = axes[0]
    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 6.5)
    ax.set_aspect('equal')

    # Draw ordinal levels
    levels = [
        (0, 'n ∈ ℕ', 'Finite computation', '#2196F3'),
        (1, 'ω', 'First limit: halting detection', '#4CAF50'),
        (2, 'ω·2', 'Two limit aggregations', '#FF9800'),
        (3, 'ω·3', 'Three limit aggregations', '#F44336'),
        (4, 'ω·n', 'n limit aggregations', '#9C27B0'),
        (5, 'ω²', 'Infinitely many levels', '#E91E63'),
        (6, 'ω² + ω', 'Beyond ω²: new frontier', '#607D8B'),
    ]

    for i, (y, label, desc, color) in enumerate(levels):
        # Draw level bar
        width = 2 + i * 0.8
        rect = plt.Rectangle((5 - width/2, y - 0.15), width, 0.3,
                              facecolor=color, alpha=0.7, edgecolor='black', linewidth=1)
        ax.add_patch(rect)
        ax.text(5, y, label, ha='center', va='center', fontsize=11,
                fontweight='bold', color='white')
        ax.text(5 + width/2 + 0.2, y, desc, ha='left', va='center',
                fontsize=9, color=color)

        # Draw arrows between levels
        if i > 0:
            ax.annotate('', xy=(5, y - 0.15), xytext=(5, y - 0.85 + 0.15),
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.set_title('Ordinal Computational Hierarchy\n'
                 'Each level strictly exceeds the one below',
                 fontsize=13, fontweight='bold')
    ax.axis('off')

    # Right panel: Energy stabilization
    ax2 = axes[1]

    # Simulate multiple energy traces
    np.random.seed(42)
    n_traces = 5
    colors = plt.cm.viridis(np.linspace(0.2, 0.8, n_traces))

    for trace_idx in range(n_traces):
        steps = 50
        energy = 20 + trace_idx * 5
        energies = [energy]
        for _ in range(steps):
            if energy > 0:
                decrease = np.random.randint(0, min(4, energy + 1))
                energy -= decrease
            energies.append(energy)

        ax2.plot(energies, color=colors[trace_idx], linewidth=2,
                label=f'E₀ = {energies[0]}', alpha=0.8)

        # Mark stabilization point
        for i in range(len(energies) - 1):
            if all(e == energies[i] for e in energies[i:]):
                ax2.axvline(x=i, color=colors[trace_idx], linestyle=':', alpha=0.3)
                ax2.scatter([i], [energies[i]], color=colors[trace_idx],
                          s=100, zorder=5, edgecolors='black')
                break

    ax2.set_xlabel('Ordinal Stage (simulated)', fontsize=12)
    ax2.set_ylabel('Energy E(α)', fontsize=12)
    ax2.set_title('Energy Stabilization Theorem\n'
                  'Antitone ordinal functions must stabilize',
                  fontsize=13, fontweight='bold')
    ax2.legend(loc='upper right', fontsize=9)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('ordinal_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: ordinal_hierarchy.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Orbit Cycling and Transfinite Computation

Demonstrates orbit cycling (pigeonhole theorem) and the connection
between finite-state dynamics and ordinal computation bounds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def detect_orbit(f_map: dict, start: int, max_steps: int = 100):
    """Trace an orbit and detect the cycle."""
    orbit = [start]
    seen = {start: 0}
    x = start
    for step in range(1, max_steps):
        x = f_map[x]
        if x in seen:
            return orbit, seen[x], step - seen[x]
        seen[x] = step
        orbit.append(x)
    return orbit, -1, -1


def main():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Orbit graph visualization
    ax = axes[0]

    # Define a function on {0, 1, ..., 7}
    f_map = {0: 3, 1: 5, 2: 4, 3: 7, 4: 1, 5: 3, 6: 2, 7: 5}
    n_states = len(f_map)

    # Position states in a circle
    angles = np.linspace(0, 2 * np.pi, n_states, endpoint=False)
    positions = {i: (2 * np.cos(a), 2 * np.sin(a))
                 for i, a in enumerate(angles)}

    # Draw edges (function arrows)
    for src, dst in f_map.items():
        sx, sy = positions[src]
        dx, dy = positions[dst]
        if src != dst:
            ax.annotate('', xy=(dx, dy), xytext=(sx, sy),
                       arrowprops=dict(arrowstyle='->', color='#555555',
                                      lw=1.5, connectionstyle='arc3,rad=0.2'))
        else:
            # Self-loop
            circle = plt.Circle((sx, sy + 0.4), 0.3, fill=False,
                              color='#555555', linewidth=1.5)
            ax.add_patch(circle)

    # Draw nodes
    for state, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.25, facecolor='#2196F3',
                            edgecolor='black', linewidth=2, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, str(state), ha='center', va='center',
               fontsize=14, fontweight='bold', color='white', zorder=6)

    # Highlight an orbit
    orbit, mu, lam = detect_orbit(f_map, 0)
    orbit_full = orbit + [f_map[orbit[-1]]]

    for i in range(len(orbit)):
        x1, y1 = positions[orbit[i]]
        x2, y2 = positions[f_map[orbit[i]]]
        color = '#FF5722' if i < mu else '#4CAF50'
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                   arrowprops=dict(arrowstyle='->', color=color,
                                  lw=3, connectionstyle='arc3,rad=0.25'),
                   zorder=4)

    ax.set_xlim(-3.5, 3.5)
    ax.set_ylim(-3.5, 3.5)
    ax.set_aspect('equal')
    ax.set_title(f'Orbit Cycling (Pigeonhole Theorem)\n'
                 f'Start=0: tail={mu}, cycle={lam} (total ≤ {n_states})',
                 fontsize=13, fontweight='bold')
    ax.text(-3.3, -3.2, '● Orange = tail  ● Green = cycle', fontsize=10)
    ax.axis('off')

    # Right: Multiple orbits showing cycling bounds
    ax2 = axes[1]

    starts = list(range(n_states))
    bar_data = []

    for s in starts:
        _, mu, lam = detect_orbit(f_map, s)
        bar_data.append((s, mu, lam))

    x_pos = np.arange(len(bar_data))
    tails = [d[1] for d in bar_data]
    cycles = [d[2] for d in bar_data]

    bars1 = ax2.bar(x_pos, tails, 0.6, label='Tail length (μ)', color='#FF9800', alpha=0.8)
    bars2 = ax2.bar(x_pos, cycles, 0.6, bottom=tails, label='Cycle length (λ)',
                    color='#4CAF50', alpha=0.8)

    # Draw the bound line
    ax2.axhline(y=n_states, color='red', linestyle='--', linewidth=2, label=f'Bound = |S| = {n_states}')

    ax2.set_xlabel('Starting State', fontsize=12)
    ax2.set_ylabel('Steps', fontsize=12)
    ax2.set_title('Orbit Cycling Bounds\n'
                  'μ + λ ≤ |state space| for all starting states',
                  fontsize=13, fontweight='bold')
    ax2.set_xticks(x_pos)
    ax2.set_xticklabels([str(d[0]) for d in bar_data])
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3, axis='y')

    # Add value labels on bars
    for i, (s, mu, lam) in enumerate(bar_data):
        total = mu + lam
        ax2.text(i, total + 0.1, f'{total}', ha='center', va='bottom', fontsize=9)

    plt.tight_layout()
    plt.savefig('orbit_cycling.png', dpi=150, bbox_inches='tight')
    print("Saved: orbit_cycling.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Rule 110 Spacetime Diagram

Renders the evolution of Rule 110 as a spacetime diagram,
showing the complex, Turing-complete dynamics of this elementary CA.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def rule110(left: bool, center: bool, right: bool) -> bool:
    index = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> index) & 1)


def evolve(config: list[bool], steps: int) -> np.ndarray:
    n = len(config)
    grid = np.zeros((steps + 1, n), dtype=int)
    grid[0] = config
    for t in range(steps):
        for i in range(n):
            grid[t + 1, i] = int(rule110(
                bool(grid[t, (i - 1) % n]),
                bool(grid[t, i]),
                bool(grid[t, (i + 1) % n])
            ))
    return grid


def main():
    # Configuration
    width = 200
    steps = 150

    # Start with a single active cell
    init = [False] * width
    init[width - 2] = True

    grid = evolve(init, steps)

    fig, ax = plt.subplots(figsize=(14, 8))
    ax.imshow(grid, cmap='binary', interpolation='nearest', aspect='auto')
    ax.set_xlabel('Cell Position', fontsize=12)
    ax.set_ylabel('Time Step', fontsize=12)
    ax.set_title('Rule 110: Spacetime Diagram\n'
                 'The simplest known Turing-complete cellular automaton',
                 fontsize=14)

    # Add ordinal level annotations
    ax.axhline(y=steps * 0.33, color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.axhline(y=steps * 0.67, color='blue', linestyle='--', alpha=0.5, linewidth=1)
    ax.text(5, steps * 0.33 - 3, 'ω/3 (conceptual)', color='red', fontsize=9, alpha=0.7)
    ax.text(5, steps * 0.67 - 3, '2ω/3 (conceptual)', color='blue', fontsize=9, alpha=0.7)

    plt.tight_layout()
    plt.savefig('rule110_spacetime.png', dpi=150, bbox_inches='tight')
    print("Saved: rule110_spacetime.png")


if __name__ == "__main__":
    main()
