#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Berggren-Seeded Pseudorandom Generation

Implements the algorithms underlying the Nisan-Wigderson generator with
Berggren seed, including:
- Berggren walk evaluation (mod q)
- Transition matrix construction and spectral analysis
- PRG output generation
- Polynomial test evaluation
"""

import numpy as np
from typing import List, Tuple, Dict, Optional
from dataclasses import dataclass


# ─── Berggren Generator Matrices ─────────────────────────────────────────────

B1 = np.array([[ 1, -2,  2],
               [ 2, -1,  2],
               [ 2, -2,  3]], dtype=np.int64)

B2 = np.array([[ 1,  2,  2],
               [ 2,  1,  2],
               [ 2,  2,  3]], dtype=np.int64)

B3 = np.array([[-1,  2,  2],
               [-2,  1,  2],
               [-2,  2,  3]], dtype=np.int64)

GENERATORS = [B1, B2, B3]
ROOT = np.array([3, 4, 5], dtype=np.int64)


@dataclass
class SpectralAnalysis:
    """Result of spectral analysis of the Berggren transition matrix."""
    modulus: int
    num_states: int
    eigenvalues: np.ndarray
    spectral_gap: float
    second_eigenvalue: float
    transition_matrix: np.ndarray
    states: List[Tuple[int, ...]]


def berggren_eval_mod(word: List[int], q: int) -> Tuple[int, int, int]:
    """
    Evaluate a Berggren word on root (3,4,5) modulo q.

    Args:
        word: List of generator indices (0, 1, or 2)
        q: Modulus

    Returns:
        Triple (a mod q, b mod q, c mod q)

    Complexity: O(len(word) * log(q)) arithmetic operations in Z/qZ
    """
    triple = ROOT.copy()
    for idx in word:
        triple = GENERATORS[idx] @ triple
        triple = triple % q  # Reduce modulo q at each step for efficiency
    return tuple(int(x) % q for x in triple)


def berggren_matrix_mod(word: List[int], q: int) -> np.ndarray:
    """
    Compute the product matrix for a Berggren word modulo q.

    Args:
        word: List of generator indices
        q: Modulus

    Returns:
        3x3 matrix (product of generators) mod q
    """
    result = np.eye(3, dtype=np.int64)
    for idx in word:
        result = (GENERATORS[idx] @ result) % q
    return result


def enumerate_berggren_states(q: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all reachable states of the Berggren walk modulo q.

    Uses BFS from the root triple (3, 4, 5) mod q.

    Args:
        q: Modulus

    Returns:
        Sorted list of reachable states (a, b, c) mod q

    Complexity: O(|S_q| * 3) where |S_q| is the number of reachable states
    """
    states = set()
    frontier = [tuple(int(x) % q for x in ROOT)]

    while frontier:
        new_frontier = []
        for state in frontier:
            if state in states:
                continue
            states.add(state)
            for gen in GENERATORS:
                triple = np.array(state, dtype=np.int64)
                new_triple = gen @ triple
                new_state = tuple(int(x) % q for x in new_triple)
                if new_state not in states:
                    new_frontier.append(new_state)
        frontier = new_frontier

    return sorted(states)


def build_transition_matrix(q: int) -> SpectralAnalysis:
    """
    Build and analyze the Berggren transition matrix modulo q.

    The transition matrix T is defined by:
        T[j, i] = (1/3) * #{generators g : g(state_i) = state_j}

    This is the Markov operator for the uniform random walk on Berggren
    generators, restricted to the congruence quotient mod q.

    Args:
        q: Modulus

    Returns:
        SpectralAnalysis containing eigenvalues, spectral gap, etc.

    Complexity: O(|S_q|^2) for matrix construction, O(|S_q|^3) for eigendecomposition
    """
    states = enumerate_berggren_states(q)
    state_idx = {s: i for i, s in enumerate(states)}
    n = len(states)

    T = np.zeros((n, n))
    for s in states:
        for gen in GENERATORS:
            triple = np.array(s, dtype=np.int64)
            new_triple = gen @ triple
            new_state = tuple(int(x) % q for x in new_triple)
            j = state_idx[new_state]
            i = state_idx[s]
            T[j, i] += 1.0 / 3.0

    eigenvalues = np.sort(np.abs(np.linalg.eigvals(T)))[::-1]
    rho = eigenvalues[1] if n > 1 else 0.0

    return SpectralAnalysis(
        modulus=q,
        num_states=n,
        eigenvalues=eigenvalues,
        spectral_gap=1.0 - rho,
        second_eigenvalue=rho,
        transition_matrix=T,
        states=states
    )


