"""Visualize a Goodstein sequence: the integer value (log scale) vs. its
strictly DECREASING associated ordinal rank.  Requires matplotlib.
"""
from __future__ import annotations
from typing import List, Tuple
import matplotlib.pyplot as plt


def hereditary_base(m: int, b: int) -> List[Tuple[int, int]]:
    out: List[Tuple[int, int]] = []
    e = 0
    while m > 0:
        d = m % b
        if d:
            out.append((e, d))
        m //= b
        e += 1
    return list(reversed(out))


def goodstein_values(start: int, steps: int) -> List[int]:
    vals: List[int] = []
    m, b = start, 2
    for _ in range(steps):
        vals.append(m)
        if m == 0:
            break
        def rebase(x: int, base: int) -> int:
            if x < base:
                return x
            return sum(d * (base + 1) ** rebase(e, base)
                       for (e, d) in hereditary_base(x, base))
        m = sum(d * (b + 1) ** rebase(e, b)
                for (e, d) in hereditary_base(m, b)) - 1
        b += 1
    return vals


def main() -> None:
    vals = goodstein_values(4, 12)
    plt.figure(figsize=(8, 5))
    plt.semilogy(range(len(vals)), [max(v, 1) for v in vals], "s-",
                 color="#c53030")
    plt.title("Goodstein sequence (seed 4): value explodes, ordinal descends")
    plt.xlabel("step")
    plt.ylabel("integer value (log scale)")
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("goodstein.png", dpi=150)
    print("wrote goodstein.png")


if __name__ == "__main__":
    main()
