"""
demo.py — Numerical demonstrations for the quadratic-residue footprint dial.

Self-contained (standard library only). Every function is inlined and type-hinted.

The script verifies, by direct computation, the exact results of the accompanying
paper:

  1. The 2/1/0 local dichotomy for the number of roots of x^2 = N (mod p).
  2. The mean-footprint identity: the average number of factor-base primes dividing
     x^2 - N over a full period of sieve locations is exactly the dial
     W(N) = sum over QR primes p of 2/p.
  3. Hensel lifting: the root count mod p^k equals the root count mod p (odd p, p not
     dividing N), so the local density is exactly 2/p^k; and the mod-8 obstruction at
     the even prime.
  4. The exact joint law of the QR pattern over a period of moduli, with the counts
     prod_{p in T} (p+1)/2 * prod_{p not in T} (p-1)/2.
  5. The exact mean sum (p+1)/p^2 and exact variance sum (p^2-1)/p^4 of the dial, and
     the uniform bound Var < 1/2.
  6. Exact information capacity: the dial takes exactly 2^{|base|} distinct values.
  7. Blindness: dial values are shared by primes and by semiprimes in the same residue
     class modulo the primorial of the factor base.
  8. The exact one-feature R^2 lift, DeltaR2 = <r,v>^2 / (||v||^2 * TSS)
     = rho^2 * (1 - R^2_before), and the recovery of |rho| ~ 0.539 from the reported
     lift 0.3927 -> 0.5691.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import isqrt, sqrt
from typing import Dict, Iterable, List, Sequence, Set, Tuple

# --------------------------------------------------------------------------------------
# Basic arithmetic helpers
# --------------------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """All primes p <= n, by a simple sieve of Eratosthenes."""
    if n < 2:
        return []
    flags: List[bool] = [True] * (n + 1)
    flags[0] = flags[1] = False
    for i in range(2, isqrt(n) + 1):
        if flags[i]:
            for j in range(i * i, n + 1, i):
                flags[j] = False
    return [i for i in range(n + 1) if flags[i]]


def odd_factor_base(bound: int) -> List[int]:
    """The odd part of the quadratic-sieve factor base: odd primes p <= bound."""
    return [p for p in primes_up_to(bound) if p != 2]


def base_primorial(bound: int) -> int:
    """D(B) = product of the odd factor base."""
    result = 1
    for p in odd_factor_base(bound):
        result *= p
    return result


def hit_count(n: int, m: int) -> int:
    """h(N, m) = #{x in [0, m) : m divides x^2 - N}: sieve hits of modulus m per period."""
    return sum(1 for x in range(m) if (x * x - n) % m == 0)


def is_qr(n: int, p: int) -> bool:
    """True iff N is a square modulo p (the convention includes the case p | N)."""
    return any((x * x - n) % p == 0 for x in range(p))


