import numpy as np
import matplotlib.pyplot as plt

def image_sq(n: int) -> int:
    A = range(-n, n + 1)
    return len({a * a for a in A})

ns = list(range(2, 60))
sizes = [len(range(-n, n + 1)) for n in ns]
img = [image_sq(n) for n in ns]
k = 2
lower = [s / k for s in sizes]
upper = [s ** (k - 1 / k ** 2) for s in sizes]

plt.figure(figsize=(8, 5))
plt.fill_between(sizes, lower, upper, alpha=0.15, color="tab:blue", label="corridor")
plt.plot(sizes, lower, "--", color="tab:red", label="lower wall |A|/k")
plt.plot(sizes, upper, "--", color="tab:green", label="upper wall |A|^(k-1/k^2)")
plt.plot(sizes, img, "o-", color="tab:blue", label="|f(A)|, f=x^2")
plt.yscale("log")
plt.xlabel("|A|")
plt.ylabel("cardinality (log scale)")
plt.title("Power-saving corridor for f(x)=x^2")
plt.legend()
plt.tight_layout()
plt.savefig("corridor_band.png", dpi=150)
print("wrote corridor_band.png")
