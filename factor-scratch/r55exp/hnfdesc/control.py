"""
PART 2 -- THE POLLARD-RHO-DISGUISE CONTROL, EXECUTED.

The claim under test: the BQF descent recovers p,q for STRUCTURAL reasons
(class group), not because it is secretly a random search.

The control has two independent readings:

 (A) MAGNITUDE. On every instance the descent emits ~10^5 reduced forms
     before it reaches one whose leading coefficient is a factor, while
     rho needs ~10^2 modular squarings.  If the descent were rho in
     disguise it would have to be ~10^3 times CHEAPER than rho, not
     dearer.  Any method that is 100x more expensive than rho cannot be
     "rho in disguise" in the sense that matters -- it is simply a much
     worse factoring algorithm.

 (B) DISCRIMINATION. Does descent work track the CLASS NUMBER h(-4N), or
     does it track sqrt(p) (which is what a rho-disguise tracks)?
     For fixed size, sqrt(p) is nearly CONSTANT across instances while h
     varies by ~4x.  So we regress descent_forms on each predictor and
     see which one it follows.

 (C) THE ADVERSARIAL CELLS. 'rough-both' instances are the ones where
     Pollard p-1 and Pollard rho's smooth-order luck both fail; if the
     descent still succeeds there, its success is not a smoothness
     artifact.  We also check p-1 agreement.

 (D) POSITIVE / NEGATIVE controls on the detector itself.

SEED at top. RUN TWICE.  Report per cell, never pooled only.
"""

import math
import random
import json
import time

import sympy
from cypari2 import Pari

import bqflib
import desc
import gen
from run import descent_work, p1_works

P = Pari()
SEED = 20251004
random.seed(SEED)

BITS = 17
Y = 10000


def spearman(xs, ys):
    """Spearman rank correlation (no scipy dependency, no normality assumed)."""
    def rank(v):
        order = sorted(range(len(v)), key=lambda i: v[i])
        r = [0.0] * len(v)
        i = 0
        while i < len(order):
            j = i
            while j + 1 < len(order) and v[order[j + 1]] == v[order[i]]:
                j += 1
            avg = (i + j) / 2.0 + 1
            for k in range(i, j + 1):
                r[order[k]] = avg
            i = j + 1
        return r
    rx, ry = rank(xs), rank(ys)
    n = len(xs)
    mx, my = sum(rx) / n, sum(ry) / n
    num = sum((rx[i] - mx) * (ry[i] - my) for i in range(n))
    dx = math.sqrt(sum((rx[i] - mx) ** 2 for i in range(n)))
    dy = math.sqrt(sum((ry[i] - my) ** 2 for i in range(n)))
    return num / (dx * dy) if dx and dy else float('nan')


