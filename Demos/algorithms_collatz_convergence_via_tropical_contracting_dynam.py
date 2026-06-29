#!/usr/bin/env python3
"""
Algorithms for Tropical Bellman Contraction in Collatz Dynamics

Implements the core algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

from typing import Dict, List, Tuple, Callable, Optional
import math


def collatz_step(n: int) -> int:
    """Accelerated Collatz step: n/2 if even, (3n+1)/2 if odd.
    
    Fixed points at 0 and 1. This is the standard compressed map
    that combines 3n+1 with the mandatory halving.
    
    Time complexity: O(1)
    
    Examples:
        >>> collatz_step(1)
        1
        >>> collatz_step(6)
        3
        >>> collatz_step(3)
        5
    """
    if n <= 1:
        return n
    return n // 2 if n % 2 == 0 else (3 * n + 1) // 2


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the full Collatz orbit from n to 1 (or until max_steps).
    
    Returns the sequence [n, T(n), T²(n), ...] stopping at 1 or max_steps.
    
    Time complexity: O(min(orbit_length, max_steps))
    Space complexity: O(min(orbit_length, max_steps))
    
    Examples:
        >>> collatz_orbit(3)
        [3, 5, 8, 4, 2, 1]
        >>> collatz_orbit(1)
        [1]
    """
    orbit = [n]
    current = n
    for _ in range(max_steps):
        if current <= 1:
            break
        current = collatz_step(current)
        orbit.append(current)
    return orbit


def bellman_value_iteration(
    gamma: float,
    step_fn: Callable[[int], int],
    target: int,
    N: int,
    epsilon: float = 1e-10,
    max_iters: int = 10000
) -> Tuple[Dict[int, float], List[float], int]:
    """Run value iteration for a general Bellman operator.
    
    Computes the unique fixed point V* of the operator:
        B_γ(V)(n) = 0 if n = target, else 1 + γ · V(step(n))
    
    Args:
        gamma: Discount factor in [0, 1)
        step_fn: The dynamical system step function
        target: Target state (fixed point of step_fn)
        N: Upper bound on state space {0, ..., N}
        epsilon: Convergence tolerance
        max_iters: Maximum number of iterations
    
    Returns:
        V: Approximate fixed point as dict {state: value}
        errors: List of sup-norm errors at each iteration
        num_iters: Number of iterations performed
    
    Time complexity: O(N · log(1/ε) / log(1/γ))
    Space complexity: O(N)
    
    Convergence guarantee: ||V_k - V*||∞ ≤ γ^k · ||V_0 - V*||∞
    """
    V = {n: 0.0 for n in range(N + 1)}
    errors = []
    
    for iteration in range(max_iters):
        V_new = {}
        for n in range(N + 1):
            if n == target:
                V_new[n] = 0.0
            else:
                next_state = step_fn(n)
                V_new[n] = 1.0 + gamma * V.get(next_state, 0.0)
        
        error = max(abs(V_new[n] - V[n]) for n in range(N + 1))
        errors.append(error)
        V = V_new
        
        if error < epsilon:
            return V, errors, iteration + 1
    
    return V, errors, max_iters


def discounted_orbit_cost(
    gamma: float,
    n: int,
    step_fn: Callable[[int], int] = collatz_step,
    target: int = 1,
    max_steps: int = 100000
) -> Tuple[float, int]:
    """Compute discounted orbit cost directly along the orbit.
    
    Returns V*(n) = Σ_{k=0}^{s-1} γ^k where s is the number of steps
    to reach the target.
    
    Args:
        gamma: Discount factor in [0, 1)
        n: Starting state
        step_fn: Step function (default: collatzStep)
        target: Target state (default: 1)
        max_steps: Maximum orbit length
    
    Returns:
        cost: The discounted orbit cost
        steps: Number of steps to reach target (or max_steps)
    
    Time complexity: O(min(orbit_length, max_steps))
    """
    cost = 0.0
    power = 1.0
    current = n
    steps = 0
    
    while current != target and steps < max_steps:
        cost += power
        power *= gamma
        current = step_fn(current)
        steps += 1
    
    return cost, steps


def contraction_verification(
    gamma: float,
    step_fn: Callable[[int], int],
    target: int,
    N: int,
    num_iters: int = 20
) -> Tuple[List[float], List[float]]:
    """Verify the contraction property by computing error ratios.
    
    Returns the sequence of errors and their ratios to confirm
    that each ratio is ≤ γ.
    
    Args:
        gamma: Discount factor
        step_fn: Step function
        target: Target state
        N: State space bound
        num_iters: Number of iterations
    
    Returns:
        errors: Sup-norm errors at each iteration
        ratios: Error ratios (errors[k+1] / errors[k])
    """
    _, errors, _ = bellman_value_iteration(
        gamma, step_fn, target, N, 
        epsilon=0, max_iters=num_iters
    )
    
    ratios = []
    for i in range(len(errors) - 1):
        if errors[i] > 1e-15:
            ratios.append(errors[i + 1] / errors[i])
        else:
            ratios.append(0.0)
    
    return errors, ratios


def expansion_ratio(
    step_fn: Callable[[int], int],
    m: int,
    n: int
) -> float:
    """Compute the distance expansion ratio |T(m)-T(n)| / |m-n|.
    
    Used to verify Theorem E (obstruction to contraction).
    
    Returns inf if m == n.
    """
    if m == n:
        return float('inf')
    d_input = abs(m - n)
    d_output = abs(step_fn(m) - step_fn(n))
    return d_output / d_input


def find_max_expansion(
    step_fn: Callable[[int], int],
    N: int
) -> Tuple[float, int, int]:
    """Find the maximum expansion ratio over pairs in {0, ..., N}.
    
    Returns (max_ratio, m, n) achieving the maximum.
    """
    max_ratio = 0.0
    best_m, best_n = 0, 0
    
    for m in range(N + 1):
        for n in range(m):
            ratio = expansion_ratio(step_fn, m, n)
            if ratio > max_ratio:
                max_ratio = ratio
                best_m, best_n = m, n
    
    return max_ratio, best_m, best_n


if __name__ == '__main__':
    # Example usage
    print("=== Bellman Value Iteration for Collatz ===")
    gamma = 0.9
    V, errors, iters = bellman_value_iteration(gamma, collatz_step, 1, 100)
    print(f"Converged in {iters} iterations (γ = {gamma})")
    print(f"V*(3) = {V[3]:.6f}")
    print(f"V*(27) = {V[27]:.6f}")
    
    print("\n=== Direct Orbit Cost ===")
    for n in [3, 7, 27]:
        cost, steps = discounted_orbit_cost(gamma, n)
        print(f"n={n}: cost={cost:.6f}, steps={steps}")
    
    print("\n=== Maximum Expansion Ratio ===")
    ratio, m, n = find_max_expansion(collatz_step, 20)
    print(f"Max ratio = {ratio:.3f} at (m,n) = ({m},{n})")
    print(f"T({m}) = {collatz_step(m)}, T({n}) = {collatz_step(n)}")
