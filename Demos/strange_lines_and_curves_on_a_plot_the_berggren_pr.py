#!/usr/bin/env python3
"""
Stars on the Rim: numerical demonstrations of the boundary geometry of the
Berggren (Barning-Hall) tree of primitive Pythagorean triples.

This script is fully self-contained (standard library only) and verifies, by
exact integer / high-precision arithmetic, every quantitative claim of the
accompanying article and paper:

  1. The three Berggren generators are integral Lorentz isometries of
     Q(a,b,c) = a^2 + b^2 - c^2, and the tree they generate consists of
     primitive Pythagorean triples with odd first leg.

  2. The chord-charge identity
         ||dir v - dir p||^2 = -2 <v,p> / (c_v c_p).

  3. The exact tangency law: c_v * ||dir v - dir p||^2 = 2d/c_p is CONSTANT
     along a horocycle of charge d, so the contact order with the boundary
     circle is exactly two.

  4. Charge quantization: the charge c-a of a primitive triple is twice a
     square (odd first leg) or an odd square (even first leg); inside the tree
     the spectrum is exactly {2n^2 : n >= 1}.

  5. The Euclid dictionary A:(m,n)->(2m-n,m), B:(m,n)->(2m+n,m),
     C:(m,n)->(m+2n,n), and the identification "spoke index = smaller Euclid
     parameter".

  6. The escape-rate dichotomy: the parabolic branch approaches its boundary
     point at rate Theta(k^-2), the hyperbolic one at rate O(3^-k), with the
     explicit constants 2/(17 k^2) and 1/(5 * 3^k) at the root.

  7. Star location and multiplicity: every node is a star centre, and each
     star carries infinitely many distinct spokes.

  8. The two-sided Lyapunov bound 5 * 3^{#B} <= c <= 5 * 7^{len}.

Run:  python3 demo.py
"""

from __future__ import annotations

from decimal import Decimal, getcontext
from fractions import Fraction
from math import gcd, isqrt
from typing import Dict, Iterable, Iterator, List, Sequence, Tuple

getcontext().prec = 60

Triple = Tuple[int, int, int]

# --------------------------------------------------------------------------
# 1. The Lorentzian setup
# --------------------------------------------------------------------------

ROOT: Triple = (3, 4, 5)
E1: Triple = (1, 0, 1)  # ideal point (1, 0)
E2: Triple = (0, 1, 1)  # ideal point (0, 1)


def bil(v: Triple, w: Triple) -> int:
    """Minkowski product <v,w> = v1 w1 + v2 w2 - v3 w3 of signature (2,1)."""
    return v[0] * w[0] + v[1] * w[1] - v[2] * w[2]


def qform(v: Triple) -> int:
    """The quadratic form Q(a,b,c) = a^2 + b^2 - c^2."""
    return bil(v, v)


def gen_A(v: Triple) -> Triple:
    a, b, c = v
    return (a - 2 * b + 2 * c, 2 * a - b + 2 * c, 2 * a - 2 * b + 3 * c)


