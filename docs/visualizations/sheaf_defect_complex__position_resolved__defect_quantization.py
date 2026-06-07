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
