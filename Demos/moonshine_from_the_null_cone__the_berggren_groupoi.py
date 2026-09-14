"""
Moonshine from the Null Cone
============================

Numerical companion to the paper "Moonshine from the Null Cone: the Berggren
Groupoid, Even Lorentzian Lattices, and the Holy Construction".

Everything here is elementary integer arithmetic on the Lorentzian lattice

        Z^{2,1} = (Z^3,  <(a,b,c),(a',b',c')> = a a' + b b' - c c'),

on which the three Barning-Hall (Berggren) matrices act, generating the free
ternary tree of primitive Pythagorean triples rooted at (3,4,5).

The script demonstrates, purely by computation:

  1. the Berggren generators as products of reflections in UNIT-norm vectors;
  2. the parity obstruction: those reflection vectors have odd norm 1, so the
     Pythagorean Lorentzian lattice admits no form-preserving map into any
     even lattice;
  3. the repair by doubling: in Z^{2,1}(2) the same vectors become roots of
     norm 2, and the Berggren monoid acts faithfully by root reflections on
     any even lattice carrying an orthogonal (2,2,-2) frame;
  4. the counting obstructions to a "nodes <-> deep holes / Niemeier lattices"
     correspondence;
  5. the Gaussian-split law for hypotenuses, and the exact prime spectrum
     {p prime : p = 1 mod 4};
  6. the holy construction at every primitive isotropic vector: the quotient
     is always the rank-one lattice <1> (i.e. A_1 after doubling), never the
     rootless Leech lattice.

Run:  python3 demo.py
"""

from __future__ import annotations

from itertools import product
from math import gcd
from typing import Dict, Iterable, List, Sequence, Tuple

Vec = Tuple[int, int, int]
Mat = Tuple[Vec, Vec, Vec]

# ----------------------------------------------------------------------------
# 1. The Lorentzian lattice Z^{2,1}
# ----------------------------------------------------------------------------


def bil(v: Vec, w: Vec) -> int:
    """The Lorentz form <v,w> = v1 w1 + v2 w2 - v3 w3 of signature (2,1)."""
    return v[0] * w[0] + v[1] * w[1] - v[2] * w[2]


def qform(v: Vec) -> int:
    """The quadratic form Q(v) = <v,v> = a^2 + b^2 - c^2."""
    return bil(v, v)


def add(v: Vec, w: Vec) -> Vec:
    return (v[0] + w[0], v[1] + w[1], v[2] + w[2])


def smul(k: int, v: Vec) -> Vec:
    return (k * v[0], k * v[1], k * v[2])


def apply_mat(m: Mat, v: Vec) -> Vec:
    return tuple(sum(m[i][j] * v[j] for j in range(3)) for i in range(3))  # type: ignore


# The three Barning-Hall matrices.
mA: Mat = ((1, -2, 2), (2, -1, 2), (2, -2, 3))
mB: Mat = ((1, 2, 2), (2, 1, 2), (2, 2, 3))
mC: Mat = ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3))

GENERATORS: Dict[str, Mat] = {"A": mA, "B": mB, "C": mC}

ROOT: Vec = (3, 4, 5)


def apply_word(word: str, v: Vec = ROOT) -> Vec:
    """Apply a Berggren address (a word in A, B, C) left-to-right to v."""
    out = v
    for letter in word:
        out = apply_mat(GENERATORS[letter], out)
    return out


# ----------------------------------------------------------------------------
# 2. Reflections in unit-norm vectors
# ----------------------------------------------------------------------------


def reflU(r: Vec, x: Vec) -> Vec:
    """Reflection s_r(x) = x - 2<x,r> r in a vector r with <r,r> = 1."""
    t = 2 * bil(x, r)
    return (x[0] - t * r[0], x[1] - t * r[1], x[2] - t * r[2])


E1: Vec = (1, 0, 0)
E2: Vec = (0, 1, 0)
ROOT_A: Vec = (1, -1, -1)
ROOT_B: Vec = (1, 1, -1)
ROOT_C: Vec = (-1, 1, -1)

