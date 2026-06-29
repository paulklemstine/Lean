"""
The Taylor / Maclaurin Calculus of Combinatorial Species
========================================================

Self-contained numerical demonstration of the formalised results:

  * egf_seqDeriv_iterate     : egf(n -> a(n+k)) = D^k (egf a)
  * coeffSeq_iterate_deriv   : F^(k)[n] = F[n+k]
  * taylor_coeffSeq          : F^(k)[0] = F[k]
  * EGF_iterate_derivative   : (F^(k)).EGF = D^k (F.EGF)
  * species_maclaurin        : coeff_0(D^k (F.EGF)) = F[k]   (NO factorial!)

Everything is computed in *exact* rational arithmetic with ``fractions.Fraction``,
so the equalities below are verified on the nose, not numerically.

Run:  python demo.py
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial
from typing import Callable, List


# ---------------------------------------------------------------------------
# Core: counting sequences, EGFs (as truncated coefficient lists), derivatives
# ---------------------------------------------------------------------------

CountingSeq = Callable[[int], Fraction]
"""A counting sequence a : N -> Q, e.g. n -> F[n]."""


def egf_coeffs(a: CountingSeq, n_terms: int) -> List[Fraction]:
    """EGF coefficients c_n = a(n)/n!  of  egf(a) = sum_n (a_n / n!) X^n."""
    return [a(n) / factorial(n) for n in range(n_terms)]


def formal_derivative(coeffs: List[Fraction]) -> List[Fraction]:
    """Formal derivative D on Q[[X]] truncated to a coefficient list:
    (D f)_n = (n+1) * f_{n+1}."""
    return [(n + 1) * coeffs[n + 1] for n in range(len(coeffs) - 1)]


def iterate_derivative(coeffs: List[Fraction], k: int) -> List[Fraction]:
    """The k-fold formal derivative D^k applied to a coefficient list."""
    out = list(coeffs)
    for _ in range(k):
        out = formal_derivative(out)
    return out


def constant_term(coeffs: List[Fraction]) -> Fraction:
    """coeff_0 : the value at X = 0 (the constant term of a power series)."""
    return coeffs[0] if coeffs else Fraction(0)


# ---------------------------------------------------------------------------
# Species (skeletal): a counting sequence plus its derivative tower
# ---------------------------------------------------------------------------

def derivative_species(a: CountingSeq) -> CountingSeq:
    """Joyal's derivative species:  F'[n] = F[n+1]  (one extra ghost point)."""
    return lambda n: a(n + 1)


def iterate_derivative_species(a: CountingSeq, k: int) -> CountingSeq:
    """The k-fold derivative species:  F^(k)[n] = F[n+k]  (k ghost points)."""
    def shifted(n: int) -> Fraction:
        return a(n + k)
    return shifted


# ---------------------------------------------------------------------------
# Two flagship species
# ---------------------------------------------------------------------------

def E_sets(n: int) -> Fraction:
    """Species of sets E:  exactly one structure on every label set, E[n] = 1.
    EGF(E) = exp(X)."""
    return Fraction(1)


def L_linear_orders(n: int) -> Fraction:
    """Species of linear orders L:  L[n] = n!  arrangements.
    EGF(L) = 1/(1 - X)."""
    return Fraction(factorial(n))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_maclaurin_reconstruction(a: CountingSeq, name: str, n_terms: int = 9) -> None:
    """species_maclaurin:  coeff_0(D^k (egf a)) = a(k), with NO factorial."""
    print(f"\n[Maclaurin reconstruction]  species '{name}'")
    print("  k :  coeff_0(D^k EGF)   vs   F[k]   (must match exactly)")
    base = egf_coeffs(a, n_terms)
    for k in range(n_terms):
        recovered = constant_term(iterate_derivative(base, k))
        expected = a(k)
        ok = "OK" if recovered == expected else "MISMATCH!"
        print(f"  {k} :   {str(recovered):>10}        {str(expected):>10}   {ok}")
        assert recovered == expected, (k, recovered, expected)


def demo_tower_formula(a: CountingSeq, name: str, K: int = 4, N: int = 5) -> None:
    """coeffSeq_iterate_derivative:  F^(k)[n] = F[n+k]."""
    print(f"\n[Tower formula  F^(k)[n] = F[n+k]]  species '{name}'")
    for k in range(K):
        fk = iterate_derivative_species(a, k)
        row = [str(fk(n)) for n in range(N)]
        print(f"  F^({k})[0..{N-1}] = {row}")
        for n in range(N):
            assert fk(n) == a(n + k)


def demo_taylor_at_origin(a: CountingSeq, name: str, K: int = 7) -> None:
    """taylor_coeffSeq:  F^(k)[0] = F[k]."""
    print(f"\n[Taylor at the origin  F^(k)[0] = F[k]]  species '{name}'")
    vals = [iterate_derivative_species(a, k)(0) for k in range(K)]
    print(f"  (F^(k)[0])_k = {[str(v) for v in vals]}")
    print(f"  (F[k])_k     = {[str(a(k)) for k in range(K)]}")
    for k in range(K):
        assert iterate_derivative_species(a, k)(0) == a(k)


def demo_egf_intertwining(a: CountingSeq, name: str, k: int = 3, n_terms: int = 9) -> None:
    """egf_seqDeriv_iterate / EGF_iterate_derivative:
       egf(n -> a(n+k)) = D^k(egf a)  as coefficient lists."""
    print(f"\n[EGF intertwining  egf(shift^k a) = D^k(egf a)]  species '{name}', k={k}")
    lhs = egf_coeffs(iterate_derivative_species(a, k), n_terms - k)
    rhs = iterate_derivative(egf_coeffs(a, n_terms), k)
    print(f"  egf(shift^{k} a) = {[str(c) for c in lhs]}")
    print(f"  D^{k}(egf a)     = {[str(c) for c in rhs]}")
    assert lhs == rhs


def main() -> None:
    print("=" * 70)
    print("  Taylor / Maclaurin Calculus of Combinatorial Species  --  demo")
    print("=" * 70)

    for a, name in [(E_sets, "E (sets)  EGF=exp"),
                    (L_linear_orders, "L (linear orders)  EGF=1/(1-X)")]:
        demo_tower_formula(a, name)
        demo_taylor_at_origin(a, name)
        demo_egf_intertwining(a, name)
        demo_maclaurin_reconstruction(a, name)

    # A bespoke species: F[n] = 2^n  (e.g. subsets, EGF = exp(2X)).
    def F_two_pow(n: int) -> Fraction:
        return Fraction(2 ** n)

    demo_maclaurin_reconstruction(F_two_pow, "F[n]=2^n  EGF=exp(2X)")

    print("\nAll exact-arithmetic assertions passed.  The factorials cancel,")
    print("and the un-normalised species count F[k] is read off directly as")
    print("the constant term of the k-fold formal derivative of the EGF.")


if __name__ == "__main__":
    main()


"""
Visualization: The Taylor tower of a combinatorial species and the
factorial-cancelling Maclaurin reconstruction.

