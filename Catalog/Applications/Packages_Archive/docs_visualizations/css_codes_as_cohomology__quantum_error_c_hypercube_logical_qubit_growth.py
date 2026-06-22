"""Visualization: growth of the hypercube logical-qubit count beta_1(Q_n).

Plots beta_1(Q_n) = n*2^(n-1) - 2^n + 1 on a log scale, illustrating that
hypercube CSS codes are richly multi-qubit (Theorem 7.3: beta_1 > 1 for n>=3).
"""
import matplotlib.pyplot as plt


def hypercube_betti1(n: int) -> int:
    return n * 2 ** (n - 1) - 2 ** n + 1


ns = list(range(1, 13))
betti = [hypercube_betti1(n) for n in ns]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ns, [max(b, 1) for b in betti], "o-", color="#6a0dad", lw=2, ms=7)
ax.set_yscale("log")
ax.axhline(1, color="gray", ls="--", lw=1, label="1 qubit threshold")
ax.set_xlabel("hypercube dimension n")
ax.set_ylabel("logical qubits  k = beta_1(Q_n)")
ax.set_title("Hypercube CSS codes are multi-qubit: k grows ~ (n/2 - 1) * 2^n")
for n, b in zip(ns, betti):
    ax.annotate(str(b), (n, max(b, 1)), textcoords="offset points",
                xytext=(0, 8), ha="center", fontsize=8)
ax.legend()
ax.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("hypercube_betti.png", dpi=150)
print("saved hypercube_betti.png")
