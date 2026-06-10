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

from algorithms import (
    find_separating_primes, extract_verifier, spectral_width,
    spectral_distance, sieve_primes, compose_verifiers,
    construct_reversible_automaton, FiniteVerifier, ProductVerifier
)
from typing import List, Dict, Tuple
import math


# ============================================================
# Application 1: Proof Compression
# ============================================================

def proof_compression_demo():
    """Demonstrate proof compression via spectral encoding.
    
    A "proof" is represented as an integer (hash of the proof trace).
    Compression maps it to residues modulo a small set of primes,
    preserving distinguishability with bounded state complexity.
    """
    print("=" * 60)
    print("APPLICATION 1: PROOF COMPRESSION")
    print("=" * 60)
    
    # Simulate proof hashes
    proofs = {
        "P1": 12345,
        "P2": 67890,
        "P3": 11111,
        "P4": 22222,
        "P5": 33333,
    }
    
    # Choose compression primes
    compression_primes = [2, 3, 5, 7, 11]
    product = math.prod(compression_primes)
    
    print(f"\nCompression using primes {compression_primes} (product = {product})")
    print(f"Compression ratio: log2({max(proofs.values())}) / log2({product}) "
          f"≈ {math.log2(max(proofs.values())):.1f} / {math.log2(product):.1f} "
          f"= {math.log2(max(proofs.values())) / math.log2(product):.2f}")
    
    # Compute compressed codes
    codes = {}
    for name, h in proofs.items():
        code = tuple(h % p for p in compression_primes)
        codes[name] = code
        print(f"  {name} (hash={h}): code = {code}")
    
    # Check uniqueness
    unique_codes = set(codes.values())
    print(f"\n  Unique codes: {len(unique_codes)}/{len(codes)}")
    if len(unique_codes) == len(codes):
        print("  → All proofs distinguishable under compression ✓")
    else:
        print("  → Collision detected! Need more primes.")
    
    # Pairwise verification
    print(f"\n  Pairwise verifiers (minimal state count):")
    names = list(proofs.keys())
    for i in range(len(names)):
        for j in range(i+1, len(names)):
            a, b = proofs[names[i]], proofs[names[j]]
            V = extract_verifier(a, b)
            if V:
                print(f"    {names[i]} vs {names[j]}: "
                      f"{V.n_states}-state verifier (mod {V.modulus})")
    print()


# ============================================================
# Application 2: Collision-Resistant Hashing
# ============================================================

def collision_resistance_demo():
    """Demonstrate collision resistance properties of spectral hashing.
    
    The spectral hash maps elements to their residue tuple modulo
    a set of primes. Collision resistance depends on the number of primes.
    """
    print("=" * 60)
    print("APPLICATION 2: COLLISION-RESISTANT SPECTRAL HASHING")
    print("=" * 60)
    
    # Analyze collision probability for different numbers of primes
    prime_counts = [1, 2, 3, 4, 5, 6, 7, 8]
    all_primes = sieve_primes(100)
    
    print(f"\nCollision analysis for range [0, 1000):")
    print(f"  {'#primes':>8} {'product':>10} {'collisions':>12} {'rate':>10}")
    print(f"  {'---':>8} {'---':>10} {'---':>12} {'---':>10}")
    
    N = 1000
    for k in prime_counts:
        primes = all_primes[:k]
        product = math.prod(primes)
        
        # Count collisions
        seen: Dict[Tuple, int] = {}
        collisions = 0
        for x in range(N):
            code = tuple(x % p for p in primes)
            if code in seen:
                collisions += 1
            else:
                seen[code] = x
        
        rate = collisions / N if N > 0 else 0
        print(f"  {k:>8} {product:>10} {collisions:>12} {rate:>10.4f}")
    
    # Show that CRT gives zero collisions when product ≥ N
    print(f"\n  By CRT: zero collisions when ∏pᵢ ≥ N = {N}")
    for k in range(1, len(all_primes) + 1):
        primes = all_primes[:k]
        if math.prod(primes) >= N:
            print(f"  → Need ≥ {k} primes: {primes} (product = {math.prod(primes)})")
            break
    print()


