"""
Krawtchouk Polynomials and Quantum Weight Enumerator Algorithms

Implements the core mathematical algorithms for quantum coding theory:
1. Krawtchouk polynomial evaluation (three methods: direct, recurrence, matrix)
2. Quantum MacWilliams transform
3. Weight enumerator computation for stabilizer codes
4. Tropical weight profile computation

Time complexity: O(n²) for full Krawtchouk matrix, O(n) per polynomial evaluation.
Space complexity: O(n²) for the matrix, O(n) for a single enumerator.
"""

import numpy as np
from math import comb, log, factorial
from typing import List, Tuple, Optional, Dict


def krawtchouk(n: int, j: int, x: int) -> int:
    """
    Compute the Krawtchouk polynomial K_j(x; n) for binary codes.

    K_j(x; n) = Σ_{l=0}^{j} (-1)^l · C(x, l) · C(n-x, j-l)

    This is the character table entry of the Hamming association scheme H(n, 2).

    Parameters:
        n: Code length
        j: Polynomial index (0 ≤ j ≤ n)
        x: Evaluation point (0 ≤ x ≤ n)

    Returns:
        Integer value K_j(x; n)

    Time complexity: O(j)
    Space complexity: O(1)

    >>> krawtchouk(5, 0, 3)
    1
    >>> krawtchouk(5, 1, 2)
    1
    >>> krawtchouk(5, 2, 1)
    2
    """
    result = 0
    for l in range(j + 1):
        result += ((-1) ** l) * comb(x, l) * comb(n - x, j - l)
    return result


def krawtchouk_recurrence(n: int, j: int, x: int) -> int:
    """
    Compute K_j(x; n) using the three-term recurrence relation.

    (j+1) · K_{j+1}(x) = (n - 2x) · K_j(x) - (n - j + 1) · K_{j-1}(x)

    More numerically stable for large j.

    Time complexity: O(j)
    Space complexity: O(1)
    """
    if j == 0:
        return 1
    K_prev = 1  # K_0 = 1
    K_curr = n - 2 * x  # K_1 = n - 2x
    if j == 1:
        return K_curr
    for i in range(1, j):
        K_next = ((n - 2 * x) * K_curr - (n - i) * K_prev) // (i + 1)
        K_prev = K_curr
        K_curr = K_next
    return K_curr


def krawtchouk_matrix(n: int) -> np.ndarray:
    """
    Compute the full (n+1) × (n+1) Krawtchouk matrix K where K[j, i] = K_j(i; n).

    This is the character table of the Hamming association scheme H(n, 2).
    It satisfies K · K^T = 2^n · diag(C(n,0), C(n,1), ..., C(n,n)).

    Time complexity: O(n²)
    Space complexity: O(n²)
    """
    K = np.zeros((n + 1, n + 1), dtype=float)
    for j in range(n + 1):
        for i in range(n + 1):
            K[j, i] = krawtchouk(n, j, i)
    return K


def macwilliams_transform(n: int, k: int, A: np.ndarray) -> np.ndarray:
    """
    Apply the quantum MacWilliams transform to compute B from A.

    B_j = (1/2^(n-k)) · Σ_i A_i · K_j(i; n)

    This is the fundamental duality transform for quantum weight enumerators.

    Parameters:
        n: Code length
        k: Number of logical qubits
        A: A-enumerator array of length n+1

    Returns:
        B-enumerator array of length n+1

    Time complexity: O(n²)
    """
    K = krawtchouk_matrix(n)
    B = K @ A / (2 ** (n - k))
    return B


def inverse_macwilliams(n: int, k: int, B: np.ndarray) -> np.ndarray:
    """
    Compute A from B by inverting the MacWilliams transform.

    A_i = (1/2^(n+k)) · Σ_j B_j · K_i(j; n)

    Time complexity: O(n²)
    """
    K = krawtchouk_matrix(n)
    A = K @ B / (2 ** (n + k))
    return A


def verify_macwilliams(n: int, k: int, A: np.ndarray, B: np.ndarray,
                       tol: float = 1e-10) -> bool:
    """
    Verify that (A, B) satisfies the quantum MacWilliams identity.

    Returns True if B_j ≈ (1/2^(n-k)) · Σ_i A_i · K_j(i; n) for all j.
    """
    B_computed = macwilliams_transform(n, k, A)
    return np.allclose(B, B_computed, atol=tol)


def hamming_bound_sum(n: int, t: int) -> int:
    """
    Compute the Hamming packing sum: Σ_{j=0}^{t} 3^j · C(n, j).

    This counts the number of n-qubit Pauli errors of weight ≤ t.
    """
    return sum(3**j * comb(n, j) for j in range(t + 1))


