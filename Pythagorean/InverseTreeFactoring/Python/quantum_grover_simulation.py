#!/usr/bin/env python3
"""
Quantum Grover Simulation for Inverse Pythagorean Tree Factoring

Simulates a quantum computer using Grover's algorithm to search for the
critical depth d* at which the GCD test reveals a factor.

The key insight: the descent is deterministic (no branching ambiguity),
so the quantum speedup comes from Grover-searching the depth parameter,
not from exploring multiple branches.

Classical complexity: O(d*) = O(min(p,q)) for N = p·q
Quantum complexity:  O(√d*) = O(√min(p,q)) via Grover
"""

import math
import numpy as np
from typing import Tuple, Optional, List
import sys

# Import the core factoring module
sys.path.insert(0, '.')
from inverse_tree_factoring import trivial_triple, parent, full_descent

# ============================================================================
# Oracle: "Does depth d reveal a factor?"
# ============================================================================

def build_oracle(N: int) -> callable:
    """
    Build the Grover oracle function for depth-based factoring.
    
    The oracle returns True if at depth d, the GCD of any leg
    with N is nontrivial.
    """
    # Precompute the full descent path
    path = full_descent(N)
    
    def oracle(d: int) -> bool:
        if d >= len(path):
            return False
        a, b, c = path[d][0]
        ga = math.gcd(abs(a), N)
        gb = math.gcd(abs(b), N)
        return (1 < ga < N) or (1 < gb < N)
    
    return oracle, len(path) - 1

# ============================================================================
# Classical Grover Simulation (state vector)
# ============================================================================

def grover_search(oracle_func, search_space_size: int, 
                  num_solutions: int = 1, verbose: bool = False) -> int:
    """
    Simulate Grover's algorithm to find a marked element.
    
    This is a faithful simulation of the quantum algorithm's behavior,
    tracking the probability amplitudes of all states.
    
    Args:
        oracle_func: function(index) -> bool
        search_space_size: N = number of elements to search
        num_solutions: expected number of marked elements
    
    Returns:
        The index found by measurement (probabilistic)
    """
    N = search_space_size
    
    # Find actual marked elements
    marked = [i for i in range(N) if oracle_func(i)]
    M = len(marked)
    
    if M == 0:
        if verbose:
            print("No marked elements found!")
        return -1
    
    # Optimal number of Grover iterations
    theta = math.asin(math.sqrt(M / N))
    optimal_iters = max(1, round(math.pi / (4 * theta) - 0.5))
    
    if verbose:
        print(f"Search space: {N}")
        print(f"Marked elements: {M} at positions {marked}")
        print(f"θ = arcsin(√(M/N)) = {theta:.6f}")
        print(f"Optimal iterations: {optimal_iters}")
        print(f"Classical queries needed: O({N})")
        print(f"Quantum queries needed: O({optimal_iters}) ≈ O(√{N})")
    
    # Initialize uniform superposition
    amplitudes = np.full(N, 1.0 / math.sqrt(N))
    
    # Grover iterations
    for iteration in range(optimal_iters):
        # Oracle: flip sign of marked elements
        for idx in marked:
            amplitudes[idx] *= -1
        
        # Diffusion operator: 2|ψ⟩⟨ψ| - I
        mean = np.mean(amplitudes)
        amplitudes = 2 * mean - amplitudes
        
        if verbose and iteration < 5:
            prob_marked = sum(amplitudes[i]**2 for i in marked)
            prob_unmarked = sum(amplitudes[i]**2 for i in range(N) if i not in marked)
            print(f"  Iteration {iteration+1}: P(marked) = {prob_marked:.6f}, "
                  f"P(unmarked) = {prob_unmarked:.6f}")
    
    # Measurement: sample according to |amplitude|²
    probabilities = amplitudes**2
    probabilities /= probabilities.sum()  # Normalize (numerical safety)
    result = np.random.choice(N, p=probabilities)
    
    if verbose:
        prob_success = sum(probabilities[i] for i in marked)
        print(f"\nMeasurement result: {result}")
        print(f"Probability of success: {prob_success:.6f}")
        print(f"Is marked: {result in marked}")
    
    return result

