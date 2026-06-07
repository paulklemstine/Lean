#!/usr/bin/env python3
"""
Sheaf-Theoretic Data Integration: Numerical Demonstrations

This script demonstrates the key theorems from the sheaf-theoretic
data integration framework with concrete numerical examples.
"""

import random
import math
from typing import Optional, Dict, Tuple, List

# Type aliases
Position = Tuple[int, int]
PartialDB = Dict[Position, Optional[int]]


def make_partial_db(nrows: int, ncols: int, values: Dict[Position, int]) -> PartialDB:
    """Create a partial database with given values, None elsewhere."""
    db: PartialDB = {}
    for r in range(nrows):
        for c in range(ncols):
            db[(r, c)] = values.get((r, c), None)
    return db


def is_consistent(db1: PartialDB, db2: PartialDB) -> bool:
    """Check if two partial databases are consistent (agree on overlaps)."""
    for pos in db1:
        if db1[pos] is not None and db2.get(pos) is not None:
            if db1[pos] != db2[pos]:
                return False
    return True


def glue(db1: PartialDB, db2: PartialDB) -> PartialDB:
    """Glue two partial databases (prefer db1 where both defined)."""
    result = dict(db1)
    for pos in db2:
        if result.get(pos) is None:
            result[pos] = db2[pos]
    return result


def is_global_section(db: PartialDB) -> bool:
    """Check if a partial database is a global section (no missing values)."""
    return all(v is not None for v in db.values())


def coboundary_norm(dbs: List[PartialDB]) -> int:
    """Compute the coboundary norm of a family of partial databases."""
    norm = 0
    for db1 in dbs:
        for db2 in dbs:
            for pos in db1:
                v1, v2 = db1.get(pos), db2.get(pos)
                if v1 is not None and v2 is not None and v1 != v2:
                    norm += 1
    return norm


def consistency_probability(r: float, c: int) -> float:
    """P(consistent) = (1-r)^c"""
    return (1 - r) ** c


# ============================================================
# Demo 1: Gluing Associativity
# ============================================================
print("=" * 60)
print("DEMO 1: Gluing Associativity")
print("=" * 60)

nrows, ncols = 3, 4

db_a = make_partial_db(nrows, ncols, {(0, 0): 1, (0, 1): 2, (1, 0): 3})
db_b = make_partial_db(nrows, ncols, {(0, 1): 2, (1, 1): 4, (2, 0): 5})
db_c = make_partial_db(nrows, ncols, {(1, 0): 3, (2, 0): 5, (2, 1): 6})

print(f"DB A defined at: {[p for p in db_a if db_a[p] is not None]}")
print(f"DB B defined at: {[p for p in db_b if db_b[p] is not None]}")
print(f"DB C defined at: {[p for p in db_c if db_c[p] is not None]}")

assert is_consistent(db_a, db_b), "A,B should be consistent"
assert is_consistent(db_a, db_c), "A,C should be consistent"
assert is_consistent(db_b, db_c), "B,C should be consistent"
print("✓ All pairs are pairwise consistent")

left_assoc = glue(glue(db_a, db_b), db_c)
right_assoc = glue(db_a, glue(db_b, db_c))

assert left_assoc == right_assoc, "Associativity should hold!"
print("✓ GluingMap (GluingMap A B) C == GluingMap A (GluingMap B C)")
print(f"  Result: {[(p, left_assoc[p]) for p in sorted(left_assoc) if left_assoc[p] is not None]}")

# ============================================================
# Demo 2: Coverage-Completeness
# ============================================================
print("\n" + "=" * 60)
print("DEMO 2: Coverage-Completeness Theorem")
print("=" * 60)

nrows, ncols = 2, 3
# Three consistent DBs that together cover all positions
d1 = make_partial_db(nrows, ncols, {(0, 0): 10, (0, 1): 20, (0, 2): 30})
d2 = make_partial_db(nrows, ncols, {(0, 1): 20, (1, 0): 40, (1, 1): 50})
d3 = make_partial_db(nrows, ncols, {(0, 2): 30, (1, 1): 50, (1, 2): 60})

dbs = [d1, d2, d3]
for i in range(len(dbs)):
    for j in range(len(dbs)):
        assert is_consistent(dbs[i], dbs[j]), f"DBs {i},{j} inconsistent!"

# Fold-glue
result = {}
for r in range(nrows):
    for c in range(ncols):
        result[(r, c)] = None

for db in dbs:
    result = glue(result, db)

print(f"Fold-glue result: {[(p, result[p]) for p in sorted(result)]}")
assert is_global_section(result), "Result should be a global section!"
print("✓ Fold-glue of covering consistent family IS a global section")

# ============================================================
# Demo 3: Coboundary Norm
# ============================================================
print("\n" + "=" * 60)
print("DEMO 3: Coboundary Norm and Sheaf Condition")
print("=" * 60)

