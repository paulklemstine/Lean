"""Plot the single-exponential floor exponent vs the double-exponential ceiling."""
import math
import matplotlib.pyplot as plt

def tower(base: int, height: int) -> int:
    v = 1
    for _ in range(height):
        v = base ** v
    return v

ks = list(range(3, 8))
# Work in log2 to keep numbers finite: log2(2^{k^2}) = k^2 ; log2(tower(2,k)) = tower(2,k-1)
floor_log = [k * k for k in ks]
ceil_log = [tower(2, k - 1) for k in ks]

fig, ax = plt.subplots(figsize=(8, 5))
ax.semilogy(ks, floor_log, "o-", label=r"$\log_2$ floor $=k^2$ (single exp)")
ax.semilogy(ks, ceil_log, "s-", label=r"$\log_2$ ceiling $=\mathrm{tower}(2,k-1)$ (double exp)")
ax.set_xlabel("clique size k")
ax.set_ylabel(r"$\log_2$ of the Ramsey bound (log scale)")
ax.set_title("Hypergraph Ramsey: probabilistic floor vs stepping-up ceiling")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
fig.tight_layout()
fig.savefig("ramsey_growth_separation.png", dpi=150)
print("wrote ramsey_growth_separation.png")
