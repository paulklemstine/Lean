#!/usr/bin/env python3
"""
Exchange Descent Algorithms — Certified Optimization on Exchange Systems

Implements the exchange descent algorithm with full correctness guarantees
matching the formally verified Lean theorems:

1. ExchangeDescent: greedy improving exchange on finite feasible sets
2. DLC verification: check directional exchange certificates
3. Exchange family construction: matroid bases, polymatroid vertices
4. Certificate depth estimation

Type hints and docstrings throughout.
"""

from __future__ import annotations

import itertools
from dataclasses import dataclass, field
from math import comb
from typing import Callable, List, Optional, Set, Tuple

import numpy as np


# ──────────────────────────────────────────────────────────────────────
# Types
# ──────────────────────────────────────────────────────────────────────

Vector = np.ndarray  # shape (n,), dtype int
Objective = Callable[[Vector], float]


# ──────────────────────────────────────────────────────────────────────
# Exchange Family
# ──────────────────────────────────────────────────────────────────────

@dataclass
class ExchangeFamily:
    """
    An abstract exchange family on integer vectors.

    Attributes:
        carrier: set of feasible vectors (as tuples for hashing)
        n: dimension of the ambient space
    """
    carrier: Set[Tuple[int, ...]]
    n: int

    def __contains__(self, x: Vector) -> bool:
        return tuple(x) in self.carrier

    def __iter__(self):
        return (np.array(v) for v in self.carrier)

    def __len__(self):
        return len(self.carrier)

    @staticmethod
    def from_vectors(vectors: List[Vector]) -> "ExchangeFamily":
        """Create an exchange family from a list of vectors."""
        n = len(vectors[0]) if vectors else 0
        carrier = set(tuple(v) for v in vectors)
        return ExchangeFamily(carrier=carrier, n=n)

    @staticmethod
    def uniform_matroid(n: int, r: int) -> "ExchangeFamily":
        """
        Bases of the uniform matroid U(r, n).

        Each basis is an indicator vector of a size-r subset of {0,...,n-1}.
        The exchange axiom holds: if x,y are bases and x_i > y_i,
        then x_i = 1, y_i = 0, so there exists j with x_j = 0, y_j = 1,
        and x - e_i + e_j is a valid basis.
        """
        bases = []
        for subset in itertools.combinations(range(n), r):
            v = np.zeros(n, dtype=int)
            for i in subset:
                v[i] = 1
            bases.append(v)
        return ExchangeFamily.from_vectors(bases)

    @staticmethod
    def partition_matroid(groups: List[List[int]], n: int) -> "ExchangeFamily":
        """
        Bases of a partition matroid: select exactly one element from each group.
        """
        bases = []
        for combo in itertools.product(*groups):
            v = np.zeros(n, dtype=int)
            for i in combo:
                v[i] = 1
            bases.append(v)
        return ExchangeFamily.from_vectors(bases)

    def verify_exchange_axiom(self) -> bool:
        """Verify the exchange axiom holds."""
        for xt in self.carrier:
            x = np.array(xt)
            for yt in self.carrier:
                y = np.array(yt)
                for i in range(self.n):
                    if x[i] > y[i]:
                        found = False
                        for j in range(self.n):
                            if x[j] < y[j]:
                                z = exchange_move(x, j, i)
                                if tuple(z) in self.carrier:
                                    found = True
                                    break
                        if not found:
                            return False
        return True

    def diameter(self) -> int:
        """Compute the L1 diameter of the carrier."""
        max_dist = 0
        vectors = [np.array(v) for v in self.carrier]
        for x in vectors:
            for y in vectors:
                d = int(np.sum(np.abs(x - y)))
                max_dist = max(max_dist, d)
        return max_dist


# ──────────────────────────────────────────────────────────────────────
# Exchange moves
# ──────────────────────────────────────────────────────────────────────

