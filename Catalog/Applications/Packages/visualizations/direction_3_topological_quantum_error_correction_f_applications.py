"""
Applications of Topological Quantum Error Correction from Gauge Theory

Real-world applications:
1. Quantum memory design — choosing optimal code parameters
2. Error budget analysis — how many errors can a code tolerate
3. Hardware resource estimation — qubits needed for a given protection level
4. Fault-tolerance threshold — minimum system size for useful computation
"""

import numpy as np
from typing import List, Tuple


def design_quantum_memory(target_lifetime_seconds: float,
                          physical_error_rate: float,
                          gate_time_ns: float = 100.0) -> dict:
    """Design a toric code quantum memory with a target lifetime.
    
    Given:
    - target_lifetime: desired memory lifetime in seconds
    - physical_error_rate: single-qubit error probability per gate
    - gate_time_ns: gate operation time in nanoseconds
    
    Returns optimal code parameters and resource requirements.
    
    The toric code has logical error rate ~ (c·p)^(L/2) where c ≈ 0.1,
    so lifetime ~ gate_time / (c·p)^(L/2).
    """
    # Threshold constant for toric code
    c_threshold = 0.1
    effective_rate = c_threshold * physical_error_rate
    
    if effective_rate >= 1.0:
        return {'feasible': False, 'reason': 'Error rate above threshold'}
    
    # Required suppression: lifetime = gate_time / effective_rate^(L/2)
    # So effective_rate^(L/2) = gate_time / lifetime
    gate_time_s = gate_time_ns * 1e-9
    required_suppression = gate_time_s / target_lifetime_seconds
    
    if required_suppression >= 1.0:
        return {'feasible': False, 'reason': 'Target already met without coding'}
    
    # L/2 = log(required_suppression) / log(effective_rate)
    L_min = 2 * np.log(required_suppression) / np.log(effective_rate)
    L = max(int(np.ceil(L_min)), 2)
    
    # Ensure L is even for symmetric torus
    if L % 2 == 1:
        L += 1
    
    n_qubits = 2 * L**2
    d_code = L
    k_logical = 2
    correction_capacity = (d_code - 1) // 2
    
    # Actual lifetime
    actual_suppression = effective_rate ** (L / 2)
    actual_lifetime = gate_time_s / actual_suppression
    
    return {
        'feasible': True,
        'L': L,
        'n_qubits': n_qubits,
        'k_logical': k_logical,
        'd_code': d_code,
        'correction_capacity': correction_capacity,
        'actual_lifetime_seconds': actual_lifetime,
        'target_lifetime_seconds': target_lifetime_seconds,
        'margin_factor': actual_lifetime / target_lifetime_seconds,
        'qubit_overhead': n_qubits / k_logical,
    }


def error_budget_analysis(L: int, physical_error_rate: float,
                          n_rounds: int = 1000) -> dict:
    """Analyze the error budget for a toric code of size L.
    
    Computes:
    - Maximum correctable errors per round
    - Expected errors per round
    - Probability of uncorrectable error
    - Effective logical error rate
    """
    n_qubits = 2 * L**2
    d_code = L
    max_correctable = (d_code - 1) // 2
    
    # Expected errors per round (binomial)
    expected_errors = n_qubits * physical_error_rate
    
    # Probability of > max_correctable errors (simplified upper bound)
    # Using Chernoff-like bound
    if expected_errors < max_correctable:
        # Safe regime
        from math import comb
        p_fail = sum(
            comb(n_qubits, k) * physical_error_rate**k * 
            (1 - physical_error_rate)**(n_qubits - k)
            for k in range(max_correctable + 1, min(max_correctable + 10, n_qubits + 1))
        )
    else:
        p_fail = 1.0  # Too many errors
    
    logical_error_rate = min(p_fail, 1.0)
    
    return {
        'L': L,
        'n_qubits': n_qubits,
        'd_code': d_code,
        'max_correctable': max_correctable,
        'expected_errors_per_round': expected_errors,
        'logical_error_rate': logical_error_rate,
        'safe_margin': max_correctable / max(expected_errors, 1e-10),
    }


