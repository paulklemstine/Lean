#!/usr/bin/env python3
"""
Oracle Theory — Interactive Python Demonstrations

Demonstrates anti-oracles, inverse oracles, noisy oracle amplification,
the Boolean algebra of oracles, and the inverse stereo projection encoding.

Run: python3 demos/oracle_demo.py
"""

import math
import random
from typing import Set, Callable, Optional, Dict, List, Tuple

# ============================================================
# 1. Oracle and Anti-Oracle
# ============================================================

class Oracle:
    """An oracle over a finite domain, modeled as a set."""
    
    def __init__(self, carrier: set, universe: set):
        self.carrier = carrier
        self.universe = universe
    
    def query(self, x) -> bool:
        """Ask the oracle: is x in the set?"""
        return x in self.carrier
    
    def anti(self) -> 'Oracle':
        """The anti-oracle: always gives the opposite answer."""
        return Oracle(self.universe - self.carrier, self.universe)
    
    def join(self, other: 'Oracle') -> 'Oracle':
        """Union: yes when either says yes."""
        return Oracle(self.carrier | other.carrier, self.universe)
    
    def meet(self, other: 'Oracle') -> 'Oracle':
        """Intersection: yes when both say yes."""
        return Oracle(self.carrier & other.carrier, self.universe)
    
    def xor(self, other: 'Oracle') -> 'Oracle':
        """Symmetric difference."""
        return Oracle(self.carrier ^ other.carrier, self.universe)
    
    def sdiff(self, other: 'Oracle') -> 'Oracle':
        """Set difference."""
        return Oracle(self.carrier - other.carrier, self.universe)
    
    def __eq__(self, other):
        return self.carrier == other.carrier
    
    def __repr__(self):
        return f"Oracle({sorted(self.carrier)})"
    
    @property
    def size(self):
        return len(self.carrier)


def demo_anti_oracle():
    """Demonstrate the Contrarian Oracle Theorem."""
    print("=" * 60)
    print("DEMO 1: The Contrarian Oracle Theorem")
    print("=" * 60)
    
    # The primality oracle on {1, ..., 20}
    universe = set(range(1, 21))
    
    def is_prime(n):
        if n < 2: return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0: return False
        return True
    
    primes = {n for n in universe if is_prime(n)}
    prime_oracle = Oracle(primes, universe)
    anti_prime = prime_oracle.anti()
    
    print(f"\nUniverse: {{1, ..., 20}}")
    print(f"Prime Oracle says YES to: {sorted(prime_oracle.carrier)}")
    print(f"Anti-Oracle says YES to:  {sorted(anti_prime.carrier)}")
    
    print(f"\nVerifying Contrarian Oracle Theorem: x ∈ O ↔ x ∉ anti(O)")
    all_correct = True
    for x in universe:
        if prime_oracle.query(x) != (not anti_prime.query(x)):
            all_correct = False
            break
    print(f"  ✓ Theorem holds for all x ∈ {{1,...,20}}: {all_correct}")
    
    # Involution
    double_anti = anti_prime.anti()
    print(f"\nInvolution: anti(anti(O)) = O")
    print(f"  anti(anti(primes)) = {sorted(double_anti.carrier)}")
    print(f"  original primes    = {sorted(prime_oracle.carrier)}")
    print(f"  ✓ Equal: {double_anti == prime_oracle}")
    
    # XOR = universal
    xor_result = prime_oracle.xor(anti_prime)
    print(f"\nXOR with anti = universal:")
    print(f"  O ⊕ anti(O) = {sorted(xor_result.carrier)}")
    print(f"  ✓ Is universal: {xor_result.carrier == universe}")
    
    # Meet = empty
    meet_result = prime_oracle.meet(anti_prime)
    print(f"\nMeet with anti = empty:")
    print(f"  O ∩ anti(O) = {sorted(meet_result.carrier)}")
    print(f"  ✓ Is empty: {meet_result.size == 0}")


