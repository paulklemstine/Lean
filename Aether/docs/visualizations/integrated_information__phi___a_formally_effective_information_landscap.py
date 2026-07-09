"""Visualize the effective-information landscape and the MIP that realizes Phi.

Generates a bar chart of ei(A) over every nontrivial cut A of a system, with
the Minimum Information Partition (the bar achieving Phi) highlighted, plus a
curve showing how Phi of two coupled bits grows with their correlation.
"""
from itertools import chain, combinations
from math import log2
import matplotlib.pyplot as plt


def nontrivial_cuts(n):
    elts = tuple(range(n)); full = frozenset(elts)
    subs = chain.from_iterable(combinations(elts, r) for r in range(n + 1))
    return [frozenset(s) for s in subs if 0 < len(s) and frozenset(s) != full]


def mi_ei(n, joint):
    def ei(A):
        Ac = frozenset(range(n)) - A
        ai, bi = sorted(A), sorted(Ac)
        pj, pa, pb = {}, {}, {}
        for st, p in joint.items():
            a = tuple(st[i] for i in ai); b = tuple(st[i] for i in bi)
            pj[(a, b)] = pj.get((a, b), 0.0) + p
            pa[a] = pa.get(a, 0.0) + p; pb[b] = pb.get(b, 0.0) + p
        return max(sum(p * log2(p / (pa[a] * pb[b])) for (a, b), p in pj.items() if p > 0), 0.0)
    return ei


def two_bit_joint(rho):
    """Symmetric two-bit joint with correlation parameter rho in [0,1]."""
    same = (1 + rho) / 4
    diff = (1 - rho) / 4
    return {(0, 0): same, (1, 1): same, (0, 1): diff, (1, 0): diff}


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: ei landscape for 3 perfectly-correlated bits.
n = 3
joint3 = {(0, 0, 0): 0.5, (1, 1, 1): 0.5}
ei = mi_ei(n, joint3)
cuts = nontrivial_cuts(n)
vals = [ei(A) for A in cuts]
phi = min(vals)
labels = ["{" + ",".join(map(str, sorted(A))) + "}" for A in cuts]
colors = ["crimson" if abs(v - phi) < 1e-9 else "steelblue" for v in vals]
ax1.bar(labels, vals, color=colors)
ax1.axhline(phi, ls="--", color="crimson", label=f"Phi = {phi:.3f} (MIP)")
ax1.set_title("Effective-information landscape (3 glued bits)")
ax1.set_xlabel("cut A"); ax1.set_ylabel("ei(A) = I(A; A^c)"); ax1.legend()

# Right: Phi vs correlation for two coupled bits.
rhos = [i / 100 for i in range(101)]
phis = [mi_ei(2, two_bit_joint(r))(frozenset({0})) for r in rhos]
ax2.plot(rhos, phis, color="darkgreen", lw=2)
ax2.set_title("Phi grows with correlation (two coupled bits)")
ax2.set_xlabel("correlation rho"); ax2.set_ylabel("Phi")
ax2.fill_between(rhos, phis, alpha=0.15, color="darkgreen")

plt.tight_layout()
plt.savefig("phi_landscape.png", dpi=130)
print("Saved phi_landscape.png")
