"""
The Differential Calculus of Combinatorial Species — numerical demonstrations.

This self-contained script illustrates, with exact rational arithmetic, the
exponential-generating-function (EGF) dictionary for combinatorial species:

    EGF(F)        = sum_n  f_n / n!  X^n          (f_n = number of structures of size n)

and the operations it intertwines:

    sum         F + G          <->  EGF(F) + EGF(G)
    product     F . G          <->  EGF(F) * EGF(G)        (binomial convolution)
    derivative  F'[n] = F[n+1] <->  d/dX EGF(F)            (shift the counting sequence)
    pointing    F*[n] = n.F[n] <->  X d/dX EGF(F)          (Euler operator)

Two canonical species are used throughout:
    E (sets)          f_n = 1     EGF = e^X
    L (linear orders) f_n = n!    EGF = 1/(1-X)

All arithmetic is exact (fractions.Fraction), so every printed identity is an
exact equality, mirroring the formally verified theorems.
"""

from __future__ import annotations

from fractions import Fraction
from math import comb, factorial
from typing import Callable, List

Seq = List[Fraction]  # a finite prefix of a counting sequence, as rationals


# ---------------------------------------------------------------------------
# Core transforms
# ---------------------------------------------------------------------------

def egf_coeffs(a: Seq) -> Seq:
    """EGF coefficients c_n = a_n / n!  (Definition 2.1)."""
    return [a[n] / factorial(n) for n in range(len(a))]


def egf_inverse(c: Seq) -> Seq:
    """Recover the counting sequence a_n = c_n * n! from EGF coefficients.

    Injectivity (Theorem 4.1): this is a genuine two-sided inverse, so the EGF
    loses no enumerative information.
    """
    return [c[n] * factorial(n) for n in range(len(c))]


def bin_conv(a: Seq, b: Seq) -> Seq:
    """Binomial (exponential) convolution (a * b)_n = sum_{i+j=n} C(n,i) a_i b_j.

    This is the counting sequence of the species product (Theorem 3.2 / 3.8).
    """
    n_max = min(len(a), len(b))
    return [
        sum(Fraction(comb(n, i)) * a[i] * b[n - i] for i in range(n + 1))
        for n in range(n_max)
    ]


def cauchy_mul(p: Seq, q: Seq) -> Seq:
    """Ordinary (Cauchy) product of two power-series coefficient prefixes."""
    n_max = min(len(p), len(q))
    return [sum(p[i] * q[n - i] for i in range(n + 1)) for n in range(n_max)]


def derivative(c: Seq) -> Seq:
    """Formal derivative on power-series coefficients: c_n -> (n+1) c_{n+1}."""
    return [Fraction(n + 1) * c[n + 1] for n in range(len(c) - 1)]


def euler(c: Seq) -> Seq:
    """Euler operator X d/dX on power-series coefficients: c_n -> n c_n."""
    return [Fraction(n) * c[n] for n in range(len(c))]


# ---------------------------------------------------------------------------
# Species as counting sequences
# ---------------------------------------------------------------------------

def species_E(n_max: int) -> Seq:
    """Species of sets E: one structure on every label set, f_n = 1."""
    return [Fraction(1) for _ in range(n_max)]


def species_L(n_max: int) -> Seq:
    """Species of linear orders L: f_n = n!."""
    return [Fraction(factorial(n)) for n in range(n_max)]


def species_derivative(f: Seq) -> Seq:
    """Derivative species F'[n] = F[n+1]: shift the counting sequence."""
    return [f[n + 1] for n in range(len(f) - 1)]


def species_pointed(f: Seq) -> Seq:
    """Pointed species F*[n] = [n] x F[n]: multiply term n by n."""
    return [Fraction(n) * f[n] for n in range(len(f))]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def show(label: str, seq: Seq) -> None:
    print(f"  {label:<34} " + ", ".join(str(x) for x in seq))


def demo_examples(N: int = 8) -> None:
    print("=" * 72)
    print("1. Canonical species and their EGFs")
    print("=" * 72)
    E, L = species_E(N), species_L(N)
    show("E  counting f_n = |E[n]|", E)
    show("EGF(E) coeffs (should be 1/n!)", egf_coeffs(E))
    print("   -> EGF(E) = sum 1/n! X^n = e^X   (Theorem 3.5)\n")
    show("L  counting f_n = |L[n]| = n!", L)
    show("EGF(L) coeffs (should be all 1)", egf_coeffs(L))
    print("   -> EGF(L) = sum X^n = 1/(1-X)    (Theorem 3.6)\n")


