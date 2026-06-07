#!/usr/bin/env python3
"""
Sheaf-Theoretic Data Integration: Core Algorithms

Type-hinted implementations of the sheaf imputation algorithms
formalized in the Lean 4 proofs.
"""

from typing import Optional, Dict, Tuple, List, Set, TypeVar, Generic
from dataclasses import dataclass
import math

T = TypeVar('T')
Position = Tuple[int, int]


@dataclass
class PartialDatabase(Generic[T]):
    """A partial database: grid positions mapped to optional values."""
    nrows: int
    ncols: int
    data: Dict[Position, Optional[T]]

    @classmethod
    def empty(cls, nrows: int, ncols: int) -> 'PartialDatabase[T]':
        return cls(nrows, ncols, {(r, c): None for r in range(nrows) for c in range(ncols)})

    @classmethod
    def from_values(cls, nrows: int, ncols: int, values: Dict[Position, T]) -> 'PartialDatabase[T]':
        data = {(r, c): values.get((r, c)) for r in range(nrows) for c in range(ncols)}
        return cls(nrows, ncols, data)

    def domain(self) -> Set[Position]:
        return {p for p, v in self.data.items() if v is not None}

    def is_global_section(self) -> bool:
        return all(v is not None for v in self.data.values())


def consistent_pair(db1: PartialDatabase[T], db2: PartialDatabase[T]) -> bool:
    """
    Check if two partial databases are consistent (agree on overlaps).

    Algorithm: ConsistentPair
    Pseudocode:
      for each position p in domain(db1) ∩ domain(db2):
        if db1[p] ≠ db2[p]: return False
      return True
    """
    for pos in db1.data:
        v1, v2 = db1.data.get(pos), db2.data.get(pos)
        if v1 is not None and v2 is not None and v1 != v2:
            return False
    return True


def gluing_map(db1: PartialDatabase[T], db2: PartialDatabase[T]) -> PartialDatabase[T]:
    """
    Glue two partial databases (prefer db1 where both defined).

    Algorithm: GluingMap
    Pseudocode:
      for each position p:
        result[p] = db1[p] if db1[p] is defined, else db2[p]
    """
    result_data: Dict[Position, Optional[T]] = {}
    all_positions = set(db1.data.keys()) | set(db2.data.keys())
    for pos in all_positions:
        v1 = db1.data.get(pos)
        result_data[pos] = v1 if v1 is not None else db2.data.get(pos)
    return PartialDatabase(
        max(db1.nrows, db2.nrows),
        max(db1.ncols, db2.ncols),
        result_data
    )


def fold_glue(dbs: List[PartialDatabase[T]]) -> PartialDatabase[T]:
    """
    Fold-glue a list of partial databases from left.

    Algorithm: FoldGlue
    Pseudocode:
      acc = empty_db
      for db in dbs:
        acc = glue(acc, db)
      return acc

    Theorem: If dbs are pairwise consistent and cover all positions,
    the result is a global section (foldGlue_global_of_covering).
    """
    if not dbs:
        return PartialDatabase.empty(0, 0)
    nrows = max(db.nrows for db in dbs)
    ncols = max(db.ncols for db in dbs)
    acc = PartialDatabase.empty(nrows, ncols)
    for db in dbs:
        acc = gluing_map(acc, db)
    return acc


def coboundary_norm(dbs: List[PartialDatabase[T]]) -> int:
    """
    Compute the coboundary norm: total disagreements across all pairs.

    Algorithm: CoboundaryNorm
    Pseudocode:
      norm = 0
      for i, j in all_pairs(dbs):
        for position p:
          if dbs[i][p] and dbs[j][p] are both defined and differ:
            norm += 1
      return norm

    Theorem: norm = 0 ⟺ sheaf condition (coboundary_zero_iff_sheaf).
    """
    norm = 0
    for db1 in dbs:
        for db2 in dbs:
            for pos in db1.data:
                v1, v2 = db1.data.get(pos), db2.data.get(pos)
                if v1 is not None and v2 is not None and v1 != v2:
                    norm += 1
    return norm


def sheaf_imputation(
    observed: PartialDatabase[T],
    candidates: List[PartialDatabase[T]]
) -> Optional[PartialDatabase[T]]:
    """
    Find the best candidate that extends the observed data.

    Algorithm: SheafImputation
    Pseudocode:
      best_cost = ∞
      best_candidate = None
      for candidate in candidates:
        cost = count disagreements between observed and candidate on observed's domain
        if cost < best_cost:
          best_cost = cost
          best_candidate = candidate
      return best_candidate

    Theorem: cost = 0 ⟺ candidate extends observed (imputation_zero_iff_extends).
    """
    best_cost = float('inf')
    best_candidate = None
    for candidate in candidates:
        cost = 0
        for pos, obs_val in observed.data.items():
            if obs_val is not None:
                cand_val = candidate.data.get(pos)
                if cand_val is not None and obs_val != cand_val:
                    cost += 1
        if cost < best_cost:
            best_cost = cost
            best_candidate = candidate
    return best_candidate


