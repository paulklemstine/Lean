#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Tropical Exchange Descent

Implements the core algorithms from the research paper:
1. Exchange descent with depth certificate tracking
2. Verified descent chain checker
3. Improving exchange finder (greedy and random)
4. Depth certificate estimator
5. k-fold tropical concavity checker

All algorithms include docstrings, type hints, and example usage.
"""

from typing import (
    List, Tuple, Optional, Dict, Set, FrozenSet, Callable, NamedTuple
)
from itertools import combinations
import random

# Type aliases
Basis = FrozenSet[int]
Valuation = Dict[Basis, int]


class ExchangeResult(NamedTuple):
    """Result of an exchange step."""
    new_basis: Basis
    removed: int
    inserted: int
    potential_drop: int


class DescentPath(NamedTuple):
    """Complete descent path with metadata."""
    bases: List[Basis]
    potentials: List[int]
    steps: int
    total_drop: int
    terminated_optimal: bool


# ========== Core Data Structures ==========

class TropicalExchangeSystem:
    """A tropical exchange family with carrier, valuation, and potential.

    This is the computational counterpart of the Lean definition
    `TropicalExchangeFamily`.

    Args:
        ground_set: The ground set elements.
        carrier: Set of feasible bases (frozensets).
        val: Valuation function (basis → integer).
        phi: Potential function for descent (basis → integer).
              If None, uses -val as the potential (minimizing -val = maximizing val).
    """

    def __init__(self, ground_set: List[int], carrier: Set[Basis],
                 val: Valuation, phi: Optional[Valuation] = None):
        self.ground_set = ground_set
        self.carrier = carrier
        self.val = val
        self.phi = phi if phi is not None else {B: -val[B] for B in carrier}

    def is_feasible(self, B: Basis) -> bool:
        """Check if B is a feasible basis."""
        return B in self.carrier

    def potential(self, B: Basis) -> int:
        """Evaluate the potential function at B."""
        return self.phi.get(B, 10**9)

    def valuation(self, B: Basis) -> int:
        """Evaluate the valuation at B."""
        return self.val.get(B, 0)

    def exchange(self, B: Basis, x: int, y: int) -> Basis:
        """Perform exchange: remove x, insert y."""
        return (B - {x}) | {y}

    def exchange_neighbors(self, B: Basis) -> List[Tuple[Basis, int, int]]:
        """All feasible single-exchange neighbors of B.

        Returns:
            List of (B', x_removed, y_inserted) triples.
        """
        neighbors = []
        for x in B:
            for y in self.ground_set:
                if y not in B:
                    B_new = self.exchange(B, x, y)
                    if self.is_feasible(B_new):
                        neighbors.append((B_new, x, y))
        return neighbors

    def lower_bound(self) -> int:
        """Compute the lower bound of the potential on the carrier."""
        return min(self.phi[B] for B in self.carrier)

    def optimal_basis(self) -> Basis:
        """Find the Φ-optimal basis (brute force)."""
        return min(self.carrier, key=lambda B: self.phi[B])


# ========== Algorithm 1: Greedy Exchange Descent ==========

def greedy_exchange_descent(T: TropicalExchangeSystem,
                             B0: Basis,
                             max_steps: int = 10000) -> DescentPath:
    """Run greedy exchange descent from B0.

    At each step, choose the exchange neighbor with the largest
    potential drop. Corresponds to the steepest descent strategy.

    Args:
        T: The tropical exchange system.
        B0: Starting basis.
        max_steps: Maximum number of steps (safety limit).

    Returns:
        DescentPath with the complete trajectory.

    Example:
        >>> bases = [frozenset(c) for c in combinations(range(6), 3)]
        >>> val = {B: sum(i*i for i in B) for B in bases}
        >>> T = TropicalExchangeSystem(list(range(6)), set(bases), val)
        >>> path = greedy_exchange_descent(T, random.choice(bases))
        >>> print(f"Steps: {path.steps}, Drop: {path.total_drop}")
    """
    bases = [B0]
    potentials = [T.potential(B0)]
    B = B0

    for _ in range(max_steps):
        neighbors = T.exchange_neighbors(B)
        improving = [(B_new, x, y) for B_new, x, y in neighbors
                     if T.potential(B_new) < T.potential(B)]

        if not improving:
            break

        # Greedy: pick the best improvement
        best = min(improving, key=lambda t: T.potential(t[0]))
        B = best[0]
        bases.append(B)
        potentials.append(T.potential(B))

    total_drop = potentials[0] - potentials[-1]
    terminated = len(T.exchange_neighbors(B)) == 0 or \
                 all(T.potential(B_new) >= T.potential(B)
                     for B_new, _, _ in T.exchange_neighbors(B))

    return DescentPath(bases, potentials, len(bases) - 1, total_drop, terminated)


# ========== Algorithm 2: Random Exchange Descent ==========

def random_exchange_descent(T: TropicalExchangeSystem,
                             B0: Basis,
                             max_steps: int = 10000) -> DescentPath:
    """Run random exchange descent: at each step, pick a random improving neighbor.

    Args:
        T: The tropical exchange system.
        B0: Starting basis.
        max_steps: Maximum number of steps.

    Returns:
        DescentPath with the complete trajectory.
    """
    bases = [B0]
    potentials = [T.potential(B0)]
    B = B0

    for _ in range(max_steps):
        neighbors = T.exchange_neighbors(B)
        improving = [(B_new, x, y) for B_new, x, y in neighbors
                     if T.potential(B_new) < T.potential(B)]

        if not improving:
            break

        chosen = random.choice(improving)
        B = chosen[0]
        bases.append(B)
        potentials.append(T.potential(B))

    total_drop = potentials[0] - potentials[-1]
    terminated = not any(T.potential(B_new) < T.potential(B)
                         for B_new, _, _ in T.exchange_neighbors(B))

    return DescentPath(bases, potentials, len(bases) - 1, total_drop, terminated)


# ========== Algorithm 3: Verified Descent Chain Checker ==========

def verify_descent_chain(potentials: List[int]) -> bool:
    """Verify that a list of potential values is strictly decreasing.

    This is the Python counterpart of `verifyStrictlyDecreasing` in Lean.

    Args:
        potentials: List of integer potential values.

    Returns:
        True if each consecutive pair is strictly decreasing.

    Example:
        >>> verify_descent_chain([10, 7, 3, 1])
        True
        >>> verify_descent_chain([10, 7, 7, 1])
        False
    """
    return all(potentials[i] > potentials[i + 1]
               for i in range(len(potentials) - 1))


def check_descent_chain(potentials: List[int]) -> Optional[int]:
    """Verified descent chain check with total drop computation.

    Counterpart of `checkDescentChain` in Lean.

    Args:
        potentials: List of potential values.

    Returns:
        Total potential drop if chain is valid, None otherwise.
    """
    if not potentials:
        return None
    if len(potentials) == 1:
        return 0
    if verify_descent_chain(potentials):
        return potentials[0] - potentials[-1]
    return None


# ========== Algorithm 4: Depth Certificate Estimator ==========

def estimate_depth_certificate(T: TropicalExchangeSystem,
                                num_samples: int = 100) -> Tuple[int, int]:
    """Estimate the depth certificate parameters (k, lb) empirically.

    Samples random non-optimal bases and their improving neighbors
    to estimate the minimum potential drop per step (k) and the
    global lower bound (lb).

    Args:
        T: The tropical exchange system.
        num_samples: Number of random samples.

    Returns:
        (k_estimate, lb) where k_estimate is the minimum observed
        potential drop and lb is the global potential lower bound.

    Example:
        >>> # ... setup T ...
        >>> k, lb = estimate_depth_certificate(T)
        >>> print(f"Estimated depth k={k}, lower bound lb={lb}")
    """
    lb = T.lower_bound()
    min_drop = float('inf')

    bases_list = list(T.carrier)
    optimal_phi = lb

    for _ in range(min(num_samples, len(bases_list))):
        B = random.choice(bases_list)
        if T.potential(B) <= optimal_phi:
            continue

        neighbors = T.exchange_neighbors(B)
        improving = [(B_new, x, y) for B_new, x, y in neighbors
                     if T.potential(B_new) < T.potential(B)]

        if improving:
            best_drop = max(T.potential(B) - T.potential(B_new)
                           for B_new, _, _ in improving)
            min_drop = min(min_drop, best_drop)

    k_estimate = int(min_drop) if min_drop < float('inf') else 1
    return max(k_estimate, 1), lb


# ========== Algorithm 5: k-Fold Tropical Concavity Checker ==========

def check_exchange_inequality(val: Valuation, bases: Set[Basis],
                               ground_set: List[int]) -> bool:
    """Check the tropical exchange inequality for a valuation.

    For all B₁, B₂ and x ∈ B₁ \\ B₂, verify there exists y ∈ B₂ \\ B₁
    with val(B₁) + val(B₂) ≤ val(B₁') + val(B₂').

    Args:
        val: Valuation dictionary.
        bases: Set of bases to check.
        ground_set: Ground set elements.

    Returns:
        True if the exchange inequality holds for all pairs.
    """
    for B1 in bases:
        for B2 in bases:
            for x in B1 - B2:
                found = False
                for y in B2 - B1:
                    B1_new = (B1 - {x}) | {y}
                    B2_new = (B2 - {y}) | {x}
                    if B1_new in bases:
                        lhs = val.get(B1, 0) + val.get(B2, 0)
                        rhs = val.get(B1_new, 0) + val.get(B2_new, 0)
                        if lhs <= rhs:
                            found = True
                            break
                if not found:
                    return False
    return True


# ========== Algorithm 6: Bound Witness ==========

def bound_witness(T: TropicalExchangeSystem, B0: Basis,
                   k: int = 1) -> Dict[str, int]:
    """Compute the theoretical bound and compare with actual descent.

    Args:
        T: The tropical exchange system.
        B0: Starting basis.
        k: Depth certificate order.

    Returns:
        Dictionary with bound analysis.
    """
    path = greedy_exchange_descent(T, B0)
    lb = T.lower_bound()
    phi0 = T.potential(B0)
    gap = phi0 - lb

    theoretical_bound = gap // k if k > 0 else gap
    actual_steps = path.steps

    return {
        "initial_potential": phi0,
        "lower_bound": lb,
        "initial_gap": gap,
        "depth_k": k,
        "theoretical_bound": theoretical_bound,
        "actual_steps": actual_steps,
        "ratio": actual_steps / theoretical_bound if theoretical_bound > 0 else 0,
        "terminated_optimal": path.terminated_optimal,
    }


# ========== Utility: Matroid Generators ==========

def uniform_matroid(n: int, r: int) -> Set[Basis]:
    """Generate all bases of the uniform matroid U(r, n)."""
    return {frozenset(c) for c in combinations(range(n), r)}


def make_lorentzian_system(n: int, r: int) -> TropicalExchangeSystem:
    """Create a tropical exchange system with Lorentzian-inspired valuation."""
    bases = uniform_matroid(n, r)
    val = {B: sum(i * i for i in B) for B in bases}
    return TropicalExchangeSystem(list(range(n)), bases, val)


def make_random_system(n: int, r: int, val_range: int = 100) -> TropicalExchangeSystem:
    """Create a tropical exchange system with random valuation."""
    bases = uniform_matroid(n, r)
    val = {B: random.randint(0, val_range) for B in bases}
    return TropicalExchangeSystem(list(range(n)), bases, val)


# ========== Example Usage ==========

if __name__ == "__main__":
    random.seed(42)

    print("=== Algorithm Demonstrations ===\n")

    # Create a small example
    T = make_lorentzian_system(7, 3)
    B0 = random.choice(list(T.carrier))

    # Algorithm 1: Greedy descent
    path = greedy_exchange_descent(T, B0)
    print(f"Greedy descent: {path.steps} steps, drop = {path.total_drop}, "
          f"optimal = {path.terminated_optimal}")

    # Algorithm 2: Random descent
    path_r = random_exchange_descent(T, B0)
    print(f"Random descent: {path_r.steps} steps, drop = {path_r.total_drop}")

    # Algorithm 3: Verify chain
    valid = verify_descent_chain(path.potentials)
    drop = check_descent_chain(path.potentials)
    print(f"Chain valid: {valid}, total drop: {drop}")

    # Algorithm 4: Estimate certificate
    k, lb = estimate_depth_certificate(T)
    print(f"Estimated depth k={k}, lower bound lb={lb}")

    # Algorithm 5: Check exchange inequality
    holds = check_exchange_inequality(T.val, T.carrier, T.ground_set)
    print(f"Exchange inequality holds: {holds}")

    # Algorithm 6: Bound witness
    witness = bound_witness(T, B0)
    print(f"\nBound analysis:")
    for key, value in witness.items():
        print(f"  {key}: {value}")
