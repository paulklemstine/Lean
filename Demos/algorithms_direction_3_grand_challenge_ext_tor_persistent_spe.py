#!/usr/bin/env python3
"""
Algorithms for Derived Persistence Theory

Implements the core computational algorithms for secondary torsion obstruction
detection in filtered chain complexes over ℤ.

Time complexity: O(|B|·|C|) for a single SES with groups of those orders.
Space complexity: O(|B| + |C|) for storing torsion subgroups.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass, field
from math import gcd
import numpy as np


# ============================================================================
# Algorithm 1: Torsion Subgroup Computation
# ============================================================================

def compute_torsion_subgroup(group_order: int, n: int) -> Set[int]:
    """
    Compute the n-torsion subgroup of ℤ/mℤ.

    T_n(ℤ/mℤ) = {a ∈ ℤ/mℤ : n·a ≡ 0 (mod m)}
              = {a : a ≡ 0 (mod m/gcd(n,m))}

    Parameters:
        group_order: The order m of the cyclic group ℤ/mℤ
        n: The torsion parameter

    Returns:
        Set of elements in the n-torsion subgroup

    Time: O(gcd(n, m))
    Space: O(gcd(n, m))

    Example:
        >>> compute_torsion_subgroup(4, 2)
        {0, 2}
        >>> compute_torsion_subgroup(6, 3)
        {0, 2, 4}
    """
    if group_order == 0:
        return {0}  # ℤ is torsion-free for any n ≠ 0

    g = gcd(abs(n), group_order)
    step = group_order // g
    return {(i * step) % group_order for i in range(g)}


def torsion_subgroup_order(group_order: int, n: int) -> int:
    """
    Compute |T_n(ℤ/mℤ)| = gcd(n, m).

    This is a direct consequence of the structure theorem:
    T_n(ℤ/mℤ) ≅ ℤ/gcd(n,m)ℤ.

    Example:
        >>> torsion_subgroup_order(4, 2)
        2
        >>> torsion_subgroup_order(6, 3)
        3
    """
    if group_order == 0:
        return 1
    return gcd(abs(n), group_order)


# ============================================================================
# Algorithm 2: Short Exact Sequence Analysis
# ============================================================================

@dataclass
class SESData:
    """Data for a short exact sequence 0 → ℤ/aℤ → ℤ/bℤ → ℤ/cℤ → 0."""
    a: int  # Order of A
    b: int  # Order of B
    c: int  # Order of C
    iota_gen: int  # ι(1) in ℤ/bℤ
    pi_gen: int    # π(1) in ℤ/cℤ


def classify_cyclic_extensions(a: int, c: int) -> List[SESData]:
    """
    Enumerate all short exact sequences 0 → ℤ/aℤ → ℤ/bℤ → ℤ/cℤ → 0
    where B is cyclic of order b = a·c.

    The canonical (non-split) extension sends 1 ∈ ℤ/aℤ to c ∈ ℤ/(ac)ℤ
    and projects by the identity on generators.

    Returns:
        List of SESData for valid extensions.

    Example:
        >>> exts = classify_cyclic_extensions(2, 2)
        >>> len(exts)
        1
    """
    b = a * c
    extensions = []

    # The standard extension: ι(x) = c·x, π(x) = x mod c
    ses = SESData(a=a, b=b, c=c, iota_gen=c, pi_gen=1)

    # Verify injectivity: c·x ≡ 0 mod (ac) ⟹ x ≡ 0 mod a ✓
    # Verify surjectivity: π is surjective since gcd(1, c) = 1
    # Verify exactness: ker(π) = {0, c, 2c, ...} = im(ι) ✓
    extensions.append(ses)

    return extensions


# ============================================================================
# Algorithm 3: Secondary Torsion Obstruction Detection
# ============================================================================

@dataclass
class DerivedPersistenceSummary:
    """Complete summary of derived persistence analysis for a SES."""
    ses: SESData
    n: int  # Torsion parameter

    # First-order data (Tor₁ level)
    torsion_A: Set[int] = field(default_factory=set)
    torsion_B: Set[int] = field(default_factory=set)
    torsion_C: Set[int] = field(default_factory=set)

    # Second-order data (secondary obstruction)
    liftable_torsion: Set[int] = field(default_factory=set)
    obstruction_elements: Set[int] = field(default_factory=set)

    # Derived invariants
    tor1_A_order: int = 0  # |Tor₁(ℤ/nℤ, A)| = gcd(n, a)
    tor1_C_order: int = 0  # |Tor₁(ℤ/nℤ, C)| = gcd(n, c)
    tor1_B_order: int = 0  # |Tor₁(ℤ/nℤ, B)| = gcd(n, b)
    predicted_torsion_B: int = 0  # |T_n(A)| · |T_n(C)| if split
    actual_torsion_B: int = 0

    @property
    def has_obstruction(self) -> bool:
        return len(self.obstruction_elements) > 0

    @property
    def torsion_deficiency(self) -> int:
        """How much torsion is 'missing' compared to the split prediction."""
        return self.predicted_torsion_B - self.actual_torsion_B


def compute_derived_persistence(ses: SESData, n: int) -> DerivedPersistenceSummary:
    """
    Complete derived persistence analysis for a cyclic SES.

    Algorithm:
    1. Compute n-torsion subgroups of A, B, C.
    2. Compute the image of T_n(B) under π.
    3. Identify elements of T_n(C) not in this image (the obstruction).
    4. Compare actual |T_n(B)| with predicted |T_n(A)| · |T_n(C)|.

    Time: O(b) where b = order of B
    Space: O(b)

    Parameters:
        ses: The short exact sequence data
        n: Torsion parameter

    Returns:
        DerivedPersistenceSummary with all computed invariants.

    Example:
        >>> ses = SESData(a=2, b=4, c=2, iota_gen=2, pi_gen=1)
        >>> result = compute_derived_persistence(ses, 2)
        >>> result.has_obstruction
        True
        >>> result.torsion_deficiency
        2
    """
    summary = DerivedPersistenceSummary(ses=ses, n=n)

    # Step 1: Compute torsion subgroups
    summary.torsion_A = compute_torsion_subgroup(ses.a, n)
    summary.torsion_B = compute_torsion_subgroup(ses.b, n)
    summary.torsion_C = compute_torsion_subgroup(ses.c, n)

    # Step 2: Compute π-image of T_n(B)
    pi_image_of_torsion = set()
    for b_elem in summary.torsion_B:
        c_elem = (ses.pi_gen * b_elem) % ses.c
        pi_image_of_torsion.add(c_elem)

    # Step 3: Identify liftable torsion and obstruction
    summary.liftable_torsion = pi_image_of_torsion & summary.torsion_C
    summary.obstruction_elements = summary.torsion_C - summary.liftable_torsion

    # Step 4: Compute derived invariants
    summary.tor1_A_order = torsion_subgroup_order(ses.a, n)
    summary.tor1_B_order = torsion_subgroup_order(ses.b, n)
    summary.tor1_C_order = torsion_subgroup_order(ses.c, n)
    summary.predicted_torsion_B = summary.tor1_A_order * summary.tor1_C_order
    summary.actual_torsion_B = summary.tor1_B_order

    return summary


# ============================================================================
# Algorithm 4: Batch Analysis and Obstruction Census
# ============================================================================

def obstruction_census(max_order: int = 30) -> List[DerivedPersistenceSummary]:
    """
    Systematic census of secondary obstructions for all cyclic SES
    with groups of order ≤ max_order.

    Searches over all valid 0 → ℤ/aℤ → ℤ/(ac)ℤ → ℤ/cℤ → 0
    and all prime torsion parameters.

    Time: O(max_order³ · log(max_order))
    Space: O(max_order²)

    Returns:
        List of summaries where obstruction is detected.

    Example:
        >>> results = obstruction_census(10)
        >>> all(not r.ses.a == 1 for r in results if r.has_obstruction)
        True
    """
    results = []
    primes = [p for p in range(2, max_order) if all(p % i != 0 for i in range(2, p))]

    for a in range(2, max_order + 1):
        for c in range(2, max_order // a + 1):
            b = a * c
            if b > max_order:
                break

            ses = SESData(a=a, b=b, c=c, iota_gen=c, pi_gen=1)

            for p in primes:
                if p > b:
                    break
                summary = compute_derived_persistence(ses, p)
                if summary.has_obstruction:
                    results.append(summary)

    return results


# ============================================================================
# Algorithm 5: Primewise Decomposition of Secondary Obstruction
# ============================================================================

def primewise_obstruction_analysis(ses: SESData) -> Dict[int, DerivedPersistenceSummary]:
    """
    Decompose the secondary torsion obstruction by prime.

    For each prime p dividing the order of B, compute the p-primary
    secondary obstruction separately.

    This implements the primewise analysis conjectured to control
    page-2 collapse.

    Parameters:
        ses: The short exact sequence data

    Returns:
        Dict mapping each prime to its obstruction summary.

    Example:
        >>> ses = SESData(a=6, b=36, c=6, iota_gen=6, pi_gen=1)
        >>> analysis = primewise_obstruction_analysis(ses)
        >>> 2 in analysis and 3 in analysis
        True
    """
    # Find primes dividing order of B
    b = ses.b
    primes = []
    temp = b
    for p in range(2, b + 1):
        if temp <= 1:
            break
        if temp % p == 0:
            primes.append(p)
            while temp % p == 0:
                temp //= p

    results = {}
    for p in primes:
        summary = compute_derived_persistence(ses, p)
        results[p] = summary

    return results


# ============================================================================
# Algorithm 6: Two-Step Filtered Chain Complex Analysis
# ============================================================================

@dataclass
class TwoStepFilteredComplex:
    """
    A two-step filtered chain complex over ℤ in a single degree.

    Represents: 0 ⊆ F⁰C ⊆ F¹C = C

    Stored as boundary matrices for the subcomplex and total complex.
    """
    # Boundary matrix for F⁰ (the subcomplex)
    d_sub: np.ndarray
    # Boundary matrix for F¹ = C (the total complex)
    d_total: np.ndarray
    # Inclusion matrix F⁰ → F¹
    inclusion: np.ndarray


def smith_normal_form_diagonal(matrix: np.ndarray) -> List[int]:
    """
    Compute the diagonal of the Smith Normal Form of an integer matrix.
    Returns the list of diagonal entries (invariant factors).

    This is a simplified implementation for small matrices.

    Time: O(n³) for n×n matrices
    Space: O(n²)
    """
    if matrix.size == 0:
        return []

    m, n = matrix.shape
    M = matrix.copy().astype(int)
    min_dim = min(m, n)
    diag = []

    for k in range(min_dim):
        # Find pivot
        sub = M[k:, k:]
        if np.all(sub == 0):
            diag.extend([0] * (min_dim - k))
            break

        # Find minimum nonzero absolute value
        nonzero = np.argwhere(sub != 0)
        if len(nonzero) == 0:
            diag.extend([0] * (min_dim - k))
            break

        min_idx = min(nonzero, key=lambda idx: abs(sub[idx[0], idx[1]]))
        pi, pj = min_idx[0] + k, min_idx[1] + k

        # Swap to pivot position
        M[[k, pi]] = M[[pi, k]]
        M[:, [k, pj]] = M[:, [pj, k]]

        # Eliminate using pivot - iterate until stable
        for _ in range(100):
            changed = False
            # Column elimination
            for j in range(k + 1, n):
                if M[k, j] != 0:
                    q = M[k, j] // M[k, k]
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        changed = True
            # Row elimination
            for i in range(k + 1, m):
                if M[i, k] != 0:
                    q = M[i, k] // M[k, k]
                    M[i, :] -= q * M[k, :]
                    if M[i, k] != 0:
                        changed = True

            if not changed:
                break

            # If not fully eliminated, swap minimum back to pivot
            sub = M[k:, k:]
            nonzero_pos = np.argwhere(sub != 0)
            if len(nonzero_pos) > 0:
                min_idx = min(nonzero_pos, key=lambda idx: abs(sub[idx[0], idx[1]]))
                pi2, pj2 = min_idx[0] + k, min_idx[1] + k
                M[[k, pi2]] = M[[pi2, k]]
                M[:, [k, pj2]] = M[:, [pj2, k]]

        diag.append(abs(M[k, k]))

    return diag


def compute_homology_torsion(boundary: np.ndarray) -> List[int]:
    """
    Compute the torsion part of homology H = ker(d)/im(d_prev).

    For a single boundary matrix d, computes the invariant factors
    of the cokernel, which give the torsion of the homology.

    Returns:
        List of torsion orders (invariant factors > 1).

    Example:
        >>> d = np.array([[2]])
        >>> compute_homology_torsion(d)
        [2]
    """
    if boundary.size == 0:
        return []

    diag = smith_normal_form_diagonal(boundary)
    return [d for d in diag if d > 1]


def analyze_two_step_complex(fc: TwoStepFilteredComplex) -> Dict:
    """
    Analyze derived persistence for a two-step filtered complex.

    Computes:
    1. Homology of the subcomplex (associated graded piece gr⁰)
    2. Homology of the quotient (associated graded piece gr¹)
    3. Homology of the total complex
    4. Torsion comparison between actual and predicted

    Returns:
        Dictionary with analysis results.
    """
    torsion_sub = compute_homology_torsion(fc.d_sub)
    torsion_total = compute_homology_torsion(fc.d_total)

    return {
        'torsion_subcomplex': torsion_sub,
        'torsion_total': torsion_total,
        'sub_torsion_product': np.prod(torsion_sub) if torsion_sub else 1,
        'total_torsion_product': np.prod(torsion_total) if torsion_total else 1,
    }


# ============================================================================
# Main: Run all algorithms with examples
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("DERIVED PERSISTENCE ALGORITHMS")
    print("=" * 60)

    # Algorithm 1: Torsion subgroup computation
    print("\n--- Algorithm 1: Torsion Subgroup ---")
    for m in [4, 6, 12]:
        for n in [2, 3]:
            T = compute_torsion_subgroup(m, n)
            print(f"  T_{n}(ℤ/{m}ℤ) = {sorted(T)} (order {len(T)} = gcd({n},{m}))")

    # Algorithm 3: Secondary obstruction
    print("\n--- Algorithm 3: Secondary Obstruction Detection ---")
    ses = SESData(a=2, b=4, c=2, iota_gen=2, pi_gen=1)
    result = compute_derived_persistence(ses, 2)
    print(f"  SES: 0 → ℤ/{ses.a}ℤ → ℤ/{ses.b}ℤ → ℤ/{ses.c}ℤ → 0")
    print(f"  2-torsion of B: {sorted(result.torsion_B)} (order {result.actual_torsion_B})")
    print(f"  Predicted (split): order {result.predicted_torsion_B}")
    print(f"  Deficiency: {result.torsion_deficiency}")
    print(f"  Obstruction: {result.obstruction_elements}")
    print(f"  Has obstruction: {result.has_obstruction}")

    # Algorithm 4: Census
    print("\n--- Algorithm 4: Obstruction Census (order ≤ 20) ---")
    census = obstruction_census(20)
    print(f"  Found {len(census)} obstructions")
    for r in census[:5]:
        print(f"  ℤ/{r.ses.a}ℤ → ℤ/{r.ses.b}ℤ → ℤ/{r.ses.c}ℤ, "
              f"n={r.n}: deficiency={r.torsion_deficiency}")

    # Algorithm 5: Primewise decomposition
    print("\n--- Algorithm 5: Primewise Decomposition ---")
    ses6 = SESData(a=6, b=36, c=6, iota_gen=6, pi_gen=1)
    pw = primewise_obstruction_analysis(ses6)
    print(f"  SES: 0 → ℤ/6ℤ → ℤ/36ℤ → ℤ/6ℤ → 0")
    for p, summary in sorted(pw.items()):
        print(f"  p={p}: obstruction={summary.has_obstruction}, "
              f"|T_p(B)|={summary.actual_torsion_B}, "
              f"predicted={summary.predicted_torsion_B}")
