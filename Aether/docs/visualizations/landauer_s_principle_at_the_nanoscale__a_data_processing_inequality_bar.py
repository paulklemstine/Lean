"""Visualize the deterministic data-processing inequality H(f_* p) <= H(p).

Bar chart comparing the entropy of an initial 4-state distribution with the
entropy of its pushforward under (a) a reversible permutation and (b) an
erasure-like collapse to a single state.
"""
import math
import matplotlib.pyplot as plt


def H(p):
    return sum((-x * math.log(x)) for x in p if x > 0.0)


def push(states, p, f):
    w = {}
    for s, ps in zip(states, p):
        w[f(s)] = w.get(f(s), 0.0) + ps
    return list(w.values())


states = [0, 1, 2, 3]
p = [0.4, 0.3, 0.2, 0.1]
labels = ["H(p)", "H(permute)", "H(collapse)"]
vals = [H(p), H(push(states, p, lambda x: (x + 1) % 4)), H(push(states, p, lambda x: 0))]

plt.figure(figsize=(7, 5))
plt.bar(labels, vals, color=["steelblue", "seagreen", "indianred"])
plt.title("Data-processing inequality: deterministic maps never raise entropy")
plt.ylabel("Shannon entropy (nats)")
plt.grid(axis="y", alpha=0.3)
plt.tight_layout()
plt.savefig("landauer_dpi.png", dpi=150)
print("wrote landauer_dpi.png")
