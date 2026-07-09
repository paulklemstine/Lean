import matplotlib.pyplot as plt

ks = list(range(4, 60))
exp = [(k - 2.0) / (k - 1.0) for k in ks]
dens = [(k - 1.0) / (k - 2.0) for k in ks]
plt.figure(figsize=(8, 5))
plt.plot(ks, exp, label=r"exponent $(k-2)/(k-1)$")
plt.plot(ks, dens, label=r"density $(k-1)/(k-2)$")
plt.axhline(1.0, ls="--", color="gray")
plt.xlabel("cycle length k"); plt.ylabel("value")
plt.title("Reciprocal exponent and 2-density (product = 1)")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("reciprocals.png", dpi=150)
