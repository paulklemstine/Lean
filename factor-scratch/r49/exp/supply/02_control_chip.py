#!/usr/bin/env python3.12
"""THE MANDATORY CONTROL.

Before any box/scan comparison is trusted, this file must reproduce the SCAN's own
reported chi_P = -1 fraction of ~23% (CEIL3b.log: gen/(all rel) = 211/1021 = 0.207,
422/1753 = 0.241, 598/2761 = 0.217, 899/3566 = 0.252, 1142/4926 = 0.232 -- the file
quotes ~23%).

If my scan sampler returns ~79% I have reproduced the BOX bias and learned nothing.

Two populations, same N, same H, same l(m), same isqrt, same chiP:
  SCAN : m = 1..N (complete), c := m^3 mod N centred.     <- must give ~23% chi_P = -1
  BOX  : m in the V1 m-window, c in CPOOL, N = m^3 - c.    <- file says ~79%

Also reports the box with the SEMIPRIME FILTER ON (N = m^3 - c must actually be a
semiprime with p,q = 3 mod 4), because that is the population CHI_BOXSCAN.py used and
the one whose ~79% the file quotes.
"""
import random
import sys
import time

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49/exp/supply")
import S_common as S

H = 40
SEED = 20261003

# ---- instance classification, cached: N = m^3 - c must be a semiprime p*q, p,q = 3 mod 4
_FACC = {}


def _fac(N):
    """(p,q) with N = p*q, p,q prime = 3 mod 4, or None.  Cached."""
    if N in _FACC:
        return _FACC[N]
    out = None
    if N > 1 and N % 4 == 1:                      # necessary: p,q both 3 mod 4
        d = 3
        while d * d <= N and d < (1 << 17):
            if N % d == 0:
                e = N // d
                if (d % 4 == 3 and e % 4 == 3 and _prime(d) and _prime(e)):
                    out = (d, e)
                break
            d += 2
    _FACC[N] = out
    return out


def _prime(n):
    if n < 2:
        return False
    for d in range(2, int(n ** 0.5) + 1):
        if n % d == 0:
            return False
    return True


def _classify(N):
    return _fac(N) is not None

print("=" * 92)
print("CONTROL: does my SCAN sampler reproduce the scan's reported chi_P = -1 ~ 23%?")
print("=" * 92)
print("%5s %10s %10s %9s %9s %9s %8s %9s %9s"
      % ("bits", "N", "m-trials", "all rel", "chi-1", "chi+1", "null", "frac-1", "frac+1"))
print("-" * 92)

