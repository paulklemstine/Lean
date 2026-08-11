"""
Tropical ideals and their matroids: numerical demonstrations.
=============================================================

Everything in this file works over the min-plus semiring

    T = Q u {oo},    a (+) b = min(a, b),    a (*) b = a + b,

whose additive identity is oo and whose multiplicative identity is 0.

The script demonstrates, with explicit numbers:

  1. Tropical hyperplanes  H(c) = { x : min_i (c_i + x_i) attained at least twice }.
  2. The constructive VECTOR ELIMINATION algorithm: given x, y in H(c) agreeing at a
     coordinate e with a finite value, produce z in H(c) with z_e = oo, z >= x (+) y,
     and z = x (+) y at every coordinate where x and y differ.  Verified on random data.
  3. The RIGIDITY phenomenon: a "lonely minimum" of the truncated tropical sum can only
     occur at a coordinate where x and y agree.
  4. SHARPNESS: for c1 = (0,0,0,0), c2 = (0,0,0,1) the intersection H(c1) n H(c2) is a
     subsemimodule but admits no elimination witness (exhaustive search on a grid).
  5. CIRCUITS: the minimal supports of a tropical hyperplane with finite coefficients are
     exactly the two-element subsets (the uniform matroid U_{n-1,n}).
  6. The VANISHING IDEAL of a rational point: tropical polynomials whose term values
     attain their minimum at least twice.  Closure under tropical addition and under
     multiplication by an arbitrary polynomial; every truncation to a finite monomial
     set is exactly a tropical hyperplane; degreewise elimination on polynomials.

Run with:  python3 demo.py
"""

from __future__ import annotations

import itertools
import random
from fractions import Fraction
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

# ----------------------------------------------------------------------------------
# The tropical semiring  T = Q u {oo}.  We encode oo as None.
# ----------------------------------------------------------------------------------

Trop = Optional[Fraction]  # None means the tropical zero, oo
Vector = Tuple[Trop, ...]
Exponent = Tuple[int, ...]
Poly = Dict[Exponent, Trop]  # tropical polynomial: exponent -> tropical coefficient

INF: Trop = None


def q(value: object) -> Fraction:
    """Convenience constructor for an exact rational."""
    return Fraction(value)  # type: ignore[arg-type]


def tadd(a: Trop, b: Trop) -> Trop:
    """Tropical addition: min, with oo absorbing nothing (it is the neutral element)."""
    if a is INF:
        return b
    if b is INF:
        return a
    return a if a <= b else b


def tmul(a: Trop, b: Trop) -> Trop:
    """Tropical multiplication: ordinary addition, with oo absorbing."""
    if a is INF or b is INF:
        return INF
    return a + b


def tle(a: Trop, b: Trop) -> bool:
    """Tropical order: a <= b, with oo as the top element."""
    if b is INF:
        return True
    if a is INF:
        return False
    return a <= b


def tlt(a: Trop, b: Trop) -> bool:
    """Strict tropical order."""
    return tle(a, b) and not tle(b, a)


def tsub(a: Trop, b: Trop) -> Trop:
    """Tropical division a / b = a - b, defined for finite b (b is invertible)."""
    assert b is not INF, "cannot divide by the tropical zero"
    if a is INF:
        return INF
    return a - b


def show(a: Trop) -> str:
    return "oo" if a is INF else str(a)


def show_vec(x: Sequence[Trop]) -> str:
    return "(" + ", ".join(show(v) for v in x) + ")"


# ----------------------------------------------------------------------------------
# 1. Tropical hyperplanes
# ----------------------------------------------------------------------------------


def adjusted(c: Sequence[Trop], x: Sequence[Trop]) -> List[Trop]:
    """The adjusted values c_i (*) x_i = c_i + x_i."""
    return [tmul(ci, xi) for ci, xi in zip(c, x)]


def in_hyperplane(c: Sequence[Trop], x: Sequence[Trop]) -> bool:
    """Membership in H(c): for every i there is j != i with c_j + x_j <= c_i + x_i.

    Over a finite index set this is exactly 'the minimum is attained at least twice'.
    """
    vals = adjusted(c, x)
    n = len(vals)
    for i in range(n):
        if not any(tle(vals[j], vals[i]) for j in range(n) if j != i):
            return False
    return True


