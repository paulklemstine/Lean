#!/usr/bin/env python3
"""
Sheaf Defect Complex: Algorithms for Database Consistency Analysis

Type-hinted implementations of the core algorithms from the sheaf-theoretic
framework for database consistency.
"""

from typing import Optional, List, Tuple, Dict, Set
from dataclasses import dataclass
import math


# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class PartialDB:
    """A partial database with optional values at each position."""
    data: List[List[Optional[int]]]

    @property
    def n_rows(self) -> int:
        return len(self.data)

    @property
    def n_cols(self) -> int:
        return len(self.data[0]) if self.data else 0

    def get(self, r: int, c: int) -> Optional[int]:
        return self.data[r][c]

    def domain(self) -> Set[Tuple[int, int]]:
        """Set of positions where values are defined."""
        return {(r, c) for r in range(self.n_rows)
                for c in range(self.n_cols) if self.data[r][c] is not None}


@dataclass
class WeightedPDB:
    """A partial database with confidence weights."""
    db: PartialDB
    weights: List[List[float]]

    def weight(self, r: int, c: int) -> float:
        return self.weights[r][c]


@dataclass
class SheafDefectComplex:
    """The Sheaf Defect Complex: captures position-resolved consistency information."""
    family: List[PartialDB]
    threshold: int

    def hot_spots(self) -> Set[Tuple[int, int]]:
        """Positions with defect exceeding the threshold."""
        n_rows = self.family[0].n_rows if self.family else 0
        n_cols = self.family[0].n_cols if self.family else 0
        spots = set()
        for r in range(n_rows):
            for c in range(n_cols):
                if position_defect(self.family, r, c) > self.threshold:
                    spots.add((r, c))
        return spots

    def cold_set(self) -> Set[Tuple[int, int]]:
        """Positions with defect at or below the threshold."""
        n_rows = self.family[0].n_rows if self.family else 0
        n_cols = self.family[0].n_cols if self.family else 0
        all_pos = {(r, c) for r in range(n_rows) for c in range(n_cols)}
        return all_pos - self.hot_spots()


# ============================================================
# Core Algorithms
# ============================================================

def disagree(a: PartialDB, b: PartialDB, r: int, c: int) -> int:
    """
    Binary disagreement indicator at position (r, c).

    Returns 1 if both databases have defined but different values at (r, c),
    0 otherwise.

    Complexity: O(1)
    """
    va, vb = a.get(r, c), b.get(r, c)
    if va is not None and vb is not None and va != vb:
        return 1
    return 0


def position_defect(family: List[PartialDB], r: int, c: int) -> int:
    """
    Compute the position defect at (r, c) for a family of databases.

    The position defect is the total number of pairwise disagreements at
    this position across all database pairs.

    Complexity: O(n²) where n = len(family)
    """
    n = len(family)
    total = 0
    for i in range(n):
        for j in range(n):
            total += disagree(family[i], family[j], r, c)
    return total


def defect_vector(family: List[PartialDB]) -> Dict[Tuple[int, int], int]:
    """
    Compute the full defect vector: position-defect for every position.

    Returns a dictionary mapping (row, col) to defect count.

    Complexity: O(n² × R × C) where n = |family|, R = rows, C = cols
    """
    if not family:
        return {}
    n_rows, n_cols = family[0].n_rows, family[0].n_cols
    result: Dict[Tuple[int, int], int] = {}
    for r in range(n_rows):
        for c in range(n_cols):
            d = position_defect(family, r, c)
            result[(r, c)] = d
    return result


def total_defect(family: List[PartialDB]) -> int:
    """
    Total defect = sum of position defects = coboundary norm.

    By the Defect Decomposition Theorem, this equals the coboundary norm
    (summing over pairs first, then positions).

    Complexity: O(n² × R × C)
    """
    return sum(defect_vector(family).values())


def defect_laplacian(family: List[PartialDB]) -> int:
    """
    Sum of squared position defects.

    The Laplacian satisfies: Laplacian ≥ Total Defect, with equality
    iff all nonzero defects equal 1.

    Complexity: O(n² × R × C)
    """
    return sum(d ** 2 for d in defect_vector(family).values())


def is_consistent(a: PartialDB, b: PartialDB) -> bool:
    """Check if two partial databases are consistent (agree on overlap)."""
    for r in range(a.n_rows):
        for c in range(a.n_cols):
            if disagree(a, b, r, c) == 1:
                return False
    return True


