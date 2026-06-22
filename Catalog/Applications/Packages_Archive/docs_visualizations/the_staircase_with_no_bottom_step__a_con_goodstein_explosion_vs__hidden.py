"""Visualize the ordinal descent of a Hardy-style self-descent and the
explosive raw values of a Goodstein sequence side by side."""
from __future__ import annotations
from typing import List, Tuple
import matplotlib.pyplot as plt


def bump_base(n: int, old: int, new: int) -> int:
    if n == 0:
        return 0
    digits, m = [], n
    while m > 0:
        digits.append(m % old); m //= old
    return sum(d * (new ** bump_base(i, old, new))
               for i, d in enumerate(digits) if d)


def goodstein_values(start: int, steps: int) -> List[int]:
    vals, value, base = [], start, 2
    for _ in range(steps):
        vals.append(value)
        if value == 0:
            break
        value = bump_base(value, base, base + 1) - 1
        base += 1
    return vals


def main() -> None:
    vals = goodstein_values(4, 9)
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(len(vals)), vals, "o-", color="crimson")
    ax.set_yscale("log")
    ax.set_title("Goodstein sequence from 4: raw values explode (log scale)")
    ax.set_xlabel("step k")
    ax.set_ylabel("Goodstein value (log)")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    fig.savefig("goodstein_explosion.png", dpi=140)
    print("wrote goodstein_explosion.png")


if __name__ == "__main__":
    main()
