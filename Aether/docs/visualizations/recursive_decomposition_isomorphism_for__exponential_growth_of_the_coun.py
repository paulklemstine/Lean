"""Visualization 1: Exponential growth of the counting sequences.

Plots the level counts C(k) for m = 1, 2, 3 on a logarithmic y-axis alongside
the 2^k lower bound, illustrating the growth theorem C(k) >= 2^k.
"""
from typing import Callable, List
import matplotlib.pyplot as plt

def sites_rule(m: int, k: int) -> List[int]:
    return list(range(1, m * k + 2))

def level_count(succ: Callable[[int], List[int]], root: int, depth: int) -> int:
    labels = [root]
    for _ in range(depth):
        nxt: List[int] = []
        for lab in labels:
            nxt.extend(succ(lab))
        labels = nxt
    return len(labels)

def main() -> None:
    depth = 6
    ks = list(range(depth + 1))
    plt.figure(figsize=(8, 5))
    for m in (1, 2, 3):
        ys = [level_count(lambda k: sites_rule(m, k), 1, d) for d in ks]
        plt.plot(ks, ys, marker="o", label=f"m = {m}")
    plt.plot(ks, [2 ** k for k in ks], "k--", label="2^k bound")
    plt.yscale("log")
    plt.xlabel("level k")
    plt.ylabel("number of nodes  C(k)")
    plt.title("Counting sequences of the m-Tamari / (m+1)-constellation tree")
    plt.legend()
    plt.tight_layout()
    plt.savefig("growth.png", dpi=150)
    print("wrote growth.png")

if __name__ == "__main__":
    main()
