"""Visualize the clopen split of the surreal line into finite and infinite parts."""
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(11, 2.6))
    # finite part (compressed reals) drawn on [0,1); infinite part on (1,2]
    ax.axhline(0, color="black", lw=1)
    ax.fill_betweenx([-0.25, 0.25], -0.05, 1.0, color="#4C72B0", alpha=0.35)
    ax.fill_betweenx([-0.25, 0.25], 1.0, 2.05, color="#C44E52", alpha=0.35)
    ax.text(0.45, 0.35, "F = finite surreals  (clopen)", ha="center", color="#274472")
    ax.text(1.55, 0.35, "infinite surreals  (clopen)", ha="center", color="#7a1f28")
    for x, lbl in [(0.0, "0"), (0.3, "reals"), (0.75, "1000+eps")]:
        ax.plot(x, 0, "o", color="#274472"); ax.text(x, -0.4, lbl, ha="center")
    for x, lbl in [(1.3, "w"), (1.7, "w^2")]:
        ax.plot(x, 0, "s", color="#7a1f28"); ax.text(x, -0.4, lbl, ha="center")
    ax.axvline(1.0, color="black", ls="--", lw=1.2)
    ax.text(1.0, 0.6, "no continuous crossing", ha="center", fontsize=9)
    ax.set_xlim(-0.1, 2.1); ax.set_ylim(-0.7, 0.8); ax.axis("off")
    ax.set_title("The surreal line splits into two clopen pieces (disconnected)")
    plt.tight_layout(); plt.savefig("surreal_disconnection.png", dpi=150)
    print("wrote surreal_disconnection.png")


if __name__ == "__main__":
    main()
