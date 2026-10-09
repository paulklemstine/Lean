#!/usr/bin/env python3
"""
One scalar prices everything: numerical companion to
"External Hints Are Priced Linearly in Bits".

Every function is inlined; only the Python standard library is used.
Sections:
  1. The master law  Speedup = 1 / (1 - (1 - theta) * P_hit)
  2. The symmetry break: internal readings vs. external likelihoods
  3. The which-factor ceiling 2K^2/(K^2+1) and the partition law 8/(7 - 2a)
  4. Many factors: fine-dial limit r/(r-1), overshoot, collapse onto 4/3
  5. The certain-hint ladder and its two lost bits
  6. Trace hints: a bounded divisor is not a rate penalty
  7. The noise break-even surface (explicit fallback model)
  8. The strategy-free t-bit guessing bound, its sharpness, no synergy
  9. Isolation cost: ceil(log2 M) yes/no queries
"""
from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

Number = float | Fraction


# ---------------------------------------------------------------------------
# 1. Master law
# ---------------------------------------------------------------------------
def master_speedup(theta: Number, p_hit: Number) -> Number:
    """Speedup of a filtered search: cost theta on a hit, 1 on a miss."""
    return 1 / (1 - (1 - theta) * p_hit)


def speedup_from_space(mu: Sequence[Number], hit: Sequence[bool], theta: Number) -> Number:
    """Speedup computed the long way, directly from a finite probability space."""
    work = sum(m * (theta if h else 1) for m, h in zip(mu, hit))
    return 1 / work


def section_master(rng: random.Random) -> None:
    print("=" * 72)
    print("1. MASTER LAW: the filter acts only through P_hit")
    print("=" * 72)
    theta = Fraction(1, 3)
    for trial in range(3):
        n = rng.randint(5, 12)
        w = [Fraction(rng.randint(1, 9)) for _ in range(n)]
        mu = [x / sum(w) for x in w]
        hit = [rng.random() < 0.5 for _ in range(n)]
        p = sum(m for m, h in zip(mu, hit) if h)
        lhs = speedup_from_space(mu, hit, theta)
        rhs = master_speedup(theta, p)
        print(f"  space #{trial}: |Omega|={n:2d}  P_hit={str(p):>8}  "
              f"direct={float(lhs):.6f}  master={float(rhs):.6f}  equal={lhs == rhs}")
    print(f"  ceiling 1/theta = {1/theta}, attained iff P_hit = 1: "
          f"{master_speedup(theta, Fraction(1)) == 1/theta}")


# ---------------------------------------------------------------------------
# 2. Symmetry break
# ---------------------------------------------------------------------------
def joint_phit(nu: Sequence[Fraction], K: int,
               R: Callable[[int, int, int], Fraction]) -> Fraction:
    """P_hit on C x Fin K x Fin K with law nu(c)/K * R(c, b, h), hit iff h == b."""
    return sum(nu[c] / K * R(c, b, b) for c in range(len(nu)) for b in range(K))


def section_symmetry(rng: random.Random) -> None:
    print("\n" + "=" * 72)
    print("2. SYMMETRY BREAK: internal readings die, external likelihoods survive")
    print("=" * 72)
    K, C = 2, 6
    w = [Fraction(rng.randint(1, 9)) for _ in range(C)]
    nu = [x / sum(w) for x in w]
    # internal: reading depends only on c (arbitrary randomisation)
    rows = []
    for _ in range(C):
        a = Fraction(rng.randint(0, 10), 10)
        rows.append([a, 1 - a])
    p_int = joint_phit(nu, K, lambda c, b, h: rows[c][h])
    print(f"  internal reading, random c-dependent kernel:  P_hit = {p_int}  "
          f"-> speedup at theta=1/2: {master_speedup(Fraction(1,2), p_int)}")
    for acc in [Fraction(1, 2), Fraction(7, 10), Fraction(9, 10), Fraction(1)]:
        L = [[acc, 1 - acc], [1 - acc, acc]]
        p_ext = joint_phit(nu, K, lambda c, b, h: L[b][h])
        print(f"  external hint, accuracy {str(acc):>5}:  P_hit = {str(p_ext):>5}  "
              f"-> speedup {float(master_speedup(Fraction(1,2), p_ext)):.4f}")
    print("  The 4/3 cap is exactly the uninformative point (accuracy 1/2).")


