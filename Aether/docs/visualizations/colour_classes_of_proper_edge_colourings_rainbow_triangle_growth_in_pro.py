"""Plot the number of (rainbow) triangles in a properly coloured K_n; under a
proper colouring all C(n,3) triangles are rainbow, so the curves coincide."""
from __future__ import annotations
from math import comb
from typing import List
import matplotlib.pyplot as plt


def main() -> None:
    ns: List[int] = list(range(3, 21))
    triangles: List[int] = [comb(n, 3) for n in ns]
    plt.plot(ns, triangles, "o-", label="triangles = rainbow triangles")
    plt.xlabel("n"); plt.ylabel("count")
    plt.title("Proper K_n: every triangle is rainbow (C(n,3))")
    plt.legend(); plt.tight_layout(); plt.savefig("rainbow_growth.png", dpi=140)
    print("wrote rainbow_growth.png")


if __name__ == "__main__":
    main()
