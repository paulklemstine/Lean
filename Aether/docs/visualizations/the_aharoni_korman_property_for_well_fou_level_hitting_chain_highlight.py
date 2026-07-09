import matplotlib.pyplot as plt

def visualize_chain_through_levels(n: int = 16) -> None:
    """Highlight the level-hitting chain 1|2|4|8|16 inside the divisibility poset."""
    ground = list(range(1, n + 1))
    less = {(a, b) for a in ground for b in ground if a != b and b % a == 0}
    memo = {}
    def h(x):
        if x in memo: return memo[x]
        below = [y for y in ground if (y, x) in less]
        memo[x] = 0 if not below else max(h(y) + 1 for y in below)
        return memo[x]
    hts = {x: h(x) for x in ground}
    levels = {}
    for x in ground: levels.setdefault(hts[x], []).append(x)
    chain = [2 ** k for k in range(n.bit_length()) if 2 ** k <= n]
    pos = {}
    fig, ax = plt.subplots(figsize=(9, 5))
    for a in sorted(levels):
        row = sorted(levels[a])
        for i, x in enumerate(row):
            px = i - (len(row) - 1) / 2
            pos[x] = (px, a)
            on = x in chain
            ax.scatter(px, a, s=650, color="#DD8452" if on else "#CFCFCF",
                       zorder=3, edgecolors="black" if on else "none")
            ax.text(px, a, str(x), ha="center", va="center", fontsize=9,
                    color="black", zorder=4)
    for i in range(len(chain) - 1):
        x0, y0 = pos[chain[i]]; x1, y1 = pos[chain[i + 1]]
        ax.plot([x0, x1], [y0, y1], color="#DD8452", lw=3, zorder=2)
    ax.set_yticks(sorted(levels)); ax.set_ylabel("height")
    ax.set_xticks([]); ax.set_title("A single chain meeting every non-empty level")
    plt.tight_layout(); plt.savefig("chain_through_levels.png", dpi=150)
    print("saved chain_through_levels.png")

if __name__ == "__main__":
    visualize_chain_through_levels()
