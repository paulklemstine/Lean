"""Visualize the exponential gap between tree and complete-graph signed
resistance determinants and the decay of Delta(K_n)."""
import matplotlib.pyplot as plt
from fractions import Fraction


def delta_complete(n: int) -> float:
    return float(Fraction(2, n) ** n * (n - 1))


def delta_tree(n: int) -> float:
    return float((n - 1) * 2 ** (n - 2)) if n >= 2 else 0.0


ns = list(range(2, 12))
kc = [delta_complete(n) for n in ns]
tr = [delta_tree(n) for n in ns]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.semilogy(ns, tr, "o-", label=r"$\Delta(P_n)=(n-1)2^{n-2}$")
ax1.semilogy(ns, kc, "s-", label=r"$\Delta(K_n)=(2/n)^n(n-1)$")
ax1.set_xlabel("n"); ax1.set_ylabel("signed determinant (log)")
ax1.set_title("Endpoints of the signed resistance determinant"); ax1.legend(); ax1.grid(True)

gap = [t / k for t, k in zip(tr, kc)]
ax2.semilogy(ns, gap, "d-", color="purple", label=r"$\Delta(P_n)/\Delta(K_n)=n^n/4$")
ax2.set_xlabel("n"); ax2.set_ylabel("ratio (log)")
ax2.set_title("Exponential gap"); ax2.legend(); ax2.grid(True)

plt.tight_layout()
plt.savefig("resistance_determinant_gap.png", dpi=150)
print("saved resistance_determinant_gap.png")
