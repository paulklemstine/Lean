#!/usr/bin/env python3
"""
Algorithms for Tropical Cryptographic Constructions

Implements the core algorithms underlying the tropical OWF-to-PRG
reduction, including tropical orbit PRGs, hybrid distributions,
and negligible function analysis.
"""

from typing import List, Tuple, Callable, Optional
import numpy as np


# ============================================================
# Tropical Arithmetic
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (classical)."""
    return a + b

def trop_pow(base: float, exp: int) -> float:
    """Tropical exponentiation: base * exp (classical).

    In the tropical semiring, x^n = n * x because multiplication
    is classical addition.

    Args:
        base: The base element in the tropical semiring.
        exp: The exponent (non-negative integer).

    Returns:
        base * exp (classical multiplication).

    Time complexity: O(1)
    Space complexity: O(1)
    """
    return base * exp


def trop_matrix_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (min-plus).

    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})

    Args:
        A: First matrix (n × m), entries in ℝ ∪ {+∞}.
        B: Second matrix (m × p), entries in ℝ ∪ {+∞}.

    Returns:
        Product matrix (n × p) under min-plus.

    Time complexity: O(n * m * p)
    Space complexity: O(n * p)
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def trop_matrix_pow(A: np.ndarray, exp: int) -> np.ndarray:
    """Tropical matrix exponentiation by repeated squaring.

    Args:
        A: Square matrix (n × n).
        exp: Non-negative integer exponent.

    Returns:
        A^exp under tropical (min-plus) multiplication.

    Time complexity: O(n³ log exp)
    Space complexity: O(n²)
    """
    n = A.shape[0]
    if exp == 0:
        # Tropical identity: 0 on diagonal, +∞ elsewhere
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result

    result = A.copy()
    exp -= 1
    base = A.copy()
    while exp > 0:
        if exp % 2 == 1:
            result = trop_matrix_mul(result, base)
        base = trop_matrix_mul(base, base)
        exp //= 2
    return result


# ============================================================
# Tropical Hash Functions
# ============================================================

def tropical_hash(x: float, modulus: int = 100) -> int:
    """Simple tropical hash: reduce mod modulus.

    This models the dimension-reducing compression step in the
    orbit-hash PRG. The non-injectivity of modular reduction
    is what provides one-wayness.

    Args:
        x: Input value.
        modulus: Hash output range [0, modulus).

    Returns:
        Hash value in [0, modulus).

    Time complexity: O(1)
    """
    return int(x) % modulus


def tropical_matrix_hash(M: np.ndarray, bits: int = 8) -> List[int]:
    """Hash a tropical matrix to a bit string.

    Applies tropical hashing to each entry and concatenates.

    Args:
        M: Input matrix.
        bits: Number of bits per entry.

    Returns:
        List of hash values.

    Time complexity: O(n²)
    """
    modulus = 2 ** bits
    return [int(x) % modulus for x in M.flatten() if x < np.inf]


# ============================================================
# Tropical Orbit PRG
# ============================================================

def orbit_prg(seed: float, T: int, hash_mod: int = 256) -> List[int]:
    """Tropical orbit pseudorandom generator.

    Generates pseudorandom output by:
    1. Starting with a seed value.
    2. Iterating tropical powering T times.
    3. Hashing each orbit point.

    The security relies on the one-wayness of tropical powering
    (difficulty of recovering the seed from the hashed orbit).

    Args:
        seed: Initial seed value.
        T: Number of orbit iterations.
        hash_mod: Hash output range.

    Returns:
        List of T+1 pseudorandom values.

    Time complexity: O(T)
    Space complexity: O(T)

    Example:
        >>> orbit_prg(42, 5, 256)
        [42, 84, 168, 80, 160, 64]
    """
    output = [tropical_hash(seed, hash_mod)]
    current = seed
    for _ in range(T):
        current = trop_pow(current, 2)  # Tropical squaring
        output.append(tropical_hash(current, hash_mod))
    return output


def matrix_orbit_prg(seed_matrix: np.ndarray, T: int,
                      hash_bits: int = 8) -> List[List[int]]:
    """Matrix-based tropical orbit PRG.

    Uses tropical matrix powering for stronger one-wayness.

    Args:
        seed_matrix: Initial matrix seed.
        T: Number of orbit iterations.
        hash_bits: Bits per hash output.

    Returns:
        List of T+1 hashed matrix states.

    Time complexity: O(T * n³)
    Space complexity: O(T * n²)
    """
    output = [tropical_matrix_hash(seed_matrix, hash_bits)]
    current = seed_matrix.copy()
    for _ in range(T):
        current = trop_matrix_mul(current, current)  # Tropical squaring
        output.append(tropical_matrix_hash(current, hash_bits))
    return output


# ============================================================
# Hybrid Distributions
# ============================================================

def hybrid_distribution(real_output: List[int],
                         uniform_output: List[int],
                         hybrid_index: int) -> List[int]:
    """Construct hybrid distribution.

    Hybrid i replaces the first i components of the real PRG output
    with uniform random values, keeping the rest from the PRG.

    Args:
        real_output: Output from the PRG.
        uniform_output: Uniform random values of same length.
        hybrid_index: Number of components to replace (0 = all real).

    Returns:
        Hybrid distribution sample.

    Time complexity: O(len(real_output))
    """
    n = len(real_output)
    result = list(uniform_output[:hybrid_index]) + list(real_output[hybrid_index:])
    return result[:n]


def compute_hybrid_advantage(distinguisher: Callable[[List[int]], bool],
                              prg_outputs: List[List[int]],
                              uniform_outputs: List[List[int]],
                              hybrid_i: int,
                              hybrid_j: int) -> float:
    """Compute distinguisher advantage between two hybrids.

    Args:
        distinguisher: Boolean test function.
        prg_outputs: Multiple PRG output samples.
        uniform_outputs: Multiple uniform output samples.
        hybrid_i: First hybrid index.
        hybrid_j: Second hybrid index.

    Returns:
        Estimated advantage |Pr[D(H_i)=1] - Pr[D(H_j)=1]|.

    Time complexity: O(num_samples * output_length)
    """
    num_samples = len(prg_outputs)

    accept_i = sum(1 for s in range(num_samples)
                   if distinguisher(hybrid_distribution(
                       prg_outputs[s], uniform_outputs[s], hybrid_i)))

    accept_j = sum(1 for s in range(num_samples)
                   if distinguisher(hybrid_distribution(
                       prg_outputs[s], uniform_outputs[s], hybrid_j)))

    return abs(accept_i - accept_j) / num_samples


def verify_telescoping_bound(advantages: List[float]) -> Tuple[float, float, bool]:
    """Verify the telescoping hybrid bound.

    Checks that |total_advantage| ≤ Σ |step_advantages|.

    Args:
        advantages: List of per-step advantages.

    Returns:
        Tuple of (total, sum_of_steps, bound_holds).
    """
    total = sum(advantages)
    sum_steps = sum(abs(a) for a in advantages)
    return total, sum_steps, abs(total) <= sum_steps + 1e-10


# ============================================================
# Negligible Function Analysis
# ============================================================

def check_negligible(f: Callable[[int], float],
                      max_k: int = 5,
                      n_range: Tuple[int, int] = (10, 200)) -> dict:
    """Check if a function appears negligible.

    Tests whether |f(n)| ≤ 1/n^k for various k and large n.

    Args:
        f: Function ℕ → ℝ to test.
        max_k: Maximum polynomial degree to check.
        n_range: Range of n values to test.

    Returns:
        Dictionary mapping k to (passes, first_failure_n).

    Time complexity: O(max_k * (n_range[1] - n_range[0]))
    """
    results = {}
    for k in range(1, max_k + 1):
        passes = True
        first_fail = None
        for n in range(n_range[0], n_range[1] + 1):
            bound = 1.0 / (n ** k) if n > 0 else float('inf')
            if abs(f(n)) > bound:
                passes = False
                first_fail = n
                break
        results[k] = {'passes': passes, 'first_failure': first_fail}
    return results


def negligible_sum(functions: List[Callable[[int], float]]) -> Callable[[int], float]:
    """Sum of functions (demonstrating negligible closure).

    If each f_i is negligible, then Σ f_i is negligible.

    Args:
        functions: List of functions ℕ → ℝ.

    Returns:
        Their pointwise sum.
    """
    def summed(n: int) -> float:
        return sum(f(n) for f in functions)
    return summed


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Orbit PRG Output:")
    output = orbit_prg(42, 8, 256)
    print(f"  seed=42, T=8: {output}")
    print()

    print("Matrix Orbit PRG:")
    seed = np.array([[1, 3], [2, 4]], dtype=float)
    mat_output = matrix_orbit_prg(seed, 3, 4)
    print(f"  T=3: {mat_output}")
    print()

    print("Negligibility Check:")
    exp_decay = lambda n: 1.0 / (2 ** n)
    result = check_negligible(exp_decay)
    for k, v in result.items():
        print(f"  k={k}: passes={v['passes']}")
    print()

    print("Telescoping Bound Verification:")
    steps = [0.01, -0.005, 0.008, -0.003, 0.007]
    total, sum_steps, holds = verify_telescoping_bound(steps)
    print(f"  Total: {total:.4f}, Sum of |steps|: {sum_steps:.4f}, Bound holds: {holds}")
