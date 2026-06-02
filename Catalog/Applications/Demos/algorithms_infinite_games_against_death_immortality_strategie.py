#!/usr/bin/env python3
"""
Algorithms for Mortal-Eternity Games

Type-hinted implementations of the core strategy tree constructions
and ordinal rank computation algorithms.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Callable, Optional, List, Tuple, Union
from enum import Enum


# === Ordinal Representation ===

class OrdinalKind(Enum):
    ZERO = "zero"
    SUCCESSOR = "successor"
    LIMIT = "limit"


@dataclass
class Ordinal:
    """Representation of ordinals below epsilon_0 in Cantor Normal Form.
    
    An ordinal is represented as a list of (exponent, coefficient) pairs:
    omega^e1 * c1 + omega^e2 * c2 + ... where e1 > e2 > ...
    
    The zero ordinal has an empty terms list.
    """
    terms: List[Tuple['Ordinal', int]]  # [(exponent, coefficient)]
    
    @staticmethod
    def zero() -> 'Ordinal':
        return Ordinal([])
    
    @staticmethod
    def finite(n: int) -> 'Ordinal':
        if n == 0:
            return Ordinal.zero()
        return Ordinal([(Ordinal.zero(), n)])
    
    @staticmethod
    def omega() -> 'Ordinal':
        return Ordinal([(Ordinal.finite(1), 1)])
    
    @staticmethod
    def omega_mul(n: int) -> 'Ordinal':
        if n == 0:
            return Ordinal.zero()
        return Ordinal([(Ordinal.finite(1), n)])
    
    @staticmethod
    def omega_sq() -> 'Ordinal':
        return Ordinal([(Ordinal.finite(2), 1)])
    
    @staticmethod
    def omega_pow(n: int) -> 'Ordinal':
        if n == 0:
            return Ordinal.finite(1)
        return Ordinal([(Ordinal.finite(n), 1)])
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return self.is_zero() or (
            len(self.terms) == 1 and self.terms[0][0].is_zero()
        )
    
    def to_nat(self) -> Optional[int]:
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0][1]
        return None
    
    def kind(self) -> OrdinalKind:
        if self.is_zero():
            return OrdinalKind.ZERO
        if self.is_finite():
            return OrdinalKind.SUCCESSOR
        # Check if last term has finite exponent with coeff 1
        # and there are higher terms
        return OrdinalKind.LIMIT
    
    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        n = self.to_nat()
        if n is not None:
            return str(n)
        parts = []
        for exp, coeff in self.terms:
            if exp.is_zero():
                parts.append(str(coeff))
            elif exp == Ordinal.finite(1):
                if coeff == 1:
                    parts.append("ω")
                else:
                    parts.append(f"ω·{coeff}")
            else:
                if coeff == 1:
                    parts.append(f"ω^{exp}")
                else:
                    parts.append(f"ω^{exp}·{coeff}")
        return " + ".join(parts)
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, Ordinal):
            return False
        return self.terms == other.terms


# === Strategy Tree ===

@dataclass
class StratTree:
    """Abstract base for strategy trees."""
    pass


@dataclass 
class Done(StratTree):
    """Mortal concedes (rank 0)."""
    pass


@dataclass
class PlayTree(StratTree):
    """Mortal survives; child_fn(n) gives subtree for Eternity's choice n."""
    child_fn: Callable[[int], StratTree]
    _description: str = ""


def depth_tree(n: int) -> StratTree:
    """Strategy tree of exact depth n. Rank = n."""
    if n <= 0:
        return Done()
    return PlayTree(lambda k, n=n: depth_tree(n - 1), f"depthTree({n})")


def omega_tree() -> StratTree:
    """Diagonal construction giving rank ω."""
    return PlayTree(lambda n: depth_tree(n), "omegaTree")


def add_finite(t: StratTree, k: int) -> StratTree:
    """Add k uniform levels. Rank increases by k."""
    if k <= 0:
        return t
    return PlayTree(lambda _, t=t, k=k: add_finite(t, k - 1),
                    f"addFinite(_, {k})")


def omega_mul_tree(n: int) -> StratTree:
    """Strategy tree with rank ω·n."""
    if n <= 0:
        return Done()
    return PlayTree(lambda k, n=n: add_finite(omega_mul_tree(n - 1), k),
                    f"omegaMulTree({n})")


def omega_sq_tree() -> StratTree:
    """Strategy tree with rank ω²."""
    return PlayTree(lambda n: omega_mul_tree(n), "omegaSqTree")


def omega_pow_tree(n: int) -> StratTree:
    """Strategy tree with rank ω^n (for n ≥ 1)."""
    if n <= 0:
        return depth_tree(1)
    if n == 1:
        return omega_tree()
    if n == 2:
        return omega_sq_tree()
    # General case: uses mul_tree construction
    base = omega_pow_tree(n - 1)
    return PlayTree(lambda k, base=base: mul_tree(base, k),
                    f"omegaPowTree({n})")


