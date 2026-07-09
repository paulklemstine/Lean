"""Visualization: cyclotomic degrees phi(n) and imaginary-quadratic class numbers.
Requires matplotlib. Produces two panels saved to reciprocity_visualization.png."""
from math import gcd, isqrt
import matplotlib.pyplot as plt

def euler_totient(n):
    r, m, p = n, n, 2
    while p * p <= m:
        if m % p == 0:
            while m % p == 0:
                m //= p
            r -= r // p
        p += 1
    if m > 1:
        r -= r // m
    return r

def class_number(d):
    disc = -d if (-d) % 4 == 1 else -4 * d
    count, a = 0, 1
    while a * a <= -disc // 3 + 1:
        for b in range(-a, a + 1):
            num = b * b - disc
            if num % (4 * a):
                continue
            c = num // (4 * a)
            if c < a:
                continue
            if abs(b) <= a <= c:
                if (abs(b) == a or a == c) and b < 0:
                    continue
                count += 1
        a += 1
    return count

ns = list(range(1, 61))
phis = [euler_totient(n) for n in ns]
ds = [d for d in range(1, 60) if all(d % (p*p) for p in range(2, isqrt(d)+1))]
hs = [class_number(d) for d in ds]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 5))
ax1.stem(ns, phis, basefmt=" ")
ax1.set_title(r"Cyclotomic degree $[\mathbb{Q}(\zeta_n):\mathbb{Q}]=\varphi(n)$")
ax1.set_xlabel("n"); ax1.set_ylabel(r"$\varphi(n)$")
ax2.bar(range(len(ds)), hs)
ax2.set_xticks(range(len(ds))); ax2.set_xticklabels(ds, rotation=90, fontsize=6)
ax2.set_title(r"Class number $h_K=[H:K]$ for $K=\mathbb{Q}(\sqrt{-d})$")
ax2.set_xlabel("d (squarefree)"); ax2.set_ylabel(r"$h_K$")
plt.tight_layout()
plt.savefig("reciprocity_visualization.png", dpi=150)
print("saved reciprocity_visualization.png")
