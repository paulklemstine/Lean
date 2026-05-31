#!/usr/bin/env python3
"""
Transfinite Cellular Automata: Demonstration Script

Demonstrates the key results:
1. OR rule spreading from a single cell
2. NOT rule oscillation and collapse
3. Depth estimation for various rules
4. Convergence spectrum computation
"""

from algorithms import (
    or_rule, not_rule, xor_rule, and_rule, majority_rule, spreading_xor_rule,
    ca_step, ca_iter, get_cell, detect_stability, estimate_depth,
    compute_convergence_spectrum, is_fixed_point,
    Config, Rule,
)
from typing import Dict, List, Tuple
import random


def print_config(cfg: Config, window: Tuple[int, int], label: str = "") -> None:
    """Print a configuration as a string of 0s and 1s."""
    lo, hi = window
    cells = "".join("█" if get_cell(cfg, i) else "·" for i in range(lo, hi + 1))
    if label:
        print(f"  {label}: {cells}")
    else:
        print(f"  {cells}")


def demo_or_rule_spreading() -> None:
    """Demonstrate the OR rule spreading theorem."""
    print("=" * 70)
    print("DEMO 1: OR Rule Spreading from Single Cell")
    print("=" * 70)
    print()
    print("Starting from a single active cell at position 0,")
    print("the OR rule spreads activation by one cell per step.")
    print()

    cfg: Config = {0: True}
    window = (-10, 10)

    for step in range(11):
        label = f"t={step:2d}"
        print_config(cfg, window, label)
        if step < 10:
            cfg = ca_step(or_rule, cfg, window)

    print()
    print("Observation: After n steps, cells in [-n, n] are active.")
    print("The omega-limit is the all-true configuration (a fixed point).")
    print(f"Depth = 1 (confirmed: omega-limit is fixed point: "
          f"{is_fixed_point(or_rule, {i: True for i in range(-10, 11)}, window)})")
    print()


def demo_not_rule_oscillation() -> None:
    """Demonstrate NOT rule oscillation and collapse."""
    print("=" * 70)
    print("DEMO 2: NOT Rule Oscillation and Collapse")
    print("=" * 70)
    print()
    print("The NOT rule flips every cell. Starting from any configuration,")
    print("every cell oscillates between true and false.")
    print()

    cfg: Config = {0: True, 1: True, -1: True}
    window = (-5, 5)

    for step in range(8):
        label = f"t={step:2d}"
        print_config(cfg, window, label)
        cfg = ca_step(not_rule, cfg, window)

    print()
    print("Every cell oscillates → omega-limit = all-false (oscillation collapse)")
    print("All-false is NOT a fixed point of NOT rule → depth = ∞")
    print()

    # Verify infinite depth
    depth, levels = estimate_depth(not_rule, {0: True}, window, max_depth=5, max_steps=100)
    print(f"Estimated depth: {'> 5 (infinite)' if depth is None else depth}")
    print()


def demo_depth_estimation() -> None:
    """Estimate transfinite depth for various rules."""
    print("=" * 70)
    print("DEMO 3: Transfinite Depth Estimation")
    print("=" * 70)
    print()

    window = (-20, 20)
    single_cell: Config = {0: True}
    three_cells: Config = {-1: True, 0: True, 1: True}

    rules: List[Tuple[str, Rule, Config]] = [
        ("OR rule, single cell", or_rule, single_cell),
        ("OR rule, three cells", or_rule, three_cells),
        ("AND rule, single cell", and_rule, single_cell),
        ("AND rule, three cells", and_rule, three_cells),
        ("NOT rule, single cell", not_rule, single_cell),
        ("XOR rule, single cell", xor_rule, single_cell),
        ("Majority rule, single cell", majority_rule, single_cell),
        ("Spreading-XOR rule, single cell", spreading_xor_rule, single_cell),
    ]

    for name, rule, cfg in rules:
        depth, levels = estimate_depth(rule, cfg, window, max_depth=5, max_steps=200)
        depth_str = str(depth) if depth is not None else "> 5 (possibly ∞)"
        print(f"  {name:40s} → depth = {depth_str}")

    print()


def demo_convergence_spectrum() -> None:
    """Compute convergence spectrum for random initial configurations."""
    print("=" * 70)
    print("DEMO 4: Convergence Spectrum")
    print("=" * 70)
    print()
    print("Classifying 100 random configurations by transfinite depth...")
    print()

    window = (-15, 15)
    random.seed(42)

    # Generate random sparse configurations
    configs: List[Config] = []
    for _ in range(100):
        density = random.uniform(0.1, 0.9)
        cfg: Config = {}
        for i in range(window[0], window[1] + 1):
            if random.random() < density:
                cfg[i] = True
        configs.append(cfg)

    rules_to_test: List[Tuple[str, Rule]] = [
        ("OR rule", or_rule),
        ("AND rule", and_rule),
        ("Majority rule", majority_rule),
    ]

    for name, rule in rules_to_test:
        spectrum = compute_convergence_spectrum(rule, configs, window, max_depth=3)
        print(f"  {name}:")
        for depth in sorted(spectrum.keys(), key=lambda x: x if x is not None else 999):
            depth_label = str(depth) if depth is not None else "> 3"
            print(f"    depth {depth_label}: {spectrum[depth]} configurations")
        print()