def family_sheaf(family: List[PartialDB]) -> bool:
    """Check if a family satisfies the sheaf condition (pairwise consistency)."""
    n = len(family)
    for i in range(n):
        for j in range(i + 1, n):
            if not is_consistent(family[i], family[j]):
                return False
    return True


def glue(a: PartialDB, b: PartialDB) -> PartialDB:
    """
    Glue two partial databases, preferring the first where both are defined.

    When a and b are consistent, the result extends both.

    Complexity: O(R × C)
    """
    n_rows, n_cols = a.n_rows, a.n_cols
    result = []
    for r in range(n_rows):
        row = []
        for c in range(n_cols):
            va = a.get(r, c)
            row.append(va if va is not None else b.get(r, c))
        result.append(row)
    return PartialDB(result)


def consistency_probability(rate: float, constraints: int) -> float:
    """
    Compute P(consistent) = (1 - rate)^constraints.

    By the Probability Product Rule, this factors multiplicatively
    over independent constraint sets.
    """
    if rate >= 1.0:
        return 0.0 if constraints > 0 else 1.0
    return (1.0 - rate) ** constraints


def overlap_constraint_count(n_databases: int, n_rows: int, n_cols: int) -> int:
    """Number of overlap constraints: C(n,2) × R × C."""
    return n_databases * (n_databases - 1) // 2 * n_rows * n_cols


def sheaf_imputation(observed: PartialDB,
                     candidates: List[List[int]]) -> Tuple[List[int], int]:
    """
    Find the closest global section (complete database row) to observed data.

    Returns the best candidate and its imputation cost (number of disagreements
    with observed data).
    """
    best_candidate = candidates[0]
    best_cost = float('inf')

    for candidate in candidates:
        cost = 0
        for c in range(observed.n_cols):
            v = observed.get(0, c)
            if v is not None and v != candidate[c]:
                cost += 1
        if cost < best_cost:
            best_cost = cost
            best_candidate = candidate

    return best_candidate, int(best_cost)


def weighted_disagree(a: WeightedPDB, b: WeightedPDB,
                      r: int, c: int) -> float:
    """Confidence-weighted disagreement at position (r, c)."""
    d = disagree(a.db, b.db, r, c)
    return a.weight(r, c) * b.weight(r, c) * d


def weighted_coboundary_norm(family: List[WeightedPDB]) -> float:
    """Total weighted coboundary norm."""
    if not family:
        return 0.0
    n = len(family)
    n_rows = family[0].db.n_rows
    n_cols = family[0].db.n_cols
    total = 0.0
    for i in range(n):
        for j in range(n):
            for r in range(n_rows):
                for c in range(n_cols):
                    total += weighted_disagree(family[i], family[j], r, c)
    return total


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    import random
    random.seed(42)

    # Create example databases
    db1 = PartialDB([[1, None, 3], [None, 2, 1]])
    db2 = PartialDB([[1, 2, None], [4, 2, None]])
    db3 = PartialDB([[None, 2, 3], [4, None, 1]])

    family = [db1, db2, db3]

    print("Example: 3 partial databases over 2×3 grid")
    for i, db in enumerate(family):
        print(f"  DB{i}: {db.data}")

    print(f"\nFamily satisfies sheaf condition? {family_sheaf(family)}")
    print(f"Total defect: {total_defect(family)}")
    print(f"Defect Laplacian: {defect_laplacian(family)}")

    dv = defect_vector(family)
    print(f"Defect vector: {dv}")

    complex = SheafDefectComplex(family, threshold=2)
    print(f"Hot spots (threshold=2): {complex.hot_spots()}")
    print(f"Cold set: {complex.cold_set()}")

    # Gluing demo
    g12 = glue(db1, db2)
    print(f"\nGlue(DB0, DB1): {g12.data}")
    print(f"Consistent(DB0, DB1)? {is_consistent(db1, db2)}")

    # Probability decay
    print(f"\nConsistency probability examples:")
    for n, k in [(5, 10), (10, 50), (20, 100)]:
        C = overlap_constraint_count(3, k, n)
        p = consistency_probability(0.1, C)
        print(f"  n={n}, k={k}: C={C}, P={p:.6e}")
