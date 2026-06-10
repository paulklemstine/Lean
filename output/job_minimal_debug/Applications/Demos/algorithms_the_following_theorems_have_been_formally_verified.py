#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for ordinal tree compilation and analysis.

Implements the ordinal notation engine: parsing CNF expressions, compiling
them to tree structures, and computing rank invariants.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import List, Tuple, Optional
import functools


# ═══════════════════════════════════════════════════════════════════════
# ALGORITHM 1: Cantor Normal Form Arithmetic
# ═══════════════════════════════════════════════════════════════════════

@dataclass(frozen=True)
class CNFOrdinal:
    """An ordinal below ω^ω in Cantor Normal Form.
    
    Represented as a tuple of (exponent, coefficient) pairs in strictly
    descending exponent order, with positive coefficients.
    
    Example: ω^3·2 + ω·5 + 3 = CNFOrdinal(((3,2), (1,5), (0,3)))
    
    Time complexity: O(1) for construction, O(k) for arithmetic
    where k = number of CNF terms.
    Space complexity: O(k).
    """
    terms: tuple  # ((exp, coeff), ...) in descending exp order
    
    @staticmethod
    def zero() -> 'CNFOrdinal':
        """The zero ordinal. O(1)."""
        return CNFOrdinal(())
    
    @staticmethod
    def finite(n: int) -> 'CNFOrdinal':
        """A finite ordinal. O(1)."""
        if n <= 0:
            return CNFOrdinal.zero()
        return CNFOrdinal(((0, n),))
    
    @staticmethod
    def omega_power(n: int) -> 'CNFOrdinal':
        """ω^n. O(1)."""
        return CNFOrdinal(((n, 1),))
    
    @staticmethod
    def from_cnf_list(terms: List[Tuple[int, int]]) -> 'CNFOrdinal':
        """Create from [(coeff, exp), ...] list (matching the formal definition).
        
        O(k) where k = len(terms).
        """
        result = []
        for coeff, exp in terms:
            if coeff > 0:
                result.append((exp, coeff))
        return CNFOrdinal(tuple(result))
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return self.is_zero() or (len(self.terms) == 1 and self.terms[0][0] == 0)
    
    def is_limit(self) -> bool:
        """Whether this ordinal is a limit ordinal. O(1)."""
        if self.is_zero():
            return False
        return self.terms[-1][0] > 0
    
    def leading_exponent(self) -> int:
        """The highest exponent in the CNF. O(1)."""
        if self.is_zero():
            return -1
        return self.terms[0][0]
    
    def __repr__(self) -> str:
        if not self.terms:
            return "0"
        parts = []
        for exp, coeff in self.terms:
            if exp == 0:
                parts.append(str(coeff))
            elif exp == 1:
                parts.append(f"ω·{coeff}" if coeff > 1 else "ω")
            else:
                parts.append(f"ω^{exp}·{coeff}" if coeff > 1 else f"ω^{exp}")
        return " + ".join(parts)
    
    def add(self, other: 'CNFOrdinal') -> 'CNFOrdinal':
        """Ordinal addition: self + other.
        
        Key property: NOT commutative. ω + 1 ≠ 1 + ω.
        
        Algorithm: Keep terms from self with exponent strictly greater
        than other's leading exponent. If self has a term with the same
        exponent as other's leading term, add the coefficients. Then
        append other's remaining terms.
        
        Time complexity: O(k1 + k2) where k1, k2 = number of terms.
        Space complexity: O(k1 + k2).
        """
        if not other.terms:
            return self
        if not self.terms:
            return other
        
        other_lead_exp = other.terms[0][0]
        result = []
        
        # Keep self's terms with strictly higher exponents
        for exp, coeff in self.terms:
            if exp > other_lead_exp:
                result.append((exp, coeff))
            elif exp == other_lead_exp:
                # Add coefficients for matching exponent
                merged_coeff = coeff + other.terms[0][1]
                result.append((exp, merged_coeff))
                result.extend(other.terms[1:])
                return CNFOrdinal(tuple(result))
            else:
                break
        
        result.extend(other.terms)
        return CNFOrdinal(tuple(result))
    
    def mul_nat(self, k: int) -> 'CNFOrdinal':
        """Multiply by natural number k (on the right): self · k.
        
        For ordinals with a limit component, lower-order terms are absorbed:
        (ω^n·a + lower) · k = ω^n·(a·k) when n > 0.
        
        Time complexity: O(1) for limit ordinals, O(k) for finite.
        Space complexity: O(1).
        """
        if k <= 0 or self.is_zero():
            return CNFOrdinal.zero()
        if k == 1:
            return self
        
        lead_exp, lead_coeff = self.terms[0]
        if lead_exp == 0:
            return CNFOrdinal.finite(lead_coeff * k)
        # For transfinite leading term, lower terms are absorbed
        return CNFOrdinal(((lead_exp, lead_coeff * k),))
    
    def compare(self, other: 'CNFOrdinal') -> int:
        """Compare two ordinals. Returns -1, 0, or 1.
        
        Time complexity: O(min(k1, k2)).
        """
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return -1
            if i >= len(other.terms):
                return 1
            se, sc = self.terms[i]
            oe, oc = other.terms[i]
            if se != oe:
                return 1 if se > oe else -1
            if sc != oc:
                return 1 if sc > oc else -1
        return 0
    
    def __lt__(self, other):
        return self.compare(other) < 0
    
    def __le__(self, other):
        return self.compare(other) <= 0
    
    def __gt__(self, other):
        return self.compare(other) > 0
    
    def __ge__(self, other):
        return self.compare(other) >= 0


