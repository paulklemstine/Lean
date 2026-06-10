"""
algorithms.py — Core algorithms for semantic entropy analysis of monotone Boolean functions.

Implements:
  - UpSat computation (upward satisfying fiber)
  - Semantic entropy profile
  - Entropy drop computation
  - Maximum cover entropy drop
  - Depth lower bound estimation
  - Layered monotone system simulation

All algorithms operate on the Boolean cube {0,1}^n with pointwise order.
"""

from __future__ import annotations
import math
from itertools import product
from typing import Callable, Dict, List, Optional, Tuple

# Type aliases
BoolVec = Tuple[int, ...]  # elements of {0,1}^n
MonotoneFn = Callable[[BoolVec], bool]


def all_bool_vecs(n: int) -> List[BoolVec]:
    """Generate all 2^n Boolean vectors of length n."""
    return list(product([0, 1], repeat=n))


def leq(x: BoolVec, y: BoolVec) -> bool:
    """Pointwise ≤ on Boolean vectors: x ≤ y iff x[i] ≤ y[i] for all i."""
    return all(xi <= yi for xi, yi in zip(x, y))


def hamming_dist(x: BoolVec, y: BoolVec) -> int:
    """Hamming distance between two Boolean vectors."""
    return sum(xi != yi for xi, yi in zip(x, y))


def up_sat(f: MonotoneFn, x: BoolVec, n: int) -> List[BoolVec]:
    """
    Compute the upward satisfying fiber UpSat(f, x).

    UpSat(f, x) = {z ∈ {0,1}^n : x ≤ z ∧ f(z) = 1}

    Args:
        f: A Boolean function on {0,1}^n.
        x: A Boolean vector.
        n: Dimension of the Boolean cube.

    Returns:
        List of all z ≥ x with f(z) = True.

    Complexity: O(2^n) time, O(2^n) space.
    """
    return [z for z in all_bool_vecs(n) if leq(x, z) and f(z)]


def semantic_mass(f: MonotoneFn, x: BoolVec, n: int) -> int:
    """
    Compute |UpSat(f, x)|.

    Complexity: O(2^n).
    """
    return len(up_sat(f, x, n))


def semantic_entropy(f: MonotoneFn, x: BoolVec, n: int) -> float:
    """
    Compute SemEnt(f, x) = log₂|UpSat(f, x)|.

    Returns 0.0 when UpSat is empty (convention: log₂(0) = 0).

    Complexity: O(2^n).
    """
    mass = semantic_mass(f, x, n)
    if mass == 0:
        return 0.0
    return math.log2(mass)


def entropy_drop(f: MonotoneFn, x: BoolVec, y: BoolVec, n: int) -> float:
    """
    Compute Δ_f(x, y) = SemEnt(f, x) - SemEnt(f, y).

    For monotone f with x ≤ y, this is guaranteed to be ≥ 0
    (by the antitonicity theorem).

    Complexity: O(2^n).
    """
    return semantic_entropy(f, x, n) - semantic_entropy(f, y, n)


def semantic_entropy_profile(f: MonotoneFn, n: int) -> Dict[BoolVec, float]:
    """
    Compute the full semantic entropy profile: SemEnt(f, x) for all x ∈ {0,1}^n.

    Returns:
        Dictionary mapping each Boolean vector to its semantic entropy.

    Complexity: O(4^n) = O(2^n) vectors × O(2^n) per UpSat computation.
    """
    return {x: semantic_entropy(f, x, n) for x in all_bool_vecs(n)}


def max_entropy_drop(f: MonotoneFn, n: int) -> Tuple[float, BoolVec, BoolVec]:
    """
    Find the maximum entropy drop over all comparable pairs (x ≤ y).

    Returns:
        (max_drop, x_opt, y_opt) where Δ_f(x_opt, y_opt) = max_drop.

    Complexity: O(4^n) for all pairs × O(2^n) per entropy computation.
    """
    best = 0.0
    best_x = None
    best_y = None
    vecs = all_bool_vecs(n)
    for x in vecs:
        for y in vecs:
            if leq(x, y):
                drop = entropy_drop(f, x, y, n)
                if drop > best:
                    best = drop
                    best_x = x
                    best_y = y
    return best, best_x, best_y


def max_cover_entropy_drop(f: MonotoneFn, n: int) -> float:
    """
    Maximum single-step (cover) entropy drop.

    Considers all pairs (u, v) with u ≤ v and Hamming distance 1.
    These are adjacent pairs in the Hasse diagram.

    Returns:
        max over covers of entropyDrop(f, u, v).

    Complexity: O(n · 2^n).
    """
    best = 0.0
    for x in all_bool_vecs(n):
        for i in range(n):
            if x[i] == 0:
                y = list(x)
                y[i] = 1
                y = tuple(y)
                drop = entropy_drop(f, x, y, n)
                best = max(best, drop)
    return best


