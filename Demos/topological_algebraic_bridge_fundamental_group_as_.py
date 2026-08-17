"""
Coverings of aspherical one-dimensional spaces: numerical demonstrations.
=========================================================================

Every connected covering of a space of type K(G,1) is classified by a subgroup
H <= G, up to conjugacy:

    connected coverings of K(G,1)  <-->  conjugacy classes of subgroups of G
    number of sheets               <-->  index [G:H]
    pi_1 of the total space        <-->  H
    deck transformation group      <-->  N_G(H)/H
    regular covering               <-->  H normal in G
    universal cover                <-->  H = 1
    double coverings               <-->  nonzero homomorphisms G -> Z/2

This script verifies the theory computationally on concrete examples:

  1. The Klein four group V = Z/2 x Z/2: exactly three double coverings, all
     with total space a K(Z/2,1) and all of degree two, yet pairwise
     non-isomorphic.  (The fundamental group is NOT a complete invariant of
     coverings.)
  2. The symmetric group S3: the two point stabilisers are distinct but
     conjugate, so they give *isomorphic* three-sheeted coverings; and that
     covering is non-regular with trivial deck group.
  3. Double coverings = nonzero mod-two characters, checked for several groups.
  4. The circle (pi_1 = Z): the number of sheets is a complete invariant.
  5. The torus (pi_1 = Z^2): exactly sigma(n) = sum_{d | n} d connected
     n-sheeted coverings, verified against brute-force enumeration of
     sublattices, and every total space is again a torus.
  6. Prime degree p over the torus: p^2 - 1 surjective characters, p - 1 per
     kernel, hence p + 1 coverings.

Run with:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# 1. Finite groups given by an explicit element set and multiplication
# ---------------------------------------------------------------------------

Elem = Tuple[int, ...]


class FiniteGroup:
    """A finite group given by its element list, product and inverse."""

    def __init__(
        self,
        name: str,
        elements: Sequence[Elem],
        mul: Callable[[Elem, Elem], Elem],
        inv: Callable[[Elem], Elem],
        identity: Elem,
    ) -> None:
        self.name = name
        self.elements: List[Elem] = list(elements)
        self.mul = mul
        self.inv = inv
        self.identity = identity

    @property
    def order(self) -> int:
        return len(self.elements)

    # -- subgroup machinery -------------------------------------------------

    def generated_by(self, gens: Sequence[Elem]) -> FrozenSet[Elem]:
        """Closure of `gens` under products and inverses."""
        closure = {self.identity}
        frontier = [self.identity]
        while frontier:
            x = frontier.pop()
            for g in list(gens) + [self.inv(g) for g in gens]:
                y = self.mul(x, g)
                if y not in closure:
                    closure.add(y)
                    frontier.append(y)
        return frozenset(closure)

    def subgroups(self) -> List[FrozenSet[Elem]]:
        """All subgroups, by closing every subset of generators incrementally."""
        found: Dict[FrozenSet[Elem], None] = {frozenset({self.identity}): None}
        changed = True
        while changed:
            changed = False
            for sub in list(found):
                for g in self.elements:
                    if g in sub:
                        continue
                    bigger = self.generated_by(list(sub) + [g])
                    if bigger not in found:
                        found[bigger] = None
                        changed = True
        return sorted(found, key=lambda s: (len(s), sorted(map(str, s))))

    def index(self, sub: FrozenSet[Elem]) -> int:
        return self.order // len(sub)

    def conjugate(self, sub: FrozenSet[Elem], g: Elem) -> FrozenSet[Elem]:
        gi = self.inv(g)
        return frozenset(self.mul(self.mul(g, h), gi) for h in sub)

    def is_normal(self, sub: FrozenSet[Elem]) -> bool:
        return all(self.conjugate(sub, g) == sub for g in self.elements)

    def normalizer(self, sub: FrozenSet[Elem]) -> FrozenSet[Elem]:
        return frozenset(g for g in self.elements if self.conjugate(sub, g) == sub)

    def conjugacy_classes_of_subgroups(self) -> List[List[FrozenSet[Elem]]]:
        classes: List[List[FrozenSet[Elem]]] = []
        seen: set = set()
        for sub in self.subgroups():
            if sub in seen:
                continue
            orbit = {self.conjugate(sub, g) for g in self.elements}
            seen |= orbit
            classes.append(sorted(orbit, key=lambda s: sorted(map(str, s))))
        return classes

    # -- covering-theoretic readings ---------------------------------------

    def deck_order(self, sub: FrozenSet[Elem]) -> int:
        """|N_G(H)/H| : the order of the deck transformation group."""
        return len(self.normalizer(sub)) // len(sub)

    def covering_report(self, sub: FrozenSet[Elem]) -> Dict[str, object]:
        return {
            "sheets": self.index(sub),
            "pi1_order": len(sub),
            "regular": self.is_normal(sub),
            "deck_order": self.deck_order(sub),
        }


def cyclic_group(n: int) -> FiniteGroup:
    return FiniteGroup(
        f"C{n}",
        [(i,) for i in range(n)],
        lambda a, b: ((a[0] + b[0]) % n,),
        lambda a: ((-a[0]) % n,),
        (0,),
    )


def direct_product(g: FiniteGroup, h: FiniteGroup) -> FiniteGroup:
    return FiniteGroup(
        f"{g.name} x {h.name}",
        [tuple(a) + tuple(b) for a in g.elements for b in h.elements],
        lambda a, b, k=len(g.identity): tuple(g.mul(a[:k], b[:k])) + tuple(h.mul(a[k:], b[k:])),
        lambda a, k=len(g.identity): tuple(g.inv(a[:k])) + tuple(h.inv(a[k:])),
        tuple(g.identity) + tuple(h.identity),
    )


def symmetric_group(n: int) -> FiniteGroup:
    """S_n as tuples: the permutation p sends i to p[i]."""
    perms = [tuple(p) for p in _permutations(list(range(n)))]

    def mul(a: Elem, b: Elem) -> Elem:
        return tuple(a[b[i]] for i in range(n))

    def inv(a: Elem) -> Elem:
        out = [0] * n
        for i, v in enumerate(a):
            out[v] = i
        return tuple(out)

    return FiniteGroup(f"S{n}", perms, mul, inv, tuple(range(n)))


def _permutations(xs: List[int]) -> List[List[int]]:
    if not xs:
        return [[]]
    out: List[List[int]] = []
    for i, x in enumerate(xs):
        for rest in _permutations(xs[:i] + xs[i + 1 :]):
            out.append([x] + rest)
    return out


def quaternion_group() -> FiniteGroup:
    """Q8 = {+-1, +-i, +-j, +-k}, encoded as (sign, unit) with unit in 0..3."""
    names = ["1", "i", "j", "k"]
    table = {
        (0, 0): (1, 0), (0, 1): (1, 1), (0, 2): (1, 2), (0, 3): (1, 3),
        (1, 0): (1, 1), (1, 1): (-1, 0), (1, 2): (1, 3), (1, 3): (-1, 2),
        (2, 0): (1, 2), (2, 1): (-1, 3), (2, 2): (-1, 0), (2, 3): (1, 1),
        (3, 0): (1, 3), (3, 1): (1, 2), (3, 2): (-1, 1), (3, 3): (-1, 0),
    }
    elements = [(s, u) for s in (1, -1) for u in range(4)]

    def mul(a: Elem, b: Elem) -> Elem:
        sign, unit = table[(a[1], b[1])]
        return (a[0] * b[0] * sign, unit)

    def inv(a: Elem) -> Elem:
        for b in elements:
            if mul(a, b) == (1, 0):
                return b
        raise RuntimeError("no inverse")

    del names
    return FiniteGroup("Q8", elements, mul, inv, (1, 0))


# ---------------------------------------------------------------------------
# 2. Example 1 -- the Klein four group: three double coverings
# ---------------------------------------------------------------------------

def demo_klein() -> None:
    print("=" * 74)
    print("1.  K(V,1) for V = Z/2 x Z/2 : three double coverings")
    print("=" * 74)
    v = direct_product(cyclic_group(2), cyclic_group(2))
    doubles = [s for s in v.subgroups() if v.index(s) == 2]
    print(f"  index-two subgroups of V : {len(doubles)}")
    for sub in doubles:
        report = v.covering_report(sub)
        print(f"    H = {sorted(sub)}  ->  {report}")
    assert len(doubles) == 3
    # all of them are isomorphic as abstract groups (each of order 2 = C2)
    assert all(len(s) == 2 for s in doubles)
    # and pairwise non-conjugate, because V is abelian: conjugacy = equality
    classes = [c for c in v.conjugacy_classes_of_subgroups() if v.index(c[0]) == 2]
    assert all(len(c) == 1 for c in classes) and len(classes) == 3
    print("  -> three coverings, all with total space a K(Z/2,1), all of degree 2,")
    print("     pairwise NON-isomorphic: pi_1 does not classify coverings.")
    print()


# ---------------------------------------------------------------------------
# 3. Example 2 -- S3: conjugate stabilisers, and a non-regular covering
# ---------------------------------------------------------------------------

def demo_s3() -> None:
    print("=" * 74)
    print("2.  K(S3,1) : distinct subgroups can give the SAME covering")
    print("=" * 74)
    s3 = symmetric_group(3)
    stab0 = frozenset(p for p in s3.elements if p[0] == 0)
    stab1 = frozenset(p for p in s3.elements if p[1] == 1)
    print(f"  Stab(0) = {sorted(stab0)}")
    print(f"  Stab(1) = {sorted(stab1)}")
    assert stab0 != stab1
    tau = (1, 0, 2)  # the transposition (0 1)
    assert s3.conjugate(stab0, tau) == stab1
    print("  distinct subgroups, but conjugate by the transposition (0 1)")
    print("  -> the two three-sheeted coverings ARE isomorphic.")
    print()
    print(f"  Stab(0) normal?        {s3.is_normal(stab0)}")
    print(f"  normaliser of Stab(0): {sorted(s3.normalizer(stab0))}")
    print(f"  deck group order:      {s3.deck_order(stab0)}")
    assert not s3.is_normal(stab0)
    assert s3.normalizer(stab0) == stab0
    assert s3.deck_order(stab0) == 1
    print("  -> a three-sheeted covering with a TRIVIAL deck group: non-regular.")
    print("     Consistent with the theorem that a non-normal subgroup of prime")
    print("     index p forces a prime factor of |G| below p:  minFac(6) = 2 < 3.")
    print()


# ---------------------------------------------------------------------------
# 4. Example 3 -- double coverings are nonzero mod-two characters
# ---------------------------------------------------------------------------

def mod_two_characters(g: FiniteGroup) -> List[Dict[Elem, int]]:
    """All homomorphisms G -> Z/2, as dictionaries with values in {0,1}."""
    out: List[Dict[Elem, int]] = []
    n = g.order
    for bits in product((0, 1), repeat=n):
        chi = {e: b for e, b in zip(g.elements, bits)}
        if chi[g.identity] != 0:
            continue
        if all((chi[g.mul(a, b)] == (chi[a] + chi[b]) % 2) for a in g.elements for b in g.elements):
            out.append(chi)
    return out


def demo_characters() -> None:
    print("=" * 74)
    print("3.  Double coverings  =  nonzero classes of H^1(G; F_2) = Hom(G, Z/2)")
    print("=" * 74)
    groups = [
        cyclic_group(2),
        cyclic_group(3),
        cyclic_group(4),
        direct_product(cyclic_group(2), cyclic_group(2)),
        symmetric_group(3),
        quaternion_group(),
    ]
    print(f"  {'group':>12} | {'|Hom(G,Z/2)|-1':>15} | {'index-2 subgroups':>18}")
    print("  " + "-" * 52)
    for g in groups:
        chars = mod_two_characters(g)
        nontrivial = [c for c in chars if any(v == 1 for v in c.values())]
        kernels = {frozenset(e for e in g.elements if c[e] == 0) for c in nontrivial}
        subs = [s for s in g.subgroups() if g.index(s) == 2]
        print(f"  {g.name:>12} | {len(nontrivial):>15} | {len(subs):>18}")
        assert len(nontrivial) == len(subs)      # the bijection chi <-> ker chi
        assert kernels == set(subs)              # and it really is "take the kernel"
    print("  -> the bijection  {nonzero mod-2 characters} <-> {index-2 subgroups}")
    print("     holds in every case; a character is determined by its kernel.")
    print()


# ---------------------------------------------------------------------------
# 5. Example 4 -- the circle: degree is a complete invariant
# ---------------------------------------------------------------------------

def demo_circle(max_degree: int = 8) -> None:
    print("=" * 74)
    print("4.  Coverings of the circle (pi_1 = Z): degree classifies")
    print("=" * 74)
    print("  subgroups of Z of index n are exactly nZ, one for each n:")
    for n in range(1, max_degree + 1):
        subgroup = f"{n}Z"
        print(f"    degree {n}: {subgroup:>4}   (the n-fold wrap  z -> z^n)")
    print("    degree infinity: 0    (the universal cover R -> S^1)")
    counts = {n: 1 for n in range(1, max_degree + 1)}
    assert all(c == 1 for c in counts.values())
    print("  -> exactly ONE connected covering of each degree: the number of")
    print("     sheets is a complete invariant for the circle.")
    print()


# ---------------------------------------------------------------------------
# 6. Example 5 -- the torus: sigma(n) coverings, all of them tori
# ---------------------------------------------------------------------------

Lattice = Tuple[int, int, int]  # Hermite normal form (a, c, d): span of (a,0),(c,d)


def divisors(n: int) -> List[int]:
    return [d for d in range(1, n + 1) if n % d == 0]


def sigma(n: int) -> int:
    """Sum-of-divisors function sigma(n) = sum_{d | n} d."""
    return sum(divisors(n))


def hnf_sublattices(n: int) -> List[Lattice]:
    """All index-n sublattices of Z^2, in Hermite normal form (a, c, d), ad = n."""
    return [(a, c, n // a) for a in divisors(n) for c in range(a)]


def lattice_members(lat: Lattice, bound: int) -> FrozenSet[Tuple[int, int]]:
    """The points of the sublattice inside [-bound, bound]^2, for cross-checking."""
    a, c, d = lat
    pts = set()
    span = 2 * bound + 2
    for i in range(-span, span + 1):
        for j in range(-span, span + 1):
            x, y = i * a + j * c, j * d
            if -bound <= x <= bound and -bound <= y <= bound:
                pts.add((x, y))
    return frozenset(pts)


def brute_force_index_n_sublattices(n: int, bound: int = 12) -> int:
    """
    Independent count: a sublattice of index n contains n*Z^2, so it is the
    preimage of a subgroup of order n in (Z/n)^2.  Enumerate those directly.
    """
    ambient = [(x, y) for x in range(n) for y in range(n)]

    def closure(gens: Sequence[Tuple[int, int]]) -> FrozenSet[Tuple[int, int]]:
        pts = {(0, 0)}
        frontier = [(0, 0)]
        while frontier:
            p = frontier.pop()
            for g in gens:
                q = ((p[0] + g[0]) % n, (p[1] + g[1]) % n)
                if q not in pts:
                    pts.add(q)
                    frontier.append(q)
        return frozenset(pts)

    subgroups = {frozenset({(0, 0)})}
    changed = True
    while changed:
        changed = False
        for s in list(subgroups):
            for g in ambient:
                if g in s:
                    continue
                bigger = closure(list(s) + [g])
                if bigger not in subgroups:
                    subgroups.add(bigger)
                    changed = True
    del bound
    return sum(1 for s in subgroups if len(s) == n)


def demo_torus(max_degree: int = 8) -> None:
    print("=" * 74)
    print("5.  Coverings of the torus (pi_1 = Z^2): exactly sigma(n) of degree n")
    print("=" * 74)
    print(f"  {'n':>3} | {'sigma(n)':>9} | {'HNF count':>10} | {'brute force':>12}")
    print("  " + "-" * 44)
    for n in range(1, max_degree + 1):
        lattices = hnf_sublattices(n)
        hnf_count = len(lattices)
        brute = brute_force_index_n_sublattices(n)
        print(f"  {n:>3} | {sigma(n):>9} | {hnf_count:>10} | {brute:>12}")
        assert hnf_count == sigma(n) == brute
        # each lattice really has index a*d = n, and distinct normal forms are
        # distinct subgroups
        assert all(a * d == n for (a, _c, d) in lattices)
        assert len({lattice_members(l, 6) for l in lattices}) == hnf_count
    print()
    print("  the three double coverings of the torus, in normal form (a, c, d):")
    for (a, c, d) in hnf_sublattices(2):
        print(f"    span{{({a},0), ({c},{d})}}   index {a * d}   determinant {a * d}")
    print("  every one of these sublattices is free of rank two, i.e. isomorphic")
    print("  to Z^2: every finite covering of the torus is again a torus.")
    print("  -> sigma(n) genuinely different coverings, ALL with the same total")
    print("     space.  The total space carries no information whatsoever.")
    print()


# ---------------------------------------------------------------------------
# 7. Example 6 -- prime degree over the torus: p^2 - 1 characters, p + 1 kernels
# ---------------------------------------------------------------------------

def demo_prime_degree(primes: Sequence[int] = (2, 3, 5, 7)) -> None:
    print("=" * 74)
    print("6.  Prime degree p over the torus:  (p^2 - 1)/(p - 1) = p + 1")
    print("=" * 74)
    print(f"  {'p':>3} | {'surjective chars':>17} | {'per kernel':>11} | {'kernels':>8} | {'p+1':>4}")
    print("  " + "-" * 56)
    for p in primes:
        chars = [(a, b) for a in range(p) for b in range(p) if (a, b) != (0, 0)]
        # the kernel of chi_{a,b}(x,y) = a x + b y mod p, as a subset of (Z/p)^2
        kernels = {}
        for (a, b) in chars:
            ker = frozenset((x, y) for x in range(p) for y in range(p)
                            if (a * x + b * y) % p == 0)
            kernels.setdefault(ker, []).append((a, b))
        sizes = {len(v) for v in kernels.values()}
        assert sizes == {p - 1}, sizes
        assert len(chars) == p * p - 1
        assert len(kernels) == p + 1
        print(f"  {p:>3} | {len(chars):>17} | {p - 1:>11} | {len(kernels):>8} | {p + 1:>4}")
    print("  -> exactly p - 1 surjective characters share each kernel, because")
    print("     |Aut(C_p)| = p - 1.  At p = 2 this degenerates to 1, which is why")
    print("     a mod-two character is determined by its kernel.")
    print()


# ---------------------------------------------------------------------------
# 8. Example 7 -- a full covering census of a finite group
# ---------------------------------------------------------------------------

def demo_census(g: FiniteGroup) -> None:
    print("=" * 74)
    print(f"7.  Complete census of the connected coverings of K({g.name},1)")
    print("=" * 74)
    classes = g.conjugacy_classes_of_subgroups()
    print(f"  {'sheets':>7} | {'|pi_1(cover)|':>13} | {'regular':>8} | {'|deck|':>7} | {'class size':>10}")
    print("  " + "-" * 60)
    for cls in sorted(classes, key=lambda c: g.index(c[0])):
        rep = cls[0]
        r = g.covering_report(rep)
        print(f"  {r['sheets']:>7} | {r['pi1_order']:>13} | {str(r['regular']):>8} |"
              f" {r['deck_order']:>7} | {len(cls):>10}")
    total = len(classes)
    print(f"  -> {total} isomorphism classes of connected coverings in total.")
    print("     (Conjugacy classes of size > 1 are exactly the places where")
    print("      distinct subgroups give the same covering.)")
    print()


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("Coverings of K(G,1) spaces: the fundamental group, and what it forgets")
    print()
    demo_klein()
    demo_s3()
    demo_characters()
    demo_circle()
    demo_torus()
    demo_prime_degree()
    demo_census(symmetric_group(3))
    demo_census(quaternion_group())
    print("All assertions passed.")


if __name__ == "__main__":
    main()
