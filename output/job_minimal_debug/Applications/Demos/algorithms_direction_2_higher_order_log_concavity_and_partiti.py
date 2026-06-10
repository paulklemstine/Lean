"""
Higher-Order Log-Concavity: Algorithms and Computational Methods

This module implements the core algorithms for computing and verifying
higher-order log-concavity of discrete sequences. The mathematical
foundation is the hierarchy of k-fold log-concavity defined recursively
through ratio sequences.

Key functions:
- kfold_depth: Compute the maximal observed depth of log-concavity
- ratio_seq: Compute the ratio sequence of a positive sequence
- is_log_concave: Check if a sequence satisfies the log-concavity inequality
- kfold_log_concave: Check if a sequence is k-fold log-concave
"""

from typing import List, Optional, Tuple
import math


def ratio_seq(seq: List[float]) -> List[float]:
    """Compute the ratio sequence r(n) = a(n+1)/a(n).

    Args:
        seq: A list of positive numbers.

    Returns:
        List of ratios, length len(seq) - 1.

    Raises:
        ValueError: If any element is non-positive.

    Example:
        >>> ratio_seq([1, 4, 6, 4, 1])
        [4.0, 1.5, 0.6666666666666666, 0.25]
    """
    if any(x <= 0 for x in seq):
        raise ValueError("All elements must be positive")
    return [seq[i + 1] / seq[i] for i in range(len(seq) - 1)]


def is_positive(seq: List[float], tol: float = 1e-12) -> bool:
    """Check if all elements of a sequence are strictly positive.

    Args:
        seq: Sequence to check.
        tol: Tolerance for positivity check.

    Returns:
        True if all elements exceed tol.
    """
    return all(x > tol for x in seq)


def is_log_concave(seq: List[float], tol: float = 1e-10) -> bool:
    """Check if a sequence satisfies the log-concavity inequality.

    A sequence a is log-concave if a(n+1)^2 >= a(n) * a(n+2) for all n.

    Args:
        seq: Sequence to check (must have at least 3 elements).
        tol: Tolerance for the inequality check.

    Returns:
        True if the sequence is log-concave up to tolerance.

    Example:
        >>> is_log_concave([1, 4, 6, 4, 1])
        True
        >>> is_log_concave([1, 2, 1, 3])
        False
    """
    if len(seq) < 3:
        return True
    for n in range(len(seq) - 2):
        if seq[n + 1] ** 2 < seq[n] * seq[n + 2] - tol:
            return False
    return True


def kfold_log_concave(seq: List[float], k: int, tol: float = 1e-10) -> bool:
    """Check if a sequence is k-fold log-concave.

    Definition (recursive):
    - 0-fold: the sequence is positive
    - (k+1)-fold: positive, log-concave, and ratio sequence is k-fold log-concave

    Args:
        seq: Sequence to check.
        k: Depth of log-concavity to verify.
        tol: Tolerance for numerical checks.

    Returns:
        True if the sequence is k-fold log-concave.

    Complexity:
        Time: O(k * n) where n = len(seq)
        Space: O(n) (ratio sequences recomputed in-place)

    Example:
        >>> kfold_log_concave([1, 3, 3, 1], 0)
        True
        >>> kfold_log_concave([1, 3, 3, 1], 1)
        True
    """
    if not is_positive(seq, tol):
        return False
    if k == 0:
        return True
    if len(seq) < 3:
        return True  # Vacuously log-concave
    if not is_log_concave(seq, tol):
        return False
    if len(seq) < 2:
        return True
    r = ratio_seq(seq)
    return kfold_log_concave(r, k - 1, tol)


def kfold_depth(seq: List[float], max_depth: int = 100, tol: float = 1e-10) -> int:
    """Compute the maximal observed depth of higher-order log-concavity.

    Iterates ratio sequences and checks log-concavity at each level.
    Returns the maximum k such that the sequence is k-fold log-concave.

    Args:
        seq: A list of positive numbers.
        max_depth: Maximum depth to check.
        tol: Tolerance for numerical checks.

    Returns:
        The maximal k-fold log-concavity depth observed.

    Complexity:
        Time: O(d * n) where d is the returned depth, n = len(seq)
        Space: O(n)

    Example:
        >>> kfold_depth([1, 4, 6, 4, 1])
        1
    """
    if not is_positive(seq, tol):
        return -1

    current = list(seq)
    depth = 0

    for _ in range(max_depth):
        if len(current) < 3:
            # Sequence too short to fail log-concavity; count as infinite depth
            return depth + max_depth - _
        if not is_log_concave(current, tol):
            return depth
        depth += 1
        if len(current) < 2:
            return depth
        current = ratio_seq(current)
        if not is_positive(current, tol):
            return depth

    return depth


