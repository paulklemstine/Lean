"""
Ordinal Cellular Automata: Transfinite Computation Demo
========================================================

Demonstrates the spreading OCA and its convergence at omega.
Shows how finite-step evolution produces threshold configurations,
and the limit at omega produces the all-true configuration.
"""

def spread_rule(config: list[bool], size: int) -> list[bool]:
    """Apply the spreading rule: cell n becomes true if it or its left neighbor is true."""
    result = [False] * size
    for n in range(size):
        result[n] = config[n] or (config[n - 1] if n > 0 else False)
    return result


def seed_config(size: int) -> list[bool]:
    """The seed configuration: only cell 0 is true."""
    config = [False] * size
    config[0] = True
    return config


def threshold_config(n: int, size: int) -> list[bool]:
    """The threshold configuration: cells 0..n-1 are true."""
    return [k < n for k in range(size)]


def evolve_finite(config: list[bool], steps: int) -> list[bool]:
    """Evolve for a finite number of steps."""
    current = config[:]
    for _ in range(steps):
        current = spread_rule(current, len(current))
    return current


def display_config(config: list[bool], label: str = "") -> str:
    """Display a configuration as a string of 0s and 1s."""
    bits = "".join("█" if c else "░" for c in config)
    return f"{label:>20s}: {bits}"


def main():
    SIZE = 40

    print("=" * 70)
    print("ORDINAL CELLULAR AUTOMATA: TRANSFINITE COMPUTATION")
    print("=" * 70)
    print()
    print("The Spreading Rule: cell n becomes TRUE if it or its")
    print("left neighbor (n-1) is TRUE. Starting from seed = [1,0,0,...]")
    print()

    # Show finite evolution
    print("--- Finite Evolution (steps 0 through 15) ---")
    print()
    config = seed_config(SIZE)
    for step in range(16):
        print(display_config(config, f"Step {step}"))
        config = spread_rule(config, SIZE)

    print()
    print("--- Key Observations ---")
    print()
    print("After n steps: cells 0..n are TRUE, cells n+1..∞ are FALSE")
    print("This is the 'threshold' configuration: threshold(n+1)")
    print()

    # Verify threshold property
    print("--- Verification: step n produces threshold(n+1) ---")
    for n in range(10):
        evolved = evolve_finite(seed_config(SIZE), n)
        thresh = threshold_config(n + 1, SIZE)
        assert evolved == thresh, f"Mismatch at step {n}"
        print(f"  Step {n:2d} = threshold({n+1:2d})  ✓")

    print()
    print("--- The Limit at ω ---")
    print()
    print("At NO finite step do we reach all-TRUE.")
    print("But at ω (the first limit ordinal), we take the")
    print("pointwise supremum of ALL finite steps:")
    print()
    print("  sup{{threshold(n) : n ∈ ℕ}} = all-TRUE")
    print()
    print("This is because for any cell k, threshold(k+1) has")
    print("cell k = TRUE, so the sup has every cell TRUE.")
    print()

    all_true = [True] * SIZE
    print(display_config(all_true, "Step ω (limit)"))
    print()

    # Show the hierarchy
    print("--- Transfinite Computation Hierarchy ---")
    print()
    print("The hierarchy is STRICTLY increasing:")
    for n in range(8):
        evolved = evolve_finite(seed_config(SIZE), n)
        true_count = sum(evolved)
        print(f"  Level {n}: {true_count} true cells")
    print(f"  Level ω: {SIZE} true cells (ALL)")
    print()
    print("Each finite level is strictly weaker than the next.")
    print("The jump to ω is QUALITATIVELY different: it requires")
    print("infinite computation (taking a limit).")
    print()

    # Stabilization
    print("--- Stabilization ---")
    print()
    print("The spreading OCA stabilizes at ω:")
    print("  • Before ω: NOT stable (spread changes threshold(n) → threshold(n+1))")
    print("  • At ω: STABLE (spread(all-TRUE) = all-TRUE)")
    print("  • After ω: Still stable (fixed point persists)")
    print()

    config = all_true[:]
    after_spread = spread_rule(config, SIZE)
    assert after_spread == all_true
    print("  spread(all-TRUE) = all-TRUE  ✓  (fixed point)")
    print()

    # The Limit Layer
    print("--- The Limit Layer ---")
    print()
    print("The all-TRUE configuration is in the LIMIT LAYER:")
    print("it appears at ω but at NO finite step.")
    print("This proves that transfinite evolution is STRICTLY")
    print("more powerful than finite evolution.")
    print()
    print("In computational terms: the spreading OCA at ω")
    print("'decides' a property (all cells eventually become true)")
    print("that no finite computation can determine.")

    # Cascade OCA
    print()
    print("--- Cascade OCA Family ---")
    print()
    print("The cascade rule of depth d requires d consecutive")
    print("true cells to propagate. Higher depth = slower spread.")
    print()

    for depth in [1, 2, 3]:
        config = seed_config(20)
        print(f"  Cascade depth {depth}:")
        for step in range(8):
            if step % 2 == 0:
                label = f"    Step {step}"
                print(display_config(config, label))
            # Apply cascade rule
            new_config = [False] * 20
            for k in range(20):
                if config[k]:
                    new_config[k] = True
                elif k >= depth and all(config[k - 1 - i] for i in range(depth)):
                    new_config[k] = True
            config = new_config
        print()