GEN_REFL: Dict[str, List[Vec]] = {
    "A": [E1, ROOT_A],
    "B": [E1, E2, ROOT_B],
    "C": [E2, ROOT_C],
}


def refl_word(rs: Sequence[Vec], x: Vec) -> Vec:
    """Apply a list of unit reflections right-to-left."""
    out = x
    for r in reversed(rs):
        out = reflU(r, out)
    return out


def word_refl(word: str) -> List[Vec]:
    """The reflection vectors realising a whole Berggren address.

    An address is read left to right as successive moves down the tree, so the
    composite map is the LAST letter applied outermost; the reflection lists are
    therefore concatenated in reverse letter order.
    """
    out: List[Vec] = []
    for letter in reversed(word):
        out.extend(GEN_REFL[letter])
    return out


# ----------------------------------------------------------------------------
# 3. Doubling: even lattices and root reflections
# ----------------------------------------------------------------------------


def bil2(v: Vec, w: Vec) -> int:
    """The even rescaling Z^{2,1}(2): the doubled Lorentz form."""
    return 2 * bil(v, w)


def lat_refl(rho: Vec, x: Vec) -> Vec:
    """Root reflection s_rho(x) = x - <x,rho> rho for a root rho of norm 2.

    Here <.,.> is the DOUBLED form, so no division ever occurs.
    """
    t = bil2(x, rho)
    return (x[0] - t * rho[0], x[1] - t * rho[1], x[2] - t * rho[2])


def berggren_aut(word: str, x: Vec) -> Vec:
    """The isometry of the even lattice Z^{2,1}(2) attached to an address."""
    out = x
    for r in reversed(word_refl(word)):
        out = lat_refl(r, out)
    return out


# ----------------------------------------------------------------------------
# 4. The Lorentzian cross product and the holy construction
# ----------------------------------------------------------------------------


def lor_cross(v: Vec, w: Vec) -> Vec:
    """Lorentzian cross product, orthogonal to both arguments for the (2,1) form."""
    return (
        v[1] * w[2] - v[2] * w[1],
        v[2] * w[0] - v[0] * w[2],
        v[1] * w[0] - v[0] * w[1],
    )


def is_primitive(v: Vec) -> bool:
    return gcd(gcd(abs(v[0]), abs(v[1])), abs(v[2])) == 1


def extgcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclid: returns (g, x, y) with a x + b y = g = gcd(a, b)."""
    if b == 0:
        return (abs(a), 1 if a >= 0 else -1, 0)
    g, x, y = extgcd(b, a % b)
    return (g, y, x - (a // b) * y)


def pairing_one(rho: Vec) -> Vec:
    """Find sigma with <rho,sigma> = 1 for a primitive rho (unimodularity).

    Two applications of Bezout's identity: this is the constructive content of
    the unimodularity of Z^{2,1}.
    """
    a, b, c = rho
    g1, x, y = extgcd(a, b)
    _, u, v = extgcd(g1, c)
    sigma = (x * u, y * u, -v)
    assert bil(rho, sigma) == 1, (rho, sigma)
    return sigma


def holy_generator(rho: Vec) -> Vec:
    """The generator tau of the holy construction rho^perp / Z rho."""
    return lor_cross(rho, pairing_one(rho))


# ----------------------------------------------------------------------------
# 5. Arithmetic of hypotenuses
# ----------------------------------------------------------------------------


def prime_factors(n: int) -> List[int]:
    out: List[int] = []
    d, m = 2, n
    while d * d <= m:
        while m % d == 0:
            out.append(d)
            m //= d
        d += 1
    if m > 1:
        out.append(m)
    return out


def obstructing_prime(n: int) -> int | None:
    """A prime p = 3 (mod 4) dividing n, if one exists."""
    for p in sorted(set(prime_factors(abs(n)))):
        if p % 4 == 3:
            return p
    return None


def tree_level(depth: int) -> List[Vec]:
    """All nodes at a given depth of the Berggren tree."""
    level = [ROOT]
    for _ in range(depth):
        level = [apply_mat(m, v) for v in level for m in (mA, mB, mC)]
    return level


def tree_ball(depth: int) -> int:
    """Number of nodes at depth <= n: 1, 4, 13, 40, 121, ..."""
    return (3 ** (depth + 1) - 1) // 2


def euclid_triple(m: int, n: int) -> Vec:
    """The Euclid parametrisation (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hypotenuse_for_prime(p: int) -> str | None:
    """For p = 1 (mod 4), the Berggren address whose node has hypotenuse p."""
    for depth in range(9):
        for word in ("".join(w) for w in product("ABC", repeat=depth)):
            if apply_word(word)[2] == p:
                return word or "(root)"
    return None


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def demo_reflection_words() -> None:
    banner("1. The Berggren generators are words in UNIT reflections")
    tests: Iterable[Vec] = [(3, 4, 5), (5, 12, 13), (1, 0, 0), (7, -2, 11)]
    for letter, mat in GENERATORS.items():
        ok = all(apply_mat(mat, v) == refl_word(GEN_REFL[letter], v) for v in tests)
        vecs = ", ".join(f"s_{r}" for r in GEN_REFL[letter])
        print(f"  m{letter} = {vecs}   verified: {ok}")
    print()
    print("  Norms of the five reflection vectors (all ODD, all equal to 1):")
    for r in (E1, E2, ROOT_A, ROOT_B, ROOT_C):
        print(f"    <{r},{r}> = {qform(r)}   even? {qform(r) % 2 == 0}")
    print()
    print("  Reflection-word length  = 3*#B + 2*#(A or C):")
    for word in ("A", "B", "AB", "BBC", "ABCBA"):
        pred = 3 * word.count("B") + 2 * (len(word) - word.count("B"))
        print(f"    word {word:<6} length {len(word_refl(word)):>2}  predicted {pred:>2}")


def demo_parity_obstruction() -> None:
    banner("2. Parity obstruction: no even lattice can host the Pythagorean form")
    print("  An even lattice has <x,x> even for EVERY x.  But in Z^{2,1}:")
    print(f"    Q(e1) = Q{E1} = {qform(E1)}  (odd)")
    print("  So NO map f (linear or not) into an even lattice can satisfy")
    print("    <f(v), f(w)> = <v, w>  for all v, w.")
    print("  Since II(25,1) -- the even unimodular Lorentzian lattice of Conway's")
    print("  holy construction -- is even, the naive embedding is impossible.")
    print()
    print("  The repair: the doubled form 2<.,.> is even, since 2<v,v> = 2 * Q(v):")
    for v in [(1, 0, 0), (3, 4, 5), (2, 1, 2), (7, -3, 4)]:
        print(f"    v = {str(v):<12} Q(v) = {qform(v):>4}   2Q(v) = {2*qform(v):>5} (even)")


def demo_doubled_embedding() -> None:
    banner("3. After doubling, the five vectors are ROOTS and the action is faithful")
    print("  Norms in the even lattice Z^{2,1}(2):")
    for r in (E1, E2, ROOT_A, ROOT_B, ROOT_C):
        print(f"    <{str(r):<12}>^2 = {bil2(r, r)}   -> a root of norm 2")
    print()
    print("  Root reflections s_rho(x) = x - <x,rho> rho are integral on ALL of the")
    print("  lattice (no division by <rho,rho>/2 is required), and they intertwine")
    print("  the Berggren action:")
    tests = [(3, 4, 5), (5, 12, 13), (2, 1, 2), (0, 0, 1)]
    words = ["", "A", "B", "C", "AB", "CBA", "ABCB"]
    ok_intertwine = all(
        berggren_aut(w, v) == apply_word(w, v) for w in words for v in tests
    )
    ok_isometry = all(
        bil2(berggren_aut(w, v), berggren_aut(w, u)) == bil2(v, u)
        for w in words
        for v in tests
        for u in tests
    )
    print(f"    berggren_aut(w) agrees with the Berggren action : {ok_intertwine}")
    print(f"    berggren_aut(w) preserves the doubled form      : {ok_isometry}")
    print()
    print("  Faithfulness: distinct addresses give distinct automorphisms, because")
    print("  they already move the root node (3,4,5) to distinct triples.")
    seen: Dict[Vec, str] = {}
    collisions = 0
    for depth in range(6):
        for w in ("".join(t) for t in product("ABC", repeat=depth)):
            node = apply_word(w)
            if node in seen:
                collisions += 1
            seen[node] = w
    print(f"    distinct nodes among the {len(seen)} addresses of depth <= 5 :"
          f" {len(seen)}  (collisions: {collisions})")


def demo_counting_obstruction() -> None:
    banner("4. The tree cannot enumerate deep holes (23) or Niemeier lattices (24)")
    print("  Level sizes of a free ternary tree are powers of 3;")
    print("  ball sizes are (3^(n+1) - 1)/2:")
    print("    levels :", [3 ** n for n in range(6)])
    print("    balls  :", [tree_ball(n) for n in range(6)])
    for target, name in ((23, "deep-hole classes"), (24, "Niemeier lattices")):
        lv = any(3 ** n == target for n in range(30))
        bl = any(tree_ball(n) == target for n in range(30))
        print(f"    {target} ({name}): occurs as a level? {lv}   as a ball? {bl}")
    print()
    print("  Consequently any labelling of the infinitely many nodes by the 24")
    print("  Niemeier classes is non-injective, and by pigeonhole some class")
    print("  receives infinitely many nodes.  Illustration with the labelling")
    print("  'hypotenuse mod 24':")
    counts: Dict[int, int] = {}
    for depth in range(8):
        for w in ("".join(t) for t in product("ABC", repeat=depth)):
            h = apply_word(w)[2] % 24
            counts[h] = counts.get(h, 0) + 1
    total = sum(counts.values())
    print(f"    {total} nodes of depth <= 7 fall into {len(counts)} classes:")
    for k in sorted(counts):
        print(f"      class {k:>2}: {counts[k]:>5} nodes")


def demo_gaussian_split_law() -> None:
    banner("5. The Gaussian-split law and the exact prime spectrum")
    hyps = sorted({apply_word(w)[2] for d in range(7)
                   for w in ("".join(t) for t in product("ABC", repeat=d))})
    print("  First Berggren hypotenuses:", hyps[:14])
    print(f"    all = 1 (mod 4)? {all(h % 4 == 1 for h in hyps)}")
    bad = [h for h in hyps if obstructing_prime(h) is not None]
    print(f"    any divisible by a prime = 3 (mod 4)? {bool(bad)}")
    print()
    print("  Moonshine head data, and why none of it is ever a hypotenuse:")
    data = [
        (196883, "smallest faithful Monster representation"),
        (196884, "head coefficient of the modular invariant j"),
        (21296876, "next Monster head dimension"),
        (21493760, "next coefficient of j"),
        (23, "classes of deep holes in the Leech lattice"),
        (24, "Niemeier lattices"),
    ]
    for n, label in data:
        p = obstructing_prime(n)
        counts_f: Dict[int, int] = {}
        for q in prime_factors(n):
            counts_f[q] = counts_f.get(q, 0) + 1
        fac = " * ".join(f"{q}^{e}" if e > 1 else str(q)
                         for q, e in sorted(counts_f.items()))
        print(f"    {n:>9} = {fac:<22} obstructing prime {p} = 3 (mod 4)")
        print(f"              [{label}]")
    print()
    print("  Converse: every prime p = 1 (mod 4) IS a hypotenuse.")
    for p in (5, 13, 17, 29, 37, 41, 53, 61):
        print(f"    p = {p:>3}: address {hypotenuse_for_prime(p)}")
    print()
    print("  Supersingular primes of the Monster, split vs inert:")
    ss = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71]
    split = [p for p in ss if p % 4 == 1]
    inert = [p for p in ss if p % 4 == 3]
    print(f"    split (p = 1 mod 4, ARE hypotenuses)      : {split}")
    print(f"    inert (p = 3 mod 4, never divide one)     : {inert}")
    print("    (2 is ramified in Z[i] and is excluded since hypotenuses are odd.)")


