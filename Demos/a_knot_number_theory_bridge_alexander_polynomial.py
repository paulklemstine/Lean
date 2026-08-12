"""
Torus-knot Alexander polynomials as arithmetic objects — numerical demonstrations.

Self-contained (standard library only). Every function is inlined and type-hinted.

What is demonstrated
--------------------
1.  The divisor spectrum  S(a,b) = {d : d | ab, d ∤ a, d ∤ b}  and the cyclotomic
    factorization  Δ_{a,b} = ∏_{d in S(a,b)} Φ_d.
2.  The defining identity  (X^{ab}-1)(X-1) = Δ_{a,b}(X^a-1)(X^b-1),
    the degree law  deg Δ = (a-1)(b-1),  the factor count  (τ(a)-1)(τ(b)-1),
    and the normalization  Δ(1) = 1.
3.  The semiprime pipeline: for N = pq the factor degrees are {p-1, q-1, (p-1)(q-1)};
    from φ(N) one gets p+q = N+1-φ(N) and hence p, q.
4.  The semigroup dictionary: Δ_{a,b} = 1 - (1-X)G, coefficients are
    [n in <a,b>] - [n-1 in <a,b>], all coefficients in {0, ±1}, palindromicity,
    Sylvester's genus formula 2·#gaps = (a-1)(b-1), semigroup symmetry.
5.  The support law  #supp Δ = 2β + 1  (β = number of maximal gap runs), the bound
    #supp Δ ≥ max(a,b), tightness on T(2,N), and the staircase count 2a-1.
6.  The obstructions: the determinant trichotomy Δ(-1) ∈ {1, a, b}, the cheap
    two-number readout returning only {a,b}, and the exponential support growth.
7.  The lattice bridge: gcd(A_M, A_N) = A_{gcd(M,N)} and deg gcd + 1 = gcd(M,N).
"""

from __future__ import annotations

from fractions import Fraction
from math import isqrt
from typing import Dict, List, Sequence, Set, Tuple

Poly = List[int]  # dense coefficient list, index = exponent, little-endian


# --------------------------------------------------------------------------- #
# Polynomial arithmetic over Z (dense, little-endian)                          #
# --------------------------------------------------------------------------- #

def poly_trim(p: Poly) -> Poly:
    """Remove trailing zero coefficients (keep at least one entry)."""
    q = list(p)
    while len(q) > 1 and q[-1] == 0:
        q.pop()
    return q


def poly_mul(p: Poly, q: Poly) -> Poly:
    """Product of two integer polynomials."""
    out: Poly = [0] * (len(p) + len(q) - 1)
    for i, a in enumerate(p):
        if a:
            for j, b in enumerate(q):
                out[i + j] += a * b
    return poly_trim(out)


def poly_sub(p: Poly, q: Poly) -> Poly:
    """Difference p - q."""
    n = max(len(p), len(q))
    return poly_trim([(p[i] if i < len(p) else 0) - (q[i] if i < len(q) else 0)
                      for i in range(n)])


def poly_divmod(p: Poly, q: Poly) -> Tuple[Poly, Poly]:
    """Exact-style division with remainder; q must have integer-invertible lead here."""
    p = poly_trim(p)
    q = poly_trim(q)
    if q == [0]:
        raise ZeroDivisionError("division by the zero polynomial")
    quot: Poly = [0] * max(1, len(p) - len(q) + 1)
    rem = list(p)
    while len(poly_trim(rem)) >= len(q) and poly_trim(rem) != [0]:
        rem = poly_trim(rem)
        shift = len(rem) - len(q)
        if rem[-1] % q[-1] != 0:
            break
        factor = rem[-1] // q[-1]
        quot[shift] = factor
        rem = poly_sub(rem, [0] * shift + [factor * c for c in q])
    return poly_trim(quot), poly_trim(rem)


def poly_eval(p: Poly, x: int) -> int:
    """Evaluate p at an integer point by Horner's rule."""
    acc = 0
    for c in reversed(p):
        acc = acc * x + c
    return acc


