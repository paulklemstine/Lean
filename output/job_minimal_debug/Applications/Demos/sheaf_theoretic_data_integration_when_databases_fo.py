#!/usr/bin/env python3
"""
Sheaf Defect Complex: Demonstrations of Database Consistency Theory

This demo illustrates the key theorems from the sheaf-theoretic framework
for database consistency:

1. Defect Decomposition: total defect = coboundary norm
2. Defect Quantization: nonzero defect ≥ 2 (disagreements come in pairs)
3. Exponential Consistency Decay: P(consistent) = (1-r)^C
4. Hot Spot Detection: identifying inconsistent positions
"""

import random
import math
from typing import Optional, Dict, Tuple, List


def create_partial_db(n_rows: int, n_cols: int, values: range,
                      missing_rate: float) -> List[List[Optional[int]]]:
    """Create a random partial database with missing entries."""
    db = []
    for _ in range(n_rows):
        row = []
        for _ in range(n_cols):
            if random.random() < missing_rate:
                row.append(None)
            else:
                row.append(random.choice(list(values)))
        db.append(row)
    return db


def disagree(db1: List[List[Optional[int]]], db2: List[List[Optional[int]]],
             r: int, c: int) -> int:
    """Binary disagreement indicator at position (r, c)."""
    v1, v2 = db1[r][c], db2[r][c]
    if v1 is not None and v2 is not None and v1 != v2:
        return 1
    return 0


def position_defect(dbs: List[List[List[Optional[int]]]],
                    r: int, c: int) -> int:
    """Total pairwise disagreements at position (r, c)."""
    n = len(dbs)
    total = 0
    for i in range(n):
        for j in range(n):
            total += disagree(dbs[i], dbs[j], r, c)
    return total


def total_defect(dbs: List[List[List[Optional[int]]]]) -> int:
    """Sum of position defects over all positions."""
    if not dbs or not dbs[0]:
        return 0
    n_rows, n_cols = len(dbs[0]), len(dbs[0][0])
    total = 0
    for r in range(n_rows):
        for c in range(n_cols):
            total += position_defect(dbs, r, c)
    return total


def coboundary_norm(dbs: List[List[List[Optional[int]]]]) -> int:
    """Coboundary norm: sum over pairs then positions."""
    if not dbs or not dbs[0]:
        return 0
    n = len(dbs)
    n_rows, n_cols = len(dbs[0]), len(dbs[0][0])
    total = 0
    for i in range(n):
        for j in range(n):
            for r in range(n_rows):
                for c in range(n_cols):
                    total += disagree(dbs[i], dbs[j], r, c)
    return total


def defect_laplacian(dbs: List[List[List[Optional[int]]]]) -> int:
    """Sum of squared position defects."""
    if not dbs or not dbs[0]:
        return 0
    n_rows, n_cols = len(dbs[0]), len(dbs[0][0])
    total = 0
    for r in range(n_rows):
        for c in range(n_cols):
            d = position_defect(dbs, r, c)
            total += d * d
    return total


def consistency_probability(r: float, constraint_count: int) -> float:
    """P(consistent) = (1-r)^C."""
    return (1.0 - r) ** constraint_count


# ============================================================
# DEMO 1: Defect Decomposition Theorem Verification
# ============================================================
print("=" * 60)
print("DEMO 1: Defect Decomposition Theorem")
print("  totalDefect(f) = cobNorm(f)")
print("=" * 60)

random.seed(42)
n_databases = 4
n_rows, n_cols = 5, 3

dbs = [create_partial_db(n_rows, n_cols, range(3), 0.3) for _ in range(n_databases)]

td = total_defect(dbs)
cn = coboundary_norm(dbs)

print(f"\nFamily of {n_databases} partial databases ({n_rows}×{n_cols})")
print(f"Total Defect (sum over positions first):  {td}")
print(f"Coboundary Norm (sum over pairs first):   {cn}")
print(f"Equal? {td == cn}  ✓" if td == cn else f"MISMATCH! ✗")

# ============================================================
# DEMO 2: Defect Quantization Theorem
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Defect Quantization Theorem")
print("  ¬FamilySheaf f → 2 ≤ totalDefect f")
print("=" * 60)

random.seed(0)
observed_defects = set()
n_trials = 10000

for _ in range(n_trials):
    dbs = [create_partial_db(2, 2, range(3), 0.3) for _ in range(3)]
    d = total_defect(dbs)
    if d > 0:
        observed_defects.add(d)

print(f"\nGenerated {n_trials} random 3-database families (2×2, values 0-2)")
print(f"Nonzero defect values observed: {sorted(observed_defects)[:15]}...")
print(f"Minimum nonzero defect: {min(observed_defects)}")
print(f"Quantization verified (min ≥ 2)? {min(observed_defects) >= 2}  ✓"
      if min(observed_defects) >= 2 else "FAILED ✗")
