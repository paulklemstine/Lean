#!/usr/bin/env python3
"""
Prime Gap Crossword: Core Algorithms

Type-hinted implementations of the key algorithms from the prime gap
crossword theory, including the primorial automaton, forcing pattern
search, and gap admissibility checking.
"""

from typing import Optional
from dataclasses import dataclass
from math import gcd


@dataclass
class PrimorialState:
    """State of the primorial automaton.
    
    Tracks the residue of the current prime modulo a primorial
    (product of the first k primes). Only residues coprime to the
    primorial are valid states.
    """
    residue: int
    modulus: int
    
    def is_valid(self) -> bool:
        """Check if this is a valid automaton state."""
        return gcd(self.residue, self.modulus) == 1
    
    def admissible_gaps(self, bound: int) -> list[int]:
        """Return all even gaps g with 2 ≤ g ≤ bound such that
        (residue + g) mod modulus is coprime to modulus."""
        return [g for g in range(2, bound + 1, 2)
                if gcd((self.residue + g) % self.modulus, self.modulus) == 1]
    
    def transition(self, gap: int) -> Optional['PrimorialState']:
        """Apply a gap transition. Returns None if inadmissible."""
        next_res = (self.residue + gap) % self.modulus
        if gcd(next_res, self.modulus) == 1:
            return PrimorialState(next_res, self.modulus)
        return None


def compute_admissible_residues(modulus: int) -> list[int]:
    """Compute all residues coprime to modulus.
    
    For modulus = 30, returns [1, 7, 11, 13, 17, 19, 23, 29].
    
    Args:
        modulus: The primorial modulus.
    
    Returns:
        Sorted list of coprime residues.
    """
    return sorted(r for r in range(modulus) if gcd(r, modulus) == 1)


def build_transition_matrix(modulus: int, gap_bound: int) -> dict[int, dict[int, list[int]]]:
    """Build the transition table for the primorial automaton.
    
    For each admissible state and each target state, records which
    gap values (≤ gap_bound) cause that transition.
    
    Args:
        modulus: The primorial modulus (e.g., 30).
        gap_bound: Maximum gap value to consider.
    
    Returns:
        Nested dict: transitions[from_state][to_state] = [gap_values]
    """
    states = compute_admissible_residues(modulus)
    transitions: dict[int, dict[int, list[int]]] = {}
    
    for s in states:
        transitions[s] = {}
        for g in range(2, gap_bound + 1, 2):
            target = (s + g) % modulus
            if target in states:
                if target not in transitions[s]:
                    transitions[s][target] = []
                transitions[s][target].append(g)
    
    return transitions


@dataclass
class ForcingPattern:
    """A gap word that forces the next gap value."""
    word: list[int]
    start_state: int
    forced_gap: int
    final_state: int


def find_forcing_patterns(
    modulus: int,
    word_length: int,
    gap_bound: int,
    gap_alphabet: Optional[list[int]] = None
) -> list[ForcingPattern]:
    """Search for forcing patterns in the primorial automaton.
    
    A forcing pattern is a gap word such that from the resulting state,
    there is exactly one admissible next gap within the bound.
    
    Args:
        modulus: The primorial modulus.
        word_length: Length of gap words to search.
        gap_bound: Maximum gap value.
        gap_alphabet: Allowed gap values (default: all even up to gap_bound).
    
    Returns:
        List of ForcingPattern objects.
    """
    if gap_alphabet is None:
        gap_alphabet = list(range(2, gap_bound + 1, 2))
    
    states = set(compute_admissible_residues(modulus))
    patterns: list[ForcingPattern] = []
    
    def search(state: int, word: list[int], depth: int) -> None:
        if depth == word_length:
            # Check if this state is forcing
            next_gaps = [g for g in gap_alphabet 
                        if g <= gap_bound and (state + g) % modulus in states]
            if len(next_gaps) == 1:
                # Find original start state
                s = word[0] if word else state  # placeholder
                patterns.append(ForcingPattern(
                    word=list(word),
                    start_state=0,  # will be set properly
                    forced_gap=next_gaps[0],
                    final_state=state
                ))
            return
        
        for g in gap_alphabet:
            next_state = (state + g) % modulus
            if next_state in states:
                word.append(g)
                search(next_state, word, depth + 1)
                word.pop()
    
    for start in sorted(states):
        search(start, [], 0)
        # Update start states
        for p in patterns:
            if p.start_state == 0:
                p.start_state = start
    
    return patterns


