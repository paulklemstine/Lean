"""
demo.py — Numerical demonstrations for
"Discrete Pseudomanifolds at the Vertex Threshold: A Classification via the
Minimal Projective Plane."

This standalone script demonstrates, with concrete finite computations:

  1. The minimal six-vertex triangulation of the real projective plane RP^2,
     its face vector (6, 15, 10), and its Euler characteristic 1.
  2. The weak-pseudomanifold property: every ridge lies in exactly two facets.
  3. The pseudomanifold handshake identity  (d+1) * f_d = 2 * f_{d-1}.
  4. The suspension operation, its preservation of the pseudomanifold property,
     and the law  chi(Sigma K) = 2 - chi(K),  so that the reduced Euler
     characteristic is negated and the RP^2 tower stays pinned at chi = 1.
  5. Contrast with spheres, whose Euler characteristic alternates in {0, 2}.

No third-party dependencies; standard library only.
"""

from __future__ import annotations

from itertools import combinations
from typing import FrozenSet, Iterable, List, Set, Tuple

# A facet is a frozenset of vertices; a facet family is a set of facets.
Facet = FrozenSet[int]
FacetFamily = Set[Facet]


# --------------------------------------------------------------------------- #
# The minimal six-vertex triangulation of RP^2 (10 triangles on vertices 0..5)
# --------------------------------------------------------------------------- #
RP2_FACETS: FacetFamily = {
    frozenset(t)
    for t in [
        (0, 1, 2), (0, 2, 3), (0, 3, 4), (0, 4, 5), (0, 1, 5),
        (1, 2, 4), (1, 3, 4), (1, 3, 5), (2, 3, 5), (2, 4, 5),
    ]
}


def ridges(facets: FacetFamily, d: int) -> Set[Facet]:
    """All d-element subsets of facets (the codimension-one faces when the
    complex is pure of dimension d)."""
    result: Set[Facet] = set()
    for sigma in facets:
        for r in combinations(sorted(sigma), d):
            result.add(frozenset(r))
    return result


def all_faces(facets: FacetFamily) -> List[Set[Facet]]:
    """Return faces grouped by cardinality: index i holds the (i+1)-vertex faces,
    i.e. the i-dimensional faces."""
    if not facets:
        return []
    top = max(len(s) for s in facets)
    grouped: List[Set[Facet]] = [set() for _ in range(top)]
    for sigma in facets:
        for k in range(1, len(sigma) + 1):
            for f in combinations(sorted(sigma), k):
                grouped[k - 1].add(frozenset(f))
    return grouped


def face_vector(facets: FacetFamily) -> List[int]:
    """(f_0, f_1, ..., f_d): counts of faces of each dimension."""
    return [len(layer) for layer in all_faces(facets)]


def euler_characteristic(facets: FacetFamily) -> int:
    """chi = f_0 - f_1 + f_2 - ..."""
    fv = face_vector(facets)
    return sum((-1) ** i * fi for i, fi in enumerate(fv))


def is_pure(facets: FacetFamily, d: int) -> bool:
    """Every facet has exactly d+1 vertices."""
    return all(len(sigma) == d + 1 for sigma in facets)


def ridge_facet_counts(facets: FacetFamily, d: int) -> dict:
    """Map each ridge to the number of facets containing it."""
    counts: dict = {}
    for rho in ridges(facets, d):
        counts[rho] = sum(1 for sigma in facets if rho <= sigma)
    return counts


def is_weak_pseudomanifold(facets: FacetFamily, d: int) -> bool:
    """Pure of dimension d and non-branching (every ridge in exactly 2 facets)."""
    if not is_pure(facets, d):
        return False
    return all(c == 2 for c in ridge_facet_counts(facets, d).values())


def handshake_holds(facets: FacetFamily, d: int) -> Tuple[int, int, bool]:
    """Return ((d+1)*f_d, 2*f_{d-1}, equal?)."""
    f_d = len(facets)
    f_dm1 = len(ridges(facets, d))
    return (d + 1) * f_d, 2 * f_dm1, (d + 1) * f_d == 2 * f_dm1


