#!/usr/bin/env python3
"""
Algorithms for Closure Barron Duality

Implements the core algorithms from the research paper:
1. Weight extraction from monotone sup-preserving functionals
2. Reconstruction from canonical weights
3. Certified recovery from oracle queries
4. Closure variation computation
"""

from typing import Dict, List, Callable, Tuple, Optional
from demo import FiniteDistribLattice, powerset_lattice, divisor_lattice


def extract_weights(
    lattice: FiniteDistribLattice,
    f: Callable,
) -> Dict:
    """Extract canonical weights from a monotone sup-preserving functional.

    Algorithm 1 from the paper.

    Args:
        lattice: A finite distributive lattice.
        f: A monotone sup-preserving functional on the lattice.

    Returns:
        Dictionary mapping join-irreducible elements to their weights.

    Complexity: O(|L|) for JI identification + O(|JI|) evaluations of f.
    """
    return {j: f(j) for j in lattice.join_irreducibles()}


def reconstruct_at(
    lattice: FiniteDistribLattice,
    weights: Dict,
    K,
) -> float:
    """Reconstruct f(K) from canonical weights.

    Algorithm 2 from the paper.

    Args:
        lattice: A finite distributive lattice.
        weights: Canonical weights on join-irreducible elements.
        K: An element of the lattice.

    Returns:
        The reconstructed value f(K) = max{w(j) | j ∈ JI, j ≤ K}.

    Complexity: O(|JI|) comparisons.
    """
    vals = [weights[j] for j in lattice.join_irreducibles() if lattice.le(j, K)]
    return max(vals) if vals else 0


def certified_recovery(
    lattice: FiniteDistribLattice,
    oracle: Callable,
) -> Tuple[Callable, Dict, List]:
    """Certified recovery of a functional from oracle queries.

    Algorithm 3 from the paper. Queries the oracle only on join-irreducible
    elements and reconstructs the complete functional with a certificate.

    Args:
        lattice: A finite distributive lattice.
        oracle: An oracle for a monotone sup-preserving functional.

    Returns:
        Tuple of (reconstructed_functional, weights, certificate).
        - reconstructed_functional: The recovered f.
        - weights: Canonical weights used.
        - certificate: List of (element, queried_value) pairs proving correctness.

    Complexity: |JI| oracle queries + O(|JI| * |L|) for full reconstruction.
    """
    ji = lattice.join_irreducibles()
    weights = {j: oracle(j) for j in ji}
    certificate = [(j, weights[j]) for j in ji]

    def f_hat(K):
        return reconstruct_at(lattice, weights, K)

    return f_hat, weights, certificate


def closure_variation(
    lattice: FiniteDistribLattice,
    f: Callable,
) -> float:
    """Compute the closure variation norm of a functional.

    The closure variation is the minimum total weight of an atomic
    decomposition: sum of canonical weights.

    Args:
        lattice: A finite distributive lattice.
        f: A monotone sup-preserving functional.

    Returns:
        The closure variation norm.

    Complexity: O(|JI|) evaluations of f.
    """
    weights = extract_weights(lattice, f)
    return sum(weights.values())


def verify_sup_preserving(
    lattice: FiniteDistribLattice,
    f: Callable,
) -> Tuple[bool, Optional[Tuple]]:
    """Verify that a functional is sup-preserving.

    Args:
        lattice: A finite distributive lattice.
        f: A functional to test.

    Returns:
        (True, None) if sup-preserving, or (False, (a, b)) giving a counterexample.

    Complexity: O(|L|^2) evaluations of f.
    """
    for a in lattice.elements:
        for b in lattice.elements:
            ab = lattice.sup(a, b)
            if f(ab) != max(f(a), f(b)):
                return False, (a, b)
    return True, None


def verify_representation(
    lattice: FiniteDistribLattice,
    f: Callable,
) -> Tuple[bool, float]:
    """Verify the representation theorem for a given functional.

    Args:
        lattice: A finite distributive lattice.
        f: A monotone sup-preserving functional.

    Returns:
        (success, max_error) where success is True iff exact reconstruction holds.
    """
    weights = extract_weights(lattice, f)
    max_error = 0.0
    for K in lattice.elements:
        actual = f(K)
        reconstructed = reconstruct_at(lattice, weights, K)
        error = abs(actual - reconstructed)
        max_error = max(max_error, error)
    return (max_error == 0, max_error)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    print()

    # Power-set lattice
    L = powerset_lattice(4)
    weights_input = {
        frozenset({0}): 5, frozenset({1}): 12,
        frozenset({2}): 3, frozenset({3}): 8
    }

    def f(K):
        vals = [weights_input[j] for j in L.sup_irred_below(K)]
        return max(vals) if vals else 0

    # Test all algorithms
    print("1. Weight extraction:")
    w = extract_weights(L, f)
    for j, v in sorted(w.items(), key=lambda x: sorted(x[0])):
        print(f"   w({set(j)}) = {v}")

    print("\n2. Reconstruction test:")
    test_element = frozenset({1, 2, 3})
    val = reconstruct_at(L, w, test_element)
    print(f"   f({set(test_element)}) = {val} (expected: {f(test_element)})")

    print("\n3. Certified recovery:")
    f_hat, recovered_w, cert = certified_recovery(L, f)
    print(f"   Queries made: {len(cert)}")
    print(f"   Total lattice elements: {len(L.elements)}")
    all_match = all(f_hat(K) == f(K) for K in L.elements)
    print(f"   All values match: {all_match}")

    print("\n4. Closure variation norm:")
    cv = closure_variation(L, f)
    print(f"   ||f||_CV = {cv}")

    print("\n5. Sup-preserving verification:")
    sp, _ = verify_sup_preserving(L, f)
    print(f"   Is sup-preserving: {sp}")

    print("\n6. Representation verification:")
    rep_ok, err = verify_representation(L, f)
    print(f"   Representation exact: {rep_ok} (error: {err})")
