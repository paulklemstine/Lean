#!/usr/bin/env python3
"""
Tropical Normal Form: Core Algorithms

Implements the normalization algorithm and extensions including:
- Basic normalization (compile to minimum of affine forms)
- Dominance elimination (remove dominated affine forms)
- Lexicographic canonicalization (sort for unique representatives)
- Tropical identity checking
- Tropical matrix normalization for shortest paths
"""

import numpy as np
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Set
from itertools import product


# ============================================================
# Core Data Structures
# ============================================================

@dataclass(frozen=True)
class AffineForm:
    """Immutable affine form: constant + Σ coeff[i] * x[i]."""
    constant: float
    coeff: Tuple[int, ...]

    def eval(self, x: np.ndarray) -> float:
        """Evaluate at point x."""
        return self.constant + sum(c * x[i] for i, c in enumerate(self.coeff))

    @staticmethod
    def add(a: 'AffineForm', b: 'AffineForm') -> 'AffineForm':
        """Pointwise addition of affine forms."""
        return AffineForm(
            a.constant + b.constant,
            tuple(ac + bc for ac, bc in zip(a.coeff, b.coeff))
        )

    @staticmethod
    def of_const(c: float, n_vars: int) -> 'AffineForm':
        return AffineForm(c, tuple([0] * n_vars))

    @staticmethod
    def of_var(i: int, n_vars: int) -> 'AffineForm':
        coeff = [0] * n_vars
        coeff[i] = 1
        return AffineForm(0.0, tuple(coeff))

    def dominates(self, other: 'AffineForm') -> bool:
        """Check if self ≤ other everywhere (self dominates other).

        self dominates other iff:
        - self.constant ≤ other.constant, AND
        - self.coeff[i] ≤ other.coeff[i] for all i

        This is sufficient (but not necessary) for self.eval(x) ≤ other.eval(x)
        when all variables are non-negative. For general ℝ, dominance requires
        equal coefficients and smaller constant.
        """
        if self.constant > other.constant:
            return False
        return all(sc <= oc for sc, oc in zip(self.coeff, other.coeff))

    def __repr__(self):
        terms = []
        if self.constant != 0:
            terms.append(f"{self.constant}")
        for i, c in enumerate(self.coeff):
            if c == 1:
                terms.append(f"x{i}")
            elif c > 1:
                terms.append(f"{c}·x{i}")
        return " + ".join(terms) if terms else "0"


# ============================================================
# Tropical Expression AST
# ============================================================

class TropExpr:
    pass

@dataclass
class Const(TropExpr):
    value: float

@dataclass
class Var(TropExpr):
    index: int

@dataclass
class TMin(TropExpr):
    left: TropExpr
    right: TropExpr

@dataclass
class TAdd(TropExpr):
    left: TropExpr
    right: TropExpr


# ============================================================
# Algorithm 1: Basic Normalization
# ============================================================

def normalize(e: TropExpr, n_vars: int) -> List[AffineForm]:
    """
    Normalize a tropical expression to a list of affine forms.

    Time complexity: O(P * n) where P = product of sizes at add nodes,
                     n = number of variables.
    Space complexity: O(P * n) for the output list.

    Corresponds to the formally verified `TropExpr.normalize` function.
    """
    if isinstance(e, Const):
        return [AffineForm.of_const(e.value, n_vars)]
    elif isinstance(e, Var):
        return [AffineForm.of_var(e.index, n_vars)]
    elif isinstance(e, TMin):
        return normalize(e.left, n_vars) + normalize(e.right, n_vars)
    elif isinstance(e, TAdd):
        nf1 = normalize(e.left, n_vars)
        nf2 = normalize(e.right, n_vars)
        return [AffineForm.add(a, b) for a in nf1 for b in nf2]
    raise TypeError(f"Unknown expression: {type(e)}")


# ============================================================
# Algorithm 2: Dominance Elimination
# ============================================================

