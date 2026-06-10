#!/usr/bin/env python3
"""
Algorithms for Pseudofinite Transfer via Definable Ultraproducts

Implements the core computational methods for analyzing definable families
over finite fields and tracking doubling/control data.

Algorithms:
  1. DefinableFamilyAnalyzer - analyze polynomial-definable GL(2) subsets
  2. CosetControlFinder - find minimal coset covers
  3. TransferEvidenceCollector - aggregate evidence for transfer conjecture
"""

from typing import List, Tuple, Set, Dict, Optional
from dataclasses import dataclass
import numpy as np


# ─── Type aliases ────────────────────────────────────────────────────
Matrix2x2 = Tuple[Tuple[int, int], Tuple[int, int]]


# ─── Core matrix arithmetic ─────────────────────────────────────────

def mat_mul_mod(m1: Matrix2x2, m2: Matrix2x2, q: int) -> Matrix2x2:
    """Multiply two 2x2 matrices mod q.

    Time: O(1)
    Space: O(1)

    >>> mat_mul_mod(((1,1),(0,1)), ((1,1),(0,1)), 5)
    ((1, 2), (0, 1))
    """
    (a, b), (c, d) = m1
    (e, f), (g, h) = m2
    return (((a*e + b*g) % q, (a*f + b*h) % q),
            ((c*e + d*g) % q, (c*f + d*h) % q))


def mat_inv_mod(m: Matrix2x2, q: int) -> Optional[Matrix2x2]:
    """Compute the inverse of a 2x2 matrix mod q (prime q).

    Time: O(log q) for modular inverse
    Space: O(1)
    """
    (a, b), (c, d) = m
    det = (a * d - b * c) % q
    if det == 0:
        return None
    det_inv = pow(det, q - 2, q)
    return ((d * det_inv % q, (-b * det_inv) % q),
            ((-c * det_inv) % q, a * det_inv % q))


def mat_trace_mod(m: Matrix2x2, q: int) -> int:
    """Trace of a 2x2 matrix mod q."""
    return (m[0][0] + m[1][1]) % q


def mat_det_mod(m: Matrix2x2, q: int) -> int:
    """Determinant of a 2x2 matrix mod q."""
    return (m[0][0] * m[1][1] - m[0][1] * m[1][0]) % q


# ─── Algorithm 1: Definable Family Analyzer ─────────────────────────

@dataclass
class FamilyAnalysis:
    """Result of analyzing a definable family over F_q."""
    q: int
    family_size: int
    product_size: int
    doubling_ratio: float
    controlling_subgroup_size: int
    coset_count: int
    is_bounded: bool


class DefinableFamilyAnalyzer:
    """Analyze polynomially definable subsets of GL(2, F_q).

    Given a membership predicate (a Python function), computes:
    - |A_q|, |A_q²|
    - Doubling ratio |A_q²|/|A_q|
    - Candidate controlling subgroup
    - Number of cosets needed for control

    Complexity:
      Time: O(|A_q|² · q) for product set computation
      Space: O(|A_q|² + q²) for storing matrices

    Example:
        >>> def upper_tri(m, q): return m[1][0] == 0
        >>> analyzer = DefinableFamilyAnalyzer(upper_tri)
        >>> result = analyzer.analyze(5)
        >>> result.doubling_ratio < 10
        True
    """

    def __init__(self, membership_pred):
        """
        Args:
            membership_pred: function(matrix, q) -> bool
                Tests whether a matrix belongs to the family over F_q
        """
        self.pred = membership_pred

    def _enumerate_family(self, q: int) -> Set[Matrix2x2]:
        """Enumerate all family members over F_q."""
        members = set()
        for a in range(q):
            for b in range(q):
                for c in range(q):
                    for d in range(q):
                        if (a * d - b * c) % q != 0:
                            m = ((a, b), (c, d))
                            if self.pred(m, q):
                                members.add(m)
        return members

    def _product_set(self, S: Set[Matrix2x2], q: int) -> Set[Matrix2x2]:
        """Compute S · S."""
        return {mat_mul_mod(a, b, q) for a in S for b in S}

    def analyze(self, q: int, doubling_threshold: float = 10.0) -> FamilyAnalysis:
        """Analyze the family over F_q.

        Args:
            q: prime field size
            doubling_threshold: bound for "bounded doubling"

        Returns:
            FamilyAnalysis with all computed data
        """
        A = self._enumerate_family(q)
        A_size = len(A)
        if A_size == 0:
            return FamilyAnalysis(q, 0, 0, float('inf'), 0, 0, False)

        AA = self._product_set(A, q)
        AA_size = len(AA)
        ratio = AA_size / A_size

        # Find controlling subgroup
        ctrl = CosetControlFinder(q)
        H_size, cosets = ctrl.find_best_control(A)

        return FamilyAnalysis(
            q=q,
            family_size=A_size,
            product_size=AA_size,
            doubling_ratio=ratio,
            controlling_subgroup_size=H_size,
            coset_count=cosets,
            is_bounded=(ratio <= doubling_threshold)
        )


