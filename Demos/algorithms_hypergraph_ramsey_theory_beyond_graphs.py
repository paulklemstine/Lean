#!/usr/bin/env python3
"""
Hypergraph Ramsey Theory: Core Algorithms

Type-hinted implementations of key algorithms and computations
from hypergraph Ramsey theory.
"""

from math import comb, log2, ceil
from typing import List, Set, FrozenSet, Callable, Optional, Tuple
from itertools import combinations
import random


# ============================================================
# Type aliases
# ============================================================
Vertex = int
RSubset = FrozenSet[int]
Coloring = Callable[[FrozenSet[int]], bool]  # True = red, False = blue


# ============================================================
# Algorithm 1: Tower Function
# ============================================================
def tower_exp(height: int, base: int) -> int:
    """
    Compute the tower function: iterated exponentiation.
    
    tower_exp(0, n) = n
    tower_exp(h+1, n) = 2^{tower_exp(h, n)}
    
    Pseudocode:
        TOWER(h, n):
            result ← n
            FOR i = 1 TO h:
                result ← 2^result
            RETURN result
    
    Args:
        height: Number of levels of exponentiation
        base: Starting value
    
    Returns:
        2↑↑height(base) — tower of 2s of given height starting from base
    """
    result = base
    for _ in range(height):
        if result > 1000:  # Prevent astronomical computation
            return float('inf')
        result = 2 ** result
    return result


# ============================================================
# Algorithm 2: Probabilistic Lower Bound Computation
# ============================================================
def probabilistic_lower_bound(r: int, k: int) -> int:
    """
    Compute the probabilistic lower bound for R_r(k,k).
    
    Finds the largest n such that 2 * C(n,k) < 2^{C(k,r)}.
    
    Pseudocode:
        PROB_LOWER_BOUND(r, k):
            target ← 2^{C(k,r)}
            n ← k
            WHILE 2 * C(n, k) < target:
                n ← n + 1
            RETURN n - 1
    
    Args:
        r: Uniformity (r-uniform hypergraph)
        k: Clique size (diagonal case)
    
    Returns:
        Largest n such that ¬ HyperRamseyProp r n k k (provably)
    """
    if k < r:
        return k  # Trivial case
    
    choose_k_r = comb(k, r)
    if choose_k_r > 1000:  # Too large to compute 2^{C(k,r)}
        # Use logarithmic approximation
        log_target = choose_k_r * log2(2)  # = C(k,r)
        n = k
        while True:
            # log2(C(n,k)) ≈ k * log2(n/k) + k * log2(e) (Stirling)
            log_choose = sum(log2(n - i) - log2(i + 1) for i in range(k))
            if log_choose + 1 >= log_target:
                return n - 1
            n += 1
            if n > 10**6:
                return n
    
    target = 2 ** choose_k_r
    n = k
    while 2 * comb(n, k) < target:
        n += 1
    return n - 1