rows = []
for bits in (10, 12, 14, 16):
    N, p, q = S.make_semiprime(bits)
    mf = S.icbrt_floor(N) + 1                      # skip the vacuous m < N^(1/3)
    ms = list(range(mf, N + 1))
    cs = []
    for m in ms:
        v = (m * m * m) % N
        cs.append(v - N if v > N // 2 else v)
    cnt, rels = S.rels_batch(ms, cs, collect=True)
    tot = sum(cnt)
    chi1 = chi2 = nul = 0
    # the null family: L == 0, i.e. l constant in m
    for (m, c, u, v, w) in rels:
        L = 8 * u ** 3 * v + c * v ** 4
        if L == 0:
            nul += 1
            continue
        ch = S.chiP(w, p, q)
        if ch == -1:
            chi1 += 1
        elif ch == 1:
            chi2 += 1
    f1 = chi1 / tot if tot else float("nan")
    f2 = chi2 / tot if tot else float("nan")
    rows.append((bits, tot, chi1, chi2, nul))
    print("%5d %10d %10d %9d %9d %9d %8d %9.4f %9.4f"
          % (bits, N, len(ms), tot, chi1, chi2, nul, f1, f2), flush=True)

print()
alltot = sum(r[1] for r in rows)
allm1 = sum(r[2] for r in rows)
allp1 = sum(r[3] for r in rows)
pooled = allm1 / alltot
print("POOLED scan chi_P = -1 fraction: %d / %d = %.4f" % (allm1, alltot, pooled))
print("the file's scan value:                                          ~0.23")
dev = abs(pooled - 0.23) / (0.23 * (1 - 0.23) / alltot) ** 0.5
print("deviation from 0.23: %.2f sigma (binomial)" % dev)
ok = abs(pooled - 0.23) < 4 * (0.23 * 0.77 / alltot) ** 0.5
print("CONTROL %s" % ("PASSES" if ok else "FAILS -- my scan sampler is not the scan's population"))

# ---------------------------------------------------------------------------
print()
print("=" * 92)
print("BOX population at the SAME sizes: m in the V1 m-window, c in CPOOL, N = m^3 - c")
print("two variants: (a) no semiprime filter, (b) N = m^3-c must be a semiprime, p,q=3mod4")
print("=" * 92)
print("%5s | %-38s | %-38s" % ("bits", "BOX unfiltered", "BOX semiprime-filtered"))
print("%5s | %8s %8s %8s %8s | %8s %8s %8s %8s"
      % ("", "inst", "rel", "-1", "frac-1", "inst", "rel", "-1", "frac-1"))
rng = random.Random(SEED)
for bits in (10, 12, 14, 16, 18, 20, 22, 24, 26):
    lo, hi = 1 << (bits - 1), 1 << bits
    cmin, cmax = min(S.CPOOL), max(S.CPOOL)
    m0 = S.icbrt_floor(lo + cmin)
    m1 = S.icbrt_floor(hi + cmax)
    # cap the work: scan the whole window if it is small, else stride
    span = m1 - m0 + 1
    stride = 1 if span <= 40000 else (span // 40000) + 1
    ms, cs = [], []
    for m in range(m0, m1 + 1, stride):
        for c in S.CPOOL:
            ms.append(m)
            cs.append(c)
    cnt, rels = S.rels_batch(ms, cs, collect=True)
    rel = [(m, c, u, v, w) for (m, c, u, v, w) in rels]
    # variant (a): all instances
    nA = len(ms)
    rA = len(rel)
    # variant (b): keep only those whose N = m^3 - c is a semiprime with p,q = 3 mod 4
    keep = {}
    for idx, (m, c, u, v, w) in enumerate(rel):
        Nv = m * m * m - c
        key = (m, c)
        if key not in keep:
            keep[key] = _classify(Nv)
    nB = sum(1 for k, okv in keep.items() if okv)
    good = set(k for k, okv in keep.items() if okv)
    rB = sum(1 for (m, c, u, v, w) in rel if (m, c) in good)
    # chi_P needs p,q: recompute for the kept instances
    m1c = mB = 0
    for (m, c, u, v, w) in rel:
        if (m, c) not in good:
            continue
        Nv = m * m * m - c
        f = _fac(Nv)
        if f is None:
            continue
        pp, qq = f
        if S.chiP(w, pp, qq) == -1:
            m1c += 1
    fa = m1c / rB if rB else float("nan")
    # (a) needs p,q too -- use the same semiprime-filtered relation set but over all
    # relations of instances that happen to be semiprimes; report (a) as all relations
    m1a = 0
    for (m, c, u, v, w) in rel:
        Nv = m * m * m - c
        f = _fac(Nv)
        if f is None:
            continue
        pp, qq = f
        if S.chiP(w, pp, qq) == -1:
            m1a += 1
    fa = m1a / rA if rA else float("nan")
    print("%5d | %8d %8d %8d %8.3f | %8d %8d %8d %8.3f"
          % (bits, nA, rA, m1a, fa, nB, rB, m1c, fa), flush=True)

print()
print("NOTE: the file quotes box ~79% usable (chi_P = -1) and scan ~23%.")
print("      The box chi_P fraction here is computed only over relations whose instance")
print("      is a genuine semiprime, because chi_P is undefined otherwise.")
