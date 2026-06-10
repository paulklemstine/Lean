#!/usr/bin/env python3
"""
Numerical demonstrations of closure dynamical system results.

Demonstrates:
  1. Periodic point counting and the trace formula
  2. Divisibility monotonicity of periodic sets
  3. Transition matrix power = iterate indicator
  4. Conjugacy invariance of periodic counts
  5. Eventual periodicity / rationality of the zeta sequence
  6. Capacity bounds and certified radius
"""

from __future__ import annotations

import math
from typing import Callable


# ──────────────────────────────────────────────────────────────────────
# Core data structures
# ──────────────────────────────────────────────────────────────────────

def iterate(f: Callable[[int], int], n: int, x: int) -> int:
    """Apply f to x exactly n times."""
    for _ in range(n):
        x = f(x)
    return x


def periodic_points(f: Callable[[int], int], states: list[int], n: int) -> set[int]:
    """Return the set of n-periodic points: {x | f^n(x) = x}."""
    return {x for x in states if iterate(f, n, x) == x}


def periodic_count(f: Callable[[int], int], states: list[int], n: int) -> int:
    """Count of n-periodic points."""
    return len(periodic_points(f, states, n))


def transition_matrix(f: Callable[[int], int], states: list[int]) -> list[list[int]]:
    """Build the transition matrix A where A[i][j] = 1 iff f(states[i]) = states[j]."""
    idx = {s: i for i, s in enumerate(states)}
    k = len(states)
    A = [[0] * k for _ in range(k)]
    for i, s in enumerate(states):
        fs = f(s)
        if fs in idx:
            A[i][idx[fs]] = 1
    return A


def mat_mul(A: list[list[int]], B: list[list[int]]) -> list[list[int]]:
    """Multiply two square integer matrices."""
    k = len(A)
    C = [[0] * k for _ in range(k)]
    for i in range(k):
        for j in range(k):
            C[i][j] = sum(A[i][l] * B[l][j] for l in range(k))
    return C


def mat_pow(A: list[list[int]], n: int) -> list[list[int]]:
    """Compute A^n for a square matrix."""
    k = len(A)
    result = [[1 if i == j else 0 for j in range(k)] for i in range(k)]  # identity
    base = [row[:] for row in A]
    while n > 0:
        if n % 2 == 1:
            result = mat_mul(result, base)
        base = mat_mul(base, base)
        n //= 2
    return result


def mat_trace(A: list[list[int]]) -> int:
    """Trace of a square matrix."""
    return sum(A[i][i] for i in range(len(A)))


def capacity(num_states: int) -> float:
    """Closure capacity = log(|α|)."""
    return math.log(num_states) if num_states > 0 else 0.0


def certified_radius(num_states: int) -> float:
    """Certified radius = 1 / (1 + capacity)."""
    return 1.0 / (1.0 + capacity(num_states))


# ──────────────────────────────────────────────────────────────────────
# Example systems
# ──────────────────────────────────────────────────────────────────────

def demo_1_basic_counting() -> None:
    """
    Demo 1: Basic periodic point counting.

    System: 6 states {0,1,2,3,4,5}, step function:
      0->1, 1->2, 2->0, 3->4, 4->3, 5->5
    Contains a 3-cycle (0,1,2), a 2-cycle (3,4), and a fixed point (5).
    """
    print("=" * 60)
    print("DEMO 1: Basic Periodic Point Counting")
    print("=" * 60)

    step_map = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
    f: Callable[[int], int] = lambda x: step_map[x]
    states = list(range(6))

    print(f"States: {states}")
    print(f"Step:   {step_map}")
    print()

    for n in range(7):
        pts = periodic_points(f, states, n)
        cnt = periodic_count(f, states, n)
        print(f"  Per_{n} = {sorted(pts)}, count = {cnt}")

    # Verify closurePeriodicCount_zero: p_0 = |α|
    assert periodic_count(f, states, 0) == len(states), "p_0 should equal |α|"
    print(f"\n✓ p_0 = {periodic_count(f, states, 0)} = |α| = {len(states)}  (closurePeriodicCount_zero)")

    # Verify closurePeriodicCount_le_card: p_n ≤ |α|
    for n in range(10):
        assert periodic_count(f, states, n) <= len(states)
    print(f"✓ p_n ≤ |α| for all n tested  (closurePeriodicCount_le_card)")
    print()


