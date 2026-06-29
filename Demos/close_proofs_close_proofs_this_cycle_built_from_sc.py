"""
Certified Expanders for Classical Groups -- numerical demonstrations.

This self-contained script illustrates, with concrete computations, the key
results of the certificate framework:

  * The classical / GL2 generation certificate (irreducible charpoly of `s`
    plus no common eigenvector with `t`) implies irreducible joint action
    (Theorems 1 and 5).
  * Vertex expansion of a symmetric generating set forces it to generate the
    whole group (Theorem 2).
  * Vertex expansion is monotone under enlarging the generating set
    (Theorem 3).
  * Expansion gives one-step neighbor growth by a factor (1 + eps), and hence
    logarithmic mixing (Theorem 4).
  * The neighborhood degree bound |N(A)| <= |A| * |S| (Lemma 5.6).

Everything is implemented from scratch with only the Python standard library.
We model a finite group abstractly via its element list and a multiplication
function, then build Cayley graphs and measure expansion by exhaustive search
over subsets (feasible only for small groups -- used purely for illustration).
"""

from __future__ import annotations

from itertools import product, combinations
from typing import Callable, Dict, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Finite field F_p arithmetic and 2x2 matrices over F_p (the GL2 case).
# ---------------------------------------------------------------------------

Mat = Tuple[int, int, int, int]  # (a, b, c, d) = [[a, b], [c, d]]


def mat_mul(p: int, x: Mat, y: Mat) -> Mat:
    """Multiply two 2x2 matrices over F_p."""
    a, b, c, d = x
    e, f, g, h = y
    return (
        (a * e + b * g) % p,
        (a * f + b * h) % p,
        (c * e + d * g) % p,
        (c * f + d * h) % p,
    )


def mat_det(p: int, x: Mat) -> int:
    """Determinant of a 2x2 matrix over F_p."""
    a, b, c, d = x
    return (a * d - b * c) % p


def mat_inv(p: int, x: Mat) -> Mat:
    """Inverse of an invertible 2x2 matrix over F_p."""
    a, b, c, d = x
    det = mat_det(p, x)
    det_inv = pow(det, -1, p)
    return (
        (d * det_inv) % p,
        (-b * det_inv) % p,
        (-c * det_inv) % p,
        (a * det_inv) % p,
    )


def mat_vec(p: int, x: Mat, v: Tuple[int, int]) -> Tuple[int, int]:
    """Apply a 2x2 matrix to a column vector over F_p."""
    a, b, c, d = x
    v0, v1 = v
    return ((a * v0 + b * v1) % p, (c * v0 + d * v1) % p)


def charpoly_coeffs(p: int, x: Mat) -> Tuple[int, int, int]:
    """Characteristic polynomial t^2 - (tr) t + det, returned as (1, -tr, det)."""
    a, b, c, d = x
    tr = (a + d) % p
    det = mat_det(p, x)
    return (1, (-tr) % p, det)


def charpoly_irreducible(p: int, x: Mat) -> bool:
    """A monic degree-2 polynomial over F_p is irreducible iff it has no root."""
    _, c1, c0 = charpoly_coeffs(p, x)
    for t in range(p):
        if (t * t + c1 * t + c0) % p == 0:
            return False
    return True


def eigenvectors(p: int, x: Mat) -> List[Tuple[int, int]]:
    """Return a representative nonzero eigenvector for each eigenvalue of x.

    Vectors are normalized so the first nonzero coordinate is 1 (projective
    representatives), so we can compare 'common eigenvectors' up to scaling.
    """
    reps: List[Tuple[int, int]] = []
    seen = set()
    nonzero_vectors = [
        (v0, v1)
        for v0, v1 in product(range(p), repeat=2)
        if not (v0 == 0 and v1 == 0)
    ]
    for v in nonzero_vectors:
        xv = mat_vec(p, x, v)
        # check xv = c * v for some scalar c
        is_eig = False
        if v[0] != 0:
            c = (xv[0] * pow(v[0], -1, p)) % p
            is_eig = xv == ((c * v[0]) % p, (c * v[1]) % p)
        else:  # v[1] != 0
            c = (xv[1] * pow(v[1], -1, p)) % p
            is_eig = xv == ((c * v[0]) % p, (c * v[1]) % p)
        if is_eig:
            key = _projective_key(p, v)
            if key not in seen:
                seen.add(key)
                reps.append(v)
    return reps


def _projective_key(p: int, v: Tuple[int, int]) -> Tuple[int, int]:
    """Normalize a nonzero vector to its projective representative."""
    if v[0] != 0:
        inv = pow(v[0], -1, p)
        return (1, (v[1] * inv) % p)
    inv = pow(v[1], -1, p)
    return (0, 1)


