"""
Saturation versus Dilution: numerical demonstrations.

Self-contained Python (standard library only). Running this file reproduces,
numerically, every quantitative claim of the accompanying paper:

  1. R^2 of a linear covariate in an orthonormal signal model equals the
     discrete Cauchy-Schwarz ratio.
  2. Exact flatness factorisation:  R2_count = flat(T) * R2_weighted.
  3. Saturation of the harmonically weighted dial:
        1 - 1/n <= R2_weighted <= 1 - 1/(8n)      (ambient population >= 2n)
     in particular R2_weighted >= 0.9975 at n = 400, for any ambient size.
  4. Dilution of the equal-weight count dial:
        R2_count <= (1 + log n)^2 / n  ->  0.
  5. Finiteness of the count-dial optimum: score(n) = H_n^2 / n attains a
     global maximum at a finite window; no scale shift is possible.
  6. Reciprocity-flip dichotomy: the prime-bottom and composite-bottom dial
     forms differ exactly when  l = 3 (mod 4)  and  N = 3 (mod 4);
     conditional flip rate 100%, zero violations.
  7. A +/-1 twist annihilates a perfect linear correlation.
  8. XOR law, factor blindness of the product dial, saturation on squares.
  9. Dispersion reading algebra: (D-1)/D, and consistency of the two
     published readings.

Usage:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------
# 0. Elementary number theory
# --------------------------------------------------------------------------


def primes_upto(limit: int) -> List[int]:
    """All primes <= limit by a simple sieve of Eratosthenes."""
    if limit < 2:
        return []
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(limit**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(limit + 1) if sieve[i]]


def jacobi(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n >= 1.  Returns -1, 0 or 1.

    Binary algorithm: strip factors of two (sign rule from n mod 8) and apply
    reciprocity swaps (sign flip exactly when both arguments are 3 mod 4).
    """
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires an odd positive bottom argument")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a            # reciprocity swap
        if a % 4 == 3 and n % 4 == 3:
            result = -result   # the twist
        a %= n
    return result if n == 1 else 0


def twist(a: int, b: int) -> int:
    """The reciprocity twist character: -1 iff a = b = 3 (mod 4), else +1."""
    return -1 if (a % 4 == 3 and b % 4 == 3) else 1


# --------------------------------------------------------------------------
# 1. The orthonormal signal model
# --------------------------------------------------------------------------


def r2_orthonormal(c: Sequence[float], a: Sequence[float]) -> float:
    """R^2 of the covariate with coefficients c against the target with
    amplitudes a, in a model with orthonormal per-prime contributions:

        R^2 = (sum c_i a_i)^2 / ((sum c_i^2)(sum a_i^2)).
    """
    num = sum(ci * ai for ci, ai in zip(c, a)) ** 2
    den = sum(ci * ci for ci in c) * sum(ai * ai for ai in a)
    return 0.0 if den == 0 else num / den


def r2_count(a: Sequence[float], n: int) -> float:
    """Explained variance of the equal-weight count dial on the window of the
    first n indices, inside the population indexed by all of `a`."""
    if n == 0:
        return 0.0
    num = sum(a[:n]) ** 2
    den = n * sum(ai * ai for ai in a)
    return num / den


def r2_weighted(a: Sequence[float], n: int) -> float:
    """Explained variance of the amplitude-weighted dial on the first n."""
    den = sum(ai * ai for ai in a)
    return 0.0 if den == 0 else sum(ai * ai for ai in a[:n]) / den


def flatness(a: Sequence[float], n: int) -> float:
    """Flatness of the amplitude profile on the first n indices:
    1 for a constant profile, smaller the more the amplitudes vary."""
    if n == 0:
        return 0.0
    den = n * sum(ai * ai for ai in a[:n])
    return 0.0 if den == 0 else sum(a[:n]) ** 2 / den


def harmonic_profile(size: int) -> List[float]:
    """The amplitude profile a_i = 1/(i+1), the model form of a_l ~ 1/l."""
    return [1.0 / (i + 1) for i in range(size)]


def harmonic_number(n: int) -> float:
    return sum(1.0 / k for k in range(1, n + 1))


def count_score(n: int) -> float:
    """The ambient-free count score H_n^2 / n."""
    return harmonic_number(n) ** 2 / n


# --------------------------------------------------------------------------
# 2. Arithmetic dials
# --------------------------------------------------------------------------


def count_dial(N: int, primes: Sequence[int]) -> int:
    """#{l in window : N is a quadratic residue mod l}."""
    return sum(1 for l in primes if jacobi(N, l) == 1)


