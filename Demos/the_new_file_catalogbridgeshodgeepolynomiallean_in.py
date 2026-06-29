"""
Numerical demonstrations of the Hodge--Deligne E-polynomial functional equations.

This file is fully self-contained (standard library only). It implements the
abstract `HodgeDiamond` structure from the formal development:

    A Hodge diamond is a complex dimension n together with Hodge numbers
    h^{p,q} (integers), indexed by 0 <= p, q <= n.

and the invariants:

    E(X; u, v)   = sum_{p,q} (-1)^(p+q) * h^{p,q} * u^p * v^q   (the E-polynomial)
    chi(X)       = sum_{p,q} (-1)^(p+q) * h^{p,q}               (Euler characteristic)
    totalDim(X)  = sum_{p,q} h^{p,q}                            (total Betti number)

and the two geometric involutions:

    mirror:  (p, q) |-> (n - p, q)         h'^{p,q} = h^{n-p, q}
    Serre:   (p, q) |-> (n - p, n - q)     h^{p,q}  = h^{n-p, n-q}   (a property)

We then numerically verify, on famous Calabi--Yau and other diamonds, the
theorems:

    epoly_mirror_functional_equation :  E(mirror X; u, v) = (-1)^n u^n E(X; 1/u, v)
    epoly_serre_functional_equation  :  E(X; u, v) = (uv)^n E(X; 1/u, 1/v)   (Serre dual X)
    epoly_one_one_eq_eulerChar       :  E(X; 1, 1) = chi(X)
    eulerChar_mirror_sign            :  chi(mirror X) = (-1)^n chi(X)
    totalDim_mirror                  :  totalDim(mirror X) = totalDim(X)

All arithmetic uses exact rational numbers (fractions.Fraction) so the equalities
are checked exactly, not up to floating-point tolerance.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# Core structure
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class HodgeDiamond:
    """A Hodge diamond: complex dimension `n` and Hodge numbers `h[(p, q)]`.

    `h` is a callable returning the integer h^{p,q}; entries outside
    0 <= p, q <= n are treated as 0 (padding), matching the formal convention
    that only the support is mathematically meaningful.
    """

    n: int
    h: Callable[[int, int], int]

    def hpq(self, p: int, q: int) -> int:
        return self.h(p, q)


def diamond_from_table(n: int, table: Dict[Tuple[int, int], int]) -> HodgeDiamond:
    """Build a HodgeDiamond from an explicit {(p, q): value} table."""
    return HodgeDiamond(n=n, h=lambda p, q: table.get((p, q), 0))


def mirror(X: HodgeDiamond) -> HodgeDiamond:
    """The mirror diamond, reflecting the p-index: h'^{p,q} = h^{n-p, q}."""
    n = X.n
    return HodgeDiamond(n=n, h=lambda p, q: X.h(n - p, q))


# ---------------------------------------------------------------------------
# Invariants
# ---------------------------------------------------------------------------

