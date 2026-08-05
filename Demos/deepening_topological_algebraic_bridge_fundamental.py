"""
Symmetries of aspherical spaces: a numerical demonstration.
===========================================================

A homotopy 1-type is a space whose higher homotopy groups all vanish.  A
connected one with fundamental group G is an Eilenberg-MacLane space K(G,1).
The theory demonstrated here says:

    hAut(K(G,1))              = Out(G) = Aut(G)/Inn(G)     (symmetry group)
    Aut(id_{K(G,1)})          = Z(G)                       (higher symmetries)
    [K(G,1), K(G,1)]          = End(G)/conjugation         (all self-maps)

and, for a disjoint union of connected pieces C_1, ..., C_n,

    1 -> prod_i Out(pi_1 C_i) -> hAut(| |_i C_i) -> Sym'(pi_0) -> 1

is exact, where Sym'(pi_0) is the group of permutations of the components
that preserve homotopy type.  Grouping the components into homotopy types
with multiplicities m_1, ..., m_r therefore gives the counting formula

    #hAut = (prod_i #Out(pi_1 C_i)) * prod_k m_k! .

This script computes all of these numbers from scratch for finite groups
(given by explicit multiplication tables) and checks them against the
theorems, including the "totient theorem"

    #hAut(K(Z/n,1)) = phi(n).

Run with:  python3 demo.py
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import permutations, product
from math import factorial, gcd
from typing import Dict, List, Optional, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1.  Finite groups by multiplication table
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class FiniteGroup:
    """A finite group on the carrier {0, ..., n-1} with 0 as the identity.

    ``table[a][b]`` is the product a * b.
    """

    name: str
    table: Tuple[Tuple[int, ...], ...]

    @property
    def order(self) -> int:
        return len(self.table)

    def mul(self, a: int, b: int) -> int:
        return self.table[a][b]

    def inv(self, a: int) -> int:
        for b in range(self.order):
            if self.mul(a, b) == 0:
                return b
        raise ValueError(f"element {a} has no inverse in {self.name}")

    def element_order(self, a: int) -> int:
        k, x = 1, a
        while x != 0:
            x = self.mul(x, a)
            k += 1
        return k

    def is_abelian(self) -> bool:
        return all(
            self.mul(a, b) == self.mul(b, a)
            for a in range(self.order)
            for b in range(self.order)
        )


def cyclic_group(n: int) -> FiniteGroup:
    """The cyclic group Z/n, i.e. pi_1 of the infinite lens space K(Z/n,1)."""
    table = tuple(tuple((a + b) % n for b in range(n)) for a in range(n))
    return FiniteGroup(f"Z/{n}", table)


def direct_product(g: FiniteGroup, h: FiniteGroup, name: Optional[str] = None) -> FiniteGroup:
    """The direct product G x H, elements encoded as a * |H| + b."""
    m = h.order
    size = g.order * m

    def enc(a: int, b: int) -> int:
        return a * m + b

    table = tuple(
        tuple(
            enc(g.mul(x // m, y // m), h.mul(x % m, y % m))
            for y in range(size)
        )
        for x in range(size)
    )
    return FiniteGroup(name or f"{g.name} x {h.name}", table)


def symmetric_group(n: int) -> FiniteGroup:
    """The symmetric group S_n, elements enumerated in lexicographic order."""
    perms: List[Tuple[int, ...]] = sorted(permutations(range(n)))
    # put the identity first
    perms.remove(tuple(range(n)))
    perms.insert(0, tuple(range(n)))
    index = {p: i for i, p in enumerate(perms)}

    def compose(p: Tuple[int, ...], q: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple(p[q[i]] for i in range(n))

    table = tuple(tuple(index[compose(p, q)] for q in perms) for p in perms)
    return FiniteGroup(f"S_{n}", table)


def dihedral_group(n: int) -> FiniteGroup:
    """The dihedral group of order 2n, elements (r^i s^j) encoded as 2i + j."""
    size = 2 * n

    def enc(i: int, j: int) -> int:
        return 2 * (i % n) + (j % 2)

    def mul(x: int, y: int) -> int:
        i, j = divmod(x, 2)
        k, l = divmod(y, 2)
        # (r^i s^j)(r^k s^l) = r^{i + (-1)^j k} s^{j+l}
        return enc(i + (k if j == 0 else -k), j + l)

    table = tuple(tuple(mul(x, y) for y in range(size)) for x in range(size))
    return FiniteGroup(f"D_{n}", table)


def quaternion_group() -> FiniteGroup:
    """The quaternion group Q_8 = {1, -1, i, -i, j, -j, k, -k}."""
    labels = ["1", "-1", "i", "-i", "j", "-j", "k", "-k"]
    idx = {name: i for i, name in enumerate(labels)}
    base = {
        ("i", "i"): "-1", ("j", "j"): "-1", ("k", "k"): "-1",
        ("i", "j"): "k", ("j", "k"): "i", ("k", "i"): "j",
        ("j", "i"): "-k", ("k", "j"): "-i", ("i", "k"): "-j",
    }

    def neg(s: str) -> str:
        return s[1:] if s.startswith("-") else "-" + s

    def mul_lab(a: str, b: str) -> str:
        sign = 1
        if a.startswith("-"):
            a, sign = a[1:], -sign
        if b.startswith("-"):
            b, sign = b[1:], -sign
        if a == "1":
            prod = b
        elif b == "1":
            prod = a
        else:
            prod = base[(a, b)]
        if prod.startswith("-"):
            prod, sign = prod[1:], -sign
        return prod if sign == 1 else neg(prod)

    table = tuple(
        tuple(idx[mul_lab(a, b)] for b in labels) for a in labels
    )
    return FiniteGroup("Q_8", table)


# ---------------------------------------------------------------------------
# 2.  Algorithm A: Aut, Inn, Out and the centre of a finite group
# ---------------------------------------------------------------------------


def generating_set(g: FiniteGroup) -> List[int]:
    """A small generating set, found greedily."""
    gens: List[int] = []
    generated = {0}
    for a in range(1, g.order):
        if a in generated:
            continue
        gens.append(a)
        # close up
        frontier = set(generated) | {a}
        while True:
            new = {g.mul(x, y) for x in frontier for y in frontier} | frontier
            if new == frontier:
                break
            frontier = new
        generated = frontier
        if len(generated) == g.order:
            break
    return gens


def _extend_by_generators(g: FiniteGroup, gens: Sequence[int],
                          images: Sequence[int]) -> Optional[List[int]]:
    """Try to extend gens |-> images to an endomorphism; None if inconsistent."""
    phi: Dict[int, int] = {0: 0}
    for gen, img in zip(gens, images):
        phi[gen] = img
    changed = True
    while changed:
        changed = False
        known = list(phi.items())
        for a, fa in known:
            for b, fb in known:
                ab = g.mul(a, b)
                fab = g.mul(fa, fb)
                if ab in phi:
                    if phi[ab] != fab:
                        return None
                else:
                    phi[ab] = fab
                    changed = True
    if len(phi) != g.order:
        return None
    return [phi[a] for a in range(g.order)]


def automorphisms(g: FiniteGroup) -> List[Tuple[int, ...]]:
    """All automorphisms of G, as tuples phi with phi[a] = image of a.

    Generators are mapped to elements of the same order (a necessary
    condition), then the assignment is closed up multiplicatively; the
    resulting map is kept when it is a well-defined bijective homomorphism.
    """
    gens = generating_set(g)
    orders = [g.element_order(a) for a in range(g.order)]
    candidates = [
        [b for b in range(g.order) if orders[b] == orders[gen]] for gen in gens
    ]
    out: List[Tuple[int, ...]] = []
    for images in product(*candidates):
        phi = _extend_by_generators(g, gens, images)
        if phi is None:
            continue
        if len(set(phi)) != g.order:
            continue
        if all(
            phi[g.mul(a, b)] == g.mul(phi[a], phi[b])
            for a in range(g.order)
            for b in range(g.order)
        ):
            out.append(tuple(phi))
    return out


def centre(g: FiniteGroup) -> List[int]:
    return [
        z for z in range(g.order)
        if all(g.mul(z, a) == g.mul(a, z) for a in range(g.order))
    ]


def inner_automorphism_count(g: FiniteGroup) -> int:
    """|Inn(G)| = |G| / |Z(G)|, by the first isomorphism theorem."""
    return g.order // len(centre(g))


def out_order(g: FiniteGroup) -> int:
    """|Out(G)| = |Aut(G)| / |Inn(G)| -- the number of symmetries of K(G,1)."""
    return len(automorphisms(g)) // inner_automorphism_count(g)


def endomorphism_classes(g: FiniteGroup) -> int:
    """Number of conjugacy classes of endomorphisms = #[K(G,1), K(G,1)]."""
    endos = set()
    gens = generating_set(g)
    for images in product(range(g.order), repeat=len(gens)):
        phi = _extend_by_generators(g, gens, images)
        if phi is None:
            continue
        if all(
            phi[g.mul(a, b)] == g.mul(phi[a], phi[b])
            for a in range(g.order)
            for b in range(g.order)
        ):
            endos.add(tuple(phi))
    # quotient by conjugation phi ~ c_a . phi
    seen: set = set()
    classes = 0
    for phi in endos:
        if phi in seen:
            continue
        classes += 1
        for a in range(g.order):
            ainv = g.inv(a)
            conj = tuple(g.mul(g.mul(a, phi[x]), ainv) for x in range(g.order))
            seen.add(conj)
    return classes


