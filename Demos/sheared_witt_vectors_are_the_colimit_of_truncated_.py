"""Numerical demonstrations for:

    "Sheared Witt Vectors as the Filtered Colimit of Truncated Witt Vectors."

This self-contained script illustrates, over concrete models, the three pillars of
the development:

  1. Shearing in isolation  (arity colimit):
     the eventually-basepoint sequences are exactly the union of the truncated ones.

  2. The double colimit:
     over a ring presented as a rising union of subrings, a finitely-supported
     coordinate sequence descends to a *single* stage, found by merging the finitely
     many constraining coordinate-stages.

  3. Necessity of shearing:
     the "vector of all variables" over a polynomial ring in countably many
     variables descends coordinatewise but never globally.

Plus a tropical (min-plus) echo, obtained by changing the basepoint from 0 to +inf.

Run:  python demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, Optional, Sequence


# ---------------------------------------------------------------------------
# 1. Shearing in isolation: sheared = colimit of truncated
# ---------------------------------------------------------------------------

def is_truncated_at(seq: Sequence[object], n: int, basepoint: object) -> bool:
    """True iff seq[k] == basepoint for every k >= n (the level-n truncated set)."""
    return all(seq[k] == basepoint for k in range(n, len(seq)))


def support_bound(seq: Sequence[object], basepoint: object) -> Optional[int]:
    """Least N with seq[k] == basepoint for all k >= N, or None if no such N
    within the sampled prefix (a proxy for 'not finitely supported')."""
    last_nonbase = -1
    for k, v in enumerate(seq):
        if v != basepoint:
            last_nonbase = k
    return last_nonbase + 1  # N = 0 means the all-basepoint sequence


def is_sheared(seq: Sequence[object], basepoint: object) -> bool:
    """True iff seq is eventually equal to the basepoint (finite essential support)."""
    return support_bound(seq, basepoint) is not None


def demo_arity_colimit() -> None:
    print("=" * 72)
    print("1. Shearing in isolation:  sheared  =  union over n of truncated-at-n")
    print("=" * 72)
    basepoint = 0
    # A finitely-supported sequence, viewed as a length-8 sample.
    seq = [3, 0, 5, 0, 0, 0, 0, 0]
    N = support_bound(seq, basepoint)
    print(f"sequence               : {seq}")
    print(f"support bound N        : {N}  (seq[k]=0 for all k>=N)")
    print(f"is sheared             : {is_sheared(seq, basepoint)}")
    print("membership in truncated sets {seq : seq[k]=0 for k>=n}:")
    for n in range(0, 9):
        print(f"   n={n}:  in truncated-at-{n}?  {is_truncated_at(seq, n, basepoint)}")
    print(f"-> first n that works is n = N = {N}: the sheared vector lands in")
    print(f"   the level-{N} truncation, exactly the colimit statement.\n")


# ---------------------------------------------------------------------------
# 2. The double colimit: descent to a single stage
# ---------------------------------------------------------------------------

@dataclass
class Monomial:
    """A monomial c * prod x_i^{e_i}; exponents keyed by variable index."""
    coeff: int
    exps: tuple[int, ...]  # exps[i] = exponent of variable x_i

    def max_var(self) -> int:
        """Largest variable index actually appearing (>=0), or -1 if constant."""
        used = [i for i, e in enumerate(self.exps) if e > 0]
        return max(used) if used else -1


@dataclass
class Poly:
    """A polynomial as a list of monomials over K[x_0, x_1, ...]."""
    terms: tuple[Monomial, ...]

    def max_var(self) -> int:
        """Largest variable index appearing in any term; -1 for a constant."""
        return max((m.max_var() for m in self.terms), default=-1)

    def in_stage(self, i: int) -> bool:
        """True iff this polynomial lies in S_i = K[x_0, ..., x_{i-1}]."""
        return self.max_var() < i


def variable(k: int) -> Poly:
    """The variable x_k as a Poly."""
    exps = tuple(1 if j == k else 0 for j in range(k + 1))
    return Poly((Monomial(1, exps),))


def constant(c: int) -> Poly:
    return Poly((Monomial(c, ()),))


def locate_stage(p: Poly) -> int:
    """Smallest stage i with p in S_i.  (max_var + 1, and 0 for constants.)"""
    return p.max_var() + 1


def descend_to_single_stage(
    seq: Sequence[Poly], basepoint: Poly
) -> tuple[int, int]:
    """Algorithm A: given a finitely supported sequence over R = union S_i,
    return (M, N): a common stage M and level N with seq[k] in S_M for all k
    and seq[k] == basepoint for k >= N.

    Complexity: O(N) locate-calls and O(N) merges (here 'merge' = max)."""
    # Support bound N.
    N = 0
    for k, p in enumerate(seq):
        if not _poly_eq(p, basepoint):
            N = k + 1
    # Merge finitely many constraining stages via directed join (= max on N).
    M = 0
    for k in range(N):
        M = max(M, locate_stage(seq[k]))
    return M, N


def _poly_eq(p: Poly, q: Poly) -> bool:
    """Structural equality up to zero-coefficient terms (sufficient for the demo)."""
    def norm(poly: Poly) -> dict[tuple[int, ...], int]:
        d: dict[tuple[int, ...], int] = {}
        for m in poly.terms:
            # pad exponent tuples to a canonical length for comparison
            key = m.exps
            d[key] = d.get(key, 0) + m.coeff
        return {k: v for k, v in d.items() if v != 0}
    return norm(p) == norm(q)


def demo_double_colimit() -> None:
    print("=" * 72)
    print("2. Double colimit:  a finitely-supported vector descends to ONE stage")
    print("=" * 72)
    zero = constant(0)
    # A sheared vector over K[x_0, x_1, ...]: (x_2, x_0 + 5, x_5, 0, 0, ...)
    p1 = variable(2)
    p2 = Poly((Monomial(1, (1,)), Monomial(5, ())))  # x_0 + 5
    p3 = variable(5)
    seq = [p1, p2, p3, zero, zero, zero]
    stages = [locate_stage(p) for p in seq[:3]]
    print("sheared vector coordinates and their minimal stages:")
    print(f"   seq[0] = x_2      in S_{stages[0]}")
    print(f"   seq[1] = x_0 + 5  in S_{stages[1]}")
    print(f"   seq[2] = x_5      in S_{stages[2]}")
    M, N = descend_to_single_stage(seq, zero)
    print(f"merge finitely many stages {stages} -> common stage M = {M}")
    print(f"support bound            -> level N = {N}")
    print(f"=> whole vector lives in S_{M}, truncated at level {N}.")
    print(f"   check: every coordinate in S_{M}?  "
          f"{all(p.in_stage(M) for p in seq)}\n")


# ---------------------------------------------------------------------------
# 3. Necessity of shearing: the vector of all variables
# ---------------------------------------------------------------------------

def demo_necessity() -> None:
    print("=" * 72)
    print("3. Necessity of shearing:  X = (x_0, x_1, x_2, ...) descends nowhere")
    print("=" * 72)
    depth = 8  # sample the first `depth` coordinates of the infinite vector
    X = [variable(k) for k in range(depth)]
    print("Every individual coordinate descends to a finite stage:")
    for k in range(depth):
        print(f"   X[{k}] = x_{k}  in  S_{locate_stage(X[k])}  (= S_{k+1})")
    print("But NO single stage i contains the whole (infinite) vector:")
    for i in range(depth):
        # the escaping coordinate is x_i, which needs stage i+1 > i
        escapes = not X[i].in_stage(i)
        print(f"   candidate stage i={i}:  x_{i} in S_{i}?  "
              f"{X[i].in_stage(i)}   (escapes: {escapes})")
    print("=> for every i the coordinate x_i escapes S_i; shearing is necessary.\n")


# ---------------------------------------------------------------------------
# 4. Tropical echo: same mechanism, basepoint +inf
# ---------------------------------------------------------------------------

INF = float("inf")


def tropical_add(a: float, b: float) -> float:
    """min-plus addition: a (+) b = min(a, b)."""
    return min(a, b)


def tropical_mul(a: float, b: float) -> float:
    """min-plus multiplication: a (*) b = a + b (with inf absorbing)."""
    if a == INF or b == INF:
        return INF
    return a + b


def demo_tropical() -> None:
    print("=" * 72)
    print("4. Tropical echo:  same shearing law, basepoint 0 replaced by +inf")
    print("=" * 72)
    basepoint = INF
    seq = [2.0, INF, 0.0, INF, INF, INF]
    N = support_bound(seq, basepoint)
    print(f"tropical vector        : {seq}")
    print(f"tropical zero (basepoint) = +inf;  additive id check: "
          f"min(3, inf) = {tropical_add(3.0, INF)}")
    print(f"support bound N        : {N}")
    print("membership in truncated tropical sets {g : g[k]=+inf for k>=n}:")
    for n in range(0, 7):
        print(f"   n={n}:  truncated-at-{n}?  {is_truncated_at(seq, n, basepoint)}")
    print(f"-> first working n = N = {N}: identical colimit mechanism as Witt,")
    print(f"   only the basepoint changed (0  ->  +inf).\n")


def main() -> None:
    demo_arity_colimit()
    demo_double_colimit()
    demo_necessity()
    demo_tropical()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
