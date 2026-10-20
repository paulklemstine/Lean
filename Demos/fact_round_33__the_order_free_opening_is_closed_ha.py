#!/usr/bin/env python3
"""
The Order-Free Triangle: numerical companion.

Self-contained demonstrations of the results on the cost structure of
Harvey's exponent-1/5 deterministic factoring algorithm:

  1. The exponent cost  c(a, b) = max{a, b, 1/2 - a/2 - b}  is always >= 1/5,
     with equality only at a = b = 1/5 (dual certificate with weights 1/5, 2/5, 2/5).
  2. Under the order constraint b <= omega the optimum is max(1/5, (1 - 2 omega)/3).
  3. The full running time T(r, m) = (sqrt(N)/(sqrt(r) m) + r) L^4 + m L^2 satisfies
     F <= T <= 3F at the optimum, F = N^{1/5} L^{16/5}; adding any nonnegative
     order-dependent term P cannot push the cost below F.
  4. Producing a large-order element at cost N^{omega/2} never changes the exponent.
  5. Pair filters: generative -> 1/5 - 3 sigma/5, evaluated -> 1/5 - 2 sigma/5.
  6. Sound residue sieves on residue-uniform good pairs accept every class.
  7. Euler-gap split: if (p-1) | (q-1) then gcd(x^{pq-1} - 1, pq) = p typically.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from fractions import Fraction
from typing import Callable, Iterable


# ---------------------------------------------------------------------------
# 1. Exponent cost model
# ---------------------------------------------------------------------------

def cost_exp(a: float, b: float) -> float:
    """Exponent cost of Harvey's algorithm with r = N^a pairs and m = N^b baby steps."""
    return max(a, b, 0.5 - a / 2 - b)


def dual_certificate(a: Fraction, b: Fraction) -> Fraction:
    """Weighted average (1/5, 2/5, 2/5) of the three legs; identically 1/5."""
    legs = (a, b, Fraction(1, 2) - a / 2 - b)
    w = (Fraction(1, 5), Fraction(2, 5), Fraction(2, 5))
    return sum(wi * li for wi, li in zip(w, legs))


def grid_minimise(f: Callable[[float, float], float],
                  lo: float = -0.2, hi: float = 0.6, n: int = 401,
                  constraint: Callable[[float, float], bool] = lambda a, b: True
                  ) -> tuple[float, float, float]:
    """Brute-force minimisation of f(a, b) on a square grid, subject to a constraint."""
    best = (math.inf, 0.0, 0.0)
    for i in range(n):
        a = lo + (hi - lo) * i / (n - 1)
        for j in range(n):
            b = lo + (hi - lo) * j / (n - 1)
            if not constraint(a, b):
                continue
            v = f(a, b)
            if v < best[0]:
                best = (v, a, b)
    return best


def demo_cost_exponent() -> None:
    print("=" * 72)
    print("1. The exponent triangle: c(a,b) = max{a, b, 1/2 - a/2 - b}")
    print("=" * 72)
    rng = random.Random(1)
    for _ in range(4):
        a = Fraction(rng.randint(-50, 80), 100)
        b = Fraction(rng.randint(-50, 80), 100)
        print(f"  a={float(a):+.2f}, b={float(b):+.2f}:  "
              f"(1/5)a + (2/5)b + (2/5)(1/2-a/2-b) = {dual_certificate(a, b)}   "
              f"c(a,b) = {cost_exp(float(a), float(b)):.4f} >= 0.2")
    v, a, b = grid_minimise(cost_exp)
    print(f"  grid minimum: c = {v:.5f} at (a, b) = ({a:.3f}, {b:.3f})  [theory: 1/5 at (1/5, 1/5)]")
    print()


# ---------------------------------------------------------------------------
# 2. Order-constrained optimum
# ---------------------------------------------------------------------------

def order_value(omega: float) -> float:
    """Optimum of c(a,b) subject to b <= omega."""
    return max(0.2, (1 - 2 * omega) / 3)


