#!/usr/bin/env python3
"""
The Functional-Equation Sign of a Duality Eigensystem
=====================================================

Numerical demonstration of the sign law for duality eigensystems.

A *duality eigensystem* is a triple (Q, alpha, sigma) where

    * Q != 0                       (the half-weight, modelling q^{n/2}),
    * alpha = (a_0, ..., a_{d-1})  (the eigenvalues),
    * sigma  a permutation of {0, ..., d-1}

satisfying

    (Involutivity)  sigma(sigma(i)) = i        for all i,
    (Duality)       a_i * a_{sigma(i)} = Q^2   for all i.

The results demonstrated here:

    1.  Duality sign law:      prod a_i = (-1)^nu * Q^d,
        where nu = #{i : sigma(i) = i and a_i = -Q}.

    2.  Functional equation:   (Q^2 T)^d P(1/(Q^2 T)) = eps * Q^d * P(T),
        where P(T) = prod (1 - a_i T)  and  eps = (-1)^(d + nu).

    3.  Central parity law:    eps = (-1)^{m_+},  m_+ = #{i : a_i = Q}.
        The duality permutation has disappeared from the answer.

    4.  Central factorisation: P(T) = (1 - Q T)^{m_+} G(T),  G(1/Q) != 0,
        so m_+ is exactly the order of vanishing of P at the central point.
        Hence eps = -1  implies  P(1/Q) = 0.

    5.  Structure:             eps^2 = 1; eps is multiplicative under direct
        sums; eps is invariant under the rescaling (Q, a) -> (cQ, ca).

    6.  Analytic bridge:       with e^L = Q and Lambda(s) = e^{(s-1)dL/2} P(e^{-sL}),
        one has Lambda(2 - s) = eps * Lambda(s), and the parity of the order of
        vanishing of Lambda at s = 1 equals eps.

    7.  Sharpness:             a single (-Q) fixed point flips the sign; two of
        them cancel; and a *non-involutive* fixed-point-free 3-cycle breaks the
        conclusion outright (prod a_i = -Q^3).

Run:  python3 demo.py
"""

from __future__ import annotations

import cmath
import math
from dataclasses import dataclass
from typing import Callable, List, Sequence, Tuple

TOL: float = 1e-8


# ----------------------------------------------------------------------------
# The model
# ----------------------------------------------------------------------------


@dataclass(frozen=True)
class DualEigensystem:
    """A duality eigensystem (Q, alpha, sigma) over the complex numbers.

    ``sigma`` is stored as a list with ``sigma[i]`` the image of ``i``.
    """

    Q: complex
    alpha: Tuple[complex, ...]
    sigma: Tuple[int, ...]

    # -- axioms ------------------------------------------------------------

    def check_axioms(self, require_involutive: bool = True) -> None:
        """Raise ValueError unless the duality-eigensystem axioms hold."""
        d = self.deg
        if abs(self.Q) < TOL:
            raise ValueError("Q must be nonzero")
        if sorted(self.sigma) != list(range(d)):
            raise ValueError("sigma must be a permutation")
        for i in range(d):
            if abs(self.alpha[i] * self.alpha[self.sigma[i]] - self.Q ** 2) > TOL:
                raise ValueError(f"duality fails at index {i}")
        if require_involutive:
            for i in range(d):
                if self.sigma[self.sigma[i]] != i:
                    raise ValueError(f"sigma is not an involution at index {i}")

    @property
    def is_involutive(self) -> bool:
        return all(self.sigma[self.sigma[i]] == i for i in range(self.deg))

    # -- basic invariants --------------------------------------------------

    @property
    def deg(self) -> int:
        """The degree d = number of eigenvalues (the Betti number)."""
        return len(self.alpha)

    @property
    def neg_fixed(self) -> List[int]:
        """Indices fixed by duality whose eigenvalue is -Q."""
        return [
            i
            for i in range(self.deg)
            if self.sigma[i] == i and abs(self.alpha[i] + self.Q) < TOL
        ]

    @property
    def nu(self) -> int:
        """nu = number of anti-diagonal (-Q) fixed points."""
        return len(self.neg_fixed)

    @property
    def central_order(self) -> int:
        """m_+ = multiplicity of the central eigenvalue +Q."""
        return sum(1 for a in self.alpha if abs(a - self.Q) < TOL)

    @property
    def prod_alpha(self) -> complex:
        p: complex = 1.0 + 0j
        for a in self.alpha:
            p *= a
        return p

    # -- the sign ----------------------------------------------------------

    @property
    def root_sign(self) -> complex:
        """eps = (-1)^d * prod(alpha) / Q^d  (Definition of the root sign)."""
        return (-1.0) ** self.deg * self.prod_alpha / self.Q ** self.deg

    def root_sign_from_fixed_points(self) -> int:
        """eps computed combinatorially as (-1)^(d + nu)."""
        return (-1) ** ((self.deg + self.nu) % 2)

    def root_sign_from_central_order(self) -> int:
        """eps computed intrinsically as (-1)^{m_+}: no knowledge of sigma."""
        return (-1) ** (self.central_order % 2)

    # -- polynomials -------------------------------------------------------

    def char_poly(self, T: complex) -> complex:
        """P(T) = prod (1 - a_i T)."""
        p: complex = 1.0 + 0j
        for a in self.alpha:
            p *= 1 - a * T
        return p

    def central_factor(self, T: complex) -> complex:
        """G(T) = prod over {a_i != Q} of (1 - a_i T)."""
        p: complex = 1.0 + 0j
        for a in self.alpha:
            if abs(a - self.Q) >= TOL:
                p *= 1 - a * T
        return p

    # -- analytic bridge ---------------------------------------------------

    def completed_L(self, s: complex, L: complex | None = None) -> complex:
        """Lambda(s) = e^{(s-1) d L / 2} * P(e^{-sL}),  with e^L = Q."""
        if L is None:
            L = cmath.log(self.Q)
        return cmath.exp((s - 1) * self.deg / 2 * L) * self.char_poly(cmath.exp(-s * L))


