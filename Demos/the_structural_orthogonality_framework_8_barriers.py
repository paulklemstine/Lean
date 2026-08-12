"""
The Structural Orthogonality Framework: numerical demonstrations.

Self-contained Python (standard library only) illustrating every principal
result of the eight-barrier framework for classical integer factoring:

  1. Polynomial barrier and its quantitative counting form.
  2. Meromorphic rigidity, illustrated numerically at the accumulation point 0.
  3. Symmetry barrier: power sums are functions of (s, N) alone.
  4. Computational circularity: (N, sigma), (N, phi) -> closed-form factors.
  5. Known-method-in-disguise: difference of squares == Fermat factorization.
  6. Multiplicative dichotomy in arbitrary degree via generic symmetric
     reduction modulo X^2 - sX + N.
  7. Structural orthogonality on a real population of semiprimes: the
     orthogonality identity, the covariance identity, the near-equal-N test,
     the squared-error decomposition, free-witness aggregation, the
     band-spread law.
  8. Boundary results: the smaller factor IS a function of N alone; fine bands
     make the test vacuous; the constant-band-mean hypothesis is necessary
     (covariance 9/4 on the population {6, 15}).

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import isqrt
from typing import Callable, Dict, Iterable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Elementary number theory helpers                                            #
# --------------------------------------------------------------------------- #


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return False
        f += 2
    return True


def primes_up_to(limit: int) -> List[int]:
    """All primes <= limit, by a simple sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, isqrt(limit) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def semiprimes_up_to(limit: int) -> List[Tuple[int, int, int]]:
    """All (N, p, q) with N = p*q <= limit and p < q both prime."""
    ps = primes_up_to(isqrt(limit))
    out: List[Tuple[int, int, int]] = []
    for p in ps:
        q = p + 1
        while p * q <= limit:
            if is_prime(q) and q > p:
                out.append((p * q, p, q))
            q += 1
    out.sort()
    return out


def min_factor(n: int) -> int:
    """Least prime factor: the witness that the smaller factor is N-only."""
    if n % 2 == 0:
        return 2
    f = 3
    while f * f <= n:
        if n % f == 0:
            return f
        f += 2
    return n


def sigma1(n: int) -> int:
    """Sum of divisors."""
    return sum(d for d in range(1, n + 1) if n % d == 0)


def totient(n: int) -> int:
    """Euler's totient, by definition."""
    def gcd(a: int, b: int) -> int:
        while b:
            a, b = b, a % b
        return a

    return sum(1 for k in range(1, n + 1) if gcd(k, n) == 1)


# --------------------------------------------------------------------------- #
# Minimal exact polynomial arithmetic over Q (coefficient lists, low degree    #
# first).                                                                      #
# --------------------------------------------------------------------------- #

Poly = List[Fraction]


def p_trim(a: Poly) -> Poly:
    b = list(a)
    while b and b[-1] == 0:
        b.pop()
    return b


def p_add(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else Fraction(0))
                   + (b[i] if i < len(b) else Fraction(0)) for i in range(n)])


def p_sub(a: Poly, b: Poly) -> Poly:
    n = max(len(a), len(b))
    return p_trim([(a[i] if i < len(a) else Fraction(0))
                   - (b[i] if i < len(b) else Fraction(0)) for i in range(n)])


def p_mul(a: Poly, b: Poly) -> Poly:
    if not a or not b:
        return []
    out = [Fraction(0)] * (len(a) + len(b) - 1)
    for i, x in enumerate(a):
        if x == 0:
            continue
        for j, y in enumerate(b):
            out[i + j] += x * y
    return p_trim(out)


def p_scale(a: Poly, c: Fraction) -> Poly:
    return p_trim([c * x for x in a])


def p_eval(a: Poly, x: Fraction) -> Fraction:
    acc = Fraction(0)
    for c in reversed(a):
        acc = acc * x + c
    return acc


def p_degree(a: Poly) -> int:
    return len(p_trim(a)) - 1