def hardware_resource_estimate(target_distance: int) -> dict:
    """Estimate hardware resources needed for a given code distance.
    
    For the toric code with distance d:
    - L = d (system size)
    - n = 2d² (physical qubits)
    - Syndrome measurements: 2(d²-1) stabilizers per round
    - Classical decoding: O(d² log d) per round
    """
    L = target_distance
    n_qubits = 2 * L**2
    n_stabilizers = 2 * (L**2 - 1)
    decoding_ops = L**2 * int(np.ceil(np.log2(max(L, 2))))
    
    return {
        'target_distance': target_distance,
        'L': L,
        'n_physical_qubits': n_qubits,
        'n_logical_qubits': 2,
        'n_stabilizers': n_stabilizers,
        'measurements_per_round': n_stabilizers,
        'decoding_ops_per_round': decoding_ops,
        'qubit_overhead': n_qubits // 2,
        'connectivity': 4,  # Each qubit participates in 4 stabilizers
    }


def gauge_group_comparison():
    """Compare quantum codes from different gauge groups."""
    print("Gauge Group Comparison for Quantum Double Codes")
    print("=" * 70)
    print(f"{'Group':>8} {'|G|':>4} {'L':>4} {'n':>6} {'k':>3} {'d':>4} "
          f"{'Δ':>5} {'Δ·d':>5} {'t_corr':>6}")
    print("-" * 70)
    
    groups = [
        ("Z2", 2, 1.0),
        ("Z3", 3, 1.0),
        ("Z4", 4, 1.0),
        ("Z5", 5, 1.0),
        ("Z2×Z2", 4, 1.0),
    ]
    
    for group_name, order, gap in groups:
        for L in [4, 8, 16]:
            n = 2 * L**2
            k = 2
            d = L
            t = (d - 1) // 2
            print(f"{group_name:>8} {order:4d} {L:4d} {n:6d} {k:3d} {d:4d} "
                  f"{gap:5.1f} {gap*d:5.0f} {t:6d}")


if __name__ == "__main__":
    print("APPLICATION 1: Quantum Memory Design")
    print("=" * 60)
    
    scenarios = [
        ("Short computation (1ms)", 1e-3, 1e-3),
        ("Medium computation (1s)", 1.0, 1e-3),
        ("Long computation (1hr)", 3600.0, 1e-3),
        ("Quantum internet (1day)", 86400.0, 1e-4),
    ]
    
    for name, lifetime, error_rate in scenarios:
        result = design_quantum_memory(lifetime, error_rate)
        print(f"\n{name}:")
        if result['feasible']:
            print(f"  System size L = {result['L']}")
            print(f"  Physical qubits = {result['n_qubits']}")
            print(f"  Code distance = {result['d_code']}")
            print(f"  Correction capacity = {result['correction_capacity']} errors")
            print(f"  Actual lifetime = {result['actual_lifetime_seconds']:.2e} s")
            print(f"  Safety margin = {result['margin_factor']:.1f}x")
        else:
            print(f"  Not feasible: {result['reason']}")
    
    print("\n\nAPPLICATION 2: Error Budget Analysis")
    print("=" * 60)
    for L in [4, 8, 16, 32]:
        result = error_budget_analysis(L, 0.001)
        print(f"L={L:3d}: n={result['n_qubits']:5d}, "
              f"t_max={result['max_correctable']:3d}, "
              f"E[errors]={result['expected_errors_per_round']:.2f}, "
              f"p_logical={result['logical_error_rate']:.2e}")
    
    print("\n\nAPPLICATION 3: Hardware Resource Estimation")
    print("=" * 60)
    for d in [3, 5, 7, 11, 17, 25]:
        result = hardware_resource_estimate(d)
        print(f"d={d:3d}: {result['n_physical_qubits']:5d} qubits, "
              f"{result['n_stabilizers']:5d} stabilizers, "
              f"{result['decoding_ops_per_round']:6d} decode ops")
    
    print("\n")
    gauge_group_comparison()