def gl2_certificate(p: int, s: Mat, t: Mat) -> Dict[str, object]:
    """Check the GL2 certificate and report each clause (Definition 8.1)."""
    s_inv = mat_det(p, s) != 0
    t_inv = mat_det(p, t) != 0
    s_irr = charpoly_irreducible(p, s)
    s_eigs = {_projective_key(p, v) for v in eigenvectors(p, s)}
    t_eigs = {_projective_key(p, v) for v in eigenvectors(p, t)}
    common = s_eigs & t_eigs
    certified = s_inv and t_inv and s_irr and not common
    return {
        "s_invertible": s_inv,
        "t_invertible": t_inv,
        "s_charpoly_irreducible": s_irr,
        "common_eigenvectors": sorted(common),
        "certified": certified,
    }


# ---------------------------------------------------------------------------
# Abstract finite-group Cayley graph machinery.
# ---------------------------------------------------------------------------

Elem = object


class FiniteGroup:
    """A finite group given by its elements, multiplication, and identity."""

    def __init__(
        self,
        elements: Sequence[Elem],
        mul: Callable[[Elem, Elem], Elem],
        identity: Elem,
    ) -> None:
        self.elements: List[Elem] = list(elements)
        self.mul = mul
        self.identity = identity

    @property
    def order(self) -> int:
        return len(self.elements)

    def inverse(self, g: Elem) -> Elem:
        for h in self.elements:
            if self.mul(g, h) == self.identity:
                return h
        raise ValueError("no inverse found; not a group?")


def cayley_neighbors(group: FiniteGroup, gen: Sequence[Elem], A: frozenset) -> frozenset:
    """CayleyNeighborFinset: all a*s for a in A, s in gen (Definition 5.1)."""
    out = set()
    for a in A:
        for s in gen:
            out.add(group.mul(a, s))
    return frozenset(out)


def cayley_boundary(group: FiniteGroup, gen: Sequence[Elem], A: frozenset) -> frozenset:
    """CayleyVertexBoundary: neighbors of A not already in A (Definition 5.2)."""
    return cayley_neighbors(group, gen, A) - A


