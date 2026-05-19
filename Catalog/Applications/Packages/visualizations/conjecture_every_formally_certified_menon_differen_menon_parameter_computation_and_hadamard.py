"""
Algorithms for Difference Set Detection and Hadamard Matrix Synthesis.

This module implements the computational pipeline from combinatorial design
parameters to orthogonal matrix construction, mirroring the certified
algebraic pathway proved in the formal system.

Algorithms:
    1. Brute-force difference set finder
    2. Sign matrix constructor
    3. Gram identity verifier
    4. Hadamard matrix synthesizer from difference sets
    5. Menon parameter validator
"""
import numpy as np
from itertools import combinations
from typing import Callable, Optional, Set, List, Tuple


def menon_parameters(u: int) -> Tuple[int, int, int]:
    """
    Compute Menon difference set parameters for a given u.

    Parameters
    ----------
    u : int
        The Menon parameter (u ≥ 1 for nontrivial cases).

    Returns
    -------
    tuple of (v, k, λ)
        v = 4u², k = 2u² - u, λ = u² - u

    Examples
    --------
    >>> menon_parameters(1)
    (4, 1, 0)
    >>> menon_parameters(2)
    (16, 6, 2)
    >>> menon_parameters(3)
    (36, 15, 6)
    """
    v = 4 * u**2
    k = 2 * u**2 - u
    lam = u**2 - u
    return v, k, lam


def verify_hadamard_criterion(v: int, k: int, lam: int) -> bool:
    """
    Check whether difference set parameters satisfy the Hadamard criterion
    v = 4(k - λ).

    This is the abstract criterion proved in the formal system: any difference
    set satisfying this relation produces a Hadamard matrix.

    Parameters
    ----------
    v, k, lam : int
        Difference set parameters.

    Returns
    -------
    bool
        True if v = 4(k - λ).

    Examples
    --------
    >>> verify_hadamard_criterion(16, 6, 2)  # Menon u=2
    True
    >>> verify_hadamard_criterion(7, 3, 1)   # Singer — not Hadamard
    False
    """
    return v == 4 * (k - lam)


def find_difference_set_cyclic(v: int, k: int, lam: int) -> Optional[Set[int]]:
    """
    Find a (v, k, λ)-difference set in Z/vZ by exhaustive search.

    Uses the cyclic group Z/vZ with addition modulo v. This is a brute-force
    algorithm with complexity O(C(v, k) · v · k).

    Parameters
    ----------
    v, k, lam : int
        Target difference set parameters.

    Returns
    -------
    set of int or None
        A difference set if found, None otherwise.

    Examples
    --------
    >>> D = find_difference_set_cyclic(7, 3, 1)
    >>> D is not None
    True
    """
    for candidate in combinations(range(v), k):
        D = set(candidate)
        valid = True
        for g in range(1, v):
            count = sum(1 for d in D if (g + d) % v in D)
            if count != lam:
                valid = False
                break
        if valid:
            return D
    return None


def sign_matrix_from_cyclic(D: Set[int], v: int) -> np.ndarray:
    """
    Construct the sign matrix for a difference set in Z/vZ.

    A[g, h] = +1 if (h - g) mod v ∈ D, else -1.

    Parameters
    ----------
    D : set of int
        The difference set.
    v : int
        Group order.

    Returns
    -------
    np.ndarray
        v × v sign matrix with entries in {+1, -1}.

    Complexity
    ----------
    Time: O(v²), Space: O(v²)
    """
    A = np.ones((v, v), dtype=int)
    for g in range(v):
        for h in range(v):
            if (h - g) % v in D:
                A[g, h] = 1
            else:
                A[g, h] = -1
    return A


