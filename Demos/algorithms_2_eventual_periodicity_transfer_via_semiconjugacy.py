#!/usr/bin/env python3
"""
Algorithms for Semiconjugacy Transfer and Orbit Analysis

Implements the core algorithms from the research paper:
1. Orbit collision detection (Floyd's algorithm)
2. Semiconjugacy verification
3. Transfer of eventual periodicity parameters
4. Cycle structure analysis under semiconjugacy

All algorithms include complexity analysis and type hints.
"""

from typing import Callable, Tuple, List, Dict, Optional, Set
from dataclasses import dataclass


@dataclass
class OrbitStructure:
    """Complete orbit structure for a point under a map."""
    start: int
    pre_period: int      # m: steps before entering cycle
    period: int           # n: cycle length
    tail: List[int]       # orbit values before cycle
    cycle: List[int]      # orbit values in the cycle

    def __repr__(self):
        return (f"OrbitStructure(start={self.start}, "
                f"pre_period={self.pre_period}, period={self.period}, "
                f"tail={self.tail}, cycle={self.cycle})")


def floyd_cycle_detection(f: Callable[[int], int], x0: int) -> Tuple[int, int]:
    """
    Floyd's Tortoise and Hare algorithm for cycle detection.

    Given a function f and starting point x0, finds the pre-period m
    and period n of the orbit x0, f(x0), f(f(x0)), ...

    Returns (m, n) such that:
        - f^[m+n](x0) = f^[m](x0)
        - n > 0
        - m is the smallest such pre-period
        - n is the smallest such period

    Time complexity: O(m + n)
    Space complexity: O(1)
    """
    # Phase 1: Find meeting point (tortoise moves 1 step, hare moves 2)
    tortoise = f(x0)
    hare = f(f(x0))
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(f(hare))

    # Phase 2: Find start of cycle (pre-period m)
    m = 0
    tortoise = x0
    while tortoise != hare:
        tortoise = f(tortoise)
        hare = f(hare)
        m += 1

    # Phase 3: Find cycle length (period n)
    n = 1
    hare = f(tortoise)
    while tortoise != hare:
        hare = f(hare)
        n += 1

    return m, n


def analyze_orbit(f: Callable[[int], int], x0: int) -> OrbitStructure:
    """
    Complete orbit analysis: compute the full tail and cycle.

    Time complexity: O(m + n)
    Space complexity: O(m + n) for storing the orbit
    """
    m, n = floyd_cycle_detection(f, x0)

    # Compute tail
    tail = []
    current = x0
    for _ in range(m):
        tail.append(current)
        current = f(current)

    # Compute cycle
    cycle = []
    cycle_start = current
    cycle.append(current)
    current = f(current)
    while current != cycle_start:
        cycle.append(current)
        current = f(current)

    return OrbitStructure(
        start=x0,
        pre_period=m,
        period=n,
        tail=tail,
        cycle=cycle
    )


def verify_semiconjugacy(
    h: Callable[[int], int],
    f: Callable[[int], int],
    g: Callable[[int], int],
    domain: List[int]
) -> Tuple[bool, Optional[int]]:
    """
    Verify that h is a semiconjugacy from f to g on a given domain.

    Checks: h(f(x)) = g(h(x)) for all x in domain.

    Returns (True, None) if verified, or (False, counterexample) if not.

    Time complexity: O(|domain|)
    Space complexity: O(1)
    """
    for x in domain:
        if h(f(x)) != g(h(x)):
            return False, x
    return True, None


def transfer_orbit_parameters(
    h: Callable[[int], int],
    f: Callable[[int], int],
    g: Callable[[int], int],
    x0: int
) -> Dict:
    """
    Compute and compare orbit parameters before and after semiconjugacy transfer.

    Given a semiconjugacy h from f to g, computes the orbit structure
    of x0 under f and of h(x0) under g, and verifies the transfer theorem.

    Returns a dictionary with:
        - source_orbit: OrbitStructure for f at x0
        - target_orbit: OrbitStructure for g at h(x0)
        - collision_transfers: whether all collisions transfer correctly
        - period_divides: whether target period divides source period

    Time complexity: O(m_f + n_f + m_g + n_g)
    Space complexity: O(m_f + n_f + m_g + n_g)
    """
    source = analyze_orbit(f, x0)
    target = analyze_orbit(g, h(x0))

    # Verify collision transfer
    def iterate(fn, start, n):
        for _ in range(n):
            start = fn(start)
        return start

    # The theorem says: if f^[i](x) = f^[j](x), then g^[i](h(x)) = g^[j](h(x))
    # Verify for the canonical collision: f^[m+n](x) = f^[m](x)
    m, n = source.pre_period, source.period
    fi = iterate(f, x0, m + n)
    fj = iterate(f, x0, m)
    gi = iterate(g, h(x0), m + n)
    gj = iterate(g, h(x0), m)

    collision_ok = (fi == fj) and (gi == gj)
    period_divides = source.period % target.period == 0

    return {
        'source_orbit': source,
        'target_orbit': target,
        'collision_transfers': collision_ok,
        'period_divides': period_divides,
        'source_collision': (m, m + n, fi),
        'target_collision': (m, m + n, gi),
    }


