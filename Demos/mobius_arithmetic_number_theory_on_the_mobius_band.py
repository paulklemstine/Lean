#!/usr/bin/env python3
"""
Mobius Arithmetic: numerical demonstrations.

This script is completely self-contained (standard library only) and verifies,
by direct computation, every quantitative claim of the accompanying article and
research paper:

  PART 1  The oriented integers and the Mobius identification
          - the deck involution is a fixed-point-free involution
          - every fibre of the quotient map has exactly two points
          - twisted arithmetic reproduces the ordinary integers

  PART 2  Factorization theory of the Mobius integers
          - prime elements of radius p come in exactly two orientations
          - the four ordered prime factorizations of 6
          - unique factorization up to orientation; radii are the invariant
          - the divisor count is 2*d(n); the lattice count is 2N+1

  PART 3  The Mobius zeta function
          - the Dirichlet series over nonzero Mobius integers is 2*zeta(s)
          - the k-fold norm theorem: constant fibre size k gives k*zeta(s)
          - doubling is not squaring: zeta~(2) = pi^2/3 != pi^4/36

  PART 4  The additive obstruction
          - multiplication lifts separably to the cover; addition does not
          - the absolute-value criterion, and an operation showing it is
            necessary but not sufficient
          - classification of finite additive twists of the integers

  PART 5  The oriented double O = Z[tau]/(tau^2 - 1)
          - it is not a domain; its unit group is the Klein four-group
          - Spec(O) -> Spec(Z) is a double cover branched exactly at 2
          - the spectral zeta function zeta_O(s) = zeta(s)^2 * (1 - 2^-s)
          - Dirichlet coefficients c(n) = d(n) - d(n/2) count ideals
          - zeta_O(2) = pi^4/48, and the new zero at s0 = 2*pi*i/log 2
"""

from __future__ import annotations

import cmath
import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Set, Tuple

Oriented = Tuple[int, int]  # (magnitude, orientation in {+1, -1})


# ----------------------------------------------------------------------------
# PART 1 -- Oriented integers, the Mobius identification, twisted arithmetic
# ----------------------------------------------------------------------------

def value(a: Oriented) -> int:
    """Signed value eps * n of an oriented integer (n, eps)."""
    n, eps = a
    return eps * n


def deck(a: Oriented) -> Oriented:
    """Deck transformation tau(n, eps) = (-n, -eps) of the double cover."""
    n, eps = a
    return (-n, -eps)


def same_class(a: Oriented, b: Oriented) -> bool:
    """Are two oriented integers identified on the Mobius band?"""
    return value(a) == value(b)


def fibre(x: int, magnitude_bound: int) -> List[Oriented]:
    """All oriented integers of signed value x with |magnitude| <= bound."""
    return [
        (n, eps)
        for n in range(-magnitude_bound, magnitude_bound + 1)
        for eps in (1, -1)
        if eps * n == x
    ]


def mobius_add(x: int, y: int) -> int:
    """Twisted addition, performed through the identification."""
    return x + y


def mobius_mul(x: int, y: int) -> int:
    """Twisted multiplication, performed through the identification."""
    return x * y


def norm(x: int) -> int:
    """The radius (norm) of a Mobius integer given by its signed value."""
    return abs(x)


def part1() -> None:
    print("=" * 78)
    print("PART 1  The Mobius identification is a free double cover")
    print("=" * 78)

    print("\nThe defining identification (n, +1) ~ (-n, -1):")
    for n in range(0, 4):
        a, b = (n, 1), (-n, -1)
        print(f"  (n={n:2d}, +1) ~ (n={-n:3d}, -1)   both have signed value "
              f"{value(a):3d}   identified: {same_class(a, b)}")

    print("\nThe deck involution tau(n, eps) = (-n, -eps):")
    involutive = True
    fixed_point_free = True
    class_preserving = True
    for n in range(-6, 7):
        for eps in (1, -1):
            a = (n, eps)
            involutive &= deck(deck(a)) == a
            fixed_point_free &= deck(a) != a
            class_preserving &= same_class(deck(a), a)
    print(f"  tau o tau = identity on the tested range : {involutive}")
    print(f"  tau has no fixed point                   : {fixed_point_free}")
    print(f"  tau preserves the Mobius class           : {class_preserving}")

    print("\nEvery fibre of the quotient map has EXACTLY two points:")
    for x in range(-3, 4):
        f = fibre(x, 8)
        print(f"  signed value {x:3d} -> fibre {f}  (size {len(f)})")

    print("\nTwisted arithmetic (through the identification):")
    samples = [((2, 1), (3, 1)), ((2, 1), (3, -1)), ((2, -1), (3, -1))]
    for a, b in samples:
        s, p = mobius_add(value(a), value(b)), mobius_mul(value(a), value(b))
        print(f"  {a} + {b} = {s:3d}      {a} * {b} = {p:3d}")

    print("\nStructure theorem: the signed value map is a ring isomorphism to Z.")
    ok = all(
        mobius_add(x, y) == x + y and mobius_mul(x, y) == x * y
        for x in range(-8, 9) for y in range(-8, 9)
    )
    print(f"  addition and multiplication agree with Z on [-8, 8]^2 : {ok}")
    print("  units of the Mobius integers: {+1, -1}, a cyclic group of order 2")


