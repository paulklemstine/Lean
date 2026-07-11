"""
Theorems as Phase Transitions in Proof Space -- numerical demonstrations.

This self-contained script illustrates the main results of the paper:

  1. Combinatorics of proof space: the exact count S(k, n) of statements of
     length <= n, its geometric closed form (k-1)*S = k^(n+1) - 1, and the
     sandwich k^n <= S(k, n) <= k^(n+1).
  2. The order parameter r(n) = prov(n) / tot(n) and asymptotic incompleteness:
     when provable statements grow with base a < k, r(n) -> 0.
  3. The logistic sharp-transition profile: critical value 1/2, strict
     monotonicity, and convergence to a Heaviside step as sharpness beta -> oo.
  4. The dimension of proof space, log(tot n)/n -> log k, and the geometric
     length distribution p(n) = (k-1)/k^(n+1), which sums to 1 with power-law
     tail k^(-n).

Run:  python demo.py
Requires only the Python standard library.
"""

from __future__ import annotations

import math
from typing import Callable, List


# ---------------------------------------------------------------------------
# 1. Combinatorics of proof space
# ---------------------------------------------------------------------------

def statements(k: int, n: int) -> int:
    """Number of statements of length exactly n over a k-symbol alphabet."""
    return k ** n


def S(k: int, n: int) -> int:
    """Number of statements of length <= n, i.e. sum_{i=0}^{n} k^i."""
    return sum(k ** i for i in range(n + 1))


def demo_counting(k: int = 3, n_max: int = 8) -> None:
    print(f"\n[1] Combinatorics of proof space (alphabet size k = {k})")
    print(f"    {'n':>3} {'S(k,n)':>12} {'(k-1)S':>14} {'k^(n+1)-1':>14} "
          f"{'k^n<=S':>7} {'S<=k^(n+1)':>11}")
    for n in range(n_max + 1):
        s = S(k, n)
        closed = (k - 1) * s
        target = k ** (n + 1) - 1
        lower_ok = k ** n <= s
        upper_ok = s <= k ** (n + 1)
        print(f"    {n:>3} {s:>12} {closed:>14} {target:>14} "
              f"{str(lower_ok):>7} {str(upper_ok):>11}")
    print("    -> geometric closed form and sandwich bounds confirmed.")


# ---------------------------------------------------------------------------
# 2. Order parameter and asymptotic incompleteness
# ---------------------------------------------------------------------------

def order_parameter(prov: Callable[[int], float],
                    tot: Callable[[int], float], n: int) -> float:
    """Fraction of length-<= n statements that are provable."""
    return prov(n) / tot(n)


def demo_order_parameter(k: float = 3.0, a: float = 2.0, C: float = 1.0,
                         n_max: int = 30) -> None:
    print(f"\n[2] Order parameter r(n) = prov/tot  (k = {k}, provable base a = {a})")
    tot = lambda n: float(k) ** n          # tot(n) >= k^n
    prov = lambda n: C * (float(a) ** n)    # prov(n) <= C a^n
    print(f"    {'n':>3} {'r(n)':>14} {'bound C(a/k)^n':>16}")
    for n in [0, 5, 10, 15, 20, 25, 30]:
        r = order_parameter(prov, tot, n)
        bound = C * (a / k) ** n
        print(f"    {n:>3} {r:>14.6e} {bound:>16.6e}")
    print(f"    -> r(n) -> 0 since a/k = {a / k:.3f} < 1 (disordered phase).")


# ---------------------------------------------------------------------------
# 3. Logistic sharp-transition profile
# ---------------------------------------------------------------------------

def logistic(beta: float, x_c: float, x: float) -> float:
    """Logistic order-parameter profile with sharpness beta, critical length x_c."""
    return 1.0 / (1.0 + math.exp(-(beta * (x - x_c))))


def demo_phase_transition(x_c: float = 10.0) -> None:
    print(f"\n[3] Logistic transition profile (critical length x_c = {x_c})")
    xs = [x_c - 2, x_c - 0.5, x_c, x_c + 0.5, x_c + 2]
    betas = [0.5, 2.0, 8.0, 50.0]
    header = "    " + f"{'x':>7}" + "".join(f"{'b=' + str(b):>12}" for b in betas)
    print(header)
    for x in xs:
        row = "    " + f"{x:>7.2f}"
        for b in betas:
            row += f"{logistic(b, x_c, x):>12.6f}"
        print(row)
    print(f"    -> value at x_c is exactly 0.5 for every beta;")
    print(f"       as beta grows the profile approaches a Heaviside step.")


# ---------------------------------------------------------------------------
# 4. Dimension and length distribution
# ---------------------------------------------------------------------------

def growth_rate(tot: Callable[[int], float], n: int) -> float:
    """log(tot n)/n, whose limit is the dimension of proof space."""
    return math.log(tot(n)) / n


def length_dist(k: float, n: int) -> float:
    """Length distribution weight p(n) = (k-1)/k^(n+1)."""
    return (k - 1.0) / (k ** (n + 1))


def demo_dimension(k: float = 3.0, n_max: int = 40) -> None:
    print(f"\n[4] Dimension and length distribution (k = {k}, log k = {math.log(k):.6f})")
    tot = lambda n: float(k) ** n
    print(f"    {'n':>4} {'log(tot n)/n':>16} {'log k':>12}")
    for n in [1, 5, 10, 20, 40]:
        print(f"    {n:>4} {growth_rate(tot, n):>16.8f} {math.log(k):>12.8f}")
    partial = sum(length_dist(k, n) for n in range(n_max + 1))
    print(f"    partial sum of p(n), n=0..{n_max}: {partial:.10f}  (-> 1)")
    print(f"    tail p(n) ~ k^(-n): p(0)={length_dist(k,0):.4f}, "
          f"p(5)={length_dist(k,5):.6f}, p(10)={length_dist(k,10):.8f}")


# ---------------------------------------------------------------------------
# 5. Abstract Godel incompleteness (finite Boolean witness)
# ---------------------------------------------------------------------------

def demo_incompleteness() -> None:
    """The non-vacuity witness: sentences = {True, False}, nothing provable,
    negation = not, truth(b) = b. Then G = True is a Godel sentence."""
    print("\n[5] Abstract Godel incompleteness -- finite witness")
    sentences: List[bool] = [True, False]
    provable = lambda s: False           # nothing is provable
    truth = lambda s: s is True          # each sentence is its own truth value
    neg = lambda s: not s
    sound = all((not provable(s)) or truth(s) for s in sentences)
    neg_true = all(truth(neg(s)) == (not truth(s)) for s in sentences)
    consistent = all(not (provable(s) and provable(neg(s))) for s in sentences)
    G = True
    godel = (truth(G) == (not provable(G)))
    print(f"    sound = {sound}, negation-respects-truth = {neg_true}, "
          f"consistent = {consistent}")
    print(f"    G = True is a Godel sentence: {godel}")
    print(f"    -> G is true ({truth(G)}), unprovable ({not provable(G)}), "
          f"and its negation is unprovable ({not provable(neg(G))}).")


# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Theorems as Phase Transitions in Proof Space -- demonstrations")
    print("=" * 70)
    demo_counting()
    demo_order_parameter()
    demo_phase_transition()
    demo_dimension()
    demo_incompleteness()
    print("\nAll demonstrations complete.")


if __name__ == "__main__":
    main()
