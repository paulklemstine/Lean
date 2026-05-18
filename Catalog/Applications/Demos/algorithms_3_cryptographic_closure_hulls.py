#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Cryptographic Closure Hulls.

Implements:
1. SecureKeySpace verification (predicate checker)
2. Orbit closure computation (constructive hull)
3. Secure closure via intersection (Moore family)
4. Existence oracle (bounded seed detection)
5. Monotonicity and idempotence verification
"""

import numpy as np
from typing import Callable, List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class SecureKeySpaceResult:
    """Result of a SecureKeySpace verification."""
    is_secure: bool
    has_zero: bool
    is_red_stable: bool
    is_bounded: bool
    max_norm: float
    violations: List[str]


def verify_secure_key_space(
    S: List[np.ndarray],
    red: Callable[[np.ndarray], np.ndarray],
    B: float,
    tol: float = 1e-10
) -> SecureKeySpaceResult:
    """
    Verify the SecureKeySpace(red, B, S) predicate.

    Checks:
      1. 0 ∈ S
      2. ∀ v ∈ S, red(v) ∈ S
      3. ∀ v ∈ S, ‖v‖ ≤ B

    Time complexity: O(|S|² · d) where d is the dimension.
    Space complexity: O(|S| · d).

    Parameters
    ----------
    S : list of numpy arrays
        The candidate key space (finite approximation).
    red : callable
        The reduction operator V → V.
    B : float
        The security radius bound.
    tol : float
        Numerical tolerance for membership checks.

    Returns
    -------
    SecureKeySpaceResult
        Detailed verification result.
    """
    violations = []

    # Check 1: zero membership
    has_zero = any(np.linalg.norm(v) < tol for v in S)
    if not has_zero:
        violations.append("Zero vector not found in S")

    # Check 2: reduction stability
    is_red_stable = True
    for v in S:
        rv = red(v)
        if not any(np.linalg.norm(rv - w) < tol for w in S):
            is_red_stable = False
            violations.append(f"red({v}) = {rv} not in S")

    # Check 3: norm bound
    norms = [np.linalg.norm(v) for v in S]
    max_norm = max(norms) if norms else 0.0
    is_bounded = all(n <= B + tol for n in norms)
    if not is_bounded:
        for v, n in zip(S, norms):
            if n > B + tol:
                violations.append(f"‖{v}‖ = {n:.6f} > B = {B}")

    return SecureKeySpaceResult(
        is_secure=has_zero and is_red_stable and is_bounded,
        has_zero=has_zero,
        is_red_stable=is_red_stable,
        is_bounded=is_bounded,
        max_norm=max_norm,
        violations=violations
    )


def compute_red_orbit_closure(
    seed: List[np.ndarray],
    red: Callable[[np.ndarray], np.ndarray],
    B: float,
    max_iterations: int = 10000,
    tol: float = 1e-10
) -> Tuple[List[np.ndarray], dict]:
    """
    Compute the RedOrbitClosure constructively.

    This implements the inductive definition:
      - base: v ∈ A → v ∈ closure
      - zero: 0 ∈ closure
      - step: v ∈ closure → red(v) ∈ closure

    Additionally filters by the norm bound ‖v‖ ≤ B.

    Time complexity: O(k · |closure|² · d) where k is the number of iterations.
    Space complexity: O(|closure| · d).

    Parameters
    ----------
    seed : list of numpy arrays
        The initial seed set A.
    red : callable
        The reduction operator.
    B : float
        The security radius.
    max_iterations : int
        Maximum number of expansion rounds.
    tol : float
        Numerical tolerance.

    Returns
    -------
    closure : list of numpy arrays
    stats : dict with iteration count and growth history
    """
    dim = seed[0].shape[0] if seed else 2

    def is_member(v, lst):
        return any(np.linalg.norm(v - w) < tol for w in lst)

    # Initialize with zero
    closure = [np.zeros(dim)]
    growth_history = [1]

    # Add bounded seed elements
    for v in seed:
        if np.linalg.norm(v) <= B + tol and not is_member(v, closure):
            closure.append(v.copy())
    growth_history.append(len(closure))

    # Iterate reduction
    for iteration in range(max_iterations):
        new_elements = []
        for v in closure:
            rv = red(v)
            n = np.linalg.norm(rv)
            if n <= B + tol and not is_member(rv, closure + new_elements):
                new_elements.append(rv)

        if not new_elements:
            break
        closure.extend(new_elements)
        growth_history.append(len(closure))

    stats = {
        "iterations": iteration + 1 if seed else 0,
        "final_size": len(closure),
        "growth_history": growth_history,
        "stabilized": len(growth_history) < max_iterations + 2,
    }

    return closure, stats


def check_existence_criterion(
    seed: List[np.ndarray],
    B: float,
    red: Optional[Callable] = None,
) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Check the existence criterion: ∀ v ∈ A, ‖v‖ ≤ B.

    This is the decision procedure for whether a secure closure exists.
    Under the hypotheses that red fixes zero and preserves the bound,
    this is equivalent to the existence of any secure superset.

    Time complexity: O(|A| · d).

    Parameters
    ----------
    seed : list of numpy arrays
        The seed set A.
    B : float
        The security radius.

    Returns
    -------
    exists : bool
        Whether a secure key space containing the seed exists.
    witness : optional numpy array
        If exists is False, a witness vector exceeding the bound.
    """
    for v in seed:
        if np.linalg.norm(v) > B:
            return False, v
    return True, None