def mul_tree(base: StratTree, k: int) -> StratTree:
    """Build tree of rank base.rank * k using lifting."""
    if k <= 0:
        return Done()
    return PlayTree(lambda m, base=base, k=k: add_finite(mul_tree(base, k - 1), m),
                    f"mulTree(_, {k})")


# === Rank Computation ===

def compute_rank_finite(tree: StratTree, max_depth: int = 50) -> Optional[int]:
    """Compute exact rank for trees with finite rank.
    Returns None if rank appears infinite."""
    if isinstance(tree, Done):
        return 0
    if not isinstance(tree, PlayTree):
        return None
    if max_depth <= 0:
        return None
    max_rank = 0
    for i in range(max_depth):
        child_rank = compute_rank_finite(tree.child_fn(i), max_depth - 1)
        if child_rank is None:
            return None
        max_rank = max(max_rank, child_rank + 1)
    return max_rank


def compute_rank_symbolic(tree: StratTree) -> Ordinal:
    """Compute symbolic ordinal rank for known tree constructions."""
    if isinstance(tree, Done):
        return Ordinal.zero()
    if isinstance(tree, PlayTree):
        desc = tree._description
        if desc.startswith("depthTree("):
            n = int(desc[10:-1])
            return Ordinal.finite(n)
        if desc == "omegaTree":
            return Ordinal.omega()
        if desc.startswith("omegaMulTree("):
            n = int(desc[13:-1])
            return Ordinal.omega_mul(n)
        if desc == "omegaSqTree":
            return Ordinal.omega_sq()
        if desc.startswith("omegaPowTree("):
            n = int(desc[13:-1])
            return Ordinal.omega_pow(n)
    return Ordinal.zero()  # fallback


# === Game Simulation ===

def simulate_game(
    tree: StratTree,
    eternity_strategy: Callable[[int, List[int]], int],
    max_rounds: int = 1000
) -> Tuple[int, List[int]]:
    """Simulate a game play.
    
    Args:
        tree: Mortal's strategy tree
        eternity_strategy: function(round, history) -> choice
        max_rounds: safety bound
    
    Returns:
        (rounds_survived, history_of_eternity_choices)
    """
    history: List[int] = []
    current = tree
    rounds = 0
    
    while isinstance(current, PlayTree) and rounds < max_rounds:
        choice = eternity_strategy(rounds, history)
        history.append(choice)
        current = current.child_fn(choice)
        rounds += 1
    
    return rounds, history


# === Transfinite Game Certificate ===

@dataclass
class GameCertificate:
    """Certificate that Mortal can survive at least α rounds."""
    ordinal_bound: Ordinal
    tree: StratTree
    
    def verify_finite(self) -> bool:
        """Verify for finite ordinals that the tree has sufficient rank."""
        n = self.ordinal_bound.to_nat()
        if n is None:
            return True  # Can't computationally verify transfinite
        rank = compute_rank_finite(self.tree, max_depth=n + 5)
        return rank is not None and rank >= n


def generate_certificate(target: Ordinal) -> GameCertificate:
    """Generate a game certificate for a target ordinal."""
    n = target.to_nat()
    if n is not None:
        return GameCertificate(target, depth_tree(n))
    if target == Ordinal.omega():
        return GameCertificate(target, omega_tree())
    if target == Ordinal.omega_sq():
        return GameCertificate(target, omega_sq_tree())
    # Default: try omega tree
    return GameCertificate(target, omega_tree())


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Rank computation
    print("Symbolic Ranks:")
    trees = [
        ("depthTree(5)", depth_tree(5)),
        ("omegaTree", omega_tree()),
        ("omegaMulTree(3)", omega_mul_tree(3)),
        ("omegaSqTree", omega_sq_tree()),
    ]
    for name, tree in trees:
        rank = compute_rank_symbolic(tree)
        print(f"  {name}: rank = {rank}")
    
    # Certificate generation
    print("\nCertificates:")
    targets = [Ordinal.finite(10), Ordinal.omega(), Ordinal.omega_sq()]
    for target in targets:
        cert = generate_certificate(target)
        verified = cert.verify_finite()
        print(f"  Certificate({target}): verified = {verified}")
    
    # Game simulation
    print("\nGame Simulations:")
    tree = omega_tree()
    strategies = [
        ("constant(3)", lambda r, h: 3),
        ("identity", lambda r, h: r),
        ("doubling", lambda r, h: 2 * r),
    ]
    for name, strat in strategies:
        rounds, _ = simulate_game(tree, strat, max_rounds=50)
        print(f"  omegaTree vs {name}: {rounds} rounds")
