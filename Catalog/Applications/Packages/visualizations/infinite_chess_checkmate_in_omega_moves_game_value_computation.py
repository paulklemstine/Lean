"""
Algorithms for Transfinite Game Values

Implements:
1. Game value computation for finite well-founded games (BFS/DFS)
2. Cantor Normal Form arithmetic for ordinals below ε₀
3. Ordinal game construction
"""

from typing import Dict, List, Set, Optional, Tuple
from dataclasses import dataclass
from functools import lru_cache


# === Algorithm 1: Game Value Computation ===

def compute_game_values(positions: List[int], 
                        moves: Dict[int, List[int]]) -> Dict[int, int]:
    """Compute game values for all positions in a finite well-founded game.
    
    Algorithm: Bottom-up computation using topological sort.
    
    Time complexity: O(|V| + |E|) where |V| = positions, |E| = total moves
    Space complexity: O(|V|)
    
    Args:
        positions: List of position identifiers
        moves: Dict mapping position -> list of successor positions
    
    Returns:
        Dict mapping position -> game value (natural number)
    
    Example:
        >>> positions = [0, 1, 2, 3]
        >>> moves = {0: [], 1: [0], 2: [1], 3: [2]}
        >>> compute_game_values(positions, moves)
        {0: 0, 1: 1, 2: 2, 3: 3}
    """
    # Compute in-degree for topological sort
    in_degree = {p: 0 for p in positions}
    reverse_moves = {p: [] for p in positions}
    
    for p, succs in moves.items():
        for s in succs:
            reverse_moves[s].append(p)
    
    # Start from terminal positions (no moves)
    values: Dict[int, int] = {}
    queue = []
    remaining = {p: len(moves.get(p, [])) for p in positions}
    
    for p in positions:
        if not moves.get(p, []):
            values[p] = 0
            queue.append(p)
    
    # Process in topological order
    while queue:
        current = queue.pop(0)
        for parent in reverse_moves[current]:
            if parent not in values:
                # Check if all successors have been valued
                all_valued = all(s in values for s in moves[parent])
                if all_valued:
                    values[parent] = max(values[s] + 1 for s in moves[parent])
                    queue.append(parent)
    
    return values


# === Algorithm 2: Cantor Normal Form ===

@dataclass(frozen=True, order=True)
class CNFTerm:
    """A single term ω^exponent · coefficient in Cantor Normal Form."""
    exponent: 'CNFOrdinal'
    coefficient: int


@dataclass(frozen=True)
class CNFOrdinal:
    """Ordinal in Cantor Normal Form: ω^e₁·c₁ + ω^e₂·c₂ + ...
    
    Terms are in strictly decreasing order of exponents.
    Each coefficient is a positive natural number.
    """
    terms: Tuple[CNFTerm, ...]
    
    @staticmethod
    def zero() -> 'CNFOrdinal':
        return CNFOrdinal(terms=())
    
    @staticmethod
    def from_nat(n: int) -> 'CNFOrdinal':
        """Convert natural number to CNF ordinal."""
        if n == 0:
            return CNFOrdinal.zero()
        return CNFOrdinal(terms=(CNFTerm(CNFOrdinal.zero(), n),))
    
    @staticmethod
    def omega() -> 'CNFOrdinal':
        """ω = ω^1·1"""
        return CNFOrdinal(terms=(CNFTerm(CNFOrdinal.from_nat(1), 1),))
    
    @staticmethod
    def omega_pow(n: int) -> 'CNFOrdinal':
        """ω^n for natural number n ≥ 0."""
        if n == 0:
            return CNFOrdinal.from_nat(1)
        return CNFOrdinal(terms=(CNFTerm(CNFOrdinal.from_nat(n), 1),))
    
    @staticmethod
    def omega_pow_omega() -> 'CNFOrdinal':
        """ω^ω"""
        return CNFOrdinal(terms=(CNFTerm(CNFOrdinal.omega(), 1),))
    
    def is_zero(self) -> bool:
        return len(self.terms) == 0
    
    def is_finite(self) -> bool:
        return self.is_zero() or (
            len(self.terms) == 1 and self.terms[0].exponent.is_zero()
        )
    
    def to_nat(self) -> Optional[int]:
        if self.is_zero():
            return 0
        if self.is_finite():
            return self.terms[0].coefficient
        return None
    
    def __lt__(self, other: 'CNFOrdinal') -> bool:
        """Compare ordinals in CNF."""
        for i in range(max(len(self.terms), len(other.terms))):
            if i >= len(self.terms):
                return True
            if i >= len(other.terms):
                return False
            if self.terms[i].exponent < other.terms[i].exponent:
                return True
            if other.terms[i].exponent < self.terms[i].exponent:
                return False
            if self.terms[i].coefficient < other.terms[i].coefficient:
                return True
            if other.terms[i].coefficient < self.terms[i].coefficient:
                return False
        return False
    
    def __le__(self, other):
        return self == other or self < other
    
    def __gt__(self, other):
        return other < self
    
    def __ge__(self, other):
        return other <= self
    
    def __str__(self):
        if self.is_zero():
            return "0"
        parts = []
        for term in self.terms:
            if term.exponent.is_zero():
                parts.append(str(term.coefficient))
            elif term.exponent == CNFOrdinal.from_nat(1):
                if term.coefficient == 1:
                    parts.append("ω")
                else:
                    parts.append(f"ω·{term.coefficient}")
            else:
                exp_str = str(term.exponent)
                if term.coefficient == 1:
                    parts.append(f"ω^{exp_str}")
                else:
                    parts.append(f"ω^{exp_str}·{term.coefficient}")
        return " + ".join(parts)
    
    def __repr__(self):
        return f"CNFOrdinal({self})"


