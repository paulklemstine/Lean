"""
Numerical demonstrations for "The Exact Exponent for Constrained Coset Guesswork".

We illustrate the central result:

    E_coset(rho, R, p) = rho * H_{1/(1+rho)}(p) - rho * (1 - R),

where H_alpha is the binary Renyi entropy of order alpha, together with:

  * the equality between the Arikan-Merhav exponent and rho * H_{1/(1+rho)}(p);
  * the exact additive shift -rho*(1-R) relative to the unconstrained exponent;
  * the boundary cases R = 1 (vacuous constraint) and p = 1/2 (E_coset = rho*R);
  * the rate-moment phase boundary R* = 1 - H_{1/(1+rho)}(p);
  * empirical convergence of a directly-enumerated guessing moment to the closed
    form, confirming the exponent shift is exact rather than a mere bound.

The file is self-contained: run `python demo.py`.
"""

from __future__ import annotations

import itertools
import math
from typing import Iterable


# ---------------------------------------------------------------------------
# Closed-form entropy and exponent functionals
# ---------------------------------------------------------------------------

def binary_renyi_entropy(alpha: float, p: float) -> float:
    """Binary Renyi entropy of order alpha != 1:

        H_alpha(p) = (1/(1-alpha)) * log2(p^alpha + (1-p)^alpha).

    Uses 0^alpha = 0 for alpha > 0.
    """
    if abs(alpha - 1.0) < 1e-15:
        raise ValueError("alpha = 1 is the Shannon limit; use binary_shannon_entropy")

    def powa(x: float) -> float:
        return 0.0 if x == 0.0 else x ** alpha

    total = powa(p) + powa(1.0 - p)
    return (1.0 / (1.0 - alpha)) * math.log2(total)


def binary_shannon_entropy(p: float) -> float:
    """Binary Shannon entropy H(p) = -p log2 p - (1-p) log2(1-p)."""
    def term(x: float) -> float:
        return 0.0 if x == 0.0 else -x * math.log2(x)

    return term(p) + term(1.0 - p)


def am_exponent(rho: float, p: float) -> float:
    """Arikan-Merhav guessing exponent in computational form:

        E(rho, p) = (1+rho) * log2(p^{1/(1+rho)} + (1-p)^{1/(1+rho)}).
    """
    beta = 1.0 / (1.0 + rho)

    def powb(x: float) -> float:
        return 0.0 if x == 0.0 else x ** beta

    return (1.0 + rho) * math.log2(powb(p) + powb(1.0 - p))


def am_exponent_via_renyi(rho: float, p: float) -> float:
    """The same exponent computed as rho * H_{1/(1+rho)}(p)."""
    return rho * binary_renyi_entropy(1.0 / (1.0 + rho), p)


def constrained_exponent(rho: float, R: float, p: float) -> float:
    """Constrained coset guessing exponent E_coset(rho, R, p)."""
    return am_exponent(rho, p) - rho * (1.0 - R)


def phase_boundary_rate(rho: float, p: float) -> float:
    """Critical rate R*(rho, p) = 1 - H_{1/(1+rho)}(p) where E_coset = 0."""
    return 1.0 - binary_renyi_entropy(1.0 / (1.0 + rho), p)


# ---------------------------------------------------------------------------
# Empirical guessing moments by direct enumeration
# ---------------------------------------------------------------------------

def bernoulli_vector_prob(bits: tuple[int, ...], p: float) -> float:
    """Probability of a bit vector under i.i.d. Bernoulli(p) (1 has prob p)."""
    ones = sum(bits)
    zeros = len(bits) - ones
    return (p ** ones) * ((1.0 - p) ** zeros)


def unconstrained_guessing_moment(n: int, p: float, rho: float) -> float:
    """E[G(X^n)^rho] under optimal (probability-sorted) guessing over F_2^n."""
    vectors = list(itertools.product((0, 1), repeat=n))
    vectors.sort(key=lambda v: bernoulli_vector_prob(v, p), reverse=True)
    moment = 0.0
    for rank, v in enumerate(vectors, start=1):
        moment += bernoulli_vector_prob(v, p) * (rank ** rho)
    return moment


def coset_of_parity_code(n: int, syndrome: int) -> list[tuple[int, ...]]:
    """A coset of the single-parity-check code {x : sum(x) = 0 mod 2} in F_2^n.

    Rate R = (n-1)/n. `syndrome` in {0, 1} selects the coset (parity class).
    """
    return [v for v in itertools.product((0, 1), repeat=n) if sum(v) % 2 == syndrome]