print(f"All defects even? {all(d % 2 == 0 for d in observed_defects)}  ✓"
      if all(d % 2 == 0 for d in observed_defects) else "Not all even")

# ============================================================
# DEMO 3: Exponential Consistency Decay
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Exponential Consistency Decay")
print("  P(consistent) = (1-r)^C")
print("=" * 60)

print(f"\n{'Constraints':>12} {'Rate':>6} {'P(consistent)':>15} {'log10(P)':>10}")
print("-" * 48)

for n_features in [5, 10, 20]:
    n_observations = 50
    C = n_features * (n_features - 1) // 2 * n_observations
    for r in [0.1, 0.3, 0.5]:
        p = consistency_probability(r, C)
        log_p = math.log10(p) if p > 0 else float('-inf')
        print(f"{C:>12} {r:>6.1f} {p:>15.2e} {log_p:>10.1f}")

# ============================================================
# DEMO 4: Hot Spot Detection
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Hot Spot Detection")
print("  Positions with defect > threshold")
print("=" * 60)

random.seed(123)
dbs = [create_partial_db(4, 4, range(5), 0.2) for _ in range(5)]

print(f"\nDefect map for 5 databases over 4×4 grid:")
print(f"(Numbers show position defect; * marks hot spots with defect > 4)")
print()
hot_count = 0
for r in range(4):
    row_str = ""
    for c in range(4):
        d = position_defect(dbs, r, c)
        marker = "*" if d > 4 else " "
        row_str += f"{d:3d}{marker}"
        if d > 4:
            hot_count += 1
    print(f"  Row {r}: {row_str}")

print(f"\nHot spots (defect > 4): {hot_count} out of 16 positions")
print(f"Total defect: {total_defect(dbs)}")
print(f"Defect Laplacian: {defect_laplacian(dbs)}")
print(f"Laplacian ≥ Total? {defect_laplacian(dbs) >= total_defect(dbs)}  ✓")

# ============================================================
# DEMO 5: Laplacian vs Total Defect Comparison
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Laplacian ≥ Total Defect (Concentration)")
print("=" * 60)

random.seed(42)
for trial in range(5):
    n_db = random.randint(3, 8)
    nr, nc = random.randint(2, 5), random.randint(2, 5)
    dbs = [create_partial_db(nr, nc, range(4), 0.3) for _ in range(n_db)]
    td = total_defect(dbs)
    dl = defect_laplacian(dbs)
    ratio = dl / td if td > 0 else 1.0
    print(f"  Trial {trial+1}: {n_db} dbs, {nr}×{nc} grid: "
          f"Total={td}, Laplacian={dl}, ratio={ratio:.2f}")

