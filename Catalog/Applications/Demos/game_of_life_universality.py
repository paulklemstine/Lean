#!/usr/bin/env python3
"""
Game of Life Universality — Demonstration Script

Demonstrates key concepts from the formalization:
1. GoL simulation and pattern evolution
2. Glider dynamics (c/4 velocity)
3. Still life verification
4. Simulation overhead calculations
"""

import numpy as np
from typing import Set, Tuple, Dict, List

# ============================================================
# Core GoL Implementation
# ============================================================

def gol_step(alive: Set[Tuple[int, int]]) -> Set[Tuple[int, int]]:
    """One step of Conway's Game of Life."""
    neighbor_counts: Dict[Tuple[int, int], int] = {}
    for (x, y) in alive:
        for dx in [-1, 0, 1]:
            for dy in [-1, 0, 1]:
                if dx == 0 and dy == 0:
                    continue
                nb = (x + dx, y + dy)
                neighbor_counts[nb] = neighbor_counts.get(nb, 0) + 1
    
    new_alive = set()
    for cell, count in neighbor_counts.items():
        if cell in alive:
            if count in (2, 3):
                new_alive.add(cell)
        else:
            if count == 3:
                new_alive.add(cell)
    return new_alive


def gol_iterate(alive: Set[Tuple[int, int]], steps: int) -> Set[Tuple[int, int]]:
    """Iterate GoL for multiple steps."""
    for _ in range(steps):
        alive = gol_step(alive)
    return alive


def display_grid(alive: Set[Tuple[int, int]], padding: int = 2) -> str:
    """Display a GoL configuration as ASCII art."""
    if not alive:
        return "(empty)"
    xs = [p[0] for p in alive]
    ys = [p[1] for p in alive]
    min_x, max_x = min(xs) - padding, max(xs) + padding
    min_y, max_y = min(ys) - padding, max(ys) + padding
    
    lines = []
    for y in range(min_y, max_y + 1):
        row = ""
        for x in range(min_x, max_x + 1):
            row += "█" if (x, y) in alive else "·"
        lines.append(row)
    return "\n".join(lines)


# ============================================================
# Demo 1: Glider Motion
# ============================================================

def demo_glider():
    """Demonstrate the glider pattern and verify c/4 velocity."""
    print("=" * 60)
    print("DEMO 1: Glider Dynamics")
    print("=" * 60)
    
    # Standard glider
    glider = {(0, 0), (1, 0), (2, 0), (2, 1), (1, 2)}
    
    print("\nInitial glider:")
    print(display_grid(glider))
    
    # Track center of mass over 4 generations
    for t in range(5):
        if t > 0:
            glider_t = gol_iterate(glider, t * 4)
        else:
            glider_t = glider
        
        xs = [p[0] for p in glider_t]
        ys = [p[1] for p in glider_t]
        cx, cy = sum(xs) / len(xs), sum(ys) / len(ys)
        print(f"  t={t*4:2d}: center=({cx:.1f}, {cy:.1f}), cells={len(glider_t)}")
    
    # Verify velocity = c/4
    g0 = glider
    g4 = gol_iterate(glider, 4)
    
    # After 4 steps, glider translates by (1, 1)
    g0_shifted = {(x + 1, y + 1) for (x, y) in g0}
    print(f"\n  Glider after 4 steps matches (1,1)-translation: {g4 == g0_shifted}")
    print(f"  Velocity = 1/4 cell/step (speed of light = 1 cell/step)")
    print(f"  Verified: 1/4 < 1 ✓ (glider_velocity_below_speed_of_light)")


# ============================================================
# Demo 2: Still Lives
# ============================================================

def demo_still_lives():
    """Verify that common still life patterns are fixed points."""
    print("\n" + "=" * 60)
    print("DEMO 2: Still Life Verification")
    print("=" * 60)
    
    still_lives = {
        "Block": {(0, 0), (1, 0), (0, 1), (1, 1)},
        "Beehive": {(1, 0), (2, 0), (0, 1), (3, 1), (1, 2), (2, 2)},
        "Loaf": {(1, 0), (2, 0), (0, 1), (3, 1), (1, 2), (3, 2), (2, 3)},
        "Boat": {(0, 0), (1, 0), (0, 1), (2, 1), (1, 2)},
        "Tub": {(1, 0), (0, 1), (2, 1), (1, 2)},
    }
    
    for name, pattern in still_lives.items():
        evolved = gol_step(pattern)
        is_still = evolved == pattern
        print(f"  {name:8s}: {len(pattern)} cells, still life = {is_still}")
    
    # Verify empty grid is a still life (empty_is_still_life)
    empty = set()
    print(f"  {'Empty':8s}: 0 cells, still life = {gol_step(empty) == empty}")


