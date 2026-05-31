"""
Demo: Protein Folding as Persistent Homology Optimization

Demonstrates the topological energy framework by:
1. Generating a synthetic protein-like configuration (helix)
2. Computing its total persistence (H0 barcode)
3. Generating decoy configurations
4. Comparing topological energy of native vs decoy folds
5. Testing the topological folding conjecture
"""

import numpy as np
from algorithms import (
    PersistenceInterval,
    PersistenceBarcode,
    compute_distance_matrix,
    compute_h0_barcode,
    total_persistence_energy,
    ultrametric_defect,
    generate_decoy,
    test_topological_folding_conjecture,
)


def generate_helix(n: int, radius: float = 2.3, pitch: float = 5.4) -> np.ndarray:
    """Generate an alpha-helix-like configuration.

    Args:
        n: Number of residues.
        radius: Helix radius in Angstroms.
        pitch: Rise per turn in Angstroms.

    Returns:
        (n, 3) array of coordinates.
    """
    # Alpha helix: 3.6 residues per turn, 1.5 Å rise per residue
    rise_per_residue = pitch / 3.6
    angle_per_residue = 2 * np.pi / 3.6

    coords = np.zeros((n, 3))
    for i in range(n):
        theta = i * angle_per_residue
        coords[i] = [
            radius * np.cos(theta),
            radius * np.sin(theta),
            i * rise_per_residue,
        ]
    return coords


def generate_sheet(n: int, strand_length: int = 10) -> np.ndarray:
    """Generate a beta-sheet-like configuration.

    Args:
        n: Number of residues.
        strand_length: Number of residues per strand.

    Returns:
        (n, 3) array of coordinates.
    """
    coords = np.zeros((n, 3))
    strand = 0
    pos_in_strand = 0

    for i in range(n):
        x = pos_in_strand * 3.5  # 3.5 Å between residues in a strand
        if strand % 2 == 1:
            x = (strand_length - 1 - pos_in_strand) * 3.5  # Antiparallel
        y = strand * 4.8  # 4.8 Å between strands
        z = 0.0

        coords[i] = [x, y, z]

        pos_in_strand += 1
        if pos_in_strand >= strand_length:
            pos_in_strand = 0
            strand += 1

    return coords


def generate_random_coil(n: int, bond_length: float = 3.8) -> np.ndarray:
    """Generate a random coil (unfolded) configuration.

    Args:
        n: Number of residues.
        bond_length: Distance between consecutive residues.

    Returns:
        (n, 3) array of coordinates.
    """
    coords = np.zeros((n, 3))
    for i in range(1, n):
        # Random direction on unit sphere
        direction = np.random.randn(3)
        direction /= np.linalg.norm(direction)
        coords[i] = coords[i - 1] + bond_length * direction
    return coords


def demo_barcode_properties():
    """Demonstrate basic barcode properties."""
    print("=" * 60)
    print("§1. Barcode Properties")
    print("=" * 60)

    # Empty barcode
    empty = PersistenceBarcode([])
    print(f"Empty barcode: TP = {empty.total_persistence} (should be 0)")

    # Single interval
    single = PersistenceBarcode([PersistenceInterval(1.0, 3.0)])
    print(f"Single [1,3): TP = {single.total_persistence} (should be 2)")

    # Multiple intervals
    multi = PersistenceBarcode([
        PersistenceInterval(0.0, 2.0),
        PersistenceInterval(1.0, 4.0),
        PersistenceInterval(0.5, 1.5),
    ])
    print(f"Three intervals: TP = {multi.total_persistence} (should be 6)")
    print(f"  Entropy = {multi.persistent_entropy():.4f}")

    # Merge property
    b1, d1, d2 = 1.0, 3.0, 5.0
    merged = (d1 - b1) + (d2 - d1)
    direct = d2 - b1
    print(f"\nMerge: ({d1}-{b1}) + ({d2}-{d1}) = {merged} = {direct} = {d2}-{b1}")

    # Split property
    b, m, d = 1.0, 2.5, 4.0
    split = (m - b) + (d - m)
    print(f"Split: ({m}-{b}) + ({d}-{m}) = {split} = {d - b}")

    # Nesting inequality
    b1, d1 = 2.0, 3.0  # Inner: lifetime = 1
    b2, d2 = 1.0, 4.0  # Outer: lifetime = 3
    print(f"\nNesting: inner [{b1},{d1}) lifetime = {d1-b1}, "
          f"outer [{b2},{d2}) lifetime = {d2-b2}")
    print(f"  Inner < Outer: {d1-b1 < d2-b2}")
    print()