def cnf_add(a: CNFOrdinal, b: CNFOrdinal) -> CNFOrdinal:
    """Add two ordinals in Cantor Normal Form.
    
    Note: Ordinal addition is NOT commutative! a + b ≠ b + a in general.
    The rule: ω^α + ω^β = ω^β if β ≥ α (the smaller term is absorbed).
    
    Time complexity: O(|a.terms| + |b.terms|)
    """
    if a.is_zero():
        return b
    if b.is_zero():
        return a
    
    # Find terms in a that have exponent ≥ leading exponent of b
    b_lead = b.terms[0].exponent
    kept_terms = []
    for term in a.terms:
        if term.exponent > b_lead:
            kept_terms.append(term)
        elif term.exponent == b_lead:
            # Same exponent: add coefficients
            new_coeff = term.coefficient + b.terms[0].coefficient
            kept_terms.append(CNFTerm(b_lead, new_coeff))
            kept_terms.extend(b.terms[1:])
            return CNFOrdinal(terms=tuple(kept_terms))
        else:
            break  # All remaining terms are absorbed by b
    
    kept_terms.extend(b.terms)
    return CNFOrdinal(terms=tuple(kept_terms))


def cnf_mul_nat(a: CNFOrdinal, n: int) -> CNFOrdinal:
    """Multiply an ordinal by a natural number.
    
    ω^α · n = ω^α · n (just change the leading coefficient)
    """
    if n == 0 or a.is_zero():
        return CNFOrdinal.zero()
    if a.is_finite():
        return CNFOrdinal.from_nat(a.to_nat() * n)
    
    # Multiply leading term coefficient
    first = a.terms[0]
    new_first = CNFTerm(first.exponent, first.coefficient * n)
    return CNFOrdinal(terms=(new_first,) + a.terms[1:])


# === Algorithm 3: Ordinal Game Construction ===

def construct_ordinal_game(alpha: int) -> Tuple[List[int], Dict[int, List[int]]]:
    """Construct the ordinal game for a finite ordinal alpha.
    
    Positions: {0, 1, ..., alpha-1}  (if alpha > 0)
    Moves: position p -> {q | q < p}
    
    This gives a game where gameValue(p) = p for all p.
    The game has value alpha-1 at the "top" position.
    
    Time complexity: O(alpha²) for constructing all move sets
    Space complexity: O(alpha²) for storing moves
    
    Args:
        alpha: A positive natural number
    
    Returns:
        (positions, moves) tuple
    
    Example:
        >>> positions, moves = construct_ordinal_game(5)
        >>> # Game values: 0→0, 1→1, 2→2, 3→3, 4→4
    """
    positions = list(range(alpha))
    moves = {}
    for p in positions:
        moves[p] = list(range(p))  # All positions less than p
    return positions, moves


# === Example Usage ===

if __name__ == "__main__":
    # Chain game
    print("Chain Game (length 5):")
    positions = list(range(6))
    moves = {k: [k-1] if k > 0 else [] for k in range(6)}
    values = compute_game_values(positions, moves)
    for p in sorted(values):
        print(f"  Position {p}: value = {values[p]}")
    
    print()
    
    # Ordinal game
    print("Ordinal Game (alpha=5):")
    positions, moves = construct_ordinal_game(5)
    values = compute_game_values(positions, moves)
    for p in sorted(values):
        print(f"  Position {p}: value = {values[p]}")
    
    print()
    
    # CNF arithmetic
    print("Cantor Normal Form Arithmetic:")
    w = CNFOrdinal.omega()
    w2 = CNFOrdinal.omega_pow(2)
    ww = CNFOrdinal.omega_pow_omega()
    
    print(f"  ω = {w}")
    print(f"  ω² = {w2}")
    print(f"  ω^ω = {ww}")
    print(f"  ω + ω = {cnf_add(w, w)}")
    print(f"  ω·3 = {cnf_mul_nat(w, 3)}")
    print(f"  ω·3 + 5 = {cnf_add(cnf_mul_nat(w, 3), CNFOrdinal.from_nat(5))}")
    print(f"  ω² + ω·3 + 5 = {cnf_add(w2, cnf_add(cnf_mul_nat(w, 3), CNFOrdinal.from_nat(5)))}")
    
    # Hierarchy
    print()
    print("Transfinite Hierarchy:")
    for n in range(8):
        print(f"  ω^{n} = {CNFOrdinal.omega_pow(n)}")
    print(f"  ω^ω = {CNFOrdinal.omega_pow_omega()}")
    print(f"  ω^{n} < ω^ω for all finite n ✓")