def consistency_probability(r: float, n_constraints: int) -> float:
    """
    Compute P(consistent) = (1-r)^C.

    Algorithm: ConsistencyProbability
    Pseudocode:
      return (1 - r) ^ n_constraints

    Theorems:
      - Strict monotonicity: more constraints → lower probability
      - Log-linearity: log P = C · log(1-r)
      - Exponential decay: P → 0 as C → ∞
    """
    if r <= 0:
        return 1.0
    if r >= 1:
        return 0.0 if n_constraints > 0 else 1.0
    return (1 - r) ** n_constraints


def overlap_constraint_count(n_dbs: int, nrows: int, ncols: int) -> int:
    """
    Count overlap constraints: C = n(n-1)/2 × (nrows × ncols).

    Algorithm: OverlapConstraintCount
    Pseudocode:
      return n * (n - 1) / 2 * nrows * ncols
    """
    return n_dbs * (n_dbs - 1) // 2 * (nrows * ncols)


@dataclass
class FeatureDatabase(Generic[T]):
    """A database restricted to a subset of features (columns)."""
    nrows: int
    feature_set: Set[int]
    data: Dict[Tuple[int, int], T]  # (row, feature) -> value

    def restrict(self, subset: Set[int]) -> 'FeatureDatabase[T]':
        """Restrict to a smaller feature subset."""
        assert subset <= self.feature_set, "subset must be contained in feature_set"
        new_data = {(r, f): v for (r, f), v in self.data.items() if f in subset}
        return FeatureDatabase(self.nrows, subset, new_data)

    def feature_consistent(self, other: 'FeatureDatabase[T]') -> bool:
        """Check consistency on the intersection of feature sets."""
        overlap = self.feature_set & other.feature_set
        for r in range(self.nrows):
            for f in overlap:
                v1 = self.data.get((r, f))
                v2 = other.data.get((r, f))
                if v1 is not None and v2 is not None and v1 != v2:
                    return False
        return True


def feature_glue(
    db_s: FeatureDatabase[T],
    db_t: FeatureDatabase[T]
) -> FeatureDatabase[T]:
    """
    Glue two feature databases on S ∪ T.

    Precondition: db_s and db_t are feature-consistent.

    Algorithm: FeatureGlue
    Pseudocode:
      for each (row, feature) in S ∪ T:
        if feature ∈ S: result[row, feature] = db_s[row, feature]
        else: result[row, feature] = db_t[row, feature]
    """
    combined_features = db_s.feature_set | db_t.feature_set
    combined_data: Dict[Tuple[int, int], T] = {}
    for r in range(max(db_s.nrows, db_t.nrows)):
        for f in combined_features:
            if f in db_s.feature_set and (r, f) in db_s.data:
                combined_data[(r, f)] = db_s.data[(r, f)]
            elif f in db_t.feature_set and (r, f) in db_t.data:
                combined_data[(r, f)] = db_t.data[(r, f)]
    return FeatureDatabase(max(db_s.nrows, db_t.nrows), combined_features, combined_data)


class SheafFiltration(Generic[T]):
    """
    A sheaf filtration: sequence of increasingly refined partial databases.

    Invariants (proved in Lean):
      - Monotone: level[i] ⊆ level[j] for i ≤ j (information grows)
      - Consistent: all levels are pairwise consistent (sheaf condition)
    """

    def __init__(self, levels: List[PartialDatabase[T]]):
        self.levels = levels
        self._validate()

    def _validate(self):
        for i in range(len(self.levels)):
            for j in range(i + 1, len(self.levels)):
                assert consistent_pair(self.levels[i], self.levels[j]), \
                    f"Levels {i} and {j} are not consistent!"
                # Check monotonicity
                for pos in self.levels[i].data:
                    vi = self.levels[i].data[pos]
                    vj = self.levels[j].data[pos]
                    if vi is not None:
                        assert vj == vi, \
                            f"Monotonicity violated at {pos}: level {i} has {vi}, level {j} has {vj}"

    def is_complete(self) -> bool:
        return len(self.levels) > 0 and self.levels[-1].is_global_section()

    @classmethod
    def from_consistent_list(cls, dbs: List[PartialDatabase[T]]) -> 'SheafFiltration[T]':
        """Build a filtration by progressive fold-gluing."""
        if not dbs:
            return cls([])
        nrows = max(db.nrows for db in dbs)
        ncols = max(db.ncols for db in dbs)
        levels = []
        acc = PartialDatabase.empty(nrows, ncols)
        for db in dbs:
            acc = gluing_map(acc, db)
            levels.append(PartialDatabase(nrows, ncols, dict(acc.data)))
        return cls(levels)


if __name__ == '__main__':
    # Quick self-test
    db1 = PartialDatabase.from_values(2, 2, {(0, 0): 1, (0, 1): 2})
    db2 = PartialDatabase.from_values(2, 2, {(0, 1): 2, (1, 0): 3})
    db3 = PartialDatabase.from_values(2, 2, {(1, 0): 3, (1, 1): 4})

    assert consistent_pair(db1, db2)
    assert consistent_pair(db2, db3)
    assert consistent_pair(db1, db3)

    result = fold_glue([db1, db2, db3])
    assert result.is_global_section()
    print("All self-tests passed!")

    # Consistency probability
    for c in [10, 100, 1000]:
        p = consistency_probability(0.3, c)
        print(f"P(consistent, r=0.3, C={c}) = {p:.6e}")
