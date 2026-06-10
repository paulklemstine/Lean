#!/usr/bin/env python3
"""
Boolean Function Sensitivity: Algorithm Implementations

Type-hinted implementations of the core algorithms from the sensitivity
conjecture theory.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import itertools


# Type aliases
BoolInput = Tuple[bool, ...]
BoolFun = Callable[[BoolInput], bool]


def flip_at(x: BoolInput, i: int) -> BoolInput:
    """Flip the i-th bit of input x.

    Corresponds to the Lean definition:
        def flipAt (x : Fin n → Bool) (i : Fin n) : Fin n → Bool :=
          Function.update x i (!x i)
    """
    lst = list(x)
    lst[i] = not lst[i]
    return tuple(lst)


def all_inputs(n: int) -> List[BoolInput]:
    """Generate all 2^n Boolean inputs of length n."""
    return list(itertools.product([False, True], repeat=n))


def local_sensitivity(f: BoolFun, x: BoolInput) -> int:
    """Compute the local sensitivity of f at input x.

    s(f, x) = |{i : f(x) ≠ f(x^(i))}|

    Time complexity: O(n) where n = len(x)
    """
    n = len(x)
    count = 0
    for i in range(n):
        if f(x) != f(flip_at(x, i)):
            count += 1
    return count


def sensitivity(f: BoolFun, n: int) -> int:
    """Compute the sensitivity of f.

    s(f) = max_x s(f, x)

    Time complexity: O(n * 2^n)
    """
    return max(local_sensitivity(f, x) for x in all_inputs(n))


def sensitive_coords(f: BoolFun, x: BoolInput) -> Set[int]:
    """Return the set of coordinates to which f is sensitive at x.

    Corresponds to the Lean definition:
        def sensitiveCoords (f : BoolFun n) (x : Fin n → Bool) : Finset (Fin n) :=
          Finset.univ.filter (isSensitiveAt f x)
    """
    n = len(x)
    return {i for i in range(n) if f(x) != f(flip_at(x, i))}


def influence_at(f: BoolFun, n: int, i: int) -> int:
    """Compute the influence of coordinate i.

    Inf_i(f) = |{x : f(x) ≠ f(x^(i))}|

    Time complexity: O(2^n)
    """
    return sum(1 for x in all_inputs(n) if f(x) != f(flip_at(x, i)))


def total_influence(f: BoolFun, n: int) -> int:
    """Compute the total influence.

    I(f) = Σ_i Inf_i(f) = Σ_x s(f, x)   (double counting identity)

    Time complexity: O(n * 2^n)
    """
    return sum(influence_at(f, n, i) for i in range(n))


def is_certificate(f: BoolFun, x: BoolInput, S: Set[int]) -> bool:
    """Check if S is a certificate for f at x.

    S is a certificate if ∀ y, (∀ i ∈ S, y_i = x_i) → f(y) = f(x)

    Time complexity: O(2^n)
    """
    n = len(x)
    fx = f(x)
    for y in all_inputs(n):
        if all(y[i] == x[i] for i in S):
            if f(y) != fx:
                return False
    return True


def certificate_complexity(f: BoolFun, x: BoolInput) -> int:
    """Compute the certificate complexity of f at x.

    C(f, x) = min{|S| : S is a certificate for f at x}

    Time complexity: O(2^n * Σ_k C(n,k)) ≈ O(2^n * 2^n) worst case
    """
    n = len(x)
    for size in range(n + 1):
        for S in itertools.combinations(range(n), size):
            if is_certificate(f, x, set(S)):
                return size
    return n  # Full set is always a certificate


def is_block_sensitive(f: BoolFun, x: BoolInput, B: Set[int]) -> bool:
    """Check if block B is sensitive for f at x.

    Corresponds to:
        def isBlockSensitive f x B :=
          f x ≠ f (fun i => if i ∈ B then !x i else x i)
    """
    y = tuple(not x[i] if i in B else x[i] for i in range(len(x)))
    return f(x) != f(y)


def block_sensitivity(f: BoolFun, n: int) -> int:
    """Compute the block sensitivity of f.

    bs(f) = max_x max{k : ∃ disjoint B_1,...,B_k sensitive at x}

    Time complexity: Exponential in n (NP-hard in general)
    """
    max_bs = 0
    for x in all_inputs(n):
        # Find maximum number of disjoint sensitive blocks at x
        # Simple greedy: try all subsets, find max packing
        sensitive_blocks: List[Set[int]] = []
        for size in range(1, n + 1):
            for B in itertools.combinations(range(n), size):
                B_set = set(B)
                if is_block_sensitive(f, x, B_set):
                    sensitive_blocks.append(B_set)

        # Greedy packing of disjoint blocks
        used: Set[int] = set()
        count = 0
        # Sort by size (smaller blocks first for better packing)
        for B in sorted(sensitive_blocks, key=len):
            if not B & used:
                used |= B
                count += 1
        max_bs = max(max_bs, count)
    return max_bs


def hypercube_neighbors(x: BoolInput) -> List[BoolInput]:
    """Return all neighbors of x in the hypercube Q_n.

    Each neighbor differs from x in exactly one coordinate.
    """
    return [flip_at(x, i) for i in range(len(x))]


def induced_degree(S: Set[BoolInput], x: BoolInput) -> int:
    """Compute the degree of x in the induced subgraph on S.

    Corresponds to:
        def inducedDeg S x := (S.filter (fun y => x ≠ y ∧ HypercubeAdj x y)).card
    """
    return sum(1 for y in hypercube_neighbors(x) if y in S and y != x)


def compute_all_measures(f: BoolFun, n: int) -> Dict[str, int]:
    """Compute all complexity measures for a Boolean function.

    Returns a dictionary with sensitivity, total influence, and
    block sensitivity.
    """
    return {
        "sensitivity": sensitivity(f, n),
        "total_influence": total_influence(f, n),
        "block_sensitivity": block_sensitivity(f, n) if n <= 5 else -1,
    }


# === Standard Boolean Functions ===

def make_and(n: int) -> BoolFun:
    """AND function on n variables."""
    return lambda x: all(x)

def make_or(n: int) -> BoolFun:
    """OR function on n variables."""
    return lambda x: any(x)

def make_parity(n: int) -> BoolFun:
    """Parity function on n variables."""
    return lambda x: sum(x) % 2 == 1

def make_majority(n: int) -> BoolFun:
    """Majority function on n variables (n should be odd)."""
    return lambda x: sum(x) > n // 2

def make_threshold(n: int, k: int) -> BoolFun:
    """Threshold-k function on n variables."""
    return lambda x: sum(x) >= k


if __name__ == "__main__":
    # Quick demo
    n = 4
    print(f"Complexity measures for n={n}:")
    for name, f in [("AND", make_and(n)), ("PARITY", make_parity(n)),
                     ("MAJORITY", make_majority(n))]:
        measures = compute_all_measures(f, n)
        print(f"  {name}: {measures}")
