#!/usr/bin/env python3
"""
Demo: Matroid Minor Theory — Rank Filtration and Excluded Minors

This script demonstrates the key concepts from our formalization of matroid
minor theory, including rank functions, deletion, contraction, and the
rank filtration of minor-closed classes.
"""

import itertools
from typing import Dict, FrozenSet, Set, Tuple, List

# Type aliases
Element = int
Subset = FrozenSet[int]


class RankMatroid:
    """A finite matroid defined by its rank function."""

    def __init__(self, ground_set: Set[int], rank_fn: Dict[Subset, int]):
        self.ground_set = frozenset(ground_set)
        self.rank_fn = rank_fn
        self._validate()

    def _validate(self):
        """Validate rank function axioms."""
        for s in self._all_subsets():
            r = self.rank_fn[s]
            assert 0 <= r <= len(s), f"Rank {r} out of bounds for {s}"
        # Monotonicity
        for a in self._all_subsets():
            for b in self._all_subsets():
                if a <= b:
                    assert self.rank_fn[a] <= self.rank_fn[b], \
                        f"Monotonicity violated: r({a})={self.rank_fn[a]} > r({b})={self.rank_fn[b]}"
        # Submodularity
        for a in self._all_subsets():
            for b in self._all_subsets():
                r_union = self.rank_fn[a | b]
                r_inter = self.rank_fn[a & b]
                r_a = self.rank_fn[a]
                r_b = self.rank_fn[b]
                assert r_union + r_inter <= r_a + r_b, \
                    f"Submodularity violated for {a}, {b}"

    def _all_subsets(self) -> List[Subset]:
        result = []
        elements = sorted(self.ground_set)
        for i in range(len(elements) + 1):
            for combo in itertools.combinations(elements, i):
                result.append(frozenset(combo))
        return result

    def rank(self) -> int:
        return self.rank_fn[self.ground_set]

    def deletion(self, d: Set[int]) -> 'RankMatroid':
        """Delete elements d from the matroid."""
        new_ground = self.ground_set - frozenset(d)
        new_rank = {}
        for s in _all_subsets_of(new_ground):
            new_rank[s] = self.rank_fn[s]  # r_M\D(A) = r_M(A) for A ⊆ E\D
        return RankMatroid(new_ground, new_rank)

    def contraction(self, c: Set[int]) -> 'RankMatroid':
        """Contract elements c from the matroid."""
        c = frozenset(c)
        new_ground = self.ground_set - c
        new_rank = {}
        r_c = self.rank_fn[c]
        for s in _all_subsets_of(new_ground):
            new_rank[s] = self.rank_fn[s | c] - r_c
        return RankMatroid(new_ground, new_rank)

    def dual(self) -> 'RankMatroid':
        """Compute the dual matroid."""
        n = len(self.ground_set)
        r_E = self.rank()
        new_rank = {}
        for s in self._all_subsets():
            complement = self.ground_set - s
            new_rank[s] = len(s) + self.rank_fn[complement] - r_E
        return RankMatroid(set(self.ground_set), new_rank)

    def __repr__(self):
        return f"RankMatroid(E={set(self.ground_set)}, rank={self.rank()})"


def _all_subsets_of(ground: FrozenSet[int]) -> List[Subset]:
    result = []
    elements = sorted(ground)
    for i in range(len(elements) + 1):
        for combo in itertools.combinations(elements, i):
            result.append(frozenset(combo))
    return result


def make_uniform_matroid(n: int, k: int) -> RankMatroid:
    """Create the uniform matroid U(k, n): rank function is min(|A|, k)."""
    ground = set(range(n))
    rank_fn = {}
    for s in _all_subsets_of(frozenset(ground)):
        rank_fn[s] = min(len(s), k)
    return RankMatroid(ground, rank_fn)


def is_minor_of(m_prime: RankMatroid, m: RankMatroid) -> bool:
    """Check if m_prime is a minor of m (by brute-force search)."""
    elements = sorted(m.ground_set)
    # Try all possible contraction/deletion pairs
    for c_size in range(len(elements) + 1):
        for c_combo in itertools.combinations(elements, c_size):
            c = set(c_combo)
            remaining = m.ground_set - frozenset(c)
            contracted = m.contraction(c)
            for d_size in range(len(remaining) + 1):
                for d_combo in itertools.combinations(sorted(remaining), d_size):
                    d = set(d_combo)
                    minor = contracted.deletion(d)
                    if minor.ground_set == m_prime.ground_set:
                        # Check rank functions agree
                        if all(minor.rank_fn[s] == m_prime.rank_fn[s]
                               for s in _all_subsets_of(m_prime.ground_set)):
                            return True
    return False


# ============================================================
# DEMONSTRATIONS
# ============================================================

print("=" * 60)
print("MATROID MINOR THEORY — NUMERICAL DEMONSTRATIONS")
print("=" * 60)

# Demo 1: Uniform Matroids
print("\n--- Demo 1: Uniform Matroids ---")
u23 = make_uniform_matroid(3, 2)
u13 = make_uniform_matroid(3, 1)
print(f"U(2,3) = {u23}, rank = {u23.rank()}")
print(f"U(1,3) = {u13}, rank = {u13.rank()}")

