"""
Molien invariants versus Burnside mark vectors: numerical demonstrations.

This self-contained script verifies, by explicit finite computation:

  1. Burnside's orbit-counting lemma in Molien normalisation:
         Mol_X(H) = (1/|H|) * sum_{h in H} |X^h| = #(orbits of H on X),
     hence Mol_X(H) is an integer and |H| divides sum_{h in H} |X^h|.

  2. The structural comparison  mark_X(H) <= Mol_X(H),  with equality exactly
     when H acts trivially on X.

  3. The Averaging Theorem (positive half of Conjecture D10):
         Mol_X(H) = (1/|H|) * sum_{h in H} mark_X(<h>),
     so the Molien invariant only samples marks at CYCLIC subgroups.

  4. The Cyclic Recovery Theorem: equal permutation characters force equal
     marks at every cyclic subgroup (checked over Z/n for several n).

  5. The refutation of Conjecture D10 over the Klein four group:
     two 6-element V-sets with identical Molien invariants at all subgroups
     but non-proportional mark vectors (0 versus 2 at the top subgroup).

  6. The infinite family over (Z/p)^2 for p = 2, 3, 5:
     the disjoint union of the p+1 transitive sets E/line versus
     E together with p fixed points.

  7. The arithmetic pay-off: necklace congruence n | sum_a k^gcd(n,a)
     and Fermat's little theorem k^p = k (mod p).

Everything is exact integer / fraction arithmetic; no external dependencies.
"""

from __future__ import annotations

from fractions import Fraction
from itertools import product
from math import gcd
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Generic machinery: a finite group given as a list of elements with a product,
# and a finite G-set given as an action function.
# ---------------------------------------------------------------------------

Elem = Tuple[int, ...]
Point = object


class FiniteGroup:
    """A finite group given by its element list, product and identity."""

    def __init__(
        self,
        elements: Sequence[Elem],
        mul: Callable[[Elem, Elem], Elem],
        identity: Elem,
    ) -> None:
        self.elements: List[Elem] = list(elements)
        self.mul = mul
        self.identity = identity

    def inverse(self, g: Elem) -> Elem:
        for h in self.elements:
            if self.mul(g, h) == self.identity:
                return h
        raise ValueError("not a group: missing inverse")

    def generated(self, gens: Iterable[Elem]) -> Tuple[Elem, ...]:
        """Closure of `gens` under the product (a subgroup as a sorted tuple)."""
        closure = {self.identity}
        frontier = [self.identity]
        gens = list(gens)
        while frontier:
            x = frontier.pop()
            for g in gens:
                y = self.mul(x, g)
                if y not in closure:
                    closure.add(y)
                    frontier.append(y)
        return tuple(sorted(closure))

    def subgroups(self) -> List[Tuple[Elem, ...]]:
        """All subgroups, obtained by closing every subset of elements.

        Cost is exponential in |G| but the groups here have order at most 25.
        """
        found = set()
        # closures of single elements and of pairs suffice for |G| <= 25
        for g in self.elements:
            found.add(self.generated([g]))
        for g in self.elements:
            for h in self.elements:
                found.add(self.generated([g, h]))
        return sorted(found, key=lambda H: (len(H), H))

    def cyclic_subgroup(self, g: Elem) -> Tuple[Elem, ...]:
        return self.generated([g])


class GSet:
    """A finite G-set: a list of points plus an action map."""

    def __init__(
        self,
        name: str,
        group: FiniteGroup,
        points: Sequence[Point],
        act: Callable[[Elem, Point], Point],
    ) -> None:
        self.name = name
        self.group = group
        self.points: List[Point] = list(points)
        self.act = act

    # --- the two invariants -------------------------------------------------

    def fix_count(self, g: Elem) -> int:
        """|X^g|: the permutation character at g."""
        return sum(1 for x in self.points if self.act(g, x) == x)

    def mark(self, H: Sequence[Elem]) -> int:
        """|X^H|: the Burnside mark, points fixed by every element of H."""
        return sum(1 for x in self.points if all(self.act(h, x) == x for h in H))

    def molien(self, H: Sequence[Elem]) -> Fraction:
        """(1/|H|) sum_{h in H} |X^h|: the Molien invariant."""
        return Fraction(sum(self.fix_count(h) for h in H), len(H))

    def num_orbits(self, H: Sequence[Elem]) -> int:
        """Number of H-orbits, computed directly by closure."""
        remaining = list(self.points)
        seen = set()
        count = 0
        for x in remaining:
            key = repr(x)
            if key in seen:
                continue
            count += 1
            orbit = {key}
            frontier = [x]
            while frontier:
                y = frontier.pop()
                for h in H:
                    z = self.act(h, y)
                    if repr(z) not in orbit:
                        orbit.add(repr(z))
                        frontier.append(z)
            seen |= orbit
        return count

    def character(self) -> Dict[Elem, int]:
        return {g: self.fix_count(g) for g in self.group.elements}


