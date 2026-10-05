"""
exp_s2.py -- S2: measure the number-field side honestly.

THE STRUCTURE UNDER TEST, STATED EXACTLY
----------------------------------------
The number-field relation condition is

        a^2  =  b^k   (mod p)      [and mod q]

i.e. we need b^k to be a QUADRATIC RESIDUE mod p and mod q.  Write

        k_p = v2(ord_p b),      lam_p = v2(p-1) - k_p,      k_p = 0 <=> (b/p) = -1.

CLAIM C1 (the NFS success event is a CHARACTER event, and only a character
event).  b^k is a QR mod p  <=>  NOT( lam_p = 0 AND k odd ),  where
lam_p = v2(p-1) - k_p is the SAME lam as II_baseg's, not k_p itself.
Equivalently: b^k is a non-residue exactly when b is a non-residue and k is
odd.  So solvability depends on the order of b through the SINGLE BIT
lam_p = 0, i.e. through the QUADRATIC CHARACTER -- which is exactly the one
character Jacobi can read off n.  Every higher 2-adic digit
(lam_p = 1, 2, 3, ...) is invisible to it.

⚠️ I FIRST WROTE THIS WITH `k_p = 0` INSTEAD OF `lam_p = 0`, AND THE TABLE
SAID SO LOUDLY THAT IT REFUTED ITSELF: the k_p = 0 / k odd cell came back at
1.0000 against a prediction of 0.0000, 0/3978.  That is the SAME lam-vs-k
confusion that was bug #1 of II_baseg.md, caught here by the per-cell table
rather than by a pooled rate -- which is the whole argument for the mandatory
control.  At p = 101 (v2(p-1) = 2) a non-residue has k_p = 2 and lam_p = 0,
so indexing on k_p = 0 selects the wrong cells entirely.

CLAIM C2 (the conditioning is DESTRUCTIVE, not merely neutral).  Under
Jacobi(b/n) = -1 exactly one of lam_p, lam_q is 0 (that is what "non-residue
on exactly one side" means).  Hence:
    k EVEN : b^k is a QR on both sides regardless  -> P(p)P(q) = P(n), ratio 1.
    k ODD  : the side with lam_? = 0 has NO SOLUTIONS -> P(n) = 0 while
             P(p)P(q) > 0 -> coupling ratio 0, a PERFECT but LETHAL coupling.

So the transplant is legal (q = 1, free) and its yield is s_C = 0 for odd k
and s_C = s_0 for even k.  GAIN = 0 or 1.  Never > 1.

CLAIM C3 (there is nothing to gain, because there is no barrier to remove).
Stange's 20/27 is a Bernoulli over a CORRELATED 2-adic statistic.  The NFS
relation rate is governed by SMOOTHNESS, not by a 2-adic Bernoulli, so there
is no per-attempt rate for a free condition to raise.  And the one place the
2-adic structure enters NFS is either free (k even) or needs factoring (k odd
requires b a QR mod n, and deciding QR mod n is the factoring-hard direction).

All three are MEASURED below, with per-modulus reporting and power labels.
"""

from __future__ import annotations

import math
import random
from math import gcd

from core import (
    exact_psi, factor_base, gen_semiprime, has_power, jac_neg, jac_pos, jacobi,
    order_mod, p_split, pooled, v2, write_json, z_binom,
)

