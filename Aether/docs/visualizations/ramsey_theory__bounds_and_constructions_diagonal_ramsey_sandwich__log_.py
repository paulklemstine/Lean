"""Plot the diagonal Ramsey sandwich 2^(m-1) < R(2m,2m) <= 4^(2m-1)."""
import matplotlib.pyplot as plt

ms = list(range(4, 11))
lower = [2 ** (m - 1) for m in ms]
upper = [4 ** (2 * m - 1) for m in ms]
k = [2 * m for m in ms]

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(k, lower, "o-", label=r"lower  $2^{m-1}$ (probabilistic)")
ax.semilogy(k, upper, "s-", label=r"upper  $4^{2m-1}$ (Erdos-Szekeres)")
ax.fill_between(k, lower, upper, alpha=0.15)
ax.set_xlabel("k = 2m")
ax.set_ylabel("R(k,k)  (log scale)")
ax.set_title("Exponential sandwich for the diagonal Ramsey number")
ax.legend()
ax.grid(True, which="both", ls=":")
plt.tight_layout()
plt.savefig("ramsey_sandwich.png", dpi=150)
print("wrote ramsey_sandwich.png")
