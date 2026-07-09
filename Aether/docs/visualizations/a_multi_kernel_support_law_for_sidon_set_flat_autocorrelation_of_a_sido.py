"""Bar chart of the difference kernel (autocorrelation) of a Sidon set."""
from __future__ import annotations
from typing import Dict, List
import matplotlib.pyplot as plt


def difference_kernel(s: List[int]) -> Dict[int, int]:
    e = list(set(s))
    k: Dict[int, int] = {}
    for a in e:
        for b in e:
            k[a - b] = k.get(a - b, 0) + 1
    return k


def main() -> None:
    s = [1, 2, 4, 8]
    dk = difference_kernel(s)
    xs = sorted(dk)
    ys = [dk[x] for x in xs]
    colors = ["crimson" if x == 0 else "steelblue" for x in xs]
    plt.figure(figsize=(9, 4))
    plt.bar(xs, ys, color=colors)
    plt.title(f"Difference kernel of the Sidon set {s}: flat off-zero")
    plt.xlabel("difference value x")
    plt.ylabel("r^-_s(x)")
    plt.axhline(1, color="gray", ls="--", lw=0.8)
    plt.tight_layout()
    plt.savefig("difference_kernel.png", dpi=150)
    print("wrote difference_kernel.png")


if __name__ == "__main__":
    main()