# ─── Algorithm 2: Coset Control Finder ──────────────────────────────

class CosetControlFinder:
    """Find minimal coset covers for subsets of GL(2, F_q).

    Tries several natural subgroup candidates and returns the one
    requiring the fewest cosets to cover the target set.

    Complexity:
      Time: O(|A| · q) per candidate subgroup
      Space: O(|A| + q)

    Pseudocode:
      1. Generate candidate subgroups H₁, H₂, ...
      2. For each Hₖ:
         a. remaining ← A
         b. cosets ← 0
         c. While remaining ≠ ∅:
            - Pick representative r ∈ remaining
            - Compute coset r·Hₖ
            - remaining ← remaining ∖ (r·Hₖ)
            - cosets ← cosets + 1
         d. Record (|Hₖ|, cosets)
      3. Return candidate with min cosets
    """

    def __init__(self, q: int):
        self.q = q

    def _unipotent_subgroup(self) -> Set[Matrix2x2]:
        """The unipotent subgroup U = {[[1,t],[0,1]] : t ∈ F_q}."""
        return {((1, t), (0, 1)) for t in range(self.q)}

    def _diagonal_subgroup(self) -> Set[Matrix2x2]:
        """The diagonal subgroup D = {[[a,0],[0,d]] : a,d ≠ 0}."""
        return {((a, 0), (0, d))
                for a in range(1, self.q)
                for d in range(1, self.q)}

    def _upper_triangular_subgroup(self) -> Set[Matrix2x2]:
        """The upper triangular subgroup B = {[[a,b],[0,d]] : a,d ≠ 0}."""
        return {((a, b), (0, d))
                for a in range(1, self.q)
                for b in range(self.q)
                for d in range(1, self.q)}

    def _coset_cover(self, A: Set[Matrix2x2],
                     H: Set[Matrix2x2]) -> int:
        """Count left cosets of H needed to cover A.

        Greedy algorithm: pick an uncovered element, compute its coset,
        remove covered elements, repeat.
        """
        remaining = set(A)
        cosets = 0
        while remaining:
            rep = next(iter(remaining))
            coset = {mat_mul_mod(rep, h, self.q) for h in H}
            remaining -= coset
            cosets += 1
        return cosets

    def find_best_control(self, A: Set[Matrix2x2]) -> Tuple[int, int]:
        """Find the subgroup giving the fewest cosets.

        Returns:
            (subgroup_size, num_cosets)
        """
        candidates = [
            ("Unipotent", self._unipotent_subgroup()),
            ("Diagonal", self._diagonal_subgroup()),
        ]

        # Only add upper triangular if q is small enough
        if self.q <= 23:
            candidates.append(
                ("Upper tri", self._upper_triangular_subgroup())
            )

        best_size, best_cosets = 1, len(A)
        for name, H in candidates:
            cosets = self._coset_cover(A, H)
            if cosets < best_cosets:
                best_size = len(H)
                best_cosets = cosets

        return best_size, best_cosets


# ─── Algorithm 3: Transfer Evidence Collector ────────────────────────