# ---------------------------------------------------------------------------
# 3.  Algorithm B: symmetries of a disjoint union of aspherical components
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Component:
    """One connected piece of a 1-type, described by its fundamental group.

    ``out`` is |Out(pi_1)| and ``centre_order`` is |Z(pi_1)|; ``None`` means
    the corresponding group is infinite.  ``iso_key`` labels the isomorphism
    type of pi_1, which by the complete-invariance theorem is exactly the
    homotopy type of the component.
    """

    label: str
    iso_key: str
    out: Optional[int]
    centre_order: Optional[int]


def component_of(g: FiniteGroup, label: Optional[str] = None) -> Component:
    return Component(
        label=label or f"K({g.name},1)",
        iso_key=g.name,
        out=out_order(g),
        centre_order=len(centre(g)),
    )


def haut_order(components: Sequence[Component]) -> Tuple[Optional[int], int, Optional[int]]:
    """Return (|hAut|, |Sym'(pi_0)|, |Aut(identity)|) for a disjoint union.

    ``None`` is returned for an infinite value.  The formula is
        |hAut| = (prod_i |Out(pi_1 C_i)|) * prod_k m_k!
    where m_k are the multiplicities of the homotopy types among components.
    """
    multiplicities: Dict[str, int] = {}
    for c in components:
        multiplicities[c.iso_key] = multiplicities.get(c.iso_key, 0) + 1
    sym_prime = 1
    for m in multiplicities.values():
        sym_prime *= factorial(m)

    internal: Optional[int] = 1
    for c in components:
        if c.out is None or internal is None:
            internal = None
        else:
            internal *= c.out

    higher: Optional[int] = 1
    for c in components:
        if c.centre_order is None or higher is None:
            higher = None
        else:
            higher *= c.centre_order

    total = None if internal is None else internal * sym_prime
    return total, sym_prime, higher