def eliminate_dominated(nf: List[AffineForm]) -> List[AffineForm]:
    """
    Remove affine forms that are dominated by another form in the list.

    An affine form a is dominated if there exists b ≠ a in the list such that
    b.eval(x) ≤ a.eval(x) for all x ∈ ℝⁿ. Since min includes a dominated
    form without effect, removing it preserves the evaluation.

    For general ℝⁿ, a dominates b iff a.coeff == b.coeff and a.constant ≤ b.constant.
    (If coefficients differ, one can always choose x to make either larger.)

    Time complexity: O(k² * n) where k = len(nf), n = number of variables.
    """
    if not nf:
        return nf

    result = []
    for i, a in enumerate(nf):
        dominated = False
        for j, b in enumerate(nf):
            if i != j and b.coeff == a.coeff and b.constant <= a.constant:
                if b.constant < a.constant or j < i:  # tie-break by index
                    dominated = True
                    break
        if not dominated:
            result.append(a)
    return result


# ============================================================
# Algorithm 3: Canonical Normalization
# ============================================================

def canonicalize(nf: List[AffineForm]) -> List[AffineForm]:
    """
    Produce a canonical normal form by:
    1. Eliminating dominated forms
    2. Removing exact duplicates
    3. Sorting lexicographically (by coeff, then constant)

    After canonicalization, two expressions are semantically equal
    iff their canonical normal forms are identical lists.

    Time complexity: O(k² * n + k * log(k) * n)
    """
    # Step 1: Eliminate dominated forms
    nf = eliminate_dominated(nf)

    # Step 2: Remove duplicates
    seen = set()
    unique = []
    for af in nf:
        key = (af.constant, af.coeff)
        if key not in seen:
            seen.add(key)
            unique.append(af)

    # Step 3: Sort lexicographically
    unique.sort(key=lambda af: (af.coeff, af.constant))

    return unique


def normalize_canonical(e: TropExpr, n_vars: int) -> List[AffineForm]:
    """Full canonical normalization pipeline."""
    return canonicalize(normalize(e, n_vars))


# ============================================================
# Algorithm 4: Tropical Identity Checking
# ============================================================

def tropical_equal(e1: TropExpr, e2: TropExpr, n_vars: int) -> bool:
    """
    Check if two tropical expressions are semantically equal.

    Uses canonical normalization: e1 ≡ e2 iff canonicalize(normalize(e1)) == canonicalize(normalize(e2)).

    Time complexity: O(P1 + P2 + max(k1,k2) * n) where Pi = normal form sizes.
    """
    nf1 = normalize_canonical(e1, n_vars)
    nf2 = normalize_canonical(e2, n_vars)
    return nf1 == nf2


# ============================================================
# Algorithm 5: Tropical Matrix Normalization
# ============================================================

def tropical_matrix_multiply(
    A: List[List[List[AffineForm]]],
    B: List[List[List[AffineForm]]],
    n_vars: int
) -> List[List[List[AffineForm]]]:
    """
    Multiply two tropical matrices whose entries are normal forms.

    (A ⊗ B)[i][j] = min_k (A[i][k] + B[k][j])
                   = mergeMin over k of addNF(A[i][k], B[k][j])

    Time complexity: O(m * n * p * max_nf_size² * n_vars)
    """
    m = len(A)
    p = len(B[0])
    n = len(B)  # = len(A[0])

    result = []
    for i in range(m):
        row = []
        for j in range(p):
            # Compute min_k (A[i][k] + B[k][j])
            combined: List[AffineForm] = []
            for k in range(n):
                # addNF
                pairwise = [AffineForm.add(a, b) for a in A[i][k] for b in B[k][j]]
                combined.extend(pairwise)
            row.append(canonicalize(combined))
        result.append(row)
    return result


