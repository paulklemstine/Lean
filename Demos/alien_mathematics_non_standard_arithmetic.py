"""
Alien Arithmetic: numerical demonstrations of nonstandard arithmetic.
=====================================================================

A hypernatural is an equivalence class of sequences of naturals, two sequences
being identified when they agree on a "large" set of coordinates (a set in a
fixed nonprincipal ultrafilter).  The ultrafilter itself is not constructible,
but *every* proof in the theory produces an explicit sequence, and every
statement of the form "P(i) holds for almost all i" is witnessed, in the proofs
we demonstrate here, by the far stronger "P(i) holds for all i >= N".

That is exactly what this file computes.  We work with sequences truncated at a
finite horizon and, for each theorem, we exhibit the *threshold* N beyond which
the coordinatewise statement holds unconditionally -- because a cofinite set is
always large, such a threshold certifies the nonstandard statement.

Sections
--------
 1. Germs, order, standard elements and omega
 2. Staircase germs: continuum many unlimited hypernaturals
 3. Galaxies: same-galaxy, far-above, density, descending scales
 4. The diagonal witness: overspill and countable saturation
 5. Number theory: hyperprimes, Fermat, Wilson, Euclidean division
 6. Prime-free galaxies: long composite runs around i! + i/2
 7. Robinson's criterion and nonstandard Bolzano-Weierstrass

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, List, Optional, Sequence, Set, Tuple

Seq = Callable[[int], int]

HORIZON: int = 2000


# ---------------------------------------------------------------------------
# 1. Germs, order, standard elements and omega
# ---------------------------------------------------------------------------

def eventually_threshold(pred: Callable[[int], bool],
                         horizon: int = HORIZON,
                         run: int = 40) -> Optional[int]:
    """Smallest N <= horizon such that pred(i) holds for every i in [N, horizon],
    provided the certified run has length at least `run`.  Returns None if no
    such N exists inside the horizon.  A cofinite set is large in every
    nonprincipal ultrafilter, so a genuine threshold certifies "almost all i"."""
    last_failure = -1
    for i in range(horizon + 1):
        if not pred(i):
            last_failure = i
    n = last_failure + 1
    if n > horizon - run:
        return None
    return n


def standard(n: int) -> Seq:
    """The standard hypernatural n* = [i |-> n]."""
    return lambda i: n


def omega(i: int) -> int:
    """The unlimited hypernatural omega = [i |-> i]."""
    return i


def is_unlimited(f: Seq, levels: int = 12, horizon: int = HORIZON) -> bool:
    """[f] is unlimited iff for every standard n, f(i) > n for almost all i.
    We certify the first `levels` values of n by explicit thresholds."""
    return all(eventually_threshold(lambda i, n=n: f(i) > n, horizon) is not None
               for n in range(levels))


def germ_lt(f: Seq, g: Seq, horizon: int = HORIZON) -> bool:
    """[f] < [g], certified by a threshold beyond which f(i) < g(i) always."""
    return eventually_threshold(lambda i: f(i) < g(i), horizon) is not None


def section_1() -> None:
    print("=" * 78)
    print("1.  Germs, the standard embedding, and omega")
    print("=" * 78)
    print("  omega = [i |-> i].  For each standard n we exhibit the threshold N")
    print("  beyond which i > n holds at every coordinate:")
    for n in (0, 3, 10, 100):
        thr = eventually_threshold(lambda i, n=n: omega(i) > standard(n)(i))
        print(f"    n = {n:>4} :  n* < omega certified from coordinate N = {thr}")
    print(f"  omega is unlimited        : {is_unlimited(omega)}")
    print(f"  the standard 5* is unlimited: {is_unlimited(standard(5))}")
    print("  (a constant sequence is dominated by a larger standard number, so no")
    print("   threshold exists and the element is not unlimited)")
    print()


# ---------------------------------------------------------------------------
# 2. Staircase germs: continuum many unlimited hypernaturals
# ---------------------------------------------------------------------------

def staircase(r: float) -> Seq:
    """S_r = [i |-> floor(i * r)], unlimited for every r > 0."""
    return lambda i: math.floor(i * r)


def predicted_crossing(r: float, s: float) -> int:
    """Theoretical bound on the coordinate beyond which floor(i r) < floor(i s):
    any i > 1 / (s - r) works."""
    return math.ceil(1.0 / (s - r))


def section_2() -> None:
    print("=" * 78)
    print("2.  Staircases:  r |-> S_r = [i |-> floor(i*r)]  is strictly increasing")
    print("=" * 78)
    print("  Distinct positive slopes give distinct unlimited hypernaturals, so the")
    print("  model has at least continuum many elements (and at most, being a")
    print("  quotient of N^N).  Hence |*N| = c.")
    print()
    print(f"  {'r':>8} {'s':>10} {'observed N':>12} {'bound 1/(s-r)':>16}")
    for r, s in [(1.0, 2.0), (1.0, 1.1), (math.sqrt(2), math.sqrt(2) + 0.05),
                 (math.pi / 3, math.pi / 3 + 0.01), (0.5, 0.51)]:
        f, g = staircase(r), staircase(s)
        obs = eventually_threshold(lambda i: f(i) < g(i))
        print(f"  {r:8.5f} {s:10.5f} {str(obs):>12} {predicted_crossing(r, s):>16}")
    print()
    print("  Each staircase is unlimited:")
    for r in (0.05, 0.5, 1.0, 3.7):
        print(f"    r = {r:<6} unlimited: {is_unlimited(staircase(r))}")
    print()


# ---------------------------------------------------------------------------
# 3. Galaxies
# ---------------------------------------------------------------------------

def far_above(f: Seq, g: Seq, levels: int = 8, horizon: int = HORIZON) -> bool:
    """[f] < [g] in the strong sense: f(i) + n < g(i) almost everywhere, for
    every standard n.  Equivalently, g lies in a strictly higher galaxy."""
    return all(eventually_threshold(lambda i, n=n: f(i) + n < g(i), horizon) is not None
               for n in range(levels))


def same_galaxy(f: Seq, g: Seq, max_shift: int = 64, horizon: int = HORIZON) -> bool:
    """[f] ~ [g] iff |f - g| stays bounded by a *standard* constant a.e."""
    for n in range(max_shift + 1):
        ok_1 = eventually_threshold(lambda i, n=n: g(i) <= f(i) + n, horizon)
        ok_2 = eventually_threshold(lambda i, n=n: f(i) <= g(i) + n, horizon)
        if ok_1 is not None and ok_2 is not None:
            return True
    return False


def midpoint(f: Seq, g: Seq) -> Seq:
    """The witness of density of the galaxy order: f + (g - f)/2."""
    return lambda i: f(i) + (g(i) - f(i)) // 2


def halve(f: Seq) -> Seq:
    """Halving drops an unlimited element into a strictly lower galaxy."""
    return lambda i: f(i) // 2


def section_3() -> None:
    print("=" * 78)
    print("3.  Galaxies: a dense, unbounded order of scales")
    print("=" * 78)
    f = omega
    g = lambda i: i + 7                    # same galaxy as omega
    h = lambda i: 2 * i                    # far above omega
    print(f"  omega ~ omega+7   (same galaxy) : {same_galaxy(f, g)}")
    print(f"  omega ~ 2*omega   (same galaxy) : {same_galaxy(f, h)}")
    print(f"  omega < 2*omega   (far above)   : {far_above(f, h)}")
    m = midpoint(f, h)
    print(f"  midpoint M = [i + i//2]:  omega << M : {far_above(f, m)}"
          f"   and M << 2*omega : {far_above(m, h)}")
    print("  -> the galaxy order is dense.")
    print()
    print("  Descending chain of scales  omega >> omega/2 >> omega/4 >> ... :")
    chain: List[Seq] = [omega]
    for _ in range(5):
        chain.append(halve(chain[-1]))
    for k in range(len(chain) - 1):
        below, above = chain[k + 1], chain[k]
        print(f"    level {k+1}: unlimited = {is_unlimited(below)},"
              f"  far below level {k} = {far_above(below, above)}")
    print("  -> no least nonstandard galaxy; the Archimedean property fails at")
    print("     densely many different scales.")
    print()


# ---------------------------------------------------------------------------
# 4. The diagonal witness: overspill and countable saturation
# ---------------------------------------------------------------------------

def diagonal_witness(membership: Callable[[int, int], bool], i: int) -> int:
    """max{ k <= i : k in A_i }  (0 if none).  This single construction proves
    overspill, internal induction and internal completeness."""
    for k in range(i, -1, -1):
        if membership(k, i):
            return k
    return 0


def saturation_witness(conditions: Sequence[Callable[[int, int], bool]],
                       i: int, search: int = 200) -> Tuple[int, int]:
    """Diagonal for countable saturation: at coordinate i satisfy as many of the
    first conditions as that coordinate allows.  Returns (depth, witness)."""
    best_depth, best_x = -1, 0
    for n in range(min(i, len(conditions) - 1), -1, -1):
        for x in range(search):
            if all(conditions[k](x, i) for k in range(n + 1)):
                return n, x
        if best_depth < 0:
            best_depth, best_x = n, 0
    return max(best_depth, 0), best_x


def section_4() -> None:
    print("=" * 78)
    print("4.  The diagonal witness: overspill and countable saturation")
    print("=" * 78)
    # A_i = { k : k even }  contains every standard even number; overspill must
    # produce an *unlimited* even element.
    even_membership: Callable[[int, int], bool] = lambda k, i: k % 2 == 0
    f = lambda i: diagonal_witness(even_membership, i)
    print("  Internal set A_i = {even numbers} contains all standard evens.")
    print("  Diagonal witness f(i) = max{k <= i : k even}:")
    print("   ", [f(i) for i in range(10)], "...")
    print(f"    f is unlimited: {is_unlimited(f)}   -> overspill in action.")
    print()
    # Countable saturation: the n-th condition is "x > n and x is a multiple of 6".
    conds: List[Callable[[int, int], bool]] = [
        (lambda x, i, n=n: x > n and x % 6 == 0) for n in range(30)
    ]
    print("  Countable family: condition n says 'x > n and 6 | x'.")
    print("  Every finite subfamily is satisfiable; saturation yields one germ")
    print("  satisfying them all simultaneously.")
    print(f"  {'i':>4} {'depth d(i)':>12} {'witness f(i)':>14}")
    for i in (0, 1, 5, 12, 25, 29):
        d, x = saturation_witness(conds, i)
        print(f"  {i:>4} {d:>12} {x:>14}")
    g = lambda i: saturation_witness(conds, i)[1]
    thr = eventually_threshold(lambda i: g(i) > 20, horizon=120, run=20)
    print(f"  the diagonal germ eventually exceeds 20 from coordinate N = {thr}")
    print("  -> a single hypernatural lies in all countably many internal sets,")
    print("     whereas in N the sets {k : k > n} have empty intersection.")
    print()


# ---------------------------------------------------------------------------
# 5. Number theory in the model
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


_PRIME_CACHE: List[int] = [2]


def nth_prime(k: int) -> int:
    """The k-th prime (0-indexed), with memoization."""
    n = _PRIME_CACHE[-1]
    while len(_PRIME_CACHE) <= k:
        n += 1
        if is_prime(n):
            _PRIME_CACHE.append(n)
    return _PRIME_CACHE[k]


def min_fac(n: int) -> int:
    if n < 2:
        return n
    d = 2
    while d * d <= n:
        if n % d == 0:
            return d
        d += 1
    return n


def section_5() -> None:
    print("=" * 78)
    print("5.  Number theory: hyperprimes, Fermat, Wilson, Euclidean division")
    print("=" * 78)
    P = nth_prime            # the germ [i |-> p_i] of the sequence of primes
    print("  P = [i |-> p_i] is a hyperprime (every coordinate prime) and unlimited:")
    print("   ", [P(i) for i in range(10)], "...")
    print(f"    all coordinates prime (first 200): "
          f"{all(is_prime(P(i)) for i in range(200))}")
    print(f"    unlimited: {is_unlimited(P)}")
    print()
    print("  Fermat, with nonstandard base A = [i |-> i+2] and exponent P:")
    print(f"  {'i':>4} {'a':>6} {'p':>6} {'(a^p - a) mod p':>18}")
    for i in (0, 1, 2, 5, 9):
        a, p = i + 2, P(i)
        print(f"  {i:>4} {a:>6} {p:>6} {pow(a, p, p) - a % p:>18}")
    print("    -> p | a^p - a at every coordinate, hence P | A^P - A in the model.")
    print()
    print("  Wilson, for the internal factorial:")
    print(f"  {'i':>4} {'p':>6} {'((p-1)! + 1) mod p':>22}")
    for i in range(6):
        p = P(i)
        print(f"  {i:>4} {p:>6} {(math.factorial(p - 1) + 1) % p:>22}")
    print("    -> P | (P-1)! + 1 in the model.")
    print()
    print("  Euclidean division A = B*Q + R with A = [i^2 + 5], B = [i + 2]:")
    A: Seq = lambda i: i * i + 5
    B: Seq = lambda i: i + 2
    ok = all(A(i) == B(i) * (A(i) // B(i)) + A(i) % B(i) and A(i) % B(i) < B(i)
             for i in range(1, HORIZON))
    print(f"    identity and R < B verified coordinatewise: {ok}")
    print(f"    Q = {[A(i) // B(i) for i in range(6)]} ... ,"
          f"  R = {[A(i) % B(i) for i in range(6)]} ...")
    print("    quotient and remainder are unique, exactly as in N.")
    print()
    print("  Every hypernatural > 1 has a hyperprime divisor (internal minFac):")
    C: Seq = lambda i: (i + 2) * (i + 3)
    print(f"    C = [(i+2)(i+3)] -> minFac germ = {[min_fac(C(i)) for i in range(8)]} ...")
    print(f"    all coordinates prime: {all(is_prime(min_fac(C(i))) for i in range(200))}")
    print()


# ---------------------------------------------------------------------------
# 6. Prime-free galaxies
# ---------------------------------------------------------------------------

def composite_centre(i: int) -> int:
    """C = [i |-> i! + i//2], the middle of the composite run i!+2, ..., i!+i."""
    return math.factorial(i) + i // 2


def galaxy_window_is_prime_free(i: int, bandwidth: int) -> bool:
    """Is the whole window C(i) +- bandwidth composite?"""
    c = composite_centre(i)
    return all(not is_prime(c + delta) for delta in range(-bandwidth, bandwidth + 1))


def section_6() -> None:
    print("=" * 78)
    print("6.  Prime-free galaxies: whole scales that primes never visit")
    print("=" * 78)
    print("  Classical fact: i!+2, ..., i!+i are all composite (j divides i!+j).")
    print("  The germ C = [i! + i//2] sits in the middle of that run, so nothing")
    print("  within a *standard* distance m of C is prime once i >= 2m+8.")
    print()
    print(f"  {'bandwidth m':>12} {'theory: i >= 2m+8':>20} {'observed threshold':>20}")
    for m in (0, 1, 2, 3, 5, 8):
        observed = None
        for i in range(3, 60):
            if all(galaxy_window_is_prime_free(j, m) for j in range(i, min(i + 25, 60))):
                observed = i
                break
        print(f"  {m:>12} {2 * m + 8:>20} {str(observed):>20}")
    print()
    print("  Concretely, at i = 14 the window around C(14) = 14! + 7 is entirely")
    print("  composite:")
    c = composite_centre(14)
    for delta in range(-3, 4):
        n = c + delta
        print(f"    {n}  composite, smallest factor {min_fac(n)}")
    print()
    print("  So no hyperprime lies in the galaxy of C: primality is a")
    print("  galaxy-dependent property.  Some galaxies DO carry primes, e.g. the")
    print("  galaxy of [i |-> p_i]; but between the galaxies of [i!] and [i!+i]")
    print("  there is no prime-carrying galaxy at all.")
    print()


# ---------------------------------------------------------------------------
# 7. Robinson's criterion and Bolzano-Weierstrass
# ---------------------------------------------------------------------------

def star_seq(a: Callable[[int], float], f: Seq) -> Callable[[int], float]:
    """The nonstandard extension of the real sequence a, evaluated at [f]."""
    return lambda i: a(f(i))


def standard_part_estimate(x: Callable[[int], float],
                           horizon: int = HORIZON) -> Tuple[float, float]:
    """Estimate the standard part of a hyperreal germ by the tail of its
    coordinates, together with the tail oscillation (0 means a genuine limit)."""
    tail = [x(i) for i in range(horizon // 2, horizon)]
    return sum(tail) / len(tail), max(tail) - min(tail)


def section_7() -> None:
    print("=" * 78)
    print("7.  Robinson's criterion and nonstandard Bolzano-Weierstrass")
    print("=" * 78)
    a: Callable[[int], float] = lambda n: 1.0 + 1.0 / (n + 1)
    for name, idx in [("omega", omega), ("2*omega", lambda i: 2 * i),
                      ("omega^2", lambda i: i * i)]:
        st, osc = standard_part_estimate(star_seq(a, idx))
        print(f"  a_n = 1 + 1/(n+1)   at index {name:<8}: st = {st:.6f}, "
              f"tail spread = {osc:.2e}")
    print("  -> the same standard part 1 at every unlimited index: a_n -> 1.")
    print()
    b: Callable[[int], float] = lambda n: (-1.0) ** n
    st_even, _ = standard_part_estimate(star_seq(b, lambda i: 2 * i))
    st_odd, _ = standard_part_estimate(star_seq(b, lambda i: 2 * i + 1))
    print(f"  b_n = (-1)^n  at index [2i]   : st = {st_even:+.1f}")
    print(f"  b_n = (-1)^n  at index [2i+1] : st = {st_odd:+.1f}")
    print("  -> two unlimited indices give different standard parts, so (-1)^n")
    print("     diverges.  No subsequence bookkeeping required.")
    print()
    c: Callable[[int], float] = lambda n: math.sin(n)
    x = star_seq(c, omega)          # the value at the infinite index omega
    bound = max(abs(c(i)) for i in range(HORIZON))
    print(f"  c_n = sin(n) is bounded by {bound:.4f}, so its value at the infinite")
    print("  index omega is a *finite* hyperreal and can be rounded to a real L;")
    print("  that L is automatically a cluster point (Bolzano-Weierstrass).")
    L = x(HORIZON - 1)
    hits = [n for n in range(HORIZON, 3 * HORIZON) if abs(c(n) - L) < 0.01]
    print(f"    rounding at a large coordinate gives L = {L:+.6f}")
    print(f"    indices n >= {HORIZON} with |c_n - L| < 0.01: {hits[:8]} ...")
    print("    -> the value returns to within epsilon of L infinitely often.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("ALIEN ARITHMETIC -- numerical demonstrations")
    print("Nonstandard models of N: transfer, internal sets, galaxies, primes")
    print()
    section_1()
    section_2()
    section_3()
    section_4()
    section_5()
    section_6()
    section_7()
    print("=" * 78)
    print("Summary")
    print("=" * 78)
    print("  * every first-order theorem of arithmetic transfers to the model;")
    print("  * the least number principle, induction and completeness survive for")
    print("    internal sets and fail maximally for external ones;")
    print("  * the model has continuum many elements and a dense order of scales;")
    print("  * primes are unbounded but NOT present at every scale;")
    print("  * limits, infinitude, pigeonhole and compactness become algebra at")
    print("    infinite indices.")
    print()


if __name__ == "__main__":
    main()
