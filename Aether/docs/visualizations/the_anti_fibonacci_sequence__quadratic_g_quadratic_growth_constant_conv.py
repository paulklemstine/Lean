"""Visualization: A(n)/n^2 converging to 1/2 (log-spaced n)."""
import matplotlib.pyplot as plt

def anti_fib_closed(n: int) -> int:
    return (n * n - n + 2) // 2

ns = [10 ** k for k in range(1, 7)]
ratios = [anti_fib_closed(n) / (n * n) for n in ns]
plt.figure(figsize=(7, 4))
plt.semilogx(ns, ratios, "o-", label=r"$A(n)/n^2$")
plt.axhline(0.5, color="red", ls="--", label=r"limit $=1/2$")
plt.axhline(0.25, color="gray", ls=":", label=r"refuted conjecture $1/4$")
plt.xlabel("n (log scale)")
plt.ylabel(r"$A(n)/n^2$")
plt.title("Anti-Fibonacci quadratic growth constant")
plt.legend()
plt.tight_layout()
plt.savefig("growth_constant.png", dpi=150)
print("saved growth_constant.png")
