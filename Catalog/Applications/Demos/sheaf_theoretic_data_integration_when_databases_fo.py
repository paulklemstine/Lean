#!/usr/bin/env python3
"""
Sheaf-Theoretic Data Integration: Consistency Nerve Demo

Demonstrates the key concepts:
1. Partial databases as sheaf sections
2. Consistency checking (the sheaf condition)
3. The Consistency Nerve — simplicial complex of consistent subfamilies
4. Defect spectrum — how approximate consistency evolves with tolerance
5. Gluing of consistent databases
"""

import numpy as np
from itertools import combinations
from typing import Optional


def create_partial_db(nR: int, nC: int, missing_rate: float = 0.3,
                      n_values: int = 5, seed: int = None) -> np.ndarray:
    """Create a partial database with missing entries (encoded as -1)."""
    rng = np.random.default_rng(seed)
    db = rng.integers(0, n_values, size=(nR, nC))
    mask = rng.random(size=(nR, nC)) < missing_rate
    db[mask] = -1  # -1 = missing
    return db


def pairwise_disagreement(db1: np.ndarray, db2: np.ndarray) -> int:
    """Count positions where both are defined and disagree."""
    both_defined = (db1 >= 0) & (db2 >= 0)
    return int(np.sum((db1 != db2) & both_defined))


def is_consistent(db1: np.ndarray, db2: np.ndarray) -> bool:
    """Check if two partial databases are consistent (agree on overlap)."""
    return pairwise_disagreement(db1, db2) == 0


def glue(db1: np.ndarray, db2: np.ndarray) -> np.ndarray:
    """Glue two partial databases (prefer db1 where defined)."""
    result = db1.copy()
    missing_in_1 = db1 < 0
    result[missing_in_1] = db2[missing_in_1]
    return result


def consistency_nerve_faces(dbs: list) -> list:
    """Compute all faces of the consistency nerve."""
    n = len(dbs)
    faces = [frozenset()]  # empty face
    for k in range(1, n + 1):
        for subset in combinations(range(n), k):
            s = frozenset(subset)
            is_face = True
            for i, j in combinations(subset, 2):
                if not is_consistent(dbs[i], dbs[j]):
                    is_face = False
                    break
            if is_face:
                faces.append(s)
    return faces


def consistency_rank(dbs: list) -> int:
    """Compute the consistency rank (max face size)."""
    faces = consistency_nerve_faces(dbs)
    return max(len(f) for f in faces)


def defect_spectrum(dbs: list, max_threshold: int = 10) -> list:
    """
    Compute the defect spectrum: for each threshold t,
    count the number of pairs with disagreement ≤ t.
    """
    n = len(dbs)
    spectrum = []
    total_pairs = n * (n - 1) // 2
    for t in range(max_threshold + 1):
        count = 0
        for i, j in combinations(range(n), 2):
            if pairwise_disagreement(dbs[i], dbs[j]) <= t:
                count += 1
        spectrum.append((t, count, total_pairs))
    return spectrum


def coverage(db: np.ndarray) -> int:
    """Count the number of defined (non-missing) entries."""
    return int(np.sum(db >= 0))


