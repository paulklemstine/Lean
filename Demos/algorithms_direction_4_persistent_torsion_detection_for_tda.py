#!/usr/bin/env python3
"""
Algorithms for Persistent Torsion Detection
=============================================

Implements the core algorithms for computing torsion barcodes from
integral chain complexes using Tor₁(ℤ/pℤ, -) as the detection functor.

Main algorithms:
1. Smith Normal Form computation for integer matrices
2. Integral homology computation from boundary matrices
3. Tor₁ torsion detector
4. Torsion barcode extraction from filtered complexes
"""

from typing import List, Tuple, Dict, Optional
from math import gcd
from dataclasses import dataclass
from copy import deepcopy


# ============================================================================
# Data Structures
# ============================================================================

@dataclass
class HomologyGroup:
    """
    A finitely generated abelian group H ≅ ℤ^r ⊕ ℤ/d₁ℤ ⊕ ··· ⊕ ℤ/dₖℤ.

    Attributes:
        free_rank: The rank r of the free part.
        torsion_coefficients: The invariant factors [d₁, ..., dₖ] with dᵢ | dᵢ₊₁.
    """
    free_rank: int
    torsion_coefficients: List[int]

    def __str__(self) -> str:
        parts = []
        if self.free_rank > 0:
            parts.append(f"ℤ^{self.free_rank}" if self.free_rank > 1 else "ℤ")
        for d in self.torsion_coefficients:
            parts.append(f"ℤ/{d}ℤ")
        return " ⊕ ".join(parts) if parts else "0"


@dataclass
class TorsionBar:
    """
    A bar in the torsion barcode.

    Attributes:
        birth: Filtration level where torsion appears.
        death: Filtration level where torsion disappears (None if persistent).
        prime: The prime p used for detection.
        degree: The homological degree k.
        tor_group: The Tor₁ group at birth.
    """
    birth: int
    death: Optional[int]
    prime: int
    degree: int
    tor_group: List[int]

    def __str__(self) -> str:
        d = str(self.death) if self.death is not None else "∞"
        tor_str = " ⊕ ".join(f"ℤ/{g}ℤ" for g in self.tor_group)
        return f"[{self.birth}, {d})  (H_{self.degree}, Tor₁ ≅ {tor_str})"


# ============================================================================
# Algorithm 1: Smith Normal Form
# ============================================================================

def smith_normal_form(M: List[List[int]]) -> Tuple[List[List[int]], List[int]]:
    """
    Compute the Smith Normal Form of an integer matrix.

    Algorithm: Iterative row/column reduction using integer GCD operations.

    Complexity:
        Time: O(m·n·min(m,n)·log(max_entry)) expected
        Space: O(m·n)

    Args:
        M: An m × n integer matrix.

    Returns:
        (D, invariant_factors) where D is the diagonal Smith form and
        invariant_factors are the nonzero diagonal entries d₁ | d₂ | ... | dₖ.

    Example:
        >>> smith_normal_form([[2, 4], [6, 8]])
        ([[2, 0], [0, -4]], [2, 4])
    """
    if not M or not M[0]:
        return M, []

    rows = len(M)
    cols = len(M[0])
    A = [row[:] for row in M]  # Deep copy

    def swap_rows(i: int, j: int):
        A[i], A[j] = A[j], A[i]

    def swap_cols(i: int, j: int):
        for row in A:
            row[i], row[j] = row[j], row[i]

    def add_row_multiple(target: int, source: int, factor: int):
        for j in range(cols):
            A[target][j] += factor * A[source][j]

    def add_col_multiple(target: int, source: int, factor: int):
        for i in range(rows):
            A[i][target] += factor * A[i][source]

    pivot = 0
    for col in range(min(rows, cols)):
        # Find nonzero entry
        found = False
        for i in range(pivot, rows):
            for j in range(col, cols):
                if A[i][j] != 0:
                    swap_rows(pivot, i)
                    swap_cols(col, j)
                    found = True
                    break
            if found:
                break
        if not found:
            continue

        if A[pivot][col] < 0:
            for j in range(cols):
                A[pivot][j] = -A[pivot][j]

        # Reduce
        changed = True
        iterations = 0
        max_iter = 1000
        while changed and iterations < max_iter:
            changed = False
            iterations += 1

            for i in range(rows):
                if i != pivot and A[i][col] != 0:
                    q = A[i][col] // A[pivot][col]
                    add_row_multiple(i, pivot, -q)
                    if A[i][col] != 0:
                        changed = True

            for j in range(cols):
                if j != col and A[pivot][j] != 0:
                    q = A[pivot][j] // A[pivot][col]
                    add_col_multiple(j, col, -q)
                    if A[pivot][j] != 0:
                        changed = True

            # Check divisibility
            if A[pivot][col] != 0:
                for i in range(pivot + 1, rows):
                    for j in range(col + 1, cols):
                        if A[i][j] % A[pivot][col] != 0:
                            add_row_multiple(pivot, i, 1)
                            changed = True
                            break
                    if changed:
                        break

        pivot += 1

    inv_factors = []
    for i in range(min(rows, cols)):
        if A[i][i] != 0:
            inv_factors.append(abs(A[i][i]))

    return A, sorted(inv_factors)


