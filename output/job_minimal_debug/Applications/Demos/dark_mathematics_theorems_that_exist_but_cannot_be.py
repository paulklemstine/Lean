"""
Dark Mathematics: Numerical Demonstrations

Demonstrates the key results about dark witness families:
1. The Dark Inequality (double counting bound)
2. Strict hierarchy construction
3. Extremal (tight) constructions
4. Product composition
"""

from typing import List, Set, Dict, Tuple
import itertools


def verify_dark_family(witnesses: Dict[int, Set[int]], level: int) -> Tuple[bool, str]:
    """Verify that a witness family is dark at the given level."""
    # Check sufficiency
    for world, wset in witnesses.items():
        if len(wset) < level:
            return False, f"World {world} has {len(wset)} witnesses, need {level}"
    
    # Check no universal witness
    all_witnesses = set()
    for wset in witnesses.values():
        all_witnesses |= wset
    
    for n in all_witnesses:
        if all(n in wset for wset in witnesses.values()):
            return False, f"Element {n} is a universal witness"
    
    return True, "Valid dark family"


def two_world_family(k: int) -> Dict[int, Set[int]]:
    """Construct the two-world dark family at level k."""
    return {
        0: set(range(k)),
        1: set(range(k, 2 * k))
    }


def complementary_block_partition(m: int, N: int) -> Dict[int, Set[int]]:
    """Construct extremal dark family via complementary block partition.
    Requires m | N.
    """
    assert N % m == 0, f"{m} does not divide {N}"
    q = N // m
    universe = set(range(N))
    witnesses = {}
    for i in range(m):
        block_i = set(range(i * q, (i + 1) * q))
        witnesses[i] = universe - block_i
    return witnesses


def dark_product(d1: Dict[int, Set[int]], d2: Dict[int, Set[int]]) -> Dict[Tuple[int, int], Set[int]]:
    """Construct the product of two dark families."""
    product = {}
    for a in d1:
        for b in d2:
            product[(a, b)] = d1[a] | d2[b]
    return product


def compute_spectrum(witnesses: Dict[int, Set[int]], N: int) -> Dict[int, Set[int]]:
    """Compute the darkness spectrum: for each element, which worlds contain it."""
    spectrum = {}
    for n in range(N):
        spectrum[n] = {a for a, wset in witnesses.items() if n in wset}
    return spectrum


def dark_inequality_check(m: int, N: int, k: int) -> bool:
    """Check if k * m <= N * (m - 1)."""
    return k * m <= N * (m - 1)


def max_darkness_level(m: int, N: int) -> int:
    """Maximum darkness level for m worlds and N-element universe."""
    return N * (m - 1) // m


# ============================================================
# DEMO 1: Two-world families and the strict hierarchy
# ============================================================
print("=" * 60)
print("DEMO 1: Strict Hierarchy of Darkness")
print("=" * 60)
for k in range(1, 8):
    fam = two_world_family(k)
    valid, msg = verify_dark_family(fam, k)
    not_higher = not verify_dark_family(fam, k + 1)[0]  # Can't be dark at k+1
    print(f"  Level {k}: {msg}, NOT level {k+1}: {not_higher}")
    print(f"    World 0: {sorted(fam[0])}")
    print(f"    World 1: {sorted(fam[1])}")

# ============================================================
# DEMO 2: Dark Inequality verification
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Dark Inequality k·m ≤ N·(m-1)")
print("=" * 60)
print(f"  {'m':>3} {'N':>3} {'max k':>5} | {'bound':>8} | {'tight?':>7}")
print("  " + "-" * 40)
for m in range(2, 7):
    for N in [m, 2*m, 3*m, 5*m]:
        max_k = max_darkness_level(m, N)
        bound_val = f"{max_k}*{m} ≤ {N}*{m-1}"
        fam = complementary_block_partition(m, N)
        valid, _ = verify_dark_family(fam, max_k)
        print(f"  {m:>3} {N:>3} {max_k:>5} | {max_k*m:>3} ≤ {N*(m-1):>3} | {'✓' if valid else '✗':>7}")

# ============================================================
# DEMO 3: Extremal construction and spectrum analysis
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Extremal Construction (m=3, N=12)")
print("=" * 60)
fam = complementary_block_partition(3, 12)
for i in range(3):
    print(f"  World {i}: {sorted(fam[i])} (size {len(fam[i])})")