def demo_holy_construction() -> None:
    banner("6. The holy construction at a null vector: always <1>, never Leech")
    tau0 = (2, 1, 2)
    print(f"  Root node rho = {ROOT}, Q(rho) = {qform(ROOT)} (null), primitive: "
          f"{is_primitive(ROOT)}")
    print(f"  tau = {tau0}: <tau,rho> = {bil(tau0, ROOT)}, Q(tau) = {qform(tau0)}")
    print("  Explicit basis of rho^perp:  v = x rho + y tau with")
    print("      x = 3c - 2a - 2b,   y = 5a + 5b - 7c,   and Q(v) = y^2.")
    ok = True
    for v in product(range(-9, 10), repeat=3):
        if bil(v, ROOT) == 0:  # type: ignore[arg-type]
            a, b, c = v
            x, y = 3 * c - 2 * a - 2 * b, 5 * a + 5 * b - 7 * c
            ok &= add(smul(x, ROOT), smul(y, tau0)) == v and qform(v) == y * y  # type: ignore[arg-type]
    print(f"    verified on all v in rho^perp with |coords| <= 9 : {ok}")
    print()
    print("  Rigidity: the same holds at EVERY primitive null vector, via the")
    print("  Lorentzian cross product and the Lagrange identity")
    print("      Q(v x w) = <v,w>^2 - Q(v) Q(w).")
    nulls = [v for v in product(range(-12, 13), repeat=3)
             if qform(v) == 0 and v != (0, 0, 0) and is_primitive(v)]  # type: ignore[arg-type]
    good = 0
    for rho in nulls:
        tau = holy_generator(rho)  # type: ignore[arg-type]
        if bil(tau, rho) == 0 and qform(tau) == 1:  # type: ignore[arg-type]
            good += 1
    print(f"    primitive null vectors tested: {len(nulls)}")
    print(f"    for how many does tau = rho x sigma satisfy Q(tau) = 1? {good}")
    print()
    print("  In the even rescaling the class of tau has norm 2: it is a ROOT.")
    print("  The Leech lattice has minimum 4 and contains no roots at all, so")
    print("  the holy construction on the Pythagorean null cone is A_1, not Leech.")
    print()
    print("  The same computation transported along the tree:")
    for w in ("", "A", "B", "C", "AB", "CBA"):
        rho = apply_word(w)
        tau = holy_generator(rho)
        print(f"    address {w or '(root)':<7} node {str(rho):<16} "
              f"tau = {str(tau):<16} Q(tau) = {qform(tau)}")


def main() -> None:
    print(__doc__)
    demo_reflection_words()
    demo_parity_obstruction()
    demo_doubled_embedding()
    demo_counting_obstruction()
    demo_gaussian_split_law()
    demo_holy_construction()
    banner("Summary")
    print("""
  (i)   Verbatim embedding of the Pythagorean null cone into the even
        Lorentzian Leech lattice II(25,1): IMPOSSIBLE (parity).
        After doubling the form: the Berggren monoid embeds FAITHFULLY into
        the isometry group of any even lattice with a (2,2,-2) frame.
  (ii)  Nodes <-> deep holes / Niemeier lattices: IMPOSSIBLE (counting).
  (iii) Tree-parametrised moonshine head data: IMPOSSIBLE (Gaussian-split law);
        the tree's radial prime spectrum is exactly {p prime : p = 1 mod 4}.
  (+)   Positive replacement: the holy construction at every primitive null
        vector of Z^{2,1} is the rank-one lattice <1> = A_1 after doubling --
        rooted, hence never Leech-like.  Rootlessness is a strictly even
        phenomenon.
""")


if __name__ == "__main__":
    main()