def weighted_dial(N: int, primes: Sequence[int]) -> float:
    """sum over residue primes l of the window of 1/l."""
    return sum(1.0 / l for l in primes if jacobi(N, l) == 1)


def composite_bottom_dial(N: int, primes: Sequence[int]) -> float:
    """The flipped form: the symbol with the composite N on the bottom."""
    return sum(1.0 / l for l in primes if N % 2 == 1 and jacobi(l, N) == 1)


def pearson(x: Sequence[float], y: Sequence[float]) -> float:
    m = len(x)
    mx, my = sum(x) / m, sum(y) / m
    sxy = sum((xi - mx) * (yi - my) for xi, yi in zip(x, y))
    sxx = math.sqrt(sum((xi - mx) ** 2 for xi in x))
    syy = math.sqrt(sum((yi - my) ** 2 for yi in y))
    return 0.0 if sxx == 0 or syy == 0 else sxy / (sxx * syy)


# --------------------------------------------------------------------------
# 3. Dispersion reading algebra
# --------------------------------------------------------------------------


def implied_dispersion(raw: float, excess: float) -> float:
    """Baseline dispersion implied by a (raw, excess-above-Poisson) pair."""
    return 1.0 / (1.0 - raw / excess)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_model_identities() -> None:
    print("=" * 74)
    print("1.  R^2 in the orthonormal model, and the flatness factorisation")
    print("=" * 74)
    a = harmonic_profile(64)
    for n in (1, 2, 4, 8, 16, 32, 64):
        c_count = [1.0] * n + [0.0] * (len(a) - n)
        c_weight = list(a[:n]) + [0.0] * (len(a) - n)
        rc, rw = r2_count(a, n), r2_weighted(a, n)
        # the dials really are those covariates
        assert abs(r2_orthonormal(c_count, a) - rc) < 1e-12
        assert abs(r2_orthonormal(c_weight, a) - rw) < 1e-12
        f = flatness(a, n)
        assert abs(f * rw - rc) < 1e-12          # exact factorisation
        assert rc <= rw + 1e-15                  # Cauchy-Schwarz domination
        print(f"  n={n:3d}   count R2={rc:.6f}   weighted R2={rw:.6f}"
              f"   flatness={f:.6f}   flat*weighted={f*rw:.6f}")
    print("  -> R2_count = flatness * R2_weighted holds to machine precision,")
    print("     and the count dial never beats the weighted one.\n")


def demo_saturation_and_dilution() -> None:
    print("=" * 74)
    print("2.  Saturation versus dilution for the harmonic amplitude profile")
    print("=" * 74)
    print(f"  {'n':>6} {'ambient N':>10} {'weighted R2':>13} {'1-1/n':>10}"
          f" {'1-1/(8n)':>10} {'count R2':>10} {'(1+log n)^2/n':>15}")
    for n in (1, 2, 5, 10, 50, 100, 400, 1000):
        N = 2 * n
        a = harmonic_profile(N)
        rw, rc = r2_weighted(a, n), r2_count(a, n)
        lo, hi = 1 - 1.0 / n, 1 - 1.0 / (8 * n)
        cap = (1 + math.log(n)) ** 2 / n if n > 1 else 1.0
        assert lo - 1e-12 <= rw <= hi + 1e-12
        assert rc <= cap + 1e-12
        print(f"  {n:6d} {N:10d} {rw:13.6f} {lo:10.6f} {hi:10.6f}"
              f" {rc:10.6f} {cap:15.6f}")
    print("  -> weighted R2 is trapped between 1-1/n and 1-1/(8n): rate Theta(1/n).")
    print("  -> count R2 is capped by (1+log n)^2/n, which tends to zero.\n")

    print("  Uniformity in the ambient population (window fixed at n = 400):")
    for N in (400, 4000, 40_000, 400_000):
        a = harmonic_profile(N)
        rw = r2_weighted(a, 400)
        assert rw >= 0.9975
        print(f"    ambient N = {N:7d}   weighted R2 at n=400 = {rw:.6f}  (>= 0.9975)")
    print("  -> a window of 400 explains >= 99.75% of what ANY window can.\n")


def demo_window_optimum() -> None:
    print("=" * 74)
    print("3.  Finiteness of the count-dial optimum: no scale shift is possible")
    print("=" * 74)
    # explicit search bound: score(n) <= (1+log n)^2 / n < score(1) = 1
    m = 2
    while (1 + math.log(m)) ** 2 / m >= 1.0:
        m += 1
    best_n, best = max(((n, count_score(n)) for n in range(1, m + 1)),
                       key=lambda t: t[1])
    print(f"  search bound m = {m}  (beyond it the score is below score(1) = 1)")
    print(f"  global maximiser of H_n^2 / n:  n* = {best_n},  score = {best:.6f}")
    for n in (1, 2, 3, 10, 100, 1000, 10_000, 100_000):
        print(f"    score({n:6d}) = {count_score(n):.8f}")
    print("  -> the score decays to 0, so its maximum is attained at a finite")
    print("     window: enlarging the cutoff can never rescue the count dial.\n")