def min_attained_twice(c: Sequence[Trop], x: Sequence[Trop]) -> bool:
    """The classical formulation of tropical vanishing, for cross-checking."""
    vals = adjusted(c, x)
    finite = [v for v in vals if v is not INF]
    if not finite:
        return True  # all terms are oo: the tropically zero vector
    lo = min(finite)
    return sum(1 for v in vals if v is not INF and v == lo) >= 2


def trop_sum(x: Sequence[Trop], y: Sequence[Trop]) -> Vector:
    """Coordinatewise tropical sum x (+) y."""
    return tuple(tadd(a, b) for a, b in zip(x, y))


def trop_scale(a: Trop, x: Sequence[Trop]) -> Vector:
    """Tropical scaling a (*) x."""
    return tuple(tmul(a, xi) for xi in x)


# ----------------------------------------------------------------------------------
# 2. Algorithm A: the constructive elimination witness
# ----------------------------------------------------------------------------------


def eliminate(c: Sequence[Trop], x: Sequence[Trop], y: Sequence[Trop], e: int) -> Vector:
    """Given x, y in H(c) with x_e = y_e finite, return z in H(c) with

        (E1) z_e = oo,
        (E2) z_i >= min(x_i, y_i) for all i,
        (E3) z_i  = min(x_i, y_i) wherever x_i != y_i.

    Step 1 truncates the tropical sum at e.  If the truncation already lies in H(c) we
    are done.  Otherwise its adjusted values have a strictly unique minimum at some i_0
    (necessarily a coordinate where x and y agree, by the rigidity lemma), and we raise
    that coordinate to the level of the runner-up value.  Cost: O(n).
    """
    n = len(c)
    assert x[e] == y[e] and x[e] is not INF
    z: List[Trop] = [tadd(x[i], y[i]) for i in range(n)]
    z[e] = INF
    if in_hyperplane(c, z):
        return tuple(z)

    vals = adjusted(c, z)
    # the strictly unique minimiser
    i0 = min(range(n), key=lambda i: (vals[i] is INF, vals[i] if vals[i] is not INF else 0))
    assert all(tlt(vals[i0], vals[j]) for j in range(n) if j != i0)
    others = [vals[j] for j in range(n) if j != i0]
    beta: Trop = INF
    for v in others:
        beta = tadd(beta, v)
    z[i0] = INF if beta is INF else tsub(beta, c[i0])
    return tuple(z)


def check_elimination(c: Sequence[Trop], x: Sequence[Trop], y: Sequence[Trop], e: int,
                      z: Sequence[Trop]) -> bool:
    """Verify (E1), (E2), (E3) and membership for a claimed elimination witness."""
    if not in_hyperplane(c, z):
        return False
    if z[e] is not INF:
        return False
    for i in range(len(c)):
        m = tadd(x[i], y[i])
        if not tle(m, z[i]):
            return False
        if x[i] != y[i] and z[i] != m:
            return False
    return True


# ----------------------------------------------------------------------------------
# Random generation of hyperplane members, for stress testing
# ----------------------------------------------------------------------------------


def random_member(c: Sequence[Trop], rng: random.Random, e: int, value: Trop) -> Vector:
    """A random member of H(c) whose e-th coordinate equals the prescribed finite value.

    Construction: choose the coordinate values freely, then repair the vector by
    lowering the coordinate carrying the second-smallest adjusted value until the
    minimum is attained twice.  If the repair would touch coordinate e we retry.
    """
    n = len(c)
    while True:
        x: List[Trop] = []
        for i in range(n):
            if i == e:
                x.append(value)
            elif rng.random() < 0.15:
                x.append(INF)
            else:
                x.append(Fraction(rng.randint(-4, 4)))
        vals = adjusted(c, x)
        order = sorted((i for i in range(n) if vals[i] is not INF),
                       key=lambda i: vals[i])  # type: ignore[arg-type]
        if len(order) < 2:
            continue
        i_min, i_second = order[0], order[1]
        if vals[i_min] == vals[i_second]:
            return tuple(x)
        if i_second == e:
            continue
        # lower coordinate i_second so that its adjusted value ties with the minimum
        x[i_second] = tsub(vals[i_min], c[i_second])
        cand = tuple(x)
        if in_hyperplane(c, cand) and cand[e] == value:
            return cand