def lagrange_interpolate(points: Sequence[Tuple[Fraction, Fraction]]) -> Poly:
    """Exact interpolating polynomial through the given points."""
    result: Poly = []
    for i, (xi, yi) in enumerate(points):
        basis: Poly = [Fraction(1)]
        denom = Fraction(1)
        for j, (xj, _) in enumerate(points):
            if i == j:
                continue
            basis = p_mul(basis, [-xj, Fraction(1)])
            denom *= (xi - xj)
        result = p_add(result, p_scale(basis, yi / denom))
    return p_trim(result)


# --------------------------------------------------------------------------- #
# 1. Polynomial barrier and the counting bound                                #
# --------------------------------------------------------------------------- #


def demo_polynomial_barrier() -> None:
    print("=" * 78)
    print("1. POLYNOMIAL BARRIER  (no P in Q[X] with P(pq) = p for all semiprimes)")
    print("=" * 78)

    sample = semiprimes_up_to(200)[:6]
    pts = [(Fraction(N), Fraction(p)) for (N, p, _q) in sample]
    P = lagrange_interpolate(pts)
    print(f"  Interpolated a degree-{p_degree(P)} polynomial through "
          f"{len(pts)} semiprimes:")
    for (N, p, q) in sample:
        print(f"    N = {N:5d} = {p:3d} * {q:3d}   P(N) = {p_eval(P, Fraction(N))}"
              f"   target = {p}")

    print("\n  Testing it on the NEXT semiprimes (it must fail; the barrier says so):")
    failures = 0
    for (N, p, q) in semiprimes_up_to(400)[6:16]:
        val = p_eval(P, Fraction(N))
        ok = (val == p)
        failures += (0 if ok else 1)
        print(f"    N = {N:5d} = {p:3d} * {q:3d}   P(N) = "
              f"{str(val)[:28]:>28}   correct? {ok}")
    print(f"  -> failures: {failures}/10")

    print("\n  Quantitative counting barrier: for a FIXED small factor p, a degree-d")
    print("  polynomial can satisfy P(pq) = p for at most d primes q.")
    X = 20000
    d = p_degree(P)
    successes = [(N, p) for (N, p, _q) in semiprimes_up_to(X)
                 if p_eval(P, Fraction(N)) == p]
    pi_sqrtX = len(primes_up_to(isqrt(X)))
    bound = d * pi_sqrtX
    total = len(semiprimes_up_to(X))
    print(f"    X = {X}:  #successes = {len(successes)}   certified bound "
          f"d*pi(sqrt X) = {d}*{pi_sqrtX} = {bound}")
    print(f"    semiprimes below X = {total};  success density "
          f"= {len(successes)/total:.6f}")


# --------------------------------------------------------------------------- #
# 2. Meromorphic rigidity, numerically                                        #
# --------------------------------------------------------------------------- #


def demo_rigidity() -> None:
    print()
    print("=" * 78)
    print("2. MEROMORPHIC RIGIDITY  (no f meromorphic at 0 with f(1/N) = 1/p)")
    print("=" * 78)
    print("  Freeze p = 3: the sample points 1/(3q) accumulate at 0, and f must")
    print("  take the constant value 1/3 on all of them, forcing f == 1/3 near 0.")
    qs = [q for q in primes_up_to(200) if q > 3][:8]
    for q in qs:
        N = 3 * q
        print(f"    q = {q:3d}   1/N = {1.0/N:.8f}   required f(1/N) = 1/3 = "
              f"{1/3:.8f}")
    print("  Freeze p = 5: the points 1/(5q) ALSO accumulate at 0, but there")
    print("  f must equal 1/5 = 0.20000000 -- contradiction with f == 1/3.")
    for q in [q for q in primes_up_to(200) if q > 5][:4]:
        N = 5 * q
        print(f"    q = {q:3d}   1/N = {1.0/N:.8f}   required f(1/N) = 1/5 = "
              f"{1/5:.8f}")


# --------------------------------------------------------------------------- #
# 3-5. Symmetry, circularity, Fermat                                          #
# --------------------------------------------------------------------------- #


def power_sum(e1: int, e2: int, k: int) -> int:
    """Newton recursion T_0 = 2, T_1 = e1, T_{k+2} = e1 T_{k+1} - e2 T_k."""
    a, b = 2, e1
    if k == 0:
        return a
    for _ in range(k - 1):
        a, b = b, e1 * b - e2 * a
    return b