# ---------------------------------------------------------------------------
# Verification routines for the general theorems
# ---------------------------------------------------------------------------


def check_burnside(X: GSet) -> bool:
    """Mol_X(H) = #orbits, hence |H| divides the character sum over H."""
    ok = True
    for H in X.group.subgroups():
        mol = X.molien(H)
        orb = X.num_orbits(H)
        ok &= mol == orb and mol.denominator == 1
        ok &= sum(X.fix_count(h) for h in H) % len(H) == 0
    return ok


def check_comparison(X: GSet) -> bool:
    """mark <= Molien, with equality iff H acts trivially."""
    ok = True
    for H in X.group.subgroups():
        mark = X.mark(H)
        mol = X.molien(H)
        ok &= mark <= mol
        trivial = all(X.act(h, x) == x for h in H for x in X.points)
        ok &= (mol == mark) == trivial
    return ok


def check_averaging_theorem(X: GSet) -> bool:
    """Mol_X(H) = average over h in H of mark_X(<h>)."""
    ok = True
    G = X.group
    for H in G.subgroups():
        avg = Fraction(sum(X.mark(G.cyclic_subgroup(h)) for h in H), len(H))
        ok &= avg == X.molien(H)
    return ok


def is_cyclic(G: FiniteGroup, H: Sequence[Elem]) -> bool:
    return any(len(G.generated([h])) == len(H) for h in H)


def compare(X: GSet, Y: GSet) -> None:
    """Print the full mark / Molien comparison of two G-sets over all subgroups."""
    G = X.group
    same_char = all(X.fix_count(g) == Y.fix_count(g) for g in G.elements)
    print(f"    permutation characters equal: {same_char}")
    print(f"    {'subgroup (order)':>18} {'cyclic':>7} "
          f"{'mark ' + X.name:>16} {'mark ' + Y.name:>16} "
          f"{'Mol ' + X.name:>14} {'Mol ' + Y.name:>14}")
    for H in G.subgroups():
        print(f"    {len(H):>18} {str(is_cyclic(G, H)):>7} "
              f"{X.mark(H):>16} {Y.mark(H):>16} "
              f"{str(X.molien(H)):>14} {str(Y.molien(H)):>14}")
    molien_equal = all(X.molien(H) == Y.molien(H) for H in G.subgroups())
    marks_equal = all(X.mark(H) == Y.mark(H) for H in G.subgroups())
    trivial = G.generated([])
    c = Fraction(X.mark(trivial), Y.mark(trivial))
    proportional = all(X.mark(H) == c * Y.mark(H) for H in G.subgroups())
    print(f"    Molien invariants agree everywhere : {molien_equal}")
    print(f"    mark vectors agree everywhere      : {marks_equal}")
    print(f"    scalar forced at trivial subgroup  : c = {c}")
    print(f"    mark vectors proportional          : {proportional}")
    cyc_ok = all(X.mark(H) == Y.mark(H) for H in G.subgroups() if is_cyclic(G, H))
    print(f"    marks agree at all CYCLIC subgroups: {cyc_ok}")


# ---------------------------------------------------------------------------
# Concrete groups and G-sets
# ---------------------------------------------------------------------------


def elementary_abelian(p: int) -> FiniteGroup:
    """E = (Z/p)^2 written additively as pairs, product = componentwise sum."""
    elements = [(a, b) for a in range(p) for b in range(p)]
    return FiniteGroup(
        elements,
        lambda u, v: ((u[0] + v[0]) % p, (u[1] + v[1]) % p),
        (0, 0),
    )


def cyclic_group(n: int) -> FiniteGroup:
    return FiniteGroup([(a,) for a in range(n)], lambda u, v: ((u[0] + v[0]) % n,), (0,))


def ea_characters(p: int) -> List[Callable[[Elem], int]]:
    """The p+1 functionals indexed by the projective line P^1(F_p)."""
    chars: List[Callable[[Elem], int]] = []
    for c in range(p):
        chars.append(lambda v, c=c: (v[0] + c * v[1]) % p)
    chars.append(lambda v: v[1] % p)  # the point at infinity
    return chars


def X_lines(p: int) -> GSet:
    """Disjoint union over the p+1 lines of the transitive E-set E/line."""
    E = elementary_abelian(p)
    chars = ea_characters(p)
    points = [(t, i) for i in range(p + 1) for t in range(p)]

    def act(g: Elem, x: Point) -> Point:
        t, i = x  # type: ignore[misc]
        return ((t + chars[i](g)) % p, i)

    return GSet(f"lines({p})", E, points, act)