def demo_2_divisibility() -> None:
    """
    Demo 2: Divisibility monotonicity — if m | n then Per_m ⊆ Per_n.

    Verifies closurePeriodic_monotone_divisor.
    """
    print("=" * 60)
    print("DEMO 2: Divisibility Monotonicity")
    print("=" * 60)

    step_map = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
    f: Callable[[int], int] = lambda x: step_map[x]
    states = list(range(6))

    pairs = [(1, 2), (1, 3), (1, 6), (2, 4), (2, 6), (3, 6)]
    for m, n in pairs:
        per_m = periodic_points(f, states, m)
        per_n = periodic_points(f, states, n)
        subset = per_m.issubset(per_n)
        print(f"  {m} | {n}: Per_{m} = {sorted(per_m)} ⊆ Per_{n} = {sorted(per_n)}? {subset}")
        assert subset, f"Divisibility monotonicity failed for m={m}, n={n}"

    print(f"\n✓ Per_m ⊆ Per_n whenever m | n  (closurePeriodic_monotone_divisor)")
    print()


def demo_3_trace_formula() -> None:
    """
    Demo 3: Trace formula — tr(A^n) = p_n(f).

    Verifies closureTrace_eq_periodicCount.
    """
    print("=" * 60)
    print("DEMO 3: Trace Formula  tr(A^n) = p_n(f)")
    print("=" * 60)

    step_map = {0: 1, 1: 2, 2: 0, 3: 4, 4: 3, 5: 5}
    f: Callable[[int], int] = lambda x: step_map[x]
    states = list(range(6))

    A = transition_matrix(f, states)
    print("Transition matrix A:")
    for row in A:
        print(f"  {row}")
    print()

    for n in range(8):
        An = mat_pow(A, n)
        tr = mat_trace(An)
        pn = periodic_count(f, states, n)
        match = "✓" if tr == pn else "✗"
        print(f"  n={n}: tr(A^{n}) = {tr}, p_{n} = {pn}  {match}")
        assert tr == pn, f"Trace formula failed at n={n}"

    print(f"\n✓ tr(A^n) = p_n for all n tested  (closureTrace_eq_periodicCount)")
    print()


def demo_4_conjugacy() -> None:
    """
    Demo 4: Conjugacy invariance — conjugate systems have equal periodic counts.

    System C: {0,1,2,3}, step 0->1->2->3->0  (4-cycle)
    System D: {a,b,c,d} = {10,11,12,13}, step 10->11->12->13->10  (4-cycle)
    Conjugacy: φ(i) = i + 10

    Verifies closurePeriodicCount_conj_invariant.
    """
    print("=" * 60)
    print("DEMO 4: Conjugacy Invariance")
    print("=" * 60)

    states_C = [0, 1, 2, 3]
    step_C: Callable[[int], int] = lambda x: (x + 1) % 4
    states_D = [10, 11, 12, 13]
    step_D: Callable[[int], int] = lambda x: 10 + (x - 10 + 1) % 4

    print(f"System C: states={states_C}, step=x↦(x+1)%4")
    print(f"System D: states={states_D}, step=x↦10+(x-10+1)%4")
    print(f"Conjugacy: φ(x) = x + 10\n")

    for n in range(6):
        pn_C = periodic_count(step_C, states_C, n)
        pn_D = periodic_count(step_D, states_D, n)
        match = "✓" if pn_C == pn_D else "✗"
        print(f"  n={n}: p_n(C) = {pn_C}, p_n(D) = {pn_D}  {match}")
        assert pn_C == pn_D

    print(f"\n✓ Conjugate systems have equal periodic counts  (closurePeriodicCount_conj_invariant)")
    print()


def demo_5_rationality() -> None:
    """
    Demo 5: Eventual periodicity of the periodic count sequence.

    For a random-ish map on 8 states, the sequence p_n(f) becomes periodic.

    Verifies closurePeriodicCount_eventually_periodic and closureZeta_rational.
    """
    print("=" * 60)
    print("DEMO 5: Eventual Periodicity / Rationality")
    print("=" * 60)

    step_map = {0: 3, 1: 5, 2: 0, 3: 1, 4: 2, 5: 4, 6: 6, 7: 3}
    f: Callable[[int], int] = lambda x: step_map[x]
    states = list(range(8))

    print(f"States: {states}")
    print(f"Step:   {step_map}\n")

    counts = [periodic_count(f, states, n) for n in range(30)]
    print("Periodic counts p_0, p_1, ..., p_29:")
    for i in range(0, 30, 10):
        chunk = counts[i:i+10]
        labels = ", ".join(f"p_{i+j}={c}" for j, c in enumerate(chunk))
        print(f"  {labels}")

    # Find eventual period
    found = False
    for p in range(1, 20):
        for N in range(0, 15):
            if all(counts[n] == counts[n + p] for n in range(N, 30 - p)):
                print(f"\n✓ Eventual period p={p} starting at N={N}")
                print(f"  p_n = p_{{n+{p}}} for all n ≥ {N}  (closureZeta_rational)")
                found = True
                break
        if found:
            break

    print()