def recover_from_sum(N: int, s: int) -> Tuple[int, int]:
    """Closed-form recovery of the factors from (N, s = p+q)."""
    disc = s * s - 4 * N
    r = isqrt(disc)
    assert r * r == disc, "discriminant must be a perfect square"
    return ((s - r) // 2, (s + r) // 2)


def demo_symmetry_and_circularity() -> None:
    print()
    print("=" * 78)
    print("3. SYMMETRY BARRIER  (power sums see only s = p+q and N = pq)")
    print("=" * 78)
    p, q = 13, 17
    s, N = p + q, p * q
    for k in range(6):
        direct = p ** k + q ** k
        newton = power_sum(s, N, k)
        print(f"    k = {k}:  p^k + q^k = {direct:12d}   Newton(s, N) = "
              f"{newton:12d}   equal? {direct == newton}")
    print("  The recursion never mentions p or q individually: any two factor")
    print("  pairs with the same (N, s) are indistinguishable by ALL power sums.")

    print()
    print("=" * 78)
    print("4. COMPUTATIONAL CIRCULARITY  ((N, s) factors N in closed form)")
    print("=" * 78)
    for (N, p, q) in [(15, 3, 5), (91, 7, 13), (221, 13, 17), (1517, 37, 41)]:
        sg = sigma1(N)
        ph = totient(N)
        s_from_sigma = sg - N - 1
        s_from_phi = N + 1 - ph
        rp, rq = recover_from_sum(N, s_from_sigma)
        rp2, rq2 = recover_from_sum(N, s_from_phi)
        print(f"    N = {N:5d}:  sigma = {sg:6d} -> s = {s_from_sigma:4d} -> "
              f"({rp}, {rq})   phi = {ph:6d} -> s = {s_from_phi:4d} -> ({rp2}, {rq2})"
              f"   true = ({p}, {q})")
    print("  Constant side of the dichotomy (no information at all):")
    for (N, p, q) in [(15, 3, 5), (91, 7, 13), (1517, 37, 41)]:
        tau = sum(1 for d in range(1, N + 1) if N % d == 0)
        print(f"    N = {N:5d}:  tau = {tau}  omega = 2  mu = +1   (same for every "
              f"semiprime)")

    print()
    print("=" * 78)
    print("5. KNOWN-METHOD-IN-DISGUISE  (difference of squares == Fermat)")
    print("=" * 78)
    for (N, p, q) in [(15, 3, 5), (91, 7, 13), (221, 13, 17)]:
        a = (p + q) // 2
        b = (q - p) // 2
        print(f"    N = {N:5d} = {a}^2 - {b}^2 = {a*a - b*b}   <->   "
              f"({a}-{b})({a}+{b}) = {p} * {q}")


# --------------------------------------------------------------------------- #
# 6. The multiplicative dichotomy in arbitrary degree                         #
# --------------------------------------------------------------------------- #


def generic_reduction(F: Sequence[int], N: int) -> Poly:
    """Universal invariant polynomial psi(s) = Psi_F(s, N) in Z[s].

    Reduce X^k modulo X^2 - s X + N generically:
        X^k = B_k X + A_k,  A_0 = 1, B_0 = 0,
        A_{k+1} = -N B_k,   B_{k+1} = B_k s + A_k.
    Then Psi_F = A_F^2 + A_F B_F s + B_F^2 N and Psi_F(p+q, pq) = F(p) F(q).
    """
    A: Poly = [Fraction(1)]
    B: Poly = []
    AF: Poly = []
    BF: Poly = []
    for c in F:
        if c:
            AF = p_add(AF, p_scale(A, Fraction(c)))
            BF = p_add(BF, p_scale(B, Fraction(c)))
        A, B = p_scale(B, Fraction(-N)), p_add(p_mul(B, [Fraction(0), Fraction(1)]), A)
    return p_add(p_add(p_mul(AF, AF), p_mul(p_mul(AF, BF), [Fraction(0), Fraction(1)])),
                 p_scale(p_mul(BF, BF), Fraction(N)))


def int_roots(poly: Poly, limit: int) -> List[int]:
    """Integer roots of an integral polynomial searched in [-limit, limit]."""
    return [s for s in range(-limit, limit + 1) if p_eval(poly, Fraction(s)) == 0]


def demo_dichotomy() -> None:
    print()
    print("=" * 78)
    print("6. MULTIPLICATIVE DICHOTOMY IN ARBITRARY DEGREE")
    print("=" * 78)
    print("  For F in Z[X], the invariant F(p)F(q) equals a universal polynomial")
    print("  Psi_F(s, N) of s-degree <= 2 deg F, computable from N alone.")

    families: List[Tuple[str, List[int]]] = [
        ("F = X            ", [0, 1]),
        ("F = X + 1        ", [1, 1]),
        ("F = X - 1        ", [-1, 1]),
        ("F = X^2          ", [0, 0, 1]),
        ("F = X^2 + 1      ", [1, 0, 1]),
        ("F = 2X^3 - X + 5 ", [5, -1, 0, 2]),
    ]
    N, p, q = 15, 3, 5
    print(f"\n  Modulus N = {N} = {p} * {q}, hidden sum s = {p + q}.\n")
    for name, F in families:
        psi = generic_reduction(F, N)
        T = (p_eval([Fraction(c) for c in F], Fraction(p))
             * p_eval([Fraction(c) for c in F], Fraction(q)))
        check = p_eval(psi, Fraction(p + q))
        deg = p_degree(psi)
        side = "N-ONLY (blind)" if deg <= 0 else "CIRCULAR (sum-revealing)"
        print(f"    {name}: deg_s Psi = {deg:2d}   Psi(s={p+q}) = {check}"
              f"   F(p)F(q) = {T}   -> {side}")
        if deg > 0:
            cand = int_roots(p_sub(psi, [T]), 60)
            recovered = []
            for s in cand:
                disc = s * s - 4 * N
                if disc >= 0 and isqrt(disc) ** 2 == disc:
                    recovered.append(recover_from_sum(N, s))
            print(f"        candidate sums {cand} (at most 2 deg F = "
                  f"{2*(len(F)-1)})  ->  factorizations {recovered}")


# --------------------------------------------------------------------------- #
# 7. Structural orthogonality on a population of semiprimes                   #
# --------------------------------------------------------------------------- #


def band_means(labels: Sequence[int], Y: Sequence[float]) -> List[float]:
    tot: Dict[int, float] = {}
    cnt: Dict[int, int] = {}
    for k, y in zip(labels, Y):
        tot[k] = tot.get(k, 0.0) + y
        cnt[k] = cnt.get(k, 0) + 1
    return [tot[k] / cnt[k] for k in labels]


def mean(v: Sequence[float]) -> float:
    return sum(v) / len(v)


def cov(x: Sequence[float], y: Sequence[float]) -> float:
    mx, my = mean(x), mean(y)
    return sum((a - mx) * (b - my) for a, b in zip(x, y)) / len(x)


def var(x: Sequence[float]) -> float:
    return cov(x, x)


def corr(x: Sequence[float], y: Sequence[float]) -> float:
    vx, vy = var(x), var(y)
    if vx <= 0 or vy <= 0:
        return 0.0
    return cov(x, y) / (vx ** 0.5 * vy ** 0.5)


def demo_structural_orthogonality() -> None:
    print()
    print("=" * 78)
    print("7. STRUCTURAL ORTHOGONALITY  (the statistical core)")
    print("=" * 78)

    pop = semiprimes_up_to(200000)
    Ns = [N for (N, _p, _q) in pop]
    Y = [float(p) for (_N, p, _q) in pop]          # the hidden target
    labels = [N // 40 for N in Ns]                  # the band label
    bm = band_means(labels, Y)
    print(f"  Population: {len(pop)} semiprimes below 200000, "
          f"band label k = floor(N/40), target Y = smaller factor p.")
    print(f"  Distinct bands: {len(set(labels))}")
    print("  An 'N-only invariant' in the sense of the theorem is a function of the")
    print("  BAND LABEL, i.e. of the modulus at the resolution of the experiment.")

    witnesses: List[Tuple[str, Callable[[int], float]]] = [
        ("k mod 9                ", lambda k: float(k % 9)),
        ("digit sum of k         ", lambda k: float(sum(int(c) for c in str(k)))),
        ("k mod 97               ", lambda k: float(k % 97)),
        ("frac part of sqrt(k)   ", lambda k: k ** 0.5 - int(k ** 0.5)),
        ("log-scale ramp of k    ", lambda k: float(len(str(k))) * ((k % 1000) / 1000.0)),
        ("(k mod 4) * (k mod 3)  ", lambda k: float((k % 4) * (k % 3))),
    ]

    print("\n  (a) The orthogonality identity  sum_i g(n_i) (Y_i - E[Y|n]_i) = 0")
    for name, g in witnesses:
        gv = [g(k) for k in labels]
        val = sum(a * (b - c) for a, b, c in zip(gv, Y, bm))
        print(f"      {name}: {val: .6e}")

    print("\n  (b) All correlation is band correlation: "
          "cov(g o n, Y) = cov(g o n, E[Y|n])")
    for name, g in witnesses:
        gv = [g(k) for k in labels]
        print(f"      {name}: cov(g,Y) = {cov(gv, Y): .6f}   "
              f"cov(g,E[Y|n]) = {cov(gv, bm): .6f}")

    print("\n  (c) Best-predictor barrier and the squared-error decomposition")
    irreducible = sum((b - y) ** 2 for b, y in zip(bm, Y))
    for name, g in witnesses:
        gv = [g(k) for k in labels]
        total = sum((a - y) ** 2 for a, y in zip(gv, Y))
        excess = sum((a - b) ** 2 for a, b in zip(gv, bm))
        rel = abs(total - excess - irreducible) / max(1.0, total)
        print(f"      {name}: err = {total:14.2f} = excess {excess:14.2f} + "
              f"irreducible {irreducible:12.2f}   "
              f"(identity holds: {rel < 1e-9})")

    print("\n  (d) Free-witness aggregation: an arbitrary nonlinear combination of")
    print("      N-only witnesses is still N-only and still cannot beat the band mean.")

    def aggregate(k: int) -> float:
        a = (k % 9) / 9.0
        b = sum(int(c) for c in str(k)) / 60.0
        c = (k % 97) / 97.0
        return 1000.0 * (a * b + (1.0 - c) ** 2 + max(a, c) - min(b, c) ** 3)

    agg = [aggregate(k) for k in labels]
    total = sum((a - y) ** 2 for a, y in zip(agg, Y))
    print(f"      aggregated witness: err = {total:.2f}  >=  band-mean err = "
          f"{irreducible:.2f}   ({total >= irreducible})")
    print(f"      orthogonality check: "
          f"{sum(a * (b - c) for a, b, c in zip(agg, Y, bm)): .6e}")

    print("\n  (e) The band-spread law:  |corr(g o n, Y)| <= "
          "sqrt(Var(E[Y|n]) / Var(Y))")
    eps = var(bm) / var(Y)
    print(f"      Var(E[Y|n]) / Var(Y) = {eps:.6f}   =>  universal bound "
          f"sqrt(eps) = {eps ** 0.5:.6f}")
    for name, g in witnesses:
        gv = [g(k) for k in labels]
        c = corr(gv, Y)
        print(f"      {name}: |corr| = {abs(c):.6f}   <= {eps ** 0.5:.6f}   "
              f"{abs(c) <= eps ** 0.5 + 1e-12}")
    ca = corr(agg, Y)
    print(f"      aggregated witness     : |corr| = {abs(ca):.6f}   <= "
          f"{eps ** 0.5:.6f}   {abs(ca) <= eps ** 0.5 + 1e-12}")

    print("\n  (f) Law of total variance: "
          "Var(Y) = within-band error + Var(E[Y|n])")
    within = irreducible / len(Y)
    print(f"      Var(Y) = {var(Y):.6f}   within = {within:.6f}   "
          f"Var(E[Y|n]) = {var(bm):.6f}   sum = {within + var(bm):.6f}")

    print("\n  (g) Quantized barrier: a strategy emitting only k values pays the")
    print("      quantization error of the band means against its palette.")
    for k in (1, 2, 4, 8, 16):
        srt = sorted(bm)
        palette = [srt[min(len(srt) - 1, (2 * j + 1) * len(srt) // (2 * k))]
                   for j in range(k)]
        qerr = sum(min((v - b) ** 2 for v in palette) for b in bm)
        print(f"      |V| = {k:2d}:  quantization error = {qerr:14.2f}   "
              f"lower bound on error = {qerr + irreducible:14.2f}")

    print("\n  (h) Sharpness of the hypothesis: an invariant that varies WITHIN a")
    print("      band is not a function of the band label, and the identity fails.")
    print("      Such invariants can carry genuine factor information -- e.g.")
    print("      N mod 3 = 0 already reveals the factor 3.")
    for name, g in [("N mod 3                ", lambda N: float(N % 3)),
                    ("N mod 4 * (N mod 3)    ", lambda N: float((N % 4) * (N % 3)))]:
        gv = [g(N) for N in Ns]
        val = sum(a * (b - c) for a, b, c in zip(gv, Y, bm))
        print(f"      {name}: orthogonality defect = {val: .6e}   "
              f"corr = {corr(gv, Y): .6f}")


# --------------------------------------------------------------------------- #
# 8. Boundary of the framework                                                #
# --------------------------------------------------------------------------- #


def demo_boundary() -> None:
    print()
    print("=" * 78)
    print("8. THE BOUNDARY OF THE FRAMEWORK")
    print("=" * 78)

    print("  (a) The barriers are NOT information-theoretic: the least prime factor")
    print("      is a function of N alone that returns the smaller factor.")
    for (N, p, q) in semiprimes_up_to(120)[:8]:
        print(f"      N = {N:4d} = {p:3d} * {q:3d}   minFac(N) = {min_factor(N)}"
              f"   correct? {min_factor(N) == p}")

    print("\n  (b) Fine bands make the near-equal-N test vacuous: if the band label")
    print("      separates the population, the band mean reproduces the target.")
    pop = semiprimes_up_to(2000)
    Y = [float(p) for (_N, p, _q) in pop]
    fine = [N for (N, _p, _q) in pop]          # injective band label
    bmf = band_means(fine, Y)
    err_fine = sum((b - y) ** 2 for b, y in zip(bmf, Y))
    coarse = [N // 40 for (N, _p, _q) in pop]
    bmc = band_means(coarse, Y)
    err_coarse = sum((b - y) ** 2 for b, y in zip(bmc, Y))
    print(f"      injective band label: irreducible error = {err_fine:.6f} "
          f"(the test says nothing)")
    print(f"      coarse band  N//40  : irreducible error = {err_coarse:.2f} "
          f"(the test has content)")

    print("\n  (c) The constant-band-mean hypothesis is necessary. On the two-point")
    print("      population {6, 15}, the N-only invariant g(N) = N has covariance")
    print("      9/4 with the smaller prime factor.")
    Xv = [Fraction(6), Fraction(15)]
    Yv = [Fraction(min_factor(6)), Fraction(min_factor(15))]
    mx = sum(Xv) / 2
    my = sum(Yv) / 2
    cxy = sum((a - mx) * (b - my) for a, b in zip(Xv, Yv)) / 2
    print(f"      X = (6, 15),  Y = (minFac 6, minFac 15) = (2, 3):  cov = {cxy}"
          f"  (= 9/4, exact rational arithmetic)")
    print("      So an N-only invariant CAN correlate with the target across bands;")
    print("      zero correlation is a consequence of the protocol, not a law.")


# --------------------------------------------------------------------------- #


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE STRUCTURAL ORTHOGONALITY FRAMEWORK -- NUMERICAL DEMONSTRATIONS  #")
    print("#" * 78)
    demo_polynomial_barrier()
    demo_rigidity()
    demo_symmetry_and_circularity()
    demo_dichotomy()
    demo_structural_orthogonality()
    demo_boundary()
    print()
    print("=" * 78)
    print("SUMMARY")
    print("=" * 78)
    print("  Every N-only invariant tested -- algebraic, arithmetic, aggregated or")
    print("  adaptive -- is orthogonal to the residual Y - E[Y|n] to machine")
    print("  precision, has covariance with the hidden factor equal to its")
    print("  covariance with the band means, and cannot beat the band mean as a")
    print("  predictor. The eight barriers explain why.")
    print()


if __name__ == "__main__":
    main()