# ----------------------------------------------------------------------------------
# 5. Circuits
# ----------------------------------------------------------------------------------


def support(x: Sequence[Trop]) -> Tuple[int, ...]:
    return tuple(i for i, v in enumerate(x) if v is not INF)


def pair_vector(c: Sequence[Trop], i: int, j: int) -> Vector:
    """The member of H(c) with support exactly {i, j}: x_i = -c_i, x_j = -c_j."""
    n = len(c)
    assert c[i] is not INF and c[j] is not INF
    return tuple(tsub(Fraction(0), c[k]) if k in (i, j) else INF for k in range(n))


def circuits_by_search(c: Sequence[Trop], grid: Sequence[Trop]) -> List[Tuple[int, ...]]:
    """Brute-force the minimal supports of H(c) over a finite grid of coordinate values."""
    n = len(c)
    supports = set()
    for x in itertools.product(list(grid) + [INF], repeat=n):
        if any(v is not INF for v in x) and in_hyperplane(c, x):
            supports.add(support(x))
    minimal = [s for s in supports
               if not any(set(t) < set(s) for t in supports if t)]
    return sorted(minimal)


# ----------------------------------------------------------------------------------
# 6. Tropical polynomials and the vanishing ideal of a point
# ----------------------------------------------------------------------------------


def mon_val(w: Sequence[Fraction], u: Exponent) -> Fraction:
    """<u, w> = sum_i u_i w_i."""
    return sum((Fraction(ui) * wi for ui, wi in zip(u, w)), Fraction(0))


def term_values(f: Poly, w: Sequence[Fraction]) -> Dict[Exponent, Trop]:
    """val_u(f) = coeff_u(f) + <u, w>, computed on the support of f."""
    return {u: tmul(cf, mon_val(w, u)) for u, cf in f.items() if cf is not INF}


def vanishes_at(f: Poly, w: Sequence[Fraction]) -> bool:
    """f vanishes at w: the minimum of the term values is attained at least twice."""
    vals = [v for v in term_values(f, w).values() if v is not INF]
    if not vals:
        return True
    lo = min(vals)
    return sum(1 for v in vals if v == lo) >= 2


def poly_add(f: Poly, g: Poly) -> Poly:
    """Tropical addition of polynomials: coefficientwise minimum."""
    out: Poly = {}
    for u in set(f) | set(g):
        out[u] = tadd(f.get(u, INF), g.get(u, INF))
    return {u: v for u, v in out.items() if v is not INF}


def poly_mul(f: Poly, g: Poly) -> Poly:
    """Tropical multiplication: coeff_v(fg) = min_{p+q=v} (coeff_p f + coeff_q g)."""
    out: Poly = {}
    for p, a in f.items():
        for r, b in g.items():
            v = tuple(pi + ri for pi, ri in zip(p, r))
            out[v] = tadd(out.get(v, INF), tmul(a, b))
    return {u: v for u, v in out.items() if v is not INF}


def coeff_vector(f: Poly, monomials: Sequence[Exponent]) -> Vector:
    """The truncation of f to a finite monomial set."""
    return tuple(f.get(u, INF) for u in monomials)


def weight_vector(w: Sequence[Fraction], monomials: Sequence[Exponent]) -> Vector:
    """The evaluation weight vector (<u, w>)_{u in E}: the hyperplane coefficients."""
    return tuple(mon_val(w, u) for u in monomials)


def poly_from_vector(x: Sequence[Trop], monomials: Sequence[Exponent]) -> Poly:
    """The polynomial supported on E whose coefficient vector is x."""
    return {u: v for u, v in zip(monomials, x) if v is not INF}