def exchange_move(x: Vector, i: int, j: int) -> Vector:
    """Compute x + e_i - e_j."""
    y = x.copy()
    y[i] += 1
    y[j] -= 1
    return y


def exchange_neighbors(x: Vector, family: ExchangeFamily) -> List[Tuple[int, int, Vector]]:
    """
    Find all feasible exchange neighbors of x.

    Returns list of (i, j, y) where y = x + e_i - e_j is feasible.
    """
    neighbors = []
    for i in range(family.n):
        for j in range(family.n):
            if i == j:
                continue
            y = exchange_move(x, i, j)
            if y in family:
                neighbors.append((i, j, y))
    return neighbors


# ──────────────────────────────────────────────────────────────────────
# Exchange Descent Algorithm
# ──────────────────────────────────────────────────────────────────────

@dataclass
class DescentResult:
    """Result of the exchange descent algorithm."""
    trajectory: List[Tuple[Vector, float]]
    num_steps: int
    is_local_min: bool
    is_global_min: Optional[bool] = None
    dlc_verified: Optional[bool] = None

    @property
    def final_point(self) -> Vector:
        return self.trajectory[-1][0]

    @property
    def final_value(self) -> float:
        return self.trajectory[-1][1]


def exchange_descent(
    family: ExchangeFamily,
    f: Objective,
    x0: Vector,
    strategy: str = "best",
) -> DescentResult:
    """
    Run the exchange descent algorithm.

    Args:
        family: the exchange family (feasible set)
        f: objective function to minimize
        x0: starting point (must be feasible)
        strategy: "best" for steepest descent, "first" for first improvement

    Returns:
        DescentResult with trajectory and metadata

    Correctness guarantees (matching Lean theorems):
        1. Every step remains feasible (descent_chain_feasible)
        2. Objective strictly decreases (descent_chain_strict_decrease)
        3. Algorithm terminates (exchangeDescent_wellFounded)
        4. Terminal point is exchange-local minimum (exchangeDescent_terminates_at_localMin)
    """
    assert x0 in family, "Starting point must be feasible"

    x = x0.copy()
    trajectory = [(x.copy(), f(x))]
    step = 0

    while True:
        neighbors = exchange_neighbors(x, family)
        fx = f(x)

        # Find improving move
        improving = [(i, j, y, f(y)) for i, j, y in neighbors if f(y) < fx - 1e-15]

        if not improving:
            break

        if strategy == "best":
            # Steepest descent
            _, _, y, fy = min(improving, key=lambda t: t[3])
        else:
            # First improvement
            _, _, y, fy = improving[0]

        x = y.copy()
        step += 1
        trajectory.append((x.copy(), fy))

    return DescentResult(
        trajectory=trajectory,
        num_steps=step,
        is_local_min=True,  # guaranteed by termination
    )


# ──────────────────────────────────────────────────────────────────────
# DLC Verification
# ──────────────────────────────────────────────────────────────────────

def verify_exchange_dlc(family: ExchangeFamily, f: Objective) -> bool:
    """
    Verify the directional exchange certificate (DLC).

    For every x, y in the carrier with f(y) < f(x), checks that there
    exists an improving exchange from x.

    This is the key condition for the local-implies-global theorem.
    """
    vectors = list(family)

    for x in vectors:
        for y in vectors:
            if f(y) < f(x) - 1e-12:
                # Must find improving exchange from x
                found = False
                for i, j, z in exchange_neighbors(x, family):
                    if f(z) < f(x) - 1e-12:
                        found = True
                        break
                if not found:
                    return False
    return True


def verify_local_implies_global(family: ExchangeFamily, f: Objective) -> bool:
    """
    Verify Theorem 1: every exchange-local minimum is global.

    Checks this directly by finding all local and global minima.
    """
    vectors = list(family)
    global_min = min(f(v) for v in vectors)

    for x in vectors:
        # Check if x is a local minimum
        is_local = True
        for i, j, y in exchange_neighbors(x, family):
            if f(y) < f(x) - 1e-12:
                is_local = False
                break

        if is_local and abs(f(x) - global_min) > 1e-10:
            return False

    return True


