#!/usr/bin/env python3
"""
Algorithms for Transfinite Game Values

Type-hinted implementations of the core algorithms from the formalization.
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Optional, Callable, Iterator
from enum import Enum


# === Ordinal Arithmetic (Cantor Normal Form) ===

@dataclass(frozen=True, order=False)
class CNFOrdinal:
    """Ordinal number in Cantor Normal Form (CNF).
    
    Every ordinal below ε₀ can be uniquely written as:
        ω^(e_1) · c_1 + ω^(e_2) · c_2 + ... + ω^(e_k) · c_k
    where e_1 > e_2 > ... > e_k and each c_i is a positive integer.
    
    We represent this as a tuple of (exponent, coefficient) pairs.
    """
    terms: tuple[tuple[CNFOrdinal, int], ...] = ()
    
    @staticmethod
    def zero() -> CNFOrdinal:
        return CNFOrdinal()
    
    @staticmethod
    def nat(n: int) -> CNFOrdinal:
        """Create a finite ordinal."""
        if n <= 0:
            return CNFOrdinal.zero()
        return CNFOrdinal(((CNFOrdinal.zero(), n),))
    
    @staticmethod
    def omega_to(e: CNFOrdinal, c: int = 1) -> CNFOrdinal:
        """Create ω^e · c."""
        if c <= 0:
            return CNFOrdinal.zero()
        return CNFOrdinal(((e, c),))
    
    @staticmethod
    def omega() -> CNFOrdinal:
        """The ordinal ω."""
        return CNFOrdinal.omega_to(CNFOrdinal.nat(1))
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return self.is_zero() or (
            len(self.terms) == 1 and self.terms[0][0].is_zero()
        )
    
    def is_limit(self) -> bool:
        """A limit ordinal has no predecessor."""
        if self.is_zero():
            return False
        _, last_exp = self.terms[-1][0], self.terms[-1]
        return not self.terms[-1][0].is_zero()
    
    def finite_value(self) -> int:
        """Return the finite value if this is a finite ordinal."""
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0][1]
        raise ValueError(f"{self} is not finite")
    
    def leading_exponent(self) -> CNFOrdinal:
        """Return the largest exponent in the CNF."""
        if self.is_zero():
            return CNFOrdinal.zero()
        return self.terms[0][0]
    
    def __lt__(self, other: CNFOrdinal) -> bool:
        """Lexicographic comparison on CNF terms."""
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return True  # self is shorter, hence smaller
            if i >= len(other.terms):
                return False
            e1, c1 = self.terms[i]
            e2, c2 = other.terms[i]
            if e1 < e2:
                return True
            if e2 < e1:
                return False
            if c1 < c2:
                return True
            if c2 < c1:
                return False
        return False
    
    def __le__(self, other: CNFOrdinal) -> bool:
        return self == other or self < other
    
    def __gt__(self, other: CNFOrdinal) -> bool:
        return other < self
    
    def __ge__(self, other: CNFOrdinal) -> bool:
        return other <= self
    
    def __str__(self) -> str:
        if self.is_zero():
            return "0"
        parts = []
        for exp, coeff in self.terms:
            if exp.is_zero():
                parts.append(str(coeff))
            elif exp == CNFOrdinal.nat(1):
                parts.append(f"ω·{coeff}" if coeff > 1 else "ω")
            else:
                base = f"ω^{exp}" if exp.is_finite() else f"ω^({exp})"
                parts.append(f"{base}·{coeff}" if coeff > 1 else base)
        return " + ".join(parts)
    
    def __repr__(self) -> str:
        return f"CNFOrdinal({self})"


def cnf_add(a: CNFOrdinal, b: CNFOrdinal) -> CNFOrdinal:
    """Ordinal addition (NOT commutative: 1 + ω = ω ≠ ω + 1)."""
    if a.is_zero():
        return b
    if b.is_zero():
        return a
    
    b_lead = b.terms[0][0]
    # Drop all terms from a whose exponent is < b's leading exponent
    kept = [t for t in a.terms if not (t[0] < b_lead)]
    
    # If the last kept term has the same exponent as b's first term, merge
    if kept and kept[-1][0] == b.terms[0][0]:
        merged = kept[:-1] + [(kept[-1][0], kept[-1][1] + b.terms[0][1])] + list(b.terms[1:])
        return CNFOrdinal(tuple(merged))
    
    return CNFOrdinal(tuple(kept) + b.terms)


def cnf_mul(a: CNFOrdinal, b: CNFOrdinal) -> CNFOrdinal:
    """Ordinal multiplication for simple cases."""
    if a.is_zero() or b.is_zero():
        return CNFOrdinal.zero()
    if a.is_finite() and b.is_finite():
        return CNFOrdinal.nat(a.finite_value() * b.finite_value())
    if b.is_finite():
        # a * n: multiply the leading coefficient by n
        lead_exp, lead_coeff = a.terms[0]
        return CNFOrdinal(((lead_exp, lead_coeff * b.finite_value()),) + a.terms[1:])
    # General case: simplified for ω^a * ω^b = ω^(a+b)
    if len(a.terms) == 1 and len(b.terms) == 1:
        new_exp = cnf_add(a.terms[0][0], b.terms[0][0])
        return CNFOrdinal.omega_to(new_exp, b.terms[0][1])
    return CNFOrdinal.omega_to(cnf_add(a.leading_exponent(), b.leading_exponent()))


# === Game Tree Data Structures ===

@dataclass
class GamePosition:
    """A position in a well-founded game."""
    name: str
    moves: list[GamePosition] = field(default_factory=list)
    _cached_value: Optional[CNFOrdinal] = field(default=None, repr=False)


def game_value(pos: GamePosition) -> CNFOrdinal:
    """Compute the game value of a position (finite games only).
    
    v(p) = sup { v(q) + 1 : q ∈ moves(p) }
    """
    if pos._cached_value is not None:
        return pos._cached_value
    
    if not pos.moves:
        pos._cached_value = CNFOrdinal.zero()
        return pos._cached_value
    
    max_val = -1
    for child in pos.moves:
        child_val = game_value(child)
        if child_val.is_finite():
            max_val = max(max_val, child_val.finite_value())
    
    pos._cached_value = CNFOrdinal.nat(max_val + 1)
    return pos._cached_value


def build_chain_game(n: int) -> list[GamePosition]:
    """Build a chain game C_n with positions 0, 1, ..., n.
    
    Moves: k → k-1 for k > 0. Position 0 is terminal.
    Game value at position k equals k.
    """
    positions = [GamePosition(name=str(i)) for i in range(n + 1)]
    for i in range(1, n + 1):
        positions[i].moves = [positions[i - 1]]
    return positions


def build_binary_tree_game(depth: int) -> GamePosition:
    """Build a complete binary tree game of given depth.
    
    Each non-leaf has two children. Depth d gives value d.
    """
    if depth == 0:
        return GamePosition(name=f"leaf")
    left = build_binary_tree_game(depth - 1)
    right = build_binary_tree_game(depth - 1)
    return GamePosition(name=f"node_d{depth}", moves=[left, right])


# === The Omega Tower Algorithm ===

def omega_tower(n: int) -> CNFOrdinal:
    """Compute omegaTower(n).
    
    omegaTower(0) = 1
    omegaTower(n+1) = ω^(omegaTower(n))
    """
    if n == 0:
        return CNFOrdinal.nat(1)
    return CNFOrdinal.omega_to(omega_tower(n - 1))


# === Game Value Verification ===

def verify_chain_game(n: int) -> bool:
    """Verify that chainGame(n) has value k at position k for all k ≤ n."""
    positions = build_chain_game(n)
    for k in range(n + 1):
        val = game_value(positions[k])
        expected = CNFOrdinal.nat(k)
        if val != expected:
            print(f"  FAIL: position {k} has value {val}, expected {expected}")
            return False
    return True


def verify_binary_tree(depth: int) -> bool:
    """Verify that a binary tree game of depth d has value d at root."""
    root = build_binary_tree_game(depth)
    val = game_value(root)
    expected = CNFOrdinal.nat(depth)
    return val == expected


# === Main verification ===

if __name__ == "__main__":
    print("Ordinal Arithmetic Verification:")
    print(f"  ω = {CNFOrdinal.omega()}")
    print(f"  ω² = {CNFOrdinal.omega_to(CNFOrdinal.nat(2))}")
    print(f"  ω^ω = {CNFOrdinal.omega_to(CNFOrdinal.omega())}")
    print()
    
    print("Omega Tower:")
    for i in range(6):
        print(f"  omegaTower({i}) = {omega_tower(i)}")
    print()
    
    print("Chain Game Verification:")
    for n in range(10):
        ok = verify_chain_game(n)
        print(f"  C_{n}: {'PASS' if ok else 'FAIL'}")
    print()
    
    print("Binary Tree Game Verification:")
    for d in range(8):
        ok = verify_binary_tree(d)
        print(f"  depth {d}: {'PASS' if ok else 'FAIL'}")
    print()
    
    print("Ordinal Addition (non-commutative!):")
    one = CNFOrdinal.nat(1)
    w = CNFOrdinal.omega()
    print(f"  1 + ω = {cnf_add(one, w)}")
    print(f"  ω + 1 = {cnf_add(w, one)}")
    print(f"  ω + ω = {cnf_add(w, w)}")
    print()
    
    print("Separation Results:")
    for n in range(1, 5):
        for m in range(1, 4):
            wn = CNFOrdinal.omega_to(CNFOrdinal.nat(n))
            wnm = cnf_mul(wn, CNFOrdinal.nat(m))
            wn1 = CNFOrdinal.omega_to(CNFOrdinal.nat(n + 1))
            print(f"  ω^{n} · {m} = {wnm} < ω^{n+1} = {wn1}: {wnm < wn1}")
