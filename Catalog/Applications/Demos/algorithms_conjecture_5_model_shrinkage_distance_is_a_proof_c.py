#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Model-Shrinkage Proof Complexity

Implements the computational machinery for analyzing semantic proof complexity
via model-shrinkage distances on the Boolean cube.

Algorithms:
1. ExactModelCounter — brute-force model counting for propositional constraints
2. ShrinkageAnalyzer — computes shrinkage profiles along derivation chains
3. BoundedShrinkageVerifier — verifies and certifies bounded-shrinkage bounds
4. DeficiencyCalculator — computes entropy deficiency with exact and approximate modes

Keywords: model counting, #SAT, proof complexity, entropy, Boolean cube
"""

import math
import itertools
from typing import List, Set, Tuple, Dict, Optional, Callable
from dataclasses import dataclass, field


# ═══════════════════════════════════════════════════════════════════
# Data Structures
# ═══════════════════════════════════════════════════════════════════

@dataclass
class ShrinkageProfile:
    """Complete shrinkage analysis of a derivation chain."""
    chain_cards: List[int]
    step_shrinkages: List[float]
    cumulative_shrinkage: float
    deficiencies: List[float]
    n_vars: int
    max_step_shrinkage: float
    is_bounded: bool
    bound_B: Optional[int]
    length_lower_bound: Optional[float]

    def summary(self) -> str:
        lines = [
            f"Shrinkage Profile (n={self.n_vars}, k={len(self.chain_cards)-1})",
            f"  Chain cardinalities: {self.chain_cards}",
            f"  Step shrinkages: {[f'{s:.3f}' for s in self.step_shrinkages]}",
            f"  Total shrinkage: {self.cumulative_shrinkage:.3f}",
            f"  Deficiencies: {[f'{d:.2f}' for d in self.deficiencies]}",
            f"  Max step shrinkage: {self.max_step_shrinkage:.3f}",
        ]
        if self.is_bounded and self.bound_B is not None:
            lines.append(f"  Bounded by B={self.bound_B}: True")
            lines.append(f"  Length lower bound: {self.length_lower_bound:.3f}")
        return "\n".join(lines)


@dataclass
class BoundCertificate:
    """Certificate that a bounded-shrinkage lower bound holds."""
    chain_length: int
    shrinkage_bound: int
    total_shrinkage_ratio: float
    lower_bound: float
    bound_holds: bool
    multiplicative_bound: int
    card_start: int
    card_end: int

    def verify(self) -> bool:
        """Independently verify the certificate."""
        if self.card_end <= 0:
            return False
        ratio = self.card_start / self.card_end
        lb = math.log(ratio, self.shrinkage_bound) if self.shrinkage_bound > 1 else 0
        return self.chain_length >= lb and self.card_start <= self.multiplicative_bound


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Exact Model Counter
# ═══════════════════════════════════════════════════════════════════

class ExactModelCounter:
    """
    Brute-force exact model counter for propositional constraints.

    Represents constraints as predicate functions on Boolean assignments.
    Enumerates all 2^n assignments and counts satisfying ones.

    Time complexity: O(2^n * cost_of_predicate)
    Space complexity: O(2^n) for storing the model set

    Example:
        >>> counter = ExactModelCounter(4)
        >>> # Count assignments where x0 = True
        >>> count = counter.count(lambda a: a[0])
        >>> print(count)  # 8
    """

    def __init__(self, n_vars: int):
        self.n_vars = n_vars
        self._all_assignments = list(itertools.product([False, True], repeat=n_vars))

    def count(self, predicate: Callable[[Tuple[bool, ...]], bool]) -> int:
        """Count assignments satisfying the predicate."""
        return sum(1 for a in self._all_assignments if predicate(a))

    def model_set(self, predicate: Callable[[Tuple[bool, ...]], bool]) -> Set[Tuple[bool, ...]]:
        """Return the set of satisfying assignments."""
        return {a for a in self._all_assignments if predicate(a)}

    def deficiency(self, predicate: Callable[[Tuple[bool, ...]], bool]) -> float:
        """Compute entropy deficiency of the constraint."""
        count = self.count(predicate)
        if count <= 0:
            return float('inf')
        return self.n_vars - math.log2(count)

    def shrinkage(self, pred_S: Callable, pred_T: Callable) -> float:
        """Compute shrinkage distance d(S, T) where Mod(T) ⊆ Mod(S)."""
        card_S = self.count(pred_S)
        card_T = self.count(pred_T)
        if card_T <= 0 or card_S <= 0:
            return float('inf')
        return math.log2(card_S / card_T)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Shrinkage Analyzer
# ═══════════════════════════════════════════════════════════════════

class ShrinkageAnalyzer:
    """
    Analyzes shrinkage profiles along semantic derivation chains.

    Given a sequence of constraint predicates (each implied by the next),
    computes the full shrinkage profile including step-wise and cumulative
    shrinkage, deficiency trajectory, and bounded-shrinkage certificates.

    Time complexity: O(k * 2^n) for k-step chain on n variables
    Space complexity: O(k) for storing the profile

    Example:
        >>> analyzer = ShrinkageAnalyzer(5)
        >>> chain = [lambda a: True, lambda a: a[0], lambda a: a[0] and a[1]]
        >>> profile = analyzer.analyze(chain)
        >>> print(profile.summary())
    """

    def __init__(self, n_vars: int):
        self.n_vars = n_vars
        self.counter = ExactModelCounter(n_vars)

    def analyze(self, predicates: List[Callable],
                bound_B: Optional[int] = None) -> ShrinkageProfile:
        """
        Analyze the shrinkage profile of a derivation chain.

        Args:
            predicates: list of constraint predicates [φ_0, φ_1, ..., φ_k]
                        where Mod(φ_{i+1}) ⊆ Mod(φ_i)
            bound_B: optional shrinkage bound to check

        Returns:
            ShrinkageProfile with complete analysis
        """
        chain_cards = [self.counter.count(p) for p in predicates]
        step_shrinkages = []
        deficiencies = []

        for i, card in enumerate(chain_cards):
            deficiencies.append(
                self.n_vars - math.log2(card) if card > 0 else float('inf')
            )

        for i in range(len(chain_cards) - 1):
            if chain_cards[i + 1] > 0:
                step_shrinkages.append(math.log2(chain_cards[i] / chain_cards[i + 1]))
            else:
                step_shrinkages.append(float('inf'))

        cumulative = sum(s for s in step_shrinkages if s != float('inf'))
        max_step = max(step_shrinkages) if step_shrinkages else 0

        is_bounded = False
        length_lb = None

        if bound_B is not None and bound_B > 1:
            is_bounded = all(
                chain_cards[i] <= bound_B * chain_cards[i + 1]
                for i in range(len(chain_cards) - 1)
            )
            if chain_cards[-1] > 0 and chain_cards[0] > 0:
                quotient = chain_cards[0] // chain_cards[-1]
                length_lb = math.log(max(quotient, 1), bound_B)

        return ShrinkageProfile(
            chain_cards=chain_cards,
            step_shrinkages=step_shrinkages,
            cumulative_shrinkage=cumulative,
            deficiencies=deficiencies,
            n_vars=self.n_vars,
            max_step_shrinkage=max_step,
            is_bounded=is_bounded,
            bound_B=bound_B,
            length_lower_bound=length_lb,
        )


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Bounded-Shrinkage Verifier
# ═══════════════════════════════════════════════════════════════════

class BoundedShrinkageVerifier:
    """
    Verifies bounded-shrinkage properties and produces certificates.

    Given a chain of model set cardinalities and a bound B, checks that
    each step satisfies |S_i| ≤ B * |S_{i+1}| and produces a certificate
    for the length lower bound k ≥ log_B(|S_0|/|S_k|).

    Time complexity: O(k) for chain of length k
    Space complexity: O(1)

    Example:
        >>> verifier = BoundedShrinkageVerifier()
        >>> cert = verifier.certify([256, 128, 64, 32, 16], B=2)
        >>> print(cert.bound_holds)  # True
    """

    def certify(self, chain_cards: List[int], B: int) -> BoundCertificate:
        """
        Produce a certificate for the bounded-shrinkage lower bound.

        Args:
            chain_cards: list of cardinalities [|S_0|, ..., |S_k|]
            B: maximum per-step shrinkage factor

        Returns:
            BoundCertificate with verification data
        """
        k = len(chain_cards) - 1
        card_start = chain_cards[0]
        card_end = chain_cards[-1]

        # Check bounded shrinkage
        for i in range(k):
            if chain_cards[i] > B * chain_cards[i + 1]:
                return BoundCertificate(
                    chain_length=k, shrinkage_bound=B,
                    total_shrinkage_ratio=card_start / card_end if card_end > 0 else float('inf'),
                    lower_bound=float('inf'),
                    bound_holds=False,
                    multiplicative_bound=B ** k * card_end,
                    card_start=card_start, card_end=card_end,
                )

        multiplicative = B ** k * card_end
        ratio = card_start / card_end if card_end > 0 else float('inf')
        quotient = card_start // card_end if card_end > 0 else 0
        lb = math.log(max(quotient, 1), B) if B > 1 else 0

        return BoundCertificate(
            chain_length=k, shrinkage_bound=B,
            total_shrinkage_ratio=ratio,
            lower_bound=lb,
            bound_holds=k >= lb,
            multiplicative_bound=multiplicative,
            card_start=card_start, card_end=card_end,
        )

    def find_minimal_B(self, chain_cards: List[int]) -> int:
        """Find the minimal B such that the chain is B-bounded."""
        max_ratio = 1
        for i in range(len(chain_cards) - 1):
            if chain_cards[i + 1] > 0:
                ratio = math.ceil(chain_cards[i] / chain_cards[i + 1])
                max_ratio = max(max_ratio, ratio)
        return max_ratio


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Deficiency Calculator
# ═══════════════════════════════════════════════════════════════════

class DeficiencyCalculator:
    """
    Computes entropy deficiency with exact and approximate modes.

    Supports:
    - Exact computation via brute-force model counting
    - Symbolic computation for structured constraints (subcubes, products)
    - Deficiency additivity verification for product constraints

    Example:
        >>> calc = DeficiencyCalculator(4)
        >>> d = calc.exact_deficiency(lambda a: a[0] and a[1])
        >>> print(d)  # 2.0
    """

    def __init__(self, n_vars: int):
        self.n_vars = n_vars
        self.counter = ExactModelCounter(n_vars)

    def exact_deficiency(self, predicate: Callable) -> float:
        """Compute exact deficiency by model counting."""
        return self.counter.deficiency(predicate)

    def subcube_deficiency(self, num_fixed: int) -> float:
        """Deficiency of a subcube with num_fixed coordinates fixed."""
        return float(num_fixed)

    def product_deficiency(self, def_a: float, def_b: float,
                           card_a: int, card_b: int) -> dict:
        """
        Analyze deficiency of a product constraint.

        Returns both the exact product deficiency and the
        sub-additivity bound.
        """
        if card_a <= 0 or card_b <= 0:
            return {'product_def': float('inf'), 'sum_def': def_a + def_b,
                    'sub_additive': True, 'exact_additive': False}

        product_card = card_a * card_b
        n_total = int(math.log2(card_a) + def_a + math.log2(card_b) + def_b)
        prod_def = n_total - math.log2(product_card)

        return {
            'product_def': prod_def,
            'sum_def': def_a + def_b,
            'sub_additive': prod_def <= def_a + def_b + 0.001,
            'exact_additive': abs(prod_def - def_a - def_b) < 0.001,
        }


# ═══════════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Model-Shrinkage Algorithms — Example Usage")
    print("=" * 50)

    # Model counting
    counter = ExactModelCounter(5)
    print(f"\n1. Model counting (n=5):")
    print(f"   All: {counter.count(lambda a: True)}")
    print(f"   x0=T: {counter.count(lambda a: a[0])}")
    print(f"   x0=T ∧ x1=T: {counter.count(lambda a: a[0] and a[1])}")

    # Shrinkage analysis
    analyzer = ShrinkageAnalyzer(5)
    chain = [
        lambda a: True,
        lambda a: a[0],
        lambda a: a[0] and a[1],
        lambda a: a[0] and a[1] and a[2],
    ]
    profile = analyzer.analyze(chain, bound_B=2)
    print(f"\n2. Shrinkage analysis:")
    print(profile.summary())

    # Bounded-shrinkage certificate
    verifier = BoundedShrinkageVerifier()
    cert = verifier.certify([1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1], B=2)
    print(f"\n3. Bounded-shrinkage certificate:")
    print(f"   Chain length: {cert.chain_length}")
    print(f"   Bound B: {cert.shrinkage_bound}")
    print(f"   Lower bound: {cert.lower_bound:.1f}")
    print(f"   Certificate valid: {cert.verify()}")

    # Deficiency
    calc = DeficiencyCalculator(6)
    print(f"\n4. Deficiency calculations (n=6):")
    for k in range(7):
        pred = (lambda k: lambda a: all(a[i] for i in range(k)))(k)
        d = calc.exact_deficiency(pred)
        print(f"   Fix {k} vars: deficiency = {d:.2f}")
