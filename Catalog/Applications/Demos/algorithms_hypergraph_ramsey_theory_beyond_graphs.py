#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Algorithms

Type-hinted implementations of key algorithms for computing and bounding
hypergraph Ramsey numbers.
"""
from math import comb, log2
from typing import List, Tuple, Optional, Set, FrozenSet, Callable
from itertools import combinations
import random


def tower(k: int, n: int) -> int:
    """Iterated exponential (tower function).

    tower(0, n) = n
    tower(k+1, n) = 2^{tower(k, n)}

    This captures the growth rate of r-uniform hypergraph Ramsey numbers:
    R_r(k,k) ~ tower(r-2, poly(k)).

    Args:
        k: Height of the tower (number of exponentiations)
        n: Base value

    Returns:
        The tower value tower(k, n)
    """
    if k == 0:
        return n
    return 2 ** tower(k - 1, n)


def probabilistic_lower_bound(k: int, r: int) -> int:
    """Compute the probabilistic (first-moment) lower bound for R_r(k,k).

    Uses the Erdős counting argument: if 2 * C(n,k) < 2^{C(k,r)},
    then some 2-coloring of the r-subsets of [n] has no monochromatic k-set.

    This gives: R_r(k,k) > max{n : 2 * C(n,k) < 2^{C(k,r)}}.

    For r=2: R(k,k) > 2^{k/2} (classical Erdős bound)
    For r=3: R_3(k,k) > 2^{Ω(k^2)}

    Args:
        k: Clique size
        r: Uniformity (r-uniform hypergraph)

    Returns:
        Lower bound n such that R_r(k,k) > n
    """
    if k < r:
        return k  # trivial case
    ckr = comb(k, r)
    threshold = 2 ** ckr

    # Binary search for largest n with 2 * C(n,k) < 2^{C(k,r)}
    lo, hi = k, min(threshold, 10**18)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        try:
            if 2 * comb(mid, k) < threshold:
                lo = mid
            else:
                hi = mid - 1
        except (OverflowError, ValueError):
            hi = mid - 1
    return lo


def stepping_up_bound(
    base_ramsey: Callable[[int, int], int],
    k: int, l: int
) -> int:
    """Compute the stepping-up upper bound for R_{r+1}(k,l).

    Given a function computing R_r(·,·), computes the stepping-up bound:
        R_{r+1}(k+1, l+1) ≤ R_r(R_{r+1}(k, l+1), R_{r+1}(k+1, l)) + 1

    Base cases: R_{r+1}(k, 0) = 0, R_{r+1}(0, l) = 0,
                R_{r+1}(k, 1) = k (if k ≤ r+1), etc.

    Args:
        base_ramsey: Function computing R_r(s, t)
        k: Red clique size
        l: Blue clique size

    Returns:
        Upper bound for R_{r+1}(k, l)
    """
    memo: dict[Tuple[int, int], int] = {}

    def compute(k: int, l: int) -> int:
        if k <= 0 or l <= 0:
            return 0
        if (k, l) in memo:
            return memo[(k, l)]

        # For small cases, use direct bounds
        if k == 1 or l == 1:
            result = max(k, l)
        else:
            a = compute(k - 1, l)
            b = compute(k, l - 1)
            result = base_ramsey(a, b) + 1

        memo[(k, l)] = result
        return result

    return compute(k, l)


def check_ramsey_property(
    n: int, k: int, r: int,
    coloring: Callable[[FrozenSet[int]], bool]
) -> Optional[FrozenSet[int]]:
    """Check whether a coloring has a monochromatic k-set.

    Given a 2-coloring of the r-subsets of [n], finds a monochromatic
    k-subset if one exists.

    Args:
        n: Size of the ground set
        k: Required clique size
        r: Uniformity
        coloring: Function mapping r-subsets to bool (True=red, False=blue)

    Returns:
        A monochromatic k-set if found, None otherwise
    """
    vertices = list(range(n))

    for subset in combinations(vertices, k):
        S = frozenset(subset)
        # Check all r-subsets
        r_subsets = list(combinations(subset, r))

        # Check if all red
        if all(coloring(frozenset(T)) for T in r_subsets):
            return S  # red monochromatic

        # Check if all blue
        if all(not coloring(frozenset(T)) for T in r_subsets):
            return S  # blue monochromatic

    return None


def random_coloring_search(
    n: int, k: int, r: int,
    num_trials: int = 1000
) -> Tuple[bool, int]:
    """Search for a coloring of r-subsets of [n] with no monochromatic k-set.

    Uses random colorings to try to demonstrate R_r(k,k) > n.

    Args:
        n: Ground set size
        k: Clique size
        r: Uniformity
        num_trials: Number of random colorings to try

    Returns:
        (found, trial_num): Whether a good coloring was found and which trial
    """
    vertices = list(range(n))
    r_subsets = [frozenset(s) for s in combinations(vertices, r)]

    for trial in range(num_trials):
        # Random coloring
        colors = {s: random.choice([True, False]) for s in r_subsets}

        # Check all k-subsets
        found_mono = False
        for subset in combinations(vertices, k):
            sub_r_sets = [frozenset(t) for t in combinations(subset, r)]
            if all(colors[s] for s in sub_r_sets):
                found_mono = True
                break
            if all(not colors[s] for s in sub_r_sets):
                found_mono = True
                break

        if not found_mono:
            return True, trial

    return False, num_trials


def link_coloring(
    n: int, r: int,
    coloring: Callable[[FrozenSet[int]], bool],
    vertex: int
) -> Callable[[FrozenSet[int]], bool]:
    """Compute the link coloring at a vertex.

    Given an (r+1)-uniform coloring and a vertex v, produces an r-uniform
    coloring where an r-set T is colored by the color of {v} ∪ T.

    This is the fundamental operation in the stepping-up construction.

    Args:
        n: Ground set size
        r: Target uniformity (the link has uniformity r)
        coloring: The original (r+1)-uniform coloring
        vertex: The vertex to take the link at

    Returns:
        The link coloring function
    """
    def link(S: FrozenSet[int]) -> bool:
        if len(S) != r or vertex in S:
            return False
        return coloring(S | frozenset([vertex]))
    return link


# === Example computations ===
if __name__ == "__main__":
    print("=== Probabilistic Lower Bounds ===")
    for r in [2, 3, 4]:
        print(f"\nUniformity r = {r}:")
        for k in range(max(r, 3), min(r + 8, 12)):
            lb = probabilistic_lower_bound(k, r)
            print(f"  R_{r}({k},{k}) > {lb}")

    print("\n=== Stepping-Up Bounds ===")
    # Use R_2(s,t) ≤ C(s+t-2, s-1) as the base
    def graph_ramsey_bound(s: int, t: int) -> int:
        if s <= 0 or t <= 0:
            return 0
        return comb(s + t - 2, s - 1)

    print("\nR_3(k,l) upper bounds via stepping-up from graph Ramsey:")
    for k in range(2, 7):
        for l in range(k, k + 1):
            bound = stepping_up_bound(graph_ramsey_bound, k, l)
            print(f"  R_3({k},{l}) ≤ {bound}")

    print("\n=== Random Search for R_3(3,3) ===")
    # R_3(3,3) = 4: need n=4 vertices for guaranteed monochromatic triple
    for n in [3, 4]:
        found, trial = random_coloring_search(n, 3, 3, num_trials=100)
        if found:
            print(f"  n={n}: Found coloring with no mono triple (trial {trial})")
        else:
            print(f"  n={n}: All 100 random colorings had mono triple → R_3(3,3) ≤ {n}")
