"""Draw a small random d-DAG and highlight the joint descendant set of a block
of late vertices."""
import random
import matplotlib.pyplot as plt


def main(d=2, N=25, seed=3):
    rng = random.Random(seed)
    parents = [[] for _ in range(N)]
    for n in range(d, N):
        parents[n] = rng.sample(range(n), d)
    block = [N - 3, N - 2]  # two late vertices
    # forward propagation of descendant flags
    flags = [[False] * N for _ in block]
    for i, v in enumerate(block):
        flags[i][v] = True
        for w in range(v + 1, N):
            if any(flags[i][u] for u in parents[w]):
                flags[i][w] = True
    joint = [w for w in range(N) if all(flags[i][w] for i in range(len(block)))]
    pos = {n: (n % 5, n // 5) for n in range(N)}
    plt.figure(figsize=(7, 6))
    for n in range(N):
        for u in parents[n]:
            x0, y0 = pos[n]; x1, y1 = pos[u]
            plt.plot([x0, x1], [y0, y1], color="0.8", lw=0.6, zorder=1)
    xs = [pos[n][0] for n in range(N)]; ys = [pos[n][1] for n in range(N)]
    plt.scatter(xs, ys, c="steelblue", s=120, zorder=2)
    plt.scatter([pos[n][0] for n in block], [pos[n][1] for n in block],
                c="orange", s=200, zorder=3, label="block")
    plt.scatter([pos[n][0] for n in joint], [pos[n][1] for n in joint],
                c="crimson", s=80, zorder=4, label="joint descendants")
    plt.title("Random d-DAG with joint descendant set"); plt.legend()
    plt.axis("off"); plt.tight_layout(); plt.savefig("ddag.png", dpi=150)


if __name__ == "__main__":
    main()
