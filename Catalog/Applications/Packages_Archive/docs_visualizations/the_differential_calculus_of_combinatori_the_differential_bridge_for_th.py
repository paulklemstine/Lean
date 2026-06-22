"""Visualize the differential bridge for the linear-order species L.

EGF(L) = 1/(1-X). The derivative species L' has EGF coefficients (n+1) and the
pointed species L* has EGF coefficients n, matching d/dX and X d/dX of 1/(1-X).
"""
import matplotlib.pyplot as plt
from math import factorial

N = 9
n = list(range(N))

# Counting sequences (log scale, they grow factorially)
L = [factorial(k) for k in n]
Lder = [factorial(k + 1) for k in n]        # L'[k] = (k+1)!
Lpt = [k * factorial(k) for k in n]         # L*[k] = k * k!

# EGF coefficients (these are simple integers)
egf_L = [1 for _ in n]                       # 1/(1-X)
egf_Lder = [k + 1 for k in n]               # d/dX 1/(1-X) = 1/(1-X)^2
egf_Lpt = [k for k in n]                     # X d/dX 1/(1-X)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.semilogy(n, L, "o-", label="L  (n!)")
ax1.semilogy(n, Lder, "s--", label="L'  (n+1)!")
ax1.semilogy(n, Lpt[1:], "^:", label="L*  (n*n!)")
ax1.set_title("Counting sequences (log scale)")
ax1.set_xlabel("n"); ax1.set_ylabel("number of structures"); ax1.legend()

ax2.plot(n, egf_L, "o-", label="EGF(L) coeff = 1")
ax2.plot(n, egf_Lder, "s--", label="EGF(L') = d/dX -> n+1")
ax2.plot(n, egf_Lpt, "^:", label="EGF(L*) = X d/dX -> n")
ax2.set_title("EGF coefficients: differentiation linearizes growth")
ax2.set_xlabel("n"); ax2.set_ylabel("coefficient of X^n"); ax2.legend()

plt.tight_layout()
plt.savefig("species_differential_bridge.png", dpi=150)
print("wrote species_differential_bridge.png")
