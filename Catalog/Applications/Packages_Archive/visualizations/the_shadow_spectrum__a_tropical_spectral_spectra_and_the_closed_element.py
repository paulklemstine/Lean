"""
Visualization: spectral sizes and the closed-element sublattice.
Generates two panels:
  (left)  bar chart of spectral size for several residuated actions,
  (right) Hasse-style scatter of the powerset lattice 2^{a,b,c} with closed
          elements (fixed points of a projection closure) highlighted.
Requires matplotlib.
"""
from itertools import product
from typing import FrozenSet, List, Tuple
import matplotlib.pyplot as plt


def powerset(ground: List[str]) -> List[FrozenSet[str]]:
    out = []
    for bits in product([0, 1], repeat=len(ground)):
        out.append(frozenset(g for g, b in zip(ground, bits) if b))
    return out


def main() -> None:
    ground = ["a", "b", "c"]
    elems = powerset(ground)
    mask = frozenset({"a", "b"})
    comp = frozenset(ground) - mask
    # projection closure cl(X) = (X & mask) | comp
    def cl(X: FrozenSet[str]) -> FrozenSet[str]:
        return (X & mask) | comp
    closed = {X for X in elems if cl(X) == X}

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    # ---- left: spectral sizes ----
    names = ["Bool id", "Bool const-false", "2^abc proj{a,b}", "2^abc id"]
    sizes = [2, 1, len(closed), len(elems)]
    bars = ax1.bar(names, sizes, color=["#4c72b0", "#c44e52", "#55a868", "#8172b3"])
    ax1.set_title("Spectral size (number of closed elements)")
    ax1.set_ylabel("spectral size")
    ax1.tick_params(axis="x", rotation=20)
    for b, s in zip(bars, sizes):
        ax1.text(b.get_x() + b.get_width() / 2, s + 0.05, str(s), ha="center")

    # ---- right: powerset Hasse layout ----
    layers: dict = {}
    for X in elems:
        layers.setdefault(len(X), []).append(X)
    pos = {}
    for k, layer in layers.items():
        layer = sorted(layer, key=lambda s: sorted(s))
        for i, X in enumerate(layer):
            pos[X] = (i - (len(layer) - 1) / 2, k)
    for X in elems:
        for Y in elems:
            if X < Y and len(Y) == len(X) + 1:
                x1, y1 = pos[X]; x2, y2 = pos[Y]
                ax2.plot([x1, x2], [y1, y2], color="#cccccc", zorder=1)
    for X in elems:
        x, y = pos[X]
        is_closed = X in closed
        ax2.scatter([x], [y], s=520,
                    color="#55a868" if is_closed else "#dddddd",
                    edgecolors="black", zorder=2)
        ax2.text(x, y, "{" + ",".join(sorted(X)) + "}" if X else "0",
                 ha="center", va="center", fontsize=8)
    ax2.set_title("2^{a,b,c}: closed elements (green) under projection onto {a,b}")
    ax2.axis("off")

    plt.tight_layout()
    plt.savefig("tropical_spectrum.png", dpi=140)
    print("wrote tropical_spectrum.png")


if __name__ == "__main__":
    main()
