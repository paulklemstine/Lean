"""
The Derived-Modulus Corner, Closed
==================================

Numerical demonstrations of the exact classification of polynomial "derived
moduli" M = f(N) that cannot expose a factor of a semiprime N = p*q.

Results demonstrated, in order:

  1. Frozen overlap:      gcd(N, f(N)) = gcd(N, f(0)) for every integer N.
  2. Classification:      gcd(N, f(N)) = 1 for all N  <=>  f(0) = +-1
                          (with an explicit witness N when f(0) != +-1).
  3. Closure:             products and substitutions of transparent moduli
                          stay transparent; the full product of the six tested
                          moduli is coprime to N for every N.
  4. Resultant law:       gcd(f(N), g(N)) divides Res(f, g), uniformly in N.
  5. Spectrum theorem:    primes dividing N^2+1 are 2 or = 1 mod 4;
                          primes dividing N^2+N+1 are 3 or = 1 mod 3.
                          Blum primes (= 3 mod 4) are excluded entirely.
  6. Degeneracy:          lpf(N-1) = lpf(N+1) = lpf(N^2+1) = 2 for odd N.
  7. Freshness:           the prime support of a transparent modulus grows
                          without bound, yet never meets the factors of N.
  8. Hint frontier:       exactly p+q-1 of the pq residues share a prime
                          with N = pq; density <= 2/B when p, q > B.
  9. Boundary:            the exponential modulus 2^N - 1 leaks:
                          gcd(253, 2^253 - 1) = 23 and 253 = 11 * 23.

Self-contained: standard library only (math, itertools, fractions, random).
"""

from __future__ import annotations

import math
import random
from fractions import Fraction
from itertools import combinations
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# Polynomials are represented as coefficient lists, lowest degree first:
#   [c0, c1, ..., cd]  means  c0 + c1*X + ... + cd*X^d
# ---------------------------------------------------------------------------

Poly = List[int]


def poly_eval(f: Poly, x: int) -> int:
    """Evaluate an integer polynomial at x by Horner's rule."""
    acc = 0
    for c in reversed(f):
        acc = acc * x + c
    return acc


def poly_mul(f: Poly, g: Poly) -> Poly:
    """Multiply two integer polynomials."""
    out: Poly = [0] * (len(f) + len(g) - 1)
    for i, a in enumerate(f):
        for j, b in enumerate(g):
            out[i + j] += a * b
    return out


def poly_compose(f: Poly, g: Poly) -> Poly:
    """Compute f(g(X)) for integer polynomials f and g."""
    out: Poly = [0]
    for c in reversed(f):
        out = poly_mul(out, g)
        if out:
            out[0] += c
        else:
            out = [c]
    return _poly_trim(out)


def _poly_trim(f: Poly) -> Poly:
    """Drop trailing zero coefficients (keeping at least one entry)."""
    g = list(f)
    while len(g) > 1 and g[-1] == 0:
        g.pop()
    return g


def poly_degree(f: Poly) -> int:
    """Degree of an integer polynomial (degree 0 for the zero polynomial)."""
    return len(_poly_trim(f)) - 1


def poly_str(f: Poly, var: str = "N") -> str:
    """Render a polynomial in readable form, highest degree first."""
    terms: List[str] = []
    for k in range(len(f) - 1, -1, -1):
        c = f[k]
        if c == 0:
            continue
        if k == 0:
            body = str(abs(c))
        elif k == 1:
            body = var if abs(c) == 1 else f"{abs(c)}{var}"
        else:
            body = f"{var}^{k}" if abs(c) == 1 else f"{abs(c)}{var}^{k}"
        sign = "-" if c < 0 else "+"
        terms.append((sign, body))
    if not terms:
        return "0"
    first_sign, first_body = terms[0]
    head = ("-" if first_sign == "-" else "") + first_body
    tail = "".join(f" {s} {b}" for s, b in terms[1:])
    return head + tail


# The six tested derived moduli.
FAMILY: Dict[str, Poly] = {
    "N - 1":       [-1, 1],
    "N + 1":       [1, 1],
    "N^2 + 1":     [1, 0, 1],
    "N^2 + N + 1": [1, 1, 1],
    "2N - 1":      [-1, 2],
    "2N + 1":      [1, 2],
}


# ---------------------------------------------------------------------------
# 1. Frozen overlap:  gcd(N, f(N)) = gcd(N, f(0))
# ---------------------------------------------------------------------------

def frozen_overlap_check(f: Poly, n_lo: int, n_hi: int) -> bool:
    """Verify gcd(N, f(N)) = gcd(N, f(0)) for all N in [n_lo, n_hi]."""
    c0 = poly_eval(f, 0)
    return all(math.gcd(n, poly_eval(f, n)) == math.gcd(n, c0)
               for n in range(n_lo, n_hi + 1))


