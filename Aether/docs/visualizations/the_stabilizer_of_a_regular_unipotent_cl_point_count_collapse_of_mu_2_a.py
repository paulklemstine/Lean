"""Bar chart: number of F_p-points of mu_2 across primes, highlighting p=2."""
import matplotlib.pyplot as plt

def mu2_count(p: int) -> int:
    return len({a for a in range(p) if (a*a) % p == 1})

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]
counts = [mu2_count(p) for p in primes]
colors = ["crimson" if p == 2 else "steelblue" for p in primes]

plt.figure(figsize=(9, 4.5))
plt.bar([str(p) for p in primes], counts, color=colors)
plt.axhline(2, ls="--", c="gray", lw=1)
plt.title(r"Number of points of $\mu_2$ ($a^2=1$) over $\mathbb{F}_p$")
plt.xlabel("characteristic p"); plt.ylabel("distinct points")
plt.annotate("collapse to 1\n(fat point)", xy=(0, 1), xytext=(0.6, 1.6),
             arrowprops=dict(arrowstyle="->"))
plt.tight_layout(); plt.savefig("mu2_pointcount.png", dpi=150)
print("wrote mu2_pointcount.png")
