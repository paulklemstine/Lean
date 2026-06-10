#!/usr/bin/env python3
"""
Algorithms for Closure-Capacity Secret-Sharing Duality

Implements the core algorithms from the research paper:
1. Closure operator construction and verification
2. Authorized coalition enumeration
3. Minimal authorized set computation
4. Reconstruction data extraction
5. Submodularity verification
"""

import itertools
from typing import Callable, FrozenSet, Set, List, Tuple, Optional


Element = int
Coalition = FrozenSet[Element]


def enumerate_subsets(universe: Set[Element]) -> List[Coalition]:
    """Enumerate all subsets of a finite universe."""
    elems = sorted(universe)
    result = []
    for r in range(len(elems) + 1):
        for combo in itertools.combinations(elems, r):
            result.append(frozenset(combo))
    return result


def verify_closure_axioms(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition]
) -> Tuple[bool, Optional[str]]:
    """
    Verify that cl satisfies closure operator axioms.

    Returns (True, None) if valid, or (False, description) if violated.

    Time complexity: O(2^n) where n = |universe|
    """
    for A in enumerate_subsets(universe):
        clA = cl(A)

        # Extensive: A ⊆ cl(A)
        if not A <= clA:
            return False, f"Extensive violated: {set(A)} ⊄ cl({set(A)}) = {set(clA)}"

        # Monotone check (for subsets of A)
        for elem in A:
            B = A - {elem}
            if not cl(B) <= clA:
                return False, f"Monotone violated: cl({set(B)}) ⊄ cl({set(A)})"

        # Idempotent: cl(cl(A)) = cl(A)
        if cl(clA) != clA:
            return False, f"Idempotent violated: cl(cl({set(A)})) ≠ cl({set(A)})"

    return True, None


def enumerate_authorized(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition],
    cap: Callable[[Coalition], float],
    t: float
) -> List[Coalition]:
    """
    Algorithm 4.1: Enumerate all authorized coalitions.

    A coalition A is authorized iff t ≤ cap(cl(A)).

    Time complexity: O(2^n · T_cl · T_cap)

    Args:
        universe: Finite participant set
        cl: Closure operator
        cap: Capacity function
        t: Authorization threshold

    Returns:
        List of all authorized coalitions
    """
    authorized = []
    for A in enumerate_subsets(universe):
        if t <= cap(cl(A)):
            authorized.append(A)
    return authorized


def enumerate_minimal_authorized(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition],
    cap: Callable[[Coalition], float],
    t: float
) -> List[Coalition]:
    """
    Algorithm 4.2: Enumerate all minimal authorized coalitions.

    A coalition A is minimal authorized iff:
    - t ≤ cap(cl(A))
    - For all B ⊂ A: ¬(t ≤ cap(cl(B)))

    Time complexity: O(2^n · T_cl · T_cap + |auth|² · n)

    Args:
        universe: Finite participant set
        cl: Closure operator
        cap: Capacity function
        t: Authorization threshold

    Returns:
        List of all minimal authorized coalitions
    """
    auth = enumerate_authorized(universe, cl, cap, t)

    # Sort by cardinality for efficient filtering
    auth.sort(key=len)

    minimals = []
    for A in auth:
        # Check if any already-found minimal is a subset
        is_minimal = not any(M <= A for M in minimals)
        if is_minimal:
            minimals.append(A)

    return minimals


def is_closure_basis(
    cl: Callable[[Coalition], Coalition],
    B: Coalition
) -> bool:
    """
    Check if B is a closure basis for cl(B).

    B is a basis iff no proper subset generates the same closure.

    Time complexity: O(|B| · T_cl)
    """
    clB = cl(B)
    for elem in B:
        if cl(B - {elem}) == clB:
            return False
    return True


