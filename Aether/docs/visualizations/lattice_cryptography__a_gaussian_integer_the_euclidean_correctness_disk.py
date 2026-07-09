import math
import matplotlib.pyplot as plt

def plot_correctness_disk(q: int = 16) -> None:
    t = q / 2
    r = q / 4
    fig, ax = plt.subplots(figsize=(7, 7))
    # integer error lattice
    pts_ok, pts_bad = [], []
    rng = range(-int(r) - 2, int(r) + 3)
    for ex in rng:
        for ey in rng:
            (pts_ok if ex * ex + ey * ey < r * r else pts_bad).append((ex, ey))
    if pts_ok:
        ax.scatter(*zip(*pts_ok), c="seagreen", s=40, label="decrypts correctly")
    if pts_bad:
        ax.scatter(*zip(*pts_bad), c="lightgray", s=20, label="outside ball")
    # Euclidean disk
    theta = [i * 2 * math.pi / 400 for i in range(401)]
    ax.plot([r * math.cos(a) for a in theta], [r * math.sin(a) for a in theta],
            "b-", lw=2, label=f"x^2+y^2=(q/4)^2, r={r}")
    ax.axhline(0, color="k", lw=0.5); ax.axvline(0, color="k", lw=0.5)
    ax.set_aspect("equal"); ax.grid(True, alpha=0.3)
    ax.set_title(f"Ring-LWE over Z[i]: correctness disk (q={q}, t={t})")
    ax.set_xlabel("e_x (real error)"); ax.set_ylabel("e_y (imag error)")
    ax.legend(loc="upper right")
    plt.tight_layout()
    plt.savefig("correctness_disk.png", dpi=150)
    print("saved correctness_disk.png")

if __name__ == "__main__":
    plot_correctness_disk()
