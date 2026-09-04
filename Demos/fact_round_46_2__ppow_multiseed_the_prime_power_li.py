"""
Numerical demonstration of the prime-power excess theory.

The prime-power excess of a positive integer n is

    E(n) = log n - log(rad n),      rad n = product of the distinct primes dividing n
         = sum_p (v_p(n) - 1) log p
         = sum_{d | n} Lambda_sharp(d),

where Lambda_sharp is the von Mangoldt function restricted to the *non-prime*
prime powers p^k (k >= 2), on which it takes the value log p.

This script verifies, numerically and self-containedly:

  1. E >= 0, and E(n) = 0 exactly for squarefree n.
  2. The Chebyshev split  E(n) = sum_{d|n} Lambda_sharp(d).
  3. The exact window law  sum_{n<=N} E(n) = sum_{d<=N} Lambda_sharp(d) * floor(N/d),
     the linear density constant  sum_p log p / (p(p-1)) ~ 0.7554,
     and the explicit floor  sum_{n<=N} E(n) >= N/4 - 2  for N >= 8.
  4. Offset (seed) uniformity of the window mass, its floor  floor(w/4) * log 2,
     and growth of the mass from w = 240 to w = 960.
  5. The fibrewise variance law  Delta R^2 = W / T  exactly, including the
     worked design {2,3,4} where Delta R^2 = 3/4, and the 2-smooth tower where
     Delta R^2 = 1 and T = m(m^2-1)/12 * (log 2)^2.
  6. The smooth floor  E(n) >= log n - y log 4  for y-smooth n.
  7. Geometric decay of the graded layers and the level-2 sandwich
     L_2(N) <= sum_{n<=N} E(n) <= 2 L_2(N).

Requires only the standard library.
"""

from __future__ import annotations

import math
from collections import defaultdict
from typing import Dict, Iterable, List, Sequence, Tuple

# --------------------------------------------------------------------------
# Basic arithmetic
# --------------------------------------------------------------------------


def smallest_prime_factor_sieve(limit: int) -> List[int]:
    """spf[n] = smallest prime factor of n, for 0 <= n <= limit."""
    spf: List[int] = list(range(limit + 1))
    i = 2
    while i * i <= limit:
        if spf[i] == i:  # i is prime
            for j in range(i * i, limit + 1, i):
                if spf[j] == j:
                    spf[j] = i
        i += 1
    return spf


def factorize(n: int, spf: Sequence[int]) -> Dict[int, int]:
    """Prime factorisation of n >= 1 as {prime: exponent}, using an spf sieve."""
    factors: Dict[int, int] = {}
    while n > 1:
        p = spf[n]
        e = 0
        while n % p == 0:
            n //= p
            e += 1
        factors[p] = e
    return factors


def radical(n: int, spf: Sequence[int]) -> int:
    """rad(n) = product of the distinct primes dividing n; rad(1) = 1."""
    r = 1
    for p in factorize(n, spf):
        r *= p
    return r


def pp_excess(n: int, spf: Sequence[int]) -> float:
    """E(n) = sum_p (v_p(n) - 1) log p."""
    return sum((e - 1) * math.log(p) for p, e in factorize(n, spf).items())


def pp_excess_via_divisor_sum(n: int, spf: Sequence[int]) -> float:
    """E(n) = sum_{d | n} Lambda_sharp(d), computed by enumerating divisors."""
    total = 0.0
    for d in range(1, n + 1):
        if n % d == 0:
            total += lambda_sharp(d, spf)
    return total


def lambda_sharp(d: int, spf: Sequence[int]) -> float:
    """von Mangoldt weight restricted to prime powers p^k with k >= 2."""
    if d < 4:
        return 0.0
    f = factorize(d, spf)
    if len(f) != 1:
        return 0.0
    (p, k), = f.items()
    return math.log(p) if k >= 2 else 0.0


def is_squarefree(n: int, spf: Sequence[int]) -> bool:
    return all(e == 1 for e in factorize(n, spf).values())


