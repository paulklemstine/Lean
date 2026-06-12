"""Visualization: the KL sandwich and the Bernoulli gap function.

Generates two figures:
  (1) KL, chi^2, and 2*TV^2 vs. an interpolation parameter, showing
      2*TV^2 <= KL <= chi^2 (the conjectured floor and the proved ceiling).
  (2) The Bernoulli gap g(q) = KL(Ber p || Ber q) - 2(p-q)^2 with its
      unique zero at q = p.
"""
from __future__ import annotations
import math
from typing import List
import matplotlib.pyplot as plt


def kl(p: List[float], q: List[float]) -> float:
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))


def chi2(p: List[float], q: List[float]) -> float:
    return sum((pi - qi) ** 2 / qi for pi, qi in zip(p, q))


def tv(p: List[float], q: List[float]) -> float:
    return 0.5 * sum(abs(pi - qi) for pi, qi in zip(p, q))


def kl_ber(p: float, q: float) -> float:
    return p * math.log(p / q) + (1 - p) * math.log((1 - p) / (1 - q))


# Figure 1: sandwich along a path p(t) = (1-t)*base + t*target
base = [0.5, 0.3, 0.2]
target = [0.1, 0.2, 0.7]
ts = [i / 200 for i in range(1, 200)]
kls, chis, tvs = [], [], []
for t in ts:
    p = [(1 - t) * b + t * c for b, c in zip(base, target)]
    q = base
    kls.append(kl(p, q))
    chis.append(chi2(p, q))
    tvs.append(2 * tv(p, q) ** 2)

fig, axes = plt.subplots(1, 2, figsize=(12, 5))
axes[0].plot(ts, chis, label=r"$\chi^2(p\|q)$ (proved ceiling)", lw=2)
axes[0].plot(ts, kls, label=r"$KL(p\|q)$", lw=2)
axes[0].plot(ts, tvs, label=r"$2\,TV^2$ (conjectured floor)", lw=2, ls="--")
axes[0].set_xlabel("interpolation parameter t")
axes[0].set_ylabel("divergence")
axes[0].set_title("The KL sandwich")
axes[0].legend()

# Figure 2: Bernoulli gap
p0 = 0.3
qs = [i / 500 for i in range(1, 500)]
gap = [kl_ber(p0, q) - 2 * (p0 - q) ** 2 for q in qs]
axes[1].plot(qs, gap, lw=2)
axes[1].axvline(p0, color="red", ls=":", label=f"q = p = {p0}")
axes[1].axhline(0, color="black", lw=0.8)
axes[1].set_xlabel("q")
axes[1].set_ylabel("g(q) = KL(Ber p || Ber q) - 2(p-q)^2")
axes[1].set_title("Bernoulli gap: unique zero at q = p")
axes[1].legend()

plt.tight_layout()
plt.savefig("kl_sandwich.png", dpi=150)
print("Saved kl_sandwich.png")
