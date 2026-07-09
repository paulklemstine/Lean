"""Visualization: anti-Fibonacci quadratic growth vs. the parabola n^2/2,
and the slow convergence of A(n)/n^2 to 1/2."""
import matplotlib.pyplot as plt

def anti_fib_closed(n: int) -> int:
    return 1 + n * (n - 1) // 2

ns = list(range(1, 201))
A = [anti_fib_closed(n) for n in ns]
para = [n ** 2 / 2 for n in ns]
ratio = [anti_fib_closed(n) / n ** 2 for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.plot(ns, A, label="A(n)")
ax1.plot(ns, para, "--", label="n^2/2")
ax1.set_title("Anti-Fibonacci values vs. n^2/2")
ax1.set_xlabel("n"); ax1.legend()
ax2.plot(ns, ratio, color="crimson")
ax2.axhline(0.5, ls="--", color="gray", label="limit 1/2")
ax2.set_title("A(n)/n^2 -> 1/2")
ax2.set_xlabel("n"); ax2.legend()
plt.tight_layout()
plt.savefig("anti_fib_growth.png", dpi=130)
print("saved anti_fib_growth.png")
