"""
demo.py — Numerical demonstration of the Hodge–Deligne E-polynomial framework.

This self-contained script (standard library only) reproduces, by direct
computation, the main results formalised in the accompanying mathematics:

    * EPoly(X; 1, 1) == eulerChar(X)                       (Euler specialisation)
    * EPoly(mirror X; u, v) == (-1)^n u^n EPoly(X; 1/u, v) (mirror functional eqn)
    * EPoly(X; u, v) == (uv)^n EPoly(X; 1/u, 1/v)          (Serre functional eqn,
                                                            when X is Serre-dual)
    * eulerChar(mirror X) == (-1)^n eulerChar(X)           (mirror sign law)
    * totalDim(mirror X) == totalDim(X)                    (total-dim invariance)

We work over the rationals (fractions.Fraction) so that all checks are *exact*:
no floating-point round-off enters, and equality is genuine equality.

A Hodge diamond is modelled as a dimension ``n`` together with a dictionary of
Hodge numbers ``h[(p, q)] = h^{p,q}`` (missing entries are 0).
"""

from __future__ import annotations

from dataclasses import dataclass, field
from fractions import Fraction
from typing import Callable, Dict, List, Tuple

Number = Fraction


# ---------------------------------------------------------------------------
# Core data structure
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class HodgeDiamond:
    """An abstract Hodge diamond: a complex dimension ``n`` and Hodge numbers.

    Only entries with ``0 <= p, q <= n`` are meaningful; all others are 0.
    """

    n: int
    h: Dict[Tuple[int, int], int] = field(default_factory=dict)

    def hodge(self, p: int, q: int) -> int:
        """Return h^{p,q}, defaulting to 0 outside the stored support."""
        return self.h.get((p, q), 0)

    # -- invariants --------------------------------------------------------
    def epoly(self, u: Number, v: Number) -> Number:
        """E(X; u, v) = sum_{p,q<=n} (-1)^{p+q} h^{p,q} u^p v^q  (over Q)."""
        total: Number = Fraction(0)
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                sign = -1 if (p + q) % 2 else 1
                total += sign * self.hodge(p, q) * (u ** p) * (v ** q)
        return total

    def euler_char(self) -> int:
        """chi(X) = sum_{p,q<=n} (-1)^{p+q} h^{p,q}  (an integer)."""
        total = 0
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                sign = -1 if (p + q) % 2 else 1
                total += sign * self.hodge(p, q)
        return total

    def total_dim(self) -> int:
        """b(X) = sum_{p,q<=n} h^{p,q}  (the total Betti number)."""
        return sum(self.hodge(p, q)
                   for p in range(self.n + 1)
                   for q in range(self.n + 1))

    # -- the two reflections ----------------------------------------------
    def mirror(self) -> "HodgeDiamond":
        """mirror X: the involution (p, q) -> (n - p, q) on Hodge numbers."""
        new_h: Dict[Tuple[int, int], int] = {}
        for p in range(self.n + 1):
            for q in range(self.n + 1):
                new_h[(p, q)] = self.hodge(self.n - p, q)
        return HodgeDiamond(self.n, new_h)

    def is_serre_dual(self) -> bool:
        """Test h^{p,q} = h^{n-p, n-q} on the support."""
        return all(
            self.hodge(p, q) == self.hodge(self.n - p, self.n - q)
            for p in range(self.n + 1)
            for q in range(self.n + 1)
        )


# ---------------------------------------------------------------------------
# Functional-equation checks (exact, at many sample points)
# ---------------------------------------------------------------------------
SAMPLE_POINTS: List[Tuple[Number, Number]] = [
    (Fraction(2), Fraction(3)),
    (Fraction(-1, 2), Fraction(5)),
    (Fraction(7, 3), Fraction(-4)),
    (Fraction(1), Fraction(1)),
    (Fraction(-5), Fraction(2, 7)),
]


def check_euler_specialisation(x: HodgeDiamond) -> bool:
    """E(X; 1, 1) == chi(X)."""
    return x.epoly(Fraction(1), Fraction(1)) == x.euler_char()


def check_mirror_equation(x: HodgeDiamond) -> bool:
    """E(mirror X; u, v) == (-1)^n u^n E(X; 1/u, v) for all nonzero u."""
    mx = x.mirror()
    n = x.n
    for u, v in SAMPLE_POINTS:
        if u == 0:
            continue
        lhs = mx.epoly(u, v)
        rhs = ((-1) ** n) * (u ** n) * x.epoly(1 / u, v)
        if lhs != rhs:
            return False
    return True


