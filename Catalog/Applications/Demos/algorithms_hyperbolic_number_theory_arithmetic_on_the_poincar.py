"""
Hyperbolic Trace Arithmetic: Core Algorithms

Type-hinted implementations of the key algorithms from the paper:
1. Chebyshev trace computation
2. Einstein addition
3. Trace periodicity detection
4. Trace primality classification
"""

from typing import List, Tuple, Optional
from math import gcd, sqrt


def cheb_trace(t: int, n: int) -> int:
    """Compute the n-th Chebyshev trace value for initial trace t.

    Satisfies: cheb_trace(t, 0) = 2, cheb_trace(t, 1) = t,
    cheb_trace(t, n+2) = t * cheb_trace(t, n+1) - cheb_trace(t, n).

    Args:
        t: The initial trace parameter.
        n: The power index (non-negative integer).

    Returns:
        The integer cheb_trace(t, n) = 2 * T_n(t/2) where T_n is the
        n-th Chebyshev polynomial of the first kind.
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    a, b = 2, t
    for _ in range(n - 1):
        a, b = b, t * b - a
    return b


def cheb_trace_sequence(t: int, length: int) -> List[int]:
    """Compute the first `length` values of the Chebyshev trace sequence.

    Args:
        t: The initial trace parameter.
        length: Number of values to compute.

    Returns:
        List [cheb_trace(t, 0), cheb_trace(t, 1), ..., cheb_trace(t, length-1)].
    """
    if length == 0:
        return []
    if length == 1:
        return [2]
    seq = [2, t]
    for i in range(2, length):
        seq.append(t * seq[-1] - seq[-2])
    return seq


def einstein_add(a: float, b: float) -> float:
    """Einstein (relativistic) velocity addition: a ⊕ b = (a + b) / (1 + a*b).

    Preserves the interval (-1, 1) when both inputs are in (-1, 1).

    Args:
        a: First velocity (should be in (-1, 1) for geometric meaning).
        b: Second velocity.

    Returns:
        The Einstein sum a ⊕ b.

    Raises:
        ZeroDivisionError: If 1 + a*b = 0.
    """
    return (a + b) / (1 + a * b)


def einstein_iterate(a: float, n: int) -> float:
    """Compute the n-fold Einstein addition of a with itself.

    Args:
        a: The base value in (-1, 1).
        n: Number of self-additions (non-negative).

    Returns:
        a ⊕ a ⊕ ... ⊕ a (n times), which equals tanh(n * arctanh(a)).
    """
    result = 0.0
    for _ in range(n):
        result = einstein_add(result, a)
    return result


def trace_discriminant(t: int) -> int:
    """Compute the trace discriminant Δ(t) = t² - 4.

    Classification:
    - Δ < 0: elliptic (t ∈ {-1, 0, 1})
    - Δ = 0: parabolic (t ∈ {-2, 2})
    - Δ > 0: hyperbolic (|t| > 2)

    Args:
        t: The trace value.

    Returns:
        The discriminant t² - 4.
    """
    return t * t - 4


def classify_trace(t: int) -> str:
    """Classify an SL₂(ℤ) element by its trace.

    Args:
        t: The trace value.

    Returns:
        One of 'elliptic', 'parabolic', or 'hyperbolic'.
    """
    d = trace_discriminant(t)
    if d < 0:
        return 'elliptic'
    elif d == 0:
        return 'parabolic'
    else:
        return 'hyperbolic'


def cheb_trace_period_mod(t: int, m: int) -> int:
    """Find the period of the Chebyshev trace sequence modulo m.

    The sequence cheb_trace(t, n) mod m is periodic; this function
    finds the minimal positive period.

    Args:
        t: The initial trace parameter.
        m: The modulus (must be ≥ 2).

    Returns:
        The minimal period k > 0 such that the state (cheb_trace(t, k) mod m,
        cheb_trace(t, k+1) mod m) equals the initial state (2 mod m, t mod m).
    """
    if m < 2:
        raise ValueError("Modulus must be at least 2")

    init_state = (2 % m, t % m)
    a, b = init_state
    for k in range(1, m * m + 1):
        a, b = b, (t * b - a) % m
        if (a, b) == init_state:
            return k
    return m * m  # Should not reach here by pigeonhole


def is_trace_divisor(t1: int, t2: int, max_n: int = 1000) -> Optional[int]:
    """Check if t1 trace-divides t2, i.e., if t2 = cheb_trace(t1, n) for some n.

    Args:
        t1: The potential trace divisor.
        t2: The target trace value.
        max_n: Maximum power to check.

    Returns:
        The smallest n such that cheb_trace(t1, n) = t2, or None if not found.
    """
    a, b = 2, t1
    if a == t2:
        return 0
    if b == t2:
        return 1
    for n in range(2, max_n + 1):
        a, b = b, t1 * b - a
        if b == t2:
            return n
        if abs(b) > abs(t2) and abs(t1) > 2:
            return None  # Sequence grows past target
    return None


def is_prime(n: int) -> bool:
    """Simple primality test.

    Args:
        n: Integer to test.

    Returns:
        True if n is prime.
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def find_trace_primes(t: int, max_n: int = 100) -> List[Tuple[int, int]]:
    """Find prime values in the Chebyshev trace sequence.

    Args:
        t: The initial trace parameter.
        max_n: Maximum index to check.

    Returns:
        List of (n, cheb_trace(t, n)) where cheb_trace(t, n) is prime.
    """
    primes = []
    seq = cheb_trace_sequence(t, max_n + 1)
    for n, val in enumerate(seq):
        if is_prime(abs(val)):
            primes.append((n, val))
    return primes


def hyperbolic_trace_count(T: int) -> int:
    """Count hyperbolic trace values with |t| ≤ T.

    These are integers t with |t| > 2 and |t| ≤ T.

    Args:
        T: The bound (non-negative integer).

    Returns:
        The count 2*(T-2) for T ≥ 3, else 0.
    """
    if T <= 2:
        return 0
    return 2 * (T - 2)