def secure_closure_intersection(
    seed: List[np.ndarray],
    secure_spaces: List[List[np.ndarray]],
    tol: float = 1e-10,
) -> List[np.ndarray]:
    """
    Compute the secure closure as intersection of all secure supersets.

    This is the impredicative definition:
      secureClosure(A) = ⋂ {S | A ⊆ S ∧ SecureKeySpace(red, B, S)}

    For finite representations, this computes the intersection of
    the provided secure spaces that contain the seed.

    Parameters
    ----------
    seed : list of numpy arrays
    secure_spaces : list of lists of numpy arrays
    tol : float

    Returns
    -------
    intersection : list of numpy arrays
    """
    if not secure_spaces:
        return []

    def contains_seed(space, seed, tol):
        for v in seed:
            if not any(np.linalg.norm(v - w) < tol for w in space):
                return False
        return True

    # Filter to spaces containing the seed
    containing = [sp for sp in secure_spaces if contains_seed(sp, seed, tol)]
    if not containing:
        return []

    # Intersect
    result = list(containing[0])
    for space in containing[1:]:
        result = [v for v in result
                  if any(np.linalg.norm(v - w) < tol for w in space)]

    return result


def verify_monotonicity(
    seed1: List[np.ndarray],
    seed2: List[np.ndarray],
    red: Callable,
    B: float,
    tol: float = 1e-10,
) -> bool:
    """
    Verify monotonicity: if seed1 ⊆ seed2, then closure(seed1) ⊆ closure(seed2).

    Parameters
    ----------
    seed1, seed2 : lists of numpy arrays
    red : callable
    B : float

    Returns
    -------
    bool
        Whether monotonicity holds for these inputs.
    """
    def is_subset(L1, L2):
        for v in L1:
            if not any(np.linalg.norm(v - w) < tol for w in L2):
                return False
        return True

    # Check seed1 ⊆ seed2
    if not is_subset(seed1, seed2):
        return True  # vacuously true if seed1 ⊄ seed2

    c1, _ = compute_red_orbit_closure(seed1, red, B)
    c2, _ = compute_red_orbit_closure(seed2, red, B)

    return is_subset(c1, c2)


def verify_idempotence(
    seed: List[np.ndarray],
    red: Callable,
    B: float,
    tol: float = 1e-10,
) -> bool:
    """
    Verify idempotence: closure(closure(A)) = closure(A).

    Parameters
    ----------
    seed : list of numpy arrays
    red : callable
    B : float

    Returns
    -------
    bool
    """
    def sets_equal(L1, L2):
        if len(L1) != len(L2):
            return False
        for v in L1:
            if not any(np.linalg.norm(v - w) < tol for w in L2):
                return False
        for v in L2:
            if not any(np.linalg.norm(v - w) < tol for w in L1):
                return False
        return True

    c1, _ = compute_red_orbit_closure(seed, red, B)
    c2, _ = compute_red_orbit_closure(c1, red, B)

    return sets_equal(c1, c2)


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithms for Cryptographic Closure Hulls")
    print("=" * 50)

    # Define a reduction operator
    def lattice_red(v):
        """Simulate lattice basis reduction: round toward shorter vector."""
        return np.round(v * 0.8)

    B = 5.0
    seed = [np.array([3.0, 4.0]), np.array([-2.0, 1.0])]

    # Compute orbit closure
    closure, stats = compute_red_orbit_closure(seed, lattice_red, B)
    print(f"\nOrbit closure of {[str(v) for v in seed]}:")
    print(f"  Size: {stats['final_size']}")
    print(f"  Iterations: {stats['iterations']}")
    print(f"  Stabilized: {stats['stabilized']}")

    # Verify it's secure
    result = verify_secure_key_space(closure, lattice_red, B)
    print(f"\nVerification:")
    print(f"  Is secure: {result.is_secure}")
    print(f"  Has zero: {result.has_zero}")
    print(f"  Red-stable: {result.is_red_stable}")
    print(f"  Bounded: {result.is_bounded}")
    print(f"  Max norm: {result.max_norm:.4f}")

    # Check existence criterion
    exists, witness = check_existence_criterion(seed, B)
    print(f"\nExistence criterion: {exists}")

    # Check with unbounded seed
    bad_seed = seed + [np.array([10.0, 0.0])]
    exists2, witness2 = check_existence_criterion(bad_seed, B)
    print(f"With oversized key [10, 0]: exists = {exists2}, witness = {witness2}")

    # Verify properties
    print(f"\nMonotonicity check: {verify_monotonicity(seed[:1], seed, lattice_red, B)}")
    print(f"Idempotence check: {verify_idempotence(seed, lattice_red, B)}")