def suspend(facets: FacetFamily, apex_a: int, apex_b: int) -> FacetFamily:
    """The suspension Sigma F using two fresh apex vertices."""
    out: FacetFamily = set()
    for sigma in facets:
        out.add(sigma | {apex_a})
        out.add(sigma | {apex_b})
    return out


def iterated_suspension(facets: FacetFamily, k: int) -> FacetFamily:
    """Sigma^k F, allocating fresh apex vertices above all existing labels."""
    current = set(facets)
    next_label = (max((max(s) for s in facets), default=-1)) + 1
    for _ in range(k):
        a, b = next_label, next_label + 1
        current = suspend(current, a, b)
        next_label += 2
    return current


def sphere_euler(d: int) -> int:
    """Euler characteristic of a d-sphere: 1 + (-1)^d."""
    return 1 + (-1) ** d


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_rp2() -> None:
    print("=" * 70)
    print("1. The minimal six-vertex triangulation of RP^2")
    print("=" * 70)
    fv = face_vector(RP2_FACETS)
    print(f"   facets (triangles) : {len(RP2_FACETS)}")
    print(f"   face vector        : {tuple(fv)}   (vertices, edges, triangles)")
    print(f"   2-neighborly       : {fv[1] == 15} (all C(6,2)=15 pairs are edges)")
    print(f"   Euler characteristic chi = {euler_characteristic(RP2_FACETS)}")
    print(f"   is weak 2-pseudomanifold : {is_weak_pseudomanifold(RP2_FACETS, 2)}")


def demo_nonbranching() -> None:
    print("\n" + "=" * 70)
    print("2. Non-branching: every edge lies in exactly two triangles")
    print("=" * 70)
    counts = ridge_facet_counts(RP2_FACETS, 2)
    distinct = sorted(set(counts.values()))
    print(f"   number of edges (ridges)         : {len(counts)}")
    print(f"   distinct facet-incidence counts  : {distinct}")
    print(f"   all edges shared by exactly two  : {distinct == [2]}")


def demo_handshake() -> None:
    print("\n" + "=" * 70)
    print("3. The pseudomanifold handshake  (d+1) f_d = 2 f_{d-1}")
    print("=" * 70)
    lhs, rhs, ok = handshake_holds(RP2_FACETS, 2)
    print(f"   3 * 10 = {lhs}   and   2 * 15 = {rhs}   equal: {ok}")


def demo_suspension_tower() -> None:
    print("\n" + "=" * 70)
    print("4. Suspension tower over RP^2: chi stays pinned at 1")
    print("=" * 70)
    print(f"   {'k':>2} | {'dim d':>5} | {'vertices':>8} | {'facets':>6} | "
          f"{'chi':>4} | {'wk pmfd':>7} | {'sphere chi':>10}")
    print("   " + "-" * 60)
    for k in range(0, 5):
        fam = iterated_suspension(RP2_FACETS, k)
        d = 2 + k
        n_vertices = len({v for s in fam for v in s})
        chi = euler_characteristic(fam)
        wk = is_weak_pseudomanifold(fam, d)
        print(f"   {k:>2} | {d:>5} | {n_vertices:>8} | {len(fam):>6} | "
              f"{chi:>4} | {str(wk):>7} | {sphere_euler(d):>10}")
    print("\n   Note: RP^2-tower chi is always 1, but a d-sphere has "
          "chi = 1+(-1)^d in {0,2},")
    print("   so no tower member is a sphere. (Reduced chi is negated each "
          "suspension; 0 is fixed.)")


def demo_euler_law() -> None:
    print("\n" + "=" * 70)
    print("5. Verifying the suspension law  chi(Sigma K) = 2 - chi(K)")
    print("=" * 70)
    base = RP2_FACETS
    for k in range(0, 4):
        fam = iterated_suspension(RP2_FACETS, k)
        nxt = iterated_suspension(RP2_FACETS, k + 1)
        c, cn = euler_characteristic(fam), euler_characteristic(nxt)
        print(f"   chi(Sigma^{k+1}) = {cn}   vs   2 - chi(Sigma^{k}) = "
              f"{2 - c}   match: {cn == 2 - c}")


def main() -> None:
    demo_rp2()
    demo_nonbranching()
    demo_handshake()
    demo_suspension_tower()
    demo_euler_law()
    print("\nAll demonstrations completed.")


if __name__ == "__main__":
    main()
