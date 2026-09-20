"""Computational evidence for the factor-blindness / plug-in-bias results.

Reproduces every number quoted in ComputationalEvidence.md.  Pure standard library.

Run:  python3 scripts/factor_blindness_evidence.py
"""

import random
from math import log2
from collections import Counter
import itertools

random.seed(11)

MODULI = [3, 5, 7, 11]


def primes(n):
    s = [True] * (n + 1)
    s[0] = s[1] = False
    for i in range(2, int(n ** 0.5) + 1):
        if s[i]:
            for j in range(i * i, n + 1, i):
                s[j] = False
    return [i for i in range(n + 1) if s[i]]


def code(p, q, ms=MODULI):
    """The CRT-chained battery readout of the ordered pair (p, q)."""
    acc = 0
    for m in ms:
        acc = (acc * m + (p + q) % m) * m + (p * q) % m
    return acc


def mi(pairs):
    """Plug-in mutual information, in bits, of a list of (label, code) samples."""
    n = len(pairs)
    j = Counter(pairs)
    a = Counter(x for x, _ in pairs)
    b = Counter(y for _, y in pairs)
    return sum(c / n * log2((c / n) / ((a[x] / n) * (b[y] / n)))
               for (x, y), c in j.items())


def section(title):
    print("\n== " + title + " ==")


P = [p for p in primes(2000) if p > 50]

section("1. sampled prime pairs: observed reading vs 200-shuffle permutation null")
samp = [(random.choice(P), random.choice(P)) for _ in range(4000)]
samp = [(p, q) for p, q in samp if p != q]
lab = [1 if p > q else 0 for p, q in samp]
cod = [code(p, q) for p, q in samp]
obs = mi(list(zip(lab, cod)))
null = []
for _ in range(200):
    L = lab[:]
    random.shuffle(L)
    null.append(mi(list(zip(L, cod))))
mu = sum(null) / len(null)
sd = (sum((x - mu) ** 2 for x in null) / len(null)) ** 0.5
print("samples %d, distinct codes %d" % (len(samp), len(set(cod))))
print("observed %.4f  null mean %.4f  null sd %.4f  z %.2f"
      % (obs, mu, sd, (obs - mu) / sd))

section("2. exact population reading (all ordered pairs of 60 primes)")
pop = [(p, q) for p, q in itertools.permutations(P[:60], 2)]
lab2 = [1 if p > q else 0 for p, q in pop]
cod2 = [code(p, q) for p, q in pop]
print("ordered pairs %d, exact I(bigger; code) = %.12f" % (len(pop), mi(list(zip(lab2, cod2)))))
print("capacity ceiling log2((3*5*7*11)^2) = %.4f, log2(#codes realised) = %.4f"
      % (log2((3 * 5 * 7 * 11) ** 2), log2(len(set(cod2)))))

section("3. sparse plug-in bias under exact independence")
for n in [2, 4, 8, 16, 64, 256, 1024]:
    vals = [mi([(random.randint(0, 1), random.randint(0, 7)) for _ in range(n)])
            for _ in range(300)]
    print("n=%5d  mean plug-in reading = %.4f  (truth: 0)" % (n, sum(vals) / len(vals)))

section("4. divisor populations: non-squares read 0, squares do not")
for n in [15, 21 * 23, 36, 100]:
    ds = [d for d in range(1, n + 1) if n % d == 0]
    pairs = [(d, n // d) for d in ds]
    l = [1 if p > q else 0 for p, q in pairs]
    c = [code(p, q) for p, q in pairs]
    print("n=%4d  square=%-5s  ordered factorisations %2d  I(bigger; code) = %.12f"
          % (n, str(int(n ** 0.5) ** 2 == n), len(pairs), mi(list(zip(l, c)))))

section("5. sparse regime: reading equals label entropy exactly")
for labels in [[1, 1, 0, 0, 0, 1], [1, 1, 1, 1, 0, 0], [1, 0, 0, 0, 0, 0]]:
    n = len(labels)
    cnt = Counter(labels)
    H = -sum(v / n * log2(v / n) for v in cnt.values())
    print("labels %s -> plug-in %.6f, label entropy %.6f"
          % (labels, mi(list(zip(labels, range(n)))), H))

section("6. three factors: S3 orbit of (3,5,7), ordering label")
triples = list(itertools.permutations((3, 5, 7)))


def rank_pattern(v):
    """the ordering pattern of a tuple of distinct entries (an element of S3)"""
    order = sorted(range(3), key=lambda i: v[i])
    return tuple(order.index(i) for i in range(3))


sym_readout = lambda v: (sum(v) % 13, (v[0] * v[1] * v[2]) % 17)
cyc_readout = lambda v: (v[0] * v[1] ** 2 + v[1] * v[2] ** 2 + v[2] * v[0] ** 2) % 101
print("S3-invariant readout (sum mod 13, prod mod 17): I(ordering; code) = %.12f"
      % mi([(rank_pattern(v), sym_readout(v)) for v in triples]))
print("A3-invariant readout (cyclic cubic mod 101)   : I(ordering; code) = %.12f"
      % mi([(rank_pattern(v), cyc_readout(v)) for v in triples]))
print("predicted coset ceiling log2([S3:A3]) = %.12f" % log2(2))
