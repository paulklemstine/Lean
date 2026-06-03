#!/usr/bin/env python3
"""
Prime Gap Crossword: Core Algorithms

Type-hinted implementations of the key algorithms from the prime gap
transition theory.
"""

from typing import Optional
from collections import defaultdict
from math import gcd, log


def sieve_of_eratosthenes(limit: int) -> list[int]:
    """Return all primes up to limit using the Sieve of Eratosthenes.
    
    Time: O(n log log n), Space: O(n)
    """
    if limit < 2:
        return []
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]


def prime_gap_sequence(limit: int) -> list[int]:
    """Compute the prime gap sequence g(n) = p(n+1) - p(n).
    
    Returns gaps for all consecutive primes up to limit.
    """
    primes = sieve_of_eratosthenes(limit)
    return [primes[i+1] - primes[i] for i in range(len(primes) - 1)]


def mod6_state_sequence(primes: list[int]) -> list[int]:
    """Compute the mod-6 state sequence for primes > 3.
    
    Each prime > 3 maps to its residue mod 6 (either 1 or 5).
    The gap sequence uniquely determines this sequence given the
    first state.
    """
    return [p % 6 for p in primes if p > 3]


def mod6_transition(state: int, gap: int) -> int:
    """Compute the next mod-6 state given current state and gap.
    
    Args:
        state: Current state (1 or 5)
        gap: Prime gap (must be even for primes > 3)
    
    Returns:
        Next state (1 or 5)
    """
    return (state + gap) % 6


def primorial_sieve_admissible(
    residue: int,
    modulus: int,
    gap: int
) -> bool:
    """Check if a gap is admissible from a given residue mod modulus.
    
    A gap g from residue r mod M is admissible if:
    1. (r + g) mod M is coprime to M (the target is in a valid state)
    2. For all 0 < k < g, (r + k) mod M is NOT coprime to M
       (all intermediate positions are sieved out)
    
    Condition 2 is the "forcing" condition — it ensures the gap cannot
    be shortened.
    """
    target = (residue + gap) % modulus
    if gcd(target, modulus) != 1:
        return False
    # Check intermediate positions are all composite (hit by sieve)
    for k in range(1, gap):
        if gcd((residue + k) % modulus, modulus) == 1:
            return False  # Could stop at this position instead
    return True


def admissible_gaps_from(
    residue: int,
    modulus: int,
    max_gap: int
) -> list[int]:
    """Find all admissible gaps from a residue class mod modulus.
    
    An admissible gap is one where the target residue is coprime to
    modulus and all intermediate residues are not coprime.
    """
    result = []
    for g in range(1, max_gap + 1):
        if primorial_sieve_admissible(residue, modulus, g):
            result.append(g)
    return result


def gap_transition_graph(
    modulus: int,
    max_gap: int
) -> dict[int, list[tuple[int, int]]]:
    """Build the gap transition graph for a given modulus.
    
    Nodes: residues coprime to modulus
    Edges: (source, gap, target) where gap is admissible
    
    Returns: dict mapping source residue to list of (gap, target) pairs
    """
    # Find all residues coprime to modulus
    units = [r for r in range(modulus) if gcd(r, modulus) == 1]
    
    graph: dict[int, list[tuple[int, int]]] = {u: [] for u in units}
    
    for r in units:
        for g in range(1, max_gap + 1):
            target = (r + g) % modulus
            if gcd(target, modulus) == 1:
                graph[r].append((g, target))
    
    return graph


def forcing_patterns(
    modulus: int,
    max_gap: int,
    max_length: int
) -> list[tuple[list[int], int]]:
    """Find forcing patterns: gap words where the next gap is unique.
    
    A gap word w = [g1, g2, ..., gk] is forcing with bound B if,
    starting from any admissible residue r mod modulus such that
    the word is admissible at r, there is exactly one admissible
    next gap g ≤ B.
    
    Returns: list of (word, forced_gap) pairs
    """
    units = [r for r in range(modulus) if gcd(r, modulus) == 1]
    results = []
    
    def search(word: list[int], depth: int) -> None:
        if depth > max_length:
            return
        
        # For each starting residue, compute the ending residue
        # and check if the next gap is forced
        ending_residues: set[int] = set()
        for r in units:
            # Check if word is admissible starting from r
            pos = r
            valid = True
            for g in word:
                next_pos = (pos + g) % modulus
                if gcd(next_pos, modulus) != 1:
                    valid = False
                    break
                pos = next_pos
            if valid:
                ending_residues.add(pos)
        
        if not ending_residues:
            return
        
        # Check if all ending residues force the same next gap
        forced_gap: Optional[int] = None
        for end_r in ending_residues:
            admissible = admissible_gaps_from(end_r, modulus, max_gap)
            if len(admissible) == 1:
                if forced_gap is None:
                    forced_gap = admissible[0]
                elif forced_gap != admissible[0]:
                    forced_gap = None
                    break
            else:
                forced_gap = None
                break
        
        if forced_gap is not None and len(word) > 0:
            results.append((list(word), forced_gap))
        
        # Extend the word
        for g in range(2, max_gap + 1, 2):  # Only even gaps for p > 3
            word.append(g)
            search(word, depth + 1)
            word.pop()
    
    search([], 0)
    return results


def hardy_littlewood_singular_series(gap: int) -> float:
    """Compute the Hardy-Littlewood singular series S(g) for a gap g.
    
    S(g) = 2 * C₂ * ∏_{p|g, p≥3} (p-1)/(p-2)
    
    where C₂ ≈ 0.6601618 is the twin prime constant.
    """
    if gap == 0 or gap % 2 != 0:
        return 0.0
    
    C2 = 0.6601618158468
    result = 2.0 * C2
    
    # Find prime factors of gap
    n = gap
    p = 3
    while p * p <= n:
        if n % p == 0:
            result *= (p - 1) / (p - 2)
            while n % p == 0:
                n //= p
        p += 2
    if n > 2:
        result *= (n - 1) / (n - 2)
    
    return result


def predicted_gap_count(
    gap: int,
    N: int,
    avg_log_p: float
) -> float:
    """Predict the number of times gap g appears among primes up to N.
    
    Based on Hardy-Littlewood: count ≈ S(g) * N / (gap * (log N)²)
    """
    S = hardy_littlewood_singular_series(gap)
    return S * N / (gap * avg_log_p * avg_log_p)


if __name__ == "__main__":
    # Quick demo
    print("Prime gaps up to 100:", prime_gap_sequence(100))
    print("\nMod-6 states:", mod6_state_sequence(sieve_of_eratosthenes(50)))
    
    print("\nAdmissible gaps from residue 1 mod 6 (max gap 12):")
    print(admissible_gaps_from(1, 6, 12))
    
    print("\nAdmissible gaps from residue 5 mod 6 (max gap 12):")
    print(admissible_gaps_from(5, 6, 12))
    
    print("\nGap transition graph mod 6 (max gap 12):")
    graph = gap_transition_graph(6, 12)
    for r, edges in sorted(graph.items()):
        if gcd(r, 6) == 1:
            print(f"  {r}: {edges}")
    
    print("\nForcing patterns mod 6 (max gap 6, length 3):")
    for word, forced in forcing_patterns(6, 6, 3):
        print(f"  {word} -> forced gap {forced}")
    
    print("\nHardy-Littlewood singular series:")
    for g in [2, 4, 6, 8, 10, 12]:
        print(f"  S({g}) = {hardy_littlewood_singular_series(g):.6f}")
