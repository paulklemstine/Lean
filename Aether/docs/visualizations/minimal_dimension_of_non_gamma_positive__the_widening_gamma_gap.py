import matplotlib.pyplot as plt

# gamma_1 = 1 - n for the all-ones polynomial 1 + t + ... + t^n
ns = list(range(2, 21))
g1 = [1 - n for n in ns]
plt.figure(figsize=(9, 5))
plt.plot(ns, g1, marker="s", color="crimson")
plt.axhline(0, color="black", lw=1)
plt.title("Persistent gamma-gap: second gamma-coefficient of 1 + t + ... + t^n")
plt.xlabel("degree n"); plt.ylabel(r"$\gamma_1 = 1 - n$")
plt.annotate("all values < 0  =>  never gamma-positive", (10, -5))
plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("gamma_gap.png", dpi=150)
print("saved gamma_gap.png")
