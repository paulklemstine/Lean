"""Visualization: Hasse diagram of B_4 with the middle layer highlighted."""
import matplotlib.pyplot as plt
from itertools import combinations


def main() -> None:
    n = 4
    subsets = [frozenset(c) for k in range(n + 1)
               for c in combinations(range(n), k)]
    # position: x by index within layer, y by cardinality
    layers = {}
    for s in subsets:
        layers.setdefault(len(s), []).append(s)
    pos = {}
    for k, ss in layers.items():
        ss.sort(key=lambda s: sorted(s))
        for i, s in enumerate(ss):
            pos[s] = (i - (len(ss) - 1) / 2, k)
    fig, ax = plt.subplots(figsize=(9, 7))
    for s in subsets:
        for t in subsets:
            if len(t) == len(s) + 1 and s < t:
                x0, y0 = pos[s]
                x1, y1 = pos[t]
                ax.plot([x0, x1], [y0, y1], color="lightgray", zorder=1)
    for s in subsets:
        x, y = pos[s]
        mid = (len(s) == n // 2)
        ax.scatter([x], [y], s=500, zorder=2,
                   color="crimson" if mid else "steelblue")
        label = "{" + ",".join(str(i) for i in sorted(s)) + "}" if s else "{}"
        ax.text(x, y, label, ha="center", va="center", color="white", fontsize=7)
    ax.set_title("Hasse diagram of B_4; middle layer (red) is the maximum antichain")
    ax.axis("off")
    fig.tight_layout()
    fig.savefig("hasse.png", dpi=150)
    print("wrote hasse.png")


if __name__ == "__main__":
    main()
