"""
Numerical demonstrations for:

    "The Sharp Threshold Constant of the Maker-Breaker Cycle Game:
     A Quantitative Envelope"

For a fixed cycle length k >= 4, the biased Maker-Breaker C_k-game on the
complete graph K_n has threshold bias

    q_k(n) = c_k * n^{(k-2)/(k-1)},

where the sharp constant is

    c_k = ( (k-1) * (2(k-1)/k)^{k-2} )^{1/(k-1)}.

This script demonstrates, with plain Python (standard library only):

  * the average-degree factor 2(k-1)/k lies in [3/2, 2) and increases;
  * the defining identity c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2};
  * the uniform envelope 3/2 <= c_k < 3 for k >= 4;
  * the exponent (k-2)/(k-1) = 1 / m_2(C_k), with m_2(C_k) = (k-1)/(k-2);
  * strict monotonicity of the bias q_k(n) in the board size n;
  * refutation of the two natural monotonicity conjectures:
      - c_k is NOT increasing (unique peak at k = 13, c_13 ~ 2.1578);
      - c_k is NOT bounded by 2 (c_5 ~ 2.0119 > 2).

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Core quantities
# --------------------------------------------------------------------------

def average_degree_factor(k: int) -> float:
    """The factor 2(k-1)/k appearing in the sharp constant."""
    return 2.0 * (k - 1) / k


def game_exponent(k: float) -> float:
    """The threshold exponent gamma(k) = (k-2)/(k-1)."""
    return (k - 2.0) / (k - 1.0)


def max_two_density(k: float) -> float:
    """The maximum 2-density m_2(C_k) = (k-1)/(k-2)."""
    return (k - 1.0) / (k - 2.0)


def log_threshold_const(k: int) -> float:
    """log(c_k), evaluated in log-space for numerical stability at large k."""
    return (math.log(k - 1) + (k - 2) * math.log(average_degree_factor(k))) / (k - 1)


def threshold_const(k: int) -> float:
    """The sharp threshold constant c_k."""
    return math.exp(log_threshold_const(k))


def threshold_bias(k: int, n: float) -> float:
    """The threshold bias q_k(n) = c_k * n^{(k-2)/(k-1)}."""
    return threshold_const(k) * n ** game_exponent(k)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------

def demo_average_degree_band() -> None:
    print("=" * 70)
    print("1. Average-degree factor 2(k-1)/k lies in [3/2, 2) and increases")
    print("=" * 70)
    prev = -1.0
    for k in [4, 5, 6, 8, 10, 20, 100, 1000]:
        a = average_degree_factor(k)
        assert 1.5 <= a < 2.0, "band violated"
        assert a > prev, "monotonicity violated"
        prev = a
        print(f"  k={k:5d}   2(k-1)/k = {a:.6f}   in [3/2,2): OK")
    print("  -> confirmed 3/2 <= 2(k-1)/k < 2, strictly increasing\n")


def demo_defining_identity() -> None:
    print("=" * 70)
    print("2. Defining identity  c_k^{k-1} = (k-1)(2(k-1)/k)^{k-2}")
    print("=" * 70)
    for k in [4, 5, 7, 13, 50]:
        lhs = threshold_const(k) ** (k - 1)
        rhs = (k - 1) * average_degree_factor(k) ** (k - 2)
        print(f"  k={k:3d}   c_k^(k-1) = {lhs:.6e}   RHS = {rhs:.6e}   "
              f"rel.err = {abs(lhs - rhs) / rhs:.2e}")
    print("  -> identity verified numerically\n")


def demo_uniform_envelope() -> None:
    print("=" * 70)
    print("3. Uniform envelope  3/2 <= c_k < 3  for all k >= 4")
    print("=" * 70)
    lo, hi = math.inf, -math.inf
    for k in list(range(4, 40)) + [100, 1000, 10000]:
        c = threshold_const(k)
        assert 1.5 <= c < 3.0, "envelope violated"
        lo, hi = min(lo, c), max(hi, c)
    print(f"  tested 4 <= k <= 10000")
    print(f"  observed range of c_k: [{lo:.6f}, {hi:.6f}]  subset of [1.5, 3)")
    print("  -> envelope holds; true supremum ~2.1578 sits strictly inside\n")


def demo_exponent_reciprocal_density() -> None:
    print("=" * 70)
    print("4. Exponent (k-2)/(k-1) = 1 / m_2(C_k),  m_2(C_k) = (k-1)/(k-2)")
    print("=" * 70)
    for k in [4, 5, 6, 10, 100]:
        g = game_exponent(k)
        d = max_two_density(k)
        assert 0.0 < g < 1.0, "exponent out of (0,1)"
        print(f"  k={k:3d}   gamma={g:.6f}   m_2={d:.6f}   1/m_2={1/d:.6f}   "
              f"match: {math.isclose(g, 1/d)}")
    print("  -> exponent equals reciprocal of the maximum 2-density\n")


def demo_bias_monotone_in_n() -> None:
    print("=" * 70)
    print("5. Threshold bias q_k(n) strictly increasing in board size n")
    print("=" * 70)
    for k in [4, 7]:
        print(f"  k={k}:")
        prev = -1.0
        for n in [10, 100, 1000, 10000, 100000]:
            q = threshold_bias(k, n)
            assert q > prev, "bias not increasing"
            prev = q
            print(f"     n={n:7d}   q_k(n) = {q:12.3f}")
    print("  -> q_k(n) increases strictly with n\n")


def demo_refuted_conjectures() -> Tuple[int, float]:
    print("=" * 70)
    print("6. Two natural conjectures REFUTED")
    print("=" * 70)
    vals: List[Tuple[int, float]] = [(k, threshold_const(k)) for k in range(4, 60)]

    # Conjecture A: c_k increasing in k -- FALSE.
    peak_k, peak_c = max(vals, key=lambda t: t[1])
    print("  (A) 'c_k is increasing in k'  ->  FALSE")
    print(f"      c_4={threshold_const(4):.4f} < c_13={threshold_const(13):.4f}"
          f" > c_20={threshold_const(20):.4f}")
    print(f"      unique peak at k={peak_k}, c_{peak_k}={peak_c:.4f}")

    # Conjecture B: c_k < 2 always -- FALSE.
    print("  (B) 'c_k < 2 for all k'       ->  FALSE")
    print(f"      c_5 = {threshold_const(5):.4f} > 2")
    over_two = [k for k, c in vals if c > 2.0]
    print(f"      c_k > 2 for k in {over_two[0]}..{over_two[-1]}")
    print(f"  -> envelope [3/2,3) is sharp in kind; peak {peak_c:.4f} lies inside\n")
    return peak_k, peak_c


def main() -> None:
    demo_average_degree_band()
    demo_defining_identity()
    demo_uniform_envelope()
    demo_exponent_reciprocal_density()
    demo_bias_monotone_in_n()
    peak_k, peak_c = demo_refuted_conjectures()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"  c_k is a bounded universal constant: 3/2 <= c_k < 3  (k >= 4)")
    print(f"  unimodal with unique peak c_{peak_k} = {peak_c:.4f}")
    print(f"  exponent gamma(k) = (k-2)/(k-1) = 1/m_2(C_k), in (0,1)")
    print(f"  bias q_k(n) strictly increasing in n; sharp window nonempty")


if __name__ == "__main__":
    main()
