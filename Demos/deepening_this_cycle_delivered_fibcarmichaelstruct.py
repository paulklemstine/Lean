"""
Calabi-Yau Fourfold Hodge Diamonds: numerical demonstrations.

Self-contained Python (standard library only) reproducing the exact integer
identities established for the Hodge diamond of a smooth Calabi-Yau fourfold:

  * the four-parameter reconstruction of the 5x5 diamond,
  * the Euler characteristic    chi = 4 + 2*h11 + 2*h31 + h22 - 4*h21,
  * the mirror exchange          h11 <-> h31  (an involution),
  * even-dimensional invariance  chi(mirror X) = chi(X),
  * the KLRY / F-theory formula  chi = 6*(8 + h11 + h31 - h21).

Run `python demo.py` to see all checks pass.
"""

from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class CY4:
    """The four independent Hodge numbers of a Calabi-Yau fourfold."""
    h11: int  # Kahler / divisor moduli
    h21: int
    h31: int  # complex-structure moduli
    h22: int  # central Hodge number


def diamond(X: CY4, p: int, q: int) -> int:
    """The reconstructed Hodge diamond h^{p,q} for 0 <= p,q (support is p,q <= 4).

    Built from the four free numbers via Hodge symmetry (h^{p,q}=h^{q,p}),
    Serre duality (h^{p,q}=h^{4-p,4-q}) and the Calabi-Yau vanishing conditions.
    """
    table = {
        (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
        (1, 1): X.h11, (3, 3): X.h11,
        (3, 1): X.h31, (1, 3): X.h31,
        (2, 2): X.h22,
        (2, 1): X.h21, (1, 2): X.h21, (2, 3): X.h21, (3, 2): X.h21,
    }
    return table.get((p, q), 0)


def euler_char(X: CY4, n: int = 4) -> int:
    """Alternating double sum  sum_{p,q=0}^{n} (-1)^{p+q} h^{p,q}."""
    return sum(
        (-1) ** (p + q) * diamond(X, p, q)
        for p in range(n + 1)
        for q in range(n + 1)
    )


def euler_char_closed(X: CY4) -> int:
    """Closed form (Theorem): chi = 4 + 2 h11 + 2 h31 + h22 - 4 h21."""
    return 4 + 2 * X.h11 + 2 * X.h31 + X.h22 - 4 * X.h21


def mirror_diamond(X: CY4, p: int, q: int) -> int:
    """Catalog mirror reflection of the first Hodge index: h(4-p, q)."""
    pr = 4 - p if p <= 4 else 0
    return diamond(X, pr, q)


def swap(X: CY4) -> CY4:
    """Mirror exchange on free data: h11 <-> h31, fixing h21, h22."""
    return CY4(h11=X.h31, h21=X.h21, h31=X.h11, h22=X.h22)


def klry_h22(h11: int, h31: int, h21: int) -> int:
    """KLRY Chern-class relation: h22 = 2(22 + 2 h11 + 2 h31 - h21)."""
    return 2 * (22 + 2 * h11 + 2 * h31 - h21)


def euler_char_ftheory(h11: int, h31: int, h21: int) -> int:
    """F-theory formula: chi = 6(8 + h11 + h31 - h21)."""
    return 6 * (8 + h11 + h31 - h21)


def print_diamond(X: CY4) -> None:
    """Pretty-print the 5x5 diamond as a grid (rows p=0..4, cols q=0..4)."""
    for p in range(5):
        print("  ".join(f"{diamond(X, p, q):>4}" for q in range(5)))


def demo() -> None:
    print("=" * 64)
    print("Calabi-Yau Fourfold Hodge Diamonds -- numerical demonstration")
    print("=" * 64)

    samples = [
        CY4(h11=1, h21=1, h31=1, h22=klry_h22(1, 1, 1)),
        CY4(h11=3, h21=2, h31=7, h22=klry_h22(3, 7, 2)),
        CY4(h11=12, h21=0, h31=140, h22=klry_h22(12, 140, 0)),  # sextic-type
    ]

    for X in samples:
        print(f"\nCY4 data: {X}")
        print("Hodge diamond (rows p=0..4, cols q=0..4):")
        print_diamond(X)

        chi_sum = euler_char(X)
        chi_closed = euler_char_closed(X)
        print(f"  Euler char (alternating sum) : {chi_sum}")
        print(f"  Euler char (closed form)     : {chi_closed}")
        assert chi_sum == chi_closed, "Theorem 4.1 failed"

        # F-theory formula (KLRY-constrained samples)
        chi_ft = euler_char_ftheory(X.h11, X.h31, X.h21)
        print(f"  Euler char (F-theory 6(8+..)): {chi_ft}")
        assert chi_sum == chi_ft, "Theorem 7.1 failed"
        assert chi_sum % 6 == 0, "chi should be divisible by 6"

        # Mirror exchange + invariance
        Xm = swap(X)
        print(f"  Mirror data (h11<->h31)      : {Xm}")
        assert swap(Xm) == X, "Theorem 5.3 (involution) failed"
        for p in range(5):
            for q in range(5):
                assert mirror_diamond(X, p, q) == diamond(Xm, p, q), \
                    "Theorem 5.2 (mirror=swap on support) failed"
        assert euler_char(Xm) == euler_char(X), "Theorem 6.1 (invariance) failed"
        print(f"  Euler char of mirror         : {euler_char(Xm)}  (== chi, invariant)")

    # Catalog mirror invariance for an *arbitrary* diamond (Theorem 6.2):
    # eulerChar 4 (mirror 4 h) = (-1)^4 eulerChar 4 h = eulerChar 4 h.
    arbitrary = CY4(h11=5, h21=-3, h31=11, h22=99)  # not KLRY-constrained
    chi = euler_char(arbitrary)
    chi_mirror = sum(
        (-1) ** (p + q) * mirror_diamond(arbitrary, p, q)
        for p in range(5) for q in range(5)
    )
    print("\nArbitrary (non-KLRY) diamond, catalog mirror invariance (Thm 6.2):")
    print(f"  chi = {chi},  chi(mirror) = {chi_mirror}  -> equal: {chi == chi_mirror}")
    assert chi == chi_mirror

    # Contrast: threefold mirror flips the sign (chi -> -chi).
    def threefold_euler(diag: dict[tuple[int, int], int]) -> int:
        return sum((-1) ** (p + q) * diag.get((p, q), 0)
                   for p in range(4) for q in range(4))

    # A toy CY threefold diamond with h11=2, h21=5.
    cy3 = {
        (0, 0): 1, (3, 3): 1, (0, 3): 1, (3, 0): 1,
        (1, 1): 2, (2, 2): 2,
        (2, 1): 5, (1, 2): 5, (2, 0): 0,  # padding shown for clarity
    }
    cy3_mirror = {(3 - p, q): v for (p, q), v in cy3.items() if p <= 3}
    chi3 = threefold_euler(cy3)
    chi3m = threefold_euler(cy3_mirror)
    print("\nContrast -- threefold (n=3, odd): mirror flips the sign:")
    print(f"  chi3 = {chi3},  chi3(mirror) = {chi3m}  -> chi3(mirror) == -chi3: "
          f"{chi3m == -chi3}")

    print("\nAll identities verified.  (n=4 even -> invariance; n=3 odd -> sign flip)")
    print("=" * 64)


if __name__ == "__main__":
    demo()
