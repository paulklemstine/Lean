#!/usr/bin/env python3
"""
Proof Channel Theory — Algorithms

Type-hinted implementations of the key algorithms from the paper.
"""

from dataclasses import dataclass
import math
from typing import Optional


@dataclass
class ProofChannel:
    """A proof channel: the information-theoretic view of proof search.

    Parameters:
        b: Alphabet size (≥ 2)
        n: Maximum proof length
        T: Number of distinct theorems
        m: Maximum proofs per theorem (≥ 1)

    Invariant: T * m ≤ b^n
    """
    b: int
    n: int
    T: int
    m: int

    def __post_init__(self) -> None:
        assert self.b >= 2, f"Alphabet size must be ≥ 2, got {self.b}"
        assert self.m >= 1, f"Multiplicity must be ≥ 1, got {self.m}"
        assert self.T >= 1, f"Theorem count must be ≥ 1, got {self.T}"
        assert self.T * self.m <= self.b ** self.n, \
            f"Capacity bound violated: {self.T}*{self.m} > {self.b}^{self.n}"

    @property
    def space_size(self) -> int:
        """Total search space: b^n."""
        return self.b ** self.n

    @property
    def total_valid_proofs(self) -> int:
        """Total valid proofs: T * m."""
        return self.T * self.m

    @property
    def search_difficulty(self) -> int:
        """Expected candidates before finding valid proof."""
        return self.space_size // self.total_valid_proofs

    @property
    def information_content(self) -> float:
        """Information content in bits: log₂(search_difficulty + 1)."""
        return math.log2(self.search_difficulty + 1)

    @property
    def capacity(self) -> float:
        """Channel capacity in bits: log₂(b^n / m)."""
        return math.log2(self.space_size / self.m) if self.m > 0 else float('inf')

    def compose(self, other: 'ProofChannel') -> 'ProofChannel':
        """Compose with another channel (same alphabet required)."""
        assert self.b == other.b, "Cannot compose channels with different alphabets"
        return ProofChannel(
            b=self.b,
            n=self.n + other.n,
            T=self.T * other.T,
            m=self.m * other.m
        )


def search_capacity_duality(b: int, n: int, k: int) -> dict[str, int]:
    """Compute the search-capacity duality bound.

    For V ≤ b^k valid proofs in space b^n, the search difficulty
    is at least b^(n-k-1).

    Returns:
        Dictionary with bound, space_size, max_valid_proofs, actual_difficulty
    """
    assert b >= 2
    assert k + 1 <= n

    V = b ** k
    bound = b ** (n - k - 1)
    actual = b ** n // V

    return {
        'bound': bound,
        'space_size': b ** n,
        'max_valid_proofs': V,
        'actual_difficulty': actual,
        'bound_holds': bound <= actual
    }


def incompressible_count(b: int, n: int) -> dict[str, int]:
    """Count incompressible strings of length n over alphabet b.

    Returns:
        Dictionary with total, compressible, incompressible, fraction
    """
    assert b >= 2
    assert n >= 1

    total = b ** n
    compressible = b ** (n - 1)
    incompressible = total - compressible

    return {
        'total': total,
        'compressible': compressible,
        'incompressible': incompressible,
        'fraction': incompressible / total,
        'identity_check': incompressible == b ** (n - 1) * (b - 1)
    }


def hierarchy_level(b: int, k: int) -> dict[str, int | bool]:
    """Compute the k-th level of the difficulty hierarchy.

    Returns:
        Dictionary with level, difficulty, next_difficulty, strict_separation
    """
    assert b >= 2

    diff = b ** k
    next_diff = b ** (k + 1)

    return {
        'level': k,
        'difficulty': diff,
        'next_difficulty': next_diff,
        'strict_separation': diff < next_diff,
        'gap': next_diff - diff
    }


def optimal_channel(b: int, n: int, target_T: int) -> ProofChannel:
    """Construct a channel with maximum multiplicity for given T.

    Given desired T theorems, find the maximum m such that T*m ≤ b^n.
    """
    space = b ** n
    m_max = space // target_T
    assert m_max >= 1, f"Cannot fit {target_T} theorems in space {space}"
    return ProofChannel(b=b, n=n, T=target_T, m=m_max)


def brute_force_search_cost(channel: ProofChannel, verif_cost: int = 1) -> int:
    """Compute brute-force search cost: space_size × verification cost."""
    return channel.space_size * verif_cost


def stratified_search_cost(
    channel: ProofChannel,
    target_length: Optional[int] = None
) -> int:
    """Compute stratified search cost: search shorter proofs first.

    If target_length is given, only search up to that length.
    Otherwise, search up to channel.n.
    """
    max_len = target_length or channel.n
    total = 0
    for length in range(1, max_len + 1):
        total += channel.b ** length
    return total


def kfold_composition(channel: ProofChannel, k: int) -> ProofChannel:
    """Compose a channel with itself k times."""
    result = channel
    for _ in range(k - 1):
        result = result.compose(channel)
    return result


def log_factor_prediction(s: int) -> float:
    """Predict proof length from statement length using the log-factor conjecture.

    Prediction: proof_length ≈ s · log₂(s)
    """
    if s < 2:
        return float(s)
    return s * math.log2(s)


def multiplicity_tradeoff(b: int, n: int) -> list[dict[str, int | float]]:
    """Compute the multiplicity-capacity tradeoff curve.

    Returns list of (m, T_max, difficulty, capacity_fraction) tuples.
    """
    space = b ** n
    results = []
    m = 1
    while m <= space:
        T_max = space // m
        if T_max < 1:
            break
        difficulty = space // (T_max * m)
        results.append({
            'm': m,
            'T_max': T_max,
            'difficulty': max(difficulty, 1),
            'capacity_fraction': T_max / space
        })
        m *= 2
    return results


if __name__ == "__main__":
    # Quick self-test
    c = ProofChannel(b=2, n=10, T=64, m=1)
    print(f"Channel: b={c.b}, n={c.n}, T={c.T}, m={c.m}")
    print(f"  Space: {c.space_size}")
    print(f"  Difficulty: {c.search_difficulty}")
    print(f"  Info content: {c.information_content:.1f} bits")

    c2 = c.compose(c)
    print(f"\nComposed: b={c2.b}, n={c2.n}, T={c2.T}, m={c2.m}")
    print(f"  Space: {c2.space_size}")
    print(f"  Difficulty: {c2.search_difficulty}")

    print(f"\nSearch-capacity duality (b=2, n=10, k=3):")
    print(f"  {search_capacity_duality(2, 10, 3)}")

    print(f"\nIncompressible count (b=2, n=8):")
    print(f"  {incompressible_count(2, 8)}")

    print(f"\nHierarchy level 5 (b=2):")
    print(f"  {hierarchy_level(2, 5)}")

    print(f"\nLog-factor predictions:")
    for s in [10, 50, 100, 500, 1000]:
        print(f"  s={s}: predicted proof length = {log_factor_prediction(s):.1f}")
