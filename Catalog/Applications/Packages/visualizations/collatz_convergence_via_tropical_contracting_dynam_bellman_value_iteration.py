#!/usr/bin/env python3
"""
Algorithms for Tropical Contraction Theory of Collatz Dynamics.

Implements the core algorithms from the research paper:
1. Bellman Value Iteration (Algorithm 1)
2. Lipschitz Constant Estimation (Algorithm 2)
3. Tropical Spectral Radius Estimation
4. Collatz Orbit Analysis in Log-Coordinates
"""

import numpy as np
from typing import Callable, Optional, Tuple, List


def bellman_value_iteration(
    gamma: float,
    a: float,
    b: float,
    N: int,
    epsilon: float = 1e-12,
    max_iter: int = 10000,
    f0: Optional[np.ndarray] = None,
) -> Tuple[np.ndarray, List[float], int]:
    """
    Compute the fixed point of the discounted Collatz Bellman operator
    by Picard (value) iteration.

    The operator is: (Bf)(n) = γ · min(f(n//2) + a, f((3n+1)//2) + b)

    Parameters
    ----------
    gamma : float
        Discount factor, must be in [0, 1).
    a : float
        Cost of the even branch.
    b : float
        Cost of the odd branch.
    N : int
        Domain size [0, N).
    epsilon : float
        Convergence tolerance in sup-norm.
    max_iter : int
        Maximum number of iterations.
    f0 : np.ndarray, optional
        Initial function. Defaults to zero.

    Returns
    -------
    f : np.ndarray
        Approximate fixed point.
    diffs : list of float
        Sup-norm differences between successive iterates.
    iterations : int
        Number of iterations performed.

    Complexity
    ----------
    Time: O(N · log(1/ε) / log(1/γ))
    Space: O(N)
    """
    if not (0 <= gamma < 1):
        raise ValueError(f"gamma must be in [0, 1), got {gamma}")

    f = np.zeros(N) if f0 is None else f0.copy()
    diffs = []

    for k in range(max_iter):
        f_new = np.empty(N)
        for n in range(N):
            even_val = f[n // 2] + a
            odd_idx = min((3 * n + 1) // 2, N - 1)
            odd_val = f[odd_idx] + b
            f_new[n] = gamma * min(even_val, odd_val)

        diff = np.max(np.abs(f_new - f))
        diffs.append(diff)
        f = f_new

        if diff < epsilon:
            break

    return f, diffs, len(diffs)


def estimate_lipschitz_constant(
    gamma: float,
    a: float,
    b: float,
    N: int,
    num_trials: int = 500,
    seed: int = 42,
) -> float:
    """
    Empirically estimate the Lipschitz constant of the Bellman operator.

    For each trial, generates random bounded functions f, g, applies the
    operator, and computes the ratio dist(Tf, Tg) / dist(f, g).

    The theorem guarantees this ratio is always ≤ γ.

    Parameters
    ----------
    gamma : float
        Discount factor.
    a, b : float
        Branch costs.
    N : int
        Domain size.
    num_trials : int
        Number of random trials.
    seed : int
        Random seed for reproducibility.

    Returns
    -------
    float
        Maximum observed Lipschitz ratio.
    """
    rng = np.random.RandomState(seed)
    max_ratio = 0.0

    for _ in range(num_trials):
        f = rng.randn(N) * 5
        g = rng.randn(N) * 5

        Tf = np.array([
            gamma * min(f[n // 2] + a, f[min((3*n+1)//2, N-1)] + b)
            for n in range(N)
        ])
        Tg = np.array([
            gamma * min(g[n // 2] + a, g[min((3*n+1)//2, N-1)] + b)
            for n in range(N)
        ])

        dist_out = np.max(np.abs(Tf - Tg))
        dist_in = np.max(np.abs(f - g))

        if dist_in > 1e-10:
            max_ratio = max(max_ratio, dist_out / dist_in)

    return max_ratio


def collatz_orbit(n: int, max_steps: int = 10000) -> List[int]:
    """Compute the Collatz orbit of n until reaching 1 or max_steps."""
    orbit = [n]
    while n != 1 and len(orbit) < max_steps:
        n = n // 2 if n % 2 == 0 else 3 * n + 1
        orbit.append(n)
    return orbit


def log_orbit_analysis(n: int) -> dict:
    """
    Analyze a Collatz orbit in tropical (logarithmic) coordinates.

    Returns statistics about the orbit including step count,
    maximum log value, average drift, and branch sequence.
    """
    orbit = collatz_orbit(n)
    log_orbit = [np.log(x) for x in orbit]

    # Compute branch sequence (True = odd step, False = even step)
    branches = [orbit[i] % 2 == 1 for i in range(len(orbit) - 1)]
    even_count = branches.count(False)
    odd_count = branches.count(True)

    steps = len(orbit) - 1
    return {
        "n": n,
        "steps": steps,
        "max_log": max(log_orbit),
        "min_log": min(log_orbit),
        "avg_drift": (log_orbit[-1] - log_orbit[0]) / max(steps, 1),
        "even_fraction": even_count / max(steps, 1),
        "odd_fraction": odd_count / max(steps, 1),
        "orbit": orbit,
        "log_orbit": log_orbit,
    }


def tropical_branch_product(word: str) -> float:
    """
    Compute the total log-drift of a parity word.

    Parameters
    ----------
    word : str
        String of 'E' (even) and 'O' (odd) characters.

    Returns
    -------
    float
        Total drift: sum of -log(2) for E and +log(3/2) for O.
    """
    drift = 0.0
    for c in word:
        if c == 'E':
            drift -= np.log(2)
        elif c == 'O':
            drift += np.log(3) - np.log(2)
        else:
            raise ValueError(f"Unknown branch character: {c}")
    return drift


if __name__ == "__main__":
    print("=== Bellman Value Iteration ===")
    f_star, diffs, iters = bellman_value_iteration(0.9, 1.0, 1.5, 100)
    print(f"Converged in {iters} iterations")
    print(f"Fixed point values (first 10): {f_star[:10].round(4)}")
    print(f"Final diff: {diffs[-1]:.2e}")

    print("\n=== Lipschitz Constant Estimation ===")
    for g in [0.5, 0.9, 0.99]:
        lip = estimate_lipschitz_constant(g, 1.0, 1.5, 100)
        print(f"γ = {g:.2f}: estimated Lip. constant = {lip:.6f} (theoretical: {g:.6f})")

    print("\n=== Orbit Analysis ===")
    for n in [27, 97, 127]:
        info = log_orbit_analysis(n)
        print(f"n={n}: {info['steps']} steps, avg_drift={info['avg_drift']:.4f}, "
              f"even%={info['even_fraction']:.1%}")

    print("\n=== Tropical Branch Products ===")
    for word in ["EEO", "EEEO", "EEEEO", "EOE", "OEE"]:
        drift = tropical_branch_product(word)
        print(f"Word '{word}': drift = {drift:.4f} ({'contracting' if drift < 0 else 'expanding'})")