# ---------------------------------------------------------------------------
# 3. Which-factor ceiling
# ---------------------------------------------------------------------------
def which_factor_phit_bruteforce(K: int, L: List[List[Fraction]]) -> Fraction:
    """Enumerate (b_p, b_q, w, h): the hint speaks about p (w) or q, unnamed."""
    total = Fraction(0)
    for bp, bq, w, h in itertools.product(range(K), range(K), (True, False), range(K)):
        spoken = bp if w else bq
        mass = Fraction(1, 2 * K * K) * L[spoken][h]
        if h == bp:
            total += mass
    return total


def which_factor_ceiling(K: int) -> Fraction:
    return Fraction(2 * K * K, K * K + 1)


def partition_law(alpha: Fraction) -> Fraction:
    return Fraction(8) / (7 - 2 * alpha)


def symmetric_likelihood(K: int, alpha: Fraction) -> List[List[Fraction]]:
    off = (1 - alpha) / (K - 1) if K > 1 else Fraction(0)
    return [[alpha if b == h else off for h in range(K)] for b in range(K)]


def section_which_factor() -> None:
    print("\n" + "=" * 72)
    print("3. WHICH-FACTOR CEILING 2K^2/(K^2+1) < 2 and PARTITION LAW 8/(7-2a)")
    print("=" * 72)
    for K in [2, 3, 4, 8, 16]:
        L = symmetric_likelihood(K, Fraction(1))
        p = which_factor_phit_bruteforce(K, L)
        s = master_speedup(Fraction(1, K), p)
        print(f"  K={K:2d}: perfect-hint P_hit={str(p):>8}  speedup={str(s):>9} "
              f"= {float(s):.4f}  ceiling={which_factor_ceiling(K)}  "
              f"isolated={K}")
    print("  partition law at K=2:")
    for a in [Fraction(1, 2), Fraction(3, 5), Fraction(4, 5), Fraction(1)]:
        p = which_factor_phit_bruteforce(2, symmetric_likelihood(2, a))
        s = master_speedup(Fraction(1, 2), p)
        print(f"    alpha={str(a):>4}: brute force {str(s):>6}   8/(7-2a) = {partition_law(a)}")


# ---------------------------------------------------------------------------
# 4. Many factors
# ---------------------------------------------------------------------------
def many_factor_ceiling(s: int, K: int) -> Fraction:
    """Perfect-hint ceiling with r = s+1 factors at per-dial cost 1/K."""
    return Fraction((s + 1) * K * K, s * K * K - (s - 1) * K + s)


def section_many_factors() -> None:
    print("\n" + "=" * 72)
    print("4. MANY FACTORS: limit r/(r-1), overshoot for r>=3, collapse onto 4/3")
    print("=" * 72)
    for r in [2, 3, 4, 7, 10, 50]:
        s = r - 1
        vals = {K: many_factor_ceiling(s, K) for K in range(1, 60)}
        best_K = max(vals, key=lambda k: vals[k])
        lim = Fraction(r, r - 1)
        print(f"  r={r:2d}: limit r/(r-1)={float(lim):.4f}  K=2 -> {float(vals[2]):.4f}"
              f"  K=r -> {float(vals.get(r, many_factor_ceiling(s, r))):.4f}"
              f"  best K={best_K:2d} ({float(vals[best_K]):.4f})"
              f"  4r/(3r-1)={float(Fraction(4*r, 3*r-1)):.4f}")


# ---------------------------------------------------------------------------
# 5. Ladder
# ---------------------------------------------------------------------------
def ladder(t: int) -> float:
    return 2.0 ** t / 4 / (1 - 2 / 2.0 ** t)


def section_ladder() -> None:
    print("\n" + "=" * 72)
    print("5. CERTAIN-HINT LADDER 2^(t-2)/(1-2^(1-t)): exactly two bits lost")
    print("=" * 72)
    for t in range(2, 13):
        a = 2 / 2.0 ** t
        via_master = master_speedup(2 * a * (1 - a), 1.0)
        print(f"  t={t:2d}: ladder={ladder(t):9.3f}  master-law form={via_master:9.3f}  "
              f"2^t/ladder={2**t/ladder(t):.4f}  ratio next/this="
              f"{ladder(t+1)/ladder(t):.4f}")


# ---------------------------------------------------------------------------
# 6. Trace hints
# ---------------------------------------------------------------------------
def section_trace() -> None:
    print("\n" + "=" * 72)
    print("6. TRACE HINTS 2^(t-1)/C_t: bounded divisor, rate still 1 bit/bit")
    print("=" * 72)
    C = lambda t: 5.0 + math.sin(t)  # any divisor in [4, 6]
    for t in [4, 8, 16, 32, 64, 128]:
        sp = 2.0 ** (t - 1) / C(t)
        print(f"  t={t:4d}: log2(speedup)/t = {math.log2(sp)/t:.4f}")


