#!/usr/bin/env python3
"""
Transfinite Cellular Automata Demo

Demonstrates key results from the formal theory:
1. OR rule spreading from a single cell
2. Omega-limit computation
3. Fixed point detection
4. Rule depth classification
"""

from algorithms import (
    or_rule, xor_rule, id_rule, wolfram_rule,
    ca_step, ca_iter, compute_omega_limit,
    transfinite_simulate, classify_rule_depth,
    CAConfig
)


def demo_or_rule_spreading():
    """Demonstrate Theorem: orRule_single_cell_spread.

    After n steps of the OR rule from a single cell,
    position i is active iff |i| <= n.
    """
    print("=" * 60)
    print("Demo 1: OR Rule Spreading (orRule_single_cell_spread)")
    print("=" * 60)

    cfg: CAConfig = {0: True}
    bounds = (-1, 1)

    for n in range(8):
        result = ca_iter(or_rule, cfg, n, bounds)
        active = sorted([i for i in range(-10, 11) if result.get(i, False)])
        expected = list(range(-n, n + 1))
        match = active == expected
        print(f"  Step {n}: active = [{min(active) if active else ''}..{max(active) if active else ''}]"
              f"  expected = [-{n}..{n}]  ✓" if match else f"  ✗")

    print()


def demo_omega_limit():
    """Demonstrate Theorem: orRule_single_cell_omegaLimit.

    The omega-limit of OR rule from singleCell is the all-true configuration.
    """
    print("=" * 60)
    print("Demo 2: Omega-Limit (orRule_single_cell_omegaLimit)")
    print("=" * 60)

    cfg: CAConfig = {0: True}
    bounds = (-20, 20)
    omega = compute_omega_limit(or_rule, cfg, 200, bounds)

    all_true = all(omega.get(i, False) for i in range(-20, 21))
    print(f"  Omega-limit is all-true in [-20, 20]: {all_true}")

    # Verify it's a fixed point
    stepped = ca_step(or_rule, omega, bounds)
    is_fixed = all(omega.get(i, False) == stepped.get(i, False)
                   for i in range(-20, 21))
    print(f"  Omega-limit is a fixed point: {is_fixed}")
    print(f"  Transfinite depth: 1 (exactly one limit step needed)")
    print()


def demo_identity_rule():
    """Demonstrate Theorem: idRule_levels_constant.

    The identity rule produces constant transfinite levels.
    """
    print("=" * 60)
    print("Demo 3: Identity Rule (idRule_levels_constant)")
    print("=" * 60)

    cfg: CAConfig = {0: True, 3: True, -2: True}
    bounds = (-5, 5)

    levels = transfinite_simulate(id_rule, cfg, 3, 50, bounds)
    for i, level in enumerate(levels):
        matches_initial = all(
            cfg.get(pos, False) == level.get(pos, False)
            for pos in range(-5, 6))
        print(f"  Level {i} matches initial: {matches_initial}")

    print()


def demo_xor_oscillation():
    """Demonstrate Theorem: oscillates_not_stable.

    XOR rule produces oscillating cells that are detected at the limit.
    """
    print("=" * 60)
    print("Demo 4: XOR Oscillation (oscillates_not_stable)")
    print("=" * 60)

    cfg: CAConfig = {0: True}
    bounds = (-1, 1)

    # Track cell 0 over time
    current = cfg.copy()
    history = []
    for step in range(20):
        val = current.get(0, False)
        history.append(val)
        current = ca_step(xor_rule, current, (-step - 1, step + 1))

    print(f"  Cell 0 history (XOR, 20 steps): {''.join('1' if v else '0' for v in history)}")

    # Compute omega-limit
    omega = compute_omega_limit(xor_rule, cfg, 200, (-50, 50))
    print(f"  Omega-limit at cell 0: {omega.get(0, False)}")
    print(f"  (Oscillating cells default to false at the limit)")
    print()


def demo_rule_classification():
    """Demonstrate depth classification for various Wolfram rules."""
    print("=" * 60)
    print("Demo 5: Rule Depth Classification")
    print("=" * 60)

    interesting_rules = [0, 4, 32, 51, 90, 110, 150, 170, 204, 232, 250, 254]

    for rule_num in interesting_rules:
        depth, classification = classify_rule_depth(rule_num, max_steps=300, check_range=30)
        depth_str = str(depth) if depth >= 0 else "∞"
        print(f"  Rule {rule_num:3d}: depth = {depth_str:>3s}  ({classification})")

    print()