def vertex_expansion_constant(group: FiniteGroup, gen: Sequence[Elem]) -> float:
    """Exhaustively compute eps = min over nonempty A with 2|A| <= |G| of
    |boundary(A)| / |A|  (Definition 5.3). Exponential -- small groups only."""
    n = group.order
    best = float("inf")
    elems = group.elements
    for size in range(1, n // 2 + 1):
        for combo in combinations(elems, size):
            A = frozenset(combo)
            ratio = len(cayley_boundary(group, gen, A)) / len(A)
            if ratio < best:
                best = ratio
    return best


def generates_whole_group(group: FiniteGroup, gen: Sequence[Elem]) -> bool:
    """Test whether gen generates the group by closure under multiplication."""
    closure = {group.identity}
    frontier = {group.identity}
    while frontier:
        new = set()
        for a in frontier:
            for s in gen:
                prod = group.mul(a, s)
                if prod not in closure:
                    closure.add(prod)
                    new.add(prod)
        frontier = new
    return len(closure) == group.order


# ---------------------------------------------------------------------------
# A concrete small group: the symmetric group S_3 (order 6).
# ---------------------------------------------------------------------------

def symmetric_group_3() -> FiniteGroup:
    """S_3 as permutations of {0,1,2}, elements are tuples (images of 0,1,2)."""
    perms = list(product(range(3), repeat=3))
    perms = [p for p in perms if len(set(p)) == 3]  # bijections only

    def mul(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        # (a*b)(i) = a(b(i))
        return tuple(a[b[i]] for i in range(3))

    identity = (0, 1, 2)
    return FiniteGroup(perms, mul, identity)


# ---------------------------------------------------------------------------
# Demonstrations.
# ---------------------------------------------------------------------------

def demo_gl2_certificate() -> None:
    print("=" * 70)
    print("DEMO 1: GL2 generation certificate over F_p  (Theorems 1 & 5)")
    print("=" * 70)
    p = 5
    # s: companion matrix of the irreducible quadratic t^2 + 2 over F_5
    #    (squares mod 5 are {0,1,4}, and -2 = 3 is a non-square, so no root).
    #    Companion of t^2 + 0*t + 2 is [[0,-2],[1,0]] = [[0,3],[1,0]].
    s: Mat = (0, 3, 1, 0)
    # t: a matrix sharing no eigenvector with s
    t: Mat = (1, 1, 0, 1)
    rep = gl2_certificate(p, s, t)
    print(f"p = {p}")
    print(f"s = [[{s[0]},{s[1]}],[{s[2]},{s[3]}]]   charpoly coeffs {charpoly_coeffs(p, s)}")
    print(f"t = [[{t[0]},{t[1]}],[{t[2]},{t[3]}]]")
    for k, v in rep.items():
        print(f"  {k:28s}: {v}")
    print(f"\n  => Certified pair acts irreducibly on F_{p}^2: {rep['certified']}")

    # A NON-example: s with reducible charpoly (a diagonal matrix)
    s2: Mat = (2, 0, 0, 3)
    rep2 = gl2_certificate(p, s2, t)
    print(f"\n  Counter-check: s' = diag(2,3) has reducible charpoly.")
    print(f"  s'_charpoly_irreducible = {rep2['s_charpoly_irreducible']}, "
          f"certified = {rep2['certified']}")


def demo_expansion_forces_generation() -> None:
    print("\n" + "=" * 70)
    print("DEMO 2: Vertex expansion forces generation  (Theorem 2)")
    print("=" * 70)
    G = symmetric_group_3()
    # A symmetric generating set: a transposition (01) and a 3-cycle (012)+inverse.
    transposition = (1, 0, 2)          # swaps 0,1
    three_cycle = (1, 2, 0)            # 0->1->2->0
    three_cycle_inv = G.inverse(three_cycle)
    gen = [transposition, three_cycle, three_cycle_inv, G.identity]
    eps = vertex_expansion_constant(G, gen)
    gens_all = generates_whole_group(G, gen)
    print(f"Group: S_3, order {G.order}")
    print(f"Symmetric generating set with identity, size {len(set(gen))}")
    print(f"  measured vertex expansion eps = {eps:.4f}  (> 0)")
    print(f"  generates whole group?        = {gens_all}")
    print(f"  => positive expansion  ==>  generation (as Theorem 2 predicts)")

    # A NON-generating set: only the transposition (and identity) -> eps must be 0.
    bad = [transposition, G.identity]
    eps_bad = vertex_expansion_constant(G, bad)
    print(f"\n  Counter-check: only a transposition.")
    print(f"  measured expansion = {eps_bad:.4f}, generates = "
          f"{generates_whole_group(G, bad)}")
    print("  => zero expansion is consistent with failure to generate.")


def demo_monotonicity_and_growth() -> None:
    print("\n" + "=" * 70)
    print("DEMO 3: Monotonicity (Thm 3) and (1+eps) growth (Thm 4)")
    print("=" * 70)
    G = symmetric_group_3()
    transposition = (1, 0, 2)
    three_cycle = (1, 2, 0)
    three_cycle_inv = G.inverse(three_cycle)
    S = [three_cycle, three_cycle_inv, G.identity]
    T = [transposition, three_cycle, three_cycle_inv, G.identity]
    eps_S = vertex_expansion_constant(G, S)
    eps_T = vertex_expansion_constant(G, T)
    print(f"S (3-cycle + identity):           eps_S = {eps_S:.4f}")
    print(f"T = S + transposition (superset): eps_T = {eps_T:.4f}")
    print(f"  monotonicity check  eps_T >= eps_S : {eps_T >= eps_S - 1e-9}")

    # (1+eps) neighbor growth for T, where 1 in T.
    print(f"\n  One-step neighbor growth |N(A)| >= (1+eps)|A|  for T (eps={eps_T:.3f}):")
    for size in range(1, G.order // 2 + 1):
        worst = float("inf")
        for combo in combinations(G.elements, size):
            A = frozenset(combo)
            nbhd = len(cayley_neighbors(G, T, A))
            worst = min(worst, nbhd / len(A))
        bound = 1 + eps_T
        ok = worst >= bound - 1e-9
        print(f"    |A|={size}: min |N(A)|/|A| = {worst:.3f}  "
              f">= 1+eps = {bound:.3f}? {ok}")


def demo_degree_bound() -> None:
    print("\n" + "=" * 70)
    print("DEMO 4: Neighborhood degree bound |N(A)| <= |A|*|S|  (Lemma 5.6)")
    print("=" * 70)
    G = symmetric_group_3()
    three_cycle = (1, 2, 0)
    gen = [three_cycle, G.inverse(three_cycle), (1, 0, 2)]
    print(f"Generating set size |S| = {len(gen)}")
    for size in range(1, G.order + 1):
        for combo in combinations(G.elements, size):
            A = frozenset(combo)
            lhs = len(cayley_neighbors(G, gen, A))
            rhs = len(A) * len(gen)
            assert lhs <= rhs, "degree bound violated!"
    print("  Verified |N(A)| <= |A|*|S| for ALL subsets A of S_3.  OK")


def main() -> None:
    demo_gl2_certificate()
    demo_expansion_forces_generation()
    demo_monotonicity_and_growth()
    demo_degree_bound()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