def pp_excess_table(limit: int) -> List[float]:
    """E(n) for all n <= limit, by accumulating log p over multiples of p^k, k>=2."""
    e_table = [0.0] * (limit + 1)
    sieve = [True] * (limit + 1)
    for p in range(2, limit + 1):
        if not sieve[p]:
            continue
        for m in range(p * p, limit + 1, p):
            sieve[m] = False
        pk = p * p
        while pk <= limit:
            lg = math.log(p)
            for m in range(pk, limit + 1, pk):
                e_table[m] += lg
            pk *= p
    return e_table


# --------------------------------------------------------------------------
# Window masses
# --------------------------------------------------------------------------


def window_mass(a: int, w: int, e_table: Sequence[float]) -> float:
    """M(a, w) = sum_{a <= n < a+w} E(n)."""
    return sum(e_table[n] for n in range(a, a + w))


def window_mass_exact(n_max: int) -> float:
    """sum_{n <= N} E(n) = sum_{p^k <= N, k>=2} log p * floor(N/p^k)  (exact law)."""
    total = 0.0
    for p in primes_up_to(int(math.isqrt(n_max)) + 1):
        pk = p * p
        while pk <= n_max:
            total += math.log(p) * (n_max // pk)
            pk *= p
    return total


def primes_up_to(limit: int) -> List[int]:
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(math.isqrt(limit)) + 1):
        if sieve[i]:
            for j in range(i * i, limit + 1, i):
                sieve[j] = False
    return [i for i, ok in enumerate(sieve) if ok]


def pp_density(m: int) -> float:
    """rho(M) = sum_{d <= M} Lambda_sharp(d)/d, the truncated prime-power density."""
    total = 0.0
    for p in primes_up_to(int(math.isqrt(m)) + 1):
        pk = p * p
        while pk <= m:
            total += math.log(p) / pk
            pk *= p
    return total


def pp_total(m: int) -> float:
    """Psi(M) = sum_{d <= M} Lambda_sharp(d) = psi(M) - theta(M)."""
    total = 0.0
    for p in primes_up_to(int(math.isqrt(m)) + 1):
        pk = p * p
        while pk <= m:
            total += math.log(p)
            pk *= p
    return total


def density_constant(prime_limit: int = 200000) -> float:
    """sum_p log p / (p(p-1)) = sum_{k>=2} sum_p log p / p^k."""
    return sum(math.log(p) / (p * (p - 1)) for p in primes_up_to(prime_limit))


# --------------------------------------------------------------------------
# The fibrewise variance law
# --------------------------------------------------------------------------


def total_sum_of_squares(values: Sequence[float]) -> float:
    if not values:
        return 0.0
    mean = sum(values) / len(values)
    return sum((v - mean) ** 2 for v in values)


def within_fibre_sum_of_squares(
    design: Iterable[int], base: Dict[int, int], target: Dict[int, float]
) -> float:
    """W = sum over fibres of rad, of the within-fibre sum of squares of the target."""
    fibres: Dict[int, List[float]] = defaultdict(list)
    for n in design:
        fibres[base[n]].append(target[n])
    return sum(total_sum_of_squares(v) for v in fibres.values())


def delta_r2(design: Sequence[int], spf: Sequence[int]) -> Tuple[float, float, float]:
    """Return (Delta R^2, W, T) for the radical/prime-power comparison on `design`."""
    base = {n: radical(n, spf) for n in design}
    target = {n: pp_excess(n, spf) for n in design}
    w = within_fibre_sum_of_squares(design, base, target)
    t = total_sum_of_squares([target[n] for n in design])
    return (w / t if t > 0 else 0.0), w, t


def best_base_model_residual(design: Sequence[int], spf: Sequence[int]) -> float:
    """Residual of the fibrewise-mean predictor: should equal W exactly."""
    fibres: Dict[int, List[int]] = defaultdict(list)
    for n in design:
        fibres[radical(n, spf)].append(n)
    residual = 0.0
    for members in fibres.values():
        ys = [pp_excess(n, spf) for n in members]
        mu = sum(ys) / len(ys)
        residual += sum((y - mu) ** 2 for y in ys)
    return residual


# --------------------------------------------------------------------------
# Graded layers
# --------------------------------------------------------------------------


