#!/usr/bin/env python3
"""
algorithms.py — Knot invariant computation algorithms

Implements:
1. State-sum Kauffman bracket evaluator
2. PD code to loop count converter
3. Jones polynomial via writhe normalization
4. Span computation for alternating knot detection
"""

from itertools import product
from collections import defaultdict
from typing import Dict, List, Tuple, Optional
from demo import LaurentPoly, delta, kauffman_bracket, jones_polynomial


# ============================================================
# Algorithm 1: PD Code to Loop Counts
# ============================================================

def pd_code_loop_count(pd_code: List[List[int]],
                       state: Tuple[int, ...],
                       a_smooth: str = "ab") -> int:
    """
    Compute the number of loops from a PD code and smoothing state.

    Parameters:
        pd_code: List of [a, b, c, d] crossings (clockwise arc labels)
        state: Tuple of 0 (A-smooth) or 1 (B-smooth) for each crossing
        a_smooth: "ab" means A connects a↔b,c↔d; "ad" means a↔d,b↔c

    Returns:
        Number of loops (connected components)

    Complexity: O(n) where n = number of crossings
    """
    n = len(pd_code)
    assert len(state) == n

    # Build the pairing: each arc label gets two endpoints
    # (one at each crossing it participates in)
    # Endpoint = (crossing_index, position_in_crossing)
    endpoints = {}  # arc_label -> list of (crossing_idx, position)
    for i, crossing in enumerate(pd_code):
        for pos, arc in enumerate(crossing):
            if arc not in endpoints:
                endpoints[arc] = []
            endpoints[arc].append((i, pos))

    # Build adjacency from smoothing
    # At each crossing [a,b,c,d] (positions 0,1,2,3):
    # A-smooth (ab): connect pos 0↔1 and pos 2↔3
    # B-smooth: connect pos 0↔3 and pos 1↔2
    # (alternative: A-smooth (ad): 0↔3 and 1↔2)
    adj = {}  # (crossing, pos) -> (crossing, pos)

    for i, crossing in enumerate(pd_code):
        if state[i] == 0:  # A-smoothing
            if a_smooth == "ab":
                adj[(i, 0)] = (i, 1)
                adj[(i, 1)] = (i, 0)
                adj[(i, 2)] = (i, 3)
                adj[(i, 3)] = (i, 2)
            else:  # a_smooth == "ad"
                adj[(i, 0)] = (i, 3)
                adj[(i, 3)] = (i, 0)
                adj[(i, 1)] = (i, 2)
                adj[(i, 2)] = (i, 1)
        else:  # B-smoothing
            if a_smooth == "ab":
                adj[(i, 0)] = (i, 3)
                adj[(i, 3)] = (i, 0)
                adj[(i, 1)] = (i, 2)
                adj[(i, 2)] = (i, 1)
            else:
                adj[(i, 0)] = (i, 1)
                adj[(i, 1)] = (i, 0)
                adj[(i, 2)] = (i, 3)
                adj[(i, 3)] = (i, 2)

    # Arc connections: each arc connects its two endpoints
    arc_adj = {}
    for arc, eps in endpoints.items():
        if len(eps) == 2:
            arc_adj[eps[0]] = eps[1]
            arc_adj[eps[1]] = eps[0]

    # Count loops by traversing cycles
    visited = set()
    loops = 0

    all_endpoints = set()
    for i, crossing in enumerate(pd_code):
        for pos in range(4):
            all_endpoints.add((i, pos))

    for start in all_endpoints:
        if start in visited:
            continue
        # Trace the loop
        current = start
        while current not in visited:
            visited.add(current)
            # Follow smoothing connection
            smooth_next = adj[current]
            visited.add(smooth_next)
            # Follow arc connection
            if smooth_next in arc_adj:
                current = arc_adj[smooth_next]
            else:
                break
        loops += 1

    return loops


