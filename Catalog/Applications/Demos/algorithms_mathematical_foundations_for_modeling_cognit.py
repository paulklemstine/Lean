"""
Cognitive Braiding Theory: Core Algorithms

Implements the mathematical framework for modeling cognitive processes
as crossing words with topological invariants.
"""

from typing import List, Tuple
from enum import Enum
import math


class CrossingSign(Enum):
    """A signed crossing: +1 for positive, -1 for negative."""
    POS = 1
    NEG = -1

    def flip(self) -> 'CrossingSign':
        return CrossingSign.NEG if self == CrossingSign.POS else CrossingSign.POS


class Crossing:
    """A crossing event at a strand position with a sign."""
    def __init__(self, position: int, sign: CrossingSign):
        self.position = position
        self.sign = sign

    def __repr__(self) -> str:
        s = "+" if self.sign == CrossingSign.POS else "-"
        return f"σ{s}({self.position})"


# Type alias
CrossingWord = List[Crossing]


def num_crossings(w: CrossingWord) -> int:
    """Number of crossings in a word."""
    return len(w)


def writhe(w: CrossingWord) -> int:
    """Compute the writhe (exponent sum) of a crossing word.

    The writhe is the sum of all crossing signs, measuring the
    net directional bias of the cognitive process.

    Time: O(n) where n = len(w)
    """
    return sum(c.sign.value for c in w)


def compose(w1: CrossingWord, w2: CrossingWord) -> CrossingWord:
    """Compose two crossing words by concatenation.

    Time: O(n1 + n2)
    """
    return w1 + w2


def inverse(w: CrossingWord) -> CrossingWord:
    """Compute the inverse of a crossing word.

    Reverses the word and flips all signs.
    Time: O(n)
    """
    return [Crossing(c.position, c.sign.flip()) for c in reversed(w)]


def kauffman_state_count(n: int) -> int:
    """Number of Kauffman bracket resolution states for n crossings.

    Each crossing can be resolved in 2 ways, giving 2^n total states.
    Time: O(1)
    """
    return 2 ** n


def cognitive_entropy(w: CrossingWord) -> float:
    """Compute the cognitive entropy of a crossing word.

    Entropy = log2(2^n) = n * log(2), where n is the number of crossings.
    This equals the Shannon entropy of a uniform distribution over
    the 2^n Kauffman resolution states.

    Time: O(n) (dominated by num_crossings)
    """
    n = num_crossings(w)
    if n == 0:
        return 0.0
    return math.log(kauffman_state_count(n)) / math.log(2)


def cognitive_invariant(w: CrossingWord) -> Tuple[int, float]:
    """Compute the cognitive invariant (writhe, entropy) of a crossing word.

    Time: O(n)
    """
    return (writhe(w), cognitive_entropy(w))


def is_balanced(w: CrossingWord) -> bool:
    """Check if a crossing word is balanced (writhe = 0)."""
    return writhe(w) == 0


def is_maximally_biased(w: CrossingWord) -> bool:
    """Check if |writhe| = num_crossings (all crossings same direction)."""
    return abs(writhe(w)) == num_crossings(w)


def reidemeister_ii_pair(position: int) -> CrossingWord:
    """Create a Reidemeister-II pair at the given position.

    This pair has writhe 0 and represents a topologically trivial element.
    """
    return [Crossing(position, CrossingSign.POS), Crossing(position, CrossingSign.NEG)]


def yang_baxter_lhs(position: int, sign: CrossingSign) -> CrossingWord:
    """Left side of Yang-Baxter: σ_i σ_{i+1} σ_i"""
    return [
        Crossing(position, sign),
        Crossing(position + 1, sign),
        Crossing(position, sign),
    ]


def yang_baxter_rhs(position: int, sign: CrossingSign) -> CrossingWord:
    """Right side of Yang-Baxter: σ_{i+1} σ_i σ_{i+1}"""
    return [
        Crossing(position + 1, sign),
        Crossing(position, sign),
        Crossing(position + 1, sign),
    ]


def enumerate_kauffman_states(n: int) -> List[List[bool]]:
    """Enumerate all 2^n Kauffman states for n crossings.

    Each state is a list of booleans: True = A-resolution, False = B-resolution.
    Time: O(2^n)
    """
    if n == 0:
        return [[]]
    sub_states = enumerate_kauffman_states(n - 1)
    return [[True] + s for s in sub_states] + [[False] + s for s in sub_states]


def kauffman_exponent(state: List[bool]) -> int:
    """Compute the Kauffman bracket exponent of a state.

    Exponent = 2 * #A - n, where #A is the number of A-resolutions.
    """
    n = len(state)
    num_a = sum(1 for s in state if s)
    return 2 * num_a - n


def realize_crossing_word(target_writhe: int, target_crossings: int) -> CrossingWord:
    """Construct a crossing word with the given writhe and crossing count.

    Requires: |target_writhe| <= target_crossings and same parity.
    Uses p positive crossings and q negative crossings where
    p = (n + w) / 2, q = (n - w) / 2.

    Time: O(target_crossings)
    """
    assert abs(target_writhe) <= target_crossings
    assert (target_writhe + target_crossings) % 2 == 0

    p = (target_crossings + target_writhe) // 2
    q = (target_crossings - target_writhe) // 2

    return ([Crossing(0, CrossingSign.POS)] * p +
            [Crossing(0, CrossingSign.NEG)] * q)


def jones_entropy(w: CrossingWord, a: float) -> float:
    """Compute the Jones polynomial entropy at parameter a.

    Uses non-uniform Boltzmann weights: p_σ ∝ |a^{k(σ)}|
    where k(σ) = 2·#A(σ) - n is the Kauffman exponent.

    At a = 1, this reduces to cognitive_entropy (uniform distribution).
    For |a| ≠ 1, the non-uniform weights reduce entropy.

    Time: O(2^n)
    """
    n = num_crossings(w)
    if n == 0:
        return 0.0

    states = enumerate_kauffman_states(n)
    weights = [abs(a ** kauffman_exponent(s)) for s in states]
    total = sum(weights)

    if total == 0:
        return 0.0

    probs = [w_i / total for w_i in weights]
    entropy = -sum(p * math.log(p) if p > 0 else 0 for p in probs)
    return entropy / math.log(2)  # Convert to bits