# ---------------------------------------------------------------------------
# 4.  Number theory: Euler's totient, for the totient theorem
# ---------------------------------------------------------------------------


def euler_totient(n: int) -> int:
    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


# ---------------------------------------------------------------------------
# 5.  The circle: the degree monoid
# ---------------------------------------------------------------------------


def circle_degree_compose(d: int, e: int) -> int:
    """Composing self-maps of the circle multiplies degrees."""
    return d * e


def circle_is_equivalence(d: int) -> bool:
    """A self-map of the circle is a homotopy equivalence iff its degree is +-1."""
    return d in (1, -1)


# ---------------------------------------------------------------------------
# 6.  Demonstrations
# ---------------------------------------------------------------------------


def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_totient_theorem(nmax: int = 24) -> None:
    rule("1.  The totient theorem:  #hAut(K(Z/n,1)) = phi(n)")
    print(f"{'n':>3} | {'|Aut(Z/n)|':>10} | {'|Inn|':>5} | {'|Out| = #hAut':>13} | {'phi(n)':>6} | ok")
    print("-" * 74)
    for n in range(1, nmax + 1):
        g = cyclic_group(n)
        a = len(automorphisms(g))
        i = inner_automorphism_count(g)
        o = a // i
        phi = euler_totient(n)
        assert o == phi, (n, o, phi)
        print(f"{n:>3} | {a:>10} | {i:>5} | {o:>13} | {phi:>6} | {'yes'}")
    print("\nRigid cases (only the identity):  n = 1, 2.")
    print("Prime case: #hAut(K(Z/p,1)) = p - 1, e.g. p = 5 gives 4, p = 13 gives 12.")
    for p in (2, 3, 5, 7, 11, 13):
        assert out_order(cyclic_group(p)) == p - 1
    print("Verified for p in {2, 3, 5, 7, 11, 13}.")