def binomial_seq(n: int) -> List[float]:
    """Generate the binomial coefficient sequence C(n, 0), C(n, 1), ..., C(n, n).

    Args:
        n: The degree.

    Returns:
        List of binomial coefficients as floats.
    """
    return [float(math.comb(n, k)) for k in range(n + 1)]


def geometric_seq(c: float, r: float, length: int) -> List[float]:
    """Generate a geometric sequence c, c*r, c*r^2, ..., c*r^(length-1).

    Args:
        c: Initial value (must be positive).
        r: Common ratio (must be positive).
        length: Number of terms.

    Returns:
        List of geometric sequence terms.
    """
    return [c * r ** k for k in range(length)]


def iter_ratio(seq: List[float], m: int) -> List[float]:
    """Compute the m-th iterated ratio sequence.

    Args:
        seq: Original sequence.
        m: Number of iterations.

    Returns:
        The m-th iterated ratio sequence.
    """
    current = list(seq)
    for _ in range(m):
        if len(current) < 2:
            return current
        current = ratio_seq(current)
    return current


def test_partition_family(family_name: str, size: int) -> dict:
    """Test k-fold log-concavity depth for a family of partition-like sequences.

    Supported families:
    - "binomial": Binomial coefficients C(N, k)
    - "geometric": Geometric sequences with ratio 0.5
    - "ising_1d": 1D Ising model partition function coefficients

    Args:
        family_name: Name of the family to test.
        size: Size parameter.

    Returns:
        Dictionary with test results including depth and sequence info.
    """
    if family_name == "binomial":
        seq = binomial_seq(size)
        depth = kfold_depth(seq)
        return {
            "family": "binomial",
            "size": size,
            "sequence_length": len(seq),
            "depth": depth,
            "sequence": seq[:min(10, len(seq))],
            "is_log_concave": is_log_concave(seq),
        }
    elif family_name == "geometric":
        seq = geometric_seq(1.0, 0.5, size)
        depth = kfold_depth(seq)
        return {
            "family": "geometric",
            "size": size,
            "sequence_length": len(seq),
            "depth": depth,
            "sequence": seq[:min(10, len(seq))],
            "is_log_concave": is_log_concave(seq),
        }
    elif family_name == "ising_1d":
        # 1D Ising model: partition function coefficients
        # For a chain of length N, Z = sum over configs of exp(-beta * H)
        # Simplified: coefficients counting configs by magnetization
        seq = binomial_seq(size)  # Simplified model
        depth = kfold_depth(seq)
        return {
            "family": "ising_1d",
            "size": size,
            "sequence_length": len(seq),
            "depth": depth,
            "sequence": seq[:min(10, len(seq))],
            "is_log_concave": is_log_concave(seq),
        }
    else:
        raise ValueError(f"Unknown family: {family_name}")


if __name__ == "__main__":
    print("=== Higher-Order Log-Concavity Algorithm Tests ===\n")

    # Test binomial sequences
    print("Binomial coefficient sequences C(N, k):")
    for n in range(2, 12):
        seq = binomial_seq(n)
        d = kfold_depth(seq)
        print(f"  N={n:2d}: depth = {d}, seq = {seq}")

    print()

    # Test geometric sequences
    print("Geometric sequences (infinite depth):")
    for r in [0.5, 1.0, 2.0]:
        seq = geometric_seq(1.0, r, 10)
        d = kfold_depth(seq)
        print(f"  r={r}: depth = {d}")

    print()

    # Test product stability
    print("Product stability test:")
    a = binomial_seq(6)
    b = binomial_seq(6)
    ab = [a[i] * b[i] for i in range(len(a))]
    print(f"  depth(C(6,k)) = {kfold_depth(a)}")
    print(f"  depth(C(6,k)^2) = {kfold_depth(ab)}")