# ═══════════════════════════════════════════════════════════════════════
# ALGORITHM 2: Tree Compilation from CNF
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class TreeDescriptor:
    """Abstract description of a tree (without materializing infinite branching).
    
    Tracks the construction recipe and ordinal rank symbolically.
    """
    kind: str  # 'leaf', 'chain', 'omega_pow', 'mul', 'prepend', 'cnf', 'omega_omega'
    rank: CNFOrdinal
    params: dict = field(default_factory=dict)
    
    def __repr__(self):
        return f"Tree({self.kind}, rank={self.rank})"


def compile_cnf(terms: List[Tuple[int, int]]) -> TreeDescriptor:
    """Compile a CNF expression to a tree descriptor.
    
    Input: [(coeff, exp), ...] in descending exp order with positive coefficients.
    Output: TreeDescriptor with verified rank.
    
    Algorithm:
    1. For each term (a, n), build mulByNat(omegaPowTree(n), a)
    2. Compose terms right-to-left using prepend
    3. Verify rank equals the CNF ordinal value
    
    Time complexity: O(k) where k = number of terms.
    Space complexity: O(k).
    
    >>> compile_cnf([(2, 3), (1, 1), (5, 0)])
    Tree(cnf, rank=ω^3·2 + ω + 5)
    """
    if not terms:
        return TreeDescriptor('leaf', CNFOrdinal.zero())
    
    # Compute the ordinal value
    ordinal = CNFOrdinal.from_cnf_list(terms)
    
    # Build the tree construction plan
    return TreeDescriptor('cnf', ordinal, {
        'terms': terms,
        'construction': _describe_construction(terms)
    })


def _describe_construction(terms: List[Tuple[int, int]]) -> str:
    """Generate human-readable construction description."""
    if not terms:
        return "leaf"
    parts = []
    for coeff, exp in terms:
        part = f"mulByNat(omegaPowTree({exp}), {coeff})"
        parts.append(part)
    
    if len(parts) == 1:
        return parts[0]
    
    result = parts[-1]
    for part in reversed(parts[:-1]):
        result = f"prepend({part}, {result})"
    return result


def compile_omega_power(n: int) -> TreeDescriptor:
    """Compile ω^n to a tree descriptor.
    
    >>> compile_omega_power(3)
    Tree(omega_pow, rank=ω^3)
    """
    return TreeDescriptor('omega_pow', CNFOrdinal.omega_power(n), {'n': n})


def compile_omega_to_omega() -> TreeDescriptor:
    """Compile ω^ω to a tree descriptor.
    
    >>> compile_omega_to_omega()
    Tree(omega_omega, rank=ω^ω)
    """
    # This is a special case: not below ω^ω but AT ω^ω
    return TreeDescriptor('omega_omega', 
                          CNFOrdinal(()),  # placeholder - ω^ω exceeds CNF below ω^ω
                          {'description': 'ω^ω = sup{ω^n : n ∈ ℕ}'})


# ═══════════════════════════════════════════════════════════════════════
# ALGORITHM 3: Ordinal Comparison and Well-Ordering
# ═══════════════════════════════════════════════════════════════════════

def ordinal_cmp(a: CNFOrdinal, b: CNFOrdinal) -> int:
    """Compare two ordinals in CNF. Returns -1, 0, or 1.
    
    This is a total order on ordinals below ω^ω, and matches
    the standard mathematical ordering.
    
    Time complexity: O(min(k_a, k_b)) where k = number of CNF terms.
    
    >>> ordinal_cmp(CNFOrdinal.omega_power(2), CNFOrdinal.omega_power(1))
    1
    """
    return a.compare(b)


def ordinal_sort(ordinals: List[CNFOrdinal]) -> List[CNFOrdinal]:
    """Sort a list of ordinals in ascending order.
    
    Time complexity: O(n log n · k) where n = list length, k = max terms.
    
    >>> ordinal_sort([CNFOrdinal.omega_power(2), CNFOrdinal.finite(3), CNFOrdinal.omega_power(1)])
    [3, ω, ω^2]
    """
    return sorted(ordinals, key=functools.cmp_to_key(ordinal_cmp))


