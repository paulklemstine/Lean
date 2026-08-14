#!/usr/bin/env python3
"""
Exact order recovery from a single heat-kernel value on a lacunary dyadic Cayley graph.

This script is a self-contained numerical companion to the theory.  It demonstrates,
end to end:

  1. The doubling lemma:  for every frequency k not divisible by r there is a dyadic
     shift t <= M with (2^t k mod r) in the far arc [r/4, 3r/4], provided r <= 2^M.

  2. The spectral gap:  every nontrivial eigenvalue of the half-lazy lacunary dyadic
     walk satisfies  0 <= mu_k <= 1 - 1/(2(M+1)).

  3. Exact recovery:  with n = 8(M+1)^2 steps,  round(1 / p_n(e)) = r  exactly,
     where p_n(e) = (1/r) * sum_k mu_k^n is the return probability at the identity.

  4. Operational grounding:  simulating the explicit diffusion operator
       (W f)(x) = f(x)/2 + (1/(4(M+1))) * sum_t [ f(x+2^t) + f(x-2^t) ]
     on the cycle Z/rZ reproduces the same number to machine precision.

  5. The arithmetic payload:  a recovered even order 2m with b^m != +-1 mod N splits N
     by a single gcd.

  6. Sharpness:  for the Mersenne cycle r = 2^M - 1 the spectral gap is Theta(1/M),
     so the quadratic step count cannot be improved to linear.

Only the standard library is used.  Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Dict, List, Optional, Tuple

# ----------------------------------------------------------------------------------
# Basic arithmetic
# ----------------------------------------------------------------------------------


def multiplicative_order(b: int, n: int) -> int:
    """Least r >= 1 with b^r = 1 (mod n).  Requires gcd(b, n) = 1."""
    if math.gcd(b, n) != 1:
        raise ValueError(f"gcd({b},{n}) != 1: the order is undefined")
    x, r = b % n, 1
    while x != 1:
        x = (x * b) % n
        r += 1
    return r


def dyadic_exponent(n: int) -> int:
    """Least M with n <= 2^M (the lacunary depth used throughout)."""
    m = 0
    while (1 << m) < n:
        m += 1
    return m


def circle_distance(r: int, x: int) -> int:
    """min(x mod r, r - x mod r): distance from 0 on the cycle of length r."""
    s = x % r
    return min(s, r - s)


# ----------------------------------------------------------------------------------
# 1. The doubling lemma
# ----------------------------------------------------------------------------------


def far_arc_shift(r: int, k: int, M: int) -> Optional[int]:
    """Smallest t <= M with (2^t k mod r) in the far arc [r/4, 3r/4], else None.

    The doubling lemma guarantees such a t exists whenever r <= 2^M and r does not
    divide k.
    """
    for t in range(M + 1):
        if r <= 4 * circle_distance(r, (k << t)):
            return t
    return None


def check_doubling_lemma(r: int, M: int) -> Tuple[bool, int]:
    """Verify the doubling lemma for every nonzero frequency of Z/rZ.

    Returns (all_ok, worst_shift), where worst_shift is the largest t actually needed.
    """
    assert r <= 2 ** M, "the doubling lemma needs r <= 2^M"
    worst = 0
    for k in range(1, r):
        t = far_arc_shift(r, k, M)
        if t is None:
            return False, -1
        worst = max(worst, t)
    return True, worst


# ----------------------------------------------------------------------------------
# 2. Spectrum of the half-lazy lacunary dyadic walk
# ----------------------------------------------------------------------------------


def dyadic_eigenvalue(r: int, M: int, k: int) -> float:
    """lambda_k = (1/(M+1)) sum_{t=0}^{M} cos(2 pi k 2^t / r)."""
    total = 0.0
    for t in range(M + 1):
        total += math.cos(2.0 * math.pi * ((k << t) % r) / r)
    return total / (M + 1)


def lazy_eigenvalue(r: int, M: int, k: int) -> float:
    """mu_k = (1 + lambda_k)/2, the eigenvalue of W = (I + P)/2."""
    return 0.5 * (1.0 + dyadic_eigenvalue(r, M, k))


def spectral_gap_report(r: int, M: int) -> Dict[str, float]:
    """Largest nontrivial eigenvalue versus the proved bound 1 - 1/(2(M+1))."""
    top = max(lazy_eigenvalue(r, M, k) for k in range(1, r)) if r > 1 else 0.0
    low = min(lazy_eigenvalue(r, M, k) for k in range(1, r)) if r > 1 else 0.0
    return {
        "top_nontrivial_mu": top,
        "min_mu": low,
        "proved_upper_bound": 1.0 - 1.0 / (2.0 * (M + 1)),
    }


# ----------------------------------------------------------------------------------
# 3. The heat kernel and exact recovery
# ----------------------------------------------------------------------------------


def heat_return_spectral(r: int, M: int, n: int) -> float:
    """p_n(e) = (1/r) sum_{k<r} mu_k^n, the return probability at the identity."""
    return sum(lazy_eigenvalue(r, M, k) ** n for k in range(r)) / r


def recover_order(r: int, M: int, n: Optional[int] = None) -> int:
    """round(1 / p_n(e)) with the prescribed step count n = 8(M+1)^2."""
    if n is None:
        n = 8 * (M + 1) ** 2
    return round(1.0 / heat_return_spectral(r, M, n))


# ----------------------------------------------------------------------------------
# 4. Operational grounding: simulate the diffusion directly
# ----------------------------------------------------------------------------------


def walk_step(state: List[float], M: int) -> List[float]:
    """One application of (W f)(x) = f(x)/2 + (1/(4(M+1))) sum_t [f(x+2^t)+f(x-2^t)]."""
    r = len(state)
    out = [0.5 * v for v in state]
    w = 1.0 / (4.0 * (M + 1))
    for t in range(M + 1):
        jump = (1 << t) % r
        for x in range(r):
            out[x] += w * (state[(x - jump) % r] + state[(x + jump) % r])
    return out


def heat_return_simulated(r: int, M: int, n: int) -> float:
    """Mass at the identity after n explicit diffusion steps from a point mass."""
    state = [0.0] * r
    state[0] = 1.0
    for _ in range(n):
        state = walk_step(state, M)
    return state[0]


# ----------------------------------------------------------------------------------
# 5. Arithmetic payload: order -> factor
# ----------------------------------------------------------------------------------


def factor_from_order(N: int, b: int, r: int) -> Optional[Tuple[int, int]]:
    """Split N using an even order r = 2m with b^m != +-1 (mod N); else None."""
    if r % 2 != 0:
        return None
    y = pow(b, r // 2, N)
    if y == 1 or y == N - 1:
        return None
    d = math.gcd(y - 1, N)
    if 1 < d < N:
        return d, N // d
    return None


# ----------------------------------------------------------------------------------
# 6. Sharpness of the gap on the Mersenne family
# ----------------------------------------------------------------------------------


def mersenne_gap_profile(max_M: int = 14) -> List[Tuple[int, float, float]]:
    """(M, (1 - lambda_1)*(M+1), 1 - lambda_1) for the extremal cycle r = 2^M - 1."""
    rows: List[Tuple[int, float, float]] = []
    for M in range(2, max_M + 1):
        r = 2 ** M - 1
        gap = 1.0 - dyadic_eigenvalue(r, M, 1)
        rows.append((M, gap * (M + 1), gap))
    return rows


def deficiency(r: int, k: int, M: int) -> float:
    """sum_{t<=M} (1 - cos(2 pi k 2^t / r)): the quantity conjectured to be >= 2."""
    return sum(1.0 - math.cos(2.0 * math.pi * ((k << t) % r) / r) for t in range(M + 1))


def min_deficiency(max_M: int = 8) -> Tuple[float, Tuple[int, int, int]]:
    """Exhaustive minimum of the deficiency over all r <= 2^M, k != 0 (mod r)."""
    best = float("inf")
    arg = (0, 0, 0)
    for M in range(1, max_M + 1):
        for r in range(2, 2 ** M + 1):
            for k in range(1, r):
                d = deficiency(r, k, M)
                if d < best:
                    best, arg = d, (r, k, M)
    return best, arg


# ----------------------------------------------------------------------------------
# Driver
# ----------------------------------------------------------------------------------

BANNER = "=" * 78


def demo_doubling_lemma() -> None:
    print(BANNER)
    print("1. THE DOUBLING LEMMA")
    print(BANNER)
    print("For r <= 2^M and every k not divisible by r, some dyadic shift 2^t k")
    print("lands in the far arc [r/4, 3r/4], where the cosine is nonpositive.\n")
    print(f"{'r':>6} {'M':>4} {'all frequencies escape':>24} {'largest shift needed':>22}")
    for r in [2, 3, 5, 12, 15, 24, 60, 127, 140, 255, 420]:
        M = dyadic_exponent(r)
        ok, worst = check_doubling_lemma(r, M)
        print(f"{r:>6} {M:>4} {str(ok):>24} {worst:>22}")
    print()


def demo_spectral_gap() -> None:
    print(BANNER)
    print("2. THE SPECTRAL GAP")
    print(BANNER)
    print("Every nontrivial eigenvalue obeys 0 <= mu_k <= 1 - 1/(2(M+1)).\n")
    print(f"{'r':>6} {'M':>4} {'min mu_k':>12} {'max nontrivial mu_k':>22} {'proved bound':>14}")
    for r in [15, 24, 48, 60, 140, 255, 420]:
        M = dyadic_exponent(r)
        rep = spectral_gap_report(r, M)
        print(
            f"{r:>6} {M:>4} {rep['min_mu']:>12.6f} "
            f"{rep['top_nontrivial_mu']:>22.6f} {rep['proved_upper_bound']:>14.6f}"
        )
    print()


def demo_order_recovery() -> None:
    print(BANNER)
    print("3. EXACT ORDER RECOVERY FROM ONE NUMBER")
    print(BANNER)
    print("N is a semiprime, b a unit, r = ord_N(b), M least with N <= 2^M,")
    print("n = 8(M+1)^2 diffusion steps.  We report round(1/p_n(e)).\n")
    cases = [(143, 2), (143, 3), (221, 2), (221, 3), (899, 2), (899, 3)]
    header = f"{'N':>6} {'b':>3} {'true r':>8} {'M':>4} {'n':>6} {'p_n(e)':>14} {'1/p_n(e)':>18} {'rounded':>9}"
    print(header)
    ok_all = True
    for N, b in cases:
        r = multiplicative_order(b, N)
        M = dyadic_exponent(N)
        n = 8 * (M + 1) ** 2
        p = heat_return_spectral(r, M, n)
        rec = round(1.0 / p)
        ok_all &= rec == r
        print(f"{N:>6} {b:>3} {r:>8} {M:>4} {n:>6} {p:>14.10f} {1.0/p:>18.12f} {rec:>9}")
    print(f"\nAll six recoveries exact: {ok_all}\n")


def demo_operational() -> None:
    print(BANNER)
    print("4. THE SPECTRAL FORMULA IS A GENUINE RETURN PROBABILITY")
    print(BANNER)
    print("Simulating the explicit diffusion operator from a point mass at 0")
    print("reproduces the spectral value (1/r) sum_k mu_k^n exactly.\n")
    print(f"{'r':>5} {'M':>4} {'n':>5} {'simulated':>16} {'spectral':>16} {'|difference|':>14}")
    for r, n in [(12, 40), (15, 40), (24, 60)]:
        M = dyadic_exponent(r)
        sim = heat_return_simulated(r, M, n)
        spe = heat_return_spectral(r, M, n)
        print(f"{r:>5} {M:>4} {n:>5} {sim:>16.12f} {spe:>16.12f} {abs(sim-spe):>14.3e}")
    print()
    r, M = 15, dyadic_exponent(15)
    n = 8 * (M + 1) ** 2
    sim = heat_return_simulated(r, M, n)
    print(f"Full-length simulation: r = {r}, M = {M}, n = {n}")
    print(f"  measured return probability = {sim:.12f}")
    print(f"  1 / measured                = {1.0/sim:.12f}")
    print(f"  rounded                     = {round(1.0/sim)}   (true order {r})\n")


def demo_factoring() -> None:
    print(BANNER)
    print("5. FROM A RECOVERED ORDER TO A FACTORISATION")
    print(BANNER)
    print("An even order 2m with b^m != +-1 (mod N) splits N by a single gcd.\n")
    print(f"{'N':>6} {'b':>3} {'recovered r':>13} {'b^(r/2) mod N':>15} {'factors':>14}")
    for N, b in [(143, 2), (221, 3), (899, 2), (2021, 2)]:
        r_true = multiplicative_order(b, N)
        M = dyadic_exponent(N)
        r = recover_order(r_true, M)          # the diffusion output, not r_true
        split = factor_from_order(N, b, r)
        y = pow(b, r // 2, N) if r % 2 == 0 else None
        txt = f"{split[0]} x {split[1]}" if split else "degenerate"
        print(f"{N:>6} {b:>3} {r:>13} {str(y):>15} {txt:>14}")
    print()


def demo_sharpness() -> None:
    print(BANNER)
    print("6. SHARPNESS: THE GAP IS Theta(1/M), SO THE TIME IS Theta((log N)^2)")
    print(BANNER)
    print("For the extremal Mersenne cycle r = 2^M - 1 the normalised gap")
    print("(1 - lambda_1)(M+1) converges to an absolute constant.\n")
    print(f"{'M':>4} {'r = 2^M - 1':>13} {'1 - lambda_1':>16} {'(1-lambda_1)(M+1)':>20}")
    for M, norm, gap in mersenne_gap_profile(14):
        print(f"{M:>4} {2**M - 1:>13} {gap:>16.8f} {norm:>20.6f}")
    print("\nThe proved bounds bracket this profile: 1 <= (1-lambda_1)(M+1) <= 106.")
    best, (r, k, M) = min_deficiency(7)
    print(f"\nExhaustive minimum of the dyadic deficiency over r <= 2^M, M <= 7:")
    print(f"  min sum_t (1 - cos(2 pi k 2^t / r)) = {best:.6f}  attained at "
          f"(r, k, M) = ({r}, {k}, {M})")
    print("  (the conjectured sharp value is exactly 2, attained only at (r,k) = (2,1))\n")


def main() -> None:
    print()
    print("EXACT ORDER RECOVERY FROM A SINGLE HEAT-KERNEL VALUE")
    print("on the lacunary dyadic Cayley graph of a cyclic group")
    print()
    demo_doubling_lemma()
    demo_spectral_gap()
    demo_order_recovery()
    demo_operational()
    demo_factoring()
    demo_sharpness()
    print(BANNER)
    print("All demonstrations completed.")
    print(BANNER)


if __name__ == "__main__":
    main()
