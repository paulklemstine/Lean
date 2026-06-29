"""Parity of the dimension controls the mirror Euler sign: (-1)^n."""
import numpy as np
import matplotlib.pyplot as plt


def main() -> None:
    ns = np.arange(2, 9)
    sign = (-1.0) ** ns
    fig, ax = plt.subplots(figsize=(8, 4.5))
    colors = ["#d62728" if s < 0 else "#2ca02c" for s in sign]
    ax.bar(ns, sign, color=colors)
    for n, s in zip(ns, sign):
        ax.text(n, s + (0.06 if s > 0 else -0.12),
                ("invariant (chi)" if s > 0 else "sign flip (-chi)"),
                ha="center", fontsize=9)
    ax.axhline(0, color="black", lw=0.8)
    ax.set_xlabel("complex dimension n")
    ax.set_ylabel(r"mirror Euler sign  $(-1)^n$")
    ax.set_title("Why fourfolds differ from threefolds: parity of n\n"
                 "(n=3 odd -> chi flips;  n=4 even -> chi invariant)")
    ax.set_ylim(-1.6, 1.6)
    fig.tight_layout()
    fig.savefig("cy4_parity.png", dpi=150)
    print("saved cy4_parity.png")


if __name__ == "__main__":
    main()
