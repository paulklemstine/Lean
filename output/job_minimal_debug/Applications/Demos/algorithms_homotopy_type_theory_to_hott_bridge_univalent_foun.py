#!/usr/bin/env python3
"""
Proof Transfer Algorithms

Type-hinted implementations of the core algorithms from the
proof transfer framework.
"""

from typing import (
    TypeVar, Generic, Callable, Dict, Tuple, List, Optional, Set, Any
)
from dataclasses import dataclass
from abc import ABC, abstractmethod

T = TypeVar('T')
U = TypeVar('U')
V = TypeVar('V')


@dataclass
class Equiv(Generic[T, U]):
    """An equivalence (bijection) between types T and U."""
    to_fun: Callable[[T], U]
    inv_fun: Callable[[U], T]
    
    def compose(self, other: 'Equiv[U, V]') -> 'Equiv[T, V]':
        """Compose two equivalences: self then other."""
        return Equiv(
            to_fun=lambda x: other.to_fun(self.to_fun(x)),
            inv_fun=lambda z: self.inv_fun(other.inv_fun(z))
        )
    
    def symm(self) -> 'Equiv[U, T]':
        """Inverse equivalence."""
        return Equiv(to_fun=self.inv_fun, inv_fun=self.to_fun)
    
    def verify(self, domain: List[T], codomain: List[U]) -> bool:
        """Verify bijectivity on finite sets."""
        for a in domain:
            if self.inv_fun(self.to_fun(a)) != a:
                return False
        for b in codomain:
            if self.to_fun(self.inv_fun(b)) != b:
                return False
        return True


@dataclass
class TransferPipeline(Generic[T, U]):
    """A proof transfer pipeline between types T and U.
    
    Packages an equivalence with canonical predicate transport.
    Transport is defined as pullback along the inverse:
        transport(P)(b) = P(e⁻¹(b))
    """
    equiv: Equiv[T, U]
    
    def transport_pred(self, P: Callable[[T], bool]) -> Callable[[U], bool]:
        """Transport a predicate from T to U."""
        return lambda b: P(self.equiv.inv_fun(b))
    
    def transport_rel(self, R: Callable[[T, T], bool]) -> Callable[[U, U], bool]:
        """Transport a binary relation from T to U."""
        return lambda b1, b2: R(self.equiv.inv_fun(b1), self.equiv.inv_fun(b2))
    
    def compose(self, other: 'TransferPipeline[U, V]') -> 'TransferPipeline[T, V]':
        """Compose two pipelines."""
        return TransferPipeline(self.equiv.compose(other.equiv))
    
    def inverse(self) -> 'TransferPipeline[U, T]':
        """Inverse pipeline."""
        return TransferPipeline(self.equiv.symm())


def transfer_universal(
    equiv: Equiv[T, U],
    P: Callable[[T], bool],
    domain: List[T],
    proof: bool  # True if ∀a∈domain, P(a)
) -> Tuple[Callable[[U], bool], bool]:
    """
    Transfer a universal statement across an equivalence.
    
    Given: ∀a∈A, P(a)
    Returns: (P', proof that ∀b∈B, P'(b))
    
    Algorithm:
    1. Define P'(b) = P(e⁻¹(b))
    2. For any b, P'(b) = P(e⁻¹(b)) which holds since e⁻¹(b) ∈ A
    """
    P_transferred = lambda b: P(equiv.inv_fun(b))
    return P_transferred, proof


def transfer_existential(
    equiv: Equiv[T, U],
    P: Callable[[T], bool],
    witness: T  # The a such that P(a)
) -> Tuple[Callable[[U], bool], U]:
    """
    Transfer an existential statement across an equivalence.
    
    Given: ∃a, P(a) with witness a₀
    Returns: (P', witness b₀ such that P'(b₀))
    
    Algorithm:
    1. Define P'(b) = P(e⁻¹(b))
    2. Witness: b₀ = e(a₀)
    3. P'(b₀) = P(e⁻¹(e(a₀))) = P(a₀) ✓
    """
    P_transferred = lambda b: P(equiv.inv_fun(b))
    witness_transferred = equiv.to_fun(witness)
    return P_transferred, witness_transferred