def demo_consistency_nerve():
    """Main demo: construct databases and analyze their consistency nerve."""
    print("=" * 70)
    print("CONSISTENCY NERVE OF DATA SHEAVES — DEMONSTRATION")
    print("=" * 70)
    
    nR, nC = 5, 4
    print(f"\nDatabase grid: {nR} rows × {nC} columns")
    print(f"Total positions: {nR * nC}")
    
    # Create a "ground truth" global section
    rng = np.random.default_rng(42)
    ground_truth = rng.integers(0, 5, size=(nR, nC))
    print(f"\nGround truth (global section):")
    print(ground_truth)
    
    # Create consistent partial databases by restricting ground truth
    print("\n--- Consistent Family (from ground truth restriction) ---")
    masks = [
        rng.random(size=(nR, nC)) < 0.4 for _ in range(4)
    ]
    consistent_dbs = []
    for i, mask in enumerate(masks):
        db = ground_truth.copy()
        db[mask] = -1
        consistent_dbs.append(db)
        print(f"\nDB {i} (coverage = {coverage(db)}/{nR*nC}):")
        print(db)
    
    rank = consistency_rank(consistent_dbs)
    print(f"\nConsistency Rank: {rank} (should equal {len(consistent_dbs)} for sheaf condition)")
    
    faces = consistency_nerve_faces(consistent_dbs)
    print(f"Nerve faces: {len(faces)} total")
    max_face = max(faces, key=len)
    print(f"Maximum face: {set(max_face)} (size {len(max_face)})")
    
    is_sheaf = rank == len(consistent_dbs)
    print(f"Sheaf condition satisfied: {is_sheaf}")
    
    # Demonstrate gluing
    if len(consistent_dbs) >= 2:
        glued = glue(consistent_dbs[0], consistent_dbs[1])
        print(f"\nGluing DB 0 + DB 1 (coverage: {coverage(consistent_dbs[0])} + "
              f"{coverage(consistent_dbs[1])} → {coverage(glued)}):")
        print(glued)
    
    # Create an inconsistent family
    print("\n\n--- Inconsistent Family (independent random) ---")
    inconsistent_dbs = [
        create_partial_db(nR, nC, missing_rate=0.2, seed=i+100)
        for i in range(5)
    ]
    
    rank2 = consistency_rank(inconsistent_dbs)
    print(f"Consistency Rank: {rank2} (out of {len(inconsistent_dbs)})")
    
    faces2 = consistency_nerve_faces(inconsistent_dbs)
    face_sizes = {}
    for f in faces2:
        k = len(f)
        face_sizes[k] = face_sizes.get(k, 0) + 1
    print(f"Face count by dimension: {dict(sorted(face_sizes.items()))}")
    
    # Defect spectrum
    print("\n--- Defect Spectrum ---")
    spectrum = defect_spectrum(inconsistent_dbs, max_threshold=8)
    print(f"{'Threshold':>10} | {'Approx-edges':>12} | {'Total pairs':>11} | {'Fraction':>8}")
    print("-" * 50)
    for t, count, total in spectrum:
        frac = count / total if total > 0 else 0
        print(f"{t:>10} | {count:>12} | {total:>11} | {frac:>8.3f}")
    
    # Exponential decay experiment
    print("\n\n--- Exponential Consistency Decay Experiment ---")
    print(f"{'n_dbs':>6} | {'n_cols':>6} | {'n_rows':>6} | {'miss_rate':>9} | "
          f"{'rank':>5} | {'is_sheaf':>8}")
    print("-" * 60)
    
    for n_dbs in [3, 5, 8, 12]:
        for n_cols in [3, 5, 10]:
            dbs = [
                create_partial_db(20, n_cols, missing_rate=0.3, seed=i*100+n_cols)
                for i in range(n_dbs)
            ]
            r = consistency_rank(dbs)
            sh = r == n_dbs
            print(f"{n_dbs:>6} | {n_cols:>6} | {20:>6} | {0.3:>9.1f} | "
                  f"{r:>5} | {str(sh):>8}")
    
    # Constraint superlinear growth
    print("\n\n--- Constraint Count Growth ---")
    print(f"{'n':>4} | {'n*(n-1)/2':>10} | {'superlinear':>11}")
    print("-" * 30)
    for n in range(2, 15):
        c = n * (n - 1) // 2
        print(f"{n:>4} | {c:>10} | {str(c > n):>11}")


