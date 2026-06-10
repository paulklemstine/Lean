"""
Profile Recovery Theorem: Algorithms for Moment Method Convergence

This module implements the core algorithms underlying the Profile Recovery Theorem,
which reduces distributional convergence (e.g., proving the Wigner semicircle law)
to moment convergence plus a determinacy condition.

Type-hinted implementations of:
1. Catalan number computation
2. Moment distance pseudometric
3. Wigner semicircle moments
4. Carleman condition checker
5. Convergence cascade simulator
"""

from typing import Callable, List, Tuple, Optional
import math


def catalan_number(n: int) -> int:
    """Compute the n-th Catalan number C_n = C(2n, n) / (n+1).
    
    The Catalan numbers count the number of non-crossing pair partitions
    of {1, ..., 2n}, which is the k-th moment of the Wigner semicircle law
    for k = 2n.
    
    Args:
        n: Non-negative integer index.
    
    Returns:
        The n-th Catalan number.
    """
    if n < 0:
        raise ValueError("Catalan number undefined for negative n")
    return math.comb(2 * n, n) // (n + 1)


def wigner_moment(k: int) -> float:
    """Compute the k-th moment of the Wigner semicircle distribution.
    
    The semicircle distribution on [-2, 2] has density (1/2π)√(4 - x²).
    Its even moments are Catalan numbers: m_{2n} = C_n.
    Its odd moments are zero (by symmetry).
    
    Args:
        k: Non-negative integer moment order.
    
    Returns:
        The k-th moment as a float.
    """
    if k < 0:
        raise ValueError("Moment order must be non-negative")
    if k % 2 == 1:
        return 0.0
    return float(catalan_number(k // 2))


def moment_distance(m1: Callable[[int], float], m2: Callable[[int], float], K: int) -> float:
    """Compute the truncated moment distance between two moment sequences.
    
    d_K(μ, ν) = Σ_{k=0}^{K-1} |m1(k) - m2(k)| / k!
    
    This is a pseudometric on moment sequences truncated at level K,
    used to quantify convergence in the method of moments.
    
    Args:
        m1: First moment sequence (callable mapping ℕ → ℝ).
        m2: Second moment sequence (callable mapping ℕ → ℝ).
        K: Truncation level.
    
    Returns:
        The moment distance as a float.
    """
    return sum(abs(m1(k) - m2(k)) / math.factorial(k) for k in range(K))


def check_carleman_condition(moments: Callable[[int], float], N: int, threshold: float = 1e6) -> bool:
    """Check whether a moment sequence appears to satisfy the Carleman condition.
    
    The Carleman condition states that Σ_{n=1}^∞ m_{2n}^{-1/(2n)} = ∞.
    We approximate this by computing the partial sum up to N terms
    and checking if it exceeds a threshold.
    
    Args:
        moments: Moment sequence function.
        N: Number of terms to sum.
        threshold: Value above which we declare the condition "likely satisfied".
    
    Returns:
        True if the partial sum exceeds the threshold (suggesting Carleman holds).
    """
    partial_sum = 0.0
    for n in range(1, N + 1):
        m2n = moments(2 * n)
        if m2n <= 0:
            return True  # Zero/negative moment means the series diverges
        partial_sum += m2n ** (-1.0 / (2 * n))
    return partial_sum > threshold


def simulate_convergence_cascade(
    moment_sequences: List[Callable[[int], float]],
    limit_moments: Callable[[int], float],
    K: int,
) -> List[float]:
    """Simulate a convergence cascade: compute moment distances at each step.
    
    For a sequence of moment sequences μ_1, μ_2, ..., compute the moment
    distance d_K(μ_n, μ) for each n, demonstrating convergence.
    
    Args:
        moment_sequences: List of moment sequence functions.
        limit_moments: The limit moment sequence.
        K: Truncation level for moment distance.
    
    Returns:
        List of moment distances.
    """
    return [moment_distance(ms, limit_moments, K) for ms in moment_sequences]


def random_matrix_empirical_moments(eigenvalues: List[float], k: int) -> float:
    """Compute the k-th empirical moment of a set of eigenvalues.
    
    m_k = (1/n) Σ_{i=1}^n λ_i^k
    
    This is the discrete analogue of the k-th moment of the spectral measure.
    
    Args:
        eigenvalues: List of eigenvalues.
        k: Moment order.
    
    Returns:
        The k-th empirical moment.
    """
    n = len(eigenvalues)
    if n == 0:
        return 0.0
    return sum(ev ** k for ev in eigenvalues) / n


def catalan_four_pow_ratio(n: int) -> float:
    """Compute the ratio C_n / 4^n, testing the conjecture C_n ≤ 4^n.
    
    The asymptotic formula C_n ~ 4^n / (n^{3/2} √π) predicts this ratio
    should decay like 1/(n^{3/2} √π) → 0.
    
    Args:
        n: Catalan number index.
    
    Returns:
        The ratio C_n / 4^n.
    """
    if n < 0:
        raise ValueError("n must be non-negative")
    return catalan_number(n) / (4 ** n)


def moment_method_convergence_rate(
    moment_sequences: List[Callable[[int], float]],
    limit_moments: Callable[[int], float],
    K: int,
) -> List[Tuple[int, float, float]]:
    """Analyze the convergence rate of the moment method.
    
    For each sequence μ_n, compute:
    - n (the index)
    - d_K(μ_n, μ) (the moment distance)
    - n * d_K(μ_n, μ) (should be bounded if rate is O(1/n))
    
    Args:
        moment_sequences: List of moment sequence functions.
        limit_moments: The limit moment sequence.
        K: Truncation level.
    
    Returns:
        List of (n, distance, n*distance) tuples.
    """
    results = []
    for i, ms in enumerate(moment_sequences, 1):
        d = moment_distance(ms, limit_moments, K)
        results.append((i, d, i * d))
    return results


if __name__ == "__main__":
    # Quick test
    print("Catalan numbers:", [catalan_number(k) for k in range(10)])
    print("Wigner moments (0..8):", [wigner_moment(k) for k in range(9)])
    print("C_n / 4^n ratios:", [f"{catalan_four_pow_ratio(k):.6f}" for k in range(10)])
    print("Catalan ≤ 4^k?", all(catalan_number(k) <= 4**k for k in range(30)))
