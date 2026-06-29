#!/usr/bin/env python3
"""
Algorithms for Expander Walk Derandomization

Implements the core algorithmic components:
1. Expander walk pseudorandom generator
2. Derandomized error amplification
3. Seed length optimizer
"""

import numpy as np
from typing import Callable, Optional, Tuple, List


def build_lazy_cayley_walk(n: int, generators: List[int], laziness: float = 0.5) -> np.ndarray:
    """
    Build a lazy random walk matrix on Z/nZ with given generators.

    Args:
        n: Size of the cyclic group Z/nZ.
        generators: List of generators (edges connect i to i±g for each g).
        laziness: Probability of staying at the current vertex.

    Returns:
        P: n×n stochastic matrix (symmetric, doubly stochastic).

    Complexity: O(n · |generators|) time, O(n²) space.
    """
    P = np.zeros((n, n))
    move_prob = (1 - laziness) / (2 * len(generators))
    for i in range(n):
        P[i, i] = laziness
        for g in generators:
            P[i, (i + g) % n] += move_prob
            P[i, (i - g) % n] += move_prob
    return P


def spectral_gap(P: np.ndarray) -> Tuple[float, float]:
    """
    Compute the spectral gap and second eigenvalue of a stochastic matrix.

    Args:
        P: n×n symmetric stochastic matrix.

    Returns:
        (gap, lambda_2): Spectral gap δ and second largest eigenvalue magnitude λ.

    Complexity: O(n³) via eigendecomposition.
    """
    eigs = np.sort(np.linalg.eigvalsh(P))[::-1]
    lambda_2 = max(abs(eigs[1]), abs(eigs[-1]))
    gap = 1 - lambda_2
    return gap, lambda_2


def l2_norm(f: np.ndarray) -> float:
    """Compute L² norm: √(∑ f(x)²)."""
    return np.sqrt(np.sum(f**2))


def walk_apply(P: np.ndarray, f: np.ndarray, t: int) -> np.ndarray:
    """
    Apply the walk operator P^t to function f.

    Args:
        P: n×n stochastic matrix.
        f: Function values (n-vector).
        t: Number of walk steps.

    Returns:
        P^t f (n-vector).

    Complexity: O(t · n²) via repeated matrix-vector multiplication,
                or O(n³ + n² log t) via matrix power.
    """
    result = f.copy()
    for _ in range(t):
        result = P @ result
    return result


def correlation(f: np.ndarray, g: np.ndarray, P: np.ndarray, t: int) -> float:
    """
    Compute the correlation ⟨f, P^t g⟩ = ∑_x f(x) · (P^t g)(x).

    This is the quantity bounded by Theorem B.

    Args:
        f, g: Mean-zero observables (n-vectors).
        P: n×n stochastic matrix.
        t: Walk length.

    Returns:
        The correlation value (scalar).
    """
    Pt_g = walk_apply(P, g, t)
    return np.sum(f * Pt_g)


def mixing_time(P: np.ndarray, epsilon: float = 0.01) -> int:
    """
    Compute the mixing time: smallest t such that λ^t < ε.

    Uses the spectral gap to give an explicit bound:
        t_mix = ⌈log(1/ε) / log(1/λ)⌉

    Args:
        P: n×n symmetric stochastic matrix.
        epsilon: Target error level.

    Returns:
        Mixing time t_mix.

    This is the formalized version of pow_lt_of_lt_one_of_pos.
    """
    gap, lam = spectral_gap(P)
    if lam <= 0:
        return 0
    if lam >= 1:
        return float('inf')
    t = int(np.ceil(np.log(1 / epsilon) / np.log(1 / lam)))
    return t


def seed_length(n: int, base: int = 3) -> int:
    """
    Compute the seed length needed to represent a state space of size base^n.

    By Theorem C: base^n ≤ 2^(2n) when base ≤ 4, so 2n bits suffice.

    Args:
        n: Exponent.
        base: Base of the state space size.

    Returns:
        Number of bits needed (at most 2n).
    """
    if base <= 4:
        return 2 * n  # Guaranteed by our theorem
    else:
        return int(np.ceil(n * np.log2(base)))


def expander_walk_prg(
    P: np.ndarray,
    seed: int,
    walk_length: int
) -> List[int]:
    """
    Expander Walk Pseudorandom Generator.

    Given a seed (initial vertex), generate a sequence of vertices
    by walking on the expander graph defined by P.

    Args:
        P: n×n stochastic matrix of an expander.
        seed: Initial vertex (0 ≤ seed < n).
        walk_length: Number of steps t.

    Returns:
        List of (t+1) vertices visited during the walk.

    Seed length: ⌈log₂ n⌉ bits for the initial vertex.
    Total randomness: ⌈log₂ n⌉ + t · ⌈log₂ d⌉ bits,
                      where d is the degree.

    Complexity: O(t · n) per walk step (or O(t · d) with sparse representation).
    """
    n = P.shape[0]
    vertices = [seed % n]
    current = seed % n

    for _ in range(walk_length):
        # Sample next vertex according to P[current, :]
        probs = P[current]
        next_vertex = np.random.choice(n, p=probs)
        vertices.append(next_vertex)
        current = next_vertex

    return vertices