@dataclass
class TransferEvidence:
    """Aggregated evidence for the transfer conjecture."""
    family_name: str
    analyses: List[FamilyAnalysis]
    ratio_trend: str  # "bounded", "growing", "oscillating"
    control_trend: str
    supports_conjecture: bool
    summary: str


class TransferEvidenceCollector:
    """Collect and analyze evidence for the pseudofinite transfer conjecture.

    The conjecture predicts that for uniformly polynomially definable
    families A_q ⊆ GL(2, F_q), if |A_q²| ≤ K|A_q| for ultrafilter-many q,
    then in the pseudofinite ultraproduct, A_ω is controlled by a definable
    subgroup of complexity bounded solely by K and formula complexity.

    Complexity:
      Time: O(Σ_q |A_q|² · q) across all fields
      Space: O(max_q |A_q|² + q²)

    Pseudocode:
      1. For each prime q in test range:
         a. Compute A_q, A_q², doubling ratio
         b. Find best controlling subgroup
         c. Record FamilyAnalysis
      2. Classify ratio trend (bounded/growing/oscillating)
      3. Classify control trend
      4. Determine if evidence supports conjecture
    """

    def __init__(self, primes: List[int]):
        self.primes = primes

    def _classify_trend(self, values: List[float],
                        threshold: float = 2.0) -> str:
        """Classify a sequence as bounded, growing, or oscillating."""
        if not values:
            return "empty"
        if max(values) / max(min(values), 0.01) < threshold:
            return "bounded"
        # Check monotonicity
        diffs = [values[i+1] - values[i] for i in range(len(values)-1)]
        if all(d >= 0 for d in diffs):
            return "growing"
        return "oscillating"

    def collect(self, name: str,
                membership_pred) -> TransferEvidence:
        """Collect evidence for a family.

        Args:
            name: family name
            membership_pred: function(matrix, q) -> bool

        Returns:
            TransferEvidence with full analysis
        """
        analyzer = DefinableFamilyAnalyzer(membership_pred)
        analyses = []
        for q in self.primes:
            result = analyzer.analyze(q)
            analyses.append(result)

        ratios = [a.doubling_ratio for a in analyses if a.family_size > 0]
        controls = [float(a.coset_count) for a in analyses if a.family_size > 0]

        ratio_trend = self._classify_trend(ratios)
        control_trend = self._classify_trend(controls)

        supports = (ratio_trend == "bounded" and control_trend == "bounded")

        summary = (
            f"Family '{name}': {len(analyses)} fields analyzed. "
            f"Doubling: {ratio_trend} (range [{min(ratios):.1f}, {max(ratios):.1f}]). "
            f"Control: {control_trend} (range [{min(controls):.0f}, {max(controls):.0f}]). "
            f"{'SUPPORTS' if supports else 'DOES NOT SUPPORT'} conjecture."
        )

        return TransferEvidence(
            family_name=name,
            analyses=analyses,
            ratio_trend=ratio_trend,
            control_trend=control_trend,
            supports_conjecture=supports,
            summary=summary
        )


# ─── Main ────────────────────────────────────────────────────────────

if __name__ == "__main__":
    primes = [3, 5, 7, 11, 13]
    collector = TransferEvidenceCollector(primes)

    # Family 1: Upper triangular
    def upper_tri(m, q):
        return m[1][0] == 0

    ev1 = collector.collect("Upper Triangular", upper_tri)
    print(ev1.summary)

    # Family 2: Unipotent with quadratic coordinate
    def unipotent_quad(m, q):
        if m[0][0] != 1 or m[1][0] != 0 or m[1][1] != 1:
            return False
        t = m[0][1]
        return any((x * x) % q == t for x in range(q))

    ev2 = collector.collect("Unipotent Quadratic", unipotent_quad)
    print(ev2.summary)

    # Family 3: Diagonal-times-unipotent
    def diag_unipotent(m, q):
        if m[1][0] != 0 or m[0][0] != m[1][1]:
            return False
        if m[0][0] == 0:
            return False
        t = m[0][1]
        return any((x * x) % q == t for x in range(q))

    ev3 = collector.collect("Diagonal × Unipotent", diag_unipotent)
    print(ev3.summary)
