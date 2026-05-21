#!/usr/bin/env python3
"""
algorithms.py — Algorithms for computing derived functor invariants over ℤ.

Implements:
1. Smith Normal Form computation
2. Ext¹ and Tor₁ computation from finite presentations
3. Universal Coefficient Theorem decomposition
4. Chain complex homology with coefficients

All algorithms correspond to verified theorems in the Lean formalization.
"""

from math import gcd
from typing import List, Tuple, Optional


def smith_normal_form(M: List[List[int]]) -> Tuple[List[List[int]], List[int]]:
    """
    Compute the Smith Normal Form of an integer matrix M.

    Returns:
        (D, invariant_factors) where D is the diagonal Smith form
        and invariant_factors is the list of diagonal entries > 1.

    Complexity: O(n² · m · log(max|M|)) where n×m is the matrix size.

    Example:
        >>> D, factors = smith_normal_form([[2, 0], [0, 6]])
        >>> factors
        [2, 6]
    """
    M = [row[:] for row in M]
    rows = len(M)
    cols = len(M[0]) if rows > 0 else 0
    pivots = []

    for k in range(min(rows, cols)):
        # Find nonzero entry in submatrix M[k:, k:]
        min_val = None
        min_row, min_col = k, k
        for i in range(k, rows):
            for j in range(k, cols):
                if M[i][j] != 0:
                    if min_val is None or abs(M[i][j]) < min_val:
                        min_val = abs(M[i][j])
                        min_row, min_col = i, j
        if min_val is None:
            break

        # Swap to pivot position
        M[k], M[min_row] = M[min_row], M[k]
        for i in range(rows):
            M[i][k], M[i][min_col] = M[i][min_col], M[i][k]

        # Make pivot positive
        if M[k][k] < 0:
            M[k] = [-x for x in M[k]]

        # Eliminate using gcd operations
        changed = True
        while changed:
            changed = False
            # Column elimination
            for j in range(k + 1, cols):
                if M[k][j] != 0:
                    q = M[k][j] // M[k][k]
                    for i2 in range(rows):
                        M[i2][j] -= q * M[i2][k]
                    if M[k][j] != 0:
                        if abs(M[k][j]) < abs(M[k][k]):
                            for i2 in range(rows):
                                M[i2][k], M[i2][j] = M[i2][j], M[i2][k]
                            changed = True
            # Row elimination
            for i in range(k + 1, rows):
                if M[i][k] != 0:
                    q = M[i][k] // M[k][k]
                    for j2 in range(cols):
                        M[i][j2] -= q * M[k][j2]
                    if M[i][k] != 0:
                        if abs(M[i][k]) < abs(M[k][k]):
                            M[k], M[i] = M[i], M[k]
                            changed = True

        pivots.append(abs(M[k][k]))

    # Extract invariant factors (> 1)
    invariant_factors = [p for p in pivots if p > 1]
    return M, invariant_factors


def compute_ext1(n: int, free_rank: int, torsion_factors: List[int]) -> dict:
    """
    Compute Ext¹(ℤ/nℤ, A) where A = ℤ^r ⊕ ⊕ᵢ ℤ/dᵢℤ.

    Algorithm (from verified theorem ext1_Zmod_eq_quotient):
      1. Ext¹(ℤ/nℤ, A) ≅ A/nA (cokernel of multiplication by n)
      2. For A = ℤ^r ⊕ ⊕ ℤ/dᵢℤ:
         A/nA ≅ (ℤ/nℤ)^r ⊕ ⊕ᵢ ℤ/gcd(n,dᵢ)ℤ

    Args:
        n: the modulus (n > 0)
        free_rank: rank of the free part of A
        torsion_factors: list of torsion factor orders

    Returns:
        dict with 'free_rank' (copies of ℤ/nℤ) and 'torsion_factors'

    Example:
        >>> compute_ext1(6, 1, [4])
        {'description': 'ℤ/6ℤ ⊕ ℤ/2ℤ', 'free_copies_of_ZnZ': 1, 'torsion_gcds': [2]}
    """
    assert n > 0, "n must be positive"
    torsion_gcds = [gcd(n, d) for d in torsion_factors if gcd(n, d) > 1]

    parts = []
    for _ in range(free_rank):
        parts.append(f"ℤ/{n}ℤ")
    for g in torsion_gcds:
        parts.append(f"ℤ/{g}ℤ")

    order = n ** free_rank
    for g in torsion_gcds:
        order *= g

    return {
        "description": " ⊕ ".join(parts) if parts else "0",
        "free_copies_of_ZnZ": free_rank,
        "torsion_gcds": torsion_gcds,
        "order": order,
    }