# ---------------------------------------------------------------------------
# 7. Noise break-even
# ---------------------------------------------------------------------------
def noisy_work(theta: float, p: float, eps: float) -> float:
    return (1 - eps) * (1 - (1 - theta) * p) + eps * (1 + theta)


def alpha_star(theta: float, eps: float) -> float:
    return 2 * eps * theta / ((1 - eps) * (1 - theta)) - theta


def section_noise() -> None:
    print("\n" + "=" * 72)
    print("7. NOISE BREAK-EVEN SURFACE (fallback cost model)")
    print("=" * 72)
    for theta in [0.25, 0.5, 0.75]:
        e_int = (1 - theta) / (2 - theta)
        e_ext = (1 - theta ** 2) / (1 + 2 * theta - theta ** 2)
        print(f"  theta={theta}: internal tolerates eps < {e_int:.4f},"
              f" external (perfect, unnamed) tolerates eps < {e_ext:.4f}")
    rng = random.Random(7)
    agree = 0
    for _ in range(20):
        th, ep, al = rng.uniform(0.05, .95), rng.uniform(0, .6), rng.uniform(0, 1)
        agree += (noisy_work(th, (al + th) / 2, ep) < 1) == (alpha_star(th, ep) < al)
    print(f"  break-even verdicts agree with closed form: {agree}/20")


# ---------------------------------------------------------------------------
# 8. Guessing bound
# ---------------------------------------------------------------------------
def optimal_guess_positions(H: Sequence[int]) -> List[int]:
    """Best strategy for a uniform target: rank inside each hint fibre."""
    seen: Dict[int, int] = {}
    g = []
    for h in H:
        seen[h] = seen.get(h, 0) + 1
        g.append(seen[h])
    return g


def section_guessing(rng: random.Random) -> None:
    print("\n" + "=" * 72)
    print("8. t-BIT GUESSING BOUND: speedup <= |beta| <= 2^t, sharp, no synergy")
    print("=" * 72)
    M = 240
    for B in [2, 4, 8, 16]:
        H = [rng.randrange(B) for _ in range(M)]
        g = optimal_guess_positions(H)
        S = sum(g)
        lhs, rhs = M * M + B * M, B * 2 * S
        speed = ((M + 1) / 2) / (S / M)
        print(f"  random hint, |beta|={B:2d}: M^2+|b|M={lhs:7d} <= |b|*2*Sum g={rhs:7d}"
              f"   speedup={speed:6.3f} <= {B}")
    for B, m in [(4, 60), (16, 15)]:
        H = [b for b in range(B) for _ in range(m)]
        g = optimal_guess_positions(H)
        Mx = B * m
        print(f"  balanced hint B={B}, m={m}: bound equality "
              f"{Mx*Mx + B*Mx == B*2*sum(g)}   speedup={((Mx+1)/2)/(sum(g)/Mx):.4f}"
              f" = B(M+1)/(M+B) = {B*(Mx+1)/(Mx+B):.4f}")
    H1 = [rng.randrange(4) for _ in range(M)]
    H2 = [rng.randrange(8) for _ in range(M)]
    g = optimal_guess_positions([a * 8 + b for a, b in zip(H1, H2)])
    print(f"  joint 2-bit + 3-bit hint: speedup={((M+1)/2)/(sum(g)/M):.3f} <= 2^5 = 32")


# ---------------------------------------------------------------------------
# 9. Isolation cost
# ---------------------------------------------------------------------------
def primes_upto(n: int) -> int:
    sieve = bytearray([1]) * (n + 1)
    sieve[0:2] = b"\x00\x00"
    for i in range(2, int(n ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(sieve[i * i::i]))
    return sum(sieve)


def section_isolation() -> None:
    print("\n" + "=" * 72)
    print("9. ISOLATION COST: ceil(log2 M) separating yes/no queries")
    print("=" * 72)
    for bits in [16, 24, 32, 40]:
        root = 2 ** (bits // 2)
        M = primes_upto(root)
        print(f"  N ~ 2^{bits}: M = pi(sqrt N) = {M:6d}  ->  {math.ceil(math.log2(M))} queries")


def main() -> None:
    rng = random.Random(20260821)
    section_master(rng)
    section_symmetry(rng)
    section_which_factor()
    section_many_factors()
    section_ladder()
    section_trace()
    section_noise()
    section_guessing(rng)
    section_isolation()


if __name__ == "__main__":
    main()
