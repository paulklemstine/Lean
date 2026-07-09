"""Bar chart of the empirical Cusick density c_t for small shifts t,
highlighting the proven exact values c_{2^k} = 3/4 and the doubling-orbit
structure (density depends only on the odd part of t)."""
from __future__ import annotations
import matplotlib.pyplot as plt


def s2(n: int) -> int:
    return bin(n).count("1")


def cusick_density(t: int, N: int = 1 << 16) -> float:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t)) / N


def main() -> None:
    ts = list(range(1, 25))
    ds = [cusick_density(t) for t in ts]
    colors = ["tab:green" if (t & (t - 1)) == 0 else "tab:blue" for t in ts]
    plt.figure(figsize=(11, 5))
    plt.bar(ts, ds, color=colors)
    plt.axhline(0.5, color="black", ls="--", lw=1, label="fair coin (1/2)")
    plt.axhline(0.75, color="tab:green", ls=":", lw=1, label="c_{2^k}=3/4 (proven)")
    plt.xlabel("shift t")
    plt.ylabel("Cusick density c_t")
    plt.title("Cusick density c_t (green = powers of two, proven c=3/4)")
    plt.ylim(0.45, 0.8)
    plt.legend()
    plt.tight_layout()
    plt.savefig("cusick_density.png", dpi=150)
    print("wrote cusick_density.png")


if __name__ == "__main__":
    main()