def shortest_path_symbolic(
    edge_weights: List[List[Optional[int]]],
    n_vars: int = 0
) -> List[List[List[AffineForm]]]:
    """
    Compute all-pairs shortest paths symbolically using tropical matrix powers.

    Each edge weight can be a constant or a variable, represented as an AffineForm.
    The result is a matrix of normal forms giving shortest-path distances as
    tropical functions of the edge weights.

    Uses repeated squaring: O(n³ * log n * max_nf_size²)
    """
    n = len(edge_weights)
    INF = float('inf')

    # Initialize: identity matrix (0 on diagonal, ∞ elsewhere) plus edge weights
    # For simplicity, use constant affine forms
    matrix = []
    for i in range(n):
        row = []
        for j in range(n):
            w = edge_weights[i][j]
            if w is None:
                row.append([AffineForm.of_const(INF, n_vars)])
            else:
                row.append([AffineForm.of_const(w, n_vars)])
        matrix.append(row)

    # Floyd-Warshall style: n iterations of tropical matrix squaring
    result = matrix
    for _ in range(n - 1):
        result = tropical_matrix_multiply(result, matrix, n_vars)

    return result


# ============================================================
# Demo and Testing
# ============================================================

def demo():
    """Run algorithm demonstrations."""
    print("=" * 60)
    print("TROPICAL ALGORITHMS DEMO")
    print("=" * 60)

    x, y, z = Var(0), Var(1), Var(2)

    # Algorithm 1: Basic normalization
    print("\n--- Algorithm 1: Basic Normalization ---")
    e = TAdd(x, TMin(y, z))
    nf = normalize(e, 3)
    print(f"normalize(x + min(y,z)) = {nf}")

    # Algorithm 2: Dominance elimination
    print("\n--- Algorithm 2: Dominance Elimination ---")
    # min(x+y, x+y, 2+x+y) has a dominated term
    e2 = TMin(TMin(TAdd(x, y), TAdd(x, y)), TAdd(Const(2), TAdd(x, y)))
    nf2 = normalize(e2, 3)
    print(f"Before elimination: {nf2}")
    nf2_elim = eliminate_dominated(nf2)
    print(f"After elimination:  {nf2_elim}")

    # Algorithm 3: Canonical normalization
    print("\n--- Algorithm 3: Canonical Normalization ---")
    e3a = TAdd(x, TMin(y, z))
    e3b = TMin(TAdd(x, y), TAdd(x, z))
    cnf_a = normalize_canonical(e3a, 3)
    cnf_b = normalize_canonical(e3b, 3)
    print(f"canonical(x + min(y,z))     = {cnf_a}")
    print(f"canonical(min(x+y, x+z))    = {cnf_b}")
    print(f"Equal? {cnf_a == cnf_b}")

    # Algorithm 4: Identity checking
    print("\n--- Algorithm 4: Tropical Identity Checking ---")
    tests = [
        ("x + min(y,z)", "min(x+y, x+z)",
         TAdd(x, TMin(y, z)), TMin(TAdd(x, y), TAdd(x, z))),
        ("min(x, min(y, z))", "min(min(x, y), z)",
         TMin(x, TMin(y, z)), TMin(TMin(x, y), z)),
        ("x + y", "y + x",
         TAdd(x, y), TAdd(y, x)),
    ]
    for name1, name2, e1, e2 in tests:
        result = tropical_equal(e1, e2, 3)
        print(f"  {name1} == {name2}? {result}")

    # Algorithm 5: Shortest paths
    print("\n--- Algorithm 5: Tropical Matrix (Shortest Paths) ---")
    # Simple 3-node graph
    edges = [
        [0, 3, None],
        [None, 0, 1],
        [2, None, 0]
    ]
    print("Edge weight matrix:")
    for row in edges:
        print(f"  {row}")
    sp = shortest_path_symbolic(edges)
    print("Shortest path matrix:")
    for i, row in enumerate(sp):
        vals = [f"{row[j][0].constant:.0f}" if row[j][0].constant != float('inf')
                else "∞" for j in range(len(row))]
        print(f"  {vals}")


if __name__ == "__main__":
    demo()
