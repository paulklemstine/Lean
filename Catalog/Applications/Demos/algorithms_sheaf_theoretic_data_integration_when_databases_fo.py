#!/usr/bin/env python3
"""
Sheaf-Theoretic Data Integration: Algorithms

Type-hinted implementations of the core algorithms from the
Consistency Nerve framework.
"""

import numpy as np
from typing import Optional, List, Tuple, FrozenSet, Dict, Set
from itertools import combinations
from dataclasses import dataclass


# ========================================================
# Core Data Types
# ========================================================

@dataclass
class PartialDatabase:
    """A partial database with optional entries.
    Missing entries are represented as None in the data dict."""
    nR: int
    nC: int
    data: Dict[Tuple[int, int], Optional[int]]

    @classmethod
    def from_array(cls, arr: np.ndarray, missing_val: int = -1) -> 'PartialDatabase':
        nR, nC = arr.shape
        data = {}
        for r in range(nR):
            for c in range(nC):
                if arr[r, c] != missing_val:
                    data[(r, c)] = int(arr[r, c])
                else:
                    data[(r, c)] = None
        return cls(nR=nR, nC=nC, data=data)

    def coverage(self) -> int:
        return sum(1 for v in self.data.values() if v is not None)

    def total_positions(self) -> int:
        return self.nR * self.nC

    def is_complete(self) -> bool:
        return self.coverage() == self.total_positions()


# ========================================================
# Algorithm 1: Pairwise Consistency Check
# ========================================================

def pairwise_consistency_check(
    db1: PartialDatabase, db2: PartialDatabase
) -> Tuple[bool, int]:
    """
    Check if two partial databases are consistent.
    Returns (is_consistent, disagreement_count).

    Time complexity: O(nR * nC)
    Space complexity: O(1)
    """
    disagreements = 0
    for pos in db1.data:
        v1 = db1.data.get(pos)
        v2 = db2.data.get(pos)
        if v1 is not None and v2 is not None and v1 != v2:
            disagreements += 1
    return (disagreements == 0, disagreements)


# ========================================================
# Algorithm 2: Consistency Nerve Construction
# ========================================================

def build_consistency_nerve(
    databases: List[PartialDatabase]
) -> List[FrozenSet[int]]:
    """
    Build the consistency nerve: the abstract simplicial complex
    whose faces are pairwise-consistent subfamilies.

    Uses incremental construction: check pairs first (1-skeleton),
    then build higher faces only from cliques of the 1-skeleton.

    Time complexity: O(n^2 * nR * nC) for 1-skeleton, then
                     O(2^n) worst case for higher faces
    """
    n = len(databases)

    # Build adjacency (1-skeleton)
    adj: Dict[int, Set[int]] = {i: set() for i in range(n)}
    for i, j in combinations(range(n), 2):
        consistent, _ = pairwise_consistency_check(databases[i], databases[j])
        if consistent:
            adj[i].add(j)
            adj[j].add(i)

    # Build all faces using Bron-Kerbosch for maximal cliques
    faces: List[FrozenSet[int]] = [frozenset()]

    def bron_kerbosch(R: Set[int], P: Set[int], X: Set[int]) -> None:
        if not P and not X:
            # R is a maximal clique
            for k in range(len(R) + 1):
                for subset in combinations(R, k):
                    face = frozenset(subset)
                    if face not in faces_set:
                        faces.append(face)
                        faces_set.add(face)
            return
        # Choose pivot
        pivot = max(P | X, key=lambda v: len(adj[v] & P)) if P | X else None
        if pivot is None:
            return
        for v in P - adj.get(pivot, set()):
            bron_kerbosch(
                R | {v},
                P & adj[v],
                X & adj[v]
            )
            P = P - {v}
            X = X | {v}

    faces_set: Set[FrozenSet[int]] = {frozenset()}
    bron_kerbosch(set(), set(range(n)), set())

    return sorted(faces, key=lambda f: (len(f), sorted(f)))


# ========================================================
# Algorithm 3: Consistency Rank Computation
# ========================================================

def compute_consistency_rank(databases: List[PartialDatabase]) -> int:
    """
    Compute the consistency rank: the clique number of the
    consistency graph.

    This equals the maximum cardinality of a pairwise-consistent
    subfamily.
    """
    faces = build_consistency_nerve(databases)
    return max(len(f) for f in faces)


# ========================================================
# Algorithm 4: Sheaf Gluing
# ========================================================

