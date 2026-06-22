"""Visualize the cumulative weight CDF and the strict supermultiplicative gap."""
from __future__ import annotations
from itertools import product
import matplotlib.pyplot as plt

HAMMING_GEN = [
    (1,1,1,1,1,1,1,1),(0,0,0,0,1,1,1,1),(0,0,1,1,0,0,1,1),(0,1,0,1,0,1,0,1),
]

def build(gen, k):
    out = []
    for c in product((0,1), repeat=k):
        out.append(tuple(sum(c[i]*gen[i][j] for i in range(k)) % 2 for j in range(8)))
    return out

def wt(v): return sum(v)
def dsum(C, D): return [a+b for a in C for b in D]
def wcount(C, t): return sum(1 for c in C if wt(c) <= t)

H = build(HAMMING_GEN, 4)
HH = dsum(H, H)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

# Left: CDF staircases.
ts = list(range(0, 9))
ax1.step(ts, [wcount(H, t) for t in ts], where="post", label="wcount(H, t)", lw=2)
tts = list(range(0, 17))
ax1.step(tts, [wcount(HH, t) for t in tts], where="post",
         label="wcount(H (+) H, t)", lw=2)
ax1.set_xlabel("threshold t"); ax1.set_ylabel("cumulative count")
ax1.set_title("Cumulative weight CDF (every stratum is a jump)")
ax1.legend(); ax1.grid(alpha=0.3)

# Right: rectangle vs simplex bound across thresholds.
xs = list(range(0, 9))
lower = [wcount(H, t)**2 for t in xs]
actual = [wcount(HH, 2*t) for t in xs]
ax2.plot(xs, lower, "o-", label="wcount(H, t)^2  (rectangle)")
ax2.plot(xs, actual, "s-", label="wcount(H (+) H, 2t)  (simplex)")
ax2.fill_between(xs, lower, actual, alpha=0.2, label="strict gap (cross-strata)")
ax2.annotate("225 < 227", xy=(4, 226), xytext=(2, 240),
             arrowprops=dict(arrowstyle="->"))
ax2.set_xlabel("threshold t (with s = r = t)")
ax2.set_ylabel("count")
ax2.set_title("Supermultiplicative bound and its strict gap")
ax2.legend(); ax2.grid(alpha=0.3)

plt.tight_layout()
plt.savefig("wcount_convolution.png", dpi=150)
print("saved wcount_convolution.png")