def demo_order_constraint() -> None:
    print("=" * 72)
    print("2. Order constraint b <= omega:  optimum = max(1/5, (1 - 2 omega)/3)")
    print("=" * 72)
    print(f"  {'omega':>7} | {'grid optimum':>12} | {'formula':>8} | constraint binding?")
    for omega in (0.0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.333, 0.5, 1.0):
        v, _, _ = grid_minimise(cost_exp, constraint=lambda a, b, w=omega: b <= w + 1e-12)
        print(f"  {omega:7.3f} | {v:12.5f} | {order_value(omega):8.5f} | "
              f"{'yes (hurts)' if omega < 0.2 else 'no (zero shadow price)'}")
    print("  -> beyond omega = 1/5 the order of the element is irrelevant.")
    print()


# ---------------------------------------------------------------------------
# 3. Full running time with polylog factors
# ---------------------------------------------------------------------------

def harvey_time(N: float, L: float, r: float, m: float) -> float:
    """(sqrt(N)/(sqrt(r) m) + r) L^4 + m L^2."""
    return (math.sqrt(N) / (math.sqrt(r) * m) + r) * L ** 4 + m * L ** 2


def harvey_F(N: float, L: float) -> float:
    return N ** 0.2 * L ** 3.2


def demo_full_time() -> None:
    print("=" * 72)
    print("3. Full running time:  F <= T(r,m),  T(r*,m*) = 3F,  F = N^{1/5} L^{16/5}")
    print("=" * 72)
    rng = random.Random(2)
    for bits in (64, 128, 256, 512, 768):
        N = 2.0 ** bits
        L = float(bits)
        F = harvey_F(N, L)
        r_star = N ** 0.2 * L ** -0.8
        m_star = N ** 0.2 * L ** 1.2
        T_star = harvey_time(N, L, r_star, m_star)
        # random search over (r, m) in log-space
        worst_ratio = math.inf
        for _ in range(20000):
            r = math.exp(rng.uniform(0, math.log(N) / 2))
            m = math.exp(rng.uniform(0, math.log(N) / 2))
            worst_ratio = min(worst_ratio, harvey_time(N, L, r, m) / F)
        legs = (r_star * L ** 4,
                math.sqrt(N) * L ** 4 / (math.sqrt(r_star) * m_star),
                m_star * L ** 2)
        prod = legs[0] * legs[1] ** 2 * legs[2] ** 2
        print(f"  {bits:4d}-bit N: T*/F = {T_star / F:.6f}, min T/F over 20000 random "
              f"(r,m) = {worst_ratio:.4f} (>= 1),  X*Y^2*Z^2/(N L^16) = "
              f"{prod / (N * L ** 16):.6f}")
    # free order-finding: the extra term P >= 0 never helps
    N, L = 2.0 ** 512, 512.0
    F = harvey_F(N, L)
    print("  Adding an order-dependent product-tree term P >= 0 (P = 0 means free order-finding):")
    for P_rel in (0.0, 0.01, 1.0):
        best = min(harvey_time(N, L, N ** 0.2 * L ** -0.8 * k1, N ** 0.2 * L ** 1.2 * k2)
                   for k1 in (0.5, 0.8, 1, 1.25, 2) for k2 in (0.5, 0.8, 1, 1.25, 2)) + P_rel * F
        print(f"    P = {P_rel:4.2f} F  ->  best total / F = {best / F:.4f}   (always in [1, 3 + P/F])")
    print()


# ---------------------------------------------------------------------------
# 4. Large-order production is dominated
# ---------------------------------------------------------------------------

def demo_production() -> None:
    print("=" * 72)
    print("4. Producing an element of order N^omega at cost N^{omega/2} is dominated")
    print("=" * 72)
    rng = random.Random(3)
    worst = 0.0
    for _ in range(100000):
        a, b = rng.uniform(-1, 1), rng.uniform(0, 1)
        worst = max(worst, max(cost_exp(a, b), b / 2) - cost_exp(a, b))
    print(f"  max over 1e5 random (a, b>=0) of [max(c, b/2) - c] = {worst}")
    print(f"  delta = N^(1/3): production exponent 1/6 = {1/6:.4f} < 1/5 = 0.2000")
    print()


# ---------------------------------------------------------------------------
# 5. Pair filters
# ---------------------------------------------------------------------------

def gen_filter_exp(sigma: float, a: float, b: float) -> float:
    """Generative filter: pairs leg and interior both shrink by sigma."""
    return max(a - sigma, b, 0.5 - a / 2 - b - sigma)


def eval_filter_exp(sigma: float, a: float, b: float) -> float:
    """Evaluated filter: every pair still costs; only the interior shrinks."""
    return max(a, b, 0.5 - a / 2 - b - sigma)