def glue_databases(
    db1: PartialDatabase, db2: PartialDatabase
) -> PartialDatabase:
    """
    Glue two partial databases, preferring db1 where defined.

    Precondition: db1 and db2 should be consistent for
    the result to be meaningful.
    """
    assert db1.nR == db2.nR and db1.nC == db2.nC
    result_data = {}
    for pos in db1.data:
        v1 = db1.data.get(pos)
        v2 = db2.data.get(pos)
        if v1 is not None:
            result_data[pos] = v1
        else:
            result_data[pos] = v2
    return PartialDatabase(nR=db1.nR, nC=db1.nC, data=result_data)


def iterated_gluing(
    databases: List[PartialDatabase]
) -> PartialDatabase:
    """
    Iteratively glue a list of databases.
    Theorem: if all databases are pairwise consistent,
    the result extends every input.
    """
    if not databases:
        raise ValueError("Cannot glue empty list")
    result = databases[0]
    for db in databases[1:]:
        result = glue_databases(result, db)
    return result


# ========================================================
# Algorithm 5: Defect Spectrum
# ========================================================

def compute_defect_spectrum(
    databases: List[PartialDatabase],
    max_threshold: int = 20
) -> List[Tuple[int, int, int]]:
    """
    Compute the defect spectrum: for each threshold t,
    count pairs with disagreement ≤ t.

    Returns: List of (threshold, edge_count, total_pairs)
    """
    n = len(databases)
    total_pairs = n * (n - 1) // 2

    # Precompute all pairwise disagreements
    disagreements: List[int] = []
    for i, j in combinations(range(n), 2):
        _, d = pairwise_consistency_check(databases[i], databases[j])
        disagreements.append(d)

    spectrum = []
    for t in range(max_threshold + 1):
        count = sum(1 for d in disagreements if d <= t)
        spectrum.append((t, count, total_pairs))

    return spectrum


# ========================================================
# Algorithm 6: Sheaf Imputation
# ========================================================

def sheaf_imputation(
    databases: List[PartialDatabase],
    n_values: int = 10
) -> Optional[PartialDatabase]:
    """
    Sheaf-based imputation: find the largest consistent subfamily,
    glue them, then fill remaining positions by majority vote.

    This implements the optimization:
    min_candidate sum_{observed positions} disagreement(candidate, observed)
    subject to: candidate extends a consistent subfamily
    """
    if not databases:
        return None

    # Find maximum consistent subfamily (max clique)
    faces = build_consistency_nerve(databases)
    max_face = max(faces, key=len)

    if len(max_face) == 0:
        return databases[0]  # fallback

    # Glue the maximum consistent subfamily
    consistent_dbs = [databases[i] for i in sorted(max_face)]
    glued = iterated_gluing(consistent_dbs)

    # Fill remaining by majority vote across all databases
    nR, nC = glued.nR, glued.nC
    result_data = dict(glued.data)

    for r in range(nR):
        for c in range(nC):
            if result_data.get((r, c)) is None:
                # Majority vote
                votes: Dict[int, int] = {}
                for db in databases:
                    v = db.data.get((r, c))
                    if v is not None:
                        votes[v] = votes.get(v, 0) + 1
                if votes:
                    result_data[(r, c)] = max(votes, key=votes.get)

    return PartialDatabase(nR=nR, nC=nC, data=result_data)


# ========================================================
# Algorithm 7: Feature Projection
# ========================================================

def project_to_columns(
    db: PartialDatabase, columns: List[int]
) -> PartialDatabase:
    """
    Project a partial database to a subset of columns.

    Theorem: projection preserves consistency and reduces disagreement.
    """
    col_set = set(columns)
    new_data = {}
    for (r, c), v in db.data.items():
        if c in col_set:
            new_data[(r, c)] = v
        else:
            new_data[(r, c)] = None
    return PartialDatabase(nR=db.nR, nC=db.nC, data=new_data)


if __name__ == "__main__":
    # Quick test
    rng = np.random.default_rng(42)
    gt = rng.integers(0, 5, size=(5, 4))

    dbs = []
    for i in range(4):
        arr = gt.copy()
        mask = rng.random(size=(5, 4)) < 0.3
        arr[mask] = -1
        dbs.append(PartialDatabase.from_array(arr))

    rank = compute_consistency_rank(dbs)
    print(f"Consistency rank: {rank} / {len(dbs)}")

    glued = iterated_gluing(dbs)
    print(f"Glued coverage: {glued.coverage()} / {glued.total_positions()}")

    spectrum = compute_defect_spectrum(dbs, max_threshold=5)
    for t, count, total in spectrum:
        print(f"  t={t}: {count}/{total} pairs are t-consistent")
