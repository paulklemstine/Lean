"""Visualize chain (single-exp) vs bushy (double-exp) growth of typeStateBound.

Produces a semilog-y plot of log10(typeStateBound) against depth, showing the
qualitative gap: chains are a straight-ish line on a log scale (single exponential)
while bushes curve sharply upward (double exponential).  Saves arrow_depth_growth.png.
"""
from __future__ import annotations
import math
import matplotlib.pyplot as plt


def chain_tsb(d: int) -> int:
    x = 1
    for _ in range(d):
        x = 2 * (x + 1)        # tsb(base -> B) = (1+1)*(tsb(B)+1)
    return x


def bushy_tsb(n: int) -> int:
    x = 1
    for _ in range(n):
        x = (x + 1) ** 2       # tsb(bushy(n+1)) = (tsb(bushy n)+1)^2
    return x


def main() -> None:
    depths = list(range(0, 7))
    chain_log = [math.log10(chain_tsb(d)) for d in depths]
    bushy_log = [math.log10(bushy_tsb(d)) for d in depths]
    ceil3 = [ (d + 1) * math.log10(3) for d in depths ]  # log10(3^(d+1))

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(depths, chain_log, "o-", label="chain types (single exp in depth)")
    ax.plot(depths, bushy_log, "s-", label="bushy types (double exp in depth)")
    ax.plot(depths, ceil3, "--", color="gray", label="depth ceiling log10(3^(d+1))")
    ax.set_xlabel("arrow depth")
    ax.set_ylabel("log10( typeStateBound )")
    ax.set_title("Depth is insufficient: same depth, vastly different complexity")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("arrow_depth_growth.png", dpi=150)
    print("wrote arrow_depth_growth.png")


if __name__ == "__main__":
    main()