# ----------------------------------------------------------------------------
# Constructors: the standard families and the sharpness witnesses
# ----------------------------------------------------------------------------


def pos_fixed(Q: complex) -> DualEigensystem:
    """Degree 1, the +Q fixed point.  eps = -1 = (-1)^1."""
    return DualEigensystem(Q=Q, alpha=(Q,), sigma=(0,))


def neg_fixed_one(Q: complex) -> DualEigensystem:
    """Degree 1, the -Q fixed point.  eps = +1 != (-1)^1: the sign flip."""
    return DualEigensystem(Q=Q, alpha=(-Q,), sigma=(0,))


def duality_pair(Q: complex, a: complex) -> DualEigensystem:
    """Degree 2, a single free duality 2-cycle {a, Q^2/a}.  Sign-neutral."""
    return DualEigensystem(Q=Q, alpha=(a, Q ** 2 / a), sigma=(1, 0))


def two_neg_fixed(Q: complex) -> DualEigensystem:
    """Degree 2, two -Q fixed points.  Hypothesis fails, conclusion holds."""
    return DualEigensystem(Q=Q, alpha=(-Q, -Q), sigma=(0, 1))


def two_pairs(Q: complex, a: complex, b: complex) -> DualEigensystem:
    """Degree 4, two duality 2-cycles.  eps = +1 = (-1)^4."""
    return DualEigensystem(
        Q=Q, alpha=(a, Q ** 2 / a, b, Q ** 2 / b), sigma=(1, 0, 3, 2)
    )


def mixed_deg4(Q: complex, a: complex) -> DualEigensystem:
    """Degree 4: (+Q, -Q, a, Q^2/a).  eps = -1 != (-1)^4."""
    return DualEigensystem(Q=Q, alpha=(Q, -Q, a, Q ** 2 / a), sigma=(0, 1, 3, 2))


def three_cycle(Q: complex) -> DualEigensystem:
    """NOT an involution: sigma is the 3-cycle, alpha = (-Q, -Q, -Q).

    Duality holds, sigma has no fixed point at all, yet prod alpha = -Q^3.
    """
    return DualEigensystem(Q=Q, alpha=(-Q, -Q, -Q), sigma=(1, 2, 0))


def direct_sum(E: DualEigensystem, F: DualEigensystem) -> DualEigensystem:
    """Concatenate two eigensystems of the same half-weight Q."""
    if abs(E.Q - F.Q) > TOL:
        raise ValueError("direct sums require equal half-weight Q")
    d = E.deg
    return DualEigensystem(
        Q=E.Q,
        alpha=E.alpha + F.alpha,
        sigma=E.sigma + tuple(d + j for j in F.sigma),
    )