def epoly(X: HodgeDiamond, u: Fraction, v: Fraction) -> Fraction:
    """E(X; u, v) = sum_{p,q in [0, n]} (-1)^(p+q) h^{p,q} u^p v^q."""
    total = Fraction(0)
    for p in range(X.n + 1):
        for q in range(X.n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * X.h(p, q) * (u ** p) * (v ** q)
    return total


def euler_char(X: HodgeDiamond) -> int:
    """chi(X) = sum_{p,q} (-1)^(p+q) h^{p,q}."""
    total = 0
    for p in range(X.n + 1):
        for q in range(X.n + 1):
            sign = -1 if (p + q) % 2 else 1
            total += sign * X.h(p, q)
    return total


def total_dim(X: HodgeDiamond) -> int:
    """totalDim(X) = sum_{p,q} h^{p,q}."""
    return sum(X.h(p, q) for p in range(X.n + 1) for q in range(X.n + 1))


def is_serre_dual(X: HodgeDiamond) -> bool:
    """Check Serre duality: h^{p,q} = h^{n-p, n-q} for all p, q in [0, n]."""
    n = X.n
    return all(
        X.h(p, q) == X.h(n - p, n - q)
        for p in range(n + 1)
        for q in range(n + 1)
    )


# ---------------------------------------------------------------------------
# Famous diamonds
# ---------------------------------------------------------------------------

def quintic_threefold() -> HodgeDiamond:
    """The quintic Calabi--Yau threefold: n=3, h^{1,1}=1, h^{2,1}=101."""
    table = {
        (0, 0): 1, (3, 3): 1,
        (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return diamond_from_table(3, table)


def mirror_quintic() -> HodgeDiamond:
    """The mirror quintic: n=3, h^{1,1}=101, h^{2,1}=1 (swap of the quintic)."""
    table = {
        (0, 0): 1, (3, 3): 1,
        (3, 0): 1, (0, 3): 1,
        (1, 1): 101, (2, 2): 101,
        (2, 1): 1, (1, 2): 1,
    }
    return diamond_from_table(3, table)


def k3_surface() -> HodgeDiamond:
    """The K3 surface: n=2, h^{1,1}=20, h^{2,0}=h^{0,2}=1, chi = 24."""
    table = {
        (0, 0): 1, (2, 2): 1,
        (2, 0): 1, (0, 2): 1,
        (1, 1): 20,
    }
    return diamond_from_table(2, table)


def projective_space(n: int) -> HodgeDiamond:
    """Complex projective space P^n: h^{p,p}=1 (0<=p<=n), all else 0; chi=n+1."""
    return diamond_from_table(n, {(p, p): 1 for p in range(n + 1)})


# ---------------------------------------------------------------------------
# Verification helpers
# ---------------------------------------------------------------------------

def check_mirror_functional_equation(
    X: HodgeDiamond, u: Fraction, v: Fraction
) -> Tuple[Fraction, Fraction, bool]:
    """E(mirror X; u, v)  vs  (-1)^n u^n E(X; 1/u, v)."""
    lhs = epoly(mirror(X), u, v)
    sign = -1 if X.n % 2 else 1
    rhs = sign * (u ** X.n) * epoly(X, 1 / u, v)
    return lhs, rhs, lhs == rhs


def check_serre_functional_equation(
    X: HodgeDiamond, u: Fraction, v: Fraction
) -> Tuple[Fraction, Fraction, bool]:
    """E(X; u, v)  vs  (uv)^n E(X; 1/u, 1/v)  (requires Serre duality)."""
    lhs = epoly(X, u, v)
    rhs = ((u * v) ** X.n) * epoly(X, 1 / u, 1 / v)
    return lhs, rhs, lhs == rhs


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print("\n" + "=" * 70)
    print(title)
    print("=" * 70)


def main() -> None:
    examples: List[Tuple[str, HodgeDiamond]] = [
        ("Quintic threefold (n=3)", quintic_threefold()),
        ("Mirror quintic (n=3)", mirror_quintic()),
        ("K3 surface (n=2)", k3_surface()),
        ("Projective space P^4 (n=4)", projective_space(4)),
    ]

    test_points: List[Tuple[Fraction, Fraction]] = [
        (Fraction(2), Fraction(3)),
        (Fraction(5), Fraction(-7)),
        (Fraction(-1, 2), Fraction(4)),
    ]

    banner("E(X; 1, 1) = chi(X)   and   totalDim / Euler characteristics")
    for name, X in examples:
        one = Fraction(1)
        e11 = epoly(X, one, one)
        chi = euler_char(X)
        td = total_dim(X)
        print(f"{name:32s}  E(X;1,1) = {e11!s:>6}   chi = {chi:>6}   "
              f"totalDim = {td:>4}   match={e11 == chi}")

    banner("Mirror functional equation:  E(mirror X; u,v) = (-1)^n u^n E(X; 1/u, v)")
    for name, X in examples:
        for (u, v) in test_points:
            lhs, rhs, ok = check_mirror_functional_equation(X, u, v)
            print(f"{name:28s} u={u!s:>5} v={v!s:>5}  "
                  f"LHS={lhs!s:>14} RHS={rhs!s:>14}  ok={ok}")

    banner("Serre/Poincare functional equation:  E(X; u,v) = (uv)^n E(X; 1/u, 1/v)")
    for name, X in examples:
        if not is_serre_dual(X):
            print(f"{name:32s}  (not Serre self-dual, skipping)")
            continue
        for (u, v) in test_points:
            lhs, rhs, ok = check_serre_functional_equation(X, u, v)
            print(f"{name:28s} u={u!s:>5} v={v!s:>5}  "
                  f"LHS={lhs!s:>14} RHS={rhs!s:>14}  ok={ok}")

    banner("Numerical mirror sign:  chi(mirror X) = (-1)^n chi(X)   "
           "and totalDim invariance")
    for name, X in examples:
        chi = euler_char(X)
        chi_m = euler_char(mirror(X))
        sign = -1 if X.n % 2 else 1
        td_match = total_dim(mirror(X)) == total_dim(X)
        print(f"{name:32s}  chi={chi:>6}  chi(mirror)={chi_m:>6}  "
              f"(-1)^n chi={sign * chi:>6}  sign_ok={chi_m == sign * chi}  "
              f"totalDim_inv={td_match}")

    banner("The mirror congruence (arithmetic descent preview): "
           "chi pairs related by (-1)^n")
    Xq, Xm = quintic_threefold(), mirror_quintic()
    print(f"chi(quintic)        = {euler_char(Xq):>6}")
    print(f"chi(mirror quintic) = {euler_char(Xm):>6}")
    print(f"sum (should be 0 since n odd): {euler_char(Xq) + euler_char(Xm)}")


if __name__ == "__main__":
    main()


"""
Visualization: Hodge diamonds, their mirrors, and the E-polynomial coefficient
symmetry imposed by the functional equations.

Produces a figure with three panels:
  (1) the Hodge diamond of the quintic threefold as a heatmap;
  (2) its mirror (reflection of the p-index), illustrating totalDim invariance
      and the (-1)^n Euler-characteristic sign flip;
  (3) the signed E-polynomial coefficient grid c_{p,q} = (-1)^(p+q) h^{p,q},
      annotated with the Serre/Poincare palindromic symmetry c_{p,q}=c_{n-p,n-q}.

Requires matplotlib + numpy. Run:  python visualization.py
"""

from __future__ import annotations

from typing import Dict, Tuple

import numpy as np
import matplotlib.pyplot as plt


def quintic_table() -> Tuple[int, Dict[Tuple[int, int], int]]:
    n = 3
    table = {
        (0, 0): 1, (3, 3): 1,
        (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    }
    return n, table


def grid(n: int, table: Dict[Tuple[int, int], int]) -> np.ndarray:
    M = np.zeros((n + 1, n + 1), dtype=int)
    for (p, q), v in table.items():
        M[p, q] = v
    return M


def mirror_grid(M: np.ndarray) -> np.ndarray:
    # mirror reflects the p (row) index: h'^{p,q} = h^{n-p,q}
    return M[::-1, :].copy()


def signed_grid(M: np.ndarray) -> np.ndarray:
    n = M.shape[0] - 1
    S = np.zeros_like(M)
    for p in range(n + 1):
        for q in range(n + 1):
            S[p, q] = ((-1) ** (p + q)) * M[p, q]
    return S


def euler_char(M: np.ndarray) -> int:
    return int(signed_grid(M).sum())


def annotate(ax, M: np.ndarray) -> None:
    n = M.shape[0] - 1
    for p in range(n + 1):
        for q in range(n + 1):
            ax.text(q, p, str(M[p, q]), ha="center", va="center",
                    color="black", fontsize=11)
    ax.set_xticks(range(n + 1))
    ax.set_yticks(range(n + 1))
    ax.set_xlabel("q")
    ax.set_ylabel("p")


def main() -> None:
    n, table = quintic_table()
    M = grid(n, table)
    Mm = mirror_grid(M)
    S = signed_grid(M)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    axes[0].imshow(M, cmap="Blues")
    annotate(axes[0], M)
    axes[0].set_title(f"Quintic Hodge diamond\nchi = {euler_char(M)}, "
                      f"totalDim = {int(M.sum())}")

    axes[1].imshow(Mm, cmap="Blues")
    annotate(axes[1], Mm)
    axes[1].set_title(f"Mirror (reflect p)\nchi = {euler_char(Mm)} = (-1)^n chi, "
                      f"totalDim = {int(Mm.sum())}")

    vmax = np.abs(S).max()
    axes[2].imshow(S, cmap="RdBu", vmin=-vmax, vmax=vmax)
    annotate(axes[2], S)
    axes[2].set_title("Signed E-poly coefficients\nc_{p,q} = c_{n-p,n-q} "
                      "(Poincare palindrome)")

    fig.suptitle("Hodge-Deligne E-polynomial: mirror & Serre symmetries",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("hodge_epolynomial.png", dpi=150)
    print("Saved hodge_epolynomial.png")


if __name__ == "__main__":
    main()
