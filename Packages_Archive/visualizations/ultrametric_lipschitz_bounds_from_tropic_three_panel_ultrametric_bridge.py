"""Visualization: the p-adic ultrametric vs the archimedean line.
Generates three panels:
  (a) p-adic distance from 0 vs the archimedean |n| for n = 0..63 (p=2),
  (b) the isosceles property: histogram of (2nd largest - largest) side over
      random triangles (always 0 in an ultrametric),
  (c) nonexpansiveness of f(q)=2q+3 vs expansiveness of g(q)=q/2 (p=2).
Requires matplotlib. Run:  python visualization.py
"""
from fractions import Fraction
from itertools import product
import random
import matplotlib.pyplot as plt


def vp(n: int, p: int) -> int:
    n = abs(n); v = 0
    while n and n % p == 0:
        n //= p; v += 1
    return v


def pabs(q: Fraction, p: int) -> Fraction:
    q = Fraction(q)
    if q == 0:
        return Fraction(0)
    return Fraction(p) ** (-(vp(q.numerator, p) - vp(q.denominator, p)))


def dist(x, y, p):
    return float(pabs(Fraction(x) - Fraction(y), p))


p = 2
fig, ax = plt.subplots(1, 3, figsize=(16, 4.5))

# (a) p-adic size vs archimedean size
ns = list(range(1, 64))
ax[0].stem(ns, [float(pabs(Fraction(n), p)) for n in ns])
ax[0].set_title(f"p-adic size |n|_{p} (highly divisible -> tiny)")
ax[0].set_xlabel("n"); ax[0].set_ylabel(f"|n|_{p}")

# (b) isosceles property
pts = [Fraction(n) for n in range(0, 64)]
gaps = []
for _ in range(4000):
    x, y, z = random.sample(pts, 3)
    s = sorted([dist(x, y, p), dist(y, z, p), dist(x, z, p)])
    gaps.append(s[2] - s[1])
ax[1].hist(gaps, bins=20)
ax[1].set_title("Every triangle is isosceles\n(largest - 2nd largest side)")
ax[1].set_xlabel("difference of two largest sides")

# (c) nonexpansive vs expansive
samples = [Fraction(a, b) for a in range(-8, 9) for b in (1, 2, 4)]
f = lambda q: 2 * q + 3
g = lambda q: q / 2
din, dfo, dgo = [], [], []
for x, y in product(samples, samples):
    d = dist(x, y, p)
    if d == 0:
        continue
    din.append(d); dfo.append(dist(f(x), f(y), p)); dgo.append(dist(g(x), g(y), p))
ax[2].scatter(din, dfo, s=8, label="f(q)=2q+3 (nonexpansive)")
ax[2].scatter(din, dgo, s=8, label="g(q)=q/2 (expansive)")
lim = max(din + dfo + dgo)
ax[2].plot([0, lim], [0, lim], "k--", label="y = x")
ax[2].set_xlabel("input distance"); ax[2].set_ylabel("output distance")
ax[2].set_title("Bridge theorem in action"); ax[2].legend()

plt.tight_layout()
plt.savefig("ultrametric_bridge.png", dpi=140)
print("wrote ultrametric_bridge.png")