# Consistent family
consistent_family = [d1, d2, d3]
norm_c = coboundary_norm(consistent_family)
print(f"Coboundary norm of consistent family: {norm_c}")
assert norm_c == 0, "Consistent family should have zero coboundary!"
print("✓ Zero coboundary ↔ Sheaf condition (consistent)")

# Inconsistent family
d4 = make_partial_db(nrows, ncols, {(0, 1): 99, (1, 0): 40})  # disagrees with d1 at (0,1)
inconsistent_family = [d1, d4]
norm_i = coboundary_norm(inconsistent_family)
print(f"Coboundary norm of inconsistent family: {norm_i}")
assert norm_i > 0, "Inconsistent family should have positive coboundary!"
print("✓ Positive coboundary → NOT sheaf condition (inconsistent)")

# ============================================================
# Demo 4: Exponential Consistency Decay
# ============================================================
print("\n" + "=" * 60)
print("DEMO 4: Exponential Consistency Decay")
print("=" * 60)

r = 0.3
for c in [1, 10, 50, 100, 500, 1000, 4500]:
    prob = consistency_probability(r, c)
    log_prob = c * math.log10(1 - r) if r < 1 else float('-inf')
    print(f"  c={c:5d}: P(consistent) = {prob:.6e}  (log₁₀ = {log_prob:.1f})")

print(f"\nFor n=10 cols, k=100 rows, r=0.3:")
C = 10 * 9 // 2 * 100  # = 4500
prob_pred = consistency_probability(0.3, C)
print(f"  C = n(n-1)/2 × k = {C}")
print(f"  P(consistent) = (0.7)^{C} ≈ {prob_pred:.2e}")
print(f"  This is essentially zero — confirming exponential decay!")

# ============================================================
# Demo 5: Feature-Subset Sheaf
# ============================================================
print("\n" + "=" * 60)
print("DEMO 5: Feature-Subset Sheaf Construction")
print("=" * 60)

# 3 rows, features = {0, 1, 2, 3}
# Subset S = {0, 1}, Subset T = {1, 2}
# Global DB on U = {0, 1, 2}
global_data = {
    (0, 0): 'a', (0, 1): 'b', (0, 2): 'c',
    (1, 0): 'd', (1, 1): 'e', (1, 2): 'f',
    (2, 0): 'g', (2, 1): 'h', (2, 2): 'i',
}

def restrict_features(data, feature_set):
    """Restrict a database to a subset of features."""
    return {(r, c): v for (r, c), v in data.items() if c in feature_set}

S = {0, 1}
T = {1, 2}
db_S = restrict_features(global_data, S)
db_T = restrict_features(global_data, T)

print(f"Feature set S = {S}: {db_S}")
print(f"Feature set T = {T}: {db_T}")

# Check consistency on S ∩ T = {1}
overlap = S & T
print(f"Overlap S ∩ T = {overlap}")
for r in range(3):
    for c in overlap:
        assert db_S.get((r, c)) == db_T.get((r, c)), \
            f"Inconsistency at ({r},{c})!"
print("✓ Restricted databases are feature-consistent on S ∩ T")

# Glue to S ∪ T = {0, 1, 2}
glued = dict(db_S)
for pos, val in db_T.items():
    if pos not in glued:
        glued[pos] = val
print(f"Glued on S ∪ T = {S | T}: {glued}")
assert glued == global_data, "Gluing should recover the global data!"
print("✓ Gluing recovers the global section (Feature Sheaf Condition)")

# ============================================================
# Demo 6: Monte Carlo Consistency Test
# ============================================================
print("\n" + "=" * 60)
print("DEMO 6: Monte Carlo Consistency Probability Test")
print("=" * 60)

random.seed(42)
n_trials = 100000
ncols = 3
nrows = 3
missing_rate = 0.5
alphabet_size = 2  # small alphabet to make consistency possible

consistent_count = 0
for _ in range(n_trials):
    db1 = {}
    db2 = {}
    for r in range(nrows):
        for c in range(ncols):
            if random.random() > missing_rate:
                db1[(r, c)] = random.randint(0, alphabet_size - 1)
            else:
                db1[(r, c)] = None
            if random.random() > missing_rate:
                db2[(r, c)] = random.randint(0, alphabet_size - 1)
            else:
                db2[(r, c)] = None
    if is_consistent(db1, db2):
        consistent_count += 1

empirical_prob = consistent_count / n_trials
# Theoretical: each position has P(disagree) = P(both defined and different)
# P(both defined) = (1-r)^2 = 0.25, P(different | both defined) = 1 - 1/alphabet
# P(single constraint satisfied) = 1 - (1-r)^2 * (1-1/alphabet)
p_single = 1 - (1 - missing_rate)**2 * (1 - 1/alphabet_size)
theoretical_prob = p_single ** (nrows * ncols)

