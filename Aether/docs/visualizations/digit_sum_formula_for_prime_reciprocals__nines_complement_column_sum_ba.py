"""Visualize the nines-complement structure of a half-order period.

Generates a bar chart: digits of the top half, digits of the bottom half, and
their column sums (all equal to b-1). Requires matplotlib.
"""
import matplotlib.pyplot as plt
from typing import List

def digits_base(b: int, n: int, width: int) -> List[int]:
    ds: List[int] = []
    while n > 0:
        ds.append(n % b); n //= b
    ds += [0] * (width - len(ds))
    return list(reversed(ds))

def visualize(b: int = 10, p: int = 7) -> None:
    value, l = 1 % p, 0
    for l in range(1, p):
        value = (value * b) % p
        if value == 1:
            break
    assert l % 2 == 0, "need even order"
    h = l // 2
    k = (b ** h + 1) // p
    top = digits_base(b, k - 1, h)
    bottom = digits_base(b, b ** h - k, h)
    colsum = [t + s for t, s in zip(top, bottom)]
    x = range(h)
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.bar([i - 0.25 for i in x], top, width=0.25, label="top half")
    ax.bar([i for i in x], bottom, width=0.25, label="bottom half")
    ax.bar([i + 0.25 for i in x], colsum, width=0.25, label="column sum = b-1")
    ax.axhline(b - 1, ls="--", color="gray")
    ax.set_title(f"Nines-complement halves of 1/{p} in base {b}")
    ax.set_xlabel("digit position"); ax.set_ylabel("digit value")
    ax.legend()
    plt.tight_layout(); plt.savefig("halves.png", dpi=120)
    print("saved halves.png")

if __name__ == "__main__":
    visualize(10, 7)