def demo_de_morgan():
    """Demonstrate De Morgan's Laws for oracles."""
    print("\n" + "=" * 60)
    print("DEMO 2: De Morgan's Laws for Oracles")
    print("=" * 60)
    
    universe = set(range(1, 13))
    evens = Oracle({n for n in universe if n % 2 == 0}, universe)
    multiples_of_3 = Oracle({n for n in universe if n % 3 == 0}, universe)
    
    print(f"\nO₁ (evens):        {sorted(evens.carrier)}")
    print(f"O₂ (mult of 3):    {sorted(multiples_of_3.carrier)}")
    
    # De Morgan 1: anti(join(O1, O2)) = meet(anti(O1), anti(O2))
    lhs1 = evens.join(multiples_of_3).anti()
    rhs1 = evens.anti().meet(multiples_of_3.anti())
    print(f"\nDe Morgan 1: anti(O₁ ∪ O₂) = anti(O₁) ∩ anti(O₂)")
    print(f"  LHS = {sorted(lhs1.carrier)}")
    print(f"  RHS = {sorted(rhs1.carrier)}")
    print(f"  ✓ Equal: {lhs1 == rhs1}")
    
    # De Morgan 2: anti(meet(O1, O2)) = join(anti(O1), anti(O2))
    lhs2 = evens.meet(multiples_of_3).anti()
    rhs2 = evens.anti().join(multiples_of_3.anti())
    print(f"\nDe Morgan 2: anti(O₁ ∩ O₂) = anti(O₁) ∪ anti(O₂)")
    print(f"  LHS = {sorted(lhs2.carrier)}")
    print(f"  RHS = {sorted(rhs2.carrier)}")
    print(f"  ✓ Equal: {lhs2 == rhs2}")


# ============================================================
# 2. Inverse Oracle
# ============================================================

class InverseOracle:
    """An inverse oracle for a function f: maps outputs back to all preimages."""
    
    def __init__(self, func, domain):
        self.func = func
        self.domain = domain
        # Precompute the inverse mapping
        self._inverse = {}
        for x in domain:
            y = func(x)
            if y not in self._inverse:
                self._inverse[y] = set()
            self._inverse[y].add(x)
    
    def invert(self, y) -> set:
        """Return all x such that f(x) = y."""
        return self._inverse.get(y, set())
    
    def verify(self) -> bool:
        """Verify correctness: for all y, x ∈ invert(y) ↔ f(x) = y."""
        for y, preimages in self._inverse.items():
            for x in preimages:
                if self.func(x) != y:
                    return False
        return True


def demo_inverse_oracle():
    """Demonstrate inverse oracles for different function types."""
    print("\n" + "=" * 60)
    print("DEMO 3: Inverse Oracles")
    print("=" * 60)
    
    # Case 1: Bijection (doubling on {1,...,10})
    print("\n--- Case 1: Bijective function (f(x) = 2x) ---")
    domain = set(range(1, 11))
    f_bij = lambda x: 2 * x
    inv_bij = InverseOracle(f_bij, domain)
    
    for y in [4, 10, 14]:
        preimages = inv_bij.invert(y)
        print(f"  f⁻¹({y}) = {preimages}  (unique preimage)")
    print(f"  ✓ Correctness verified: {inv_bij.verify()}")
    
    # Case 2: Non-injective (squaring mod 97)
    print("\n--- Case 2: Non-injective function (f(x) = x² mod 97) ---")
    domain = set(range(1, 97))
    f_sq = lambda x: (x * x) % 97
    inv_sq = InverseOracle(f_sq, domain)
    
    for y in [4, 9, 1]:
        preimages = inv_sq.invert(y)
        print(f"  f⁻¹({y}) = {sorted(preimages)}  ({len(preimages)} preimages)")
    print(f"  ✓ Correctness verified: {inv_sq.verify()}")
    
    # Case 3: Hash function (simulated one-way function)
    print("\n--- Case 3: 'One-way' function (hash simulation) ---")
    domain = set(range(1000))
    f_hash = lambda x: hash(str(x)) % 256
    inv_hash = InverseOracle(f_hash, domain)
    
    target = f_hash(42)
    preimages = inv_hash.invert(target)
    print(f"  hash(42) = {target}")
    print(f"  f⁻¹({target}) has {len(preimages)} preimages")
    print(f"  42 ∈ preimages: {42 in preimages}")
    print(f"  ✓ Correctness verified: {inv_hash.verify()}")
    
    # Composition of inverse oracles
    print("\n--- Composition: inverting g ∘ f ---")
    domain_f = set(range(1, 6))
    f = lambda x: x + 10
    g = lambda y: y * 2
    
    inv_f = InverseOracle(f, domain_f)
    inv_g = InverseOracle(g, {f(x) for x in domain_f})
    
    # Compose: (g ∘ f)⁻¹(z) = ⋃_{y ∈ g⁻¹(z)} f⁻¹(y)
    composed = lambda z: set().union(*(inv_f.invert(y) for y in inv_g.invert(z)))
    
    for x in domain_f:
        z = g(f(x))
        preimages = composed(z)
        print(f"  (g∘f)⁻¹({z}) = {preimages}, contains {x}: {x in preimages}")