def check_serre_equation(x: HodgeDiamond) -> bool:
    """E(X; u, v) == (uv)^n E(X; 1/u, 1/v) for nonzero u, v (Serre-dual X)."""
    if not x.is_serre_dual():
        return True  # hypothesis not met; vacuously consistent
    n = x.n
    for u, v in SAMPLE_POINTS:
        if u == 0 or v == 0:
            continue
        lhs = x.epoly(u, v)
        rhs = ((u * v) ** n) * x.epoly(1 / u, 1 / v)
        if lhs != rhs:
            return False
    return True


def check_mirror_sign(x: HodgeDiamond) -> bool:
    """chi(mirror X) == (-1)^n chi(X)."""
    return x.mirror().euler_char() == ((-1) ** x.n) * x.euler_char()


def check_total_dim_invariance(x: HodgeDiamond) -> bool:
    """totalDim(mirror X) == totalDim(X)."""
    return x.mirror().total_dim() == x.total_dim()


def check_mirror_involutive(x: HodgeDiamond) -> bool:
    """mirror(mirror X) agrees with X on the support."""
    mm = x.mirror().mirror()
    return all(
        mm.hodge(p, q) == x.hodge(p, q)
        for p in range(x.n + 1)
        for q in range(x.n + 1)
    )


# ---------------------------------------------------------------------------
# Standard example diamonds
# ---------------------------------------------------------------------------
def elliptic_curve() -> HodgeDiamond:
    """Elliptic curve, n = 1: chi = 0 (the torus)."""
    return HodgeDiamond(1, {(0, 0): 1, (1, 0): 1, (0, 1): 1, (1, 1): 1})


def k3_surface() -> HodgeDiamond:
    """K3 surface, n = 2: chi = 24, with h^{1,1} = 20."""
    return HodgeDiamond(2, {
        (0, 0): 1, (2, 0): 1, (0, 2): 1, (1, 1): 20, (2, 2): 1,
    })


def quintic_threefold() -> HodgeDiamond:
    """Quintic Calabi-Yau threefold, n = 3: chi = -200."""
    return HodgeDiamond(3, {
        (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
        (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101,
    })


def pretty_poly(x: HodgeDiamond) -> str:
    """Render E(X; u, v) as a human-readable polynomial string."""
    terms: List[str] = []
    for p in range(x.n + 1):
        for q in range(x.n + 1):
            c = x.hodge(p, q)
            if c == 0:
                continue
            coeff = c * (-1 if (p + q) % 2 else 1)
            mono = (("u^%d" % p) if p else "") + (("v^%d" % q) if q else "")
            mono = mono or "1"
            terms.append("%+d*%s" % (coeff, mono))
    return " ".join(terms) if terms else "0"


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------
def report(name: str, x: HodgeDiamond) -> None:
    print("=" * 70)
    print(f"{name}  (complex dimension n = {x.n})")
    print("-" * 70)
    print(f"  E(X; u, v) = {pretty_poly(x)}")
    print(f"  chi(X)            = {x.euler_char()}")
    print(f"  totalDim(X)       = {x.total_dim()}")
    print(f"  Serre-dual?       = {x.is_serre_dual()}")
    mx = x.mirror()
    print(f"  chi(mirror X)     = {mx.euler_char()}   "
          f"[predicted (-1)^n chi = {((-1) ** x.n) * x.euler_char()}]")
    print("  verified identities:")
    print(f"    E(X;1,1) == chi(X)               : {check_euler_specialisation(x)}")
    print(f"    mirror functional equation       : {check_mirror_equation(x)}")
    print(f"    Serre functional equation        : {check_serre_equation(x)}")
    print(f"    mirror sign law                  : {check_mirror_sign(x)}")
    print(f"    totalDim invariance under mirror : {check_total_dim_invariance(x)}")
    print(f"    mirror is involutive             : {check_mirror_involutive(x)}")


def main() -> None:
    examples: List[Tuple[str, HodgeDiamond]] = [
        ("Elliptic curve", elliptic_curve()),
        ("K3 surface", k3_surface()),
        ("Quintic Calabi-Yau threefold", quintic_threefold()),
    ]
    for name, x in examples:
        report(name, x)

    # Highlight: the mirror of the quintic is the mirror quintic.
    print("=" * 70)
    print("Mirror symmetry of the quintic, made explicit")
    print("-" * 70)
    q = quintic_threefold()
    mq = q.mirror()
    print(f"  quintic        : h^(1,1) = {q.hodge(1, 1)},  "
          f"h^(2,1) = {q.hodge(2, 1)},  chi = {q.euler_char()}")
    print(f"  mirror quintic : h^(1,1) = {mq.hodge(1, 1)},  "
          f"h^(2,1) = {mq.hodge(2, 1)},  chi = {mq.euler_char()}")
    print("  The mirror exchanges h^(1,1) <-> h^(2,1) and flips the sign of chi,")
    print("  exactly as mirror symmetry predicts for a Calabi-Yau threefold.")
    print("=" * 70)


if __name__ == "__main__":
    main()