def finite_system_orbit_census(
    f: Callable[[int], int],
    g: Callable[[int], int],
    h: Callable[[int], int],
    source_size: int
) -> Dict:
    """
    Complete census of orbit structure for a finite source system under semiconjugacy.

    For every starting point in range(source_size), computes orbit parameters
    and verifies the transfer theorem.

    This implements the computational content of semiconj_eventually_periodic_of_fintype.

    Time complexity: O(source_size * max_orbit_length)
    Space complexity: O(source_size)

    Returns:
        - total_points: number of source points
        - distinct_source_cycles: number of distinct cycles in source
        - distinct_target_cycles: number of distinct cycles in target image
        - all_transfers_valid: whether the theorem holds for all points
        - max_source_period: largest source cycle length
        - max_target_period: largest target cycle length
        - period_distribution: histogram of source periods
    """
    all_valid = True
    source_cycles: Set[Tuple[int, ...]] = set()
    target_cycles: Set[Tuple[int, ...]] = set()
    period_dist: Dict[int, int] = {}
    max_s_period = 0
    max_t_period = 0

    for x0 in range(source_size):
        result = transfer_orbit_parameters(h, f, g, x0)
        s = result['source_orbit']
        t = result['target_orbit']

        if not result['collision_transfers']:
            all_valid = False

        source_cycles.add(tuple(s.cycle))
        target_cycles.add(tuple(t.cycle))
        max_s_period = max(max_s_period, s.period)
        max_t_period = max(max_t_period, t.period)
        period_dist[s.period] = period_dist.get(s.period, 0) + 1

    return {
        'total_points': source_size,
        'distinct_source_cycles': len(source_cycles),
        'distinct_target_cycles': len(target_cycles),
        'all_transfers_valid': all_valid,
        'max_source_period': max_s_period,
        'max_target_period': max_t_period,
        'period_distribution': period_dist,
    }


def compute_rho_shape(f: Callable[[int], int], x0: int, max_steps: int = 1000) -> Dict:
    """
    Compute the ρ (rho) shape of an orbit — the characteristic lasso structure.

    Named after the Greek letter ρ, whose shape (a tail leading into a loop)
    matches the structure of eventually periodic orbits.

    This is the fundamental data structure in Pollard's rho algorithm for
    integer factorization and discrete logarithm computation.

    Returns:
        - tail_length: pre-period m
        - cycle_length: period n
        - tail_values: values in the tail
        - cycle_values: values in the cycle
        - total_distinct: number of distinct orbit values
    """
    m, n = floyd_cycle_detection(f, x0)

    # Compute tail
    tail = []
    current = x0
    for _ in range(m):
        tail.append(current)
        current = f(current)

    # Compute cycle
    cycle = [current]
    current = f(current)
    while current != cycle[0]:
        cycle.append(current)
        current = f(current)

    return {
        'tail_length': m,
        'cycle_length': n,
        'tail_values': tail,
        'cycle_values': cycle,
        'total_distinct': m + n,
    }


# ─── Example usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Semiconjugacy Transfer")
    print("=" * 50)

    # Define a semiconjugate pair
    N, M = 128, 16
    f = lambda x: (7 * x + 3) % N
    g = lambda y: (7 * y + 3) % M
    h = lambda x: x % M

    # Verify semiconjugacy
    ok, cex = verify_semiconjugacy(h, f, g, list(range(N)))
    print(f"\nSemiconjugacy verified: {ok}")

    # Analyze a single orbit
    print("\nSingle orbit analysis:")
    result = transfer_orbit_parameters(h, f, g, 42)
    print(f"  Source: pre-period={result['source_orbit'].pre_period}, "
          f"period={result['source_orbit'].period}")
    print(f"  Target: pre-period={result['target_orbit'].pre_period}, "
          f"period={result['target_orbit'].period}")
    print(f"  Collision transfers: {result['collision_transfers']}")
    print(f"  Period divides: {result['period_divides']}")

    # Full census
    print("\nFull system census:")
    census = finite_system_orbit_census(f, g, h, N)
    for k, v in census.items():
        print(f"  {k}: {v}")

    # Rho shape
    print("\nRho shape analysis:")
    rho = compute_rho_shape(f, 1)
    print(f"  Tail: {rho['tail_values']}")
    print(f"  Cycle: {rho['cycle_values']}")
    print(f"  Total distinct states: {rho['total_distinct']}")
