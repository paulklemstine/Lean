import math
import matplotlib.pyplot as plt

ks = list(range(4, 200))
f1 = [(k - 1.0) ** (1.0 / (k - 1.0)) for k in ks]
f2 = [(2.0 * (k - 1.0) / k) ** ((k - 2.0) / (k - 1.0)) for k in ks]
prod = [a * b for a, b in zip(f1, f2)]
plt.figure(figsize=(8, 5))
plt.plot(ks, f1, label=r"$(k-1)^{1/(k-1)}\to 1$")
plt.plot(ks, f2, label=r"$(2(k-1)/k)^{(k-2)/(k-1)}\to 2$")
plt.plot(ks, prod, lw=2, color="black", label=r"product $c_k$")
plt.xlabel("cycle length k"); plt.ylabel("value")
plt.title("Factorization of the threshold constant")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("factors.png", dpi=150)