def verify_equivalence_relation_transfer(
    equiv: Equiv[T, U],
    R: Callable[[T, T], bool],
    domain_A: List[T],
    domain_B: List[U]
) -> Dict[str, bool]:
    """
    Verify that equivalence relation properties transfer.
    
    Returns dict with reflexivity, symmetry, transitivity checks
    for both original and transferred relations.
    """
    R_transferred = lambda b1, b2: R(equiv.inv_fun(b1), equiv.inv_fun(b2))
    
    results = {}
    
    # Check reflexivity
    results['refl_A'] = all(R(a, a) for a in domain_A)
    results['refl_B'] = all(R_transferred(b, b) for b in domain_B)
    
    # Check symmetry
    results['sym_A'] = all(
        not R(a1, a2) or R(a2, a1)
        for a1 in domain_A for a2 in domain_A
    )
    results['sym_B'] = all(
        not R_transferred(b1, b2) or R_transferred(b2, b1)
        for b1 in domain_B for b2 in domain_B
    )
    
    # Check transitivity
    results['trans_A'] = all(
        not (R(a1, a2) and R(a2, a3)) or R(a1, a3)
        for a1 in domain_A for a2 in domain_A for a3 in domain_A
    )
    results['trans_B'] = all(
        not (R_transferred(b1, b2) and R_transferred(b2, b3)) or R_transferred(b1, b3)
        for b1 in domain_B for b2 in domain_B for b3 in domain_B
    )
    
    return results


def compression_ratio(m: int, n: int, k: int) -> float:
    """
    Compute the proof compression ratio.
    
    m: equivalence proof complexity
    n: average theorem complexity
    k: number of theorems to transfer
    
    Returns: (m + k) / (n * k)
    """
    if n * k == 0:
        return float('inf')
    return (m + k) / (n * k)


def optimal_transfer_threshold(m: int, n: int) -> int:
    """
    Compute the minimum number of theorems k for which
    transfer is strictly cheaper than direct proof.
    
    Returns the smallest k such that m + k < n * k,
    i.e., k > m / (n - 1).
    """
    if n <= 1:
        return -1  # Transfer never helps
    threshold = m / (n - 1)
    return int(threshold) + 1


def build_chain_pipeline(
    equivalences: List[Equiv]
) -> TransferPipeline:
    """
    Build a transfer pipeline from a chain of equivalences.
    
    Given e₁: A₀ ≃ A₁, e₂: A₁ ≃ A₂, ..., eₖ: Aₖ₋₁ ≃ Aₖ,
    returns the composed pipeline A₀ → Aₖ.
    """
    if not equivalences:
        raise ValueError("Need at least one equivalence")
    
    pipeline = TransferPipeline(equivalences[0])
    for e in equivalences[1:]:
        pipeline = pipeline.compose(TransferPipeline(e))
    
    return pipeline


if __name__ == "__main__":
    # Example: transfer between {0,...,4} and {10,...,14}
    e = Equiv(
        to_fun=lambda x: x + 10,
        inv_fun=lambda y: y - 10
    )
    
    pipeline = TransferPipeline(e)
    
    # Transfer "is even"
    is_even = lambda x: x % 2 == 0
    is_even_transferred = pipeline.transport_pred(is_even)
    
    print("Transfer of 'is even' from {0,...,4} to {10,...,14}:")
    for b in range(10, 15):
        print(f"  {b}: {is_even_transferred(b)}")
    
    # Compression analysis
    print("\nCompression ratios for n=10, m=10:")
    for k in [1, 2, 3, 5, 10, 50, 100]:
        r = compression_ratio(10, 10, k)
        print(f"  k={k:>3}: ratio = {r:.3f}")
    
    print(f"\nOptimal transfer threshold (m=10, n=10): k ≥ {optimal_transfer_threshold(10, 10)}")
    print(f"Optimal transfer threshold (m=5, n=10): k ≥ {optimal_transfer_threshold(5, 10)}")
