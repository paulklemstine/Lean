"""Plot the exact expectation E[badCount] = C(n,4)/8 and the E=1 first-moment line."""
from math import comb
import matplotlib.pyplot as plt

ns = list(range(4, 16))
expectation = [comb(n, 4) / 8 for n in ns]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ns, expectation, "o-", color="darkred", label=r"$E[\mathrm{badCount}]=\binom{n}{4}/8$")
ax.axhline(1.0, color="gray", ls="--", label="first-moment threshold $E=1$")
ax.axvline(5.5, color="steelblue", ls=":", label="success only for $n\le 5$")
ax.set_xlabel("number of vertices n")
ax.set_ylabel("expected number of monochromatic tetrahedra")
ax.set_title("Exact first-moment expectation for monochromatic 4-sets (r=3)")
ax.legend()
ax.grid(True, alpha=0.3)
fig.tight_layout()
fig.savefig("ramsey_expectation.png", dpi=150)
print("wrote ramsey_expectation.png")
