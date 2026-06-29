"""
Visualization: the Cramer expectation sum against reality and its bounds.

Generates a two-panel figure:
  (1) CramerSum(N), the logarithmic integral Li(N), the true pi(N), and the
      explicit lower bound N/(2 log N), all on one axis;
  (2) the running ratio CramerSum(N) / pi(N), showing convergence to 1.

Requires matplotlib. Saves 'cramer_model.png'.
"""

from __future__ import annotations

import math
from typing import List

import matplotlib.pyplot as plt


def cramer_sum(N: int) -> float:
    return sum(1.0 / math.log(n) for n in range(2, N + 1))


def log_integral(a: float, b: float, steps: int = 50_000) -> float:
    if steps % 2 == 1:
        steps += 1
    h = (b - a) / steps
    f = lambda x: 1.0 / math.log(x)
    total = f(a) + f(b)
    for i in range(1, steps):
        total += (4.0 if i % 2 else 2.0) * f(a + i * h)
    return total * h / 3.0


def sieve_pi(N: int) -> List[int]:
    is_p = bytearray([1]) * (N + 1)
    is_p[0] = is_p[1] = 0
    for i in range(2, int(N ** 0.5) + 1):
        if is_p[i]:
            is_p[i * i::i] = bytearray(len(range(i * i, N + 1, i)))
    counts, c = [0, 0], 0
    for n in range(2, N + 1):
        c += is_p[n]
        counts.append(c)
    return counts


def main() -> None:
    Nmax = 20_000
    xs = list(range(100, Nmax + 1, 100))
    pi_counts = sieve_pi(Nmax)
    cs = [cramer_sum(N) for N in xs]
    li = [log_integral(2.0, float(N)) for N in xs]
    pis = [pi_counts[N] for N in xs]
    lb = [N / (2.0 * math.log(N)) for N in xs]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

    ax1.plot(xs, cs, label="CramerSum(N) = sum 1/log n", lw=2)
    ax1.plot(xs, li, "--", label="Li(N) = int dx/log x", lw=1.5)
    ax1.plot(xs, pis, ":", label="pi(N) (true primes)", lw=1.5)
    ax1.plot(xs, lb, color="gray", label="N/(2 log N) lower bound", lw=1)
    ax1.set_xlabel("N")
    ax1.set_ylabel("count")
    ax1.set_title("Random-prime expectation vs reality")
    ax1.legend()
    ax1.grid(alpha=0.3)

    ax2.plot(xs, [c / p for c, p in zip(cs, pis)], color="crimson", lw=2)
    ax2.axhline(1.0, color="black", lw=0.8, ls="--")
    ax2.set_xlabel("N")
    ax2.set_ylabel("CramerSum(N) / pi(N)")
    ax2.set_title("Model / reality ratio -> 1")
    ax2.grid(alpha=0.3)

    fig.tight_layout()
    fig.savefig("cramer_model.png", dpi=130)
    print("saved cramer_model.png")


if __name__ == "__main__":
    main()
