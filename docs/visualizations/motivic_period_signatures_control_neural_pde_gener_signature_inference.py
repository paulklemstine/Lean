#!/usr/bin/env python3
"""
algorithms.py — Period Signature Algorithms

Implements verified algorithms for computing, comparing, and analyzing
period signatures of analytic differential families.

All algorithms correspond to formally verified properties in the Lean
formalization (Catalog/Speculative/MotivicPeriod/Theorems.lean).
"""

from dataclasses import dataclass, field
from enum import IntEnum
from typing import List, Optional, Tuple


# ═══════════════════════════════════════════════════════════════════════
# Core Data Structures
# ═══════════════════════════════════════════════════════════════════════

class PeriodLayer(IntEnum):
    """Qualitative solution type classification.

    Corresponds to the inductive type `MotivicPeriod.PeriodLayer` in Lean.
    """
    ALGEBRAIC = 1       # weight 1
    LOGARITHMIC = 2     # weight 2
    ELLIPTIC = 3        # weight 3
    HYPERGEOMETRIC = 4  # weight 4

    @property
    def weight(self) -> int:
        """Complexity weight of this layer.

        Verified property: layerWeight_pos ensures weight > 0 for all layers.
        """
        return int(self.value)


@dataclass(frozen=True, order=True)
class PeriodSignature:
    """Coarse motivic/periodic signature for an analytic differential family.

    Corresponds to `MotivicPeriod.PeriodSignature` in the Lean formalization.

    Attributes:
        alg_rank: Dimension of the algebraic part of solution space
        log_rank: Number of independent logarithmic layers
        sing_count: Number of distinguished singular loci
        mono_complex: Coarse monodromy complexity

    Formally verified properties:
        - complexityExponent_monotone: C(σ) ≤ C(τ) when σ ≤ τ componentwise
        - universality_strict_separation: C(σ) < C(τ) when σ <_log τ or σ <_mono τ
        - algebraic_minimal_complexity: algebraic signatures minimize complexity
    """
    alg_rank: int = 0
    log_rank: int = 0
    sing_count: int = 0
    mono_complex: int = 0

    def __post_init__(self):
        if any(v < 0 for v in [self.alg_rank, self.log_rank,
                                self.sing_count, self.mono_complex]):
            raise ValueError("All signature components must be non-negative")

    def complexity_exponent(self) -> int:
        """Combined complexity exponent.

        Formula: C(σ) = algRank + 2·logRank + singCount + monoComplex

        The coefficient 2 on logRank reflects that logarithmic branching
        introduces qualitatively harder approximation barriers.

        Time complexity: O(1)
        Space complexity: O(1)
        """
        return self.alg_rank + 2 * self.log_rank + self.sing_count + self.mono_complex

    def min_width_needed(self) -> int:
        """Minimal approximation architecture width proxy.

        Formula: W(σ) = logRank + monoComplex + 1

        Time complexity: O(1)
        Space complexity: O(1)
        """
        return self.log_rank + self.mono_complex + 1

    def signature_le(self, other: 'PeriodSignature') -> bool:
        """Componentwise partial order comparison.

        Returns True iff self ≤ other in all four components.

        Time complexity: O(1)
        """
        return (self.alg_rank <= other.alg_rank and
                self.log_rank <= other.log_rank and
                self.sing_count <= other.sing_count and
                self.mono_complex <= other.mono_complex)

    def universality_class(self) -> str:
        """Determine the universality class label.

        Classification based on dominant complexity source:
        - Algebraic: no logarithmic or monodromy complexity
        - Logarithmic: log terms present, limited monodromy
        - Elliptic: moderate monodromy complexity
        - Hypergeometric: high monodromy complexity

        Time complexity: O(1)
        """
        if self.log_rank == 0 and self.mono_complex == 0:
            return "Algebraic"
        elif self.log_rank > 0 and self.mono_complex <= 1:
            return "Logarithmic"
        elif self.mono_complex <= 3:
            return "Elliptic"
        else:
            return "Hypergeometric"


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Signature Inference
# ═══════════════════════════════════════════════════════════════════════