# ----------------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def demo_hyperplane_basics() -> None:
    banner("1.  Tropical hyperplanes: the minimum must be attained twice")
    c: Vector = (q(0), q(1), q(3), q(0))
    tests: List[Vector] = [
        (q(2), q(1), q(0), q(2)),   # adjusted (2,2,3,2): min 2 attained thrice
        (q(0), q(1), q(0), q(5)),   # adjusted (0,2,3,5): lonely minimum -> not a member
        (INF, q(0), q(-2), INF),    # adjusted (oo,1,1,oo): min 1 attained twice
        (INF, INF, INF, INF),       # the tropical zero vector
    ]
    print(f"coefficients c = {show_vec(c)}\n")
    for x in tests:
        vals = adjusted(c, x)
        print(f"  x = {show_vec(x):28s} adjusted = {show_vec(vals):28s} "
              f"in H(c): {in_hyperplane(c, x)}")
        assert in_hyperplane(c, x) == min_attained_twice(c, x)
    print("\n  (relational definition and 'minimum attained twice' agree in all cases)")

    banner("1b. H(c) is a tropical subsemimodule")
    x = (q(2), q(1), q(0), q(2))
    y = (INF, q(0), q(-2), INF)
    s = trop_sum(x, y)
    t = trop_scale(q(5), x)
    print(f"  x        = {show_vec(x)}   in H(c): {in_hyperplane(c, x)}")
    print(f"  y        = {show_vec(y)}   in H(c): {in_hyperplane(c, y)}")
    print(f"  x (+) y  = {show_vec(s)}   in H(c): {in_hyperplane(c, s)}")
    print(f"  5 (*) x  = {show_vec(t)}   in H(c): {in_hyperplane(c, t)}")
    assert in_hyperplane(c, s) and in_hyperplane(c, t)


def demo_elimination() -> None:
    banner("2.  Vector elimination: a worked example")
    c: Vector = (q(0), q(1), q(-2), q(-1))
    x: Vector = (q(2), q(5), q(4), q(5))
    y: Vector = (q(2), q(9), q(4), q(7))
    print(f"  c = {show_vec(c)}")
    print(f"  x = {show_vec(x)}   in H(c): {in_hyperplane(c, x)}   adjusted {show_vec(adjusted(c,x))}")
    print(f"  y = {show_vec(y)}   in H(c): {in_hyperplane(c, y)}   adjusted {show_vec(adjusted(c,y))}")
    e = 0
    z = eliminate(c, x, y, e)
    print(f"\n  eliminating coordinate e = {e} (where x_e = y_e = {show(x[e])}):")
    print(f"  truncated sum   = {show_vec(tuple(INF if i == e else tadd(x[i], y[i]) for i in range(4)))}")
    print(f"  witness z       = {show_vec(z)}")
    print(f"  z in H(c)       : {in_hyperplane(c, z)}")
    print(f"  all of (E1),(E2),(E3): {check_elimination(c, x, y, e, z)}")
    assert check_elimination(c, x, y, e, z)

    banner("2b. Randomised stress test of the elimination algorithm")
    rng = random.Random(20260811)
    trials, repaired = 0, 0
    for _ in range(4000):
        n = rng.randint(3, 6)
        c = tuple(Fraction(rng.randint(-3, 3)) for _ in range(n))
        e = rng.randrange(n)
        value = Fraction(rng.randint(-3, 3))
        x = random_member(c, rng, e, value)
        y = random_member(c, rng, e, value)
        z = eliminate(c, x, y, e)
        assert check_elimination(c, x, y, e, z), (c, x, y, e, z)
        trials += 1
        truncated = tuple(INF if i == e else tadd(x[i], y[i]) for i in range(n))
        if not in_hyperplane(c, truncated):
            repaired += 1
    print(f"  {trials} random instances, all elimination witnesses verified.")
    print(f"  In {repaired} of them the naive truncation was NOT a member and the")
    print(f"  'raise the lonely minimum' repair was genuinely needed "
          f"({100.0 * repaired / trials:.1f}%).")