def compute_tor1(n: int, free_rank: int, torsion_factors: List[int]) -> dict:
    """
    Compute Tor₁(ℤ/nℤ, A) where A = ℤ^r ⊕ ⊕ᵢ ℤ/dᵢℤ.

    Algorithm (from verified theorem tor1_Zmod_eq_torsion):
      1. Tor₁(ℤ/nℤ, A) ≅ A[n] (kernel of multiplication by n)
      2. For A = ℤ^r ⊕ ⊕ ℤ/dᵢℤ:
         A[n] ≅ ⊕ᵢ ℤ/gcd(n,dᵢ)ℤ  (free part contributes 0)

    Args:
        n: the modulus (n > 0)
        free_rank: rank of the free part of A
        torsion_factors: list of torsion factor orders

    Returns:
        dict with computed invariants

    Example:
        >>> compute_tor1(6, 1, [4])
        {'description': 'ℤ/2ℤ', 'torsion_gcds': [2], 'is_zero': False}
    """
    assert n > 0, "n must be positive"
    torsion_gcds = [gcd(n, d) for d in torsion_factors if gcd(n, d) > 1]

    parts = [f"ℤ/{g}ℤ" for g in torsion_gcds]

    return {
        "description": " ⊕ ".join(parts) if parts else "0",
        "torsion_gcds": torsion_gcds,
        "is_zero": len(torsion_gcds) == 0,
        "order": (1 if not torsion_gcds else
                  eval('*'.join(str(g) for g in torsion_gcds)) if torsion_gcds else 1),
    }


def check_torsion_detection(n: int, free_rank: int, torsion_factors: List[int]) -> dict:
    """
    Apply the torsion detection theorem (tor1_vanishes_iff_no_n_torsion):
      Tor₁(ℤ/nℤ, A) = 0  ⟺  A has no n-torsion

    This is the cross-domain theorem connecting homological algebra
    to coding theory and physics.
    """
    tor1 = compute_tor1(n, free_rank, torsion_factors)
    has_torsion = not tor1["is_zero"]

    return {
        "n": n,
        "has_n_torsion": has_torsion,
        "tor1_vanishes": tor1["is_zero"],
        "tor1": tor1["description"],
        "interpretation": (
            f"A has {n}-torsion defects (obstructions exist)"
            if has_torsion
            else f"A is {n}-torsion-free (no obstructions)"
        ),
    }