def twist(E: DualEigensystem, c: complex) -> DualEigensystem:
    """(Q, alpha) -> (cQ, c*alpha): the model's Tate twist."""
    if abs(c) < TOL:
        raise ValueError("twist scalar must be nonzero")
    return DualEigensystem(
        Q=c * E.Q, alpha=tuple(c * a for a in E.alpha), sigma=E.sigma
    )


# ----------------------------------------------------------------------------
# Numerical utilities
# ----------------------------------------------------------------------------


def numerical_order_of_vanishing(
    f: Callable[[complex], complex],
    center: complex,
    max_order: int = 8,
    radius: float = 0.35,
    n_nodes: int = 512,
) -> int:
    """Order of vanishing of an analytic ``f`` at ``center``.

    Computes Taylor coefficients c_k by the Cauchy integral
    c_k = (1/2 pi i) * int f(z) / (z - center)^{k+1} dz, discretised on a
    circle of the given radius via the trapezoidal rule (spectrally accurate
    for analytic integrands), and returns the least k with |c_k| above a
    relative threshold.
    """
    scale = max(
        abs(f(center + radius * cmath.exp(2j * math.pi * t / n_nodes)))
        for t in range(n_nodes)
    )
    threshold = max(scale, 1.0) * 1e-7
    for k in range(max_order + 1):
        acc = 0.0 + 0j
        for t in range(n_nodes):
            theta = 2 * math.pi * t / n_nodes
            z = center + radius * cmath.exp(1j * theta)
            acc += f(z) * cmath.exp(-1j * k * theta)
        c_k = acc / (n_nodes * radius ** k)
        if abs(c_k) > threshold:
            return k
    return max_order + 1


def close(x: complex, y: complex, tol: float = 1e-6) -> bool:
    return abs(x - y) <= tol * max(1.0, abs(x), abs(y))


def fmt(z: complex) -> str:
    if abs(z.imag) < 1e-9:
        return f"{z.real:+.6f}"
    return f"{z.real:+.6f}{z.imag:+.6f}i"


def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------


def demo_sign_law(systems: Sequence[Tuple[str, DualEigensystem]]) -> None:
    banner("1.  THE DUALITY SIGN LAW      prod a_i = (-1)^nu * Q^d")
    print(f"{'system':26s} {'d':>2s} {'nu':>3s} {'m+':>3s} "
          f"{'prod alpha':>22s} {'(-1)^nu Q^d':>22s}")
    print("-" * 78)
    for name, E in systems:
        E.check_axioms(require_involutive=E.is_involutive)
        predicted = (-1) ** E.nu * E.Q ** E.deg
        ok = close(E.prod_alpha, predicted)
        mark = "OK " if ok or not E.is_involutive else "!! "
        if not E.is_involutive:
            mark = "n/a"  # the law needs involutivity
        print(f"{name:26s} {E.deg:2d} {E.nu:3d} {E.central_order:3d} "
              f"{fmt(E.prod_alpha):>22s} {fmt(predicted):>22s}  {mark}")
    print()
    print("  'n/a' marks the non-involutive 3-cycle, where the law legitimately")
    print("  fails: involutivity is exactly what the pairing argument consumes.")


def demo_functional_equation(systems: Sequence[Tuple[str, DualEigensystem]]) -> None:
    banner("2.  THE FUNCTIONAL EQUATION   (Q^2 T)^d P(1/(Q^2 T)) = eps Q^d P(T)")
    test_points = [0.37 + 0.21j, -1.4 + 0.9j, 2.1 - 0.6j]
    print(f"{'system':26s} {'eps (def)':>12s} {'(-1)^(d+nu)':>13s} "
          f"{'(-1)^m+':>9s} {'max FE error':>14s}")
    print("-" * 78)
    for name, E in systems:
        worst = 0.0
        for T in test_points:
            lhs = (E.Q ** 2 * T) ** E.deg * E.char_poly(1 / (E.Q ** 2 * T))
            rhs = E.root_sign * E.Q ** E.deg * E.char_poly(T)
            worst = max(worst, abs(lhs - rhs) / max(1.0, abs(rhs)))
        combi = E.root_sign_from_fixed_points() if E.is_involutive else 0
        combi_s = f"{combi:+d}" if E.is_involutive else "  n/a"
        central = E.root_sign_from_central_order() if E.is_involutive else 0
        central_s = f"{central:+d}" if E.is_involutive else "  n/a"
        print(f"{name:26s} {fmt(E.root_sign):>12s} {combi_s:>13s} "
              f"{central_s:>9s} {worst:14.3e}")
    print()
    print("  The functional equation holds for EVERY system (it needs only that")
    print("  sigma is a bijection).  The three sign columns agree exactly when")
    print("  sigma is an involution -- that is the content of the sign law and")
    print("  of the central parity law.")


