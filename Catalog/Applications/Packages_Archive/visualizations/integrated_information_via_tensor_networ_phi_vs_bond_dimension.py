"""Visualization: Phi vs bond dimension for random matrix product states.

Generates random open-boundary MPS of fixed bond dimension D, computes the exact
Phi over the minimum-information partition, and plots the empirical Phi against the
theoretical ceiling D - 1 (phi_mps_le_bond). Saves 'phi_vs_bond.png'.
"""
from itertools import product
from typing import Tuple, List
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

Config = Tuple[int, ...]

def random_mps(n: int, d: int, D: int, seed: int):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, d, D, D)) + 1j*rng.standard_normal((n, d, D, D))
    vL = rng.standard_normal(D) + 1j*rng.standard_normal(D)
    vR = rng.standard_normal(D) + 1j*rng.standard_normal(D)
    def psi(x: Config) -> complex:
        v = vL.copy()
        for site, s in enumerate(x):
            v = v @ A[site, s]
        return complex(v @ vR)
    return psi

def phi_mip(psi, n: int, d: int) -> int:
    parts, seen = [], set()
    for S in product([0, 1], repeat=n):
        s = tuple(i for i in range(n) if S[i])
        if 1 <= len(s) <= n - 1 and s not in seen:
            seen.add(s); parts.append(s)
    best = None
    for S in parts:
        Sl = sorted(S); Sc = sorted(set(range(n)) - set(Sl))
        rows = list(product(range(d), repeat=len(Sl)))
        cols = list(product(range(d), repeat=len(Sc)))
        M = np.zeros((len(rows), len(cols)), dtype=complex)
        for i, a in enumerate(rows):
            for j, b in enumerate(cols):
                full = [0]*n
                for q, v in zip(Sl, a): full[q] = v
                for q, v in zip(Sc, b): full[q] = v
                M[i, j] = psi(tuple(full))
        sv = np.linalg.svd(M, compute_uv=False)
        r = int(np.sum(sv > 1e-9 * max(1.0, sv[0]))) if sv.size else 0
        c = max(r - 1, 0)
        best = c if best is None else min(best, c)
    return best

n, d = 4, 2
Ds = list(range(1, 5))
means, ceilings = [], []
for D in Ds:
    vals = [phi_mip(random_mps(n, d, D, seed), n, d) for seed in range(20)]
    means.append(np.mean(vals)); ceilings.append(D - 1)

plt.figure(figsize=(7, 5))
plt.plot(Ds, ceilings, "r--", label="theoretical ceiling  D - 1")
plt.plot(Ds, means, "bo-", label="empirical mean Phi (random MPS)")
plt.xlabel("bond dimension D"); plt.ylabel("Phi")
plt.title("Integrated information vs MPS bond dimension (n=4 qubits)")
plt.legend(); plt.grid(True, alpha=0.3)
plt.savefig("phi_vs_bond.png", dpi=150, bbox_inches="tight")
print("saved phi_vs_bond.png")
