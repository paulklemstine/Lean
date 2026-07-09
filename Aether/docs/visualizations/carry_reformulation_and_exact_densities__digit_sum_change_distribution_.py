"""Visualize the running carry/digit-sum balance s2(n+t)-s2(n) as a stopped
walk, illustrating why the Cusick event (>= 0) is biased positive. Plots the
distribution of s2(n+t)-s2(n) for a fixed t over a large block."""
from __future__ import annotations
import matplotlib.pyplot as plt
from collections import Counter


def s2(n: int) -> int:
    return bin(n).count("1")


def main() -> None:
    N = 1 << 16
    for t in (1, 3, 7):
        diffs = Counter(s2(n + t) - s2(n) for n in range(N))
        xs = sorted(diffs)
        ys = [diffs[x] / N for x in xs]
        plt.plot(xs, ys, marker="o", label=f"t={t} (s2(t)={s2(t)})")
    plt.axvline(-0.5, color="red", ls="--", lw=1,
                label="Cusick threshold (diff >= 0)")
    plt.xlabel("s2(n+t) - s2(n)")
    plt.ylabel("probability")
    plt.title("Distribution of the digit-sum change (biased toward >= 0)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("cusick_walk.png", dpi=150)
    print("wrote cusick_walk.png")


if __name__ == "__main__":
    main()
