#!/usr/bin/env python3
"""
Algorithms for Certified Optimization via Quotient Algebras

This module implements the core algorithms formalized in the Lean 4 proof:
1. Free monoid word representation and evaluation
2. Commutative normalization (canonical sorting)
3. Quotient optimizer abstraction
4. Multiset content computation

Each algorithm corresponds to a formally verified definition or theorem.

Usage:
    from algorithms import *
    
    # Create and normalize a word
    w = FreeMonoidWord(['b', 'a', 'c', 'a'])
    nw = comm_normalize(w)
    print(nw)  # FreeMonoidWord(['a', 'a', 'b', 'c'])
    
    # Evaluate in a commutative monoid
    interp = {'a': 2, 'b': 3, 'c': 5}
    assert eval_word(w, interp, int.__mul__, 1) == eval_word(nw, interp, int.__mul__, 1)
"""

from collections import Counter
from typing import TypeVar, Callable, Dict, List, Any, Tuple, Generic, Optional
from dataclasses import dataclass, field


# ============================================================
# Core Data Structures
# ============================================================

T = TypeVar('T')
M = TypeVar('M')


@dataclass(frozen=True)
class FreeMonoidWord(Generic[T]):
    """A word in the free monoid on generators of type T.
    
    Corresponds to Lean's FreeMonoid X, which is definitionally List X.
    Multiplication is concatenation, identity is the empty word.
    
    Time complexity:
        - Construction: O(n)
        - Multiplication: O(n + m) where n, m are word lengths
        - Length: O(1) via cached property
    """
    generators: tuple
    
    def __init__(self, gens):
        object.__setattr__(self, 'generators', tuple(gens))
    
    def __mul__(self, other: 'FreeMonoidWord') -> 'FreeMonoidWord':
        """Monoid multiplication = concatenation. O(n + m)."""
        return FreeMonoidWord(self.generators + other.generators)
    
    def __len__(self) -> int:
        return len(self.generators)
    
    def __repr__(self) -> str:
        return f"FreeMonoidWord({list(self.generators)})"
    
    def __str__(self) -> str:
        if not self.generators:
            return "ε"
        return "·".join(str(g) for g in self.generators)
    
    @staticmethod
    def identity() -> 'FreeMonoidWord':
        """The identity element (empty word)."""
        return FreeMonoidWord([])
    
    @staticmethod
    def of(x) -> 'FreeMonoidWord':
        """Create a single-generator word. Corresponds to FreeMonoid.of."""
        return FreeMonoidWord([x])
    
    def to_multiset(self) -> Counter:
        """Convert to multiset representation. O(n)."""
        return Counter(self.generators)


# ============================================================
# Algorithm 1: Commutative Normalization
# ============================================================

def comm_normalize(word: FreeMonoidWord) -> FreeMonoidWord:
    """Canonical normalization by sorting generators.
    
    Corresponds to `commNorm` in the Lean formalization.
    This is the concrete instantiation of the quotient-section paradigm.
    
    Properties (all formally verified):
        - Soundness: comm_normalize(w) is a permutation of w
        - Idempotence: comm_normalize(comm_normalize(w)) == comm_normalize(w)
        - Canonicity: comm_normalize(a) == comm_normalize(b) iff a ~ b (permutation)
        - Semantics: eval(comm_normalize(w)) == eval(w) in any commutative monoid
    
    Time complexity: O(n log n) where n = len(word)
    Space complexity: O(n)
    
    Args:
        word: A free monoid word over an ordered generator type.
        
    Returns:
        The sorted canonical representative of the permutation class.
    """
    return FreeMonoidWord(sorted(word.generators))


# ============================================================
# Algorithm 2: Free Monoid Evaluation (FreeMonoid.lift)
# ============================================================

def eval_word(word: FreeMonoidWord, interpretation: Dict, 
              mul_op: Callable, identity) -> Any:
    """Evaluate a free monoid word in a target monoid.
    
    Corresponds to `FreeMonoid.lift ι` in the Lean formalization.
    Given an interpretation ι : X → M and a word w = x₁·x₂·...·xₙ,
    computes ι(x₁) * ι(x₂) * ... * ι(xₙ) in M.
    
    Time complexity: O(n · T_mul) where T_mul is the cost of multiplication in M.
    Space complexity: O(1) additional.
    
    Args:
        word: The free monoid word to evaluate.
        interpretation: Maps generators to monoid elements.
        mul_op: The monoid multiplication operation.
        identity: The monoid identity element.
        
    Returns:
        The evaluation result in the target monoid.
    """
    result = identity
    for gen in word.generators:
        result = mul_op(result, interpretation[gen])
    return result


# ============================================================
# Algorithm 3: Quotient Optimizer Abstraction
# ============================================================

@dataclass
class QuotientOptimizer(Generic[T]):
    """Abstract quotient-based optimizer.
    
    Corresponds to the `QuotientOptimizer` structure in Lean.
    
    Models the paradigm: optimization = canonical section over a semantic quotient.
    - rel: the equivalence relation (semantic congruence)
    - normalize: the canonical representative selector
    - sound: normalized form is equivalent to original
    - idempotent: normalizing twice = normalizing once
    
    The key theorem (preserves_eval): for any homomorphism φ to a target
    where rel collapses to equality, φ(normalize(a)) = φ(a).
    """
    name: str
    normalize: Callable[[T], T]
    rel: Callable[[T, T], bool]
    
    def preserves_eval(self, phi: Callable[[T], Any], a: T) -> bool:
        """Check that φ(normalize(a)) == φ(a).
        
        This is the computational witness of the abstract correctness theorem.
        """
        return phi(self.normalize(a)) == phi(a)
    
    def is_sound(self, a: T) -> bool:
        """Check that normalize(a) is related to a."""
        return self.rel(self.normalize(a), a)
    
    def is_idempotent(self, a: T) -> bool:
        """Check that normalize(normalize(a)) == normalize(a)."""
        return self.normalize(self.normalize(a)) == self.normalize(a)


