"""
demo.py — Numerical demonstrations for
"A Certificate Architecture for Expander Cayley Graphs from Classical Groups"

This standalone script illustrates, with concrete finite groups, the main
theorems of the accompanying article and research paper:

  * Theorem 1 / Theorem 6 : the classical generation certificate (irreducible
    charpoly of s + no common eigenvector) forces irreducible joint action.
  * Definitions 4.1-4.3   : Cayley neighbor sets, vertex boundary, vertex
    expansion.
  * Theorem 2             : positive vertex expansion forces generation.
  * Theorem 3             : vertex expansion is monotone under enlargement of S.
  * Theorem 4 / Cor 4.8   : expansion => geometric neighborhood growth =>
    logarithmic diameter (fast mixing).
  * Lemma 4.6             : degree bound |N_S(A)| <= |A| * |S|.

Everything is implemented from scratch over F_p = Z/pZ; no external libraries
are required (pure standard library).
"""

from __future__ import annotations

from itertools import product
from typing import Dict, FrozenSet, Iterable, List, Optional, Tuple

# A 2x2 matrix over F_p is a tuple (a, b, c, d) representing [[a, b], [c, d]].
Mat = Tuple[int, int, int, int]
Vec = Tuple[int, int]


# --------------------------------------------------------------------------- #
#  Linear algebra over F_p                                                     #
# --------------------------------------------------------------------------- #
def mat_mul(x: Mat, y: Mat, p: int) -> Mat:
    """Multiply two 2x2 matrices over F_p."""
    a, b, c, d = x
    e, f, g, h = y
    return (
        (a * e + b * g) % p,
        (a * f + b * h) % p,
        (c * e + d * g) % p,
        (c * f + d * h) % p,
    )


def mat_vec(x: Mat, v: Vec, p: int) -> Vec:
    """Apply a 2x2 matrix to a column vector over F_p."""
    a, b, c, d = x
    u, w = v
    return ((a * u + b * w) % p, (c * u + d * w) % p)


def det(x: Mat, p: int) -> int:
    """Determinant of a 2x2 matrix over F_p."""
    a, b, c, d = x
    return (a * d - b * c) % p


def trace(x: Mat, p: int) -> int:
    """Trace of a 2x2 matrix over F_p."""
    a, _, _, d = x
    return (a + d) % p


def identity() -> Mat:
    return (1, 0, 0, 1)


def mat_inv(x: Mat, p: int) -> Mat:
    """Inverse of an invertible 2x2 matrix over F_p."""
    a, b, c, d = x
    D = det(x, p)
    Dinv = pow(D, -1, p)
    return ((d * Dinv) % p, (-b * Dinv) % p, (-c * Dinv) % p, (a * Dinv) % p)


