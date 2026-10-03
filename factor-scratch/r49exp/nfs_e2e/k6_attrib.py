"""
Step-3 attribution: which prime carries the excess, at which exponent, and is the k >= 6
part of the gain the ZERO-ZERO subspace (a = 0 mod p^ceil(k/2), b = 0 mod p^ceil(k/3)) that
paper #523 section 4 identified, rather than the 2-1/p ramification effect?

Run after selftest.py passes.  Writes out/k_attrib.txt.
"""

from __future__ import annotations

import numpy as np

import core

A_EXP, BB_EXP = 18, 12
X = core.value_scale(A_EXP)
B = 512
N = 6_000_000
PS = (2, 3, 5, 7, 11, 13)
EMAX = 9

lines = []


def P(s=""):
    print(s)
    lines.append(s)


def val_dist(x, p, emax=EMAX):
    """P(v_p(x) = e) for e = 0..emax, and P(v_p > emax), by exact repeated division.

    The division runs to exhaustion (an |x| <= 2^36 value can have v_2 up to 36); only
    the recorded exponents are capped, so nothing is silently dropped."""
    n = x.shape[0]
    y = x.copy()
    e = np.zeros(n, dtype=np.int16)
    guard = 0
    while True:
        q = y // p
        m = (q * p) == y
        if not m.any():
            break
        y[m] = q[m]
        e[m] += 1
        guard += 1
        if guard > 64:
            raise AssertionError("valuation runaway -- input not a positive int64")
    dist = [int((e == kk).sum()) / n for kk in range(emax + 1)]
    return dist, float((e > emax).sum()) / n