def demo_central_parity(systems: Sequence[Tuple[str, DualEigensystem]]) -> None:
    banner("3.  CENTRAL PARITY   eps = (-1)^{m+},   P(T) = (1-QT)^{m+} G(T)")
    print(f"{'system':26s} {'m+':>3s} {'P(1/Q)':>14s} {'G(1/Q)':>16s} "
          f"{'eps':>6s}")
    print("-" * 78)
    for name, E in systems:
        if not E.is_involutive:
            continue
        Pc = E.char_poly(1 / E.Q)
        Gc = E.central_factor(1 / E.Q)
        # verify the factorisation at a random point
        T = 0.83 - 0.41j
        lhs = E.char_poly(T)
        rhs = (1 - E.Q * T) ** E.central_order * E.central_factor(T)
        assert close(lhs, rhs), "central factorisation failed"
        print(f"{name:26s} {E.central_order:3d} {fmt(Pc):>14s} {fmt(Gc):>16s} "
              f"{E.root_sign_from_central_order():+6d}")
    print()
    print("  G(1/Q) is never zero, so m+ is EXACTLY the order of vanishing of P")
    print("  at the central point T = 1/Q.  Whenever eps = -1 the multiplicity m+")
    print("  is odd, hence positive, hence P(1/Q) = 0: sign -1 forces central")
    print("  vanishing.")


def demo_structure(Q: complex) -> None:
    banner("4.  STRUCTURE   eps^2 = 1,  multiplicativity,  twist invariance")
    A = pos_fixed(Q)                       # d = 1, eps = -1
    B = duality_pair(Q, 1.7 - 0.9j)        # d = 2, eps = +1
    C = neg_fixed_one(Q)                   # d = 1, eps = +1
    print("  eps^2 = 1 for every system:")
    for name, E in [("pos_fixed", A), ("duality_pair", B), ("neg_fixed", C)]:
        print(f"    {name:16s} eps = {fmt(E.root_sign)}   "
              f"eps^2 = {fmt(E.root_sign ** 2)}")
    print()
    print("  Multiplicativity under direct sums,  eps(E + F) = eps(E) eps(F):")
    for (n1, E), (n2, F) in [(("A", A), ("B", B)),
                             (("A", A), ("C", C)),
                             (("B", B), ("C", C))]:
        S = direct_sum(E, F)
        S.check_axioms()
        print(f"    eps({n1}+{n2}) = {fmt(S.root_sign)}   "
              f"eps({n1})eps({n2}) = {fmt(E.root_sign * F.root_sign)}   "
              f"deg {S.deg} = {E.deg}+{F.deg}   "
              f"m+ {S.central_order} = {E.central_order}+{F.central_order}")
    print()
    print("  Twist invariance,  (Q, a) -> (cQ, ca):")
    for c in [2.0 + 0j, -1.0 + 0j, 0.3 + 1.1j]:
        Bt = twist(B, c)
        Bt.check_axioms()
        At = twist(A, c)
        At.check_axioms()
        print(f"    c = {fmt(c):>18s}   eps(A^c) = {fmt(At.root_sign)}   "
              f"eps(B^c) = {fmt(Bt.root_sign)}")


def demo_odd_degree(Q: complex) -> None:
    banner("5.  ODD DEGREE FORCES CENTRAL VANISHING")
    # d = 3: one +Q fixed point plus one duality pair; no -Q fixed point.
    E = DualEigensystem(
        Q=Q, alpha=(Q, 2.3 + 1.1j, Q ** 2 / (2.3 + 1.1j)), sigma=(0, 2, 1)
    )
    E.check_axioms()
    print(f"    degree d              = {E.deg}  (odd)")
    print(f"    a -Q fixed point?     = {'yes' if E.nu else 'no'}")
    print(f"    a fixed point exists? = "
          f"{'yes' if any(E.sigma[i] == i for i in range(E.deg)) else 'no'}")
    print(f"    central multiplicity  = {E.central_order}  (odd)")
    print(f"    root sign eps         = {fmt(E.root_sign)}  = (-1)^d")
    print(f"    P(1/Q)                = {fmt(E.char_poly(1 / E.Q))}")
    print()
    print("  An involution of an odd-sized set must have a fixed point; with no")
    print("  -Q fixed point allowed, that fixed point carries +Q, so m+ is odd,")
    print("  eps = -1, and the characteristic polynomial vanishes at the centre.")