def demo_frozen_overlap() -> None:
    print("=" * 74)
    print("1. FROZEN OVERLAP:  gcd(N, f(N)) = gcd(N, f(0))")
    print("=" * 74)
    extra = {
        "N^2 + 6":      [6, 0, 1],      # non-transparent, f(0) = 6
        "N^3 - N + 10": [10, -1, 0, 1],  # non-transparent, f(0) = 10
    }
    all_polys = dict(FAMILY)
    all_polys.update(extra)
    for name, f in all_polys.items():
        ok = frozen_overlap_check(f, 1, 4000)
        print(f"  f(N) = {name:<14}  f(0) = {poly_eval(f, 0):>3}   "
              f"identity holds for N = 1..4000: {ok}")
    print()


# ---------------------------------------------------------------------------
# 2. Classification: universal coprimality <=> transparency (|f(0)| = 1)
# ---------------------------------------------------------------------------

def is_transparent(f: Poly) -> bool:
    """A polynomial is transparent when its constant term is a unit."""
    return abs(poly_eval(f, 0)) == 1


def least_prime_factor(n: int) -> int:
    """Smallest prime factor of n >= 2."""
    n = abs(n)
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n


def leak_witness(f: Poly) -> int | None:
    """
    Return an explicit N with gcd(N, f(N)) > 1 when f is not transparent,
    and None when f is transparent (no such N exists).

    Construction from the classification theorem:
      f(0) = 0        ->  N = 2;
      |f(0)| >= 2     ->  N = least prime factor of |f(0)|.
    """
    if is_transparent(f):
        return None
    c0 = poly_eval(f, 0)
    return 2 if c0 == 0 else least_prime_factor(c0)


def demo_classification() -> None:
    print("=" * 74)
    print("2. CLASSIFICATION: universal coprimality  <=>  |f(0)| = 1")
    print("=" * 74)
    tests: Dict[str, Poly] = dict(FAMILY)
    tests.update({
        "N^2 + 6":      [6, 0, 1],
        "N^2 + 4N":     [0, 4, 1],
        "N^3 + 35":     [35, 0, 0, 1],
        "3N^2 + N - 9": [-9, 1, 3],
    })
    for name, f in tests.items():
        w = leak_witness(f)
        if w is None:
            worst = max(math.gcd(n, poly_eval(f, n)) for n in range(1, 5000))
            print(f"  {name:<14} transparent   -> gcd = 1 always "
                  f"(max over N<5000: {worst})")
        else:
            g = math.gcd(w, poly_eval(f, w))
            print(f"  {name:<14} NOT transparent -> witness N = {w:<4} "
                  f"gcd(N, f(N)) = {g}")
    print()


# ---------------------------------------------------------------------------
# 3. Closure: products and substitutions stay transparent
# ---------------------------------------------------------------------------

def demo_closure() -> None:
    print("=" * 74)
    print("3. CLOSURE: no product or substitution escapes")
    print("=" * 74)
    full: Poly = [1]
    for f in FAMILY.values():
        full = poly_mul(full, f)
    print(f"  full product  P(N) = (N-1)(N+1)(N^2+1)(N^2+N+1)(2N-1)(2N+1)")
    print(f"  degree {poly_degree(full)},  P(0) = {poly_eval(full, 0)} "
          f"(transparent: {is_transparent(full)})")
    worst = max(math.gcd(n, poly_eval(full, n)) for n in range(1, 3000))
    print(f"  max gcd(N, P(N)) over N = 1..2999: {worst}")

    # substitutions g with g(0) = 0
    subs: Dict[str, Poly] = {
        "N -> 2N":     [0, 2],
        "N -> N^3":    [0, 0, 0, 1],
        "N -> N^2+N":  [0, 1, 1],
    }
    for sname, g in subs.items():
        comp = poly_compose(full, g)
        worst = max(math.gcd(n, poly_eval(comp, n)) for n in range(1, 1200))
        print(f"  P({sname.split('-> ')[1]:<7})  constant term "
              f"{poly_eval(comp, 0):>3}   max gcd over N<1200: {worst}")

    # A composition that is NOT allowed: g(0) != 0 can break transparency.
    bad = poly_compose([1, 0, 1], [3, 1])   # (N+3)^2 + 1, constant term 10
    w = leak_witness(bad)
    print(f"  contrast: (N+3)^2+1 has constant term {poly_eval(bad, 0)}; "
          f"witness N = {w}, gcd = {math.gcd(w, poly_eval(bad, w))}")
    print()