def bracket_from_pd(pd_code: List[List[int]],
                    a_smooth: str = "ab",
                    verbose: bool = False) -> LaurentPoly:
    """Compute the Kauffman bracket from a PD code."""
    n = len(pd_code)

    def loops_fn(state):
        return pd_code_loop_count(pd_code, state, a_smooth)

    return kauffman_bracket(n, loops_fn, verbose=verbose)


# ============================================================
# Algorithm 2: Span-based alternating knot detection
# ============================================================

def compute_span(poly: LaurentPoly) -> int:
    """Compute the span (max_deg - min_deg) of a Laurent polynomial."""
    if not poly.coeffs:
        return 0
    return max(poly.coeffs.keys()) - min(poly.coeffs.keys())


def is_trivial_jones(jones: LaurentPoly) -> bool:
    """Check if a Jones polynomial equals 1 (unknot)."""
    return jones == LaurentPoly.one()


def alternating_detection(n_crossings: int,
                          loops_fn,
                          writhe: int) -> str:
    """
    Apply the alternating knot detection criterion.

    For adequate diagrams: span > 0 implies the knot is non-trivial.

    Returns: "unknot", "knotted", or "inconclusive"
    """
    if n_crossings == 0:
        return "unknot"

    jones = jones_polynomial(n_crossings, loops_fn, writhe)
    bracket = kauffman_bracket(n_crossings, loops_fn)

    if is_trivial_jones(jones):
        return "unknot"

    span = compute_span(bracket)
    if span > 0:
        return "knotted"

    return "inconclusive"


# ============================================================
# Algorithm 3: Torus knot bracket via braid words
# ============================================================

def torus_knot_2_n_loops(n: int):
    """
    Generate loop count function for torus knot T(2,n).

    T(2,n) has n crossings in a standard braid closure diagram.
    The loop counts depend on the specific braid structure.
    """
    # For T(2,n), the PD code follows a regular pattern
    # This is a simplified model for odd n (which gives knots)
    pd_code = []
    for i in range(n):
        a = 2 * i + 1
        b = 2 * ((i + 1) % n) + 2
        c = 2 * i + 2
        d = 2 * ((i + 1) % n) + 1
        pd_code.append([a, b, c, d])

    def loops_fn(state):
        return pd_code_loop_count(pd_code, state)

    return loops_fn, pd_code


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Knot Invariant Algorithms")
    print("=" * 60)

    # PD code computation for trefoil
    print("\n--- PD Code Bracket Computation ---")
    trefoil_pd = [[1, 5, 2, 4], [3, 1, 4, 6], [5, 3, 6, 2]]
    trefoil_bracket = bracket_from_pd(trefoil_pd, a_smooth="ad", verbose=True)
    print(f"\n  Trefoil bracket (PD code): {trefoil_bracket}")
    print(f"  Span: {compute_span(trefoil_bracket)}")

    # Detection
    print("\n--- Alternating Knot Detection ---")
    from demo import trefoil_loops, figure_eight_loops

    result = alternating_detection(3, trefoil_loops, writhe=-3)
    print(f"  Trefoil: {result}")

    result = alternating_detection(4, figure_eight_loops, writhe=0)
    print(f"  Figure-eight: {result}")

    result = alternating_detection(0, lambda s: 1, writhe=0)
    print(f"  Unknot: {result}")

    # Torus knots
    print("\n--- Torus Knot Family T(2,n) ---")
    for n in [3, 5, 7]:
        try:
            loops_fn, pd = torus_knot_2_n_loops(n)
            bracket = kauffman_bracket(n, loops_fn)
            print(f"  T(2,{n}): bracket span = {compute_span(bracket)}, "
                  f"expected 4×{n} = {4*n}")
        except Exception as e:
            print(f"  T(2,{n}): computation skipped ({e})")

    print("\n" + "=" * 60)
    print("Algorithm demonstrations complete!")
    print("=" * 60)
