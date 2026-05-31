"""
Information-Theoretic Proof Search Complexity: Core Algorithms

Implements the key algorithms and data structures for analyzing
proof search complexity, including brute-force search, information
content estimation, and proof density computation.
"""

from __future__ import annotations
import math
from dataclasses import dataclass
from typing import Callable, Optional, List, Tuple


@dataclass
class ProofSearchInstance:
    """A proof search instance capturing the essential parameters.

    Attributes:
        alphabet_size: Number of symbols in the proof language (≥ 2)
        max_proof_len: Maximum length of proofs considered
        num_valid_proofs: Number of valid proofs of length ≤ max_proof_len
        verif_cost: Cost of checking a single candidate proof
    """
    alphabet_size: int
    max_proof_len: int
    num_valid_proofs: int
    verif_cost: int

    def __post_init__(self) -> None:
        assert self.alphabet_size >= 2, "Alphabet must have at least 2 symbols"
        assert self.num_valid_proofs <= self.alphabet_size ** self.max_proof_len, \
            "Valid proofs cannot exceed search space"
        assert self.verif_cost >= 1, "Verification cost must be positive"

    @property
    def search_space_size(self) -> int:
        """Total number of candidate proofs: b^n."""
        return self.alphabet_size ** self.max_proof_len

    @property
    def brute_force_cost(self) -> int:
        """Cost of exhaustive search: b^n * v."""
        return self.search_space_size * self.verif_cost

    @property
    def proof_density(self) -> float:
        """Fraction of candidates that are valid proofs."""
        s = self.search_space_size
        return self.num_valid_proofs / s if s > 0 else 0.0

    @property
    def information_content_bits(self) -> float:
        """Information content: -log2(proof_density) bits."""
        d = self.proof_density
        return -math.log2(d) if d > 0 else float('inf')

    @property
    def search_verification_ratio(self) -> float:
        """Ratio of search cost to verification cost."""
        return float(self.search_space_size)


def brute_force_search(
    alphabet_size: int,
    max_length: int,
    verify: Callable[[List[int]], bool]
) -> Optional[List[int]]:
    """Brute-force proof search over all strings up to max_length.

    Args:
        alphabet_size: Number of symbols (b)
        max_length: Maximum proof length (n)
        verify: Oracle that checks if a candidate is a valid proof

    Returns:
        A valid proof as a list of symbol indices, or None if not found.

    Complexity: O(b^n * verification_cost)
    """
    def enumerate_strings(length: int) -> List[List[int]]:
        if length == 0:
            return [[]]
        shorter = enumerate_strings(length - 1)
        return [s + [c] for s in shorter for c in range(alphabet_size)]

    for length in range(1, max_length + 1):
        for candidate in enumerate_strings(length):
            if verify(candidate):
                return candidate
    return None


def information_guided_search(
    alphabet_size: int,
    max_length: int,
    prior: Callable[[List[int]], float],
    verify: Callable[[List[int]], bool]
) -> Optional[List[int]]:
    """Information-guided proof search using a prior distribution.

    Searches candidates in order of decreasing prior probability,
    which is optimal when verification cost is uniform.

    Args:
        alphabet_size: Number of symbols (b)
        max_length: Maximum proof length (n)
        prior: Function mapping candidates to prior probabilities
        verify: Oracle that checks validity

    Returns:
        A valid proof, or None.
    """
    candidates: List[Tuple[float, List[int]]] = []

    def enumerate_strings(length: int) -> List[List[int]]:
        if length == 0:
            return [[]]
        shorter = enumerate_strings(length - 1)
        return [s + [c] for s in shorter for c in range(alphabet_size)]

    for length in range(1, max_length + 1):
        for s in enumerate_strings(length):
            candidates.append((prior(s), s))

    # Sort by decreasing probability
    candidates.sort(key=lambda x: -x[0])

    for _, candidate in candidates:
        if verify(candidate):
            return candidate
    return None