def demo_projection():
    """Demonstrate that projection preserves consistency."""
    print("\n\n" + "=" * 70)
    print("PROJECTION PRESERVES CONSISTENCY")
    print("=" * 70)
    
    nR, nC = 4, 6
    rng = np.random.default_rng(99)
    ground_truth = rng.integers(0, 3, size=(nR, nC))
    
    db1 = ground_truth.copy()
    db1[rng.random(size=(nR, nC)) < 0.3] = -1
    db2 = ground_truth.copy()
    db2[rng.random(size=(nR, nC)) < 0.3] = -1
    
    print(f"DB1 (coverage {coverage(db1)}):\n{db1}")
    print(f"DB2 (coverage {coverage(db2)}):\n{db2}")
    print(f"Consistent: {is_consistent(db1, db2)}")
    
    # Project to first 3 columns
    cols = [0, 1, 2]
    db1_proj = db1[:, cols]
    db2_proj = db2[:, cols]
    
    print(f"\nProjected to columns {cols}:")
    print(f"DB1_proj:\n{db1_proj}")
    print(f"DB2_proj:\n{db2_proj}")
    print(f"Still consistent: {is_consistent(db1_proj, db2_proj)}")
    
    d_full = pairwise_disagreement(db1, db2)
    d_proj = pairwise_disagreement(db1_proj, db2_proj)
    print(f"Disagreement: full={d_full}, projected={d_proj}")
    print(f"Projection reduces disagreement: {d_proj <= d_full}")