def demo_product(N: int = 8) -> None:
    print("=" * 72)
    print("2. Product law: EGF(F.G) = EGF(F) * EGF(G)   (Theorem 3.2)")
    print("=" * 72)
    E, L = species_E(N), species_L(N)
    # EGF of binomial convolution vs Cauchy product of EGFs.
    lhs = egf_coeffs(bin_conv(E, L))
    rhs = cauchy_mul(egf_coeffs(E), egf_coeffs(L))
    show("EGF(E*L) via binomial conv", lhs)
    show("EGF(E) * EGF(L) (Cauchy)", rhs)
    print(f"   match: {lhs == rhs}\n")
    # Commutativity of the species product, the 'analytic shadow' proof (Thm 4.2)
    ab = bin_conv(E, L)
    ba = bin_conv(L, E)
    show("(E * L) counting", ab)
    show("(L * E) counting", ba)
    print(f"   binConv commutes: {ab == ba}   (Theorem 4.2)\n")


def demo_injectivity(N: int = 8) -> None:
    print("=" * 72)
    print("3. Injectivity of the EGF transform   (Theorem 4.1)")
    print("=" * 72)
    L = species_L(N)
    recovered = egf_inverse(egf_coeffs(L))
    show("L counting", L)
    show("recovered from EGF coeffs", recovered)
    print(f"   round-trip exact: {recovered == L}")
    print("   => EGF is injective: equal EGFs force equal sequences.\n")


def demo_derivative(N: int = 8) -> None:
    print("=" * 72)
    print("4. Derivative bridge: EGF(F') = d/dX EGF(F)   (Theorems 4.3, 5.3)")
    print("=" * 72)
    L = species_L(N)
    Ld = species_derivative(L)          # L'[n] = L[n+1] = (n+1)!
    lhs = egf_coeffs(Ld)
    rhs = derivative(egf_coeffs(L))
    show("L' counting f_{n+1} = (n+1)!", Ld)
    show("EGF(L') coeffs", lhs)
    show("d/dX EGF(L) coeffs", rhs)
    print(f"   match: {lhs == rhs}")
    # EGF(L') = 1/(1-X)^2 = EGF(L.L): removing the ghost splits the row.
    ll = egf_coeffs(bin_conv(L, L))
    show("EGF(L.L) coeffs (= 1/(1-X)^2)", ll[: len(lhs)])
    print(f"   EGF(L') == EGF(L.L): {lhs == ll[: len(lhs)]}  (foreshadows Leibniz)\n")


def demo_pointing(N: int = 8) -> None:
    print("=" * 72)
    print("5. Pointing bridge: EGF(F*) = X d/dX EGF(F)   (Theorems 4.4, 5.4)")
    print("=" * 72)
    L = species_L(N)
    Lp = species_pointed(L)             # L*[n] = n * n!
    lhs = egf_coeffs(Lp)
    rhs = euler(egf_coeffs(L))
    show("L* counting n * n!", Lp)
    show("EGF(L*) coeffs", lhs)
    show("X d/dX EGF(L) coeffs", rhs)
    print(f"   match: {lhs == rhs}\n")


def demo_leibniz_preview(N: int = 8) -> None:
    print("=" * 72)
    print("6. Future work preview: the Leibniz rule  (F.G)' = F'.G + F.G'")
    print("=" * 72)
    E, L = species_E(N), species_L(N)
    # Work at the EGF-coefficient level, where the rule is forced by injectivity.
    cE, cL = egf_coeffs(E), egf_coeffs(L)
    prod = cauchy_mul(cE, cL)
    lhs = derivative(prod)
    # Align lengths cleanly: compute on equal-length prefixes.
    m = min(len(derivative(cE)), len(derivative(cL)))
    term1 = cauchy_mul(derivative(cE), cL)[:m]
    term2 = cauchy_mul(cE, derivative(cL))[:m]
    rhs = [term1[i] + term2[i] for i in range(m)]
    lhs = lhs[:m]
    show("d/dX(EGF E * EGF L)", lhs)
    show("EGF(E') EGF(L) + EGF(E) EGF(L')", rhs)
    print(f"   analytic Leibniz holds: {lhs == rhs}")
    print("   => by injectivity this forces (E.L)' = E'.L + E.L' on counts.\n")


def main() -> None:
    N = 8
    demo_examples(N)
    demo_product(N)
    demo_injectivity(N)
    demo_derivative(N)
    demo_pointing(N)
    demo_leibniz_preview(N)
    print("All exact identities verified.")


if __name__ == "__main__":
    main()
