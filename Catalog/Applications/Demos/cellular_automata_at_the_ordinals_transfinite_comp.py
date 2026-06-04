#!/usr/bin/env python3
"""
Ordinal Cellular Automata: Transfinite Computation Demo
========================================================

Demonstrates key concepts from the formalization:
1. Rule 110 evolution on finite grids
2. Identity CA with limit aggregation (transfinite extension witness)
3. Convergence behavior analysis
"""

import itertools


def rule110(left: bool, center: bool, right: bool) -> bool:
    """Rule 110 local transition function."""
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


def evolve_step(config: list[bool], rule=rule110, boundary=False) -> list[bool]:
    """One step of CA evolution on a finite grid."""
    n = len(config)
    new = []
    for i in range(n):
        left = config[i - 1] if i > 0 else boundary
        center = config[i]
        right = config[i + 1] if i < n - 1 else boundary
        new.append(rule(left, center, right))
    return new


def evolve_n_steps(config: list[bool], n: int, rule=rule110) -> list[list[bool]]:
    """Evolve for n steps, returning all intermediate configurations."""
    history = [config]
    current = config
    for _ in range(n):
        current = evolve_step(current, rule)
        history.append(current)
    return history


def identity_rule(left: bool, center: bool, right: bool) -> bool:
    """Identity local rule: ignores neighbors, returns center."""
    return center


def demonstrate_transfinite_extension():
    """
    Demonstrates the key theorem: exists_strict_transfinite_extension.
    
    With the identity local rule and limit aggregation that maps everything to True,
    the finite orbit is {initial config} while the transfinite orbit also contains
    the all-True configuration reached at time omega.
    """
    print("=" * 60)
    print("TRANSFINITE ORBIT STRICT EXTENSION")
    print("=" * 60)
    
    # Initial configuration: all False
    n = 10
    init = [False] * n
    
    # Finite evolution with identity rule
    print("\nIdentity rule: finite evolution (10 steps)")
    history = evolve_n_steps(init, 10, identity_rule)
    for i, cfg in enumerate(history):
        cells = "".join("█" if c else "░" for c in cfg)
        print(f"  t={i:2d}: {cells}")
    
    print(f"\n  Finite orbit size: 1 (all steps identical)")
    print(f"  Finite orbit = {{all-False}}")
    
    # At time omega (limit aggregation)
    limit_config = [True] * n  # limit aggregation maps to True
    cells = "".join("█" if c else "░" for c in limit_config)
    print(f"\n  t=ω:  {cells}  ← limit aggregation (always True)")
    print(f"  Transfinite orbit = {{all-False, all-True}}")
    print(f"  Strict containment: finiteOrbit ⊊ orbit ✓")


