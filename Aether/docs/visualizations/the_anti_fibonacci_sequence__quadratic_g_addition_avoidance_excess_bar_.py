"""Visualization: avoidance excess (A(n-1)+A(n-2)) - A(n) = (n-2)(n-5)/2."""
import matplotlib.pyplot as plt

def anti_fib_closed(n: int) -> int:
    return (n * n - n + 2) // 2

ns = list(range(2, 16))
excess = [anti_fib_closed(n - 1) + anti_fib_closed(n - 2) - anti_fib_closed(n) for n in ns]
colors = ["red" if e < 0 else ("orange" if e == 0 else "steelblue") for e in excess]
plt.figure(figsize=(7, 4))
plt.bar(ns, excess, color=colors)
plt.axhline(0, color="black", lw=0.8)
plt.xlabel("n")
plt.ylabel(r"$(A(n-1)+A(n-2)) - A(n)$")
plt.title("Addition-avoidance excess: strict for n >= 6, equality at n = 5")
plt.tight_layout()
plt.savefig("avoidance_excess.png", dpi=150)
print("saved avoidance_excess.png")