# ============================================================================
# Quantum Factoring via Grover + Pythagorean Descent
# ============================================================================

def quantum_factor(N: int, verbose: bool = False) -> Optional[Tuple[int, int]]:
    """
    Factor N using simulated Grover search over descent depths.
    
    Returns (p, q) such that N = p * q, or None.
    """
    if N % 2 == 0:
        return (2, N // 2)
    
    oracle, max_depth = build_oracle(N)
    
    if max_depth == 0:
        return None
    
    if verbose:
        print(f"\n{'='*60}")
        print(f"QUANTUM FACTORING: N = {N}")
        print(f"{'='*60}")
        print(f"Maximum depth: {max_depth}")
    
    # Use Grover to find the critical depth
    d_star = grover_search(oracle, max_depth + 1, verbose=verbose)
    
    if d_star >= 0 and oracle(d_star):
        # Extract the factor
        path = full_descent(N)
        a, b, c = path[d_star][0]
        
        for component in [a, b]:
            g = math.gcd(abs(component), N)
            if 1 < g < N:
                if verbose:
                    print(f"\n✓ Factor found at depth {d_star}: {g}")
                    print(f"  N = {g} × {N // g}")
                return (g, N // g)
    
    return None

# ============================================================================
# Complexity Comparison
# ============================================================================

def complexity_comparison(max_N: int = 10000):
    """
    Compare classical and quantum query complexities for factoring semiprimes.
    """
    from itertools import combinations
    
    # Generate small primes
    def sieve(n):
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n+1, i):
                    is_prime[j] = False
        return [i for i in range(2, n+1) if is_prime[i]]
    
    primes = [p for p in sieve(200) if p > 2]  # Odd primes
    
    print(f"\n{'='*80}")
    print("COMPLEXITY COMPARISON: Classical vs Quantum Pythagorean Factoring")
    print(f"{'='*80}")
    print(f"\n{'N':>10} {'p':>6} {'q':>6} {'d*':>6} {'√d*':>8} "
          f"{'Classical':>12} {'Quantum':>12} {'Speedup':>10}")
    print("-" * 80)
    
    results = []
    
    for i, p in enumerate(primes[:20]):
        for q in primes[i+1:i+4]:
            N = p * q
            if N > max_N or N % 2 == 0:
                continue
            
            oracle, max_depth = build_oracle(N)
            
            # Find d*
            d_star = None
            for d in range(max_depth + 1):
                if oracle(d):
                    d_star = d
                    break
            
            if d_star is None:
                continue
            
            classical = d_star  # Number of oracle queries
            quantum = max(1, round(math.pi/4 * math.sqrt(max_depth / max(1, sum(1 for d in range(max_depth+1) if oracle(d))))))
            speedup = classical / max(1, quantum)
            
            results.append((N, p, q, d_star, quantum))
            
            print(f"{N:10d} {p:6d} {q:6d} {d_star:6d} {math.sqrt(d_star):8.2f} "
                  f"{classical:12d} {quantum:12d} {speedup:10.2f}x")
    
    return results

# ============================================================================
# Demo
# ============================================================================

def demo():
    print("=" * 70)
    print("QUANTUM GROVER SIMULATION FOR PYTHAGOREAN TREE FACTORING")
    print("=" * 70)
    
    # Factor a few numbers
    test_cases = [77, 143, 221, 667, 2537]
    
    for N in test_cases:
        result = quantum_factor(N, verbose=(N == 77))
        if result and N != 77:
            p, q = result
            print(f"\nN = {N}: factors = {p} × {q}")
    
    # Complexity comparison
    complexity_comparison()


if __name__ == '__main__':
    np.random.seed(42)
    demo()