# ---------------------------------------------------------------------------
# 4. Resultant law:  gcd(f(N), g(N)) | Res(f, g)
# ---------------------------------------------------------------------------

def sylvester_resultant(f: Poly, g: Poly) -> int:
    """
    Resultant of two integer polynomials, as the determinant of the
    Sylvester matrix, computed exactly over the rationals.
    """
    f, g = _poly_trim(f), _poly_trim(g)
    m, n = poly_degree(f), poly_degree(g)
    size = m + n
    if size == 0:
        return 1
    mat: List[List[Fraction]] = [[Fraction(0)] * size for _ in range(size)]
    for i in range(n):                        # n rows of coefficients of f
        for j, c in enumerate(reversed(f)):
            mat[i][i + j] = Fraction(c)
    for i in range(m):                        # m rows of coefficients of g
        for j, c in enumerate(reversed(g)):
            mat[n + i][i + j] = Fraction(c)
    return int(_determinant(mat))


def _determinant(mat: List[List[Fraction]]) -> Fraction:
    """Exact determinant by Gaussian elimination over the rationals."""
    a = [row[:] for row in mat]
    n = len(a)
    det = Fraction(1)
    for col in range(n):
        pivot = next((r for r in range(col, n) if a[r][col] != 0), None)
        if pivot is None:
            return Fraction(0)
        if pivot != col:
            a[col], a[pivot] = a[pivot], a[col]
            det = -det
        det *= a[col][col]
        inv = Fraction(1) / a[col][col]
        for r in range(col + 1, n):
            factor = a[r][col] * inv
            if factor != 0:
                for c in range(col, n):
                    a[r][c] -= factor * a[col][c]
    return det


def demo_resultant_law() -> None:
    print("=" * 74)
    print("4. RESULTANT LAW:  gcd(f(N), g(N)) divides Res(f, g), all N")
    print("=" * 74)
    names = list(FAMILY)
    worst_overall = 0
    for a, b in combinations(names, 2):
        f, g = FAMILY[a], FAMILY[b]
        res = sylvester_resultant(f, g)
        observed = 0
        divides_all = True
        for n in range(-2000, 2001):
            d = math.gcd(poly_eval(f, n), poly_eval(g, n))
            observed = max(observed, d)
            if res != 0 and d != 0 and abs(res) % d != 0:
                divides_all = False
        worst_overall = max(worst_overall, observed)
        print(f"  ({a:<12}, {b:<12})  Res = {res:>4}   "
              f"max gcd = {observed:<3}  divides: {divides_all}")
    print(f"  --> uniform pairwise bound over the whole family: "
          f"{worst_overall} (theory: 7)")
    print()


# ---------------------------------------------------------------------------
# 5. Spectrum theorem
# ---------------------------------------------------------------------------

def prime_factors(n: int) -> List[int]:
    """Distinct prime factors of |n| by trial division."""
    n = abs(n)
    out: List[int] = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            out.append(d)
            while n % d == 0:
                n //= d
        d += 1 if d == 2 else 2
    if n > 1:
        out.append(n)
    return out


def demo_spectrum() -> None:
    print("=" * 74)
    print("5. SPECTRUM THEOREM: the prime spectrum belongs to the apparatus")
    print("=" * 74)
    spec_sq: set[int] = set()
    spec_c3: set[int] = set()
    for n in range(1, 400):
        spec_sq.update(prime_factors(n * n + 1))
        spec_c3.update(prime_factors(n * n + n + 1))
    bad_sq = sorted(p for p in spec_sq if not (p == 2 or p % 4 == 1))
    bad_c3 = sorted(p for p in spec_c3 if not (p == 3 or p % 3 == 1))
    print(f"  primes seen in N^2+1     (N < 400): {len(spec_sq)} distinct; "
          f"violations of 'p=2 or p=1 mod 4': {bad_sq}")
    print(f"  primes seen in N^2+N+1   (N < 400): {len(spec_c3)} distinct; "
          f"violations of 'p=3 or p=1 mod 3': {bad_c3}")
    print(f"  smallest members of spectrum(N^2+1):   "
          f"{sorted(spec_sq)[:10]}")
    print(f"  smallest members of spectrum(N^2+N+1): "
          f"{sorted(spec_c3)[:10]}")

    print("\n  Blum exclusion: primes = 3 mod 4 never divide any M^2 + 1.")
    for p in [3, 7, 11, 19, 23, 31, 43, 47]:
        hit = any((m * m + 1) % p == 0 for m in range(p))
        print(f"    p = {p:<3} (p mod 4 = {p % 4})  divides some M^2+1: {hit}")
    print()


