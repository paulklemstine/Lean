#!/usr/bin/env python3
"""
Algorithms derived from the Kernel Density Theorem.

Implements computational tools for finite-field linear algebra
including kernel computation, density estimation, and code analysis.
"""

from itertools import product as cartesian_product
from typing import List, Tuple, Set
import math


def gf_add(a: int, b: int, q: int) -> int:
    """Add two elements in GF(q)."""
    return (a + b) % q


def gf_mul(a: int, b: int, q: int) -> int:
    """Multiply two elements in GF(q)."""
    return (a * b) % q


def gf_inv(a: int, q: int) -> int:
    """Multiplicative inverse in GF(q) using Fermat's little theorem."""
    if a % q == 0:
        raise ValueError(f"{a} has no inverse mod {q}")
    return pow(a, q - 2, q)


def mat_vec_mul(matrix: List[List[int]], vec: List[int], q: int) -> List[int]:
    """Matrix-vector multiplication over GF(q).

    Args:
        matrix: m × n matrix as list of rows
        vec: n-dimensional vector
        q: field characteristic (prime)

    Returns:
        m-dimensional result vector

    Time complexity: O(m * n)
    Space complexity: O(m)
    """
    m = len(matrix)
    result = [0] * m
    for i in range(m):
        s = sum(matrix[i][j] * vec[j] for j in range(len(vec)))
        result[i] = s % q
    return result


def compute_kernel_brute(matrix: List[List[int]], q: int, n: int) -> List[List[int]]:
    """Compute kernel by enumeration (brute force).

    Args:
        matrix: m × n matrix over GF(q)
        q: field characteristic
        n: domain dimension

    Returns:
        List of all kernel vectors

    Time complexity: O(q^n * m * n)
    Space complexity: O(q^n * n)

    Note: Only practical for small q^n. The kernel density theorem
    guarantees |ker| ≤ q^n / q = q^(n-1) when the map is nonzero.
    """
    zero = [0] * len(matrix)
    kernel = []
    for v in cartesian_product(range(q), repeat=n):
        if mat_vec_mul(matrix, list(v), q) == zero:
            kernel.append(list(v))
    return kernel


def gaussian_elimination_gf(matrix: List[List[int]], q: int) -> Tuple[List[List[int]], int]:
    """Row echelon form over GF(q).

    Args:
        matrix: m × n matrix over GF(q)
        q: prime field characteristic

    Returns:
        (row_echelon_form, rank)

    Time complexity: O(m * n * min(m,n))
    Space complexity: O(m * n)
    """
    mat = [row[:] for row in matrix]
    m = len(mat)
    if m == 0:
        return mat, 0
    n = len(mat[0])
    rank = 0
    pivot_cols = []

    for col in range(n):
        # Find pivot
        pivot_row = None
        for row in range(rank, m):
            if mat[row][col] % q != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        # Swap
        mat[rank], mat[pivot_row] = mat[pivot_row], mat[rank]

        # Scale pivot row
        inv = gf_inv(mat[rank][col], q)
        mat[rank] = [(x * inv) % q for x in mat[rank]]

        # Eliminate
        for row in range(m):
            if row != rank and mat[row][col] % q != 0:
                factor = mat[row][col]
                mat[row] = [(mat[row][j] - factor * mat[rank][j]) % q for j in range(n)]

        pivot_cols.append(col)
        rank += 1

    return mat, rank


def compute_kernel_gaussian(matrix: List[List[int]], q: int) -> List[List[int]]:
    """Compute a basis for the kernel using Gaussian elimination.

    More efficient than brute force for large spaces.

    Args:
        matrix: m × n matrix over GF(q)
        q: prime field characteristic

    Returns:
        List of basis vectors for ker(matrix)

    Time complexity: O(m * n^2 + (n - rank) * n)
    Space complexity: O(n^2)

    The kernel density theorem predicts |ker| = q^(n - rank).
    """
    m = len(matrix)
    n = len(matrix[0]) if m > 0 else 0
    rref, rank = gaussian_elimination_gf(matrix, q)

    # Identify pivot and free columns
    pivot_cols = []
    for i in range(rank):
        for j in range(n):
            if rref[i][j] == 1:
                is_pivot = all(rref[k][j] == 0 for k in range(rank) if k != i)
                if is_pivot:
                    pivot_cols.append(j)
                    break

    free_cols = [j for j in range(n) if j not in pivot_cols]

    # Build kernel basis
    basis = []
    for fc in free_cols:
        vec = [0] * n
        vec[fc] = 1
        for i, pc in enumerate(pivot_cols):
            vec[pc] = (-rref[i][fc]) % q
        basis.append(vec)

    return basis