def demo_rigidity() -> None:
    banner("3.  Rigidity: a lonely minimum sits where x and y agree")
    rng = random.Random(4711)
    checked = 0
    for _ in range(4000):
        n = rng.randint(3, 6)
        c = tuple(Fraction(rng.randint(-3, 3)) for _ in range(n))
        e = rng.randrange(n)
        value = Fraction(rng.randint(-3, 3))
        x = random_member(c, rng, e, value)
        y = random_member(c, rng, e, value)
        z0 = [tadd(x[i], y[i]) for i in range(n)]
        z0[e] = INF
        if in_hyperplane(c, z0):
            continue
        vals = adjusted(c, z0)
        i0 = min((i for i in range(n)), key=lambda i: (vals[i] is INF,
                                                       vals[i] if vals[i] is not INF else 0))
        assert all(tlt(vals[i0], vals[j]) for j in range(n) if j != i0)
        assert i0 != e
        assert x[i0] == y[i0], "rigidity lemma violated!"
        checked += 1
    print(f"  {checked} instances with a lonely minimum examined;")
    print("  in every one of them the two inputs already agreed at that coordinate,")
    print("  which is exactly what licenses raising it without violating (E3).")


def demo_sharpness() -> None:
    banner("4.  Sharpness: an intersection of hyperplanes failing elimination")
    c1: Vector = (q(0), q(0), q(0), q(0))
    c2: Vector = (q(0), q(0), q(0), q(1))
    x: Vector = (q(0), q(0), q(1), q(0))
    y: Vector = (q(0), q(0), q(1), q(1))
    print(f"  c1 = {show_vec(c1)}   c2 = {show_vec(c2)}")
    for name, v in (("x", x), ("y", y)):
        print(f"  {name} = {show_vec(v)}  in H(c1): {in_hyperplane(c1, v)}  "
              f"in H(c2): {in_hyperplane(c2, v)}")
    assert all(in_hyperplane(c, v) for c in (c1, c2) for v in (x, y))

    print("\n  The intersection is a subsemimodule (closed under (+) and scaling):")
    s = trop_sum(x, y)
    t = trop_scale(q(-2), x)
    print(f"    x (+) y   = {show_vec(s)}  in both: "
          f"{in_hyperplane(c1, s) and in_hyperplane(c2, s)}")
    print(f"    -2 (*) x  = {show_vec(t)}  in both: "
          f"{in_hyperplane(c1, t) and in_hyperplane(c2, t)}")

    e = 0
    grid: List[Trop] = [Fraction(k, 2) for k in range(-6, 9)] + [INF]
    found = []
    for z in itertools.product(grid, repeat=4):
        if not (in_hyperplane(c1, z) and in_hyperplane(c2, z)):
            continue
        if check_elimination(c1, x, y, e, z) and check_elimination(c2, x, y, e, z):
            found.append(z)
    print(f"\n  Exhaustive search over {len(grid)}^4 = {len(grid) ** 4} candidate vectors")
    print(f"  (half-integers in [-3, 4] together with oo) for an elimination witness at e = 0:")
    print(f"    witnesses found: {len(found)}")
    assert not found
    print("\n  Why none can exist, in general:")
    print("    (E1) forces z_1 = oo;   (E3) pins z_4 = min(0,1) = 0;")
    print("    (E2) gives z_2 >= 0 and z_3 >= 1.")
    print("    Membership in H(c1) tested at coordinate 4 then forces z_2 = 0,")
    print("    and membership in H(c2) tested at coordinate 2 needs some")
    print("    c2_k + z_k <= 0 with k != 2 -- but the options are oo, >= 1 and 1.")
    print("    Contradiction: tropical linear spaces are NOT closed under intersection.")