def gen_B(v: Triple) -> Triple:
    a, b, c = v
    return (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


def gen_C(v: Triple) -> Triple:
    a, b, c = v
    return (-a + 2 * b + 2 * c, -2 * a + b + 2 * c, -2 * a + 2 * b + 3 * c)


GENERATORS = {"A": gen_A, "B": gen_B, "C": gen_C}


def inv_A(v: Triple) -> Triple:
    a, b, c = v
    return (a + 2 * b - 2 * c, -2 * a - b + 2 * c, -2 * a - 2 * b + 3 * c)


def inv_B(v: Triple) -> Triple:
    a, b, c = v
    return (a + 2 * b - 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)


def inv_C(v: Triple) -> Triple:
    a, b, c = v
    return (-a - 2 * b + 2 * c, 2 * a + b - 2 * c, -2 * a - 2 * b + 3 * c)


INVERSES = {"A": inv_A, "B": inv_B, "C": inv_C}


def apply_word(word: str, v: Triple = ROOT) -> Triple:
    """Apply the letters of `word` left-to-right, starting at `v`."""
    for letter in word:
        v = GENERATORS[letter](v)
    return v


def dir_point(v: Triple) -> Tuple[Fraction, Fraction]:
    """The ideal point (a/c, b/c) on the unit circle."""
    a, b, c = v
    return (Fraction(a, c), Fraction(b, c))


def chord_sq(v: Triple, p: Triple) -> Fraction:
    """Exact squared chordal distance between the two plotted ideal points."""
    xv, yv = dir_point(v)
    xp, yp = dir_point(p)
    return (xv - xp) ** 2 + (yv - yp) ** 2


def charge(v: Triple, p: Triple) -> int:
    """The Lorentz charge d = -<v,p> of v at the null vector p."""
    return -bil(v, p)


# --------------------------------------------------------------------------
# 2. Euclid coordinates
# --------------------------------------------------------------------------

def eu(m: int, n: int) -> Triple:
    """Euclid parametrisation (m^2-n^2, 2mn, m^2+n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def euclid_params(v: Triple) -> Tuple[int, int]:
    """Recover (m,n) with 0 < n < m from a primitive triple with odd first leg."""
    a, _, c = v
    m_sq = (c + a) // 2
    n_sq = (c - a) // 2
    m, n = isqrt(m_sq), isqrt(n_sq)
    assert m * m == m_sq and n * n == n_sq, "not a primitive odd-leg triple"
    return m, n


def spoke_index(v: Triple) -> int:
    """The spoke index of a node = its smaller Euclid parameter."""
    return euclid_params(v)[1]


# --------------------------------------------------------------------------
# 3. Tree enumeration
# --------------------------------------------------------------------------

def tree_nodes(max_hyp: int) -> List[Tuple[str, Triple]]:
    """All (address, triple) with hypotenuse <= max_hyp, breadth-first."""
    out: List[Tuple[str, Triple]] = []
    frontier: List[Tuple[str, Triple]] = [("", ROOT)]
    while frontier:
        nxt: List[Tuple[str, Triple]] = []
        for word, v in frontier:
            if v[2] > max_hyp:
                continue
            out.append((word, v))
            for letter, g in GENERATORS.items():
                child = g(v)
                if child[2] <= max_hyp:
                    nxt.append((word + letter, child))
        frontier = nxt
    return out


def all_primitive_odd_leg(max_hyp: int) -> List[Triple]:
    """Brute-force list of primitive triples with odd first leg, c <= max_hyp."""
    found: List[Triple] = []
    for a in range(1, max_hyp + 1, 2):
        for b in range(1, max_hyp + 1):
            s = a * a + b * b
            c = isqrt(s)
            if c * c == s and c <= max_hyp and gcd(a, b) == 1:
                found.append((a, b, c))
    return sorted(found)


def descend(v: Triple) -> str:
    """Recover the address of a primitive odd-leg triple by Fermat descent."""
    letters: List[str] = []
    while v != ROOT:
        for name, inv in INVERSES.items():
            w = inv(v)
            if w[0] > 0 and w[1] > 0 and 0 < w[2] < v[2] and qform(w) == 0:
                letters.append(name)
                v = w
                break
        else:  # pragma: no cover - unreachable by completeness
            raise RuntimeError(f"descent stuck at {v}")
    return "".join(reversed(letters))


# --------------------------------------------------------------------------
# Presentation helpers
# --------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def check(label: str, condition: bool) -> None:
    status = "OK " if condition else "FAIL"
    print(f"  [{status}] {label}")
    assert condition, label


# --------------------------------------------------------------------------
# Demo 1 : the generators are integral Lorentz isometries
# --------------------------------------------------------------------------

def demo_lorentz() -> None:
    banner("1.  The Berggren generators lie in O(2,1;Z)")
    probes: List[Triple] = [(3, 4, 5), (5, 12, 13), (1, 0, 1), (2, -7, 11), (0, 1, 1)]
    for name, g in GENERATORS.items():
        ok = all(bil(g(v), g(w)) == bil(v, w) for v in probes for w in probes)
        check(f"generator {name} preserves the Minkowski product", ok)
    print()
    print("  Root and its three children (all on the light cone):")
    for name, g in GENERATORS.items():
        child = g(ROOT)
        print(f"    {name}(3,4,5) = {child}   Q = {qform(child)}")
    print()
    print("  Conserved charges of each generator:")
    v = (20, 21, 29)
    print(f"    v            = {v}")
    print(f"    C conserves c-a : {v[2]-v[0]} -> {gen_C(v)[2]-gen_C(v)[0]}")
    print(f"    A conserves c-b : {v[2]-v[1]} -> {gen_A(v)[2]-gen_A(v)[1]}")
    print(f"    B negates  a-b  : {v[0]-v[1]} -> {gen_B(v)[0]-gen_B(v)[1]}")


# --------------------------------------------------------------------------
# Demo 2 : the chord-charge identity
# --------------------------------------------------------------------------

def demo_chord_charge() -> None:
    banner("2.  Chord = charge:  ||dir v - dir p||^2 = -2<v,p>/(c_v c_p)")
    nodes = [v for _, v in tree_nodes(400)]
    centres: List[Triple] = [E1, E2, ROOT, (5, 12, 13), (15, 8, 17)]
    ok = True
    for p in centres:
        for v in nodes:
            lhs = chord_sq(v, p)
            rhs = Fraction(-2 * bil(v, p), v[2] * p[2])
            ok = ok and lhs == rhs
    check(f"identity holds exactly for {len(nodes)} nodes x {len(centres)} centres", ok)
    print()
    print("  Sample (star centre p = (1,0,1), i.e. the boundary point (1,0)):")
    print(f"    {'node':>18} {'d = c-a':>8}  {'||dir v - (1,0)||^2':>22}")
    for v in nodes[:8]:
        print(f"    {str(v):>18} {charge(v, E1):>8}  {str(chord_sq(v, E1)):>22}")


# --------------------------------------------------------------------------
# Demo 3 : exact tangency, contact order two
# --------------------------------------------------------------------------

def demo_tangency() -> None:
    banner("3.  Exact tangency law:  c_v * ||dir v - dir p||^2 = 2d/c_p  (CONSTANT)")
    p = E1
    print("  Spoke of charge d = 2n^2 at (1,0) is the family eu(m,n), m = n+1, n+2, ...")
    print()
    for n in (1, 2, 3, 5):
        d = 2 * n * n
        print(f"  spoke index n = {n},  charge d = {d},  predicted 2d/c_p = {2*d}")
        row = []
        for m in range(n + 1, n + 7):
            v = eu(m, n)
            row.append(v[2] * chord_sq(v, p))
        check(f"    product constant along the spoke  ({row[0]})",
              all(x == Fraction(2 * d) for x in row))
    print()
    print("  Contact order is exactly two:  c^2 * chord^2 -> infinity,  sqrt(c) * chord^2 -> 0")
    n = 2
    print(f"    {'m':>6} {'c':>10} {'c^2*chord^2':>16} {'sqrt(c)*chord^2':>18}")
    for m in (3, 10, 100, 1000, 10000):
        v = eu(m, n)
        ch = chord_sq(v, p)
        big = Decimal(v[2]) ** 2 * Decimal(ch.numerator) / Decimal(ch.denominator)
        small = Decimal(v[2]).sqrt() * Decimal(ch.numerator) / Decimal(ch.denominator)
        print(f"    {m:>6} {v[2]:>10} {big:>16.4f} {small:>18.8f}")


# --------------------------------------------------------------------------
# Demo 4 : charge quantization
# --------------------------------------------------------------------------

def is_twice_square(d: int) -> bool:
    return d % 2 == 0 and isqrt(d // 2) ** 2 == d // 2


def is_odd_square(d: int) -> bool:
    r = isqrt(d)
    return r * r == d and r % 2 == 1


def demo_quantization() -> None:
    banner("4.  Charge quantization:  c - a is twice a square, or an odd square")
    N = 400
    triples = [t for t in all_primitive_odd_leg(N)]
    odd_first = [t for t in triples if t[0] % 2 == 1]
    even_first = [(b, a, c) for (a, b, c) in triples if b % 2 == 0]  # swap legs
    check("odd first leg  =>  c-a = 2n^2",
          all(is_twice_square(c - a) for a, _, c in odd_first))
    check("even first leg =>  c-a = odd square",
          all(is_odd_square(c - a) for a, _, c in even_first))

    seen_odd = sorted({c - a for a, _, c in odd_first})
    seen_even = sorted({c - a for a, _, c in even_first})
    print()
    print(f"  charges realised with ODD  first leg (c <= {N}):  {seen_odd[:12]} ...")
    print(f"  charges realised with EVEN first leg (c <= {N}):  {seen_even[:12]} ...")
    print(f"  first twelve values of 2n^2                    :  "
          f"{[2*n*n for n in range(1, 13)]}")
    print(f"  first twelve odd squares                       :  "
          f"{[(2*m-1)**2 for m in range(1, 13)]}")
    print()
    print("  Realisability (every admissible charge occurs):")
    for n in range(1, 5):
        t = (2 * n + 1, 2 * n * n + 2 * n, 2 * n * n + 2 * n + 1)
        check(f"    (2n+1, 2n^2+2n, 2n^2+2n+1) with n={n} -> {t}, charge {t[2]-t[0]} = 2*{n}^2",
              qform(t) == 0 and gcd(t[0], t[1]) == 1 and t[2] - t[0] == 2 * n * n)
    for m in range(1, 5):
        t = (4 * m, 4 * m * m - 1, 4 * m * m + 1)
        check(f"    (4m, 4m^2-1, 4m^2+1) with m={m} -> {t}, charge {t[2]-t[0]} = ({2*m-1})^2",
              qform(t) == 0 and gcd(t[0], t[1]) == 1 and t[2] - t[0] == (2 * m - 1) ** 2)
    print()
    print("  Density-zero check: #{admissible charges <= X} grows like ~1.2 sqrt(X)")
    for X in (100, 1000, 10000, 100000):
        cnt = sum(1 for d in range(1, X + 1) if is_twice_square(d) or is_odd_square(d))
        print(f"    X = {X:>7}:  count = {cnt:>5}   count/sqrt(X) = {cnt / X**0.5:.4f}")


# --------------------------------------------------------------------------
# Demo 5 : the Euclid dictionary and the spoke index
# --------------------------------------------------------------------------

def demo_euclid() -> None:
    banner("5.  Euclid coordinates:  A:(m,n)->(2m-n,m)  B:(m,n)->(2m+n,m)  C:(m,n)->(m+2n,n)")
    pairs = [(2, 1), (5, 2), (7, 4), (11, 3)]
    for (m, n) in pairs:
        v = eu(m, n)
        check(f"  A on eu({m},{n})", gen_A(v) == eu(2 * m - n, m))
        check(f"  B on eu({m},{n})", gen_B(v) == eu(2 * m + n, m))
        check(f"  C on eu({m},{n})", gen_C(v) == eu(m + 2 * n, n))
        check(f"  charge at (1,0) is 2*{n}^2 = {2*n*n}", charge(v, E1) == 2 * n * n)
        check(f"  charge at (0,1) is ({m}-{n})^2 = {(m-n)**2}", charge(v, E2) == (m - n) ** 2)
    print()
    print("  The three pure branches from the root, with their spoke indices:")
    print(f"    {'k':>3} | {'A^k root':>22} idx | {'B^k root':>26} idx | {'C^k root':>22} idx")
    va = vb = vc = ROOT
    for k in range(6):
        print(f"    {k:>3} | {str(va):>22} {spoke_index(va):>3} | "
              f"{str(vb):>26} {spoke_index(vb):>3} | {str(vc):>22} {spoke_index(vc):>3}")
        va, vb, vc = gen_A(va), gen_B(vb), gen_C(vc)
    print()
    print("  A-branch index = k+1 (slowest);  C-branch index frozen at 1 (one spoke);")
    print("  B-branch index = Pell number 1,2,5,12,29,70 (fastest), with 2^k <= n < 2*3^k:")
    pell = [1, 2]
    while len(pell) < 8:
        pell.append(2 * pell[-1] + pell[-2])
    print(f"    {'k':>3} {'2^k':>8} {'Pell_k':>8} {'2*3^k':>8}")
    for k in range(8):
        print(f"    {k:>3} {2**k:>8} {pell[k]:>8} {2*3**k:>8}")
        check(f"    sandwich at k={k}", (k == 0) or (2**k <= pell[k] < 2 * 3**k))


# --------------------------------------------------------------------------
# Demo 6 : escape-rate dichotomy
# --------------------------------------------------------------------------

def demo_dichotomy() -> None:
    banner("6.  Escape-rate dichotomy:  parabolic Theta(k^-2)  vs  hyperbolic O(3^-k)")
    sqrt2_over_2 = Decimal(2).sqrt() / 2
    print(f"    {'k':>3} | {'1 - x(C^k r)':>16} {'2/(17k^2)':>14} | "
          f"{'|x(B^k r)-r2/2|':>18} {'1/(5*3^k)':>14}")
    vc = vb = ROOT
    for k in range(1, 10):
        vc, vb = gen_C(vc), gen_B(vb)
        xc = Decimal(vc[0]) / Decimal(vc[2])
        xb = Decimal(vb[0]) / Decimal(vb[2])
        lhs_c = 1 - xc
        bound_c = Decimal(2) / Decimal(17 * k * k)
        lhs_b = abs(xb - sqrt2_over_2)
        bound_b = Decimal(1) / Decimal(5 * 3 ** k)
        print(f"    {k:>3} | {lhs_c:>16.10f} {bound_c:>14.10f} | "
              f"{lhs_b:>18.14f} {bound_b:>14.10f}")
        check(f"    parabolic lower bound at k={k}", lhs_c >= bound_c)
        check(f"    hyperbolic upper bound at k={k}", lhs_b <= bound_b)
    print()
    print("  Irrationality obstruction: x(v) = a/c is always rational, but the")
    print("  hyperbolic limit is sqrt(2)/2, irrational.  Hence NO triple is ever")
    print("  plotted at angle pi/4: there is no star there, only one geodesic.")
    print(f"    sqrt(2)/2 = {sqrt2_over_2}")
    print(f"    closest tree node within c <= 5000 : ", end="")
    best = min((v for _, v in tree_nodes(5000)),
               key=lambda v: abs(Decimal(v[0]) / Decimal(v[2]) - sqrt2_over_2))
    print(f"{best},  x = {Decimal(best[0])/Decimal(best[2]):.14f}")


# --------------------------------------------------------------------------
# Demo 7 : star location and multiplicity
# --------------------------------------------------------------------------

def demo_stars() -> None:
    banner("7.  A star at every node, each with infinitely many spokes")
    print("  Transport identities that move the star around the tree:")
    check(f"    A(1,0,1) = (3,4,5)", gen_A(E1) == ROOT)
    check(f"    B(1,0,1) = (3,4,5)", gen_B(E1) == ROOT)
    check(f"    C(1,0,1) = (1,0,1)", gen_C(E1) == E1)
    print()
    print("  The tree spokes T(n,j) = C^j A^n root at the ideal point (1,0):")
    print("  (row n is one spoke; the charge is constant along a row and equals 2(n+1)^2)")
    for n in range(4):
        v = ROOT
        for _ in range(n):
            v = gen_A(v)
        row: List[Triple] = []
        w = v
        for _ in range(4):
            row.append(w)
            w = gen_C(w)
        charges = {charge(t, E1) for t in row}
        print(f"    n={n}: charge {charges.pop():>3}   " +
              "  ".join(str(t) for t in row))
    print()
    print("  Star at the ROOT (3,4,5): the family A C^j (3,4,5) converges to (3/5,4/5)")
    print(f"    {'j':>3} {'node':>28} {'dir x':>14} {'dir y':>14}")
    w = ROOT
    for j in range(7):
        node = gen_A(w)
        x, y = dir_point(node)
        print(f"    {j:>3} {str(node):>28} {float(x):>14.9f} {float(y):>14.9f}")
        check(f"      charge 2 at the root", charge(node, ROOT) == 2)
        w = gen_C(w)
    print(f"    limit                                {3/5:>14.9f} {4/5:>14.9f}")
    print()
    print("  Quantitative separation of spokes:")
    print("    at EQUAL hypotenuse the squared chordal distances are in the ratio d/d'.")
    # eu(8,1) = (63,16,65) and eu(7,4) = (33,56,65): same hypotenuse, different charge.
    v1, v2 = eu(8, 1), eu(7, 4)
    d1, d2 = charge(v1, E1), charge(v2, E1)
    print(f"      eu(8,1) = {v1}, c = {v1[2]}, charge d  = {d1}")
    print(f"      eu(7,4) = {v2}, c = {v2[2]}, charge d' = {d2}")
    check(f"      equal hypotenuse", v1[2] == v2[2])
    r_chord = chord_sq(v1, E1) / chord_sq(v2, E1)
    check(f"      chord^2 ratio {r_chord} equals d/d' = {Fraction(d1, d2)}",
          r_chord == Fraction(d1, d2))


# --------------------------------------------------------------------------
# Demo 8 : completeness and the Lyapunov bound
# --------------------------------------------------------------------------

def demo_completeness_and_growth() -> None:
    banner("8.  Completeness of the tree, and the two-sided Lyapunov bound")
    N = 300
    from_tree = sorted(v for _, v in tree_nodes(N))
    brute = sorted(t for t in all_primitive_odd_leg(N) if t[0] % 2 == 1)
    check(f"tree with c <= {N} equals the brute-force list "
          f"({len(from_tree)} vs {len(brute)} triples)", from_tree == brute)
    print()
    print("  Address recovery by Fermat descent:")
    for t in [(3, 4, 5), (5, 12, 13), (21, 20, 29), (119, 120, 169), (33, 56, 65)]:
        w = descend(t)
        check(f"    {str(t):>16} -> address {w!r:>10}  (round-trip)",
              apply_word(w) == t)
    print()
    print("  Lyapunov sandwich  5*3^{#B} <= c <= 5*7^{len}:")
    print(f"    {'address':>10} {'5*3^#B':>10} {'c':>12} {'5*7^len':>12}")
    for w in ["", "A", "B", "C", "ABC", "BBC", "CCC", "BABC", "BBBB", "CCCCC"]:
        v = apply_word(w)
        lo = 5 * 3 ** w.count("B")
        hi = 5 * 7 ** len(w)
        print(f"    {w!r:>10} {lo:>10} {v[2]:>12} {hi:>12}")
        check(f"      sandwich for {w!r}", lo <= v[2] <= hi)
    print()
    print("  Spoke index vs depth:  n < 2*3^depth, universally.")
    print(f"    {'depth':>6} {'max index seen':>16} {'2*3^depth':>12}")
    by_depth: Dict[int, int] = {}
    for word, v in tree_nodes(2 * 10 ** 6):
        d = len(word)
        by_depth[d] = max(by_depth.get(d, 0), spoke_index(v))
    for d in sorted(by_depth)[:9]:
        print(f"    {d:>6} {by_depth[d]:>16} {2*3**d:>12}")
        check(f"      bound at depth {d}", by_depth[d] < 2 * 3 ** d)


# --------------------------------------------------------------------------
# Demo 9 : the drawn picture
# --------------------------------------------------------------------------

def demo_drawn_curve() -> None:
    banner("9.  The drawn curve:  ||dir v - dir p||^2 = 2 d (1 - r) / c_p,  r = 1 - 1/c")
    p = E1
    for n in (1, 3):
        d = 2 * n * n
        print(f"  spoke index n = {n} (charge d = {d}) at the boundary point (1,0):")
        print(f"    {'m':>5} {'c':>10} {'drawn radius r':>18} {'chord^2':>22} "
              f"{'2d(1-r)/c_p':>22}")
        for m in (n + 1, n + 2, n + 5, n + 20, n + 100):
            v = eu(m, n)
            r = Fraction(1) - Fraction(1, v[2])
            lhs = chord_sq(v, p)
            rhs = 2 * d * (1 - r) / Fraction(p[2])
            print(f"    {m:>5} {v[2]:>10} {float(r):>18.12f} {str(lhs):>22} "
                  f"{str(rhs):>22}")
            check("      drawn-curve equation", lhs == rhs)
        print()


# --------------------------------------------------------------------------

def main() -> None:
    print(__doc__)
    demo_lorentz()
    demo_chord_charge()
    demo_tangency()
    demo_quantization()
    demo_euclid()
    demo_dichotomy()
    demo_stars()
    demo_completeness_and_growth()
    demo_drawn_curve()
    banner("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
