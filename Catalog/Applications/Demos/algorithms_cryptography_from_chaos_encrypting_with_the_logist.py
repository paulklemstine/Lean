"""
Algorithms for Logistic Map Cryptography

Implements the core algorithms discussed in the research paper:
1. Logistic Map Iteration (with precision control)
2. Chebyshev Semiconjugacy Verification
3. Logistic Cipher (encrypt/decrypt)
4. Keystream Generation with Statistical Testing
5. Period Detection via Floyd's Algorithm
6. Polynomial Degree Computation

All algorithms include complexity analysis in docstrings.
"""

import math
from typing import Generator, Optional


def logistic_map(x: float, r: float = 4.0) -> float:
    """
    The logistic map f(x) = r*x*(1-x).

    Time: O(1)
    Space: O(1)

    Args:
        x: Current state in [0, 1]
        r: Parameter (default 4.0 for full chaos)

    Returns:
        Next state f(x)
    """
    return r * x * (1.0 - x)


def logistic_iterate(x0: float, n: int, r: float = 4.0) -> float:
    """
    Compute f^n(x0), the n-th iterate of the logistic map.

    Time: O(n)
    Space: O(1)

    Args:
        x0: Initial condition
        n: Number of iterations
        r: Parameter

    Returns:
        f^n(x0)
    """
    x = x0
    for _ in range(n):
        x = logistic_map(x, r)
    return x


def logistic_orbit(x0: float, n: int, r: float = 4.0) -> list:
    """
    Compute the full orbit [x0, f(x0), f²(x0), ..., f^n(x0)].

    Time: O(n)
    Space: O(n)

    Args:
        x0: Initial condition
        n: Number of iterations
        r: Parameter

    Returns:
        List of orbit points
    """
    orbit = [x0]
    x = x0
    for _ in range(n):
        x = logistic_map(x, r)
        orbit.append(x)
    return orbit


def keystream_generator(seed: float, warmup: int = 100,
                        r: float = 4.0) -> Generator[float, None, None]:
    """
    Generate an infinite keystream from the logistic map.

    After `warmup` transient iterations, yields successive iterates.

    Time per yield: O(1) amortized (O(warmup) for first yield)
    Space: O(1)

    Args:
        seed: Initial condition in (0, 1)
        warmup: Transient iterations to skip
        r: Parameter

    Yields:
        Keystream values in [0, 1]
    """
    x = seed
    for _ in range(warmup):
        x = logistic_map(x, r)
    while True:
        x = logistic_map(x, r)
        yield x


def logistic_encrypt(plaintext: list, seed: float,
                     warmup: int = 100) -> list:
    """
    Encrypt using the logistic cipher (additive stream cipher).

    Algorithm:
        1. Generate keystream K from seed with warmup iterations
        2. Ciphertext C_i = (M_i + K_i) mod 1

    Time: O(warmup + len(plaintext))
    Space: O(len(plaintext))

    Args:
        plaintext: List of floats in [0, 1]
        seed: Cipher key (initial condition)
        warmup: Transient skip

    Returns:
        Ciphertext as list of floats
    """
    ks = keystream_generator(seed, warmup)
    return [(m + next(ks)) % 1.0 for m in plaintext]


def logistic_decrypt(ciphertext: list, seed: float,
                     warmup: int = 100) -> list:
    """
    Decrypt using the logistic cipher.

    Algorithm:
        1. Generate same keystream K from seed
        2. Plaintext M_i = (C_i - K_i) mod 1

    Time: O(warmup + len(ciphertext))
    Space: O(len(ciphertext))
    """
    ks = keystream_generator(seed, warmup)
    return [(c - next(ks)) % 1.0 for c in ciphertext]


def lyapunov_exponent(x0: float, n: int, r: float = 4.0) -> float:
    """
    Estimate the Lyapunov exponent of the logistic map.

    λ = lim (1/n) Σ log|f'(x_k)| where f'(x) = r(1 - 2x)

    For r=4, the theoretical value is log(2) ≈ 0.693.

    Time: O(n)
    Space: O(1)

    Args:
        x0: Initial condition
        n: Number of iterations for averaging
        r: Parameter

    Returns:
        Estimated Lyapunov exponent
    """
    x = x0
    total = 0.0
    for _ in range(n):
        deriv = abs(r * (1.0 - 2.0 * x))
        if deriv > 0:
            total += math.log(deriv)
        x = logistic_map(x, r)
    return total / n


