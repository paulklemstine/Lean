import matplotlib.pyplot as plt
from fractions import Fraction

Ns = list(range(0, 26))
binary_frac = [float(Fraction(2 ** n, 3 ** n)) for n in Ns]
budget_frac = [min(1, 1_000_000_000 / 3 ** n) for n in Ns]

fig, ax = plt.subplots(figsize=(9, 5.5))
ax.semilogy(Ns, binary_frac, "o-", label=r"binary reach $2^N/3^N=(2/3)^N$")
ax.semilogy(Ns, budget_frac, "s--", label=r"constant budget $10^9/3^N$ (capped at 1)")
ax.axhline(1.0, color="grey", lw=0.6)
ax.set_xlabel("number of statements N")
ax.set_ylabel("reachable fraction of all oracles (log scale)")
ax.set_title("The Oracle Counting Barrier: describable share vanishes geometrically")
ax.legend()
ax.grid(True, which="both", alpha=0.3)
fig.tight_layout()
fig.savefig("oracle_barrier_vanishing.png", dpi=150)
print("saved oracle_barrier_vanishing.png")