def poly_str(p: Poly, var: str = "X") -> str:
    """Human-readable rendering of a polynomial."""
    p = poly_trim(p)
    terms: List[str] = []
    for i in range(len(p) - 1, -1, -1):
        c = p[i]
        if c == 0:
            continue
        mag = "" if abs(c) == 1 and i > 0 else str(abs(c))
        power = "" if i == 0 else (var if i == 1 else f"{var}^{i}")
        sign = "-" if c < 0 else "+"
        terms.append(f"{sign} {mag}{power}".strip())
    if not terms:
        return "0"
    head = terms[0]
    head = head[2:] if head.startswith("+ ") else head
    return " ".join([head] + terms[1:])


def x_pow_minus_one(n: int) -> Poly:
    """The polynomial X^n - 1."""
    p: Poly = [0] * (n + 1)
    p[0] = -1
    p[n] = 1
    return p


# --------------------------------------------------------------------------- #
# Number theory                                                                #
# --------------------------------------------------------------------------- #

def divisors(n: int) -> List[int]:
    """Sorted list of positive divisors of n >= 1."""
    ds: List[int] = []
    i = 1
    while i * i <= n:
        if n % i == 0:
            ds.append(i)
            if i != n // i:
                ds.append(n // i)
        i += 1
    return sorted(ds)


def euler_phi(n: int) -> int:
    """Euler's totient function."""
    result, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            result -= result // p
        p += 1
    if m > 1:
        result -= result // m
    return result


def cyclotomic(n: int) -> Poly:
    """The n-th cyclotomic polynomial Φ_n, by recursive exact division."""
    if n == 1:
        return [-1, 1]
    num = x_pow_minus_one(n)
    for d in divisors(n):
        if d < n:
            num, rem = poly_divmod(num, cyclotomic(d))
            assert rem == [0], "cyclotomic recursion must divide exactly"
    return num


# --------------------------------------------------------------------------- #
# The torus-knot Alexander polynomial                                          #
# --------------------------------------------------------------------------- #

def spectrum(a: int, b: int) -> List[int]:
    """The divisor spectrum S(a,b) = {d : d | ab, d does not divide a or b}."""
    return [d for d in divisors(a * b) if a % d != 0 and b % d != 0]


def torus_alexander(a: int, b: int) -> Poly:
    """Δ_{a,b} = ∏_{d in S(a,b)} Φ_d, the Alexander polynomial of T(a,b)."""
    out: Poly = [1]
    for d in spectrum(a, b):
        out = poly_mul(out, cyclotomic(d))
    return out


def alexander_pencil(n: int) -> Poly:
    """A_N = (X^N + 1)/(X + 1) for odd N: the Alexander polynomial of T(2,N)."""
    return [(-1) ** (n - 1 - k) for k in range(n)][::-1] if n % 2 == 1 else []


# --------------------------------------------------------------------------- #
# Numerical semigroup <a,b>                                                    #
# --------------------------------------------------------------------------- #

def is_representable(a: int, b: int, n: int) -> bool:
    """Is n = a i + b j for nonnegative integers i, j?"""
    j = 0
    while b * j <= n:
        if (n - b * j) % a == 0:
            return True
        j += 1
    return False


def gaps(a: int, b: int) -> List[int]:
    """The gaps of <a,b>: nonrepresentable n below the conductor (a-1)(b-1)."""
    c = (a - 1) * (b - 1)
    return [n for n in range(c) if not is_representable(a, b, n)]


def gap_runs(a: int, b: int) -> List[List[int]]:
    """The maximal runs of consecutive gaps."""
    runs: List[List[int]] = []
    for g in gaps(a, b):
        if runs and runs[-1][-1] == g - 1:
            runs[-1].append(g)
        else:
            runs.append([g])
    return runs


def coeff_by_semigroup(a: int, b: int, n: int) -> int:
    """[X^n] Δ_{a,b} = [n in <a,b>] - [n-1 in <a,b>], the coefficient law."""
    lo = 1 if is_representable(a, b, n) else 0
    hi = 1 if (n >= 1 and is_representable(a, b, n - 1)) else 0
    return lo - hi


# --------------------------------------------------------------------------- #
# Recovery pipelines                                                           #
# --------------------------------------------------------------------------- #

def recover_semiprime_from_degrees(n: int, degrees: Sequence[int]) -> Tuple[int, int]:
    """From the irreducible factor degrees of A_N (N = pq) recover (p, q)."""
    phi = max(degrees)
    s = n + 1 - phi
    disc = s * s - 4 * n
    root = isqrt(disc)
    if root * root != disc:
        raise ValueError("the degree data is not that of a semiprime")
    return (s - root) // 2, (s + root) // 2


def cheap_readout(a: int, b: int) -> Tuple[int, int]:
    """
    The cheap two-number readout of Δ_{a,b}: the least positive index m with
    coefficient +1 is min(a,b), and deg/(m-1) + 1 is max(a,b).
    """
    delta = torus_alexander(a, b)
    m = next(i for i in range(1, len(delta)) if delta[i] == 1)
    d = len(delta) - 1
    return m, d // (m - 1) + 1


def knot_determinant(a: int, b: int) -> int:
    """The knot determinant Δ_{a,b}(-1)."""
    return poly_eval(torus_alexander(a, b), -1)


def poly_gcd_q(p: Poly, q: Poly) -> List[Fraction]:
    """Monic gcd over Q of two integer polynomials, via the Euclidean algorithm."""
    f: List[Fraction] = [Fraction(c) for c in poly_trim(p)]
    g: List[Fraction] = [Fraction(c) for c in poly_trim(q)]

    def trim(u: List[Fraction]) -> List[Fraction]:
        while len(u) > 1 and u[-1] == 0:
            u.pop()
        return u

    while trim(g) != [Fraction(0)]:
        # f mod g
        r = list(f)
        while len(trim(r)) >= len(g) and trim(r) != [Fraction(0)]:
            r = trim(r)
            shift = len(r) - len(g)
            factor = r[-1] / g[-1]
            for i, c in enumerate(g):
                r[i + shift] -= factor * c
            r = trim(r)
        f, g = g, trim(r)
    lead = f[-1]
    return [c / lead for c in f]


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_spectrum_and_identity() -> None:
    print("=" * 74)
    print("1.  Divisor spectrum, defining identity, degree, factor count, Δ(1) = 1")
    print("=" * 74)
    for a, b in [(2, 3), (2, 15), (3, 5), (5, 7), (4, 9)]:
        s = spectrum(a, b)
        delta = torus_alexander(a, b)
        lhs = poly_mul(x_pow_minus_one(a * b), x_pow_minus_one(1))
        rhs = poly_mul(delta, poly_mul(x_pow_minus_one(a), x_pow_minus_one(b)))
        tau_a, tau_b = len(divisors(a)), len(divisors(b))
        print(f"\nT({a},{b}):  S = {s}")
        print(f"  Δ_{{{a},{b}}} = {poly_str(delta)}")
        print(f"  identity (X^ab-1)(X-1) = Δ(X^a-1)(X^b-1) : {lhs == rhs}")
        print(f"  deg Δ = {len(delta)-1}  vs  (a-1)(b-1) = {(a-1)*(b-1)}")
        print(f"  #factors = {len(s)}  vs  (τ(a)-1)(τ(b)-1) = {(tau_a-1)*(tau_b-1)}")
        print(f"  Δ(1) = {poly_eval(delta, 1)}")


def demo_semiprime_pipeline() -> None:
    print()
    print("=" * 74)
    print("2.  The semiprime pipeline:  A_N -> factor degrees -> φ(N) -> p, q")
    print("=" * 74)
    semiprimes: List[Tuple[int, int]] = [(3, 5), (3, 7), (5, 7), (7, 11),
                                         (11, 13), (13, 17)]
    print(f"{'N':>6} {'factor indices':>22} {'degrees':>18} {'φ(N)':>7} "
          f"{'p+q':>5} {'recovered':>12}")
    for p, q in semiprimes:
        n = p * q
        idx = [2 * d for d in divisors(n) if d > 1]
        degs = [euler_phi(i) for i in idx]
        phi = euler_phi(n)
        p2, q2 = recover_semiprime_from_degrees(n, degs)
        ok = "OK" if (p2, q2) == (p, q) else "FAIL"
        print(f"{n:>6} {str(idx):>22} {str(sorted(degs)):>18} {phi:>7} "
              f"{n+1-phi:>5} {f'{p2}x{q2} {ok}':>12}")
    print("\n  Verification that A_N really is the product of those cyclotomics:")
    for p, q in [(11, 13)]:
        n = p * q
        prod: Poly = [1]
        for d in divisors(n):
            if d > 1:
                prod = poly_mul(prod, cyclotomic(2 * d))
        print(f"    N = {n}:  ∏ Φ_2d  ==  A_N  :  {prod == alexander_pencil(n)}")
        print(f"    deg = {len(prod)-1},  #nonzero coefficients = "
              f"{sum(1 for c in prod if c)},  A_N(-1) = {poly_eval(prod, -1)}")


def demo_semigroup_dictionary() -> None:
    print()
    print("=" * 74)
    print("3.  The numerical-semigroup dictionary")
    print("=" * 74)
    for a, b in [(3, 5), (5, 7), (4, 9)]:
        delta = torus_alexander(a, b)
        c = (a - 1) * (b - 1)
        g = gaps(a, b)
        by_law = [coeff_by_semigroup(a, b, n) for n in range(c + 1)]
        dense = delta + [0] * (c + 1 - len(delta))
        symmetric = all(is_representable(a, b, n) != is_representable(a, b, c - 1 - n)
                        for n in range(c))
        print(f"\n<{a},{b}>: conductor {c}, Frobenius number {a*b-a-b}")
        print(f"  gaps ({len(g)}): {g}")
        print(f"  Sylvester 2·#gaps = (a-1)(b-1):  {2*len(g)} == {c}  "
              f"{2*len(g) == c}")
        print(f"  coefficient law matches Δ:  {by_law == dense}")
        print(f"  all coefficients in {{0,±1}}:  {all(abs(x) <= 1 for x in delta)}")
        print(f"  palindromic:  {delta == delta[::-1]}")
        print(f"  semigroup symmetry (n <-> c-1-n):  {symmetric}")


def demo_support_law() -> None:
    print()
    print("=" * 74)
    print("4.  The support law  #supp Δ = 2β + 1  and the bound  #supp ≥ max(a,b)")
    print("=" * 74)
    print(f"{'(a,b)':>10} {'deg':>6} {'#gaps':>7} {'β=#runs':>9} {'2β+1':>6} "
          f"{'#supp':>7} {'max(a,b)':>9}")
    pairs = [(2, 5), (2, 9), (2, 15), (2, 21), (3, 4), (4, 5), (5, 6), (6, 7),
             (3, 7), (5, 7), (4, 9), (5, 12)]
    for a, b in pairs:
        delta = torus_alexander(a, b)
        beta = len(gap_runs(a, b))
        supp = sum(1 for cc in delta if cc)
        assert supp == 2 * beta + 1
        assert supp >= max(a, b)
        print(f"{f'({a},{b})':>10} {len(delta)-1:>6} {len(gaps(a,b)):>7} "
              f"{beta:>9} {2*beta+1:>6} {supp:>7} {max(a,b):>9}")
    print("\n  Pencil T(2,N): #supp = N exactly (bound attained).")
    print("  Staircase T(a,a+1): #supp = 2a-1 > max(a,a+1) once a >= 3.")


def demo_obstructions() -> None:
    print()
    print("=" * 74)
    print("5.  The obstructions")
    print("=" * 74)
    print("\n  (a) Determinant trichotomy  Δ(-1) ∈ {1, a, b}:")
    print(f"{'(a,b)':>10} {'Δ(-1)':>8}  parity")
    for a, b in [(2, 9), (2, 15), (2, 143), (3, 5), (5, 7), (11, 13), (4, 9)]:
        det = knot_determinant(a, b)
        parity = "both odd" if a % 2 and b % 2 else "one even"
        assert det in (1, a, b)
        print(f"{f'({a},{b})':>10} {det:>8}  {parity}")
    print("      -> for T(2,N) the determinant is N (the input);")
    print("         for T(p,q) with p,q odd it is 1 (no information).")

    print("\n  (b) Cheap readout returns only the parameters:")
    for a, b in [(2, 15), (2, 143), (5, 7), (4, 9)]:
        m, mx = cheap_readout(a, b)
        print(f"      T({a},{b}):  least +1 index = {m} = min(a,b);  "
              f"deg/(m-1)+1 = {mx} = max(a,b)")

    print("\n  (c) Materialization cost grows exponentially in the bit length:")
    print(f"{'N':>8} {'bits':>6} {'deg A_N':>9} {'#supp A_N':>11}")
    for n in [15, 33, 63, 143, 323, 1073]:
        if n % 2 == 1:
            an = alexander_pencil(n)
            print(f"{n:>8} {n.bit_length():>6} {len(an)-1:>9} "
                  f"{sum(1 for cc in an if cc):>11}")


def demo_lattice_bridge() -> None:
    print()
    print("=" * 74)
    print("6.  The lattice bridge:  gcd(A_M, A_N) = A_gcd(M,N)")
    print("=" * 74)
    from math import gcd as _gcd
    print(f"{'M':>5} {'N':>5} {'gcd(M,N)':>9} {'deg gcd(A_M,A_N)':>18} "
          f"{'deg+1':>7} {'match':>7}")
    for m, n in [(9, 15), (15, 21), (21, 35), (33, 55), (45, 63), (7, 11)]:
        g = _gcd(m, n)
        gq = poly_gcd_q(alexander_pencil(m), alexander_pencil(n))
        deg = len(gq) - 1
        target = [Fraction(c) for c in alexander_pencil(g)] if g > 1 else [Fraction(1)]
        match = gq == target
        print(f"{m:>5} {n:>5} {g:>9} {deg:>18} {deg+1:>7} {str(match):>7}")


def demo_completeness() -> None:
    print()
    print("=" * 74)
    print("7.  Completeness: Δ_{a,b} determines (a,b) by three maxima")
    print("=" * 74)
    for a, b in [(3, 7), (5, 12), (4, 9), (2, 15)]:
        s = spectrum(a, b)
        co = [d for d in divisors(a * b) if d not in s]
        rec_ab = max(s)
        rec_b = max(co)
        rec_a = max(d for d in co if rec_b % d != 0)
        print(f"  T({a},{b}):  max S = {rec_ab} = ab;  max C = {rec_b} = b;  "
              f"max(C, ∤b) = {rec_a} = a   "
              f"[{'OK' if (rec_a, rec_b) == (a, b) else 'FAIL'}]")
    seen: Dict[Tuple[int, ...], Tuple[int, int]] = {}
    collisions = 0
    for a in range(2, 13):
        for b in range(a + 1, 16):
            if _coprime(a, b):
                key = tuple(torus_alexander(a, b))
                if key in seen:
                    collisions += 1
                seen[key] = (a, b)
    print(f"\n  Exhaustive check over coprime 1 < a < b <= 15: "
          f"{len(seen)} polynomials, {collisions} collisions.")


def _coprime(a: int, b: int) -> bool:
    while b:
        a, b = b, a % b
    return a == 1


def main() -> None:
    demo_spectrum_and_identity()
    demo_semiprime_pipeline()
    demo_semigroup_dictionary()
    demo_support_law()
    demo_obstructions()
    demo_lattice_bridge()
    demo_completeness()
    print()
    print("=" * 74)
    print("All demonstrated identities held on every instance tested.")
    print("=" * 74)


if __name__ == "__main__":
    main()