print(f"  Settings: {nrows}×{ncols} grid, missing_rate={missing_rate}, alphabet={alphabet_size}")
print(f"  Empirical P(consistent): {empirical_prob:.4f}")
print(f"  Theoretical P(consistent): {theoretical_prob:.4f}")
print(f"  Ratio: {empirical_prob / theoretical_prob:.3f}")

print("\n" + "=" * 60)
print("ALL DEMOS COMPLETED SUCCESSFULLY")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Exponential Consistency Decay

Shows how the probability of database consistency decays exponentially
with the number of overlap constraints, for different missing rates.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def consistency_probability(r, c):
    """P(consistent) = (1-r)^c"""
    return (1 - r) ** c

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left panel: P(consistent) vs constraint count for various r
ax1 = axes[0]
constraints = np.arange(0, 201)
for r in [0.05, 0.1, 0.2, 0.3, 0.5]:
    probs = [consistency_probability(r, c) for c in constraints]
    ax1.plot(constraints, probs, label=f'r = {r}', linewidth=2)

ax1.set_xlabel('Number of constraints C', fontsize=12)
ax1.set_ylabel('P(consistent)', fontsize=12)
ax1.set_title('Exponential Consistency Decay\n$P = (1-r)^C$', fontsize=14)
ax1.legend(fontsize=10)
ax1.set_ylim(0, 1.05)
ax1.grid(True, alpha=0.3)

# Right panel: log P vs C (showing linearity)
ax2 = axes[1]
constraints_log = np.arange(1, 501)
for r in [0.05, 0.1, 0.2, 0.3, 0.5]:
    log_probs = [c * np.log10(1 - r) for c in constraints_log]
    ax2.plot(constraints_log, log_probs, label=f'r = {r}', linewidth=2)

ax2.set_xlabel('Number of constraints C', fontsize=12)
ax2.set_ylabel('log₁₀ P(consistent)', fontsize=12)
ax2.set_title('Log-Linearity: log P = C · log(1−r)\n(Proved: consistency_prob_log_linear)', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('consistency_decay.png', dpi=150, bbox_inches='tight')
print("Saved: consistency_decay.png")


#!/usr/bin/env python3
"""
Visualization: Sheaf Filtration — Progressive Database Completion

Shows how a sheaf filtration progressively fills in missing database entries,
with each level extending the previous while maintaining consistency.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def create_filtration_demo():
    """Create a demo filtration: 4×5 grid, 4 levels."""
    nrows, ncols = 4, 5
    
    # Level 0: sparse (3 entries)
    level0 = np.full((nrows, ncols), np.nan)
    level0[0, 0] = 1; level0[1, 2] = 5; level0[3, 4] = 9
    
    # Level 1: extends level 0 (6 entries)
    level1 = level0.copy()
    level1[0, 1] = 2; level1[2, 2] = 6; level1[3, 3] = 8
    
    # Level 2: extends further (12 entries)
    level2 = level1.copy()
    level2[0, 2] = 3; level2[0, 3] = 4; level2[1, 0] = 4
    level2[1, 1] = 3; level2[2, 0] = 7; level2[2, 1] = 8
    
    # Level 3: global section (all 20 entries)
    level3 = level2.copy()
    for r in range(nrows):
        for c in range(ncols):
            if np.isnan(level3[r, c]):
                level3[r, c] = (r + c) % 10
    
    return [level0, level1, level2, level3]

levels = create_filtration_demo()

fig, axes = plt.subplots(1, 4, figsize=(16, 4))

for idx, (ax, level) in enumerate(zip(axes, levels)):
    # Create a mask for missing values
    mask = np.isnan(level)
    display = np.where(mask, -1, level)
    
    # Color map
    cmap = plt.cm.YlOrRd
    cmap.set_under('lightgray')
    
    im = ax.imshow(display, cmap=cmap, vmin=0, vmax=9, aspect='equal')
    
    # Annotate cells
    nrows, ncols = level.shape
    for r in range(nrows):
        for c in range(ncols):
            if not np.isnan(level[r, c]):
                ax.text(c, r, f'{int(level[r, c])}', ha='center', va='center',
                       fontsize=12, fontweight='bold', color='black')
            else:
                ax.text(c, r, '?', ha='center', va='center',
                       fontsize=12, color='gray')
    
    filled = np.sum(~mask)
    total = nrows * ncols
    ax.set_title(f'Level {idx}\n({filled}/{total} filled)', fontsize=12)
    ax.set_xticks(range(ncols))
    ax.set_yticks(range(nrows))
    ax.set_xticklabels([f'c{c}' for c in range(ncols)])
    ax.set_yticklabels([f'r{r}' for r in range(nrows)])

fig.suptitle('Sheaf Filtration: Progressive Database Completion\n'
             'Each level extends the previous (monotone + consistent)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('sheaf_filtration.png', dpi=150, bbox_inches='tight')
print("Saved: sheaf_filtration.png")
