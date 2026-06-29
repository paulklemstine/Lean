"""
demo.py -- Numerical demonstration of the cone-complex dimension theory of the
tropical moduli space M_g^trop.

A combinatorial type of a connected stable weighted graph of genus g is recorded
by five non-negative integers:

    vert0   : number of weight-0 vertices
    vertPos : number of positive-weight vertices
    edges   : number of edges
    weight  : total vertex weight W
    genus   : the genus g

with v := vert0 + vertPos. The geometry imposes three linear laws:

    (G) genus formula : g + v = e + 1 + W
    (S) stability     : 3 v <= 2 W + 2 e
    (C) connectedness : v <= e + 1
    (P) weight pos.   : vertPos <= W

From these we derive (and verify here numerically):

    vertex_bound        : v + 2 <= 2 g          (v <= 2g - 2)
    edge_bound          : e + 3 <= 3 g          (e <= 3g - 3)   = dim M_g^trop
    jacobianDim_eq      : b1 := e - v + 1 = g - W
    jacobianDim_nonneg  : b1 >= 0
    weight_le_genus     : W <= g
    trivalent top cone  : for trivalent (3-regular) graphs, 3v = 2e,
                          |V| = 2 b1 - 2, |E| = 3 b1 - 3

This script is fully self-contained: it enumerates all legal types for small
genus, checks every theorem on every type, and exhibits the sharp top cones.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterator


@dataclass(frozen=True)
class StableType:
    """A combinatorial type of a connected stable weighted graph of genus g."""

    vert0: int
    vertPos: int
    edges: int
    weight: int
    genus: int

    @property
    def verts(self) -> int:
        """Total number of vertices v = vert0 + vertPos."""
        return self.vert0 + self.vertPos

    @property
    def jacobian_dim(self) -> int:
        """First Betti number b1 = e - v + 1 = dim of the tropical Jacobian."""
        return self.edges - self.verts + 1

    def is_legal(self) -> bool:
        """Check the four structural relations (G), (S), (C), (P)."""
        v, e, w, g = self.verts, self.edges, self.weight, self.genus
        return (
            g + v == e + 1 + w               # (G) genus formula
            and 3 * v <= 2 * w + 2 * e       # (S) stability
            and v <= e + 1                   # (C) connectedness
            and self.vertPos <= w            # (P) weight positivity
        )


def enumerate_types(g: int) -> Iterator[StableType]:
    """Enumerate every legal combinatorial type of genus g.

    By the finiteness theorem every legal vector lies in the finite box
    [0, 2g] x [0, 2g] x [0, 3g] x [0, g], so we iterate over it and filter.
    """
    for v0 in range(0, 2 * g + 1):
        for vp in range(0, 2 * g + 1):
            for e in range(0, 3 * g + 1):
                for w in range(0, g + 1):
                    t = StableType(v0, vp, e, w, g)
                    if t.is_legal():
                        yield t


def check_theorems(t: StableType) -> dict[str, bool]:
    """Verify every headline theorem on a single legal type."""
    v, e, w, g = t.verts, t.edges, t.weight, t.genus
    b1 = t.jacobian_dim
    return {
        "vertex_bound  (v + 2 <= 2g)": v + 2 <= 2 * g,
        "edge_bound    (e + 3 <= 3g)": e + 3 <= 3 * g,
        "jacobianDim_eq (b1 = g - W)": b1 == g - w,
        "jacobianDim_nonneg (b1>=0)": b1 >= 0,
        "weight_le_genus (W <= g)": w <= g,
    }


def top_type(g: int) -> StableType:
    """The trivalent top cone topType g = (2g-2, 0, 3g-3, 0, g) for g >= 2."""
    return StableType(vert0=2 * g - 2, vertPos=0, edges=3 * g - 3, weight=0, genus=g)


def is_trivalent_top(t: StableType) -> bool:
    """A weight-0 type realizes a trivalent top cone iff 3v = 2e (handshake)."""
    return t.weight == 0 and 3 * t.verts == 2 * t.edges


def demo() -> None:
    print("=" * 70)
    print("Tropical moduli space M_g^trop : dimension theory by counting")
    print("=" * 70)

    for g in range(2, 6):
        types = list(enumerate_types(g))
        max_edges = max(t.edges for t in types)
        max_verts = max(t.verts for t in types)
        max_b1 = max(t.jacobian_dim for t in types)

        print(f"\n--- genus g = {g} ---")
        print(f"  number of legal combinatorial types : {len(types)}")
        print(f"  predicted dimension 3g - 3          : {3 * g - 3}")
        print(f"  observed max edges (= dim)          : {max_edges}")
        print(f"  predicted max vertices 2g - 2       : {2 * g - 2}")
        print(f"  observed max vertices               : {max_verts}")
        print(f"  predicted max Jacobian dim (= g)    : {g}")
        print(f"  observed max b1                     : {max_b1}")

        assert max_edges == 3 * g - 3, "edge bound not sharp!"
        assert max_verts == 2 * g - 2, "vertex bound not sharp!"

        # Verify every theorem on every type.
        for t in types:
            for name, ok in check_theorems(t).items():
                assert ok, f"FAILED {name} on {t}"

        # The trivalent top type realizes the bound.
        tt = top_type(g)
        assert tt.is_legal(), "top type illegal!"
        assert is_trivalent_top(tt), "top type not trivalent!"
        print(f"  trivalent top type topType({g})       : "
              f"V={tt.verts}, E={tt.edges}, W={tt.weight}, b1={tt.jacobian_dim}")
        print(f"    check |V| = 2 b1 - 2 : {tt.verts} = {2 * tt.jacobian_dim - 2}")
        print(f"    check |E| = 3 b1 - 3 : {tt.edges} = {3 * tt.jacobian_dim - 3}")

    print("\n" + "=" * 70)
    print("Genus 2 : the complete catalogue of combinatorial types")
    print("=" * 70)
    print(f"{'v0':>3} {'vp':>3} {'e':>3} {'W':>3} {'v':>3} {'b1=g-W':>7} "
          f"{'conedim':>8} {'trivalent?':>11}")
    for t in sorted(enumerate_types(2), key=lambda s: (-s.edges, -s.verts)):
        print(f"{t.vert0:>3} {t.vertPos:>3} {t.edges:>3} {t.weight:>3} "
              f"{t.verts:>3} {t.jacobian_dim:>7} {t.edges:>8} "
              f"{str(is_trivalent_top(t)):>11}")

    print("\nAll theorems verified on every enumerated type. Dimension = 3g - 3.")


if __name__ == "__main__":
    demo()


"""
visualize.py -- Visualizations of the tropical moduli space M_g^trop dimension theory.