def demo_transfinite_tower():
    """Demonstrate transfinite level composition.

    Show that transfiniteLevel(rule, cfg, m+n) equals
    transfiniteLevel(rule, transfiniteLevel(rule, cfg, m), n).
    """
    print("=" * 60)
    print("Demo 6: Transfinite Level Composition")
    print("=" * 60)

    cfg: CAConfig = {0: True}
    bounds = (-10, 10)
    rule = or_rule

    # Compute levels directly
    levels_direct = transfinite_simulate(rule, cfg, 3, 100, bounds)

    # Compute via composition: first 1 level, then 2 more
    level_1 = transfinite_simulate(rule, cfg, 1, 100, bounds)
    levels_from_1 = transfinite_simulate(rule, level_1[1], 2, 100, bounds)

    # Compare level 3 from direct vs composed
    check_range = range(-10, 11)
    match_2 = all(levels_direct[2].get(i, False) == levels_from_1[1].get(i, False)
                  for i in check_range)
    match_3 = all(levels_direct[3].get(i, False) == levels_from_1[2].get(i, False)
                  for i in check_range)

    print(f"  Level 2 (direct) = Level 1+1 (composed): {match_2}")
    print(f"  Level 3 (direct) = Level 1+2 (composed): {match_3}")
    print()


def demo_monotonicity():
    """Demonstrate monotone iteration: OR rule iterations are expanding."""
    print("=" * 60)
    print("Demo 7: Monotone Expanding Dynamics (orRule_iter_monotone)")
    print("=" * 60)

    cfg: CAConfig = {0: True, 5: True}
    bounds = (-1, 6)

    prev_active = set()
    all_expanding = True
    for n in range(10):
        result = ca_iter(or_rule, cfg, n, bounds)
        active = {i for i in range(-15, 20) if result.get(i, False)}
        if not prev_active <= active:
            all_expanding = False
        prev_active = active
        print(f"  Step {n}: {len(active):2d} active cells, "
              f"range [{min(active)}..{max(active)}]")

    print(f"\n  All iterations expanding (monotone): {all_expanding}")
    print()


