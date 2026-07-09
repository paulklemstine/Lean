"""Visualization: dyadic Anti-Escher collapse — shrinking ideals (2^n)."""
import matplotlib.pyplot as plt


def plot_dyadic(max_n: int = 8, window: int = 64) -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    for n in range(max_n):
        mults = [x for x in range(0, window + 1) if x % (2 ** n) == 0]
        ax.scatter(mults, [n] * len(mults), s=12, color=plt.cm.plasma(n / max_n))
    ax.set_xlabel("integers in [0, %d]" % window)
    ax.set_ylabel("chain stage n  ->  ideal (2^n)")
    ax.set_title("Anti-Escher collapse: multiples of 2^n thin out; only 0 survives")
    plt.tight_layout()
    plt.savefig("dyadic_collapse.png", dpi=150)
    print("wrote dyadic_collapse.png")


if __name__ == "__main__":
    plot_dyadic()