def infer_signature(
    num_alg: int,
    has_logs: bool,
    sing_pts: int,
    mono_rank: int,
) -> PeriodSignature:
    """Infer a coarse period signature from symbolic differential-family data.

    Corresponds to `MotivicPeriod.inferSignature` in Lean.

    Algorithm:
        1. Set algRank = num_alg
        2. Set logRank = max(1, mono_rank) if has_logs else 0
        3. Set singCount = sing_pts
        4. Set monoComplex = mono_rank

    Verified property (inferSignature_complexity_mono):
        If data_1 ≤ data_2 componentwise (with b₁=false ∨ b₂=true),
        then C(infer(data_1)) ≤ C(infer(data_2)).

    Args:
        num_alg: Number of algebraic solution components
        has_logs: Whether logarithmic terms appear in solutions
        sing_pts: Number of singular points
        mono_rank: Rank of the monodromy representation

    Returns:
        PeriodSignature encoding the inferred complexity structure

    Time complexity: O(1)
    Space complexity: O(1)

    Examples:
        >>> infer_signature(2, False, 0, 0)
        PeriodSignature(alg_rank=2, log_rank=0, sing_count=0, mono_complex=0)
        >>> infer_signature(1, True, 3, 4)
        PeriodSignature(alg_rank=1, log_rank=4, sing_count=3, mono_complex=4)
    """
    log_rank = max(1, mono_rank) if has_logs else 0
    return PeriodSignature(
        alg_rank=num_alg,
        log_rank=log_rank,
        sing_count=sing_pts,
        mono_complex=mono_rank,
    )


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Signature Comparison
# ═══════════════════════════════════════════════════════════════════════

def compare_signatures(
    sigma: PeriodSignature,
    tau: PeriodSignature,
) -> dict:
    """Compare two period signatures and determine their relationship.

    Returns a dictionary with comparison results including:
    - componentwise ordering
    - complexity exponent comparison
    - whether strict separation holds
    - universality class comparison

    Time complexity: O(1)
    Space complexity: O(1)

    Examples:
        >>> s1 = PeriodSignature(1, 0, 1, 0)
        >>> s2 = PeriodSignature(1, 2, 1, 1)
        >>> result = compare_signatures(s1, s2)
        >>> result['strict_separation']
        True
    """
    le = sigma.signature_le(tau)
    ge = tau.signature_le(sigma)
    eq = (sigma == tau)

    c_sigma = sigma.complexity_exponent()
    c_tau = tau.complexity_exponent()

    strict_log = le and sigma.log_rank < tau.log_rank
    strict_mono = le and sigma.mono_complex < tau.mono_complex

    return {
        'sigma': sigma,
        'tau': tau,
        'sigma_le_tau': le,
        'tau_le_sigma': ge,
        'equal': eq,
        'comparable': le or ge,
        'c_sigma': c_sigma,
        'c_tau': c_tau,
        'complexity_order': 'σ < τ' if c_sigma < c_tau else
                           'σ = τ' if c_sigma == c_tau else 'σ > τ',
        'strict_separation': strict_log or strict_mono,
        'strict_log': strict_log,
        'strict_mono': strict_mono,
        'sigma_class': sigma.universality_class(),
        'tau_class': tau.universality_class(),
        'same_class': sigma.universality_class() == tau.universality_class(),
    }


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Layer Weight Computation
# ═══════════════════════════════════════════════════════════════════════

def signature_weight(layers: List[PeriodLayer]) -> int:
    """Compute the total weight of a list of period layers.

    Corresponds to `MotivicPeriod.signatureWeight` in Lean.

    Verified properties:
    - signatureWeight_mono_of_sublist: sublists have ≤ weight
    - signatureWeight_lt_of_strict_sublist: strict sublists have < weight

    Args:
        layers: List of PeriodLayer values

    Returns:
        Sum of weights of all layers

    Time complexity: O(n) where n = len(layers)
    Space complexity: O(1)
    """
    return sum(layer.weight for layer in layers)


def is_sublist(l1: list, l2: list) -> bool:
    """Check if l1 is a sublist of l2 (not necessarily contiguous).

    Time complexity: O(n + m) where n, m are lengths
    """
    it = iter(l2)
    return all(item in it for item in l1)


def verify_weight_monotonicity(l1: List[PeriodLayer], l2: List[PeriodLayer]) -> dict:
    """Verify weight monotonicity for a pair of layer lists.

    Checks:
    - If l1 is a sublist of l2, then weight(l1) ≤ weight(l2)
    - If l1 is a strict sublist of l2, then weight(l1) < weight(l2)

    Time complexity: O(n + m)
    """
    sub = is_sublist(l1, l2)
    w1 = signature_weight(l1)
    w2 = signature_weight(l2)
    strict = sub and l1 != l2

    return {
        'l1_weight': w1,
        'l2_weight': w2,
        'is_sublist': sub,
        'is_strict_sublist': strict,
        'monotonicity_holds': (not sub) or (w1 <= w2),
        'strict_monotonicity_holds': (not strict) or (w1 < w2),
    }


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Universality Class Partitioning
# ═══════════════════════════════════════════════════════════════════════

