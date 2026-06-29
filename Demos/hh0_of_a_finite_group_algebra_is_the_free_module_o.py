"""
Numerical demonstrations of the theorem:

    HH_0(R[G]) := R[G] / [R[G], R[G]]  is  R-linearly equivalent to  R[Conj(G)],

i.e. degree-zero Hochschild homology of a group algebra is the free R-module on
the set of conjugacy classes of G.

This script is fully self-contained (standard library only). It models finite
groups by explicit multiplication tables, computes:

  * the conjugacy classes of G (= a basis of HH_0(R[G])),
  * the canonical class map  toConj : R[G] -> R[Conj(G)]  collapsing coefficients
    within each class,
  * the commutator submodule [R[G], R[G]] (over R = Q, exact rational arithmetic),

and then VERIFIES, by exact linear algebra, the central identity

    dim [R[G], R[G]]  +  #Conj(G)  =  |G|       (rank-nullity for toConj)

equivalently  [R[G],R[G]] = ker(toConj), and hence  dim HH_0(R[G]) = #Conj(G).

Groups demonstrated: cyclic C_n (abelian), symmetric S_3, quaternion Q_8,
symmetric S_4, dihedral D_4.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from typing import Callable


# ---------------------------------------------------------------------------
# Finite group represented by a multiplication table on elements 0..n-1.
# ---------------------------------------------------------------------------

class FiniteGroup:
    """A finite group given by an explicit Cayley table.

    Elements are the integers 0..order-1. `mul[a][b]` is the product a*b,
    `inv[a]` is the inverse of a, and `e` is the identity element.
    """

    def __init__(self, order: int, mul: list[list[int]], e: int = 0) -> None:
        self.order: int = order
        self.mul: list[list[int]] = mul
        self.e: int = e
        self.inv: list[int] = [self._find_inverse(a) for a in range(order)]
        self._check_axioms()

    def _find_inverse(self, a: int) -> int:
        for b in range(self.order):
            if self.mul[a][b] == self.e and self.mul[b][a] == self.e:
                return b
        raise ValueError(f"element {a} has no inverse")

    def _check_axioms(self) -> None:
        n = self.order
        # identity
        for a in range(n):
            assert self.mul[self.e][a] == a and self.mul[a][self.e] == a
        # associativity
        for a, b, c in product(range(n), repeat=3):
            assert self.mul[self.mul[a][b]][c] == self.mul[a][self.mul[b][c]]

    def conjugate(self, c: int, u: int) -> int:
        """Return c * u * c^{-1}."""
        return self.mul[self.mul[c][u]][self.inv[c]]

    def conjugacy_classes(self) -> list[frozenset[int]]:
        """Partition the group into conjugacy classes (orbit enumeration)."""
        seen: set[int] = set()
        classes: list[frozenset[int]] = []
        for u in range(self.order):
            if u in seen:
                continue
            orbit = frozenset(self.conjugate(c, u) for c in range(self.order))
            classes.append(orbit)
            seen |= orbit
        return classes


# ---------------------------------------------------------------------------
# Group algebra over Q and the linear-algebraic verification.
# ---------------------------------------------------------------------------

Vector = list[Fraction]  # coordinates in the standard basis {single g 1}


def basis_vector(n: int, g: int) -> Vector:
    v = [Fraction(0)] * n
    v[g] = Fraction(1)
    return v


def commutator_generators(G: FiniteGroup) -> list[Vector]:
    """All additive commutators single(ab) - single(ba) over basis pairs.

    These span the commutator submodule [R[G], R[G]] (single(a)*single(b) =
    single(ab) in the group algebra, so single(a)single(b) - single(b)single(a)
    = single(ab) - single(ba)).
    """
    n = G.order
    gens: list[Vector] = []
    for a, b in product(range(n), repeat=2):
        ab = G.mul[a][b]
        ba = G.mul[b][a]
        v = [Fraction(0)] * n
        v[ab] += Fraction(1)
        v[ba] -= Fraction(1)
        gens.append(v)
    return gens


def rank(rows: list[Vector]) -> int:
    """Exact rank over Q by Gaussian elimination."""
    mat = [row[:] for row in rows]
    if not mat:
        return 0
    ncols = len(mat[0])
    r = 0
    for col in range(ncols):
        pivot = next((i for i in range(r, len(mat)) if mat[i][col] != 0), None)
        if pivot is None:
            continue
        mat[r], mat[pivot] = mat[pivot], mat[r]
        inv = Fraction(1) / mat[r][col]
        mat[r] = [x * inv for x in mat[r]]
        for i in range(len(mat)):
            if i != r and mat[i][col] != 0:
                factor = mat[i][col]
                mat[i] = [x - factor * y for x, y in zip(mat[i], mat[r])]
        r += 1
        if r == len(mat):
            break
    return r


def to_conj(G: FiniteGroup, w: Vector) -> dict[frozenset[int], Fraction]:
    """The class map: collapse coefficients of w within each conjugacy class."""
    classes = G.conjugacy_classes()
    coords: dict[frozenset[int], Fraction] = {}
    for cls in classes:
        coords[cls] = sum((w[g] for g in cls), Fraction(0))
    return coords


def verify(G: FiniteGroup, name: str) -> None:
    n = G.order
    classes = G.conjugacy_classes()
    num_classes = len(classes)
    comm_rank = rank(commutator_generators(G))
    dim_HH0 = n - comm_rank  # = dim ker? no: dim HH0 = n - dim[ , ]

    print(f"=== {name} ===")
    print(f"  |G|                       = {n}")
    print(f"  # conjugacy classes       = {num_classes}")
    print(f"  dim [R[G], R[G]]          = {comm_rank}")
    print(f"  dim HH_0 = |G| - dim[ , ] = {dim_HH0}")
    # Theorem: dim HH_0(R[G]) = # conjugacy classes
    assert dim_HH0 == num_classes, "THEOREM VIOLATED"
    # Equivalently rank-nullity for toConj: surjective onto Q^{#classes}
    assert comm_rank == n - num_classes
    print(f"  THEOREM HOLDS: dim HH_0(R[G]) = #Conj(G) = {num_classes}  [OK]")
    # Show the class map on a sample element (sum of all basis elements).
    w = [Fraction(1)] * n
    coords = to_conj(G, w)
    print("  toConj(1_R[G]) coordinates (class size per class):")
    for cls in classes:
        rep = min(cls)
        print(f"      class of g={rep}: coeff = {coords[cls]} (|class| = {len(cls)})")
    print()


# ---------------------------------------------------------------------------
# Concrete groups.
# ---------------------------------------------------------------------------

def cyclic_group(nn: int) -> FiniteGroup:
    mul = [[(a + b) % nn for b in range(nn)] for a in range(nn)]
    return FiniteGroup(nn, mul, e=0)


def group_from_permutations(perms: list[tuple[int, ...]]) -> FiniteGroup:
    """Build a group from a closed set of permutations (as images tuples)."""
    index = {p: i for i, p in enumerate(perms)}

    def compose(p: tuple[int, ...], q: tuple[int, ...]) -> tuple[int, ...]:
        # (p*q)(i) = p(q(i))
        return tuple(p[q[i]] for i in range(len(p)))

    n = len(perms)
    mul = [[index[compose(perms[a], perms[b])] for b in range(n)] for a in range(n)]
    identity = tuple(range(len(perms[0])))
    return FiniteGroup(n, mul, e=index[identity])


def symmetric_group(k: int) -> FiniteGroup:
    from itertools import permutations
    perms = list(permutations(range(k)))
    return group_from_permutations(perms)


def quaternion_Q8() -> FiniteGroup:
    # Elements: 1,-1,i,-i,j,-j,k,-k indexed 0..7
    names = ["1", "-1", "i", "-i", "j", "-j", "k", "-k"]
    idx = {nm: m for m, nm in enumerate(names)}

    def neg(x: str) -> str:
        return x[1:] if x.startswith("-") else "-" + x

    base = {
        ("i", "i"): "-1", ("j", "j"): "-1", ("k", "k"): "-1",
        ("i", "j"): "k", ("j", "k"): "i", ("k", "i"): "j",
        ("j", "i"): "-k", ("k", "j"): "-i", ("i", "k"): "-j",
    }

    def mul_names(x: str, y: str) -> str:
        sx = x.startswith("-")
        sy = y.startswith("-")
        bx = x[1:] if sx else x
        by = y[1:] if sy else y
        sign = sx ^ sy
        if bx == "1":
            res = by
        elif by == "1":
            res = bx
        else:
            res = base[(bx, by)]
        if sign:
            res = neg(res)
        # normalize "--1" etc.
        while res.startswith("--"):
            res = res[2:]
        return res

    n = 8
    mul = [[idx[mul_names(names[a], names[b])] for b in range(n)] for a in range(n)]
    return FiniteGroup(n, mul, e=idx["1"])


def dihedral_D4() -> FiniteGroup:
    # D4 as symmetries of a square = subgroup of S_4 acting on 4 vertices.
    # rotations and reflections of the square 0-1-2-3.
    from itertools import product as iproduct
    rot = (1, 2, 3, 0)  # 90-degree rotation
    refl = (1, 0, 3, 2)  # a reflection

    def compose(p, q):
        return tuple(p[q[i]] for i in range(4))

    identity = (0, 1, 2, 3)
    elems = {identity}
    frontier = [identity]
    gens = [rot, refl]
    while frontier:
        x = frontier.pop()
        for g in gens:
            y = compose(g, x)
            if y not in elems:
                elems.add(y)
                frontier.append(y)
    return group_from_permutations(sorted(elems))


def main() -> None:
    print("Hochschild HH_0 of a group algebra = free module on conjugacy classes")
    print("Verified over R = Q by exact linear algebra.\n")
    verify(cyclic_group(6), "Cyclic group C_6 (abelian: every element its own class)")
    verify(symmetric_group(3), "Symmetric group S_3 (3 classes: e, transpositions, 3-cycles)")
    verify(quaternion_Q8(), "Quaternion group Q_8 (5 classes)")
    verify(dihedral_D4(), "Dihedral group D_4 (5 classes)")
    verify(symmetric_group(4), "Symmetric group S_4 (5 classes = #partitions of 4)")
    print("All groups verified: dim HH_0(R[G]) = number of conjugacy classes.")


if __name__ == "__main__":
    main()