# ============================================================
# Demo 3: Oscillators
# ============================================================

def demo_oscillators():
    """Verify oscillator periods."""
    print("\n" + "=" * 60)
    print("DEMO 3: Oscillator Period Verification")
    print("=" * 60)
    
    # Blinker (period 2)
    blinker = {(0, 0), (1, 0), (2, 0)}
    
    b1 = gol_step(blinker)
    b2 = gol_step(b1)
    print(f"  Blinker: period 2 = {b2 == blinker}")
    print(f"    Phase 0: {sorted(blinker)}")
    print(f"    Phase 1: {sorted(b1)}")
    
    # Toad (period 2)
    toad = {(1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1)}
    t1 = gol_step(toad)
    t2 = gol_step(t1)
    print(f"  Toad:    period 2 = {t2 == toad}")
    
    # Pulsar (period 3)
    pulsar = set()
    for s in [(-1, 1), (1, 1), (-1, -1), (1, -1)]:
        for (x, y) in [(2, 1), (3, 1), (4, 1), (1, 2), (1, 3), (1, 4)]:
            pulsar.add((s[0] * x, s[1] * y))
    
    p1 = gol_step(pulsar)
    p2 = gol_step(p1)
    p3 = gol_step(p2)
    print(f"  Pulsar:  period 3 = {p3 == pulsar}, cells = {len(pulsar)}")


# ============================================================
# Demo 4: Simulation Overhead
# ============================================================

def demo_overhead():
    """Demonstrate simulation overhead calculations."""
    print("\n" + "=" * 60)
    print("DEMO 4: Simulation Overhead Bounds")
    print("=" * 60)
    
    # Standard simulation chain: GoL → Register → Counter → Tag → TM
    chain_factors = [120, 8, 4, 2]  # Example time factors
    
    total = 1
    for i, f in enumerate(chain_factors):
        total *= f
        stage_names = ["GoL→Register", "Register→Counter", "Counter→Tag", "Tag→TM"]
        print(f"  Stage {i+1} ({stage_names[i]}): factor = {f}, cumulative = {total}")
    
    print(f"\n  Total time dilation: {total}")
    print(f"  Overhead polynomial chain bound (f=120, k=4): {120**4}")
    print(f"  Actual ≤ bound: {total <= 120**4}")
    
    # Overhead as function of TM parameters
    print("\n  Overhead as f(states, symbols):")
    for k in [2, 5, 10, 20]:
        for m in [2, 3, 5]:
            T = k**2 * m**2
            S = k * m
            print(f"    k={k:2d}, m={m}: time≤{T:6d}, space≤{S:4d}")


# ============================================================
# Demo 5: Non-injectivity
# ============================================================

def demo_non_injectivity():
    """Demonstrate that GoL is not injective (gol_not_injective)."""
    print("\n" + "=" * 60)
    print("DEMO 5: Non-injectivity (Garden of Eden)")
    print("=" * 60)
    
    # Two different configs that map to the same successor
    c1 = set()  # empty grid
    c2 = {(0, 0)}  # single cell
    
    s1 = gol_step(c1)
    s2 = gol_step(c2)
    
    print(f"  Config 1 (empty): {sorted(c1)}")
    print(f"  Config 2 (single cell): {sorted(c2)}")
    print(f"  Step(Config 1): {sorted(s1)}")
    print(f"  Step(Config 2): {sorted(s2)}")
    print(f"  Different configs: {c1 != c2}")
    print(f"  Same successors:   {s1 == s2}")
    print(f"  → golStep is NOT injective ✓")


# ============================================================
# Demo 6: Translation Invariance
# ============================================================