def demo_connected_examples() -> None:
    rule("2.  Symmetry groups of connected aspherical spaces")
    groups = [
        (cyclic_group(1), "a point"),
        (cyclic_group(2), "K(Z/2,1), infinite real projective space"),
        (cyclic_group(6), "K(Z/6,1)"),
        (direct_product(cyclic_group(2), cyclic_group(2), "V"), "K(V,1), V the Klein four group"),
        (symmetric_group(3), "K(S_3,1)"),
        (dihedral_group(4), "K(D_4,1)"),
        (quaternion_group(), "K(Q_8,1)"),
        (symmetric_group(4), "K(S_4,1)"),
    ]
    header = f"{'group':>8} | {'|G|':>4} | {'|Z(G)|':>6} | {'|Aut|':>6} | {'|Inn|':>5} | {'#hAut = |Out|':>13} | space"
    print(header)
    print("-" * len(header))
    for g, descr in groups:
        z = len(centre(g))
        a = len(automorphisms(g))
        i = inner_automorphism_count(g)
        print(f"{g.name:>8} | {g.order:>4} | {z:>6} | {a:>6} | {i:>5} | {a // i:>13} | {descr}")

    print("\nHighlights:")
    s3 = symmetric_group(3)
    print(f"  K(S_3,1) is homotopy rigid: |Out(S_3)| = {out_order(s3)} and "
          f"|Z(S_3)| = {len(centre(s3))}, so the identity is its only")
    print("  self-homotopy-equivalence, and it has no nontrivial self-homotopy.")
    v = direct_product(cyclic_group(2), cyclic_group(2), "V")
    autv = automorphisms(v)
    nonabelian = any(
        tuple(p[q[x]] for x in range(v.order)) != tuple(q[p[x]] for x in range(v.order))
        for p in autv for q in autv
    )
    print(f"  K(V,1) has |hAut| = {out_order(v)}; hAut is nonabelian: {nonabelian}")
    print("  (an abelian fundamental group can have a nonabelian symmetry group).")
    q8 = quaternion_group()
    print(f"  K(Q_8,1) has |hAut| = {out_order(q8)} and higher symmetry group of order "
          f"{len(centre(q8))}.")


def demo_selfmap_monoid() -> None:
    rule("3.  All self-maps, not only the equivalences:  [X,X] = End(pi_1)/conj")
    print(f"{'group':>8} | {'#[X,X]':>7} | {'#hAut':>6} | comment")
    print("-" * 74)
    for g in [cyclic_group(2), cyclic_group(4), cyclic_group(6),
              direct_product(cyclic_group(2), cyclic_group(2), "V"),
              symmetric_group(3)]:
        print(f"{g.name:>8} | {endomorphism_classes(g):>7} | {out_order(g):>6} | "
              f"{'invertible classes = equivalences'}")
    print("\nFor the circle the monoid is infinite: [S^1,S^1] = (Z, x) via the degree.")
    print("  deg(f o g) = deg(f) * deg(g):",
          circle_degree_compose(3, -5), "= 3 * (-5)")
    print("  equivalences are exactly the degrees +-1:",
          [d for d in range(-3, 4) if circle_is_equivalence(d)])
    print("  hence #hAut(S^1) = 2 and hAut(S^1) = Z/2.")
    print("  For the n-torus, hAut(T^n) = GL_n(Z); for n = 1 this is {+1,-1}.")