def derandomized_amplification(
    P: np.ndarray,
    test_fn: Callable[[int], bool],
    num_walks: int = 100,
    walk_length: int = 10
) -> float:
    """
    Derandomized error amplification using expander walks.

    Instead of using independent random samples (which requires
    O(t · log n) random bits), use an expander walk (which requires
    only O(log n + t · log d) bits).

    For a BPP algorithm with error ≤ 1/3:
    - Independent repetition: t trials, O(t · log n) bits, error ≤ (1/3)^t
    - Expander walk: t steps, O(log n + t) bits, error ≤ (1/3 + λ)^t

    Args:
        P: Expander walk matrix.
        test_fn: Function mapping vertex → {True, False}.
        num_walks: Number of independent walks to average.
        walk_length: Length of each walk.

    Returns:
        Fraction of walk samples that pass the test.
    """
    n = P.shape[0]
    total_pass = 0
    total_samples = 0

    for _ in range(num_walks):
        seed = np.random.randint(n)
        walk = expander_walk_prg(P, seed, walk_length)
        for v in walk:
            if test_fn(v):
                total_pass += 1
            total_samples += 1

    return total_pass / total_samples


def optimal_walk_parameters(
    n: int,
    target_error: float,
    spectral_gap_val: float
) -> dict:
    """
    Compute optimal walk parameters for derandomization.

    Given:
        - State space size ~ 3^n
        - Target error ε
        - Spectral gap δ

    Returns optimal:
        - Walk length t
        - Total seed bits
        - Comparison with independent sampling

    Args:
        n: Parameter (state space ~ 3^n).
        target_error: Desired error level ε.
        spectral_gap_val: Spectral gap δ of the expander.

    Returns:
        Dictionary with computed parameters.
    """
    lam = 1 - spectral_gap_val

    # Walk length for target error
    if lam > 0 and lam < 1:
        t = int(np.ceil(np.log(1 / target_error) / np.log(1 / lam)))
    else:
        t = 1

    # Seed bits
    initial_bits = 2 * n  # By Theorem C
    step_bits = 1  # For a constant-degree graph
    total_bits = initial_bits + t * step_bits

    # Independent sampling would need
    independent_bits = t * (2 * n)

    return {
        "walk_length": t,
        "contraction_rate": lam,
        "initial_seed_bits": initial_bits,
        "bits_per_step": step_bits,
        "total_seed_bits": total_bits,
        "independent_sampling_bits": independent_bits,
        "randomness_savings_factor": independent_bits / total_bits if total_bits > 0 else float('inf'),
        "achieved_error": lam**t,
        "target_error": target_error,
    }


if __name__ == "__main__":
    print("=" * 60)
    print("Expander Walk Algorithms — Examples")
    print("=" * 60)

    # Build an expander
    n = 50
    P = build_lazy_cayley_walk(n, [1, 7, 13], laziness=0.25)
    gap, lam = spectral_gap(P)
    print(f"\nExpander on Z/{n}Z with generators {{1, 7, 13}}:")
    print(f"  Spectral gap: δ = {gap:.6f}")
    print(f"  Second eigenvalue: λ = {lam:.6f}")

    # Mixing time
    t_mix = mixing_time(P, epsilon=0.01)
    print(f"  Mixing time (ε=0.01): t = {t_mix}")

    # Seed length
    print(f"\n  Seed length for 3^10 states: {seed_length(10)} bits")
    print(f"  Seed length for 3^20 states: {seed_length(20)} bits")
    print(f"  Seed length for 3^100 states: {seed_length(100)} bits")

    # Optimal parameters
    print("\n--- Optimal Walk Parameters ---")
    for target_n in [10, 50, 100]:
        params = optimal_walk_parameters(target_n, 0.01, gap)
        print(f"\n  n = {target_n}, target error = 0.01:")
        print(f"    Walk length: {params['walk_length']}")
        print(f"    Total seed bits: {params['total_seed_bits']}")
        print(f"    Independent sampling bits: {params['independent_sampling_bits']}")
        print(f"    Randomness savings: {params['randomness_savings_factor']:.1f}x")
        print(f"    Achieved error: {params['achieved_error']:.2e}")

    # Derandomized test
    print("\n--- Derandomized Amplification Demo ---")
    # Test function: accept if vertex is in the first third
    accept_fn = lambda v: v < n // 3
    result = derandomized_amplification(P, accept_fn, num_walks=1000, walk_length=20)
    print(f"  Acceptance rate (should be ~{n//3}/{n} = {n//3/n:.3f}): {result:.3f}")