def partition_by_universality_class(
    signatures: List[PeriodSignature],
) -> dict:
    """Partition signatures into universality classes.

    Groups signatures by their universality class label and computes
    within-class and across-class statistics.

    Time complexity: O(n) where n = len(signatures)
    Space complexity: O(n)
    """
    classes: dict[str, list] = {}
    for sig in signatures:
        cls = sig.universality_class()
        if cls not in classes:
            classes[cls] = []
        classes[cls].append(sig)

    result = {}
    for cls_name, sigs in classes.items():
        exponents = [s.complexity_exponent() for s in sigs]
        result[cls_name] = {
            'count': len(sigs),
            'signatures': sigs,
            'exponents': exponents,
            'min_exponent': min(exponents),
            'max_exponent': max(exponents),
            'mean_exponent': sum(exponents) / len(exponents),
        }

    return result


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 5: Complexity Lattice Construction
# ═══════════════════════════════════════════════════════════════════════

def build_complexity_lattice(
    signatures: List[PeriodSignature],
) -> dict:
    """Build the Hasse diagram of the componentwise partial order.

    Computes covering relations (edges in the Hasse diagram) for
    the partial order defined by signatureLE.

    Time complexity: O(n³) — can be optimized with topological sort
    Space complexity: O(n²)
    """
    n = len(signatures)
    # Compute full order relation
    le_matrix = [[signatures[i].signature_le(signatures[j])
                  for j in range(n)] for i in range(n)]

    # Compute covering relation (Hasse diagram edges)
    covers = []
    for i in range(n):
        for j in range(n):
            if i != j and le_matrix[i][j]:
                # Check if there's anything strictly between i and j
                is_cover = True
                for k in range(n):
                    if k != i and k != j and le_matrix[i][k] and le_matrix[k][j]:
                        is_cover = False
                        break
                if is_cover:
                    covers.append((i, j))

    return {
        'signatures': signatures,
        'le_matrix': le_matrix,
        'covers': covers,
        'num_comparable_pairs': sum(1 for i in range(n) for j in range(i+1, n)
                                    if le_matrix[i][j] or le_matrix[j][i]),
        'num_incomparable_pairs': sum(1 for i in range(n) for j in range(i+1, n)
                                      if not le_matrix[i][j] and not le_matrix[j][i]),
    }


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 60)
    print("Period Signature Algorithms — Example Usage")
    print("=" * 60)

    # Algorithm 1: Inference
    print("\n--- Algorithm 1: Signature Inference ---")
    sig = infer_signature(2, True, 3, 4)
    print(f"infer_signature(2, True, 3, 4) = {sig}")
    print(f"  C(σ) = {sig.complexity_exponent()}")
    print(f"  W(σ) = {sig.min_width_needed()}")
    print(f"  Class = {sig.universality_class()}")

    # Algorithm 2: Comparison
    print("\n--- Algorithm 2: Signature Comparison ---")
    s1 = PeriodSignature(1, 0, 1, 0)
    s2 = PeriodSignature(1, 2, 1, 3)
    result = compare_signatures(s1, s2)
    print(f"compare({s1}, {s2}):")
    print(f"  σ ≤ τ: {result['sigma_le_tau']}")
    print(f"  Strict separation: {result['strict_separation']}")
    print(f"  C(σ)={result['c_sigma']}, C(τ)={result['c_tau']}: {result['complexity_order']}")

    # Algorithm 3: Layer weights
    print("\n--- Algorithm 3: Layer Weight Computation ---")
    layers = [PeriodLayer.ALGEBRAIC, PeriodLayer.LOGARITHMIC, PeriodLayer.HYPERGEOMETRIC]
    print(f"Layers: {[l.name for l in layers]}")
    print(f"Weight: {signature_weight(layers)}")

    sub_layers = [PeriodLayer.ALGEBRAIC, PeriodLayer.HYPERGEOMETRIC]
    result = verify_weight_monotonicity(sub_layers, layers)
    print(f"Sublist {[l.name for l in sub_layers]} of {[l.name for l in layers]}:")
    print(f"  Weights: {result['l1_weight']} ≤ {result['l2_weight']}: {result['monotonicity_holds']}")

    # Algorithm 4: Universality class partitioning
    print("\n--- Algorithm 4: Universality Class Partitioning ---")
    test_sigs = [
        PeriodSignature(2, 0, 0, 0),
        PeriodSignature(3, 0, 1, 0),
        PeriodSignature(1, 1, 1, 1),
        PeriodSignature(1, 2, 2, 2),
        PeriodSignature(2, 1, 3, 3),
        PeriodSignature(1, 2, 3, 4),
        PeriodSignature(2, 3, 4, 6),
    ]
    partitions = partition_by_universality_class(test_sigs)
    for cls_name, info in partitions.items():
        print(f"  {cls_name}: {info['count']} families, "
              f"exponents {info['min_exponent']}-{info['max_exponent']}")

    print("\n✓ All algorithms executed successfully.")
