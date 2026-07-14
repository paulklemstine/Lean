"""
demo.py -- Numerical demonstration of the functorial excess of the Z2-coindex
under suspension.

This self-contained script realises the combinatorial cross-polytope model of the
n-sphere and its equivariant simplicial maps (Z2-maps), and demonstrates the main
results:

  1. The suspension of a Z2-map is again a Z2-map (raising both dimensions by 1).
  2. Suspension is a *functor*: it preserves identities and composition.
  3. The k-fold suspension of the identity of S^0 is the identity of S^k -- the
     whole constructive lower-bound tower coind(S^n) >= n from a single seed.
  4. Finite Borsuk-Ulam obstructions: there is no Z2-map S^1->S^0, S^2->S^1, or
     S^3->S^2, verified by exhaustive search over positive-vertex data.
  5. The resulting sharp excess: coind(S^n) = n for n = 0, 1, 2, each suspension
     raising the coindex by exactly one.

A vertex of S^n is a pair (i, b) with coordinate index 0 <= i <= n and sign
b in {False, True} (False = '+', True = '-'). The antipodal map flips b. A Z2-map
is stored as its restriction to positive vertices: a tuple g with g[i] = image of
(i, False); the value on (i, True) is the antipode of g[i].
"""

from __future__ import annotations

from itertools import product
from typing import Dict, List, Tuple

Vertex = Tuple[int, bool]        # (coordinate index, sign)
PosMap = Tuple[Vertex, ...]      # image of each positive vertex (i, False)


# ---------------------------------------------------------------------------
# The combinatorial sphere and its antipodal involution
# ---------------------------------------------------------------------------

def vertices(n: int) -> List[Vertex]:
    """All 2(n+1) vertices of the combinatorial n-sphere S^n."""
    return [(i, b) for i in range(n + 1) for b in (False, True)]


def antipode(v: Vertex) -> Vertex:
    """The antipodal map nu: flips the sign of a vertex."""
    i, b = v
    return (i, not b)


def is_antipodal(u: Vertex, v: Vertex) -> bool:
    """True iff u and v are an antipodal pair (same axis, opposite sign)."""
    return u == antipode(v)


# ---------------------------------------------------------------------------
# Z2-maps as positive-vertex data
# ---------------------------------------------------------------------------

def apply_map(g: PosMap, v: Vertex) -> Vertex:
    """Apply the Z2-map encoded by g to an arbitrary vertex (uses equivariance)."""
    i, b = v
    img = g[i]
    return img if not b else antipode(img)


def is_simplicial(g: PosMap, m: int, n: int) -> bool:
    """Check the simpliciality condition of the equivariant map g: S^m -> S^n.

    A map is simplicial iff every non-antipodal pair of S^m has a non-antipodal
    image in S^n. Equivariance is automatic from the encoding.
    """
    verts = vertices(m)
    for u in verts:
        for w in verts:
            if u == w or is_antipodal(u, w):
                continue
            if is_antipodal(apply_map(g, u), apply_map(g, w)):
                return False
    return True


def all_z2maps(m: int, n: int) -> List[PosMap]:
    """Exhaustively enumerate all Z2-maps S^m -> S^n (finite search)."""
    result: List[PosMap] = []
    for g in product(vertices(n), repeat=m + 1):
        if is_simplicial(g, m, n):
            result.append(g)
    return result


def z2map_exists(m: int, n: int) -> bool:
    """Decide whether any Z2-map S^m -> S^n exists."""
    for g in product(vertices(n), repeat=m + 1):
        if is_simplicial(g, m, n):
            return True
    return False


def identity_map(n: int) -> PosMap:
    """The identity Z2-map of S^n."""
    return tuple((i, False) for i in range(n + 1))


# ---------------------------------------------------------------------------
# Suspension and iterated suspension
# ---------------------------------------------------------------------------

