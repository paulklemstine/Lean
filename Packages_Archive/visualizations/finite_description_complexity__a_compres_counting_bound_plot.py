"""Visualize the counting bound: reachable distinct outputs vs. the k+1 ceiling."""
from typing import Callable, Set
import matplotlib.pyplot as plt

def reachable_set(encoder: Callable[[int], int], n: int, k: int) -> Set[int]:
    return {encoder(i) for i in range(n) if i <= k}

def main() -> None:
    n = 30
    encoders = {
        "identity (tight)": lambda i: i,
        "squares mod 1000": lambda i: (i * i + 7 * i) % 1000,
        "mod 5 (collisions)": lambda i: i % 5,
    }
    ks = list(range(n))
    plt.figure(figsize=(8, 5))
    plt.plot(ks, [k + 1 for k in ks], "k--", label="counting ceiling k+1")
    for name, E in encoders.items():
        plt.plot(ks, [len(reachable_set(E, n, k)) for k in ks], marker="o", ms=3, label=name)
    plt.xlabel("code budget k")
    plt.ylabel("number of distinct reachable outputs |R_k(E)|")
    plt.title("Counting Bound: |R_k(E)| <= k + 1 for every encoder")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("counting_bound.png", dpi=150)
    print("Saved counting_bound.png")

if __name__ == "__main__":
    main()