# Demo 2: Deletion and Contraction
print("\n--- Demo 2: Deletion and Contraction ---")
u24 = make_uniform_matroid(4, 2)
print(f"U(2,4) = {u24}")
deleted = u24.deletion({3})
print(f"U(2,4) \\ {{3}} = {deleted}, rank = {deleted.rank()}")
contracted = u24.contraction({0})
print(f"U(2,4) / {{0}} = {contracted}, rank = {contracted.rank()}")

# Demo 3: Dual Matroid
print("\n--- Demo 3: Dual Matroid ---")
u24_dual = u24.dual()
print(f"U(2,4)* = {u24_dual}, rank = {u24_dual.rank()}")
print(f"  (Should be U(2,4) since U(k,n)* = U(n-k,n))")

# Demo 4: Minor Relation
print("\n--- Demo 4: Minor Relation ---")
u23_small = make_uniform_matroid(3, 2)
print(f"Is U(2,3) a minor of U(2,4)? {is_minor_of(u23_small, u24)}")
print(f"Is U(2,4) a minor of U(2,3)? {is_minor_of(u24, u23_small)}")

# Demo 5: Rank Filtration
print("\n--- Demo 5: Rank Filtration of Uniform Matroids ---")
n = 4
print(f"Uniform matroids on {n} elements, by rank level:")
for k in range(n + 1):
    uk = make_uniform_matroid(n, k)
    print(f"  Rank {k}: U({k},{n}), rank = {uk.rank()}")

# Demo 6: Antichain Detection
print("\n--- Demo 6: Minor Antichains ---")
# U(1,3) and U(2,3) — neither is a minor of the other in the right way
u12 = make_uniform_matroid(2, 1)
u22 = make_uniform_matroid(2, 2)
print(f"U(1,2) = {u12}, U(2,2) = {u22}")
print(f"Is U(1,2) minor of U(2,2)? {is_minor_of(u12, u22)}")
print(f"Is U(2,2) minor of U(1,2)? {is_minor_of(u22, u12)}")

# Demo 7: Width of Rank Filtration Levels
print("\n--- Demo 7: Counting matroids by rank on small ground sets ---")
for n_size in range(1, 4):
    # Count distinct rank functions on n_size elements
    ground = set(range(n_size))
    subsets = _all_subsets_of(frozenset(ground))
    count = 0
    by_rank = {}
    for combo in itertools.product(*[range(min(len(s), n_size) + 1) for s in subsets]):
        rank_fn = {s: v for s, v in zip(subsets, combo)}
        try:
            m = RankMatroid(ground, rank_fn)
            r = m.rank()
            by_rank[r] = by_rank.get(r, 0) + 1
            count += 1
        except (AssertionError, ValueError):
            pass
    print(f"  n={n_size}: {count} matroids total, by rank: {dict(sorted(by_rank.items()))}")

print("\n" + "=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Rank Filtration of Matroids on Small Ground Sets

Generates a bar chart showing the number of distinct matroids at each rank
level for ground sets of sizes 1-3, illustrating the rank filtration structure.
"""

import itertools
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def all_subsets_of(ground):
    elements = sorted(ground)
    result = []
    for i in range(len(elements) + 1):
        for combo in itertools.combinations(elements, i):
            result.append(frozenset(combo))
    return result


def is_valid_matroid(ground, rank_fn):
    subsets = all_subsets_of(ground)
    for s in subsets:
        if not (0 <= rank_fn[s] <= len(s)):
            return False
    for a in subsets:
        for b in subsets:
            if a <= b and rank_fn[a] > rank_fn[b]:
                return False
    for a in subsets:
        for b in subsets:
            if rank_fn[a | b] + rank_fn[a & b] > rank_fn[a] + rank_fn[b]:
                return False
    return True


def count_matroids_by_rank(n):
    ground = frozenset(range(n))
    subsets = all_subsets_of(ground)
    by_rank = {}

    # Generate all possible rank functions
    ranges = [range(min(len(s), n) + 1) for s in subsets]
    for combo in itertools.product(*ranges):
        rank_fn = {s: v for s, v in zip(subsets, combo)}
        if is_valid_matroid(ground, rank_fn):
            r = rank_fn[ground]
            by_rank[r] = by_rank.get(r, 0) + 1

    return by_rank


# Compute data
data = {}
for n in range(1, 4):
    data[n] = count_matroids_by_rank(n)
    print(f"n={n}: {data[n]}")

# Create visualization
fig, axes = plt.subplots(1, 3, figsize=(14, 5))
colors = ['#2196F3', '#4CAF50', '#FF9800', '#9C27B0', '#F44336']

for idx, n in enumerate([1, 2, 3]):
    ax = axes[idx]
    ranks = sorted(data[n].keys())
    counts = [data[n][r] for r in ranks]

    bars = ax.bar(ranks, counts, color=[colors[r % len(colors)] for r in ranks],
                  edgecolor='black', linewidth=0.5, alpha=0.85)

    # Add count labels
    for bar, count in zip(bars, counts):
        ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.1,
                str(count), ha='center', va='bottom', fontsize=12, fontweight='bold')

    ax.set_xlabel('Rank', fontsize=12)
    ax.set_ylabel('Number of Matroids', fontsize=12)
    ax.set_title(f'Ground Set Size n = {n}\n(Total: {sum(counts)} matroids)', fontsize=13)
    ax.set_xticks(ranks)
    ax.set_ylim(0, max(counts) * 1.25)

plt.suptitle('Rank Filtration of Finite Matroids',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('rank_filtration.png', dpi=150, bbox_inches='tight')
print("Saved rank_filtration.png")
