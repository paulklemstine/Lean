"""
Numerical demonstrations for:

    The scheme-theoretic stabilizer of a regular unipotent conjugacy class
    under the center of the simply connected cover, modeled on SL_2 -> PGL_2.

Everything is elementary linear algebra over an explicit field. We verify,
by direct computation:

  1. The centralizer of the regular unipotent u = [[1,1],[0,1]] in SL_2 is
     exactly { [[a,b],[0,a]] : a^2 = 1 }.
  2. The center of SL_2 is mu_2 = { a*I : a^2 = 1 }; a matrix commuting with
     both root unipotents u and l = [[1,0],[1,1]] must be scalar.
  3. ker(pi : SL_2 -> PGL_2) = mu_2.
  4. The etale / infinitesimal dichotomy: a^2 = 1 has two roots when
     char k != 2 and the single fat root a = 1 (i.e. (a-1)^2 = 0) when
     char k = 2.

We use exact arithmetic: rationals (via fractions.Fraction) as a stand-in
for characteristic 0, and integers mod p as finite fields F_p for prime p.
"""

from __future__ import annotations

from dataclasses import dataclass
from fractions import Fraction
from itertools import product
from typing import Callable, List, Sequence, Tuple

# ---------------------------------------------------------------------------
# A tiny "field" abstraction: we only need +, -, *, and equality, plus the
# list of all elements for finite fields (to run exhaustive checks).
# ---------------------------------------------------------------------------


@dataclass(frozen=True)
class Fp:
    """An element of the prime field F_p, stored as a canonical residue."""

    value: int
    p: int

    def __post_init__(self) -> None:
        object.__setattr__(self, "value", self.value % self.p)

    def __add__(self, other: "Fp") -> "Fp":
        return Fp(self.value + other.value, self.p)

    def __sub__(self, other: "Fp") -> "Fp":
        return Fp(self.value - other.value, self.p)

    def __mul__(self, other: "Fp") -> "Fp":
        return Fp(self.value * other.value, self.p)

    def __eq__(self, other: object) -> bool:
        return isinstance(other, Fp) and self.value == other.value and self.p == other.p

    def __hash__(self) -> int:
        return hash((self.value, self.p))

    def __repr__(self) -> str:
        return f"{self.value}(mod {self.p})"


def field_Fp(p: int) -> Tuple[List[Fp], Fp, Fp]:
    """Return (all elements, zero, one) of F_p."""
    elems = [Fp(i, p) for i in range(p)]
    return elems, Fp(0, p), Fp(1, p)


# A 2x2 matrix is a tuple (m00, m01, m10, m11).
Mat = Tuple[object, object, object, object]


def mat_mul(A: Mat, B: Mat) -> Mat:
    a00, a01, a10, a11 = A
    b00, b01, b10, b11 = B
    return (
        a00 * b00 + a01 * b10,
        a00 * b01 + a01 * b11,
        a10 * b00 + a11 * b10,
        a10 * b01 + a11 * b11,
    )


def det(A: Mat) -> object:
    a00, a01, a10, a11 = A
    return a00 * a11 - a01 * a10


# ---------------------------------------------------------------------------
# 1. Centralizer of the regular unipotent over a finite field F_p.
# ---------------------------------------------------------------------------


def all_sl2(elems: Sequence[object], one: object) -> List[Mat]:
    """Enumerate all determinant-one 2x2 matrices over a finite field."""
    out: List[Mat] = []
    for a00, a01, a10, a11 in product(elems, repeat=4):
        M = (a00, a01, a10, a11)
        if det(M) == one:
            out.append(M)
    return out


def centralizer_check(p: int) -> None:
    """Verify the centralizer description of u = [[1,1],[0,1]] in SL_2(F_p)."""
    elems, zero, one = field_Fp(p)
    u: Mat = (one, one, zero, one)
    sl2 = all_sl2(elems, one)

    commuting = [M for M in sl2 if mat_mul(M, u) == mat_mul(u, M)]
    predicted = [
        M
        for M in sl2
        if M[2] == zero and M[0] == M[3] and (M[0] * M[0] == one)
    ]

    assert set(commuting) == set(predicted), "centralizer mismatch!"
    print(f"[F_{p}]  centralizer of u has {len(commuting)} elements "
          f"(matches [[a,b],[0,a]], a^2=1): OK")