def demo_analytic_bridge(systems: Sequence[Tuple[str, DualEigensystem]]) -> None:
    banner("6.  ANALYTIC BRIDGE   Lambda(2-s) = eps Lambda(s),  "
           "(-1)^ord = eps = (-1)^{m+}")
    print(f"{'system':26s} {'max FE error':>14s} {'ord_{s=1}':>10s} "
          f"{'(-1)^ord':>9s} {'eps':>6s}")
    print("-" * 78)
    for name, E in systems:
        if not E.is_involutive:
            continue
        L = cmath.log(E.Q)
        worst = 0.0
        for s in [0.4 + 0.3j, 1.9 - 0.7j, 2.6 + 1.2j, 1.0 + 0j]:
            lhs = E.completed_L(2 - s, L)
            rhs = E.root_sign * E.completed_L(s, L)
            worst = max(worst, abs(lhs - rhs) / max(1.0, abs(rhs)))
        r = numerical_order_of_vanishing(lambda s: E.completed_L(s, L), 1.0 + 0j)
        print(f"{name:26s} {worst:14.3e} {r:10d} {(-1) ** r:+9d} "
              f"{E.root_sign_from_central_order():+6d}")
    print()
    print("  The order of vanishing is measured numerically, by Cauchy integrals")
    print("  for the Taylor coefficients of the entire function Lambda around")
    print("  s = 1.  Its parity always reproduces the combinatorial sign, and in")
    print("  every case here it equals m+ on the nose.")


def demo_sharpness(Q: complex) -> None:
    banner("7.  SHARPNESS: EVERY HYPOTHESIS IS LOAD-BEARING")

    print("  (a)  A single -Q fixed point flips the sign (degree 1):")
    for name, E in [("alpha = +Q", pos_fixed(Q)), ("alpha = -Q", neg_fixed_one(Q))]:
        print(f"       {name:12s} prod alpha = {fmt(E.prod_alpha):>14s}   "
              f"Q^d = {fmt(Q ** E.deg):>14s}   eps = {fmt(E.root_sign)}   "
              f"(-1)^d = {(-1) ** E.deg:+d}")
    print()

    print("  (b)  Two -Q fixed points cancel: hypothesis FAILS, conclusion HOLDS.")
    E = two_neg_fixed(Q)
    print(f"       nu = {E.nu} (even)   prod alpha = {fmt(E.prod_alpha)}   "
          f"Q^2 = {fmt(Q ** 2)}   eps = {fmt(E.root_sign)}")
    print()

    print("  (c)  Two-cycles are sign-neutral, whatever the eigenvalue:")
    for a in [1.0 + 0j, 5.5 - 3.2j, 0.04 + 0.01j]:
        E = duality_pair(Q, a)
        print(f"       a = {fmt(a):>20s}   prod alpha = {fmt(E.prod_alpha):>14s}"
              f"   eps = {fmt(E.root_sign)}")
    print()

    print("  (d)  Degree 4: the sign is not a function of the degree alone.")
    for name, E in [("two pairs", two_pairs(Q, 1.3 + 0.4j, -2.2 + 0.7j)),
                    ("(+Q, -Q, a, Q^2/a)", mixed_deg4(Q, 1.9 - 0.5j))]:
        print(f"       {name:20s} prod alpha = {fmt(E.prod_alpha):>16s}   "
              f"eps = {fmt(E.root_sign)}   (-1)^d = {(-1) ** E.deg:+d}")
    print()

    print("  (e)  Involutivity cannot be weakened to bijectivity.")
    E = three_cycle(Q)
    E.check_axioms(require_involutive=False)
    print(f"       sigma = 3-cycle; fixed points: "
          f"{[i for i in range(3) if E.sigma[i] == i]} (none!)")
    print(f"       duality holds at every index, but sigma o sigma != id.")
    print(f"       prod alpha = {fmt(E.prod_alpha)}   "
          f"-Q^3 = {fmt(-Q ** 3)}   Q^3 = {fmt(Q ** 3)}")
    print(f"       eps = {fmt(E.root_sign)}, i.e. (-1)^(d+1), not (-1)^d.")
    print()
    print("       Reason: chasing a_i a_{sigma(i)} = Q^2 around a 3-cycle forces")
    print("       a_0 = a_2 and then a_0^2 = Q^2, so the cycle is constant +-Q.")


