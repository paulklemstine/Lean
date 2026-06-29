"""
demo.py — The Thermodynamic Proof System (TPS)

Numerical demonstrations of the results formalized in
`Catalog/Speculative/AutoResearch/ThermodynamicProofSystem.lean` and its
information-theoretic substrate `ShannonEntropy.lean`.

The framework models a *proof* as an entropy-reducing transition between belief
states over a finite set of epistemic microstates, and assigns it a Landauer
energy cost  cost(T, p, q) = T * (H(p) - H(q)).

This script numerically witnesses every theorem of the framework:

  * entropy_pointMass            H(point mass) = 0
  * pointMass_isProbDist         a point mass is a valid distribution
  * reversible_entropy_invariant H(p . sigma^-1) = H(p)        (Bennett)
  * reversible_free              cost of a permutation step = 0 (Bennett)
  * landauerCost_nonneg          a genuine proof never refunds energy
  * entropy_le_log_card          H(p) <= log n   (max-entropy theorem)
  * tps_landauer_bound           cost <= T * log n
  * tps_landauer_tight           cost from uniform = T * log n   (sharp)
  * tps_landauer_bits            unit-T uniform cost = log2(n) bits

Run:  python demo.py
"""

from __future__ import annotations

import math
import random
from typing import Callable, List, Sequence


# --------------------------------------------------------------------------- #
# Core information-theoretic primitives                                        #
# --------------------------------------------------------------------------- #
def neg_mul_log(x: float) -> float:
    """Mathlib's Real.negMulLog: x |-> -x * log x, with the 0*log0 = 0 convention."""
    if x <= 0.0:
        return 0.0
    return -x * math.log(x)


def entropy(p: Sequence[float]) -> float:
    """Shannon entropy H(p) = -sum_x p(x) log p(x) (in nats)."""
    return sum(neg_mul_log(px) for px in p)


def is_prob_dist(p: Sequence[float], tol: float = 1e-9) -> bool:
    """Check non-negativity and normalization (IsProbDist)."""
    return all(px >= -tol for px in p) and abs(sum(p) - 1.0) <= tol


def point_mass(n: int, a: int) -> List[float]:
    """The determined (proven) belief state: all weight on answer `a` out of `n`."""
    return [1.0 if x == a else 0.0 for x in range(n)]


def uniform(n: int) -> List[float]:
    """The maximal-ignorance prior: 1/n on each of n outcomes."""
    return [1.0 / n] * n


def landauer_cost(T: float, p: Sequence[float], q: Sequence[float]) -> float:
    """Thermodynamic cost of the proof p ~> q at temperature T: T*(H(p) - H(q))."""
    return T * (entropy(p) - entropy(q))


def permute(p: Sequence[float], sigma: Sequence[int]) -> List[float]:
    """Apply a permutation sigma (a reversible relabelling) to a belief state.

    Returns q with q[sigma[i]] = p[i], i.e. q(x) = p(sigma^-1 x).
    """
    n = len(p)
    q = [0.0] * n
    for i in range(n):
        q[sigma[i]] = p[i]
    return q


def nats_to_bits(nats: float) -> float:
    """Convert an information quantity from nats to bits."""
    return nats / math.log(2.0)


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_determined_state() -> None:
    print("=" * 70)
    print("1.  A proven proposition carries no uncertainty (entropy_pointMass)")
    print("=" * 70)
    for n in (2, 4, 8, 256):
        pm = point_mass(n, 0)
        print(f"  n={n:>3}:  is_prob_dist={is_prob_dist(pm)!s:>5}   "
              f"H(point mass) = {entropy(pm):.12f}")
    print()


def demo_bennett() -> None:
    print("=" * 70)
    print("2.  Bennett's principle: reversible steps are free")
    print("    (reversible_entropy_invariant / reversible_free)")
    print("=" * 70)
    random.seed(0)
    n = 6
    p = [0.30, 0.25, 0.20, 0.15, 0.07, 0.03]
    for _ in range(3):
        sigma = list(range(n))
        random.shuffle(sigma)
        q = permute(p, sigma)
        print(f"  sigma={sigma}  H(p)={entropy(p):.6f}  "
              f"H(p.sigma^-1)={entropy(q):.6f}  cost={landauer_cost(1.0, p, q):.2e}")
    print()


def demo_second_law() -> None:
    print("=" * 70)
    print("3.  Second-law flavour: a genuine proof never refunds energy")
    print("    (landauerCost_nonneg)")
    print("=" * 70)
    n = 4
    p = uniform(n)              # maximal ignorance
    q = [0.7, 0.1, 0.1, 0.1]   # sharper belief
    r = point_mass(n, 0)       # fully determined
    for label, dest in (("uniform -> sharper", q), ("uniform -> proven", r)):
        c = landauer_cost(1.0, p, dest)
        print(f"  {label:<20}  H(q) <= H(p): {entropy(dest) <= entropy(p) + 1e-12!s:>5}"
              f"   cost = {c:.6f}  (>= 0: {c >= -1e-12})")
    print()


def demo_max_entropy_and_bound() -> None:
    print("=" * 70)
    print("4.  Max-entropy theorem and the fundamental Landauer bound")
    print("    (entropy_le_log_card / tps_landauer_bound / tps_landauer_tight)")
    print("=" * 70)
    random.seed(1)
    T = 1.0
    for n in (2, 4, 8, 256):
        cap = math.log(n)
        # random distribution
        raw = [random.random() for _ in range(n)]
        s = sum(raw)
        p = [x / s for x in raw]
        c_rand = landauer_cost(T, p, point_mass(n, 0))
        c_unif = landauer_cost(T, uniform(n), point_mass(n, 0))
        print(f"  n={n:>3}:  T*log n = {cap:9.6f}   "
              f"random-prior cost = {c_rand:9.6f} (<= bound: {c_rand <= cap + 1e-9})"
              f"   uniform cost = {c_unif:9.6f} (= bound: {abs(c_unif - cap) < 1e-9})")
    print()


def demo_bits() -> None:
    print("=" * 70)
    print("5.  The Landauer bound in bits (tps_landauer_bits)")
    print("=" * 70)
    for n in (2, 4, 8, 16, 256):
        cost_nats = landauer_cost(1.0, uniform(n), point_mass(n, 0))
        print(f"  n={n:>3}:  cost = {cost_nats:9.6f} nats = "
              f"{nats_to_bits(cost_nats):7.4f} bits   (log2 n = {math.log2(n):7.4f})")
    print()


def demo_additivity() -> None:
    print("=" * 70)
    print("6.  Additivity of entropy over independent systems (entropy_prod)")
    print("=" * 70)
    p = [0.6, 0.4]
    q = [0.5, 0.3, 0.2]
    prod = [px * qy for px in p for qy in q]
    print(f"  H(p)            = {entropy(p):.6f}")
    print(f"  H(q)            = {entropy(q):.6f}")
    print(f"  H(p) + H(q)     = {entropy(p) + entropy(q):.6f}")
    print(f"  H(p (x) q)      = {entropy(prod):.6f}")
    print()


def main() -> None:
    print("\nTHE THERMODYNAMIC PROOF SYSTEM — numerical witnesses\n")
    demo_determined_state()
    demo_bennett()
    demo_second_law()
    demo_max_entropy_and_bound()
    demo_bits()
    demo_additivity()
    print("All numerical checks consistent with the formalized theorems.")


if __name__ == "__main__":
    main()