def floyd_period_detection(x0: float, r: float = 4.0,
                           tolerance: float = 1e-12,
                           max_iter: int = 10**7) -> Optional[int]:
    """
    Detect period of the logistic map orbit using Floyd's algorithm.

    Time: O(period)
    Space: O(1)

    Args:
        x0: Initial condition
        r: Parameter
        tolerance: Floating-point comparison tolerance
        max_iter: Maximum iterations before giving up

    Returns:
        Period length, or None if not found
    """
    # Phase 1: Find a meeting point
    tortoise = logistic_map(x0, r)
    hare = logistic_map(logistic_map(x0, r), r)
    steps = 0
    while abs(tortoise - hare) > tolerance and steps < max_iter:
        tortoise = logistic_map(tortoise, r)
        hare = logistic_map(logistic_map(hare, r), r)
        steps += 1

    if steps >= max_iter:
        return None

    # Phase 2: Find the period
    period = 1
    hare = logistic_map(tortoise, r)
    while abs(tortoise - hare) > tolerance and period < max_iter:
        hare = logistic_map(hare, r)
        period += 1

    return period if period < max_iter else None


def chebyshev_verify(theta: float, n: int) -> dict:
    """
    Verify the Chebyshev semiconjugacy: f^n(sin²θ) = sin²(2^n θ).

    Time: O(n)
    Space: O(1)

    Returns:
        Dict with left_side, right_side, absolute_error, relative_error
    """
    x0 = math.sin(theta) ** 2
    left = logistic_iterate(x0, n)
    right = math.sin((2**n) * theta) ** 2
    abs_err = abs(left - right)
    rel_err = abs_err / max(abs(right), 1e-300)
    return {
        "left_side": left,
        "right_side": right,
        "absolute_error": abs_err,
        "relative_error": rel_err,
    }


def statistical_frequency_test(seed: float, n: int = 10000,
                                warmup: int = 100) -> dict:
    """
    Run a simple frequency test on the logistic map keystream.

    Divides [0,1] into bins and checks uniformity under the
    arcsine (invariant) measure.

    Time: O(n)
    Space: O(n_bins)

    Returns:
        Dict with bin_counts, chi_squared, p_value_approx
    """
    n_bins = 10
    counts = [0] * n_bins
    ks = keystream_generator(seed, warmup)

    for _ in range(n):
        val = next(ks)
        bin_idx = min(int(val * n_bins), n_bins - 1)
        counts[bin_idx] += 1

    # Expected under arcsine distribution: P([a,b]) = (2/π)(arcsin(√b) - arcsin(√a))
    expected = []
    for i in range(n_bins):
        a, b = i / n_bins, (i + 1) / n_bins
        prob = (2 / math.pi) * (math.asin(math.sqrt(b)) - math.asin(math.sqrt(a)))
        expected.append(n * prob)

    chi_sq = sum((o - e)**2 / e for o, e in zip(counts, expected))

    return {
        "bin_counts": counts,
        "expected_counts": [round(e, 1) for e in expected],
        "chi_squared": chi_sq,
        "degrees_of_freedom": n_bins - 1,
        "passes_at_5pct": chi_sq < 16.919,  # χ²(9, 0.05) = 16.919
    }


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Lyapunov exponent
    lam = lyapunov_exponent(0.3, 100000)
    print(f"Lyapunov exponent estimate: {lam:.6f}")
    print(f"Theoretical value (log 2):  {math.log(2):.6f}")
    print(f"Relative error:             {abs(lam - math.log(2)) / math.log(2):.2e}")

    # Semiconjugacy
    print(f"\nChebyshev semiconjugacy at θ=0.3:")
    for n in [1, 5, 10, 20]:
        result = chebyshev_verify(0.3, n)
        print(f"  n={n:2d}: error = {result['absolute_error']:.2e}")

    # Statistical test
    print(f"\nStatistical frequency test:")
    stats = statistical_frequency_test(0.3, 100000)
    print(f"  χ² = {stats['chi_squared']:.2f} (df={stats['degrees_of_freedom']})")
    print(f"  Passes at 5%: {stats['passes_at_5pct']}")

    # Encryption
    print(f"\nEncryption round-trip:")
    msg = [0.1, 0.2, 0.3, 0.4, 0.5]
    key = 0.7654321
    enc = logistic_encrypt(msg, key)
    dec = logistic_decrypt(enc, key)
    print(f"  Original:  {msg}")
    print(f"  Decrypted: {[round(d, 10) for d in dec]}")
    print(f"  Max error: {max(abs(m-d) for m, d in zip(msg, dec)):.2e}")