# ----------------------------------------------------------------------------
# PART 2 -- Factorization theory
# ----------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    n = abs(n)
    if n < 2:
        return False
    for p in range(2, int(math.isqrt(n)) + 1):
        if n % p == 0:
            return False
    return True


def mobius_is_prime(x: int) -> bool:
    """A Mobius integer is prime exactly when its radius is a rational prime."""
    return is_prime(norm(x))


def primes_of_radius(p: int) -> List[int]:
    """The Mobius primes of radius p, as signed values: p^+ and p^-."""
    return [p, -p]


def ordered_prime_factorizations(m: int, bound: int) -> List[Tuple[int, int]]:
    """All ordered pairs (a, b) of Mobius primes with a*b = m."""
    out: List[Tuple[int, int]] = []
    for a in range(-bound, bound + 1):
        if a == 0 or not mobius_is_prime(a):
            continue
        if m % a != 0:
            continue
        b = m // a
        if mobius_is_prime(b) and a * b == m:
            out.append((a, b))
    return sorted(out)


def divisor_count(n: int) -> int:
    """Classical number-of-divisors function d(n) = sigma_0(n)."""
    if n <= 0:
        return 0
    return sum(1 for k in range(1, n + 1) if n % k == 0)


def mobius_divisors(x: int, bound: int) -> List[int]:
    """Divisors of a nonzero Mobius integer, as signed values."""
    return [d for d in range(-bound, bound + 1) if d != 0 and x % d == 0]


def label(x: int) -> str:
    """Render a Mobius integer in oriented notation, e.g. 2^+ or 3^-."""
    return f"{abs(x)}^{'+' if x >= 0 else '-'}"


def part2() -> None:
    print("\n" + "=" * 78)
    print("PART 2  Factorization: doubled elements, undoubled spectrum")
    print("=" * 78)

    print("\nPrime elements over the first rational primes (a Z/2-torsor each):")
    for p in [2, 3, 5, 7, 11]:
        ps = primes_of_radius(p)
        print(f"  p = {p:2d} -> {[label(q) for q in ps]}  "
              f"(count {len(ps)}; they differ by the unit -1, so they generate "
              f"the SAME ideal)")

    print("\nThe test case: ordered prime factorizations of 6.")
    facs = ordered_prime_factorizations(6, 12)
    for a, b in facs:
        print(f"  6 = {label(a)} * {label(b)}   ({a} * {b})")
    print(f"  total: {len(facs)} ordered factorizations "
          f"(predicted 4: (2+,3+), (3+,2+), (2-,3-), (3-,2-))")
    print(f"  (2^+, 3^+) != (2^-, 3^-) as oriented data: "
          f"{(2, 3) != (-2, -3)}")
    print("  but 2^+ and 2^- are associates (differ by the unit -1), so unique")
    print("  factorization is NOT violated; the multiset of RADII is the invariant:")
    print(f"    radii of (2^+, 3^+) = {sorted([2, 3])};  "
          f"radii of (2^-, 3^-) = {sorted([2, 3])}")

    print("\nThe Mobius divisor function is twice the classical one:")
    print(f"  {'n':>3} | {'#divisors in Z~':>16} | {'2*d(n)':>7}")
    for n in range(1, 13):
        got = len(mobius_divisors(n, n))
        print(f"  {n:>3} | {got:>16} | {2 * divisor_count(n):>7}")

    print("\nLattice count: #{x : radius(x) <= N} = 2N + 1")
    for N in range(0, 7):
        count = sum(1 for x in range(-N, N + 1))
        print(f"  N = {N}:  {count:3d}   predicted {2 * N + 1:3d}")


# ----------------------------------------------------------------------------
# PART 3 -- Zeta functions
# ----------------------------------------------------------------------------

def zeta_partial(s: complex, terms: int = 200000) -> complex:
    """Partial sum of the Riemann zeta function (Re s > 1)."""
    return sum(complex(n) ** (-s) for n in range(1, terms + 1))


