"""
Numerical demonstrations for:

    Symmetrized Monomial Identities of the Arrow Ideal of an Acyclic Quiver

This self-contained script illustrates, with concrete integer matrices and
small acyclic quivers, the three pillars of the paper:

  1. GEOMETRIC BOUND  (r_add_length_le, length_lt_of_bounded):
     a strictly monotone potential bounds path length; an acyclic quiver on
     n vertices has no path of length >= n.

  2. NILPOTENCY VIA SHIFT  (Shift.mul, Shift.eq_zero_of_top,
     prod_ofFn_strictUpper_eq_zero):
     the shift of a product is the sum of the shifts; the product of n
     strictly upper triangular n x n matrices is the zero matrix.

  3. POLYNOMIAL IDENTITIES  (PI.symMono_strictUpper_eq_zero,
     PI.stdPoly_strictUpper_eq_zero):
     the degree-n symmetrized monomial S and the standard polynomial S_n
     both vanish identically on strictly upper triangular n x n matrices.

All matrix arithmetic is implemented from scratch over the integers; no
external libraries are required.
"""

from __future__ import annotations

from itertools import permutations
from typing import Dict, List, Tuple

Matrix = List[List[int]]


# --------------------------------------------------------------------------
# Minimal integer matrix algebra
# --------------------------------------------------------------------------
def zeros(n: int) -> Matrix:
    """Return the n x n zero matrix."""
    return [[0 for _ in range(n)] for _ in range(n)]


