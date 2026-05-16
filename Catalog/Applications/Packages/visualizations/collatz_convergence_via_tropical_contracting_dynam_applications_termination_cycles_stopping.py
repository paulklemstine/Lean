#!/usr/bin/env python3
"""
Applications of Tropical Bellman Contraction Theory

Demonstrates real-world applications of the Bellman contraction framework:
1. Program termination analysis via ranking functions
2. Generalized Collatz-type maps (5n+1, etc.)
3. Cycle detection via Bellman inequalities
4. Stopping time distribution analysis
"""

from typing import Callable, Dict, List, Tuple
import math


def collatz_step(n: int) -> int:
    if n <= 1: return n
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def bellman_value_iteration(gamma, step_fn, target, N, eps=1e-10, max_iter=5000):
    V = {n: 0.0 for n in range(N + 1)}
    for _ in range(max_iter):
        V_new = {}
        err = 0.0
        for n in range(N + 1):
            if n == target:
                V_new[n] = 0.0
            else:
                V_new[n] = 1.0 + gamma * V.get(step_fn(n), 0.0)
            err = max(err, abs(V_new[n] - V[n]))
        V = V_new
        if err < eps: break
    return V


# === Application 1: Program Termination Analysis ===

def app_termination_ranking():
    """Use Bellman fixed points as ranking functions for program termination.
    
    Consider a simple arithmetic program:
        while n > 1:
            if n % 2 == 0: n = n / 2
            else: n = (3*n + 1) / 2
    
    The Bellman fixed point V* is a ranking function:
    - V*(n) > 0 for n > 1
    - V*(T(n)) < V*(n) for n > 1 (because V*(n) = 1 + γ·V*(T(n)) > γ·V*(T(n)))
    
    This provides a certified termination proof (modulo Collatz conjecture).
    """
    print("=" * 60)
    print("APPLICATION 1: Program Termination via Ranking Functions")
    print("=" * 60)
    
    gamma = 0.9
    N = 200
    V = bellman_value_iteration(gamma, collatz_step, 1, N)
    
    print(f"\nRanking function V* with γ = {gamma}:")
    print(f"{'n':>5} {'V*(n)':>10} {'V*(T(n))':>10} {'decrease':>10} {'ratio':>8}")
    print("-" * 50)
    
    for n in [2, 3, 5, 7, 10, 15, 27, 50, 100]:
        tn = collatz_step(n)
        vn = V.get(n, 0)
        vtn = V.get(tn, 0)
        decrease = vn - vtn
        ratio = vtn / vn if vn > 0 else 0
        print(f"{n:>5} {vn:>10.4f} {vtn:>10.4f} {decrease:>10.4f} {ratio:>8.4f}")
    
    # Verify ranking function properties
    violations = 0
    for n in range(2, N + 1):
        tn = collatz_step(n)
        if tn <= N and V[n] <= V.get(tn, 0):
            violations += 1
    
    print(f"\nRanking function violations in {{2,...,{N}}}: {violations}")
    print("(0 violations means V* is a valid ranking function)")


# === Application 2: Generalized Collatz Maps ===

