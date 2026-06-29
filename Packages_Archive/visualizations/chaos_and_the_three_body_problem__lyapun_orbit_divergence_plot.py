"""Visualize exponential divergence of nearby orbits under the doubling map.
Generates two trajectories started 1e-9 apart and plots |difference| on a log
axis; the slope is the Lyapunov exponent log 2. Saves orbit_divergence.png."""
from __future__ import annotations
import math
from typing import List
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def doubling(x: float) -> float:
    return (2.0 * x) % 1.0

def trajectory(x0: float, n: int) -> List[float]:
    xs, x = [], x0
    for _ in range(n):
        xs.append(x); x = doubling(x)
    return xs

def main() -> None:
    n = 55
    a = trajectory(0.401, n)
    b = trajectory(0.401 + 1e-9, n)
    diff = [abs(ai - bi) + 1e-18 for ai, bi in zip(a, b)]
    steps = list(range(n))
    plt.figure(figsize=(8, 5))
    plt.semilogy(steps, diff, "o-", ms=3, label="|x_n - y_n|")
    ref = [1e-9 * math.exp(math.log(2) * k) for k in steps]
    plt.semilogy(steps, ref, "--", label="1e-9 * e^{(log 2) n}")
    plt.xlabel("iteration n"); plt.ylabel("separation (log scale)")
    plt.title("Exponential orbit divergence: slope = Lyapunov exponent log 2")
    plt.legend(); plt.tight_layout()
    plt.savefig("orbit_divergence.png", dpi=130)

if __name__ == "__main__":
    main()
