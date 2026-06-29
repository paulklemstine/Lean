"""
Visualization: the mirror as a vertical reflection of the Hodge diamond, and the
Euler-number sign flip across complex dimension. Produces a two-panel figure.

Run:  python3 _viz.py   ->  writes arithmetic_mirror.png
"""

from __future__ import annotations

from typing import Dict, Tuple

import matplotlib.pyplot as plt
import numpy as np


def diamond_grid(table: Dict[Tuple[int, int], int], d: int) -> np.ndarray:
    """Return a (d+1) x (d+1) array g[q, p] = h(p, q)."""
    g = np.zeros((d + 1, d + 1), dtype=int)
    for p in range(d + 1):
        for q in range(d + 1):
            g[q, p] = table.get((p, q), 0)
    return g


def mirror_table(table: Dict[Tuple[int, int], int], d: int) -> Dict[Tuple[int, int], int]:
    """Vertical reflection p -> d - p."""
    return {(p, q): table.get((d - p, q), 0)
            for p in range(d + 1) for q in range(d + 1)}


def draw_diamond(ax, table: Dict[Tuple[int, int], int], d: int, title: str) -> None:
    g = diamond_grid(table, d)
    im = ax.imshow(g, cmap="magma", origin="lower")
    for p in range(d + 1):
        for q in range(d + 1):
            ax.text(p, q, str(g[q, p]), ha="center", va="center",
                    color="white" if g[q, p] < g.max() / 2 else "black",
                    fontsize=11, fontweight="bold")
    ax.set_title(title, fontsize=12)
    ax.set_xlabel("p  (column index)")
    ax.set_ylabel("q  (row index)")
    ax.set_xticks(range(d + 1))
    ax.set_yticks(range(d + 1))
    return im


