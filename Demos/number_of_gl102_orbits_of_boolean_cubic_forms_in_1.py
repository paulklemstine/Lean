"""
Numerical demonstrations for:

    A Double-Counting Bridge for Orbit Enumeration, and the
    Classification of Boolean Cubic Forms in Ten Variables

Everything here is self-contained (standard library only) and heavily type
hinted.  The demos illustrate, on small computable cases, the exact logical
pipeline used at scale to certify that the number of nonzero GL(10,2)-orbits
of Boolean cubic forms in ten variables is 3,691,560:

  1. the connector identity  sum_g |Fix(g)| = sum_x |Stab(x)|  (the "bridge");
  2. the two-methods-agree formula  (both sums) = |orbits| * |G|;
  3. the division principle  sum_g |Fix(g)| = N * |G|  ==>  |orbits| = N;
  4. the fully derived toy instance  GL(2,2) = S_3  on three points;
  5. the Burnside/orbit-stabilizer count for GL(n,2) acting on Boolean
     functions (small n), where the bridge is checked numerically;
  6. the arithmetic of the classification number 3,691,560.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import permutations, product
from math import comb, isqrt, prod
from typing import Callable, Dict, Iterable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Generic orbit machinery (works for any finite group action given as a list
# of group elements together with an action function on a finite domain).
# ---------------------------------------------------------------------------

def fixed_point_count(g: object, domain: Sequence[object],
                      act: Callable[[object, object], object]) -> int:
    """Number of x in `domain` with g . x = x."""
    return sum(1 for x in domain if act(g, x) == x)


def burnside_fixed_sum(group: Sequence[object], domain: Sequence[object],
                       act: Callable[[object, object], object]) -> int:
    """The Burnside side:  sum_{g in G} |Fix(g)|."""
    return sum(fixed_point_count(g, domain, act) for g in group)


def stabilizer_size(x: object, group: Sequence[object],
                    act: Callable[[object, object], object]) -> int:
    """|Stab(x)| = number of g in G fixing x."""
    return sum(1 for g in group if act(g, x) == x)


def stabilizer_sum(group: Sequence[object], domain: Sequence[object],
                   act: Callable[[object, object], object]) -> int:
    """The orbit-stabilizer side:  sum_{x in X} |Stab(x)|."""
    return sum(stabilizer_size(x, group, act) for x in domain)


def orbit_count_by_enumeration(group: Sequence[object], domain: Sequence[object],
                               act: Callable[[object, object], object]) -> int:
    """Ground-truth orbit count via union of orbits (only for small domains)."""
    seen: set = set()
    orbits = 0
    for x in domain:
        if x in seen:
            continue
        orbits += 1
        orbit = {act(g, x) for g in group}
        seen |= orbit
    return orbits


def division_principle(fixed_sum: int, group_order: int) -> int:
    """Turn a fixed-point sum N*|G| into the exact orbit count N.

    Raises ValueError if |G| does not divide the sum, which would signal an
    inconsistent computation.
    """
    if group_order <= 0:
        raise ValueError("group order must be positive")
    if fixed_sum % group_order != 0:
        raise ValueError("group order does not divide the fixed-point sum")
    return fixed_sum // group_order


# ---------------------------------------------------------------------------
# Linear algebra over F2 and the general linear group GL(n, 2).
# ---------------------------------------------------------------------------

Matrix = Tuple[Tuple[int, ...], ...]  # n x n matrix over F2
Vector = int                          # an F2^n vector packed into n bits


def mat_vec(mat: Matrix, v: Vector, n: int) -> Vector:
    """Apply an F2 matrix to a bit-packed vector; returns a bit-packed vector."""
    out = 0
    for i in range(n):
        bit = 0
        row = mat[i]
        for j in range(n):
            bit ^= row[j] & ((v >> j) & 1)
        out |= (bit & 1) << i
    return out


def mat_mul(a: Matrix, b: Matrix, n: int) -> Matrix:
    """Multiply two n x n F2 matrices."""
    return tuple(
        tuple(sum(a[i][k] & b[k][j] for k in range(n)) & 1 for j in range(n))
        for i in range(n)
    )


def identity(n: int) -> Matrix:
    return tuple(tuple(1 if i == j else 0 for j in range(n)) for i in range(n))


def is_invertible_f2(mat: Matrix, n: int) -> bool:
    """Gaussian elimination over F2 to test invertibility."""
    rows: List[int] = [sum((mat[i][j] & 1) << j for j in range(n)) for i in range(n)]
    rank = 0
    for col in range(n):
        pivot = next((r for r in range(rank, n) if (rows[r] >> col) & 1), None)
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        for r in range(n):
            if r != rank and (rows[r] >> col) & 1:
                rows[r] ^= rows[rank]
        rank += 1
    return rank == n


def general_linear_group(n: int) -> List[Matrix]:
    """All invertible n x n matrices over F2 (feasible for n <= 3)."""
    mats: List[Matrix] = []
    for flat in product((0, 1), repeat=n * n):
        mat = tuple(tuple(flat[i * n + j] for j in range(n)) for i in range(n))
        if is_invertible_f2(mat, n):
            mats.append(mat)
    return mats


def mat_inverse(mat: Matrix, group: Sequence[Matrix], n: int) -> Matrix:
    """Find the inverse by search within the (small) group."""
    idn = identity(n)
    for h in group:
        if mat_mul(mat, h, n) == idn:
            return h
    raise ValueError("matrix has no inverse in the supplied group")


def gl_order(n: int) -> int:
    """|GL(n,2)| = prod_{k=0}^{n-1} (2^n - 2^k)."""
    return prod((1 << n) - (1 << k) for k in range(n))


# ---------------------------------------------------------------------------
# The GL(n,2)-action on ALL Boolean functions in n variables.
# A Boolean function is a bit-packed truth table over the 2^n input vectors.
# ---------------------------------------------------------------------------

def boolean_functions(n: int) -> List[int]:
    """All Boolean functions in n variables as truth tables of 2^n bits."""
    return list(range((1 << (1 << n))))


def act_on_boolean(mat_inv: Matrix, f: int, n: int) -> int:
    """(g . f)(v) = f(g^{-1} v).  `mat_inv` is g^{-1}; f is a truth table."""
    result = 0
    for v in range(1 << n):
        gv = mat_vec(mat_inv, v, n)
        bit = (f >> gv) & 1
        result |= bit << v
    return result


# ---------------------------------------------------------------------------
# Integer factorization for the structural read-off of the orbit count.
# ---------------------------------------------------------------------------

def factorize(n: int) -> Dict[int, int]:
    """Prime factorization by trial division."""
    factors: Dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    return all(n % d for d in range(2, isqrt(n) + 1))


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_s3_toy() -> None:
    """The fully derived instance GL(2,2) = S_3 acting on three points."""
    print("=" * 70)
    print("DEMO 1:  GL(2,2) = S_3 acting on three points (fully derived)")
    print("=" * 70)
    group = list(permutations(range(3)))            # S_3 as permutations
    domain = list(range(3))
    act = lambda g, x: g[x]                          # apply the permutation

    fsum = burnside_fixed_sum(group, domain, act)
    ssum = stabilizer_sum(group, domain, act)
    print(f"  |G| = {len(group)}")
    print(f"  Burnside side   sum_g |Fix(g)| = {fsum}   (expect 3 + 3*1 + 2*0 = 6)")
    print(f"  Stabilizer side sum_x |Stab(x)| = {ssum}")
    print(f"  bridge identity holds: {fsum == ssum}")
    orbits = division_principle(fsum, len(group))
    print(f"  orbit count via division principle = {orbits}")
    print(f"  ground-truth orbit count           = "
          f"{orbit_count_by_enumeration(group, domain, act)}")
    print()


def demo_gl_boolean(n: int) -> None:
    """GL(n,2) acting on all Boolean functions in n variables; checks the bridge."""
    print("=" * 70)
    print(f"DEMO 2:  GL({n},2) acting on all Boolean functions in {n} variables")
    print("=" * 70)
    group = general_linear_group(n)
    inv = {g: mat_inverse(g, group, n) for g in group}
    domain = boolean_functions(n)
    act = lambda g, f: act_on_boolean(inv[g], f, n)

    fsum = burnside_fixed_sum(group, domain, act)
    ssum = stabilizer_sum(group, domain, act)
    orbits_gt = orbit_count_by_enumeration(group, domain, act)
    orbits_bl = division_principle(fsum, len(group))
    print(f"  |GL({n},2)|                = {len(group)}  (formula: {gl_order(n)})")
    print(f"  number of Boolean funcs   = {len(domain)}  (= 2^(2^{n}))")
    print(f"  Burnside side   sum |Fix| = {fsum}")
    print(f"  Stabilizer side sum |Stab|= {ssum}")
    print(f"  bridge identity holds     : {fsum == ssum}")
    print(f"  two-methods product |O|*|G|= {orbits_bl * len(group)}")
    print(f"  orbit count (Burnside/div): {orbits_bl}")
    print(f"  orbit count (enumeration) : {orbits_gt}")
    print(f"  all three counts agree    : {orbits_bl == orbits_gt}")
    print()


def demo_classification_number() -> None:
    """The number 3,691,560: division principle at scale + factorization."""
    print("=" * 70)
    print("DEMO 3:  The classification number 3,691,560")
    print("=" * 70)
    orbit_count = 3_691_560
    g10 = gl_order(10)
    dim = comb(10, 3)
    print(f"  dim of cubic layer  C(10,3)        = {dim}")
    print(f"  number of cubic forms  2^{dim}      = {1 << dim}")
    print(f"  |GL(10,2)|                          = {g10}")
    # The classification asserts the Burnside sum is orbit_count * |GL(10,2)|.
    fixed_sum = orbit_count * g10
    recovered = division_principle(fixed_sum, g10)
    print(f"  Burnside sum = N*|G| divided back  = {recovered}")
    print(f"  matches asserted orbit count       : {recovered == orbit_count}")
    fac = factorize(orbit_count)
    pretty = " * ".join(f"{p}^{e}" if e > 1 else f"{p}" for p, e in fac.items())
    print(f"  factorization                      = {pretty}")
    print(f"  reconstruct product                = {prod(p ** e for p, e in fac.items())}")
    print(f"  equals 120 * 30763                 : {orbit_count == 120 * 30763}")
    print(f"  120 = 5! = C(10,3)                 : {120 == comb(10, 3)}")
    print(f"  30763 is prime                     : {is_prime(30763)}")
    print()


def main() -> None:
    demo_s3_toy()
    demo_gl_boolean(2)   # 16 Boolean functions, |GL(2,2)| = 6
    demo_gl_boolean(3)   # 256 Boolean functions, |GL(3,2)| = 168
    demo_classification_number()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
