#!/usr/bin/env python3
"""
Closure-Stone Realization Duality: Core Algorithms

Implements the algorithmic content of the reconstruction theorem:
1. Closure operator construction from dependencies
2. Closed set enumeration
3. Full basis extraction
4. Forward-chaining closure computation
5. Prime spectrum computation
6. Canonical basis reduction (heuristic)
7. Closure table isomorphism verification

All algorithms include type hints, docstrings, and complexity analysis.
"""

from itertools import combinations
from typing import Callable, FrozenSet, Set, List, Tuple, Optional, Dict


# ============================================================
# Core Types
# ============================================================

Element = int
Subset = FrozenSet[Element]
Implication = Tuple[FrozenSet[Element], Element]


# ============================================================
# Algorithm 1: Closure Operator Construction
# ============================================================

def make_closure_from_deps(
    universe: Set[Element],
    deps: List[Implication]
) -> Callable[[Subset], Subset]:
    """
    Construct a closure operator from functional dependencies.

    Args:
        universe: The finite ground set X.
        deps: List of (premise, conclusion) pairs.

    Returns:
        A closure function cl: Subset -> Subset.

    Complexity: O(|X| * |deps|) per closure call.
    """
    def cl(A: Subset) -> Subset:
        result = set(A)
        changed = True
        while changed:
            changed = False
            for premise, conclusion in deps:
                if premise <= result and conclusion not in result:
                    result.add(conclusion)
                    changed = True
        return frozenset(result)
    return cl


# ============================================================
# Algorithm 2: Powerset and Closed Set Enumeration
# ============================================================

def powerset(X: Set[Element]) -> List[Subset]:
    """
    Generate all subsets of X.

    Complexity: O(2^|X|).
    """
    items = sorted(X)
    result = []
    for r in range(len(items) + 1):
        for combo in combinations(items, r):
            result.append(frozenset(combo))
    return result


def enumerate_closed_sets(
    X: Set[Element],
    cl: Callable[[Subset], Subset]
) -> List[Subset]:
    """
    Enumerate all closed sets of a closure operator.

    A set A is closed if cl(A) = A.

    Complexity: O(2^|X| * T_cl) where T_cl is the cost of one closure call.

    Args:
        X: Universe.
        cl: Closure operator.

    Returns:
        Sorted list of closed sets.
    """
    closed = []
    for S in powerset(X):
        if cl(S) == S:
            closed.append(S)
    return sorted(closed, key=lambda s: (len(s), sorted(s)))


# ============================================================
# Algorithm 3: Full Basis Extraction
# ============================================================

def extract_full_basis(
    X: Set[Element],
    cl: Callable[[Subset], Subset]
) -> List[Implication]:
    """
    Extract the full implicational basis.

    The full basis contains all (S, x) where x ∈ cl(S).
    This is sound and complete by the reconstruction theorem.

    Complexity: O(2^|X| * |X| * T_cl).

    Args:
        X: Universe.
        cl: Closure operator.

    Returns:
        List of (premise, conclusion) pairs.
    """
    basis = []
    for S in powerset(X):
        closure = cl(S)
        for x in sorted(closure - S):
            basis.append((S, x))
    return basis


# ============================================================
# Algorithm 4: Forward Chaining
# ============================================================

def forward_chain(
    basis: List[Implication],
    A: Subset
) -> Subset:
    """
    Compute closure of A under implications by forward chaining.

    Repeatedly applies all applicable implications until fixpoint.

    Complexity: O(|X| * |basis|) total, since at most |X| elements added.

    Args:
        basis: Set of implications.
        A: Initial set.

    Returns:
        Closure of A under the basis.
    """
    result = set(A)
    changed = True
    while changed:
        changed = False
        for premise, conclusion in basis:
            if premise <= result and conclusion not in result:
                result.add(conclusion)
                changed = True
    return frozenset(result)


# ============================================================
# Algorithm 5: Prime Spectrum Computation
# ============================================================

def is_meet_prime(
    P: Subset,
    closed_sets: List[Subset],
    X: Set[Element]
) -> bool:
    """
    Check if P is meet-prime among the closed sets.

    P is meet-prime if P ≠ X and for all closed A, B:
    A ∩ B ⊆ P implies A ⊆ P or B ⊆ P.

    Complexity: O(|closed|^2 * |X|).
    """
    if P == frozenset(X):
        return False
    for A in closed_sets:
        for B in closed_sets:
            if (A & B) <= P and not A <= P and not B <= P:
                return False
    return True


