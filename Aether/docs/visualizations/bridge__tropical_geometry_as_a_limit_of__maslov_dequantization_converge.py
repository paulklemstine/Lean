"""Visualize Maslov dequantization: x (+)_t y -> max(x,y) as t grows, staying
within the [max, max + log2/t] sandwich."""
import math
import matplotlib.pyplot as plt
import numpy as np


def plot_dequantization(x: float = 1.0, y: float = 2.5) -> None:
    ts = np.linspace(0.2, 12.0, 400)
    vals = [max(x, y) + math.log(math.exp(t*(x-max(x,y))) +
            math.exp(t*(y-max(x,y))))/t for t in ts]
    upper = [max(x, y) + math.log(2)/t for t in ts]
    plt.plot(ts, vals, "b-", label="x (+)_t y")
    plt.plot(ts, [max(x, y)]*len(ts), "k--", label="max(x,y)")
    plt.plot(ts, upper, "r:", label="max + log2/t")
    plt.title("Maslov dequantization converges to the maximum")
    plt.xlabel("temperature t"); plt.ylabel("value")
    plt.legend(); plt.grid(alpha=0.3)
    plt.tight_layout(); plt.savefig("dequantization.png", dpi=150)
    print("saved dequantization.png")


if __name__ == "__main__":
    plot_dequantization()
