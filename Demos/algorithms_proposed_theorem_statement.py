#!/usr/bin/env python3
"""
Semiconjugacy Orbit Arithmetic — Algorithms

General-purpose algorithms for:
1. Computing minimal periods of endofunctions
2. Verifying semiconjugacy conditions
3. Computing orbit structure and cycle decomposition
4. Analyzing period divisibility under semiconjugacy

All algorithms include type hints, docstrings, and complexity analysis.
"""

from typing import Callable, TypeVar, Hashable, Optional
from collections import defaultdict
import math

T = TypeVar("T", bound=Hashable)
S = TypeVar("S", bound=Hashable)


# ══════════════════════════════════════════════════════════════════════════
# Algorithm 1: Minimal Period via Floyd's Cycle Detection
# ══════════════════════════════════════════════════════════════════════════

def minimal_period_floyd(f: Callable[[T], T], x: T) -> tuple[int, int]:
    """
    Compute the minimal period and preperiod of x under f using Floyd's
    tortoise-and-hare algorithm.

    Returns:
        (preperiod, period) where:
        - preperiod μ: smallest m ≥ 0 such that f^[m](x) is periodic
        - period λ: minimal period of f^[μ](x)

    Time complexity: O(μ + λ)
    Space complexity: O(1)

    Example:
        >>> f = lambda x: (x + 1) % 5
        >>> minimal_period_floyd(f, 0)
        (0, 5)
    """
    # Phase 1: Find a meeting point (tortoise and hare)
    tortoise = f(x)
    hare = f(f(x))
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(f(hare))

    # Phase 2: Find the preperiod μ
    mu = 0
    tortoise = x
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        mu += 1

    # Phase 3: Find the period λ
    lam = 1
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        lam += 1

    return mu, lam


def minimal_period(f: Callable[[T], T], x: T) -> int:
    """
    Compute the minimal period of x under f.
    Returns 0 if x is not periodic (within detection limits).

    For finite-state systems, always terminates and returns the correct period.

    Time complexity: O(μ + λ) where μ = preperiod, λ = period
    Space complexity: O(1)
    """
    mu, lam = minimal_period_floyd(f, x)
    if mu == 0:
        return lam
    return lam  # period of the eventual cycle


# ══════════════════════════════════════════════════════════════════════════
# Algorithm 2: Semiconjugacy Verification
# ══════════════════════════════════════════════════════════════════════════

def verify_semiconjugacy(
    f: Callable[[T], T],
    g: Callable[[S], S],
    h: Callable[[T], S],
    domain: list[T],
) -> tuple[bool, Optional[T]]:
    """
    Verify that h is a semiconjugacy from f to g on the given domain.

    Checks: h(f(x)) == g(h(x)) for all x in domain.

    Returns:
        (True, None) if the semiconjugacy condition holds everywhere.
        (False, x) if a counterexample x is found with h(f(x)) ≠ g(h(x)).

    Time complexity: O(|domain|) function evaluations
    Space complexity: O(1)

    Example:
        >>> f = lambda x: (x + 1) % 6
        >>> g = lambda y: (y + 1) % 3
        >>> h = lambda x: x % 3
        >>> verify_semiconjugacy(f, g, h, list(range(6)))
        (True, None)
    """
    for x in domain:
        if h(f(x)) != g(h(x)):
            return False, x
    return True, None


# ══════════════════════════════════════════════════════════════════════════
# Algorithm 3: Orbit Decomposition
# ══════════════════════════════════════════════════════════════════════════

def orbit_decomposition(
    f: Callable[[T], T], domain: list[T]
) -> dict[int, list[list[T]]]:
    """
    Compute the full cycle decomposition of f restricted to the given domain.

    Returns a dictionary mapping cycle length to list of cycles.
    Each cycle is represented as a list of elements in orbit order.
    Only includes elements that are actually periodic (on a cycle).

    Time complexity: O(|domain|)
    Space complexity: O(|domain|)

    Example:
        >>> f = lambda x: (x + 1) % 6
        >>> orbits = orbit_decomposition(f, list(range(6)))
        >>> orbits
        {6: [[0, 1, 2, 3, 4, 5]]}
    """
    visited: set[T] = set()
    cycles_by_length: dict[int, list[list[T]]] = defaultdict(list)

    for start in domain:
        if start in visited:
            continue

        # Trace the orbit until we find a cycle or revisit
        path: list[T] = []
        path_set: set[T] = set()
        x = start

        while x not in path_set and x not in visited:
            path.append(x)
            path_set.add(x)
            x = f(x)

        if x in visited:
            # This path leads to an already-processed component
            visited.update(path)
            continue

        # x is in path_set: we found a cycle
        cycle_start_idx = path.index(x)
        cycle = path[cycle_start_idx:]
        tail = path[:cycle_start_idx]

        cycles_by_length[len(cycle)].append(cycle)
        visited.update(path)

    return dict(cycles_by_length)


# ══════════════════════════════════════════════════════════════════════════
# Algorithm 4: Period Divisibility Analysis Under Semiconjugacy
# ══════════════════════════════════════════════════════════════════════════