def compute_prime_spectrum(
    X: Set[Element],
    cl: Callable[[Subset], Subset]
) -> List[Subset]:
    """
    Compute the prime spectrum of a closure operator.

    Returns all meet-prime closed sets.

    Complexity: O(2^|X| * T_cl + |closed|^3 * |X|).
    """
    closed = enumerate_closed_sets(X, cl)
    return [P for P in closed if is_meet_prime(P, closed, X)]


# ============================================================
# Algorithm 6: Reduced Basis (Heuristic)
# ============================================================

def reduce_basis(
    X: Set[Element],
    cl: Callable[[Subset], Subset],
    full_basis: List[Implication]
) -> List[Implication]:
    """
    Heuristically reduce the full basis by removing redundant implications.

    An implication (S, x) is redundant if removing it doesn't change
    the closure operator.

    Complexity: O(|basis|^2 * 2^|X| * T_cl) in worst case.

    Args:
        X: Universe.
        cl: Original closure operator.
        full_basis: The full basis to reduce.

    Returns:
        A reduced (possibly minimal) basis.
    """
    all_subsets = powerset(X)
    reduced = list(full_basis)

    i = 0
    while i < len(reduced):
        # Try removing implication i
        candidate = reduced[:i] + reduced[i+1:]
        # Check if candidate still generates cl
        is_redundant = True
        for S in all_subsets:
            if forward_chain(candidate, S) != cl(S):
                is_redundant = False
                break
        if is_redundant:
            reduced = candidate
        else:
            i += 1

    return reduced


# ============================================================
# Algorithm 7: Closure Table Isomorphism Check
# ============================================================

def verify_closure_iso(
    X: Set[Element],
    Y: Set[Element],
    cl_X: Callable[[Subset], Subset],
    cl_Y: Callable[[Subset], Subset],
    f: Dict[Element, Element]
) -> bool:
    """
    Verify that f is a closure table isomorphism from (X, cl_X) to (Y, cl_Y).

    Checks: f(cl_X(A)) = cl_Y(f(A)) for all A ⊆ X.

    Complexity: O(2^|X| * (T_clX + T_clY)).
    """
    for S in powerset(X):
        f_cl = frozenset(f[x] for x in cl_X(S))
        cl_f = cl_Y(frozenset(f[x] for x in S))
        if f_cl != cl_f:
            return False
    return True


# ============================================================
# Algorithm 8: Verification Suite
# ============================================================

def verify_closure_axioms(
    X: Set[Element],
    cl: Callable[[Subset], Subset]
) -> Dict[str, bool]:
    """
    Verify all closure operator axioms.

    Returns dict with keys 'extensive', 'monotone', 'idempotent'.
    """
    all_subsets = powerset(X)
    return {
        'extensive': all(S <= cl(S) for S in all_subsets),
        'monotone': all(
            cl(A) <= cl(B)
            for A in all_subsets
            for B in all_subsets
            if A <= B
        ),
        'idempotent': all(cl(cl(S)) == cl(S) for S in all_subsets),
    }


def verify_reconstruction(
    X: Set[Element],
    cl: Callable[[Subset], Subset],
    basis: List[Implication]
) -> bool:
    """Verify that forward_chain(basis, ·) = cl(·) on all subsets."""
    return all(
        forward_chain(basis, S) == cl(S)
        for S in powerset(X)
    )


def verify_separation(
    closed_sets: List[Subset],
    primes: List[Subset]
) -> bool:
    """Verify that primes separate all pairs of distinct closed sets."""
    for i, A in enumerate(closed_sets):
        for B in closed_sets[i+1:]:
            separated = any(
                (A <= P and not B <= P) or (B <= P and not A <= P)
                for P in primes
            )
            if not separated:
                return False
    return True


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example: closure on {0, 1, 2, 3}
    X = {0, 1, 2, 3}
    deps = [
        (frozenset({0}), 1),
        (frozenset({1}), 2),
    ]
    cl = make_closure_from_deps(X, deps)

    print("=== Closure Operator Verification ===")
    axioms = verify_closure_axioms(X, cl)
    for name, ok in axioms.items():
        print(f"  {name}: {ok}")

    print("\n=== Closed Sets ===")
    closed = enumerate_closed_sets(X, cl)
    for C in closed:
        print(f"  {set(C)}")

    print("\n=== Full Basis ===")
    basis = extract_full_basis(X, cl)
    print(f"  {len(basis)} implications")

    print("\n=== Reduced Basis ===")
    reduced = reduce_basis(X, cl, basis)
    for p, c in reduced:
        print(f"  {set(p)} → {c}")
    print(f"  Reconstruction verified: {verify_reconstruction(X, cl, reduced)}")

    print("\n=== Prime Spectrum ===")
    primes = compute_prime_spectrum(X, cl)
    for P in primes:
        print(f"  {set(P)}")
    print(f"  Separation verified: {verify_separation(closed, primes)}")