def extract_reconstruction(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition],
    cap: Callable[[Coalition], float],
    t: float
) -> Tuple[List[Coalition], Callable[[Coalition], int]]:
    """
    Algorithm 4.3: Extract certified reconstruction data.

    Returns minimal authorized sets and a score function such that
    Auth(A) ↔ 1 ≤ score(A).

    Args:
        universe: Finite participant set
        cl: Closure operator
        cap: Capacity function
        t: Authorization threshold

    Returns:
        (minimal_authorized_sets, score_function)
    """
    minimals = enumerate_minimal_authorized(universe, cl, cap, t)

    def score(A: Coalition) -> int:
        return 1 if any(M <= A for M in minimals) else 0

    return minimals, score


def verify_reconstruction(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition],
    cap: Callable[[Coalition], float],
    t: float,
    score: Callable[[Coalition], int],
    tau: int = 1
) -> Tuple[bool, Optional[str]]:
    """
    Verify that a reconstruction score function is correct.

    Checks: Auth(A) ↔ τ ≤ score(A) for all A ⊆ universe.

    Returns (True, None) if correct, or (False, counterexample).
    """
    for A in enumerate_subsets(universe):
        auth = (t <= cap(cl(A)))
        recon = (tau <= score(A))
        if auth != recon:
            return False, f"Mismatch at {set(A)}: auth={auth}, recon={recon}"
    return True, None


def verify_submodularity(
    universe: Set[Element],
    cl: Callable[[Coalition], Coalition],
    cap: Callable[[Coalition], float]
) -> Tuple[bool, Optional[str]]:
    """
    Verify that cap is submodular on closures.

    Checks: cap(cl(A∪B)) + cap(cl(A∩B)) ≤ cap(cl(A)) + cap(cl(B))
    for all A, B ⊆ universe.

    Returns (True, None) if submodular, or (False, counterexample).
    """
    subsets = enumerate_subsets(universe)
    for A in subsets:
        for B in subsets:
            lhs = cap(cl(A | B)) + cap(cl(A & B))
            rhs = cap(cl(A)) + cap(cl(B))
            if lhs > rhs + 1e-10:  # numerical tolerance
                return False, (f"Submodularity violated: "
                              f"A={set(A)}, B={set(B)}, "
                              f"LHS={lhs}, RHS={rhs}")
    return True, None


def construct_identity_realization(
    minimal_auth: List[Coalition]
) -> Tuple[Callable, Callable, int]:
    """
    Theorem 2: Construct identity-closure realization from minimal authorized sets.

    Returns (cl, cap, threshold) where cl = id and cap checks membership.
    """
    min_auth_set = set(minimal_auth)

    def cl(A: Coalition) -> Coalition:
        return A

    def cap(A: Coalition) -> int:
        return 1 if any(M <= A for M in min_auth_set) else 0

    return cl, cap, 1


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Closure-Capacity Secret-Sharing Duality")
    print("=" * 55)

    # Example: 2-out-of-4 threshold
    universe = {1, 2, 3, 4}
    X = frozenset(universe)

    def cl(A):
        return X if len(A) >= 2 else frozenset(A)

    def cap(A):
        return len(A)

    t = 2

    # Verify closure axioms
    valid, msg = verify_closure_axioms(universe, cl)
    print(f"\nClosure axioms valid: {valid}")

    # Enumerate authorized
    auth = enumerate_authorized(universe, cl, cap, t)
    print(f"Authorized coalitions: {len(auth)}")

    # Enumerate minimal authorized
    minimals = enumerate_minimal_authorized(universe, cl, cap, t)
    print(f"Minimal authorized: {[set(M) for M in minimals]}")

    # Check basis property
    for M in minimals:
        print(f"  {set(M)} is closure basis: {is_closure_basis(cl, M)}")

    # Extract reconstruction
    _, score = extract_reconstruction(universe, cl, cap, t)
    valid, msg = verify_reconstruction(universe, cl, cap, t, score)
    print(f"Reconstruction valid: {valid}")

    # Verify submodularity
    valid, msg = verify_submodularity(universe, cl, cap)
    print(f"Submodular: {valid}")