def period_divisibility_analysis(
    f: Callable[[T], T],
    g: Callable[[S], S],
    h: Callable[[T], S],
    domain: list[T],
) -> dict[str, object]:
    """
    Analyze period divisibility relationships under a semiconjugacy h: (α,f) → (β,g).

    For each periodic point x in the domain, computes:
    - minimalPeriod(f, x)
    - minimalPeriod(g, h(x))
    - The divisibility ratio

    Returns a summary dictionary with:
    - 'all_divide': whether all divisibility constraints hold
    - 'points': list of (x, period_f, h(x), period_g, ratio) tuples
    - 'period_collapse_histogram': distribution of collapse ratios
    - 'source_periods': set of source periods
    - 'image_periods': set of image periods

    Time complexity: O(|domain| · max_period)
    Space complexity: O(|domain|)

    Example:
        >>> f = lambda x: (x + 1) % 12
        >>> g = lambda y: (y + 1) % 4
        >>> h = lambda x: x % 4
        >>> result = period_divisibility_analysis(f, g, h, list(range(12)))
        >>> result['all_divide']
        True
    """
    points = []
    all_divide = True
    collapse_histogram: dict[int, int] = defaultdict(int)
    source_periods: set[int] = set()
    image_periods: set[int] = set()

    for x in domain:
        pf = minimal_period(f, x)
        hx = h(x)
        pg = minimal_period(g, hx)

        if pg > 0 and pf > 0:
            divides = pf % pg == 0
            ratio = pf // pg
        elif pg == 0:
            divides = True
            ratio = 0
        else:
            divides = pf == 0
            ratio = 0

        if not divides:
            all_divide = False

        points.append({
            'x': x,
            'period_f': pf,
            'h_x': hx,
            'period_g': pg,
            'ratio': ratio,
            'divides': divides,
        })

        if pf > 0:
            source_periods.add(pf)
        if pg > 0:
            image_periods.add(pg)
        if ratio > 0:
            collapse_histogram[ratio] += 1

    return {
        'all_divide': all_divide,
        'points': points,
        'collapse_histogram': dict(collapse_histogram),
        'source_periods': source_periods,
        'image_periods': image_periods,
    }


# ══════════════════════════════════════════════════════════════════════════
# Algorithm 5: Constructing Semiconjugacies from Quotient Maps
# ══════════════════════════════════════════════════════════════════════════

def construct_quotient_dynamics(
    f: Callable[[T], T],
    h: Callable[[T], S],
    domain: list[T],
) -> tuple[Optional[Callable[[S], S]], bool]:
    """
    Given f and a candidate quotient map h, attempt to construct g
    such that h ∘ f = g ∘ h (if it exists).

    The map g exists iff h(f(x)) = h(f(y)) whenever h(x) = h(y),
    i.e., h(f(·)) is constant on fibers of h.

    Returns:
        (g, True) if the quotient dynamics exists, with g as a dict-lookup function
        (None, False) if no consistent g exists

    Time complexity: O(|domain|)
    Space complexity: O(|image of h|)

    Example:
        >>> f = lambda x: (x + 1) % 6
        >>> h = lambda x: x % 3
        >>> g, ok = construct_quotient_dynamics(f, h, list(range(6)))
        >>> ok
        True
        >>> g(0), g(1), g(2)
        (1, 2, 0)
    """
    g_table: dict[S, S] = {}

    for x in domain:
        hx = h(x)
        hfx = h(f(x))

        if hx in g_table:
            if g_table[hx] != hfx:
                return None, False
        else:
            g_table[hx] = hfx

    def g(y: S) -> S:
        return g_table[y]

    return g, True


# ══════════════════════════════════════════════════════════════════════════
# Main: Example usage
# ══════════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("  Semiconjugacy Orbit Arithmetic — Algorithm Demos")
    print("=" * 60)

    # Example 1: Floyd's cycle detection
    print("\n── Floyd's Cycle Detection ──")
    f1 = lambda x: (x + 1) % 7
    mu, lam = minimal_period_floyd(f1, 0)
    print(f"f(x) = x+1 mod 7, starting at 0: preperiod={mu}, period={lam}")

    # Example 2: Orbit decomposition
    print("\n── Orbit Decomposition ──")
    table = [2, 3, 0, 1, 5, 6, 7, 4]
    f2 = lambda x: table[x]
    orbits = orbit_decomposition(f2, list(range(8)))
    for length, cycles in sorted(orbits.items()):
        for cycle in cycles:
            print(f"  Cycle of length {length}: {cycle}")

    # Example 3: Quotient construction
    print("\n── Quotient Dynamics Construction ──")
    f3 = lambda x: (x + 1) % 12
    h3 = lambda x: x % 4
    g3, ok = construct_quotient_dynamics(f3, h3, list(range(12)))
    print(f"  f(x) = x+1 mod 12, h(x) = x mod 4")
    print(f"  Quotient exists: {ok}")
    if ok and g3:
        print(f"  g: {[g3(y) for y in range(4)]}")

    # Example 4: Full divisibility analysis
    print("\n── Period Divisibility Analysis ──")
    if ok and g3:
        result = period_divisibility_analysis(f3, g3, h3, list(range(12)))
        print(f"  All divide: {result['all_divide']}")
        print(f"  Source periods: {result['source_periods']}")
        print(f"  Image periods: {result['image_periods']}")
        print(f"  Collapse histogram: {result['collapse_histogram']}")

    print("\n" + "=" * 60)
    print("  All algorithm demos completed!")
    print("=" * 60)
