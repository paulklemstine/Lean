"""Visualization: the order-three slowness surplus across prime powers.

Renders (1) the order-three truncation surplus E3_plane - E3_uniform versus q,
showing strict positivity and rapid growth, and (2) the two-point Jensen gap that
drives it: the harmonic weight f(p)=1/(1-p) evaluated at the collinear and generic
triple probabilities versus its value at their shared mean.
"""
from math import comb
from fractions import Fraction
import matplotlib.pyplot as plt


def order3_surplus(q: int) -> float:
    n = q * q + q + 1
    u1 = Fraction(q * q, n)
    u2 = Fraction(q * q * (q * q - 1), n * (n - 1))
    u3 = Fraction(q * q * (q * q - 1) * (q * q - 2), n * (n - 1) * (n - 2))
    p_point, p_pair = Fraction(q * q, n), Fraction(q * q - q, n)
    p_coll, p_gen = Fraction(q * q - 2 * q, n), Fraction((q - 1) ** 2, n)
    n_coll = n * comb(q + 1, 3)
    n_gen = comb(n, 3) - n_coll
    u = comb(n, 1) / (1 - u1) - comb(n, 2) / (1 - u2) + comb(n, 3) / (1 - u3)
    p = (comb(n, 1) / (1 - p_point) - comb(n, 2) / (1 - p_pair)
         + n_coll / (1 - p_coll) + n_gen / (1 - p_gen))
    return float(p - u)


qs = [2, 3, 4, 5, 7, 8, 9, 11, 13, 16, 25]
surplus = [order3_surplus(q) for q in qs]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))

ax1.semilogy(qs, surplus, "o-", color="#c0392b")
ax1.set_xlabel("order q of the projective plane")
ax1.set_ylabel("order-three surplus  E3_plane - E3_uniform  (log scale)")
ax1.set_title("Structured plane is strictly slower (and increasingly so)")
ax1.grid(True, which="both", alpha=0.3)

# Jensen gap illustration for q = 5
q = 5
n = q * q + q + 1
pc, pg = q * q - 2 * q, (q - 1) ** 2
xc, xg = pc / n, pg / n
f = lambda x: 1 / (1 - x)
xs = [i / 1000 for i in range(0, int(0.999 * 1000))]
ax2.plot(xs, [f(x) for x in xs], color="#2c3e50", label="f(p)=1/(1-p)")
mean = (xc + xg) / 2
ax2.plot([xc, xg], [f(xc), f(xg)], "o--", color="#c0392b",
         label="chord between collinear & generic")
ax2.plot(mean, (f(xc) + f(xg)) / 2, "s", color="#c0392b",
         label="chord midpoint (plane average)")
ax2.plot(mean, f(mean), "D", color="#27ae60", label="f at the shared mean (uniform)")
ax2.set_xlim(min(xc, xg) - 0.02, max(xc, xg) + 0.02)
ax2.set_xlabel("avoid-probability p")
ax2.set_ylabel("harmonic weight 1/(1-p)")
ax2.set_title("Strict convexity gap at order three (q = 5)")
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig("slowness_surplus.png", dpi=150)
print("saved slowness_surplus.png")
