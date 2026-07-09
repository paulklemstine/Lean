"""Log-scale plot of the vanishing uniform density of dark configurations."""
import matplotlib.pyplot as plt


def dark_density(N: int) -> float:
    """(N-1)/(N * 2^N): the exact fraction of dark configurations."""
    return (N - 1) / (N * (2 ** N))


def main() -> None:
    Ns = list(range(2, 25))
    ys = [dark_density(N) for N in Ns]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.semilogy(Ns, ys, "o-", color="#0b6e4f")
    ax.set_xlabel("family size N")
    ax.set_ylabel("fraction of dark configurations (log scale)")
    ax.set_title("Darkness has vanishing uniform density: (N-1)/(N*2^N) -> 0")
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("dark_density.png", dpi=150)
    print("wrote dark_density.png")


if __name__ == "__main__":
    main()