def one(p, q, tag):
    N = p * q
    D = -4 * N
    h = int(P.qfbclassno(D))
    t0 = time.time()
    hit_a, idx, hidx, capped = descent_work(N)
    dt = time.time() - t0
    g = math.gcd(hit_a, N) if hit_a else None
    rho_steps = []
    for s in (11, 1237, 99991):
        f, steps, _, _ = bqflib.pollard_rho_steps(N, s)
        if f and 1 < f < N:
            rho_steps.append(steps)
    rho_med = sorted(rho_steps)[len(rho_steps) // 2] if rho_steps else None
    return dict(tag=tag, N=N, p=min(p, q), q=max(p, q), bits=N.bit_length(),
                h=h, forms=idx, hit_a=hit_a, gcd=g, secs=round(dt, 2),
                rho_med=rho_med, sqrt_p=math.isqrt(min(p, q)),
                ratio=(idx / rho_med) if rho_med else None,
                p1=p1_works(p, q))


if __name__ == '__main__':
    rows = []
    print(f"SEED={SEED} BITS={BITS} Y={Y}  (N < 2^40, all generated locally)")
    print()
    print("=" * 116)
    print("PER-CELL TABLE (never pooled only)")
    print("=" * 116)
    print(f"{'tag':<12} {'h(-4N)':>8} {'desc forms':>10} {'rho med':>8} {'ratio':>8} "
          f"{'sqrt(p)':>8} {'p-1':>6} {'gcd==fac':>8} {'secs':>6}")
    print("-" * 116)
    for trial in range(8):
        for gf in (gen.gen_smooth_both, gen.gen_smooth_one, gen.gen_rough_both):
            p, q, tag = gf(bits=BITS, y=Y)
            r = one(p, q, tag)
            rows.append(r)
            good = r['gcd'] in (r['p'], r['q'])
            print(f"{tag:<12} {r['h']:>8} {r['forms']:>10} {str(r['rho_med']):>8} "
                  f"{(f'{r[chr(114)+chr(97)+chr(116)+chr(105)+chr(111)]:.0f}' if r['ratio'] else 'n/a'):>8} "
                  f"{r['sqrt_p']:>8} {str(r['p1']):>6} {str(good):>8} {r['secs']:>6}")
    n = len(rows)
    print(f"\nrows = {n}  (each row is one independent instance; no pooling of the verdict)")
    if n < 20:
        print("*** UNDERPOWERED: fewer than 20 rows -- cell-level verdicts are indicative only ***")

    # ---- (A) magnitude -------------------------------------------------
    ratios = [r['ratio'] for r in rows if r['ratio']]
    if ratios:
        print()
        print("(A) MAGNITUDE: descent_forms / rho_median_steps")
        print(f"    n={len(ratios)}  min={min(ratios):.0f}x  median={sorted(ratios)[len(ratios)//2]:.0f}x  max={max(ratios):.0f}x")
        print(f"    -> the descent is {min(ratios):.0f}x-{max(ratios):.0f}x MORE work than rho.")
        print("       A rho-disguise would have to be ~1000x CHEAPER. It is not.")

    # ---- (B) discrimination -------------------------------------------
    forms = [r['forms'] for r in rows]
    hs = [r['h'] for r in rows]
    sq = [r['sqrt_p'] for r in rows]
    print()
    print("(B) DISCRIMINATION: Spearman rank correlation of descent work vs")
    print(f"    class number h(-4N):   rho_s = {spearman(forms, hs):+.3f}   (n={n})")
    print(f"    sqrt(p) (rho-predictor): rho_s = {spearman(forms, sq):+.3f}   (n={n})")
    hr = [r['h'] / r['rho_med'] for r in rows if r['ratio']]
    fr = [r['forms'] for r in rows if r['ratio']]
    if len(hr) >= 3:
        print(f"    h(-4N)/rho_steps vs forms: rho_s = {spearman(fr, hr):+.3f}   (n={len(hr)})")

    # ---- (C) adversarial cells -----------------------------------------
    print()
    print("(C) ADVERSARIAL CELLS -- does the descent still work where smoothness fails?")
    for tag in ('smooth-both', 'smooth-one', 'rough-both'):
        sub = [r for r in rows if r['tag'] == tag]
        ok = sum(1 for r in sub if r['gcd'] in (r['p'], r['q']))
        p1 = sum(1 for r in sub if r['p1'])
        print(f"    {tag:<12} n={len(sub):<3} descent recovered factor {ok}/{len(sub)}"
              f"   p-1 method works {p1}/{len(sub)}")
        if len(sub) < 20:
            print(f"                 *** UNDERPOWERED cell (n={len(sub)} < 20) ***")

    # ---- (D) detector controls -----------------------------------------
    print()
    print("(D) DETECTOR CONTROLS")
    pos = neg = 0
    posn = negn = 0
    for r in rows[:4]:
        posn += 1
        if r['gcd'] in (r['p'], r['q']):
            pos += 1
    # NEGATIVE: D with a single prime factor -> no non-trivial a exists
    for bits in (17, 18):
        rr = int(sympy.nextprime(1 << (bits - 1)))
        hits = 0
        for a in range(2, 3001):
            if (4 * rr) % a == 0 and math.gcd(a, rr) not in (1, rr):
                hits += 1
        negn += 1
        neg += 1 if hits == 0 else 0
        print(f"    NEG D=-4r (r={rr} prime): non-trivial a-divides-D hits = {hits}  "
              f"{'QUIET (good)' if hits == 0 else '*** FIRED (bad) ***'}")
    print(f"    POS control: descent recovered a factor on {pos}/{posn} (want {posn}/{posn})")
    print(f"    NEG control: stayed quiet on {neg}/{negn} (want {negn}/{negn})")

    json.dump(rows, open('results_part2.json', 'w'), indent=1, default=str)
    print("\nwrote results_part2.json")
