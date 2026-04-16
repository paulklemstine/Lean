#!/usr/bin/env python3
"""
Energy Landscape 3D Visualization and Gradient Descent Factoring

This demo visualizes the factoring energy function E(x) = N mod x
and demonstrates how gradient descent on this landscape finds factors.

Formally verified foundations:
- divisor_is_local_min: Divisors are local minima of E(x)
- energy_pos_of_not_dvd: Non-divisors have positive energy
- sublevel_zero_divisors: Zero-energy points = divisors
"""

import math
import random
from collections import defaultdict

def energy(N, x):
    """The factoring energy function E(N, x) = N mod x."""
    if x == 0:
        return float('inf')
    return N % x

def energy_landscape(N, x_range=None):
    """Compute the full energy landscape for N."""
    if x_range is None:
        x_range = range(1, N + 1)
    return {x: energy(N, x) for x in x_range}

def find_divisors_via_energy(N):
    """Find all divisors of N by scanning for zero-energy points."""
    return [x for x in range(1, N + 1) if energy(N, x) == 0]

def gradient_descent_factor(N, start=None, max_steps=1000):
    """
    Discrete gradient descent on E(x) to find factors of N.

    Starting from a random point, move toward lower energy.
    Formally verified: divisors are the ONLY local minima with E=0.
    """
    if start is None:
        start = random.randint(2, max(2, int(math.sqrt(N)) + 10))

    x = start
    path = [x]

    for _ in range(max_steps):
        if energy(N, x) == 0:
            return x, path  # Found a divisor!

        # Check neighbors
        e_curr = energy(N, x)
        e_left = energy(N, x - 1) if x > 1 else float('inf')
        e_right = energy(N, x + 1) if x + 1 <= N else float('inf')

        if e_left < e_curr and e_left <= e_right:
            x -= 1
        elif e_right < e_curr:
            x += 1
        else:
            # Local minimum but not zero - jump to a new position
            x = random.randint(2, int(math.sqrt(N)) + 10)

        path.append(x)

    return None, path

def basin_analysis(N):
    """
    Analyze basins of attraction for each divisor.
    For each starting point, determine which divisor gradient descent reaches.
    """
    basins = defaultdict(list)

    for start in range(2, N):
        x = start
        for _ in range(N):
            if energy(N, x) == 0:
                basins[x].append(start)
                break
            e_left = energy(N, x - 1) if x > 1 else float('inf')
            e_right = energy(N, x + 1) if x <= N else float('inf')
            e_curr = energy(N, x)

            if e_left < e_curr and e_left <= e_right:
                x -= 1
            elif e_right < e_curr:
                x += 1
            else:
                break
        else:
            basins['stuck'].append(start)

    return dict(basins)

def morse_theory_analysis(N):
    """
    Compute Morse-theoretic invariants of the energy landscape.

    Formally verified:
    - laplacian_nonneg_at_divisor: Discrete Laplacian ≥ 0 at divisors
    - energy_bound: E(N, x) < x for all x > 0
    """
    critical_points = {'minima': [], 'maxima': [], 'saddles': []}

    for x in range(2, N):
        e = energy(N, x)
        e_left = energy(N, x - 1)
        e_right = energy(N, x + 1)

        laplacian = e_right + e_left - 2 * e

        if e <= e_left and e <= e_right:
            critical_points['minima'].append((x, e, laplacian))
        elif e >= e_left and e >= e_right:
            critical_points['maxima'].append((x, e, laplacian))
        elif (e < e_left and e > e_right) or (e > e_left and e < e_right):
            critical_points['saddles'].append((x, e, laplacian))

    return critical_points

def persistent_homology_filtration(N):
    """
    Compute the sublevel set filtration for persistent homology.

    Formally verified:
    - sublevel_zero_divisors: At t=0, sublevel = divisors
    - sublevel_monotone: Sublevel sets grow monotonically
    - sublevel_full: At t=N-1, sublevel = [1,N]
    """
    events = []
    energies = sorted(set(energy(N, x) for x in range(1, N + 1)))

    for t in energies:
        sublevel = [x for x in range(1, N + 1) if energy(N, x) <= t]
        # Count connected components
        components = 0
        prev_in = False
        for x in range(1, N + 1):
            if energy(N, x) <= t:
                if not prev_in:
                    components += 1
                prev_in = True
            else:
                prev_in = False
        events.append((t, len(sublevel), components))

    return events

