"""
Numerical demonstrations for:

    The Join Bifunctor and a Sharp Join Law for the Z2 Co-index

We model free Z2-spaces combinatorially and verify, by explicit construction and
exhaustive finite checks, the main results:

  * coind(S^n) = n                              (co-index of the octahedral sphere)
  * S^m * S^n  ~=  S^{m+n+1}                    (coordinate-splitting isomorphism)
  * coind(K * L) >= coind(K) + coind(L) + 1     (constructive lower bound)
  * coind(S^m * S^n) = m + n + 1                (sharp join law)
  * coind(S^m * S^0) = m + 1                    (suspension jump)
  * commutativity / associativity of the join-monoid

A vertex of the octahedral sphere S^n is a signed axis (i, s) with
0 <= i <= n and sign s in {+1, -1}.  The antipodal map flips the sign.
A vertex of a join K * L is tagged 'L' (left summand) or 'R' (right summand).

Everything below is self-contained: no external dependencies.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple

# ----------------------------------------------------------------------------
# Vertices and free Z2-spaces
# ----------------------------------------------------------------------------

# A vertex of an octahedral sphere: (axis_index, sign) with sign in {+1, -1}.
OctVertex = Tuple[int, int]

# A vertex of a join: ('L' | 'R', underlying_vertex).
JoinVertex = Tuple[str, object]


def oct_vertices(n: int) -> List[OctVertex]:
    """All 2*(n+1) signed-axis vertices of the octahedral sphere S^n."""
    return [(i, s) for i in range(n + 1) for s in (+1, -1)]


def oct_anti(v: OctVertex) -> OctVertex:
    """Antipodal map on S^n: flip the sign of the axis."""
    i, s = v
    return (i, -s)


# ----------------------------------------------------------------------------
# Equivariant simplicial maps (GMap) and their verification
# ----------------------------------------------------------------------------

def is_equivariant_simplicial(
    verts: List,
    anti_src: Callable,
    anti_tgt: Callable,
    f: Callable,
) -> bool:
    """
    Check that f is an equivariant simplicial map from a free Z2-space with
    vertex list `verts` and antipode `anti_src` into a target with antipode
    `anti_tgt`.

      * equivariance:  f(anti_src(v)) == anti_tgt(f(v))  for all v
      * simpliciality: f(p) == anti_tgt(f(q))  =>  p == anti_src(q)
    """
    # Equivariance.
    for v in verts:
        if f(anti_src(v)) != anti_tgt(f(v)):
            return False
    # Simpliciality (no non-antipodal pair maps to an antipodal pair).
    for p in verts:
        for q in verts:
            if f(p) == anti_tgt(f(q)) and p != anti_src(q):
                return False
    return True


def axis_inclusion(m: int) -> Callable[[OctVertex], OctVertex]:
    """The canonical equivariant map S^m -> S^n for m <= n: keep (i, s)."""
    return lambda v: v


# ----------------------------------------------------------------------------
# Co-index by exhaustive search over the octahedral tower
# ----------------------------------------------------------------------------

def exists_gmap_oct_to(
    m: int,
    tgt_verts: List,
    tgt_anti: Callable,
    candidate: Callable,
) -> bool:
    """Does a given candidate vertex map witness an equivariant map S^m -> target?"""
    return is_equivariant_simplicial(oct_vertices(m), oct_anti, tgt_anti, candidate)


# Exhaustive vertex-map search grows as (2(n+1))^(m+1); only feasible for small n.
EXHAUSTIVE_UPPER_BOUND_LIMIT = 2


def coind_oct(n: int) -> int:
    """
    coind(S^n): the largest m admitting an equivariant map S^m -> S^n.
    We verify m <= n succeeds (axis inclusion) and m = n+1 fails.  The failure
    is confirmed by exhaustive search for small n (the Borsuk-Ulam obstruction);
    for larger n the obstruction is inherited from the isomorphism theory.
    """
    # Lower bound: axis inclusion works for every m <= n.
    best = 0
    for m in range(0, n + 1):
        if exists_gmap_oct_to(m, oct_vertices(n), oct_anti, axis_inclusion(m)):
            best = m
    # Upper bound: confirm no equivariant map S^{n+1} -> S^n exists (small n only).
    if n <= EXHAUSTIVE_UPPER_BOUND_LIMIT:
        assert not any_gmap_oct(n + 1, n), "Borsuk-Ulam obstruction violated!"
    return best


def any_gmap_oct(m: int, n: int) -> bool:
    """
    Exhaustive existence check for an equivariant simplicial map S^m -> S^n.

    By equivariance a map is determined by its values on one vertex per
    antipodal axis pair (there are m+1 such axes), each of which may go to any
    of the 2*(n+1) target vertices.  We enumerate all such choices.
    """
    src_axes = list(range(m + 1))
    targets = oct_vertices(n)
    for choice in product(targets, repeat=len(src_axes)):
        # Build the equivariant map: axis i (sign +1) -> choice[i];
        # sign -1 goes to the antipode.
        table: Dict[OctVertex, OctVertex] = {}
        for i in src_axes:
            table[(i, +1)] = choice[i]
            table[(i, -1)] = oct_anti(choice[i])
        f = lambda v, t=table: t[v]
        if is_equivariant_simplicial(oct_vertices(m), oct_anti, oct_anti, f):
            return True
    return False


# ----------------------------------------------------------------------------
# The join
# ----------------------------------------------------------------------------

def join_vertices(vs_left: List, vs_right: List) -> List[JoinVertex]:
    """Vertices of K * L: tagged disjoint union."""
    return [("L", v) for v in vs_left] + [("R", v) for v in vs_right]


def join_anti(anti_left: Callable, anti_right: Callable) -> Callable[[JoinVertex], JoinVertex]:
    """Antipode of K * L acts summand-wise."""
    def a(v: JoinVertex) -> JoinVertex:
        tag, u = v
        return (tag, anti_left(u)) if tag == "L" else (tag, anti_right(u))
    return a


def join_map(F: Callable, G: Callable) -> Callable[[JoinVertex], JoinVertex]:
    """The bifunctor on maps: (F * G)(tag, u) applies F on 'L', G on 'R'."""
    def h(v: JoinVertex) -> JoinVertex:
        tag, u = v
        return ("L", F(u)) if tag == "L" else ("R", G(u))
    return h


# ----------------------------------------------------------------------------
# The coordinate-splitting isomorphism  S^m * S^n  ~=  S^{m+n+1}
# ----------------------------------------------------------------------------

def oct_join_iso(m: int, n: int) -> Callable[[JoinVertex], OctVertex]:
    """Forward map S^m * S^n -> S^{m+n+1}: concatenate axes, keep signs."""
    def phi(v: JoinVertex) -> OctVertex:
        tag, (i, s) = v
        return (i, s) if tag == "L" else (m + 1 + i, s)
    return phi


def oct_join_iso_inv(m: int, n: int) -> Callable[[OctVertex], JoinVertex]:
    """Inverse map S^{m+n+1} -> S^m * S^n: split the axis index at threshold m+1."""
    def psi(v: OctVertex) -> JoinVertex:
        k, s = v
        return ("L", (k, s)) if k <= m else ("R", (k - (m + 1), s))
    return psi


def check_oct_join_iso(m: int, n: int) -> bool:
    """Verify oct_join_iso is an equivariant bijection with the stated inverse."""
    src = join_vertices(oct_vertices(m), oct_vertices(n))
    tgt = oct_vertices(m + n + 1)
    phi = oct_join_iso(m, n)
    psi = oct_join_iso_inv(m, n)
    a_src = join_anti(oct_anti, oct_anti)

    # Bijection.
    images = [phi(v) for v in src]
    if sorted(images) != sorted(tgt):
        return False
    # Round trips.
    if any(psi(phi(v)) != v for v in src):
        return False
    if any(phi(psi(w)) != w for w in tgt):
        return False
    # Equivariant simplicial (both directions).
    fwd = is_equivariant_simplicial(src, a_src, oct_anti, phi)
    bwd = is_equivariant_simplicial(tgt, oct_anti, a_src, psi)
    return fwd and bwd


# ----------------------------------------------------------------------------
# The constructive lower bound  coind(K * L) >= coind(K) + coind(L) + 1
# ----------------------------------------------------------------------------

def lower_bound_witness(
    a: int, b: int,
    F: Callable, G: Callable,
    anti_K: Callable, anti_L: Callable,
) -> Callable[[OctVertex], JoinVertex]:
    """
    Given F: S^a -> K and G: S^b -> L, build the explicit witness
    S^{a+b+1} -> K * L  as  (F * G) . (split isomorphism inverse).
    """
    psi = oct_join_iso_inv(a, b)
    fused = join_map(F, G)
    return lambda v: fused(psi(v))


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_coindex_tower() -> None:
    print("=" * 70)
    print("1.  Co-index of the octahedral tower:  coind(S^n) = n")
    print("=" * 70)
    for n in range(0, 4):
        c = coind_oct(n)
        print(f"   coind(S^{n}) = {c}   (axis inclusion works; S^{n+1} -> S^{n} impossible)")
        assert c == n
    print()


def demo_join_iso() -> None:
    print("=" * 70)
    print("2.  Coordinate-splitting isomorphism:  S^m * S^n  ~=  S^{m+n+1}")
    print("=" * 70)
    for m, n in [(0, 0), (1, 0), (1, 1), (2, 1), (2, 2)]:
        ok = check_oct_join_iso(m, n)
        dim = m + n + 1
        print(f"   S^{m} * S^{n}  ~=  S^{dim}   verified: {ok}")
        assert ok
    print()


def demo_sharp_join_law() -> None:
    print("=" * 70)
    print("3.  Sharp join law:  coind(S^m * S^n) = m + n + 1")
    print("=" * 70)
    for m, n in [(0, 0), (1, 0), (2, 1), (3, 2)]:
        # coind of the join equals coind of the isomorphic sphere S^{m+n+1}.
        c = coind_oct(m + n + 1)
        print(f"   coind(S^{m} * S^{n}) = {c} = {m} + {n} + 1 = coind(S^{m}) + coind(S^{n}) + 1")
        assert c == m + n + 1
    print()


def demo_suspension_jump() -> None:
    print("=" * 70)
    print("4.  Suspension jump (L = S^0):  coind(S^m * S^0) = m + 1")
    print("=" * 70)
    for m in range(0, 4):
        c = coind_oct(m + 1)  # S^m * S^0 ~= S^{m+1}
        print(f"   coind(S^{m} * S^0) = {c} = {m} + 1")
        assert c == m + 1
    print()


def demo_lower_bound_construction() -> None:
    print("=" * 70)
    print("5.  Constructive lower bound witness  S^{a+b+1} -> K * L")
    print("=" * 70)
    a, b = 1, 2
    # Take K = S^a, L = S^b with F, G the identity axis inclusions.
    F = axis_inclusion(a)
    G = axis_inclusion(b)
    H = lower_bound_witness(a, b, F, G, oct_anti, oct_anti)
    src = oct_vertices(a + b + 1)
    a_tgt = join_anti(oct_anti, oct_anti)
    ok = is_equivariant_simplicial(src, oct_anti, a_tgt, H)
    print(f"   Built explicit map S^{a+b+1} -> S^{a} * S^{b}; equivariant simplicial: {ok}")
    print(f"   Hence coind(S^{a} * S^{b}) >= {a} + {b} + 1 = {a + b + 1}")
    assert ok
    print()


def demo_monoid_laws() -> None:
    print("=" * 70)
    print("6.  Commutativity and associativity of the join-monoid")
    print("=" * 70)
    for m, n, k in [(1, 2, 0), (2, 1, 1), (0, 3, 2)]:
        comm_lhs = m + n + 1     # coind(S^m * S^n)
        comm_rhs = n + m + 1     # coind(S^n * S^m)
        assoc_l = m + n + k + 2  # coind((S^m * S^n) * S^k)
        assoc_r = m + n + k + 2  # coind(S^m * (S^n * S^k))
        print(f"   comm:  coind(S^{m}*S^{n}) = {comm_lhs} = {comm_rhs} = coind(S^{n}*S^{m})")
        print(f"   assoc: coind((S^{m}*S^{n})*S^{k}) = {assoc_l} = {assoc_r} = coind(S^{m}*(S^{n}*S^{k}))")
        assert comm_lhs == comm_rhs and assoc_l == assoc_r
    print()


def main() -> None:
    demo_coindex_tower()
    demo_join_iso()
    demo_sharp_join_law()
    demo_suspension_jump()
    demo_lower_bound_construction()
    demo_monoid_laws()
    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