def is_qr_euler(n: int, p: int) -> bool:
    """Euler's criterion (fast): N is a square mod the odd prime p."""
    r = n % p
    if r == 0:
        return True
    return pow(r, (p - 1) // 2, p) == 1


def qr_pattern(n: int, bound: int) -> Set[int]:
    """The set of factor-base primes modulo which N is a quadratic residue."""
    return {p for p in odd_factor_base(bound) if is_qr_euler(n, p)}


def qr_weight(n: int, bound: int) -> Fraction:
    """The footprint dial W(N, B) = sum over QR primes p <= B of 2/p, computed exactly."""
    total = Fraction(0)
    for p in odd_factor_base(bound):
        if is_qr_euler(n, p):
            total += Fraction(2, p)
    return total


def footprint_weight(n: int, bound: int) -> Fraction:
    """The raw footprint weight F(N, B) = sum over p <= B of h(N,p)/p."""
    return sum((Fraction(hit_count(n, p), p) for p in odd_factor_base(bound)), Fraction(0))


# --------------------------------------------------------------------------------------
# 1. The local dichotomy
# --------------------------------------------------------------------------------------


def demo_dichotomy(bound: int = 30, moduli: Iterable[int] = range(1, 40)) -> None:
    print("=" * 78)
    print("1. The 2/1/0 dichotomy:  h(N,p) = 2 if N is a nonzero QR, 1 if p | N, else 0")
    print("=" * 78)
    ok = True
    for p in odd_factor_base(bound):
        for n in moduli:
            h = hit_count(n, p)
            if n % p == 0:
                expected = 1
            elif is_qr_euler(n, p):
                expected = 2
            else:
                expected = 0
            ok &= h == expected
    print(f"   checked all odd primes p <= {bound} and N in {list(moduli)[0]}..{list(moduli)[-1]}")
    print(f"   dichotomy holds everywhere: {ok}")
    print()
    print("   sample (N = 1009):")
    for p in odd_factor_base(20):
        print(
            f"     p = {p:2d}   QR: {str(is_qr_euler(1009, p)):5s}   "
            f"h(N,p) = {hit_count(1009, p)}   local density = {Fraction(hit_count(1009,p), p)}"
        )
    print()


# --------------------------------------------------------------------------------------
# 2. The mean-footprint identity
# --------------------------------------------------------------------------------------


def mean_footprint_over_period(n: int, bound: int) -> Fraction:
    """Average, over a full period of sieve locations, of #{p in base : p | x^2 - N}."""
    base = odd_factor_base(bound)
    period = base_primorial(bound)
    total = 0
    for x in range(period):
        v = x * x - n
        total += sum(1 for p in base if v % p == 0)
    return Fraction(total, period)


def demo_mean_footprint(bound: int = 11) -> None:
    print("=" * 78)
    print("2. Mean-footprint identity:  (1/D) sum_x #{p : p | x^2 - N}  =  W(N,B)  exactly")
    print("=" * 78)
    base = odd_factor_base(bound)
    period = base_primorial(bound)
    print(f"   factor base {base}, period D = {period}")
    for n in (1009, 2027, 4001, 7919):
        if any(n % p == 0 for p in base):
            continue
        lhs = mean_footprint_over_period(n, bound)
        rhs = qr_weight(n, bound)
        raw = footprint_weight(n, bound)
        print(
            f"   N = {n:5d}:  mean footprint = {lhs}  =  W(N) = {rhs}  "
            f"(raw F = {raw})   match: {lhs == rhs == raw}"
        )
    print()


# --------------------------------------------------------------------------------------
# 3. Hensel lifting and the even prime
# --------------------------------------------------------------------------------------


def demo_hensel(bound: int = 20, exponents: int = 4) -> None:
    print("=" * 78)
    print("3. Hensel lifting:  h(N, p^k) = h(N, p) for odd p, p not dividing N, k >= 1")
    print("=" * 78)
    n = 1009
    for p in odd_factor_base(bound):
        if n % p == 0:
            continue
        counts = [hit_count(n, p ** k) for k in range(1, exponents + 1)]
        densities = [Fraction(hit_count(n, p ** k), p ** k) for k in range(1, exponents + 1)]
        stable = all(c == counts[0] for c in counts)
        print(
            f"   p = {p:2d}  QR: {str(is_qr_euler(n,p)):5s}  counts {counts}  "
            f"densities {[str(d) for d in densities]}  stable: {stable}"
        )
    print()
    print("   mod-8 obstruction at the even prime (N odd, N != 1 mod 8 => h(N,2^k)=0, k>=3):")
    for n in (3, 5, 7, 9, 17, 25, 41):
        row = [hit_count(n, 2 ** k) for k in range(1, 7)]
        print(f"     N = {n:3d}  (N mod 8 = {n % 8})   h(N,2^k), k=1..6:  {row}")
    print()


# --------------------------------------------------------------------------------------
# 4. The exact joint law over a period of moduli
# --------------------------------------------------------------------------------------


def predicted_pattern_count(base: Sequence[int], pattern: Set[int]) -> int:
    """prod_{p in T} (p+1)/2 * prod_{p not in T} (p-1)/2."""
    total = 1
    for p in base:
        total *= (p + 1) // 2 if p in pattern else (p - 1) // 2
    return total


def demo_joint_law(bound: int = 11) -> None:
    print("=" * 78)
    print("4. Exact joint law of the QR pattern over one period of moduli")
    print("=" * 78)
    base = odd_factor_base(bound)
    period = base_primorial(bound)
    observed: Dict[frozenset, int] = {}
    for n in range(period):
        key = frozenset(qr_pattern(n, bound))
        observed[key] = observed.get(key, 0) + 1
    print(f"   base {base}, period D = {period}, patterns = 2^{len(base)} = {2**len(base)}")
    all_match = True
    shown = 0
    for r in range(len(base) + 1):
        for combo in combinations(base, r):
            t = set(combo)
            pred = predicted_pattern_count(base, t)
            obs = observed.get(frozenset(t), 0)
            all_match &= pred == obs
            if shown < 8:
                print(f"     T = {sorted(t)!s:16s} predicted {pred:5d}   observed {obs:5d}")
                shown += 1
    print(f"   ... all {2**len(base)} patterns match exactly: {all_match}")
    print(f"   every pattern occurs at least once: {all(observed.get(frozenset(set(c)),0) > 0 for r in range(len(base)+1) for c in combinations(base, r))}")
    print()


# --------------------------------------------------------------------------------------
# 5. Exact mean and variance
# --------------------------------------------------------------------------------------


def dial_mean_exact(bound: int) -> Fraction:
    """sum over odd primes p <= B of (p+1)/p^2."""
    return sum((Fraction(p + 1, p * p) for p in odd_factor_base(bound)), Fraction(0))


def dial_variance_exact(bound: int) -> Fraction:
    """sum over odd primes p <= B of (p^2-1)/p^4."""
    return sum((Fraction(p * p - 1, p ** 4) for p in odd_factor_base(bound)), Fraction(0))


def random_footprint(bound: int) -> Fraction:
    """The random-integer footprint sum 1/p, which is the mean of the raw dial F."""
    return sum((Fraction(1, p) for p in odd_factor_base(bound)), Fraction(0))


def demo_moments(bound: int = 11) -> None:
    print("=" * 78)
    print("5. Exact mean and variance of the dial over one period of moduli")
    print("=" * 78)
    base = odd_factor_base(bound)
    period = base_primorial(bound)
    dials = [qr_weight(n, bound) for n in range(period)]
    emp_mean = sum(dials, Fraction(0)) / period
    emp_var = sum(((d - emp_mean) ** 2 for d in dials), Fraction(0)) / period
    raw = [footprint_weight(n, bound) for n in range(period)]
    emp_raw_mean = sum(raw, Fraction(0)) / period

    print(f"   base {base}, period D = {period}")
    print(f"   empirical mean of W  = {emp_mean}   predicted sum (p+1)/p^2 = {dial_mean_exact(bound)}"
          f"   match: {emp_mean == dial_mean_exact(bound)}")
    print(f"   empirical mean of F  = {emp_raw_mean}   predicted sum 1/p      = {random_footprint(bound)}"
          f"   match: {emp_raw_mean == random_footprint(bound)}")
    print(f"   empirical variance   = {emp_var}   predicted sum (p^2-1)/p^4 = {dial_variance_exact(bound)}"
          f"   match: {emp_var == dial_variance_exact(bound)}")
    print()
    print("   growth of mean (diverges) vs variance (converges, always < 1/2):")
    for b in (13, 50, 100, 400, 2000, 10000):
        m = float(dial_mean_exact(b))
        v = float(dial_variance_exact(b))
        print(f"     B = {b:6d}   |base| = {len(odd_factor_base(b)):5d}   mean = {m:8.5f}   "
              f"var = {v:8.5f}   sd = {sqrt(v):7.5f}   var < 1/2: {v < 0.5}")
    print()


# --------------------------------------------------------------------------------------
# 6. Exact information capacity
# --------------------------------------------------------------------------------------


def demo_capacity(bound: int = 13) -> None:
    print("=" * 78)
    print("6. Exact capacity: the dial attains exactly 2^{|base|} distinct values")
    print("=" * 78)
    base = odd_factor_base(bound)
    period = base_primorial(bound)
    values = {qr_weight(n, bound) for n in range(period)}
    subset_sums = set()
    for r in range(len(base) + 1):
        for combo in combinations(base, r):
            subset_sums.add(sum((Fraction(2, p) for p in combo), Fraction(0)))
    print(f"   base {base}, |base| = {len(base)}")
    print(f"   distinct dial values realised in one period: {len(values)}")
    print(f"   distinct subset sums:                        {len(subset_sums)}")
    print(f"   2^|base| =                                   {2**len(base)}")
    print(f"   all three agree (full range + injectivity):  "
          f"{len(values) == len(subset_sums) == 2**len(base)}")
    print(f"   information content: exactly {len(base)} bits about N")
    print()


# --------------------------------------------------------------------------------------
# 7. Blindness: same dial value for primes and semiprimes
# --------------------------------------------------------------------------------------


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d, s = n - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = x * x % n
            if x == n - 1:
                break
        else:
            return False
    return True


def demo_blindness(bound: int = 13, target: int = 1009) -> None:
    print("=" * 78)
    print("7. Blindness: every dial value is shared by large primes and large semiprimes")
    print("=" * 78)
    d = base_primorial(bound)
    w = qr_weight(target, bound)
    print(f"   base {odd_factor_base(bound)}, primorial D = {d}")
    print(f"   target N = {target}, dial value W(N) = {w} = {float(w):.6f}")

    # a large prime in the class N mod D
    q = target + d
    while not (is_prime(q) and q > 10 ** 6):
        q += d
    # a large semiprime in the class N mod D:  r = 1 mod D, s = N r^{-1} mod D
    r = 1 + d
    while not (is_prime(r) and r > 10 ** 3):
        r += d
    r_inv = pow(r % d, -1, d)
    s0 = (target * r_inv) % d
    s = s0 + d
    while not (is_prime(s) and s > 10 ** 4 and s != r):
        s += d
    print(f"   prime      q  = {q}                     W(q)  = {qr_weight(q, bound)}   "
          f"equal: {qr_weight(q, bound) == w}")
    print(f"   semiprime  rs = {r} * {s} = {r*s}      W(rs) = {qr_weight(r*s, bound)}   "
          f"equal: {qr_weight(r*s, bound) == w}")
    print("   => no classifier of the dial value can tell a prime from a semiprime.")
    print()


# --------------------------------------------------------------------------------------
# 8. The exact R^2 lift
# --------------------------------------------------------------------------------------


def dot(u: Sequence[float], v: Sequence[float]) -> float:
    return sum(a * b for a, b in zip(u, v))


def sq_norm(u: Sequence[float]) -> float:
    return dot(u, u)


def tss(y: Sequence[float]) -> float:
    m = sum(y) / len(y)
    return sum((a - m) ** 2 for a in y)


def best_line_fit(residual: Sequence[float], feature: Sequence[float]) -> Tuple[float, float]:
    """Optimal step t* = <r,v>/||v||^2 and the resulting residual sum of squares."""
    t = dot(residual, feature) / sq_norm(feature)
    rss = sum((r - t * v) ** 2 for r, v in zip(residual, feature))
    return t, rss


def demo_lift(bound: int = 100, sample_size: int = 400, seed: int = 20260829) -> None:
    print("=" * 78)
    print("8. Exact one-feature R^2 lift:  DeltaR2 = <r,v>^2 / (||v||^2 TSS) = rho^2 (1-R2)")
    print("=" * 78)

    # deterministic pseudo-random sample of odd moduli, and a synthetic yield with a
    # genuine footprint component plus reproducible pseudo-noise
    state = seed
    def nxt() -> int:
        nonlocal state
        state = (1103515245 * state + 12345) % (2 ** 31)
        return state

    moduli = []
    while len(moduli) < sample_size:
        n = 10 ** 6 + 2 * (nxt() % 10 ** 6) + 1
        if all(n % p != 0 for p in odd_factor_base(bound)):
            moduli.append(n)

    feature = [float(qr_weight(n, bound)) for n in moduli]
    size_term = [((n % 1000) / 1000.0) for n in moduli]
    noise = [((nxt() % 2000) / 1000.0 - 1.0) * 0.25 for _ in moduli]
    y = [1.0 + 0.8 * s + 0.9 * f + e for s, f, e in zip(size_term, feature, noise)]

    # baseline: least-squares fit on the size term alone (with intercept)
    ones = [1.0] * len(y)
    # two-parameter normal equations
    s11, s12, s22 = sq_norm(ones), dot(ones, size_term), sq_norm(size_term)
    b1, b2 = dot(ones, y), dot(size_term, y)
    det = s11 * s22 - s12 * s12
    a0 = (b1 * s22 - b2 * s12) / det
    a1 = (s11 * b2 - s12 * b1) / det
    g = [a0 + a1 * s for s in size_term]

    residual = [yy - gg for yy, gg in zip(y, g)]
    total = tss(y)
    r2_before = 1.0 - sq_norm(residual) / total
    _, rss_after = best_line_fit(residual, feature)
    r2_after = 1.0 - rss_after / total

    predicted_lift = dot(residual, feature) ** 2 / (sq_norm(feature) * total)
    rho = dot(residual, feature) / sqrt(sq_norm(residual) * sq_norm(feature))

    print(f"   sample of {sample_size} moduli, factor base bound B = {bound}")
    print(f"   R^2 before            = {r2_before:.6f}")
    print(f"   R^2 after (+ dial)    = {r2_after:.6f}")
    print(f"   observed lift         = {r2_after - r2_before:.9f}")
    print(f"   predicted <r,v>^2/(|v|^2 TSS) = {predicted_lift:.9f}")
    print(f"   rho^2 (1 - R^2_before)        = {rho**2 * (1 - r2_before):.9f}")
    print(f"   residual-feature correlation rho = {rho:.6f}")
    print(f"   ceiling 1 - R^2_before = {1 - r2_before:.6f}  "
          f"(lift respects the ceiling: {r2_after - r2_before <= 1 - r2_before + 1e-12})")
    print()

    print("   Reading the reported experiment through the same identity:")
    for label, before, after in (
        ("u = 2.5", 0.3927, 0.5691),
        ("u = 3.5", 0.2063, 0.3078),
        ("u = 2.5, both features", 0.3927, 0.5864),
    ):
        lift = after - before
        rho2 = lift / (1.0 - before)
        print(f"     {label:24s} R2 {before:.4f} -> {after:.4f}   lift {lift:.4f}   "
              f"ceiling {1-before:.4f}   |rho| = {sqrt(rho2):.4f}")
    print()


# --------------------------------------------------------------------------------------


def main() -> None:
    print()
    print("THE QUADRATIC-RESIDUE FOOTPRINT DIAL — numerical demonstrations")
    print()
    demo_dichotomy()
    demo_mean_footprint()
    demo_hensel()
    demo_joint_law()
    demo_moments()
    demo_capacity()
    demo_blindness()
    demo_lift()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
