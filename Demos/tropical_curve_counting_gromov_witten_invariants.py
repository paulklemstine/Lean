"""
Numerical demonstrations of the Hodge--Deligne E-polynomial functional equations.

This script implements the abstract Hodge diamond and its two-variable
Hodge--Deligne E-polynomial

    E(X; u, v) = sum_{p,q=0..n} (-1)^(p+q) * h^{p,q} * u^p * v^q

and verifies, on standard examples (genus-g curve, P^2, K3 surface, quintic
Calabi--Yau threefold), the four results proved in the Lean development:

  Theorem 1 (epoly_one_one_eq_eulerChar):
      E(X; 1, 1) = chi(X)
  Theorem 2 (epoly_mirror_functional_equation):  (u != 0)
      E(mirror X; u, v) = (-1)^n * u^n * E(X; 1/u, v)
  Theorem 3 (epoly_serre_functional_equation):   (Serre self-dual, u,v != 0)
      E(X; u, v) = (u*v)^n * E(X; 1/u, 1/v)
  Theorem 4 (eulerChar_mirror_sign):
      chi(mirror X) = (-1)^n * chi(X)

All arithmetic is exact (Fraction), and identities are certified by agreement
at a panel of rational sample points -- a polynomial identity of bidegree
<= (2n, 2n) is determined by its values at enough generic points.

Run:  python3 demo.py
"""

from __future__ import annotations

from fractions import Fraction
from typing import Callable, Dict, List, Tuple

# A Hodge diamond is (n, h) where h maps (p, q) -> integer Hodge number.
HodgeNumbers = Dict[Tuple[int, int], int]


class HodgeDiamond:
    """An abstract Hodge diamond: dimension n and Hodge numbers h^{p,q}."""

    def __init__(self, n: int, h: HodgeNumbers) -> None:
        self.n: int = n
        # Only entries with 0 <= p,q <= n are meaningful; default 0 elsewhere.
        self.h: HodgeNumbers = dict(h)

    def hpq(self, p: int, q: int) -> int:
        """Hodge number h^{p,q}, with 0 outside the support."""
        return self.h.get((p, q), 0)

    def epoly(self, u: Fraction, v: Fraction) -> Fraction:
        """Evaluate E(X; u, v) = sum (-1)^(p+q) h^{p,q} u^p v^q."""
        total = Fraction(0)
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                sign = -1 if (p + q) % 2 else 1
                total += sign * self.hpq(p, q) * (u ** p) * (v ** q)
        return total

    def euler_char(self) -> int:
        """chi(X) = sum (-1)^(p+q) h^{p,q}."""
        total = 0
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                sign = -1 if (p + q) % 2 else 1
                total += sign * self.hpq(p, q)
        return total

    def total_dim(self) -> int:
        """Total Betti number sum h^{p,q}."""
        return sum(self.hpq(p, q) for p in range(self.n + 1)
                   for q in range(self.n + 1))

    def mirror(self) -> "HodgeDiamond":
        """Mirror diamond: (mirror X)^{p,q} = X^{n-p, q}."""
        n = self.n
        h2: HodgeNumbers = {}
        for p in range(n + 1):
            for q in range(n + 1):
                val = self.hpq(n - p, q)
                if val:
                    h2[(p, q)] = val
        return HodgeDiamond(n, h2)


# Rational sample points with u, v != 0 used to certify identities.
SAMPLE_POINTS: List[Tuple[Fraction, Fraction]] = [
    (Fraction(2), Fraction(3)),
    (Fraction(5, 2), Fraction(-7, 3)),
    (Fraction(-3), Fraction(4)),
    (Fraction(1, 4), Fraction(9, 5)),
    (Fraction(7, 3), Fraction(-1, 2)),
]


def verify_identity(lhs: Callable[[Fraction, Fraction], Fraction],
                    rhs: Callable[[Fraction, Fraction], Fraction]) -> bool:
    """Return True iff lhs(u,v) == rhs(u,v) at all sample points."""
    return all(lhs(u, v) == rhs(u, v) for (u, v) in SAMPLE_POINTS)


def check_mirror_equation(X: HodgeDiamond) -> bool:
    """Theorem 2: E(mirror X; u,v) = (-1)^n u^n E(X; 1/u, v)."""
    n, M = X.n, X.mirror()
    sign = -1 if n % 2 else 1

    def lhs(u: Fraction, v: Fraction) -> Fraction:
        return M.epoly(u, v)

    def rhs(u: Fraction, v: Fraction) -> Fraction:
        return sign * (u ** n) * X.epoly(1 / u, v)

    return verify_identity(lhs, rhs)


