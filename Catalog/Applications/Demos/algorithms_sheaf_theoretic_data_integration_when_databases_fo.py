"""
Sheaf-Theoretic Data Integration: Algorithms

Implements the core algorithms from the formalized sheaf-theoretic framework
for database consistency and imputation.
"""
from typing import Optional, Dict, Tuple, List, Set
import numpy as np


# ─── Core Data Structures ───────────────────────────────────────────

class PartialDatabase:
    """A partial database: a grid of optional values.
    
    Represents a database with nRows observations and nCols features,
    where some entries may be missing (None).
    """
    
    def __init__(self, nRows: int, nCols: int, data: Optional[np.ndarray] = None,
                 mask: Optional[np.ndarray] = None):
        self.nRows = nRows
        self.nCols = nCols
        if data is not None:
            self.data = data.copy()
            self.mask = mask if mask is not None else np.ones((nRows, nCols), dtype=bool)
        else:
            self.data = np.zeros((nRows, nCols))
            self.mask = np.zeros((nRows, nCols), dtype=bool)
    
    def get(self, row: int, col: int) -> Optional[float]:
        """Get value at position, or None if missing."""
        if self.mask[row, col]:
            return float(self.data[row, col])
        return None
    
    def set(self, row: int, col: int, value: float) -> None:
        """Set value at position."""
        self.data[row, col] = value
        self.mask[row, col] = True
    
    def domain(self) -> Set[Tuple[int, int]]:
        """Return the set of positions with values."""
        return {(r, c) for r in range(self.nRows) 
                for c in range(self.nCols) if self.mask[r, c]}


# ─── Algorithm 1: Consistency Check ─────────────────────────────────

def is_consistent_pair(db1: PartialDatabase, db2: PartialDatabase,
                       tol: float = 1e-10) -> bool:
    """Check if two partial databases are consistent (agree on overlap).
    
    Implements the sheaf overlap condition: for every position where
    both databases have values, the values must be equal.
    
    Time complexity: O(nRows * nCols)
    """
    assert db1.nRows == db2.nRows and db1.nCols == db2.nCols
    overlap = db1.mask & db2.mask
    if not overlap.any():
        return True
    return np.allclose(db1.data[overlap], db2.data[overlap], atol=tol)


def sheaf_condition(dbs: List[PartialDatabase], tol: float = 1e-10) -> bool:
    """Check if a family of partial databases satisfies the sheaf condition.
    
    The sheaf condition requires pairwise consistency for all pairs.
    This is the Čech 0-cocycle condition.
    
    Time complexity: O(n^2 * nRows * nCols) where n = len(dbs)
    """
    for i in range(len(dbs)):
        for j in range(i + 1, len(dbs)):
            if not is_consistent_pair(dbs[i], dbs[j], tol):
                return False
    return True


# ─── Algorithm 2: Gluing ────────────────────────────────────────────

def glue_pair(db1: PartialDatabase, db2: PartialDatabase) -> PartialDatabase:
    """Glue two partial databases, preferring db1 where both are defined.
    
    Implements the GluingMap from the formalization.
    """
    result = PartialDatabase(db1.nRows, db1.nCols)
    result.data = db1.data.copy()
    result.mask = db1.mask.copy()
    
    # Fill in from db2 where db1 is missing
    fill_mask = ~db1.mask & db2.mask
    result.data[fill_mask] = db2.data[fill_mask]
    result.mask[fill_mask] = True
    
    return result


def iterated_glue(dbs: List[PartialDatabase]) -> PartialDatabase:
    """Iteratively glue a list of partial databases (left fold).
    
    By the Iterated Gluing Theorem, if the databases are pairwise
    consistent, the result extends all of them.
    
    Time complexity: O(n * nRows * nCols)
    """
    if not dbs:
        return PartialDatabase(0, 0)
    
    result = PartialDatabase(dbs[0].nRows, dbs[0].nCols)
    for db in dbs:
        result = glue_pair(result, db)
    return result


# ─── Algorithm 3: Coboundary Distance ───────────────────────────────

def coboundary_distance(db1: PartialDatabase, db2: PartialDatabase,
                        tol: float = 1e-10) -> int:
    """Compute the coboundary distance between two partial databases.
    
    Counts positions where both are defined but disagree.
    By the formalized theorem, this is a pseudometric (when the middle
    element is a global section).
    """
    overlap = db1.mask & db2.mask
    if not overlap.any():
        return 0
    return int(np.sum(~np.isclose(db1.data[overlap], db2.data[overlap], atol=tol)))


def total_coboundary_norm(dbs: List[PartialDatabase], tol: float = 1e-10) -> int:
    """Total coboundary norm of a family.
    
    By the Bridge Theorem (cobNorm_zero_iff_sheaf), this is zero
    if and only if the family satisfies the sheaf condition.
    """
    total = 0
    for i in range(len(dbs)):
        for j in range(len(dbs)):
            total += coboundary_distance(dbs[i], dbs[j], tol)
    return total


# ─── Algorithm 4: Sheaf Imputation ──────────────────────────────────

def sheaf_imputation(observed: PartialDatabase, 
                     candidates: List[PartialDatabase]) -> PartialDatabase:
    """Find the candidate that best extends the observed data.
    
    Minimizes the sheaf imputation objective: the number of observed
    positions where the candidate disagrees with the observation.
    
    This implements the sheaf-theoretic approach to missing data:
    find the closest global section of the data sheaf.
    """
    if not candidates:
        return observed
    
    best_candidate = candidates[0]
    best_distance = coboundary_distance(observed, candidates[0])
    
    for candidate in candidates[1:]:
        d = coboundary_distance(observed, candidate)
        if d < best_distance:
            best_distance = d
            best_candidate = candidate
    
    return glue_pair(observed, best_candidate)


# ─── Algorithm 5: Consistency Probability ────────────────────────────

def consistency_probability(r: float, constraint_count: int) -> float:
    """Compute (1-r)^c, the probability of consistency.
    
    By the Phase Transition Theorem, this drops below any ε > 0
    once c exceeds -log(ε)/log(1-r).
    """
    if r <= 0:
        return 1.0
    if r >= 1:
        return 0.0 if constraint_count > 0 else 1.0
    return (1 - r) ** constraint_count


def critical_constraint_count(r: float, epsilon: float) -> int:
    """Find the smallest c such that (1-r)^c < epsilon.
    
    This is the phase transition threshold from the formalization.
    """
    if r <= 0 or r >= 1 or epsilon <= 0:
        return 0
    import math
    return int(math.ceil(math.log(epsilon) / math.log(1 - r)))


# ─── Algorithm 6: Feature-Subset Sheaf ──────────────────────────────

def feature_projection(record: np.ndarray, features: List[int]) -> np.ndarray:
    """Project a record onto a subset of features.
    
    This is the restriction map of the feature presheaf.
    """
    return record[features]


def check_presheaf_composition(record: np.ndarray,
                                S: List[int], T: List[int]) -> bool:
    """Verify presheaf functoriality: restriction composes correctly.
    
    Checks that projecting onto T ⊆ S gives the same result as
    projecting directly onto T.
    """
    # T must be a subset of S
    if not set(T).issubset(set(S)):
        return False
    
    # Project onto S first, then restrict to T's positions within S
    proj_S = feature_projection(record, S)
    T_in_S = [S.index(t) for t in T]
    proj_S_then_T = proj_S[T_in_S]
    
    # Project directly onto T
    proj_T = feature_projection(record, T)
    
    return np.allclose(proj_S_then_T, proj_T)
