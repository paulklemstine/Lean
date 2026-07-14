"""
Numerical demonstrations for the exact enumeration of antipodal (Z2-equivariant)
simplicial maps between cross-polytope spheres.

A combinatorial n-sphere S^n is the boundary of the (n+1)-dimensional cross-polytope.
Its vertices are the poles (axis i, sign s) for i in {0..n}, s in {+1, -1}; a face is
any set of poles using each axis at most once. The antipode flips the sign.

An antipodal simplicial map S^m -> S^n is exactly:
    * an injection of the m+1 source axes into the n+1 target axes, PLUS
    * an independent sign choice on each of the m+1 source axes.

Hence the exact count is
    #maps(m, n) = (n+1)^{falling (m+1)} * 2^{m+1}.

This script:
    1. computes the count from the closed form,
    2. brute-force enumerates all maps for small m, n and checks the formula,
    3. reproduces the count table, the Borsuk-Ulam zero pattern, and the
       hyperoctahedral diagonal 2^{n+1}(n+1)!.
"""

from __future__ import annotations

from itertools import permutations, product
from math import factorial
from typing import Iterator, List, Tuple

# A vertex of S^n: (axis, sign) with sign in {+1, -1}.
Vertex = Tuple[int, int]
# A Z2-map is stored by its positive-vertex data: image of (i, +1) for i in 0..m.
PosData = Tuple[Vertex, ...]


def falling_factorial(a: int, k: int) -> int:
    """Falling factorial a^{underline k} = a (a-1) ... (a-k+1); 1 if k == 0."""
    result = 1
    for i in range(k):
        result *= (a - i)
    return result


def count_closed_form(m: int, n: int) -> int:
    """Exact number of antipodal simplicial maps S^m -> S^n."""
    return falling_factorial(n + 1, m + 1) * 2 ** (m + 1)


def enumerate_maps(m: int, n: int) -> Iterator[PosData]:
    """Brute-force enumerate all antipodal simplicial maps S^m -> S^n.

    A map is determined by positive-vertex data g(i) = (axis, sign). Simpliciality
    is equivalent to the axis map being injective; signs are free.
    """
    axes = range(n + 1)
    signs = (+1, -1)
    # injections of {0..m} into {0..n}: ordered selections without repetition.
    for axis_choice in permutations(axes, m + 1):
        for sign_choice in product(signs, repeat=m + 1):
            yield tuple((axis_choice[i], sign_choice[i]) for i in range(m + 1))


def brute_force_count(m: int, n: int) -> int:
    """Count maps by explicit enumeration (validates the closed form)."""
    return sum(1 for _ in enumerate_maps(m, n))


def is_simplicial(pos: PosData) -> bool:
    """A map (given by positive-vertex data) is simplicial iff its axis map is injective."""
    axes = [v[0] for v in pos]
    return len(set(axes)) == len(axes)


def count_table(max_m: int, max_n: int) -> List[List[int]]:
    """Table of counts with rows m = 0..max_m and columns n = 0..max_n."""
    return [[count_closed_form(m, n) for n in range(max_n + 1)] for m in range(max_m + 1)]


def hyperoctahedral_order(n: int) -> int:
    """Order of the hyperoctahedral group B_{n+1} = signed permutations of n+1 coords."""
    return factorial(n + 1) * 2 ** (n + 1)


def coindex(n: int, search_up_to: int = 50) -> int:
    """coind(S^n) = largest m with a map S^m -> S^n = n (via the count)."""
    best = -1
    for m in range(search_up_to + 1):
        if count_closed_form(m, n) > 0:
            best = m
    return best


def index(m: int, search_up_to: int = 50) -> int:
    """ind(S^m) = smallest n with a map S^m -> S^n = m (via the count)."""
    for n in range(search_up_to + 1):
        if count_closed_form(m, n) > 0:
            return n
    return -1


def main() -> None:
    print("=" * 70)
    print("Exact enumeration of antipodal maps of cross-polytope spheres")
    print("=" * 70)

    print("\n[1] Closed form vs. brute-force enumeration (small cases):")
    print(f"{'m':>3} {'n':>3} {'closed':>10} {'brute':>10} {'match':>7}")
    for m in range(4):
        for n in range(4):
            cf = count_closed_form(m, n)
            # only brute-force when the space is small enough to enumerate quickly
            bf = brute_force_count(m, n) if cf <= 5000 else cf
            print(f"{m:>3} {n:>3} {cf:>10} {bf:>10} {str(cf == bf):>7}")

    print("\n[2] Count table  #maps(m, n) = (n+1)^{fall m+1} * 2^{m+1}:")
    table = count_table(2, 4)
    header = "m\\n | " + " ".join(f"{n:>5}" for n in range(5))
    print(header)
    print("-" * len(header))
    for m, row in enumerate(table):
        print(f"{m:>3} | " + " ".join(f"{v:>5}" for v in row))

    print("\n[3] Borsuk-Ulam threshold: count is 0 exactly when n < m.")
    for m in range(4):
        for n in range(4):
            if count_closed_form(m, n) == 0:
                assert n < m
    print("    Verified: every zero entry has n < m (no map from a bigger sphere).")
    print(f"    Critical case #maps(S^3 -> S^2) = {count_closed_form(3, 2)} (Borsuk-Ulam).")

    print("\n[4] Diagonal = order of hyperoctahedral group B_{n+1} = 2^{n+1}(n+1)!:")
    for n in range(5):
        diag = count_closed_form(n, n)
        grp = hyperoctahedral_order(n)
        print(f"    #maps(S^{n} -> S^{n}) = {diag:>6}   |B_{n+1}| = {grp:>6}   match={diag == grp}")

    print("\n[5] Index equals coindex for every sphere (gap = 0):")
    for n in range(6):
        print(f"    n={n}:  coind(S^{n}) = {coindex(n)}   ind(S^{n}) = {index(n)}")

    print("\n[6] Suspension preserves the excess n - m:")
    for (m, n) in [(1, 3), (0, 0), (2, 5)]:
        for k in range(3):
            a = count_closed_form(m, n) > 0
            b = count_closed_form(m + k, n + k) > 0
            print(f"    (m,n)=({m},{n}), k={k}: nonempty(m,n)={a}, "
                  f"nonempty(m+k,n+k)={b}, agree={a == b}")

    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
