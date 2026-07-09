"""Visualize geometric soundness amplification: survival probability vs rounds."""
import matplotlib.pyplot as plt


def main() -> None:
    ks = list(range(0, 21))
    for e, n, label in [(3, 6, "p=1/2 (2e=n)"), (2, 3, "p=2/3"), (1, 6, "p=1/6")]:
        ys = [(e / n) ** k for k in ks]
        plt.semilogy(ks, ys, marker="o", label=label)
    plt.xlabel("number of rounds k")
    plt.ylabel("cheating survival probability (log scale)")
    plt.title("Soundness amplification: (e/n)^k -> 0")
    plt.grid(True, which="both", alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("amplification.png", dpi=150)
    print("wrote amplification.png")


if __name__ == "__main__":
    main()
