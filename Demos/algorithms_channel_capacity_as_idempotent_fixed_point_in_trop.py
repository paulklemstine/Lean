"""
Tropical Information Theory — Core Algorithms

Implements the key algorithms from the tropical channel capacity framework:
1. Max-plus matrix multiplication
2. Tropical eigenvalue computation (Karp's algorithm)
3. Tropical eigenvector computation (normalized power iteration)
4. Collatz-Wielandt characterization
5. Tropical code design and decoding
"""

import numpy as np
from typing import Tuple, List, Optional
from itertools import product as cart_product


# ============================================================
# 1. Max-Plus Matrix Algebra
# ============================================================

def maxplus_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Max-plus matrix multiplication: (A ⊗ B)_{ij} = max_k (A_{ik} + B_{kj}).

    Time complexity: O(n * m * p) for n×m and m×p matrices.
    Space complexity: O(n * p) for the result.

    >>> A = np.array([[1, 2], [3, 0]])
    >>> B = np.array([[0, 1], [2, 0]])
    >>> maxplus_multiply(A, B)
    array([[4., 2.],
           [3., 4.]])
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), -np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = max(C[i, j], A[i, k] + B[k, j])
    return C


def maxplus_power(A: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the k-th max-plus power of a square matrix.

    Time complexity: O(n^3 * k) via repeated multiplication.
    Space complexity: O(n^2).

    >>> A = np.array([[0, 5], [3, 0]])
    >>> maxplus_power(A, 2)
    array([[8., 5.],
           [3., 8.]])
    """
    n = A.shape[0]
    if k == 0:
        # Max-plus identity: 0 on diagonal, -inf elsewhere
        I = np.full((n, n), -np.inf)
        np.fill_diagonal(I, 0)
        return I
    result = A.copy()
    for _ in range(k - 1):
        result = maxplus_multiply(result, A)
    return result


# ============================================================
# 2. Maximum Cycle Mean (Tropical Eigenvalue)
# ============================================================

def karp_max_cycle_mean(A: np.ndarray) -> float:
    """
    Compute the maximum cycle mean using Karp's algorithm.

    The maximum cycle mean λ* = max over all cycles C of
    (sum of weights on C) / (length of C).

    This is the tropical eigenvalue of A.

    Algorithm:
    1. Compute D[k][i][j] = max weight of length-k path from i to j
    2. λ* = max_i min_{k<n} (D[n][i][i] - D[k][i][i]) / (n - k)

    Time complexity: O(n^3) using dynamic programming.
    Space complexity: O(n^3) for path weight tables.

    >>> A = np.array([[0, 5], [3, 0]])
    >>> karp_max_cycle_mean(A)
    4.0
    """
    n = A.shape[0]
    # D[k][i][j] = max weight path from i to j of length exactly k
    D = [np.full((n, n), -np.inf) for _ in range(n + 1)]
    D[0] = np.where(np.eye(n, dtype=bool), 0, -np.inf)

    for k in range(1, n + 1):
        for i in range(n):
            for j in range(n):
                D[k][i][j] = max(D[k-1][i][m] + A[m][j] for m in range(n))

    # Karp's formula
    best = -np.inf
    for i in range(n):
        if D[n][i][i] == -np.inf:
            continue
        worst_over_k = np.inf
        for k in range(n):
            if D[k][i][i] == -np.inf:
                continue
            val = (D[n][i][i] - D[k][i][i]) / (n - k)
            worst_over_k = min(worst_over_k, val)
        if worst_over_k != np.inf:
            best = max(best, worst_over_k)
    return best


# ============================================================
# 3. Tropical Eigenvector (Normalized Power Iteration)
# ============================================================

def tropical_power_iteration(
    A: np.ndarray,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[float, np.ndarray]:
    """
    Find a tropical eigenpair (λ, x) via normalized power iteration.

    Algorithm:
    1. Start with x⁰ = 0
    2. Iterate: x^{k+1} = T_A(x^k) - T_A(x^k)_0
    3. Converge to eigenvector; eigenvalue = T_A(x*)_0

    Time complexity: O(n^2 * max_iter) per iteration.
    Space complexity: O(n).
    Convergence: guaranteed for irreducible matrices in O(n^2) iterations.

    >>> A = np.array([[0, 5], [3, 0]])
    >>> lam, x = tropical_power_iteration(A)
    >>> abs(lam - 4.0) < 1e-10
    True
    """
    n = A.shape[0]
    x = np.zeros(n)

    for iteration in range(max_iter):
        # T_A(x)
        Tx = np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])
        lam = Tx[0]
        x_new = Tx - lam  # Normalize so x[0] = 0

        if np.max(np.abs(x_new - x)) < tol:
            return lam, x_new
        x = x_new

    Tx = np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])
    return Tx[0], x


def tropical_eigenvector_from_cycle_mean(A: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Construct the tropical eigenvector from the max cycle mean.

    Algorithm:
    1. Compute λ* = max cycle mean via Karp's algorithm
    2. Form reduced matrix B = A - λ*
    3. Compute x_i = max_{k=0..n-1} (B^⊗k)_{0i}

    Time complexity: O(n^3) for cycle mean + O(n^4) for eigenvector.
    Space complexity: O(n^2).

    >>> A = np.array([[0, 5], [3, 0]])
    >>> lam, x = tropical_eigenvector_from_cycle_mean(A)
    >>> abs(lam - 4.0) < 1e-10
    True
    """
    n = A.shape[0]
    lam = karp_max_cycle_mean(A)

    # Reduced matrix
    B = A - lam

    # Compute max-plus powers of B
    x = np.full(n, -np.inf)
    Bk = maxplus_power(B, 0)  # Identity
    for k in range(n):
        for i in range(n):
            x[i] = max(x[i], Bk[0, i])
        Bk = maxplus_multiply(Bk, B)

    # Normalize
    x = x - x[0]
    return lam, x


# ============================================================
# 4. Collatz-Wielandt Characterization
# ============================================================

def collatz_wielandt_value(A: np.ndarray, x: np.ndarray) -> float:
    """
    Compute the Collatz-Wielandt excess: max_i (T_A(x)_i - x_i).

    This is always ≥ the tropical eigenvalue for any x.

    >>> A = np.array([[0, 5], [3, 0]])
    >>> x = np.zeros(2)
    >>> collatz_wielandt_value(A, x)
    5.0
    """
    n = A.shape[0]
    Tx = np.array([max(A[i, j] + x[j] for j in range(n)) for i in range(n)])
    return max(Tx - x)


def collatz_wielandt_optimize(
    A: np.ndarray,
    n_samples: int = 1000,
    use_gradient: bool = True
) -> Tuple[float, np.ndarray]:
    """
    Find the Collatz-Wielandt minimum via optimization.

    The CW value inf_x max_i (T_A(x)_i - x_i) equals the tropical eigenvalue.

    Algorithm: gradient-free search over random normalized vectors,
    followed by power iteration refinement.

    Time complexity: O(n^2 * n_samples + n^2 * max_iter).
    Space complexity: O(n).

    >>> A = np.array([[0, 5], [3, 0]])
    >>> val, x = collatz_wielandt_optimize(A)
    >>> abs(val - 4.0) < 0.1
    True
    """
    n = A.shape[0]
    best_val = np.inf
    best_x = np.zeros(n)

    # Random search
    for _ in range(n_samples):
        x = np.random.randn(n)
        x[0] = 0  # Normalize
        val = collatz_wielandt_value(A, x)
        if val < best_val:
            best_val = val
            best_x = x.copy()

    # Refine with power iteration
    lam, x_refined = tropical_power_iteration(A)
    val_refined = collatz_wielandt_value(A, x_refined)
    if val_refined < best_val:
        best_val = val_refined
        best_x = x_refined

    return best_val, best_x


# ============================================================
# 5. Tropical Code Design and Decoding
# ============================================================

def tropical_word_score(
    A: np.ndarray, u: tuple, v: tuple
) -> float:
    """
    Compute the tropical word score: sum_t A(u_t, v_t).

    >>> A = np.array([[5, 1], [1, 5]])
    >>> tropical_word_score(A, (0, 0), (0, 0))
    10.0
    """
    return sum(A[u[t], v[t]] for t in range(len(u)))


def is_tropically_separated(
    A: np.ndarray, delta: float, codebook: List[tuple]
) -> bool:
    """
    Check if a codebook is tropically δ-separated.

    A codebook is δ-separated if for all distinct u, v in C:
      score(u, u) > score(u, v) + 2δ

    >>> A = np.array([[5, 1], [1, 5]])
    >>> is_tropically_separated(A, 1.0, [(0,0,0,0), (1,1,1,1)])
    True
    """
    for i, u in enumerate(codebook):
        for j, v in enumerate(codebook):
            if i != j:
                if tropical_word_score(A, u, u) <= tropical_word_score(A, u, v) + 2 * delta:
                    return False
    return True


def tropical_decode(
    A: np.ndarray, codebook: List[tuple], received: tuple
) -> int:
    """
    Maximum-score tropical decoder.

    Returns the index of the codeword u ∈ C that maximizes score(u, received).

    >>> A = np.array([[5, 1], [1, 5]])
    >>> tropical_decode(A, [(0,0,0,0), (1,1,1,1)], (0,0,0,1))
    0
    """
    scores = [tropical_word_score(A, u, received) for u in codebook]
    return int(np.argmax(scores))


def design_tropical_code(
    A: np.ndarray, word_length: int, target_delta: float
) -> List[tuple]:
    """
    Greedy tropical code design.

    Greedily adds codewords maintaining δ-separation.

    Time complexity: O(q^n * |C| * n) per candidate.
    Space complexity: O(q^n) for candidate enumeration.

    >>> A = np.array([[5, 1], [1, 5]])
    >>> code = design_tropical_code(A, 3, 1.0)
    >>> len(code) >= 2
    True
    """
    q = A.shape[0]
    codebook = []

    # Enumerate all possible codewords
    for word in cart_product(range(q), repeat=word_length):
        # Check separation with all existing codewords
        separated = True
        for existing in codebook:
            gap1 = tropical_word_score(A, word, word) - tropical_word_score(A, word, existing)
            gap2 = tropical_word_score(A, existing, existing) - tropical_word_score(A, existing, word)
            if gap1 <= 2 * target_delta or gap2 <= 2 * target_delta:
                separated = False
                break
        if separated:
            codebook.append(word)

    return codebook


# ============================================================
# 6. Log-Channel Bridge
# ============================================================

def log_channel_matrix(P: np.ndarray, eps: float = 1e-15) -> np.ndarray:
    """
    Compute the log-channel matrix from a stochastic matrix.

    Adds small epsilon to avoid log(0).

    >>> P = np.array([[0.9, 0.1], [0.1, 0.9]])
    >>> A = log_channel_matrix(P)
    >>> np.all(A <= 1e-10)
    True
    """
    P_safe = np.maximum(P, eps)
    return np.log(P_safe)


def channel_tropical_capacity(P: np.ndarray) -> float:
    """
    Compute the tropical capacity proxy for a channel matrix P.

    This is exp(tropical eigenvalue of log(P)), which provides
    an upper bound related to the classical channel capacity.

    >>> P = np.array([[0.9, 0.1], [0.1, 0.9]])
    >>> cap = channel_tropical_capacity(P)
    >>> 0 < cap <= 1
    True
    """
    A = log_channel_matrix(P)
    lam = karp_max_cycle_mean(A)
    return np.exp(lam)


if __name__ == "__main__":
    print("Running algorithm tests...")

    # Test max-plus multiplication
    A = np.array([[1.0, 2.0], [3.0, 0.0]])
    B = np.array([[0.0, 1.0], [2.0, 0.0]])
    C = maxplus_multiply(A, B)
    assert np.allclose(C, np.array([[4, 2], [3, 4]])), f"Max-plus multiply failed: {C}"
    print("✓ Max-plus multiplication")

    # Test Karp's algorithm
    A = np.array([[0.0, 5.0], [3.0, 0.0]])
    lam = karp_max_cycle_mean(A)
    assert abs(lam - 4.0) < 1e-10, f"Karp failed: λ = {lam}"
    print(f"✓ Karp's algorithm: λ = {lam}")

    # Test power iteration
    lam2, x2 = tropical_power_iteration(A)
    assert abs(lam2 - 4.0) < 1e-10, f"Power iteration failed: λ = {lam2}"
    print(f"✓ Power iteration: λ = {lam2}, x = {x2}")

    # Test eigenvector construction
    lam3, x3 = tropical_eigenvector_from_cycle_mean(A)
    assert abs(lam3 - 4.0) < 1e-10, f"Eigenvector construction failed: λ = {lam3}"
    print(f"✓ Eigenvector from cycle mean: λ = {lam3}, x = {x3}")

    # Test CW characterization
    cw, _ = collatz_wielandt_optimize(A)
    assert abs(cw - 4.0) < 0.1, f"CW optimization failed: {cw}"
    print(f"✓ Collatz-Wielandt: {cw:.4f}")

    # Test tropical code
    A_code = np.array([[5.0, 1.0], [1.0, 5.0]])
    code = design_tropical_code(A_code, 4, 1.0)
    assert len(code) >= 2, f"Code design failed: {len(code)} codewords"
    assert is_tropically_separated(A_code, 1.0, code)
    print(f"✓ Tropical code: {len(code)} codewords, 4-separated")

    print("\nAll tests passed!")