def layer_mass(k: int, n_max: int) -> float:
    """L_k(N) = sum_{p <= N} log p * floor(N / p^k)."""
    total = 0.0
    bound = int(round(n_max ** (1.0 / k))) + 2
    for p in primes_up_to(bound):
        if p ** k <= n_max:
            total += math.log(p) * (n_max // p ** k)
    return total


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------


def demo_1_basic_structure(spf: Sequence[int]) -> None:
    print("=" * 78)
    print("1.  E(n) >= 0, vanishing exactly on squarefree n; Chebyshev split")
    print("=" * 78)
    print(f"{'n':>5} {'rad n':>7} {'E(n)':>10} {'squarefree':>11} {'divisor sum':>13}")
    for n in [1, 2, 3, 4, 6, 8, 9, 12, 16, 30, 36, 60, 72, 360, 1024]:
        e = pp_excess(n, spf)
        ds = pp_excess_via_divisor_sum(n, spf)
        print(f"{n:>5} {radical(n, spf):>7} {e:>10.6f} "
              f"{str(is_squarefree(n, spf)):>11} {ds:>13.6f}")
        assert e >= -1e-12
        assert abs(e - ds) < 1e-12
        assert (abs(e) < 1e-12) == is_squarefree(n, spf)
    print("  all checks passed: E >= 0, E = 0 iff squarefree, E = sum_{d|n} Lambda#(d)\n")

    print("  Irreducible residual at a radical collision (p, p^2):")
    print(f"  {'p':>4} {'(log p)^2/2':>13}   [lower bound on any radical-only model]")
    for p in [2, 3, 5, 7, 11, 101]:
        print(f"  {p:>4} {math.log(p) ** 2 / 2:>13.6f}")
    print()


def demo_2_window_law(spf: Sequence[int], e_table: Sequence[float]) -> None:
    print("=" * 78)
    print("2.  Exact window law and the linear density")
    print("=" * 78)
    print(f"{'N':>7} {'sum E(n)':>14} {'exact law':>14} {'/N':>9} "
          f"{'N/4 - 2':>10} {'floor ok':>9}")
    for n_max in [10, 50, 100, 500, 1000, 5000, 20000]:
        direct = sum(e_table[1:n_max + 1])
        exact = window_mass_exact(n_max)
        floor = n_max / 4 - 2
        assert abs(direct - exact) < 1e-9 * max(1.0, abs(direct))
        assert direct >= floor - 1e-9
        print(f"{n_max:>7} {direct:>14.4f} {exact:>14.4f} {direct / n_max:>9.5f} "
              f"{floor:>10.2f} {'yes':>9}")
    c = density_constant()
    print(f"\n  density constant  sum_p log p/(p(p-1)) = {c:.6f}")
    print(f"  truncated rho(20000)                    = {pp_density(20000):.6f}")
    print("  the column '/N' converges to this constant: the mass is linear in N\n")


def demo_3_seed_stability(e_table: Sequence[float]) -> None:
    print("=" * 78)
    print("3.  Seed (offset) stability and growth with window length")
    print("=" * 78)
    offsets = [1, 1000, 5000, 20000, 60000]
    for w in (240, 960):
        masses = [window_mass(a, w, e_table) for a in offsets]
        floor = (w // 4) * math.log(2)
        mean = sum(masses) / len(masses)
        sd = math.sqrt(sum((m - mean) ** 2 for m in masses) / len(masses))
        print(f"  w = {w}:  floor floor(w/4)*log2 = {floor:8.3f}")
        for a, m in zip(offsets, masses):
            print(f"      offset {a:>6}:  M = {m:10.4f}   per integer {m / w:.5f}")
            assert m >= floor - 1e-9
        print(f"      mean {mean:.4f},  sd across offsets {sd:.4f},  "
              f"sd/mean {sd / mean:.4f}")
        print()
    m240 = [window_mass(a, 240, e_table) for a in offsets]
    m960 = [window_mass(a, 960, e_table) for a in offsets]
    print("  growth 240 -> 960 (theory: at least 180*log 2 = "
          f"{180 * math.log(2):.3f} extra):")
    for a, s, l in zip(offsets, m240, m960):
        print(f"      offset {a:>6}:  {s:9.3f} -> {l:9.3f}   gain {l - s:9.3f}")
        assert l - s >= 180 * math.log(2) - 1e-9
    max_off = max(offsets) - 1 + 960
    print(f"\n  offset-free error bound Psi(M) at M = {max_off}: "
          f"{pp_total(max_off):.3f}")
    print("  (dispersion across offsets is bounded by 2*Psi(M), independent of w)\n")


def demo_4_fibrewise_law(spf: Sequence[int]) -> None:
    print("=" * 78)
    print("4.  The fibrewise variance law:  Delta R^2 = W / T  exactly")
    print("=" * 78)

    design = [2, 3, 4]
    dr2, w, t = delta_r2(design, spf)
    lg2 = math.log(2)
    print("  Design {2, 3, 4}:")
    print(f"      W = {w:.8f}   (theory (log2)^2/2   = {lg2 ** 2 / 2:.8f})")
    print(f"      T = {t:.8f}   (theory (2/3)(log2)^2 = {2 / 3 * lg2 ** 2:.8f})")
    print(f"      Delta R^2 = {dr2:.8f}   (theory 3/4 = 0.75)")
    assert abs(w - lg2 ** 2 / 2) < 1e-12
    assert abs(t - 2 / 3 * lg2 ** 2) < 1e-12
    assert abs(dr2 - 0.75) < 1e-12

    print("\n  Collision-free design (distinct squarefree radicals): Delta R^2 = 0")
    sqfree = [2, 3, 5, 6, 7, 10, 15, 30]
    dr2_0, w0, t0 = delta_r2(sqfree, spf)
    print(f"      W = {w0:.8f},  T = {t0:.8f},  Delta R^2 = {dr2_0:.8f}")

    print("\n  2-smooth tower {2, 4, ..., 2^m}: one fibre, Delta R^2 = 1")
    print(f"  {'m':>4} {'T (measured)':>15} {'m(m^2-1)/12*(log2)^2':>23} {'DR2':>7}")
    for m in [2, 3, 5, 8, 12]:
        tower = [2 ** k for k in range(1, m + 1)]
        dr2_t, _, t_t = delta_r2(tower, spf)
        theory = m * (m * m - 1) / 12 * lg2 ** 2
        print(f"  {m:>4} {t_t:>15.8f} {theory:>23.8f} {dr2_t:>7.4f}")
        assert abs(t_t - theory) < 1e-9
        assert abs(dr2_t - 1.0) < 1e-12

    print("\n  Consecutive-integer windows: the lift is the collision density")
    print(f"  {'window':>18} {'#collisions':>12} {'W':>10} {'T':>10} {'Delta R^2':>11}")
    for a, w_len in [(2, 60), (2, 240), (1000, 240), (5000, 240), (2, 960)]:
        d = list(range(a, a + w_len))
        dr2_w, w_w, t_w = delta_r2(d, spf)
        fibres: Dict[int, List[int]] = defaultdict(list)
        for n in d:
            fibres[radical(n, spf)].append(n)
        ncol = sum(1 for v in fibres.values() if len(v) > 1)
        print(f"  [{a:>6},{a + w_len:>7}) {ncol:>12} {w_w:>10.4f} {t_w:>10.4f} "
              f"{dr2_w:>11.6f}")

    print("\n  attainment check: residual of the fibrewise-mean model equals W")
    d = list(range(2, 500))
    _, w_d, _ = delta_r2(d, spf)
    res = best_base_model_residual(d, spf)
    print(f"      W = {w_d:.8f},  fibrewise-mean residual = {res:.8f}")
    assert abs(w_d - res) < 1e-9
    print()


def demo_5_smooth_floor(spf: Sequence[int]) -> None:
    print("=" * 78)
    print("5.  The smooth-pool floor  E(n) >= log n - y log 4")
    print("=" * 78)
    print(f"  {'y':>3} {'4^y':>12} {'n':>12} {'log n':>9} {'floor':>10} {'E(n)':>10}")
    for y, n in [(2, 2 ** 14), (2, 3 ** 0 * 2 ** 20), (3, 2 ** 6 * 3 ** 6),
                 (5, 2 ** 5 * 3 ** 4 * 5 ** 3), (7, 2 ** 4 * 3 ** 4 * 5 ** 2 * 7 ** 2)]:
        floor = math.log(n) - y * math.log(4)
        e = pp_excess(n, spf) if n < len(spf) else _pp_excess_big(n)
        print(f"  {y:>3} {4 ** y:>12} {n:>12} {math.log(n):>9.4f} "
              f"{floor:>10.4f} {e:>10.4f}")
        assert e >= floor - 1e-9
    print("  every y-smooth n > 4^y therefore has E(n) > 0: it is NOT squarefree\n")


def smooth_pool(y: int, x_max: int, spf: Sequence[int]) -> List[int]:
    """All y-smooth integers 2 <= n <= x_max."""
    return [n for n in range(2, x_max + 1) if max(factorize(n, spf)) <= y]


def demo_5b_smooth_pools(spf: Sequence[int]) -> None:
    print("=" * 78)
    print("5b. Smooth pools are collision-rich: Delta R^2 grows as the pool gets")
    print("    smoother, because every radical divides the primorial y#")
    print("=" * 78)
    x_max = min(100000, len(spf) - 1)
    print(f"  pool = all y-smooth n <= {x_max}")
    print(f"  {'y':>4} {'|pool|':>8} {'#radicals':>10} {'2^pi(y)':>9} "
          f"{'W':>12} {'T':>12} {'Delta R^2':>11}")
    for y in (7, 13, 31, 97):
        pool = smooth_pool(y, x_max, spf)
        dr2, w, t = delta_r2(pool, spf)
        nrad = len({radical(n, spf) for n in pool})
        cap = 2 ** len(primes_up_to(y))
        print(f"  {y:>4} {len(pool):>8} {nrad:>10} {cap:>9} "
              f"{w:>12.2f} {t:>12.2f} {dr2:>11.4f}")
        assert nrad <= cap
    print("  the number of available radicals is capped by 2^pi(y): pigeonhole")
    print("  forces collisions, and the lift rises as y (the smoothness) falls\n")


def _pp_excess_big(n: int) -> float:
    """E(n) by trial division, for values beyond the sieve limit."""
    m, total = n, 0.0
    p = 2
    while p * p <= m:
        if m % p == 0:
            e = 0
            while m % p == 0:
                m //= p
                e += 1
            total += (e - 1) * math.log(p)
        p += 1
    return total


def demo_6_layers(e_table: Sequence[float]) -> None:
    print("=" * 78)
    print("6.  Graded layers: geometric decay and the level-2 sandwich")
    print("=" * 78)
    for n_max in (1000, 20000):
        total = sum(e_table[1:n_max + 1]) if n_max < len(e_table) else window_mass_exact(n_max)
        print(f"  N = {n_max}:   total prime-power mass = {total:.4f}")
        print(f"    {'k':>3} {'L_k(N)':>12} {'ratio to L_{k-1}':>18}")
        prev = None
        acc = 0.0
        k = 2
        while True:
            lk = layer_mass(k, n_max)
            if lk == 0.0:
                break
            ratio = "" if prev is None else f"{lk / prev:.4f}"
            print(f"    {k:>3} {lk:>12.4f} {ratio:>18}")
            assert prev is None or lk <= prev / 2 + 1e-9
            acc += lk
            prev = lk
            k += 1
        l2 = layer_mass(2, n_max)
        print(f"    sum of layers = {acc:.4f}   (equals the total mass)")
        print(f"    sandwich:  L_2 = {l2:.4f} <= {total:.4f} <= 2*L_2 = {2 * l2:.4f}")
        assert l2 <= total + 1e-6 <= 2 * l2 + 1e-6
        print()


def main() -> None:
    limit = 100000
    print("Prime-power excess: numerical demonstration")
    print(f"(sieving up to {limit})\n")
    spf = smallest_prime_factor_sieve(limit)
    e_table = pp_excess_table(limit)

    demo_1_basic_structure(spf)
    demo_2_window_law(spf, e_table)
    demo_3_seed_stability(e_table)
    demo_4_fibrewise_law(spf)
    demo_5_smooth_floor(spf)
    demo_5b_smooth_pools(spf)
    demo_6_layers(e_table)

    print("=" * 78)
    print("All assertions passed.")
    print("=" * 78)


if __name__ == "__main__":
    main()
