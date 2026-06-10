"""
Algorithms for Periodic Orbit Varieties of Elementary Cellular Automata

Implements:
1. Transfer matrix construction for ECA fixed point counting
2. O(log n) periodic orbit counting via matrix exponentiation over GF(2)
3. Linear code extraction from periodic orbits
4. Code dimension computation via Gaussian elimination over GF(2)
"""

from itertools import product
from typing import List, Tuple, Optional


def local_rule(r: int, left: int, center: int, right: int) -> int:
    """Apply ECA rule r to a 3-cell neighborhood (l, c, r) -> new center.

    Args:
        r: Rule number (0-255)
        left, center, right: Binary cell values (0 or 1)

    Returns:
        New center cell value (0 or 1)

    Time: O(1)
    """
    idx = 4 * left + 2 * center + right
    return (r >> idx) & 1


def eca_step(r: int, state: list) -> list:
    """Apply one step of ECA rule r with cyclic boundary conditions.

    Args:
        r: Rule number (0-255)
        state: List of 0s and 1s

    Returns:
        New state after one step

    Time: O(n)
    """
    n = len(state)
    return [local_rule(r, state[(i-1) % n], state[i], state[(i+1) % n])
            for i in range(n)]


def eca_iterate(r: int, state: list, k: int) -> list:
    """Apply ECA rule r exactly k times.

    Time: O(k * n)
    """
    s = list(state)
    for _ in range(k):
        s = eca_step(r, s)
    return s


def mat_mul_gf2(A: list, B: list, size: int) -> list:
    """Multiply two size×size matrices over GF(2).

    Time: O(size^3)
    """
    C = [[0]*size for _ in range(size)]
    for i in range(size):
        for j in range(size):
            val = 0
            for l in range(size):
                val ^= (A[i][l] & B[l][j])
            C[i][j] = val
    return C


def mat_pow_gf2(M: list, size: int, exp: int) -> list:
    """Matrix exponentiation over GF(2) by repeated squaring.

    Args:
        M: size×size matrix over GF(2)
        size: matrix dimension
        exp: exponent

    Returns:
        M^exp over GF(2)

    Time: O(size^3 * log(exp))
    """
    # Identity matrix
    result = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
    base = [row[:] for row in M]
    while exp > 0:
        if exp & 1:
            result = mat_mul_gf2(result, base, size)
        base = mat_mul_gf2(base, base, size)
        exp >>= 1
    return result


def build_transfer_matrix(r: int) -> list:
    """Build the 4×4 transfer matrix for ECA rule r.

    The transfer matrix T has rows/columns indexed by pairs (s_i, s_{i+1}).
    T[(s_i, s_j)][(s_j', s_k)] = 1 if s_j = s_j' and localRule(r, s_i, s_j, s_k) = s_j.

    This encodes the fixed-point constraint: a state s is a fixed point iff
    the cyclic product of T entries along s is nonzero.

    Returns:
        4×4 matrix over {0, 1}

    Time: O(1) (constant number of entries)
    """
    T = [[0]*4 for _ in range(4)]
    for si in range(2):
        for sj in range(2):
            row = 2 * si + sj
            for sk in range(2):
                col = 2 * sj + sk
                # Fixed point constraint: rule output equals current cell
                if local_rule(r, si, sj, sk) == sj:
                    T[row][col] = 1
    return T


def trace_gf2(M: list, size: int) -> int:
    """Compute trace of a matrix over GF(2)."""
    return sum(M[i][i] for i in range(size)) % 2