def main() -> None:
    # quintic threefold, d = 3
    d = 3
    X = {(0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,
         (1, 1): 1, (2, 2): 1, (2, 1): 101, (1, 2): 101}
    Y = mirror_table(X, d)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    draw_diamond(axes[0], X, d, "Quintic X : h(1,1)=1, h(2,1)=101")
    draw_diamond(axes[1], Y, d, "Mirror Y = reflect p->d-p : h(1,1)=101")
    fig.suptitle("Arithmetic Mirror Symmetry: Picard rank of Y = curve count of X",
                 fontsize=14, fontweight="bold")
    fig.tight_layout()
    fig.savefig("arithmetic_mirror.png", dpi=130)
    print("wrote arithmetic_mirror.png")


if __name__ == "__main__":
    main()


"""
Arithmetic Mirror Symmetry for Calabi-Yau: numerical demonstrations.

This self-contained script models a Calabi-Yau Hodge diamond as a function
h(p, q) on natural-number indices, subject to three axioms:

  * conjugation symmetry : h(p, q) = h(q, p)         for 0 <= p, q <= d
  * Serre duality        : h(p, q) = h(d-p, d-q)      for 0 <= p, q <= d
  * finite support       : h(p, q) = 0                if p > d or q > d

The mirror is the guarded vertical reflection

  mirror_h(p, q) = h(d - p, q)   if  0 <= p, q <= d ,  else 0 .

We numerically verify, for several concrete Calabi-Yau diamonds, the theorems
proved formally in the companion Lean development:

  * reflect_eq         : h(d-p, q) = h(d-q, p)
  * mirror closure     : the mirror satisfies all three diamond axioms
  * mirror_involutive  : mirror(mirror(X)) = X
  * picardRank_mirror  : picardRank(mirror X) = h(d-1, 1)   (the curve count)
  * eulerChar_mirror   : chi(mirror X) = (-1)^d * chi(X)
  * K3 example         : chi(K3) = 24,  picardRank(K3) = 20,  self-mirror
"""

from __future__ import annotations

from typing import Callable, Dict, List, Tuple

# A Hodge diamond is modeled as a function h : (p, q) -> non-negative int.
Diamond = Callable[[int, int], int]


def from_table(table: Dict[Tuple[int, int], int]) -> Diamond:
    """Build a Hodge-diamond function from a sparse {(p, q): value} table."""
    def h(p: int, q: int) -> int:
        return table.get((p, q), 0)
    return h


def is_calabi_yau(h: Diamond, d: int) -> bool:
    """Check the three Calabi-Yau diamond axioms on the box [0, d]^2 (plus a
    margin to test finite support)."""
    for p in range(d + 1):
        for q in range(d + 1):
            if h(p, q) != h(q, p):                       # conjugation symmetry
                return False
            if h(p, q) != h(d - p, d - q):               # Serre duality
                return False
    # finite support: vanish just outside the box
    for p in range(d + 2):
        for q in range(d + 2):
            if (p > d or q > d) and h(p, q) != 0:
                return False
    return True


def mirror(h: Diamond, d: int) -> Diamond:
    """The guarded vertical reflection p -> d - p (the mirror diamond)."""
    def mh(p: int, q: int) -> int:
        if 0 <= p <= d and 0 <= q <= d:
            return h(d - p, q)
        return 0
    return mh


def picard_rank(h: Diamond) -> int:
    """The Picard rank h^{1,1} (rank of the Neron-Severi / Picard group)."""
    return h(1, 1)


def euler_char(h: Diamond, d: int) -> int:
    """The Euler characteristic chi = sum_{p,q} (-1)^{p+q} h(p, q)."""
    total = 0
    for p in range(d + 1):
        for q in range(d + 1):
            total += (-1) ** (p + q) * h(p, q)
    return total


def reflect_eq_holds(h: Diamond, d: int) -> bool:
    """reflect_eq : h(d-p, q) = h(d-q, p) for all p, q in [0, d]."""
    return all(
        h(d - p, q) == h(d - q, p)
        for p in range(d + 1) for q in range(d + 1)
    )


def involutive_holds(h: Diamond, d: int) -> bool:
    """mirror(mirror(X)) = X on the box [0, d]^2."""
    mm = mirror(mirror(h, d), d)
    return all(
        mm(p, q) == h(p, q)
        for p in range(d + 1) for q in range(d + 1)
    )


def show_diamond(h: Diamond, d: int, name: str) -> None:
    """Pretty-print a Hodge diamond, rotated 45 degrees."""
    print(f"  Hodge diamond of {name} (d = {d}):")
    width = 2 * d + 1
    for s in range(2 * d + 1):          # s = p + q runs over anti-diagonals
        row: List[str] = []
        for p in range(d + 1):
            q = s - p
            if 0 <= q <= d:
                row.append(str(h(p, q)))
        line = "   ".join(row)
        pad = " " * (2 * (width - len(row)))
        print("    " + pad + line)
    print()


# --------------------------------------------------------------------------
# Example diamonds
# --------------------------------------------------------------------------

# K3 surface (d = 2): self-mirror, chi = 24, Picard rank 20.
K3 = from_table({
    (0, 0): 1, (2, 2): 1,
    (2, 0): 1, (0, 2): 1,
    (1, 1): 20,
})

# The quintic threefold X (d = 3): h^{1,1} = 1, h^{2,1} = 101, chi = -200.
QUINTIC = from_table({
    (0, 0): 1, (3, 3): 1, (3, 0): 1, (0, 3): 1,      # h^{0,0}=h^{3,3}=h^{3,0}=h^{0,3}=1
    (1, 1): 1, (2, 2): 1,                            # h^{1,1}=h^{2,2}=1
    (2, 1): 101, (1, 2): 101,                        # h^{2,1}=h^{1,2}=101
})


def demo() -> None:
    print("=" * 70)
    print("Arithmetic Mirror Symmetry for Calabi-Yau")
    print("=" * 70)
    print()

    # ---- K3 surface --------------------------------------------------------
    d = 2
    print("[1] K3 surface (d = 2)")
    show_diamond(K3, d, "K3")
    assert is_calabi_yau(K3, d), "K3 fails the Calabi-Yau axioms!"
    print(f"  is_calabi_yau(K3)            = {is_calabi_yau(K3, d)}")
    print(f"  reflect_eq holds            = {reflect_eq_holds(K3, d)}")
    print(f"  mirror is Calabi-Yau        = {is_calabi_yau(mirror(K3, d), d)}")
    print(f"  mirror is involutive        = {involutive_holds(K3, d)}")
    print(f"  picardRank(K3)              = {picard_rank(K3)}")
    print(f"  picardRank(mirror K3)       = {picard_rank(mirror(K3, d))}")
    print(f"  h(d-1, 1) = h(1,1)          = {K3(d - 1, 1)}   (curve count)")
    print(f"  chi(K3)                     = {euler_char(K3, d)}")
    print(f"  chi(mirror K3)              = {euler_char(mirror(K3, d), d)}")
    print(f"  (-1)^d * chi(K3)            = {(-1)**d * euler_char(K3, d)}")
    assert euler_char(K3, d) == 24
    assert picard_rank(K3) == 20
    assert picard_rank(mirror(K3, d)) == K3(d - 1, 1)
    assert euler_char(mirror(K3, d), d) == (-1) ** d * euler_char(K3, d)
    print("  -> K3 is self-mirror: chi = 24, Picard rank 20.  [OK]")
    print()

    # ---- Quintic threefold and its mirror ---------------------------------
    d = 3
    print("[2] Quintic threefold (d = 3) and its mirror")
    show_diamond(QUINTIC, d, "quintic X")
    assert is_calabi_yau(QUINTIC, d), "quintic fails the Calabi-Yau axioms!"
    Y = mirror(QUINTIC, d)
    show_diamond(Y, d, "mirror Y")
    print(f"  is_calabi_yau(X)            = {is_calabi_yau(QUINTIC, d)}")
    print(f"  mirror Y is Calabi-Yau      = {is_calabi_yau(Y, d)}")
    print(f"  mirror is involutive        = {involutive_holds(QUINTIC, d)}")
    print(f"  picardRank(X) = h^{{1,1}}(X)  = {picard_rank(QUINTIC)}")
    print(f"  h^{{d-1,1}}(X) = h^{{2,1}}(X)   = {QUINTIC(d - 1, 1)}  (curve count on X)")
    print(f"  picardRank(Y) = h^{{1,1}}(Y)  = {picard_rank(Y)}")
    print(f"  chi(X)                      = {euler_char(QUINTIC, d)}")
    print(f"  chi(Y)                      = {euler_char(Y, d)}")
    print(f"  (-1)^d * chi(X)             = {(-1)**d * euler_char(QUINTIC, d)}")
    assert picard_rank(Y) == QUINTIC(d - 1, 1)            # arithmetic mirror symmetry
    assert euler_char(Y, d) == (-1) ** d * euler_char(QUINTIC, d)
    print("  -> Picard rank of mirror = curve count of X (101);")
    print("     chi flips sign in odd dimension: chi(Y) = -chi(X) = +200.  [OK]")
    print()

    print("All theorems verified numerically.")


if __name__ == "__main__":
    demo()
