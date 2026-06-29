"""
Hypergraph Ramsey Theory Beyond Graphs --- numerical demonstrations.

This self-contained script illustrates, with exact integer arithmetic, the
results formalized in the accompanying paper:

  * the probabilistic (first-moment) lower bound
        2 * C(n, k) < 2^C(k, 3)  ==>  R_3(k, k) > n,
    with the verified instances R_3(5,5) > 11 and R_3(6,6) > 29;
  * the exact incidence identity sum_chi badCount(chi) = C(n,4) * 2^(C(n,3)-3)
    and the resulting expectation C(n,4)/8 for monochromatic tetrahedra;
  * the tower function tower(2, m) and the values 4, 16, 65536;
  * the separation c^k < tower(2, k) for k >= c+1 (single vs. double exp);
  * a tiny brute-force check that R_2(3,3) = 6 (the classic party number),
    used to validate the coloring/monochromatic-clique model.

Run:  python3 demo.py
"""

from __future__ import annotations

import sys
from fractions import Fraction
from itertools import combinations, product
from math import comb


# ---------------------------------------------------------------------------
# Tower (iterated exponential) function
# ---------------------------------------------------------------------------
def tower(base: int, height: int) -> int:
    """Return tower(base, height): base raised to base ... height times.

    tower(b, 0) = 1 and tower(b, m+1) = b ** tower(b, m).
    """
    value: int = 1
    for _ in range(height):
        value = base ** value
    return value


# ---------------------------------------------------------------------------
# Probabilistic lower bound
# ---------------------------------------------------------------------------
def first_moment_threshold_holds(n: int, k: int, r: int = 3) -> bool:
    """True iff 2 * C(n, k) < 2^C(k, r), the first-moment lower-bound condition.

    When True, there exists an r-uniform 2-coloring of [n] with no monochromatic
    k-clique, hence R_r(k, k) > n.
    """
    return 2 * comb(n, k) < 2 ** comb(k, r)


def best_probabilistic_lower_bound(k: int, r: int = 3, n_max: int = 5000) -> int:
    """Largest n with 2*C(n,k) < 2^C(k,r): a certified R_r(k,k) > n witness."""
    best: int = k  # trivially R_r(k,k) > k for k > r
    for n in range(k, n_max + 1):
        if first_moment_threshold_holds(n, k, r):
            best = n
        else:
            break
    return best


# ---------------------------------------------------------------------------
# Exact incidence identity and expectation (the r=3, monochromatic 4-set case)
# ---------------------------------------------------------------------------
def sum_badcount(n: int) -> int:
    """Sum over all colorings of the number of monochromatic 4-sets.

    Equals C(n,4) * 2^(C(n,3) - 3) by the exact incidence identity (valid n>=4).
    """
    return comb(n, 4) * 2 ** (comb(n, 3) - 3)


def expected_badcount(n: int) -> Fraction:
    """Average number of monochromatic 4-sets over all 2^C(n,3) colorings.

    Equals C(n,4)/8 exactly.
    """
    return Fraction(sum_badcount(n), 2 ** comb(n, 3))


# ---------------------------------------------------------------------------
# Brute-force Ramsey check for the graph case R_2(3,3) (validates the model)
# ---------------------------------------------------------------------------
def has_mono_clique_graph(coloring: dict[frozenset[int], int], n: int, k: int) -> bool:
    """True iff some k-subset of [n] is monochromatic under an edge 2-coloring."""
    for clique in combinations(range(n), k):
        edges = [coloring[frozenset(e)] for e in combinations(clique, 2)]
        if all(c == edges[0] for c in edges):
            return True
    return False


def graph_ramsey_property(n: int, k: int) -> bool:
    """True iff EVERY 2-coloring of edges of K_n has a monochromatic K_k."""
    pairs: list[frozenset[int]] = [frozenset(e) for e in combinations(range(n), 2)]
    for bits in product((0, 1), repeat=len(pairs)):
        coloring = {p: b for p, b in zip(pairs, bits)}
        if not has_mono_clique_graph(coloring, n, k):
            return False
    return True


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 70)
    print("HYPERGRAPH RAMSEY THEORY BEYOND GRAPHS --- numerical demonstrations")
    print("=" * 70)

    print("\n[1] Probabilistic lower bound  2*C(n,k) < 2^C(k,3)  =>  R_3(k,k) > n")
    for n, k in [(11, 5), (29, 6)]:
        lhs = 2 * comb(n, k)
        rhs = 2 ** comb(k, 3)
        ok = first_moment_threshold_holds(n, k)
        print(f"    k={k}, n={n}: 2*C({n},{k}) = {lhs:>9} {'<' if ok else '>='} "
              f"2^C({k},3) = {rhs:>9}  ->  R_3({k},{k}) > {n}: {ok}")

    print("\n[2] Best first-moment floor R_3(k,k) > n for small k")
    for k in range(4, 9):
        n = best_probabilistic_lower_bound(k)
        print(f"    k={k}: C(k,3)={comb(k,3):>3}  =>  certified R_3({k},{k}) > {n}")

    print("\n[3] Exact incidence identity & expectation of monochromatic 4-sets")
    for n in range(4, 14):
        s = sum_badcount(n)
        e = expected_badcount(n)
        flag = "  (< 1: first moment succeeds)" if e < 1 else ""
        print(f"    n={n:>2}: sum badCount = C({n},4)*2^(C({n},3)-3) = {s}")
        print(f"           E[badCount] = C({n},4)/8 = {e} = {float(e):.4f}{flag}")

    print("\n[4] Tower function tower(2, m) = 2^2^...^2 (m twos)")
    for m in range(5):
        print(f"    tower(2,{m}) = {tower(2, m)}")

    print("\n[5] Separation: c^k < tower(2,k) for k >= c+1 (single vs double exp)")
    for c in (2, 3):
        k = c + 1
        print(f"    c={c}, k={k}: c^k = {c**k:>6} < tower(2,{k}) = {tower(2, k)}")
    t5 = tower(2, 5)  # = 2^65536, far too large to print fully
    sys.set_int_max_str_digits(100000)  # allow rendering the digit count
    print(f"    c=4, k=5: 4^5 = {4**5} < tower(2,5) = 2^65536 "
          f"(a {len(str(t5))}-digit number): {4**5 < t5}")

    print("\n[6] Model validation by brute force: the classic party number R_2(3,3)")
    print(f"    Every 2-coloring of K_5 has a mono triangle? {graph_ramsey_property(5, 3)}")
    print(f"    Every 2-coloring of K_6 has a mono triangle? {graph_ramsey_property(6, 3)}")
    print("    => R_2(3,3) = 6, confirming the coloring / clique model.")

    print("\nDone.")


if __name__ == "__main__":
    main()
