#!/usr/bin/env python3
"""
Algorithms for Surreal Topology: Order Gap Detection and Archimedean Testing

Implements the key algorithmic ideas from the formal proofs:
1. Dedekind cut construction for √2 in ℚ
2. Gap convergence sequences (Newton-like iteration)
3. Archimedean property testing for number systems
"""

from fractions import Fraction
from typing import Callable, List, Optional, Tuple


def dedekind_cut_sqrt2(q: Fraction) -> bool:
    """Classify a rational number relative to the √2 Dedekind cut.
    
    Returns True if q is in the lower cut (q < 0 or q² < 2).
    Returns False if q is in the upper cut (q ≥ 0 and q² ≥ 2).
    
    Time complexity: O(1) arithmetic operations on Fraction.
    """
    if q < 0:
        return True
    return q * q < 2


def lower_cut_iterate(q: Fraction) -> Fraction:
    """Given q ≥ 0 with q² < 2, find q' > q with q'² < 2.
    
    Formula: q' = (2q + 2)/(q + 2)
    
    Correctness: q'² < 2 ⟺ 4(q+1)²/(q+2)² < 2 ⟺ 2(q+1)² < (q+2)²
                ⟺ 2q² + 4q + 2 < q² + 4q + 4 ⟺ q² < 2 ✓
    
    Monotonicity: q' > q ⟺ 2q + 2 > q(q+2) = q² + 2q ⟺ 2 > q² ✓
    """
    return (2 * q + 2) / (q + 2)


def upper_cut_iterate(q: Fraction) -> Fraction:
    """Given q > 0 with q² > 2, find q' < q with q'² > 2.
    
    Formula: q' = (q² + 2)/(2q)  [Newton's method step]
    
    Correctness: q'² ≥ 2 ⟺ (q²+2)²/(4q²) ≥ 2 ⟺ (q²+2)² ≥ 8q²
                ⟺ q⁴ + 4q² + 4 ≥ 8q² ⟺ (q²-2)² ≥ 0 ✓ (always)
    
    Strict inequality q'² > 2 when q² > 2 (since (q²-2)² > 0).
    Monotonicity: q' < q ⟺ q²+2 < 2q² ⟺ 2 < q² ✓
    """
    return (q * q + 2) / (2 * q)


def converge_to_sqrt2(n_iterations: int = 20) -> Tuple[List[Fraction], List[Fraction]]:
    """Generate converging sequences from below and above √2.
    
    Returns (lower_seq, upper_seq) where:
    - lower_seq approaches √2 from below (all q² < 2)
    - upper_seq approaches √2 from above (all q² > 2)
    
    The gap between consecutive terms shrinks quadratically (Newton's method).
    """
    lower: List[Fraction] = [Fraction(1)]
    upper: List[Fraction] = [Fraction(2)]
    
    for _ in range(n_iterations):
        lower.append(lower_cut_iterate(lower[-1]))
        upper.append(upper_cut_iterate(upper[-1]))
    
    return lower, upper


def gap_width_sequence(n_iterations: int = 15) -> List[float]:
    """Compute the width of the gap at each iteration.
    
    Shows quadratic convergence of Newton's method:
    gap(n+1) ≈ gap(n)² / (2√2)
    """
    lower, upper = converge_to_sqrt2(n_iterations)
    return [float(upper[i] - lower[i]) for i in range(len(lower))]


def is_archimedean_test(
    elements: List[float],
    positive_unit: float = 1.0,
    max_multiples: int = 1000
) -> Tuple[bool, Optional[float]]:
    """Test the Archimedean property for a finite collection of elements.
    
    Checks: for each x in elements, does there exist n such that x ≤ n * positive_unit?
    
    Returns (is_archimedean, first_counterexample_or_None).
    
    Note: This is always True for finite subsets of ℝ. It becomes meaningful
    for symbolic/extended number systems.
    """
    for x in elements:
        found = False
        for n in range(max_multiples + 1):
            if x <= n * positive_unit:
                found = True
                break
        if not found:
            return False, x
    return True, None


def construct_nat_gap_witness(bound: float) -> dict:
    """Demonstrate the gap construction from Theorem 3.4.
    
    Given a bound b such that n ≤ b for all n (hypothetically),
    shows the structure of the gap L = {x | ∃n, x < n}.
    
    Returns a dictionary describing the gap structure.
    """
    return {
        "gap_set_L": "{ x ∈ F | ∃ n : ℕ, x < n }",
        "gap_complement": "{ x ∈ F | ∀ n : ℕ, n ≤ x }",
        "L_nonempty_witness": f"0 ∈ L since 0 < 1",
        "complement_nonempty_witness": f"{bound} ∈ Lᶜ since ∀n, n ≤ {bound}",
        "L_no_max_proof": "If x < n, then x+1 < n+1, so x+1 ∈ L and x+1 > x",
        "complement_no_min_proof": "If ∀n, n ≤ y, then ∀n, n+1 ≤ y, so n ≤ y-1, giving y-1 ∈ Lᶜ",
        "conclusion": "L is an order gap → F is disconnected"
    }


def ordered_field_classification() -> List[dict]:
    """Classify well-known ordered fields by topological properties.
    
    Returns a table of ordered fields with their properties.
    """
    return [
        {
            "name": "ℚ (rationals)",
            "archimedean": True,
            "dedekind_complete": False,
            "connected": False,
            "gap_example": "√2 cut: {q | q < 0 ∨ q² < 2}"
        },
        {
            "name": "ℝ (reals)",
            "archimedean": True,
            "dedekind_complete": True,
            "connected": True,
            "gap_example": "None (Dedekind complete)"
        },
        {
            "name": "ℚ(√2)",
            "archimedean": True,
            "dedekind_complete": False,
            "connected": False,
            "gap_example": "∛2 cut"
        },
        {
            "name": "Hyperreals *ℝ",
            "archimedean": False,
            "dedekind_complete": False,
            "connected": False,
            "gap_example": "Finite/infinite boundary: {x | ∃n, x < n}"
        },
        {
            "name": "Surreals No",
            "archimedean": False,
            "dedekind_complete": False,
            "connected": False,
            "gap_example": "Gaps at every ordinal birthday"
        },
    ]


if __name__ == "__main__":
    # Demo: convergence to √2
    print("Convergence to √2:")
    lower, upper = converge_to_sqrt2(10)
    for i in range(min(8, len(lower))):
        gap = float(upper[i] - lower[i])
        print(f"  Step {i}: [{float(lower[i]):.15f}, {float(upper[i]):.15f}]  gap = {gap:.2e}")
    
    print()
    
    # Demo: gap width convergence
    print("Gap width (quadratic convergence):")
    widths = gap_width_sequence(10)
    for i, w in enumerate(widths[:8]):
        print(f"  Step {i}: {w:.2e}")
    
    print()
    
    # Demo: classification table
    print("Ordered Field Classification:")
    for f in ordered_field_classification():
        status = "CONNECTED" if f["connected"] else "DISCONNECTED"
        print(f"  {f['name']:<20s} Arch={f['archimedean']!s:<6s} Complete={f['dedekind_complete']!s:<6s} → {status}")