def singleton_bound(n: int, d: int) -> int:
    """
    Maximum k for an [[n, k, d]] code satisfying the quantum Singleton bound.

    2d + k ≤ n + 2, so k ≤ n - 2d + 2.
    """
    return max(0, n - 2 * d + 2)


def bravyi_terhal_bound_2d(n: int, d: int, c: float = 1.0) -> float:
    """
    Maximum k for a 2D local code under the Bravyi-Terhal bound.

    k · d² ≤ c · n, so k ≤ c · n / d².
    """
    if d == 0:
        return float('inf')
    return c * n / (d ** 2)


def tropical_weight_profile(A: np.ndarray) -> np.ndarray:
    """
    Compute the tropical weight profile: -log(A_j) for positive entries.

    Returns an array where entries with A_j ≤ 0 are set to infinity.
    """
    result = np.full_like(A, np.inf)
    positive = A > 0
    result[positive] = -np.log(A[positive])
    return result


def tropical_eval(weights: np.ndarray, z: float) -> float:
    """
    Evaluate the tropical polynomial: min_j(w_j + j · z).
    """
    n = len(weights) - 1
    values = [weights[j] + j * z for j in range(n + 1)]
    return min(values)


# Known quantum codes
KNOWN_CODES: Dict[str, dict] = {
    "[[5,1,3]]": {
        "n": 5, "k": 1, "d": 3,
        "name": "Perfect 5-qubit code",
        "A": np.array([1, 0, 0, 0, 0, 15]),  # Stabilizer: I + 15 weight-5
        "description": "The smallest perfect quantum code, discovered by "
                       "Laflamme, Miquel, Paz, and Zurek (1996)."
    },
    "[[7,1,3]]": {
        "n": 7, "k": 1, "d": 3,
        "name": "Steane code",
        "A": np.array([1, 0, 0, 0, 7, 0, 0, 56]),
        "description": "CSS code based on the classical [7,4,3] Hamming code."
    },
    "[[9,1,3]]": {
        "n": 9, "k": 1, "d": 3,
        "name": "Shor code",
        "A": np.array([1, 0, 0, 0, 0, 0, 30, 0, 0, 225]),
        "description": "The first quantum error-correcting code, based on "
                       "repetition encoding (Shor, 1995)."
    },
}


if __name__ == "__main__":
    print("=== Krawtchouk Polynomial Tests ===")
    # Verify known values
    tests = [
        (5, 0, 3, 1), (5, 1, 2, 1), (5, 2, 1, 2),
        (5, 2, 2, -2), (7, 3, 1, 5), (5, 1, 0, 5),
    ]
    for n, j, x, expected in tests:
        val = krawtchouk(n, j, x)
        status = "✓" if val == expected else "✗"
        print(f"  {status} K_{j}({x}; {n}) = {val} (expected {expected})")

    # Verify recurrence matches direct computation
    print("\n=== Recurrence Verification ===")
    for n in [5, 7, 10]:
        for j in range(n + 1):
            for x in range(n + 1):
                v1 = krawtchouk(n, j, x)
                v2 = krawtchouk_recurrence(n, j, x)
                if v1 != v2:
                    print(f"  ✗ Mismatch at K_{j}({x}; {n}): {v1} vs {v2}")
                    break
        else:
            print(f"  ✓ All values match for n = {n}")

    # Verify Krawtchouk matrix orthogonality
    print("\n=== Krawtchouk Matrix Orthogonality ===")
    for n in [5, 7]:
        K = krawtchouk_matrix(n)
        diag = np.array([2**n * comb(n, j) for j in range(n + 1)])
        product = K @ K.T
        expected = np.diag(diag)
        if np.allclose(product, expected):
            print(f"  ✓ K · K^T = 2^{n} · diag(C({n},j)) for n = {n}")
        else:
            print(f"  ✗ Orthogonality fails for n = {n}")

    # MacWilliams transform for known codes
    print("\n=== MacWilliams Transform Verification ===")
    for code_name, code in KNOWN_CODES.items():
        n, k = code["n"], code["k"]
        A = code["A"].astype(float)
        B = macwilliams_transform(n, k, A)
        print(f"  {code_name} ({code['name']}):")
        print(f"    A = {A}")
        print(f"    B = {B}")
        print(f"    B[0] = {B[0]:.1f} (expected 2^{k} = {2**k})")
        if abs(B[0] - 2**k) < 1e-10:
            print(f"    ✓ B₀ = 2^k verified")
        else:
            print(f"    ✗ B₀ ≠ 2^k")
