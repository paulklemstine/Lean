"""
Prime Gap Crossword: Algorithms for gap analysis, sieve constraints, and forcing patterns.

This module implements the core algorithms from the research paper:
1. Prime sieve and gap computation
2. Modular constraint checking
3. Forcing pattern detection
4. Residue exclusion chain analysis
"""

from typing import List, Tuple, Dict, Set, Optional
from math import gcd, log, prod
from itertools import product as cartesian_product


def sieve_of_eratosthenes(n: int) -> List[int]:
    """Return all primes up to n using the Sieve of Eratosthenes."""
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i * i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def prime_gaps(primes: List[int]) -> List[int]:
    """Compute consecutive prime gaps from a list of primes."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def gap_mod6_classify(gaps: List[int]) -> Dict[int, int]:
    """Classify gaps by their residue mod 6. Returns counts for residues 0, 2, 4."""
    counts = {0: 0, 2: 0, 4: 0}
    for g in gaps:
        r = g % 6
        if r in counts:
            counts[r] += 1
    return counts


def is_coprime(a: int, b: int) -> bool:
    """Check if a and b are coprime."""
    return gcd(a, b) == 1


def coprime_residues(q: int) -> List[int]:
    """Return residues in [0, q) coprime to q."""
    return [r for r in range(q) if gcd(r, q) == 1]


def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def primorial(n: int) -> int:
    """Compute the primorial of n: product of all primes up to n."""
    primes = sieve_of_eratosthenes(n)
    return prod(primes) if primes else 1


class GapConstraintSystem:
    """
    A gap constraint system over modulus M with sieve primes S.
    
    Tracks which gap residues mod M are admissible from each starting residue.
    """
    
    def __init__(self, sieve_primes: List[int]):
        """Initialize with a list of sieve primes."""
        self.sieve_primes = sorted(sieve_primes)
        self.modulus = prod(sieve_primes)
        self._admissible_residues = self._compute_admissible()
    
    def _compute_admissible(self) -> Set[int]:
        """Compute residues mod M that avoid all sieve primes."""
        return {r for r in range(self.modulus) 
                if all(r % p != 0 for p in self.sieve_primes)}
    
    def admissible_gaps(self, start_residue: int, max_gap: int) -> List[int]:
        """Return admissible even gaps from a given starting residue."""
        result = []
        for g in range(2, max_gap + 1, 2):
            target = (start_residue + g) % self.modulus
            if target in self._admissible_residues:
                # Check all intermediate values are hit by some sieve prime
                all_composite = True
                for k in range(1, g):
                    mid = (start_residue + k) % self.modulus
                    if mid in self._admissible_residues:
                        all_composite = False
                        break
                if all_composite:
                    result.append(g)
        return result
    
    def is_forcing(self, gap_history: List[int], max_gap: int) -> Optional[int]:
        """
        Check if a gap history forces the next gap.
        
        Returns the forced gap if unique, None otherwise.
        """
        valid_next_gaps: Set[int] = set()
        
        for start in self._admissible_residues:
            # Check if gap_history is admissible from this start
            pos = start
            admissible = True
            for g in gap_history:
                next_pos = (pos + g) % self.modulus
                if next_pos not in self._admissible_residues:
                    admissible = False
                    break
                pos = next_pos
            
            if admissible:
                # Find admissible next gaps from pos
                for g in range(2, max_gap + 1, 2):
                    next_pos = (pos + g) % self.modulus
                    if next_pos in self._admissible_residues:
                        valid_next_gaps.add(g)
        
        if len(valid_next_gaps) == 1:
            return valid_next_gaps.pop()
        return None


class ResidueExclusionChain:
    """
    Tracks how successive sieve primes eliminate gap candidates.
    """
    
    def __init__(self, primes: List[int]):
        """Initialize with a sequence of sieve primes."""
        self.primes = sorted(primes)
    
    def survival_count(self, k: int) -> int:
        """
        Number of residues surviving after sieving by the first k primes.
        For k primes p_1, ..., p_k, this is ∏(p_i - 1).
        """
        return prod(p - 1 for p in self.primes[:k])
    
    def total_count(self, k: int) -> int:
        """Total number of residues mod ∏p_i for first k primes."""
        return prod(self.primes[:k])
    
    def survival_fraction(self, k: int) -> float:
        """Fraction of residues surviving: ∏(1 - 1/p_i)."""
        return self.survival_count(k) / self.total_count(k)
    
    def display(self) -> List[Dict[str, float]]:
        """Return a table of survival statistics."""
        result = []
        for k in range(1, len(self.primes) + 1):
            result.append({
                'primes_used': self.primes[:k],
                'modulus': self.total_count(k),
                'survivors': self.survival_count(k),
                'fraction': self.survival_fraction(k),
            })
        return result


def find_forcing_patterns(sieve_primes: List[int], max_gap: int, 
                          history_length: int) -> List[Tuple[List[int], int]]:
    """
    Find all forcing patterns of given length over a sieve set.
    
    Returns list of (gap_history, forced_next_gap) pairs.
    """
    gcs = GapConstraintSystem(sieve_primes)
    forcing = []
    
    # Generate candidate gap histories
    even_gaps = list(range(2, max_gap + 1, 2))
    
    for history in cartesian_product(even_gaps, repeat=history_length):
        history_list = list(history)
        forced = gcs.is_forcing(history_list, max_gap)
        if forced is not None:
            forcing.append((history_list, forced))
    
    return forcing


def verify_gap_mod6(bound: int) -> Dict[str, any]:
    """
    Verify the gap mod 6 constraint for all primes up to bound.
    Returns statistics on gap residues mod 6.
    """
    primes = sieve_of_eratosthenes(bound)
    gaps = prime_gaps(primes)
    
    # Skip the first gap (between 2 and 3) and gaps involving p ≤ 3
    large_gaps = []
    for i, g in enumerate(gaps):
        if primes[i] > 3:
            large_gaps.append(g)
    
    mod6_counts = gap_mod6_classify(large_gaps)
    total = sum(mod6_counts.values())
    
    violations = sum(1 for g in large_gaps if g % 6 not in {0, 2, 4})
    
    return {
        'bound': bound,
        'total_gaps': total,
        'mod6_counts': mod6_counts,
        'mod6_fractions': {k: v / total if total > 0 else 0 
                          for k, v in mod6_counts.items()},
        'violations': violations,
    }


def verify_triple_theorem(bound: int) -> List[Tuple[int, int, int]]:
    """
    Find all prime triples (p, p+2, p+4) up to bound.
    The theorem predicts only (3, 5, 7).
    """
    primes_set = set(sieve_of_eratosthenes(bound))
    triples = []
    for p in sorted(primes_set):
        if p + 2 in primes_set and p + 4 in primes_set:
            triples.append((p, p + 2, p + 4))
    return triples