# ---------------------------------------------------------------------------
# 6. Degeneracy of the naive invariants
# ---------------------------------------------------------------------------

def demo_degeneracy() -> None:
    print("=" * 74)
    print("6. DEGENERACY: three of the six invariants are constants")
    print("=" * 74)
    rng = random.Random(20260813)
    odd_samples = [2 * rng.randrange(10 ** 3, 10 ** 4) + 1 for _ in range(200)]
    lpf_pred = {least_prime_factor(n - 1) for n in odd_samples}
    lpf_succ = {least_prime_factor(n + 1) for n in odd_samples}
    lpf_sq = {least_prime_factor(n * n + 1) for n in odd_samples}
    mod8 = {(n * n + 1) % 8 for n in odd_samples}
    print(f"  over 200 random odd N:")
    print(f"    values of lpf(N-1):   {sorted(lpf_pred)}")
    print(f"    values of lpf(N+1):   {sorted(lpf_succ)}")
    print(f"    values of lpf(N^2+1): {sorted(lpf_sq)}")
    print(f"    values of (N^2+1) mod 8: {sorted(mod8)}  (theory: {{2}})")
    print("  -> zero bits of information about the factorisation.")
    print()


# ---------------------------------------------------------------------------
# 7. Freshness: infinite support, never a factor of N
# ---------------------------------------------------------------------------

def demo_freshness() -> None:
    print("=" * 74)
    print("7. FRESHNESS: primes of f(N) grow without bound, and never divide N")
    print("=" * 74)
    print("  Euclid step for f(N) = N^2 + 1: exclude a set S of primes by")
    print("  taking N divisible by all of them; then f(N) = 1 mod s for s in S.")
    S = [2, 5, 13, 17]
    base = 1
    for s in S:
        base *= s
    for k in (1, 2, 3):
        n = base * k
        val = n * n + 1
        fresh = [p for p in prime_factors(val) if p not in S]
        print(f"    N = {n:<8} N^2+1 = {val:<14} new primes: {fresh}")

    print("\n  and no prime of f(N) ever divides N:")
    rng = random.Random(7)
    for _ in range(4):
        n = rng.randrange(10 ** 4, 10 ** 5)
        val = n * n + 1
        shared = [p for p in prime_factors(val) if n % p == 0]
        print(f"    N = {n:<7} shared primes with N^2+1: {shared} "
              f"(gcd = {math.gcd(n, val)})")
    print()


# ---------------------------------------------------------------------------
# 8. The hint frontier
# ---------------------------------------------------------------------------

def useful_hint_count(p: int, q: int) -> int:
    """Number of h in [0, pq) with gcd(pq, h) != 1 (brute force)."""
    n = p * q
    return sum(1 for h in range(n) if math.gcd(n, h) != 1)


def demo_hint_frontier() -> None:
    print("=" * 74)
    print("8. HINT FRONTIER: exactly p+q-1 useful hints, density <= 2/B")
    print("=" * 74)
    for p, q in [(3, 5), (7, 11), (13, 17), (23, 29), (41, 43)]:
        obs = useful_hint_count(p, q)
        pred = p + q - 1
        B = min(p, q)
        dens = obs / (p * q)
        print(f"  N = {p}*{q} = {p * q:<5} useful hints: {obs:<4} "
              f"(theory p+q-1 = {pred})  density {dens:.5f} <= 2/B = "
              f"{2 / B:.5f}: {dens <= 2 / B}")

    print("\n  derived moduli always land on the useless side:")
    for p, q in [(101, 103), (211, 223), (1009, 1013)]:
        n = p * q
        gcds = {name: math.gcd(n, abs(poly_eval(f, n)))
                for name, f in FAMILY.items()}
        print(f"    N = {n:<9} gcd(N, f(N)) for all six f: "
              f"{sorted(set(gcds.values()))}")
    print()


# ---------------------------------------------------------------------------
# 9. Boundary: the exponential modulus leaks
# ---------------------------------------------------------------------------

def exponential_gcd(n: int) -> int:
    """gcd(n, 2^n - 1), computed with modular exponentiation."""
    if n <= 0:
        return 0
    return math.gcd(n, (pow(2, n, n) - 1) % n)


def multiplicative_order(a: int, m: int) -> int:
    """Multiplicative order of a modulo m (assumes gcd(a, m) = 1)."""
    k, x = 1, a % m
    while x != 1:
        x = (x * a) % m
        k += 1
    return k