Produces two figures:
  1. The linear growth of dim M_g^trop = 3g - 3 and max vertices 2g - 2.
  2. The growth in the number of legal combinatorial types per genus.

Self-contained: enumerates types directly.
"""

from __future__ import annotations

from typing import Iterator

import matplotlib.pyplot as plt


def legal_types(g: int) -> Iterator[tuple[int, int, int, int]]:
    """Yield legal invariant vectors (v0, vp, e, w) of genus g."""
    for v0 in range(0, 2 * g + 1):
        for vp in range(0, 2 * g + 1):
            for e in range(0, 3 * g + 1):
                for w in range(0, g + 1):
                    v = v0 + vp
                    if (g + v == e + 1 + w
                            and 3 * v <= 2 * w + 2 * e
                            and v <= e + 1
                            and vp <= w):
                        yield (v0, vp, e, w)


def main() -> None:
    genera = list(range(2, 11))
    dim = [3 * g - 3 for g in genera]
    maxv = [2 * g - 2 for g in genera]
    counts = [sum(1 for _ in legal_types(g)) for g in genera]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.plot(genera, dim, "o-", label="dim M_g^trop = 3g - 3", color="#c0392b")
    ax1.plot(genera, maxv, "s-", label="max vertices = 2g - 2", color="#2980b9")
    ax1.set_xlabel("genus g")
    ax1.set_ylabel("dimension / vertices")
    ax1.set_title("Dimension theory of M_g^trop")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.bar(genera, counts, color="#27ae60", alpha=0.8)
    ax2.set_xlabel("genus g")
    ax2.set_ylabel("number of legal combinatorial types")
    ax2.set_title("Finiteness of the cone complex")
    ax2.grid(True, axis="y", alpha=0.3)

    fig.tight_layout()
    fig.savefig("tropical_moduli_dimension.png", dpi=150)
    print("saved tropical_moduli_dimension.png")


if __name__ == "__main__":
    main()