def berggren_prg(seed_length: int, q: int, m: int = 2,
                 seed: Optional[int] = None) -> np.ndarray:
    """
    Berggren Pseudorandom Generator.

    Generates m output coordinates in Z/qZ from a seed of given length.
    The seed encodes a word in {0,1,2}^seed_length, which determines a
    Berggren walk. The output is the first m coordinates of the resulting
    triple modulo q.

    Args:
        seed_length: Length of the Berggren word (= walk length ℓ)
        q: Output modulus
        m: Number of output coordinates (1, 2, or 3)
        seed: Optional integer seed encoding the word

    Returns:
        Array of m elements in {0, ..., q-1}

    Complexity: O(seed_length) matrix-vector multiplications in Z/qZ
    """
    if seed is not None:
        # Decode seed to word
        word = []
        s = seed
        for _ in range(seed_length):
            word.append(s % 3)
            s //= 3
    else:
        word = list(np.random.randint(0, 3, size=seed_length))

    result = berggren_eval_mod(word, q)
    return np.array(result[:m])


def evaluate_polynomial_test(coeffs: Dict[Tuple[int, ...], int],
                             point: Tuple[int, ...], q: int) -> int:
    """
    Evaluate a multivariate polynomial over Z/qZ.

    Args:
        coeffs: Dictionary mapping exponent tuples to coefficients
        point: Point at which to evaluate
        q: Modulus

    Returns:
        P(point) mod q
    """
    result = 0
    for exponents, coeff in coeffs.items():
        term = coeff
        for i, exp in enumerate(exponents):
            if i < len(point):
                term = (term * pow(int(point[i]), int(exp), q)) % q
        result = (result + term) % q
    return result


def compute_fooling_error(seed_length: int, q: int, poly_coeffs: dict,
                          num_samples: int = 10000) -> float:
    """
    Empirically compute the fooling error of the Berggren PRG against
    a polynomial test.

    Args:
        seed_length: Walk length ℓ
        q: Modulus
        poly_coeffs: Polynomial coefficients
        num_samples: Number of random walks to sample

    Returns:
        Maximum absolute bias |Pr[P(G_ℓ) = v] - Pr[P(U) = v]| over v ∈ Z/qZ
    """
    from collections import Counter

    # Walk distribution
    walk_counts = Counter()
    rng = np.random.default_rng(42)
    for _ in range(num_samples):
        word = list(rng.integers(0, 3, size=seed_length))
        output = berggren_eval_mod(word, q)
        val = evaluate_polynomial_test(poly_coeffs, output[:2], q)
        walk_counts[val] += 1

    # Uniform distribution
    uniform_counts = Counter()
    for a in range(q):
        for b in range(q):
            val = evaluate_polynomial_test(poly_coeffs, (a, b), q)
            uniform_counts[val] += 1

    max_bias = 0.0
    for v in range(q):
        walk_prob = walk_counts.get(v, 0) / num_samples
        unif_prob = uniform_counts.get(v, 0) / (q * q)
        bias = abs(walk_prob - unif_prob)
        max_bias = max(max_bias, bias)

    return max_bias


def mixing_time_estimate(q: int, epsilon: float = 0.01) -> int:
    """
    Estimate the mixing time of the Berggren walk mod q.

    The mixing time t_mix(ε) is the smallest ℓ such that
    TV(μ_ℓ, uniform) ≤ ε.

    From the spectral gap theorem: t_mix(ε) ≈ log(|S_q|/ε) / log(1/ρ).

    Args:
        q: Modulus
        epsilon: Target TV distance

    Returns:
        Estimated mixing time
    """
    analysis = build_transition_matrix(q)
    rho = analysis.second_eigenvalue
    if rho >= 1.0 - 1e-10:
        return -1  # No spectral gap detected

    n = analysis.num_states
    # t_mix ≈ log(sqrt(n) / epsilon) / log(1/rho)
    t_mix = int(np.ceil(np.log(np.sqrt(n) / epsilon) / np.log(1.0 / rho)))
    return t_mix


if __name__ == "__main__":
    print("Berggren PRG Algorithms — Quick Test")
    print("=" * 50)

    # Test basic evaluation
    word = [0, 1, 2, 0, 1]
    q = 7
    result = berggren_eval_mod(word, q)
    print(f"Berggren word {word} mod {q} → {result}")

    # Spectral analysis
    for q in [5, 7, 11]:
        analysis = build_transition_matrix(q)
        t_mix = mixing_time_estimate(q)
        print(f"\nq={q}: {analysis.num_states} states, "
              f"ρ={analysis.second_eigenvalue:.4f}, "
              f"gap={analysis.spectral_gap:.4f}, "
              f"t_mix(0.01)={t_mix}")

    # PRG output
    print(f"\nPRG outputs (seed_length=10, q=7):")
    for seed in range(5):
        output = berggren_prg(10, 7, m=2, seed=seed)
        print(f"  seed={seed}: output={output}")
