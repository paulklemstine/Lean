#!/usr/bin/env python3
"""
Multi-Channel Factoring Optimization Demo
==========================================
Explores optimal k selection for multi-channel factoring,
channel scaling, and the birthday paradox connection.
"""

from math import comb, sqrt, log2, gcd
import random
import time

def total_channels(k):
    """Total GCD channels from two k-tuples."""
    return k**2 + 2 * comb(k, 2)

def marginal_gain(k):
    """Marginal channels from increasing k by 1."""
    return total_channels(k+1) - total_channels(k)

def demo_channel_scaling():
    """Show how channels scale with k."""
    print("=" * 70)
    print("CHANNEL SCALING ANALYSIS")
    print("=" * 70)
    print()
    print(f"{'k':>4} {'Cross k²':>10} {'Within 2C(k,2)':>15} {'Total':>8} {'= 2k²-k':>8} {'Marginal':>10}")
    print("-" * 65)
    
    for k in range(2, 21):
        cross = k**2
        within = 2 * comb(k, 2)
        total = cross + within
        formula = 2*k**2 - k
        marg = marginal_gain(k-1) if k > 2 else "—"
        marg_str = f"4·{k-1}+1={4*(k-1)+1}" if k > 2 else "—"
        print(f"{k:>4} {cross:>10} {within:>15} {total:>8} {formula:>8} {marg_str:>10}")
    print()

def simulate_cross_collision(N, k, num_trials=1000):
    """Simulate cross-collision factoring."""
    p = min(d for d in range(2, N) if N % d == 0)
    q = N // p
    
    successes = 0
    total_tuples = 0
    
    for _ in range(num_trials):
        # Generate two k-tuples of random residues mod N
        tuple1 = [random.randint(1, N-1) for _ in range(k)]
        tuple2 = [random.randint(1, N-1) for _ in range(k)]
        total_tuples += 2
        
        # Check all k² cross-collisions
        found = False
        for a in tuple1:
            for b in tuple2:
                g = gcd(abs(a - b), N)
                if 1 < g < N:
                    successes += 1
                    found = True
                    break
            if found:
                break
        
        if not found:
            # Check within-tuple collisions too
            for i in range(k):
                for j in range(i+1, k):
                    g = gcd(abs(tuple1[i] - tuple1[j]), N)
                    if 1 < g < N:
                        successes += 1
                        found = True
                        break
                if found:
                    break
    
    return successes / num_trials, total_tuples / num_trials

def demo_birthday_analysis():
    """Birthday paradox analysis for factoring."""
    print("=" * 70)
    print("BIRTHDAY PARADOX FOR FACTORING")
    print("=" * 70)
    print()
    
    N = 10007 * 10009  # ~10^8
    print(f"N = {N} = 10007 × 10009")
    print(f"√N ≈ {int(sqrt(N))}")
    print()
    
    print(f"{'k':>4} {'Channels':>10} {'√N/k':>10} {'Theory tuples':>15} {'Speedup':>10}")
    print("-" * 55)
    
    sqrtN = sqrt(N)
    for k in [1, 2, 4, 8, 16, 32]:
        channels = total_channels(k)
        tuples_needed = sqrtN / k
        speedup = k
        print(f"{k:>4} {channels:>10} {int(tuples_needed):>10} {int(tuples_needed):>15} {speedup:>10}×")
    print()

def demo_optimal_k():
    """Find optimal k for various computational budgets."""
    print("=" * 70)
    print("OPTIMAL k SELECTION")
    print("=" * 70)
    print()
    print("Cost model: generating one k-tuple costs k units")
    print("            need ~√N/k tuples for expected collision")
    print("            total cost = k · √N/k = √N (leading term)")
    print("            but with k² channels, success prob scales as k²/N")
    print()
    
    N = 10**6
    sqrtN = sqrt(N)
    
    print(f"N = {N}, √N = {int(sqrtN)}")
    print()
    print(f"{'k':>4} {'Tuple cost':>12} {'Tuples needed':>15} {'Total cost':>12} {'Channels':>10}")
    print("-" * 60)
    
    for k in range(1, 33):
        tuple_cost = k
        tuples_needed = max(1, int(sqrtN / k))
        total_cost = tuple_cost * tuples_needed
        channels = total_channels(k)
        print(f"{k:>4} {tuple_cost:>12} {tuples_needed:>15} {total_cost:>12} {channels:>10}")
    print()
    
    # Find minimum
    costs = [(k, k * max(1, int(sqrtN/k))) for k in range(1, 100)]
    best_k, best_cost = min(costs, key=lambda x: x[1])
    print(f"Optimal k ≈ {best_k} (total cost = {best_cost})")
    print()

def demo_multi_factor():
    """Demonstrate advantage with multiple prime factors."""
    print("=" * 70)
    print("MULTI-FACTOR ADVANTAGE (E12)")
    print("=" * 70)
    print()
    
    cases = [
        ("Semiprime", [101, 103]),
        ("3 factors", [7, 11, 13]),
        ("4 factors", [3, 5, 7, 11]),
        ("5 factors", [2, 3, 5, 7, 11]),
    ]
    
    for name, factors in cases:
        N = 1
        for f in factors:
            N *= f
        
        num_divisors = 1
        for _ in factors:
            num_divisors *= 2
        
        nontrivial = num_divisors - 2
        
        print(f"{name}: N = {'×'.join(map(str, factors))} = {N}")
        print(f"  Total divisors: {num_divisors}")
        print(f"  Nontrivial divisors: {nontrivial}")
        print(f"  Factor-finding probability per GCD: ~{nontrivial}/{N} = {nontrivial/N:.6f}")
        print()
    print()

if __name__ == "__main__":
    demo_channel_scaling()
    demo_birthday_analysis()
    demo_optimal_k()
    demo_multi_factor()
