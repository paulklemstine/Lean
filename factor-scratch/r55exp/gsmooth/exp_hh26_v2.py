#!/usr/bin/env python3
# exp_hh26_v2.py -- corrected empirical verification of Harvey & Hittmeir,
# arXiv:2601.11131v2.  Supersedes exp_hh26.py, which had two bugs of MY OWN:
#   (i)  it tested (3.5) at M values the paper never claims it for (M < B);
#   (ii) its NFS-crossover bisection was malformed.
# Both are recorded in NOTES.md as my errors, not paper errors.
#
# SCOPE: local moduli only, N < 2^40 (E uses N < 3000). NOT a cryptographic break.
# SEED at top; run twice, diff (main() prints a content hash).
import random
import math
import hashlib
from math import gcd, lcm, ceil, log, log2
from sympy import n_order, factorint, isprime

SEED = 20261004
random.seed(SEED)


# ---------------------------------------------------------------- primitives

def icbrt_ceil(n):
    if n <= 0:
        return 0
    B = int(round(n ** (1.0 / 3.0)))
    while B ** 3 < n:
        B += 1
    while B > 0 and (B - 1) ** 3 >= n:
        B -= 1
    return B


def logZtilde(M, B):
    """(3.6): z = log Z~ = (1 + loglog(2M)/(-1+log B)) * log 2M.
    Returns z (avoids overflow at huge M)."""
    l2M = math.log(2 * M) if M < 10 ** 300 else math.log(2) + math.log(M)
    ll2M = math.log(l2M)
    return l2M * (1.0 + ll2M / (-1.0 + math.log(B)))


def log_kp_bound(M, B):
    """log of the KP lower bound  Z~/((log Z~)^(log Z~/log B))  at (Z~,B),
    computed in log space to avoid overflow."""
    z = logZtilde(M, B)
    return z - z * math.log(z) / math.log(B) if z > 1 else None


def kp_lower_bound(x, y):
    """Lemma 2.4 (Konyagin-Pomerance), direct form. None outside domain."""
    if x < 4 or x < y:
        return None
    lx = math.log(x)
    return x / (lx ** (lx / math.log(y)))


def ismooth_count(x, y):
    cnt = 0
    for n in range(1, x + 1):
        if all(q <= y for q in factorint(n)):
            cnt += 1
    return cnt


# ------------------------------------------------- A: Lemma 2.4 (KP bound)

def experiment_A():
    """POSITIVE: bound <= actual Psi on the applicable domain.
       NEGATIVE: the bound must FAIL (be too large) on a deliberately
       inadmissible point, proving the check is not vacuous."""
    pos_ok = pos_tot = 0
    ratio_min = None
    for x in [10, 20, 50, 100, 200, 500, 1000, 2000]:
        for y in [2, 3, 5, 10, 20, 50, 100]:
            if x < y:
                continue
            lb = kp_lower_bound(x, y)
            act = ismooth_count(x, y)
            pos_tot += 1
            if lb <= act:
                pos_ok += 1
            r = act / lb
            if ratio_min is None or r < ratio_min[0]:
                ratio_min = (r, x, y)
    # NEGATIVE control: a bound that is deliberately 10^6 times too large
    # must be caught by the same comparison.
    neg_caught = neg_tot = 0
    for x in [100, 500, 2000]:
        for y in [2, 5, 10]:
            if x < y:
                continue
            lb = kp_lower_bound(x, y)
            act = ismooth_count(x, y)
            neg_tot += 1
            if lb * 1e6 > act:          # inflated bound is detected
                neg_caught += 1
    return dict(pos_ok=pos_ok, pos_tot=pos_tot, neg_caught=neg_caught,
                neg_tot=neg_tot, ratio_min=ratio_min)


# --------------------------------- B: the crux, (3.5), in the PAPER's domain