def demo_circuits() -> None:
    banner("5.  Circuits: the matroid of a tropical hyperplane is uniform")
    c: Vector = (q(0), q(2), q(-1), q(1))
    n = len(c)
    print(f"  c = {show_vec(c)}   (all coefficients finite)\n")
    for i, j in itertools.combinations(range(n), 2):
        v = pair_vector(c, i, j)
        print(f"    support {{{i},{j}}}: x = {show_vec(v)}  in H(c): {in_hyperplane(c, v)}")
        assert in_hyperplane(c, v) and support(v) == (i, j)
    grid = [Fraction(k) for k in range(-4, 5)]
    minimal = circuits_by_search(c, grid)
    print(f"\n  Minimal supports found by brute force over integers in [-4,4]:")
    print(f"    {[list(s) for s in minimal]}")
    assert all(len(s) == 2 for s in minimal)
    assert len(minimal) == n * (n - 1) // 2
    print(f"  All {len(minimal)} of them have exactly two elements:")
    print(f"  the underlying matroid is the uniform matroid U_{{{n-1},{n}}}.")

    print("\n  Circuit elimination C3 <= (C1 u C2) \\ {e} is then automatic for pairs:")
    c1s, c2s, e = {0, 1}, {1, 2}, 1
    print(f"    C1 = {sorted(c1s)}, C2 = {sorted(c2s)}, e = {e}  ->  "
          f"C3 = {sorted((c1s | c2s) - {e})} is again a circuit.")


def demo_point_ideal() -> None:
    banner("6.  The vanishing ideal of a point")
    w = (Fraction(1), Fraction(-2))  # the point w = (1, -2) in Q^2
    print(f"  point w = ({w[0]}, {w[1]})")
    print("  a tropical polynomial is a finite map  exponent -> tropical coefficient;")
    print("  it vanishes at w when min_u (coeff_u + <u,w>) is attained at least twice.\n")

    # f = 0 (*) x^(1,0)  (+)  1 (*) x^(0,1)  vanishes at w:
    #   val(1,0) = 0 + 1 = 1 ; val(0,1) = 3 + (-2) = 1
    f: Poly = {(1, 0): q(0), (0, 1): q(3)}
    g: Poly = {(0, 0): q(0), (1, 1): q(1)}     # val = 0 and 1 + (-1) = 0: also vanishes
    h: Poly = {(0, 0): q(0), (2, 0): q(5)}     # val = 0 and 7: lonely minimum

    for name, p in (("f", f), ("g", g), ("h", h)):
        vals = term_values(p, w)
        pretty = ", ".join(f"x^{u}: {show(v)}" for u, v in sorted(vals.items()))
        print(f"  {name}: term values  {pretty}   vanishes: {vanishes_at(p, w)}")
    assert vanishes_at(f, w) and vanishes_at(g, w) and not vanishes_at(h, w)

    print("\n  Closure under tropical addition:")
    fg = poly_add(f, g)
    print(f"    f (+) g  has support {sorted(fg)}   vanishes: {vanishes_at(fg, w)}")
    assert vanishes_at(fg, w)

    print("\n  Closure under multiplication by an ARBITRARY polynomial "
          "(the substantive point):")
    rng = random.Random(31415)
    for trial in range(5):
        arbitrary: Poly = {}
        for _ in range(rng.randint(1, 3)):
            u = (rng.randint(0, 3), rng.randint(0, 3))
            arbitrary[u] = Fraction(rng.randint(-4, 4))
        prod = poly_mul(f, arbitrary)
        ok = vanishes_at(prod, w)
        print(f"    trial {trial + 1}: f * (support {sorted(arbitrary)}) "
              f"-> support {sorted(prod)}   vanishes: {ok}")
        assert ok
    print("\n    Certificate: if a, a' are two distinct minimisers of val(f) and b is any")
    print("    minimiser of val(g), then a+b and a'+b are distinct exponents at which")
    print("    the product attains its global minimum.")

    banner("6b. Truncations are exactly tropical hyperplanes")
    monomials: List[Exponent] = [(0, 0), (1, 0), (0, 1), (1, 1)]
    pi = weight_vector(w, monomials)
    print(f"  monomial set E = {monomials}")
    print(f"  evaluation weights  pi_w = {show_vec(pi)}   (these are the hyperplane coefficients)\n")

    # Direction 1: coefficient vectors of vanishing polynomials land in H(pi_w).
    rng = random.Random(2718)
    checked = 0
    for _ in range(3000):
        vec = tuple(INF if rng.random() < 0.25 else Fraction(rng.randint(-4, 4))
                    for _ in monomials)
        p = poly_from_vector(vec, monomials)
        assert vanishes_at(p, w) == in_hyperplane(pi, vec)
        checked += 1
    print(f"  {checked} random coefficient vectors tested: in every case")
    print("    'the polynomial vanishes at w'  <=>  'the vector lies in H(pi_w)'.")

    banner("6c. Degreewise elimination on polynomials")
    # two vanishing polynomials supported on E agreeing in one coefficient
    vx: Vector = (q(2), q(5), q(4), q(5))
    vy: Vector = (q(2), q(9), q(4), q(7))
    assert in_hyperplane(pi, vx) and in_hyperplane(pi, vy)
    e = 0
    vz = eliminate(pi, vx, vy, e)
    px, py, pz = (poly_from_vector(v, monomials) for v in (vx, vy, vz))
    print(f"  f coefficients on E: {show_vec(vx)}   vanishes: {vanishes_at(px, w)}")
    print(f"  g coefficients on E: {show_vec(vy)}   vanishes: {vanishes_at(py, w)}")
    print(f"  eliminating the monomial {monomials[e]} (equal, finite coefficient {show(vx[e])}):")
    print(f"  h coefficients on E: {show_vec(vz)}   vanishes: {vanishes_at(pz, w)}")
    print(f"  h has no {monomials[e]}-term: {vz[e] is INF}")
    print(f"  (E1),(E2),(E3) all hold: {check_elimination(pi, vx, vy, e, vz)}")
    assert vanishes_at(pz, w) and check_elimination(pi, vx, vy, e, vz)

    banner("6d. Uniform matroid in every degree")
    minimal = circuits_by_search(pi, [Fraction(k) for k in range(-3, 4)])
    print(f"  minimal supports of the truncation to E: {[list(s) for s in minimal]}")
    print(f"  all of size two: {all(len(s) == 2 for s in minimal)}  -> uniform matroid "
          f"U_{{{len(monomials)-1},{len(monomials)}}}")
    assert all(len(s) == 2 for s in minimal)


