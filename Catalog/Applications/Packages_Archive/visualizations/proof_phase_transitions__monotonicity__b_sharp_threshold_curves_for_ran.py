"""Visualization: empirical sharp-threshold curves for random implicational theories.

Generates Pr[Derivable T 0 (n-1)] vs. rescaled density c = p*n/log n for several n,
showing the curves sharpening toward a step at c = 1 (the connectivity threshold
p* ~ log n / n). Requires matplotlib.
"""
import math, random
from collections import deque
from typing import Set, Tuple
import matplotlib.pyplot as plt

Edge = Tuple[int, int]

def derivable(edges: Set[Edge], a: int, b: int) -> bool:
    if a == b:
        return True
    adj: dict[int, list[int]] = {}
    for (x, y) in edges:
        adj.setdefault(x, []).append(y)
    seen = {a}; q = deque([a])
    while q:
        x = q.popleft()
        for y in adj.get(x, ()):
            if y not in seen:
                if y == b:
                    return True
                seen.add(y); q.append(y)
    return False

def prob(n: int, p: float, trials: int, rng: random.Random) -> float:
    hits = 0
    for _ in range(trials):
        T = {(i, j) for i in range(n) for j in range(n)
             if i != j and rng.random() < p}
        if derivable(T, 0, n - 1):
            hits += 1
    return hits / trials

def main() -> None:
    rng = random.Random(7)
    cs = [0.2 + 0.1 * k for k in range(28)]
    plt.figure(figsize=(8, 5))
    for n in (20, 40, 80, 160):
        ys = [prob(n, c * math.log(n) / n, 80, rng) for c in cs]
        plt.plot(cs, ys, marker="o", ms=3, label=f"n = {n}")
    plt.axvline(1.0, color="grey", ls="--", lw=1, label="c = 1 (p* = log n / n)")
    plt.xlabel("rescaled density  c = p * n / log n")
    plt.ylabel("Pr[ Derivable T  0 -> n-1 ]")
    plt.title("Proof phase transition: derivability in random implicational theories")
    plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
    plt.savefig("threshold_curve.png", dpi=150)
    print("saved threshold_curve.png")

if __name__ == "__main__":
    main()
