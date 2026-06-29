#!/usr/bin/env python3
"""
Algorithms for Arithmetic Pseudorandom Generators

Implements the core algorithms from the spectral-gap-to-fooling framework,
including averaging operator construction, spectral analysis, and 
pseudorandom walk generation for arithmetic semigroups.
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class SpectralAnalysis:
    """Result of spectral analysis of an averaging operator."""
    spectral_radius: float
    spectral_gap: float
    eigenvalues: np.ndarray
    is_expander: bool
    mixing_time_estimate: int


@dataclass
class FoolingResult:
    """Result of testing whether a walk fools a given test function."""
    test_name: str
    initial_error: float
    errors_by_step: List[float]
    theoretical_bound: List[float]
    spectral_radius: float


def build_averaging_operator(
    state_space_size: int,
    generators: List[np.ndarray],
    action: Callable[[np.ndarray, Tuple], Tuple],
    states: List[Tuple]
) -> np.ndarray:
    """
    Build the averaging operator matrix for a semigroup action.
    
    Algorithm:
        Input: State space S, generators g_1,...,g_r, action · : G × S → S
        Output: Matrix T ∈ R^{|S| × |S|}
        
        1. Initialize T = 0
        2. For each state s_i ∈ S:
            3. For each generator g_k:
                4. Compute t = g_k · s_i
                5. Find index j such that s_j = t
                6. T[j, i] += 1/r
        7. Return T
    
    Time complexity: O(|S| · r · lookup_cost)
    Space complexity: O(|S|²)
    
    Args:
        state_space_size: Number of states |S|
        generators: List of r generator matrices/transformations
        action: Function (generator, state) → new_state
        states: List of all states
    
    Returns:
        Averaging operator matrix T
    """
    r = len(generators)
    state_to_idx = {s: i for i, s in enumerate(states)}
    T = np.zeros((state_space_size, state_space_size))
    
    for i, s in enumerate(states):
        for gen in generators:
            t = action(gen, s)
            j = state_to_idx[t]
            T[j, i] += 1.0 / r
    
    return T


def compute_spectral_analysis(T: np.ndarray) -> SpectralAnalysis:
    """
    Compute complete spectral analysis of an averaging operator.
    
    Algorithm:
        Input: Doubly stochastic matrix T ∈ R^{N×N}
        Output: SpectralAnalysis record
        
        1. Compute all eigenvalues λ_1 ≥ λ_2 ≥ ... ≥ λ_N
        2. Verify λ_1 ≈ 1 (Perron-Frobenius)
        3. Set ρ = max(|λ_2|, ..., |λ_N|)  (spectral radius on mean-zero)
        4. Set gap = 1 - ρ
        5. Estimate mixing time ≈ 1/gap · ln(N)
        6. Return analysis
    
    Time complexity: O(N³) for eigenvalue computation
    """
    eigenvalues = np.linalg.eigvals(T)
    mags = np.abs(eigenvalues)
    sorted_mags = np.sort(mags)[::-1]
    
    rho = sorted_mags[1] if len(sorted_mags) > 1 else 0.0
    gap = 1.0 - rho
    N = T.shape[0]
    mixing_time = int(np.ceil(np.log(N) / gap)) if gap > 1e-10 else N
    
    return SpectralAnalysis(
        spectral_radius=rho,
        spectral_gap=gap,
        eigenvalues=eigenvalues,
        is_expander=(gap > 0.01),
        mixing_time_estimate=mixing_time
    )


def test_fooling(
    T: np.ndarray,
    f: np.ndarray,
    max_steps: int,
    test_name: str = "unnamed"
) -> FoolingResult:
    """
    Test whether a random walk fools a given test function.
    
    Algorithm:
        Input: Averaging operator T, test function f, max steps n_max
        Output: FoolingResult with error trajectory
        
        1. Compute E[f] = mean(f)
        2. Compute ||f - E[f]||∞ = C
        3. Compute spectral radius ρ of T
        4. For n = 0, 1, ..., n_max:
            5. Compute T^n f
            6. error[n] = max_x |T^n f(x) - E[f]|
            7. bound[n] = C · ρ^n
        8. Return results
    
    Time complexity: O(n_max · N²)
    """
    analysis = compute_spectral_analysis(T)
    rho = analysis.spectral_radius
    
    mean_f = np.mean(f)
    C = np.max(np.abs(f - mean_f))
    
    errors = []
    bounds = []
    current = f.copy()
    
    for n in range(max_steps + 1):
        error = np.max(np.abs(current - mean_f))
        errors.append(error)
        bounds.append(C * rho**n)
        current = T @ current
    
    return FoolingResult(
        test_name=test_name,
        initial_error=C,
        errors_by_step=errors,
        theoretical_bound=bounds,
        spectral_radius=rho
    )


def berggren_action_mod_q(gen: np.ndarray, state: Tuple[int, ...], q: int) -> Tuple[int, ...]:
    """Apply a Berggren generator to a state in (Z/qZ)³."""
    s = np.array(state, dtype=int)
    result = (gen @ s) % q
    return tuple(result.tolist())


def build_berggren_system(q: int) -> Tuple[np.ndarray, List[Tuple], SpectralAnalysis]:
    """
    Build and analyze the complete Berggren system mod q.
    
    Algorithm:
        Input: Modulus q ≥ 2
        Output: (T, states, analysis)
        
        1. Enumerate all states (a,b,c) ∈ (Z/qZ)³
        2. Define Berggren generators A, B, C
        3. Build averaging operator T
        4. Compute spectral analysis
        5. Return (T, states, analysis)
    
    Time complexity: O(q⁶) for matrix construction, O(q⁹) for eigenvalues
    """
    A = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
    B = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
    C = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])
    
    generators = [A, B, C]
    states = [(a, b, c) for a in range(q) for b in range(q) for c in range(q)]
    N = len(states)
    
    action = lambda gen, s: berggren_action_mod_q(gen, s, q)
    T = build_averaging_operator(N, generators, action, states)
    analysis = compute_spectral_analysis(T)
    
    return T, states, analysis


def pseudorandom_walk(
    T: np.ndarray,
    initial_state_idx: int,
    n_steps: int
) -> List[int]:
    """
    Generate a pseudorandom walk using the averaging operator.
    
    At each step, choose a random generator (uniformly) and apply it.
    Returns the trajectory as a list of state indices.
    
    Algorithm:
        Input: T, initial state index, number of steps
        Output: List of state indices visited
        
        1. Set current = initial_state_idx
        2. trajectory = [current]
        3. For step = 1, ..., n_steps:
            4. Choose next state from distribution T[:, current]
            5. trajectory.append(next)
            6. current = next
        7. Return trajectory
    """
    trajectory = [initial_state_idx]
    current = initial_state_idx
    
    for _ in range(n_steps):
        probs = T[:, current]
        next_state = np.random.choice(len(probs), p=probs)
        trajectory.append(next_state)
        current = next_state
    
    return trajectory


def estimate_mixing_time(T: np.ndarray, epsilon: float = 0.01) -> int:
    """
    Estimate the mixing time: minimum n such that max test error < epsilon.
    
    Algorithm:
        Input: Averaging operator T, threshold ε
        Output: Mixing time n*
        
        1. Compute ρ = spectral radius
        2. Return ⌈log(1/ε) / log(1/ρ)⌉
    
    Time complexity: O(N³) for eigenvalue computation
    """
    analysis = compute_spectral_analysis(T)
    rho = analysis.spectral_radius
    
    if rho >= 1.0 - 1e-12:
        return -1  # No mixing
    
    return int(np.ceil(np.log(1.0 / epsilon) / np.log(1.0 / rho)))


if __name__ == "__main__":
    print("Building Berggren system mod 5...")
    T, states, analysis = build_berggren_system(5)
    
    print(f"  State space size: {len(states)}")
    print(f"  Spectral radius: {analysis.spectral_radius:.6f}")
    print(f"  Spectral gap: {analysis.spectral_gap:.6f}")
    print(f"  Is expander: {analysis.is_expander}")
    print(f"  Mixing time estimate: {analysis.mixing_time_estimate}")
    
    # Test with linear function
    f = np.array([s[0] for s in states], dtype=float)
    result = test_fooling(T, f, 20, "Linear: a")
    
    print(f"\n  Fooling test '{result.test_name}':")
    print(f"    Initial error: {result.initial_error:.6f}")
    print(f"    Error at n=10: {result.errors_by_step[10]:.10f}")
    print(f"    Error at n=20: {result.errors_by_step[20]:.14f}")
    
    # Mixing time
    mt = estimate_mixing_time(T, 0.01)
    print(f"\n  Mixing time (ε=0.01): {mt} steps")
