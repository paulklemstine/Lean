"""
Numerical demonstrations for the exact two-point correlation function of the
open one-dimensional Ising chain.

This script validates, with plain Python and the standard library only, the
main theorems of the accompanying paper:

  * corrNum_closed     :  corrNum(beta,J,n) = 2 * (2 sinh(beta J))^n
  * Zfree_closed       :  Z(beta,J,n)       = 2 * (2 cosh(beta J))^n
  * corr_eq_tanh_pow   :  <s0 sn>           = (tanh(beta J))^n
  * corr_eq_exp_neg_gap:  <s0 sn>           = exp(-g n),  g = log(coth(beta J))
  * spectralGap_pos    :  g > 0 for beta, J > 0
  * corr_tendsto_zero  :  <s0 sn> -> 0 as n -> infinity

Every quantity is computed two ways: (1) by brute-force enumeration of all
2^(n+1) spin configurations, exactly mirroring the Lean definitions, and
(2) by the proven closed forms.  Agreement is the numerical witness of the
theorems.
"""

from __future__ import annotations

import itertools
import math
from typing import Iterator, List, Tuple


# --------------------------------------------------------------------------- #
#  Brute-force layer: a direct transcription of the Lean definitions.         #
# --------------------------------------------------------------------------- #

def sp(b: bool) -> float:
    """Spin value of a Boolean: True -> +1, False -> -1  (Lean `sp`)."""
    return 1.0 if b else -1.0


def all_configs(n: int) -> Iterator[Tuple[bool, ...]]:
    """All 2^(n+1) configurations of a chain with n bonds (n+1 sites)."""
    return itertools.product([False, True], repeat=n + 1)


def weight(beta: float, J: float, n: int, s: Tuple[bool, ...]) -> float:
    """Boltzmann weight of configuration s: product of edge factors (Lean `weight`)."""
    w = 1.0
    for i in range(n):
        w *= math.exp(beta * J * sp(s[i]) * sp(s[i + 1]))
    return w


def Zfree_brute(beta: float, J: float, n: int) -> float:
    """Partition function by enumeration (Lean `Zfree`)."""
    return sum(weight(beta, J, n, s) for s in all_configs(n))


def corrNum_brute(beta: float, J: float, n: int) -> float:
    """Unnormalized signed correlation by enumeration (Lean `corrNum`)."""
    return sum(
        sp(s[0]) * sp(s[n]) * weight(beta, J, n, s) for s in all_configs(n)
    )


def corr_brute(beta: float, J: float, n: int) -> float:
    """Normalized two-point correlation by enumeration (Lean `corr`)."""
    return corrNum_brute(beta, J, n) / Zfree_brute(beta, J, n)


# --------------------------------------------------------------------------- #
#  Closed-form layer: the proven theorems.                                    #
# --------------------------------------------------------------------------- #

def Zfree_closed(beta: float, J: float, n: int) -> float:
    """Zfree_closed:  Z = 2 (2 cosh(beta J))^n."""
    return 2.0 * (2.0 * math.cosh(beta * J)) ** n


def corrNum_closed(beta: float, J: float, n: int) -> float:
    """corrNum_closed:  corrNum = 2 (2 sinh(beta J))^n."""
    return 2.0 * (2.0 * math.sinh(beta * J)) ** n


def corr_closed(beta: float, J: float, n: int) -> float:
    """corr_eq_tanh_pow:  <s0 sn> = (tanh(beta J))^n."""
    return math.tanh(beta * J) ** n


def spectral_gap(beta: float, J: float) -> float:
    """spectralGap:  g = log cosh(beta J) - log sinh(beta J) = log coth(beta J)."""
    bj = beta * J
    return math.log(math.cosh(bj)) - math.log(math.sinh(bj))


def correlation_length(beta: float, J: float) -> float:
    """Correlation length xi = 1 / g."""
    return 1.0 / spectral_gap(beta, J)