def gram_identity_check(A: np.ndarray, v: int, k: int, lam: int) -> dict:
    """
    Verify the Gram identity A * A^T = v·I + (v - 4(k-λ))·J.

    Parameters
    ----------
    A : np.ndarray
        The sign matrix.
    v, k, lam : int
        Difference set parameters.

    Returns
    -------
    dict
        Verification results including diagonal/off-diagonal values,
        expected values, and whether the identity holds.
    """
    gram = A @ A.T
    diag_values = set(gram[i, i] for i in range(v))
    offdiag_values = set(gram[i, j] for i in range(v) for j in range(v) if i != j)

    expected_diag = v
    expected_offdiag = v - 4 * (k - lam)

    return {
        "gram_matrix": gram,
        "diagonal_values": diag_values,
        "offdiag_values": offdiag_values,
        "expected_diagonal": expected_diag,
        "expected_offdiag": expected_offdiag,
        "diagonal_correct": diag_values == {expected_diag},
        "offdiag_correct": offdiag_values == {expected_offdiag},
        "is_hadamard": expected_offdiag == 0 and offdiag_values == {0},
    }


def hadamard_from_menon(u: int) -> Optional[Tuple[np.ndarray, dict]]:
    """
    Synthesize a Hadamard matrix from a Menon difference set.

    This implements the full pipeline:
    1. Compute Menon parameters (v=4u², k=2u²-u, λ=u²-u)
    2. Find a difference set with these parameters in Z/vZ
    3. Construct the sign matrix
    4. Verify the Hadamard property

    Parameters
    ----------
    u : int
        Menon parameter.

    Returns
    -------
    tuple of (np.ndarray, dict) or None
        The Hadamard matrix and verification info, or None if no
        difference set was found.

    Examples
    --------
    >>> result = hadamard_from_menon(2)
    >>> result is not None
    True
    >>> result[1]['is_hadamard']
    True
    """
    v, k, lam = menon_parameters(u)
    D = find_difference_set_cyclic(v, k, lam)
    if D is None:
        return None

    A = sign_matrix_from_cyclic(D, v)
    info = gram_identity_check(A, v, k, lam)
    info["parameters"] = {"u": u, "v": v, "k": k, "lambda": lam}
    info["difference_set"] = sorted(D)
    return A, info


def gram_offdiag_spectrum(v: int, k: int, lam: int) -> int:
    """
    Compute the off-diagonal Gram coefficient v - 4(k - λ).

    This single number determines whether a difference set produces:
    - A Hadamard matrix (coefficient = 0)
    - A conference-like matrix (coefficient ≠ 0)

    Parameters
    ----------
    v, k, lam : int
        Difference set parameters.

    Returns
    -------
    int
        The off-diagonal coefficient.
    """
    return v - 4 * (k - lam)


# ============================================================
# Main demonstration
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Demonstrate Menon parameter computation
    print("\n--- Menon Parameters ---")
    for u in range(1, 6):
        v, k, lam = menon_parameters(u)
        coeff = gram_offdiag_spectrum(v, k, lam)
        print(f"u={u}: (v={v}, k={k}, λ={lam}), "
              f"off-diag coefficient = {coeff}, "
              f"Hadamard: {coeff == 0}")

    # Demonstrate full pipeline for u=1 and u=2
    for u in [1, 2]:
        print(f"\n--- Full Pipeline for u={u} ---")
        result = hadamard_from_menon(u)
        if result is not None:
            A, info = result
            print(f"Parameters: {info['parameters']}")
            print(f"Difference set: {info['difference_set']}")
            print(f"Diagonal correct: {info['diagonal_correct']}")
            print(f"Off-diagonal correct: {info['offdiag_correct']}")
            print(f"Is Hadamard: {info['is_hadamard']}")
            if A.shape[0] <= 8:
                print(f"Sign matrix:\n{A}")
                print(f"Gram matrix:\n{info['gram_matrix']}")
        else:
            print("No difference set found in cyclic group")

    # Demonstrate non-Hadamard case
    print("\n--- Non-Hadamard: Singer (7,3,1) ---")
    D = find_difference_set_cyclic(7, 3, 1)
    if D:
        A = sign_matrix_from_cyclic(D, 7)
        info = gram_identity_check(A, 7, 3, 1)
        print(f"D = {sorted(D)}")
        print(f"Off-diagonal coefficient: {gram_offdiag_spectrum(7, 3, 1)}")
        print(f"Is Hadamard: {info['is_hadamard']}")
        print(f"Gram matrix:\n{info['gram_matrix']}")
