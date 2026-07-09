"""Plot s2(x*y) versus its submultiplicative bound over a range of products."""
from __future__ import annotations

import matplotlib.pyplot as plt


def s2(n: int) -> int:
    return bin(n).count("1")


def main() -> None:
    products, actual, bound = [], [], []
    y = 21
    for x in range(10, 100):
        products.append(x * y)
        actual.append(s2(x * y))
        bound.append(min(y * s2(x), x * s2(y)))
    plt.plot(products, actual, label="s2(x*y) actual", color="teal")
    plt.plot(products, bound, label="min(y*s2(x), x*s2(y)) bound", color="orange")
    plt.xlabel("product x*y  (y = 21 fixed)")
    plt.ylabel("binary digit sum")
    plt.title("Submultiplicativity of the binary digit sum")
    plt.legend()
    plt.tight_layout()
    plt.savefig("binary_bound.png", dpi=150)


if __name__ == "__main__":
    main()
