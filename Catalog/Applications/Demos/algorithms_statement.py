#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Freivalds' verification and finite-field linear algebra.

Implements:
1. Freivalds' randomized matrix verification (single and multi-trial)
2. Kernel counting for linear maps over finite fields
3. Hyperplane counting and affine solution enumeration
4. Soundness amplification analysis
"""

import numpy as np
from typing import Tuple, Optional, List
from itertools import product as cartesian_product


class FiniteFieldMatrix:
    """Matrix arithmetic over GF(q) for prime q."""

    def __init__(self, data: np.ndarray, q: int):
        """
        Args:
            data: Integer matrix (entries taken mod q)
            q: Prime field characteristic
        """
        self.q = q
        self.data = data % q
        self.m, self.n = data.shape

    def __matmul__(self, other: 'FiniteFieldMatrix') -> 'FiniteFieldMatrix':
        assert self.q == other.q and self.n == other.m
        return FiniteFieldMatrix(self.data @ other.data, self.q)

    def mulvec(self, r: np.ndarray) -> np.ndarray:
        """Compute M @ r mod q."""
        return (self.data @ r) % self.q

    def __sub__(self, other: 'FiniteFieldMatrix') -> 'FiniteFieldMatrix':
        return FiniteFieldMatrix(self.data - other.data, self.q)

    def __eq__(self, other: 'FiniteFieldMatrix') -> bool:
        return self.q == other.q and np.array_equal(self.data, other.data)

    def __ne__(self, other: 'FiniteFieldMatrix') -> bool:
        return not self.__eq__(other)

    def is_zero(self) -> bool:
        return np.all(self.data == 0)

    def __repr__(self):
        return f"FiniteFieldMatrix(mod {self.q}):\n{self.data}"


def freivalds_single_check(
    A: FiniteFieldMatrix,
    B: FiniteFieldMatrix,
    K: FiniteFieldMatrix,
    r: Optional[np.ndarray] = None
) -> Tuple[bool, np.ndarray]:
    """
    Single-trial Freivalds check: is K == A @ B?

    Algorithm:
        1. Sample random r ∈ GF(q)^p (or use provided r)
        2. Compute K·r and A·(B·r)
        3. Accept if they are equal

    Args:
        A: m×n matrix over GF(q)
        B: n×p matrix over GF(q)
        K: m×p matrix (claimed product)
        r: Optional test vector; random if None

    Returns:
        (accepted, r): Whether the check passed, and the vector used

    Complexity: O(mp + np) field operations (vs O(mnp) for direct multiply)
    """
    q = A.q
    p = B.n

    if r is None:
        r = np.random.randint(0, q, p)

    # Compute B·r first (n operations per row of B)
    Br = B.mulvec(r)
    # Then A·(B·r) (m operations per row of A)
    ABr = A.mulvec(Br)
    # Compute K·r
    Kr = K.mulvec(r)

    return np.array_equal(ABr, Kr), r


def freivalds_multi_check(
    A: FiniteFieldMatrix,
    B: FiniteFieldMatrix,
    K: FiniteFieldMatrix,
    t: int = 1
) -> Tuple[bool, float]:
    """
    Multi-trial Freivalds verification with t independent trials.

    Soundness: If K ≠ A·B, then Pr[all t trials accept] ≤ (1/q)^t

    Args:
        A, B, K: Matrices over GF(q)
        t: Number of independent trials

    Returns:
        (accepted, error_bound): Whether all trials passed,
                                  and the theoretical error bound

    Complexity: O(t · (mp + np)) field operations
    """
    q = A.q

    for _ in range(t):
        accepted, _ = freivalds_single_check(A, B, K)
        if not accepted:
            return False, 0.0

    return True, (1.0 / q) ** t


def count_kernel(M: FiniteFieldMatrix) -> int:
    """
    Count |{r ∈ GF(q)^p | M·r = 0}| by exhaustive enumeration.

    For a nonzero m×p matrix M over GF(q):
        - |ker(M)| ≤ q^(p-1)  (our main theorem)
        - |ker(M)| = q^(p - rank(M))  (exact formula)

    Complexity: O(q^p · mp) — only for small instances!
    """
    q = M.q
    p = M.n
    count = 0
    for r_tuple in cartesian_product(range(q), repeat=p):
        r = np.array(r_tuple)
        if np.all(M.mulvec(r) == 0):
            count += 1
    return count


def count_hyperplane_solutions(
    w: np.ndarray, b: int, q: int
) -> int:
    """
    Count |{r ∈ GF(q)^p | w·r = b mod q}|.

    For nonzero w, this equals exactly q^(p-1).

    Args:
        w: Coefficient vector (nonzero)
        b: Right-hand side
        q: Field characteristic (prime)

    Returns:
        Number of solutions
    """
    p = len(w)
    count = 0
    for r_tuple in cartesian_product(range(q), repeat=p):
        r = np.array(r_tuple)
        if sum(w[i] * r[i] for i in range(p)) % q == b % q:
            count += 1
    return count


def gf_rank(M: FiniteFieldMatrix) -> int:
    """
    Compute the rank of M over GF(q) via Gaussian elimination.

    Uses modular arithmetic with modular inverse.
    """
    q = M.q
    mat = M.data.copy() % q
    m, n = mat.shape
    rank = 0

    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(rank, m):
            if mat[row, col] % q != 0:
                pivot = row
                break

        if pivot is None:
            continue

        # Swap rows
        mat[[rank, pivot]] = mat[[pivot, rank]]

        # Compute modular inverse of pivot element
        pivot_val = int(mat[rank, col]) % q
        pivot_inv = pow(pivot_val, q - 2, q)  # Fermat's little theorem

        # Scale pivot row
        mat[rank] = (mat[rank] * pivot_inv) % q

        # Eliminate column
        for row in range(m):
            if row != rank and mat[row, col] % q != 0:
                factor = int(mat[row, col])
                mat[row] = (mat[row] - factor * mat[rank]) % q

        rank += 1

    return rank


def kernel_size_formula(M: FiniteFieldMatrix) -> int:
    """
    Compute |ker(M)| = q^(p - rank(M)) using the rank.

    This is the exact formula; our main theorem proves the
    weaker bound |ker(M)| ≤ q^(p-1) for nonzero M.
    """
    r = gf_rank(M)
    return M.q ** (M.n - r)


def soundness_amplification_table(q: int, max_t: int = 20) -> List[dict]:
    """
    Compute the soundness amplification table for t trials over GF(q).

    For each t, the false-accept probability is at most (1/q)^t.

    Returns:
        List of dicts with {t, bound, bits_of_security, random_bits_needed}
    """
    results = []
    for t in range(1, max_t + 1):
        bound = (1.0 / q) ** t
        bits = t * np.log2(q)
        random_bits = t * int(np.ceil(np.log2(q)))  # per coordinate
        results.append({
            't': t,
            'bound': bound,
            'bits_of_security': bits,
            'random_field_elements': t,  # p elements per trial, but q-ary
        })
    return results


# ─── Example usage ───

if __name__ == "__main__":
    print("=== Freivalds' Algorithm Demo ===\n")

    q = 7
    m, n, p = 4, 4, 4

    np.random.seed(42)
    A = FiniteFieldMatrix(np.random.randint(0, q, (m, n)), q)
    B = FiniteFieldMatrix(np.random.randint(0, q, (n, p)), q)
    K_correct = A @ B
    K_wrong_data = K_correct.data.copy()
    K_wrong_data[0, 0] = (K_wrong_data[0, 0] + 1) % q
    K_wrong = FiniteFieldMatrix(K_wrong_data, q)

    print(f"Working over GF({q})")
    print(f"Matrices: {m}×{n} times {n}×{p}\n")

    # Single trial
    accepted, r = freivalds_single_check(A, B, K_correct)
    print(f"Correct product, single trial: {'ACCEPT' if accepted else 'REJECT'}")

    accepted, r = freivalds_single_check(A, B, K_wrong)
    print(f"Wrong product, single trial: {'ACCEPT' if accepted else 'REJECT'}")

    # Multi-trial
    for t in [1, 5, 10, 20]:
        accepted, bound = freivalds_multi_check(A, B, K_wrong, t)
        print(f"Wrong product, {t} trials: {'ACCEPT' if accepted else 'REJECT'} "
              f"(error bound: {bound:.2e})")

    # Rank and kernel
    print("\n=== Kernel Analysis ===")
    M = K_wrong - K_correct
    r = gf_rank(M)
    ker_size = kernel_size_formula(M)
    print(f"Difference matrix rank: {r}")
    print(f"|ker(K-AB)| = {q}^({p}-{r}) = {ker_size}")
    print(f"Bound q^(p-1) = {q}^{p-1} = {q**(p-1)}")
    print(f"Pr[false accept] ≤ {ker_size}/{q**p} = {ker_size/q**p:.6f}")
    print(f"1/q = {1/q:.6f}")

    # Soundness amplification
    print("\n=== Soundness Amplification Table ===")
    table = soundness_amplification_table(q, 10)
    print(f"{'t':>3} | {'Pr bound':>12} | {'Security bits':>14}")
    print("-" * 35)
    for row in table:
        print(f"{row['t']:3d} | {row['bound']:12.2e} | {row['bits_of_security']:14.1f}")
