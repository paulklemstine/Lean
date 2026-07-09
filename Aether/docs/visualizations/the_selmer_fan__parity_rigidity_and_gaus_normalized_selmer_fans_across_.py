"""Visualize the Selmer fan for several q, showing self-dual bell shapes."""
import matplotlib.pyplot as plt
from typing import List


def fan(q: int, n: int) -> List[int]:
    row = [1]
    for m in range(1, n + 1):
        new = [1] + [0] * m
        for j in range(1, m + 1):
            up = row[j] if j < len(row) else 0
            new[j] = row[j - 1] + (q ** j) * up
        row = new
    return row


n = 8
plt.figure(figsize=(9, 5))
for q in [1, 2, 3, 5]:
    f = fan(q, n)
    ks = list(range(n + 1))
    norm = [x / sum(f) for x in f]
    plt.plot(ks, norm, marker="o", label=f"q={q}")
plt.axvline(n / 2, ls="--", color="gray", alpha=0.6, label="axis n/2")
plt.title(f"Normalized Selmer fan (n={n}): self-dual layers, Pascal at q=1")
plt.xlabel("rank k")
plt.ylabel("normalized layer weight")
plt.legend()
plt.tight_layout()
plt.savefig("selmer_fan.png", dpi=150)
print("wrote selmer_fan.png")
