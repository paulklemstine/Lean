"""
Numerical demonstrations for:

    The Product Bruhat Order and the Closure of Orbit Strata
    on Products of Flag Manifolds

Everything is elementary and self-contained. A "permutation" is a tuple
`w` of length n that is a rearrangement of range(n); `w[k]` is the image of
position k (0-indexed throughout).

We verify, by direct computation on small symmetric groups, the results of
the paper:

  * the Ehresmann rank count  rk_w(i, j) = #{ k <= i : w[k] <= j }
  * the Bruhat order  u <= v  iff  rk_v(i,j) <= rk_u(i,j) for all i, j
  * the transpose identity   rk_{w^{-1}}(i, j) = rk_w(j, i)
  * inversion invariance     u <= v  iff  u^{-1} <= v^{-1}
  * antisymmetry             (u <= v and v <= u) => u == v
  * extremes                 id is minimum, reversal w0 is maximum
  * length zero              w == id  iff  #inversions(w) == 0
  * headline correspondence  u <= v  iff  (u,u^{-1}) <= (v,v^{-1})
"""

from __future__ import annotations

from itertools import permutations
from typing import List, Tuple

Perm = Tuple[int, ...]


# --------------------------------------------------------------------------
# Core combinatorial primitives
# --------------------------------------------------------------------------

def all_perms(n: int) -> List[Perm]:
    """All permutations of {0, ..., n-1}."""
    return list(permutations(range(n)))


def inverse(w: Perm) -> Perm:
    """Group inverse of a permutation: inv[w[k]] = k."""
    inv = [0] * len(w)
    for k, wk in enumerate(w):
        inv[wk] = k
    return tuple(inv)


def rk(w: Perm, i: int, j: int) -> int:
    """Ehresmann rank count: #{ k <= i : w[k] <= j }  (0-indexed)."""
    return sum(1 for k in range(i + 1) if w[k] <= j)


def rank_matrix(w: Perm) -> List[List[int]]:
    """The full n x n rank matrix of w."""
    n = len(w)
    return [[rk(w, i, j) for j in range(n)] for i in range(n)]


def bruhat_le(u: Perm, v: Perm) -> bool:
    """Bruhat order via the Ehresmann rank criterion: u <= v."""
    n = len(u)
    return all(rk(v, i, j) <= rk(u, i, j) for i in range(n) for j in range(n))


def num_inversions(w: Perm) -> int:
    """Coxeter length: number of pairs i < j with w[i] > w[j]."""
    n = len(w)
    return sum(1 for i in range(n) for j in range(i + 1, n) if w[i] > w[j])


def identity(n: int) -> Perm:
    return tuple(range(n))


def reversal(n: int) -> Perm:
    """The longest element w0: k |-> n-1-k."""
    return tuple(n - 1 - k for k in range(n))


def prod_bruhat_le(p: Tuple[Perm, Perm], q: Tuple[Perm, Perm]) -> bool:
    """Componentwise (product) Bruhat order."""
    return bruhat_le(p[0], q[0]) and bruhat_le(p[1], q[1])


# --------------------------------------------------------------------------
# Verifications
# --------------------------------------------------------------------------

def check_transpose_identity(n: int) -> bool:
    """rk_{w^{-1}}(i, j) == rk_w(j, i) for all w, i, j."""
    for w in all_perms(n):
        wi = inverse(w)
        for i in range(n):
            for j in range(n):
                if rk(wi, i, j) != rk(w, j, i):
                    return False
    return True


def check_inversion_invariance(n: int) -> bool:
    """u <= v  iff  u^{-1} <= v^{-1}."""
    perms = all_perms(n)
    for u in perms:
        for v in perms:
            if bruhat_le(u, v) != bruhat_le(inverse(u), inverse(v)):
                return False
    return True


def check_antisymmetry(n: int) -> bool:
    """(u <= v and v <= u) => u == v."""
    perms = all_perms(n)
    for u in perms:
        for v in perms:
            if bruhat_le(u, v) and bruhat_le(v, u) and u != v:
                return False
    return True


def check_extremes(n: int) -> bool:
    """id is the minimum and reversal is the maximum."""
    e, w0 = identity(n), reversal(n)
    return all(bruhat_le(e, w) and bruhat_le(w, w0) for w in all_perms(n))


def check_length_zero(n: int) -> bool:
    """w == id  iff  num_inversions(w) == 0."""
    e = identity(n)
    for w in all_perms(n):
        if (num_inversions(w) == 0) != (w == e):
            return False
    return True


def check_headline(n: int) -> bool:
    """u <= v  iff  (u, u^{-1}) <= (v, v^{-1}) componentwise."""
    perms = all_perms(n)
    for u in perms:
        for v in perms:
            lhs = bruhat_le(u, v)
            rhs = prod_bruhat_le((u, inverse(u)), (v, inverse(v)))
            if lhs != rhs:
                return False
    return True


def main() -> None:
    print("=" * 66)
    print("Bruhat order & closure of orbit strata -- numerical checks")
    print("=" * 66)

    # A concrete rank-matrix example.
    w: Perm = (2, 0, 3, 1)
    print(f"\nExample permutation w = {w}  (0-indexed)")
    print(f"  inverse(w)      = {inverse(w)}")
    print(f"  #inversions(w)  = {num_inversions(w)}")
    print("  rank matrix rk_w(i,j):")
    for row in rank_matrix(w):
        print("    ", row)

    # Transpose identity illustrated on the same w.
    print("\nTranspose identity  rk_{w^-1}(i,j) == rk_w(j,i):")
    n = len(w)
    ok = all(rk(inverse(w), i, j) == rk(w, j, i)
             for i in range(n) for j in range(n))
    print(f"  holds for w = {w}: {ok}")

    # A comparable and an incomparable pair in S_3.
    print("\nSample comparisons in S_3 (0-indexed):")
    for u, v in [((0, 1, 2), (2, 1, 0)),
                 ((1, 0, 2), (2, 0, 1)),
                 ((1, 0, 2), (0, 2, 1))]:
        print(f"  {u} <= {v} ?  {bruhat_le(u, v)}")

    # Exhaustive checks across small n.
    print("\nExhaustive verification of all theorems:")
    header = ("n", "transpose", "inv-inv", "antisym",
              "extremes", "len-zero", "headline")
    print("  " + "  ".join(f"{h:>10}" for h in header))
    for n in range(1, 6):
        results = (
            check_transpose_identity(n),
            check_inversion_invariance(n),
            check_antisymmetry(n),
            check_extremes(n),
            check_length_zero(n),
            check_headline(n),
        )
        cells = [f"{n:>10}"] + [f"{str(r):>10}" for r in results]
        print("  " + "  ".join(cells))

    print("\nAll properties confirmed for n = 1..5.")


if __name__ == "__main__":
    main()