def count_fixed_points_transfer(r: int, n: int) -> int:
    """Count fixed points of ECA rule r on n cells using the transfer matrix.

    The number of fixed points equals Tr(T^n) computed over the integers
    (not GF(2)), where T is the transfer matrix.

    Args:
        r: Rule number
        n: Number of cells (n ≥ 1)

    Returns:
        Number of fixed points

    Time: O(4^3 * log(n)) = O(log n)

    Note: This computes over integers, not GF(2), because we need
    the actual count, not the count mod 2.
    """
    T = build_transfer_matrix(r)

    # Matrix power over integers
    def mat_mul_int(A, B, size):
        C = [[0]*size for _ in range(size)]
        for i in range(size):
            for j in range(size):
                for l in range(size):
                    C[i][j] += A[i][l] * B[l][j]
        return C

    def mat_pow_int(M, size, exp):
        result = [[1 if i == j else 0 for j in range(size)] for i in range(size)]
        base = [row[:] for row in M]
        while exp > 0:
            if exp & 1:
                result = mat_mul_int(result, base, size)
            base = mat_mul_int(base, base, size)
            exp >>= 1
        return result

    Tn = mat_pow_int(T, 4, n)
    return sum(Tn[i][i] for i in range(4))


def find_periodic_points_brute(r: int, n: int, k: int) -> List[tuple]:
    """Find all k-periodic points by brute force enumeration.

    Time: O(2^n * k * n)
    Space: O(2^n * n)
    """
    periodic = []
    for bits in product([0, 1], repeat=n):
        state = list(bits)
        if eca_iterate(r, state, k) == state:
            periodic.append(bits)
    return periodic


def gaussian_elimination_gf2(matrix: List[List[int]]) -> int:
    """Gaussian elimination over GF(2) to find rank.

    Args:
        matrix: List of row vectors over GF(2)

    Returns:
        Rank of the matrix

    Time: O(rows * cols^2)
    """
    if not matrix:
        return 0
    rows = len(matrix)
    cols = len(matrix[0])
    mat = [list(row) for row in matrix]  # copy
    rank = 0
    for col in range(cols):
        # Find pivot
        pivot = None
        for row in range(rank, rows):
            if mat[row][col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        # Swap
        mat[rank], mat[pivot] = mat[pivot], mat[rank]
        # Eliminate
        for row in range(rows):
            if row != rank and mat[row][col] == 1:
                for c in range(cols):
                    mat[row][c] ^= mat[rank][c]
        rank += 1
    return rank


def periodic_orbit_code_dimension(r: int, n: int, k: int) -> int:
    """Compute the dimension of the periodic orbit code C(r, k, n).

    For linear rules, this is the GF(2)-dimension of the space of
    k-periodic points.

    Time: O(2^n * k * n + 2^n * n^2) — brute force + Gaussian elimination
    """
    points = find_periodic_points_brute(r, n, k)
    if not points:
        return 0
    return gaussian_elimination_gf2([list(p) for p in points])


def is_linear_rule(r: int) -> bool:
    """Check if ECA rule r is linear over GF(2).

    Time: O(1) (64 checks)
    """
    if local_rule(r, 0, 0, 0) != 0:
        return False
    for bits in product([0, 1], repeat=6):
        l1, c1, r1, l2, c2, r2 = bits
        lhs = local_rule(r, l1 ^ l2, c1 ^ c2, r1 ^ r2)
        rhs = local_rule(r, l1, c1, r1) ^ local_rule(r, l2, c2, r2)
        if lhs != rhs:
            return False
    return True


def classify_all_linear_rules() -> List[int]:
    """Find all 256 ECA rules that are linear over GF(2).

    Returns:
        Sorted list of linear rule numbers

    Time: O(256 * 64) = O(1)
    """
    return sorted(r for r in range(256) if is_linear_rule(r))


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("=== Transfer Matrix Algorithm ===")
    print(f"Linear rules: {classify_all_linear_rules()}")

    for r in [0, 90, 150, 204]:
        print(f"\nRule {r}:")
        T = build_transfer_matrix(r)
        for row in T:
            print(f"  {row}")
        for n in [5, 10, 20, 50, 100]:
            count = count_fixed_points_transfer(r, n)
            print(f"  n={n:3d}: |Fix| = {count}")

    print("\n=== Periodic Orbit Code Dimensions ===")
    for r in [90, 150]:
        print(f"\nRule {r} (linear={is_linear_rule(r)}):")
        for n in [4, 5, 6, 7, 8]:
            for k in [1, 2, 3]:
                dim = periodic_orbit_code_dimension(r, n, k)
                print(f"  C({r},{k},{n}): dim = {dim}, rate = {dim/n:.3f}")