def demo_factoring():
    """Demonstrate energy landscape factoring on several composites."""
    test_cases = [
        (15, "3 × 5"),
        (77, "7 × 11"),
        (143, "11 × 13"),
        (221, "13 × 17"),
        (323, "17 × 19"),
        (1073, "29 × 37"),
        (2021, "43 × 47"),
        (10403, "101 × 103"),
    ]

    print("=" * 70)
    print("ENERGY LANDSCAPE FACTORING DEMO")
    print("Formally verified: divisors are exactly the zero-energy local minima")
    print("=" * 70)

    for N, expected in test_cases:
        divisors = find_divisors_via_energy(N)
        nontrivial = [d for d in divisors if 1 < d < N]

        # Try gradient descent
        factor, path = gradient_descent_factor(N)

        print(f"\nN = {N} ({expected})")
        print(f"  Divisors found via E=0 scan: {divisors}")
        print(f"  Nontrivial factors: {nontrivial}")
        if factor:
            print(f"  Gradient descent found: {factor} in {len(path)} steps")
        else:
            print(f"  Gradient descent: not converged in {len(path)} steps")

def demo_morse_theory():
    """Demonstrate Morse theory analysis."""
    N = 105  # = 3 × 5 × 7
    print("\n" + "=" * 70)
    print(f"MORSE THEORY ANALYSIS: N = {N} = 3 × 5 × 7")
    print("=" * 70)

    cp = morse_theory_analysis(N)

    print(f"\nLocal minima (verified: includes all divisors):")
    for x, e, lap in cp['minima'][:15]:
        marker = " ← DIVISOR" if e == 0 else ""
        print(f"  x={x:3d}, E={e:3d}, Laplacian={lap:+4d}{marker}")

    print(f"\nLocal maxima (energy barriers between divisors):")
    for x, e, lap in cp['maxima'][:10]:
        print(f"  x={x:3d}, E={e:3d}, Laplacian={lap:+4d}")

    zero_minima = sum(1 for _, e, _ in cp['minima'] if e == 0)
    divisors = find_divisors_via_energy(N)
    print(f"\nZero-energy minima: {zero_minima}")
    print(f"Number of divisors: {len(divisors)}")
    print(f"Match (formally verified): {'YES' if zero_minima == len(divisors) - 1 else 'CHECK'}")

def demo_persistent_homology():
    """Demonstrate persistent homology filtration."""
    N = 30  # = 2 × 3 × 5
    print("\n" + "=" * 70)
    print(f"PERSISTENT HOMOLOGY FILTRATION: N = {N} = 2 × 3 × 5")
    print("=" * 70)

    events = persistent_homology_filtration(N)

    print(f"\nFiltration events (threshold, sublevel size, components):")
    for t, size, comp in events[:15]:
        print(f"  t={t:3d}: |sublevel|={size:3d}, components={comp:2d}")

    print(f"\nKey verified properties:")
    print(f"  sublevel(0) = divisors: {[x for x in range(1, N+1) if energy(N, x) == 0]}")
    print(f"  sublevel(N-1) = [1,N]: size = {events[-1][1]} (expected {N})")
    print(f"  Monotonicity: {all(events[i][1] <= events[i+1][1] for i in range(len(events)-1))}")

def demo_basin_analysis():
    """Demonstrate basin of attraction analysis."""
    N = 35  # = 5 × 7
    print("\n" + "=" * 70)
    print(f"BASIN OF ATTRACTION ANALYSIS: N = {N} = 5 × 7")
    print("=" * 70)

    basins = basin_analysis(N)

    for divisor in sorted(basins.keys()):
        if divisor != 'stuck':
            points = basins[divisor]
            print(f"\n  Basin of d={divisor}: {len(points)} points")
            print(f"    Starting points: {points[:20]}{'...' if len(points) > 20 else ''}")

    if 'stuck' in basins:
        print(f"\n  Stuck points: {len(basins['stuck'])}")

if __name__ == "__main__":
    demo_factoring()
    demo_morse_theory()
    demo_persistent_homology()
    demo_basin_analysis()