def make_comm_optimizer() -> QuotientOptimizer:
    """Construct the commutative normalization optimizer.
    
    Corresponds to `commNormQuotientOptimizer` in Lean.
    """
    def perm_rel(a: FreeMonoidWord, b: FreeMonoidWord) -> bool:
        return a.to_multiset() == b.to_multiset()
    
    return QuotientOptimizer(
        name="Commutative Normalization (Sorting)",
        normalize=comm_normalize,
        rel=perm_rel
    )


# ============================================================
# Algorithm 4: Multiset Content Bridge
# ============================================================

def multiset_content(word: FreeMonoidWord) -> Counter:
    """Compute the multiset content (occupation numbers) of a word.
    
    This is the cross-domain bridge function:
    - Compiler optimization: operation frequency counts
    - Commutative algebra: monomial exponent vectors
    - Combinatorics: occupation-number representation
    - Statistical mechanics: bosonic state counting
    
    Time complexity: O(n)
    Space complexity: O(|alphabet|)
    
    Args:
        word: The free monoid word.
        
    Returns:
        A Counter mapping each generator to its multiplicity.
    """
    return word.to_multiset()


def eval_from_multiset(content: Counter, interpretation: Dict,
                       power_op: Callable, mul_op: Callable, identity) -> Any:
    """Evaluate directly from multiset content.
    
    Instead of iterating over the word, compute the product of ι(x)^{count(x)}.
    This is more efficient when the monoid supports fast exponentiation.
    
    Time complexity: O(|alphabet| · T_pow) where T_pow is the power operation cost.
    
    Args:
        content: Multiset content (generator multiplicities).
        interpretation: Maps generators to monoid elements.
        power_op: Computes x^n in the target monoid.
        mul_op: Monoid multiplication.
        identity: Monoid identity.
        
    Returns:
        The evaluation result, equal to eval_word for any word with this content.
    """
    result = identity
    for gen, count in sorted(content.items()):
        result = mul_op(result, power_op(interpretation[gen], count))
    return result


# ============================================================
# Algorithm 5: Quotient Factorization
# ============================================================

def quotient_map(word: FreeMonoidWord) -> Counter:
    """The quotient map: FreeMonoid X → FreeMonoid X / ≈c.
    
    Maps a word to its equivalence class under commutativity,
    represented by the multiset content.
    
    Corresponds to `commQuotMk` in Lean.
    """
    return multiset_content(word)


def canonical_section(equiv_class: Counter) -> FreeMonoidWord:
    """The canonical section: FreeMonoid X / ≈c → FreeMonoid X.
    
    Picks the sorted representative from each equivalence class.
    This is the 'section' in the quotient-section paradigm.
    
    The key property: commNorm = canonical_section ∘ quotient_map.
    """
    generators = []
    for gen in sorted(equiv_class.keys()):
        generators.extend([gen] * equiv_class[gen])
    return FreeMonoidWord(generators)


def verify_factorization(word: FreeMonoidWord) -> bool:
    """Verify that commNorm factors through the quotient.
    
    Checks: comm_normalize(word) == canonical_section(quotient_map(word))
    
    This is the computational witness of `commNorm_factors_through_quotient`.
    """
    via_direct = comm_normalize(word)
    via_quotient = canonical_section(quotient_map(word))
    return via_direct == via_quotient


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("=== Algorithms for Certified Optimization via Quotient Algebras ===\n")
    
    # Example 1: Basic normalization
    w = FreeMonoidWord(['c', 'a', 'b', 'a', 'd'])
    nw = comm_normalize(w)
    print(f"Word:       {w}")
    print(f"Normalized: {nw}")
    print(f"Idempotent: {comm_normalize(nw) == nw}")
    print()
    
    # Example 2: Evaluation preservation
    interp = {'a': 2, 'b': 3, 'c': 5, 'd': 7}
    eval_orig = eval_word(w, interp, int.__mul__, 1)
    eval_norm = eval_word(nw, interp, int.__mul__, 1)
    print(f"eval(word)       = {eval_orig}")
    print(f"eval(normalized) = {eval_norm}")
    print(f"Preserved: {eval_orig == eval_norm}")
    print()
    
    # Example 3: Quotient factorization
    print(f"Quotient map:     {dict(quotient_map(w))}")
    print(f"Section(quotient): {canonical_section(quotient_map(w))}")
    print(f"Direct normalize:  {comm_normalize(w)}")
    print(f"Factorization OK:  {verify_factorization(w)}")
    print()
    
    # Example 4: QuotientOptimizer
    opt = make_comm_optimizer()
    phi = lambda word: eval_word(word, interp, int.__mul__, 1)
    print(f"Optimizer: {opt.name}")
    print(f"Sound:     {opt.is_sound(w)}")
    print(f"Idempotent:{opt.is_idempotent(w)}")
    print(f"Preserves: {opt.preserves_eval(phi, w)}")