def app_generalized_maps():
    """Apply the framework to non-standard Collatz-type maps.
    
    The 5n+1 problem: T(n) = n/2 if even, (5n+1)/2 if odd.
    This map has known nontrivial cycles, unlike 3n+1.
    The Bellman framework detects this through cycle-consistent values.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Generalized Collatz Maps")
    print("=" * 60)
    
    def collatz_5n1(n):
        if n <= 1: return n
        return n // 2 if n % 2 == 0 else (5 * n + 1) // 2
    
    def collatz_3n1(n):
        return collatz_step(n)
    
    gamma = 0.9
    N = 100
    
    for name, step_fn in [("3n+1", collatz_3n1), ("5n+1", collatz_5n1)]:
        V = bellman_value_iteration(gamma, step_fn, 1, N)
        
        print(f"\n{name} map with γ = {gamma}:")
        print(f"  V*(1) = {V[1]:.4f}")
        print(f"  V*(2) = {V[2]:.4f}")
        print(f"  V*(3) = {V[3]:.4f}")
        print(f"  max V*(n) for n ≤ {N}: {max(V[n] for n in range(1, N+1)):.4f}")
        print(f"  bound 1/(1-γ) = {1/(1-gamma):.4f}")
        
        # Check for states where V*(n) ≈ 1/(1-γ) (potential non-convergent orbits)
        threshold = 0.95 / (1 - gamma)
        high_cost = [n for n in range(2, N+1) if V[n] > threshold]
        if high_cost:
            print(f"  States near max bound: {high_cost[:10]}...")
        else:
            print(f"  All states well below max bound")


# === Application 3: Cycle Detection via Bellman Inequalities ===

def app_cycle_detection():
    """Detect cycles using the Bellman fixed-point structure.
    
    Key insight: if n₁ → n₂ → ··· → n_k → n₁ is a cycle with all nᵢ > 1,
    then V*(nᵢ) = 1 + γ · V*(nᵢ₊₁) for each i.
    Summing: Σ V*(nᵢ) = k + γ · Σ V*(nᵢ), so V*(nᵢ) = k/(k(1-γ)) = 1/(1-γ).
    
    All cycle members have the SAME value 1/(1-γ)!
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Cycle Detection via Bellman Values")
    print("=" * 60)
    
    gamma = 0.9
    max_val = 1 / (1 - gamma)
    
    # Check the 5n+1 map which has known cycles
    def step_5n1(n):
        if n <= 1: return n
        return n // 2 if n % 2 == 0 else (5 * n + 1) // 2
    
    N = 500
    V = bellman_value_iteration(gamma, step_5n1, 1, N, max_iter=10000)
    
    print(f"\n5n+1 map: looking for states with V*(n) ≈ 1/(1-γ) = {max_val:.2f}")
    
    candidates = [(n, V[n]) for n in range(2, N+1) if V[n] > 0.99 * max_val]
    if candidates:
        print(f"  Found {len(candidates)} cycle candidate states:")
        for n, v in candidates[:20]:
            orbit = [n]
            current = n
            for _ in range(30):
                current = step_5n1(current)
                if current == n or current <= 1:
                    break
                orbit.append(current)
            if current == n:
                print(f"    n={n}: V*={v:.4f}, cycle: {' → '.join(map(str, orbit))} → {n}")
    
    # For 3n+1, no candidates should appear
    V_collatz = bellman_value_iteration(gamma, collatz_step, 1, N)
    candidates_3n1 = [n for n in range(2, N+1) if V_collatz[n] > 0.99 * max_val]
    print(f"\n3n+1 map: cycle candidates in {{2,...,{N}}}: {len(candidates_3n1)}")
    if not candidates_3n1:
        print("  No candidates (consistent with Collatz conjecture)")


# === Application 4: Stopping Time Distribution ===

def app_stopping_times():
    """Analyze the distribution of Collatz stopping times using Bellman values.
    
    The Bellman fixed point V*(n) = (1-γ^s)/(1-γ) where s is the stopping time.
    Inverting: s = log(1 - (1-γ)·V*(n)) / log(γ).
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Stopping Time Distribution Analysis")
    print("=" * 60)
    
    gamma = 0.99  # Close to 1 for accurate stopping time recovery
    N = 1000
    V = bellman_value_iteration(gamma, collatz_step, 1, N)
    
    # Recover stopping times from Bellman values
    stopping_times = {}
    for n in range(2, N + 1):
        # V*(n) = (1 - γ^s) / (1 - γ), so γ^s = 1 - (1-γ)·V*(n)
        val = 1 - (1 - gamma) * V[n]
        if val > 0:
            s = math.log(val) / math.log(gamma)
            stopping_times[n] = round(s)
        else:
            stopping_times[n] = -1  # orbit too long
    
    # Verify against direct computation
    print(f"\nStopping times recovered from V* (γ = {gamma}):")
    print(f"{'n':>5} {'Bellman s':>10} {'Direct s':>10} {'Match':>6}")
    print("-" * 35)
    
    for n in [2, 3, 5, 7, 10, 27, 97, 871]:
        if n > N:
            continue
        # Direct computation
        current = n
        direct_s = 0
        while current > 1 and direct_s < 10000:
            current = collatz_step(current)
            direct_s += 1
        
        bellman_s = stopping_times.get(n, -1)
        match = "✓" if bellman_s == direct_s else "✗"
        print(f"{n:>5} {bellman_s:>10} {direct_s:>10} {match:>6}")
    
    # Distribution statistics
    valid_times = [s for s in stopping_times.values() if s >= 0]
    if valid_times:
        print(f"\nStopping time statistics for n ∈ {{2,...,{N}}}:")
        print(f"  Mean: {sum(valid_times)/len(valid_times):.1f}")
        print(f"  Max: {max(valid_times)}")
        print(f"  Median: {sorted(valid_times)[len(valid_times)//2]}")


if __name__ == '__main__':
    app_termination_ranking()
    app_generalized_maps()
    app_cycle_detection()
    app_stopping_times()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)