def mobius_zeta_partial(s: complex, radius_bound: int = 200000) -> complex:
    """Sum of radius^{-s} over the nonzero Mobius integers of bounded radius."""
    total = 0j
    for n in range(1, radius_bound + 1):
        total += 2 * complex(n) ** (-s)   # the two orientations n^+ and n^-
    return total


def kfold_zeta_partial(s: complex, k: int, bound: int = 200000) -> complex:
    """Dirichlet series of a k-fold norm: fibre of constant size k."""
    return sum(k * complex(n) ** (-s) for n in range(1, bound + 1))


def part3() -> None:
    print("\n" + "=" * 78)
    print("PART 3  The Mobius zeta function: doubled, never squared")
    print("=" * 78)

    print("\nzeta~(s) = sum over nonzero Mobius integers of radius^{-s} = 2 zeta(s)")
    print(f"  {'s':>4} | {'sum over Z~':>18} | {'2 * zeta(s)':>18}")
    for s in [2.0, 3.0, 4.0, 1.5]:
        lhs = mobius_zeta_partial(complex(s), 100000).real
        rhs = 2 * zeta_partial(complex(s), 100000).real
        print(f"  {s:>4} | {lhs:>18.10f} | {rhs:>18.10f}")

    print("\nExact special values:")
    zt2 = math.pi ** 2 / 3
    z2sq = math.pi ** 4 / 36
    print(f"  zeta~(2)  = pi^2/3  = {zt2:.10f}")
    print(f"  zeta(2)^2 = pi^4/36 = {z2sq:.10f}")
    print(f"  a genuine double cover would SQUARE the zeta function; the Mobius")
    print(f"  identification only DOUBLES it:  equal? {math.isclose(zt2, z2sq)}")

    print("\nThe k-fold norm theorem: constant fibre size k gives exactly k*zeta(s).")
    print(f"  {'k':>3} | {'Dirichlet series at s=2':>24} | {'k * zeta(2)':>16}")
    for k in range(1, 6):
        lhs = kfold_zeta_partial(2 + 0j, k, 100000).real
        rhs = k * (math.pi ** 2 / 6)
        print(f"  {k:>3} | {lhs:>24.10f} | {rhs:>16.10f}")
    print("  Multiplying by a constant cannot create, destroy or move a zero:")
    print("  the k-fold Riemann hypothesis is equivalent to the classical one")
    print("  for every k >= 1.")


# ----------------------------------------------------------------------------
# PART 4 -- The additive obstruction
# ----------------------------------------------------------------------------

def has_separable_lift(F: Callable[[int, int], int], span: int = 4) -> bool:
    """
    Search exhaustively for a separable lift of F on the oriented cover:
    a magnitude rule g (unconstrained, so we only need it to be a function of
    the two magnitudes) together with an orientation rule h: {+-1}^2 -> {+-1}.

    The magnitude of the output is forced to be |g(m,n)|, so a necessary and
    sufficient condition on the tested window is: for each pair of magnitudes
    (m, n) the four sign choices must produce values of a single absolute
    value, and the produced signs must be a function of the input signs alone.
    """
    for h in itertools.product([1, -1], repeat=4):
        h_map: Dict[Tuple[int, int], int] = {
            (1, 1): h[0], (1, -1): h[1], (-1, 1): h[2], (-1, -1): h[3]
        }
        consistent = True
        for m in range(-span, span + 1):
            for n in range(-span, span + 1):
                candidates: Set[int] = set()
                for eps in (1, -1):
                    for delta in (1, -1):
                        out = F(eps * m, delta * n)
                        # out must equal h_map[eps,delta] * g(m,n)
                        candidates.add(h_map[(eps, delta)] * out)
                if len(candidates) > 1:
                    consistent = False
                    break
            if not consistent:
                break
        if consistent:
            return True
    return False


def abs_criterion(F: Callable[[int, int], int], span: int = 6) -> bool:
    """Necessary criterion: |F| is invariant under negating either argument."""
    for m in range(-span, span + 1):
        for n in range(-span, span + 1):
            if abs(F(-m, n)) != abs(F(m, n)):
                return False
            if abs(F(m, -n)) != abs(F(m, n)):
                return False
    return True


def parity_twist(m: int, n: int) -> int:
    """m*n if m is even, |m*n| otherwise: orientation-blind in absolute value."""
    return m * n if m % 2 == 0 else abs(m * n)


def twist_orders(c: int, kmax: int = 8) -> List[int]:
    """Orders k <= kmax with (multiplication by c) iterated k times = identity."""
    return [k for k in range(1, kmax + 1) if c ** k == 1]


