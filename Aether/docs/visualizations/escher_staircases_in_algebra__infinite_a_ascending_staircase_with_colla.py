"""Visualization: the ascending Boolean staircase and its collapsing intersection."""
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    N = 8
    # each rung I_n drawn as a bar of "dimension" n (log2 of its finite truncation size)
    for n in range(N + 1):
        ax.add_patch(plt.Rectangle((n, 0), 0.8, n, color=plt.cm.viridis(n / N), alpha=0.8))
        ax.text(n + 0.4, n + 0.15, f"I_{n}", ha="center", fontsize=9)
    ax.axhline(0, color="red", lw=2, ls="--", label="intersection = I_0 = {0}")
    ax.set_xlim(-0.5, N + 1)
    ax.set_ylim(-0.5, N + 1)
    ax.set_xlabel("rung index n")
    ax.set_ylabel("height (log2 |truncated rung|)")
    ax.set_title("Escher staircase: climbs forever, meet is the bottom rung {0}")
    ax.legend(loc="upper left")
    fig.tight_layout()
    fig.savefig("escher_staircase.png", dpi=150)
    print("wrote escher_staircase.png")


if __name__ == "__main__":
    main()