if __name__ == "__main__":
    demo_consistency_nerve()
    demo_projection()
    print("\n\n✓ All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
Visualization 2: Exponential Consistency Decay
Shows how the probability of database consistency decays
exponentially with the number of overlap constraints.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def consistency_probability(r: float, C: int) -> float:
    """P(consistent) = (1-r)^C"""
    return (1 - r) ** C


def constraint_count(n: int) -> int:
    """Number of pairwise constraints: n*(n-1)/2"""
    return n * (n - 1) // 2


def simulate_consistency(n_dbs: int, nR: int, nC: int,
                         missing_rate: float, n_values: int,
                         n_trials: int = 1000) -> float:
    """Empirically estimate the probability that n random databases
    are pairwise consistent."""
    rng = np.random.default_rng(42)
    consistent_count = 0

    for _ in range(n_trials):
        dbs = []
        for _ in range(n_dbs):
            db = rng.integers(0, n_values, size=(nR, nC))
            mask = rng.random(size=(nR, nC)) < missing_rate
            db[mask] = -1
            dbs.append(db)

        all_consistent = True
        for i, j in combinations(range(n_dbs), 2):
            both_defined = (dbs[i] >= 0) & (dbs[j] >= 0)
            if np.any((dbs[i] != dbs[j]) & both_defined):
                all_consistent = False
                break

        if all_consistent:
            consistent_count += 1

    return consistent_count / n_trials


def plot_exponential_decay():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Theoretical decay curves
    ax = axes[0]
    constraints = np.arange(0, 50)

    for r in [0.05, 0.1, 0.2, 0.3, 0.5]:
        probs = [(1 - r) ** c for c in constraints]
        ax.plot(constraints, probs, '-', linewidth=2, label=f'r = {r}')

    ax.set_xlabel('Number of constraints C', fontsize=12)
    ax.set_ylabel('P(consistent) = (1-r)^C', fontsize=12)
    ax.set_title('Exponential Consistency Decay\n(Theoretical)', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_yscale('log')
    ax.set_ylim(1e-10, 1.5)
    ax.grid(True, alpha=0.3)

    # Panel 2: Empirical vs theoretical
    ax = axes[1]

    n_values_list = [2, 3, 5]
    colors = ['royalblue', 'darkorange', 'forestgreen']
    nR, nC = 3, 3
    missing_rate = 0.3

    for n_val, color in zip(n_values_list, colors):
        empirical_probs = []
        n_range = range(2, 7)
        for n_dbs in n_range:
            p = simulate_consistency(n_dbs, nR, nC, missing_rate,
                                     n_val, n_trials=2000)
            empirical_probs.append(p)

        ax.plot(list(n_range), empirical_probs, 'o-', color=color,
                linewidth=2, markersize=8,
                label=f'|V|={n_val} (empirical)')

    ax.set_xlabel('Number of databases n', fontsize=12)
    ax.set_ylabel('P(all pairwise consistent)', fontsize=12)
    ax.set_title(f'Empirical Decay ({nR}×{nC} grid, r={missing_rate})',
                 fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Consistency Probability Vanishes Exponentially',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/exponential_decay.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: exponential_decay.png")


def plot_constraint_growth():
    fig, ax = plt.subplots(figsize=(8, 5))

    ns = np.arange(2, 20)
    linear = ns
    quadratic = ns * (ns - 1) // 2

    ax.plot(ns, linear, 's-', color='steelblue', markersize=6,
            label='n (linear)', linewidth=2)
    ax.plot(ns, quadratic, 'o-', color='crimson', markersize=6,
            label='n(n-1)/2 (constraints)', linewidth=2)

    # Shade the superlinear region
    mask = quadratic > linear
    ax.fill_between(ns[mask], linear[mask], quadratic[mask],
                    alpha=0.15, color='red',
                    label='Superlinear gap (n ≥ 4)')

    ax.set_xlabel('Number of databases n', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Constraint Count Grows Superlinearly\n(Proved: n*(n-1)/2 > n for n ≥ 4)',
                 fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/constraint_growth.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: constraint_growth.png")


if __name__ == "__main__":
    plot_exponential_decay()
    plot_constraint_growth()


#!/usr/bin/env python3
"""
Visualization 1: The Consistency Nerve
Shows the simplicial complex structure of database consistency.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from itertools import combinations
from typing import List, Set, FrozenSet, Tuple


def create_partial_db(nR: int, nC: int, missing_rate: float,
                      seed: int, ground_truth: np.ndarray = None) -> np.ndarray:
    rng = np.random.default_rng(seed)
    if ground_truth is None:
        db = rng.integers(0, 5, size=(nR, nC))
    else:
        db = ground_truth.copy()
    mask = rng.random(size=(nR, nC)) < missing_rate
    db[mask] = -1
    return db


def pairwise_disagreement(db1: np.ndarray, db2: np.ndarray) -> int:
    both_defined = (db1 >= 0) & (db2 >= 0)
    return int(np.sum((db1 != db2) & both_defined))


def is_consistent(db1: np.ndarray, db2: np.ndarray) -> bool:
    return pairwise_disagreement(db1, db2) == 0


def consistency_nerve_faces(dbs: list) -> list:
    n = len(dbs)
    faces = [frozenset()]
    for k in range(1, n + 1):
        for subset in combinations(range(n), k):
            s = frozenset(subset)
            ok = True
            for i, j in combinations(subset, 2):
                if not is_consistent(dbs[i], dbs[j]):
                    ok = False
                    break
            if ok:
                faces.append(s)
    return faces


def plot_consistency_nerve():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    nR, nC = 5, 4
    rng = np.random.default_rng(42)
    ground_truth = rng.integers(0, 5, size=(nR, nC))

    # Panel 1: Consistent family (from ground truth)
    consistent_dbs = [
        create_partial_db(nR, nC, 0.4, seed=i, ground_truth=ground_truth)
        for i in range(5)
    ]

    n = len(consistent_dbs)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    positions = [(np.cos(a), np.sin(a)) for a in angles]

    ax = axes[0]
    ax.set_title("Consistent Family\n(Nerve = Complete Simplex)", fontsize=13)

    # Draw all triangles (2-faces) in light blue
    faces = consistency_nerve_faces(consistent_dbs)
    for face in faces:
        if len(face) == 3:
            pts = [positions[i] for i in sorted(face)]
            triangle = plt.Polygon(pts, alpha=0.15, color='royalblue')
            ax.add_patch(triangle)

    # Draw edges
    for face in faces:
        if len(face) == 2:
            i, j = sorted(face)
            ax.plot([positions[i][0], positions[j][0]],
                    [positions[i][1], positions[j][1]],
                    'b-', linewidth=2, alpha=0.6)

    # Draw vertices
    for i, (x, y) in enumerate(positions):
        ax.plot(x, y, 'o', markersize=15, color='darkblue', zorder=5)
        ax.text(x, y, f'DB{i}', ha='center', va='center',
                fontsize=8, color='white', fontweight='bold', zorder=6)

    rank = max(len(f) for f in faces)
    ax.text(0, -1.4, f"Rank = {rank} = n ⟹ Sheaf ✓",
            ha='center', fontsize=11, color='green', fontweight='bold')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.6, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    # Panel 2: Inconsistent family (random)
    inconsistent_dbs = [
        create_partial_db(nR, nC, 0.2, seed=i + 100)
        for i in range(5)
    ]

    ax = axes[1]
    ax.set_title("Inconsistent Family\n(Nerve ≠ Complete Simplex)", fontsize=13)

    faces2 = consistency_nerve_faces(inconsistent_dbs)

    for face in faces2:
        if len(face) == 3:
            pts = [positions[i] for i in sorted(face)]
            triangle = plt.Polygon(pts, alpha=0.15, color='coral')
            ax.add_patch(triangle)

    for i, j in combinations(range(n), 2):
        if is_consistent(inconsistent_dbs[i], inconsistent_dbs[j]):
            ax.plot([positions[i][0], positions[j][0]],
                    [positions[i][1], positions[j][1]],
                    'r-', linewidth=2, alpha=0.6)
        else:
            ax.plot([positions[i][0], positions[j][0]],
                    [positions[i][1], positions[j][1]],
                    '--', color='gray', linewidth=1, alpha=0.3)

    for i, (x, y) in enumerate(positions):
        ax.plot(x, y, 'o', markersize=15, color='darkred', zorder=5)
        ax.text(x, y, f'DB{i}', ha='center', va='center',
                fontsize=8, color='white', fontweight='bold', zorder=6)

    rank2 = max(len(f) for f in faces2)
    ax.text(0, -1.4, f"Rank = {rank2} < {n} ⟹ Sheaf ✗",
            ha='center', fontsize=11, color='red', fontweight='bold')

    ax.set_xlim(-1.5, 1.5)
    ax.set_ylim(-1.6, 1.5)
    ax.set_aspect('equal')
    ax.axis('off')

    plt.suptitle("The Consistency Nerve: Simplicial Complex of Database Families",
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/consistency_nerve.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: consistency_nerve.png")


def plot_defect_spectrum():
    fig, ax = plt.subplots(figsize=(10, 6))

    nR, nC = 8, 6
    n_dbs = 8
    dbs = [create_partial_db(nR, nC, 0.25, seed=i + 200)
           for i in range(n_dbs)]

    total_pairs = n_dbs * (n_dbs - 1) // 2
    max_t = 15

    thresholds = list(range(max_t + 1))
    edge_counts = []
    for t in thresholds:
        count = 0
        for i, j in combinations(range(n_dbs), 2):
            if pairwise_disagreement(dbs[i], dbs[j]) <= t:
                count += 1
        edge_counts.append(count)

    fractions = [c / total_pairs for c in edge_counts]

    ax.bar(thresholds, fractions, color='steelblue', alpha=0.8, edgecolor='navy')
    ax.axhline(y=1.0, color='green', linestyle='--', alpha=0.5,
               label='Complete graph (sheaf condition)')
    ax.set_xlabel('Tolerance threshold t', fontsize=12)
    ax.set_ylabel('Fraction of t-consistent pairs', fontsize=12)
    ax.set_title('Defect Spectrum: How Consistency Emerges with Tolerance',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.set_ylim(0, 1.1)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/defect_spectrum.png',
                dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: defect_spectrum.png")


if __name__ == "__main__":
    plot_consistency_nerve()
    plot_defect_spectrum()