Produces a two-panel figure:

  (left)  The derivative tower table  F^(k)[n] = F[n+k]  as a heatmap of
          log-counts for the species of linear orders L (counts (n+k)!).
  (right) The Maclaurin reconstruction: constant term of D^k(EGF) plotted
          against the true species count F[k], showing exact agreement and
          the cancellation of the k! that an ordinary GF would introduce.

Run:  python visualization.py   (writes species_taylor_tower.png)
"""

from __future__ import annotations

from fractions import Fraction
from math import factorial, log10
from typing import Callable, List

import numpy as np
import matplotlib.pyplot as plt


def egf_coeffs(a: Callable[[int], Fraction], n_terms: int) -> List[Fraction]:
    return [a(n) / factorial(n) for n in range(n_terms)]


def formal_derivative(coeffs: List[Fraction]) -> List[Fraction]:
    return [(n + 1) * coeffs[n + 1] for n in range(len(coeffs) - 1)]


def iterate_derivative(coeffs: List[Fraction], k: int) -> List[Fraction]:
    out = list(coeffs)
    for _ in range(k):
        out = formal_derivative(out)
    return out


def L(n: int) -> Fraction:  # species of linear orders, L[n] = n!
    return Fraction(factorial(n))


def main() -> None:
    K, N = 7, 7
    # Left panel: tower heatmap of log10(F^(k)[n]) = log10((n+k)!)
    tower = np.array([[log10(float(L(n + k))) if (n + k) > 0 else 0.0
                       for n in range(N)] for k in range(K)])

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5.2))

    im = ax1.imshow(tower, cmap="viridis", aspect="auto", origin="lower")
    ax1.set_title(r"Derivative tower  $F^{(k)}[n]=F[n+k]=(n+k)!$"
                  "\n(log$_{10}$ counts, species L)")
    ax1.set_xlabel(r"honest labels $n$")
    ax1.set_ylabel(r"derivative order $k$ (ghost points)")
    for k in range(K):
        for n in range(N):
            ax1.text(n, k, f"{factorial(n + k)}", ha="center", va="center",
                     color="white", fontsize=7)
    fig.colorbar(im, ax=ax1, label=r"$\log_{10} F^{(k)}[n]$")

    # Right panel: Maclaurin reconstruction
    base = egf_coeffs(L, 2 * K)
    recovered = [int(iterate_derivative(base, k)[0]) for k in range(K)]
    truth = [factorial(k) for k in range(K)]
    naive = [factorial(k) * recovered[k] for k in range(K)]  # ordinary-GF artefact

    ks = list(range(K))
    ax2.semilogy(ks, truth, "o-", label=r"true count $F[k]=k!$", lw=2)
    ax2.semilogy(ks, recovered, "x--", ms=10,
                 label=r"coeff$_0(D^k\,$EGF$)$ (matches!)")
    ax2.semilogy(ks, naive, "s:", color="crimson", alpha=0.7,
                 label=r"$k!\cdot$coeff$_0$ (ordinary-GF artefact)")
    ax2.set_title("Maclaurin reconstruction\nthe EGF $1/n!$ cancels the $k!$")
    ax2.set_xlabel(r"derivative order $k$")
    ax2.set_ylabel("value (log scale)")
    ax2.legend()
    ax2.grid(True, which="both", alpha=0.3)

    fig.suptitle("The Taylor / Maclaurin Calculus of Combinatorial Species",
                 fontsize=14, fontweight="bold")
    fig.tight_layout(rect=(0, 0, 1, 0.95))
    fig.savefig("species_taylor_tower.png", dpi=150)
    print("wrote species_taylor_tower.png")


if __name__ == "__main__":
    main()
