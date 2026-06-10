"""
Logistic Map Cipher — Core Algorithms

Type-hinted implementations of the logistic cipher and its analysis tools.
"""

from typing import List, Tuple
import struct


def logistic_map(x: float, r: float = 4.0) -> float:
    """The logistic map f(x) = r * x * (1 - x)."""
    return r * x * (1.0 - x)


def logistic_orbit(x0: float, n: int, r: float = 4.0) -> List[float]:
    """Generate n iterates of the logistic map starting from x0."""
    orbit = [x0]
    x = x0
    for _ in range(n - 1):
        x = logistic_map(x, r)
        orbit.append(x)
    return orbit


def logistic_keystream(x0: float, warmup: int, length: int,
                       r: float = 4.0) -> List[int]:
    """
    Generate a keystream of `length` bytes from the logistic map.

    Args:
        x0: Initial seed in (0, 1)
        warmup: Number of iterations to discard before generating keystream
        length: Number of keystream bytes to generate
        r: Logistic map parameter (default 4.0)

    Returns:
        List of integers in [0, 255] representing the keystream.
    """
    x = x0
    # Warm-up phase
    for _ in range(warmup):
        x = logistic_map(x, r)
    # Generate keystream
    keystream = []
    for _ in range(length):
        x = logistic_map(x, r)
        keystream.append(int(x * 256) % 256)
    return keystream


def logistic_encrypt(plaintext: bytes, x0: float, warmup: int = 100,
                     r: float = 4.0) -> bytes:
    """
    Encrypt plaintext using the logistic cipher.

    Args:
        plaintext: The message to encrypt
        x0: Secret seed in (0, 1)
        warmup: Number of warm-up iterations
        r: Logistic map parameter

    Returns:
        Ciphertext bytes
    """
    ks = logistic_keystream(x0, warmup, len(plaintext), r)
    return bytes(p ^ k for p, k in zip(plaintext, ks))


def logistic_decrypt(ciphertext: bytes, x0: float, warmup: int = 100,
                     r: float = 4.0) -> bytes:
    """
    Decrypt ciphertext using the logistic cipher.
    Identical to encryption (XOR is its own inverse).
    """
    return logistic_encrypt(ciphertext, x0, warmup, r)


def lyapunov_exponent(x0: float, n: int, r: float = 4.0) -> float:
    """
    Estimate the Lyapunov exponent of the logistic map.

    The Lyapunov exponent λ = lim (1/n) Σ log|f'(x_i)|
    For r=4, the theoretical value is log(2) ≈ 0.6931.
    """
    import math
    x = x0
    total = 0.0
    for _ in range(n):
        deriv = abs(r * (1 - 2 * x))
        if deriv > 0:
            total += math.log(deriv)
        x = logistic_map(x, r)
    return total / n


def sensitivity_test(x0: float, epsilon: float, n: int,
                     r: float = 4.0) -> List[float]:
    """
    Measure how a perturbation of epsilon in x0 grows over n iterations.

    Returns list of |f^k(x0) - f^k(x0 + epsilon)| for k = 0, ..., n-1.
    """
    orbit1 = logistic_orbit(x0, n, r)
    orbit2 = logistic_orbit(x0 + epsilon, n, r)
    return [abs(a - b) for a, b in zip(orbit1, orbit2)]


def frequency_test(bits: List[int]) -> float:
    """
    NIST SP 800-22 Frequency (Monobit) Test.

    Returns the proportion of ones (should be close to 0.5 for random data).
    """
    ones = sum(bits)
    return ones / len(bits)


def runs_test(bits: List[int]) -> int:
    """
    Count the number of runs (maximal sequences of identical bits).
    For random data, expected number of runs ≈ 2n*p*(1-p) + 1.
    """
    runs = 1
    for i in range(1, len(bits)):
        if bits[i] != bits[i - 1]:
            runs += 1
    return runs


def chebyshev_conjugacy(theta: float) -> float:
    """
    The Chebyshev conjugacy: x = sin²(π*θ).
    Transforms the logistic map into the doubling map θ → 2θ mod 1.
    """
    import math
    return math.sin(math.pi * theta) ** 2


def doubling_map(theta: float) -> float:
    """The doubling map: θ → 2θ mod 1."""
    return (2 * theta) % 1.0


def iterate_degree(n: int) -> int:
    """
    The degree of f^n for the logistic map (degree 2).
    Returns 2^n — the number of roots and thus the search space for inversion.
    """
    return 2 ** n
