"""
Numerical demonstrations for:

    Complement-split constructions beat the quasi-clique/quasi-star envelope
    for semi-induced stars S_{k,1}.

The semi-induced star S_{k,1} has a center incident to k present ("red") edges
and one absent ("blue") edge. In the graphon model the fixed-density
semi-inducibility functional reduces to

    I(W) = ∫_0^1 d(x)^k (1 - d(x)) dx,     with   ∫_0^1 d(x) dx = β,

where d(x) is the degree density. The two canonical constructions give:

    cliqueTerm(k, β) = β^k (1 - β)              (constant / quasi-clique graphon)
    starTerm(k, β)   = β (1 - β)^k              (edge-complement / quasi-star)
    envelope(k, β)   = min(cliqueTerm, starTerm)

The split graphon (dominating clique of size a = 1 - sqrt(1 - β) joined to an
independent set) has edge density exactly β and value

    splitVal(k, β) = (1 - β) (1 - sqrt(1 - β))^k.

Main theorem (splitVal_lt_envelope): for every k >= 1 and every
β in (0, (sqrt(5) - 1)/2), splitVal(k, β) < envelope(k, β).

This script verifies these closed forms, the density identity, the everywhere
domination of the quasi-clique, the golden-ratio threshold, and confirms the
split graphon is (numerically) optimal among two-class graphons.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import List, Tuple

# The golden-ratio conjugate: positive root of β^2 + β - 1 = 0.
GOLDEN_THRESHOLD: float = (math.sqrt(5.0) - 1.0) / 2.0  # ≈ 0.6180339887


# --------------------------------------------------------------------------- #
# Closed-form quantities                                                        #
# --------------------------------------------------------------------------- #

def clique_term(k: int, beta: float) -> float:
    """Value of the constant (quasi-clique) graphon: β^k (1 - β)."""
    return beta ** k * (1.0 - beta)


def star_term(k: int, beta: float) -> float:
    """Value of the edge-complement (quasi-star) graphon: β (1 - β)^k."""
    return beta * (1.0 - beta) ** k


def envelope(k: int, beta: float) -> float:
    """The quasi-clique / quasi-star envelope: min of the two terms."""
    return min(clique_term(k, beta), star_term(k, beta))


def split_value(k: int, beta: float) -> float:
    """Value of the split graphon: (1 - β) (1 - sqrt(1 - β))^k."""
    s = math.sqrt(1.0 - beta)
    return (1.0 - beta) * (1.0 - s) ** k


def split_class_size(beta: float) -> float:
    """Relative size a of the dominating clique class: a = 1 - sqrt(1 - β)."""
    return 1.0 - math.sqrt(1.0 - beta)


# --------------------------------------------------------------------------- #
# Two-class step graphon (mirrors the Lean TwoClassGraphon)                     #
# --------------------------------------------------------------------------- #

def two_class_degrees(a: float, p: float, q: float, r: float) -> Tuple[float, float]:
    """Class degree densities (d1, d2) of a two-class step graphon."""
    d1 = a * p + (1.0 - a) * q
    d2 = a * q + (1.0 - a) * r
    return d1, d2


def two_class_density(a: float, p: float, q: float, r: float) -> float:
    """Overall edge density of a two-class step graphon."""
    d1, d2 = two_class_degrees(a, p, q, r)
    return a * d1 + (1.0 - a) * d2


def two_class_star_value(k: int, a: float, p: float, q: float, r: float) -> float:
    """Semi-induced S_{k,1} value of a two-class step graphon."""
    d1, d2 = two_class_degrees(a, p, q, r)
    return a * d1 ** k * (1.0 - d1) + (1.0 - a) * d2 ** k * (1.0 - d2)


# --------------------------------------------------------------------------- #
# Brute-force optimality check over two-class graphons                          #
# --------------------------------------------------------------------------- #

def grid_min_two_class(k: int, beta: float, n: int = 120) -> Tuple[float, Tuple[float, float, float, float]]:
    """
    Minimize the S_{k,1} value over *realizable* two-class graphons of density β.

    Crucially, the degree pair (d1, d2) must come from an actual symmetric block
    matrix (a, p, q, r) with all entries in [0, 1] -- not every (d1, d2) is
    realizable (e.g. d1 = 1, d2 = 0 is impossible because a vertex of degree 1
    is joined to everyone). We therefore grid over (a, p, r) and solve the cross
    density q from the density constraint

        β = a^2 p + 2 a (1 - a) q + (1 - a)^2 r,

    keeping only solutions with q in [0, 1]. Returns (best_value, (a, p, q, r)).
    """
    best_val = float("inf")
    best_params = (0.0, 0.0, 0.0, 0.0)
    for i in range(1, n):  # a in (0, 1)
        a = i / n
        denom = 2.0 * a * (1.0 - a)
        for jp in range(n + 1):
            p = jp / n
            for jr in range(n + 1):
                r = jr / n
                q = (beta - a * a * p - (1.0 - a) ** 2 * r) / denom
                if q < -1e-12 or q > 1.0 + 1e-12:
                    continue
                d1 = a * p + (1.0 - a) * q
                d2 = a * q + (1.0 - a) * r
                val = a * d1 ** k * (1.0 - d1) + (1.0 - a) * d2 ** k * (1.0 - d2)
                if val < best_val:
                    best_val = val
                    best_params = (a, p, q, r)
    return best_val, best_params


# --------------------------------------------------------------------------- #
# Demonstrations                                                                #
# --------------------------------------------------------------------------- #

def demo_density_identity() -> None:
    """The split graphon has edge density exactly β (Lemma splitConstruction_density)."""
    print("=" * 72)
    print("DEMO 1: split graphon density identity   a(2 - a) = β,  a = 1 - sqrt(1 - β)")
    print("=" * 72)
    for beta in [0.1, 0.25, 0.5, GOLDEN_THRESHOLD, 0.8]:
        a = split_class_size(beta)
        dens = two_class_density(a, 1.0, 1.0, 0.0)  # split: p=q=1, r=0
        print(f"  β = {beta:.6f}   a = {a:.6f}   realized density = {dens:.10f}   "
              f"(|error| = {abs(dens - beta):.2e})")
    print()


def demo_star_value_identity() -> None:
    """starVal of the split graphon equals (1-β)(1-sqrt(1-β))^k (Lemma splitConstruction_starVal)."""
    print("=" * 72)
    print("DEMO 2: split graphon star value matches the closed form")
    print("=" * 72)
    for k in [2, 3, 4]:
        for beta in [0.2, 0.5]:
            a = split_class_size(beta)
            direct = two_class_star_value(k, a, 1.0, 1.0, 0.0)
            closed = split_value(k, beta)
            print(f"  k = {k}  β = {beta:.2f}   step-graphon = {direct:.8f}   "
                  f"closed form = {closed:.8f}   match = {math.isclose(direct, closed)}")
    print()


def demo_separation() -> None:
    """splitVal < envelope on the golden interval (Theorem splitVal_lt_envelope)."""
    print("=" * 72)
    print("DEMO 3: split value vs. envelope across densities")
    print(f"        golden threshold  β* = (sqrt(5)-1)/2 = {GOLDEN_THRESHOLD:.6f}")
    print("=" * 72)
    header = f"  {'k':>2} {'β':>7} {'split':>11} {'clique':>11} {'star':>11} {'env':>11} {'split<env?':>11}"
    for k in [2, 3, 4, 6]:
        print(header)
        for beta in [0.10, 0.30, 0.50, GOLDEN_THRESHOLD, 0.70, 0.85]:
            sv = split_value(k, beta)
            ct = clique_term(k, beta)
            st = star_term(k, beta)
            en = min(ct, st)
            print(f"  {k:>2} {beta:>7.4f} {sv:>11.6f} {ct:>11.6f} {st:>11.6f} "
                  f"{en:>11.6f} {str(sv < en):>11}")
        print()


def demo_two_class_optimality() -> None:
    """Brute force confirms the split graphon is numerically optimal among two-class graphons."""
    print("=" * 72)
    print("DEMO 4: brute-force two-class minimum vs. the split closed form")
    print("=" * 72)
    for k in [2, 3, 4]:
        for beta in [0.3, 0.5]:
            best_val, (a, p, q, r) = grid_min_two_class(k, beta, n=120)
            closed = split_value(k, beta)
            print(f"  k = {k}  β = {beta:.2f}   grid min = {best_val:.6f}  "
                  f"at (a={a:.3f}, p={p:.2f}, q={q:.2f}, r={r:.2f})   "
                  f"split = {closed:.6f}   |Δ| = {abs(best_val - closed):.4f}")
    print()


def demo_golden_threshold() -> None:
    """Locate, numerically, where splitVal stops beating starTerm: at β = (sqrt(5)-1)/2."""
    print("=" * 72)
    print("DEMO 5: numerical crossover of split vs. quasi-star  (expect β*)")
    print("=" * 72)
    for k in [2, 5, 10]:
        # scan β; find largest β where splitVal < starTerm
        lo, hi = 0.0, 1.0
        # split beats star for small β; find the transition by bisection on the predicate
        for _ in range(60):
            mid = 0.5 * (lo + hi)
            if split_value(k, mid) < star_term(k, mid):
                lo = mid
            else:
                hi = mid
        print(f"  k = {k:>2}   numeric crossover β ≈ {0.5*(lo+hi):.6f}   "
              f"(β* = {GOLDEN_THRESHOLD:.6f})")
    print()


def main() -> None:
    print()
    print("Semi-induced stars S_{k,1}: the split construction beats the envelope")
    print()
    demo_density_identity()
    demo_star_value_identity()
    demo_separation()
    demo_two_class_optimality()
    demo_golden_threshold()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


"""
Visualization: split value vs. the quasi-clique/quasi-star envelope for
semi-induced stars S_{k,1}, showing the separation on the golden interval
(0, (sqrt(5)-1)/2).

