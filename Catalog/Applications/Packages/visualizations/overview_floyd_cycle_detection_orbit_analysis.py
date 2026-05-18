#!/usr/bin/env python3
"""
Semiconjugacy Orbit Arithmetic — Algorithms

Implements the core algorithms for analyzing orbit structure under semiconjugacies.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple, TypeVar
from collections import defaultdict

T = TypeVar('T')
S = TypeVar('S')


def iterate(f: Callable[[T], T], x: T, n: int) -> T:
    """Compute f^[n](x) by repeated application.

    Time complexity: O(n) applications of f.
    Space complexity: O(1) beyond f's requirements.
    """
    for _ in range(n):
        x = f(x)
    return x


def detect_cycle(f: Callable[[T], T], x0: T) -> Tuple[int, int]:
    """Floyd's cycle detection: find (preperiod, period) for the orbit of x0 under f.

    Returns (mu, lam) where:
      - mu = preperiod (number of steps before entering the cycle)
      - lam = period (length of the cycle)

    Time complexity: O(mu + lam)
    Space complexity: O(1)
    """
    # Phase 1: Find a meeting point
    tortoise = f(x0)
    hare = f(f(x0))
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(f(hare))

    # Phase 2: Find the start of the cycle (preperiod mu)
    mu = 0
    tortoise = x0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        mu += 1

    # Phase 3: Find the cycle length (period lam)
    lam = 1
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        lam += 1

    return mu, lam


def minimal_period(f: Callable[[T], T], x: T, bound: int = 10000) -> int:
    """Find the minimal period of x under f.

    Returns 0 if x is not periodic within `bound` iterations.

    Time complexity: O(bound) in worst case, O(period) for periodic points.
    Space complexity: O(1) using cycle detection.
    """
    mu, lam = detect_cycle(f, x)
    if mu == 0:
        return lam
    # x is eventually periodic but may not be periodic
    # Check if x itself is periodic
    if iterate(f, x, lam) == x:
        # Find minimal period dividing lam
        for d in range(1, lam + 1):
            if lam % d == 0 and iterate(f, x, d) == x:
                return d
    return 0  # x is not periodic (it's only eventually periodic)


def verify_semiconjugacy(
    h: Callable[[T], S],
    f: Callable[[T], T],
    g: Callable[[S], S],
    domain: List[T]
) -> Tuple[bool, Optional[T]]:
    """Verify that h ∘ f = g ∘ h on a finite domain.

    Returns (True, None) if verified, or (False, counterexample) otherwise.

    Time complexity: O(|domain|) applications of h, f, g.
    """
    for x in domain:
        if h(f(x)) != g(h(x)):
            return False, x
    return True, None


def orbit_period_analysis(
    h: Callable[[T], S],
    f: Callable[[T], T],
    g: Callable[[S], S],
    domain: List[T]
) -> Dict[str, object]:
    """Analyze the orbit period structure of a semiconjugate system.

    For each point x in the domain, computes:
    - minimal period of x under f
    - minimal period of h(x) under g
    - verifies the divisibility theorem: minimalPeriod(g, h(x)) | minimalPeriod(f, x)

    Time complexity: O(|domain| * max_period)
    Space complexity: O(|domain|)

    Returns a dictionary with analysis results.
    """
    results = {
        'points': [],
        'all_divide': True,
        'period_spectrum_f': set(),
        'period_spectrum_g': set(),
        'compression_ratios': [],
    }

    for x in domain:
        mp_f = minimal_period(f, x)
        hx = h(x)
        mp_g = minimal_period(g, hx)

        divides = (mp_f % mp_g == 0) if mp_g > 0 and mp_f > 0 else True
        ratio = mp_f / mp_g if mp_g > 0 and mp_f > 0 else None

        point_data = {
            'x': x,
            'h_x': hx,
            'period_f': mp_f,
            'period_g': mp_g,
            'divides': divides,
            'compression_ratio': ratio,
        }
        results['points'].append(point_data)

        if not divides:
            results['all_divide'] = False
        if mp_f > 0:
            results['period_spectrum_f'].add(mp_f)
        if mp_g > 0:
            results['period_spectrum_g'].add(mp_g)
        if ratio is not None:
            results['compression_ratios'].append(ratio)

    return results


def find_orbit_collision(
    h: Callable[[T], S],
    f: Callable[[T], T],
    x: T,
    codomain_size: int
) -> Tuple[int, int]:
    """Find the first orbit collision in the image: m < n with h(f^[m](x)) = h(f^[n](x)).

    By the pigeonhole principle, a collision must occur within codomain_size + 1 steps.

    Time complexity: O(codomain_size^2) in worst case, O(codomain_size) expected.
    Space complexity: O(codomain_size)

    Returns (m, n) with m < n.
    """
    seen: Dict[S, int] = {}
    current = x
    for step in range(codomain_size + 1):
        image = h(current)
        if image in seen:
            return seen[image], step
        seen[image] = step
        current = f(current)

    # Should never reach here if codomain is truly finite with the given size
    raise RuntimeError("No collision found — codomain_size may be incorrect")


def construct_semiconjugacy_from_quotient(
    f: Callable[[T], T],
    equiv_class: Callable[[T], S],
    domain: List[T]
) -> Optional[Callable[[S], S]]:
    """Attempt to construct a semiconjugate system g on the quotient space.

    Given f : T → T and a quotient map equiv_class : T → S,
    constructs g : S → S such that equiv_class ∘ f = g ∘ equiv_class,
    if such g exists (i.e., f respects the equivalence relation).

    Returns g if the construction succeeds, None otherwise.

    Time complexity: O(|domain|)
    """
    g_map: Dict[S, S] = {}

    for x in domain:
        cls_x = equiv_class(x)
        cls_fx = equiv_class(f(x))

        if cls_x in g_map:
            if g_map[cls_x] != cls_fx:
                return None  # f doesn't respect the equivalence
        else:
            g_map[cls_x] = cls_fx

    return lambda y: g_map[y]


def functional_digraph_decomposition(
    f: Callable[[T], T],
    domain: List[T]
) -> Dict[str, object]:
    """Decompose a finite dynamical system into its cycle + tail structure.

    Every finite functional digraph decomposes into disjoint components,
    each consisting of a single cycle with trees hanging off cycle nodes.

    Time complexity: O(|domain|)
    Space complexity: O(|domain|)

    Returns:
    - cycles: list of cycles (each a list of elements)
    - tails: dict mapping tail elements to their eventual cycle entry point
    - cycle_lengths: set of distinct cycle lengths
    """
    visited = set()
    in_cycle = set()
    cycles = []
    tails = {}

    for start in domain:
        if start in visited:
            continue

        # Trace the orbit until we hit something visited or loop
        path = []
        path_set = set()
        current = start

        while current not in visited and current not in path_set:
            path.append(current)
            path_set.add(current)
            current = f(current)

        if current in path_set:
            # Found a new cycle
            cycle_start_idx = path.index(current)
            cycle = path[cycle_start_idx:]
            tail = path[:cycle_start_idx]

            cycles.append(cycle)
            for c in cycle:
                in_cycle.add(c)
                visited.add(c)
            for t in tail:
                tails[t] = current
                visited.add(t)
        else:
            # current was already visited — entire path is a tail
            for p in path:
                if p not in visited:
                    # Find the entry to the visited part
                    tails[p] = current
                    visited.add(p)

    return {
        'cycles': cycles,
        'cycle_lengths': {len(c) for c in cycles},
        'num_cycles': len(cycles),
        'tails': tails,
        'num_tail_elements': len(tails),
    }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=== Orbit Period Analysis ===\n")

    # Example: Z/12Z → Z/4Z
    f = lambda x: (x + 5) % 12
    g = lambda y: (y + 1) % 4
    h = lambda x: x % 4

    analysis = orbit_period_analysis(h, f, g, list(range(12)))
    print(f"All divisibility constraints satisfied: {analysis['all_divide']}")
    print(f"Period spectrum of f: {sorted(analysis['period_spectrum_f'])}")
    print(f"Period spectrum of g: {sorted(analysis['period_spectrum_g'])}")
    print(f"Compression ratios: {sorted(set(r for r in analysis['compression_ratios'] if r))}")

    print("\n=== Orbit Collision Detection ===\n")

    f2 = lambda x: x + 7
    h2 = lambda x: x % 10
    m, n = find_orbit_collision(h2, f2, 0, 10)
    print(f"First collision at steps m={m}, n={n}")
    print(f"h(f^[{m}](0)) = {h2(iterate(f2, 0, m))}")
    print(f"h(f^[{n}](0)) = {h2(iterate(f2, 0, n))}")

    print("\n=== Functional Digraph Decomposition ===\n")

    perm = {0: 1, 1: 2, 2: 0, 3: 4, 4: 5, 5: 3, 6: 7, 7: 3}
    f3 = lambda x: perm[x]
    decomp = functional_digraph_decomposition(f3, list(range(8)))
    print(f"Number of cycles: {decomp['num_cycles']}")
    print(f"Cycle lengths: {decomp['cycle_lengths']}")
    print(f"Cycles: {decomp['cycles']}")
    print(f"Tail elements: {decomp['num_tail_elements']}")
    print(f"Tail mapping: {decomp['tails']}")