def demo_spreading_verification() -> None:
    """Verify the spreading theorem computationally."""
    print("=" * 70)
    print("DEMO 5: Spreading Theorem Verification")
    print("=" * 70)
    print()
    print("Verifying: caIter(orRule, singleCell, n)(i) = true ↔ |i| ≤ n")
    print()

    cfg: Config = {0: True}
    window = (-30, 30)

    all_correct = True
    for n in range(21):
        iter_cfg = ca_iter(or_rule, cfg, n, window)
        for i in range(window[0], window[1] + 1):
            predicted = abs(i) <= n
            actual = get_cell(iter_cfg, i)
            if predicted != actual:
                print(f"  MISMATCH at n={n}, i={i}: predicted={predicted}, actual={actual}")
                all_correct = False

    if all_correct:
        print("  ✓ Spreading theorem verified for n = 0..20, i = -30..30")
    print()


def demo_oscillation_detection() -> None:
    """Detect oscillation patterns in various rules."""
    print("=" * 70)
    print("DEMO 6: Oscillation Detection")
    print("=" * 70)
    print()

    window = (-10, 10)
    cfg: Config = {0: True}

    rules_to_test: List[Tuple[str, Rule]] = [
        ("NOT rule", not_rule),
        ("XOR rule", xor_rule),
        ("OR rule", or_rule),
    ]

    for name, rule in rules_to_test:
        print(f"  {name} from single cell:")
        _, is_stable = detect_stability(rule, cfg, window, max_steps=200, stability_window=30)
        oscillating = sum(1 for i in range(window[0], window[1] + 1) if not is_stable.get(i, True))
        stable = sum(1 for i in range(window[0], window[1] + 1) if is_stable.get(i, True))
        print(f"    Stable cells: {stable}, Oscillating cells: {oscillating}")
    print()


if __name__ == "__main__":
    demo_or_rule_spreading()
    demo_not_rule_oscillation()
    demo_depth_estimation()
    demo_convergence_spectrum()
    demo_spreading_verification()
    demo_oscillation_detection()
    print("All demos completed.")


#!/usr/bin/env python3
"""
Visualization: Space-Time Diagrams for Transfinite Cellular Automata

Produces space-time diagrams showing the evolution of various CA rules,
highlighting the spreading, oscillation, and convergence phenomena.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
from typing import Callable, Dict, Tuple

Config = Dict[int, bool]
Rule = Callable[[bool, bool, bool], bool]


def get_cell(cfg: Config, i: int) -> bool:
    return cfg.get(i, False)


def ca_step(rule: Rule, cfg: Config, window: Tuple[int, int]) -> Config:
    lo, hi = window
    new_cfg: Config = {}
    for i in range(lo, hi + 1):
        val = rule(get_cell(cfg, i - 1), get_cell(cfg, i), get_cell(cfg, i + 1))
        if val:
            new_cfg[i] = True
    return new_cfg


def or_rule(l: bool, c: bool, r: bool) -> bool:
    return l or c or r

def not_rule(_l: bool, c: bool, _r: bool) -> bool:
    return not c

def xor_rule(l: bool, c: bool, r: bool) -> bool:
    return l ^ c ^ r

def majority_rule(l: bool, c: bool, r: bool) -> bool:
    return (int(l) + int(c) + int(r)) >= 2


def simulate_spacetime(rule: Rule, cfg: Config, window: Tuple[int, int],
                       steps: int) -> np.ndarray:
    lo, hi = window
    width = hi - lo + 1
    grid = np.zeros((steps + 1, width), dtype=int)
    current = cfg
    for t in range(steps + 1):
        for i in range(lo, hi + 1):
            grid[t, i - lo] = int(get_cell(current, i))
        if t < steps:
            current = ca_step(rule, current, window)
    return grid


def main():
    window = (-25, 25)
    steps = 50
    single_cell: Config = {0: True}

    rules = [
        ("OR Rule (Spreading)", or_rule),
        ("NOT Rule (Oscillation)", not_rule),
        ("XOR Rule (Complex Patterns)", xor_rule),
        ("Majority Rule", majority_rule),
    ]

    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle("Space-Time Diagrams: Transfinite CA Rule Comparison",
                 fontsize=16, fontweight='bold')

    cmap = mcolors.ListedColormap(['#1a1a2e', '#e94560'])

    for idx, (name, rule) in enumerate(rules):
        ax = axes[idx // 2][idx % 2]
        grid = simulate_spacetime(rule, single_cell, window, steps)
        ax.imshow(grid, cmap=cmap, aspect='auto', interpolation='nearest',
                  extent=[window[0] - 0.5, window[1] + 0.5, steps + 0.5, -0.5])
        ax.set_title(name, fontsize=13, fontweight='bold')
        ax.set_xlabel("Cell Position (i)", fontsize=11)
        ax.set_ylabel("Time Step (t)", fontsize=11)

    plt.tight_layout()
    plt.savefig("spacetime_diagrams.png", dpi=150, bbox_inches='tight')
    print("Saved spacetime_diagrams.png")


if __name__ == "__main__":
    main()
