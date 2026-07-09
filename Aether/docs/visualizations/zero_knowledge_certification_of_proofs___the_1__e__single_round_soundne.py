"""Visualize the 1/|E| single-round soundness gap as graph size grows."""
import matplotlib.pyplot as plt


def main() -> None:
    ms = list(range(2, 41))
    min_catch = [1.0 / m for m in ms]          # one bad edge
    plt.plot(ms, min_catch, marker="o", color="crimson",
             label="minimum single-round catch prob = 1/|E|")
    plt.fill_between(ms, min_catch, 1.0, alpha=0.15, color="crimson",
                     label="achievable catch region")
    plt.xlabel("number of edges |E|")
    plt.ylabel("single-round catch probability")
    plt.title("Guaranteed soundness gap 1/|E| for an improper colouring")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("soundness_gap.png", dpi=150)
    print("wrote soundness_gap.png")


if __name__ == "__main__":
    main()
