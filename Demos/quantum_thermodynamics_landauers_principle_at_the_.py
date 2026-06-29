"""
Numerical demonstrations of the finite-size theory of Landauer's principle.

This module is fully self-contained (standard library only) and reproduces, with
concrete numbers, the central results of the accompanying paper:

  * Shannon entropy of the uniform / erased bit and the entropy loss ln 2.
  * Relative entropy (KL divergence), Gibbs' inequality, and the dual account
    of Landauer's cost as kT * D(erased || uniform).
  * The finite Jarzynski equality, the exact fluctuation-correction identity,
    the average second law DeltaF <= E[W], and the kT ln 2 bound.
  * Saturation of the bound in the reversible (zero-fluctuation) limit.
  * The exponential bound on second-law violations, exp(-xi/(kT)).
  * Extensivity: an n-bit register costs n * kT ln 2, exactly kT ln 2 per bit.
  * The deterministic data-processing inequality and zero-cost reversible maps.

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, Dict, Hashable, List, Sequence, Tuple

# Boltzmann constant in J/K (used for physically scaled numbers).
K_B: float = 1.380649e-23


# --------------------------------------------------------------------------- #
# Core information-theoretic primitives
# --------------------------------------------------------------------------- #
def expect(p: Dict[Hashable, float], f: Callable[[Hashable], float]) -> float:
    """Expectation E_p[f] = sum_omega p(omega) * f(omega)."""
    return sum(prob * f(omega) for omega, prob in p.items())


def is_pmf(p: Dict[Hashable, float], tol: float = 1e-12) -> bool:
    """Check that p is a probability mass function: nonnegative, sums to one."""
    return all(v >= -tol for v in p.values()) and abs(sum(p.values()) - 1.0) < tol


def neg_mul_log(x: float) -> float:
    """negMulLog(x) = -x ln x, with the convention 0 * log 0 = 0."""
    return 0.0 if x <= 0.0 else -x * math.log(x)


def shannon_entropy(p: Dict[Hashable, float]) -> float:
    """Shannon entropy H(p) = sum_omega negMulLog(p(omega))  (in nats)."""
    return sum(neg_mul_log(v) for v in p.values())


def relative_entropy(p: Dict[Hashable, float], q: Dict[Hashable, float]) -> float:
    """KL divergence D(p || q) = sum_omega p(omega) ln (p(omega)/q(omega))."""
    total = 0.0
    for omega, pp in p.items():
        if pp > 0.0:
            total += pp * math.log(pp / q[omega])
    return total


# --------------------------------------------------------------------------- #
# Jarzynski / thermodynamic primitives
# --------------------------------------------------------------------------- #
def jarzynski_lhs(p: Dict[Hashable, float], w: Callable[[Hashable], float],
                  alpha: float) -> float:
    """E_p[exp(-alpha W)] -- the left-hand side of the Jarzynski equality."""
    return expect(p, lambda omega: math.exp(-alpha * w(omega)))


def implied_free_energy(p: Dict[Hashable, float],
                        w: Callable[[Hashable], float], alpha: float) -> float:
    """DeltaF inferred from the Jarzynski equality: -alpha^{-1} ln E[exp(-alpha W)]."""
    return -math.log(jarzynski_lhs(p, w, alpha)) / alpha


def fluctuation_correction(p: Dict[Hashable, float],
                           w: Callable[[Hashable], float], alpha: float) -> float:
    """alpha^{-1} * ln E_p[exp(-alpha (W - E[W]))]  (>= 0 by the second law)."""
    mean_w = expect(p, w)
    factor = expect(p, lambda omega: math.exp(-alpha * (w(omega) - mean_w)))
    return math.log(factor) / alpha


def violation_probability(p: Dict[Hashable, float],
                          w: Callable[[Hashable], float],
                          delta_f: float, xi: float) -> float:
    """Total probability that W < DeltaF - xi (a second-law 'violation')."""
    return sum(prob for omega, prob in p.items() if w(omega) < delta_f - xi)


# --------------------------------------------------------------------------- #
# Distributions and maps used in the examples
# --------------------------------------------------------------------------- #
def uniform_bit() -> Dict[int, float]:
    return {0: 0.5, 1: 0.5}


def erased_bit() -> Dict[int, float]:
    return {0: 1.0, 1: 0.0}


def uniform_register(n: int) -> Dict[Tuple[int, ...], float]:
    """Uniform distribution over the 2^n configurations of an n-bit register."""
    states = _all_bitstrings(n)
    prob = 1.0 / len(states)
    return {s: prob for s in states}


def _all_bitstrings(n: int) -> List[Tuple[int, ...]]:
    out: List[Tuple[int, ...]] = [()]
    for _ in range(n):
        out = [s + (b,) for s in out for b in (0, 1)]
    return out


def pushforward(f: Callable[[Hashable], Hashable],
                p: Dict[Hashable, float]) -> Dict[Hashable, float]:
    """Image (pushforward) distribution (f_* p)(y) = sum_{x : f(x)=y} p(x)."""
    out: Dict[Hashable, float] = {}
    for x, prob in p.items():
        y = f(x)
        out[y] = out.get(y, 0.0) + prob
    return out


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_entropy_loss() -> None:
    print("=" * 70)
    print("1. Entropy of a bit and the entropy loss of erasure")
    print("=" * 70)
    u, e = uniform_bit(), erased_bit()
    print(f"  H(uniform bit) = {shannon_entropy(u):.6f}  (ln 2 = {math.log(2):.6f})")
    print(f"  H(erased bit)  = {shannon_entropy(e):.6f}")
    print(f"  entropy loss   = {shannon_entropy(u) - shannon_entropy(e):.6f}")
    print()


def demo_relative_entropy() -> None:
    print("=" * 70)
    print("2. Relative entropy, Gibbs' inequality, and the dual cost")
    print("=" * 70)
    u, e = uniform_bit(), erased_bit()
    print(f"  D(erased || uniform) = {relative_entropy(e, u):.6f}  (= ln 2)")
    print(f"  D(uniform || uniform) = {relative_entropy(u, u):.6f}  (self = 0)")
    # Gibbs' inequality across a sweep of biased bits.
    worst = min(relative_entropy({0: t, 1: 1 - t}, u)
                for t in [i / 20 for i in range(1, 20)])
    print(f"  min D(p || uniform) over biased bits = {worst:.6f}  (>= 0, Gibbs)")
    print()


def demo_jarzynski_second_law() -> None:
    print("=" * 70)
    print("3. Jarzynski equality, fluctuation correction, and kT ln 2 bound")
    print("=" * 70)
    k, T = K_B, 300.0
    alpha = 1.0 / (k * T)
    delta_f = k * T * math.log(2)  # Landauer free-energy cost of one bit
    # A genuinely fluctuating two-outcome erasure work, constructed so that the
    # Jarzynski equality E[exp(-alpha W)] = exp(-alpha DeltaF) holds exactly.
    p = {0: 0.5, 1: 0.5}
    # Choose W(1) freely; solve W(0) so the Jarzynski equality is satisfied.
    w1 = delta_f * 1.6
    lhs_target = math.exp(-alpha * delta_f)
    w0 = -math.log((lhs_target - 0.5 * math.exp(-alpha * w1)) / 0.5) / alpha
    work = {0: w0, 1: w1}
    w = lambda omega: work[omega]
    mean_w = expect(p, w)
    print(f"  alpha = 1/(kT),  DeltaF = kT ln 2 = {delta_f:.3e} J")
    print(f"  Jarzynski LHS E[exp(-alpha W)] = {jarzynski_lhs(p, w, alpha):.6e}")
    print(f"  Jarzynski RHS exp(-alpha DeltaF) = {lhs_target:.6e}")
    print(f"  mean work E[W]              = {mean_w:.6e} J")
    print(f"  fluctuation correction     = {fluctuation_correction(p, w, alpha):.6e} J (>= 0)")
    print(f"  identity DeltaF + correction = {delta_f + fluctuation_correction(p, w, alpha):.6e} J")
    print(f"  second law DeltaF <= E[W]:  {delta_f:.3e} <= {mean_w:.3e}  -> {delta_f <= mean_w}")
    print()


def demo_saturation() -> None:
    print("=" * 70)
    print("4. Saturation in the reversible (zero-fluctuation) limit")
    print("=" * 70)
    k, T = K_B, 300.0
    alpha = 1.0 / (k * T)
    delta_f = k * T * math.log(2)
    # Reversible erasure: constant work equal to DeltaF on the whole support.
    p = {0: 0.5, 1: 0.5}
    w_rev = lambda omega: delta_f
    print(f"  reversible work W == DeltaF on support:")
    print(f"    E[W] = {expect(p, w_rev):.6e} J,  correction = {fluctuation_correction(p, w_rev, alpha):.2e} J")
    print(f"    saturated: E[W] == kT ln 2  -> {math.isclose(expect(p, w_rev), delta_f)}")
    print()


def demo_violation_bound() -> None:
    print("=" * 70)
    print("5. Exponential bound on second-law violations  exp(-xi/(kT))")
    print("=" * 70)
    k, T = K_B, 300.0
    alpha = 1.0 / (k * T)
    delta_f = k * T * math.log(2)
    # A broad work distribution whose Jarzynski equality holds, with some mass
    # below DeltaF (transient 'violations').
    p = {0: 0.25, 1: 0.5, 2: 0.25}
    base = {0: -0.5 * delta_f, 1: delta_f, 2: 2.5 * delta_f}
    # Renormalise W by a constant shift so the Jarzynski equality holds exactly.
    raw = sum(p[o] * math.exp(-alpha * base[o]) for o in p)
    shift = -math.log(raw / math.exp(-alpha * delta_f)) / alpha
    work = {o: base[o] - shift for o in p}
    w = lambda omega: work[omega]
    print(f"  implied DeltaF = {implied_free_energy(p, w, alpha):.3e} J (target {delta_f:.3e})")
    for xi_units in (0.0, 1.0, 3.0):
        xi = xi_units * k * T
        emp = violation_probability(p, w, delta_f, xi)
        bound = math.exp(-alpha * xi)
        print(f"    xi = {xi_units:.0f} kT:  P[W < DeltaF - xi] = {emp:.4f}  <=  exp(-xi/kT) = {bound:.4f}")
    print()


def demo_extensivity() -> None:
    print("=" * 70)
    print("6. Extensivity: an n-bit register costs n * kT ln 2")
    print("=" * 70)
    k, T = K_B, 300.0
    for n in (1, 2, 4, 8):
        reg = uniform_register(n)
        h = shannon_entropy(reg)
        cost = k * T * h
        print(f"    n = {n}:  H = {h:.4f} nats (n ln 2 = {n * math.log(2):.4f}),"
              f"  cost = {cost:.3e} J,  per bit = {cost / n:.3e} J")
    print(f"  per-bit cost kT ln 2 = {k * T * math.log(2):.3e} J (constant)")
    print()


def demo_data_processing() -> None:
    print("=" * 70)
    print("7. Data-processing inequality and reversible (zero-cost) maps")
    print("=" * 70)
    p = {0: 0.5, 1: 0.5}
    erase = lambda b: 0           # many-to-one: information destroyed
    identity = lambda b: b        # injective: information preserved
    h_in = shannon_entropy(p)
    h_erase = shannon_entropy(pushforward(erase, p))
    h_id = shannon_entropy(pushforward(identity, p))
    print(f"  H(p) = {h_in:.6f}")
    print(f"  erasure : H(f_* p) = {h_erase:.6f}  ->  loss = {h_in - h_erase:.6f}  (= ln 2)")
    print(f"  identity: H(f_* p) = {h_id:.6f}  ->  loss = {h_in - h_id:.6f}  (reversible, 0)")
    print()


def main() -> None:
    print("\nFinite-size Landauer principle: numerical demonstrations\n")
    demo_entropy_loss()
    demo_relative_entropy()
    demo_jarzynski_second_law()
    demo_saturation()
    demo_violation_bound()
    demo_extensivity()
    demo_data_processing()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
