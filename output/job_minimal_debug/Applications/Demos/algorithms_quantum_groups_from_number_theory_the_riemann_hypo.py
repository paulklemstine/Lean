"""
Quantum Group Spectral Theory: Algorithms

Implementations of q-integer computation, Casimir eigenvalue generation,
spectral statistics, and the Chebyshev bridge verification.
"""

from typing import List, Tuple
import math


def q_integer(x: float, n: int) -> float:
    """Compute the q-integer [n]_q parameterized by x = (q + q^{-1})/2.

    Uses the Chebyshev recurrence: [0] = 0, [1] = 1, [n+2] = 2x[n+1] - [n].
    Equivalent to Chebyshev U_{n-1}(x) for n >= 1.

    Args:
        x: Deformation parameter (x = cos(theta) when q = e^{i*theta})
        n: Non-negative integer index

    Returns:
        The q-integer [n]_q as a float

    Time complexity: O(n), Space: O(1)
    """
    if n == 0:
        return 0.0
    if n == 1:
        return 1.0
    a, b = 0.0, 1.0
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def casimir_eigenvalue(x: float, n: int) -> float:
    """Compute the q-Casimir eigenvalue lambda_n = [n]_q * [n+1]_q.

    At x = 1 (classical limit), this gives n*(n+1).

    Args:
        x: Deformation parameter
        n: Representation label

    Returns:
        The q-Casimir eigenvalue
    """
    return q_integer(x, n) * q_integer(x, n + 1)


def casimir_spectrum(x: float, N: int) -> List[float]:
    """Generate the first N+1 q-Casimir eigenvalues.

    Args:
        x: Deformation parameter
        N: Maximum representation label

    Returns:
        List of eigenvalues [lambda_0, lambda_1, ..., lambda_N]
    """
    if N < 0:
        return []
    # Compute all q-integers up to N+1 efficiently
    q_ints = [0.0] * (N + 2)
    if N >= 0:
        q_ints[0] = 0.0
    if N >= 0:
        q_ints[1] = 1.0
    for k in range(2, N + 2):
        q_ints[k] = 2 * x * q_ints[k - 1] - q_ints[k - 2]
    return [q_ints[n] * q_ints[n + 1] for n in range(N + 1)]


def spectral_gaps(x: float, N: int) -> List[float]:
    """Compute spectral gaps Delta_n = lambda_{n+1} - lambda_n.

    At x = 1, these are 2*(n+1) (linear growth).

    Args:
        x: Deformation parameter
        N: Number of gaps to compute

    Returns:
        List of gaps [Delta_0, ..., Delta_{N-1}]
    """
    spectrum = casimir_spectrum(x, N)
    return [spectrum[n + 1] - spectrum[n] for n in range(N)]


def spectral_telescoping_sum(N: int) -> float:
    """Compute sum_{k=1}^{N} 1/(k*(k+1)) = 1 - 1/(N+1).

    Demonstrates the spectral zeta convergence to 1.

    Args:
        N: Upper summation limit (positive integer)

    Returns:
        The partial sum
    """
    return sum(1.0 / (k * (k + 1)) for k in range(1, N + 1))


def chebyshev_U(x: float, n: int) -> float:
    """Compute the Chebyshev polynomial of the second kind U_n(x).

    U_0(x) = 1, U_1(x) = 2x, U_{n+1}(x) = 2x*U_n(x) - U_{n-1}(x).

    Args:
        x: Evaluation point
        n: Polynomial degree

    Returns:
        U_n(x)
    """
    if n == 0:
        return 1.0
    if n == 1:
        return 2 * x
    a, b = 1.0, 2 * x
    for _ in range(2, n + 1):
        a, b = b, 2 * x * b - a
    return b


def verify_chebyshev_bridge(x: float, n_max: int) -> List[Tuple[int, float, float, float]]:
    """Verify that [n+1]_q = U_n(x) for n = 0, ..., n_max.

    Args:
        x: Deformation parameter
        n_max: Maximum degree to check

    Returns:
        List of (n, qInt(x, n+1), chebyU(x, n), difference) tuples
    """
    results = []
    for n in range(n_max + 1):
        qi = q_integer(x, n + 1)
        cu = chebyshev_U(x, n)
        results.append((n, qi, cu, abs(qi - cu)))
    return results


def nearest_neighbor_spacings(eigenvalues: List[float]) -> List[float]:
    """Compute normalized nearest-neighbor spacings of a spectrum.

    Sorts eigenvalues, computes gaps, and normalizes by mean gap.

    Args:
        eigenvalues: List of eigenvalues

    Returns:
        Normalized spacings
    """
    sorted_eigs = sorted(eigenvalues)
    gaps = [sorted_eigs[i + 1] - sorted_eigs[i] for i in range(len(sorted_eigs) - 1)]
    if not gaps:
        return []
    mean_gap = sum(gaps) / len(gaps)
    if mean_gap == 0:
        return gaps
    return [g / mean_gap for g in gaps]


def addition_formula_check(x: float, m: int, n: int) -> Tuple[float, float, float]:
    """Verify the addition formula [m+n+1] = [m+1]*[n+1] - [m]*[n].

    Args:
        x: Deformation parameter
        m, n: Non-negative integer indices

    Returns:
        (lhs, rhs, difference) tuple
    """
    lhs = q_integer(x, m + n + 1)
    rhs = q_integer(x, m + 1) * q_integer(x, n + 1) - q_integer(x, m) * q_integer(x, n)
    return (lhs, rhs, abs(lhs - rhs))


if __name__ == "__main__":
    # Quick verification
    print("=== Classical Limit Verification ===")
    for n in range(8):
        print(f"  [{ n}]_(q=1) = {q_integer(1.0, n):.1f}  (expected {n})")

    print("\n=== Casimir Classical ===")
    for n in range(6):
        print(f"  lambda_{n}(1) = {casimir_eigenvalue(1.0, n):.1f}  (expected {n*(n+1)})")

    print("\n=== Chebyshev Bridge ===")
    x = 0.7
    for n, qi, cu, diff in verify_chebyshev_bridge(x, 8):
        print(f"  [{ n+1}]_q = {qi:.6f}, U_{n}({x}) = {cu:.6f}, diff = {diff:.2e}")

    print("\n=== Addition Formula ===")
    for m in range(4):
        for n in range(4):
            lhs, rhs, diff = addition_formula_check(x, m, n)
            status = "✓" if diff < 1e-10 else "✗"
            print(f"  {status} m={m}, n={n}: [{m+n+1}] = {lhs:.6f}, [m+1][n+1]-[m][n] = {rhs:.6f}")

    print("\n=== Spectral Telescoping ===")
    for N in [10, 100, 1000, 10000]:
        s = spectral_telescoping_sum(N)
        print(f"  sum_{{k=1}}^{{{N}}} 1/(k(k+1)) = {s:.10f}  (expected {1 - 1/(N+1):.10f})")
