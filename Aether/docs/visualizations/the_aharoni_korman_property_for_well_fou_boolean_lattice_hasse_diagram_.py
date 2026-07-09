import matplotlib.pyplot as plt
from itertools import combinations

def visualize_boolean_lattice(k: int = 3) -> None:
    """Hasse diagram of the subset lattice B_k, colored by height (= subset size)."""
    subsets = []
    for r in range(k + 1):
        for c in combinations(range(k), r):
            subsets.append(frozenset(c))
    hts = {s: len(s) for s in subsets}
    levels = {}
    for s in subsets: levels.setdefault(hts[s], []).append(s)
    pos = {}
    fig, ax = plt.subplots(figsize=(7, 6))
    for a in sorted(levels):
        row = levels[a]
        for i, s in enumerate(row):
            px = i - (len(row) - 1) / 2
            pos[s] = (px, a)
    for a, s in ((hts[s], s) for s in subsets):
        px, py = pos[s]
        ax.scatter(px, py, s=900, c=[[0.2, 0.4 + 0.15 * a, 0.7]], zorder=3)
        lbl = "{" + ",".join(map(str, sorted(s))) + "}"
        ax.text(px, py, lbl, ha="center", va="center", fontsize=8,
                color="white", zorder=4)
    for s in subsets:
        for t in subsets:
            if s < t and len(t) == len(s) + 1 and s <= t:
                x0, y0 = pos[s]; x1, y1 = pos[t]
                ax.plot([x0, x1], [y0, y1], color="#CCCCCC", zorder=1)
    ax.set_yticks(range(k + 1)); ax.set_ylabel("height (subset size)")
    ax.set_xticks([]); ax.set_title("Boolean lattice B_%d colored by height" % k)
    plt.tight_layout(); plt.savefig("boolean_lattice.png", dpi=150)
    print("saved boolean_lattice.png")

if __name__ == "__main__":
    visualize_boolean_lattice(3)