# ============================================================
# Algorithm 3: Exhaustive Hypergraph Ramsey Checker
# ============================================================
def check_hyper_ramsey_prop(r: int, n: int, s: int, t: int, 
                             max_colorings: int = 100000) -> Tuple[bool, Optional[dict]]:
    """
    Check HyperRamseyProp r n s t by exhaustive or random search.
    
    For small n: exhaustively check all 2^{C(n,r)} colorings.
    For large n: randomly sample colorings.
    
    Pseudocode:
        CHECK_RAMSEY(r, n, s, t):
            r_subsets ← all r-element subsets of [n]
            FOR each coloring c of r_subsets:
                has_red_s ← EXISTS T ⊆ [n], |T|=s: all r-subsets of T are red
                has_blue_t ← EXISTS T ⊆ [n], |T|=t: all r-subsets of T are blue
                IF NOT (has_red_s OR has_blue_t):
                    RETURN (False, c)  // counterexample
            RETURN (True, None)
    
    Args:
        r: Uniformity
        n: Number of vertices
        s: Red clique size
        t: Blue clique size
        max_colorings: Maximum colorings to check
    
    Returns:
        (holds, info) where holds is True if property holds,
        info contains counterexample if found
    """
    vertices = list(range(n))
    r_subsets = [frozenset(sub) for sub in combinations(vertices, r)]
    num_r_subsets = len(r_subsets)
    
    total_colorings = 2 ** num_r_subsets
    
    def check_coloring(coloring_bits: int) -> bool:
        """Check if a coloring satisfies the Ramsey property."""
        def color(S: FrozenSet[int]) -> bool:
            idx = r_subsets.index(S)
            return bool((coloring_bits >> idx) & 1)
        
        # Check for red s-clique
        for T in combinations(vertices, s):
            T_set = frozenset(T)
            T_r_subs = [frozenset(sub) for sub in combinations(T, r)]
            if all(color(S) for S in T_r_subs):
                return True  # Found red s-clique
        
        # Check for blue t-clique
        for T in combinations(vertices, t):
            T_set = frozenset(T)
            T_r_subs = [frozenset(sub) for sub in combinations(T, r)]
            if all(not color(S) for S in T_r_subs):
                return True  # Found blue t-clique
        
        return False
    
    if total_colorings <= max_colorings:
        # Exhaustive search
        for bits in range(total_colorings):
            if not check_coloring(bits):
                return (False, {"counterexample_bits": bits, "method": "exhaustive"})
        return (True, {"method": "exhaustive", "colorings_checked": total_colorings})
    else:
        # Random sampling
        for _ in range(max_colorings):
            bits = random.randint(0, total_colorings - 1)
            if not check_coloring(bits):
                return (False, {"counterexample_bits": bits, "method": "random"})
        return (True, {"method": "random", "colorings_checked": max_colorings,
                       "note": "Not exhaustive — property may still fail"})


# ============================================================
# Algorithm 4: Stepping-Up Bound Computation
# ============================================================
def stepping_up_upper_bound(r: int, k: int) -> str:
    """
    Compute the upper bound for R_r(k,k) via the stepping-up lemma.
    
    Pseudocode:
        STEPPING_UP_BOUND(r, k):
            IF r = 2:
                RETURN C(2k-2, k-1)  // graph Ramsey upper bound
            ELSE:
                prev ← STEPPING_UP_BOUND(r-1, k-1)
                RETURN 2^prev
    
    Args:
        r: Uniformity
        k: Diagonal clique size
    
    Returns:
        String representation of the bound (may be too large for int)
    """
    if r < 2 or k < r:
        return str(k)
    
    if r == 2:
        bound = comb(2 * k - 2, k - 1)
        return str(bound)
    else:
        prev = stepping_up_upper_bound(r - 1, k - 1)
        try:
            prev_int = int(prev)
            if prev_int < 100:
                return str(2 ** prev_int)
            else:
                return f"2^{prev}"
        except (ValueError, OverflowError):
            return f"2^({prev})"


# ============================================================
# Main demonstration
# ============================================================
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Tower function
    print("Tower Function:")
    for h in range(5):
        val = tower_exp(h, 3)
        print(f"  tower({h}, 3) = {val}")
    
    # Probabilistic bounds
    print("\nProbabilistic Lower Bounds:")
    for r in range(2, 5):
        for k in [4, 5, 6, 8]:
            if k >= r:
                bound = probabilistic_lower_bound(r, k)
                print(f"  R_{r}({k},{k}) > {bound}")
    
    # Small Ramsey checks
    print("\nExhaustive Ramsey Checks:")
    test_cases = [
        (2, 5, 3, 3),  # R_2(3,3) > 5 (known: R(3,3)=6)
        (2, 6, 3, 3),  # R_2(3,3) ≤ 6 (known: R(3,3)=6)
    ]
    for r, n, s, t in test_cases:
        holds, info = check_hyper_ramsey_prop(r, n, s, t)
        print(f"  HyperRamseyProp({r}, {n}, {s}, {t}) = {holds}  [{info['method']}]")
    
    # Stepping-up bounds
    print("\nStepping-Up Upper Bounds:")
    for r in range(2, 6):
        for k in [3, 4, 5]:
            bound = stepping_up_upper_bound(r, k)
            print(f"  R_{r}({k},{k}) ≤ {bound}")
