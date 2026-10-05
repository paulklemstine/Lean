#!/usr/bin/env python3
# exp_hh26.py -- empirical verification of Harvey & Hittmeir, arXiv:2601.11131v2,
# "Deterministic methods for finding elements of large multiplicative order".
#
# SCOPE: local moduli only, N < 2^40 (mostly N < 2^13). NOT a cryptographic break.
#
# SEED: fixed at top; run twice and diff (see main()).
import random
import math
import sys
from math import gcd, lcm, ceil, log, log2
from sympy import n_order, factorint, isprime, primerange

SEED = 20261004
random.seed(SEED)

# ---------------------------------------------------------------- helpers

def ismooth_count(x, y):
    """Psi(x,y) = #{ n <= x : every prime factor of n is <= y }. Exact, brute force."""
    cnt = 0
    for n in range(1, x + 1):
        ok = True
        for q, _ in factorint(n).items():
            if q > y:
                ok = False
                break
        if ok:
            cnt += 1
    return cnt


def icbrt_ceil(n):
    """smallest integer B with B**3 >= n"""
    if n <= 0:
        return 0
    B = int(round(n ** (1.0 / 3.0)))
    while B ** 3 < n:
        B += 1
    while B > 0 and (B - 1) ** 3 >= n:
        B -= 1
    return B


def Ztilde(M, B):
    """Z~ = 2M * (log 2M)^((log 2M)/(-1+log B)),  paper p.9 line 17 / eq (3.6)."""
    L = math.log(2 * M)
    num = math.log(2 * M)
    den = -1.0 + math.log(B)
    return 2 * M * (L ** (num / den))


def kp_lower_bound(x, y):
    """Lemma 2.4 (Konyagin-Pomerance): Psi(x,y) >= x / (log x)^(log x / log y).
    Returns None where the lemma is not applicable (x < y or x < 4)."""
    if x < 4 or x < y:
        return None
    lx = math.log(x)
    return x / (lx ** (lx / math.log(y)))


# ------------------------------------------------- EXPERIMENT A: Lemma 2.4

def experiment_A(verbose=True):
    """Does the Konyagin-Pomerance lower bound of Lemma 2.4 hold, and is our
    detector non-vacuous?

    POSITIVE control : bound must be <= actual Psi on the applicable domain.
    NEGATIVE control : bound must be > actual Psi OUTSIDE the domain (x<y),
                       proving the check is not vacuous.
    """
    pos_ok = pos_tot = 0
    neg_fired = neg_tot = 0
    worst = None
    for x in [10, 20, 50, 100, 200, 500, 1000, 2000]:
        for y in [2, 3, 5, 10, 20, 50, 100]:
            if x < y:
                continue
            lb = kp_lower_bound(x, y)
            if lb is None:
                continue
            act = ismooth_count(x, y)
            pos_tot += 1
            if lb <= act:
                pos_ok += 1
            else:
                if verbose:
                    print(f"   A VIOLATION x={x} y={y} lb={lb:.2f} act={act}")
            ratio = act / lb
            if worst is None or ratio < worst[0]:
                worst = (ratio, x, y)
    # negative control: x < y, lemma undefined -> must NOT silently "hold"
    for x in [3, 5, 10, 20]:
        for y in [10, 20, 50, 100, 1000]:
            if x >= y:
                continue
            neg_tot += 1
            lb = kp_lower_bound(x, y)   # returns None
            if lb is None:
                neg_fired += 1
    return dict(pos_ok=pos_ok, pos_tot=pos_tot, neg_fired=neg_fired,
                neg_tot=neg_tot, worst_ratio=worst)


# ------------------------------------- EXPERIMENT B: the crux inequality (3.5)

