"""Number-line visualization of the collapse  [x, b) cap (a, x] = {x}."""
import matplotlib.pyplot as plt


def plot_singleton_collapse(a: float = -1.0, x: float = 0.0, b: float = 1.0) -> None:
    fig, ax = plt.subplots(figsize=(9, 3))
    ax.hlines(3, a - 0.5, b + 0.5, color="lightgray", lw=1)

    # right half-open [x, b): filled dot at x, open dot at b
    ax.hlines(2, x, b, color="crimson", lw=6, alpha=0.7)
    ax.plot(x, 2, "o", color="crimson", ms=10)
    ax.plot(b, 2, "o", mfc="white", mec="crimson", ms=10)
    ax.text(b + 0.05, 2, r"$[x, b)$ right-looking", va="center", color="crimson")

    # left half-open (a, x]: open dot at a, filled dot at x
    ax.hlines(1, a, x, color="royalblue", lw=6, alpha=0.7)
    ax.plot(a, 1, "o", mfc="white", mec="royalblue", ms=10)
    ax.plot(x, 1, "o", color="royalblue", ms=10)
    ax.text(a - 0.05, 1, r"$(a, x]$ left-looking", va="center", ha="right",
            color="royalblue")

    # intersection = {x}
    ax.plot(x, 0, "*", color="black", ms=20)
    ax.text(x + 0.05, 0, r"$[x,b)\cap(a,x]=\{x\}$", va="center")

    for xv, lab in [(a, "a"), (x, "x"), (b, "b")]:
        ax.axvline(xv, color="gray", ls=":", lw=0.7)
        ax.text(xv, 3.4, f"${lab}$", ha="center")
    ax.set_ylim(-0.7, 3.8)
    ax.axis("off")
    ax.set_title("Possibility collapse: two half-open cuts pin a single point")
    plt.tight_layout()
    plt.savefig("singleton_collapse.png", dpi=150)
    print("wrote singleton_collapse.png")


if __name__ == "__main__":
    plot_singleton_collapse()
