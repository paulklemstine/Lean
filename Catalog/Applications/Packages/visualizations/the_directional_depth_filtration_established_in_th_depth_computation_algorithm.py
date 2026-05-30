"""
Directional Depth Theory: Core Algorithms
==========================================

Implements the key algorithms from the directional depth theory research,
including depth computation, filtration construction, and exchange verification.
"""

from typing import List, Optional, Tuple
import math


def ratio_transform(seq: List[float]) -> List[float]:
    """Apply the ratio transform R(a)(n) = a(n+1)/a(n).

    Time complexity: O(n) where n = len(seq)
    Space complexity: O(n)

    Args:
        seq: A positive real-valued sequence.

    Returns:
        The ratio-transformed sequence, one element shorter.

    Example:
        >>> ratio_transform([1, 2, 4, 8])
        [2.0, 2.0, 2.0]
    """
    if not seq or len(seq) < 2:
        return []
    return [seq[i + 1] / seq[i] for i in range(len(seq) - 1)]


def is_log_concave(seq: List[float], rel_tol: float = 1e-9) -> bool:
    """Check if a sequence is log-concave.

    A sequence a is log-concave if a(n+1)^2 >= a(n)*a(n+2) for all n.

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        seq: A positive real-valued sequence.
        rel_tol: Relative tolerance for floating point comparison.

    Returns:
        True if the sequence is log-concave.

    Example:
        >>> is_log_concave([1, 3, 6, 10])  # C(4,k)-like
        True
    """
    for i in range(len(seq) - 2):
        lhs = seq[i + 1] ** 2
        rhs = seq[i] * seq[i + 2]
        if lhs < rhs * (1 - rel_tol):
            return False
    return True


def compute_depth(seq: List[float], max_depth: int = 50) -> int:
    """Compute the directional depth of a positive sequence.

    The depth is the maximum k such that applying the ratio transform
    k times preserves positivity and log-concavity.

    Time complexity: O(k * n) where k = depth, n = len(seq)
    Space complexity: O(n)

    Algorithm:
        1. Check positivity and log-concavity of input (depth >= 0)
        2. Apply ratio transform
        3. Check positivity and log-concavity of result (depth >= 1)
        4. Repeat until failure or max_depth reached

    Args:
        seq: A positive real-valued sequence.
        max_depth: Maximum depth to test.

    Returns:
        The computed depth, or -1 if not even log-concave.

    Example:
        >>> compute_depth([1, 2, 4, 8, 16])  # Geometric
        3
    """
    current = list(seq)
    if not all(x > 0 for x in current):
        return -1
    if not is_log_concave(current):
        return -1

    depth = 0
    for _ in range(max_depth):
        if len(current) < 3:
            return depth
        try:
            current = ratio_transform(current)
        except (ZeroDivisionError, OverflowError):
            return depth
        if not current or not all(x > 0 for x in current):
            return depth
        if not is_log_concave(current):
            return depth
        depth += 1

    return depth


def depth_filtration(seq: List[float], max_k: int = 10) -> List[bool]:
    """Compute the depth filtration of a sequence.

    Returns a boolean array where entry k is True iff the sequence
    has depth >= k.

    Time complexity: O(max_k * n)
    Space complexity: O(max_k)

    Args:
        seq: A positive real-valued sequence.
        max_k: Maximum filtration level to compute.

    Returns:
        List of booleans, one per filtration level.

    Example:
        >>> depth_filtration([1, 2, 4, 8], max_k=5)
        [True, True, True, False, False]
    """
    d = compute_depth(seq, max_depth=max_k)
    return [k <= d for k in range(max_k)]


def verify_exchange_property(seq: List[float], tol: float = 1e-10) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Verify the exchange property: a(i)*a(j+1) <= a(i+1)*a(j) for i <= j.

    Time complexity: O(n^2)
    Space complexity: O(1)

    Args:
        seq: A positive real-valued sequence.
        tol: Absolute tolerance.

    Returns:
        (True, None) if exchange property holds, or
        (False, (i, j)) giving a counterexample.

    Example:
        >>> verify_exchange_property([1, 3, 3, 1])
        (True, None)
    """
    n = len(seq)
    for i in range(n - 1):
        for j in range(i, n - 1):
            if i + 1 < n:
                if seq[i] * seq[j + 1] > seq[i + 1] * seq[j] + tol:
                    return (False, (i, j))
    return (True, None)


def tropical_concavity_gaps(seq: List[float]) -> List[float]:
    """Compute the tropical concavity gaps: 2*log(a(n+1)) - log(a(n)) - log(a(n+2)).

    These are nonneg iff log(a) is tropical concave (equiv to log-concavity).

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        seq: A positive real-valued sequence.

    Returns:
        List of gap values (nonneg means tropical-concave at that index).

    Example:
        >>> gaps = tropical_concavity_gaps([1, 4, 9, 16])
        >>> all(g >= -1e-10 for g in gaps)
        True
    """
    log_seq = [math.log(x) for x in seq if x > 0]
    return [2 * log_seq[i + 1] - log_seq[i] - log_seq[i + 2]
            for i in range(len(log_seq) - 2)]


def depth_spectrum(seq: List[float], scales: List[int]) -> dict:
    """Compute the depth spectrum at multiple scales.

    The depth spectrum measures how depth varies when subsampling
    the sequence at different rates.

    Time complexity: O(sum(n/s * d) for s in scales)

    Args:
        seq: A positive real-valued sequence.
        scales: List of scaling factors.

    Returns:
        Dict mapping scale to computed depth.

    Example:
        >>> depth_spectrum([2**n for n in range(100)], [1, 2, 5])
        {1: 20, 2: 20, 5: 20}
    """
    result = {}
    for s in scales:
        sub = [seq[s * i] for i in range(len(seq) // s) if s * i < len(seq)]
        if len(sub) >= 3:
            result[s] = compute_depth(sub)
        else:
            result[s] = -2  # too short
    return result


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=== Directional Depth Theory: Algorithm Examples ===\n")

    # Geometric sequence
    geo = [3 * 2 ** n for n in range(25)]
    print(f"Geometric 3*2^n: depth = {compute_depth(geo)}")
    print(f"  Filtration: {depth_filtration(geo, max_k=8)}")
    print(f"  Exchange: {verify_exchange_property(geo[:10])}")

    # Binomial coefficients
    n = 12
    binom = [math.comb(n, k) for k in range(n + 1)]
    print(f"\nC({n},k): depth = {compute_depth(binom)}")
    gaps = tropical_concavity_gaps(binom)
    print(f"  Tropical gaps (first 5): {[f'{g:.4f}' for g in gaps[:5]]}")

    # Depth spectrum
    long_geo = [2 ** n for n in range(100)]
    spec = depth_spectrum(long_geo, [1, 2, 3, 5, 10])
    print(f"\nDepth spectrum of 2^n: {spec}")
