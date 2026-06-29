import matplotlib.pyplot as plt


def odd_part(x: int) -> int:
    while x % 2 == 0:
        x //= 2
    return x


def visualize(n: int = 16) -> None:
    xs = list(range(1, 2 * n + 1))
    cores = [odd_part(x) for x in xs]
    distinct = sorted(set(cores))
    cmap = {c: i for i, c in enumerate(distinct)}
    colors = [cmap[c] for c in cores]
    plt.figure(figsize=(12, 2.2))
    plt.scatter(xs, [0] * len(xs), c=colors, cmap="tab20", s=240, marker="s")
    for x, c in zip(xs, cores):
        plt.text(x, 0.18, str(c), ha="center", fontsize=7)
    plt.title(f"[1,{2*n}] colored by odd part: {len(distinct)} = n classes "
              f"=> any n+1 picks collide")
    plt.yticks([])
    plt.xlabel("integer (label above = odd part)")
    plt.tight_layout()
    plt.savefig("pigeonhole_coarsegraining.png", dpi=130)
    print("saved pigeonhole_coarsegraining.png")


if __name__ == "__main__":
    visualize(16)
