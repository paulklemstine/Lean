"""Plot c(k)=1/k^2 and the shifted exponent k - 1/k^2."""
import matplotlib.pyplot as plt

ks = list(range(2, 13))
c = [1.0 / (k * k) for k in ks]
shifted = [k - 1.0 / (k * k) for k in ks]

fig, ax1 = plt.subplots(figsize=(8, 5))
ax1.plot(ks, shifted, "s-", color="tab:blue", label=r"$k - 1/k^2$")
ax1.plot(ks, ks, "--", color="gray", label=r"$k$ (naive)")
ax1.axhline(1.0, color="green", ls=":", label="floor exponent 1")
ax1.set_xlabel("degree k")
ax1.set_ylabel("exponent")
ax1.legend(loc="upper left")

ax2 = ax1.twinx()
ax2.plot(ks, c, "o-", color="tab:red", label=r"$c(k)=1/k^2$")
ax2.set_ylabel("power-saving constant c(k)", color="tab:red")
plt.title("Power-saving constant and shifted exponent")
plt.tight_layout()
plt.savefig("exponent.png", dpi=150)
print("saved exponent.png")