spectrum = compute_spectrum(fam, 12)
print(f"\n  Spectrum analysis (which worlds contain each element):")
for n in range(12):
    spec = spectrum[n]
    print(f"    Element {n:>2}: in worlds {sorted(spec)}, spectrum size = {len(spec)}")

# Verify all spectrum sizes are m-1 = 2 (extremal property)
all_m_minus_1 = all(len(s) == 2 for s in spectrum.values())
print(f"\n  All spectrum sizes = m-1 = 2: {all_m_minus_1} (extremal characterization)")

# ============================================================
# DEMO 4: Product composition
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Product Composition (Additivity of Darkness)")
print("=" * 60)
d1 = two_world_family(3)  # Level 3, witnesses in {0,...,5}
# Shift d2 to disjoint range
d2_base = two_world_family(4)  # Level 4
d2 = {k: {x + 6 for x in v} for k, v in d2_base.items()}  # witnesses in {6,...,13}

print(f"  D1 (level 3): World 0 = {sorted(d1[0])}, World 1 = {sorted(d1[1])}")
print(f"  D2 (level 4): World 0 = {sorted(d2[0])}, World 1 = {sorted(d2[1])}")

prod = dark_product(d1, d2)
valid, msg = verify_dark_family(prod, 7)
print(f"\n  Product D1×D2 (expected level 3+4=7): {msg}")
for (a, b) in sorted(prod.keys()):
    print(f"    World ({a},{b}): {sorted(prod[(a,b)])} (size {len(prod[(a,b)])})")

# ============================================================
# DEMO 5: Shadow emptiness verification
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Shadow Emptiness")
print("=" * 60)
test_families = [
    ("Two-world (k=5)", two_world_family(5)),
    ("Block partition (m=3, N=9)", complementary_block_partition(3, 9)),
    ("Block partition (m=4, N=20)", complementary_block_partition(4, 20)),
]
for name, fam in test_families:
    all_witnesses = set()
    for wset in fam.values():
        all_witnesses |= wset
    shadow = {n for n in all_witnesses if all(n in wset for wset in fam.values())}
    print(f"  {name}: shadow = {shadow if shadow else '∅'}")

# ============================================================
# DEMO 6: Testable conjecture for non-divisible N
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Conjecture Test - Non-Divisible N")
print("=" * 60)
print("  Testing whether max darkness level = ⌊N(m-1)/m⌋ for m ∤ N")
print(f"  {'m':>3} {'N':>3} {'⌊bound⌋':>7} {'achieved?':>10}")
print("  " + "-" * 30)

for m in range(2, 5):
    for N in range(m + 1, 4 * m):
        if N % m == 0:
            continue  # Skip divisible cases (already proved tight)
        target = N * (m - 1) // m
        # Try to construct a dark family achieving target level
        # Greedy: distribute elements as evenly as possible
        best_level = 0
        # Use a greedy approach: each world gets N - ceil(N/m) elements
        q_ceil = (N + m - 1) // m
        # Try complementary-like construction
        witnesses = {}
        for i in range(m):
            start = i * N // m
            end = (i + 1) * N // m
            block_i = set(range(start, end))
            witnesses[i] = set(range(N)) - block_i
        
        min_size = min(len(wset) for wset in witnesses.values())
        valid, _ = verify_dark_family(witnesses, min_size)
        achieved = valid and min_size == target
        print(f"  {m:>3} {N:>3} {target:>7} {min_size:>4} {'✓' if achieved else '≈':>10}")

print("\nAll demonstrations complete.")