def corr_via_gap(beta: float, J: float, n: int) -> float:
    """corr_eq_exp_neg_gap:  <s0 sn> = exp(-g n)."""
    return math.exp(-spectral_gap(beta, J) * n)


# --------------------------------------------------------------------------- #
#  Demonstrations.                                                            #
# --------------------------------------------------------------------------- #

def demo_closed_forms(beta: float, J: float, n_max: int) -> None:
    print(f"\n=== Closed forms vs brute force  (beta={beta}, J={J}) ===")
    print(f"{'n':>3} | {'Z brute':>14} {'Z closed':>14} | "
          f"{'corrNum brute':>14} {'corrNum closed':>14} | {'<s0 sn>':>10}")
    for n in range(n_max + 1):
        zb, zc = Zfree_brute(beta, J, n), Zfree_closed(beta, J, n)
        cb, cc = corrNum_brute(beta, J, n), corrNum_closed(beta, J, n)
        corr = corr_brute(beta, J, n)
        assert math.isclose(zb, zc, rel_tol=1e-9)
        assert math.isclose(cb, cc, rel_tol=1e-9)
        print(f"{n:>3} | {zb:>14.6f} {zc:>14.6f} | "
              f"{cb:>14.6f} {cc:>14.6f} | {corr:>10.6f}")


def demo_tanh_law(beta: float, J: float, n_max: int) -> None:
    print(f"\n=== Headline law  <s0 sn> = (tanh(beta J))^n  (beta={beta}, J={J}) ===")
    t = math.tanh(beta * J)
    print(f"tanh(beta J) = {t:.6f}")
    print(f"{'n':>3} | {'brute':>12} {'(tanh)^n':>12} {'exp(-g n)':>12}")
    for n in range(n_max + 1):
        cb = corr_brute(beta, J, n)
        cc = corr_closed(beta, J, n)
        cg = corr_via_gap(beta, J, n)
        assert math.isclose(cb, cc, rel_tol=1e-9)
        assert math.isclose(cb, cg, rel_tol=1e-9)
        print(f"{n:>3} | {cb:>12.6f} {cc:>12.6f} {cg:>12.6f}")


def demo_gap_and_length(J: float, betas: List[float]) -> None:
    print(f"\n=== Spectral gap and correlation length  (J={J}) ===")
    print(f"{'beta':>6} {'T=1/beta':>10} {'gap g':>12} "
          f"{'xi=1/g':>12} {'low-T ~ 0.5 e^(2bJ)':>22}")
    for beta in betas:
        g = spectral_gap(beta, J)
        xi = correlation_length(beta, J)
        approx = 0.5 * math.exp(2 * beta * J)  # xi ~ 0.5 e^(2 beta J) as beta -> inf
        assert g > 0.0  # spectralGap_pos
        print(f"{beta:>6.2f} {1.0 / beta:>10.4f} {g:>12.6f} "
              f"{xi:>12.6f} {approx:>22.6f}")


def demo_no_long_range_order(beta: float, J: float, ns: List[int]) -> None:
    print(f"\n=== No long-range order:  <s0 sn> -> 0  (beta={beta}, J={J}) ===")
    print(f"{'n':>5} {'<s0 sn> = (tanh)^n':>22}")
    for n in ns:
        print(f"{n:>5} {corr_closed(beta, J, n):>22.3e}")
    print("Correlations decay exponentially to zero: 1D has no order at T > 0.")


def main() -> None:
    print("Exact two-point correlation of the 1D open Ising chain")
    print("=" * 60)
    demo_closed_forms(beta=0.7, J=1.0, n_max=8)
    demo_tanh_law(beta=0.7, J=1.0, n_max=8)
    demo_gap_and_length(J=1.0, betas=[0.25, 0.5, 1.0, 2.0, 4.0])
    demo_no_long_range_order(beta=0.7, J=1.0, ns=[1, 5, 10, 25, 50, 100])
    print("\nAll brute-force values match the closed forms. QED (numerically).")


if __name__ == "__main__":
    main()