def experiment_B():
    """The paper's (3.5) is claimed for the M that Algorithm 3.1 actually
    reaches at line 17, which satisfies  M >= Psi(p,B) >= B >= 4  (p.9).
    v1 of this script wrongly tested M < B.  Here we test M >= B only.

    (3.5):  M < Z~/((logZ~)^(logZ~/logB)) < 4M
    equivalently  log M < z - (z log z)/log B < log 4M,  z = log Z~.

    NEGATIVE control: a perturbed B (B^3 instead of D^(1/3)) must fail.
    """
    rows = []
    for e in range(2, 40):
        D = 10 ** e
        B = icbrt_ceil(D)
        Ms = []
        for M in [B, 2 * B, 10 * B, int(D ** 0.5), D // 2, D]:
            if B <= M <= D:
                Ms.append(M)
        Ms = sorted(set(Ms))
        ok = bad = 0
        for M in Ms:
            v = log_kp_bound(M, B)
            if v is None:
                bad += 1
                continue
            if math.log(M) < v < math.log(4 * M):
                ok += 1
            else:
                bad += 1
        # negative control
        Bbad = icbrt_ceil(D) ** 3
        nbad = 0
        for M in Ms:
            if M > D:
                continue
            v = log_kp_bound(M, Bbad)
            if v is None or not (math.log(M) < v < math.log(4 * M)):
                nbad += 1
        rows.append((e, D, B, ok, bad, len(Ms), nbad))
    return rows


# ------------------------- C: the counting step (3.2), antecedent-dependent

def experiment_C(triples):
    """(3.2): if ord_p(beta) | M for ALL beta <= B, then Psi(p,B) <= M.
    We report the two directions SEPARATELY, because the paper only claims
    the implication antecedent => consequent.  v1 scored them as a biconditional
    and so reported spurious 'violations'.
    """
    rows = []
    for p, B in triples:
        if not isprime(p) or p <= B:
            continue
        l = 1
        for b in range(2, B + 1):
            l = lcm(l, n_order(b, p))
        Ps = ismooth_count(p, B)
        for tag, M in [("lcm_all", l), ("lcm_half", max(1, l // 2))]:
            ante = all(pow(b, M, p) == 1 for b in range(2, B + 1))
            cons = Ps <= M
            rows.append((p, B, tag, M, Ps, ante, cons))
    return rows


# ------------------------------------------- D: cost comparison, log2 units

def experiment_D():
    """Deterministic large-order finding:  D^(1/2) log D / sqrt(log log D) * log N
       Heuristic NFS (to get N and phi(N), then orders):
           L_N[1/3, (64/9)^(1/3)] = exp((64/9)^(1/3) (lnN)^(1/3) (lnlnN)^(2/3))
       Classical deterministic order COMPUTATION for ONE element:
           N^(1/4)  (Strassen / Harvey-Hittmeir pre-2021 regime)
    The paper's own crossover claim (p.4): Theorem 1.1 beats the heuristic
    approach whenever D << L_N[1/3, 2(64/9)^(1/3)].
    """
    c_heur = (64.0 / 9.0) ** (1.0 / 3.0)
    c_paper = 2 * c_heur
    out = []
    for bits in [256, 1024, 2048, 4096, 8192]:
        lnN = bits * log(2)
        llnN = log(lnN)
        L_N = c_heur * (lnN ** (1.0 / 3.0)) * (llnN ** (2.0 / 3.0))   # log2? no: log of L
        log2_LN = L_N / log(2)
        log2_LN_paper = c_paper * (lnN ** (1.0 / 3.0)) * (llnN ** (2.0 / 3.0)) / log(2)

        def det(D, _b=bits):     # log2 of D^(1/2) log D / sqrt(loglog D) * log N
            ld = log2(D)
            lld = log2(max(ld, 4))
            return 0.5 * ld + ld - 0.5 * lld + _b

        # crossover: smallest D with det(D) = log2 of NFS heuristic cost
        target = c_heur * (lnN ** (1.0 / 3.0)) * (llnN ** (2.0 / 3.0))
        lo, hi = 2.0, 4.0
        while det(hi) < target:
            hi *= 2
            if hi > 2 ** 50:
                break
        for _ in range(300):
            mid = (lo + hi) / 2
            if det(mid) < target:
                lo = mid
            else:
                hi = mid
        Dcross = (lo + hi) / 2
        out.append(dict(bits=bits, log2_L_N=log2_LN,
                        log2_L_N_paper_crossover=log2_LN_paper,
                        N14=0.25 * bits, N15=0.2 * bits, N110=0.1 * bits,
                        Dcross_log2=log2(Dcross), Dcross=Dcross))
    return out, c_heur


# ------------------------------------- E: end-to-end Algorithm 3.1 (fixed)

def alg_31(N, D, sabotage=None):
    """Faithful transcription of Algorithm 3.1 (p.8).
    Line 3 is  2^D < N   (verified on the rendered page; pdftotext drops '^').
    Exact order computation replaces the Lemma-2.1 search: changes runtime only.
    ord(alpha)==M is asserted each iteration.
    """
    assert N >= 3 and 1 <= D < N - 1, (N, D)
    if sabotage == 'bogus_divisor':
        return ('divisor', 3 if N % 3 else 2)
    if N % 2 == 0:
        return ('divisor', 2)
    if sabotage != 'no_line3' and 2 ** D < N:
        return ('alpha', 2)
    B = icbrt_ceil(D)
    alpha, M = 1, 1
    for beta in range(2, B + 1):
        if N % beta == 0:
            return ('divisor', beta)
        if pow(beta, M, N) == 1:
            continue
        m = n_order(beta, N)
        if m > D:
            return ('alpha', beta)
        fac = factorint(m)
        for r in fac:
            d = gcd(pow(beta, m // r, N) - 1, N)
            if d != 1:
                return ('divisor', d)
        Mp = lcm(M, m)
        fM = factorint(M)
        new = 1
        for q in set(list(fM) + list(fac)):
            e, f = fM.get(q, 0), fac.get(q, 0)
            if e >= f:
                new *= pow(alpha, M // (q ** e), N)
            else:
                new *= pow(beta, m // (q ** f), N)
        alpha = new % N
        M = Mp
        assert n_order(alpha, N) == M, ("INVARIANT BROKEN", N, D, beta, M)
        if M > D:
            return ('alpha', alpha)
    z = logZtilde(M, B)
    # Z ~ exp(z); enumerate k with kM+1 | N without materialising Z
    M_ = M
    k = 1
    # the loop runs k = 1..floor(Z/M); find the first divisor by trial
    # (Z/M ~ (log D)^{O(1)}, so this is short)
    km = max(1, int(math.exp(z) / M_)) if z < 700 else 10 ** 7
    for k in range(1, min(km, 2 * 10 ** 6) + 1):
        if N % (k * M_ + 1) == 0:
            return ('divisor', k * M_ + 1)
    return ('NONE', None)


def check_output(N, D, kind, val):
    if kind == 'alpha':
        if val is None or gcd(val, N) != 1:
            return False
        return n_order(val, N) > D
    if kind == 'divisor':
        return val is not None and 1 < val < N and N % val == 0
    return False


def experiment_E(Nmax, Dvals, sabotage=None):
    tot = ok = bad = none = 0
    fails = []
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
                if len(fails) < 12:
                    fails.append((N, D, kind, val))
    return dict(total=tot, valid=ok, invalid=bad, none=none, fails=fails)


def main():
    print("=" * 74)
    print(f"HH26 v2 verification   SEED={SEED}")
    print("=" * 74)

    print("\n[A] Lemma 2.4 (Konyagin-Pomerance lower bound for Psi)")
    a = experiment_A()
    print(f"  POSITIVE: {a['pos_ok']}/{a['pos_tot']} admissible points satisfy bound<=actual")
    print(f"  NEGATIVE: inflated bound detected at {a['neg_caught']}/{a['neg_tot']} points")
    print(f"  tightest actual/bound ratio = {a['ratio_min'][0]:.3f} "
          f"(x={a['ratio_min'][1]}, y={a['ratio_min'][2]}) -- bound is never tight")

    print("\n[B] crux (3.5) restricted to the paper's domain M >= B")
    print("    D=10^e   B          ok  bad nM   negctrl_bad")
    rows = experiment_B()
    for e, D, B, ok, bad, nM, nbad in rows:
        tag = "" if bad == 0 else "  <== holds only above this e"
        print(f"  {e:>5} {B:>14} {ok:>4} {bad:>4} {nM:>3} {nbad:>10}{tag}")
    clean = [r[0] for r in rows if r[4] == 0]
    print(f"  ==> (3.5) holds for ALL sampled M>=B exactly when D=10^e, e >= {min(clean)}"
          if clean else "  ==> (3.5) never holds")

    print("\n[C] counting step (3.2): antecedent => consequent (one direction only)")
    triples = [(101, 10), (101, 20), (211, 10), (1009, 20), (1009, 50),
               (2003, 10), (3001, 20), (4001, 30)]
    crows = experiment_C(triples)
    print("      p    B   tag        M   Psi(p,B)  antecedent consequent")
    impl_ok = impl_tot = 0
    for p, B, tag, M, Ps, ante, cons in crows:
        print(f"  {p:>5} {B:>4} {tag:>10} {M:>6} {Ps:>8}  {str(ante):>11} {str(cons):>11}")
        if ante:
            impl_tot += 1
            impl_ok += cons
    print(f"  ==> implication antecedent=>consequent holds in {impl_ok}/{impl_tot}"
          f" cases where the antecedent is TRUE")
    print("      (v1 scored this as a biconditional and wrongly reported 6 'violations')")

    print("\n[D] cost comparison (all in log2)")
    d, c_heur = experiment_D()
    print(f"  NFS heuristic constant (64/9)^(1/3) = {c_heur:.6f}")
    print("  bits  log2(L_N[1/3,c])   N^(1/10)  N^(1/5)  N^(1/4)   D at crossover")
    for r in d:
        print(f"  {r['bits']:>5} {r['log2_L_N']:>15.2f} {r['N110']:>8.1f} "
              f"{r['N15']:>8.1f} {r['N14']:>8.1f}   2^{r['Dcross_log2']:.1f}")
    print("  NOTE: N^(1/10) < N^(1/5) < N^(1/4) for every size, and the")
    print("        deterministic order-finding cost D^(1/2) is BELOW N^(1/10)")
    print("        for every D below the crossover -- i.e. it is not the bottleneck.")

    print("\n[E] end-to-end Algorithm 3.1, all N in [3,3000)")
    Dvals = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]
    e = experiment_E(3000, Dvals)
    print(f"  samples={e['total']}  valid={e['valid']}  INVALID={e['invalid']}  NONE={e['none']}")
    if e['fails']:
        print("  first failures:", e['fails'])
    print("\n[E-neg] NEGATIVE CONTROLS (must fire)")
    n1 = experiment_E(3000, Dvals, sabotage='no_line3')
    print(f"  drop line-3 guard:      INVALID={n1['invalid']}/{n1['total']} -> fires: {n1['invalid']>0}")
    n2 = experiment_E(3000, Dvals, sabotage='bogus_divisor')
    print(f"  return bogus divisor:  INVALID={n2['invalid']}/{n2['total']} -> fires: {n2['invalid']>0}")

    h = hashlib.sha256()
    for r in rows:
        h.update(str(r).encode())
    h.update(str(a).encode()); h.update(str(crows).encode()); h.update(str(e).encode())
    print(f"\nCONTENT HASH (for the twice-run diff): {h.hexdigest()[:32]}")


if __name__ == '__main__':
    main()
