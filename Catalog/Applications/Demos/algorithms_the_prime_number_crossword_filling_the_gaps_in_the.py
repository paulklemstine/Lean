"""
Prime Gap Crossword: Algorithms for Sieve-Based Gap Analysis

This module implements the modular sieve framework for analyzing prime gap
patterns. The key idea: fix a set S of small primes and study which gap
sequences are "admissible" — compatible with the divisibility constraints
imposed by S.

Type-hinted throughout for clarity.
"""

from typing import List, Set, Tuple, Optional, Dict
from math import gcd, prod
from functools import reduce
from itertools import product as iterproduct


def is_prime(n: int) -> bool:
    """Primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def primes_up_to(n: int) -> List[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = [True] * (n + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(n**0.5) + 1):
        if sieve[i]:
            for j in range(i * i, n + 1, i):
                sieve[j] = False
    return [i for i in range(2, n + 1) if sieve[i]]


def prime_gaps(limit: int) -> List[int]:
    """Compute the prime gap sequence up to limit."""
    ps = primes_up_to(limit)
    return [ps[i + 1] - ps[i] for i in range(len(ps) - 1)]


def gap_word_positions(gaps: List[int]) -> List[int]:
    """Cumulative sums starting from 0."""
    positions = [0]
    for g in gaps:
        positions.append(positions[-1] + g)
    return positions


def interior_set(gaps: List[int]) -> Set[int]:
    """All integers strictly between consecutive positions."""
    positions = gap_word_positions(gaps)
    result: Set[int] = set()
    for i in range(len(positions) - 1):
        for j in range(positions[i] + 1, positions[i + 1]):
            result.add(j)
    return result


def avoids_primes(S: Set[int], n: int) -> bool:
    """Check if n avoids all primes in S."""
    return all(n % q != 0 for q in S)


def hit_by_primes(S: Set[int], n: int) -> bool:
    """Check if n is divisible by at least one prime in S."""
    return any(n % q == 0 for q in S)


def admissible_at(S: Set[int], gaps: List[int], a: int) -> bool:
    """Check if gap word is S-admissible at residue a."""
    positions = gap_word_positions(gaps)
    interior = interior_set(gaps)

    # All positions must avoid S
    for t in positions:
        if not avoids_primes(S, a + t):
            return False

    # All interior points must be hit by S
    for u in interior:
        if not hit_by_primes(S, a + u):
            return False

    return True


def admissible_residues(S: Set[int], gaps: List[int], M: int) -> List[int]:
    """Find all admissible residues in [0, M)."""
    return [a for a in range(M) if admissible_at(S, gaps, a)]


def primorial(S: Set[int]) -> int:
    """Product of all primes in S."""
    return reduce(lambda x, y: x * y, S, 1)


def admissible_next_gaps(
    S: Set[int], w: List[int], B: int, M: Optional[int] = None
) -> List[int]:
    """Find all admissible next gaps for word w over sieve S with bound B."""
    if M is None:
        M = primorial(S)
    return [
        g for g in range(1, B + 1)
        if len(admissible_residues(S, w + [g], M)) > 0
    ]


def is_forcing(S: Set[int], w: List[int], B: int,
               M: Optional[int] = None) -> Tuple[bool, Optional[int]]:
    """Check if w is forcing over S with bound B.
    Returns (is_forcing, forced_gap) or (False, None)."""
    next_gaps = admissible_next_gaps(S, w, B, M)
    if len(next_gaps) == 1:
        return True, next_gaps[0]
    return False, None


def find_forcing_patterns(
    S: Set[int], B: int, max_length: int, M: Optional[int] = None
) -> List[Tuple[List[int], int]]:
    """Find all forcing patterns up to given length."""
    if M is None:
        M = primorial(S)
    results: List[Tuple[List[int], int]] = []

    def search(w: List[int], depth: int) -> None:
        if depth > max_length:
            return
        forced, g = is_forcing(S, w, B, M)
        if forced and g is not None:
            results.append((w.copy(), g))
        # Extend with all admissible gaps
        for g in admissible_next_gaps(S, w, B, M):
            search(w + [g], depth + 1)

    # Start with each possible first gap
    for g in range(1, B + 1):
        if len(admissible_residues(S, [g], M)) > 0:
            search([g], 1)

    return results


def gap_automaton_transition(
    S: Set[int], M: int, state: Set[int], gap: int
) -> Set[int]:
    """Transition function: given current admissible residues and a gap,
    compute new admissible residues."""
    new_state: Set[int] = set()
    for a in state:
        new_a = (a + gap) % M
        # Check: a+gap position avoids all S, interior points hit by S
        if avoids_primes(S, new_a):
            # Check interior between a and a+gap
            all_interior_hit = all(
                hit_by_primes(S, (a + k) % M) for k in range(1, gap)
            )
            if all_interior_hit:
                new_state.add(new_a)
    return new_state


def gap_pattern_statistics(
    limit: int, pattern_length: int = 3
) -> Dict[Tuple[int, ...], int]:
    """Count occurrences of gap patterns of given length."""
    gaps = prime_gaps(limit)
    counts: Dict[Tuple[int, ...], int] = {}
    for i in range(len(gaps) - pattern_length + 1):
        pattern = tuple(gaps[i:i + pattern_length])
        counts[pattern] = counts.get(pattern, 0) + 1
    return counts


def conditional_gap_probabilities(
    limit: int, context_length: int = 1
) -> Dict[Tuple[int, ...], Dict[int, float]]:
    """Compute P(next gap = g | previous context gaps)."""
    gaps = prime_gaps(limit)
    context_counts: Dict[Tuple[int, ...], Dict[int, int]] = {}

    for i in range(context_length, len(gaps)):
        context = tuple(gaps[i - context_length:i])
        next_gap = gaps[i]
        if context not in context_counts:
            context_counts[context] = {}
        context_counts[context][next_gap] = \
            context_counts[context].get(next_gap, 0) + 1

    result: Dict[Tuple[int, ...], Dict[int, float]] = {}
    for context, counts in context_counts.items():
        total = sum(counts.values())
        result[context] = {g: c / total for g, c in sorted(counts.items())}

    return result


def forcing_fraction(
    S: Set[int], B: int, max_length: int
) -> float:
    """Fraction of gap words up to max_length that are forcing."""
    M = primorial(S)
    total = 0
    forcing_count = 0

    def count(w: List[int], depth: int) -> None:
        nonlocal total, forcing_count
        if depth > max_length:
            return
        if len(w) > 0:
            total += 1
            forced, _ = is_forcing(S, w, B, M)
            if forced:
                forcing_count += 1
        for g in admissible_next_gaps(S, w, B, M):
            count(w + [g], depth + 1)

    for g in range(1, B + 1):
        if len(admissible_residues(S, [g], M)) > 0:
            count([g], 1)

    return forcing_count / total if total > 0 else 0.0