if __name__ == "__main__":
    print("\n  TRANSFINITE CELLULAR AUTOMATA — Demonstration\n")
    print("  Each demo corresponds to a formally verified theorem.\n")

    demo_or_rule_spreading()
    demo_omega_limit()
    demo_identity_rule()
    demo_xor_oscillation()
    demo_rule_classification()
    demo_transfinite_tower()
    demo_monotonicity()

    print("=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Wolfram Rule Depth Classification

Classifies all 256 elementary CA rules by their transfinite computation
depth (how many omega-limit steps needed to reach a fixed point).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def wolfram_rule(n: int):
    def rule(left: bool, center: bool, right: bool) -> bool:
        idx = (4 if left else 0) + (2 if center else 0) + (1 if right else 0)
        return bool((n >> idx) & 1)
    return rule


def ca_step(rule, cfg: dict, bounds: tuple) -> dict:
    lo, hi = bounds
    new_cfg = {}
    for i in range(lo - 1, hi + 2):
        left = cfg.get(i - 1, False)
        center = cfg.get(i, False)
        right = cfg.get(i + 1, False)
        new_cfg[i] = rule(left, center, right)
    return new_cfg


def compute_omega_limit(rule, cfg: dict, max_steps: int, bounds: tuple) -> dict:
    lo, hi = bounds
    configs = [cfg.copy()]
    current = cfg.copy()
    for step in range(max_steps):
        current = ca_step(rule, current, (lo - step, hi + step))
        configs.append(current.copy())

    omega_cfg = {}
    half = max_steps // 2
    for pos in range(lo - max_steps, hi + max_steps + 1):
        values = [c.get(pos, False) for c in configs[half:]]
        if len(set(values)) == 1:
            omega_cfg[pos] = values[0]
        else:
            omega_cfg[pos] = False
    return omega_cfg


def classify_rule(rule_number: int, max_steps: int = 200, check_range: int = 25):
    rule = wolfram_rule(rule_number)
    cfg = {0: True}
    bounds = (-1, 1)

    stepped = ca_step(rule, cfg, bounds)
    is_fixed = all(cfg.get(i, False) == stepped.get(i, False)
                   for i in range(-check_range, check_range + 1))
    if is_fixed:
        return 0

    omega = compute_omega_limit(rule, cfg, max_steps, (-check_range, check_range))
    omega_stepped = ca_step(rule, omega, (-check_range - 1, check_range + 1))
    omega_fixed = all(omega.get(i, False) == omega_stepped.get(i, False)
                      for i in range(-check_range, check_range + 1))
    if omega_fixed:
        return 1

    return 2  # depth > 1


def main():
    depths = []
    for rule_num in range(256):
        d = classify_rule(rule_num)
        depths.append(d)

    # Count
    count_0 = depths.count(0)
    count_1 = depths.count(1)
    count_2 = depths.count(2)
    print(f"Depth 0 (immediate fixed point): {count_0} rules")
    print(f"Depth 1 (one omega-limit): {count_1} rules")
    print(f"Depth >1 (oscillating): {count_2} rules")

    # Plot as 16x16 grid
    fig, ax = plt.subplots(figsize=(10, 10))
    grid = [[0]*16 for _ in range(16)]
    for i in range(256):
        grid[i // 16][i % 16] = depths[i]

    cmap = plt.cm.colors.ListedColormap(['#2ecc71', '#3498db', '#e74c3c'])
    im = ax.imshow(grid, cmap=cmap, vmin=0, vmax=2, interpolation='nearest')
    ax.set_xlabel('Rule Number (mod 16)', fontsize=14)
    ax.set_ylabel('Rule Number (÷ 16)', fontsize=14)
    ax.set_title('Transfinite Depth of 256 Elementary CA Rules\n'
                 'Green=0, Blue=1, Red=>1', fontsize=16)

    # Add rule numbers
    for i in range(16):
        for j in range(16):
            rule_num = i * 16 + j
            ax.text(j, i, str(rule_num), ha='center', va='center',
                   fontsize=6, color='white' if depths[rule_num] > 0 else 'black')

    plt.tight_layout()
    plt.savefig('depth_classification.png', dpi=150)
    print("Saved depth_classification.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: OR Rule Spreading from a Single Cell

Generates a space-time diagram showing how the OR rule spreads
from a single active cell, illustrating the spreading theorem:
caIter(orRule, singleCell, n)(i) = true iff |i| <= n.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def or_rule(left: bool, center: bool, right: bool) -> bool:
    return left or center or right


def ca_step(rule, cfg: dict, bounds: tuple) -> dict:
    lo, hi = bounds
    new_cfg = {}
    for i in range(lo - 1, hi + 2):
        left = cfg.get(i - 1, False)
        center = cfg.get(i, False)
        right = cfg.get(i + 1, False)
        new_cfg[i] = rule(left, center, right)
    return new_cfg


def main():
    num_steps = 30
    spatial_range = 35

    # Simulate
    cfg = {0: True}
    bounds = (-1, 1)
    grid = []

    for step in range(num_steps):
        row = [1 if cfg.get(i, False) else 0
               for i in range(-spatial_range, spatial_range + 1)]
        grid.append(row)
        cfg = ca_step(or_rule, cfg, (-spatial_range, spatial_range))

    # Plot
    fig, ax = plt.subplots(figsize=(12, 8))
    cmap = mcolors.ListedColormap(['#1a1a2e', '#e94560'])
    ax.imshow(grid, cmap=cmap, aspect='auto', interpolation='nearest',
              extent=[-spatial_range - 0.5, spatial_range + 0.5,
                      num_steps - 0.5, -0.5])
    ax.set_xlabel('Position (i)', fontsize=14)
    ax.set_ylabel('Time Step (n)', fontsize=14)
    ax.set_title('OR Rule Spreading: Active iff |i| ≤ n\n'
                 '(Theorem: orRule_single_cell_spread)', fontsize=16)

    # Add the boundary lines |i| = n
    steps = list(range(num_steps))
    ax.plot(steps, steps, 'w--', linewidth=1.5, alpha=0.7, label='|i| = n')
    ax.plot([-s for s in steps], steps, 'w--', linewidth=1.5, alpha=0.7)

    ax.legend(loc='upper right', fontsize=12)
    plt.tight_layout()
    plt.savefig('spreading_theorem.png', dpi=150)
    print("Saved spreading_theorem.png")


if __name__ == "__main__":
    main()