def demo_random_stress_test(n_trials: int = 400, seed: int = 20260823) -> None:
    banner("8.  RANDOMISED STRESS TEST OF THE THREE SIGN FORMULAS")
    import random

    rng = random.Random(seed)
    failures = 0
    for _ in range(n_trials):
        Q = complex(rng.uniform(0.4, 3.0), rng.uniform(-2.0, 2.0))
        if abs(Q) < 0.3:
            continue
        n_pairs = rng.randint(0, 3)
        n_pos = rng.randint(0, 3)
        n_neg = rng.randint(0, 3)
        alpha: List[complex] = []
        sigma: List[int] = []
        for _ in range(n_pairs):
            a = complex(rng.uniform(-3, 3), rng.uniform(-3, 3))
            if abs(a) < 0.2:
                a = 0.5 + 0.5j
            k = len(alpha)
            alpha += [a, Q ** 2 / a]
            sigma += [k + 1, k]
        for _ in range(n_pos):
            k = len(alpha)
            alpha.append(Q)
            sigma.append(k)
        for _ in range(n_neg):
            k = len(alpha)
            alpha.append(-Q)
            sigma.append(k)
        if not alpha:
            continue
        E = DualEigensystem(Q=Q, alpha=tuple(alpha), sigma=tuple(sigma))
        E.check_axioms()
        eps = E.root_sign
        s1 = E.root_sign_from_fixed_points()
        s2 = E.root_sign_from_central_order()
        T = complex(rng.uniform(0.3, 2.0), rng.uniform(0.3, 2.0))
        lhs = (Q ** 2 * T) ** E.deg * E.char_poly(1 / (Q ** 2 * T))
        rhs = eps * Q ** E.deg * E.char_poly(T)
        ok = (close(eps, s1) and close(eps, s2)
              and abs(lhs - rhs) <= 1e-5 * max(1.0, abs(rhs)))
        if not ok:
            failures += 1
            print(f"    FAILURE: Q={Q}, alpha={alpha}, sigma={sigma}")
    print(f"    {n_trials} random duality eigensystems tested "
          f"(degrees 1-12, random complex Q).")
    print(f"    Formulas checked:  eps (definition)  ==  (-1)^(d+nu)  "
          f"==  (-1)^{{m+}},")
    print(f"    plus the functional equation at a random point.")
    print(f"    Failures: {failures}")


def main() -> None:
    Q: complex = 1.6 + 0.7j  # nothing requires Q real or positive

    systems: List[Tuple[str, DualEigensystem]] = [
        ("d=1, +Q fixed point", pos_fixed(Q)),
        ("d=1, -Q fixed point", neg_fixed_one(Q)),
        ("d=2, duality pair", duality_pair(Q, 1.7 - 0.9j)),
        ("d=2, two -Q fixed", two_neg_fixed(Q)),
        ("d=4, two pairs", two_pairs(Q, 1.3 + 0.4j, -2.2 + 0.7j)),
        ("d=4, (+Q,-Q,a,Q^2/a)", mixed_deg4(Q, 1.9 - 0.5j)),
        ("d=3, 3-cycle (NOT inv.)", three_cycle(Q)),
    ]

    print(__doc__.split("Run:")[0].rstrip())
    print(f"\nHalf-weight used throughout:  Q = {fmt(Q)}")

    demo_sign_law(systems)
    demo_functional_equation(systems)
    demo_central_parity(systems)
    demo_structure(Q)
    demo_odd_degree(Q)
    demo_analytic_bridge(systems)
    demo_sharpness(Q)
    demo_random_stress_test()

    banner("SUMMARY")
    print("""
    prod a_i    = (-1)^nu Q^d                       (duality sign law)
    eps         = (-1)^(d + nu) = (-1)^{m+}          (central parity law)
    P(T)        = (1 - QT)^{m+} G(T),  G(1/Q) != 0   (exact central order)
    eps = -1    ==>  P(1/Q) = 0                      (central vanishing)
    Lambda(2-s) = eps Lambda(s),  (-1)^ord = eps     (analytic bridge)

    All the sign information in a duality-symmetric spectrum is concentrated
    in the two real points +-Q of the Weil circle -- and there, only in a
    parity.
    """)


if __name__ == "__main__":
    main()