def demo_arithmetic_sweep() -> None:
    print("=" * 74)
    print("4.  The two dials on a real population of semiprimes")
    print("=" * 74)
    ps = [p for p in primes_upto(4000) if p > 2000]
    population: List[int] = [ps[i] * ps[i + 1] for i in range(60)]
    windows: Dict[int, List[int]] = {
        B: [l for l in primes_upto(B) if l > 2] for B in (400, 4000, 40_000)
    }
    print(f"  population: {len(population)} semiprimes, "
          f"{min(population)} .. {max(population)}")
    base_w = [weighted_dial(N, windows[400]) for N in population]
    for B in sorted(windows):
        w = [weighted_dial(N, windows[B]) for N in population]
        c = [float(count_dial(N, windows[B])) for N in population]
        print(f"  B = {B:6d}: |window| = {len(windows[B]):5d}   "
              f"mean count = {sum(c)/len(c):9.2f}   mean weighted = "
              f"{sum(w)/len(w):.6f}   corr(W(B), W(400)) = {pearson(w, base_w):.6f}")
    print("  -> the count dial's scale grows without bound while the weighted")
    print("     dial barely moves and stays correlated ~1 with its B=400 version.\n")


def demo_reciprocity_audit() -> None:
    print("=" * 74)
    print("5.  Reciprocity-flip audit: flip happens IFF l = N = 3 (mod 4)")
    print("=" * 74)
    ls = [l for l in primes_upto(200) if l > 2]
    rows = 0
    cond_rows = 0
    cond_flips = 0
    uncond_flips = 0
    violations = 0
    for N in range(3, 2000, 2):
        for l in ls:
            if math.gcd(l, N) != 1:
                continue
            clean = jacobi(N, l)
            flipped = jacobi(l, N)
            assert flipped == twist(l, N) * clean      # reciprocity as a twist
            flip = clean != flipped
            cond = (l % 4 == 3) and (N % 4 == 3)
            rows += 1
            cond_rows += cond
            cond_flips += flip and cond
            uncond_flips += flip
            violations += flip != cond
    print(f"  rows audited            : {rows}")
    print(f"  rows meeting condition  : {cond_rows} ({100*cond_rows/rows:.2f}%)")
    print(f"  conditional flip rate   : {100*cond_flips/cond_rows:.2f}%  "
          f"({cond_flips}/{cond_rows})")
    print(f"  unconditional flip rate : {100*uncond_flips/rows:.2f}%")
    print(f"  violations of 'flip <=> condition': {violations}")
    assert violations == 0 and cond_flips == cond_rows
    print("  -> total flip on the condition, identical agreement off it.\n")

    # localisation: on l = 1 (mod 4) the two dial forms are the same covariate
    w1 = [l for l in primes_upto(400) if l % 4 == 1]
    same = all(
        abs(sum(1.0 / l for l in w1 if jacobi(l, N) == 1)
            - sum(1.0 / l for l in w1 if jacobi(N, l) == 1)) < 1e-15
        for N in range(3, 999, 2)
    )
    print(f"  on a window of primes l = 1 (mod 4), the two dial forms coincide: {same}")
    print("  -> the whole artifact is carried by the 3 mod 4 half of the window.\n")


def demo_twist_annihilation() -> None:
    print("=" * 74)
    print("6.  A +/-1 twist can send a perfect correlation to exactly zero")
    print("=" * 74)
    target = [1, 1, -1, -1]
    clean = list(target)                    # perfectly aligned dial
    tw = [1, -1, 1, -1]                     # twist pattern on a balanced set
    flipped = [w * c for w, c in zip(tw, clean)]
    cov_clean = sum(c * t for c, t in zip(clean, target))
    cov_flip = sum(f * t for f, t in zip(flipped, target))
    print(f"  target            : {target}")
    print(f"  clean dial        : {clean}      covariance with target = {cov_clean}")
    print(f"  twist pattern     : {tw}")
    print(f"  flipped dial      : {flipped}      covariance with target = {cov_flip}")
    assert cov_clean == 4 and cov_flip == 0
    recovered = [w * f for w, f in zip(tw, flipped)]
    assert recovered == clean
    print("  -> zero linear signal, yet the twist is an involution: applying it")
    print("     again recovers the clean dial exactly. No information is lost;")
    print("     only the LINEAR readability of it is.\n")


