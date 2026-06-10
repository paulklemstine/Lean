#!/usr/bin/env python3
"""
Algorithms for Semiconjugacy Analysis of Finite Dynamical Systems

Implements:
1. Semiconjugacy verification
2. Minimal period computation
3. Orbit decomposition
4. Compression quality metrics
5. Quotient dynamics construction
6. Periodic orbit lifting
"""

from typing import Callable, Optional
from dataclasses import dataclass
from collections import defaultdict


@dataclass
class OrbitInfo:
    """Information about the orbit of a point."""
    point: int
    minimal_period: int
    orbit: list[int]
    is_periodic: bool
    pre_period: int  # steps before entering the cycle


@dataclass
class CompressionReport:
    """Report on compression quality under semiconjugacy."""
    is_semiconjugacy: bool
    is_surjective: bool
    original_size: int
    latent_size: int
    compression_ratio: float
    original_periods: dict[int, int]  # point -> minimal period
    latent_periods: dict[int, int]    # point -> minimal period
    max_period_ratio: float           # max(period_f / period_g)
    period_preservation_rate: float   # fraction with same period
    capacity_bound_tight: bool        # is max latent period = latent size?
    orbit_count_original: int
    orbit_count_latent: int


def compute_minimal_period(f: Callable[[int], int], x: int, n: int) -> int:
    """
    Compute the minimal period of x under f on a state space of size n.

    Returns 0 if x is not periodic within n steps.
    Time: O(n), Space: O(1)
    """
    y = f(x)
    for k in range(1, n + 1):
        if y == x:
            return k
        y = f(y)
    return 0


def compute_orbit_info(f: Callable[[int], int], x: int, n: int) -> OrbitInfo:
    """
    Compute complete orbit information for a point.

    Uses Floyd's cycle detection for efficiency.
    Time: O(n), Space: O(n)
    """
    seen = {}
    current = x
    for step in range(n + 1):
        if current in seen:
            cycle_start = seen[current]
            cycle_length = step - cycle_start
            orbit = []
            y = x
            for _ in range(step):
                orbit.append(y)
                y = f(y)
            return OrbitInfo(
                point=x,
                minimal_period=cycle_length,
                orbit=orbit,
                is_periodic=(cycle_start == 0),
                pre_period=cycle_start,
            )
        seen[current] = step
        current = f(current)

    return OrbitInfo(
        point=x, minimal_period=0, orbit=list(seen.keys()),
        is_periodic=False, pre_period=-1,
    )


def verify_semiconjugacy(
    f: Callable[[int], int],
    g: Callable[[int], int],
    e: Callable[[int], int],
    n: int,
) -> bool:
    """
    Verify that e semiconjugates f to g on Fin(n).

    Checks: ∀ x ∈ {0, ..., n-1}, e(f(x)) = g(e(x))
    Time: O(n)
    """
    return all(e(f(x)) == g(e(x)) for x in range(n))


def check_surjectivity(
    e: Callable[[int], int], domain_size: int, codomain_size: int
) -> bool:
    """Check if e : Fin(domain_size) → Fin(codomain_size) is surjective."""
    image = set(e(x) for x in range(domain_size))
    return len(image) == codomain_size


def construct_quotient_dynamics(
    f: Callable[[int], int],
    e: Callable[[int], int],
    domain_size: int,
    codomain_size: int,
) -> Optional[Callable[[int], int]]:
    """
    Construct quotient dynamics g such that e semiconjugates f to g.

    Returns None if the quotient is not well-defined (fiber not invariant).
    Time: O(domain_size)
    """
    g_table: dict[int, int] = {}
    for x in range(domain_size):
        y = e(x)
        gy = e(f(x))
        if y in g_table:
            if g_table[y] != gy:
                return None  # fiber not invariant
        else:
            g_table[y] = gy

    # Check all codomain points are covered
    if len(g_table) < codomain_size:
        return None  # encoder not surjective

    return lambda y: g_table[y]


def check_fiber_invariance(
    f: Callable[[int], int],
    e: Callable[[int], int],
    domain_size: int,
) -> bool:
    """
    Check if f is fiber-invariant with respect to e.

    ∀ x, y: e(x) = e(y) → e(f(x)) = e(f(y))
    Time: O(domain_size) using hash map
    """
    fiber_images: dict[int, int] = {}
    for x in range(domain_size):
        y = e(x)
        fy_image = e(f(x))
        if y in fiber_images:
            if fiber_images[y] != fy_image:
                return False
        else:
            fiber_images[y] = fy_image
    return True


def decompose_orbits(
    f: Callable[[int], int], n: int
) -> list[list[int]]:
    """
    Decompose Fin(n) into orbits under f.

    Returns a list of orbits, where each orbit is a list of points.
    Time: O(n), Space: O(n)
    """
    visited = set()
    orbits = []
    for x in range(n):
        if x not in visited:
            orbit = []
            current = x
            while current not in visited:
                visited.add(current)
                orbit.append(current)
                current = f(current)
            orbits.append(orbit)
    return orbits