# ============================================================
# Application 3: Minimal Verifier Synthesis
# ============================================================

def minimal_verifier_synthesis():
    """Synthesize minimal verifiers for a set of elements to distinguish."""
    print("=" * 60)
    print("APPLICATION 3: MINIMAL VERIFIER SYNTHESIS")
    print("=" * 60)
    
    # Given a set of elements, find the minimal prime that separates all pairs
    elements = [10, 23, 37, 41, 59]
    
    print(f"\nElements: {elements}")
    print(f"Pairs to separate: {len(elements) * (len(elements)-1) // 2}")
    
    # For each prime, check how many pairs it separates
    primes = sieve_primes(50)
    
    print(f"\nPrime separation power:")
    total_pairs = len(elements) * (len(elements) - 1) // 2
    
    best_prime = None
    best_count = 0
    
    for p in primes[:10]:
        classes = {}
        for x in elements:
            r = x % p
            if r not in classes:
                classes[r] = []
            classes[r].append(x)
        
        separated = sum(1 for i in range(len(elements)) 
                       for j in range(i+1, len(elements))
                       if elements[i] % p != elements[j] % p)
        
        if separated > best_count:
            best_count = separated
            best_prime = p
        
        print(f"  mod {p:>2}: {len(classes)} classes, "
              f"separates {separated}/{total_pairs} pairs "
              f"{'← best so far' if p == best_prime else ''}")
    
    # Greedy covering: find minimal set of primes separating all pairs
    print(f"\nGreedy covering algorithm:")
    uncovered = set()
    for i in range(len(elements)):
        for j in range(i+1, len(elements)):
            uncovered.add((elements[i], elements[j]))
    
    selected_primes = []
    while uncovered:
        # Pick prime covering most uncovered pairs
        best_p, best_covered = 2, set()
        for p in primes:
            covered = {(a, b) for a, b in uncovered if (a - b) % p != 0}
            if len(covered) > len(best_covered):
                best_p, best_covered = p, covered
        
        selected_primes.append(best_p)
        uncovered -= best_covered
        print(f"  Selected p={best_p}: covers {len(best_covered)} pairs, "
              f"{len(uncovered)} remaining")
    
    product_states = math.prod(selected_primes)
    print(f"\n  Minimal covering set: {selected_primes}")
    print(f"  Product verifier: {product_states} states")
    print()


# ============================================================
# Application 4: Reversible Verification Energy Bounds
# ============================================================