if __name__ == "__main__":
    main()


"""
Visualization: Transfinite Computation Hierarchy
=================================================

Shows the strict hierarchy of computation levels and the
qualitative jump at the first limit ordinal omega.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def spread_rule(config: list[bool]) -> list[bool]:
    size = len(config)
    result = [False] * size
    for n in range(size):
        result[n] = config[n] or (config[n - 1] if n > 0 else False)
    return result


def cascade_rule(depth: int, config: list[bool]) -> list[bool]:
    size = len(config)
    result = [False] * size
    for k in range(size):
        if config[k]:
            result[k] = True
        elif k >= depth and all(config[k - 1 - i] for i in range(depth)):
            result[k] = True
    return result


def seed_config(size: int) -> list[bool]:
    config = [False] * size
    config[0] = True
    return config


def evolve(rule_fn, config: list[bool], steps: int) -> list[bool]:
    current = config[:]
    for _ in range(steps):
        current = rule_fn(current)
    return current


def main():
    SIZE = 100
    MAX_STEPS = 50

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Panel 1: Growth curves for different cascade depths
    ax = axes[0, 0]
    for depth in [1, 2, 3, 5]:
        rule = lambda c, d=depth: cascade_rule(d, c)
        counts = []
        config = seed_config(SIZE)
        for step in range(MAX_STEPS):
            counts.append(sum(config))
            config = rule(config)
        ax.plot(range(MAX_STEPS), counts, label=f'Depth {depth}', linewidth=2)

    ax.axhline(y=SIZE, color='gold', linewidth=2, linestyle='--', label='Limit at ω')
    ax.set_xlabel('Time Step', fontsize=11)
    ax.set_ylabel('TRUE Cells', fontsize=11)
    ax.set_title('Cascade OCA: Growth Rate vs Depth', fontsize=13, fontweight='bold')
    ax.legend()
    ax.grid(alpha=0.3)

    # Panel 2: Stabilization ordinal visualization
    ax = axes[0, 1]
    ordinals = list(range(20)) + [25]  # last represents omega
    values = list(range(1, 21)) + [SIZE]

    ax.fill_between(range(20), values[:20], alpha=0.3, color='#e94560',
                    label='Finite levels')
    ax.plot(range(20), values[:20], 'o-', color='#e94560', markersize=4)

    # The omega jump
    ax.plot([19, 20], [20, SIZE], 'o--', color='gold', markersize=8,
            linewidth=2, label='Jump to ω')
    ax.annotate('ω', xy=(20, SIZE), fontsize=14, fontweight='bold',
                color='gold', ha='center', va='bottom')

    ax.set_xlabel('Ordinal Level', fontsize=11)
    ax.set_ylabel('TRUE Cells (Computation Power)', fontsize=11)
    ax.set_title('Strict Hierarchy with ω-Jump', fontsize=13, fontweight='bold')
    ax.legend()
    ax.grid(alpha=0.3)

    # Panel 3: Limit layer visualization
    ax = axes[1, 0]
    steps_to_show = [0, 3, 6, 9, 12, 15]
    for i, step in enumerate(steps_to_show):
        config = evolve(spread_rule, seed_config(40), step)
        y_vals = [1 if c else 0 for c in config]
        ax.bar(np.arange(40) + i * 0.12, y_vals, width=0.1,
               alpha=0.7, label=f'Step {step}')

    # Omega
    ax.bar(np.arange(40) + len(steps_to_show) * 0.12,
           [1] * 40, width=0.1, alpha=0.9, color='gold', label='Step ω')

    ax.set_xlabel('Cell Position', fontsize=11)
    ax.set_ylabel('Cell State', fontsize=11)
    ax.set_title('Evolution Snapshots → Limit Layer', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8, ncol=4)

    # Panel 4: Fixed point analysis
    ax = axes[1, 1]
    SIZE2 = 30
    # Show that spread(allTrue) = allTrue
    all_true = [True] * SIZE2
    after_spread = spread_rule(all_true)

    # Show residuals
    x = range(SIZE2)
    residuals = [int(a) - int(b) for a, b in zip(after_spread, all_true)]
    ax.bar(x, [1] * SIZE2, color='gold', alpha=0.5, label='All-TRUE config')
    ax.bar(x, [0] * SIZE2, color='red', alpha=0.5, label='After spread (same)')

    ax.text(SIZE2 / 2, 0.5, 'spread(⊤) = ⊤\nFIXED POINT',
            ha='center', va='center', fontsize=14, fontweight='bold',
            bbox=dict(boxstyle='round', facecolor='gold', alpha=0.8))

    ax.set_xlabel('Cell Position', fontsize=11)
    ax.set_ylabel('Cell State', fontsize=11)
    ax.set_title('ω-Jump Idempotence', fontsize=13, fontweight='bold')
    ax.set_ylim(-0.1, 1.5)

    plt.tight_layout()
    plt.savefig('hierarchy_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hierarchy_analysis.png")


if __name__ == "__main__":
    main()


"""
Visualization: Ordinal Cellular Automata Evolution
===================================================

