"""Bar chart of the universal divisor D(n) for n = 2..20."""
from __future__ import annotations
import matplotlib.pyplot as plt

def is_prime(k: int) -> bool:
    return k > 1 and all(k % d for d in range(2, int(k ** 0.5) + 1))

def D(n: int) -> int:
    prod = 1
    for p in range(2, n + 1):
        if is_prime(p) and (n - 1) % (p - 1) == 0:
            prod *= p
    return prod

ns = list(range(2, 21))
vals = [D(n) for n in ns]
plt.figure(figsize=(10, 5))
plt.bar([str(n) for n in ns], vals, color="steelblue")
plt.yscale("log")
plt.xlabel("exponent n")
plt.ylabel("D(n)  (log scale)")
plt.title("Maximal universal divisor D(n) of a^n - a")
plt.tight_layout()
plt.savefig("universal_divisor.png", dpi=150)
print("saved universal_divisor.png")