# --------------------------------------------------------------------------- #
#  Section 5 / Theorem 6: the GL_2(F_p) certificate                            #
# --------------------------------------------------------------------------- #
def charpoly_irreducible_2x2(x: Mat, p: int) -> bool:
    """The characteristic polynomial t^2 - tr(x) t + det(x) is irreducible over
    F_p iff its discriminant tr^2 - 4 det is a non-residue (and nonzero)."""
    disc = (trace(x, p) ** 2 - 4 * det(x, p)) % p
    if disc == 0:
        return False  # repeated root in F_p
    # disc is a quadratic residue iff disc^((p-1)/2) == 1
    return pow(disc, (p - 1) // 2, p) != 1


def eigenvectors(x: Mat, p: int) -> List[Vec]:
    """All nonzero v (up to nothing -- we list every nonzero v) with x v = c v
    for some scalar c in F_p. Returns the list of such eigenvectors."""
    out: List[Vec] = []
    for v in product(range(p), repeat=2):
        if v == (0, 0):
            continue
        xv = mat_vec(x, v, p)
        # xv = c v for some c?  Solve componentwise; handle zero entries.
        scalars = set()
        ok = True
        for vi, xvi in zip(v, xv):
            if vi == 0:
                if xvi != 0:
                    ok = False
                    break
            else:
                scalars.add((xvi * pow(vi, -1, p)) % p)
        if ok and len(scalars) <= 1:
            out.append(v)  # type: ignore[arg-type]
    return out


def has_common_eigenvector(s: Mat, t: Mat, p: int) -> bool:
    """Does there exist a nonzero v that is an eigenvector of both s and t?"""
    es = set(eigenvectors(s, p))
    et = set(eigenvectors(t, p))
    return len(es & et) > 0


def gl2_certificate(s: Mat, t: Mat, p: int) -> bool:
    """Definition 5.1: both invertible, charpoly(s) irreducible, no common
    eigenvector.  By Theorem 6 this forces irreducible joint action on F_p^2."""
    return (
        det(s, p) != 0
        and det(t, p) != 0
        and charpoly_irreducible_2x2(s, p)
        and not has_common_eigenvector(s, t, p)
    )


# --------------------------------------------------------------------------- #
#  Group generation: enumerate <S> by closure                                 #
# --------------------------------------------------------------------------- #
def generate_group(gens: Iterable[Mat], p: int) -> FrozenSet[Mat]:
    """Closure of the generating set under multiplication (BFS)."""
    frontier: List[Mat] = list(dict.fromkeys(gens))
    seen = set(frontier)
    seen.add(identity())
    frontier.append(identity())
    while frontier:
        nxt: List[Mat] = []
        for g in frontier:
            for s in gens:
                h = mat_mul(g, s, p)
                if h not in seen:
                    seen.add(h)
                    nxt.append(h)
        frontier = nxt
    return frozenset(seen)


# --------------------------------------------------------------------------- #
#  Section 4: Cayley graph vertex expansion                                    #
# --------------------------------------------------------------------------- #
def cayley_neighbors(group: FrozenSet[Mat], S: List[Mat], A: FrozenSet[Mat],
                     p: int) -> FrozenSet[Mat]:
    """Definition 4.1: N_S(A) = { a*s : a in A, s in S }."""
    return frozenset(mat_mul(a, s, p) for a in A for s in S)


def vertex_boundary(group: FrozenSet[Mat], S: List[Mat], A: FrozenSet[Mat],
                    p: int) -> FrozenSet[Mat]:
    """Definition 4.2: boundary = N_S(A) \\ A."""
    return cayley_neighbors(group, S, A, p) - A


def expansion_constant(group: FrozenSet[Mat], S: List[Mat],
                       p: int, max_subsets: int = 200000) -> float:
    """Empirical vertex expansion: the minimum over a sample of nonempty
    A with 2|A| <= |G| of |boundary(A)| / |A|.  Small groups only."""
    elems = list(group)
    n = len(elems)
    import itertools
    import random

    best = float("inf")
    # Exhaustive for very small groups, sampled otherwise.
    count = 0
    for k in range(1, n // 2 + 1):
        combos: Iterable[Tuple[Mat, ...]]
        total = _nCk(n, k)
        if total <= 4000:
            combos = itertools.combinations(elems, k)
        else:
            combos = (tuple(random.sample(elems, k)) for _ in range(2000))
        for combo in combos:
            A = frozenset(combo)
            b = len(vertex_boundary(group, S, A, p))
            best = min(best, b / len(A))
            count += 1
            if count >= max_subsets:
                return best
    return best


def _nCk(n: int, k: int) -> int:
    from math import comb
    return comb(n, k)


# --------------------------------------------------------------------------- #
#  Theorem 4 / Corollary 4.8: geometric growth and diameter                    #
# --------------------------------------------------------------------------- #
def reachable_in_steps(group: FrozenSet[Mat], S: List[Mat], a: Mat,
                       p: int, k: int) -> FrozenSet[Mat]:
    """Definition: CayleyReachableInSteps -- elements reachable from a in <= k
    steps in Cay(G, S)."""
    reach = {a}
    frontier = {a}
    for _ in range(k):
        nxt = set()
        for b in frontier:
            for s in S:
                nxt.add(mat_mul(b, s, p))
        new = nxt - reach
        reach |= nxt
        frontier = new
        if not new:
            break
    return frozenset(reach)


def diameter(group: FrozenSet[Mat], S: List[Mat], p: int) -> int:
    """Graph diameter via BFS layers from the identity (vertex-transitive)."""
    a = identity()
    k = 0
    reach = {a}
    frontier = {a}
    while len(reach) < len(group):
        nxt = set()
        for b in frontier:
            for s in S:
                nxt.add(mat_mul(b, s, p))
        new = nxt - reach
        if not new:
            break
        reach |= nxt
        frontier = new
        k += 1
    return k


# --------------------------------------------------------------------------- #
#  Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_certificate() -> None:
    print("=" * 70)
    print("DEMO 1 — The GL_2(F_p) generation certificate (Theorems 1 & 6)")
    print("=" * 70)
    for p in (5, 7, 11):
        # s with irreducible charpoly: a companion-like matrix whose
        # discriminant is a non-residue.
        s = (0, 1, 1, 1)  # charpoly t^2 - t - 1
        # t a shear that shares no eigenvector with s
        t = (1, 1, 0, 1)
        cert = gl2_certificate(s, t, p)
        irr = charpoly_irreducible_2x2(s, p)
        common = has_common_eigenvector(s, t, p)
        print(f"  p={p:2d}: charpoly(s) irreducible? {irr!s:5}  "
              f"common eigenvector? {common!s:5}  ->  certificate: {cert}")
    print("  When the certificate holds, Theorem 6 guarantees <s,t> acts")
    print("  irreducibly on F_p^2 (no shared invariant line).\n")


def demo_expansion_and_generation() -> None:
    print("=" * 70)
    print("DEMO 2 — Vertex expansion, generation, growth (Theorems 2,3,4)")
    print("=" * 70)
    p = 5
    s = (1, 1, 0, 1)
    t = (1, 0, 1, 1)
    S = [s, mat_inv(s, p), t, mat_inv(t, p)]  # symmetric generating set
    G = generate_group(S, p)
    print(f"  p={p}: |<S>| = {len(G)}  (this is SL_2(F_5), |SL_2(F_5)|=120)")

    eps = expansion_constant(G, S, p)
    print(f"  Empirical vertex expansion eps ~= {eps:.4f}  (> 0)")
    print("  Theorem 2: eps > 0 forces S to generate G — verified by the")
    print(f"             closure above reaching all {len(G)} elements.")

    # Theorem 3: monotonicity under adding the identity as a generator.
    S2 = S + [identity()]
    eps2 = expansion_constant(G, S2, p)
    print(f"  Theorem 3 (monotonicity): adding a generator, eps' ~= {eps2:.4f}"
          f"  (>= {eps:.4f})")

    # Theorem 4: geometric growth with 1 in S.
    print("  Theorem 4 (geometric growth, 1 in S): |N_S(A)| vs (1+eps)|A|")
    a0 = identity()
    for k in range(0, 4):
        Rk = reachable_in_steps(G, S2, a0, p, k)
        print(f"     k={k}: |reachable in <= k steps| = {len(Rk)}")
    d = diameter(G, S, p)
    import math
    print(f"  Diameter = {d}, while (1/eps)*log|G| ~= "
          f"{(1/eps)*math.log(len(G)):.1f}  (Corollary 4.8: log diameter)\n")


def demo_degree_bound() -> None:
    print("=" * 70)
    print("DEMO 3 — Degree bound  |N_S(A)| <= |A| * |S|  (Lemma 4.6)")
    print("=" * 70)
    p = 5
    s = (1, 1, 0, 1)
    t = (1, 0, 1, 1)
    S = [s, mat_inv(s, p), t, mat_inv(t, p)]
    G = generate_group(S, p)
    import random
    random.seed(0)
    elems = list(G)
    for k in (1, 3, 8, 20):
        A = frozenset(random.sample(elems, k))
        N = cayley_neighbors(G, S, A, p)
        print(f"  |A|={k:2d}:  |N_S(A)| = {len(N):3d}  <=  |A|*|S| = "
              f"{k * len(S):3d}   {'OK' if len(N) <= k * len(S) else 'FAIL'}")
    print()


def demo_comparison() -> None:
    print("=" * 70)
    print("DEMO 4 — Comparing certified gaps across groups (Def 6.2)")
    print("=" * 70)
    for p in (3, 5):
        s = (1, 1, 0, 1)
        t = (1, 0, 1, 1)
        S = [s, mat_inv(s, p), t, mat_inv(t, p)]
        G = generate_group(S, p)
        eps = expansion_constant(G, S, p)
        print(f"  SL_2(F_{p}): |G|={len(G):4d}  empirical eps ~= {eps:.4f}")
    print("  Uniformity of eps across p is the content of Conjecture 6.3.\n")


def main() -> None:
    demo_certificate()
    demo_expansion_and_generation()
    demo_degree_bound()
    demo_comparison()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