# ──────────────────────────────────────────────────────────────────────
# Certificate Depth Estimation
# ──────────────────────────────────────────────────────────────────────

def estimate_certificate_depth(
    family: ExchangeFamily,
    f: Objective,
    max_depth: int = 10,
) -> int:
    """
    Estimate the depth of the directional exchange certificate.

    At depth 0, no condition is required (trivially true).
    At depth k+1, we require the DLC plus depth k.

    Since ExchangeDLC_k is defined as ExchangeDLC ∧ ExchangeDLC_k (k-1),
    the depth is either 0 (if DLC fails) or ∞ (if DLC holds).

    For more nuanced depth estimation, we could use quantitative
    measures of how strongly the DLC condition holds.
    """
    if not verify_exchange_dlc(family, f):
        return 0
    # If DLC holds, all finite depths are satisfied
    return max_depth


# ──────────────────────────────────────────────────────────────────────
# Coefficient Objectives
# ──────────────────────────────────────────────────────────────────────

def binomial_coefficient_objective(params: List[int]) -> Objective:
    """
    Coefficient objective from product of binomials:
    coeff(x) = product of C(p_i, x_i).

    Used for cross-domain bridge: algebraic log-concavity → optimization.
    """
    def f(x: Vector) -> float:
        val = 1.0
        for i, p in enumerate(params):
            xi = int(x[i])
            if xi < 0 or xi > p:
                return 0.0
            val *= comb(p, xi)
        return val
    return f


# ──────────────────────────────────────────────────────────────────────
# Complete certified optimization pipeline
# ──────────────────────────────────────────────────────────────────────

def certified_exchange_optimization(
    family: ExchangeFamily,
    f: Objective,
    x0: Optional[Vector] = None,
    verify: bool = True,
) -> DescentResult:
    """
    Complete certified optimization pipeline.

    1. Optionally verify DLC
    2. Run exchange descent
    3. Verify global optimality
    4. Return certified result

    This implements the verified algorithm from the Lean development:
    - exchangeDescent_terminates_at_localMin: terminal point is local min
    - isExchangeLocalMin_isGlobal: local min is global (if DLC holds)
    - exchangeDescent_terminates_at_globalMin: combining both
    """
    if x0 is None:
        x0 = next(iter(family))

    # Step 1: Verify DLC (optional but recommended)
    dlc_ok = None
    if verify:
        dlc_ok = verify_exchange_dlc(family, f)

    # Step 2: Run descent
    result = exchange_descent(family, f, x0)
    result.dlc_verified = dlc_ok

    # Step 3: Verify global optimality
    if verify:
        global_min = min(f(v) for v in family)
        result.is_global_min = abs(result.final_value - global_min) < 1e-10

    return result


# ──────────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Exchange Descent Algorithms — Example Usage")
    print("=" * 50)

    # Create a uniform matroid
    E = ExchangeFamily.uniform_matroid(6, 3)
    print(f"\nExchange family: U(3, 6) with {len(E)} bases")
    print(f"Exchange axiom: {E.verify_exchange_axiom()}")
    print(f"Diameter: {E.diameter()}")

    # Linear objective
    weights = np.array([5.0, 3.0, 1.0, -1.0, -3.0, -5.0])
    f = lambda x: float(np.dot(weights, x))

    # Certified optimization
    x0 = np.array([1, 1, 1, 0, 0, 0])
    result = certified_exchange_optimization(E, f, x0)

    print(f"\nStarting point: {x0}, f = {f(x0):.4f}")
    print(f"Final point: {result.final_point}, f = {result.final_value:.4f}")
    print(f"Steps: {result.num_steps}")
    print(f"Local minimum: {result.is_local_min}")
    print(f"DLC verified: {result.dlc_verified}")
    print(f"Global minimum: {result.is_global_min}")