def reversible_verification_demo():
    """Demonstrate energy-optimal reversible verification.
    
    Landauer's principle: irreversible bit erasure costs kT ln(2) energy.
    Reversible computation avoids this cost entirely.
    """
    print("=" * 60)
    print("APPLICATION 4: REVERSIBLE VERIFICATION (ENERGY BOUNDS)")
    print("=" * 60)
    
    kT = 4.11e-21  # kT at room temperature (300K) in Joules
    landauer = kT * math.log(2)  # Landauer limit per bit erasure
    
    print(f"\nLandauer limit: {landauer:.2e} J per bit erasure (at 300K)")
    
    # Compare irreversible vs reversible verifiers
    test_cases = [
        ("2-state (Boolean)", 2),
        ("7-state (mod 7)", 7),
        ("30-state (mod 2×3×5)", 30),
        ("210-state (mod 2×3×5×7)", 210),
    ]
    
    print(f"\n  {'Verifier':>30} {'States':>8} {'Irrev. energy':>15} {'Rev. energy':>15}")
    print(f"  {'---':>30} {'---':>8} {'---':>15} {'---':>15}")
    
    for name, states in test_cases:
        bits = math.ceil(math.log2(states))
        irrev_energy = bits * landauer  # Irreversible: erase all bits
        rev_energy = 0.0  # Reversible: zero energy (in principle)
        
        print(f"  {name:>30} {states:>8} {irrev_energy:>15.2e} {'0 (optimal)':>15}")
    
    # Demonstrate reversibility verification
    print(f"\nReversibility verification:")
    for n in [2, 5, 7, 11]:
        R = construct_reversible_automaton(n)
        ok = R.verify_left_inverse(list(range(n)))
        inj = all(R.is_injective_on_states(a) for a in range(n))
        print(f"  Z/{n}Z automaton: left-inverse ✓, injective ✓" if ok and inj
              else f"  Z/{n}Z automaton: FAILED")
    
    print()


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Applications of Spectral Proof Certificate Theory          ║")
    print("╚══════════════════════════════════════════════════════════════╝")
    print()
    
    proof_compression_demo()
    collision_resistance_demo()
    minimal_verifier_synthesis()
    reversible_verification_demo()
    
    print("=" * 60)
    print("All application demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Stone-Priestley Duality for Tropical Proof Certificates: Demonstration

This script demonstrates the four main theorems with concrete numerical examples:
- Theorem A: Separation by prime congruences
- Theorem B: Spectral representation
- Theorem C: Verifier extraction
- Theorem D: Compression bounds

Run with: python3 demo.py
"""

import itertools
from dataclasses import dataclass, field
from typing import Callable, Dict, List, Set, Tuple

# ============================================================
# § 1. Tropical Semiring Infrastructure
# ============================================================

class TropicalSemiring:
    """Min-plus semiring on integers (or ∞).
    
    Addition: min(a, b)  (tropical sum)
    Multiplication: a + b  (tropical product)
    Zero: ∞  (additive identity for min)
    One: 0   (multiplicative identity for +)
    """
    INF = float('inf')
    
    @staticmethod
    def add(a: float, b: float) -> float:
        """Tropical addition = min."""
        return min(a, b)
    
    @staticmethod
    def mul(a: float, b: float) -> float:
        """Tropical multiplication = ordinary addition."""
        if a == TropicalSemiring.INF or b == TropicalSemiring.INF:
            return TropicalSemiring.INF
        return a + b
    
    @staticmethod
    def zero() -> float:
        return TropicalSemiring.INF
    
    @staticmethod
    def one() -> float:
        return 0.0
    
    @staticmethod
    def is_idempotent(a: float) -> bool:
        """Check a ⊕ a = a (always true for min)."""
        return TropicalSemiring.add(a, a) == a


def demo_idempotency():
    """Demonstrate that tropical addition is idempotent."""
    print("=" * 60)
    print("§ 1. TROPICAL IDEMPOTENCY")
    print("=" * 60)
    T = TropicalSemiring
    
    test_values = [0, 1, -5, 42, 100, T.INF]
    print(f"\nIdempotent law: min(a, a) = a")
    for a in test_values:
        result = T.add(a, a)
        status = "✓" if T.is_idempotent(a) else "✗"
        print(f"  {status} min({a}, {a}) = {result}")
    
    print(f"\nDistributivity: a + min(b, c) = min(a+b, a+c)")
    for a, b, c in [(1, 2, 3), (0, 5, -1), (10, 10, 20)]:
        lhs = T.mul(a, T.add(b, c))
        rhs = T.add(T.mul(a, b), T.mul(a, c))
        status = "✓" if lhs == rhs else "✗"
        print(f"  {status} {a} + min({b},{c}) = min({a}+{b}, {a}+{c}) : {lhs} = {rhs}")
    print()


# ============================================================
# § 2. Prime Congruences and Separation
# ============================================================

@dataclass
class ModCongruence:
    """Ring congruence: a ≡ b (mod m).
    
    For the tropical semiring on integers, modular congruences
    serve as a concrete family of ring congruences.
    """
    modulus: int
    
    def relates(self, a: int, b: int) -> bool:
        """Check if a ≡ b (mod modulus)."""
        if self.modulus == 0:
            return a == b  # trivial congruence (equality)
        return (a - b) % self.modulus == 0
    
    def is_prime(self) -> bool:
        """A modular congruence mod p is prime iff p is prime."""
        if self.modulus < 2:
            return self.modulus == 0  # trivial is 'prime' in a degenerate sense
        return all(self.modulus % i != 0 for i in range(2, int(self.modulus**0.5) + 1))
    
    def quotient_class(self, a: int) -> int:
        """The equivalence class of a in Z/mZ."""
        if self.modulus == 0:
            return a
        return a % self.modulus
    
    def __repr__(self):
        return f"Mod({self.modulus})"


def demo_separation():
    """Demonstrate Theorem A: prime congruence separation."""
    print("=" * 60)
    print("§ 2. THEOREM A: PRIME CONGRUENCE SEPARATION")
    print("=" * 60)
    
    # For integers, distinct elements are separated by prime congruences
    test_pairs = [(3, 7), (10, 25), (0, 1), (100, 107), (42, 42)]
    primes = [2, 3, 5, 7, 11, 13]
    
    for a, b in test_pairs:
        if a == b:
            print(f"\n  a={a}, b={b}: EQUAL — no separation needed")
            continue
        
        separators = []
        for p in primes:
            cong = ModCongruence(p)
            if not cong.relates(a, b):
                separators.append(p)
        
        print(f"\n  a={a}, b={b}: separated by primes {separators}")
        print(f"    Minimal separator: p={separators[0] if separators else 'NONE'}")
        
        # Show quotient images
        if separators:
            p = separators[0]
            print(f"    [{a}]_{p} = {a % p}, [{b}]_{p} = {b % p}")
    
    print()


# ============================================================
# § 3. Spectral Representation
# ============================================================

def spectral_observable(s: int, primes: List[int]) -> Dict[int, int]:
    """Compute the spectral observable η(s): the quotient image at each prime."""
    return {p: s % p for p in primes}


def demo_representation():
    """Demonstrate Theorem B: spectral representation."""
    print("=" * 60)
    print("§ 3. THEOREM B: SPECTRAL REPRESENTATION")
    print("=" * 60)
    
    primes = [2, 3, 5, 7]
    elements = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    
    print(f"\nSpectral observables η(s) at primes {primes}:")
    print(f"  {'s':>3} | {'mod 2':>5} {'mod 3':>5} {'mod 5':>5} {'mod 7':>5}")
    print(f"  {'---':>3}-+-{'-----':>5}-{'-----':>5}-{'-----':>5}-{'-----':>5}")
    
    observables = {}
    for s in elements:
        obs = spectral_observable(s, primes)
        observables[s] = tuple(obs[p] for p in primes)
        print(f"  {s:>3} | {obs[2]:>5} {obs[3]:>5} {obs[5]:>5} {obs[7]:>5}")
    
    # Check injectivity within the range
    print(f"\nInjectivity check (mod {2*3*5*7}={2*3*5*7}):")
    seen = {}
    collisions = 0
    for s in range(2*3*5*7):
        obs = tuple(s % p for p in primes)
        if obs in seen:
            collisions += 1
        else:
            seen[obs] = s
    print(f"  Elements: {2*3*5*7}, Distinct observables: {len(seen)}, Collisions: {collisions}")
    print(f"  → Representation is {'injective ✓' if collisions == 0 else 'NOT injective ✗'}")
    
    # Order preservation
    print(f"\nOrder preservation (tropical order a ≤ b iff min(a,b) = a):")
    for a, b in [(1, 3), (2, 5), (0, 7)]:
        obs_a = spectral_observable(a, primes)
        obs_b = spectral_observable(b, primes)
        print(f"  a={a}, b={b}: η(a) = {tuple(obs_a[p] for p in primes)}, "
              f"η(b) = {tuple(obs_b[p] for p in primes)}")
    print()


# ============================================================
# § 4. Verifier Extraction
# ============================================================

@dataclass
class ExtractedVerifier:
    """A finite-state verifier.
    
    States are integers 0..n_states-1.
    Transitions: step(state, input) -> state.
    """
    n_states: int
    step: Callable[[int, int], int]
    start: int
    accept: Callable[[int], bool]
    name: str = ""
    
    def run(self, inputs: List[int]) -> bool:
        """Run the verifier on a sequence of inputs."""
        state = self.start
        for inp in inputs:
            state = self.step(state, inp)
        return self.accept(state)


@dataclass
class ReversibleAutomaton:
    """A reversible trace automaton with invertible transitions."""
    n_states: int
    step: Callable[[int, int], int]
    rev_step: Callable[[int, int], int]
    start: int
    accept: Callable[[int], bool]
    name: str = ""
    
    def verify_reversibility(self, inputs: List[int]) -> bool:
        """Check that rev_step(step(q, a), a) = q for all states and inputs."""
        for q in range(self.n_states):
            for a in inputs:
                if self.rev_step(self.step(q, a), a) != q:
                    return False
        return True


def extract_verifier_from_prime(p: int, a: int, b: int) -> ExtractedVerifier:
    """Extract a verifier that distinguishes a from b using congruence mod p."""
    return ExtractedVerifier(
        n_states=p,
        step=lambda state, inp: inp % p,
        start=0,
        accept=lambda state: state == a % p,
        name=f"V_mod{p}(a={a})"
    )


def demo_extraction():
    """Demonstrate Theorem C: verifier extraction."""
    print("=" * 60)
    print("§ 4. THEOREM C: VERIFIER EXTRACTION")
    print("=" * 60)
    
    a, b = 3, 7
    p = 2  # smallest prime separating 3 and 7
    
    print(f"\nExtracting verifier for a={a} vs b={b}")
    print(f"  Separating prime: p={p}")
    print(f"  [{a}]_{p} = {a % p}, [{b}]_{p} = {b % p}")
    
    V = extract_verifier_from_prime(p, a, b)
    print(f"\n  Extracted verifier: {V.n_states} states")
    print(f"  V({a}) = {'ACCEPT' if V.run([a]) else 'REJECT'}")
    print(f"  V({b}) = {'ACCEPT' if V.run([b]) else 'REJECT'}")
    
    # XOR-based reversible automaton
    print(f"\nReversible XOR automaton:")
    xor_auto = ReversibleAutomaton(
        n_states=2,
        step=lambda q, a: q ^ (a % 2),
        rev_step=lambda q, a: q ^ (a % 2),
        start=0,
        accept=lambda q: q == 1,
        name="XOR parity tracker"
    )
    
    test_sequences = [
        [0, 1, 0],
        [1, 1, 1],
        [0, 0, 0],
        [1, 0, 1, 0, 1],
    ]
    
    for seq in test_sequences:
        # Trace the automaton
        state = xor_auto.start
        trace = [state]
        for inp in seq:
            state = xor_auto.step(state, inp)
            trace.append(state)
        accept = xor_auto.accept(state)
        parity = sum(seq) % 2
        print(f"  Input: {seq} → States: {trace} → "
              f"{'ACCEPT' if accept else 'REJECT'} "
              f"(parity={parity})")
    
    # Verify reversibility
    rev_ok = xor_auto.verify_reversibility([0, 1])
    print(f"\n  Reversibility verified: {'✓' if rev_ok else '✗'}")
    
    # Demonstrate reversibility
    print(f"\n  Reversibility demo:")
    for q in range(2):
        for a in [0, 1]:
            fwd = xor_auto.step(q, a)
            rev = xor_auto.rev_step(fwd, a)
            print(f"    step({q}, {a}) = {fwd}, rev_step({fwd}, {a}) = {rev} "
                  f"{'✓' if rev == q else '✗'}")
    print()


# ============================================================
# § 5. Compression Bounds
# ============================================================

def demo_compression():
    """Demonstrate Theorem D: compression bounds."""
    print("=" * 60)
    print("§ 5. THEOREM D: COMPRESSION BOUNDS")
    print("=" * 60)
    
    # For integer separation, the spectral width is the number of
    # primes dividing (a - b).
    test_pairs = [
        (0, 1, "adjacent"),
        (0, 6, "2×3"),
        (0, 30, "2×3×5"),
        (0, 210, "2×3×5×7"),
        (10, 40, "diff=30=2×3×5"),
    ]
    
    small_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31]
    
    print(f"\nSpectral width analysis (separating primes among first {len(small_primes)}):")
    print(f"  {'a':>5} {'b':>5} {'diff':>5} {'note':>20} {'width':>6} {'separators':>30}")
    print(f"  {'---':>5} {'---':>5} {'---':>5} {'---':>20} {'---':>6} {'---':>30}")
    
    for a, b, note in test_pairs:
        diff = abs(a - b)
        separators = [p for p in small_primes if (a - b) % p != 0]
        width = len(separators)
        sep_str = str(separators[:5]) + ("..." if len(separators) > 5 else "")
        print(f"  {a:>5} {b:>5} {diff:>5} {note:>20} {width:>6} {sep_str:>30}")
    
    # Product automaton composition
    print(f"\nVerifier composition (product automaton):")
    sizes = [2, 3, 5]
    for i, (s1, s2) in enumerate(itertools.combinations(sizes, 2)):
        product = s1 * s2
        print(f"  V₁({s1} states) × V₂({s2} states) → V({product} states)")
    
    # Triple composition
    triple = sizes[0] * sizes[1] * sizes[2]
    print(f"  V₁(2) × V₂(3) × V₃(5) → V({triple} states)")
    
    # Bound: verifier states ≤ product of quotient sizes
    print(f"\nCompression bound: |V| ≤ ∏ |S/Pᵢ|")
    for n_primes in range(1, 6):
        primes = small_primes[:n_primes]
        product = 1
        for p in primes:
            product *= p
        print(f"  {n_primes} prime(s) {primes}: "
              f"max verifier states = {product}")
    
    print()


# ============================================================
# § 6. Full Pipeline Demo
# ============================================================

def demo_pipeline():
    """Full pipeline: element → separation → representation → extraction → verification."""
    print("=" * 60)
    print("§ 6. FULL PIPELINE: SPECTRAL PROOF EXTRACTION")
    print("=" * 60)
    
    # Setup: distinguish proof certificate a=17 from b=42
    a, b = 17, 42
    diff = abs(a - b)
    print(f"\nTask: distinguish certificate a={a} from b={b} (diff={diff})")
    
    # Step 1: Find separating primes
    primes = [2, 3, 5, 7, 11, 13]
    separators = [(p, a % p, b % p) for p in primes if a % p != b % p]
    print(f"\nStep 1 (Separation): found {len(separators)} separating primes")
    for p, qa, qb in separators:
        print(f"  mod {p}: [{a}]={qa}, [{b}]={qb}")
    
    # Step 2: Compute spectral observable
    obs_a = {p: a % p for p in primes}
    obs_b = {p: b % p for p in primes}
    print(f"\nStep 2 (Representation):")
    print(f"  η({a}) = {tuple(obs_a[p] for p in primes)}")
    print(f"  η({b}) = {tuple(obs_b[p] for p in primes)}")
    print(f"  Distinct: {'✓' if obs_a != obs_b else '✗'}")
    
    # Step 3: Extract verifier
    best_p = separators[0][0]
    V = extract_verifier_from_prime(best_p, a, b)
    print(f"\nStep 3 (Extraction): {V.n_states}-state verifier using mod {best_p}")
    
    # Step 4: Run verifier
    print(f"\nStep 4 (Verification):")
    for x in [a, b, 0, 1, 99, a + best_p]:
        result = V.run([x])
        expected = (x % best_p == a % best_p)
        status = "✓" if result == expected else "✗"
        print(f"  {status} V({x}) = {'ACCEPT' if result else 'REJECT'} "
              f"(class [{x % best_p}]_{best_p})")
    
    # Step 5: Compression analysis
    min_states = min(p for p, _, _ in separators)
    max_states = 1
    for p, _, _ in separators:
        max_states *= p
    print(f"\nStep 5 (Compression bounds):")
    print(f"  Minimal single-prime verifier: {min_states} states")
    print(f"  Product verifier (all primes): {max_states} states")
    print(f"  Spectral width: {len(separators)} separating primes")
    
    print()


# ============================================================
# MAIN
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Stone-Priestley Duality for Tropical Proof Certificates ║")
    print("║  Demonstration of Theorems A, B, C, D                   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_idempotency()
    demo_separation()
    demo_representation()
    demo_extraction()
    demo_compression()
    demo_pipeline()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)
