"""Visualization: the perfect-square spectrum. Plots 8m-7 for m up to 120,
highlighting the m for which it is a perfect square (the anti-Fibonacci values),
and the square-root-thin counting function ~ sqrt(2M)."""
import matplotlib.pyplot as plt
from math import isqrt

def is_anti_fib(m: int) -> bool:
    if m < 1:
        return False
    s = 8 * m - 7
    r = isqrt(s)
    return r * r == s

M = 120
ms = list(range(1, M + 1))
members = [m for m in ms if is_anti_fib(m)]
counts = [sum(1 for k in range(1, m + 1) if is_anti_fib(k)) for m in ms]
approx = [(2 * m) ** 0.5 for m in ms]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.scatter(ms, [8 * m - 7 for m in ms], s=8, color="lightgray", label="8m-7")
ax1.scatter(members, [8 * m - 7 for m in members], s=30, color="purple",
            label="perfect square (anti-Fib)")
ax1.set_title("8m-7 is square exactly on anti-Fibonacci values")
ax1.set_xlabel("m"); ax1.legend()
ax2.plot(ms, counts, label="#{k<=m : anti-Fib}")
ax2.plot(ms, approx, "--", label="sqrt(2m)")
ax2.set_title("Density-zero counting function ~ sqrt(2m)")
ax2.set_xlabel("m"); ax2.legend()
plt.tight_layout()
plt.savefig("anti_fib_spectrum.png", dpi=130)
print("saved anti_fib_spectrum.png")
