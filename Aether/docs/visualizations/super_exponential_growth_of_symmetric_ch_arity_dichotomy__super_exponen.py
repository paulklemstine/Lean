"""Visualization: growing vs bounded arity. numSCD(n)=n! (super-exponential)
against the crown floor m^(2w) (polynomial), on a log scale."""
import matplotlib.pyplot as plt
from math import factorial

xs = list(range(1, 21))
w = 2
plt.figure(figsize=(8, 5))
plt.semilogy(xs, [factorial(n) for n in xs], "o-", lw=2,
             label="slab numSCD(n)=n! (growing arity)")
plt.semilogy(xs, [m ** (2 * w) for m in xs], "s--", lw=2,
             label=f"crown floor m^(2w), w={w} (bounded arity)")
plt.semilogy(xs, [2 ** n for n in xs], ":", color="gray", label="2^n reference")
plt.xlabel("parameter (n or m)"); plt.ylabel("count (log scale)")
plt.title("Growing arity explodes; bounded arity stays polynomial")
plt.legend(); plt.grid(True, which="both", alpha=0.3); plt.tight_layout()
plt.savefig("arity_dichotomy.png", dpi=150)
print("wrote arity_dichotomy.png")