def main():
    rng = np.random.default_rng(778_899)
    a, b, v = core.sample_box(rng, A_EXP, BB_EXP, N)
    m = core.shell_mask(v, A_EXP)
    a, b, v = a[m], b[m], v[m]
    xt = np.abs(v)
    xn = core.nullize(v, rng)
    n = xt.shape[0]

    P("=" * 78)
    P("STEP 3 ATTRIBUTION -- P(v_p(x) = e) in each arm, against the model prediction")
    P("=" * 78)
    P(f"shell n = {n:,}   factor bound B = {B}   (p^e <= B marks what the FB can see)")
    P()
    P("Model, from P(p^k | a^2-b^3) = alpha_p / p^k with alpha_p = 2 - 1/p for k >= 2 and")
    P("= 1/p at k = 1 (p = 2 measured separately):")
    P("    P(e=0) = 1 - alpha/p^2")
    P("    P(e=1) = 1/p - alpha/p^2")
    P("    P(e>=2) = alpha(1-1/p)/p^e")
    P("  so the density RATIO true/uniform is 1 at e=0,  (p-alpha)/(p-1)  at e=1,  and")
    P("  exactly alpha = 2-1/p at EVERY e >= 2.  A ratio that is flat in e >= 2 is the")
    P("  signature of the paper's law; any deviation is the zero-zero subspace or a")
    P("  small-prime structure effect.")
    P()
    for p in PS:
        alpha = 2 - 1 / p
        dt, taill = val_dist(xt, p)
        dn, tailn = val_dist(xn, p)
        pred = [1 - alpha / p ** 2, 1 / p - alpha / p ** 2] + \
               [alpha * (1 - 1 / p) / p ** e for e in range(2, EMAX + 1)]
        P(f"  p = {p}   (alpha = 2-1/p = {alpha:.4f};  p^{EMAX+1} = "
          f"{p**(EMAX+1)}{'  > B: FB cannot see this e' if p**(EMAX+1) > B else ''})")
        P(f"    {'e':>3} {'P_true':>11} {'P_null':>11} {'model':>11} {'true/null':>10} "
          f"{'true/model':>11}")
        for e in range(0, EMAX + 1):
            P(f"    {e:>3} {dt[e]:>11.6f} {dn[e]:>11.6f} {pred[e]:>11.6f} "
              f"{(dt[e]/dn[e] if dn[e] else float('nan')):>10.4f} "
              f"{(dt[e]/pred[e] if pred[e] else float('nan')):>11.4f}")
        P(f"    >  {EMAX} {taill:>10.6f} {tailn:>11.6f}")
        P()

    # ---- the paper's own statistic, measured in each arm ---------------
    P("=" * 78)
    P("THE PAPER'S OWN STATISTIC:  R(p,k) = P(p^k | x) / (1/p^k), measured in each arm")
    P("=" * 78)
    P("This is exactly the table in paper #523 section 2, re-measured at the box rather")
    P("than mod p^k.  It needs no differencing, so it is immune to the compounding above.")
    P("Paper: R = 1 at k=1, 2-1/p for 2<=k<=5, and 2-1/p+(p-1) at k=6.")
    P()
    P(f"  {'p':>4} " + " ".join(f"{'k='+str(k):>9}" for k in range(1, 9)) +
          "   |  " + " ".join(f"{'N_k true':>9}" for k in range(1, 9)))
    KMAXR = 8
    for p in PS:
        rt, rn, cnt = [], [], []
        for k in range(1, KMAXR + 1):
            pk = p ** k
            ot = int((xt % pk == 0).sum())
            on = int((xn % pk == 0).sum())
            rt.append(ot / n * pk)
            rn.append(on / n * pk)
            cnt.append(ot)
        alpha = 2 - 1 / p
        P(f"  {p:>4} " + " ".join(f"{x:>9.4f}" for x in rt) + "   |  " +
          " ".join(f"{c:>9d}" for c in cnt))
        P(f"       " + " ".join(f"{x:>9.4f}" for x in rn) + "   (NULL arm)")
        P(f"       paper predicts k=1: 1.0000;  k=2..5: {alpha:.4f};  k=6: "
          f"{alpha + p - 1:.4f};  k=7,8: not stated")
        P()
    P("=" * 78)
    P("IS THE k>=6 GAIN THE ZERO-ZERO SUBSPACE?")
    P("=" * 78)
    P("For a relation whose largest factor-base exponent is k, the paper's section 4 says the")
    P("k >= 6 excess over 2-1/p comes from a = 0 (mod p^ceil(k/2)) and b = 0 (mod p^ceil(k/3)).")
    P("We take the relations with max exponent >= 6, find WHICH prime attains it, and test")
    P("the zero-zero configuration directly on the (a,b) that produced them.")
    P()
    primes = core.primes_upto(B)
    st = core.strip_multi(xt, primes, [B])[B]
    cof, mx = st[0], st[1]
    smooth = cof == 1
    big = np.nonzero(smooth & (mx >= 6))[0]
    P(f"  relations with max FB exponent >= 6:  {big.shape[0]:,} of {int(smooth.sum()):,}")
    zz = {"p^3|a and p^2|b": 0, "other": 0, "p=2": 0, "p=3": 0, "p=5": 0, "p=7+": 0}
    attrib = {}
    for idx in big:
        y = int(cof[idx])  # = 1
        # find which prime attains the max exponent, by re-dividing
        val = xt[idx]
        best_p, best_e = None, 0
        for p in primes:
            e = 0
            while val % p == 0:
                val //= p
                e += 1
            if e > best_e:
                best_e, best_p = e, p
        attrib[best_p] = attrib.get(best_p, 0) + 1
        if best_p == 2:
            zz["p=2"] += 1
        elif best_p == 3:
            zz["p=3"] += 1
        elif best_p == 5:
            zz["p=5"] += 1
        else:
            zz["p=7+"] += 1
        pk = best_p
        a0, b0 = int(a[idx]), int(b[idx])
        need_a = 3 if best_e == 6 else 4
        need_b = 2 if best_e == 6 else 3
        if a0 % (pk ** need_a) == 0 and b0 % (pk ** need_b) == 0:
            zz["p^3|a and p^2|b"] += 1
        else:
            zz["other"] += 1
    P(f"    attributed prime: " + ", ".join(f"p={k}:{c:,}" for k, c in sorted(attrib.items())))
    P(f"    zero-zero configuration holds for {zz['p^3|a and p^2|b']:,} of "
      f"{big.shape[0]:,} ({100*zz['p^3|a and p^2|b']/max(big.shape[0],1):.1f}%)")
    P()
    P("  For reference, under a UNIFORM model a = 0 mod p^3 has probability p^-3 and")
    for p in (2, 3, 5):
        P(f"    p={p}: P(p^3 | a and p^2 | b) = {1/p**5:.3e}  -> expected hits "
          f"{1/p**5*big.shape[0]:.2f}")
    P()

    import os
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "k_attrib.txt"), "w") as fh:
        fh.write("\n".join(lines) + "\n")
    print(f"\nwritten: {out}/k_attrib.txt")


if __name__ == "__main__":
    main()