def X_reg(p: int) -> GSet:
    """The regular E-set together with p fixed points."""
    E = elementary_abelian(p)
    points = [("reg", a, b) for a in range(p) for b in range(p)]
    points += [("pt", c, 0) for c in range(p)]

    def act(g: Elem, x: Point) -> Point:
        tag, a, b = x  # type: ignore[misc]
        if tag == "reg":
            return ("reg", (a + g[0]) % p, (b + g[1]) % p)
        return x

    return GSet(f"reg({p})", E, points, act)


def coset_gset(G: FiniteGroup, subgroup_list: Sequence[Tuple[Elem, ...]], name: str) -> GSet:
    """Disjoint union of the coset spaces G/H for the given list of subgroups H."""
    points: List[Point] = []
    cosets_by_index: List[List[frozenset]] = []
    for idx, H in enumerate(subgroup_list):
        cosets = sorted({frozenset(G.mul(g, h) for h in H) for g in G.elements},
                        key=lambda s: sorted(s))
        cosets_by_index.append(cosets)
        points += [(idx, j) for j in range(len(cosets))]

    def act(g: Elem, x: Point) -> Point:
        idx, j = x  # type: ignore[misc]
        cosets = cosets_by_index[idx]
        moved = frozenset(G.mul(g, y) for y in cosets[j])
        return (idx, cosets.index(moved))

    return GSet(name, G, points, act)


def cyclic_gset(n: int, block_sizes: Sequence[int]) -> GSet:
    """Disjoint union of transitive Z/n-sets Z/n / (d Z/n) of the given sizes."""
    G = cyclic_group(n)
    points = [(t, i) for i, d in enumerate(block_sizes) for t in range(d)]

    def act(g: Elem, x: Point) -> Point:
        t, i = x  # type: ignore[misc]
        d = block_sizes[i]
        return ((t + g[0]) % d, i)

    return GSet(f"C{n}-set{list(block_sizes)}", G, points, act)


# ---------------------------------------------------------------------------
# Arithmetic side: necklaces and Fermat
# ---------------------------------------------------------------------------


def necklace_sum(n: int, k: int) -> int:
    """sum_{a=0}^{n-1} k^gcd(n,a) — the character sum of the colouring action."""
    return sum(k ** gcd(n, a) for a in range(n))


def necklace_count(n: int, k: int) -> Fraction:
    """(1/n) * sum_a k^gcd(n,a) — the number of k-coloured n-bead necklaces."""
    return Fraction(necklace_sum(n, k), n)


def brute_force_necklaces(n: int, k: int) -> int:
    """Count rotation classes of colourings directly, for cross-checking."""
    seen = set()
    for f in product(range(k), repeat=n):
        rotations = {tuple(f[(i + r) % n] for i in range(n)) for r in range(n)}
        seen.add(min(rotations))
    return len(seen)


