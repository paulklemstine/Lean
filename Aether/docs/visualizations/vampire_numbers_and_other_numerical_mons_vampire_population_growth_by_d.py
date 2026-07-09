"""Bar chart: number of vampire numbers by digit length."""
from __future__ import annotations

import matplotlib.pyplot as plt


def num_digits(n: int) -> int:
    return len(str(n))


def digits(n: int) -> list[int]:
    return sorted(int(c) for c in str(n))


def is_vampire(v: int) -> bool:
    if num_digits(v) % 2:
        return False
    k = num_digits(v) // 2
    x = 1
    while x * x <= v:
        if v % x == 0:
            y = v // x
            if (num_digits(x) == k and num_digits(y) == k
                    and not (x % 10 == 0 and y % 10 == 0)
                    and sorted(digits(x) + digits(y)) == digits(v)):
                return True
        x += 1
    return False


def main() -> None:
    counts = {4: 0, 6: 0}
    for v in range(1000, 10000):
        if is_vampire(v):
            counts[4] += 1
    for v in range(100000, 1000000):
        if is_vampire(v):
            counts[6] += 1
    plt.bar([str(k) for k in counts], list(counts.values()), color="crimson")
    plt.xlabel("number of digits")
    plt.ylabel("count of vampire numbers")
    plt.title("Vampire numbers grow with digit length")
    plt.tight_layout()
    plt.savefig("vampire_counts.png", dpi=150)


if __name__ == "__main__":
    main()
