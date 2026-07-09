"""Visualization: densities of the representation sets S_m and the saturation
threshold at m = 4.  Requires matplotlib."""
from math import isqrt
import matplotlib.pyplot as plt


def is_sum_of_m_squares(m: int, n: int) -> bool:
    if n < 0 or m < 0:
        return False
    if m == 0:
        return n == 0
    if m >= 4:
        return True
    squares = [s * s for s in range(isqrt(n) + 1)]
    reachable = {0}
    for _ in range(m):
        nxt = set()
        for v in reachable:
            for sq in squares:
                if v + sq <= n:
                    nxt.add(v + sq)
        reachable = nxt
    return n in reachable


def main() -> None:
    upper = 3000
    ms = [2, 3, 4, 5, 6]
    densities = []
    for m in ms:
        count = sum(1 for n in range(upper + 1) if is_sum_of_m_squares(m, n))
        densities.append(count / (upper + 1))
    plt.figure(figsize=(7, 4.5))
    plt.bar([str(m) for m in ms], densities, color="#3366cc")
    plt.axhline(1.0, color="crimson", ls="--", label="all integers (density 1)")
    plt.xlabel("m")
    plt.ylabel(f"density of S_m in [0, {upper}]")
    plt.title("Representation sets saturate to all integers at m = 4")
    plt.legend()
    plt.tight_layout()
    plt.savefig("representation_densities.png", dpi=150)
    print("saved representation_densities.png")


if __name__ == "__main__":
    main()
