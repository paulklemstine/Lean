"""
algorithms.py — Implementation of sl₂ crystal operators on binary words
via bracket matching, arising in tropical Brill-Noether theory.

Implements:
- Bracket matching algorithm for binary words
- Crystal operators e (raising) and f (lowering)
- Weight, epsilon, phi computations
- CDPR path validation
"""

from typing import Optional, List, Tuple
from dataclasses import dataclass
from enum import Enum


class Step(Enum):
    """A binary step: UP (+1) or DOWN (-1)."""
    UP = 1
    DOWN = -1


@dataclass
class BracketMatchResult:
    """Result of bracket matching on a binary word."""
    epsilon: int          # Number of unmatched DOWN steps
    phi: int              # Number of unmatched UP steps
    rightmost_down: Optional[int]   # Position of rightmost unmatched DOWN
    leftmost_up: Optional[int]      # Position of leftmost unmatched UP


def bracket_match(word: List[Step]) -> BracketMatchResult:
    """
    Perform left-to-right bracket matching on a binary word.

    Each DOWN step matches with the nearest unmatched UP step to its left.
    Returns counts and positions of unmatched steps.

    Time complexity: O(n) where n = len(word)
    Space complexity: O(1) (only counters, no explicit stack)

    >>> bracket_match([Step.UP, Step.DOWN, Step.DOWN, Step.UP])
    BracketMatchResult(epsilon=1, phi=1, rightmost_down=2, leftmost_up=3)
    """
    up_count = 0          # Current unmatched UP count (stack size)
    down_count = 0        # Total unmatched DOWN count
    rightmost_down = None
    leftmost_up = None

    for i, step in enumerate(word):
        if step == Step.UP:
            if up_count == 0:
                leftmost_up = i    # New leftmost unmatched UP
            up_count += 1
        else:  # Step.DOWN
            if up_count > 0:
                up_count -= 1
                if up_count == 0:
                    leftmost_up = None  # Stack drained
            else:
                down_count += 1
                rightmost_down = i

    return BracketMatchResult(
        epsilon=down_count,
        phi=up_count,
        rightmost_down=rightmost_down,
        leftmost_up=leftmost_up
    )


def weight(word: List[Step]) -> int:
    """
    Weight of a binary word: sum of step values.

    In crystal theory, this is the weight of the corresponding
    representation-theoretic element.

    >>> weight([Step.UP, Step.DOWN, Step.UP])
    1
    """
    return sum(s.value for s in word)


def epsilon(word: List[Step]) -> int:
    """Number of unmatched DOWN steps (ε)."""
    return bracket_match(word).epsilon


def phi(word: List[Step]) -> int:
    """Number of unmatched UP steps (φ)."""
    return bracket_match(word).phi


def crystal_e(word: List[Step]) -> Optional[List[Step]]:
    """
    Crystal raising operator (ẽ): changes the rightmost unmatched DOWN to UP.

    Returns None if ε(word) = 0 (no unmatched DOWN steps).

    Time complexity: O(n)
    Space complexity: O(n) for the new word

    >>> crystal_e([Step.UP, Step.DOWN, Step.DOWN])
    [<Step.UP: 1>, <Step.UP: 1>, <Step.DOWN: -1>]
    """
    result = bracket_match(word)
    if result.rightmost_down is None:
        return None
    new_word = word.copy()
    new_word[result.rightmost_down] = Step.UP
    return new_word


def crystal_f(word: List[Step]) -> Optional[List[Step]]:
    """
    Crystal lowering operator (f̃): changes the leftmost unmatched UP to DOWN.

    Returns None if φ(word) = 0 (no unmatched UP steps).

    Time complexity: O(n)
    Space complexity: O(n) for the new word

    >>> crystal_f([Step.UP, Step.DOWN, Step.UP])
    [<Step.UP: 1>, <Step.DOWN: -1>, <Step.DOWN: -1>]
    """
    result = bracket_match(word)
    if result.leftmost_up is None:
        return None
    new_word = word.copy()
    new_word[result.leftmost_up] = Step.DOWN
    return new_word


