"""Visualise the Theta(|Omega| * k) round complexity to reach error 2^-k."""
import math
import matplotlib.pyplot as plt


def plot_rounds_needed() -> None:
    ns = list(range(2, 201))
    for k in (10, 20, 40):
        ys = [math.ceil(k * math.log(2) / math.log(n / (n - 1))) for n in ns]
        plt.plot(ns, ys, label=f"error 2^-{k}")
    plt.xlabel("challenge space size |Omega|")
    plt.ylabel("rounds needed R")
    plt.title("Round complexity is linear in |Omega| (Theta(|Omega|*k))")
    plt.legend()
    plt.tight_layout()
    plt.savefig("rounds_needed.png", dpi=150)


if __name__ == "__main__":
    plot_rounds_needed()
