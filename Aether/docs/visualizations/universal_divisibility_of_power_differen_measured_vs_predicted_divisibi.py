"""Plot measured vs predicted density of p | (a^5 - a)."""
from __future__ import annotations
from math import gcd
import matplotlib.pyplot as plt

def measured(p: int, n: int, N: int = 20000) -> float:
    return sum(1 for a in range(1, N + 1) if (pow(a, n, p) - a) % p == 0) / N

primes = [2, 3, 5, 7, 11, 13, 17]
n = 5
meas = [measured(p, n) for p in primes]
pred = [(gcd(n - 1, p - 1) + 1) / p for p in primes]
plt.figure(figsize=(9, 5))
plt.plot(primes, meas, "o-", label="measured")
plt.plot(primes, pred, "s--", label="predicted (gcd(n-1,p-1)+1)/p")
plt.xlabel("prime p")
plt.ylabel("density of p | (a^5 - a)")
plt.title("Divisibility density for a^5 - a")
plt.legend()
plt.tight_layout()
plt.savefig("density.png", dpi=150)
print("saved density.png")
