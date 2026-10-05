"""
PART 3 -- COST or STRUCTURE?  The actual round question.

Part 2 showed the descent DOES recover a factor, and does so for
structural reasons (work ~ h(-4N), rho_s=+0.92, not rho_s=+0.04 with
sqrt(p)).  So the question "is it rho in disguise" is settled: no.

The remaining question is the round's real one:

    if the group is not smooth, is the failure a COST problem
    (smoothness testing dominates) or a STRUCTURAL one
    (the information is not there)?

Answer here: NEITHER failure occurs at this scale -- the information IS
there and IS extracted.  What we measure instead is the COST MODEL, and
the cost model is what kills the route.

Hypothesis (stated before measurement):

  H1  descent_forms ~ h(-4N) = Theta(sqrt(N)/pi * L(1,chi_D))
      so descent cost is N^(1/2), NOT subexponential.
  H2  The ratio descent_forms / h(-4N) is O(1) -- the descent emits a
      CONSTANT FRACTION of the class group before hitting an ambiguous
      form.  This is what "reachable in small steps" would need to be
      false.
  H3  Therefore cost(N) ~ sqrt(N) = N^(1/2), while rho = N^(1/4) and
      GNFS = exp((64/9)^(1/3) (ln N)^(1/3) (ln ln N)^(2/3)).  For every
      N large enough, sqrt(N) loses to BOTH.

H3 is the closure, restated as a cost statement rather than a smoothness
statement.  The closure said "h B-smooth forces p <= B".  That specific
hypothesis is NOT what fails -- the descent never needed h to be smooth.
What fails is Theta(sqrt(N)).

MEASUREMENT: h and descent_forms across sizes and across the
class-number distribution, plus the explicit ratio.
"""

import math
import random
import json
import time

from cypari2 import Pari

import gen
from run import descent_work
from control import spearman

P = Pari()
SEED = 20251004
random.seed(SEED)


def one(p, q, tag):
    N = p * q
    h = int(P.qfbclassno(-4 * N))
    t0 = time.time()
    hit_a, idx, hidx, capped = descent_work(N)
    dt = time.time() - t0
    return dict(tag=tag, N=N, bits=N.bit_length(), h=h, forms=idx,
                hit_a=hit_a, capped=capped, secs=round(dt, 2),
                ratio=idx / h if h else None,
                sqrtN=math.isqrt(N))


if __name__ == '__main__':
    rows = []
    print(f"SEED={SEED}   (all N generated locally, N < 2^46)")
    print()
    print("=" * 104)
    print("SIZING: does descent cost track h(-4N)?  does the ratio stay O(1)?")
    print("=" * 104)
    print(f"{'bits':>5} {'tag':<12} {'h(-4N)':>10} {'desc forms':>11} {'forms/h':>9} "
          f"{'sqrt(N)':>12} {'secs':>6}")
    print("-" * 104)
    for bits in (15, 17, 19, 21, 23):
        for gf, tag in ((gen.gen_smooth_both, 'smooth-both'),
                        (gen.gen_smooth_one, 'smooth-one'),
                        (gen.gen_rough_both, 'rough-both')):
            try:
                p, q, t = gf(bits=bits, y=10000)
            except RuntimeError as e:
                print(f"{bits:>5} {tag:<12} generation failed: {e}")
                continue
            r = one(p, q, tag)
            rows.append(r)
            print(f"{r['bits']:>5} {tag:<12} {r['h']:>10} {r['forms']:>11} "
                  f"{r['ratio']:>9.3f} {r['sqrtN']:>12} {r['secs']:>6}")

    n = len(rows)
    print(f"\nrows = {n}")
    if n < 20:
        print("*** UNDERPOWERED ***")

    # ---- H1: forms tracks h -------------------------------------------
    forms = [r['forms'] for r in rows]
    hs = [r['h'] for r in rows]
    sq = [r['sqrtN'] for r in rows]
    print()
    print("H1/H2 -- what does descent work track?")
    print(f"    Spearman(forms, h(-4N))     = {spearman(forms, hs):+.3f}  (n={n})")
    print(f"    Spearman(forms, sqrt(N))    = {spearman(forms, sq):+.3f}  (n={n})")
    print(f"    Spearman(h, sqrt(N))        = {spearman(hs, sq):+.3f}  (n={n})  [analytic predicts ~1]")

    ratios = [r['ratio'] for r in rows]
    print()
    print("H2 -- forms/h(-4N), the 'fraction of the class group traversed':")
    print(f"    min={min(ratios):.3f}  median={sorted(ratios)[len(ratios)//2]:.3f}  max={max(ratios):.3f}")
    print("    O(1) means: the descent traverses a CONSTANT FRACTION of the whole class")
    print("    group.  There is no 'small-step reachability' -- it is a full traversal.")

    # ---- H3: the exponent ------------------------------------------------
    print()
    print("H3 -- COST MODEL.  descent forms vs the alternatives.")
    print(f"{'bits':>5} {'N':>18} {'descent~':>12} {'rho~=N^1/4':>12} {'ratio':>8} "
          f"{'GNFS exp':>10} {'GNFS/descent':>14}")
    print("-" * 104)
    for b in (128, 256, 512, 1024, 2048):
        lnN = b * math.log(2)
        # work in log10 space: 2^b overflows float beyond ~1024 bits
        ld = b * math.log10(2) / 2.0        # log10 of N^(1/2)
        lr = b * math.log10(2) / 4.0        # log10 of N^(1/4)
        lgnfs = ((64 / 9) ** (1 / 3) * (lnN) ** (1 / 3)
                 * (math.log(lnN)) ** (2 / 3)) / math.log(10)
        print(f"{b:>5} N=2^{b:<5} descent=1e{ld:>7.1f} rho=1e{lr:>7.1f} "
              f"descent/rho=1e{ld-lr:>6.1f} GNFS=1e{lgnfs:>6.1f} "
              f"descent/GNFS=1e{ld-lgnfs:>7.1f}")
    print()
    print("    descent (N^1/2) loses to rho (N^1/4) by N^1/4, and loses to GNFS by")
    print("    N^(1/2)/L_N[1/3,c].  This is the closure -- but as a COST statement,")
    print("    not as a smoothness statement.")

    json.dump(rows, open('results_part3.json', 'w'), indent=1, default=str)
    print("\nwrote results_part3.json")