Creates a spacetime diagram showing how the spreading OCA evolves,
with the limit at omega clearly marked.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def spread_rule(config: list[bool]) -> list[bool]:
    size = len(config)
    result = [False] * size
    for n in range(size):
        result[n] = config[n] or (config[n - 1] if n > 0 else False)
    return result


def seed_config(size: int) -> list[bool]:
    config = [False] * size
    config[0] = True
    return config


def main():
    SIZE = 30
    STEPS = 25

    # Generate spacetime diagram
    configs = []
    config = seed_config(SIZE)
    for _ in range(STEPS):
        configs.append(config[:])
        config = spread_rule(config)

    # Add the omega limit (all true)
    omega_config = [True] * SIZE
    configs.append(omega_config)

    # Create the plot
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 8),
                                     gridspec_kw={'width_ratios': [2, 1]})

    # Left: Spacetime diagram
    data = np.array([[1 if c else 0 for c in row] for row in configs])

    # Use a custom colormap
    cmap = plt.cm.colors.ListedColormap(['#1a1a2e', '#e94560'])

    ax1.imshow(data, cmap=cmap, aspect='auto', interpolation='nearest')
    ax1.set_xlabel('Cell Position (k)', fontsize=12)
    ax1.set_ylabel('Time Step', fontsize=12)
    ax1.set_title('Spreading OCA: Spacetime Diagram', fontsize=14, fontweight='bold')

    # Mark the omega step
    ax1.axhline(y=STEPS - 0.5, color='gold', linewidth=2, linestyle='--')
    ax1.text(SIZE + 0.5, STEPS, 'ω (limit)', fontsize=11, color='gold',
             va='center', fontweight='bold')

    # Add step labels
    for i in range(0, STEPS, 5):
        ax1.text(-1.5, i, str(i), ha='right', va='center', fontsize=9)
    ax1.text(-1.5, STEPS, 'ω', ha='right', va='center', fontsize=11,
             fontweight='bold', color='gold')

    # Right: Hierarchy bar chart
    true_counts = [sum(c) for c in configs[:-1]]
    true_counts.append(SIZE)  # omega

    labels = [str(i) for i in range(STEPS)] + ['ω']
    colors = ['#e94560'] * STEPS + ['gold']

    # Only show every 5th bar for readability
    indices = list(range(0, STEPS, 3)) + [STEPS]
    bar_counts = [true_counts[i] for i in indices]
    bar_labels = [labels[i] for i in indices]
    bar_colors = ['#e94560'] * (len(indices) - 1) + ['gold']

    bars = ax2.barh(range(len(indices)), bar_counts, color=bar_colors, edgecolor='white')
    ax2.set_yticks(range(len(indices)))
    ax2.set_yticklabels(bar_labels)
    ax2.set_xlabel('Number of TRUE Cells', fontsize=12)
    ax2.set_ylabel('Time Step', fontsize=12)
    ax2.set_title('Transfinite Hierarchy', fontsize=14, fontweight='bold')
    ax2.invert_yaxis()

    # Add value labels
    for i, (bar, count) in enumerate(zip(bars, bar_counts)):
        ax2.text(count + 0.5, i, str(count), va='center', fontsize=9)

    # Legend
    finite_patch = mpatches.Patch(color='#e94560', label='Finite steps')
    omega_patch = mpatches.Patch(color='gold', label='Limit at ω')
    ax2.legend(handles=[finite_patch, omega_patch], loc='lower right')

    plt.tight_layout()
    plt.savefig('oca_spacetime.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: oca_spacetime.png")


if __name__ == "__main__":
    main()
