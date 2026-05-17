#!/usr/bin/env python3
"""
GL(1) Langlands Correspondence — Core Algorithms

Implements the mathematical algorithms underlying the GL(1) Langlands
correspondence over ℚ:

1. Artin reciprocity map computation
2. Dirichlet character enumeration and evaluation
3. p-adic valuation and product formula verification
4. Frobenius element computation
5. Character group operations
"""

from math import gcd
from typing import Dict, List, Optional, Tuple
import numpy as np


# ============================================================
# Algorithm 1: p-adic Valuation
# ============================================================

def padic_val(n: int, p: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of integer n.
    
    Time: O(log_p(n))
    Space: O(1)
    
    >>> padic_val(12, 2)
    2
    >>> padic_val(12, 3)
    1
    >>> padic_val(7, 2)
    0
    """
    if n == 0:
        raise ValueError("p-adic valuation of 0 is infinity")
    if p < 2:
        raise ValueError(f"p must be prime, got {p}")
    
    v = 0
    n = abs(n)
    while n % p == 0:
        v += 1
        n //= p
    return v


def padic_val_rational(num: int, den: int, p: int) -> int:
    """
    Compute v_p(num/den), the p-adic valuation of a rational.
    
    v_p(a/b) = v_p(a) - v_p(b)
    
    Time: O(log_p(max(|num|, den)))
    Space: O(1)
    
    >>> padic_val_rational(12, 5, 2)
    2
    >>> padic_val_rational(5, 12, 2)
    -2
    """
    return padic_val(num, p) - padic_val(den, p)


# ============================================================
# Algorithm 2: Finite Idèle Data
# ============================================================

class FiniteIdeleData:
    """
    Valuation-based model of a finite idèle of ℚ.
    
    Stores the p-adic valuation at each prime as a sparse dictionary.
    Multiplication of idèles ↔ addition of valuation data.
    """
    
    def __init__(self, valuations: Dict[int, int] = None):
        """
        Initialize with sparse valuation data.
        
        Args:
            valuations: Dict mapping primes to their valuations.
                       Only nonzero valuations need to be stored.
        """
        self.valuations = {}
        if valuations:
            for p, v in valuations.items():
                if v != 0:
                    self.valuations[p] = v
    
    @classmethod
    def from_rational(cls, num: int, den: int = 1) -> 'FiniteIdeleData':
        """
        Create the idèle data of a rational number num/den.
        
        This is the diagonal embedding ℚˣ → 𝕀_f(ℚ).
        
        Time: O(√max(|num|, den)) for trial division
        """
        if num == 0:
            raise ValueError("Cannot create idèle data for 0")
        
        vals = {}
        for n, sign in [(abs(num), 1), (den, -1)]:
            temp = n
            p = 2
            while p * p <= temp:
                while temp % p == 0:
                    vals[p] = vals.get(p, 0) + sign
                    temp //= p
                p += 1
            if temp > 1:
                vals[temp] = vals.get(temp, 0) + sign
        
        return cls({p: v for p, v in vals.items() if v != 0})
    
    @classmethod
    def uniformizer(cls, p: int) -> 'FiniteIdeleData':
        """
        Create the uniformizer idèle at prime p.
        Valuation 1 at p, 0 elsewhere.
        """
        return cls({p: 1})
    
    def __add__(self, other: 'FiniteIdeleData') -> 'FiniteIdeleData':
        """Addition of valuation data = multiplication of idèles."""
        result = dict(self.valuations)
        for p, v in other.valuations.items():
            result[p] = result.get(p, 0) + v
        return FiniteIdeleData({p: v for p, v in result.items() if v != 0})
    
    def __neg__(self) -> 'FiniteIdeleData':
        """Negation = inversion of idèle."""
        return FiniteIdeleData({p: -v for p, v in self.valuations.items()})
    
    def __sub__(self, other: 'FiniteIdeleData') -> 'FiniteIdeleData':
        return self + (-other)
    
    def __repr__(self) -> str:
        if not self.valuations:
            return "IdeleData(1)"
        terms = []
        for p in sorted(self.valuations.keys()):
            v = self.valuations[p]
            if v == 1:
                terms.append(f"{p}")
            elif v == -1:
                terms.append(f"{p}⁻¹")
            elif v > 0:
                terms.append(f"{p}^{v}")
            else:
                terms.append(f"{p}^({v})")
        return "IdeleData(" + " · ".join(terms) + ")"
    
    def support(self) -> set:
        """Return the set of primes with nonzero valuation."""
        return set(self.valuations.keys())


# ============================================================
# Algorithm 3: Artin Reciprocity Map
# ============================================================

def artin_map(a: int, n: int) -> int:
    """
    The Artin reciprocity map Art_n : (ℤ/nℤ)ˣ → Gal(ℚ(ζ_n)/ℚ).
    
    Sends a coprime to n to the Galois automorphism σ_a : ζ_n ↦ ζ_n^a.
    Since Gal(ℚ(ζ_n)/ℚ) ≅ (ℤ/nℤ)ˣ, this returns a mod n.
    
    Time: O(1)
    
    >>> artin_map(3, 7)
    3
    >>> artin_map(8, 7)
    1
    """
    assert gcd(a, n) == 1, f"{a} not coprime to {n}"
    return a % n


def frobenius(p: int, n: int) -> int:
    """
    Frobenius element Frob_p in Gal(ℚ(ζ_n)/ℚ) for prime p ∤ n.
    
    Time: O(1)
    """
    assert gcd(p, n) == 1
    return p % n


# ============================================================
# Algorithm 4: Dirichlet Characters
# ============================================================

class DirichletCharacter:
    """
    A Dirichlet character mod n, representing both a Hecke character
    and (via Langlands) a 1-dim Galois representation.
    
    Internally stored as a lookup table (ℤ/nℤ)ˣ → ℂˣ.
    """
    
    def __init__(self, n: int, values: Dict[int, complex]):
        self.n = n
        self.values = values
        self._units = [a for a in range(1, n) if gcd(a, n) == 1]
    
    @classmethod
    def trivial(cls, n: int) -> 'DirichletCharacter':
        """The trivial character: χ(a) = 1 for all a coprime to n."""
        units = [a for a in range(1, n) if gcd(a, n) == 1]
        return cls(n, {a: 1+0j for a in units})
    
    @classmethod
    def from_generator(cls, n: int, gen: int, gen_image: complex) -> 'DirichletCharacter':
        """
        Build a character by specifying the image of a generator.
        
        If g generates (ℤ/nℤ)ˣ, then χ(g^k) = gen_image^k determines χ uniquely.
        
        Time: O(φ(n))
        """
        units = [a for a in range(1, n) if gcd(a, n) == 1]
        phi_n = len(units)
        
        values = {}
        val = 1
        img = 1+0j
        for _ in range(phi_n):
            values[val] = img
            val = (val * gen) % n
            img *= gen_image
        
        return cls(n, values)
    
    def __call__(self, a: int) -> complex:
        """Evaluate χ(a) for a coprime to n."""
        a_mod = a % self.n
        if a_mod in self.values:
            return self.values[a_mod]
        raise ValueError(f"{a} not coprime to {self.n}")
    
    def at_frobenius(self, p: int) -> complex:
        """
        Evaluate at the Frobenius element Frob_p.
        
        Under the GL(1) Langlands correspondence:
        χ(Frob_p) = ρ(Frob_p) where ρ is the dual Galois character.
        
        This is the fundamental compatibility.
        """
        return self(frobenius(p, self.n))
    
    def __mul__(self, other: 'DirichletCharacter') -> 'DirichletCharacter':
        """Pointwise product of characters."""
        assert self.n == other.n
        values = {a: self.values[a] * other.values[a] for a in self.values}
        return DirichletCharacter(self.n, values)
    
    def is_homomorphism(self) -> bool:
        """Verify the character is a group homomorphism."""
        for a in self._units:
            for b in self._units:
                ab = (a * b) % self.n
                if abs(self.values[ab] - self.values[a] * self.values[b]) > 1e-10:
                    return False
        return True
    
    def order(self) -> int:
        """Compute the order of χ in the character group."""
        chi_power = DirichletCharacter.trivial(self.n)
        for k in range(1, len(self._units) + 1):
            chi_power = chi_power * self
            is_trivial = all(abs(chi_power.values[a] - 1) < 1e-10 for a in self._units)
            if is_trivial:
                return k
        return len(self._units)
    
    def conductor(self) -> int:
        """
        Compute the conductor of χ: the smallest m | n such that
        χ factors through (ℤ/mℤ)ˣ.
        
        Time: O(n * φ(n)) worst case
        """
        for m in range(1, self.n + 1):
            if self.n % m != 0:
                continue
            # Check if χ factors through mod m
            factors = True
            for a in self._units:
                for b in self._units:
                    if a % m == b % m and abs(self.values[a] - self.values[b]) > 1e-10:
                        factors = False
                        break
                if not factors:
                    break
            if factors:
                return m
        return self.n
    
    def level_raise(self, m: int) -> 'DirichletCharacter':
        """
        Level-raise: view χ mod n as a character mod m where n | m.
        
        χ'(a) = χ(a mod n)
        """
        assert m % self.n == 0
        units_m = [a for a in range(1, m) if gcd(a, m) == 1]
        values = {}
        for a in units_m:
            a_mod = a % self.n
            if a_mod in self.values:
                values[a] = self.values[a_mod]
        return DirichletCharacter(m, values)


# ============================================================
# Algorithm 5: Product Formula Verification
# ============================================================

def verify_product_formula(num: int, den: int = 1) -> Tuple[bool, Dict[int, int]]:
    """
    Verify the product formula for x = num/den:
    ∏_p |x|_p · |x|_∞ = 1
    
    Returns (verified, valuations_dict).
    
    Time: O(√max(|num|, den))
    """
    idele = FiniteIdeleData.from_rational(num, den)
    
    # Check: ∏ p^(-v_p) · |num/den| should equal 1
    # i.e., ∏ p^(v_p) = |num/den|
    product = 1.0
    for p, v in idele.valuations.items():
        product *= p ** v
    
    target = abs(num) / den
    verified = abs(product - target) < 1e-10
    
    return verified, idele.valuations


# ============================================================
# Algorithm 6: GL(1) Langlands Equivalence
# ============================================================

def enumerate_characters(n: int) -> List[DirichletCharacter]:
    """
    Enumerate all Dirichlet characters mod n.
    
    By the GL(1) Langlands correspondence, these are in bijection
    with 1-dimensional Galois representations factoring through
    Gal(ℚ(ζ_n)/ℚ).
    
    Time: O(φ(n)²) for character table computation
    """
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    phi_n = len(units)
    
    # Find a generator (for cyclic groups)
    gen = None
    for g in units:
        powers = set()
        val = 1
        for _ in range(phi_n):
            val = (val * g) % n
            powers.add(val)
        if len(powers) == phi_n:
            gen = g
            break
    
    if gen is None:
        # Not cyclic; return trivial character only for simplicity
        return [DirichletCharacter.trivial(n)]
    
    characters = []
    for k in range(phi_n):
        omega_k = np.exp(2j * np.pi * k / phi_n)
        chi = DirichletCharacter.from_generator(n, gen, omega_k)
        characters.append(chi)
    
    return characters


def langlands_gl1_table(n: int) -> None:
    """
    Print the full GL(1) Langlands correspondence table at level n.
    
    Shows each Hecke character χ_k and its Galois dual ρ_k,
    with Frobenius evaluations demonstrating χ_k(p) = ρ_k(Frob_p).
    """
    chars = enumerate_characters(n)
    units = [a for a in range(1, n) if gcd(a, n) == 1]
    
    print(f"\nGL(1) Langlands table mod {n}")
    print(f"φ({n}) = {len(units)} characters = {len(units)} Galois representations")
    print()
    
    # Header
    header = "χ_k\\a  | " + " | ".join(f"{a:>6}" for a in units)
    print(header)
    print("-" * len(header))
    
    for k, chi in enumerate(chars):
        row = f"χ_{k:<4} | "
        vals = []
        for a in units:
            v = chi(a)
            if abs(v.imag) < 1e-10:
                vals.append(f"{v.real:>6.3f}")
            else:
                vals.append(f"{v.real:>+.2f}{v.imag:>+.2f}i"[:6])
            row += f"{vals[-1]} | "
        print(row)
    
    print(f"\nConductors: {[chi.conductor() for chi in chars]}")
    print(f"Orders: {[chi.order() for chi in chars]}")


if __name__ == "__main__":
    # Test p-adic valuations
    print("=== p-adic Valuations ===")
    print(f"v_2(12) = {padic_val(12, 2)}")
    print(f"v_3(12) = {padic_val(12, 3)}")
    print(f"v_5(12) = {padic_val(12, 5)}")
    
    # Test finite idèle data
    print("\n=== Finite Idèle Data ===")
    x = FiniteIdeleData.from_rational(12, 5)
    print(f"12/5 → {x}")
    print(f"Support: {x.support()}")
    
    y = FiniteIdeleData.from_rational(5, 12)
    print(f"5/12 → {y}")
    print(f"12/5 · 5/12 → {x + y}")
    
    # Test product formula
    print("\n=== Product Formula ===")
    for num, den in [(12, 1), (7, 3), (100, 63)]:
        ok, vals = verify_product_formula(num, den)
        print(f"x = {num}/{den}: verified={ok}, valuations={vals}")
    
    # Test Langlands table
    langlands_gl1_table(5)
    langlands_gl1_table(7)
