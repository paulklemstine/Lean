"""Visualization: empirical vertex-expansion constant of SL_2(F_p)
Cayley graphs as p grows, illustrating Conjecture 6.3 (uniform expansion)."""
from typing import FrozenSet, List, Tuple
import itertools, random
from math import comb
import matplotlib.pyplot as plt

Mat = Tuple[int, int, int, int]


def mat_mul(x: Mat, y: Mat, p: int) -> Mat:
    a, b, c, d = x; e, f, g, h = y
    return ((a*e+b*g) % p, (a*f+b*h) % p, (c*e+d*g) % p, (c*f+d*h) % p)


def mat_inv(x: Mat, p: int) -> Mat:
    a, b, c, d = x
    Di = pow((a*d - b*c) % p, -1, p)
    return ((d*Di) % p, (-b*Di) % p, (-c*Di) % p, (a*Di) % p)


def generate(gens: List[Mat], p: int) -> FrozenSet[Mat]:
    seen = {(1, 0, 0, 1)}; frontier = list(seen)
    while frontier:
        nxt = []
        for g in frontier:
            for s in gens:
                h = mat_mul(g, s, p)
                if h not in seen:
                    seen.add(h); nxt.append(h)
        frontier = nxt
    return frozenset(seen)


def eps(group: FrozenSet[Mat], S: List[Mat], p: int) -> float:
    elems = list(group); n = len(elems); best = 1e9
    for k in range(1, n // 2 + 1):
        combos = (itertools.combinations(elems, k) if comb(n, k) <= 3000
                  else (tuple(random.sample(elems, k)) for _ in range(1500)))
        for combo in combos:
            A = frozenset(combo)
            N = frozenset(mat_mul(a, s, p) for a in A for s in S)
            best = min(best, len(N - A) / len(A))
    return best


primes = [3, 5, 7, 11]
xs, ys, sizes = [], [], []
for p in primes:
    s = (1, 1, 0, 1); t = (1, 0, 1, 1)
    S = [s, mat_inv(s, p), t, mat_inv(t, p)]
    G = generate(S, p)
    xs.append(p); ys.append(eps(G, S, p)); sizes.append(len(G))

fig, ax = plt.subplots(figsize=(7, 4.5))
ax.plot(xs, ys, "o-", lw=2, color="#2b6cb0")
for x, y, sz in zip(xs, ys, sizes):
    ax.annotate(f"|G|={sz}", (x, y), textcoords="offset points", xytext=(0, 8))
ax.set_xlabel("prime p"); ax.set_ylabel("empirical vertex expansion eps")
ax.set_title("Uniform expansion of SL_2(F_p) Cayley graphs")
ax.grid(alpha=0.3); plt.tight_layout(); plt.savefig("expansion_uniformity.png", dpi=150)
print("saved expansion_uniformity.png")
