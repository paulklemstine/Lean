#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing obstruction system invariants.

Implements the key computational methods from the sharp threshold
concentration theory:
1. Transition window computation
2. Normalized width calculation
3. Pivotal element counting
4. Maximum packing (greedy)
5. Decay exponent estimation

All algorithms include docstrings, type hints, and complexity analysis.
"""

import math
import itertools
from typing import List, Tuple, Set, Dict, Optional, FrozenSet


# ===========================================================================
# Data Structures
# ===========================================================================

class ObstructionSystem:
    """
    An obstruction system on a finite ground set.
    
    Attributes:
        ground: The ground set of atoms.
        obstructions: Family of obstruction sets (hyperedges).
    
    A set S is satisfiable iff no obstruction is contained in S.
    """
    
    def __init__(self, ground: Set[int], obstructions: List[FrozenSet[int]]):
        self.ground = ground
        self.obstructions = [o for o in obstructions if o]  # filter empty
        # Verify obstructions are subsets of ground
        for o in self.obstructions:
            assert o <= ground, f"Obstruction {o} not subset of ground"
    
    def is_sat(self, S: Set[int]) -> bool:
        """Check if S is satisfiable (contains no obstruction)."""
        return all(not o <= S for o in self.obstructions)
    
    def num_atoms(self) -> int:
        return len(self.ground)
    
    def num_obstructions(self) -> int:
        return len(self.obstructions)


def triangle_system(n: int) -> ObstructionSystem:
    """
    Create the triangle obstruction system on K_n.
    
    Ground set: edges of K_n (as pairs (i,j) encoded as i*n+j).
    Obstructions: triples of edges forming triangles.
    
    Time: O(n³) to construct.
    Space: O(n³) for the obstruction list.
    
    Example:
        >>> sys = triangle_system(4)
        >>> sys.num_atoms()
        6
        >>> sys.num_obstructions()
        4
    """
    ground = set()
    for i in range(n):
        for j in range(i + 1, n):
            ground.add(i * n + j)
    
    obstructions = []
    for i in range(n):
        for j in range(i + 1, n):
            for k in range(j + 1, n):
                tri = frozenset({i * n + j, i * n + k, j * n + k})
                obstructions.append(tri)
    
    return ObstructionSystem(ground, obstructions)


# ===========================================================================
# Algorithm 1: Transition Window (Exact)
# ===========================================================================

def compute_sat_threshold(sys: ObstructionSystem, max_k: Optional[int] = None) -> int:
    """
    Compute the satisfiability threshold: largest k such that ALL
    k-subsets of the ground set are satisfiable.
    
    Time: O(sum_{k=0}^{sat} binom(|ground|, k) * |obstructions| * max_obs_size)
    Space: O(|ground|)
    
    This is exponential in general but tractable for small systems.
    
    Args:
        sys: The obstruction system.
        max_k: Maximum k to check (default: |ground|).
    
    Returns:
        The satisfiability threshold.
    
    Example:
        >>> sys = triangle_system(4)
        >>> compute_sat_threshold(sys)
        2
    """
    ground_list = sorted(sys.ground)
    n = len(ground_list)
    if max_k is None:
        max_k = n
    
    threshold = 0
    for k in range(min(max_k, n) + 1):
        all_sat = True
        for combo in itertools.combinations(range(n), k):
            S = {ground_list[i] for i in combo}
            if not sys.is_sat(S):
                all_sat = False
                break
        if all_sat:
            threshold = k
        else:
            break
    
    return threshold


def compute_unsat_threshold(sys: ObstructionSystem, max_k: Optional[int] = None) -> int:
    """
    Compute the unsatisfiability threshold: smallest k such that ALL
    k-subsets of the ground set are unsatisfiable.
    
    Time: O(sum_{k=unsat}^{|ground|} binom(|ground|, k) * |obstructions| * max_obs_size)
    Space: O(|ground|)
    
    Args:
        sys: The obstruction system.
        max_k: Maximum k to check (default: |ground|).
    
    Returns:
        The unsatisfiability threshold.
    
    Example:
        >>> sys = triangle_system(4)
        >>> compute_unsat_threshold(sys)
        5
    """
    ground_list = sorted(sys.ground)
    n = len(ground_list)
    if max_k is None:
        max_k = n
    
    # Search from top down
    threshold = n + 1
    for k in range(n, -1, -1):
        all_unsat = True
        for combo in itertools.combinations(range(n), k):
            S = {ground_list[i] for i in combo}
            if sys.is_sat(S):
                all_unsat = False
                break
        if all_unsat:
            threshold = k
        else:
            break
    
    return threshold


def compute_transition_window(sys: ObstructionSystem) -> Dict:
    """
    Compute the full transition window information.
    
    Returns dict with sat_threshold, unsat_threshold, width, normalized_width.
    
    Example:
        >>> sys = triangle_system(4)
        >>> w = compute_transition_window(sys)
        >>> w['width']
        2
    """
    sat = compute_sat_threshold(sys)
    unsat = compute_unsat_threshold(sys)
    n = sys.num_atoms()
    width = max(0, unsat - sat)
    
    return {
        'sat_threshold': sat,
        'unsat_threshold': unsat,
        'width': width,
        'normalized_width': width / n if n > 0 else 0.0,
        'num_atoms': n,
    }


# ===========================================================================
# Algorithm 2: Normalized Transition Width
# ===========================================================================

def normalized_transition_width(total_atoms: int, width: int) -> float:
    """
    Compute the normalized transition width.
    
    This is the key quantity from our Lean formalization:
      normalizedTransitionWidth(totalAtoms, width) = width / totalAtoms
    
    Time: O(1)
    Space: O(1)
    
    Args:
        total_atoms: Size of the ground set.
        width: Width of the transition window.
    
    Returns:
        The normalized width as a float.
    
    Example:
        >>> normalized_transition_width(10, 3)
        0.3
    """
    if total_atoms == 0:
        return 0.0
    return width / total_atoms


# ===========================================================================
# Algorithm 3: Pivotal Element Counting
# ===========================================================================

def compute_pivotal_count(sys: ObstructionSystem, k: int) -> int:
    """
    Count the number of pivotal elements at size k.
    
    An element x is pivotal if there exists a k-subset S containing x
    such that S is unsatisfiable but S \\ {x} is satisfiable.
    
    Time: O(|ground| * binom(|ground|-1, k-1) * |obstructions| * max_obs_size)
    Space: O(|ground|)
    
    Args:
        sys: The obstruction system.
        k: The size parameter.
    
    Returns:
        Number of pivotal elements.
    
    Example:
        >>> sys = triangle_system(4)
        >>> compute_pivotal_count(sys, 3)
        6
    """
    ground_list = sorted(sys.ground)
    n = len(ground_list)
    pivotal = set()
    
    for combo in itertools.combinations(range(n), k):
        S = {ground_list[i] for i in combo}
        if not sys.is_sat(S):
            for idx in combo:
                x = ground_list[idx]
                S_minus_x = S - {x}
                if sys.is_sat(S_minus_x):
                    pivotal.add(x)
    
    return len(pivotal)


def pivotal_profile(sys: ObstructionSystem) -> List[int]:
    """
    Compute the full pivotal count profile across all sizes.
    
    Returns a list where entry k is the pivotal count at size k.
    
    Time: O(2^|ground| * |ground| * |obstructions|) — exponential.
    Space: O(|ground|)
    
    Example:
        >>> sys = triangle_system(4)
        >>> pivotal_profile(sys)
        [0, 0, 0, 6, 6, 6, 0]
    """
    n = sys.num_atoms()
    return [compute_pivotal_count(sys, k) for k in range(n + 1)]


# ===========================================================================
# Algorithm 4: Greedy Packing
# ===========================================================================

def greedy_packing(sys: ObstructionSystem) -> List[FrozenSet[int]]:
    """
    Compute a maximal edge-disjoint packing of obstructions using a
    greedy algorithm.
    
    Time: O(|obstructions|² * max_obs_size)
    Space: O(|obstructions| * max_obs_size)
    
    Args:
        sys: The obstruction system.
    
    Returns:
        List of pairwise disjoint obstructions.
    
    Example:
        >>> sys = triangle_system(4)
        >>> pack = greedy_packing(sys)
        >>> len(pack) >= 1
        True
    """
    used = set()
    packing = []
    
    # Sort obstructions by size (smaller first)
    sorted_obs = sorted(sys.obstructions, key=len)
    
    for o in sorted_obs:
        if not (o & used):
            packing.append(o)
            used |= o
    
    return packing


# ===========================================================================
# Algorithm 5: Decay Exponent Estimation
# ===========================================================================

def estimate_decay_exponent(ns: List[int], widths: List[float]) -> Dict:
    """
    Estimate the decay exponent β from the hypothesis w(n) ~ C * n^{-β}.
    
    Uses log-log linear regression: log(w) = -β * log(n) + log(C).
    
    Time: O(len(ns))
    Space: O(len(ns))
    
    Args:
        ns: List of system sizes.
        widths: Corresponding normalized widths.
    
    Returns:
        Dict with 'beta', 'C', 'r_squared' (coefficient of determination).
    
    Example:
        >>> estimate_decay_exponent([4, 5, 6], [0.5, 0.3, 0.2])
        {'beta': ..., 'C': ..., 'r_squared': ...}
    """
    # Filter positive values
    valid = [(n, w) for n, w in zip(ns, widths) if w > 0 and n > 1]
    if len(valid) < 2:
        return {'beta': float('nan'), 'C': float('nan'), 'r_squared': float('nan')}
    
    xs = [math.log(n) for n, _ in valid]
    ys = [math.log(w) for _, w in valid]
    
    m = len(xs)
    sx = sum(xs)
    sy = sum(ys)
    sxx = sum(x * x for x in xs)
    sxy = sum(x * y for x, y in zip(xs, ys))
    syy = sum(y * y for y in ys)
    
    denom = m * sxx - sx * sx
    if abs(denom) < 1e-15:
        return {'beta': float('nan'), 'C': float('nan'), 'r_squared': float('nan')}
    
    slope = (m * sxy - sx * sy) / denom
    intercept = (sy - slope * sx) / m
    
    # R² calculation
    ss_res = sum((y - (slope * x + intercept)) ** 2 for x, y in zip(xs, ys))
    ss_tot = sum((y - sy / m) ** 2 for y in ys)
    r_squared = 1 - ss_res / ss_tot if abs(ss_tot) > 1e-15 else float('nan')
    
    return {
        'beta': -slope,
        'C': math.exp(intercept),
        'r_squared': r_squared,
    }


# ===========================================================================
# Main demonstration
# ===========================================================================

if __name__ == "__main__":
    print("Algorithm demonstrations:")
    print()
    
    # Triangle system on K_4
    sys4 = triangle_system(4)
    print(f"Triangle system K_4: {sys4.num_atoms()} atoms, "
          f"{sys4.num_obstructions()} obstructions")
    
    w4 = compute_transition_window(sys4)
    print(f"  Transition window: [{w4['sat_threshold']}, {w4['unsat_threshold']}]")
    print(f"  Width: {w4['width']}, Normalized: {w4['normalized_width']:.4f}")
    
    pack4 = greedy_packing(sys4)
    print(f"  Greedy packing: {len(pack4)} disjoint obstructions")
    
    print()
    
    # Triangle system on K_5
    sys5 = triangle_system(5)
    print(f"Triangle system K_5: {sys5.num_atoms()} atoms, "
          f"{sys5.num_obstructions()} obstructions")
    
    w5 = compute_transition_window(sys5)
    print(f"  Transition window: [{w5['sat_threshold']}, {w5['unsat_threshold']}]")
    print(f"  Width: {w5['width']}, Normalized: {w5['normalized_width']:.4f}")
    
    prof5 = pivotal_profile(sys5)
    print(f"  Pivotal profile: {prof5}")
    
    print()
    
    # Decay estimation
    ns_data = []
    ws_data = []
    for n in range(3, 8):
        sys = triangle_system(n)
        w = compute_transition_window(sys)
        ns_data.append(n)
        ws_data.append(w['normalized_width'])
        print(f"K_{n}: normalized_width = {w['normalized_width']:.4f}")
    
    decay = estimate_decay_exponent(ns_data, ws_data)
    print(f"\nDecay exponent: β = {decay['beta']:.4f}, "
          f"R² = {decay['r_squared']:.4f}")