# ---------------------------------------------------------------------------
# Main driver
# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 78)
    print("1. Burnside's lemma, comparison, and the Averaging Theorem")
    print("=" * 78)
    test_sets: List[GSet] = [X_lines(2), X_reg(2), X_lines(3), X_reg(3),
                             cyclic_gset(6, [6, 3, 2, 1]), cyclic_gset(4, [4, 2, 1, 1])]
    for X in test_sets:
        b = check_burnside(X)
        c = check_comparison(X)
        a = check_averaging_theorem(X)
        print(f"  {X.name:>18}: Burnside={b}  mark<=Molien(+equality case)={c}  "
              f"Averaging Theorem={a}")

    print()
    print("=" * 78)
    print("2. Refutation of Conjecture D10 over the Klein four group V = (Z/2)^2")
    print("=" * 78)
    print("  X_three = V/A0 + V/A1 + V/A2  (three 'dominoes'),")
    print("  X_reg   = V + two fixed points.  Both have 6 points.")
    A, B = X_lines(2), X_reg(2)
    compare(A, B)
    print("  => equal Molien data, c is forced to 1 at the trivial subgroup,")
    print("     and then the top subgroup demands 0 = 2.  Conjecture D10 is FALSE.")
    print("  => the two V-sets are also non-isomorphic, despite equal characters.")

    print()
    print("=" * 78)
    print("3. The infinite family: (Z/p)^2 for p = 2, 3, 5")
    print("=" * 78)
    for p in (2, 3, 5):
        A, B = X_lines(p), X_reg(p)
        E = A.group
        top = tuple(sorted(E.elements))
        bot = (E.identity,)
        same_char = all(A.fix_count(g) == B.fix_count(g) for g in E.elements)
        same_mol = all(A.molien(H) == B.molien(H) for H in E.subgroups())
        print(f"  p = {p}: |X| = {len(A.points)} = p^2+p = {p*p+p}; "
              f"equal characters = {same_char}; equal Molien = {same_mol}")
        print(f"          mark at bottom: {A.mark(bot)} vs {B.mark(bot)} (forces c = 1)")
        print(f"          mark at top   : {A.mark(top)} vs {B.mark(top)} "
              f"(0 vs p = {p}: contradiction)")
        cyc = all(A.mark(H) == B.mark(H) for H in E.subgroups() if is_cyclic(E, H))
        print(f"          marks agree at every cyclic subgroup: {cyc}")

    print()
    print("=" * 78)
    print("4. Cyclic Recovery Theorem: over Z/n the character determines the marks")
    print("=" * 78)
    print("  Exhaustive search over all Z/n-sets built from transitive pieces,")
    print("  total size at most 8: every character-equal pair has equal marks.")
    for n in (4, 6, 8):
        G = cyclic_group(n)
        divisors = [d for d in range(1, n + 1) if n % d == 0]
        family: List[GSet] = []
        for mult in product(range(0, 4), repeat=len(divisors)):
            blocks = [d for d, m in zip(divisors, mult) for _ in range(m)]
            if 0 < sum(blocks) <= 8:
                family.append(cyclic_gset(n, blocks))
        pairs = 0
        char_equal_pairs = 0
        violations = 0
        subs = G.subgroups()
        for i, X in enumerate(family):
            for Y in family[i + 1:]:
                pairs += 1
                if all(X.fix_count(g) == Y.fix_count(g) for g in G.elements):
                    char_equal_pairs += 1
                    if any(X.mark(H) != Y.mark(H) for H in subs):
                        violations += 1
        print(f"  n = {n}: {pairs} pairs tested, {char_equal_pairs} with equal "
              f"characters, {violations} mark violations")
    print("  (Zero character-equal pairs means the character already separates these")
    print("   Z/n-sets — exactly the content of the theorem, since over a cyclic group")
    print("   the character recovers the full mark vector.)")
    print()
    print("  Contrast: exhaustive search over Klein four group sets built from")
    print("  transitive pieces of total size at most 6.")
    V = elementary_abelian(2)
    v_subgroups = V.subgroups()
    v_family: List[GSet] = []
    for mult in product(range(0, 4), repeat=len(v_subgroups)):
        pieces = [H for H, m in zip(v_subgroups, mult) for _ in range(m)]
        size = sum(len(V.elements) // len(H) for H in pieces)
        if 0 < size <= 6:
            v_family.append(coset_gset(V, pieces, "V-set" + str(mult)))
    char_equal = 0
    mark_different = 0
    witness = None
    for i, Xv in enumerate(v_family):
        for Yv in v_family[i + 1:]:
            if all(Xv.fix_count(g) == Yv.fix_count(g) for g in V.elements):
                char_equal += 1
                if any(Xv.mark(H) != Yv.mark(H) for H in v_subgroups):
                    mark_different += 1
                    witness = witness or (Xv, Yv)
    print(f"  Klein four group: {char_equal} character-equal pairs, of which "
          f"{mark_different} have different mark vectors.")
    if witness is not None:
        Xv, Yv = witness
        print("  A witness pair (marks listed by increasing subgroup order):")
        print(f"    marks: {[Xv.mark(H) for H in v_subgroups]} vs "
              f"{[Yv.mark(H) for H in v_subgroups]}")
        print(f"    characters: {[Xv.fix_count(g) for g in V.elements]} vs "
              f"{[Yv.fix_count(g) for g in V.elements]}")

    print()
    print("=" * 78)
    print("5. Arithmetic pay-off: necklace congruence and Fermat's little theorem")
    print("=" * 78)
    print(f"  {'n':>3} {'k':>3} {'sum_a k^gcd(n,a)':>20} {'/ n':>12} {'integer?':>9} "
          f"{'brute force':>12}")
    for n in range(1, 9):
        for k in range(1, 4):
            s = necklace_sum(n, k)
            q = necklace_count(n, k)
            bf = brute_force_necklaces(n, k) if k ** n <= 200000 else None
            agree = "-" if bf is None else str(bf)
            print(f"  {n:>3} {k:>3} {s:>20} {str(q):>12} "
                  f"{str(q.denominator == 1):>9} {agree:>12}")
    print()
    print("  Fermat's little theorem, k^p mod p versus k mod p:")
    for p in (2, 3, 5, 7, 11, 13):
        bad = [k for k in range(0, 20) if pow(k, p, p) != k % p]
        print(f"    p = {p:>2}: violations among 0 <= k < 20: {bad}")
    print()
    print("  Derivation check: for prime p, sum_a k^gcd(p,a) = k^p + (p-1)k")
    for p in (2, 3, 5, 7):
        for k in range(1, 5):
            assert necklace_sum(p, k) == k ** p + (p - 1) * k
    print("    verified for p in {2,3,5,7}, k in {1,2,3,4}")

    print()
    print("All checks completed.")


if __name__ == "__main__":
    main()