def identity(n: int) -> Matrix:
    """Return the n x n identity matrix."""
    return [[1 if i == j else 0 for j in range(n)] for i in range(n)]


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Multiply two n x n matrices over the integers."""
    n = len(a)
    out = zeros(n)
    for i in range(n):
        for k in range(n):
            aik = a[i][k]
            if aik == 0:
                continue
            for j in range(n):
                out[i][j] += aik * b[k][j]
    return out


def matprod(mats: List[Matrix]) -> Matrix:
    """Ordered product of a list of matrices (left to right)."""
    if not mats:
        raise ValueError("empty product undefined here; supply at least one matrix")
    acc = mats[0]
    for m in mats[1:]:
        acc = matmul(acc, m)
    return acc


def is_zero(a: Matrix) -> bool:
    """Test whether every entry of a is 0."""
    return all(v == 0 for row in a for v in row)


def scale(c: int, a: Matrix) -> Matrix:
    """Scalar multiple c * a."""
    return [[c * v for v in row] for row in a]


def add(a: Matrix, b: Matrix) -> Matrix:
    """Entrywise sum a + b."""
    n = len(a)
    return [[a[i][j] + b[i][j] for j in range(n)] for i in range(n)]


# --------------------------------------------------------------------------
# Shift filtration
# --------------------------------------------------------------------------
def has_shift(a: Matrix, k: int) -> bool:
    """
    Test the predicate Shift k a : every entry strictly below the k-th
    superdiagonal vanishes, i.e. a[i][j] = 0 whenever j < i + k.
    """
    n = len(a)
    for i in range(n):
        for j in range(n):
            if j < i + k and a[i][j] != 0:
                return False
    return True


def shift_of(a: Matrix) -> int:
    """
    The largest k for which Shift k a holds. For the zero matrix this is n
    (it satisfies Shift n, the top filtration level). For a nonzero matrix
    it equals min{ j - i : a[i][j] != 0 }.
    """
    n = len(a)
    best = n  # zero matrix attains the top shift n
    for i in range(n):
        for j in range(n):
            if a[i][j] != 0:
                best = min(best, j - i)
    return best


def is_strict_upper(a: Matrix) -> bool:
    """StrictUpper a == Shift 1 a : zero on and below the main diagonal."""
    return has_shift(a, 1)


# --------------------------------------------------------------------------
# Quiver / longest-path machinery
# --------------------------------------------------------------------------
def topological_potential(n: int, edges: List[Tuple[int, int]]) -> Dict[int, int]:
    """
    Compute a potential r : V -> N strictly increasing along every arrow,
    for an acyclic quiver on vertices 0..n-1 with the given directed edges.
    r(v) = longest path length ending at v (a valid topological potential
    bounded by n). Raises ValueError if a cycle is detected.
    """
    succ: Dict[int, List[int]] = {v: [] for v in range(n)}
    indeg = [0] * n
    for a, b in edges:
        succ[a].append(b)
        indeg[b] += 1

    # Kahn's algorithm, accumulating the longest path length to each vertex.
    queue = [v for v in range(n) if indeg[v] == 0]
    r = {v: 0 for v in range(n)}
    visited = 0
    while queue:
        u = queue.pop()
        visited += 1
        for w in succ[u]:
            if r[u] + 1 > r[w]:
                r[w] = r[u] + 1
            indeg[w] -= 1
            if indeg[w] == 0:
                queue.append(w)
    if visited != n:
        raise ValueError("quiver is not acyclic")
    return r


def longest_path_length(n: int, edges: List[Tuple[int, int]]) -> int:
    """The longest directed path length in an acyclic quiver on n vertices."""
    r = topological_potential(n, edges)
    return max(r.values()) if r else 0


# --------------------------------------------------------------------------
# Multilinear polynomials: symmetrized monomial and standard polynomial
# --------------------------------------------------------------------------
def perm_sign(perm: Tuple[int, ...]) -> int:
    """Sign (+/-1) of a permutation given as a tuple of images."""
    n = len(perm)
    sign = 1
    seen = [False] * n
    for i in range(n):
        if seen[i]:
            continue
        # trace the cycle through i
        length = 0
        j = i
        while not seen[j]:
            seen[j] = True
            j = perm[j]
            length += 1
        if length % 2 == 0:
            sign = -sign
    return sign


def symmetrized_monomial(mats: List[Matrix]) -> Matrix:
    """
    S(a_1, ..., a_n) = sum over all permutations sigma of
    a_{sigma(1)} a_{sigma(2)} ... a_{sigma(n)}.
    """
    n = len(mats)
    total = zeros(n)
    for sigma in permutations(range(n)):
        total = add(total, matprod([mats[sigma[i]] for i in range(n)]))
    return total


def standard_polynomial(mats: List[Matrix]) -> Matrix:
    """
    S_n(a_1, ..., a_n) = sum over permutations sigma of
    sgn(sigma) * a_{sigma(1)} ... a_{sigma(n)}.
    """
    n = len(mats)
    total = zeros(n)
    for sigma in permutations(range(n)):
        term = matprod([mats[sigma[i]] for i in range(n)])
        total = add(total, scale(perm_sign(sigma), term))
    return total


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_geometric_bound() -> None:
    print("=" * 70)
    print("DEMO 1 -- Geometric bound: acyclicity forbids long paths")
    print("=" * 70)
    # Linear quiver A_5 : 0 -> 1 -> 2 -> 3 -> 4   (sharp case)
    n = 5
    edges = [(i, i + 1) for i in range(n - 1)]
    r = topological_potential(n, edges)
    L = longest_path_length(n, edges)
    print(f"Linear quiver A_{n} with edges {edges}")
    print(f"  potential r            = {r}")
    print(f"  all r(v) < n ?         = {all(val < n for val in r.values())}")
    print(f"  longest path length    = {L}   (theory: at most n-1 = {n-1})")
    assert L == n - 1
    assert all(val < n for val in r.values())

    # A bushier acyclic quiver on 6 vertices.
    n2 = 6
    edges2 = [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (2, 5), (5, 4)]
    r2 = topological_potential(n2, edges2)
    L2 = longest_path_length(n2, edges2)
    print(f"\nAcyclic quiver on {n2} vertices, edges {edges2}")
    print(f"  potential r            = {r2}")
    print(f"  longest path length    = {L2}   (<= n-1 = {n2-1})")
    assert L2 < n2
    print("  OK: longest path length < number of vertices.\n")


def demo_shift_additivity() -> None:
    print("=" * 70)
    print("DEMO 2 -- Shift is additive; shift n forces the zero matrix")
    print("=" * 70)
    n = 4
    # A shift-1 (strictly upper) and a shift-2 matrix.
    M = [[0, 2, 5, 1],
         [0, 0, 3, 4],
         [0, 0, 0, 7],
         [0, 0, 0, 0]]
    N = [[0, 0, 6, 2],
         [0, 0, 0, 9],
         [0, 0, 0, 0],
         [0, 0, 0, 0]]
    print(f"shift(M) = {shift_of(M)}   (M strictly upper, shift 1)")
    print(f"shift(N) = {shift_of(N)}   (shift 2)")
    P = matmul(M, N)
    print(f"shift(M*N) = {shift_of(P)}   (theory: shift(M)+shift(N) = {shift_of(M)+shift_of(N)})")
    assert shift_of(P) >= shift_of(M) + shift_of(N)
    print("  OK: Shift.mul -- shift of product >= sum of shifts.\n")


def demo_nilpotency() -> None:
    print("=" * 70)
    print("DEMO 3 -- Product of n strictly upper triangular n x n matrices = 0")
    print("=" * 70)
    for n in range(2, 6):
        # n distinct strictly upper triangular matrices with random-ish entries
        mats: List[Matrix] = []
        for t in range(n):
            a = zeros(n)
            for i in range(n):
                for j in range(i + 1, n):
                    a[i][j] = (i + 2 * j + 3 * t + 1) % 7  # deterministic, varied
            assert is_strict_upper(a)
            mats.append(a)
        prod = matprod(mats)
        print(f"  n = {n}: product of {n} strictly upper matrices is zero ? {is_zero(prod)}")
        assert is_zero(prod)
        # one fewer factor need NOT be zero (degree sharpness witness)
        if n >= 2:
            chain = [zeros(n) for _ in range(n - 1)]
            for t in range(n - 1):
                chain[t][t][t + 1] = 1  # E_{t,t+1}
            short = matprod(chain)
            print(f"         chain E_01 E_12 ... of length {n-1} is nonzero ? {not is_zero(short)}"
                  f"   (equals E_0,{n-1})")
            assert not is_zero(short)
    print("  OK: nilpotency of index n, and degree-(n-1) nonvanishing witness.\n")


def demo_identities() -> None:
    print("=" * 70)
    print("DEMO 4 -- Symmetrized monomial S and standard polynomial S_n vanish")
    print("=" * 70)
    for n in range(2, 5):
        mats: List[Matrix] = []
        for t in range(n):
            a = zeros(n)
            for i in range(n):
                for j in range(i + 1, n):
                    a[i][j] = (3 * i + j + 5 * t + 2) % 11
            mats.append(a)
        S = symmetrized_monomial(mats)
        Sn = standard_polynomial(mats)
        print(f"  n = {n}:  S (unsigned, {factorial(n)} terms) is zero ? {is_zero(S)}")
        print(f"          S_n (signed) is zero ? {is_zero(Sn)}")
        assert is_zero(S) and is_zero(Sn)
    print("\n  Contrast: on the FULL matrix algebra the unsigned S does NOT vanish.")
    # full (not strictly upper) 2x2 matrices: S(a,b) = ab + ba is generally != 0
    a = [[1, 0], [0, 0]]
    b = [[0, 1], [0, 0]]
    full_S = symmetrized_monomial([a, b])
    print(f"  Full M_2 example: S(a,b) = ab + ba = {full_S}  (nonzero -> signs matter there)")
    assert not is_zero(full_S)
    print("  OK: identities hold on strictly upper, fail (unsigned) on full M_n.\n")


def factorial(n: int) -> int:
    """n! for display purposes."""
    out = 1
    for k in range(2, n + 1):
        out *= k
    return out


def main() -> None:
    demo_geometric_bound()
    demo_shift_additivity()
    demo_nilpotency()
    demo_identities()
    print("All demonstrations passed.")


if __name__ == "__main__":
    main()
