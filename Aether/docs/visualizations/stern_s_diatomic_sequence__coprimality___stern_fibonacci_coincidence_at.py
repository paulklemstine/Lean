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


def fib(k: int) -> int:
    a, b = 0, 1
    for _ in range(k):
        a, b = b, a + b
    return a


depth = 10
xs = list(range(depth))
sj = [stern((4 ** n - 1) // 3) for n in xs]
f2 = [fib(2 * n) for n in xs]
plt.figure(figsize=(8, 5))
plt.plot(xs, sj, "o-", label="s(J(n))")
plt.plot(xs, f2, "x--", label="F(2n)")
plt.yscale("log")
plt.title("Stern along Jacobsthal indices equals even-index Fibonacci")
plt.xlabel("n")
plt.ylabel("value (log scale)")
plt.legend()
plt.tight_layout()
plt.savefig("bridge_plot.png", dpi=150)
print("wrote bridge_plot.png")