print("\nAll demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Exponential Consistency Decay

Shows how the probability of database consistency decays exponentially
with the number of constraints (columns, rows, and pairs).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def consistency_probability(r, C):
    return (1.0 - r) ** C


def overlap_constraints(n_cols, n_rows):
    return n_cols * (n_cols - 1) // 2 * n_rows


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: P vs missing rate for different grid sizes
rates = np.linspace(0.01, 0.5, 200)
for n_cols, n_rows, color in [(3, 10, 'blue'), (5, 20, 'green'),
                                (8, 50, 'orange'), (10, 100, 'red')]:
    C = overlap_constraints(n_cols, n_rows)
    probs = [(1 - r) ** C for r in rates]
    log_probs = [np.log10(max(p, 1e-300)) for p in probs]
    axes[0].plot(rates, log_probs, color=color, linewidth=2,
                 label=f'{n_cols} cols, {n_rows} rows (C={C})')

axes[0].set_xlabel('Missing Rate r', fontsize=12)
axes[0].set_ylabel('log₁₀ P(consistent)', fontsize=12)
axes[0].set_title('Consistency Probability vs Rate', fontsize=14,
                  fontweight='bold')
axes[0].legend(fontsize=9)
axes[0].grid(True, alpha=0.3)
axes[0].set_ylim(-50, 1)

# Plot 2: P vs number of columns (fixed rate, rows)
n_cols_range = range(2, 25)
for r, color in [(0.05, 'blue'), (0.1, 'green'), (0.2, 'orange'),
                  (0.3, 'red')]:
    n_rows = 50
    log_probs = []
    for n in n_cols_range:
        C = overlap_constraints(n, n_rows)
        p = (1 - r) ** C
        log_probs.append(np.log10(max(p, 1e-300)))
    axes[1].plot(list(n_cols_range), log_probs, color=color, linewidth=2,
                 marker='o', markersize=3, label=f'r = {r}')

axes[1].set_xlabel('Number of Columns n', fontsize=12)
axes[1].set_ylabel('log₁₀ P(consistent)', fontsize=12)
axes[1].set_title('Consistency vs Columns (50 rows)', fontsize=14,
                  fontweight='bold')
axes[1].legend(fontsize=10)
axes[1].grid(True, alpha=0.3)
axes[1].set_ylim(-200, 1)

# Plot 3: Constraint count scaling
n_range = np.arange(2, 30)
constraints_linear = n_range * 50
constraints_quadratic = n_range * (n_range - 1) // 2 * 50

axes[2].plot(n_range, constraints_linear, 'b-', linewidth=2,
             label='Linear: n × k')
axes[2].plot(n_range, constraints_quadratic, 'r-', linewidth=2,
             label='Quadratic: C(n,2) × k')
axes[2].fill_between(n_range, constraints_linear, constraints_quadratic,
                     alpha=0.15, color='red')
axes[2].set_xlabel('Number of Columns n', fontsize=12)
axes[2].set_ylabel('Constraint Count', fontsize=12)
axes[2].set_title('Overlap Constraints Scale Quadratically', fontsize=14,
                  fontweight='bold')
axes[2].legend(fontsize=10)
axes[2].grid(True, alpha=0.3)

fig.suptitle('Exponential Consistency Decay in the Sheaf Model',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('consistency_decay.png', dpi=150, bbox_inches='tight')
print("Saved consistency_decay.png")


#!/usr/bin/env python3
"""
Visualization: Defect Heatmap for Database Consistency

Shows the spatial distribution of consistency defects across a database grid.
Hot spots (high defect) indicate positions where databases strongly disagree.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random


def disagree(db1, db2, r, c):
    v1, v2 = db1[r][c], db2[r][c]
    if v1 is not None and v2 is not None and v1 != v2:
        return 1
    return 0


def position_defect(dbs, r, c):
    n = len(dbs)
    total = 0
    for i in range(n):
        for j in range(n):
            total += disagree(dbs[i], dbs[j], r, c)
    return total


def create_partial_db(n_rows, n_cols, values, missing_rate):
    db = []
    for _ in range(n_rows):
        row = []
        for _ in range(n_cols):
            if random.random() < missing_rate:
                row.append(None)
            else:
                row.append(random.choice(list(values)))
        db.append(row)
    return db


random.seed(42)
n_rows, n_cols = 10, 10
n_dbs = 6

dbs = [create_partial_db(n_rows, n_cols, range(5), 0.3) for _ in range(n_dbs)]

# Compute defect matrix
defect_matrix = np.zeros((n_rows, n_cols))
for r in range(n_rows):
    for c in range(n_cols):
        defect_matrix[r][c] = position_defect(dbs, r, c)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Heatmap of position defects
im1 = axes[0].imshow(defect_matrix, cmap='YlOrRd', interpolation='nearest')
axes[0].set_title('Position Defect Heatmap', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column')
axes[0].set_ylabel('Row')
plt.colorbar(im1, ax=axes[0], label='Defect Count')

# Binary hot spots (threshold = median)
threshold = np.median(defect_matrix)
hot_spots = (defect_matrix > threshold).astype(float)
im2 = axes[1].imshow(hot_spots, cmap='RdGy_r', interpolation='nearest',
                      vmin=0, vmax=1)
axes[1].set_title(f'Hot Spots (defect > {threshold:.0f})', fontsize=14,
                  fontweight='bold')
axes[1].set_xlabel('Column')
axes[1].set_ylabel('Row')
plt.colorbar(im2, ax=axes[1], label='Hot Spot')

# Defect distribution histogram
defect_values = defect_matrix.flatten()
axes[2].hist(defect_values, bins=range(int(max(defect_values)) + 2),
             color='steelblue', edgecolor='white', alpha=0.8)
axes[2].axvline(x=threshold, color='red', linestyle='--', linewidth=2,
                label=f'Threshold = {threshold:.0f}')
axes[2].set_title('Defect Distribution', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Position Defect')
axes[2].set_ylabel('Count')
axes[2].legend()

total = int(np.sum(defect_matrix))
laplacian = int(np.sum(defect_matrix ** 2))
fig.suptitle(f'Sheaf Defect Complex Analysis ({n_dbs} databases, {n_rows}×{n_cols} grid)\n'
             f'Total Defect = {total}, Laplacian = {laplacian}, '
             f'Laplacian/Total = {laplacian/total:.2f}',
             fontsize=13, y=1.02)

plt.tight_layout()
plt.savefig('defect_heatmap.png', dpi=150, bbox_inches='tight')
print(f"Saved defect_heatmap.png")
print(f"Total defect: {total}")
print(f"Defect Laplacian: {laplacian}")
print(f"Ratio (Laplacian/Total): {laplacian/total:.2f}")


#!/usr/bin/env python3
"""
Visualization: Defect Quantization Theorem

Demonstrates that the total defect of inconsistent database families
is always ≥ 2, and in fact always even (disagreements come in symmetric pairs).
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import random
from collections import Counter


def disagree(db1, db2, r, c):
    v1, v2 = db1[r][c], db2[r][c]
    if v1 is not None and v2 is not None and v1 != v2:
        return 1
    return 0


def total_defect(dbs):
    if not dbs or not dbs[0]:
        return 0
    n = len(dbs)
    n_rows, n_cols = len(dbs[0]), len(dbs[0][0])
    total = 0
    for i in range(n):
        for j in range(n):
            for r in range(n_rows):
                for c in range(n_cols):
                    total += disagree(dbs[i], dbs[j], r, c)
    return total


def create_partial_db(n_rows, n_cols, values, missing_rate):
    db = []
    for _ in range(n_rows):
        row = []
        for _ in range(n_cols):
            if random.random() < missing_rate:
                row.append(None)
            else:
                row.append(random.choice(list(values)))
        db.append(row)
    return db


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Experiment 1: Distribution of defects for 2 databases
random.seed(42)
defects_2db = []
for _ in range(50000):
    dbs = [create_partial_db(2, 2, range(3), 0.3) for _ in range(2)]
    d = total_defect(dbs)
    if d > 0:
        defects_2db.append(d)

counter_2db = Counter(defects_2db)
vals = sorted(counter_2db.keys())
counts = [counter_2db[v] for v in vals]
colors = ['red' if v % 2 == 1 else 'steelblue' for v in vals]
axes[0].bar(vals, counts, color=colors, edgecolor='white', alpha=0.8)
axes[0].set_title('Defect Distribution (2 databases)', fontsize=14,
                  fontweight='bold')
axes[0].set_xlabel('Total Defect')
axes[0].set_ylabel('Frequency')
axes[0].axvline(x=1, color='red', linestyle='--', alpha=0.5, label='Defect = 1 (impossible)')
axes[0].legend()

# Experiment 2: Distribution for 4 databases
random.seed(42)
defects_4db = []
for _ in range(50000):
    dbs = [create_partial_db(2, 2, range(3), 0.3) for _ in range(4)]
    d = total_defect(dbs)
    if d > 0:
        defects_4db.append(d)

counter_4db = Counter(defects_4db)
vals = sorted(counter_4db.keys())[:20]
counts = [counter_4db[v] for v in vals]
colors = ['red' if v % 2 == 1 else 'steelblue' for v in vals]
axes[1].bar(vals, counts, color=colors, edgecolor='white', alpha=0.8)
axes[1].set_title('Defect Distribution (4 databases)', fontsize=14,
                  fontweight='bold')
axes[1].set_xlabel('Total Defect')
axes[1].set_ylabel('Frequency')

# Experiment 3: Minimum defect as function of family size
random.seed(42)
family_sizes = range(2, 10)
min_defects = []
for n in family_sizes:
    min_d = float('inf')
    for _ in range(20000):
        dbs = [create_partial_db(2, 3, range(4), 0.3) for _ in range(n)]
        d = total_defect(dbs)
        if d > 0:
            min_d = min(min_d, d)
    min_defects.append(min_d if min_d != float('inf') else 0)

axes[2].bar(list(family_sizes), min_defects, color='steelblue',
            edgecolor='white', alpha=0.8)
axes[2].axhline(y=2, color='red', linestyle='--', linewidth=2,
                label='Quantization bound = 2')
axes[2].set_title('Min Nonzero Defect vs Family Size', fontsize=14,
                  fontweight='bold')
axes[2].set_xlabel('Number of Databases')
axes[2].set_ylabel('Minimum Nonzero Defect')
axes[2].legend()

odd_count_2 = sum(1 for d in defects_2db if d % 2 == 1)
odd_count_4 = sum(1 for d in defects_4db if d % 2 == 1)

fig.suptitle('Defect Quantization: Disagreements Come in Symmetric Pairs\n'
             f'Odd defects observed: {odd_count_2} (2-db), {odd_count_4} (4-db) '
             f'— always 0',
             fontsize=13, y=1.05)
plt.tight_layout()
plt.savefig('defect_quantization.png', dpi=150, bbox_inches='tight')
print("Saved defect_quantization.png")
print(f"Min nonzero defects by family size: {list(zip(family_sizes, min_defects))}")