def gap_admissibility_check(
    sieve_primes: list[int],
    gap_word: list[int],
    starting_residue: int
) -> bool:
    """Check if a gap word is admissible at a given starting residue.
    
    A gap word [g₁, g₂, ..., gₖ] is admissible at residue a if:
    - a, a+g₁, a+g₁+g₂, ... are all coprime to ∏sieve_primes
    - All intermediate positions are divisible by some sieve prime
    
    Args:
        sieve_primes: List of small primes for the sieve.
        gap_word: List of gap values.
        starting_residue: Starting position modulo the primorial.
    
    Returns:
        True if the word is admissible at this residue.
    """
    modulus = 1
    for p in sieve_primes:
        modulus *= p
    
    # Check prime positions are coprime to modulus
    pos = starting_residue % modulus
    for g in gap_word:
        if gcd(pos, modulus) != 1:
            return False
        # Check interior positions are hit
        for k in range(1, g):
            interior = (pos + k) % modulus
            if all(interior % p != 0 for p in sieve_primes):
                return False  # Interior position avoids all sieve primes
        pos = (pos + g) % modulus
    
    # Check final position
    return gcd(pos, modulus) == 1


def prime_gap_mod6_state(p: int) -> int:
    """Return the mod-6 state of a prime > 3.
    
    Args:
        p: A prime number > 3.
    
    Returns:
        1 or 5 (the residue mod 6).
    
    Raises:
        ValueError: If p ≤ 3 or p mod 6 not in {1, 5}.
    """
    if p <= 3:
        raise ValueError(f"p = {p} must be > 3")
    r = p % 6
    if r not in (1, 5):
        raise ValueError(f"p = {p} has p % 6 = {r}, not prime")
    return r


def compute_gap_statistics(limit: int) -> dict[str, object]:
    """Compute comprehensive prime gap statistics up to limit.
    
    Args:
        limit: Upper bound for prime generation.
    
    Returns:
        Dictionary with gap counts, mod-6 distribution, etc.
    """
    from sympy import primerange
    
    primes = list(primerange(2, limit))
    gaps = [primes[i+1] - primes[i] for i in range(len(primes) - 1)]
    
    stats: dict[str, object] = {
        'num_primes': len(primes),
        'num_gaps': len(gaps),
        'max_gap': max(gaps),
        'gap_counts': dict(sorted(
            ((g, c) for g, c in 
             __import__('collections').Counter(gaps).items()),
            key=lambda x: x[0]
        )),
        'mod6_distribution': dict(sorted(
            ((g % 6, c) for g, c in 
             __import__('collections').Counter(
                 g for p, g in zip(primes[1:], gaps[1:]) if p > 3
             ).items()),
            key=lambda x: x[0]
        )),
    }
    
    return stats


if __name__ == "__main__":
    # Quick demonstration
    print("Admissible residues mod 30:", compute_admissible_residues(30))
    print("Admissible residues mod 210:", len(compute_admissible_residues(210)), "states")
    
    # Build transition table
    trans = build_transition_matrix(30, 30)
    for s in [1, 7, 11]:
        targets = {t: gaps for t, gaps in trans[s].items()}
        print(f"\nFrom state {s}:")
        for t in sorted(targets):
            print(f"  → {t}: gaps {targets[t]}")
    
    # Find forcing patterns
    patterns = find_forcing_patterns(30, 2, 6)
    print(f"\nForcing patterns (depth 2, bound 6): {len(patterns)}")
    for p in patterns[:5]:
        print(f"  word={p.word}, forced_gap={p.forced_gap}, final_state={p.final_state}")