def demo_operations() -> None:
    banner("7.  Rescaling and deletion preserve tropical linear spaces")
    rng = random.Random(1234)
    n = 5
    c = tuple(Fraction(rng.randint(-3, 3)) for _ in range(n))
    a = tuple(Fraction(rng.randint(-3, 3)) for _ in range(n))
    print(f"  c = {show_vec(c)},  rescaling vector a = {show_vec(a)}")
    print("  Rescaling H(c) by a is again a hyperplane, with coefficients c - a:")
    c_scaled = tuple(tsub(ci, ai) for ci, ai in zip(c, a))
    ok = True
    for _ in range(2000):
        e = rng.randrange(n)
        x = random_member(c, rng, e, Fraction(rng.randint(-3, 3)))
        rescaled = tuple(tmul(ai, xi) for ai, xi in zip(a, x))
        ok &= in_hyperplane(c_scaled, rescaled)
    print(f"    verified on 2000 random members: {ok}")
    assert ok

    print("\n  Deletion: members supported inside S, restricted to S.")
    S = (0, 1, 2)
    deleted: List[Vector] = []
    for _ in range(5000):
        e = rng.randrange(n)
        x = random_member(c, rng, e, Fraction(rng.randint(-3, 3)))
        if all(x[i] is INF for i in range(n) if i not in S):
            deleted.append(tuple(x[i] for i in S))
    uniq = sorted(set(deleted), key=lambda v: tuple(show(t) for t in v))[:4]
    c_S = tuple(c[i] for i in S)
    print(f"    S = {list(S)};  sample of the deletion: "
          f"{[show_vec(v) for v in uniq]}")
    print(f"    each lies in the smaller hyperplane H(c|S) = H({show_vec(c_S)}): "
          f"{all(in_hyperplane(c_S, v) for v in deleted)}")
    assert all(in_hyperplane(c_S, v) for v in deleted)


def main() -> None:
    demo_hyperplane_basics()
    demo_elimination()
    demo_rigidity()
    demo_sharpness()
    demo_circuits()
    demo_point_ideal()
    demo_operations()
    print()
    print("=" * 78)
    print("All demonstrations completed and all assertions verified.")
    print("=" * 78)


if __name__ == "__main__":
    main()