def kernel_size_from_rank(q: int, n: int, rank: int) -> int:
    """Compute |ker(f)| = q^(n - rank) using the product formula.

    This is a direct application of card_kernel_mul_card_range:
        |ker(f)| * |range(f)| = |V|
        |ker(f)| * q^rank = q^n
        |ker(f)| = q^(n - rank)

    Args:
        q: field size
        n: domain dimension
        rank: rank of the linear map

    Returns:
        Cardinality of the kernel
    """
    return q ** (n - rank)


def kernel_density(q: int, rank: int) -> float:
    """Compute the kernel density |ker(f)| / |V| = 1/q^rank.

    By the kernel density theorem, for a nonzero map this is at most 1/q.
    Equality holds when rank = 1 (e.g., linear functionals).

    Args:
        q: field size
        rank: rank of the linear map

    Returns:
        Fraction of domain in the kernel
    """
    return 1.0 / (q ** rank)


def linear_code_parameters(q: int, n: int, parity_check: List[List[int]]) -> dict:
    """Analyze a linear code defined by its parity-check matrix.

    A linear [n, k, d]_q code is the kernel of a parity-check matrix H.
    By card_kernel_mul_card_range:
        |code| = q^k where k = n - rank(H)

    Args:
        q: field size
        n: code length
        parity_check: r × n parity-check matrix over GF(q)

    Returns:
        Dictionary with code parameters
    """
    _, rank = gaussian_elimination_gf(parity_check, q)
    k = n - rank
    code_size = q ** k
    ambient_size = q ** n
    rate = k / n
    density = code_size / ambient_size

    return {
        "q": q,
        "n": n,
        "k": k,
        "rank_H": rank,
        "code_size": code_size,
        "ambient_size": ambient_size,
        "rate": rate,
        "density": density,
        "density_bound": f"1/q^{rank} = 1/{q**rank}",
    }


def universal_hash_collision_probability(q: int, n: int) -> float:
    """Collision probability for a random linear hash over GF(q)^n.

    For a uniformly random nonzero linear functional φ: GF(q)^n → GF(q),
    and any fixed nonzero x ∈ GF(q)^n, the probability that φ(x) = 0
    is exactly 1/q. This follows from the kernel density theorem applied
    to φ, noting that the density 1/q is achieved with equality for
    any nonzero linear functional.

    Args:
        q: field size
        n: domain dimension

    Returns:
        Collision probability 1/q
    """
    return 1.0 / q


if __name__ == "__main__":
    print("=== Algorithm Examples ===\n")

    # Example 1: Kernel computation
    H = [[1, 0, 1, 1], [0, 1, 1, 0]]
    q = 2
    print("Parity-check matrix H over GF(2):")
    for row in H:
        print(f"  {row}")

    basis = compute_kernel_gaussian(H, q)
    print(f"\nKernel basis:")
    for v in basis:
        print(f"  {v}")

    _, rank = gaussian_elimination_gf(H, q)
    print(f"\nRank = {rank}, Kernel dimension = {len(H[0]) - rank}")
    print(f"Predicted |ker| = {kernel_size_from_rank(q, len(H[0]), rank)}")
    print(f"Kernel density = {kernel_density(q, rank):.4f}")

    # Example 2: Code analysis
    print("\n--- Linear Code Analysis ---")
    params = linear_code_parameters(2, 7, [
        [1, 0, 0, 1, 1, 0, 1],
        [0, 1, 0, 1, 0, 1, 1],
        [0, 0, 1, 0, 1, 1, 1],
    ])
    print(f"Hamming [7,4] code parameters: {params}")
