"""
Numerical demonstrations of the q-ary exact coset-guesswork exponent.

Main facts illustrated
----------------------
For a maximal-entropy (uniform) source over an alphabet of q >= 2 symbols and a
moment order rho > 0, the rho-th guesswork moment over q^k equiprobable
candidates is

    M_q(k) = q^{-k} * sum_{j=1}^{q^k} j^rho.

The base-q per-symbol growth rate of the constrained coset moment,
(1/m) * log_q M_q(k_m), converges to exactly rho * R whenever k_m / m -> R.
The unconstrained case R = 1 gives rho, so a rate-R code lowers the exponent by
exactly rho * (1 - R), independent of the alphabet size q.

We also verify the two-sided power-sum sandwich

    q^{(j-1)(rho+1)} <= sum_{k=1}^{q^j} k^rho <= q^{j(rho+1)}

and the Renyi-entropy identity H_alpha(uniform on q letters) = log_b q.

Run:  python demo.py
"""

from __future__ import annotations

import math


def power_sum(rho: float, N: int) -> float:
    """Return S_rho(N) = sum_{k=1}^{N} k^rho."""
    return sum((k ** rho) for k in range(1, N + 1))


def coset_moment(q: int, rho: float, k: int) -> float:
    """Return the rho-th q-ary guesswork moment M_q(k) = q^{-k} * S_rho(q^k)."""
    return (q ** (-k)) * power_sum(rho, q ** k)


def logb(base: float, x: float) -> float:
    """Base-`base` logarithm."""
    return math.log(x) / math.log(base)


def per_symbol_rate(q: int, rho: float, k_m: int, m: int) -> float:
    """Return (1/m) * log_q M_q(k_m), the empirical per-symbol growth rate."""
    return (1.0 / m) * logb(q, coset_moment(q, rho, k_m))


def renyi_entropy_uniform(b: float, alpha: float, q: int) -> float:
    """Renyi entropy of order alpha (alpha != 1) of the uniform law on q letters."""
    total = sum((1.0 / q) ** alpha for _ in range(q))
    return (1.0 / (1.0 - alpha)) * logb(b, total)


def power_sum_sandwich_ok(q: int, rho: float, j: int) -> tuple[float, float, float]:
    """Return (lower, S_rho(q^j), upper) for the two-sided power-sum estimate."""
    lower = q ** ((j - 1) * (rho + 1))
    upper = q ** (j * (rho + 1))
    return lower, power_sum(rho, q ** j), upper


def _max_block(q: int, cap: int = 2_000_000) -> int:
    """Largest k with q^k <= cap, so the power sum stays computable."""
    k = 1
    while q ** (k + 1) <= cap:
        k += 1
    return k


def demo_exponent_convergence() -> None:
    print("=" * 68)
    print("Convergence of the constrained coset exponent to rho * R")
    print("=" * 68)
    for q in (2, 3, 4):
        kmax = _max_block(q)
        for rho, R in ((1.0, 0.5), (2.0, 0.5), (2.0, 0.75)):
            print(f"\n  q = {q}, rho = {rho}, target rho*R = {rho * R:.4f}"
                  f"  (unconstrained rho = {rho})")
            # choose block lengths m so that k_m = round(R*m) stays <= kmax
            for m in (4, 8, 12, 16, 20):
                k_m = round(R * m)            # k_m / m -> R
                if k_m < 1 or k_m > kmax:
                    continue
                rate = per_symbol_rate(q, rho, k_m, m)
                print(f"    m = {m:2d}, k_m = {k_m:2d}: "
                      f"(1/m) log_q M = {rate:.5f}")


def demo_redundancy_shift() -> None:
    print("\n" + "=" * 68)
    print("Exact redundancy shift  rho - rho*R = rho*(1-R), alphabet-agnostic")
    print("=" * 68)
    for q in (2, 3, 4):
        kmax = _max_block(q)
        for rho, R in ((2.0, 0.6), (3.0, 0.4)):
            # unconstrained uses k_full = m (R=1); pick m = kmax so it is computable
            m = kmax
            k_full = m                          # R = 1 (unconstrained)
            k_cons = max(1, round(R * m))
            e_full = per_symbol_rate(q, rho, k_full, m)
            e_cons = per_symbol_rate(q, rho, k_cons, m)
            shift = e_full - e_cons
            print(f"  q={q:2d} rho={rho} R={R} (m={m}): unconstrained~{e_full:.4f}, "
                  f"constrained~{e_cons:.4f}, shift~{shift:.4f} "
                  f"(predicted {rho * (1 - R):.4f})")


def demo_power_sum_sandwich() -> None:
    print("\n" + "=" * 68)
    print("Two-sided power-sum sandwich  q^((j-1)(rho+1)) <= S <= q^(j(rho+1))")
    print("=" * 68)
    for q in (2, 3):
        for rho in (1.0, 2.5):
            for j in (1, 2, 3, 4):
                lo, s, hi = power_sum_sandwich_ok(q, rho, j)
                ok = lo <= s <= hi
                print(f"  q={q} rho={rho} j={j}: {lo:.3e} <= {s:.3e} <= {hi:.3e}"
                      f"  [{'OK' if ok else 'FAIL'}]")


def demo_renyi_uniform() -> None:
    print("\n" + "=" * 68)
    print("Renyi entropy of the uniform law equals log_b q for every order")
    print("=" * 68)
    b = 2.0
    for q in (2, 3, 8):
        target = logb(b, q)
        vals = [renyi_entropy_uniform(b, a, q) for a in (0.25, 0.5, 2.0, 5.0)]
        print(f"  q={q}: log_2 q = {target:.4f}, H_alpha for various alpha = "
              + ", ".join(f"{v:.4f}" for v in vals))


def main() -> None:
    demo_exponent_convergence()
    demo_redundancy_shift()
    demo_power_sum_sandwich()
    demo_renyi_uniform()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
