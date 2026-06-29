import matplotlib.pyplot as plt
from itertools import product
from math import comb

def hamming(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)

def ball_volume(n, q, t):
    t = min(t, n)
    return sum(comb(n, i) * (q - 1) ** i for i in range(t + 1))

def greedy(n, q, d):
    code = []
    for w in product(range(q), repeat=n):
        if all(hamming(w, c) >= d for c in code):
            code.append(w)
    return code

cases = [(4, 2, 1), (6, 2, 1), (5, 3, 1)]
labels, lefts, mids, rights = [], [], [], []
for (n, q, t) in cases:
    m = len(greedy(n, q, 2 * t + 1))
    labels.append(f"n={n},q={q},t={t}")
    lefts.append(m * ball_volume(n, q, t))
    mids.append(q ** n)
    rights.append(m * ball_volume(n, q, 2 * t))

import numpy as np
x = np.arange(len(cases))
w = 0.27
plt.figure(figsize=(9, 5))
plt.bar(x - w, lefts, w, label="|C|*V(t)  (lower)")
plt.bar(x, mids, w, label="q^n  (truth)")
plt.bar(x + w, rights, w, label="|C|*V(2t)  (upper)")
plt.xticks(x, labels)
plt.ylabel("count")
plt.title("Code-size sandwich:  |C|*V(t) <= q^n <= |C|*V(2t)")
plt.legend()
plt.tight_layout()
plt.savefig("sandwich_bars.png", dpi=150)
print("saved sandwich_bars.png")
