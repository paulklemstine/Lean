"""Numerical demonstrations of the Local-to-Global KKL Theorem for partite complexes.

The complete n-partite complex over an alphabet of size m has as its facets the
transversals  x : {0,...,n-1} -> {0,...,m-1}, identified with tuples in
[m]^n.  A Boolean labelling is a map  f : [m]^n -> {0, 1}.

Key quantities implemented here (all exact, over the m^n facets):

    Inf(f, i)            unnormalized influence of color i:
                         # ordered i-adjacent pairs (x, y) with f(x) != f(y).
    InfSub(f, j, b, i)   influence of color i inside the link where x_j = b.
    LinkTotInf(f, j, b)  sum over i != j of InfSub(f, j, b, i).

Demonstrated results:

    Self-averaging bridge     Inf(f, i) = sum_b InfSub(f, j, b, i).
    Total-influence bound     all links >= T  =>  sum_{i!=j} Inf(f,i) >= m*T.
    Local-to-global KKL        some i != j has (n-1)*Inf(f,i) >= m*T.
    Degeneracy dichotomy       all Inf(f,i)=0  <=>  f constant.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

Facet = Tuple[int, ...]
Labelling = Callable[[Facet], int]


def facets(n: int, m: int) -> List[Facet]:
    """All m^n transversals of the complete n-partite complex over [m]."""
    return list(product(range(m), repeat=n))


def influence(f: Labelling, n: int, m: int, i: int) -> int:
    """Inf(f, i): number of ordered i-adjacent sensitive pairs."""
    count = 0
    for x in facets(n, m):
        for c in range(m):
            if c == x[i]:
                continue
            y = x[:i] + (c,) + x[i + 1:]
            if f(x) != f(y):
                count += 1
    return count


def influence_link(f: Labelling, n: int, m: int, j: int, b: int, i: int) -> int:
    """InfSub(f, j, b, i): sensitive i-pairs whose first facet has x_j = b."""
    count = 0
    for x in facets(n, m):
        if x[j] != b:
            continue
        for c in range(m):
            if c == x[i]:
                continue
            y = x[:i] + (c,) + x[i + 1:]
            if f(x) != f(y):
                count += 1
    return count


def link_total_influence(f: Labelling, n: int, m: int, j: int, b: int) -> int:
    """LinkTotInf(f, j, b) = sum over i != j of InfSub(f, j, b, i)."""
    return sum(influence_link(f, n, m, j, b, i) for i in range(n) if i != j)


def check_bridge(f: Labelling, n: int, m: int, j: int) -> bool:
    """Verify Inf(f, i) = sum_b InfSub(f, j, b, i) for every color i."""
    ok = True
    for i in range(n):
        lhs = influence(f, n, m, i)
        rhs = sum(influence_link(f, n, m, j, b, i) for b in range(m))
        print(f"    color i={i}:  Inf={lhs:3d}   sum_b InfSub={rhs:3d}   "
              f"{'OK' if lhs == rhs else 'MISMATCH'}")
        ok = ok and (lhs == rhs)
    return ok


def local_to_global_kkl(f: Labelling, n: int, m: int, j: int
                        ) -> Tuple[int, int, int]:
    """Return (T, witness_color, Inf@witness) where T = min link total influence.

    The theorem guarantees (n-1)*Inf(f, i) >= m*T for the returned color i (!= j).
    """
    link_vals = [link_total_influence(f, n, m, j, b) for b in range(m)]
    T = min(link_vals)
    best_i, best_inf = -1, -1
    for i in range(n):
        if i == j:
            continue
        v = influence(f, n, m, i)
        if v > best_inf:
            best_i, best_inf = i, v
    return T, best_i, best_inf


def is_constant(f: Labelling, n: int, m: int) -> bool:
    fs = facets(n, m)
    v0 = f(fs[0])
    return all(f(x) == v0 for x in fs)


# ---------------------------------------------------------------------------
# Example labellings
# ---------------------------------------------------------------------------

def dictator(i: int, threshold: int) -> Labelling:
    """f(x) = 1 iff x_i >= threshold  (a single influential coordinate)."""
    return lambda x: 1 if x[i] >= threshold else 0


def parity_mod(m: int) -> Labelling:
    """f(x) = (sum of coordinates) mod m == 0 : every coordinate is influential."""
    return lambda x: 1 if sum(x) % m == 0 else 0


def majority_binary() -> Labelling:
    """Boolean majority (m = 2): f(x) = 1 iff a strict majority of bits are 1."""
    return lambda x: 1 if sum(x) * 2 > len(x) else 0


def constant_zero() -> Labelling:
    return lambda x: 0


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def demo_bridge() -> None:
    print("=" * 70)
    print("DEMO 1: Self-averaging bridge   Inf(f,i) = sum_b InfSub(f,j,b,i)")
    print("=" * 70)
    n, m, j = 3, 4, 0
    f = parity_mod(m)
    print(f"  n={n} colors, m={m} symbols, pinned color j={j}, f = (sum mod {m} == 0)")
    ok = check_bridge(f, n, m, j)
    print(f"  Bridge holds for all colors: {ok}\n")


def demo_kkl() -> None:
    print("=" * 70)
    print("DEMO 2: Local-to-global KKL   (n-1)*Inf(f,i) >= m*T for some i != j")
    print("=" * 70)
    for (n, m) in [(3, 3), (4, 2), (3, 5)]:
        f = parity_mod(m)
        j = 0
        T, i, inf_i = local_to_global_kkl(f, n, m, j)
        lhs, rhs = (n - 1) * inf_i, m * T
        print(f"  n={n}, m={m}, j={j}:  min link total influence T={T}")
        print(f"     witness color i={i} with Inf={inf_i};  "
              f"(n-1)*Inf={lhs} >= m*T={rhs}  -> {'OK' if lhs >= rhs else 'FAIL'}")
        avg = m * T / (n - 1)
        print(f"     guaranteed average bound  m*T/(n-1) = {avg:.3f}\n")


def demo_boolean_cube() -> None:
    print("=" * 70)
    print("DEMO 3: Boolean cube (m = 2) recovers the classical setting")
    print("=" * 70)
    n, m, j = 4, 2, 0
    f = majority_binary()
    print(f"  n={n}-bit majority function, pinned bit j={j}")
    for i in range(n):
        print(f"    Inf(bit {i}) = {influence(f, n, m, i)}")
    T, i, inf_i = local_to_global_kkl(f, n, m, j)
    print(f"  min link total influence T={T}, witness bit i={i}, Inf={inf_i}")
    print(f"  (n-1)*Inf={ (n-1)*inf_i } >= m*T={ m*T }\n")


def demo_degeneracy() -> None:
    print("=" * 70)
    print("DEMO 4: Degeneracy dichotomy   all Inf=0  <=>  f constant")
    print("=" * 70)
    n, m = 3, 3
    for name, f in [("constant 0", constant_zero()),
                    ("dictator on color 1", dictator(1, 1))]:
        infs = [influence(f, n, m, i) for i in range(n)]
        print(f"  {name}: influences {infs}; constant? {is_constant(f, n, m)}")
    print()


if __name__ == "__main__":
    demo_bridge()
    demo_kkl()
    demo_boolean_cube()
    demo_degeneracy()
    print("All demonstrations completed.")