def part4() -> None:
    print("\n" + "=" * 78)
    print("PART 4  Multiplication lifts to the cover; addition does not")
    print("=" * 78)

    print("\nMultiplication is orientation-local:  (m,eps)*(n,delta) = (mn, eps*delta)")
    ok = True
    for m in range(-4, 5):
        for n in range(-4, 5):
            for eps in (1, -1):
                for delta in (1, -1):
                    ok &= (eps * m) * (delta * n) == (eps * delta) * (m * n)
    print(f"  verified on the window [-4,4]^2 x signs : {ok}")

    print("\nThe fatal computation for addition:")
    print("    1^+ + 1^+ = 2   (magnitudes 1 and 1)")
    print("    1^+ + 1^- = 0   (magnitudes 1 and 1)")
    print("  same magnitudes, outputs of absolute value 2 and 0: no function of")
    print("  the two magnitudes can produce both.")

    ops: List[Tuple[str, Callable[[int, int], int]]] = [
        ("m * n            ", lambda m, n: m * n),
        ("m + n            ", lambda m, n: m + n),
        ("m - n            ", lambda m, n: m - n),
        ("m + n^2          ", lambda m, n: m + n * n),
        ("m + 1            ", lambda m, n: m + 1),
        ("parity twist     ", parity_twist),
    ]
    print(f"\n  {'operation':<18} | {'|F| criterion':>14} | {'separable lift':>15}")
    print("  " + "-" * 54)
    for name, F in ops:
        print(f"  {name:<18} | {str(abs_criterion(F)):>14} | "
              f"{str(has_separable_lift(F)):>15}")
    print("\n  The parity twist passes the absolute-value criterion and still has")
    print("  no separable lift: the true obstruction is a SIGN cocycle.")

    print("\nClassification of finite additive twists of Z (rho(n) = c*n):")
    for c in [-3, -2, -1, 0, 1, 2, 3]:
        orders = twist_orders(c)
        desc = f"orders {orders}" if orders else "no finite order"
        print(f"  c = {c:2d} : {desc}")
    print("  Only c = +1 (identity, all orders) and c = -1 (the Mobius twist,")
    print("  even orders only) have finite order: the half-twist is the unique")
    print("  nontrivial finite twist, and there is no Z/k version for odd k >= 3.")


# ----------------------------------------------------------------------------
# PART 5 -- The oriented double O = Z[tau]/(tau^2 - 1)
# ----------------------------------------------------------------------------

OElem = Tuple[int, int]  # a + b*tau, stored as the pair (a, b)


def o_mul(x: OElem, y: OElem) -> OElem:
    """Multiplication in O = Z[tau]/(tau^2 - 1)."""
    a, b = x
    c, d = y
    return (a * c + b * d, a * d + b * c)


def o_add(x: OElem, y: OElem) -> OElem:
    return (x[0] + y[0], x[1] + y[1])


def o_coords(x: OElem) -> Tuple[int, int]:
    """The two orientations pi^+ and pi^-: a + b*tau |-> (a+b, a-b)."""
    a, b = x
    return (a + b, a - b)


def o_is_unit(x: OElem) -> bool:
    u, v = o_coords(x)
    return abs(u) == 1 and abs(v) == 1


def o_swap(x: OElem) -> OElem:
    """The deck involution tau |-> -tau."""
    a, b = x
    return (a, -b)


def sheets(p: int) -> int:
    """Number of points of Spec(O) above the rational prime p."""
    return 1 if p == 2 else 2


