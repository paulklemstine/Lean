"""
Calabi-Yau fourfold Hodge diamonds, the mirror involution, and the Euler
characteristic: numerical demonstrations.

This self-contained script reproduces, by direct integer arithmetic, every
identity proved in the accompanying paper:

  * the four-number compression of a CY-fourfold Hodge diamond,
  * the closed Euler-characteristic formula  chi = 4 + 2h11 + 2h31 + h22 - 4h21,
  * the mirror reflection  p -> 4 - p  realizing the swap  h11 <-> h31,
  * involutivity of that swap,
  * mirror invariance of chi for fourfolds (even dimension) versus the
    threefold sign flip (odd dimension),
  * the Klemm-Lian-Roan-Yau collapse to  chi = 6(8 + h11 + h31 - h21).

Everything is exact: all arithmetic is over the integers.
"""

from __future__ import annotations

from dataclasses import dataclass


# --------------------------------------------------------------------------- #
#  The four free Hodge numbers of a Calabi-Yau fourfold                        #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class CY4:
    """A Calabi-Yau fourfold's independent Hodge data.

    h11 : Kaehler / divisor moduli  (h^{1,1})
    h21 : intermediate number       (h^{2,1})
    h31 : complex-structure moduli  (h^{3,1})
    h22 : middle Hodge number       (h^{2,2})
    """

    h11: int
    h21: int
    h31: int
    h22: int

    def diamond(self, p: int, q: int) -> int:
        """Full Hodge diamond entry h^{p,q} on the support 0 <= p, q <= 4.

        Built from the four free numbers via Hodge symmetry, Serre duality and
        the Calabi-Yau vanishing conditions. Off-support entries pad with 0.
        """
        table = {
            (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
            (1, 1): self.h11, (3, 3): self.h11,
            (3, 1): self.h31, (1, 3): self.h31,
            (2, 2): self.h22,
            (2, 1): self.h21, (1, 2): self.h21,
            (2, 3): self.h21, (3, 2): self.h21,
        }
        return table.get((p, q), 0)

    def swap(self) -> "CY4":
        """The mirror exchange: swap h11 <-> h31, fix h21 and h22."""
        return CY4(h11=self.h31, h21=self.h21, h31=self.h11, h22=self.h22)


# --------------------------------------------------------------------------- #
#  Generic diamond machinery (works in any complex dimension n)               #
# --------------------------------------------------------------------------- #
def euler_char(n: int, h) -> int:
    """Alternating double sum  sum_{p,q=0}^{n} (-1)^{p+q} h(p,q)."""
    total = 0
    for p in range(n + 1):
        for q in range(n + 1):
            total += (-1) ** (p + q) * h(p, q)
    return total


def mirror(n: int, h):
    """Mirror reflection of the first Hodge index: p -> n - p."""
    return lambda p, q: h(n - p, q) if n - p >= 0 else 0


# --------------------------------------------------------------------------- #
#  Closed-form predictions from the paper                                     #
# --------------------------------------------------------------------------- #
def euler_char_formula(X: CY4) -> int:
    """Theorem 3.3:  chi = 4 + 2h11 + 2h31 + h22 - 4h21."""
    return 4 + 2 * X.h11 + 2 * X.h31 + X.h22 - 4 * X.h21


def klry_h22(h11: int, h21: int, h31: int) -> int:
    """Klemm-Lian-Roan-Yau Chern relation: h22 = 2(22 + 2h11 + 2h31 - h21)."""
    return 2 * (22 + 2 * h11 + 2 * h31 - h21)


def ftheory_euler(h11: int, h21: int, h31: int) -> int:
    """Theorem 5.2:  chi = 6(8 + h11 + h31 - h21)."""
    return 6 * (8 + h11 + h31 - h21)


# --------------------------------------------------------------------------- #
#  Pretty-printing the diamond                                                #
# --------------------------------------------------------------------------- #
def render_diamond(X: CY4) -> str:
    """Render the 5x5 support of a CY4 diamond as an aligned rhombus."""
    rows = []
    for p in range(5):
        cells = [f"{X.diamond(p, q):>4}" for q in range(5)]
        rows.append("  ".join(cells))
    return "\n".join(rows)


# --------------------------------------------------------------------------- #
#  Demonstrations                                                             #
# --------------------------------------------------------------------------- #
def demo_euler_formula() -> None:
    print("=" * 68)
    print("1.  Euler characteristic: direct sum vs. closed formula")
    print("=" * 68)
    samples = [
        CY4(h11=1, h21=0, h31=3, h22=204),     # the sextic fourfold-type data
        CY4(h11=2, h21=0, h31=272, h22=1224),
        CY4(h11=4, h21=1, h31=8, h22=120),
    ]
    for X in samples:
        direct = euler_char(4, X.diamond)
        closed = euler_char_formula(X)
        print(f"  CY4{(X.h11, X.h21, X.h31, X.h22)}: "
              f"sum={direct:>7}, formula={closed:>7}, match={direct == closed}")
        assert direct == closed


def demo_diamond() -> None:
    print("\n" + "=" * 68)
    print("2.  A worked Hodge diamond (5x5 support)")
    print("=" * 68)
    X = CY4(h11=3, h21=2, h31=5, h22=100)
    print(f"  CY4(h11=3, h21=2, h31=5, h22=100):\n")
    print(render_diamond(X))
    print(f"\n  chi = {euler_char_formula(X)}")


def demo_mirror_is_swap() -> None:
    print("\n" + "=" * 68)
    print("3.  Mirror reflection (p -> 4-p) realizes the h11 <-> h31 swap")
    print("=" * 68)
    X = CY4(h11=3, h21=2, h31=5, h22=100)
    mh = mirror(4, X.diamond)
    sw = X.swap()
    all_match = all(
        mh(p, q) == sw.diamond(p, q)
        for p in range(5) for q in range(5)
    )
    print(f"  X        = CY4{(X.h11, X.h21, X.h31, X.h22)}")
    print(f"  X.swap() = CY4{(sw.h11, sw.h21, sw.h31, sw.h22)}")
    print(f"  mirror(diamond)(p,q) == swap.diamond(p,q) on all 25 cells: "
          f"{all_match}")
    assert all_match


def demo_involution() -> None:
    print("\n" + "=" * 68)
    print("4.  The mirror exchange is an involution (Z/2 action)")
    print("=" * 68)
    X = CY4(h11=7, h21=3, h31=11, h22=300)
    back = X.swap().swap()
    print(f"  X            = CY4{(X.h11, X.h21, X.h31, X.h22)}")
    print(f"  X.swap.swap  = CY4{(back.h11, back.h21, back.h31, back.h22)}")
    print(f"  swap o swap == id: {back == X}")
    assert back == X


def demo_parity_dichotomy() -> None:
    print("\n" + "=" * 68)
    print("5.  Parity dichotomy:  chi(mirror) = (-1)^n chi")
    print("=" * 68)

    # Fourfold (n=4, even): chi is mirror-invariant.
    X = CY4(h11=3, h21=2, h31=5, h22=100)
    chi4 = euler_char(4, X.diamond)
    chi4_mirror = euler_char(4, mirror(4, X.diamond))
    print(f"  n=4 (even):  chi={chi4}, chi(mirror)={chi4_mirror}, "
          f"invariant={chi4 == chi4_mirror}")
    assert chi4 == chi4_mirror

    # Threefold (n=3, odd): chi flips sign. Use a generic symmetric diamond.
    def threefold(p: int, q: int) -> int:
        t = {(0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
             (1, 1): 5, (2, 2): 5, (2, 1): 8, (1, 2): 8}
        return t.get((p, q), 0)

    chi3 = euler_char(3, threefold)
    chi3_mirror = euler_char(3, mirror(3, threefold))
    print(f"  n=3 (odd):   chi={chi3}, chi(mirror)={chi3_mirror}, "
          f"sign-flip={chi3_mirror == -chi3}")
    assert chi3_mirror == -chi3


def demo_klry() -> None:
    print("\n" + "=" * 68)
    print("6.  Klemm-Lian-Roan-Yau collapse to the F-theory Euler formula")
    print("=" * 68)
    triples = [(1, 0, 3), (2, 0, 272), (4, 1, 8), (10, 5, 50)]
    for (h11, h21, h31) in triples:
        h22 = klry_h22(h11, h21, h31)
        X = CY4(h11=h11, h21=h21, h31=h31, h22=h22)
        chi_full = euler_char_formula(X)
        chi_f = ftheory_euler(h11, h21, h31)
        tadpole = chi_full / 24
        print(f"  (h11,h21,h31)={(h11, h21, h31)}: h22={h22:>5}, "
              f"chi={chi_full:>6}, 6(8+h11+h31-h21)={chi_f:>6}, "
              f"chi/24={tadpole:>8.3f}, match={chi_full == chi_f}")
        assert chi_full == chi_f


def main() -> None:
    demo_euler_formula()
    demo_diamond()
    demo_mirror_is_swap()
    demo_involution()
    demo_parity_dichotomy()
    demo_klry()
    print("\nAll exact-arithmetic checks passed.")


if __name__ == "__main__":
    main()
