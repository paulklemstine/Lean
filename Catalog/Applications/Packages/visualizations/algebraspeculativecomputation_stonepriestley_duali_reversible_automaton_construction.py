#!/usr/bin/env python3
"""
Algorithms for Spectral Proof Certificate Extraction

Implements the core algorithms from the research paper:
1. Prime Congruence Separator (Algorithm 1)
2. Verifier Extraction (Algorithm 2) 
3. Reversible Automaton Construction (Algorithm 3)
4. Spectral Width Computation (Algorithm 4)
5. Product Verifier Composition (Algorithm 5)

All algorithms have polynomial time complexity in the input size.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Set, Callable
import math


# ============================================================
# Algorithm 1: Prime Congruence Separator
# ============================================================

def find_separating_primes(a: int, b: int, max_prime: int = 100) -> List[int]:
    """Find all prime congruences that separate a from b.
    
    Algorithm: For each prime p ≤ max_prime, check if a ≢ b (mod p).
    
    Time complexity: O(max_prime * sqrt(max_prime))
    Space complexity: O(max_prime)
    
    Args:
        a, b: Elements to separate
        max_prime: Upper bound on primes to consider
    
    Returns:
        List of primes p such that a mod p ≠ b mod p
    
    Example:
        >>> find_separating_primes(3, 7)
        [3, 5, 7, 11, 13, ...]
    """
    if a == b:
        return []
    
    diff = abs(a - b)
    primes = sieve_primes(max_prime)
    return [p for p in primes if diff % p != 0]


def find_minimal_separator(a: int, b: int) -> Optional[int]:
    """Find the smallest prime separating a from b.
    
    Time complexity: O(|a-b| * log(|a-b|))
    
    Returns:
        Smallest prime p with a mod p ≠ b mod p, or None if a == b.
    """
    if a == b:
        return None
    diff = abs(a - b)
    # The smallest prime not dividing diff
    p = 2
    while p <= diff + 1:
        if diff % p != 0:
            return p
        p = next_prime(p)
    return p  # This is guaranteed to terminate


def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n.
    
    Time complexity: O(n log log n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def next_prime(n: int) -> int:
    """Find the smallest prime > n."""
    candidate = n + 1
    while True:
        if all(candidate % i != 0 for i in range(2, int(candidate**0.5) + 1)):
            return candidate
        candidate += 1


# ============================================================
# Algorithm 2: Verifier Extraction
# ============================================================

@dataclass
class FiniteVerifier:
    """A finite-state verifier extracted from spectral data.
    
    Attributes:
        n_states: Number of states
        modulus: The prime modulus used for separation
        target_class: The residue class to accept
    """
    n_states: int
    modulus: int
    target_class: int
    
    def verify(self, x: int) -> bool:
        """Check if x is in the target residue class.
        
        Time complexity: O(1)
        """
        return x % self.modulus == self.target_class
    
    def state_complexity(self) -> int:
        """Return the number of states."""
        return self.n_states


def extract_verifier(a: int, b: int) -> Optional[FiniteVerifier]:
    """Extract a finite-state verifier that accepts a and rejects b.
    
    Algorithm:
    1. Find minimal separating prime p
    2. Build p-state verifier accepting a's residue class
    
    Time complexity: O(|a-b| log |a-b|)
    Space complexity: O(1)
    
    Args:
        a: Element to accept
        b: Element to reject
    
    Returns:
        FiniteVerifier that accepts a and rejects b
    """
    p = find_minimal_separator(a, b)
    if p is None:
        return None
    return FiniteVerifier(
        n_states=p,
        modulus=p,
        target_class=a % p
    )


# ============================================================
# Algorithm 3: Reversible Automaton Construction  
# ============================================================

@dataclass
class ReversibleAutomaton:
    """A reversible finite automaton with invertible transitions.
    
    Uses modular arithmetic for reversibility: step is addition mod n,
    reverse step is subtraction mod n.
    """
    n_states: int
    
    def step(self, state: int, input_symbol: int) -> int:
        """Forward transition: (state + input) mod n_states.
        
        Time complexity: O(1)
        """
        return (state + input_symbol) % self.n_states
    
    def rev_step(self, state: int, input_symbol: int) -> int:
        """Reverse transition: (state - input) mod n_states.
        
        Time complexity: O(1)
        """
        return (state - input_symbol) % self.n_states
    
    def verify_left_inverse(self, inputs: List[int]) -> bool:
        """Check rev_step(step(q, a), a) = q for all states and given inputs.
        
        Time complexity: O(n_states * len(inputs))
        """
        for q in range(self.n_states):
            for a in inputs:
                if self.rev_step(self.step(q, a), a) != q:
                    return False
        return True
    
    def is_injective_on_states(self, input_symbol: int) -> bool:
        """Check that step(·, a) is injective on states.
        
        Time complexity: O(n_states)
        """
        seen: Set[int] = set()
        for q in range(self.n_states):
            result = self.step(q, input_symbol)
            if result in seen:
                return False
            seen.add(result)
        return True


def construct_reversible_automaton(modulus: int) -> ReversibleAutomaton:
    """Construct a reversible automaton with the given number of states.
    
    The automaton uses Z/nZ with additive transitions, which are
    automatically reversible (subtraction is the inverse).
    
    Time complexity: O(1)
    """
    return ReversibleAutomaton(n_states=modulus)


# ============================================================
# Algorithm 4: Spectral Width Computation
# ============================================================

def spectral_width(a: int, b: int, primes: List[int]) -> int:
    """Compute the spectral width: number of primes separating a from b.
    
    Time complexity: O(len(primes))
    
    Args:
        a, b: Elements to compare
        primes: List of prime congruences to test
    
    Returns:
        Number of primes in the list that separate a from b
    """
    if a == b:
        return 0
    return sum(1 for p in primes if (a - b) % p != 0)


def spectral_distance(a: int, b: int, primes: List[int]) -> float:
    """Compute the spectral distance: fraction of primes separating a from b.
    
    Time complexity: O(len(primes))
    
    Returns:
        spectral_width / len(primes), or 0 if no primes given
    """
    if not primes:
        return 0.0
    return spectral_width(a, b, primes) / len(primes)


def prime_separator_number(a: int, b: int) -> int:
    """Compute the prime separator number: minimal number of primes
    needed to distinguish a from b in any quotient product.
    
    For integers, this equals 1 if a ≠ b (a single prime suffices).
    
    Time complexity: O(|a-b| log |a-b|)
    """
    if a == b:
        return 0
    return 1  # For Z, a single prime always suffices


# ============================================================
# Algorithm 5: Product Verifier Composition
# ============================================================

@dataclass
class ProductVerifier:
    """Product of multiple verifiers running in parallel.
    
    Accepts iff ALL component verifiers accept (conjunction).
    State = tuple of component states.
    """
    components: List[FiniteVerifier]
    
    def n_states(self) -> int:
        """Total state count = product of component state counts.
        
        Time complexity: O(len(components))
        """
        result = 1
        for v in self.components:
            result *= v.n_states
        return result
    
    def verify(self, x: int) -> bool:
        """Accept iff all components accept.
        
        Time complexity: O(len(components))
        """
        return all(v.verify(x) for v in self.components)


def compose_verifiers(*verifiers: FiniteVerifier) -> ProductVerifier:
    """Compose multiple verifiers into a product verifier.
    
    Theorem D guarantees: |states| = product of component state counts.
    
    Time complexity: O(1) for construction
    """
    return ProductVerifier(components=list(verifiers))


# ============================================================
# Self-test
# ============================================================

if __name__ == "__main__":
    print("Algorithm self-tests:")
    
    # Test 1: Separator
    seps = find_separating_primes(17, 42, max_prime=50)
    print(f"  Separating primes for (17, 42): {seps[:5]}...")
    assert 2 in seps, "2 should separate 17 and 42"
    assert 5 not in seps, "5 should not separate 17 and 42 (diff=25)"
    
    # Test 2: Verifier
    V = extract_verifier(17, 42)
    assert V is not None
    assert V.verify(17) and not V.verify(42)
    print(f"  Verifier: {V.n_states} states, accepts 17, rejects 42 ✓")
    
    # Test 3: Reversible automaton
    R = construct_reversible_automaton(7)
    assert R.verify_left_inverse(list(range(7)))
    print(f"  Reversible automaton: {R.n_states} states, left-inverse verified ✓")
    for a in range(7):
        assert R.is_injective_on_states(a), f"Not injective for input {a}"
    print(f"  Step injectivity verified for all inputs ✓")
    
    # Test 4: Spectral width
    primes = sieve_primes(50)
    w = spectral_width(17, 42, primes)
    print(f"  Spectral width(17, 42) over primes ≤ 50: {w}/{len(primes)}")
    
    # Test 5: Product verifier
    V1 = extract_verifier(17, 42)
    V2 = FiniteVerifier(3, 3, 17 % 3)
    PV = compose_verifiers(V1, V2)
    assert PV.verify(17) and not PV.verify(42)
    print(f"  Product verifier: {PV.n_states()} states = {V1.n_states} × {V2.n_states}")
    
    print("\nAll self-tests passed ✓")


#!/usr/bin/env python3
"""
Applications of Spectral Proof Certificate Theory

Demonstrates real-world connections:
1. Proof compression via spectral encoding
2. Collision-resistant hashing from prime spectra
3. Minimal verifier synthesis for certification
4. Reversible computation and energy-optimal verification
"""