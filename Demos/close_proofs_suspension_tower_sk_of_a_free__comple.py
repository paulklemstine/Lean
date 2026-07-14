"""
demo.py -- Numerical demonstrations for the suspension tower of free Z2-complexes.

Everything here works in the combinatorial cross-polytope model of the sphere S^n:

    * The vertices of S^n are the 2(n+1) pairs (i, b) with axis i in {0,...,n}
      and sign b in {0,1}.  We read (i,0) as +e_i and (i,1) as -e_i.
    * The antipodal (free Z2) involution swaps the sign: a(i, b) = (i, 1-b).
    * A subset of vertices is a SIMPLEX iff it never contains both a vertex and
      its antipode (at most one vertex per axis).
    * An ANTIPODAL MAP F : S^m -> S^n is a vertex map that is equivariant
      (f(a v) = a(f v)) and simplicial (sends simplices to simplices).

Because of equivariance, an antipodal map is determined by its values on the
positive vertices (i, 0); we store that as a tuple g of length m+1 whose i-th
entry is the image vertex of (i, 0).

The script demonstrates, entirely by explicit computation:
  1. the existence criterion  Map(S^m, S^n) != {} iff m <= n;
  2. the coindex  coind(S^n) = n  (computed by enumeration for small n);
  3. the finite Borsuk-Ulam base cases  S^1 !-> S^0, S^2 !-> S^1, S^3 !-> S^2;
  4. suspension of an antipodal map and functoriality (susp of a composite
     equals the composite of suspensions);
  5. the suspension tower lifting a low-dimensional map to arbitrary height.

Run:  python demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Iterable, Iterator, Optional

# A vertex is (axis, sign);  an antipodal map is stored by its images on the
# positive vertices, i.e. a tuple of vertices of length (m+1).
Vertex = tuple[int, int]
Map = tuple[Vertex, ...]


# ---------------------------------------------------------------------------
# Basic combinatorics of the cross-polytope sphere S^n
# ---------------------------------------------------------------------------
def antipode(v: Vertex) -> Vertex:
    """The free involution a(i, b) = (i, 1 - b)."""
    i, b = v
    return (i, 1 - b)


def vertices(n: int) -> list[Vertex]:
    """All 2(n+1) vertices of S^n."""
    return [(i, b) for i in range(n + 1) for b in (0, 1)]


def facets(n: int) -> Iterator[tuple[Vertex, ...]]:
    """The 2^(n+1) top simplices: one signed vertex per axis."""
    for signs in product((0, 1), repeat=n + 1):
        yield tuple((i, signs[i]) for i in range(n + 1))


def is_simplex(sigma: Iterable[Vertex]) -> bool:
    """A set of vertices is a simplex iff no axis carries both signs."""
    seen: dict[int, int] = {}
    for (i, b) in sigma:
        if i in seen and seen[i] != b:
            return False
        seen[i] = b
    return True


# ---------------------------------------------------------------------------
# Antipodal maps
# ---------------------------------------------------------------------------
def apply_map(g: Map, v: Vertex) -> Vertex:
    """Evaluate the equivariant map with positive-image data g on vertex v."""
    i, b = v
    img = g[i]
    return img if b == 0 else antipode(img)


def is_antipodal_map(g: Map, m: int, n: int) -> bool:
    """Check equivariance (automatic) + simpliciality on every facet of S^m."""
    if len(g) != m + 1:
        return False
    if any(img[0] > n or img[0] < 0 for img in g):
        return False
    for facet in facets(m):
        image = [apply_map(g, v) for v in facet]
        if not is_simplex(image):
            return False
    return True


def enumerate_maps(m: int, n: int) -> Iterator[Map]:
    """Enumerate all antipodal maps S^m -> S^n via their positive images."""
    verts = vertices(n)
    for g in product(verts, repeat=m + 1):
        if is_antipodal_map(g, m, n):
            yield g


def exists_map(m: int, n: int) -> bool:
    """Is Map(S^m, S^n) nonempty?"""
    return next(enumerate_maps(m, n), None) is not None


def any_map(m: int, n: int) -> Optional[Map]:
    """Return one antipodal map S^m -> S^n if one exists."""
    return next(enumerate_maps(m, n), None)


def coindex(n: int, dmax: Optional[int] = None) -> int:
    """coind(S^n) = largest d with an antipodal map S^d -> S^n."""
    if dmax is None:
        dmax = n + 2
    best = -1
    for d in range(dmax + 1):
        if exists_map(d, n):
            best = d
    return best


# ---------------------------------------------------------------------------
# Diagonal witness, identity, composition, suspension
# ---------------------------------------------------------------------------
def diagonal_map(m: int, n: int) -> Map:
    """The axis-preserving inclusion S^m -> S^n (requires m <= n)."""
    assert m <= n
    return tuple((i, 0) for i in range(m + 1))


def identity_map(n: int) -> Map:
    """The identity antipodal map on S^n."""
    return tuple((i, 0) for i in range(n + 1))


def compose(g2: Map, g1: Map) -> Map:
    """Compose S^m --g1--> S^n --g2--> S^k, returning positive-image data."""
    return tuple(apply_map(g2, g1[i]) for i in range(len(g1)))


def suspend(g: Map, m: int, n: int) -> Map:
    """Suspension: S^{m+1} -> S^{n+1}; equator acts as g, new pole -> new pole."""
    return tuple(list(g) + [(n + 1, 0)])


def suspend_iter(g: Map, m: int, n: int, k: int) -> Map:
    """The k-fold suspension tower of g."""
    cur = g
    cm, cn = m, n
    for _ in range(k):
        cur = suspend(cur, cm, cn)
        cm, cn = cm + 1, cn + 1
    return cur


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_existence_criterion(mmax: int = 4, nmax: int = 4) -> None:
    print("1. Existence criterion:  Map(S^m, S^n) nonempty  <=>  m <= n")
    print("   (rows m, columns n; '+' = exists, '.' = none)")
    header = "      " + " ".join(f"n={n}" for n in range(nmax + 1))
    print(header)
    for m in range(mmax + 1):
        row = []
        for n in range(nmax + 1):
            ok = exists_map(m, n)
            assert ok == (m <= n), f"criterion failed at m={m}, n={n}"
            row.append(" + " if ok else " . ")
        print(f"   m={m}  " + " ".join(row))
    print("   -> matches the theorem exactly.\n")


def demo_coindex(nmax: int = 3) -> None:
    print("2. Coindex of the cross-polytope spheres:  coind(S^n) = n")
    for n in range(nmax + 1):
        c = coindex(n)
        assert c == n, f"coindex mismatch at n={n}: got {c}"
        print(f"   coind(S^{n}) = {c}")
    print()


def demo_borsuk_ulam() -> None:
    print("3. Finite Borsuk-Ulam base cases (no antipodal map on the diagonal):")
    for (mm, nn) in [(1, 0), (2, 1), (3, 2)]:
        exists = exists_map(mm, nn)
        assert not exists, f"unexpected map S^{mm} -> S^{nn}"
        print(f"   S^{mm} -> S^{nn} :  no antipodal map  (checked exhaustively)")
    print()


def demo_no_map_to_low_spheres(upto: int = 3) -> None:
    print("4. Descent spreads each impossibility into an infinite family:")
    for (base_m, target_n, label) in [(1, 0, "S^0"), (2, 1, "S^1"), (3, 2, "S^2")]:
        cells = []
        for extra in range(upto + 1):
            m = base_m + extra
            assert not exists_map(m, target_n)
            cells.append(f"S^{m}")
        print(f"   no map from {', '.join(cells)}, ... onto {label}")
    print()


def demo_functoriality() -> None:
    print("5. Suspension is a functor:  susp(G o F) = susp(G) o susp(F)")
    F = diagonal_map(1, 2)         # S^1 -> S^2
    G = diagonal_map(2, 3)         # S^2 -> S^3
    lhs = suspend(compose(G, F), 1, 3)
    rhs = compose(suspend(G, 2, 3), suspend(F, 1, 2))
    assert lhs == rhs, "functoriality failed!"
    print(f"   F : S^1 -> S^2 = {F}")
    print(f"   G : S^2 -> S^3 = {G}")
    print(f"   susp(G o F)        = {lhs}")
    print(f"   susp(G) o susp(F)  = {rhs}")
    print("   -> equal, so suspension preserves composition.")
    # identity law
    assert suspend(identity_map(2), 2, 2) == identity_map(3)
    print("   susp(id_{S^2}) = id_{S^3}  ->  identities preserved.\n")


def demo_tower_lifting(height: int = 4) -> None:
    print("6. The suspension tower lifts a low map to arbitrary height:")
    F = diagonal_map(0, 1)         # equatorial map S^0 -> S^1
    print(f"   start: F : S^0 -> S^1 = {F}")
    for k in range(1, height + 1):
        Fk = suspend_iter(F, 0, 1, k)
        assert is_antipodal_map(Fk, k, 1 + k), "tower produced an invalid map!"
        print(f"   susp^{k}(F) : S^{k} -> S^{1 + k}  valid = {Fk}")
    print("   -> every rung yields a genuine antipodal map (lifting theorem).\n")


def main() -> None:
    print("=" * 70)
    print(" Suspension tower of free Z2-complexes -- numerical demonstrations")
    print("=" * 70)
    print()
    demo_existence_criterion()
    demo_coindex()
    demo_borsuk_ulam()
    demo_no_map_to_low_spheres()
    demo_functoriality()
    demo_tower_lifting()
    print("All assertions passed: the computations confirm the theorems.")


if __name__ == "__main__":
    main()