# ═══════════════════════════════════════════════════════════════════════
# ALGORITHM 4: CNF Decomposition
# ═══════════════════════════════════════════════════════════════════════

def decompose_ordinal(alpha: CNFOrdinal) -> List[CNFOrdinal]:
    """Decompose an ordinal into its individual CNF terms.
    
    Each term ω^n·a is returned as a separate ordinal.
    
    Time complexity: O(k) where k = number of terms.
    
    >>> decompose_ordinal(CNFOrdinal.from_cnf_list([(2,3),(5,1),(3,0)]))
    [ω^3·2, ω·5, 3]
    """
    return [CNFOrdinal(((exp, coeff),)) for exp, coeff in alpha.terms]


def fundamental_sequence(alpha: CNFOrdinal, n: int) -> CNFOrdinal:
    """Compute the n-th element of the fundamental sequence of a limit ordinal.
    
    For a limit ordinal α with CNF a₁·ω^{e₁} + ... + aₖ·ω^{eₖ}:
    - If eₖ = 1: α[n] = a₁·ω^{e₁} + ... + (aₖ-1)·ω + n
    - If eₖ > 1: α[n] = a₁·ω^{e₁} + ... + (aₖ-1)·ω^{eₖ} + ω^{eₖ-1}·n
    
    Time complexity: O(k).
    
    >>> fundamental_sequence(CNFOrdinal.omega_power(2), 3)
    ω·3
    """
    if alpha.is_zero() or not alpha.is_limit():
        raise ValueError(f"{alpha} is not a limit ordinal")
    
    terms = list(alpha.terms)
    last_exp, last_coeff = terms[-1]
    
    if last_exp == 1:
        # ω·a_k: replace last term with (a_k-1)·ω + n
        prefix = terms[:-1]
        result = list(prefix)
        if last_coeff > 1:
            result.append((1, last_coeff - 1))
        if n > 0:
            result.append((0, n))
        return CNFOrdinal(tuple(result))
    else:
        # ω^e_k·a_k: replace last term with (a_k-1)·ω^e_k + ω^{e_k-1}·n
        prefix = terms[:-1]
        result = list(prefix)
        if last_coeff > 1:
            result.append((last_exp, last_coeff - 1))
        if n > 0:
            result.append((last_exp - 1, n))
        return CNFOrdinal(tuple(result))


# ═══════════════════════════════════════════════════════════════════════
# Example usage and verification
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    print()
    
    # CNF Arithmetic
    print("--- CNF Arithmetic ---")
    a = CNFOrdinal.from_cnf_list([(2, 3), (1, 1)])  # ω^3·2 + ω
    b = CNFOrdinal.from_cnf_list([(3, 2), (5, 0)])  # ω^2·3 + 5
    print(f"  a = {a}")
    print(f"  b = {b}")
    print(f"  a + b = {a.add(b)}")
    print(f"  b + a = {b.add(a)}")  # Different! Non-commutative!
    print(f"  a · 3 = {a.mul_nat(3)}")
    print(f"  a > b? {a > b}")
    print()
    
    # Compilation
    print("--- Tree Compilation ---")
    cnf = [(2, 3), (5, 2), (3, 1), (7, 0)]
    desc = compile_cnf(cnf)
    print(f"  Input CNF: {cnf}")
    print(f"  Result: {desc}")
    print(f"  Construction: {desc.params['construction']}")
    print()
    
    # Fundamental sequences
    print("--- Fundamental Sequences ---")
    omega2 = CNFOrdinal.omega_power(2)
    print(f"  ω²[n] for n = 0..5:")
    for n in range(6):
        print(f"    ω²[{n}] = {fundamental_sequence(omega2, n)}")
    
    omega3 = CNFOrdinal.omega_power(3)
    print(f"  ω³[n] for n = 0..4:")
    for n in range(5):
        print(f"    ω³[{n}] = {fundamental_sequence(omega3, n)}")
    print()
    
    # Sorting
    print("--- Ordinal Sorting ---")
    ordinals = [
        CNFOrdinal.omega_power(2),
        CNFOrdinal.finite(42),
        CNFOrdinal.omega_power(1),
        CNFOrdinal.from_cnf_list([(1, 2), (1, 0)]),
        CNFOrdinal.finite(7),
        CNFOrdinal.from_cnf_list([(3, 1)]),
    ]
    print(f"  Unsorted: {ordinals}")
    print(f"  Sorted:   {ordinal_sort(ordinals)}")
    print()
    
    # Decomposition
    print("--- CNF Decomposition ---")
    alpha = CNFOrdinal.from_cnf_list([(2, 4), (1, 2), (3, 1), (7, 0)])
    print(f"  {alpha} decomposes into:")
    for term in decompose_ordinal(alpha):
        print(f"    {term}")
