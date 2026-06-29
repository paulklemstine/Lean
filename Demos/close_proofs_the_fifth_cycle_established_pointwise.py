"""
demo.py — Calabi-Yau Fourfold Hodge Diamonds, Mirror Symmetry, and the
F-theory Euler Formula.

Self-contained numerical demonstration of the five exact results:

  1. Euler characteristic of the diamond:
       chi = 4 + 2*h11 + 2*h31 + h22 - 4*h21
  2. Mirror reflection (p -> 4 - p) on the support equals swapping h11 <-> h31.
  3. The mirror swap is an involution.
  4. chi is mirror-invariant for fourfolds (because 4 is even, (-1)^4 = +1).
  5. KLRY relation h22 = 2*(22 + 2*h11 + 2*h31 - h21) collapses chi to the
     F-theory formula chi = 6*(8 + h11 + h31 - h21).

All arithmetic is exact integer arithmetic. No external dependencies.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Tuple


# ---------------------------------------------------------------------------
# Definition 2.1 / 2.2 : the four free Hodge numbers and the full diamond
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class CY4:
    """The four independent Hodge numbers of a Calabi-Yau fourfold."""
    h11: int  # Kahler / divisor moduli
    h21: int  # mixed deformation number
    h31: int  # complex-structure moduli
    h22: int  # central Hodge number

    def diamond(self, p: int, q: int) -> int:
        """Full Hodge diamond h^{p,q}; meaningful only on 0 <= p,q <= 4."""
        table: Dict[Tuple[int, int], int] = {
            (0, 0): 1, (4, 4): 1, (0, 4): 1, (4, 0): 1,
            (1, 1): self.h11, (3, 3): self.h11,
            (3, 1): self.h31, (1, 3): self.h31,
            (2, 2): self.h22,
            (2, 1): self.h21, (1, 2): self.h21,
            (2, 3): self.h21, (3, 2): self.h21,
        }
        return table.get((p, q), 0)

    def swap(self) -> "CY4":
        """Mirror exchange: swap h11 <-> h31, fix h21 and h22."""
        return CY4(h11=self.h31, h21=self.h21, h31=self.h11, h22=self.h22)


# ---------------------------------------------------------------------------
# Definition 2.3 : Euler-characteristic functional (signed sum over grid)
# ---------------------------------------------------------------------------
def euler_char(X: CY4, n: int = 4) -> int:
    """eulerChar n = sum_{p,q=0}^{n} (-1)^(p+q) * diamond(p,q)."""
    total = 0
    for p in range(n + 1):
        for q in range(n + 1):
            total += ((-1) ** (p + q)) * X.diamond(p, q)
    return total


def euler_char_formula(X: CY4) -> int:
    """Theorem 3.1: chi = 4 + 2*h11 + 2*h31 + h22 - 4*h21."""
    return 4 + 2 * X.h11 + 2 * X.h31 + X.h22 - 4 * X.h21


def mirror_diamond(X: CY4, p: int, q: int) -> int:
    """Catalog mirror reflection of first index: mirror(p,q) = diamond(4-p, q)."""
    pr = 4 - p if p <= 4 else 0  # N-truncated reflection on the support
    return X.diamond(pr, q)


def klry_h22(h11: int, h21: int, h31: int) -> int:
    """KLRY Chern-class relation for the central Hodge number."""
    return 2 * (22 + 2 * h11 + 2 * h31 - h21)


def euler_char_klry(h11: int, h21: int, h31: int) -> int:
    """Theorem 3.6: F-theory Euler formula chi = 6*(8 + h11 + h31 - h21)."""
    return 6 * (8 + h11 + h31 - h21)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def print_diamond(X: CY4) -> None:
    print("    Hodge diamond h^{p,q} (rows p=0..4, cols q=0..4):")
    for p in range(5):
        row = "      " + " ".join(f"{X.diamond(p, q):>4}" for q in range(5))
        print(row)


def demo_euler_characteristic() -> None:
    print("=" * 70)
    print("RESULT 1 — Euler characteristic = 4 + 2h11 + 2h31 + h22 - 4h21")
    print("=" * 70)
    examples = [
        CY4(h11=3,  h21=0,   h31=2796, h22=11212),   # sextic in P^5 (toy values)
        CY4(h11=1,  h21=0,   h31=1,    h22=10),
        CY4(h11=5,  h21=7,   h31=11,   h22=100),
    ]
    for X in examples:
        s = euler_char(X)            # explicit signed sum
        f = euler_char_formula(X)    # closed form
        print(f"\n  CY4{X}")
        print_diamond(X)
        print(f"    signed-sum chi = {s},  closed-form chi = {f},  match = {s == f}")


def demo_mirror_swap() -> None:
    print("\n" + "=" * 70)
    print("RESULT 2 & 3 — mirror reflection == swap(h11,h31); swap is an involution")
    print("=" * 70)
    X = CY4(h11=5, h21=7, h31=11, h22=100)
    Y = X.swap()
    print(f"\n  X       = {X}")
    print(f"  swap(X) = {Y}")
    # Result 2: mirror reflection equals swapped diamond on support p,q <= 4
    ok = all(mirror_diamond(X, p, q) == Y.diamond(p, q)
             for p in range(5) for q in range(5))
    print(f"  mirror(X) == swap(X).diamond on support p,q<=4 : {ok}")
    # Result 3: involution
    print(f"  swap(swap(X)) == X : {X.swap().swap() == X}")


def demo_mirror_invariance() -> None:
    print("\n" + "=" * 70)
    print("RESULT 4 — chi is mirror-invariant for fourfolds ((-1)^4 = +1)")
    print("=" * 70)
    for X in [CY4(5, 7, 11, 100), CY4(3, 0, 2796, 11212), CY4(2, 4, 6, 8)]:
        cx, cy = euler_char(X), euler_char(X.swap())
        print(f"  chi(X)={cx:>8}  chi(swap X)={cy:>8}  invariant={cx == cy}")
    print("\n  Contrast (threefold lens): mirror flips sign chi -> -chi, since")
    print("  (-1)^3 = -1.  The parity of the dimension is the whole story.")


def demo_klry_collapse() -> None:
    print("\n" + "=" * 70)
    print("RESULT 5 — KLRY relation collapses chi to 6*(8 + h11 + h31 - h21)")
    print("=" * 70)
    for (h11, h21, h31) in [(3, 0, 2796), (5, 7, 11), (1, 0, 1)]:
        h22 = klry_h22(h11, h21, h31)
        X = CY4(h11=h11, h21=h21, h31=h31, h22=h22)
        general = euler_char_formula(X)
        ftheory = euler_char_klry(h11, h21, h31)
        print(f"\n  (h11,h21,h31)=({h11},{h21},{h31}) -> KLRY h22={h22}")
        print(f"    general chi = {general}")
        print(f"    F-theory 6*(8+h11+h31-h21) = {ftheory}")
        print(f"    match = {general == ftheory},  chi divisible by 6 = {general % 6 == 0}")
        print(f"    D3 tadpole chi/24 = {general / 24}")


def main() -> None:
    demo_euler_characteristic()
    demo_mirror_swap()
    demo_mirror_invariance()
    demo_klry_collapse()
    print("\n" + "=" * 70)
    print("All five exact identities verified numerically.")
    print("=" * 70)


if __name__ == "__main__":
    main()