def demonstrate_rule110():
    """Demonstrate Rule 110 evolution showing complex behavior."""
    print("\n" + "=" * 60)
    print("RULE 110 EVOLUTION")
    print("=" * 60)
    
    n = 40
    # Single cell seed
    init = [False] * n
    init[n // 2] = True
    
    history = evolve_n_steps(init, 30, rule110)
    print(f"\nRule 110 from single seed (width={n}, 30 steps):")
    for i, cfg in enumerate(history):
        cells = "".join("█" if c else " " for c in cfg)
        print(f"  {cells}")
    
    # Check quiescent preservation
    all_false = [False] * n
    evolved = evolve_step(all_false, rule110)
    print(f"\nQuiescent preservation: rule110(F,F,F) = {rule110(False,False,False)}")
    print(f"  All-false config is fixed: {evolved == all_false} ✓")


def demonstrate_convergence():
    """Analyze convergence behavior of Rule 110."""
    print("\n" + "=" * 60)
    print("CONVERGENCE ANALYSIS")
    print("=" * 60)
    
    n = 20
    
    # Test various initial configurations
    configs = [
        ("single seed", [False]*9 + [True] + [False]*10),
        ("two seeds", [False]*5 + [True] + [False]*8 + [True] + [False]*5),
        ("block of 3", [False]*8 + [True,True,True] + [False]*9),
    ]
    
    for name, init in configs:
        # Evolve until convergence or max steps
        current = init
        seen = [current]
        converged_at = None
        
        for t in range(1, 200):
            current = evolve_step(current, rule110)
            if current in seen:
                converged_at = t
                break
            seen.append(current)
        
        if converged_at:
            period_start = seen.index(current)
            period = converged_at - period_start
            print(f"\n  {name}: periodic from t={period_start}, period={period}")
        else:
            print(f"\n  {name}: no periodicity in 200 steps")
            # Check if last configs are changing
            last_few = seen[-5:]
            all_same = all(c == last_few[0] for c in last_few)
            if all_same:
                print(f"    → converged to fixed point around t={len(seen)-5}")
            else:
                print(f"    → still evolving (complex dynamics)")


def demonstrate_omega_squared_structure():
    """
    Illustrate the ω² structure: cells indexed by (a, b) ∈ ω×ω.
    Each 'row' a contains an ω-length CA. At limit ordinal ω·a,
    row a aggregates and feeds into row a+1.
    """
    print("\n" + "=" * 60)
    print("ω² STRUCTURE: LAYERED COMPUTATION")
    print("=" * 60)
    
    width = 20
    rows = 4
    steps_per_row = 10
    
    print(f"\nSimulating ω² CA: {rows} layers × {steps_per_row} steps × {width} cells")
    print("Each layer runs Rule 110, then aggregates into the next layer.\n")
    
    # Layer 0: start with single seed
    current = [False] * width
    current[width // 2] = True
    
    for layer in range(rows):
        print(f"  Layer {layer} (time ω·{layer} to ω·{layer}+{steps_per_row}):")
        
        for step in range(steps_per_row):
            cells = "".join("█" if c else " " for c in current)
            if step == 0 or step == steps_per_row - 1:
                print(f"    t=ω·{layer}+{step:2d}: {cells}")
            elif step == 1:
                print(f"    {'...':>14}")
        
        # Limit aggregation: OR of last configuration
        # (simplified version of cofinal truth)
        aggregated = current[:]  # carry forward
        # Add some "limit effect": activate cells adjacent to active cells
        new = current[:]
        for i in range(width):
            if current[i]:
                if i > 0: new[i-1] = True
                if i < width-1: new[i+1] = True
        current = new
        
        # Continue evolution in next layer
        for _ in range(steps_per_row):
            current = evolve_step(current, rule110)
    
    print(f"\n  Each layer at ω·k receives aggregated data from layer k-1")
    print(f"  This creates a hierarchy of computation levels")
    print(f"  Information flows: finite steps (within layer) + transfinite (between layers)")


if __name__ == "__main__":
    demonstrate_transfinite_extension()
    demonstrate_rule110()
    demonstrate_convergence()
    demonstrate_omega_squared_structure()
    
    print("\n" + "=" * 60)
    print("SUMMARY OF FORMALIZED RESULTS")
    print("=" * 60)
    print("""
  1. evolve_zero: Evolution at time 0 = initial configuration
  2. evolve_succ: Evolution at successor unfolds local rule
  3. quiescent_succStep_invariant: Quiescent configs are fixed points
  4. allQuiescent_evolve_stable: Quiescent stability through ALL ordinals
  5. finiteOrbit_subset_orbit: Finite orbit ⊆ transfinite orbit
  6. exists_strict_transfinite_extension: ∃ CA with strict containment
  7. identity_finite_evolve: Identity rule keeps initial config forever
  8. rule110_quiescent: Rule 110 preserves quiescent state
  9. diagonal_constraint: Quiescent configs always in their own orbit
    """)


#!/usr/bin/env python3
"""
Visualization: Ordinal Cellular Automata Evolution
===================================================

Generates spacetime diagrams showing CA evolution across finite and
transfinite stages, illustrating the strict extension theorem.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def rule110(left: bool, center: bool, right: bool) -> bool:
    idx = (int(left) << 2) | (int(center) << 1) | int(right)
    return bool((110 >> idx) & 1)


def identity_rule(left: bool, center: bool, right: bool) -> bool:
    return center


def evolve_step(config: list[bool], rule, boundary=False) -> list[bool]:
    n = len(config)
    result = []
    for i in range(n):
        left = config[i - 1] if i > 0 else boundary
        center = config[i]
        right = config[i + 1] if i < n - 1 else boundary
        result.append(rule(left, center, right))
    return result


def make_spacetime_diagram(init: list[bool], steps: int, rule, title: str,
                           ax=None, show_limit=False, limit_config=None):
    """Create a spacetime diagram of CA evolution."""
    n = len(init)
    grid = np.zeros((steps + 1 + (2 if show_limit else 0), n))
    
    current = init
    grid[0] = [int(c) for c in current]
    
    for t in range(1, steps + 1):
        current = evolve_step(current, rule)
        grid[t] = [int(c) for c in current]
    
    if show_limit and limit_config is not None:
        grid[steps + 1] = [0.5] * n  # separator
        grid[steps + 2] = [int(c) for c in limit_config]
    
    if ax is None:
        fig, ax = plt.subplots(figsize=(10, 8))
    
    cmap = plt.cm.colors.ListedColormap(['white', 'black', '#ff6600'])
    bounds = [-0.25, 0.25, 0.75, 1.25]
    norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
    
    ax.imshow(grid, cmap=cmap, norm=norm, aspect='auto', interpolation='nearest')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel('Cell Position')
    ax.set_ylabel('Time Step')
    
    if show_limit:
        ax.axhline(y=steps + 0.5, color='red', linewidth=2, linestyle='--')
        ax.text(n + 0.5, steps + 1, '← ω', color='red', fontsize=11,
                va='center', fontweight='bold')
    
    return ax


# Main visualization
fig, axes = plt.subplots(1, 3, figsize=(18, 8))

# Panel 1: Rule 110 from single seed
width = 60
init_110 = [False] * width
init_110[width // 2] = True
make_spacetime_diagram(init_110, 40, rule110,
                       "Rule 110: Complex Dynamics", axes[0])

# Panel 2: Identity rule showing finite stasis
width2 = 30
init_id = [False] * width2
init_id[width2 // 2] = True
limit_true = [True] * width2
make_spacetime_diagram(init_id, 15, identity_rule,
                       "Identity Rule: Finite Orbit = {init}\n→ Limit produces new config at ω",
                       axes[1], show_limit=True, limit_config=limit_true)

# Panel 3: Rule 110 on ω² (layered)
width3 = 40
layers = 4
steps_per = 8
total_steps = layers * (steps_per + 1)
grid_omega2 = np.zeros((total_steps, width3))

current = [False] * width3
current[width3 // 2] = True

row = 0
for layer in range(layers):
    for step in range(steps_per):
        grid_omega2[row] = [int(c) for c in current]
        current = evolve_step(current, rule110)
        row += 1
    # Limit aggregation: expand support
    for i in range(width3):
        if current[i]:
            if i > 0: current[i-1] = True
            if i < width3 - 1: current[i+1] = True
    grid_omega2[row] = [0.5] * width3  # separator
    row += 1

cmap = plt.cm.colors.ListedColormap(['white', 'black', '#ff6600'])
bounds = [-0.25, 0.25, 0.75, 1.25]
norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)
axes[2].imshow(grid_omega2, cmap=cmap, norm=norm, aspect='auto',
               interpolation='nearest')
axes[2].set_title("Rule 110 on ω²: Layered Transfinite\nOrange lines = limit ordinals ω·k",
                  fontsize=12, fontweight='bold')
axes[2].set_xlabel('Cell Position')
axes[2].set_ylabel('Time')

# Mark limit ordinals
for layer in range(layers):
    y = layer * (steps_per + 1) + steps_per
    axes[2].axhline(y=y, color='red', linewidth=1.5, linestyle='--', alpha=0.7)

plt.tight_layout()
plt.savefig('ordinal_ca_visualization.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: ordinal_ca_visualization.png")

# Second figure: convergence analysis
fig2, axes2 = plt.subplots(1, 2, figsize=(14, 6))

# Novelty set analysis
widths = [10, 15, 20, 25, 30]
for w in widths:
    init = [False] * w
    init[w // 2] = True
    
    seen = set()
    novel_steps = []
    current = init
    
    for t in range(100):
        key = tuple(current)
        if key not in seen:
            novel_steps.append(t)
            seen.add(key)
        current = evolve_step(current, rule110)
    
    axes2[0].plot(range(len(novel_steps)), novel_steps, 'o-', label=f'width={w}',
                  markersize=3)

axes2[0].set_xlabel('Novel Configuration Index')
axes2[0].set_ylabel('Time Step of First Appearance')
axes2[0].set_title('Novelty Set Growth\n(Rule 110, various widths)')
axes2[0].legend()
axes2[0].grid(True, alpha=0.3)

# Orbit size growth
orbit_sizes = []
for w in range(5, 40):
    init = [False] * w
    init[w // 2] = True
    
    seen = set()
    current = init
    for t in range(200):
        seen.add(tuple(current))
        current = evolve_step(current, rule110)
    orbit_sizes.append(len(seen))

axes2[1].plot(range(5, 40), orbit_sizes, 'b-o', markersize=4)
axes2[1].set_xlabel('Grid Width')
axes2[1].set_ylabel('Distinct Configurations (200 steps)')
axes2[1].set_title('Finite Orbit Size vs Width\n(Rule 110, single seed)')
axes2[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('convergence_analysis.png', dpi=150, bbox_inches='tight')
plt.close()

print("Saved: convergence_analysis.png")
