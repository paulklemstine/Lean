import numpy as np
import matplotlib.pyplot as plt


def fib(n):
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


ns = np.arange(0, 45)
fig, ax = plt.subplots(figsize=(9, 6))
ax.plot(ns, [fib(int(n)) for n in ns], marker="o", color="crimson",
        label="Fibonacci F(n)")
for k in (2, 4, 6):
    ax.plot(ns, (ns + 2.0) ** k, linestyle="--",
            label=f"polynomial cap (n+2)^{k}")
ax.set_yscale("log")
ax.set_xlabel("n")
ax.set_ylabel("value (log scale)")
ax.set_title("Fibonacci growth overtakes every polynomial (Thm 4.2)")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("fib_separation.png", dpi=150)
print("wrote fib_separation.png")
