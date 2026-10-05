"""
PART 4 -- WHY does forms/h COLLAPSE with size?

scaling.py measured forms/h(-4N) falling 1.85 -> 0.030 from 30 to 46 bits.
Two very different explanations, and they have OPPOSITE verdicts:

  (E1) "SMALL-STEP REACHABILITY" -- the good news.  The descent hits an
       ambiguous form after only O(1) fraction of the class group, and
       that fraction shrinks with N.  If this were real and stable, the
       route would be asymptotically cheaper than a full traversal.

  (E2) A CONFOUND I ALREADY KNOW ABOUT: my descent STOPS at the first
       a | 4N with non-trivial gcd(a,N).  If p < q, then a = p is
       reachable, but so is a = q -- and whichever of p, q is SMALLER
       appears at a smaller leading coefficient, so the descent stops
       earlier.  That is a SIZE artefact, not structure.

Discriminator:  E2 predicts the hit is a ~ min(p,q) and the hit index
tracks the leading coefficient, NOT the class group.  E1 predicts the hit
is at a *structurally distinguished* position.

MEASUREMENT: record hit_a against min(p,q), max(p,q), and h(-4N), and
check whether hit_a is literally a factor (E2) or something else (E1).

ALSO: the honest baseline.  A full traversal to a given a_cap is what a
complete reduced-form enumeration costs.  Report both.
"""

import math
import random
import json

from cypari2 import Pari

import gen
from run import descent_work
from control import spearman

P = Pari()
SEED = 20251004
random.seed(SEED)

rows = []
print(f"SEED={SEED}")
print()
print("=" * 112)
print("IS THE EARLY HIT A FACTOR?  (E2 = size artefact)  or structural? (E1)")
print("=" * 112)
print(f"{'bits':>5} {'tag':<12} {'p=min':>9} {'q=max':>9} {'hit a':>9} "
      f"{'hit==p':>7} {'hit==q':>7} {'hit/p':>7} {'h(-4N)':>9} {'forms':>8} {'forms/h':>8}")
print("-" * 112)
for bits in (17, 19, 21, 23, 25, 27):
    for gf, tag in ((gen.gen_rough_both, 'rough-both'),
                    (gen.gen_smooth_one, 'smooth-one')):
        try:
            p, q, t = gf(bits=bits, y=10000)
        except RuntimeError as e:
            print(f"{bits:>5} {tag:<12} gen failed: {e}")
            continue
        lo, hi = min(p, q), max(p, q)
        N = lo * hi
        h = int(P.qfbclassno(-4 * N))
        hit_a, idx, hidx, capped = descent_work(N)
        rows.append(dict(bits=bits, tag=tag, p=lo, q=hi, hit_a=hit_a, h=h,
                         forms=idx, capped=capped))
        print(f"{N.bit_length():>5} {tag:<12} {lo:>9} {hi:>9} {str(hit_a):>9} "
              f"{str(hit_a == lo):>7} {str(hit_a == hi):>7} "
              f"{(f'{hit_a/lo:.2f}' if hit_a else 'n/a'):>7} {h:>9} {idx:>8} "
              f"{(f'{idx/h:.3f}' if h else 'n/a'):>8}")

n = len(rows)
ok = [r for r in rows if r['hit_a'] is not None]
hit_is_p = sum(1 for r in ok if r['hit_a'] == r['p'])
hit_is_q = sum(1 for r in ok if r['hit_a'] == r['q'])
print()
print(f"rows = {n}, descent found a hit on {len(ok)}")
print(f"  hit_a == min(p,q): {hit_is_p}/{len(ok)}")
print(f"  hit_a == max(p,q): {hit_is_q}/{len(ok)}")
print(f"  hit_a is a factor at all: {sum(1 for r in ok if r['hit_a'] in (r['p'], r['q']))}/{len(ok)}")

if len(ok) >= 3:
    print()
    print("Spearman(hit_a, min(p,q)) = %+.3f   (n=%d)" % (spearman([r['hit_a'] for r in ok], [r['p'] for r in ok]), len(ok)))
    print("Spearman(hit_a, h(-4N))   = %+.3f   (n=%d)" % (spearman([r['hit_a'] for r in ok], [r['h'] for r in ok]), len(ok)))
    print("Spearman(forms, h(-4N))  = %+.3f   (n=%d)" % (spearman([r['forms'] for r in ok], [r['h'] for r in ok]), len(ok)))
    print("Spearman(forms, hit_a)   = %+.3f   (n=%d)" % (spearman([r['forms'] for r in ok], [r['hit_a'] for r in ok]), len(ok)))

json.dump(rows, open('results_part4.json', 'w'), indent=1, default=str)
print("\nwrote results_part4.json")
