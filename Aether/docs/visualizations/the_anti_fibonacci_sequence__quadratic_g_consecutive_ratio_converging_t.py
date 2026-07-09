"""Visualization 2: Consecutive ratios converge to 1, never reaching the golden ratio."""
from __future__ import annotations
import matplotlib.pyplot as plt

PHI = (1 + 5 ** 0.5) / 2


def closed(n: int) -> int:
    return 1 + n * (n - 1) // 2


def main() -> None:
    ns = list(range(1, 51))
    r = [closed(n + 1) / closed(n) for n in ns]

    fig, ax = plt.subplots(figsize=(9, 5.5))
    ax.plot(ns, r, "o-", ms=4, color="teal", label="A(n+1)/A(n)")
    ax.axhline(1.0, ls="--", color="black", label="anti-Fibonacci limit = 1")
    ax.axhline(PHI, ls=":", color="goldenrod", lw=2,
               label=f"golden ratio phi = {PHI:.4f} (never reached)")
    ax.fill_between(ns, 1.0, PHI, color="gold", alpha=0.10)
    ax.set_title("The anti-Fibonacci ratio avoids the golden ratio")
    ax.set_xlabel("n"); ax.set_ylabel("consecutive ratio"); ax.legend()

    fig.tight_layout()
    fig.savefig("antifib_ratio.png", dpi=150)
    print("saved antifib_ratio.png")


if __name__ == "__main__":
    main()