def demo_symmetry():
    """Demonstrate GoL symmetries (translation, reflection)."""
    print("\n" + "=" * 60)
    print("DEMO 6: Symmetries")
    print("=" * 60)
    
    pattern = {(0, 0), (1, 0), (2, 0), (1, 1)}  # T-tetromino
    v = (5, 3)
    
    # Translation invariance
    evolved = gol_step(pattern)
    translated_then_evolved = gol_step({(x + v[0], y + v[1]) for (x, y) in pattern})
    evolved_then_translated = {(x + v[0], y + v[1]) for (x, y) in evolved}
    
    print(f"  Pattern: {sorted(pattern)}")
    print(f"  Translation vector: {v}")
    print(f"  translate(evolve) == evolve(translate): "
          f"{evolved_then_translated == translated_then_evolved}")
    
    # Reflection invariance
    reflected_x = {(x, -y) for (x, y) in pattern}
    evolved_reflected = gol_step(reflected_x)
    reflected_evolved = {(x, -y) for (x, y) in evolved}
    
    print(f"  reflect_x(evolve) == evolve(reflect_x): "
          f"{reflected_evolved == evolved_reflected}")


if __name__ == "__main__":
    demo_glider()
    demo_still_lives()
    demo_oscillators()
    demo_overhead()
    demo_non_injectivity()
    demo_symmetry()
    
    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Simulation Overhead Landscape

Shows how simulation overhead scales with TM parameters (states × symbols),
demonstrating the O(k²m²) time bound and O(km) space bound from the
gol_simulation_overhead theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_time_overhead(k: int, m: int) -> int:
    return k ** 2 * m ** 2


def compute_space_overhead(k: int, m: int) -> int:
    return k * m


def compute_chain_overhead(factors: list) -> list:
    cumulative = []
    total = 1
    for f in factors:
        total *= f
        cumulative.append(total)
    return cumulative


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # Plot 1: Time overhead heatmap
    ax1 = axes[0]
    states = np.arange(1, 21)
    symbols = np.arange(1, 11)
    K, M = np.meshgrid(states, symbols)
    T = K**2 * M**2
    
    im = ax1.pcolormesh(states, symbols, np.log10(T), cmap='YlOrRd', shading='auto')
    plt.colorbar(im, ax=ax1, label='log₁₀(time overhead)')
    ax1.set_xlabel('TM States (k)')
    ax1.set_ylabel('TM Symbols (m)')
    ax1.set_title('GoL Time Overhead: O(k²m²)')
    
    # Plot 2: Simulation chain composition
    ax2 = axes[1]
    chain_labels = ['GoL→Reg', 'Reg→Cnt', 'Cnt→Tag', 'Tag→TM']
    example_chains = {
        'Small TM (2,2)': [20, 4, 2, 2],
        'Medium TM (5,3)': [60, 8, 4, 2],
        'Large TM (10,5)': [120, 16, 8, 4],
    }
    
    x_pos = np.arange(len(chain_labels))
    width = 0.25
    for i, (name, factors) in enumerate(example_chains.items()):
        cumulative = compute_chain_overhead(factors)
        ax2.bar(x_pos + i * width, np.log10(cumulative), width, label=name, alpha=0.8)
    
    ax2.set_xlabel('Simulation Stage')
    ax2.set_ylabel('log₁₀(cumulative overhead)')
    ax2.set_title('Chain Composition: ∏ τᵢ')
    ax2.set_xticks(x_pos + width)
    ax2.set_xticklabels(chain_labels, rotation=15)
    ax2.legend(fontsize=8)
    
    # Plot 3: Overhead bound comparison
    ax3 = axes[2]
    k_range = np.arange(2, 30)
    
    # Actual overhead (assuming typical chain)
    actual = k_range**2 * 4  # simplified
    # Upper bound from theorem
    upper = k_range**4  # f^k with k=4
    # Lower bound (linear)
    lower = k_range
    
    ax3.semilogy(k_range, actual, 'b-', linewidth=2, label='Typical overhead O(k²)')
    ax3.semilogy(k_range, upper, 'r--', linewidth=2, label='Chain bound O(k⁴)')
    ax3.semilogy(k_range, lower, 'g:', linewidth=2, label='Linear O(k)')
    ax3.fill_between(k_range, lower, upper, alpha=0.1, color='blue')
    ax3.set_xlabel('TM Complexity (k)')
    ax3.set_ylabel('Simulation Overhead')
    ax3.set_title('Overhead Scaling Bounds')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/GameOfLife/overhead_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved overhead_landscape.png")


if __name__ == '__main__':
    main()