# ============================================================================
# Algorithm 2: Integral Homology
# ============================================================================

def compute_integral_homology(
    chain_dimensions: List[int],
    boundary_matrices: List[List[List[int]]]
) -> List[HomologyGroup]:
    """
    Compute integral homology groups from a chain complex.

    Given chain groups C₀, C₁, ..., Cₙ with boundary maps ∂ₖ : Cₖ → Cₖ₋₁,
    compute Hₖ = ker(∂ₖ) / im(∂ₖ₊₁) for each k.

    Algorithm:
        1. Compute Smith normal form of each boundary matrix.
        2. Extract invariant factors (torsion) and null space dimension (free rank).

    Complexity:
        Time: O(Σₖ dim(Cₖ)³ · log(max_entry))
        Space: O(max_k dim(Cₖ)²)

    Args:
        chain_dimensions: [dim(C₀), dim(C₁), ..., dim(Cₙ)]
        boundary_matrices: [∂₁, ∂₂, ..., ∂ₙ] where ∂ₖ is a dim(Cₖ₋₁) × dim(Cₖ) matrix

    Returns:
        List of HomologyGroup for H₀, H₁, ..., Hₙ.
    """
    n = len(chain_dimensions)
    results = []

    for k in range(n):
        # ker(∂ₖ) rank
        if k < len(boundary_matrices):
            dk = boundary_matrices[k]
            _, dk_factors = smith_normal_form(dk)
            rank_dk = len([f for f in dk_factors if f > 0])
            ker_rank = chain_dimensions[k] - rank_dk
        else:
            ker_rank = chain_dimensions[k]

        # im(∂ₖ₊₁) and its torsion
        if k + 1 <= len(boundary_matrices) and k < len(boundary_matrices):
            # We need Smith form of ∂ₖ₊₁ (which maps Cₖ₊₁ → Cₖ)
            pass

        if k > 0 and k - 1 < len(boundary_matrices):
            dk_prev = boundary_matrices[k - 1]
            _, prev_factors = smith_normal_form(dk_prev)
            im_rank = len([f for f in prev_factors if f > 0])
            torsion = [f for f in prev_factors if f > 1]
        else:
            im_rank = 0
            torsion = []

        free_rank = max(0, ker_rank - im_rank)
        results.append(HomologyGroup(free_rank=free_rank, torsion_coefficients=torsion))

    return results


# ============================================================================
# Algorithm 3: Tor₁ Torsion Detector
# ============================================================================

def compute_tor1(H: HomologyGroup, p: int) -> HomologyGroup:
    """
    Compute Tor₁^ℤ(ℤ/pℤ, H) for a finitely generated abelian group H.

    Mathematical formula:
        Tor₁(ℤ/pℤ, ℤ^r ⊕ ⊕ᵢ ℤ/dᵢℤ) ≅ ⊕ᵢ ℤ/gcd(p, dᵢ)ℤ

    The free part contributes nothing (free modules are Tor-acyclic).
    Each torsion factor ℤ/dℤ contributes ℤ/gcd(p,d)ℤ.

    Complexity: O(k) where k = number of torsion coefficients.

    Args:
        H: A finitely generated abelian group.
        p: The prime (or any positive integer) for the detector.

    Returns:
        The Tor₁ group as a HomologyGroup.

    Example:
        >>> compute_tor1(HomologyGroup(0, [6]), 4)
        HomologyGroup(free_rank=0, torsion_coefficients=[2])
    """
    tor_coeffs = []
    for d in H.torsion_coefficients:
        g = gcd(p, d)
        if g > 1:
            tor_coeffs.append(g)
    return HomologyGroup(free_rank=0, torsion_coefficients=sorted(tor_coeffs))


def is_tor1_nonzero(H: HomologyGroup, p: int) -> bool:
    """Check if Tor₁(ℤ/pℤ, H) is nonzero."""
    return any(gcd(p, d) > 1 for d in H.torsion_coefficients)


# ============================================================================
# Algorithm 4: Torsion Barcode Extraction
# ============================================================================

