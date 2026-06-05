#!/usr/bin/env python3
"""
algorithms.py — Algorithms for non-standard arithmetic.

Provides type-hinted implementations of:
1. Ultrapower equivalence checking
2. Non-standard element comparison
3. Transfer principle simulation
4. Prime sequence generation for non-standard primes
"""

from typing import List, Callable, Set, Tuple, Optional
from dataclasses import dataclass
import math


# ============================================================
# Algorithm 1: Ultrapower Element Representation
# ============================================================

@dataclass
class UltrapowerElement:
    """Represents an element of ℕ* = ℕ^I/U as a finite approximation.
    
    In the formal construction, elements are equivalence classes of
    sequences modulo an ultrafilter. For computation, we represent
    them as finite sequences with a specified index set size.
    """
    sequence: List[int]
    
    @property
    def size(self) -> int:
        return len(self.sequence)
    
    @staticmethod
    def constant(n: int, size: int) -> 'UltrapowerElement':
        """The diagonal embedding d(n) = [n, n, ..., n]."""
        return UltrapowerElement([n] * size)
    
    @staticmethod
    def identity(size: int) -> 'UltrapowerElement':
        """The canonical infinite element ω = [0, 1, 2, ..., N-1]."""
        return UltrapowerElement(list(range(size)))
    
    @staticmethod
    def nth_prime_sequence(size: int) -> 'UltrapowerElement':
        """The non-standard prime π = [p_0, p_1, p_2, ...]."""
        primes = []
        candidate = 2
        while len(primes) < size:
            if all(candidate % p != 0 for p in range(2, int(math.sqrt(candidate)) + 1)):
                primes.append(candidate)
            candidate += 1
        return UltrapowerElement(primes)
    
    def add(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        """Pointwise addition: [f] + [g] = [f + g]."""
        assert self.size == other.size
        return UltrapowerElement([a + b for a, b in zip(self.sequence, other.sequence)])
    
    def mul(self, other: 'UltrapowerElement') -> 'UltrapowerElement':
        """Pointwise multiplication: [f] · [g] = [f · g]."""
        assert self.size == other.size
        return UltrapowerElement([a * b for a, b in zip(self.sequence, other.sequence)])


# ============================================================
# Algorithm 2: Ultrafilter Simulation (Majority Filter)
# ============================================================

def majority_filter_check(indices: Set[int], total: int) -> bool:
    """Simulate ultrafilter membership using the majority filter.
    
    A principal ultrafilter at point p declares S "large" iff p ∈ S.
    A nonprincipal ultrafilter declares S "large" iff it contains
    "most" elements. We approximate this with the majority criterion:
    S is large iff |S| > total/2.
    
    Pseudocode:
        INPUT: set S ⊆ {0, ..., N-1}, total N
        OUTPUT: True if |S| > N/2
    """
    return len(indices) > total / 2


def ultrapower_less_than(a: UltrapowerElement, b: UltrapowerElement) -> bool:
    """Check if [a] <* [b] in the ultrapower.
    
    [a] <* [b] iff {i | a(i) < b(i)} is U-large.
    
    Pseudocode:
        INPUT: sequences a, b of length N
        OUTPUT: True if a(i) < b(i) on more than N/2 indices
    """
    large_set = {i for i in range(a.size) if a.sequence[i] < b.sequence[i]}
    return majority_filter_check(large_set, a.size)


def ultrapower_equal(a: UltrapowerElement, b: UltrapowerElement) -> bool:
    """Check if [a] = [b] in the ultrapower.
    
    Pseudocode:
        INPUT: sequences a, b of length N
        OUTPUT: True if a(i) = b(i) on more than N/2 indices
    """
    agree_set = {i for i in range(a.size) if a.sequence[i] == b.sequence[i]}
    return majority_filter_check(agree_set, a.size)


def ultrapower_divides(a: UltrapowerElement, b: UltrapowerElement) -> bool:
    """Check if [a] |* [b] in the ultrapower.
    
    Pseudocode:
        INPUT: sequences a, b of length N
        OUTPUT: True if a(i) | b(i) on more than N/2 indices
    """
    div_set = {i for i in range(a.size) 
               if a.sequence[i] != 0 and b.sequence[i] % a.sequence[i] == 0}
    return majority_filter_check(div_set, a.size)


# ============================================================
# Algorithm 3: Transfer Principle Checker
# ============================================================

@dataclass
class FirstOrderAtom:
    """An atomic first-order formula over ℕ."""
    predicate: str  # "eq", "le", "lt", "dvd", "prime"
    args: Tuple     # indices into the variable list

def check_transfer(
    formula: Callable[[int], bool],
    elements: List[UltrapowerElement],
    size: int
) -> Tuple[bool, float]:
    """Check whether a first-order property transfers.
    
    Given a predicate P and ultrapower elements, compute the
    fraction of indices where P holds. If > 0.5, P "transfers."
    
    Pseudocode:
        INPUT: predicate P, ultrapower elements [f_1], ..., [f_k]
        OUTPUT: (transfers: bool, confidence: float)
        
        count = 0
        for i in 0..N-1:
            if P(f_1(i), ..., f_k(i)):
                count += 1
        fraction = count / N
        return (fraction > 0.5, fraction)
    """
    count = sum(1 for i in range(size) if formula(i))
    fraction = count / size
    return (fraction > 0.5, fraction)


# ============================================================
# Algorithm 4: Non-Standard Prime Generator  
# ============================================================

def generate_nonstandard_prime(size: int) -> Tuple[UltrapowerElement, dict]:
    """Generate a non-standard prime element.
    
    Constructs the sequence [p_0, p_1, p_2, ...] of consecutive primes
    and verifies:
    1. Every entry is prime
    2. p_n > n for all n
    
    Pseudocode:
        INPUT: sequence length N
        OUTPUT: (ultrapower element π, verification dict)
        
        primes = []
        candidate = 2
        while |primes| < N:
            if isPrime(candidate):
                primes.append(candidate)
            candidate += 1
        
        verify:
            all_prime = ∀ i, isPrime(primes[i])
            all_exceed = ∀ i, primes[i] > i
        
        return (UltrapowerElement(primes), {all_prime, all_exceed})
    """
    pi = UltrapowerElement.nth_prime_sequence(size)
    
    all_prime = all(
        all(pi.sequence[i] % p != 0 for p in range(2, int(math.sqrt(pi.sequence[i])) + 1))
        if pi.sequence[i] > 1 else False
        for i in range(size)
    )
    all_exceed = all(pi.sequence[i] > i for i in range(size))
    
    return pi, {
        "all_prime": all_prime,
        "all_exceed_index": all_exceed,
        "min_prime": min(pi.sequence),
        "max_prime": max(pi.sequence),
        "growth_rate": pi.sequence[-1] / size if size > 0 else 0
    }


# ============================================================
# Algorithm 5: Overspill Detector
# ============================================================

def detect_overspill(
    property_family: Callable[[int, int], bool],
    max_n: int,
    size: int
) -> dict:
    """Detect the overspill phenomenon.
    
    Given a family P(i, n), compute:
    - For each n, the fraction of indices where P(i, n) holds
    - The fraction where ∀ n < max_n, P(i, n) holds simultaneously
    - The ratio (simultaneous / individual), showing overspill gap
    
    Pseudocode:
        INPUT: property P(i,n), bound max_n, index set size N
        OUTPUT: analysis dict
        
        for n in 0..max_n-1:
            individual[n] = |{i | P(i,n)}| / N
        
        simultaneous = |{i | ∀ n < max_n, P(i,n)}| / N
        gap = min(individual) - simultaneous
        
        return {individual, simultaneous, gap}
    """
    individual = {}
    for n in range(max_n):
        count = sum(1 for i in range(size) if property_family(i, n))
        individual[n] = count / size
    
    simultaneous_count = sum(
        1 for i in range(size)
        if all(property_family(i, n) for n in range(max_n))
    )
    simultaneous = simultaneous_count / size
    
    min_individual = min(individual.values()) if individual else 0
    
    return {
        "individual_fractions": individual,
        "simultaneous_fraction": simultaneous,
        "gap": min_individual - simultaneous,
        "overspill_detected": simultaneous == 0 and min_individual > 0.5
    }


if __name__ == "__main__":
    N = 100
    
    # Demo: Non-standard prime
    pi, info = generate_nonstandard_prime(N)
    print(f"Non-standard prime (N={N}):")
    print(f"  All entries prime: {info['all_prime']}")
    print(f"  All exceed index: {info['all_exceed_index']}")
    print(f"  Growth rate (p_N/N): {info['growth_rate']:.2f}")
    
    # Demo: Overspill detection
    result = detect_overspill(lambda i, n: n < i, max_n=20, size=N)
    print(f"\nOverspill analysis for P(i,n) = 'n < i' (N={N}, max_n=20):")
    print(f"  Simultaneous fraction: {result['simultaneous_fraction']}")
    print(f"  Overspill detected: {result['overspill_detected']}")
    
    # Demo: ω > d(n) check
    omega = UltrapowerElement.identity(N)
    for n in [10, 50, 99]:
        dn = UltrapowerElement.constant(n, N)
        print(f"\n  ω >* d({n}): {ultrapower_less_than(dn, omega)}")