def demo_contact_filtration():
    """Demonstrate contact filtration monotonicity."""
    print("=" * 60)
    print("§2. Contact Filtration Monotonicity")
    print("=" * 60)

    n = 20
    helix = generate_helix(n)
    D = compute_distance_matrix(helix)

    thresholds = [2.0, 4.0, 6.0, 8.0, 10.0, 15.0, 20.0]
    prev_count = 0

    print(f"Helix with {n} residues:")
    print(f"{'Threshold':>10} {'Contacts':>10} {'Monotone':>10}")
    for eps in thresholds:
        contacts = sum(1 for i in range(n) for j in range(i+1, n) if D[i,j] <= eps)
        is_mono = "✓" if contacts >= prev_count else "✗"
        print(f"{eps:10.1f} {contacts:10d} {is_mono:>10}")
        prev_count = contacts
    print()


def demo_topological_energy():
    """Compare topological energy of different fold types."""
    print("=" * 60)
    print("§3. Topological Energy Comparison")
    print("=" * 60)

    n = 30
    np.random.seed(42)

    configs = {
        "Alpha helix": generate_helix(n),
        "Beta sheet": generate_sheet(n),
        "Random coil 1": generate_random_coil(n),
        "Random coil 2": generate_random_coil(n),
        "Random coil 3": generate_random_coil(n),
    }

    print(f"Comparing {n}-residue configurations:")
    print(f"{'Configuration':>15} {'TP (H0)':>10} {'Features':>10} {'U-defect':>10}")

    for name, coords in configs.items():
        D = compute_distance_matrix(coords)
        barcode = compute_h0_barcode(D)
        tp = barcode.total_persistence
        n_feat = barcode.num_features
        u_def = ultrametric_defect(D)
        print(f"{name:>15} {tp:10.2f} {n_feat:10d} {u_def:10.2f}")
    print()


def demo_stability():
    """Demonstrate distance matrix stability under perturbation."""
    print("=" * 60)
    print("§4. Distance Matrix Stability (Theorem G)")
    print("=" * 60)

    n = 20
    helix = generate_helix(n)

    perturbation_sizes = [0.1, 0.5, 1.0, 2.0, 5.0]

    print(f"{'δ (perturb)':>12} {'max|ΔD|':>10} {'2δ bound':>10} {'Satisfied':>10}")

    for delta in perturbation_sizes:
        perturbed = helix + np.random.randn(n, 3) * delta

        D1 = compute_distance_matrix(helix)
        D2 = compute_distance_matrix(perturbed)

        max_diff = np.max(np.abs(D1 - D2))
        config_dist = max(np.linalg.norm(helix[i] - perturbed[i]) for i in range(n))
        bound = 2 * config_dist

        satisfied = "✓" if max_diff <= bound + 1e-10 else "✗"
        print(f"{delta:12.1f} {max_diff:10.4f} {bound:10.4f} {satisfied:>10}")
    print()


def demo_conjecture_test():
    """Test the topological folding conjecture on a synthetic protein."""
    print("=" * 60)
    print("§5. Topological Folding Conjecture Test")
    print("=" * 60)

    np.random.seed(42)
    n = 25
    native = generate_helix(n)

    print(f"Testing conjecture on {n}-residue helix...")
    print(f"Generating 50 decoy configurations...\n")

    results = test_topological_folding_conjecture(
        native,
        n_decoys=50,
        bond_length=5.0,
        perturbation_std=3.0,
    )

    print(f"Native fold TP:      {results['native_total_persistence']:.4f}")
    print(f"Decoys generated:    {results['n_decoys_generated']}")
    print(f"Decoys with lower TP:{results['n_decoys_lower_tp']}")
    print(f"Conjecture holds:    {results['conjecture_holds']}")
    print(f"Native rank:         {results['native_rank']} / {results['n_decoys_generated'] + 1}")
    print(f"Native percentile:   {results['native_percentile']:.1f}%")
    print(f"Decoy TP mean ± std: {results['decoy_tp_mean']:.4f} ± {results['decoy_tp_std']:.4f}")
    print(f"Decoy TP range:      [{results['decoy_tp_min']:.4f}, {results['decoy_tp_max']:.4f}]")
    print()


def demo_lower_bound():
    """Demonstrate the total persistence lower bound (Theorem F)."""
    print("=" * 60)
    print("§6. Total Persistence Lower Bound (Theorem F)")
    print("=" * 60)

    n = 30
    helix = generate_helix(n)
    D = compute_distance_matrix(helix)
    barcode = compute_h0_barcode(D)

    tp = barcode.total_persistence
    k = barcode.num_features

    if k > 0:
        min_lifetime = min(I.lifetime for I in barcode.intervals)
        lower_bound = k * min_lifetime

        print(f"Barcode has {k} intervals")
        print(f"Minimum lifetime δ = {min_lifetime:.4f}")
        print(f"Lower bound k*δ = {lower_bound:.4f}")
        print(f"Actual TP = {tp:.4f}")
        print(f"Bound satisfied: {lower_bound <= tp + 1e-10}")
    else:
        print("No finite intervals in barcode")
    print()