def crystal_string(word: List[Step], direction: str = "down") -> List[List[Step]]:
    """
    Compute the crystal string through a word.

    If direction="down", repeatedly apply f until None.
    If direction="up", repeatedly apply e until None.

    Returns the sequence of words in the string.

    >>> len(crystal_string([Step.UP, Step.UP, Step.DOWN]))
    2
    """
    string = [word]
    op = crystal_f if direction == "down" else crystal_e
    current = word
    while True:
        next_word = op(current)
        if next_word is None:
            break
        string.append(next_word)
        current = next_word
    return string


def highest_weight_element(word: List[Step]) -> List[Step]:
    """
    Find the highest-weight element in the connected component of word.

    Repeatedly applies ẽ until reaching the top of the crystal string.

    >>> highest_weight_element([Step.DOWN, Step.UP, Step.DOWN])
    [<Step.UP: 1>, <Step.DOWN: -1>, <Step.DOWN: -1>]
    """
    current = word
    while True:
        next_word = crystal_e(current)
        if next_word is None:
            return current
        current = next_word


def connected_component(word: List[Step]) -> List[List[Step]]:
    """
    Compute the full connected component containing the given word.

    First finds the highest-weight element, then applies f repeatedly.

    Returns all words in the component, from highest to lowest weight.
    """
    hw = highest_weight_element(word)
    return crystal_string(hw, direction="down")


def is_valid_cdpr_path(word: List[Step], start_height: int) -> bool:
    """
    Check if a binary word forms a valid CDPR path starting at the given height.

    A CDPR path must stay non-negative at all intermediate points.

    In tropical Brill-Noether theory, these paths encode reduced divisors
    on chains of loops.

    >>> is_valid_cdpr_path([Step.UP, Step.DOWN, Step.DOWN], 1)
    True
    >>> is_valid_cdpr_path([Step.DOWN, Step.DOWN, Step.UP], 0)
    False
    """
    height = start_height
    for step in word:
        height += step.value
        if height < 0:
            return False
    return True


def enumerate_cdpr_paths(g: int, start: int) -> List[List[Step]]:
    """
    Enumerate all valid CDPR paths of length g starting at height start.

    >>> len(enumerate_cdpr_paths(3, 1))
    3
    """
    if g == 0:
        return [[]]
    paths = []
    for suffix in enumerate_cdpr_paths(g - 1, start + 1):
        paths.append([Step.UP] + suffix)
    if start > 0:
        for suffix in enumerate_cdpr_paths(g - 1, start - 1):
            paths.append([Step.DOWN] + suffix)
    return paths


def verify_string_identity(word: List[Step]) -> bool:
    """Verify the string identity: φ(w) - ε(w) = wt(w)."""
    return phi(word) - epsilon(word) == weight(word)


def verify_inverse_property(word: List[Step]) -> bool:
    """Verify the inverse property: e(w) = q ⟹ f(q) = w."""
    q = crystal_e(word)
    if q is not None:
        w_back = crystal_f(q)
        if w_back != word:
            return False
    q = crystal_f(word)
    if q is not None:
        w_back = crystal_e(q)
        if w_back != word:
            return False
    return True


def word_to_string(word: List[Step]) -> str:
    """Convert a word to a readable string."""
    return "".join("+" if s == Step.UP else "-" for s in word)


def string_to_word(s: str) -> List[Step]:
    """Parse a string like '+-+-' into a word."""
    return [Step.UP if c == "+" else Step.DOWN for c in s]


if __name__ == "__main__":
    # Example usage
    w = string_to_word("+-+--+")
    print(f"Word: {word_to_string(w)}")
    print(f"Weight: {weight(w)}")
    print(f"ε = {epsilon(w)}, φ = {phi(w)}")
    print(f"String identity: φ - ε = {phi(w) - epsilon(w)} = wt = {weight(w)}")

    e_result = crystal_e(w)
    print(f"ẽ(w) = {word_to_string(e_result) if e_result else 'None'}")

    f_result = crystal_f(w)
    print(f"f̃(w) = {word_to_string(f_result) if f_result else 'None'}")

    comp = connected_component(w)
    print(f"\nConnected component ({len(comp)} elements):")
    for elem in comp:
        bm = bracket_match(elem)
        print(f"  {word_to_string(elem)}  wt={weight(elem):+d}  ε={bm.epsilon}  φ={bm.phi}")
