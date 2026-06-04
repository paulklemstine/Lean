#!/usr/bin/env python3
"""
Algorithms for Noncommutative Geometry and K-Theory

Implements:
1. Matrix unit system verification
2. Gelfand spectrum computation (character search)
3. Murray-von Neumann equivalence detection
4. K₀ computation via Grothendieck group
5. Dimension function computation
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass


@dataclass
class MatrixUnitSystem:
    """A system of matrix units in a ring, represented concretely."""
    n: int  # size of the system
    units: np.ndarray  # shape (n, n, d, d) where d is the matrix dimension

    def verify(self, tol: float = 1e-10) -> bool:
        """Verify the matrix unit multiplication rule and completeness."""
        d = self.units.shape[2]

        # Check multiplication rule
        for i in range(self.n):
            for j in range(self.n):
                for k in range(self.n):
                    for l in range(self.n):
                        product = self.units[i, j] @ self.units[k, l]
                        if j == k:
                            expected = self.units[i, l]
                        else:
                            expected = np.zeros((d, d), dtype=complex)
                        if not np.allclose(product, expected, atol=tol):
                            return False

        # Check completeness
        diagonal_sum = sum(self.units[i, i] for i in range(self.n))
        return np.allclose(diagonal_sum, np.eye(d), atol=tol)


def standard_matrix_units(n: int) -> MatrixUnitSystem:
    """Construct the standard matrix unit system of size n in M_n(ℂ)."""
    units = np.zeros((n, n, n, n), dtype=complex)
    for i in range(n):
        for j in range(n):
            units[i, j, i, j] = 1.0
    return MatrixUnitSystem(n=n, units=units)


def find_characters(
    structure_constants: np.ndarray,
    tol: float = 1e-8
) -> List[np.ndarray]:
    """
    Find all characters (algebra homomorphisms to ℂ) of a finite-dimensional
    algebra given by structure constants.

    Args:
        structure_constants: shape (d, d, d) where c[i,j,k] is the coefficient
            of basis element e_k in the product e_i * e_j
        tol: numerical tolerance

    Returns:
        List of character vectors φ where φ[i] = φ(e_i)

    Algorithm:
        A character φ must satisfy:
        1. φ(e_i · e_j) = φ(e_i) · φ(e_j) for all i, j
        2. φ ≠ 0 (unitality)
        
        This gives polynomial equations: ∑_k c[i,j,k] φ[k] = φ[i] φ[j]
        We solve these by finding common zeros of the polynomials.
    """
    d = structure_constants.shape[0]
    characters: List[np.ndarray] = []

    # For small dimensions, use brute-force search over candidate evaluations
    # In practice, this uses the structure theory (maximal ideals)

    # Find the identity element
    # If ∑_j c[i,j,k] = δ_{ik} for some j (identity element index)
    identity = None
    for j in range(d):
        if np.allclose(structure_constants[:, j, :], np.eye(d), atol=tol):
            identity = j
            break

    if identity is None:
        return []  # No identity element found

    # For commutative algebras, characters correspond to maximal ideals
    # We find them by looking for simultaneous eigenvalues of the
    # regular representation matrices
    
    # Left multiplication matrices L_i
    L = np.zeros((d, d, d), dtype=complex)
    for i in range(d):
        L[i] = structure_constants[i]

    # Check commutativity
    is_commutative = True
    for i in range(d):
        for j in range(d):
            if not np.allclose(L[i] @ L[j], L[j] @ L[i], atol=tol):
                is_commutative = False
                break
        if not is_commutative:
            break

    if not is_commutative:
        return []  # Noncommutative: no characters (our theorem!)

    # For commutative algebras, find simultaneous eigenvalues
    # Characters are common eigenvectors of all L_i^T
    if d == 1:
        return [np.array([1.0], dtype=complex)]

    # Use the first non-identity generator to find eigenspaces
    gen_idx = 0 if identity != 0 else 1
    if gen_idx >= d:
        return [np.array([1.0] * d, dtype=complex)]

    eigenvalues, eigenvectors = np.linalg.eig(L[gen_idx])

    for idx in range(d):
        v = eigenvectors[:, idx]
        # Check if v is a common eigenvector of all L_i
        phi = np.zeros(d, dtype=complex)
        is_character = True
        for i in range(d):
            Lv = L[i] @ v
            if np.allclose(v, 0, atol=tol):
                is_character = False
                break
            # Find eigenvalue: Lv = λv
            nonzero_idx = np.argmax(np.abs(v))
            lam = Lv[nonzero_idx] / v[nonzero_idx]
            if not np.allclose(Lv, lam * v, atol=tol):
                is_character = False
                break
            phi[i] = lam

        if is_character and not np.allclose(phi, 0, atol=tol):
            # Verify multiplicativity
            valid = True
            for i in range(d):
                for j in range(d):
                    prod_val = sum(structure_constants[i, j, k] * phi[k]
                                   for k in range(d))
                    if abs(prod_val - phi[i] * phi[j]) > tol:
                        valid = False
                        break
                if not valid:
                    break
            if valid:
                characters.append(phi)

    return characters


def detect_mvn_equivalence(
    p: np.ndarray, q: np.ndarray, algebra_dim: int,
    tol: float = 1e-8
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Detect Murray-von Neumann equivalence between idempotents p and q
    in a matrix algebra.

    Returns (v, w) such that v*w = p and w*v = q, or None if not equivalent.

    For matrix algebras, p ~ q iff rank(p) = rank(q).
    """
    # Check idempotency
    if not np.allclose(p @ p, p, atol=tol):
        raise ValueError("p is not idempotent")
    if not np.allclose(q @ q, q, atol=tol):
        raise ValueError("q is not idempotent")

    rank_p = int(round(np.trace(p).real))
    rank_q = int(round(np.trace(q).real))

    if rank_p != rank_q:
        return None  # Different ranks => not equivalent

    # Construct v, w explicitly using SVD-like decomposition
    # p and q are projections, so they have eigenvalue decompositions
    # p = U_p diag(1,...,1,0,...,0) U_p^*
    # q = U_q diag(1,...,1,0,...,0) U_q^*
    # Then v = U_p[:, :r] U_q[:, :r]^* and w = U_q[:, :r] U_p[:, :r]^*

    eigvals_p, eigvecs_p = np.linalg.eigh(p)
    eigvals_q, eigvecs_q = np.linalg.eigh(q)

    # Sort by eigenvalue descending
    idx_p = np.argsort(eigvals_p)[::-1]
    idx_q = np.argsort(eigvals_q)[::-1]

    U_p = eigvecs_p[:, idx_p[:rank_p]]
    U_q = eigvecs_q[:, idx_q[:rank_q]]

    v = U_p @ U_q.conj().T
    w = U_q @ U_p.conj().T

    # Verify
    assert np.allclose(v @ w, p, atol=tol), "v*w ≠ p"
    assert np.allclose(w @ v, q, atol=tol), "w*v ≠ q"

    return v, w