def demo_filters() -> None:
    print("=" * 72)
    print("5. Pair filters with compression s = N^sigma")
    print("=" * 72)
    print(f"  {'sigma':>7} | {'gen grid':>8} {'1/5-3s/5':>8} | {'eval grid':>9} {'1/5-2s/5':>8}")
    for sigma in (0.0, 1 / 30, 1 / 18, 1 / 12, 0.1):
        g, _, _ = grid_minimise(lambda a, b, s=sigma: gen_filter_exp(s, a, b))
        e, _, _ = grid_minimise(lambda a, b, s=sigma: eval_filter_exp(s, a, b))
        print(f"  {sigma:7.4f} | {g:8.5f} {0.2 - 0.6 * sigma:8.5f} | {e:9.5f} {0.2 - 0.4 * sigma:8.5f}")
    print("  1/6 = 0.16667 is reached at sigma = 1/18 (generative) or sigma = 1/12 (evaluated).")
    print()


# ---------------------------------------------------------------------------
# 6. Residue sieves
# ---------------------------------------------------------------------------

def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for d in range(2, int(n ** 0.5) + 1):
        if n % d == 0:
            return False
    return True


def lehman_good_pair_residues(ell: int, samples: int, bits: int, seed: int = 4) -> set[int]:
    """Residues mod ell of a*b for the 'good' pair a/b ~ q/p (best approximation, ab small)
    over random balanced semiprimes. Used to illustrate residue-uniformity."""
    rng = random.Random(seed)
    primes = [n for n in range(2 ** (bits - 1), 2 ** bits) if is_prime(n)]
    seen: set[int] = set()
    for _ in range(samples):
        p, q = rng.sample(primes, 2)
        best: tuple[float, int, int] = (math.inf, 1, 1)
        for b in range(1, 40):
            a = max(1, round(b * q / p))
            err = abs(a * p - b * q)
            if err < best[0]:
                best = (err, a, b)
        _, a, b = best
        seen.add((a * b) % ell)
    return seen


def demo_residue_sieve() -> None:
    print("=" * 72)
    print("6. Residue sieves: a sound sieve on residue-uniform good pairs accepts everything")
    print("=" * 72)
    for ell in (3, 5, 7, 11):
        seen = lehman_good_pair_residues(ell, samples=400, bits=12)
        print(f"  ell = {ell:2d}: good-pair residues of ab observed = {sorted(seen)}"
              f"  -> sound sieve must keep {len(seen)}/{ell} classes")
    print()


# ---------------------------------------------------------------------------
# 7. Euler-gap split
# ---------------------------------------------------------------------------

def euler_split(N: int, bases: Iterable[int]) -> tuple[int, int] | None:
    for x in bases:
        g = math.gcd(pow(x, N - 1, N) - 1, N)
        if 1 < g < N:
            return x, g
    return None


def demo_euler_gap() -> None:
    print("=" * 72)
    print("7. Large Euler gap: (p-1) | (q-1)  =>  gcd(x^{pq-1} - 1, pq) = p")
    print("=" * 72)
    for p, q in ((11, 31), (13, 37), (101, 601), (1009, 1009 * 6 - 5)):
        if not (is_prime(p) and is_prime(q) and (q - 1) % (p - 1) == 0):
            continue
        N = p * q
        x = 2
        # exponent reduction in Z/p: x^{pq-1} = x^{q-1}
        assert pow(x, N - 1, p) == pow(x, q - 1, p) == 1
        res = euler_split(N, range(2, 50))
        print(f"  N = {p} * {q} = {N}:  2^(N-1) mod p = {pow(2, N - 1, p)},  "
              f"split found: base {res[0]} gives gcd = {res[1]}" if res else f"  N={N}: no split")
    # control: a random balanced semiprime with small gcd(p-1, q-1)
    p, q = 1019, 1031
    print(f"  control N = {p}*{q}, gcd(p-1,q-1) = {math.gcd(p - 1, q - 1)}: "
          f"split = {euler_split(p * q, range(2, 50))}")
    print()


def main() -> None:
    demo_cost_exponent()
    demo_order_constraint()
    demo_full_time()
    demo_production()
    demo_filters()
    demo_residue_sieve()
    demo_euler_gap()


if __name__ == "__main__":
    main()
