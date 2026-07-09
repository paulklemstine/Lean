"""Visualization 3: consecutive products a_n a_{n+1} highlighting exceptions."""
import math
import matplotlib.pyplot as plt

def is_square(n):
    r = math.isqrt(n); return r * r == n

def a(n): return 0.0 if is_square(n) else ((-1) ** n)

N = 100
prod = [a(n) * a(n + 1) for n in range(N)]
colors = ["#e53e3e" if p >= 0 else "#2b6cb0" for p in prod]
plt.figure(figsize=(12, 3))
plt.bar(range(N), prod, color=colors, width=0.9)
plt.axhline(0, color="black", linewidth=0.6)
plt.xlabel("index n"); plt.ylabel("a_n * a_{n+1}")
plt.title("Neighbor products: red bars (>= 0) mark the exceptional set (near squares)")
plt.tight_layout(); plt.savefig("neighbor_products.png", dpi=130)
print("saved neighbor_products.png")
