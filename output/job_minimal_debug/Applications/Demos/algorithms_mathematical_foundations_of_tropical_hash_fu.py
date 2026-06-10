"""
Tropical Hash Function Algorithms
Type-hinted implementations of TSHA, NTSHA, and related constructions.
"""

from typing import List, Tuple, Optional
import math


def tsha(m: List[int], h: List[int]) -> int:
    """Tropical Secure Hash Algorithm: TSHA(m, h) = min_i(m_i + h_i).

    Args:
        m: Message vector of length k.
        h: Key vector of length k.

    Returns:
        The minimum of component-wise sums.

    Raises:
        ValueError: If vectors have different lengths or are empty.
    """
    if len(m) != len(h):
        raise ValueError("Message and key must have same length")
    if len(m) == 0:
        raise ValueError("Vectors must be non-empty")
    return min(m[i] + h[i] for i in range(len(m)))


def ntsha(m: List[int], h: List[int], p: int) -> int:
    """Nonlinear Tropical Secure Hash Algorithm: NTSHA_p(m, h) = min_i((m_i + h_i) mod p).

    Args:
        m: Message vector of length k.
        h: Key vector of length k.
        p: Modulus (must be >= 2).

    Returns:
        The minimum of modular component-wise sums.

    Raises:
        ValueError: If vectors differ in length, are empty, or p < 2.
    """
    if len(m) != len(h):
        raise ValueError("Message and key must have same length")
    if len(m) == 0:
        raise ValueError("Vectors must be non-empty")
    if p < 2:
        raise ValueError("Modulus must be >= 2")
    return min((m[i] + h[i]) % p for i in range(len(m)))


def dntsha(m: List[int], h1: List[int], h2: List[int], p: int) -> Tuple[int, int]:
    """Double NTSHA with independent keys.

    Args:
        m: Message vector.
        h1: First key vector.
        h2: Second key vector.
        p: Modulus.

    Returns:
        Tuple (NTSHA_p(m, h1), NTSHA_p(m, h2)).
    """
    return (ntsha(m, h1, p), ntsha(m, h2, p))


def canonical_preimage(h: List[int], y: int, p: int) -> List[int]:
    """Construct the canonical preimage for NTSHA_p at target value y.

    The canonical preimage m_i = y - h_i gives (m_i + h_i) mod p = y mod p = y
    when 0 <= y < p.

    Args:
        h: Key vector.
        y: Target hash value (0 <= y < p).
        p: Modulus.

    Returns:
        Message vector m such that NTSHA_p(m, h) = y.
    """
    return [y - h[i] for i in range(len(h))]


def tropical_hash_iterate(m: List[int], h: List[int], n: int) -> Optional[int]:
    """Progressive tropical hash using only the first n+1 coordinates.

    Args:
        m: Message vector of length k.
        h: Key vector of length k.
        n: Number of coordinates to include (0-indexed, uses coords 0..n).

    Returns:
        Minimum of m_i + h_i for i <= n, or None if no coordinates included.
    """
    k = len(m)
    components = [m[i] + h[i] for i in range(min(n + 1, k))]
    return min(components) if components else None


def find_ntsha_collision(h: List[int], p: int, m1: List[int]) -> Optional[List[int]]:
    """Attempt to find a collision for NTSHA_p: m2 != m1 with NTSHA_p(m1, h) = NTSHA_p(m2, h).

    Strategy: Identify the minimizing index j, then shift a non-minimizing
    coordinate by p (which preserves the hash by fiber periodicity).

    Args:
        h: Key vector.
        p: Modulus.
        m1: Original message.

    Returns:
        A different message m2 with the same hash, or None if k = 1 and p = 1.
    """
    k = len(m1)
    if k < 2:
        return None

    # Find minimizing index
    components = [(m1[i] + h[i]) % p for i in range(k)]
    min_val = min(components)
    j = components.index(min_val)

    # Find a non-minimizing index and shift by p
    m2 = m1.copy()
    for i in range(k):
        if i != j:
            m2[i] = m1[i] + p
            break

    return m2


def tropical_avalanche_test(m: List[int], h: List[int], j: int, delta: int) -> Tuple[int, int, int]:
    """Test the avalanche property by perturbing coordinate j by delta.

    Args:
        m: Message vector.
        h: Key vector.
        j: Index to perturb.
        delta: Perturbation amount.

    Returns:
        Tuple (original_hash, perturbed_hash, difference).
    """
    original = tsha(m, h)
    m_perturbed = m.copy()
    m_perturbed[j] = m[j] + delta
    perturbed = tsha(m_perturbed, h)
    return (original, perturbed, perturbed - original)


def ntsha_distribution(k: int, p: int, num_samples: int = 100000) -> List[float]:
    """Estimate the distribution of NTSHA values for random inputs.

    Args:
        k: Dimension.
        p: Modulus.
        num_samples: Number of random samples.

    Returns:
        List of length p with estimated probabilities for each output value.
    """
    import random
    counts = [0] * p
    N = 10 * p  # Range for random inputs
    for _ in range(num_samples):
        m = [random.randint(0, N) for _ in range(k)]
        h = [random.randint(0, N) for _ in range(k)]
        v = ntsha(m, h, p)
        counts[v] += 1
    return [c / num_samples for c in counts]


def predicted_ntsha_distribution(k: int, p: int) -> List[float]:
    """Theoretical prediction for NTSHA distribution (uniform components).

    Under the assumption that (m_i + h_i) mod p is approximately uniform,
    the minimum of k uniform-on-{0,...,p-1} variables has:
    P(V = j) = ((p - j)/p)^k - ((p - j - 1)/p)^k

    Args:
        k: Dimension.
        p: Modulus.

    Returns:
        List of length p with predicted probabilities.
    """
    probs = []
    for j in range(p):
        if j < p:
            prob = ((p - j) / p) ** k - ((p - j - 1) / p) ** k
        else:
            prob = 0.0
        probs.append(prob)
    return probs


if __name__ == "__main__":
    # Quick self-test
    m = [3, 7, 1, 5]
    h = [2, 1, 4, 3]
    print(f"TSHA({m}, {h}) = {tsha(m, h)}")
    print(f"NTSHA_11({m}, {h}) = {ntsha(m, h, 11)}")
    print(f"Canonical preimage for y=3, p=11: {canonical_preimage(h, 3, 11)}")

    # Verify shift equivariance breaking
    m1 = [1]
    h1 = [0]
    c = 2
    p = 3
    lhs = ntsha([m1[0] + c], h1, p)
    rhs = ntsha(m1, h1, p) + c
    print(f"\nShift equivariance test:")
    print(f"  NTSHA_3([1+2], [0]) = {lhs}")
    print(f"  NTSHA_3([1], [0]) + 2 = {rhs}")
    print(f"  Equal? {lhs == rhs} (should be False)")
