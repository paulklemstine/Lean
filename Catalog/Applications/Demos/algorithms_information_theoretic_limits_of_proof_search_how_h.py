"""
Information-Theoretic Proof Search: Core Algorithms

Implements the key algorithms from the research paper on
information-theoretic limits of proof search complexity.
"""

import math
from typing import Callable, Optional, List, Tuple
from dataclasses import dataclass


@dataclass
class ProofSearchSpace:
    """A proof search space with combinatorial parameters.

    Attributes:
        alphabet_size: Number of symbols in the proof language (b ≥ 2)
        max_proof_len: Maximum proof length (n)
        valid_count: Number of valid proof strings (V ≤ b^n)
        theorem_count: Number of provable theorems (T ≤ V)
    """
    alphabet_size: int
    max_proof_len: int
    valid_count: int
    theorem_count: int

    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2, "Alphabet size must be ≥ 2"
        assert self.valid_count <= self.alphabet_size ** self.max_proof_len
        assert self.theorem_count <= self.valid_count
        assert self.theorem_count > 0

    @property
    def total_candidates(self) -> int:
        """Total number of candidate strings: b^n."""
        return self.alphabet_size ** self.max_proof_len

    @property
    def search_difficulty(self) -> int:
        """Search difficulty: ⌊b^n / (V+1)⌋."""
        return self.total_candidates // (self.valid_count + 1)

    @property
    def proof_density(self) -> float:
        """Fraction of valid proofs among all candidates."""
        tc = self.total_candidates
        return self.valid_count / tc if tc > 0 else 0.0

    @property
    def information_content_bits(self) -> float:
        """Information content in bits: -log₂(density)."""
        d = self.proof_density
        return -math.log2(d) if d > 0 else float('inf')


@dataclass
class ProofComplexityProfile:
    """Captures how proof difficulty scales with statement complexity.

    Attributes:
        alphabet_size: Number of symbols (b ≥ 2)
        proof_len_fn: Maps statement length → max proof length (monotone)
        proof_count_fn: Maps statement length → number of provable theorems
    """
    alphabet_size: int
    proof_len_fn: Callable[[int], int]
    proof_count_fn: Callable[[int], int]

    def difficulty_at(self, s: int) -> int:
        """Search difficulty at statement length s."""
        space = self.alphabet_size ** self.proof_len_fn(s)
        return space // (self.proof_count_fn(s) + 1)

    def cumulative_difficulty(self, s: int) -> int:
        """Cumulative difficulty up to statement length s."""
        return sum(self.difficulty_at(i) for i in range(s))

    def information_profile(self, max_s: int) -> List[Tuple[int, float]]:
        """Compute information content at each statement length."""
        result = []
        for s in range(1, max_s + 1):
            space = self.alphabet_size ** self.proof_len_fn(s)
            count = self.proof_count_fn(s)
            density = count / space if space > 0 else 0
            info = -math.log2(density) if density > 0 else float('inf')
            result.append((s, info))
        return result


def sparse_proof_search_bound(b: int, n: int, k: int) -> int:
    """Compute the lower bound on search difficulty.

    For V ≤ b^k valid proofs in a space of b^n candidates,
    search requires ≥ b^(n-k-1) examinations.

    Args:
        b: Alphabet size (≥ 2)
        n: Proof length
        k: Exponent of valid proof count (k+1 ≤ n)

    Returns:
        Lower bound b^(n-k-1) on search difficulty.
    """
    assert b >= 2
    assert k + 1 <= n
    return b ** (n - k - 1)


def brute_force_search(
    alphabet_size: int,
    max_len: int,
    verifier: Callable[[List[int]], bool],
    max_candidates: Optional[int] = None
) -> Optional[List[int]]:
    """Brute-force proof search over all strings.

    Args:
        alphabet_size: Number of symbols
        max_len: Maximum string length
        verifier: Function that checks if a string is a valid proof
        max_candidates: Maximum number of candidates to check

    Returns:
        A valid proof string, or None if not found.
    """
    checked = 0
    limit = max_candidates or alphabet_size ** max_len

    def generate(prefix: List[int], remaining: int):
        nonlocal checked
        if checked >= limit:
            return None
        if remaining == 0:
            checked += 1
            if verifier(prefix):
                return list(prefix)
            return None
        for sym in range(alphabet_size):
            result = generate(prefix + [sym], remaining - 1)
            if result is not None:
                return result
        return None

    return generate([], max_len)


def compressible_fraction(b: int, n: int) -> float:
    """Compute the maximum compressible fraction of strings.

    At most b^(n-1) of b^n strings can be compressed, giving
    fraction ≤ 1/b.

    Args:
        b: Alphabet size (≥ 2)
        n: String length (≥ 1)

    Returns:
        Upper bound on compressible fraction: 1/b.
    """
    assert b >= 2
    assert n >= 1
    return 1.0 / b


def search_hierarchy_bound(b: int, k: int) -> Tuple[int, int]:
    """Compute hierarchy level bounds.

    Returns (lower, upper) where lower = k+1 and upper = b^k.
    The theorem guarantees lower ≤ upper.

    Args:
        b: Base (≥ 2)
        k: Level

    Returns:
        Tuple of (linear bound, exponential bound).
    """
    return (k + 1, b ** k)


def proof_density_at_length(
    valid_count: int,
    alphabet_size: int,
    proof_length: int
) -> float:
    """Compute proof density at a given length.

    Args:
        valid_count: Number of valid proofs
        alphabet_size: Alphabet size (≥ 2)
        proof_length: Proof length

    Returns:
        Density V / b^n.
    """
    total = alphabet_size ** proof_length
    return valid_count / total if total > 0 else 0.0


def information_bottleneck_bound(
    alphabet_size: int,
    proof_length: int
) -> int:
    """Maximum number of theorems provable with proofs of given length.

    By the mutual information bottleneck theorem,
    T ≤ b^n.

    Args:
        alphabet_size: Alphabet size
        proof_length: Maximum proof length

    Returns:
        Upper bound b^n on theorem count.
    """
    return alphabet_size ** proof_length


def log_factor_prediction(statement_length: int) -> float:
    """Predicted proof length under the log-factor conjecture.

    Conjecture: proof_length ≈ C · s · log₂(s) for some constant C.
    We use C = 3 as a reasonable estimate.

    Args:
        statement_length: Length of the theorem statement

    Returns:
        Predicted proof length.
    """
    if statement_length <= 1:
        return float(statement_length)
    C = 3.0
    return C * statement_length * math.log2(statement_length)


if __name__ == "__main__":
    # Example usage
    space = ProofSearchSpace(
        alphabet_size=2,
        max_proof_len=20,
        valid_count=100,
        theorem_count=50
    )
    print(f"Search space: {space.total_candidates:,} candidates")
    print(f"Search difficulty: {space.search_difficulty:,}")
    print(f"Proof density: {space.proof_density:.2e}")
    print(f"Information content: {space.information_content_bits:.1f} bits")

    # Hierarchy
    for k in range(10):
        lo, hi = search_hierarchy_bound(2, k)
        print(f"Level {k}: {lo} ≤ {hi}")