def find_periodic_orbits(
    f: Callable[[int], int], n: int
) -> list[tuple[list[int], int]]:
    """
    Find all distinct periodic orbits.

    Returns list of (cycle_points, period) tuples.
    Time: O(n), Space: O(n)
    """
    visited = set()
    cycles = []
    for x in range(n):
        if x in visited:
            continue
        # Trace the orbit
        path = []
        current = x
        while current not in visited:
            visited.add(current)
            path.append(current)
            current = f(current)
        # Check if current is in our path (forming a cycle)
        if current in path:
            idx = path.index(current)
            cycle = path[idx:]
            cycles.append((cycle, len(cycle)))
    return cycles


def lift_periodic_orbit(
    f: Callable[[int], int],
    e: Callable[[int], int],
    domain_size: int,
    y: int,
    latent_period: int,
) -> Optional[tuple[int, int]]:
    """
    Lift a periodic orbit from the latent space.

    Given y with period latent_period under g, find x with e(x) = y
    and x periodic under f.

    Returns (x, period_of_x) or None if no periodic preimage found.
    Time: O(domain_size * latent_period)
    """
    # Find preimages of y
    preimages = [x for x in range(domain_size) if e(x) == y]
    if not preimages:
        return None

    # For each preimage, check if it's periodic
    for x0 in preimages:
        p = compute_minimal_period(f, x0, domain_size)
        if p > 0:
            return (x0, p)

    # If no preimage is directly periodic, check iterates
    for x0 in preimages:
        current = x0
        for step in range(domain_size):
            current = f(current)
            p = compute_minimal_period(f, current, domain_size)
            if p > 0 and e(current) == y:
                return (current, p)

    return None


def compression_report(
    f: Callable[[int], int],
    g: Callable[[int], int],
    e: Callable[[int], int],
    domain_size: int,
    codomain_size: int,
) -> CompressionReport:
    """
    Generate a comprehensive compression quality report.

    Time: O(domain_size^2) worst case
    """
    is_semi = verify_semiconjugacy(f, g, e, domain_size)
    is_surj = check_surjectivity(e, domain_size, codomain_size)

    orig_periods = {}
    for x in range(domain_size):
        p = compute_minimal_period(f, x, domain_size)
        if p > 0:
            orig_periods[x] = p

    lat_periods = {}
    for y in range(codomain_size):
        p = compute_minimal_period(g, y, codomain_size)
        if p > 0:
            lat_periods[y] = p

    # Compute period ratios
    max_ratio = 0.0
    preserved = 0
    total = 0
    for x, pf in orig_periods.items():
        pg = compute_minimal_period(g, e(x), codomain_size)
        if pg > 0:
            ratio = pf / pg
            max_ratio = max(max_ratio, ratio)
            if pf == pg:
                preserved += 1
            total += 1

    orig_orbits = find_periodic_orbits(f, domain_size)
    lat_orbits = find_periodic_orbits(g, codomain_size)

    max_lat_period = max(lat_periods.values()) if lat_periods else 0

    return CompressionReport(
        is_semiconjugacy=is_semi,
        is_surjective=is_surj,
        original_size=domain_size,
        latent_size=codomain_size,
        compression_ratio=domain_size / codomain_size if codomain_size > 0 else float('inf'),
        original_periods=orig_periods,
        latent_periods=lat_periods,
        max_period_ratio=max_ratio,
        period_preservation_rate=preserved / total if total > 0 else 1.0,
        capacity_bound_tight=(max_lat_period == codomain_size),
        orbit_count_original=len(orig_orbits),
        orbit_count_latent=len(lat_orbits),
    )


def print_report(report: CompressionReport) -> None:
    """Pretty-print a compression report."""
    print(f"Semiconjugacy: {'✓' if report.is_semiconjugacy else '✗'}")
    print(f"Surjective:    {'✓' if report.is_surjective else '✗'}")
    print(f"Compression:   {report.original_size} → {report.latent_size} "
          f"({report.compression_ratio:.1f}x)")
    print(f"Original periodic orbits: {report.orbit_count_original}")
    print(f"Latent periodic orbits:   {report.orbit_count_latent}")
    print(f"Max period ratio:         {report.max_period_ratio:.1f}")
    print(f"Period preservation rate:  {report.period_preservation_rate:.1%}")
    print(f"Capacity bound tight:     {'✓' if report.capacity_bound_tight else '✗'}")


if __name__ == "__main__":
    # Example: analyze compression of a 12-state cyclic system to 4 states
    N, M = 12, 4
    f = lambda x: (x + 1) % N
    e = lambda x: x % M
    g = lambda y: (y + 1) % M

    print("Compression Analysis: Cyclic(12) → Cyclic(4)")
    print("-" * 50)
    report = compression_report(f, g, e, N, M)
    print_report(report)

    print("\n\nQuotient Dynamics Construction")
    print("-" * 50)
    N2, M2 = 8, 4
    f2_table = [1, 2, 3, 0, 5, 6, 7, 4]  # Two 4-cycles
    f2 = lambda x: f2_table[x]
    e2 = lambda x: x % M2

    g2 = construct_quotient_dynamics(f2, e2, N2, M2)
    if g2 is not None:
        print("Quotient dynamics constructed successfully!")
        print(f"g table: {[g2(y) for y in range(M2)]}")
        report2 = compression_report(f2, g2, e2, N2, M2)
        print_report(report2)
    else:
        print("Fiber not invariant — quotient dynamics undefined.")