def depth_lower_bound(f: MonotoneFn, n: int, k: int = 2) -> float:
    """
    Compute a depth lower bound for monotone circuits of fan-in k.

    Uses the formula: depth ≥ max_drop / log₂(k).

    This follows from Theorem 3 (depth_lower_bound_layered): if each
    layer with fan-in k drops entropy by at most log₂(k), then
    Δ_f(x,y) ≤ d · log₂(k), hence d ≥ Δ_f(x,y) / log₂(k).

    Args:
        f: Monotone Boolean function.
        n: Dimension.
        k: Fan-in (default 2).

    Returns:
        Lower bound on circuit depth (as a float).
    """
    if k <= 1:
        raise ValueError("Fan-in k must be > 1")
    max_drop, _, _ = max_entropy_drop(f, n)
    return max_drop / math.log2(k)


def verify_antitonicity(f: MonotoneFn, n: int) -> bool:
    """
    Verify Theorem 1 (antitonicity of semantic entropy) computationally.

    Checks that for all x ≤ y, SemEnt(f, y) ≤ SemEnt(f, x).

    Returns:
        True if the antitonicity property holds for all pairs.
    """
    profile = semantic_entropy_profile(f, n)
    vecs = all_bool_vecs(n)
    for x in vecs:
        for y in vecs:
            if leq(x, y):
                if profile[y] > profile[x] + 1e-12:
                    return False
    return True


def verify_hamming_bound(f: MonotoneFn, n: int) -> bool:
    """
    Verify Theorem 4 (Hamming distance bound) computationally.

    Checks that entropyDrop(f, x, y) ≤ hammingDist(x,y) · maxCoverDrop.

    Returns:
        True if the bound holds for all comparable pairs.
    """
    max_step = max_cover_entropy_drop(f, n)
    vecs = all_bool_vecs(n)
    for x in vecs:
        for y in vecs:
            if leq(x, y):
                drop = entropy_drop(f, x, y, n)
                if drop > hamming_dist(x, y) * max_step + 1e-12:
                    return False
    return True


def chain_entropy_length(f: MonotoneFn, x: BoolVec, y: BoolVec,
                         n: int) -> float:
    """
    Compute the maximum chain entropy length from x to y.

    This is the entropy drop along the greedy saturated chain
    (which equals the total entropy drop by telescoping for
    monotone functions).

    Complexity: O(n · 2^n).
    """
    if not leq(x, y):
        return 0.0
    return entropy_drop(f, x, y, n)


# ─── Standard monotone functions ───

def make_and(n: int) -> MonotoneFn:
    """n-ary AND: f(x) = 1 iff all x_i = 1."""
    def f(x: BoolVec) -> bool:
        return all(xi == 1 for xi in x)
    return f


def make_or(n: int) -> MonotoneFn:
    """n-ary OR: f(x) = 1 iff some x_i = 1."""
    def f(x: BoolVec) -> bool:
        return any(xi == 1 for xi in x)
    return f


def make_threshold(n: int, t: int) -> MonotoneFn:
    """Threshold function: f(x) = 1 iff sum(x_i) ≥ t."""
    def f(x: BoolVec) -> bool:
        return sum(x) >= t
    return f


def make_majority(n: int) -> MonotoneFn:
    """Majority function: f(x) = 1 iff sum(x_i) > n/2."""
    return make_threshold(n, n // 2 + 1)


def is_monotone(f: MonotoneFn, n: int) -> bool:
    """Check if f is monotone on {0,1}^n."""
    vecs = all_bool_vecs(n)
    for x in vecs:
        for y in vecs:
            if leq(x, y) and f(x) and not f(y):
                return False
    return True


if __name__ == "__main__":
    # Quick self-test
    n = 3
    for name, f in [("AND", make_and(n)), ("OR", make_or(n)),
                     ("MAJ", make_majority(n)), ("THR≥2", make_threshold(n, 2))]:
        assert is_monotone(f, n), f"{name} is not monotone!"
        assert verify_antitonicity(f, n), f"Antitonicity failed for {name}!"
        assert verify_hamming_bound(f, n), f"Hamming bound failed for {name}!"
        md, mx, my = max_entropy_drop(f, n)
        lb = depth_lower_bound(f, n, k=2)
        print(f"{name}(n={n}): max_drop={md:.3f}, depth_lb={lb:.3f}, "
              f"max_cover_drop={max_cover_entropy_drop(f, n):.3f}")
    print("All self-tests passed!")