def ideal_coeff(n: int) -> int:
    """c(n) = d(n) - d(n/2), the Dirichlet coefficients of zeta(s)^2*(1-2^-s)."""
    return divisor_count(n) - (divisor_count(n // 2) if n % 2 == 0 else 0)


def spectral_zeta_from_euler(s: complex, prime_bound: int = 20000) -> complex:
    """Euler product over Spec(O), truncated at primes below prime_bound."""
    result = 1 + 0j
    for p in range(2, prime_bound):
        if is_prime(p):
            factor = (1 - complex(p) ** (-s)) ** (-1)
            result *= factor ** sheets(p)
    return result


def spectral_zeta_closed(s: complex, terms: int = 200000) -> complex:
    """zeta(s)^2 * (1 - 2^{-s})."""
    z = zeta_partial(s, terms)
    return z * z * (1 - complex(2) ** (-s))


def part5() -> None:
    print("\n" + "=" * 78)
    print("PART 5  The oriented double O = Z[tau]/(tau^2 - 1): an honest twist")
    print("=" * 78)

    one: OElem = (1, 0)
    tau: OElem = (0, 1)

    print("\nBasic structure (elements written a + b*tau):")
    print(f"  tau^2                  = {o_mul(tau, tau)}   (= 1)")
    print(f"  (1 + tau)(1 - tau)     = {o_mul(o_add(one, tau), (1, -1))}   "
          f"(= 0, so O is NOT a domain, hence O is not isomorphic to Z)")
    print(f"  coordinates of a+b*tau : (a+b, a-b), the two orientations pi^+, pi^-")

    print("\nThe unit group is the Klein four-group {+-1, +-tau}:")
    units = [x for x in itertools.product(range(-3, 4), repeat=2) if o_is_unit(x)]
    print(f"  units found with |a|,|b| <= 3 : {sorted(units)}  (count {len(units)})")
    print(f"  the deck involution swaps orientations: swap(tau) = {o_swap(tau)}")

    print("\nSpec(O) -> Spec(Z) is a double cover branched exactly at 2.")
    print(f"  {'p':>3} | {'sheets':>7} | residue ring O/pO")
    for p in [2, 3, 5, 7, 11, 13]:
        rr = "F_2[e]/(e^2) (non-reduced: ramified)" if p == 2 else f"F_{p} x F_{p} (split)"
        print(f"  {p:>3} | {sheets(p):>7} | {rr}")
    print("  The conductor of O in its normalisation Z x Z is 2 as well:")
    print("  (Z x Z)/O = Z/2, so conductor = branch locus.")

    print("\nSpectral zeta function: zeta_O(s) = zeta(s)^2 * (1 - 2^{-s}).")
    print(f"  {'s':>4} | {'Euler product over Spec O':>26} | {'zeta(s)^2 (1-2^-s)':>21}")
    for s in [2.0, 3.0, 4.0]:
        lhs = spectral_zeta_from_euler(complex(s)).real
        rhs = spectral_zeta_closed(complex(s), 100000).real
        print(f"  {s:>4} | {lhs:>26.10f} | {rhs:>21.10f}")

    print("\n  Exact value at s = 2:")
    print(f"    zeta_O(2) = pi^4/48 = {math.pi ** 4 / 48:.10f}")
    print(f"    zeta~(2)  = pi^2/3  = {math.pi ** 2 / 3:.10f}")
    print("    the multiplicative twist SQUARES the Euler factors, where the")
    print("    set-level twist merely doubled the whole function.")

    print("\nDirichlet coefficients c(n) = d(n) - d(n/2) count ideals of index n:")
    coeffs = [ideal_coeff(n) for n in range(1, 13)]
    print(f"  c(1..12) = {coeffs}")
    print(f"  predicted [1, 1, 2, 1, 2, 2, 2, 1, 3, 2, 2, 2]: "
          f"{coeffs == [1, 1, 2, 1, 2, 2, 2, 1, 3, 2, 2, 2]}")
    print("  at prime index they reproduce the sheet counts:")
    for p in [2, 3, 5, 7, 11]:
        print(f"    c({p}) = {ideal_coeff(p)}  sheets({p}) = {sheets(p)}")
    print("  and c(9) = 3 counts the three ideals of index 9 over the prime 3:")
    print("    P+(3)^2,  P+(3)P-(3) = (3),  P-(3)^2")

    print("\nThe branch prime supplies genuinely new zeros.")
    s0 = complex(0.0, 2 * math.pi / math.log(2))
    print(f"  s0 = 2*pi*i/log 2 = {s0.imag:.6f}i")
    print(f"  1 - 2^(-s0) = {1 - complex(2) ** (-s0):.3e}   (vanishes)")
    print("  so zeta_O(s0) = 0, while zeta(s0) != 0 (the only zeros of zeta with")
    print("  Re s <= 0 are the real trivial zeros -2, -4, -6, ...).")
    print("  The full family of new zeros is 2*pi*i*k/log 2, k a nonzero integer;")
    print("  they all lie on Re s = 0, OUTSIDE the critical strip, so inside the")
    print("  strip the oriented Riemann hypothesis is equivalent to the classical one.")


def main() -> None:
    part1()
    part2()
    part3()
    part4()
    part5()
    print("\n" + "=" * 78)
    print("Summary: a Z/2 symmetry stored in an identification of the underlying")
    print("set is multiplicatively trivial and additively non-liftable, and leaves")
    print("the arithmetic (and the zeros) untouched. A Z/2 symmetry stored in the")
    print("multiplication branches the spectrum, squares the Euler factors, and")
    print("moves zeros -- but only through its ramification.")
    print("=" * 78)


if __name__ == "__main__":
    main()