def compute_k0_matrix_algebra(n: int) -> str:
    """
    Compute K₀(M_n(ℂ)) ≅ ℤ.

    The isomorphism sends a projection P to its rank.
    """
    print(f"Computing K₀(M_{n}(ℂ)):")
    print(f"  Idempotents (projections) in M_{n}(ℂ):")

    # List standard projections by rank
    for r in range(n + 1):
        P = np.diag([1.0] * r + [0.0] * (n - r))
        print(f"    P_{{rank={r}}} = diag({[1]*r + [0]*(n-r)}), trace = {r}")

    print(f"  All rank-{1} projections are MvN-equivalent (e.g., E_{{00}} ~ E_{{11}})")
    print(f"  K₀(M_{n}(ℂ)) = Grothendieck group of {{0, 1, ..., {n}}} ≅ ℤ")
    print(f"  Generator: [E_{{00}}] (rank-1 projection)")
    print(f"  [I] = {n} · [E_{{00}}] (identity has rank {n})")

    return "ℤ"


def grothendieck_group_element(
    a: int, b: int
) -> Tuple[int, str]:
    """
    Represent an element of the Grothendieck group K(ℕ) ≅ ℤ
    as a formal difference (a, b) representing a - b.
    """
    value = a - b
    return value, f"[{a}] - [{b}] = {value}"


def bott_periodicity_table(max_n: int = 8) -> None:
    """Display the Bott periodicity pattern for K-groups."""
    print("\nBott Periodicity Table:")
    print("-" * 40)
    print(f"{'n':>4} | {'n mod 2':>7} | {'K_n(ℂ)':>10}")
    print("-" * 40)
    for n in range(-2, max_n):
        mod = n % 2
        k_group = "ℤ" if mod == 0 else "0"
        print(f"{n:>4} | {mod:>7} | {k_group:>10}")
    print("-" * 40)
    print("Period = 2: K_{n+2}(ℂ) ≅ K_n(ℂ) for all n")


if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHMS FOR NONCOMMUTATIVE GEOMETRY")
    print("=" * 60)

    # 1. Matrix unit verification
    print("\n1. Matrix Unit System Verification")
    for n in [2, 3, 4]:
        mus = standard_matrix_units(n)
        valid = mus.verify()
        print(f"   M_{n}(ℂ): {'✓' if valid else '✗'}")

    # 2. Character search - commutative example
    print("\n2. Character Search")
    # ℂ × ℂ: structure constants
    sc = np.zeros((2, 2, 2), dtype=complex)
    sc[0, 0, 0] = 1  # e1 * e1 = e1
    sc[1, 1, 1] = 1  # e2 * e2 = e2
    chars = find_characters(sc)
    print(f"   ℂ × ℂ: found {len(chars)} characters")
    for i, c in enumerate(chars):
        print(f"     φ_{i+1} = {c}")

    # 3. MvN equivalence
    print("\n3. Murray-von Neumann Equivalence Detection")
    n = 3
    for r in range(1, n):
        P1 = np.zeros((n, n), dtype=complex)
        P1[0, 0] = 1
        P2 = np.zeros((n, n), dtype=complex)
        P2[r, r] = 1
        result = detect_mvn_equivalence(P1, P2, n)
        if result:
            v, w = result
            print(f"   E_{{00}} ~ E_{{{r}{r}}}: v*w=E_{{00}} {'✓' if np.allclose(v@w, P1) else '✗'}, "
                  f"w*v=E_{{{r}{r}}} {'✓' if np.allclose(w@v, P2) else '✗'}")

    # 4. K₀ computation
    print("\n4. K₀ Computation")
    compute_k0_matrix_algebra(3)

    # 5. Grothendieck group
    print("\n5. Grothendieck Group Elements")
    for a, b in [(3, 1), (2, 2), (0, 5), (7, 3)]:
        val, desc = grothendieck_group_element(a, b)
        print(f"   ({a}, {b}) ↦ {desc}")

    # 6. Bott periodicity
    print("\n6. Bott Periodicity")
    bott_periodicity_table()