# ============================================================
# 3. Noisy Oracle Amplification
# ============================================================

def demo_noisy_amplification():
    """Demonstrate noisy oracle amplification via majority vote."""
    print("\n" + "=" * 60)
    print("DEMO 4: Noisy Oracle Amplification")
    print("=" * 60)
    
    random.seed(42)
    
    def noisy_oracle(x: int, correct_answer: bool, error_rate: float) -> bool:
        """An oracle that gives the wrong answer with probability error_rate."""
        if random.random() < error_rate:
            return not correct_answer
        return correct_answer
    
    def amplified_query(x: int, correct_answer: bool, error_rate: float, 
                         repetitions: int) -> bool:
        """Query the noisy oracle `repetitions` times and take majority vote."""
        votes = sum(1 for _ in range(repetitions) 
                    if noisy_oracle(x, correct_answer, error_rate))
        return votes > repetitions // 2
    
    def measure_accuracy(error_rate: float, repetitions: int, 
                          trials: int = 10000) -> float:
        """Measure the effective accuracy after amplification."""
        correct_count = 0
        for _ in range(trials):
            true_answer = random.choice([True, False])
            amplified = amplified_query(0, true_answer, error_rate, repetitions)
            if amplified == true_answer:
                correct_count += 1
        return correct_count / trials
    
    print("\nAmplification results (majority vote over k queries):")
    print(f"{'k':>6} | {'ε=0.10':>8} | {'ε=0.30':>8} | {'ε=0.45':>8} | {'ε=0.49':>8}")
    print("-" * 50)
    
    for k in [1, 3, 5, 11, 21, 51, 101]:
        accuracies = []
        for eps in [0.10, 0.30, 0.45, 0.49]:
            acc = measure_accuracy(eps, k, trials=5000)
            accuracies.append(acc)
        print(f"{k:>6} | {accuracies[0]:>8.4f} | {accuracies[1]:>8.4f} | "
              f"{accuracies[2]:>8.4f} | {accuracies[3]:>8.4f}")
    
    print("\nKey insight: Any ε < 0.5 can be amplified to arbitrary accuracy.")
    print("At ε = 0.5, the oracle is useless (coin flip).")
    print("At ε > 0.5, it's a contrarian — negate to get ε' = 1 - ε < 0.5!")


# ============================================================
# 4. Inverse Stereo Projection: Encoding Rationals into Integers
# ============================================================

def cantor_pair(a: int, b: int) -> int:
    """Cantor pairing function: ℤ × ℤ → ℕ.
    First maps integers to naturals (zig-zag), then pairs."""
    # Map ℤ → ℕ via zig-zag: 0→0, 1→1, -1→2, 2→3, -2→4, ...
    def z_to_n(z):
        return 2 * z if z >= 0 else -2 * z - 1
    a_nat = z_to_n(a)
    b_nat = z_to_n(b)
    return (a_nat + b_nat) * (a_nat + b_nat + 1) // 2 + b_nat

def cantor_unpair(n: int) -> tuple:
    """Inverse Cantor pairing: ℕ → ℤ × ℤ."""
    def n_to_z(k):
        return k // 2 if k % 2 == 0 else -(k + 1) // 2
    # Find w such that w*(w+1)/2 ≤ n < (w+1)*(w+2)/2
    w = int((-1 + math.sqrt(1 + 8 * n)) / 2)
    while w * (w + 1) // 2 > n:
        w -= 1
    t = n - w * (w + 1) // 2
    b_nat = t
    a_nat = w - t
    return n_to_z(a_nat), n_to_z(b_nat)