def demo_product_dial_limits() -> None:
    print("=" * 74)
    print("7.  What the product dial cannot see: XOR law, blindness, squares")
    print("=" * 74)
    window = [l for l in primes_upto(200) if l > 2]

    # XOR law
    ok = True
    for a_val in range(3, 60):
        for b_val in range(3, 60):
            for l in window[:10]:
                if math.gcd(a_val * b_val, l) != 1:
                    continue
                lhs = jacobi(a_val * b_val, l) == 1
                rhs = jacobi(a_val, l) == jacobi(b_val, l)
                ok &= lhs == rhs
    print(f"  XOR law  (ab | l) = 1  <=>  (a|l) = (b|l)   verified: {ok}")

    # factor blindness: equal symbol products give equal dials
    found = 0
    ps = [p for p in primes_upto(500) if p > 200]
    for i, p in enumerate(ps):
        for q in ps[i + 1:]:
            for j, p2 in enumerate(ps):
                for q2 in ps[j + 1:]:
                    if (p, q) >= (p2, q2):
                        continue
                    if all(jacobi(p, l) * jacobi(q, l)
                           == jacobi(p2, l) * jacobi(q2, l) for l in window[:6]):
                        d1 = weighted_dial(p * q, window[:6])
                        d2 = weighted_dial(p2 * q2, window[:6])
                        assert abs(d1 - d2) < 1e-15
                        if found == 0:
                            print(f"  blindness example: {p}*{q} and {p2}*{q2} "
                                  f"share the dial value {d1:.6f}")
                        found += 1
                        if found > 40:
                            break
                if found > 40:
                    break
            if found > 40:
                break
        if found > 40:
            break
    print(f"  pairs of semiprimes with identical dials found: {found}+")

    # squares saturate
    m = 1009
    full = sum(1.0 / l for l in window)
    assert abs(weighted_dial(m * m, window) - full) < 1e-12
    print(f"  square {m}^2 attains the maximal dial value "
          f"{full:.6f} = sum of 1/l over the window")
    print("  -> these are hard ceilings: no reweighting can break them.\n")


def demo_reading_algebra() -> None:
    print("=" * 74)
    print("8.  Dispersion bookkeeping: two readings of one reduction")
    print("=" * 74)
    D, delta = 4.88, 1.63
    raw, excess = delta / D, delta / (D - 1)
    print(f"  baseline dispersion D = {D}, reduction Delta = {delta}")
    print(f"  raw reading    = Delta/D     = {raw:.4f}")
    print(f"  excess reading = Delta/(D-1) = {excess:.4f}")
    print(f"  ratio          = (D-1)/D     = {(D-1)/D:.6f}  "
          f"(measured {raw/excess:.6f}, independent of Delta)")
    for other in (0.5, 2.0, 3.1):
        assert abs((other / D) / (other / (D - 1)) - (D - 1) / D) < 1e-12
    d1 = implied_dispersion(0.3343, 0.4206)
    d2 = implied_dispersion(0.4851, 0.6100)
    print(f"  count dial   at B=400 : raw 33.43%, excess 42.06% -> D = {d1:.4f}")
    print(f"  weighted dial at B=1e6: raw 48.51%, excess 61.00% -> D = {d2:.4f}")
    print(f"  |difference| = {abs(d1-d2):.4f}  (< 0.03: one and the same population)")
    assert abs(d1 - d2) < 0.03
    raw_res = (1 - 0.3343, 1 - 0.4851)      # count, weighted (raw reading)
    exc_res = (1 - 0.4206, 1 - 0.6100)      # count, weighted (excess reading)
    print(f"  raw-reading residuals   : count {raw_res[0]:.2%},  "
          f"weighted {raw_res[1]:.2%}")
    print(f"  excess-reading residuals: count {exc_res[0]:.2%},  "
          f"weighted {exc_res[1]:.2%}")
    assert raw_res[1] < raw_res[0] and exc_res[1] < exc_res[0]
    assert 0.39 <= exc_res[1] and exc_res[0] <= 0.58
    print("  -> on both readings the weighted dial leaves strictly less")
    print("     unexplained; on the excess reading the residual band is")
    print("     [39%, 58%], so the earlier '>= 86% new structure' claim")
    print("     shrinks to roughly half.\n")


def main() -> None:
    demo_model_identities()
    demo_saturation_and_dilution()
    demo_window_optimum()
    demo_arithmetic_sweep()
    demo_reciprocity_audit()
    demo_twist_annihilation()
    demo_product_dial_limits()
    demo_reading_algebra()
    print("All demonstrations completed; every assertion held.")


if __name__ == "__main__":
    main()