def check_serre_equation(X: HodgeDiamond) -> bool:
    """Theorem 3: E(X; u,v) = (uv)^n E(X; 1/u, 1/v) (Serre self-dual)."""
    n = X.n

    def lhs(u: Fraction, v: Fraction) -> Fraction:
        return X.epoly(u, v)

    def rhs(u: Fraction, v: Fraction) -> Fraction:
        return ((u * v) ** n) * X.epoly(1 / u, 1 / v)

    return verify_identity(lhs, rhs)


def is_serre_self_dual(X: HodgeDiamond) -> bool:
    """Check h^{p,q} = h^{n-p,n-q} on the support."""
    n = X.n
    return all(X.hpq(p, q) == X.hpq(n - p, n - q)
               for p in range(n + 1) for q in range(n + 1))


def check_euler_mirror_sign(X: HodgeDiamond) -> bool:
    """Theorem 4: chi(mirror X) = (-1)^n chi(X)."""
    sign = -1 if X.n % 2 else 1
    return X.mirror().euler_char() == sign * X.euler_char()


def check_epoly_one_one(X: HodgeDiamond) -> bool:
    """Theorem 1: E(X; 1, 1) = chi(X)."""
    return X.epoly(Fraction(1), Fraction(1)) == X.euler_char()


# ---------------------------------------------------------------------------
# Standard examples.
# ---------------------------------------------------------------------------

def genus_g_curve(g: int) -> HodgeDiamond:
    """Smooth complex curve of genus g (n = 1)."""
    return HodgeDiamond(1, {(0, 0): 1, (1, 0): g, (0, 1): g, (1, 1): 1})


def projective_plane() -> HodgeDiamond:
    """P^2 (n = 2): h^{0,0}=h^{1,1}=h^{2,2}=1."""
    return HodgeDiamond(2, {(0, 0): 1, (1, 1): 1, (2, 2): 1})


def k3_surface() -> HodgeDiamond:
    """K3 surface (n = 2): h^{1,1}=20, corner entries 1."""
    return HodgeDiamond(2, {(0, 0): 1, (2, 0): 1, (0, 2): 1,
                            (2, 2): 1, (1, 1): 20})


def quintic_threefold() -> HodgeDiamond:
    """Quintic Calabi-Yau threefold (n = 3): h^{2,1}=h^{1,2}=101."""
    return HodgeDiamond(3, {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1,
        (2, 1): 101, (1, 2): 101,
    })


def poly_str(X: HodgeDiamond) -> str:
    """Human-readable E-polynomial via its monomial table."""
    terms: List[str] = []
    for p in range(X.n + 1):
        for q in range(X.n + 1):
            c = X.hpq(p, q)
            if not c:
                continue
            coeff = c * (-1 if (p + q) % 2 else 1)
            mon = ""
            if p:
                mon += f"u^{p}" if p > 1 else "u"
            if q:
                mon += (f"v^{q}" if q > 1 else "v")
            mon = mon or "1"
            terms.append(f"{coeff:+d}*{mon}")
    return " ".join(terms) if terms else "0"


def report(name: str, X: HodgeDiamond) -> None:
    print(f"=== {name}  (n = {X.n}) ===")
    print(f"  E(X; u, v) = {poly_str(X)}")
    print(f"  chi(X)      = {X.euler_char()}     total dim = {X.total_dim()}")
    print(f"  E(mirror)   = {poly_str(X.mirror())}")
    print(f"  [Thm 1] E(X;1,1) = chi(X)               : {check_epoly_one_one(X)}")
    print(f"  [Thm 2] mirror functional equation      : {check_mirror_equation(X)}")
    serre = is_serre_self_dual(X)
    if serre:
        print(f"  [Thm 3] Serre functional equation       : {check_serre_equation(X)}")
    else:
        print(f"  [Thm 3] (not Serre self-dual; skipped)")
    print(f"  [Thm 4] chi(mirror) = (-1)^n chi(X)      : {check_euler_mirror_sign(X)}")
    print()


def main() -> None:
    print("Hodge--Deligne E-polynomial functional equations -- numerical checks\n")
    report("Genus-2 curve", genus_g_curve(2))
    report("Genus-5 curve", genus_g_curve(5))
    report("Projective plane P^2", projective_plane())
    report("K3 surface", k3_surface())
    report("Quintic Calabi-Yau threefold", quintic_threefold())

    # Aggregate sanity check across all examples.
    examples = [genus_g_curve(2), genus_g_curve(5), projective_plane(),
                k3_surface(), quintic_threefold()]
    all_ok = all(
        check_epoly_one_one(X)
        and check_mirror_equation(X)
        and check_euler_mirror_sign(X)
        and (not is_serre_self_dual(X) or check_serre_equation(X))
        for X in examples
    )
    print(f"ALL THEOREMS VERIFIED ON ALL EXAMPLES: {all_ok}")


