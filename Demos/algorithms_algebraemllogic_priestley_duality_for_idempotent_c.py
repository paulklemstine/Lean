#!/usr/bin/env python3
"""
Algorithms for Closure-Temporal Order Minimization

Implements the key algorithms from the research paper:
1. Partition refinement for observational quotient computation
2. Separation verification
3. Observable generation from base predicates

Complexity analysis included in docstrings.
"""

from typing import List, Set, FrozenSet, Tuple, Callable, Optional
from collections import defaultdict
import time


class FiniteCTO:
    """Finite closure-temporal order.

    Args:
        n: Number of elements (elements are 0, ..., n-1)
        le_matrix: n×n boolean matrix, le_matrix[i][j] = (i ≤ j)
        cl_map: list of length n, cl_map[i] = cl(i)
        T_map: list of length n, T_map[i] = T(i)
    """

    def __init__(self, n: int, le_matrix: List[List[bool]],
                 cl_map: List[int], T_map: List[int]):
        self.n = n
        self.le_matrix = le_matrix
        self.cl_map = cl_map
        self.T_map = T_map

    def le(self, i: int, j: int) -> bool:
        return self.le_matrix[i][j]

    def cl(self, i: int) -> int:
        return self.cl_map[i]

    def T(self, i: int) -> int:
        return self.T_map[i]

    def is_closed(self, i: int) -> bool:
        return self.cl_map[i] == i


def compute_observational_quotient(
    cto: FiniteCTO,
    observables: List[FrozenSet[int]]
) -> List[List[int]]:
    """Compute the observational quotient by partition refinement.

    Algorithm:
        Start with the trivial partition {M}.
        For each observable O, refine the partition by splitting
        each block B into B ∩ O and B \\ O.

    Complexity: O(n × k) where n = |M| and k = |observables|.

    Args:
        cto: The finite CTO.
        observables: List of stable observables (as frozensets of element indices).

    Returns:
        List of equivalence classes (each class is a list of element indices).
    """
    # Start with single block containing all elements
    partition = [list(range(cto.n))]

    for obs in observables:
        new_partition = []
        for block in partition:
            inside = [x for x in block if x in obs]
            outside = [x for x in block if x not in obs]
            if inside:
                new_partition.append(inside)
            if outside:
                new_partition.append(outside)
        partition = new_partition

    return partition


