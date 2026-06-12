import math
import numpy as np
import matplotlib.pyplot as plt

def kl_div(p, q):
    return sum(pi * math.log(pi / qi) for pi, qi in zip(p, q))

def fisher_form(p, v, w):
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))

q = [0.4, 0.6]
xs = np.linspace(0.02, 0.98, 200)
kls, fishers = [], []
for x in xs:
    p = [x, 1 - x]
    d = [p[0] - q[0], p[1] - q[1]]
    kls.append(kl_div(p, q))
    fishers.append(fisher_form(q, d, d))

plt.figure(figsize=(8, 5))
plt.plot(xs, fishers, label=r"$g_q(p-q,p-q)=\chi^2(p\Vert q)$ (upper bound)", lw=2)
plt.plot(xs, kls, label=r"$\mathrm{KL}(p\Vert q)$", lw=2)
plt.axhline(0, color="gray", ls="--", label="lower bound 0")
plt.axvline(q[0], color="k", ls=":", alpha=0.5)
plt.fill_between(xs, kls, fishers, alpha=0.15)
plt.xlabel(r"$p_1$  (with $p=(p_1,1-p_1)$,  $q=(0.4,0.6)$)")
plt.ylabel("divergence")
plt.title("KL sandwich:  0 ≤ KL ≤ Fisher = χ²")
plt.legend()
plt.tight_layout()
plt.savefig("kl_sandwich.png", dpi=150)
print("saved kl_sandwich.png")