"""
Visualization: Dark Witness Families and the Dark Inequality

Creates a figure showing:
1. The witness structure of a dark family (bipartite incidence)
2. The Dark Inequality bound surface
3. Spectrum distribution for extremal families
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def plot_dark_family_structure():
    """Visualize a dark witness family as a bipartite incidence diagram."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Family 1: Two-world, level 3
    ax = axes[0]
    ax.set_title("Two-World Family (Level 3)", fontsize=12, fontweight='bold')
    worlds = {0: {0, 1, 2}, 1: {3, 4, 5}}
    _draw_bipartite(ax, worlds, 6)
    
    # Family 2: Three-world, level 4 (extremal, N=6)
    ax = axes[1]
    ax.set_title("Three-World Extremal (Level 4, N=6)", fontsize=12, fontweight='bold')
    worlds = {
        0: {2, 3, 4, 5},
        1: {0, 1, 4, 5},
        2: {0, 1, 2, 3}
    }
    _draw_bipartite(ax, worlds, 6)
    
    # Family 3: Product of two level-2 families
    ax = axes[2]
    ax.set_title("Product Family (Level 2+2=4)", fontsize=12, fontweight='bold')
    worlds = {
        (0,0): {0, 1, 4, 5},
        (0,1): {0, 1, 6, 7},
        (1,0): {2, 3, 4, 5},
        (1,1): {2, 3, 6, 7}
    }
    _draw_bipartite(ax, worlds, 8)
    
    plt.tight_layout()
    plt.savefig('dark_families_structure.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dark_families_structure.png")


def _draw_bipartite(ax, worlds, N):
    """Draw bipartite incidence diagram for a dark family."""
    m = len(worlds)
    world_keys = list(worlds.keys())
    
    # Position worlds on the left, elements on the right
    world_y = np.linspace(0.9, 0.1, m)
    elem_y = np.linspace(0.9, 0.1, N)
    
    # Draw edges
    for i, (w, wset) in enumerate(worlds.items()):
        for n in wset:
            ax.plot([0.2, 0.8], [world_y[i], elem_y[n]], 
                    color='steelblue', alpha=0.3, linewidth=1)
    
    # Draw world nodes
    for i, w in enumerate(world_keys):
        ax.scatter([0.2], [world_y[i]], s=200, c='darkred', zorder=5)
        ax.text(0.08, world_y[i], f"W{w}", ha='center', va='center', fontsize=9)
    
    # Draw element nodes - color by spectrum size
    for n in range(N):
        spec_size = sum(1 for wset in worlds.values() if n in wset)
        color = plt.cm.YlOrRd(spec_size / m) if spec_size > 0 else 'lightgray'
        ax.scatter([0.8], [elem_y[n]], s=150, c=[color], zorder=5, edgecolors='black', linewidth=0.5)
        ax.text(0.92, elem_y[n], str(n), ha='center', va='center', fontsize=8)
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')


def plot_dark_inequality():
    """Plot the Dark Inequality bound surface."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    N_values = np.arange(2, 51)
    
    for m in [2, 3, 4, 5, 10]:
        max_levels = [N * (m - 1) / m for N in N_values]
        ax.plot(N_values, max_levels, linewidth=2, label=f'm = {m} worlds')
    
    ax.set_xlabel('Universe size N', fontsize=12)
    ax.set_ylabel('Maximum darkness level k', fontsize=12)
    ax.set_title('Dark Inequality: Maximum Achievable Darkness Level\n'
                 r'$k \leq N \cdot (m-1)/m$', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(2, 50)
    ax.set_ylim(0, 50)
    
    # Add annotation
    ax.annotate('Asymptote: k → N\nas m → ∞', xy=(40, 39), fontsize=10,
                ha='center', style='italic', color='gray')
    
    plt.tight_layout()
    plt.savefig('dark_inequality.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dark_inequality.png")


def plot_spectrum_distribution():
    """Plot spectrum size distributions for various dark families."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 4))
    
    configs = [
        (3, 12, "Extremal (m=3, N=12)"),
        (4, 20, "Extremal (m=4, N=20)"),
        (5, 25, "Extremal (m=5, N=25)")
    ]
    
    for ax, (m, N, title) in zip(axes, configs):
        q = N // m
        # Complementary block partition
        spectrum_sizes = []
        for n in range(N):
            block = n // q
            spec_size = m - 1  # n is in all worlds except world `block`
            spectrum_sizes.append(spec_size)
        
        ax.hist(spectrum_sizes, bins=range(m + 1), align='left', 
                color='steelblue', edgecolor='black', alpha=0.7, rwidth=0.8)
        ax.set_xlabel('Spectrum size', fontsize=10)
        ax.set_ylabel('Count', fontsize=10)
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.set_xticks(range(m))
        
        # Annotate: all spectra have size m-1
        ax.text(0.95, 0.95, f'All = {m-1}\n(extremal!)', 
                transform=ax.transAxes, ha='right', va='top',
                fontsize=10, color='darkred', fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
    
    plt.suptitle('Darkness Spectrum Distribution: Extremal Families Have Uniform Spectra',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('spectrum_distribution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: spectrum_distribution.png")


if __name__ == "__main__":
    plot_dark_family_structure()
    plot_dark_inequality()
    plot_spectrum_distribution()
    print("All visualizations generated.")
