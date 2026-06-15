"""Visualize incompressibility density: fraction of a universe lacking a short code."""
from typing import Callable
import matplotlib.pyplot as plt

def fraction_incompressible(encoder: Callable[[int], int], n: int,
                            universe_size: int, k: int) -> float:
    reachable = {encoder(i) for i in range(n) if i <= k}
    describable = sum(1 for x in range(universe_size) if x in reachable)
    return 1.0 - describable / universe_size

def main() -> None:
    universe_size = 256
    n = universe_size
    encoder = lambda i: (1103515245 * i + 12345) % universe_size  # LCG pseudo-encoder
    ks = list(range(universe_size))
    fracs = [fraction_incompressible(encoder, n, universe_size, k) for k in ks]
    lower = [max(0.0, 1.0 - (k + 1) / universe_size) for k in ks]
    plt.figure(figsize=(8, 5))
    plt.plot(ks, fracs, label="actual incompressible fraction")
    plt.plot(ks, lower, "r--", label="guaranteed lower bound 1-(k+1)/|U|")
    plt.xlabel("code budget k")
    plt.ylabel("fraction of universe with no code of index <= k")
    plt.title("Incompressibility density over a 256-element universe")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("incompressibility_density.png", dpi=150)
    print("Saved incompressibility_density.png")

if __name__ == "__main__":
    main()