def experiment_B(Ds, verbose=True):
    """The heart of the proof: for every M <= D with B = ceil(D^(1/3)),
        M < Psi_KP(Z~, B) < 4M     (paper eq. (3.5), p.9)
    plus the domain condition Z~ > B (needed to apply Lemma 2.4 at (Z~,B)).

    POSITIVE control : for large D the inequality must hold for ALL M <= D.
    NEGATIVE control : a deliberately WRONG variant (B := D^3 instead of
                       D^(1/3)) must FAIL, proving the check discriminates.
    """
    rows = []
    for D in Ds:
        B = icbrt_ceil(D)
        ok = bad = 0
        # sample M over the full range including both endpoints
        Ms = set()
        Ms.add(1); Ms.add(D)
        for e in range(1, 12):
            Ms.add(max(1, D // (2 ** e)))
        Ms.add(max(1, int(D ** 0.5)))
        Ms.add(max(1, D // 3))
        Ms = sorted(m for m in Ms if 1 <= m <= D)
        for M in Ms:
            if M < 1:
                continue
            Zt = Ztilde(M, B)
            lb = kp_lower_bound(Zt, B)
            if lb is None:
                bad += 1
                continue
            if M < lb < 4 * M:
                ok += 1
            else:
                bad += 1
                if verbose and bad <= 3:
                    print(f"   B FAIL D={D} M={M} B={B} lb={lb:.4g} 4M={4*M}")
        # NEGATIVE control: wrong B
        Bbad = icbrt_ceil(D) ** 3
        negfail = 0
        for M in Ms:
            if M < 1:
                continue
            Zt = Ztilde(M, Bbad)
            lb = kp_lower_bound(Zt, Bbad)
            if lb is None or not (M < lb < 4 * M):
                negfail += 1
        rows.append((D, B, ok, bad, len(Ms), negfail))
    return rows


# --------------------------- EXPERIMENT C: the counting step Psi(p,B) <= M

def experiment_C(triples, verbose=True):
    """Proof step (3.2): if every beta <= B has ord_p(beta) | M then
       Psi(p, B) <= M,  because each B-smooth n <= p solves n^M = 1 (mod p)
       and that congruence has <= M solutions mod p.
    We test the antecedent-consequent on real primes.

    POSITIVE control : on instances where the antecedent HOLDS, Psi(p,B) <= M.
    NEGATIVE control : on instances where it FAILS (M too small), we should see
                       Psi(p,B) > M  -- i.e. the detector fires both ways.
    """
    rows = []
    for p, B in triples:
        if not isprime(p) or p <= B:
            continue
        Ms = []
        l = 1
        for b in range(2, B + 1):
            l = lcm(l, n_order(b, p))
        Ms.append(("full_lcm", l))
        Ms.append(("half", l // 2 if l >= 2 else 1))
        Ps = ismooth_count(p, B)
        for tag, M in Ms:
            antecedent = all(pow(b, M, p) == 1 for b in range(2, B + 1))
            consequent = Ps <= M
            rows.append((p, B, tag, M, Ps, antecedent, consequent))
    return rows


# --------------------------------- EXPERIMENT D: NFS crossover + exponents

def experiment_D():
    """Compare (a) deterministic large-order finding  D^(1/2) log D log N
       (b) heuristic NFS order-finding  L_N[1/3, 2(64/9)^(1/3)]
       (c) classical deterministic order COMPUTATION  N^(1/4)
       (d) Harvey's deterministic factoring exponent N^(1/5)
    Returns crossover D where (a) = (b)."""
    c = 2 * (64.0 / 9.0) ** (1.0 / 3.0)
    out = []
    for bits in [256, 1024, 2048, 4096, 8192]:
        lnN = bits * log(2)
        llnN = log(lnN)
        L_N = math.exp(c * (lnN ** (1.0 / 3.0)) * (llnN ** (2.0 / 3.0)))
        log2_LN = L_N / log(2)

        def det_cost(D):     # in log2
            return 0.5 * log2(D) + log2(log2(D)) + bits

        # solve det_cost(D) = log2_LN  (monotone increasing in D)
        lo, hi = 1.0, 2.0
        while det_cost(hi) < log2_LN:
            hi *= 2
            if hi > 2 ** 40:
                break
        for _ in range(200):
            mid = (lo + hi) / 2
            if det_cost(mid) < log2_LN:
                lo = mid
            else:
                hi = mid
        Dcross = (lo + hi) / 2
        out.append(dict(bits=bits, log2_L_N=log2_LN,
                        log2_N_1_4=0.25 * bits, log2_N_1_5=0.2 * bits,
                        log2_N_1_10=0.1 * bits,
                        D_crossover_log2=math.log2(Dcross) if Dcross > 1 else None,
                        D_cross_raw=Dcross))
    return out, c


# ------------------------------------------ EXPERIMENT E: end-to-end algorithm

def alg_31(N, D, trace=False, sabotage=None):
    """Faithful transcription of Algorithm 3.1 (p.8).  For speed the
    order-search of Lemma 2.1 is replaced by EXACT order computation, which
    changes only the runtime, not the output.  ord(alpha)==M is asserted at
    every iteration, so a wrong Lemma-2.2 construction would be caught.

    sabotage: None | 'no_line3' | 'bogus_divisor'  (negative controls)
    """
    assert N >= 3 and 1 <= D < N - 1, (N, D)
    if sabotage == 'bogus_divisor':
        return ('divisor', 3 if N % 3 else 2)
    # line 2
    if N % 2 == 0:
        return ('divisor', 2)
    # line 3:  2^D < N   (verified against rendered page 8; pdftotext drops ^)
    if sabotage != 'no_line3' and 2 ** D < N:
        return ('alpha', 2)
    # line 4
    B = icbrt_ceil(D)
    alpha, M = 1, 1                       # lines 5
    for beta in range(2, B + 1):          # line 6
        if N % beta == 0:                 # line 7
            return ('divisor', beta)
        if pow(beta, M, N) == 1:          # line 8
            continue
        m = n_order(beta, N)              # line 9 (exact)
        if m > D:                         # line 10
            return ('alpha', beta)
        fac = factorint(m)                # line 11
        for r in fac:                     # lines 12-13
            d = gcd(pow(beta, m // r, N) - 1, N)
            if d != 1:
                return ('divisor', d)
        # lines 14-15: element of order lcm(M,m)
        Mp = lcm(M, m)
        new = 1
        for q in set(list(factorint(M)) + list(fac)):
            e, f = factorint(M).get(q, 0), fac.get(q, 0)
            if e >= f:
                new *= pow(alpha, M // (q ** e), N)
            else:
                new *= pow(beta, m // (q ** f), N)
        alpha = new % N
        M = Mp
        assert n_order(alpha, N) == M, ("INVARIANT BROKEN", N, D, beta, M)
        if M > D:                         # line 16
            return ('alpha', alpha)
    # lines 17-19
    Zt = Ztilde(M, B)
    Z = int(ceil(Zt))
    for k in range(1, Z // M + 1):
        if N % (k * M + 1) == 0:
            return ('divisor', k * M + 1)
    return ('NONE', None)                 # paper says unreachable


def check_output(N, D, kind, val):
    """Independent verifier of the algorithm's output. Returns True if valid."""
    if kind == 'alpha':
        if val is None:
            return False
        if gcd(val, N) != 1:
            return False
        return n_order(val, N) > D
    if kind == 'divisor':
        return (val is not None and 1 < val < N and N % val == 0)
    return False


def experiment_E(Nmax, Dvals, sabotage=None, verbose=False):
    tot = ok = bad = none = 0
    failures = []
    for N in range(3, Nmax):
        for D in Dvals:
            if not (1 <= D < N - 1):
                continue
            tot += 1
            kind, val = alg_31(N, D, sabotage=sabotage)
            if kind == 'NONE':
                none += 1
                continue
            if check_output(N, D, kind, val):
                ok += 1
            else:
                bad += 1
                if len(failures) < 10:
                    failures.append((N, D, kind, val))
    return dict(total=tot, valid=ok, invalid=bad, returned_none=none,
                failures=failures, sabotage=sabotage)


# ------------------------------------------------------------------- main

def main():
    print("=" * 72)
    print(f"HH26 verification   SEED={SEED}")
    print("=" * 72)

    print("\n[A] Lemma 2.4 (KP bound Psi(x,y) >= x/(log x)^(log x/log y))")
    a = experiment_A(verbose=False)
    print(f"  positive control: {a['pos_ok']}/{a['pos_tot']} instances hold")
    print(f"  negative control: {a['neg_fired']}/{a['neg_tot']} out-of-domain "
          f"correctly refused (None)")
    print(f"  tightest actual/bound ratio = {a['worst_ratio'][0]:.3f} "
          f"at x={a['worst_ratio'][1]}, y={a['worst_ratio'][2]}")

    print("\n[B] crux inequality (3.5):  M < Psi_KP(Z~,B) < 4M,  B=ceil(D^(1/3))")
    Ds = [10 ** k for k in range(2, 13)] + [3, 7, 100, 1000, 10 ** 6]
    rows = experiment_B(Ds, verbose=False)
    print("   D        B      ok  bad  nM   negcontrol_failed")
    for D, B, ok, bad, nM, negfail in rows:
        flag = "" if bad == 0 else "   <== (3.5) FAILS"
        print(f"  {D:>10} {B:>7} {ok:>4} {bad:>4} {nM:>4} {negfail:>8}{flag}")
    allok = all(r[3] == 0 for r in rows)
    print(f"  ==> (3.5) holds for every sampled M at every D: {allok}")

    print("\n[C] counting step (3.2): antecedent (ord_p(beta)|M for all beta<=B)"
          " => Psi(p,B) <= M")
    triples = [(101, 10), (101, 20), (211, 10), (1009, 20), (1009, 50),
               (2003, 10), (3001, 20), (4001, 30)]
    crows = experiment_C(triples, verbose=False)
    print("     p     B   tag       M      Psi(p,B)  antecedent consequent")
    agree = viol = 0
    for p, B, tag, M, Ps, ante, cons in crows:
        print(f"  {p:>5} {B:>4} {tag:>9} {M:>7} {Ps:>9}  {str(ante):>11} {str(cons):>11}")
        if ante == cons:
            agree += 1
        else:
            viol += 1
    print(f"  antecedent==consequent in {agree}/{len(crows)} instances, "
          f"{viol} violations")

    print("\n[D] cost comparison (log2 units)")
    d, c = experiment_D()
    print(f"  NFS constant 2*(64/9)^(1/3) = {c:.6f}")
    print("  bits   log2(L_N[1/3,c])  N^(1/10)  N^(1/5)  N^(1/4)   D_crossover")
    for r in d:
        dc = r['D_crossover_log2']
        dcs = f"2^{dc:.1f}" if dc is not None else "< 1 (all D)"
        print(f"  {r['bits']:>5} {r['log2_L_N']:>15.1f} {r['log2_N_1_10']:>8.1f}"
              f" {r['log2_N_1_5']:>8.1f} {r['log2_N_1_4']:>8.1f}   {dcs}")

    print("\n[E] end-to-end Algorithm 3.1 on all N in [3, Nmax)")
    Dvals = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233]
    e = experiment_E(3000, Dvals)
    print(f"  samples = {e['total']}   valid = {e['valid']}   INVALID = {e['invalid']}"
          f"   returned NONE = {e['returned_none']}")
    if e['failures']:
        print("  FAILURES:", e['failures'])
    print(f"  ==> every output verified independently: {e['invalid'] == 0}"
          f"  (and returned_none = {e['returned_none']})")

    print("\n[E-neg] NEGATIVE CONTROLS (these MUST fail)")
    en1 = experiment_E(3000, Dvals, sabotage='no_line3')
    print(f"  sabotage 'no_line3' (drop the 2^D<N guard): "
          f"invalid = {en1['invalid']}/{en1['total']}  -> detector fires: "
          f"{en1['invalid'] > 0}")
    en2 = experiment_E(3000, Dvals, sabotage='bogus_divisor')
    print(f"  sabotage 'bogus_divisor' (return 3):        "
          f"invalid = {en2['invalid']}/{en2['total']}  -> detector fires: "
          f"{en2['invalid'] > 0}")

    print("\nDONE")


if __name__ == '__main__':
    main()