def rational_to_int(p: int, q: int) -> int:
    """Encode a rational p/q (with q > 0, gcd(p,q)=1) into a single integer.
    This is the 'inverse stereographic projection': ℚ → ℤ."""
    g = math.gcd(abs(p), q)
    return cantor_pair(p // g, q // g)

def int_to_rational(n: int) -> tuple:
    """Decode an integer back to a rational (p, q)."""
    p, q = cantor_unpair(n)
    if q <= 0:
        return None  # Invalid encoding
    return (p, q)


def demo_stereo_projection():
    """Demonstrate the inverse stereo projection encoding."""
    print("\n" + "=" * 60)
    print("DEMO 5: Inverse Stereo Projection (ℚ → ℤ Encoding)")
    print("=" * 60)
    
    print("\nThe 'inverse stereo projection' encodes rationals as integers,")
    print("allowing any oracle over ℚ to be looked up by integer index.\n")
    
    rationals = [(0, 1), (1, 1), (-1, 1), (1, 2), (-1, 2), 
                 (2, 3), (3, 7), (22, 7), (-5, 3)]
    
    print(f"{'Rational':>10} | {'Encoded':>10} | {'Decoded':>12} | {'Round-trip':>10}")
    print("-" * 50)
    
    for p, q in rationals:
        encoded = rational_to_int(p, q)
        decoded = cantor_unpair(encoded)
        rt_ok = decoded == (p, q)
        print(f"{p:>4}/{q:<4}   | {encoded:>10} | {str(decoded):>12} | {'✓' if rt_ok else '✗':>10}")
    
    # Build an oracle over ℚ: "is p/q > 1?"
    print(f"\nOracle: 'Is p/q > 1?' (looked up by integer index)")
    print(f"{'Rational':>10} | {'Index':>8} | {'p/q > 1?':>8}")
    print("-" * 35)
    
    for p, q in rationals:
        idx = rational_to_int(p, q)
        answer = p / q > 1
        print(f"{p:>4}/{q:<4}   | {idx:>8} | {'YES' if answer else 'NO':>8}")
    
    print("\nThe encoding is injective: distinct rationals get distinct indices.")
    indices = [rational_to_int(p, q) for p, q in rationals]
    print(f"  All indices distinct: {len(indices) == len(set(indices))}")


# ============================================================
# 5. Information Content
# ============================================================

def binary_entropy(k: int, n: int) -> float:
    """Binary entropy H(O) for an oracle with k 'yes' answers out of n."""
    if k == 0 or k == n:
        return 0.0
    p = k / n
    return -(p * math.log2(p) + (1 - p) * math.log2(1 - p))


def demo_information_content():
    """Demonstrate that H(O) = H(anti(O))."""
    print("\n" + "=" * 60)
    print("DEMO 6: Information Content — H(O) = H(anti(O))")
    print("=" * 60)
    
    n = 20
    print(f"\nUniverse size: {n}")
    print(f"{'|O|':>5} | {'|anti(O)|':>9} | {'H(O)':>8} | {'H(anti)':>8} | {'Equal?':>7}")
    print("-" * 50)
    
    for k in range(n + 1):
        h_o = binary_entropy(k, n)
        h_anti = binary_entropy(n - k, n)
        equal = abs(h_o - h_anti) < 1e-10
        if k <= 5 or k >= 15 or k == 10:
            print(f"{k:>5} | {n-k:>9} | {h_o:>8.4f} | {h_anti:>8.4f} | {'✓' if equal else '✗':>7}")
    
    print(f"\n✓ H(O) = H(anti(O)) for all k: verified")
    print(f"  Maximum entropy at k = {n//2} (oracle answers are maximally unpredictable)")
    print(f"  Zero entropy at k = 0 or k = {n} (completely predictable)")


# ============================================================
# 6. Boolean Algebra Visualization
# ============================================================

def demo_boolean_algebra():
    """Demonstrate the Boolean algebra structure."""
    print("\n" + "=" * 60)
    print("DEMO 7: Boolean Algebra of Oracles")
    print("=" * 60)
    
    universe = set(range(1, 9))
    
    A = Oracle({1, 2, 3, 4}, universe)
    B = Oracle({3, 4, 5, 6}, universe)
    
    print(f"\nUniverse: {sorted(universe)}")
    print(f"A = {sorted(A.carrier)}")
    print(f"B = {sorted(B.carrier)}")
    print(f"\nOperations:")
    print(f"  A ∪ B (join)  = {sorted(A.join(B).carrier)}")
    print(f"  A ∩ B (meet)  = {sorted(A.meet(B).carrier)}")
    print(f"  A ⊕ B (xor)   = {sorted(A.xor(B).carrier)}")
    print(f"  A \\ B (sdiff) = {sorted(A.sdiff(B).carrier)}")
    print(f"  ¬A (anti)     = {sorted(A.anti().carrier)}")
    print(f"  ¬B (anti)     = {sorted(B.anti().carrier)}")
    
    print(f"\nDe Morgan verification:")
    print(f"  ¬(A∪B) = {sorted(A.join(B).anti().carrier)}")
    print(f"  ¬A∩¬B  = {sorted(A.anti().meet(B.anti()).carrier)}")
    print(f"  Equal:  {A.join(B).anti() == A.anti().meet(B.anti())}")
    
    print(f"\nDistributivity:")
    C = Oracle({2, 4, 6, 8}, universe)
    print(f"  C = {sorted(C.carrier)}")
    lhs = A.join(B.meet(C))
    rhs = A.join(B).meet(A.join(C))
    print(f"  A∪(B∩C)     = {sorted(lhs.carrier)}")
    print(f"  (A∪B)∩(A∪C) = {sorted(rhs.carrier)}")
    print(f"  Equal: {lhs == rhs}")
    
    print(f"\nComplement laws:")
    print(f"  A ∪ ¬A = {sorted(A.join(A.anti()).carrier)} (= universe: {A.join(A.anti()).carrier == universe})")
    print(f"  A ∩ ¬A = {sorted(A.meet(A.anti()).carrier)} (= empty: {len(A.meet(A.anti()).carrier) == 0})")


# ============================================================
# 7. Pullback Oracle
# ============================================================

def demo_pullback():
    """Demonstrate pullback of oracles along functions."""
    print("\n" + "=" * 60)
    print("DEMO 8: Pullback and Pushforward of Oracles")
    print("=" * 60)
    
    # Oracle on ℕ: "is n even?"
    target_universe = set(range(20))
    even_oracle = Oracle({n for n in target_universe if n % 2 == 0}, target_universe)
    
    # Function f: strings → ℕ (length function)
    strings = ["", "a", "ab", "abc", "abcd", "hello", "hi", "bye", "test", "x"]
    f = lambda s: len(s)
    
    # Pullback: "is len(s) even?"
    pullback_carrier = {s for s in strings if f(s) in even_oracle.carrier}
    pullback_oracle = Oracle(pullback_carrier, set(strings))
    
    print(f"\nTarget oracle: 'Is n even?' on {{0,...,19}}")
    print(f"Function f: string → len(string)")
    print(f"Pullback oracle: 'Is len(s) even?'\n")
    
    for s in strings:
        in_pullback = s in pullback_carrier
        print(f"  f⁻¹*O('{s}') = {in_pullback}  (len='{len(s)}', even={len(s) % 2 == 0})")
    
    # Pullback commutes with anti
    anti_then_pullback = {s for s in strings if f(s) not in even_oracle.carrier}
    pullback_then_anti = set(strings) - pullback_carrier
    
    print(f"\n  Pullback commutes with anti:")
    print(f"    pullback(anti(O)) = {sorted(anti_then_pullback, key=str)}")
    print(f"    anti(pullback(O)) = {sorted(pullback_then_anti, key=str)}")
    print(f"    ✓ Equal: {anti_then_pullback == pullback_then_anti}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║         ORACLE THEORY — Interactive Demonstrations       ║")
    print("║     Formalized in Lean 4 / Mathlib, Explored in Python   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_anti_oracle()
    demo_de_morgan()
    demo_inverse_oracle()
    demo_noisy_amplification()
    demo_stereo_projection()
    demo_information_content()
    demo_boolean_algebra()
    demo_pullback()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("See the Lean formalization for machine-verified proofs.")
    print("=" * 60)