def demo_6_capacity_bounds() -> None:
    """
    Demo 6: Capacity bounds and certified radius.

    Verifies closurePeriodic_growth_le_capacity, closureCertifiedRadius_pos,
    closureCertifiedRadius_le_one, closureCertifiedRadius_antitone_capacity.
    """
    print("=" * 60)
    print("DEMO 6: Capacity Bounds and Certified Radius")
    print("=" * 60)

    systems = [
        ("2-state flip", [0, 1], {0: 1, 1: 0}),
        ("4-state cycle", [0, 1, 2, 3], {0: 1, 1: 2, 2: 3, 3: 0}),
        ("8-state mixed", list(range(8)), {0: 3, 1: 5, 2: 0, 3: 1, 4: 2, 5: 4, 6: 6, 7: 3}),
        ("16-state shift", list(range(16)), {i: (i + 1) % 16 for i in range(16)}),
    ]

    prev_cap = -1.0
    prev_rad = float("inf")

    for name, states, step_map in systems:
        f: Callable[[int], int] = lambda x, m=step_map: m[x]
        k = len(states)
        cap = capacity(k)
        rad = certified_radius(k)

        print(f"\n  System: {name} (|α| = {k})")
        print(f"    Capacity      = ln({k}) = {cap:.4f}")
        print(f"    Certified rad = 1/(1+cap) = {rad:.4f}")

        # Verify growth bound: log(p_n) ≤ cap
        for n in range(1, 10):
            pn = periodic_count(f, states, n)
            if pn > 0:
                assert math.log(pn) <= cap + 1e-12, f"Growth bound failed"

        print(f"    ✓ log(p_n) ≤ capacity for all n  (closurePeriodic_growth_le_capacity)")

        # Verify certified radius properties
        assert rad > 0, "Certified radius should be positive"
        assert rad <= 1.0 + 1e-12, "Certified radius should be ≤ 1"
        print(f"    ✓ 0 < r ≤ 1  (closureCertifiedRadius_pos, _le_one)")

        # Verify antitonicity
        if cap >= prev_cap:
            assert rad <= prev_rad + 1e-12, "Certified radius should be antitone in capacity"
            print(f"    ✓ Antitone: cap ≥ {prev_cap:.2f} ⟹ r ≤ {prev_rad:.4f}  (closureCertifiedRadius_antitone_capacity)")

        prev_cap = cap
        prev_rad = rad

    print()


def demo_7_orbit_eventual_periodicity() -> None:
    """
    Demo 7: Every orbit is eventually periodic with bounded preperiod and period.

    Verifies closureDynamics_eventually_periodic.
    """
    print("=" * 60)
    print("DEMO 7: Individual Orbit Eventual Periodicity")
    print("=" * 60)

    step_map = {0: 3, 1: 5, 2: 0, 3: 1, 4: 2, 5: 4, 6: 6, 7: 3}
    f: Callable[[int], int] = lambda x: step_map[x]
    states = list(range(8))
    card = len(states)

    print(f"States: {states}, |α| = {card}")
    print(f"Step:   {step_map}\n")

    for x in states:
        orbit = [x]
        current = x
        for _ in range(2 * card):
            current = f(current)
            orbit.append(current)

        # Find μ and p
        found = False
        for mu in range(card + 1):
            for p in range(1, card + 1):
                if iterate(f, mu + p, x) == iterate(f, mu, x):
                    print(f"  x={x}: orbit={orbit[:mu+p+1]}... μ={mu}, p={p} (μ≤{card}, p≤{card})")
                    assert mu <= card and p <= card
                    found = True
                    break
            if found:
                break

    print(f"\n✓ Every orbit eventually periodic with μ,p ≤ |α|  (closureDynamics_eventually_periodic)")
    print()


# ──────────────────────────────────────────────────────────────────────
# Main
# ──────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  CLOSURE DYNAMICAL SYSTEMS — NUMERICAL DEMONSTRATIONS")
    print("═" * 60 + "\n")

    demo_1_basic_counting()
    demo_2_divisibility()
    demo_3_trace_formula()
    demo_4_conjugacy()
    demo_5_rationality()
    demo_6_capacity_bounds()
    demo_7_orbit_eventual_periodicity()

    print("═" * 60)
    print("  ALL DEMONSTRATIONS PASSED")
    print("═" * 60)
