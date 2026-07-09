import matplotlib.pyplot as plt
from typing import Dict


def stern(n: int, memo: Dict[int, int] = None) -> int:
    if memo is None:
        memo = {0: 0, 1: 1}
    if n in memo:
        return memo[n]
    memo[n] = (stern(n // 2, memo) if n % 2 == 0
               else stern(n // 2, memo) + stern(n // 2 + 1, memo))
    return memo[n]


K = 10
sums = [sum(stern(2 ** k + i) for i in range(2 ** k)) for k in range(K)]
powers = [3 ** k for k in range(K)]
plt.figure(figsize=(8, 5))
plt.plot(range(K), sums, "s-", label="dyadic row sum")
plt.plot(range(K), powers, "--", label="3^k")
plt.yscale("log")
plt.title("Dyadic row sums of Stern's sequence equal 3^k")
plt.xlabel("level k")
plt.ylabel("sum (log scale)")
plt.legend()
plt.tight_layout()
plt.savefig("rowsum_plot.png", dpi=150)
print("wrote rowsum_plot.png")