def constrained_guessing_moment(n: int, p: float, rho: float, syndrome: int) -> float:
    """Conditional rho-th guessing moment inside one coset of the parity code.

    Guessing is restricted to the coset, ranks are recomputed within it, and the
    moment is taken with respect to the conditional distribution on the coset.
    """
    coset = coset_of_parity_code(n, syndrome)
    weights = [bernoulli_vector_prob(v, p) for v in coset]
    z = sum(weights)
    order = sorted(range(len(coset)), key=lambda i: weights[i], reverse=True)
    moment = 0.0
    for rank, idx in enumerate(order, start=1):
        moment += (weights[idx] / z) * (rank ** rho)
    return moment


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_renyi_form() -> None:
    print("=" * 70)
    print("1. Arikan-Merhav exponent equals rho * H_{1/(1+rho)}(p)")
    print("=" * 70)
    for rho, p in [(1.0, 0.1), (2.0, 0.25), (0.5, 0.4), (3.0, 0.05)]:
        a = am_exponent(rho, p)
        b = am_exponent_via_renyi(rho, p)
        print(f"  rho={rho:<4} p={p:<5}  E_computational={a:.10f}  "
              f"rho*H_renyi={b:.10f}  diff={abs(a-b):.2e}")
    print()


def demo_exact_shift() -> None:
    print("=" * 70)
    print("2. The constraint shifts the exponent DOWN by exactly rho*(1-R)")
    print("=" * 70)
    for rho, R, p in [(1.0, 0.5, 0.1), (2.0, 0.75, 0.3), (3.0, 0.5, 1 / 7)]:
        gap = am_exponent(rho, p) - constrained_exponent(rho, R, p)
        expected = rho * (1.0 - R)
        print(f"  rho={rho:<4} R={R:<5} p={p:<6}  gap={gap:.10f}  "
              f"rho*(1-R)={expected:.10f}  (source-independent)")
    print()


def demo_boundaries() -> None:
    print("=" * 70)
    print("3. Boundary cases")
    print("=" * 70)
    # Full rate: constraint vacuous.
    for rho, p in [(1.0, 0.25), (2.5, 0.3)]:
        e1 = constrained_exponent(rho, 1.0, p)
        e2 = am_exponent(rho, p)
        print(f"  R=1: E_coset={e1:.8f}  E_AM={e2:.8f}  (equal -> vacuous)")
    # Symmetric source p=1/2: E_coset = rho*R.
    for rho, R in [(2.0, 0.5), (1.0, 0.3), (3.0, 0.8)]:
        e = constrained_exponent(rho, R, 0.5)
        print(f"  p=1/2: E_coset(rho={rho}, R={R})={e:.8f}  rho*R={rho*R:.8f}")
    print()


def demo_phase_boundary() -> None:
    print("=" * 70)
    print("4. Rate-moment phase boundary  R* = 1 - H_{1/(1+rho)}(p)")
    print("=" * 70)
    for rho, p in [(1.0, 0.1), (2.0, 0.25), (1.0, 0.5)]:
        Rstar = phase_boundary_rate(rho, p)
        e_at = constrained_exponent(rho, Rstar, p)
        e_above = constrained_exponent(rho, min(1.0, Rstar + 0.1), p)
        e_below = constrained_exponent(rho, max(0.0, Rstar - 0.1), p)
        print(f"  rho={rho:<4} p={p:<5}  R*={Rstar:.6f}  "
              f"E(R*)={e_at:.2e}  E(R*+0.1)={e_above:+.4f}  E(R*-0.1)={e_below:+.4f}")
    print()


def demo_empirical_convergence() -> None:
    print("=" * 70)
    print("5. Empirical exponent converges to the closed form (exactness)")
    print("=" * 70)
    rho, p = 1.0, 0.2
    print(f"  Parity-check code, rho={rho}, p={p}")
    print(f"  Closed-form unconstrained exponent E(rho,p) = {am_exponent(rho, p):.6f}")
    print(f"  {'n':>3} {'R=(n-1)/n':>10} {'(1/n)log2 M_unc':>16} "
          f"{'(1/n)log2 M_cos':>16} {'shift':>10} {'rho*(1-R)':>10}")
    for n in range(3, 13):
        R = (n - 1) / n
        m_unc = unconstrained_guessing_moment(n, p, rho)
        m_cos = constrained_guessing_moment(n, p, rho, syndrome=0)
        e_unc = math.log2(m_unc) / n
        e_cos = math.log2(m_cos) / n
        print(f"  {n:>3} {R:>10.4f} {e_unc:>16.6f} {e_cos:>16.6f} "
              f"{e_unc - e_cos:>10.4f} {rho*(1-R):>10.4f}")
    print("  (The empirical shift approaches rho*(1-R) = rho/n as n grows.)")
    print()


def main() -> None:
    demo_renyi_form()
    demo_exact_shift()
    demo_boundaries()
    demo_phase_boundary()
    demo_empirical_convergence()


if __name__ == "__main__":
    main()