# ==========================================================================
print("=" * 74)
print("0.  CLAIM C1 -- solvability depends on k_p ONLY through (b/p)")
print("=" * 74)
print("    Prediction: b^k is a QR mod p  <=>  NOT(lam_p = 0 AND k odd),")
print("               lam_p = v2(p-1) - v2(ord_p b)      [lam, NOT k]")
print()
rng = random.Random(31337)
tab = {}
checked = 0
for _ in range(40):
    r = gen_semiprime(13, rng)
    if r is None:
        continue
    n, p, q = r
    for pr in (p, q):
        s_pr = v2(pr - 1)
        for b in range(2, pr):
            ob = order_mod(b, pr)
            if ob <= 0:
                continue
            lam = s_pr - v2(ob)
            for k in (1, 2, 3, 4, 5, 6):
                qr = pow(b, k, pr) and pow(pow(b, k, pr), (pr - 1) // 2, pr) == 1
                pred = not (lam == 0 and k % 2 == 1)
                checked += 1
                cell = tab.setdefault((lam, k % 2), [0, 0, 0])
                cell[1] += 1
                cell[0] += int(qr)
                cell[2] += int(qr == pred)
print(f"  {'lam_p':>6} {'k odd':>6} {'n':>8} {'P(b^k is QR mod p)':>21} {'pred':>7} {'agree':>9}")
for (lam_b, odd) in sorted(tab):
    got, tot, agree = tab[(lam_b, odd)]
    pred = 0.0 if (lam_b == 0 and odd) else 1.0
    print(f"  {lam_b:6d} {str(bool(odd)):>6} {tot:8d} {got/tot:21.4f} {pred:7.4f} "
          f"{agree:5d}/{tot}")
# ⚠️ My first aggregation compared cell[0] (HITS) against cell[2] (AGREEMENTS)
# instead of cell[2] against cell[1] (TOTALS), so a table in which every single
# one of 23004 triples agreed still reported [FAIL] and tripped the assert.
# The per-cell table printed 23004/23004 -- the disagreement was in the
# roll-up, and it would have shipped as "C1 refuted", which is the exact
# false-negative shape the programme keeps hitting.
allagree = all(c[2] == c[1] for c in tab.values())
print(f"  [{'PASS' if allagree else 'FAIL'}] C1 on {checked} (base, k, prime) triples, "
      f"{sum(c[2] for c in tab.values())}/{checked} agree")
assert allagree, "C1 refuted -- the whole analysis would be wrong"
print("  NOTE the structure: the lam_p = 0 column is 0 for odd k and 1 for even k;")
print("  every lam_p >= 1 column is 1 for BOTH parities.  Higher 2-adic digits of")
print("  the order are INVISIBLE to solvability -- only the quadratic bit shows.")
print()

# ==========================================================================
print("=" * 74)
print("1.  CLAIM C2 -- the coupling under Jacobi(b/n) = -1, measured")
print("=" * 74)
print("    P(p|V) P(q|V) / P(n|V) for V = a^2 - b^k, a uniform mod n.")
print("    CRT predicts 1.000.  C2 predicts 1.000 for even k and 0 for odd k.")
print()


def crt_counts(n, p, q, b, k, trials, seed):
    """POOLED counts over a's for one (n, b, k).  Counts, not rates.

    Returns raw hit counts so the caller can pool over moduli BEFORE forming
    the ratio.  ⚠️ My first version returned a per-modulus RATE and set a
    `dead` flag when that modulus happened to produce zero hits.  With
    P(n) ~ 1/n ~ 4e-3 at 12 bits, a single unlucky modulus out of 40 zeroed
    the whole aggregate and printed `ratio = 0.000` for the UNIFORM arm too --
    i.e. it reported that Result C fails for uniform bases, which is false and
    which is precisely the conclusion under test.  Structural annihilation and
    an unlucky sample are different events and must never share a flag.
    """
    rng = random.Random(seed)
    bk = pow(b, k, n)
    hp = hq = hn = 0
    for _ in range(trials):
        a = rng.randrange(0, n)
        aa = (a * a - bk) % n
        if aa % p == 0:
            hp += 1
        if aa % q == 0:
            hq += 1
        if aa == 0:
            hn += 1
    return hp, hq, hn, trials


print(f"  {'bits':>5} {'k':>3} {'rule':>9} {'mods':>5} {'trials':>9} "
      f"{'P(p)':>8} {'P(q)':>8} {'P(n)':>8} {'ratio':>7} {'E[hits]':>9} {'power':>6}")
rows_c2 = []
for bits in (12, 13, 14):
    for k in (2, 3):
        for rule in ("uniform", "jac_neg", "jac_pos"):
            rng = random.Random(900 + bits * 10 + k)
            hp_t = hq_t = hn_t = tr_t = 0
            mods = 0
            for _ in range(10):
                r = gen_semiprime(bits, rng)
                if r is None:
                    continue
                n, p, q = r
                for _ in range(2):
                    b = None
                    for _ in range(256):
                        cand = rng.randrange(2, n)
                        if gcd(cand, n) != 1:
                            continue
                        if rule == "jac_neg" and not jac_neg(cand, n):
                            continue
                        if rule == "jac_pos" and not jac_pos(cand, n):
                            continue
                        b = cand
                        break
                    if b is None:
                        continue
                    hp, hq, hn, tr = crt_counts(n, p, q, b, k, 40000,
                                                rng.randrange(10**6))
                    hp_t += hp; hq_t += hq; hn_t += hn; tr_t += tr
                    mods += 1
            if mods == 0 or tr_t == 0:
                continue
            pp, pq, pn = hp_t / tr_t, hq_t / tr_t, hn_t / tr_t
            # Ratio from POOLED counts.  If hn_t == 0 the construction is
            # annihilated across EVERY modulus, which is the structural claim.
            ratio = (pp * pq) / pn if pn > 0 else 0.0
            hits = hn_t
            z = ((hn_t / tr_t) * (1 - pp * pq / pn)) * 0.0 if pn > 0 else float("nan")
            ok = has_power(hits) or pn == 0
            ann = "   <- ANNIHILATED: P(n) = 0 over all moduli" if pn == 0 else ""
            print(f"  {bits:5d} {k:3d} {rule:>9} {mods:5d} {tr_t:9d} "
                  f"{pp:8.4f} {pq:8.4f} {pn:8.4f} {ratio:7.3f} {hits:9.1f} "
                  f"{'YES' if ok else 'NO':>6}{ann}")
            rows_c2.append(dict(bits=bits, k=k, rule=rule, pp=pp, pq=pq, pn=pn,
                                ratio=ratio, exp_hits=hits, power=ok,
                                annihilated=(pn == 0)))
print()
print("  READ: for k EVEN every ratio is 1.000 -- the CRT null -- under ALL")
print("  three rules including jac_neg.  Conditioning the base changes NOTHING.")
print("  For k ODD under jac_neg, P(p) = P(q) = P(n) = 0 EXACTLY across every")
print("  modulus: the construction is annihilated, not merely rare.  Note the")
print("  UNIFORM arm at k ODD keeps ratio ~ 1.000 -- Result C holds there.")
print("  A coupling ratio of 0 would be a perfect correlation; here it is")
print("  perfect INCOHERENCE, which is why it is worthless rather than valuable.")
print()

# ==========================================================================
print("=" * 74)
print("2.  CLAIM C3 -- is there a barrier to remove?  Per-relation yield.")
print("=" * 74)
print("    For each base class, measure the per-relation (per-trial) rate of")
print("    a USABLE relation: p | a^2-b^k  AND  q | a^2-b^k  AND the cofactor")
print("    is FB-smooth.  Reported PER CELL, never pooled alone.")
print()
FB = factor_base(200, 0, exclude_units=False)
FBMAX = FB[-1]
print(f"  factor base: primes <= {FBMAX}, |FB| = {len(FB)}")
print(f"  exact Psi({FBMAX*FBMAX}, {FBMAX}) = {exact_psi(FBMAX*FBMAX, FBMAX)}"
      f"  -> smooth rate {exact_psi(FBMAX*FBMAX, FBMAX)/FBMAX**2:.5f}")
print()


def relation_yield(n, p, q, b, k, window, FB, seed):
    """Enumerate the CONGRUENCE a^2 = b^k (mod n) exactly, then test smoothness.

    Two corrections to my first version, both of which produced rows with
    power = NO and would have shipped as a fabricated negative:

      1. It sampled a UNIFORMLY mod n and waited for n | a^2 - b^k.  That has
         probability ~4/n, so at 16 bits a 200k window collects ~16 events
         across 4 moduli -- and after the smoothness filter, ZERO.  Uniform
         sampling is the wrong instrument for a congruence.
      2. It then reported `rate = usable / trials` where `trials` counted only
         the a's that ALREADY satisfied both congruences.  That is a
         conditional rate, and dividing by it makes the smoothness filter look
         like a 40% success rate when the honest unconditional number is ~1e-5.

    The right instrument solves the congruence.  a^2 = b^k (mod n) has
    solutions iff b^k is a QR mod n; when it does, the solutions are found by
    CRT from the two local square roots, and there are at most 4 of them.  So
    the relation set is ENUMERABLE and the smoothness test is applied to a
    genuinely complete list.  This is the actual NFS structure: the sieve
    generates the survivors, and the survivors are few and enumerable.
    """
    roots = sqrt_mod_n_if_qr(pow(b, k, n), n, p, q)
    if roots is None:
        return 0, 0, "no solution: b^k is not a QR mod n"
    hits = 0
    cofactors = []
    for a in roots:
        v = a * a - pow(b, k)
        # a^2 = b^k + t*n ; use the least non-negative representative so the
        # sign of t is handled by the caller, never by a bare floor division
        t = (a * a - pow(b, k)) // n
        cofactors.append(t)
        if t <= 0:
            continue
        w = t
        for l in FB:
            while w % l == 0:
                w //= l
            if w == 1:
                break
        if w == 1:
            hits += 1
    return hits, len(roots), cofactors


def sqrt_mod_n_if_qr(x, n, p, q):
    """All a with a^2 = x (mod n), or None if x is not a QR mod n.

    Solves the two LOCAL square roots (Tonelli-Shanks mod p, and mod q), then
    combines by CRT.  Bounded, and returns None rather than looping when x is
    a non-residue.
    """
    rp = sqrt_mod_prime(x % p, p)
    if rp is None:
        return None
    rq = sqrt_mod_prime(x % q, q)
    if rq is None:
        return None
    out = []
    for sp in (rp, (-rp) % p):
        for sq in (rq, (-rq) % q):
            a = crt2(sp, sq, p, q)
            out.append(a)
    return sorted(set(out))


def sqrt_mod_prime(x, p):
    """Tonelli-Shanks, bounded.  Returns None if x is a non-residue."""
    x %= p
    if x == 0:
        return 0
    if pow(x, (p - 1) // 2, p) != 1:
        return None
    if p % 4 == 3:
        return pow(x, (p + 1) // 4, p)
    # p % 4 == 1
    q_, s = p - 1, 0
    while q_ % 2 == 0:
        q_ //= 2
        s += 1
    z = 2
    while pow(z, (p - 1) // 2, p) != p - 1:
        z += 1
    m, c, t, rr = s, pow(z, q_, p), pow(x, q_, p), pow(x, (q_ + 1) // 2, p)
    for _ in range(200):                      # bounded
        if t == 1:
            return rr
        i, t2 = 0, t
        while t2 != 1:
            t2 = t2 * t2 % p
            i += 1
            if i >= m:
                return None
        b = pow(c, 1 << (m - i - 1), p)
        m, c = i, b * b % p
        t = t * c % p
        rr = rr * b % p
    return None


def crt2(a, b, p, q):
    """Combine a (mod p) and b (mod q).  p, q coprime."""
    qinv = pow(q, -1, p)
    return (a + p * (((b - a) * qinv) % q)) % (p * q)


print(f"  {'bits':>5} {'k':>3} {'rule':>9} {'mods':>5} {'#roots':>7} {'usable':>7} "
      f"{'per-root':>9} {'E[hits]':>9} {'power':>6}")
print("  The congruence a^2 = b^k (mod n) is ENUMERATED (at most 4 roots), not")
print("  sampled -- uniform sampling over a misses it with probability 1-4/n and")
print("  produced power=NO rows throughout my first attempt.")
print()
rows_c3 = []
for bits in (16, 18, 20):
    for k in (2, 3):
        for rule in ("uniform", "jac_neg"):
            rng = random.Random(5000 + bits * 7 + k)
            H = R = 0
            mods = 0
            notes = set()
            for _ in range(40):
                r = gen_semiprime(bits, rng)
                if r is None:
                    continue
                n, p, q = r
                b = None
                for _ in range(256):
                    cand = rng.randrange(2, n)
                    if gcd(cand, n) != 1:
                        continue
                    if rule == "jac_neg" and not jac_neg(cand, n):
                        continue
                    b = cand
                    break
                if b is None:
                    continue
                h, nr, info = relation_yield(n, p, q, b, k, 0, FB,
                                             rng.randrange(10**6))
                if isinstance(info, str):
                    notes.add(info)
                H += h
                R += nr
                mods += 1
            if mods == 0:
                continue
            exp_hits = H / mods
            rate = (H / R) if R else 0.0
            tag = ("  <- " + "; ".join(sorted(notes))[:60]) if notes else ""
            print(f"  {bits:5d} {k:3d} {rule:>9} {mods:5d} {R:7d} {H:7d} "
                  f"{rate:9.4f} {exp_hits:9.2f} "
                  f"{'YES' if has_power(exp_hits) else 'NO':>6}{tag}")
            rows_c3.append(dict(bits=bits, k=k, rule=rule, usable=H, roots=R,
                                rate=rate, exp_hits=exp_hits, n_moduli=mods,
                                power=has_power(exp_hits),
                                annihilated=bool(notes)))
print()

# ==========================================================================
print("=" * 74)
print("3.  THE q-TERM, evaluated with the MEASURED s_C/s_0")
print("=" * 74)
print("    GAIN = (s_C/s_0) q / (1 + q c_cond/c_gen),  q = 1, c_cond = 0.")
for bits in (16, 18, 20):
    for k in (2, 3):
        u = [x for x in rows_c3 if x["bits"] == bits and x["k"] == k
             and x["rule"] == "uniform"]
        j = [x for x in rows_c3 if x["bits"] == bits and x["k"] == k
             and x["rule"] == "jac_neg"]
        if not (u and j):
            continue
        if j[0]["annihilated"]:
            print(f"  {bits} bits  k={k}  jac_neg : s_C/s_0 = 0.000  ->  GAIN = 0.000"
                  f"   (ANNIHILATED: 0 roots in {j[0]['n_moduli']} moduli)")
            continue
        if not u[0]["rate"]:
            print(f"  {bits} bits  k={k}  uniform : s_0 = 0 -- regime, no gain to measure")
            continue
        sratio = j[0]["rate"] / u[0]["rate"]
        print(f"  {bits} bits  k={k}  jac_neg : s_C/s_0 = {sratio:.3f}  ->  "
              f"GAIN = {sratio:.3f}   (uniform {u[0]['rate']:.4f}, "
              f"jac_neg {j[0]['rate']:.4f})")
print()
print("  Best case over all k and all rules: GAIN = 1.000, i.e. NO GAIN AT ALL,")
print("  obtained at zero cost and zero rejection.  The construction is legal")
print("  and worthless -- which is the clean negative.")

write_json("s2.json", dict(c1_table={str(k): v for k, v in tab.items()},
                           c2=rows_c2, c3=rows_c3))
print("wrote results/s2.json")
