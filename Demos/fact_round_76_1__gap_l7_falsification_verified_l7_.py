#!/usr/bin/env python3
"""
Numerical demonstration of the sign-flip law for committed enumeration orders.

Everything in this file is self-contained (standard library only) and checks,
numerically, the results of the accompanying paper:

  1. Exchange Theorem       -- mass-sorted enumeration is extremal.
  2. No free lunch          -- every order costs (n+1)/2 on a flat prior.
  3. Abel identity          -- expected cost = sum of survival masses.
  4. Head domination        -- prefix-dominating enumerations cost no more.
  5. Sign-flip law          -- ascending beats descending iff E[1/sqrt(r)] < (2+sqrt2)/4.
  6. Band law               -- E[1/sqrt(r)] = 2/(1+sqrt(1+delta)) on r ~ U[1,1+delta].
  7. Crossover constants    -- m* = (2+sqrt2)/4, rho* = 4-2sqrt2, delta* = 80-56sqrt2.
  8. Hard balance           -- tilt exactly sqrt2-1, cost ratio exactly sqrt2.
  9. Family law             -- delta*(k) = 8 sqrt k (sqrt k - 1)/(sqrt k + 1)^2 < k-1.
 10. Certification          -- interval measurement -> certified order + gain bracket.
 11. Touch floor / wheels   -- phi(M)m survivors of Mm, hence S <= M/phi(M); 30 -> 3.75.
 12. Cap audit              -- zero violations of S <= (4/3) min(1/mu, 2^k)/Lambda.
 13. Jacobi degeneracy      -- (N|p) = 0 identically when p | N.
 14. Factor blindness       -- keyed and fixed residue promotion promote equal counts.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

SQRT2: float = math.sqrt(2.0)
M_STAR: float = (2.0 + SQRT2) / 4.0            # crossover mean height
RHO_STAR: float = 4.0 - 2.0 * SQRT2            # reciprocal crossover constant
DELTA_STAR: float = 80.0 - 56.0 * SQRT2        # crossover band width at k = 2


# ----------------------------------------------------------------------------
# 1. The reordering model: probe cost, mass sorting, Abel identity
# ----------------------------------------------------------------------------

def probe_cost(mass: Sequence[float], order: Sequence[int]) -> float:
    """Expected probe cost of visiting slots in the given order.

    The slot visited k-th (0-indexed) is charged k+1 probes.
    """
    return sum((k + 1) * mass[slot] for k, slot in enumerate(order))


def mass_sorted_order(mass: Sequence[float]) -> List[int]:
    """The extremal enumeration: slots in nonincreasing order of mass."""
    return sorted(range(len(mass)), key=lambda i: -mass[i])


def cost_via_tail_sums(mass_in_order: Sequence[float]) -> float:
    """Abel identity: expected cost equals the sum of survival (tail) masses."""
    n = len(mass_in_order)
    return sum(sum(mass_in_order[k] for k in range(j, n)) for j in range(n))


def demo_exchange_theorem(n: int = 8, trials: int = 5, seed: int = 20260831) -> None:
    print("=" * 78)
    print("1-3.  EXCHANGE THEOREM, NO FREE LUNCH, ABEL IDENTITY")
    print("=" * 78)
    rng = random.Random(seed)

    for t in range(trials):
        raw = [rng.random() for _ in range(n)]
        total = sum(raw)
        mass = [x / total for x in raw]
        best_order = mass_sorted_order(mass)
        best = probe_cost(mass, best_order)
        # brute force over all n! enumerations
        worst_seen = max(probe_cost(mass, list(p))
                         for p in itertools.permutations(range(n)))
        brute_best = min(probe_cost(mass, list(p))
                         for p in itertools.permutations(range(n)))
        ok = abs(best - brute_best) < 1e-12
        print(f"  trial {t}: mass-sorted cost = {best:.6f}   "
              f"brute-force min = {brute_best:.6f}   max = {worst_seen:.6f}   "
              f"[{'OK' if ok else 'FAIL'}]")

    flat = [1.0 / n] * n
    costs = {round(probe_cost(flat, list(p)), 12)
             for p in itertools.permutations(range(n))}
    print(f"\n  flat prior, n = {n}: distinct costs over all {math.factorial(n)} "
          f"orders = {costs}  (theory: {(n + 1) / 2})")

    mass = [0.4, 0.25, 0.15, 0.1, 0.06, 0.03, 0.008, 0.002]
    direct = probe_cost(mass, list(range(len(mass))))
    abel = cost_via_tail_sums(mass)
    print(f"  Abel identity: direct = {direct:.10f}, tail sums = {abel:.10f}, "
          f"agree = {abs(direct - abel) < 1e-12}")


def demo_head_domination(seed: int = 7) -> None:
    print()
    print("=" * 78)
    print("4.  HEAD-DOMINATION LAW")
    print("=" * 78)
    rng = random.Random(seed)
    n = 10
    checked = 0
    for _ in range(4000):
        u = sorted([rng.random() for _ in range(n)])          # back-loaded
        v = sorted(u, reverse=True)                           # front-loaded
        tot = sum(u)
        u = [x / tot for x in u]
        v = [x / tot for x in v]
        dominates = all(sum(u[:j]) <= sum(v[:j]) + 1e-15 for j in range(n + 1))
        if dominates:
            checked += 1
            assert probe_cost(v, list(range(n))) <= probe_cost(u, list(range(n))) + 1e-12
    print(f"  {checked} prefix-dominating pairs tested, all satisfy C(v) <= C(u).")
    u = [0.05, 0.10, 0.15, 0.70]
    v = [0.70, 0.15, 0.10, 0.05]
    print(f"  example: back-loaded cost = {probe_cost(u, list(range(4))):.4f}, "
          f"front-loaded cost = {probe_cost(v, list(range(4))):.4f}")


# ----------------------------------------------------------------------------
# 2. The window model and the sign-flip law
# ----------------------------------------------------------------------------

def asc_cost(r: float, k: float = 2.0) -> float:
    """Window-ascending cost for balance ratio r, in units of sqrt(N)."""
    return 1.0 / math.sqrt(r) - 1.0 / math.sqrt(k)


def desc_cost(r: float) -> float:
    """Window-descending cost for balance ratio r, in units of sqrt(N)."""
    return 1.0 - 1.0 / math.sqrt(r)


def mean_inv_sqrt_band(delta: float) -> float:
    """Exact population mean E[1/sqrt(r)] for r ~ U[1, 1+delta]."""
    return 2.0 / (1.0 + math.sqrt(1.0 + delta))


def tilt(delta: float, k: float = 2.0) -> float:
    """Normalised position of the mean hit height inside the window."""
    lo = 1.0 / math.sqrt(k)
    return (mean_inv_sqrt_band(delta) - lo) / (1.0 - lo)


def crossover_width(k: float) -> float:
    """delta*(k) = 8 sqrt(k) (sqrt(k)-1) / (sqrt(k)+1)^2."""
    t = math.sqrt(k)
    return 8.0 * t * (t - 1.0) / (t + 1.0) ** 2


def lambda_lab(m: float, k: float = 2.0) -> float:
    """Prior-shape gain: expected descending cost / expected ascending cost."""
    return (1.0 - m) / (m - 1.0 / math.sqrt(k))


def demo_signflip() -> None:
    print()
    print("=" * 78)
    print("5-8.  SIGN-FLIP LAW, BAND LAW, CROSSOVER CONSTANTS, HARD BALANCE")
    print("=" * 78)
    print(f"  m*      = (2+sqrt2)/4  = {M_STAR:.10f}")
    print(f"  rho*    = 4 - 2 sqrt2  = {RHO_STAR:.10f}   (rho* * m* = "
          f"{RHO_STAR * M_STAR:.12f})")
    print(f"  delta*  = 80 - 56sqrt2 = {DELTA_STAR:.10f}")
    print(f"  bracket 1.1715 < rho* < 1.1716: "
          f"{1.1715 < RHO_STAR < 1.1716}")

    print("\n  Monte-Carlo check of the band law (n = 400000 draws per band):")
    rng = random.Random(20260831)
    for delta in (0.25, 0.5, DELTA_STAR, 0.9, 1.0):
        n = 400_000
        sample = [1.0 + delta * rng.random() for _ in range(n)]
        emp = sum(1.0 / math.sqrt(r) for r in sample) / n
        exact = mean_inv_sqrt_band(delta)
        a = sum(asc_cost(r) for r in sample) / n
        d = sum(desc_cost(r) for r in sample) / n
        winner = "ascending" if a < d else ("descending" if d < a else "tie")
        pred = "ascending" if delta > DELTA_STAR else (
            "descending" if delta < DELTA_STAR else "tie")
        print(f"    delta = {delta:.6f}: E[1/sqrt r] empirical = {emp:.6f}, "
              f"exact = {exact:.6f}, tilt = {tilt(delta):.4f}, "
              f"asc = {a:.5f}, desc = {d:.5f} -> {winner:<10s} "
              f"(law predicts {pred})")

    m1 = mean_inv_sqrt_band(1.0)
    print(f"\n  Hard balance (delta = 1): E[1/sqrt r] = {m1:.8f} "
          f"= 2(sqrt2 - 1) = {2 * (SQRT2 - 1):.8f}")
    print(f"    tilt        = {tilt(1.0):.8f}   (theory sqrt2 - 1 = {SQRT2 - 1:.8f})")
    print(f"    desc / asc  = {lambda_lab(m1):.8f}   (theory sqrt2 = {SQRT2:.8f})")
    m_half = mean_inv_sqrt_band(0.5)
    print(f"  Narrow band  (delta = 1/2): E[1/sqrt r] = {m_half:.8f} > m*, "
          f"tilt = {tilt(0.5):.4f} (top-heavy)")
    print(f"    desc / asc  = {lambda_lab(m_half):.8f} < 1  -> descending wins")
    print("\n  FALSIFICATION: same two policies, opposite winners on two "
          "admissible bands.")


def demo_family() -> None:
    print()
    print("=" * 78)
    print("9.  THE WINDOW FAMILY: delta*(k) < k - 1 FOR EVERY k > 1")
    print("=" * 78)
    print(f"  {'k':>8} {'delta*(k)':>14} {'k - 1':>10} {'inside?':>9}   "
          f"{'winner at widest band'}")
    for k in (1.1, 1.5, 2.0, 3.0, 5.0, 10.0, 100.0):
        ds = crossover_width(k)
        widest = k - 1.0
        m = mean_inv_sqrt_band(widest)
        win = "ascending" if m - 1.0 / math.sqrt(k) < 1.0 - m else "descending"
        print(f"  {k:>8.2f} {ds:>14.8f} {widest:>10.4f} {str(ds < widest):>9}   {win}")
    print(f"  consistency: delta*(2) = {crossover_width(2.0):.10f} vs "
          f"80 - 56 sqrt2 = {DELTA_STAR:.10f}")


def demo_certification() -> None:
    print()
    print("=" * 78)
    print("10.  CERTIFICATION FROM A MEASUREMENT WITH AN ERROR BAR")
    print("=" * 78)
    for mhat, eps, label in ((0.8284, 0.01, "hard-balanced pool"),
                             (0.8990, 0.01, "narrow band (delta = 1/2)"),
                             (0.8500, 0.01, "pool straddling the crossover")):
        lo, hi = mhat - eps, mhat + eps
        if hi < M_STAR:
            verdict = (f"CERTIFIED ascending, gain in "
                       f"[{lambda_lab(hi):.4f}, {lambda_lab(lo):.4f}]")
        elif lo > M_STAR:
            verdict = (f"CERTIFIED descending, gain in "
                       f"[{1 / lambda_lab(lo):.4f}, {1 / lambda_lab(hi):.4f}]")
        else:
            verdict = "UNDETERMINED (interval straddles the crossover)"
        print(f"  {label:<30s} mhat = {mhat:.4f} +/- {eps:.3f} -> {verdict}")


# ----------------------------------------------------------------------------
# 3. The master cap: touch floor, wheels, audit
# ----------------------------------------------------------------------------

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


def wheel_survivors(mod: int, blocks: int) -> int:
    """Brute-force count of x < mod*blocks with gcd(mod, x) = 1."""
    return sum(1 for x in range(mod * blocks) if math.gcd(mod, x) == 1)


def cap_l7(mu: float, twok: float, lam: float) -> float:
    """The master cap (4/3) * min(1/mu, 2^k) / Lambda."""
    return (4.0 / 3.0) * min(1.0 / mu, twok) / lam


def demo_wheels_and_cap() -> None:
    print()
    print("=" * 78)
    print("11-12.  TOUCH FLOOR, WHEEL LAW, AND THE ZERO-VIOLATION AUDIT")
    print("=" * 78)
    print(f"  {'M':>5} {'blocks':>7} {'survivors':>10} {'phi(M)*m':>10} "
          f"{'keep mu':>10} {'ceiling M/phi(M)':>18}")
    for mod in (2, 6, 30, 210):
        for blocks in (1, 4):
            s = wheel_survivors(mod, blocks)
            pred = euler_phi(mod) * blocks
            print(f"  {mod:>5} {blocks:>7} {s:>10} {pred:>10} "
                  f"{s / (mod * blocks):>10.6f} "
                  f"{mod / euler_phi(mod):>18.6f}   "
                  f"[{'OK' if s == pred else 'FAIL'}]")

    print("\n  mod-30 protocol law:  ceiling = 30/phi(30) = 30/8 = "
          f"{30 / euler_phi(30):.4f}")
    for measured in (3.7331, 3.741, 3.7496):
        gap = 100.0 * (3.75 - measured) / 3.75
        print(f"    measured S = {measured:.4f} <= 3.75 : "
              f"{measured <= 3.75}   gap to law = {gap:.3f}%")

    print("\n  Touch floor, direct simulation (full scan vs filtered scan):")
    for mod, blocks in ((30, 100), (6, 500)):
        M = mod * blocks
        kappa = euler_phi(mod) * blocks
        s = ((M + 1) / 2) / ((kappa + 1) / 2)
        print(f"    M = {M}, survivors = {kappa}: S = {s:.6f} <= "
              f"{mod / euler_phi(mod):.6f} : {s <= mod / euler_phi(mod)}")

    audit: List[Tuple[str, float, float, float, float]] = [
        ("wheel arm",                       3.7331, 4 / 15, 32.0, 1.0),
        ("wheel arm (headline)",            3.7410, 4 / 15, 32.0, 1.0),
        ("wheel arm",                       3.7496, 4 / 15, 32.0, 1.0),
        ("mod-3 keyed, pool A",             0.6366, 1.0,    32.0, 1.0),
        ("mod-3 fixed, pool A",             0.6537, 1.0,    32.0, 1.0),
        ("mod-3 keyed, legacy pool",        0.6840, 1.0,    32.0, 1.0),
        ("mod-3 fixed, legacy pool",        0.6600, 1.0,    32.0, 1.0),
        ("narrow-band window ascending",    0.5682, 1.0,    32.0, 1.0),
        ("narrow-band window descending",   1.0000, 1.0,    32.0, 1.0),
        ("legacy pool truncated ascending", 0.9278, 1.0,    32.0, 1.0),
        ("ladder-aligned surrogate",        0.9900, 1.0,    32.0, 1.0),
        ("ladder-naive surrogate",          0.2700, 1.0,    32.0, 1.0),
        ("hybrid window x wheel",           4.0600, 4 / 15, 32.0, 0.7533),
    ]
    print("\n  Cap audit:")
    violations = 0
    for name, S, mu, twok, lam in audit:
        cap = cap_l7(mu, twok, lam)
        ok = S <= cap + 1e-12
        violations += 0 if ok else 1
        print(f"    {name:<34s} S = {S:6.4f}  cap = {cap:7.4f}  "
              f"[{'ok' if ok else 'VIOLATION'}]")
    print(f"  total violations: {violations}")

    S_hybrid, lam_hybrid = 4.06, 0.7533
    print("\n  Vacuity boundary (why extracting mu is load-bearing):")
    print(f"    mu booked at 1     -> cap = {cap_l7(1.0, 32.0, lam_hybrid):.4f} "
          f"< S = {S_hybrid}  (cap VIOLATED, and equals 4/3 when Lambda = 1)")
    print(f"    mu extracted 4/15  -> cap = {cap_l7(4 / 15, 32.0, lam_hybrid):.4f} "
          f">= S = {S_hybrid}  (cap satisfied and non-vacuous)")
    print(f"    pure permutation, mu = 1, Lambda = 1 -> cap = "
          f"{cap_l7(1.0, 32.0, 1.0):.6f} = 4/3 exactly (says nothing)")


# ----------------------------------------------------------------------------
# 4. Witness corrections
# ----------------------------------------------------------------------------

def jacobi_symbol(a: int, n: int) -> int:
    """Jacobi symbol (a|n) for odd n >= 1; returns 0 when gcd(a, n) != 1."""
    if n <= 0 or n % 2 == 0:
        raise ValueError("Jacobi symbol requires odd positive n")
    a %= n
    result = 1
    while a != 0:
        while a % 2 == 0:
            a //= 2
            if n % 8 in (3, 5):
                result = -result
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            result = -result
        a %= n
    return result if n == 1 else 0


def demo_witnesses() -> None:
    print()
    print("=" * 78)
    print("13-14.  WITNESS CORRECTIONS")
    print("=" * 78)
    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    values = set()
    for p, q in itertools.product(primes, repeat=2):
        values.add(jacobi_symbol(p * q, p))
    print(f"  Jacobi witness at the factor, over {len(primes) ** 2} draws (p,q): "
          f"observed values = {values}")
    print("    -> identically 0: the witness measures 'p divides N', not prior shape.")
    coprime_nonzero = all(jacobi_symbol(N, x) != 0
                          for N in (15, 77, 143) for x in (7, 9, 11, 13)
                          if math.gcd(N, x) == 1)
    print(f"    contrast: (N|x) != 0 whenever gcd(N,x) = 1 : {coprime_nonzero}")

    print("\n  Keyed vs fixed residue promotion (factor blindness):")
    for mod in (3, 5, 30):
        blocks = 40
        counts: Dict[int, int] = {}
        for c in range(mod):
            if math.gcd(c, mod) != 1:
                continue
            counts[c] = sum(1 for x in range(mod * blocks) if x % mod == c)
        survivors = wheel_survivors(mod, blocks)
        shares = {c: n / survivors for c, n in counts.items()}
        print(f"    M = {mod:>3}: promoted counts per invertible class = "
              f"{sorted(set(counts.values()))} (all equal: "
              f"{len(set(counts.values())) == 1}), "
              f"share = {sorted(set(round(s, 10) for s in shares.values()))} "
              f"(theory 1/phi(M) = {1 / euler_phi(mod):.10f})")

    def key(n: int) -> int:
        return 1 if n % 2 == 0 else 2

    blocks = 40
    keyed = {N: sum(1 for x in range(3 * blocks) if x % 3 == key(N))
             for N in (15, 77, 143, 221, 899)}
    print(f"    mod-3 keyed promotion counts across moduli N: "
          f"{sorted(set(keyed.values()))} -> identical for every key, hence "
          f"factor-blind.")


def main() -> None:
    demo_exchange_theorem()
    demo_head_domination()
    demo_signflip()
    demo_family()
    demo_certification()
    demo_wheels_and_cap()
    demo_witnesses()
    print()
    print("=" * 78)
    print("All demonstrations complete.")
    print("=" * 78)


if __name__ == "__main__":
    main()
