import matplotlib.pyplot as plt

def visualize_divisibility_levels(n: int = 16) -> None:
    """Draw the divisibility poset on {1..n} as horizontal height levels."""
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
    pos = {}
    fig, ax = plt.subplots(figsize=(9, 5))
    for a in sorted(levels):
        row = sorted(levels[a])
        for i, x in enumerate(row):
            px = i - (len(row) - 1) / 2
            pos[x] = (px, a)
            ax.scatter(px, a, s=600, color="#4C72B0", zorder=3)
            ax.text(px, a, str(x), color="white", ha="center", va="center",
                    fontsize=10, zorder=4)
    for (u, v) in less:
        if hts[v] == hts[u] + 1:  # cover edges only
            x0, y0 = pos[u]; x1, y1 = pos[v]
            ax.plot([x0, x1], [y0, y1], color="#BBBBBB", zorder=1)
    ax.set_yticks(sorted(levels))
    ax.set_ylabel("height (number of prime factors)")
    ax.set_title("Height levels of the divisibility order on {1,...,%d}" % n)
    ax.set_xticks([])
    plt.tight_layout(); plt.savefig("divisibility_levels.png", dpi=150)
    print("saved divisibility_levels.png")

if __name__ == "__main__":
    visualize_divisibility_levels()
