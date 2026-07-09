"""Visualization: consecutive ratio A(n+1)/A(n) decreasing to 1, away from phi."""
import matplotlib.pyplot as plt

def anti_fib_closed(n: int) -> int:
    return (n * n - n + 2) // 2

phi = (1 + 5 ** 0.5) / 2
ns = list(range(1, 60))
ratios = [anti_fib_closed(n + 1) / anti_fib_closed(n) for n in ns]
plt.figure(figsize=(7, 4))
plt.plot(ns, ratios, "o-", label=r"$A(n+1)/A(n)$")
plt.axhline(1.0, color="green", ls="--", label="limit = 1")
plt.axhline(phi, color="red", ls=":", label=r"golden ratio $\varphi$ (avoided)")
plt.xlabel("n")
plt.ylabel("consecutive ratio")
plt.title("Anti-Fibonacci ratio converges to 1, not to the golden ratio")
plt.legend()
plt.tight_layout()
plt.savefig("ratio_avoidance.png", dpi=150)
print("saved ratio_avoidance.png")