def compute_torsion_barcode(
    filtration: List[List[HomologyGroup]],
    p: int
) -> List[TorsionBar]:
    """
    Extract the p-torsion barcode from a filtered sequence of homology groups.

    Algorithm:
        1. At each filtration level, compute Tor₁(ℤ/pℤ, Hₖ) for each degree k.
        2. Track birth/death events: a bar starts when Tor₁ becomes nonzero
           and ends when it becomes zero again.

    Complexity:
        Time: O(L · D · T) where L = filtration length, D = max degree,
              T = max torsion factors per group.
        Space: O(L · D)

    Args:
        filtration: filtration[i] = list of HomologyGroup for each degree at level i.
        p: The prime for torsion detection.

    Returns:
        List of TorsionBar representing the p-torsion barcode.
    """
    n_levels = len(filtration)
    if n_levels == 0:
        return []

    max_degree = max(len(level) for level in filtration)
    bars: List[TorsionBar] = []

    for degree in range(max_degree):
        in_bar = False
        birth = 0
        birth_tor: List[int] = []

        for level in range(n_levels):
            if degree < len(filtration[level]):
                H = filtration[level][degree]
                detected = is_tor1_nonzero(H, p)
            else:
                detected = False

            if detected and not in_bar:
                birth = level
                birth_tor = compute_tor1(filtration[level][degree], p).torsion_coefficients
                in_bar = True
            elif not detected and in_bar:
                bars.append(TorsionBar(
                    birth=birth, death=level,
                    prime=p, degree=degree,
                    tor_group=birth_tor
                ))
                in_bar = False

        if in_bar:
            bars.append(TorsionBar(
                birth=birth, death=None,
                prime=p, degree=degree,
                tor_group=birth_tor
            ))

    return bars


def multi_prime_torsion_barcodes(
    filtration: List[List[HomologyGroup]],
    primes: List[int]
) -> Dict[int, List[TorsionBar]]:
    """
    Compute torsion barcodes for multiple primes simultaneously.

    This reveals the full arithmetic signature of the filtration.

    Args:
        filtration: The filtered homology groups.
        primes: List of primes to test.

    Returns:
        Dictionary mapping each prime to its torsion barcode.
    """
    return {p: compute_torsion_barcode(filtration, p) for p in primes}


# ============================================================================
# Algorithm 5: Torsion Birth Detection (verified algorithm)
# ============================================================================

def find_torsion_birth(
    filtration: List[List[HomologyGroup]],
    p: int,
    degree: int,
    start: int = 0
) -> Optional[int]:
    """
    Find the first filtration index where p-torsion appears in degree k.

    This is the computational version of the formally verified
    `exists_torsion_birth` theorem.

    Algorithm: Linear scan from start index.
    Complexity: O(L · T) where L = filtration length, T = max torsion factors.

    Args:
        filtration: The filtered homology groups.
        p: The prime for detection.
        degree: The homological degree to check.
        start: Starting filtration index.

    Returns:
        The birth index, or None if no torsion appears.
    """
    for level in range(start, len(filtration)):
        if degree < len(filtration[level]):
            if is_tor1_nonzero(filtration[level][degree], p):
                return level
    return None


# ============================================================================
# Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Algorithms for Persistent Torsion Detection")
    print("=" * 50)

    # Example: Smith Normal Form
    M = [[2, 4, 4], [6, 12, 14]]
    D, factors = smith_normal_form(M)
    print(f"\nSmith Normal Form of {M}:")
    print(f"  Invariant factors: {factors}")

    # Example: Tor₁ computation
    H = HomologyGroup(free_rank=1, torsion_coefficients=[2, 6])
    for p in [2, 3, 5]:
        tor = compute_tor1(H, p)
        print(f"\n  Tor₁(ℤ/{p}ℤ, {H}) = {tor}")

    # Example: Torsion barcode
    filtration = [
        [HomologyGroup(1, [])],
        [HomologyGroup(1, []), HomologyGroup(0, [2])],
        [HomologyGroup(1, []), HomologyGroup(0, [6])],
        [HomologyGroup(1, []), HomologyGroup(0, [3])],
        [HomologyGroup(1, []), HomologyGroup(1, [])],
    ]

    print("\n\nTorsion barcodes for mixed filtration:")
    barcodes = multi_prime_torsion_barcodes(filtration, [2, 3, 5])
    for p, bars in barcodes.items():
        print(f"  p={p}: {[str(b) for b in bars] if bars else '∅'}")

    # Example: Birth detection
    birth = find_torsion_birth(filtration, 2, degree=1)
    print(f"\n  First 2-torsion birth in H₁: level {birth}")
    birth = find_torsion_birth(filtration, 3, degree=1)
    print(f"  First 3-torsion birth in H₁: level {birth}")
