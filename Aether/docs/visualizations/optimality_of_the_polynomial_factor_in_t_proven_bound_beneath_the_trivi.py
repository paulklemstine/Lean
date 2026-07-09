"""Visualization: the proven bound vs. the exponential ceiling base^n."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

BASE = 3.0 / 2.0 ** (2.0 / 3.0)


def M(n: int) -> int:
    return sum(math.comb(n, k) for k in range(0, n // 3 + 1))


def main() -> None:
    ns = list(range(6, 181, 3))
    log_bound = [math.log2((n + 1) * 3 * M(n)) for n in ns]
    log_base = [n * math.log2(BASE) for n in ns]
    log_2n = [n for n in ns]  # log2(2^n) = n

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ns, log_2n, "--", label=r"trivial ceiling $\log_2 2^n$")
    ax.plot(ns, log_bound, label=r"proven bound $\log_2[(n{+}1)\,3M(n)]$")
    ax.plot(ns, log_base, ":", label=r"$\log_2 (3/2^{2/3})^n$")
    ax.set_xlabel("n")
    ax.set_ylabel(r"$\log_2$ (family size)")
    ax.set_title("Sunflower-free bound sits below the trivial ceiling")
    ax.legend()
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("bound_growth.png", dpi=150)
    print("wrote bound_growth.png")


if __name__ == "__main__":
    main()