def proof_length_lower_bound(num_theorems: int, alphabet_size: int) -> int:
    """Compute the minimum proof length to distinguish num_theorems theorems.

    By the counting argument, proofs of length n over alphabet b can
    represent at most b^n distinct theorems. So n >= log_b(T).

    Args:
        num_theorems: Number of theorems to distinguish
        alphabet_size: Alphabet size (b >= 2)

    Returns:
        Minimum proof length (ceiling of log_b(num_theorems))
    """
    if num_theorems <= 1:
        return 0
    return math.ceil(math.log(num_theorems, alphabet_size))


def search_tree_size(branching: int, depth: int) -> int:
    """Compute the number of leaves in a b-ary tree of depth d.

    Args:
        branching: Branching factor (b)
        depth: Tree depth (d)

    Returns:
        b^d
    """
    return branching ** depth


def proof_search_gap(
    statement_length: int,
    alphabet_size: int = 2
) -> dict:
    """Compute the verification-search gap for a given statement length.

    Args:
        statement_length: Length of the theorem statement (n)
        alphabet_size: Proof language alphabet size (b)

    Returns:
        Dictionary with search space size, estimated proof length,
        and the gap between search and verification costs.
    """
    n = statement_length
    b = alphabet_size

    # Estimated proof length: n * log2(n) (from conjecture)
    proof_len = max(1, int(n * math.log2(max(2, n))))

    search_space = b ** proof_len
    verif_cost = n ** 2  # Polynomial verification
    search_cost = search_space * verif_cost
    gap = search_space  # Ratio of search to verification

    return {
        "statement_length": n,
        "estimated_proof_length": proof_len,
        "search_space_size": search_space,
        "verification_cost": verif_cost,
        "brute_force_search_cost": search_cost,
        "search_verification_gap": gap,
        "information_content_bits": proof_len * math.log2(b),
        "log_factor": proof_len / n if n > 0 else float('inf'),
    }


def estimate_proof_density(
    alphabet_size: int,
    proof_length: int,
    num_valid: int
) -> dict:
    """Estimate proof density and related information-theoretic quantities.

    Args:
        alphabet_size: Alphabet size (b)
        proof_length: Proof length (n)
        num_valid: Number of valid proofs

    Returns:
        Dictionary with density, information content, and search bounds.
    """
    space = alphabet_size ** proof_length
    density = num_valid / space if space > 0 else 0
    info_bits = -math.log2(density) if density > 0 else float('inf')

    return {
        "search_space": space,
        "num_valid_proofs": num_valid,
        "proof_density": density,
        "information_content_bits": info_bits,
        "expected_search_cost": 1.0 / density if density > 0 else float('inf'),
        "kraft_bound_satisfied": num_valid <= space,
    }


def proof_length_ratio_analysis(
    statement_lengths: List[int],
    proof_lengths: List[int]
) -> dict:
    """Analyze the ratio of proof length to statement length.

    Tests the conjecture that proof_length / (statement_length * log(statement_length))
    converges to a constant.

    Args:
        statement_lengths: List of theorem statement lengths
        proof_lengths: List of corresponding proof lengths

    Returns:
        Statistics on the ratio p / (s * log2(s)).
    """
    ratios: List[float] = []
    for s, p in zip(statement_lengths, proof_lengths):
        if s >= 2:
            log_s = math.log2(s)
            ratio = p / (s * log_s) if s * log_s > 0 else float('inf')
            ratios.append(ratio)

    if not ratios:
        return {"error": "No valid data points"}

    mean_ratio = sum(ratios) / len(ratios)
    variance = sum((r - mean_ratio) ** 2 for r in ratios) / len(ratios)

    return {
        "num_samples": len(ratios),
        "mean_ratio": mean_ratio,
        "std_ratio": math.sqrt(variance),
        "min_ratio": min(ratios),
        "max_ratio": max(ratios),
        "conjecture_supported": 0.1 < mean_ratio < 50,
    }