def universal_coefficient_theorem(
    chain_homology: List[Tuple[int, List[int]]],
    coeff_free_rank: int,
    coeff_torsion: List[int],
) -> List[dict]:
    """
    Apply the Universal Coefficient Theorem for a chain complex C
    of free abelian groups with coefficient module A:

      0 → Hₙ(C) ⊗ A → Hₙ(C; A) → Tor₁(Hₙ₋₁(C), A) → 0

    Args:
        chain_homology: list of (free_rank, torsion_factors) for Hₙ(C)
        coeff_free_rank: free rank of coefficient module A
        coeff_torsion: torsion factors of coefficient module A

    Returns:
        list of dicts, one per degree, with UCT decomposition
    """
    results = []
    for deg in range(len(chain_homology)):
        fr, tf = chain_homology[deg]

        # Tensor term
        # Hₙ(C) ⊗ A: computed by distributivity
        # ℤ ⊗ A ≅ A, ℤ/dℤ ⊗ A ≅ A/dA
        tensor_parts_desc = []
        for _ in range(fr):
            if coeff_free_rank > 0 or coeff_torsion:
                desc = []
                for _ in range(coeff_free_rank):
                    desc.append("ℤ")
                for d in coeff_torsion:
                    desc.append(f"ℤ/{d}ℤ")
                tensor_parts_desc.append(" ⊕ ".join(desc))
        for d in tf:
            ext = compute_ext1(d, coeff_free_rank, coeff_torsion)
            if ext["description"] != "0":
                tensor_parts_desc.append(ext["description"])
        tensor_desc = " ⊕ ".join(tensor_parts_desc) if tensor_parts_desc else "0"

        # Tor term (from previous degree)
        if deg > 0:
            pfr, ptf = chain_homology[deg - 1]
            # Tor₁(Hₙ₋₁, A): for each torsion factor d of Hₙ₋₁ and each
            # torsion factor e of A, contribute ℤ/gcd(d,e)ℤ
            tor_parts = []
            for d in ptf:
                for e in coeff_torsion:
                    g = gcd(d, e)
                    if g > 1:
                        tor_parts.append(f"ℤ/{g}ℤ")
            tor_desc = " ⊕ ".join(tor_parts) if tor_parts else "0"
            splits = tor_desc == "0"
        else:
            tor_desc = "0"
            splits = True

        results.append({
            "degree": deg,
            "tensor_term": tensor_desc,
            "tor_term": tor_desc,
            "splits": splits,
            "isomorphism": (
                f"Hₙ(C; A) ≅ {tensor_desc}"
                if splits
                else f"0 → {tensor_desc} → Hₙ(C; A) → {tor_desc} → 0"
            ),
        })

    return results


def presentation_to_invariants(matrix: List[List[int]]) -> Tuple[int, List[int]]:
    """
    Convert a presentation matrix to (free_rank, invariant_factors).

    A finitely presented abelian group G given by presentation matrix M
    (where G = ℤ^cols / im(M)) has structure determined by Smith Normal Form.

    Args:
        matrix: integer presentation matrix (generators as columns)

    Returns:
        (free_rank, torsion_factors)
    """
    rows = len(matrix)
    cols = len(matrix[0]) if rows > 0 else 0
    _, factors = smith_normal_form(matrix)
    free_rank = cols - len(factors) - max(0, rows - cols)
    return max(0, free_rank), factors


if __name__ == "__main__":
    print("=== Smith Normal Form Example ===")
    M = [[2, 4], [0, 6]]
    D, factors = smith_normal_form(M)
    print(f"Input matrix: {M}")
    print(f"Smith form: {D}")
    print(f"Invariant factors: {factors}")
    fr, tf = presentation_to_invariants(M)
    print(f"Group: ℤ^{fr} ⊕ {'⊕'.join(f'ℤ/{d}ℤ' for d in tf) if tf else '0'}")

    print("\n=== Ext¹ and Tor₁ Computation ===")
    for n in [2, 3, 6]:
        ext = compute_ext1(n, fr, tf)
        tor = compute_tor1(n, fr, tf)
        det = check_torsion_detection(n, fr, tf)
        print(f"\nn = {n}:")
        print(f"  Ext¹(ℤ/{n}ℤ, G) = {ext['description']}")
        print(f"  Tor₁(ℤ/{n}ℤ, G) = {tor['description']}")
        print(f"  {det['interpretation']}")

    print("\n=== Universal Coefficient Theorem (RP²) ===")
    # RP²: H₀=ℤ, H₁=ℤ/2ℤ, H₂=0
    homology = [(1, []), (0, [2]), (0, [])]
    results = universal_coefficient_theorem(homology, 0, [2])
    for r in results:
        print(f"  Degree {r['degree']}: {r['isomorphism']}")
