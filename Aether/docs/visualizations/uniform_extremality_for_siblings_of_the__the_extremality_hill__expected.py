import numpy as np
import matplotlib.pyplot as plt


def plot_two_type_hill() -> None:
    a = np.linspace(0.001, 0.999, 400)
    plt.figure(figsize=(8, 5))
    for j in (2, 3, 4, 6):
        f = 2 - a ** j - (1 - a) ** j
        plt.plot(a, f, label=f"j = {j}")
        peak = 2 - 2 ** (1 - j)
        plt.scatter([0.5], [peak], color="black", zorder=5)
    plt.axvline(0.5, color="gray", linestyle="--", alpha=0.6)
    plt.title("Expected empty slots  f(a) = 2 - a^j - (1-a)^j  (N = 2)")
    plt.xlabel("probability a of the first type")
    plt.ylabel("expected number of empty sibling slots")
    plt.legend()
    plt.tight_layout()
    plt.savefig("two_type_hill.png", dpi=150)
    print("saved two_type_hill.png")


if __name__ == "__main__":
    plot_two_type_hill()
