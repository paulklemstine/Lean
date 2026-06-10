#!/usr/bin/env python3
"""
Thermodynamic Stone–Prime Completeness: Interactive Demonstration
================================================================

This demo brings the formally verified completeness theorem to life with
concrete numerical examples and visualizations.

The key result: derivability in a proof semiring is equivalent to
universal thermodynamic validity — and non-derivability always yields
a separating prime point with a strictly positive free-energy gap.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from dataclasses import dataclass
from typing import List, Tuple, Optional, Callable

# ─── Core Definitions ─────────────────────────────────────────────────────

@dataclass
class PrimePoint:
    """A prime point in the congruence spectrum."""
    name: str
    eval_fn: Callable[[str], float]

    def eval(self, x: str) -> float:
        return self.eval_fn(x)


@dataclass
class ThermoState:
    """A thermodynamic state = (prime point, inverse temperature beta >= 0)."""
    point: PrimePoint
    beta: float

    def __post_init__(self):
        assert self.beta >= 0, f"beta must be >= 0, got {self.beta}"


def thermo_eval(state, base_eval, energy, x):
    """F(p, beta, x) = base(p,x) + beta * energy(p,x)"""
    return base_eval(state.point, x) + state.beta * energy(state.point, x)


def free_energy_gap(state, base_eval, energy, x, y):
    """FreeEnergyGap(p, beta, x, y) = F(p, beta, x) - F(p, beta, y)"""
    return thermo_eval(state, base_eval, energy, x) - thermo_eval(state, base_eval, energy, y)


# ─── Demo 1: Simple Separation ────────────────────────────────────────────

def demo_simple_separation():
    print("=" * 70)
    print("DEMO 1: Simple Separation in a Three-Element Proof Semiring")
    print("=" * 70)

    evals = {
        'p1': {'a': 3.0, 'b': 5.0, 'c': 4.0},
        'p2': {'a': 2.0, 'b': 1.0, 'c': 4.0},
        'p3': {'a': 1.0, 'b': 2.0, 'c': 3.0},
    }

    primes = [
        PrimePoint('p1', lambda x, e=evals['p1']: e[x]),
        PrimePoint('p2', lambda x, e=evals['p2']: e[x]),
        PrimePoint('p3', lambda x, e=evals['p3']: e[x]),
    ]

    energies = {
        'p1': {'a': 1.0, 'b': -1.0, 'c': 0.5},
        'p2': {'a': -0.5, 'b': 2.0, 'c': -1.0},
        'p3': {'a': 0.0, 'b': 0.5, 'c': -0.5},
    }

    def base_eval(p, x):
        return evals[p.name][x]

    def energy(p, x):
        return energies[p.name][x]

    elements = ['a', 'b', 'c']

    print("\nBase valuations (Lawvere/Stone semantics at β=0):")
    print(f"{'':>6}", end="")
    for x in elements:
        print(f"{x:>8}", end="")
    print()
    for p in primes:
        print(f"{p.name:>6}", end="")
        for x in elements:
            print(f"{base_eval(p, x):>8.1f}", end="")
        print()

    print("\nDerivability check (x ≤ y iff eval(p,x) ≤ eval(p,y) for all p):")
    for x in elements:
        for y in elements:
            if x == y:
                continue
            valid_at_zero = all(base_eval(p, x) <= base_eval(p, y) for p in primes)
            if valid_at_zero:
                print(f"  {x} ≤ {y}: DERIVABLE (valid at all prime points)")
            else:
                for p in primes:
                    if base_eval(p, y) < base_eval(p, x):
                        gap = base_eval(p, x) - base_eval(p, y)
                        print(f"  {x} ≤ {y}: NOT derivable — "
                              f"separated by {p.name} with gap = {gap:.1f}")
                        break

    print("\n\nThermodynamic free-energy gaps for a ≤ b:")
    betas = [0.0, 0.5, 1.0, 2.0, 5.0]
    for beta_val in betas:
        print(f"\n  β = {beta_val}:")
        for p in primes:
            state = ThermoState(p, beta_val)
            gap = free_energy_gap(state, base_eval, energy, 'a', 'b')
            fx = thermo_eval(state, base_eval, energy, 'a')
            fy = thermo_eval(state, base_eval, energy, 'b')
            status = "GAP > 0 (separates!)" if gap > 1e-10 else "gap ≤ 0"
            print(f"    {p.name}: F(a)={fx:6.2f}, F(b)={fy:6.2f}, "
                  f"gap={gap:6.2f}  [{status}]")


# ─── Demo 2: Temperature Landscape ────────────────────────────────────────

def demo_temperature_landscape():
    print("\n" + "=" * 70)
    print("DEMO 2: Temperature Landscape of Free-Energy Gaps")
    print("=" * 70)

    evals_data = {
        'p1': {'x': 3.0, 'y': 4.0},
        'p2': {'x': 5.0, 'y': 2.0},
    }

    energies_data = {
        'p1': {'x': 2.0, 'y': -1.0},
        'p2': {'x': -1.0, 'y': 3.0},
    }

    betas = np.linspace(0, 5, 200)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Free-energy gap vs beta
    ax = axes[0]
    for p_name, color in [('p1', 'steelblue'), ('p2', 'coral')]:
        gaps = []
        for b in betas:
            fx = evals_data[p_name]['x'] + b * energies_data[p_name]['x']
            fy = evals_data[p_name]['y'] + b * energies_data[p_name]['y']
            gaps.append(fx - fy)
        ax.plot(betas, gaps, color=color, linewidth=2, label=p_name)

    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Free-energy gap F(x) - F(y)', fontsize=12)
    ax.set_title('Free-Energy Gap vs Temperature', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: Max gap across primes
    ax = axes[1]
    max_gaps = []
    for b in betas:
        gaps_at_b = []
        for p_name in ['p1', 'p2']:
            fx = evals_data[p_name]['x'] + b * energies_data[p_name]['x']
            fy = evals_data[p_name]['y'] + b * energies_data[p_name]['y']
            gaps_at_b.append(fx - fy)
        max_gaps.append(max(gaps_at_b))

    ax.plot(betas, max_gaps, color='darkgreen', linewidth=2.5)
    ax.fill_between(betas, 0, max_gaps, where=[g > 0 for g in max_gaps],
                     alpha=0.15, color='red', label='Separation region')
    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('max_p FreeEnergyGap', fontsize=12)
    ax.set_title('Maximum Gap (Separation Barrier)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Panel 3: Random phase diagram
    ax = axes[2]
    np.random.seed(42)
    for i in range(5):
        base_gap = np.random.randn() * 2
        energy_gap = np.random.randn() * 1.5
        gaps = base_gap + betas * energy_gap
        ax.plot(betas, gaps, linewidth=1.5, alpha=0.7, label=f'p{i+1}')

    ax.axhline(y=0, color='black', linewidth=1, linestyle='--')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Free-energy gap', fontsize=12)
    ax.set_title('Spectral Phase Diagram (5 primes)', fontsize=13)
    ax.legend(fontsize=9, ncol=2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('demos/temperature_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/temperature_landscape.png")


# ─── Demo 3: Finite Grid Search ───────────────────────────────────────────

def demo_finite_grid_search():
    print("\n" + "=" * 70)
    print("DEMO 3: Finite Grid Countermodel Search")
    print("=" * 70)

    n_primes = 4
    beta_grid = [0.0, 0.5, 1.0, 2.0, 5.0, 10.0]

    np.random.seed(123)
    base_vals_x = np.random.randn(n_primes) * 3
    base_vals_y = base_vals_x + np.random.randn(n_primes) * 0.5
    energy_x = np.random.randn(n_primes) * 2
    energy_y = np.random.randn(n_primes) * 2

    print(f"\n  Prime spectrum: {n_primes} points")
    print(f"  Temperature grid: {len(beta_grid)} values")
    print(f"  Total search space: {n_primes * len(beta_grid)} grid points")

    print("\n  Grid search results (FreeEnergyGap = F(x) - F(y)):")
    print(f"  {'':>6}", end="")
    for b in beta_grid:
        print(f"{'β='+str(b):>10}", end="")
    print()

    best_gap = -np.inf
    best_point = None
    gap_matrix = np.zeros((n_primes, len(beta_grid)))

    for i in range(n_primes):
        print(f"  {'p'+str(i+1):>6}", end="")
        for j, b in enumerate(beta_grid):
            fx = base_vals_x[i] + b * energy_x[i]
            fy = base_vals_y[i] + b * energy_y[i]
            gap = fx - fy
            gap_matrix[i, j] = gap
            marker = " *" if gap > 0 else "  "
            print(f"{gap:>8.2f}{marker}", end="")
            if gap > best_gap:
                best_gap = gap
                best_point = (i, b)
        print()

    if best_gap > 0:
        p_idx, beta_val = best_point
        print(f"\n  ✓ SEPARATED: Best witness at p{p_idx+1}, β={beta_val}")
        print(f"    Free-energy gap = {best_gap:.4f} > 0")
    else:
        print(f"\n  ✗ No separation found on this grid")

    # Heatmap
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    im = ax.imshow(gap_matrix, aspect='auto', cmap='RdBu_r',
                    vmin=-np.max(np.abs(gap_matrix)),
                    vmax=np.max(np.abs(gap_matrix)))
    ax.set_xticks(range(len(beta_grid)))
    ax.set_xticklabels([f'{b}' for b in beta_grid])
    ax.set_yticks(range(n_primes))
    ax.set_yticklabels([f'p{i+1}' for i in range(n_primes)])
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Prime point', fontsize=12)
    ax.set_title('Free-Energy Gap Heatmap (red = separation)', fontsize=13)
    plt.colorbar(im, ax=ax, label='FreeEnergyGap(p, β, x, y)')

    for i in range(n_primes):
        for j in range(len(beta_grid)):
            if gap_matrix[i, j] > 0:
                ax.plot(j, i, 'k*', markersize=10)

    plt.tight_layout()
    plt.savefig('demos/finite_grid_search.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/finite_grid_search.png")


# ─── Demo 4: Completeness Illustration ────────────────────────────────────

def demo_completeness_illustration():
    print("\n" + "=" * 70)
    print("DEMO 4: Completeness Theorem Illustration")
    print("=" * 70)

    base = {
        'p1': {'a': 1, 'b': 3, 'c': 2},
        'p2': {'a': 2, 'b': 4, 'c': 5},
        'p3': {'a': 0, 'b': 1, 'c': 1},
    }

    elements = ['a', 'b', 'c']
    primes = ['p1', 'p2', 'p3']

    print("\nBase valuations:")
    print(f"  {'':>6}", end="")
    for x in elements:
        print(f"{x:>8}", end="")
    print()
    for p in primes:
        print(f"  {p:>6}", end="")
        for x in elements:
            print(f"{base[p][x]:>8}", end="")
        print()

    print("\nCompleteness check (β=0, Stone semantics):")
    for x in elements:
        for y in elements:
            if x == y:
                continue
            all_valid = all(base[p][x] <= base[p][y] for p in primes)
            if all_valid:
                print(f"  {x} ≤ {y}: ✓ DERIVABLE")
            else:
                sep = [(p, base[p][x] - base[p][y]) for p in primes
                       if base[p][x] > base[p][y]]
                sep_str = ', '.join(f"{p}: gap={g}" for p, g in sep)
                print(f"  {x} ≤ {y}: ✗ NOT derivable  (separated by {sep_str})")

    # Visualization
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    ax = axes[0]
    x_pos = np.arange(len(primes))
    width = 0.25
    colors = ['#2196F3', '#4CAF50', '#FF9800']
    for i, elem in enumerate(elements):
        vals = [base[p][elem] for p in primes]
        ax.bar(x_pos + i * width, vals, width, label=elem, color=colors[i], alpha=0.8)
    ax.set_xticks(x_pos + width)
    ax.set_xticklabels(primes)
    ax.set_ylabel('Evaluation', fontsize=12)
    ax.set_title('Evaluations at Prime Points', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3, axis='y')

    ax = axes[1]
    positions = {'a': (0.3, 0.2), 'b': (0.7, 0.6), 'c': (0.5, 0.9)}
    derivable = {}
    for x in elements:
        for y in elements:
            derivable[(x, y)] = all(base[p][x] <= base[p][y] for p in primes)

    for elem, (px, py) in positions.items():
        ax.plot(px, py, 'o', markersize=30, color=colors[elements.index(elem)], zorder=5)
        ax.text(px, py, elem, ha='center', va='center', fontsize=16, fontweight='bold', zorder=6)

    for x in elements:
        for y in elements:
            if x != y and derivable[(x, y)]:
                px1, py1 = positions[x]
                px2, py2 = positions[y]
                dx, dy = px2 - px1, py2 - py1
                length = np.sqrt(dx**2 + dy**2)
                shrink = 0.08
                ax.annotate('', xy=(px2 - shrink*dx/length, py2 - shrink*dy/length),
                           xytext=(px1 + shrink*dx/length, py1 + shrink*dy/length),
                           arrowprops=dict(arrowstyle='->', color='black', lw=2,
                                          connectionstyle='arc3,rad=0.1'))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.1)
    ax.set_title('Derivability Relation\n(arrows = derivable)', fontsize=13)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('demos/completeness_illustration.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/completeness_illustration.png")


# ─── Demo 5: Additive Decomposition ───────────────────────────────────────

def demo_additive_decomposition():
    print("\n" + "=" * 70)
    print("DEMO 5: Additive Free-Energy Gap Decomposition")
    print("=" * 70)

    cases = [
        ("Stable separation", 2.0, 1.0),
        ("Temperature-induced", -1.0, 3.0),
        ("Temperature-killed", 3.0, -2.0),
        ("Never separates", -2.0, -1.0),
    ]

    betas = np.linspace(0, 5, 200)
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for idx, (name, base_gap, energy_gap) in enumerate(cases):
        ax = axes[idx // 2][idx % 2]
        gaps = base_gap + betas * energy_gap

        ax.plot(betas, gaps, 'b-', linewidth=2.5)
        ax.axhline(y=0, color='black', linewidth=0.5, linestyle='--')
        ax.fill_between(betas, 0, gaps, where=gaps > 0,
                         alpha=0.2, color='red', label='Separation (gap > 0)')
        ax.fill_between(betas, gaps, 0, where=gaps <= 0,
                         alpha=0.2, color='green', label='Validity (gap ≤ 0)')

        if energy_gap != 0:
            beta_crit = -base_gap / energy_gap
            if 0 <= beta_crit <= 5:
                ax.axvline(x=beta_crit, color='red', linewidth=1.5,
                          linestyle=':', label=f'β* = {beta_crit:.2f}')

        ax.set_xlabel('β', fontsize=11)
        ax.set_ylabel('FreeEnergyGap', fontsize=11)
        ax.set_title(f'{name}\nbase={base_gap}, energy={energy_gap}', fontsize=12)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

    plt.suptitle('Additive Decomposition: Gap = base_gap + β × energy_gap',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('demos/additive_decomposition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: demos/additive_decomposition.png")

    print("\n  Analysis of critical temperatures:")
    for name, base_gap, energy_gap in cases:
        if energy_gap != 0:
            beta_crit = -base_gap / energy_gap
            if beta_crit >= 0:
                direction = "separation begins" if energy_gap > 0 else "separation ends"
                print(f"    {name}: β* = {beta_crit:.2f} ({direction})")
            else:
                state = "always separates" if base_gap > 0 else "never separates"
                print(f"    {name}: no critical point in β≥0 ({state})")
        else:
            state = "always separates" if base_gap > 0 else "never separates"
            print(f"    {name}: constant gap ({state})")


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Thermodynamic Stone–Prime Completeness: Demonstrations        ║")
    print("║  Formally verified in Lean 4 — brought to life in Python       ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    demo_simple_separation()
    demo_temperature_landscape()
    demo_finite_grid_search()
    demo_completeness_illustration()
    demo_additive_decomposition()

    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)
    print("""
  The completeness theorem states:

    derivable x y  ↔  ∀ p β, 0 ≤ β → eval p β x ≤ eval p β y

  Non-derivability yields a separating prime with positive free-energy gap.
  All results are formally verified in Lean 4 with Mathlib.
    """)
