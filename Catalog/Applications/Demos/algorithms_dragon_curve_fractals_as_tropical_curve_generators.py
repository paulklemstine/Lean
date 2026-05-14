#!/usr/bin/env python3
"""
Algorithms for Tropical Substitution Fractals

Implements the core algorithms from the research paper:
1. Membership testing via tropical potential evaluation
2. State enumeration via binary tree traversal
3. Dragon turn word generation
4. Tropical potential computation with memoization

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import Tuple, Set, List, Optional, Dict
from functools import lru_cache

# Type aliases
State = Tuple[int, int, int]  # (x, y, direction)

# Direction displacements: 0=East, 1=North, 2=West, 3=South
DX = (1, 0, -1, 0)
DY = (0, 1, 0, -1)


# ==============================================================================
# Core Step Functions
# ==============================================================================

def step_L(s: State) -> State:
    """
    Left step: advance in current direction, then turn counterclockwise.

    Time: O(1), Space: O(1)

    >>> step_L((0, 0, 0))  # At origin facing East
    (1, 0, 1)
    """
    x, y, d = s
    return (x + DX[d], y + DY[d], (d + 1) % 4)


def step_R(s: State) -> State:
    """
    Right step: advance in current direction, then turn clockwise.

    Time: O(1), Space: O(1)

    >>> step_R((0, 0, 0))  # At origin facing East
    (1, 0, 3)
    """
    x, y, d = s
    return (x + DX[d], y + DY[d], (d + 3) % 4)


def step_L_inv(s: State) -> State:
    """
    Inverse of step_L. Given an output state, recovers the unique input.

    Satisfies: step_L(step_L_inv(s)) == s and step_L_inv(step_L(s)) == s

    Time: O(1), Space: O(1)

    >>> step_L(step_L_inv((3, 2, 1)))
    (3, 2, 1)
    """
    x, y, d = s
    dp = (d + 3) % 4
    return (x - DX[dp], y - DY[dp], dp)


def step_R_inv(s: State) -> State:
    """
    Inverse of step_R. Given an output state, recovers the unique input.

    Time: O(1), Space: O(1)

    >>> step_R(step_R_inv((3, 2, 1)))
    (3, 2, 1)
    """
    x, y, d = s
    dp = (d + 1) % 4
    return (x - DX[dp], y - DY[dp], dp)


# ==============================================================================
# Membership Testing
# ==============================================================================

def is_reachable(s: State, n: int) -> bool:
    """
    Test if state s is reachable in exactly n steps.

    Uses the tropical potential characterization:
    s ∈ reachable(n) iff tropPot(n, s) = 0.

    Implemented via recursive backtracking through inverse step maps.

    Time: O(2^n) worst case, but typically much faster due to early termination.
    Space: O(n) stack depth.

    >>> is_reachable((0, 0, 0), 0)
    True
    >>> is_reachable((1, 0, 1), 1)  # step_L from origin
    True
    >>> is_reachable((1, 0, 3), 1)  # step_R from origin
    True
    >>> is_reachable((0, 0, 1), 1)  # not reachable in 1 step
    False
    """
    if n == 0:
        return s == (0, 0, 0)
    return is_reachable(step_L_inv(s), n - 1) or is_reachable(step_R_inv(s), n - 1)


def is_reachable_memo(s: State, n: int, memo: Optional[Dict] = None) -> bool:
    """
    Memoized version of is_reachable.

    Uses dynamic programming to avoid recomputation.
    Particularly efficient when testing many states at the same level.

    Time: O(|reachable(n)|) amortized per query after warmup.
    Space: O(sum_{k=0}^{n} |reachable(k)|) for memo table.

    >>> is_reachable_memo((0, 0, 0), 0)
    True
    >>> is_reachable_memo((1, 0, 1), 1)
    True
    """
    if memo is None:
        memo = {}

    key = (s, n)
    if key in memo:
        return memo[key]

    if n == 0:
        result = s == (0, 0, 0)
    else:
        result = (is_reachable_memo(step_L_inv(s), n - 1, memo) or
                  is_reachable_memo(step_R_inv(s), n - 1, memo))

    memo[key] = result
    return result


# ==============================================================================
# State Enumeration
# ==============================================================================

def enumerate_reachable(n: int) -> Set[State]:
    """
    Enumerate all states reachable in exactly n steps.

    Uses forward iteration (binary tree traversal).

    Time: O(2^n), Space: O(2^n)

    >>> sorted(enumerate_reachable(0))
    [(0, 0, 0)]
    >>> sorted(enumerate_reachable(1))
    [(1, 0, 1), (1, 0, 3)]
    """
    if n == 0:
        return {(0, 0, 0)}

    prev = enumerate_reachable(n - 1)
    result = set()
    for s in prev:
        result.add(step_L(s))
        result.add(step_R(s))
    return result


def enumerate_reachable_iterative(n: int) -> Set[State]:
    """
    Iterative version of enumerate_reachable, avoiding deep recursion.

    Time: O(2^n), Space: O(2^n)

    >>> sorted(enumerate_reachable_iterative(2))
    [(1, -1, 0), (1, -1, 2), (1, 1, 0), (1, 1, 2)]
    """
    current = {(0, 0, 0)}
    for _ in range(n):
        next_set = set()
        for s in current:
            next_set.add(step_L(s))
            next_set.add(step_R(s))
        current = next_set
    return current


# ==============================================================================
# Tropical Potential
# ==============================================================================

def trop_pot(n: int, s: State) -> int:
    """
    Evaluate the tropical potential at stage n.

    tropPot(0, s) = 0 if s is the initial state, 1 otherwise.
    tropPot(n+1, s) = min(tropPot(n, stepLInv(s)), tropPot(n, stepRInv(s)))

    Returns 0 if s ∈ reachable(n), 1 otherwise.

    Time: O(2^n), Space: O(n)

    >>> trop_pot(0, (0, 0, 0))
    0
    >>> trop_pot(0, (1, 0, 0))
    1
    >>> trop_pot(1, (1, 0, 1))
    0
    """
    if n == 0:
        return 0 if s == (0, 0, 0) else 1
    return min(trop_pot(n - 1, step_L_inv(s)),
               trop_pot(n - 1, step_R_inv(s)))


@lru_cache(maxsize=None)
def trop_pot_cached(n: int, s: State) -> int:
    """
    Cached version of trop_pot for repeated evaluations.

    >>> trop_pot_cached(3, (0, 1, 3))
    0
    """
    if n == 0:
        return 0 if s == (0, 0, 0) else 1
    return min(trop_pot_cached(n - 1, step_L_inv(s)),
               trop_pot_cached(n - 1, step_R_inv(s)))


# ==============================================================================
# Dragon Turn Words
# ==============================================================================

def dragon_word(n: int) -> List[bool]:
    """
    Generate the dragon turn word at stage n.

    dragonWord(0) = []
    dragonWord(n+1) = dragonWord(n) ++ [True] ++ reverse(complement(dragonWord(n)))

    True = right turn, False = left turn.
    Length = 2^n - 1.

    Time: O(2^n), Space: O(2^n)

    >>> dragon_word(0)
    []
    >>> dragon_word(1)
    [True]
    >>> dragon_word(2)
    [True, True, False]
    >>> dragon_word(3)
    [True, True, False, True, True, False, False]
    """
    if n == 0:
        return []
    prev = dragon_word(n - 1)
    return prev + [True] + [not b for b in reversed(prev)]


def dragon_word_iterative(n: int) -> List[bool]:
    """
    Iterative generation of dragon turn words.

    More memory-efficient for large n.

    >>> dragon_word_iterative(3)
    [True, True, False, True, True, False, False]
    """
    word = []
    for _ in range(n):
        word = word + [True] + [not b for b in reversed(word)]
    return word


def is_dragon_subword(w: List[bool], max_n: int = 20) -> bool:
    """
    Check if w appears as a contiguous subword of any dragon word up to stage max_n.

    >>> is_dragon_subword([True])
    True
    >>> is_dragon_subword([False, False, False, False])  # 4 consecutive lefts
    False
    """
    k = len(w)
    w_tuple = tuple(w)
    for n in range(1, max_n + 1):
        dw = dragon_word(n)
        if len(dw) >= k:
            for i in range(len(dw) - k + 1):
                if tuple(dw[i:i + k]) == w_tuple:
                    return True
        if len(dw) > 10 * k:  # early termination if word is much longer
            break
    return False


# ==============================================================================
# Self-Contained Tests
# ==============================================================================

def run_tests():
    """Run all algorithm tests."""
    print("Running algorithm tests...")

    # Test inverse properties
    for d in range(4):
        for x in range(-3, 4):
            for y in range(-3, 4):
                s = (x, y, d)
                assert step_L(step_L_inv(s)) == s, f"stepL ∘ stepLInv ≠ id at {s}"
                assert step_L_inv(step_L(s)) == s, f"stepLInv ∘ stepL ≠ id at {s}"
                assert step_R(step_R_inv(s)) == s, f"stepR ∘ stepRInv ≠ id at {s}"
                assert step_R_inv(step_R(s)) == s, f"stepRInv ∘ stepR ≠ id at {s}"
    print("  ✓ Inverse properties verified")

    # Test reachable = zero set of tropPot
    for n in range(8):
        reachable = enumerate_reachable(n)
        for s in reachable:
            assert trop_pot(n, s) == 0, f"tropPot({n}, {s}) ≠ 0 but {s} ∈ reachable"
        # Sample non-reachable states
        for x in range(-10, 11):
            for y in range(-10, 11):
                for d in range(4):
                    s = (x, y, d)
                    if s not in reachable:
                        assert trop_pot(n, s) == 1, f"tropPot({n}, {s}) = 0 but {s} ∉ reachable"
    print("  ✓ Theorem A (reachable = zero set) verified for n=0..7")

    # Test self-similarity
    for n in range(8):
        R_n = enumerate_reachable(n)
        R_n1 = enumerate_reachable(n + 1)
        L_img = {step_L(s) for s in R_n}
        R_img = {step_R(s) for s in R_n}
        assert R_n1 == L_img | R_img, f"Self-similarity fails at n={n}"
    print("  ✓ Theorem B (self-similarity) verified for n=0..7")

    # Test cardinality growth (with collisions for n >= 3)
    for n in range(12):
        R = enumerate_reachable(n)
        assert len(R) <= 2 ** n, f"|reachable({n})| = {len(R)} > {2**n}"
    print("  ✓ |reachable(n)| ≤ 2^n verified for n=0..11")

    # Test dragon word starts with True
    for n in range(1, 15):
        w = dragon_word(n)
        assert w[0] == True, f"dragonWord({n}) starts with {w[0]}"
    print("  ✓ Dragon words start with True for n=1..14")

    # Test non-universality
    assert not is_dragon_subword([False, False, False, False])
    print("  ✓ [L,L,L,L] is not a dragon subword")

    print("\nAll tests passed! ✓")


if __name__ == "__main__":
    run_tests()
