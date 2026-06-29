"""
Numerical demonstration of the Hamiltonian Compression Factor results for
Mobius-ladder cubic circulants ML(n).

This script is fully self-contained (standard library only). It exercises the
MAIN THEOREM (mobiusLadder_twoSymmetric) -- for every even n >= 4 the graph
ML(n) admits a 2-symmetric Hamiltonian cycle -- by explicitly constructing the
canonical tour and the half-turn automorphism and verifying all five defining
axioms. It also verifies cubicity (mobiusLadder_cubic) and the base-case
identifications ML(4) = K_4 and ML(6) = K_{3,3}.

Ground-truth definitions (over Z/nZ):
    diam(n)      = (n // 2) mod n
    MLAdj(n,a,b) <-> (a-b) in {1, -1, diam(n)}   (all mod n)
"""

from __future__ import annotations

from typing import Callable, List, Tuple


# ---------------------------------------------------------------------------
# Core definitions (mirroring Defs.lean)
# ---------------------------------------------------------------------------

def diam(n: int) -> int:
    """Diameter element n/2 reduced mod n."""
    return (n // 2) % n


def ml_adj(n: int, a: int, b: int) -> bool:
    """Mobius-ladder adjacency with connection set {+1, -1, n/2}."""
    d: int = (a - b) % n
    return d == 1 % n or d == (-1) % n or d == diam(n)


# ---------------------------------------------------------------------------
# The 2-symmetric Hamiltonian cycle witness (mirroring MobiusLadder.lean)
# ---------------------------------------------------------------------------

def order_map(n: int, i: int) -> int:
    """Canonical Hamiltonian cycle ordering: position i -> vertex i."""
    return i % n


def auto_map(n: int, x: int) -> int:
    """Order-2 automorphism: translation by the diameter n/2."""
    return (x + diam(n)) % n


# ---------------------------------------------------------------------------
# Axiom verification for Definition 2.3 (TwoSymHamCycle)
# ---------------------------------------------------------------------------

def verify_two_symmetric(n: int) -> dict[str, bool]:
    """Verify the five axioms of a 2-symmetric Hamiltonian cycle for ML(n)."""
    verts: range = range(n)

    consecutive: bool = all(
        ml_adj(n, order_map(n, i), order_map(n, i + 1)) for i in verts
    )

    edges: List[Tuple[int, int]] = [
        (a, b) for a in verts for b in verts if ml_adj(n, a, b)
    ]
    preserves: bool = all(
        ml_adj(n, auto_map(n, a), auto_map(n, b)) for (a, b) in edges
    )

    involutive: bool = all(auto_map(n, auto_map(n, x)) == x for x in verts)
    nontrivial: bool = any(auto_map(n, x) != x for x in verts)
    rotation: bool = all(
        auto_map(n, order_map(n, i)) == order_map(n, i + diam(n)) for i in verts
    )

    return {
        "consecutive (C)": consecutive,
        "preserves (P)": preserves,
        "involutive (I)": involutive,
        "nontrivial (N)": nontrivial,
        "rotation (R)": rotation,
    }


def is_cubic(n: int) -> bool:
    """Verify every vertex of ML(n) has exactly 3 neighbours."""
    return all(
        sum(1 for b in range(n) if ml_adj(n, a, b)) == 3 for a in range(n)
    )


# ---------------------------------------------------------------------------
# Base-case identifications (mirroring Instances.lean)
# ---------------------------------------------------------------------------

def check_ml4_is_k4() -> bool:
    """ML(4) = K_4: adjacency <-> distinctness."""
    return all(
        ml_adj(4, a, b) == (a != b) for a in range(4) for b in range(4)
    )


def check_ml6_is_k33() -> bool:
    """ML(6) = K_{3,3}: adjacency <-> opposite parity."""
    return all(
        ml_adj(6, a, b) == (a % 2 != b % 2)
        for a in range(6)
        for b in range(6)
    )


# ---------------------------------------------------------------------------
# Driver
# ---------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("Hamiltonian Compression Factor of Mobius-ladder cubic circulants")
    print("=" * 70)

    print("\n[Main theorem] 2-symmetric Hamiltonian cycle for ML(n), even n>=4:")
    for n in [4, 6, 8, 10, 12, 20, 50, 100, 1000]:
        axioms = verify_two_symmetric(n)
        ok = all(axioms.values())
        cubic = is_cubic(n)
        print(f"  n={n:5d}  diam={diam(n):4d}  "
              f"2-symmetric={ok!s:5}  cubic={cubic!s:5}")
        if n == 12:
            print("    axiom breakdown for n=12:")
            for name, val in axioms.items():
                print(f"      {name:18s}: {val}")

    print("\n[Cubicity] neighbour list of vertex 0 in ML(12):")
    nbrs = [b for b in range(12) if ml_adj(12, 0, b)]
    print(f"    N(0) = {nbrs}   (expect {{1, 11, 6}} = {{+1, -1, n/2}})")

    print("\n[Base cases]")
    print(f"  ML(4) = K_4      : {check_ml4_is_k4()}")
    print(f"  ML(6) = K_{{3,3}} : {check_ml6_is_k33()}")

    print("\n[Hamiltonian tour of ML(8)] order + half-turn images:")
    tour = [order_map(8, i) for i in range(8)]
    images = [auto_map(8, v) for v in tour]
    print(f"    tour      : {tour}")
    print(f"    half-turn : {images}   (each shifted by diam(8)={diam(8)})")

    print("\nAll checks complete.")


if __name__ == "__main__":
    main()


"""
Visualization: draw the Mobius-ladder circulant ML(n) and highlight its
2-symmetric Hamiltonian cycle together with the half-turn automorphism.

The n vertices are placed on a circle. Rim edges (+/-1) form the outer cycle;
rung edges (n/2) cross the centre. The canonical Hamiltonian tour is drawn in
bold, and each vertex i is paired by an arrow to its half-turn image i + n/2,
illustrating the order-2 rotation that certifies kappa(ML(n)) >= 2.
"""

from __future__ import annotations

import math
from typing import List, Tuple

import matplotlib.pyplot as plt


def diam(n: int) -> int:
    return (n // 2) % n


def positions(n: int) -> List[Tuple[float, float]]:
    return [
        (math.cos(2 * math.pi * i / n), math.sin(2 * math.pi * i / n))
        for i in range(n)
    ]


def draw_mobius_ladder(n: int = 12) -> None:
    pos = positions(n)
    fig, ax = plt.subplots(figsize=(7, 7))

    # rim edges (Hamiltonian cycle, bold)
    for i in range(n):
        x0, y0 = pos[i]
        x1, y1 = pos[(i + 1) % n]
        ax.plot([x0, x1], [y0, y1], color="#1f77b4", lw=3, zorder=1)

    # rung edges (diameters)
    d = diam(n)
    for i in range(n):
        j = (i + d) % n
        if i < j:
            x0, y0 = pos[i]
            x1, y1 = pos[j]
            ax.plot([x0, x1], [y0, y1], color="#d62728",
                    lw=1.2, ls="--", alpha=0.7, zorder=0)

    # half-turn arrows (i -> i + n/2) for the first half
    for i in range(n // 2):
        j = (i + d) % n
        x0, y0 = pos[i]
        x1, y1 = pos[j]
        ax.annotate("", xy=(x1 * 0.85, y1 * 0.85), xytext=(x0 * 0.85, y0 * 0.85),
                    arrowprops=dict(arrowstyle="->", color="#2ca02c", alpha=0.5))

    for i, (x, y) in enumerate(pos):
        ax.scatter([x], [y], s=320, color="white", edgecolors="black", zorder=2)
        ax.text(x, y, str(i), ha="center", va="center", zorder=3, fontsize=10)

    ax.set_title(f"ML({n}): bold = Hamiltonian cycle, dashed = rungs (n/2),\n"
                 f"green arrows = half-turn automorphism (rotation by {d})")
    ax.set_aspect("equal")
    ax.axis("off")
    plt.tight_layout()
    plt.savefig("mobius_ladder.png", dpi=150)
    print("saved mobius_ladder.png")


if __name__ == "__main__":
    draw_mobius_ladder(12)