if __name__ == "__main__":
    print("╔════════════════════════════════════════════════════════╗")
    print("║  Protein Folding as Persistent Homology Optimization  ║")
    print("║                    Demo Suite                         ║")
    print("╚════════════════════════════════════════════════════════╝")
    print()

    demo_barcode_properties()
    demo_contact_filtration()
    demo_topological_energy()
    demo_stability()
    demo_conjecture_test()
    demo_lower_bound()

    print("Demo complete.")


"""
Visualization: Persistence barcode and total persistence comparison.

Generates a figure comparing the topological energy of different protein
fold types (helix, sheet, random coil).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch


def compute_distance_matrix(points):
    n = len(points)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(points[i] - points[j])
            D[i, j] = d
            D[j, i] = d
    return D


def compute_h0_barcode(distance_matrix):
    n = len(distance_matrix)
    parent = list(range(n))
    rank_uf = [0] * n

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return None
        if rank_uf[rx] < rank_uf[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank_uf[rx] == rank_uf[ry]:
            rank_uf[rx] += 1
        return ry

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((distance_matrix[i, j], i, j))
    edges.sort()

    intervals = []
    for dist, i, j in edges:
        dead = union(i, j)
        if dead is not None:
            intervals.append((0.0, dist))
    return intervals


def generate_helix(n, radius=2.3, pitch=5.4):
    rise = pitch / 3.6
    angle = 2 * np.pi / 3.6
    coords = np.zeros((n, 3))
    for i in range(n):
        theta = i * angle
        coords[i] = [radius * np.cos(theta), radius * np.sin(theta), i * rise]
    return coords


def generate_random_coil(n, bond_length=3.8):
    coords = np.zeros((n, 3))
    for i in range(1, n):
        direction = np.random.randn(3)
        direction /= np.linalg.norm(direction)
        coords[i] = coords[i - 1] + bond_length * direction
    return coords


def main():
    np.random.seed(42)
    n = 30

    helix = generate_helix(n)
    coils = [generate_random_coil(n) for _ in range(5)]

    helix_barcode = compute_h0_barcode(compute_distance_matrix(helix))
    coil_barcodes = [compute_h0_barcode(compute_distance_matrix(c)) for c in coils]

    helix_tp = sum(d - b for b, d in helix_barcode)
    coil_tps = [sum(d - b for b, d in bc) for bc in coil_barcodes]

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Barcode diagram for helix
    ax = axes[0]
    sorted_bars = sorted(helix_barcode, key=lambda x: x[1] - x[0], reverse=True)
    for i, (b, d) in enumerate(sorted_bars[:20]):
        ax.barh(i, d - b, left=b, height=0.7, color='steelblue', alpha=0.8)
    ax.set_xlabel('Filtration Value (Å)', fontsize=12)
    ax.set_ylabel('Feature Index', fontsize=12)
    ax.set_title(f'H₀ Barcode — Alpha Helix\nTP = {helix_tp:.1f}', fontsize=13)
    ax.invert_yaxis()

    # Panel 2: Barcode diagram for random coil
    ax = axes[1]
    sorted_bars = sorted(coil_barcodes[0], key=lambda x: x[1] - x[0], reverse=True)
    for i, (b, d) in enumerate(sorted_bars[:20]):
        ax.barh(i, d - b, left=b, height=0.7, color='coral', alpha=0.8)
    ax.set_xlabel('Filtration Value (Å)', fontsize=12)
    ax.set_title(f'H₀ Barcode — Random Coil\nTP = {coil_tps[0]:.1f}', fontsize=13)
    ax.invert_yaxis()

    # Panel 3: TP comparison
    ax = axes[2]
    labels = ['Helix'] + [f'Coil {i+1}' for i in range(len(coil_tps))]
    tps = [helix_tp] + coil_tps
    colors = ['steelblue'] + ['coral'] * len(coil_tps)
    bars = ax.bar(labels, tps, color=colors, alpha=0.8, edgecolor='gray')
    ax.set_ylabel('Total Persistence', fontsize=12)
    ax.set_title('Topological Energy Comparison', fontsize=13)
    ax.axhline(y=helix_tp, color='steelblue', linestyle='--', alpha=0.5, label='Native (helix)')
    ax.legend()

    for bar, tp in zip(bars, tps):
        ax.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 1,
                f'{tp:.0f}', ha='center', va='bottom', fontsize=9)

    plt.tight_layout()
    plt.savefig('persistence_comparison.png', dpi=150, bbox_inches='tight')
    print("Saved persistence_comparison.png")


if __name__ == "__main__":
    main()


"""
Visualization: Distance matrix stability under perturbation.

