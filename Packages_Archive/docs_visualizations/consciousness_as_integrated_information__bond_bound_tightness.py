"""Visualize the bond bound and its tightness: random matrix-product states
M = A @ B with bond dimension D have Phi(M) <= D - 1, and the maximally
entangled state attains Phi = d - 1. Saves phi_bond.png."""
import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(7)
Ds = list(range(1, 9))
phi_mps, bound, phi_max = [], [], []
for D in Ds:
    A = rng.standard_normal((10, D)) + 1j * rng.standard_normal((10, D))
    B = rng.standard_normal((D, 10)) + 1j * rng.standard_normal((D, 10))
    phi_mps.append(max(int(np.linalg.matrix_rank(A @ B)) - 1, 0))
    bound.append(D - 1)
    phi_max.append(max(int(np.linalg.matrix_rank(np.eye(D, dtype=complex))) - 1, 0))

plt.figure(figsize=(8, 5))
plt.plot(Ds, bound, "k--", label="bound  D - 1")
plt.plot(Ds, phi_mps, "o-", color="steelblue", label="Phi(A@B), random MPS")
plt.plot(Ds, phi_max, "s-", color="crimson", label="Phi(I_d) = d - 1 (tight)")
plt.xlabel("bond / local dimension D = d")
plt.ylabel("integrated information Phi")
plt.title("Bond dimension caps integration (and the bound is tight)")
plt.legend()
plt.tight_layout()
plt.savefig("phi_bond.png", dpi=150)
print("saved phi_bond.png")
