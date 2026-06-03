#!/usr/bin/env python3
"""
Quantum Random Walk Demo: Mixing Times on Cayley Graphs

Demonstrates the quadratic quantum speedup for random walks on
Cayley graphs of finite groups.
"""

import math
from algorithms import (
    cyclic_group,
    symmetric_group,
    analyze_group,
    cyclic_spectral_gap_exact,
    cayley_adjacency_matrix,
    quantum_walk_evolution,
    measurement_probabilities,
    total_variation_distance,
)
import numpy as np


def demo_cyclic_groups():
    """Demonstrate quantum speedup on cyclic groups ℤ/nℤ."""
    print("=" * 70)
    print("QUANTUM RANDOM WALKS ON CYCLIC GROUPS ℤ/nℤ")
    print("=" * 70)
    print()

    for n in [5, 10, 20, 50, 100]:
        elements, generators, op, inv = cyclic_group(n)
        result = analyze_group(f"ℤ/{n}ℤ", elements, generators, op, inv)

        exact_gap = cyclic_spectral_gap_exact(n)
        lower_bound = 2.0 / n**2

        print(f"Group: {result['name']}")
        print(f"  Order: {result['group_order']}")
        print(f"  Spectral gap (computed): {result['spectral_gap']:.6f}")
        print(f"  Spectral gap (exact):    {exact_gap:.6f}")
        print(f"  Lower bound 2/n²:        {lower_bound:.6f}")
        print(f"  Classical mixing time:   {result['classical_mixing_time']:.2f}")
        print(f"  Quantum mixing time:     {result['quantum_mixing_time']:.2f}")
        print(f"  Speedup ratio √(1/γ):    {result['speedup_ratio']:.2f}")
        print(f"  Ratio ≈ n/√2:            {n / math.sqrt(2):.2f}")
        print()


def demo_symmetric_groups():
    """Demonstrate quantum speedup on symmetric groups S_n."""
    print("=" * 70)
    print("QUANTUM RANDOM WALKS ON SYMMETRIC GROUPS S_n")
    print("=" * 70)
    print()

    for n in [3, 4, 5]:
        elements, generators, op, inv = symmetric_group(n)
        result = analyze_group(f"S_{n}", elements, generators, op, inv)

        print(f"Group: {result['name']}")
        print(f"  Order: {result['group_order']} = {n}!")
        print(f"  Generators: {result['num_generators']} transpositions")
        print(f"  Spectral gap: {result['spectral_gap']:.6f}")
        print(f"  Expected gap ≈ 1/{n}: {1.0/n:.6f}")
        print(f"  Classical mixing time: {result['classical_mixing_time']:.2f}")
        print(f"  Quantum mixing time:   {result['quantum_mixing_time']:.2f}")
        print(f"  Speedup ratio:         {result['speedup_ratio']:.2f}")
        print(f"  Expected √n:           {math.sqrt(n):.2f}")
        print()


def demo_quantum_walk_simulation():
    """Simulate a quantum walk on ℤ/20ℤ and show convergence."""
    print("=" * 70)
    print("QUANTUM WALK SIMULATION ON ℤ/20ℤ")
    print("=" * 70)
    print()

    n = 20
    elements, generators, op, inv = cyclic_group(n)
    A = cayley_adjacency_matrix(elements, generators, op, inv)

    initial_state = np.zeros(n, dtype=complex)
    initial_state[0] = 1.0
    uniform = np.ones(n) / n

    print(f"{'Time':>8} {'TV Distance':>12} {'Status':>10}")
    print("-" * 35)

    for t_int in range(0, 201, 10):
        t = float(t_int)
        state = quantum_walk_evolution(A, initial_state, t)
        probs = measurement_probabilities(state)
        tv = total_variation_distance(probs, uniform)

        status = "MIXED" if tv < 0.1 else ""
        print(f"{t:>8.1f} {tv:>12.6f} {status:>10}")


def demo_spectral_gap_verification():
    """Verify the spectral gap bound 2/n² ≤ 1 - cos(2π/n)."""
    print("=" * 70)
    print("SPECTRAL GAP BOUND VERIFICATION: 2/n² ≤ 1 - cos(2π/n)")
    print("=" * 70)
    print()

    print(f"{'n':>5} {'2/n²':>12} {'1-cos(2π/n)':>14} {'Ratio':>8} {'Valid':>6}")
    print("-" * 50)

    for n in range(3, 51):
        lower = 2.0 / n**2
        exact = 1.0 - math.cos(2 * math.pi / n)
        ratio = exact / lower

        valid = "✓" if lower <= exact + 1e-15 else "✗"
        print(f"{n:>5} {lower:>12.8f} {exact:>14.8f} {ratio:>8.4f} {valid:>6}")


def demo_universal_bound():
    """Verify the universal bound τ_quantum ≤ √(N/γ) · log(N/ε)."""
    print()
    print("=" * 70)
    print("UNIVERSAL QUANTUM SPEEDUP BOUND VERIFICATION")
    print("=" * 70)
    print()

    groups = []

    for n in [5, 10, 20, 50]:
        elems, gens, op, inv = cyclic_group(n)
        groups.append((f"ℤ/{n}ℤ", elems, gens, op, inv))

    for n in [3, 4]:
        elems, gens, op, inv = symmetric_group(n)
        groups.append((f"S_{n}", elems, gens, op, inv))

    epsilon = 0.01

    print(f"{'Group':>10} {'|G|':>5} {'γ':>10} {'τ_Q':>10} {'√(N/γ)·L':>12} {'Ratio':>8}")
    print("-" * 60)

    for name, elems, gens, op, inv in groups:
        result = analyze_group(name, elems, gens, op, inv, epsilon)
        N = result['group_order']
        gap = result['spectral_gap']
        tau_q = result['quantum_mixing_time']
        universal = math.sqrt(N / gap) * (math.log(N) + math.log(1 / epsilon))
        ratio = tau_q / universal if universal > 0 else 0

        print(f"{name:>10} {N:>5} {gap:>10.6f} {tau_q:>10.2f} {universal:>12.2f} {ratio:>8.4f}")


if __name__ == "__main__":
    demo_cyclic_groups()
    demo_symmetric_groups()
    demo_quantum_walk_simulation()
    demo_spectral_gap_verification()
    demo_universal_bound()