def suspend(g: PosMap, m: int, n: int) -> PosMap:
    """Suspension Sigma: turns g: S^m -> S^n into Sigma g: S^{m+1} -> S^{n+1}.

    The new pole coordinate m+1 is sent to the new pole n+1 (sign preserved);
    every old positive vertex (i, False) is sent to its old image, unchanged.
    """
    return tuple(list(g) + [(n + 1, False)])


def suspend_iter(g: PosMap, m: int, n: int, k: int) -> PosMap:
    """The k-fold suspension Sigma^k."""
    cur = g
    for j in range(k):
        cur = suspend(cur, m + j, n + j)
    return cur


def compose(h: PosMap, g: PosMap) -> PosMap:
    """Composition h . g of Z2-maps (g: S^m -> S^n, h: S^n -> S^k)."""
    return tuple(apply_map(h, g[i]) for i in range(len(g)))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_suspension_wellformed() -> None:
    print("=" * 70)
    print("1. Suspension of a Z2-map is again a Z2-map")
    print("=" * 70)
    for m in range(3):
        g = identity_map(m)
        sg = suspend(g, m, m)
        ok = is_simplicial(sg, m + 1, m + 1)
        print(f"  Sigma(id_S^{m}) : S^{m+1} -> S^{m+1}   simplicial = {ok}   {sg}")
    print()


def demo_functor_laws() -> None:
    print("=" * 70)
    print("2. Suspension is a functor: preserves identities and composition")
    print("=" * 70)
    for n in range(4):
        lhs = suspend(identity_map(n), n, n)
        rhs = identity_map(n + 1)
        print(f"  Sigma(id_S^{n}) == id_S^{n+1} : {lhs == rhs}")
    print()
    # Composition law on concrete maps S^1 -> S^1 -> S^1.
    print("  Composition law Sigma(h.g) == Sigma(h).Sigma(g):")
    for g in all_z2maps(1, 1):
        for h in all_z2maps(1, 1):
            lhs = suspend(compose(h, g), 1, 1)
            rhs = compose(suspend(h, 1, 1), suspend(g, 1, 1))
            assert lhs == rhs, (g, h)
    print("    verified for all Z2-maps S^1 -> S^1 -> S^1  (OK)")
    print()


def demo_tower_from_a_point() -> None:
    print("=" * 70)
    print("3. The whole tower is one point, suspended: Sigma^n(id_S^0) = id_S^n")
    print("=" * 70)
    base = identity_map(0)
    for n in range(6):
        tower = suspend_iter(base, 0, 0, n)
        print(f"  Sigma^{n}(id_S^0) == id_S^{n} : {tower == identity_map(n)}"
              f"   -> witnesses coind(S^{n}) >= {n}")
    print()


def demo_borsuk_ulam() -> None:
    print("=" * 70)
    print("4. Finite Borsuk-Ulam obstructions (exhaustive search)")
    print("=" * 70)
    for (m, n) in [(1, 0), (2, 1), (3, 2)]:
        count = len(all_z2maps(m, n))
        space = (2 * (n + 1)) ** (m + 1)
        print(f"  Z2-maps S^{m} -> S^{n}: {count} found among {space} candidates"
              f"   => IsEmpty = {count == 0}")
    print()


def demo_sharp_excess() -> None:
    print("=" * 70)
    print("5. Sharp excess: coind(S^n) = n and each suspension adds exactly 1")
    print("=" * 70)
    for n in range(3):
        lower = z2map_exists(n, n)          # witness at the diagonal
        upper = not z2map_exists(n + 1, n)  # obstruction one dimension up
        print(f"  coind(S^{n}) = {n}:  witness S^{n}->S^{n} = {lower},"
              f"  no map S^{n+1}->S^{n} = {upper}  => increment exactly 1")
    print()


def main() -> None:
    demo_suspension_wellformed()
    demo_functor_laws()
    demo_tower_from_a_point()
    demo_borsuk_ulam()
    demo_sharp_excess()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