if __name__ == "__main__":
    main()


"""
Visualization: the Hodge diamond, its mirror, and the functional-equation check.

Renders, for a chosen example diamond, three panels:
  (1) the Hodge diamond h^{p,q} as a tilted heat grid;
  (2) the mirror diamond (mirror X)^{p,q} = X^{n-p,q};
  (3) a bar chart of |E(mirror X; u,v) - (-1)^n u^n E(X; 1/u, v)| at sample
      points, which is identically zero (Theorem 2).

Produces 'hodge_epolynomial_functional_equations.png'. Requires matplotlib.
"""

from __future__ import annotations

from fractions import Fraction
from typing import Dict, List, Tuple

import matplotlib.pyplot as plt
import numpy as np

HodgeNumbers = Dict[Tuple[int, int], int]


def hpq(h: HodgeNumbers, p: int, q: int) -> int:
    return h.get((p, q), 0)


def mirror(n: int, h: HodgeNumbers) -> HodgeNumbers:
    return {(p, q): hpq(h, n - p, q)
            for p in range(n + 1) for q in range(n + 1)
            if hpq(h, n - p, q)}


def epoly(n: int, h: HodgeNumbers, u: Fraction, v: Fraction) -> Fraction:
    tot = Fraction(0)
    for p in range(n + 1):
        for q in range(n + 1):
            sign = -1 if (p + q) % 2 else 1
            tot += sign * hpq(h, p, q) * (u ** p) * (v ** q)
    return tot


def grid(n: int, h: HodgeNumbers) -> np.ndarray:
    return np.array([[hpq(h, p, q) for q in range(n + 1)]
                     for p in range(n + 1)], dtype=float)


def main() -> None:
    # K3 surface as the showcase (n = 2).
    n = 2
    h: HodgeNumbers = {(0, 0): 1, (2, 0): 1, (0, 2): 1, (2, 2): 1, (1, 1): 20}
    hm = mirror(n, h)

    fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))

    for ax, data, title in (
        (axes[0], grid(n, h), "Hodge diamond  $h^{p,q}$ (K3 surface)"),
        (axes[1], grid(n, hm), "Mirror diamond  $(\\mathrm{mirror}\\,X)^{p,q}$"),
    ):
        im = ax.imshow(data, cmap="viridis", origin="lower")
        for p in range(n + 1):
            for q in range(n + 1):
                ax.text(q, p, f"{int(data[p, q])}", ha="center", va="center",
                        color="white", fontsize=12, fontweight="bold")
        ax.set_xlabel("q")
        ax.set_ylabel("p")
        ax.set_xticks(range(n + 1))
        ax.set_yticks(range(n + 1))
        ax.set_title(title, fontsize=11)
        fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    pts: List[Tuple[Fraction, Fraction]] = [
        (Fraction(2), Fraction(3)), (Fraction(5, 2), Fraction(-7, 3)),
        (Fraction(-3), Fraction(4)), (Fraction(1, 4), Fraction(9, 5)),
        (Fraction(7, 3), Fraction(-1, 2)),
    ]
    sign = -1 if n % 2 else 1
    residuals = []
    labels = []
    for i, (u, v) in enumerate(pts):
        lhs = epoly(n, hm, u, v)
        rhs = sign * (u ** n) * epoly(n, h, 1 / u, v)
        residuals.append(float(abs(lhs - rhs)))
        labels.append(f"pt{i+1}")

    axes[2].bar(labels, residuals, color="#c0392b")
    axes[2].set_ylim(-0.5, 1.0)
    axes[2].axhline(0, color="black", linewidth=0.8)
    axes[2].set_title("$|E(\\mathrm{mirror}\\,X) - (-1)^n u^n E(X;1/u,v)|$\n"
                      "(Theorem 2: identically 0)", fontsize=10)
    axes[2].set_ylabel("residual")

    fig.suptitle("Hodge--Deligne E-polynomial: mirror functional equation",
                 fontsize=13)
    fig.tight_layout()
    fig.savefig("hodge_epolynomial_functional_equations.png", dpi=150)
    print("wrote hodge_epolynomial_functional_equations.png")


if __name__ == "__main__":
    main()