def demo_disjoint_unions() -> None:
    rule("4.  Disconnected 1-types:  1 -> prod Out -> hAut -> Sym'(pi_0) -> 1")

    circle = Component("K(Z,1) (the circle)", "Z", out=2, centre_order=None)
    lens3 = component_of(cyclic_group(3), "K(Z/3,1)")
    lens5 = component_of(cyclic_group(5), "K(Z/5,1)")
    s3 = component_of(symmetric_group(3), "K(S_3,1)")
    klein = component_of(direct_product(cyclic_group(2), cyclic_group(2), "V"), "K(V,1)")

    experiments: List[Tuple[str, List[Component], Optional[int]]] = [
        ("K(Z,1) | | K(Z/3,1)  (different homotopy types)", [circle, lens3], 4),
        ("three copies of K(S_3,1)  (rigid pieces, interchangeable)", [s3, s3, s3], 6),
        ("two copies of K(V,1)", [klein, klein], 72),
        ("K(Z,1) | | K(Z,1)  (two circles)", [circle, circle], 8),
        ("K(Z/3,1) | | K(Z/5,1) | | K(Z/5,1)", [lens3, lens5, lens5], None),
        ("K(Z,1) | | K(Z/3,1) | | K(S_3,1)", [circle, lens3, s3], None),
    ]

    for name, comps, expected in experiments:
        total, symp, higher = haut_order(comps)
        pieces = " * ".join(str(c.out) for c in comps)
        print(f"\n  {name}")
        print(f"    components:            {[c.label for c in comps]}")
        print(f"    prod |Out(pi_1 C_i)| = {pieces} = "
              f"{'infinite' if any(c.out is None for c in comps) else eval_product(comps)}")
        print(f"    |Sym'(pi_0)|         = {symp}")
        print(f"    #hAut                = {total if total is not None else 'infinite'}")
        print(f"    self-homotopies of the identity: order "
              f"{higher if higher is not None else 'infinite'}")
        if expected is not None:
            assert total == expected, (name, total, expected)
            print(f"    matches the theorem's value {expected}: yes")

    print("\n  Note the two extremes:")
    print("   * K(Z,1) | | K(Z/3,1): the pieces have different homotopy types "
          "(Z is infinite,")
    print("     Z/3 is not), so Sym' is trivial and #hAut = 2 * 2 = 4.")
    print("   * three copies of K(S_3,1): the pieces are rigid but interchangeable, "
          "so all")
    print("     6 = 3! symmetries are relabellings.")


def eval_product(comps: Sequence[Component]) -> int:
    p = 1
    for c in comps:
        assert c.out is not None
        p *= c.out
    return p


def demo_wreath_growth() -> None:
    rule("5.  Constant families: the wreath product Out(G) wr Sym(n)")
    print("For n copies of K(G,1), every permutation of the copies is realised, and")
    print("  #hAut = |Out(G)|^n * n! .")
    print(f"\n{'n':>3} | {'K(Z/5,1)':>12} | {'K(V,1)':>12} | {'K(S_3,1)':>12}")
    print("-" * 50)
    o5 = out_order(cyclic_group(5))
    ov = out_order(direct_product(cyclic_group(2), cyclic_group(2), "V"))
    os3 = out_order(symmetric_group(3))
    for n in range(1, 7):
        print(f"{n:>3} | {o5 ** n * factorial(n):>12} | {ov ** n * factorial(n):>12} | "
              f"{os3 ** n * factorial(n):>12}")
    # cross-check with the general counting routine
    klein = component_of(direct_product(cyclic_group(2), cyclic_group(2), "V"))
    total, _, _ = haut_order([klein] * 3)
    assert total == ov ** 3 * factorial(3)
    print("\nCross-checked against the general counting formula for 3 copies of K(V,1):",
          total)


def demo_matrix_normal_form() -> None:
    rule("6.  Matrix normal form of a self-map of a disjoint union")
    print("A self-map of | |_i C_i is a pair <sigma, P>: an index map sigma and, for")
    print("each i, a homotopy class of maps C_i -> C_{sigma(i)}.  Composition is")
    print("  <sigma,P> . <tau,Q> = <sigma o tau, i |-> Q_i then P_{tau(i)}>.")
    print("For copies of the circle the entries are integers (degrees), so a self-map")
    print("of a disjoint union of n circles is an integer matrix with one entry per")
    print("column, and composition is matrix multiplication.\n")

    # Two circles: sigma swaps them, degrees 2 and -3.
    sigma = {0: 1, 1: 0}
    degrees = {0: 2, 1: -3}
    tau = {0: 1, 1: 0}
    deg2 = {0: 5, 1: 1}
    comp_sigma = {i: sigma[tau[i]] for i in (0, 1)}
    comp_deg = {i: degrees[tau[i]] * deg2[i] for i in (0, 1)}
    print(f"  f = <sigma={sigma}, degrees={degrees}>")
    print(f"  g = <tau={tau},   degrees={deg2}>")
    print(f"  f o g = <{comp_sigma}, degrees={comp_deg}>")
    print("  f is an equivalence iff sigma is a bijection and each degree is +-1:",
          all(circle_is_equivalence(d) for d in degrees.values()))
    print("  the identity-permutation self-equivalences of two circles number 2*2 = 4,")
    print("  and with the swap the total is 4*2 = 8, as computed above.")


def main() -> None:
    print(__doc__)
    demo_totient_theorem()
    demo_connected_examples()
    demo_selfmap_monoid()
    demo_disjoint_unions()
    demo_wreath_growth()
    demo_matrix_normal_form()
    rule("All assertions passed.")


if __name__ == "__main__":
    main()
