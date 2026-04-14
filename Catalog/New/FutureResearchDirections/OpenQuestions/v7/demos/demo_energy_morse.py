#!/usr/bin/env python3
"""
Energy Landscape Morse Theory Demo (A7, C13)

Visualizes the energy landscape E(x) = N mod x, its critical points,
sublevel sets, and Morse-theoretic structure.
"""

import math

def energy(N, x):
    """E(N, x) = N mod x."""
    return N % x

def discrete_laplacian(N, x):
    """Discrete second derivative at x."""
    if x <= 1:
        return 0
    return energy(N, x+1) + energy(N, x-1) - 2 * energy(N, x)

def total_variation(N):
    """Total variation of E over [1, N]."""
    tv = 0
    for x in range(1, N):
        tv += abs(energy(N, x+1) - energy(N, x))
    return tv

def divisors(N):
    """Return sorted list of divisors of N."""
    divs = []
    for d in range(1, int(math.sqrt(N)) + 1):
        if N % d == 0:
            divs.append(d)
            if d != N // d:
                divs.append(N // d)
    return sorted(divs)

def sublevel_set_size(N, t):
    """Size of sublevel set {x ∈ [1,N] : E(N,x) ≤ t}."""
    return sum(1 for x in range(1, N+1) if energy(N, x) <= t)

def demo_energy_landscape():
    """Display the energy landscape for various N."""
    print("=" * 70)
    print("ENERGY LANDSCAPE E(x) = N mod x")
    print("=" * 70)

    for N in [30, 77, 105]:
        divs = divisors(N)
        print(f"\n  N = {N}, divisors = {divs}")
        print(f"  {'x':>4} {'E(N,x)':>8} {'Div?':>5} {'Laplacian':>10} {'Bar':>20}")
        print("  " + "-" * 50)

        for x in range(1, min(N+1, 40)):
            e = energy(N, x)
            is_div = "✓" if N % x == 0 else ""
            lap = discrete_laplacian(N, x) if x > 1 else "-"
            bar = "█" * min(e, 20)
            print(f"  {x:4d} {e:8d} {is_div:>5} {str(lap):>10} {bar}")

def demo_sublevel_filtration():
    """Show how sublevel sets grow as threshold increases."""
    print("\n" + "=" * 70)
    print("SUBLEVEL SET FILTRATION")
    print("=" * 70)

    N = 30
    divs = divisors(N)
    print(f"\n  N = {N}, divisors = {divs}, τ(N) = {len(divs)}")
    print(f"\n  {'Threshold t':>12} {'|Sublevel(t)|':>15} {'New points':>12}")
    print("  " + "-" * 45)

    prev_size = 0
    for t in range(0, N):
        size = sublevel_set_size(N, t)
        if size != prev_size:
            print(f"  {t:12d} {size:15d} {size - prev_size:12d}")
            prev_size = size

    print(f"\n  At t=0: |Sublevel(0)| = {sublevel_set_size(N, 0)} = τ({N}) = {len(divs)} ✓")
    print(f"  At t={N-1}: |Sublevel({N-1})| = {sublevel_set_size(N, N-1)} = N = {N} ✓")

def demo_critical_points():
    """Analyze critical points and Morse indices."""
    print("\n" + "=" * 70)
    print("CRITICAL POINT ANALYSIS (MORSE THEORY)")
    print("=" * 70)

    for N in [30, 77, 210]:
        divs = divisors(N)
        print(f"\n  N = {N}")
        print(f"  Divisors (zero-energy critical points): {divs}")
        print(f"  Number of local minima = τ(N) = {len(divs)}")

        # Compute Laplacian at each divisor
        print(f"\n  {'Divisor d':>10} {'E(d)':>6} {'E(d-1)':>8} {'E(d+1)':>8} {'Laplacian':>10} {'Type':>8}")
        print("  " + "-" * 55)

        for d in divs:
            if d == 1:
                continue
            e_d = energy(N, d)
            e_prev = energy(N, d-1)
            e_next = energy(N, d+1) if d < N else 0
            lap = discrete_laplacian(N, d)
            pt_type = "MIN" if lap >= 0 else "SADDLE"
            print(f"  {d:10d} {e_d:6d} {e_prev:8d} {e_next:8d} {lap:10d} {pt_type:>8}")

        # Total variation
        tv = total_variation(N)
        avg_e = sum(energy(N, x) for x in range(1, N+1)) / N
        print(f"\n  Total variation: {tv}")
        print(f"  Average energy: {avg_e:.2f}")
        print(f"  Energy bound (N²): {N*N}")

def demo_semiprime_landscape():
    """Compare energy landscapes of primes vs semiprimes."""
    print("\n" + "=" * 70)
    print("PRIME vs SEMIPRIME ENERGY LANDSCAPES")
    print("=" * 70)

    cases = [
        ("Prime", 23),
        ("Semiprime", 21),  # 3 × 7
        ("Semiprime", 35),  # 5 × 7
        ("3-smooth", 30),   # 2 × 3 × 5
    ]

    for label, N in cases:
        divs = divisors(N)
        zero_count = sum(1 for x in range(1, N+1) if energy(N, x) == 0)
        tv = total_variation(N)
        avg_e = sum(energy(N, x) for x in range(1, N+1)) / N

        print(f"\n  {label}: N = {N}")
        print(f"    Divisors: {divs}")
        print(f"    Zero-energy points: {zero_count} (= τ(N))")
        print(f"    Total variation: {tv}")
        print(f"    Average energy: {avg_e:.2f}")

if __name__ == "__main__":
    print("╔" + "═" * 68 + "╗")
    print("║  ENERGY LANDSCAPE MORSE THEORY — Gravitational Factoring v7       ║")
    print("╚" + "═" * 68 + "╝")

    demo_energy_landscape()
    demo_sublevel_filtration()
    demo_critical_points()
    demo_semiprime_landscape()
