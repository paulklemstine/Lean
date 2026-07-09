"""Visualization: normalized approximation error b^2*|sqrt(d)-a/b| versus b,
showing the Diophantine floor c that the quadratic surd never crosses.
Requires matplotlib."""
from __future__ import annotations
import math
import matplotlib.pyplot as plt

def normalized_errors(d: int, B: int) -> tuple[list[int], list[float]]:
    root = math.sqrt(d)
    bs, ys = [], []
    for b in range(1, B + 1):
        a = round(root * b)
        bs.append(b)
        ys.append(b * b * abs(root - a / b))
    return bs, ys

def main() -> None:
    fig, ax = plt.subplots(figsize=(9, 5))
    for d, color in ((2, "tab:blue"), (3, "tab:orange"), (5, "tab:green")):
        bs, ys = normalized_errors(d, 300)
        ax.scatter(bs, ys, s=6, color=color, alpha=0.5, label=f"d={d}")
        c = 1.0 / (2.0 * math.sqrt(d) + 1.0)
        ax.axhline(c, color=color, ls="--", lw=1)
    ax.set_xlabel("denominator b")
    ax.set_ylabel(r"$b^2\,|\sqrt{d}-a/b|$")
    ax.set_title("Quadratic surds stay above the Diophantine floor c/b^2 (dashed = c)")
    ax.set_ylim(0, 1.2)
    ax.legend()
    fig.tight_layout()
    fig.savefig("diophantine_floor.png", dpi=150)
    print("wrote diophantine_floor.png")

if __name__ == "__main__":
    main()
