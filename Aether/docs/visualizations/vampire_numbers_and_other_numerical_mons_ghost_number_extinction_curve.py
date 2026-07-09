import matplotlib.pyplot as plt
from typing import List


def digits(b: int, n: int) -> List[int]:
    out: List[int] = []
    while n > 0:
        out.append(n % b)
        n //= b
    return out


def is_ghost(v: int, x: int, y: int) -> bool:
    dv = set(digits(10, v))
    return dv.isdisjoint(digits(10, x)) and dv.isdisjoint(digits(10, y))


def ghost_density_decay(max_width: int) -> None:
    widths, densities = [], []
    for width in range(2, max_width + 1):
        lo, hi = 10 ** (width - 1), 10 ** width
        total = hi - lo
        c = 0
        for v in range(lo, hi):
            x = 2
            while x * x <= v:
                if v % x == 0 and is_ghost(v, x, v // x):
                    c += 1
                    break
                x += 1
        widths.append(width)
        densities.append(c / total)
    plt.figure(figsize=(7, 4))
    plt.plot(widths, densities, "o-", color="#00838f")
    plt.xlabel("number of digits")
    plt.ylabel("fraction admitting a ghost factorization")
    plt.title("Ghost numbers fade toward extinction")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("ghost_decay.png", dpi=150)
    print("saved ghost_decay.png")


if __name__ == "__main__":
    ghost_density_decay(5)
