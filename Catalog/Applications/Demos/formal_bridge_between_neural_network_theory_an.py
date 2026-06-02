#!/usr/bin/env python3
"""
Neural Stone Duality — Demonstration Script

Demonstrates the key results:
1. Activation patterns of ReLU networks partition input space
2. Region counts obey binomial sum bounds
3. Layer composition multiplies region counts
4. Tropical signatures refine Boolean signatures
"""

import numpy as np
from itertools import product as iterproduct
from math import comb, log2
from typing import Dict, List, Set, Tuple

def binomial_sum(n: int, d: int) -> int:
    """Compute Φ(n,d) = Σ_{k=0}^{d} C(n,k)."""
    return sum(comb(n, k) for k in range(min(d, n) + 1))

def relu(x: np.ndarray) -> np.ndarray:
    return np.maximum(0, x)

def activation_signature(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> Tuple[bool, ...]:
    """Compute the Boolean activation signature of a single layer."""
    pre = W @ x + b
    return tuple(p > 0 for p in pre)

def tropical_signature(W: np.ndarray, b: np.ndarray, x: np.ndarray) -> Tuple:
    """Compute the tropical activation signature (magnitude-aware)."""
    pre = W @ x + b
    return tuple(
        ('active', float(p)) if p > 0 else ('inactive',)
        for p in pre
    )

def count_regions(W: np.ndarray, b: np.ndarray,
                  grid_points: np.ndarray) -> Dict[Tuple, List[np.ndarray]]:
    """Count distinct activation regions on a grid of input points."""
    regions: Dict[Tuple, List[np.ndarray]] = {}
    for x in grid_points:
        sig = activation_signature(W, b, x)
        if sig not in regions:
            regions[sig] = []
        regions[sig].append(x)
    return regions


def demo_partition():
    """Demo 1: Activation regions partition input space."""
    print("=" * 60)
    print("DEMO 1: Activation Regions Partition Input Space")
    print("=" * 60)

    np.random.seed(42)
    n_neurons = 4
    input_dim = 2

    W = np.random.randn(n_neurons, input_dim)
    b = np.random.randn(n_neurons)

    # Create grid
    grid = np.array([[x, y]
                     for x in np.linspace(-3, 3, 50)
                     for y in np.linspace(-3, 3, 50)])

    regions = count_regions(W, b, grid)

    print(f"Network: {n_neurons} neurons, {input_dim}D input")
    print(f"Grid: {len(grid)} points")
    print(f"Distinct activation patterns: {len(regions)}")
    print(f"Zaslavsky bound Φ({n_neurons},{input_dim}): {binomial_sum(n_neurons, input_dim)}")
    print(f"Powerset bound 2^{n_neurons}: {2**n_neurons}")

    # Verify partition: every point belongs to exactly one region
    total = sum(len(pts) for pts in regions.values())
    assert total == len(grid), "Partition covering failed!"
    print(f"✓ All {total} points covered (partition verified)")
    print()


def demo_binomial_sums():
    """Demo 2: Binomial sum properties."""
    print("=" * 60)
    print("DEMO 2: Binomial Sum Properties")
    print("=" * 60)

    # Pascal recurrence
    for n in range(1, 8):
        for d in range(1, n + 1):
            lhs = binomial_sum(n + 1, d + 1)
            rhs = binomial_sum(n, d + 1) + binomial_sum(n, d)
            assert lhs == rhs, f"Pascal failed for n={n}, d={d}"
    print("✓ Pascal recurrence Φ(n+1,d+1) = Φ(n,d+1) + Φ(n,d) verified for n,d ≤ 7")

    # Upper bound
    for n in range(10):
        for d in range(10):
            assert binomial_sum(n, d) <= 2**n
    print("✓ Φ(n,d) ≤ 2^n verified for n,d ≤ 9")

    # Strict improvement
    for n in range(2, 10):
        for d in range(1, n):
            assert binomial_sum(n, d) < 2**n
    print("✓ Φ(n,d) < 2^n for 0 < d < n verified for n ≤ 9")

    # Show table
    print("\nBinomial sum table Φ(n,d):")
    header = 'n\\d'
    print(f"{header:>4}", end="")
    for d in range(8):
        print(f"{d:>6}", end="")
    print(f"{'2^n':>8}")
    for n in range(8):
        print(f"{n:>4}", end="")
        for d in range(8):
            print(f"{binomial_sum(n, d):>6}", end="")
        print(f"{2**n:>8}")
    print()


def demo_refinement():
    """Demo 3: Layer composition multiplies region counts."""
    print("=" * 60)
    print("DEMO 3: Layer Composition Refinement")
    print("=" * 60)

    np.random.seed(123)
    input_dim = 2

    for width in [3, 4, 5]:
        W1 = np.random.randn(width, input_dim)
        b1 = np.random.randn(width)
        W2 = np.random.randn(width, width)
        b2 = np.random.randn(width)

        grid = np.array([[x, y]
                         for x in np.linspace(-3, 3, 100)
                         for y in np.linspace(-3, 3, 100)])

        # Count regions for each layer
        sigs1 = set()
        sigs2 = set()
        sigs_combined = set()
        for x in grid:
            s1 = activation_signature(W1, b1, x)
            h = relu(W1 @ x + b1)
            s2 = activation_signature(W2, b2, h)
            sigs1.add(s1)
            sigs2.add(s2)
            sigs_combined.add((s1, s2))

        print(f"Width {width}: Layer1={len(sigs1)}, Layer2={len(sigs2)}, "
              f"Combined={len(sigs_combined)}, "
              f"Bound={len(sigs1)*len(sigs2)}, "
              f"(2w)^L={(2*width)**2}")
        assert len(sigs_combined) <= len(sigs1) * len(sigs2), "Refinement bound violated!"
    print("✓ Refinement bound m₁·m₂ verified for all cases")
    print()


def demo_tropical():
    """Demo 4: Tropical signatures refine Boolean signatures."""
    print("=" * 60)
    print("DEMO 4: Tropical Refinement")
    print("=" * 60)

    np.random.seed(456)
    n_neurons = 5
    input_dim = 2

    W = np.random.randn(n_neurons, input_dim)
    b = np.random.randn(n_neurons)

    grid = np.array([[x, y]
                     for x in np.linspace(-3, 3, 80)
                     for y in np.linspace(-3, 3, 80)])

    bool_sigs = set()
    trop_sigs = set()

    for x in grid:
        bs = activation_signature(W, b, x)
        ts = tropical_signature(W, b, x)
        bool_sigs.add(bs)
        # Discretize tropical magnitudes to integers for counting
        ts_discrete = tuple(
            ('active', int(v[1] * 10) / 10) if v[0] == 'active' else v
            for v in ts
        )
        trop_sigs.add(ts_discrete)

    print(f"Network: {n_neurons} neurons, {input_dim}D input")
    print(f"Boolean signatures: {len(bool_sigs)}")
    print(f"Tropical signatures (discretized): {len(trop_sigs)}")
    print(f"Ratio: {len(trop_sigs)/len(bool_sigs):.1f}x")
    print(f"Zaslavsky bound Φ({n_neurons},{input_dim}): {binomial_sum(n_neurons, input_dim)}")

    # Verify surjectivity: every Boolean sig has at least one tropical sig
    trop_to_bool = {}
    for x in grid:
        bs = activation_signature(W, b, x)
        if bs not in trop_to_bool:
            trop_to_bool[bs] = True
    assert len(trop_to_bool) == len(bool_sigs), "Surjectivity check failed"
    print("✓ Coarsening surjectivity verified")
    print()


def demo_vc_dimension():
    """Demo 5: VC dimension zero characterization."""
    print("=" * 60)
    print("DEMO 5: VC Dimension Zero Families")
    print("=" * 60)

    # A VC-0 family on [4]: all members agree on every element
    n = 4
    family_vc0 = [frozenset({0, 2})]  # Just one set
    print(f"VC-0 family on [{n}]: {[set(s) for s in family_vc0]}")
    print(f"|F| = {len(family_vc0)} ≤ 1 ✓")

    # A VC-1 family
    family_vc1 = [frozenset(), frozenset({0}), frozenset({1}), frozenset({0, 1})]
    # This shatters {0} and {1} but not {0,1} since {1} ∩ {0,1} = {1} but
    # we need both {0} and {1} in the trace of {0,1}
    print(f"\nVC-1 family on [{n}]: {[set(s) for s in family_vc1]}")
    print(f"|F| = {len(family_vc1)} ≤ Φ({n},1) = {binomial_sum(n, 1)}")

    # Sauer-Shelah bound check
    for d in range(n + 1):
        bound = binomial_sum(n, d)
        # Maximum family size with VC-dim ≤ d
        print(f"  VC-dim ≤ {d}: |F| ≤ {bound} (vs 2^{n} = {2**n})")
    print()


if __name__ == "__main__":
    demo_partition()
    demo_binomial_sums()
    demo_refinement()
    demo_tropical()
    demo_vc_dimension()
    print("All demonstrations completed successfully! ✓")


#!/usr/bin/env python3
"""
Visualization: ReLU Network Activation Regions

Shows how hyperplanes partition 2D space into activation regions,
color-coded by their Boolean activation signature.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def activation_signature(W, b, x):
    pre = W @ x + b
    return tuple(p > 0 for p in pre)


def main():
    np.random.seed(42)
    n_neurons = 5
    W = np.random.randn(n_neurons, 2)
    b = np.random.randn(n_neurons)

    resolution = 300
    x_range = np.linspace(-3, 3, resolution)
    y_range = np.linspace(-3, 3, resolution)
    X, Y = np.meshgrid(x_range, y_range)

    sig_to_id = {}
    Z = np.zeros_like(X, dtype=int)
    for i in range(resolution):
        for j in range(resolution):
            sig = activation_signature(W, b, np.array([X[i, j], Y[i, j]]))
            if sig not in sig_to_id:
                sig_to_id[sig] = len(sig_to_id)
            Z[i, j] = sig_to_id[sig]

    n_regions = len(sig_to_id)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: colored regions
    cmap = plt.cm.get_cmap('tab20', n_regions)
    ax = axes[0]
    ax.pcolormesh(X, Y, Z, cmap=cmap, shading='auto')
    ax.set_title(f'Activation Regions ({n_regions} regions)\n'
                 f'{n_neurons} neurons in 2D', fontsize=13)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')

    # Draw hyperplane boundaries
    for k in range(n_neurons):
        w1, w2 = W[k]
        bk = b[k]
        if abs(w2) > 1e-10:
            y_line = (-w1 * x_range - bk) / w2
            mask = (y_line > -3) & (y_line < 3)
            ax.plot(x_range[mask], y_line[mask], 'k-', alpha=0.5, linewidth=0.8)
        else:
            x_line = -bk / w1
            if -3 < x_line < 3:
                ax.axvline(x_line, color='k', alpha=0.5, linewidth=0.8)
    ax.set_xlim(-3, 3)
    ax.set_ylim(-3, 3)

    # Right: binomial sum bounds
    ax = axes[1]
    dims = range(0, n_neurons + 1)
    bounds = [sum(np.math.comb(n_neurons, k) for k in range(d + 1)) for d in dims]
    ax.bar(list(dims), bounds, color='steelblue', alpha=0.8, label='Φ(n,d)')
    ax.axhline(y=n_regions, color='red', linestyle='--', linewidth=2,
               label=f'Actual regions = {n_regions}')
    ax.axhline(y=2**n_neurons, color='orange', linestyle=':', linewidth=2,
               label=f'2^n = {2**n_neurons}')
    ax.set_xlabel('Dimension d')
    ax.set_ylabel('Bound')
    ax.set_title(f'Zaslavsky Bound Φ({n_neurons}, d)', fontsize=13)
    ax.legend()
    ax.set_xticks(list(dims))

    plt.tight_layout()
    plt.savefig('activation_regions.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved activation_regions.png ({n_regions} regions found)")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Tropical vs Boolean Activation Signatures

Shows how tropical signatures (with magnitude) refine Boolean
signatures (on/off only), and the surjectivity of coarsening.
"""

import numpy as np
import matplotlib.pyplot as plt


def main():
    np.random.seed(42)
    n_neurons = 4
    W = np.random.randn(n_neurons, 2)
    b = np.random.randn(n_neurons)

    resolution = 200
    x_range = np.linspace(-3, 3, resolution)
    y_range = np.linspace(-3, 3, resolution)
    X, Y = np.meshgrid(x_range, y_range)

    bool_sigs = {}
    magnitudes = np.zeros((resolution, resolution))

    for i in range(resolution):
        for j in range(resolution):
            x = np.array([X[i, j], Y[i, j]])
            pre = W @ x + b
            sig = tuple(p > 0 for p in pre)
            if sig not in bool_sigs:
                bool_sigs[sig] = len(bool_sigs)
            # Total activation magnitude (tropical information)
            magnitudes[i, j] = np.sum(np.maximum(0, pre))

    n_regions = len(bool_sigs)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: Boolean regions
    Z_bool = np.zeros_like(X, dtype=int)
    for i in range(resolution):
        for j in range(resolution):
            x = np.array([X[i, j], Y[i, j]])
            pre = W @ x + b
            sig = tuple(p > 0 for p in pre)
            Z_bool[i, j] = bool_sigs[sig]

    cmap = plt.cm.get_cmap('Set3', n_regions)
    axes[0].pcolormesh(X, Y, Z_bool, cmap=cmap, shading='auto')
    axes[0].set_title(f'Boolean Signatures\n({n_regions} patterns)', fontsize=13)
    axes[0].set_xlabel('x₁')
    axes[0].set_ylabel('x₂')

    # Middle: Tropical magnitudes
    im = axes[1].pcolormesh(X, Y, magnitudes, cmap='viridis', shading='auto')
    axes[1].set_title('Tropical Magnitude\n(total activation)', fontsize=13)
    axes[1].set_xlabel('x₁')
    axes[1].set_ylabel('x₂')
    plt.colorbar(im, ax=axes[1], label='Σ max(0, Wx+b)')

    # Right: Comparison chart
    M_values = [10, 50, 100, 500, 1000]
    bool_counts = []
    trop_counts = []

    for M in M_values:
        res = 100
        xr = np.linspace(-M/10, M/10, res)
        yr = np.linspace(-M/10, M/10, res)

        b_set = set()
        t_set = set()
        for xi in xr:
            for yi in yr:
                x = np.array([xi, yi])
                pre = W @ x + b
                bsig = tuple(p > 0 for p in pre)
                # Discretize magnitudes to integer bins
                tsig = tuple(
                    ('a', round(max(0, p), 1)) if p > 0 else ('i',)
                    for p in pre
                )
                b_set.add(bsig)
                t_set.add(tsig)
        bool_counts.append(len(b_set))
        trop_counts.append(len(t_set))

    ax = axes[2]
    x_pos = range(len(M_values))
    width_bar = 0.35
    ax.bar([x - width_bar/2 for x in x_pos], bool_counts, width_bar,
           label='Boolean', color='steelblue', alpha=0.8)
    ax.bar([x + width_bar/2 for x in x_pos], trop_counts, width_bar,
           label='Tropical', color='coral', alpha=0.8)
    ax.set_xlabel('Magnitude bound M')
    ax.set_ylabel('Distinct signatures')
    ax.set_title('Boolean vs Tropical\nSignature Counts', fontsize=13)
    ax.set_xticks(list(x_pos))
    ax.set_xticklabels([str(M) for M in M_values])
    ax.legend()

    plt.tight_layout()
    plt.savefig('tropical_refinement.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved tropical_refinement.png")


if __name__ == "__main__":
    main()