def demo_exponential_boundary() -> None:
    print("=" * 74)
    print("9. BOUNDARY: 2^N - 1 is outside the class, and it leaks")
    print("=" * 74)
    a, b = 6, 0
    fa, fb = 2 ** a - 1, 2 ** b - 1
    print(f"  congruence transport fails: a-b = {a - b}, "
          f"F(a)-F(b) = {fa - fb}, divides: {(fa - fb) % (a - b) == 0}")

    leaks = [n for n in range(2, 400) if 1 < exponential_gcd(n) < n]
    print(f"  N < 400 with 1 < gcd(N, 2^N-1) < N: {leaks[:16]}"
          f"{' ...' if len(leaks) > 16 else ''}  ({len(leaks)} total)")

    print(f"\n  the headline witness:")
    g = exponential_gcd(253)
    print(f"    gcd(253, 2^253 - 1) = {g}     253 = 11 * 23 = "
          f"{11 * 23}   -> complete factorisation")
    print(f"    ord_23(2) = {multiplicative_order(2, 23)}  divides 253: "
          f"{253 % multiplicative_order(2, 23) == 0}")
    print(f"    ord_11(2) = {multiplicative_order(2, 11)}  divides 253: "
          f"{253 % multiplicative_order(2, 11) == 0}")

    print(f"\n  every multiple of 6 shares the prime 3:")
    for k in range(1, 6):
        n = 6 * k
        print(f"    N = {n:<4} gcd(N, 2^N-1) = {exponential_gcd(n)}")

    print(f"\n  but leaks are sparse for large random semiprimes:")
    rng = random.Random(11)
    hits = 0
    trials = 0
    small_primes = [p for p in range(100, 1000) if len(prime_factors(p)) == 1]
    for _ in range(200):
        p, q = rng.sample(small_primes, 2)
        trials += 1
        if exponential_gcd(p * q) > 1:
            hits += 1
    print(f"    {hits}/{trials} random semiprimes p*q with p,q in [100,1000) leak")
    print()


# ---------------------------------------------------------------------------
# 10. The confound: C(M) tracks N, not the gap |p-q|
# ---------------------------------------------------------------------------

def pearson(xs: Sequence[float], ys: Sequence[float]) -> float:
    """Pearson correlation coefficient of two equal-length samples."""
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    sxy = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    sxx = sum((x - mx) ** 2 for x in xs)
    syy = sum((y - my) ** 2 for y in ys)
    if sxx == 0 or syy == 0:
        return 0.0
    return sxy / math.sqrt(sxx * syy)


def omega(n: int) -> int:
    """Number of distinct prime factors of n."""
    return len(prime_factors(n))


def demo_confound() -> None:
    print("=" * 74)
    print("10. THE N-CONFOUND: invariants track N, not the gap |p - q|")
    print("=" * 74)
    rng = random.Random(2026)
    primes = [p for p in range(200, 4000) if len(prime_factors(p)) == 1]
    samples: List[Tuple[int, int, int]] = []
    for _ in range(120):
        p, q = rng.sample(primes, 2)
        samples.append((p, q, p * q))
    n_vals = [float(n) for _, _, n in samples]
    gap_vals = [float(abs(p - q)) for p, q, _ in samples]
    inv = [float(omega(n * n + 1)) for _, _, n in samples]

    c_n = pearson(inv, n_vals)
    c_gap = pearson(inv, gap_vals)
    print(f"  invariant C(M) = number of distinct prime factors of N^2+1")
    print(f"    corr(C(M), N)      = {c_n:+.3f}")
    print(f"    corr(C(M), |p-q|)  = {c_gap:+.3f}")

    # permutation null for the gap correlation
    null: List[float] = []
    shuffled = list(gap_vals)
    for _ in range(2000):
        rng.shuffle(shuffled)
        null.append(abs(pearson(inv, shuffled)))
    null.sort()
    p95 = null[int(0.95 * len(null))]
    print(f"    permutation null 95th percentile of |corr|: {p95:.3f}")
    print(f"    observed |corr| with gap inside the null: "
          f"{abs(c_gap) <= p95}")
    print("  -> the gap coordinate carries no signal; the N correlation is")
    print("     the confound, since p ~ sqrt(N) across a wide batch.")
    print()


# ---------------------------------------------------------------------------

def main() -> None:
    print()
    print("#" * 74)
    print("#  THE DERIVED-MODULUS CORNER, CLOSED  --  numerical demonstrations")
    print("#" * 74)
    print()
    demo_frozen_overlap()
    demo_classification()
    demo_closure()
    demo_resultant_law()
    demo_spectrum()
    demo_degeneracy()
    demo_freshness()
    demo_hint_frontier()
    demo_exponential_boundary()
    demo_confound()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