# ---------------------------------------------------------------------------
# 2. Center of SL_2: commuting with u and l forces scalar.
# ---------------------------------------------------------------------------


def center_check(p: int) -> None:
    """Verify Z(SL_2(F_p)) = { a*I : a^2 = 1 }."""
    elems, zero, one = field_Fp(p)
    u: Mat = (one, one, zero, one)
    l: Mat = (one, zero, one, one)
    sl2 = all_sl2(elems, one)

    central = [
        M for M in sl2 if all(mat_mul(M, N) == mat_mul(N, M) for N in sl2)
    ]
    scalars = [
        (a, zero, zero, a) for a in elems if a * a == one
    ]

    assert set(central) == set(scalars), "center mismatch!"
    # cross-check: commuting with just u and l already pins down the center.
    from_two = [
        M for M in sl2
        if mat_mul(M, u) == mat_mul(u, M) and mat_mul(M, l) == mat_mul(l, M)
    ]
    assert set(from_two) == set(scalars), "u,l do not pin down the center!"
    print(f"[F_{p}]  center of SL_2 = mu_2, {len(central)} element(s): OK")


# ---------------------------------------------------------------------------
# 3. ker(pi : SL_2 -> PGL_2) = mu_2  (scalar determinant-one matrices).
# ---------------------------------------------------------------------------


def kernel_check(p: int) -> None:
    elems, zero, one = field_Fp(p)
    sl2 = all_sl2(elems, one)
    kernel = [
        M for M in sl2 if M[1] == zero and M[2] == zero and M[0] == M[3]
    ]
    mu2 = [(a, zero, zero, a) for a in elems if a * a == one]
    assert set(kernel) == set(mu2), "kernel mismatch!"
    print(f"[F_{p}]  ker(pi) = mu_2, {len(kernel)} element(s): OK")


# ---------------------------------------------------------------------------
# 4. The etale / infinitesimal dichotomy for a^2 = 1.
# ---------------------------------------------------------------------------


def mu2_points_Fp(p: int) -> List[int]:
    """The distinct F_p-points of mu_2 = {a : a^2 = 1}."""
    return sorted({a for a in range(p) if (a * a) % p == 1})


def mu2_points_Q() -> List[Fraction]:
    """The rational points of mu_2 (a stand-in for characteristic 0)."""
    return [a for a in (Fraction(1), Fraction(-1)) if a * a == 1]


def dichotomy_report(primes: Sequence[int]) -> None:
    print("\nEtale / infinitesimal dichotomy for mu_2  (a^2 = 1):")
    q_pts = mu2_points_Q()
    print(f"  char 0 (Q):   points = {[str(x) for x in q_pts]}  -> etale (2 points)")
    for p in primes:
        pts = mu2_points_Fp(p)
        if p == 2:
            # a^2 - 1 = (a-1)^2 in char 2: single fat root at a = 1.
            note = "-> infinitesimal (1 fat point, (a-1)^2 = 0, length 2)"
        else:
            note = "-> etale (2 points)"
        print(f"  char {p}: points = {pts}  {note}")


def verify_char2_identity() -> None:
    """In F_2, show a^2 - 1 and (a-1)^2 agree as functions on all of F_2."""
    for a in range(2):
        lhs = (a * a - 1) % 2
        rhs = ((a - 1) * (a - 1)) % 2
        assert lhs == rhs
    print("\n[F_2]  identity a^2 - 1 = (a-1)^2 holds pointwise: OK")


# ---------------------------------------------------------------------------
# Main driver.
# ---------------------------------------------------------------------------


def main() -> None:
    print("=" * 68)
    print("Regular unipotent stabilizer under the center of SL_2 -> PGL_2")
    print("=" * 68)

    print("\n(1) Centralizer of the regular unipotent u = [[1,1],[0,1]]:")
    for p in (2, 3, 5, 7):
        centralizer_check(p)

    print("\n(2) Center of SL_2 equals mu_2:")
    for p in (2, 3, 5):
        center_check(p)

    print("\n(3) Kernel of pi : SL_2 -> PGL_2 equals mu_2:")
    for p in (2, 3, 5, 7):
        kernel_check(p)

    dichotomy_report((2, 3, 5, 7, 11))
    verify_char2_identity()

    print("\nAll checks passed.")


if __name__ == "__main__":
    main()
