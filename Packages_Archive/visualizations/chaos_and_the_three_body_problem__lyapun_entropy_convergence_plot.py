"""Visualize convergence of the periodic-orbit entropy estimate log(d^n-1)/n
to log d, together with the squeeze bounds. Saves entropy_convergence.png."""
from __future__ import annotations
import math
from typing import List
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def main() -> None:
    plt.figure(figsize=(8, 5))
    for d in (2, 3, 5):
        ns: List[int] = list(range(1, 31))
        est = [math.log(d ** n - 1) / n for n in ns]
        plt.plot(ns, est, "o-", ms=3, label=f"log(d^n-1)/n, d={d}")
        plt.axhline(math.log(d), ls="--", color="gray", lw=0.8)
    plt.xlabel("n"); plt.ylabel("entropy estimate")
    plt.title("Periodic-orbit growth rate -> log d (= Lyapunov exponent)")
    plt.legend(); plt.tight_layout()
    plt.savefig("entropy_convergence.png", dpi=130)

if __name__ == "__main__":
    main()