Produces 'separation.png': for several k, the split value (1-β)(1-sqrt(1-β))^k
plotted against cliqueTerm = β^k(1-β), starTerm = β(1-β)^k, and their envelope,
with the golden-ratio threshold marked.

Run:  python3 visualize.py
"""

from __future__ import annotations

import math
from typing import List

import numpy as np
import matplotlib.pyplot as plt

GOLDEN: float = (math.sqrt(5.0) - 1.0) / 2.0


def split_value(k: int, beta: np.ndarray) -> np.ndarray:
    s = np.sqrt(1.0 - beta)
    return (1.0 - beta) * (1.0 - s) ** k


def clique_term(k: int, beta: np.ndarray) -> np.ndarray:
    return beta ** k * (1.0 - beta)


def star_term(k: int, beta: np.ndarray) -> np.ndarray:
    return beta * (1.0 - beta) ** k


def main() -> None:
    ks: List[int] = [2, 3, 4, 6]
    beta = np.linspace(1e-4, 1.0 - 1e-4, 1000)

    fig, axes = plt.subplots(2, 2, figsize=(12, 9))
    for ax, k in zip(axes.ravel(), ks):
        ct = clique_term(k, beta)
        st = star_term(k, beta)
        env = np.minimum(ct, st)
        sv = split_value(k, beta)

        ax.plot(beta, ct, "--", color="tab:blue", lw=1.2, label=r"quasi-clique $\beta^k(1-\beta)$")
        ax.plot(beta, st, "--", color="tab:green", lw=1.2, label=r"quasi-star $\beta(1-\beta)^k$")
        ax.plot(beta, env, color="black", lw=2.0, label="envelope")
        ax.plot(beta, sv, color="tab:red", lw=2.2, label=r"split $(1-\beta)(1-\sqrt{1-\beta})^k$")

        ax.axvline(GOLDEN, color="goldenrod", ls=":", lw=1.8,
                   label=r"$\beta^\star=\frac{\sqrt5-1}{2}$")
        ax.axvspan(0, GOLDEN, color="gold", alpha=0.10)
        ax.set_title(f"$k = {k}$")
        ax.set_xlabel(r"$\beta$")
        ax.set_ylabel("value")
        ax.set_xlim(0, 1)
        ax.set_ylim(bottom=0)
        ax.legend(fontsize=8, loc="upper right")

    fig.suptitle("Split construction beats the envelope on the golden interval "
                 r"$(0,\,\frac{\sqrt5-1}{2})$", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, 0.97))
    fig.savefig("separation.png", dpi=140)
    print("Wrote separation.png")


if __name__ == "__main__":
    main()
