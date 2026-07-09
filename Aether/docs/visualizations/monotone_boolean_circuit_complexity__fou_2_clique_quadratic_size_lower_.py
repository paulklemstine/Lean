import matplotlib.pyplot as plt
from math import comb
from typing import List


def clique2_lower_bound(m: int) -> int:
    """Certified size lower bound for 2-CLIQUE on m vertices: C(m,2)."""
    return comb(m, 2)


def main() -> None:
    ms: List[int] = list(range(2, 21))
    bounds: List[int] = [clique2_lower_bound(m) for m in ms]
    plt.figure(figsize=(8, 5))
    plt.plot(ms, bounds, "o-", color="#2c3e50",
             label=r"size $\geq \binom{m}{2}$ (clique2_size_ge_choose)")
    plt.fill_between(ms, bounds, alpha=0.15, color="#2c3e50")
    plt.xlabel("number of vertices m")
    plt.ylabel("monotone circuit size lower bound")
    plt.title("Quadratic monotone lower bound for 2-CLIQUE")
    plt.grid(True, alpha=0.3)
    plt.legend()
    plt.tight_layout()
    plt.savefig("clique2_lower_bound.png", dpi=150)
    print("saved clique2_lower_bound.png")


if __name__ == "__main__":
    main()