def verify_separation(
    cto: FiniteCTO,
    observables: List[FrozenSet[int]]
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify whether the CTO is separated by the given observables.

    Complexity: O(n² × k) where n = |M| and k = |observables|.

    Args:
        cto: The finite CTO.
        observables: List of stable observables.

    Returns:
        (True, None) if separated.
        (False, (i, j)) if elements i and j are not separated.
    """
    n = cto.n
    for i in range(n):
        for j in range(i + 1, n):
            separated = False
            for obs in observables:
                if (i in obs) != (j in obs):
                    separated = True
                    break
            if not separated:
                return False, (i, j)
    return True, None


def generate_upset_closure(
    cto: FiniteCTO,
    base_sets: List[Set[int]]
) -> List[FrozenSet[int]]:
    """Generate stable observables from base predicates.

    Given base sets, compute their upset closures and filter
    for stability under cl-preimage and T-biconditional.

    Complexity: O(|base_sets| × n²) for upset closure generation.

    Args:
        cto: The finite CTO.
        base_sets: Initial sets to generate observables from.

    Returns:
        List of stable observables generated.
    """
    n = cto.n
    result = []

    for base in base_sets:
        # Compute upset closure
        upset = set(base)
        changed = True
        while changed:
            changed = False
            for i in range(n):
                if i in upset:
                    for j in range(n):
                        if cto.le(i, j) and j not in upset:
                            upset.add(j)
                            changed = True

        # Check cl-inverse stability
        cl_inv_ok = True
        for i in range(n):
            if cto.cl(i) in upset and i not in upset:
                cl_inv_ok = False
                break

        if not cl_inv_ok:
            continue

        # Check T-biconditional
        t_iff_ok = True
        for i in range(n):
            if (i in upset) != (cto.T(i) in upset):
                t_iff_ok = False
                break

        if not t_iff_ok:
            continue

        result.append(frozenset(upset))

    return result


def find_all_stable_observables(cto: FiniteCTO) -> List[FrozenSet[int]]:
    """Find all stable observables by exhaustive enumeration.

    Complexity: O(2^n × n²) — exponential, only for small n.

    Args:
        cto: The finite CTO.

    Returns:
        List of all stable observables.
    """
    n = cto.n
    result = []

    for mask in range(1 << n):
        s = frozenset(i for i in range(n) if mask & (1 << i))

        # Check upset
        ok = True
        for i in range(n):
            if i in s:
                for j in range(n):
                    if cto.le(i, j) and j not in s:
                        ok = False
                        break
            if not ok:
                break
        if not ok:
            continue

        # Check cl-inverse
        for i in range(n):
            if cto.cl(i) in s and i not in s:
                ok = False
                break
        if not ok:
            continue

        # Check T-biconditional
        for i in range(n):
            if (i in s) != (cto.T(i) in s):
                ok = False
                break
        if not ok:
            continue

        result.append(s)

    return result


def minimality_certificate(
    cto: FiniteCTO,
    observables: List[FrozenSet[int]]
) -> dict:
    """Generate a minimality certificate for the observational quotient.

    The certificate includes:
    - The observational equivalence classes
    - For each pair of distinct classes, a separating observable
    - The quotient size and original size

    Complexity: O(n² × k)

    Args:
        cto: The finite CTO.
        observables: List of stable observables.

    Returns:
        Certificate dictionary.
    """
    classes = compute_observational_quotient(cto, observables)
    n_classes = len(classes)

    # Find separating observables for each pair of classes
    separators = {}
    for ci in range(n_classes):
        for cj in range(ci + 1, n_classes):
            rep_i = classes[ci][0]
            rep_j = classes[cj][0]
            for k, obs in enumerate(observables):
                if (rep_i in obs) != (rep_j in obs):
                    separators[(ci, cj)] = k
                    break

    return {
        "original_size": cto.n,
        "quotient_size": n_classes,
        "classes": classes,
        "separators": separators,
        "compression_ratio": n_classes / cto.n if cto.n > 0 else 1.0,
        "is_minimal": True  # By theorem, the observational quotient is always minimal
    }


# ===================================================================
# Demonstration
# ===================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstration: Observational Quotient Computation")
    print("=" * 60)

    # Build a 6-element CTO
    # Hasse diagram:
    #     5
    #    /|\
    #   3  4
    #   |\/|
    #   |/\|
    #   1  2
    #    \/
    #    0

    n = 6
    le = [[False]*n for _ in range(n)]
    # Set up the order
    edges = [(0,1), (0,2), (1,3), (1,4), (2,3), (2,4), (3,5), (4,5)]
    for i in range(n):
        le[i][i] = True
    for (a, b) in edges:
        le[a][b] = True
    # Transitive closure
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if le[i][k] and le[k][j]:
                    le[i][j] = True

    # Closure: cl(0)=0, cl(1)=3, cl(2)=4, cl(3)=3, cl(4)=4, cl(5)=5
    cl = [0, 3, 4, 3, 4, 5]
    # Temporal: T(0)=0, T(1)=2, T(2)=1, T(3)=4, T(4)=3, T(5)=5
    T = [0, 2, 1, 4, 3, 5]

    cto = FiniteCTO(n, le, cl, T)

    print(f"\nCTO with {n} elements")
    print(f"Closed elements: {[i for i in range(n) if cl[i] == i]}")
    print(f"Temporal step: {T}")

    # Find all stable observables
    t0 = time.time()
    all_obs = find_all_stable_observables(cto)
    t1 = time.time()
    print(f"\nFound {len(all_obs)} stable observables in {(t1-t0)*1000:.1f}ms")
    for obs in all_obs:
        print(f"  {set(obs)}")

    # Compute quotient
    t0 = time.time()
    classes = compute_observational_quotient(cto, all_obs)
    t1 = time.time()
    print(f"\nObservational quotient ({len(classes)} classes, computed in {(t1-t0)*1000:.1f}ms):")
    for i, cls in enumerate(classes):
        print(f"  Class {i}: {cls}")

    # Verify separation
    sep, witness = verify_separation(cto, all_obs)
    print(f"\nSeparated: {sep}")
    if not sep:
        print(f"  Inseparable pair: {witness}")

    # Generate certificate
    cert = minimality_certificate(cto, all_obs)
    print(f"\nMinimality certificate:")
    print(f"  Original size: {cert['original_size']}")
    print(f"  Quotient size: {cert['quotient_size']}")
    print(f"  Compression ratio: {cert['compression_ratio']:.2%}")
    print(f"  Separating observables: {cert['separators']}")
    print(f"  Is minimal (by theorem): {cert['is_minimal']}")

    # ===================================================================
    # Benchmark: scaling behavior
    # ===================================================================
    print("\n" + "=" * 60)
    print("Benchmark: Partition Refinement Scaling")
    print("=" * 60)

    for size in [4, 8, 12, 16]:
        # Linear order with identity cl and T
        le_lin = [[i <= j for j in range(size)] for i in range(size)]
        cl_id = list(range(size))
        T_id = list(range(size))
        cto_bench = FiniteCTO(size, le_lin, cl_id, T_id)

        t0 = time.time()
        obs_bench = find_all_stable_observables(cto_bench)
        t1 = time.time()
        classes_bench = compute_observational_quotient(cto_bench, obs_bench)
        t2 = time.time()

        print(f"  n={size:3d}: {len(obs_bench):4d} observables, "
              f"{len(classes_bench):3d} classes, "
              f"enum={1000*(t1-t0):.1f}ms, quotient={1000*(t2-t1):.1f}ms")