Demonstrates Theorem G: |d(C1,i,j) - d(C2,i,j)| <= 2 * configDist(C1, C2).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def compute_distance_matrix(points):
    n = len(points)
    D = np.zeros((n, n))
    for i in range(n):
        for j in range(i + 1, n):
            d = np.linalg.norm(points[i] - points[j])
            D[i, j] = d
            D[j, i] = d
    return D


def generate_helix(n, radius=2.3, pitch=5.4):
    rise = pitch / 3.6
    angle = 2 * np.pi / 3.6
    coords = np.zeros((n, 3))
    for i in range(n):
        theta = i * angle
        coords[i] = [radius * np.cos(theta), radius * np.sin(theta), i * rise]
    return coords


def main():
    np.random.seed(42)
    n = 25
    native = generate_helix(n)

    perturbation_sizes = np.linspace(0.01, 5.0, 50)
    max_diffs = []
    bounds = []
    config_dists = []

    for delta in perturbation_sizes:
        perturbed = native + np.random.randn(n, 3) * delta

        D1 = compute_distance_matrix(native)
        D2 = compute_distance_matrix(perturbed)

        max_diff = np.max(np.abs(D1 - D2))
        cd = max(np.linalg.norm(native[i] - perturbed[i]) for i in range(n))
        bound = 2 * cd

        max_diffs.append(max_diff)
        bounds.append(bound)
        config_dists.append(cd)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Panel 1: Stability bound
    ax = axes[0]
    ax.plot(config_dists, max_diffs, 'o', color='steelblue', alpha=0.6,
            markersize=5, label='max|ΔD[i,j]|')
    ax.plot(config_dists, bounds, '-', color='coral', linewidth=2,
            label='2·d∞(C₁,C₂) bound')
    ax.set_xlabel('Configuration Distance d∞(C₁, C₂)', fontsize=12)
    ax.set_ylabel('Maximum Distance Matrix Perturbation', fontsize=12)
    ax.set_title('Theorem G: Distance Matrix Stability', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 2: TP vs perturbation
    tps_native = []
    tps_perturbed = []

    for delta in np.linspace(0.1, 8.0, 40):
        perturbed = native + np.random.randn(n, 3) * delta

        D1 = compute_distance_matrix(native)
        D2 = compute_distance_matrix(perturbed)

        parent1 = list(range(n))
        rank1 = [0] * n

        def find1(x):
            while parent1[x] != x:
                parent1[x] = parent1[parent1[x]]
                x = parent1[x]
            return x

        def union1(x, y):
            rx, ry = find1(x), find1(y)
            if rx == ry:
                return None
            if rank1[rx] < rank1[ry]:
                rx, ry = ry, rx
            parent1[ry] = rx
            if rank1[rx] == rank1[ry]:
                rank1[rx] += 1
            return ry

        edges1 = sorted((D1[i,j], i, j) for i in range(n) for j in range(i+1, n))
        tp1 = sum(d for d, i, j in edges1 if union1(i, j) is not None)

        parent2 = list(range(n))
        rank2 = [0] * n

        def find2(x):
            while parent2[x] != x:
                parent2[x] = parent2[parent2[x]]
                x = parent2[x]
            return x

        def union2(x, y):
            rx, ry = find2(x), find2(y)
            if rx == ry:
                return None
            if rank2[rx] < rank2[ry]:
                rx, ry = ry, rx
            parent2[ry] = rx
            if rank2[rx] == rank2[ry]:
                rank2[rx] += 1
            return ry

        edges2 = sorted((D2[i,j], i, j) for i in range(n) for j in range(i+1, n))
        tp2 = sum(d for d, i, j in edges2 if union2(i, j) is not None)

        tps_native.append(tp1)
        tps_perturbed.append(tp2)

    ax = axes[1]
    deltas = np.linspace(0.1, 8.0, 40)
    ax.plot(deltas, tps_native, '-', color='steelblue', linewidth=2, label='Native TP')
    ax.plot(deltas, tps_perturbed, 'o-', color='coral', alpha=0.7,
            markersize=4, label='Perturbed TP')
    ax.set_xlabel('Perturbation Size δ', fontsize=12)
    ax.set_ylabel('Total Persistence', fontsize=12)
    ax.set_title('Total Persistence vs. Perturbation', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('stability_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved stability_analysis.png")


if __name__ == "__main__":
    main()
