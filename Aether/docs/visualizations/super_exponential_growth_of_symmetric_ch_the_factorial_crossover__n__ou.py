"""Visualization: factorial vs exponentials on a log scale, showing that n!
eventually overtakes every fixed exponential c^n (super-exponential growth)."""
import matplotlib.pyplot as plt
from math import factorial

ns = list(range(1, 26))
plt.figure(figsize=(8, 5))
plt.semilogy(ns, [factorial(n) for n in ns], "o-", lw=2, label="n!  (super-exp)")
for c in (2, 5, 10):
    plt.semilogy(ns, [c ** n for n in ns], "--", label=f"{c}^n")
plt.xlabel("n"); plt.ylabel("value (log scale)")
plt.title("The factorial outruns every exponential")
plt.legend(); plt.grid(True, which="both", alpha=0.3); plt.tight_layout()
plt.savefig("factorial_crossover.png", dpi=150)
print("wrote factorial_crossover.png")
