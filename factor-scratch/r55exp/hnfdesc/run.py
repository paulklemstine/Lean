"""
MAIN EXPERIMENT: does an explicit BQF/HNF descent recover p and q from a
class group whose order is NOT smooth, and if it fails, is the failure a
COST problem or a STRUCTURAL one?

THE CENTRAL CONTROL (the point of this round)
---------------------------------------------
A "class group factoring" method that succeeds in small time is frequently
Pollard rho in disguise: it is finding p by a random search, and any
attribution to class-group structure is spurious.  So every instance here
is paired with a PAIRED POLLARD RHO measurement on the SAME instance, and
we compare WORK COUNTS, not just success:

  * rho_steps  : modular squarings rho needs
  * descent_idx: number of reduced forms the descent must emit before it
                 reaches one whose leading coefficient divides D

If the descent were rho in disguise, descent_idx would track sqrt(p), i.e.
it would track rho_steps, and would NOT track h(D).  If it is genuinely
class-group, descent_idx tracks the class number.

SEED at top, RUN TWICE, diff.

SCOPE: all moduli generated locally, N < 2^40.  Nothing of cryptographic
interest is factored.
"""

import random
import time
import math
import json
import sympy
from cypari2 import Pari

import bqflib
import desc
import gen

P = Pari()
SEED = 20251004
random.seed(SEED)

BITS = 17
Y = 10000


def descent_work(N, a_cap=None):
    """
    Walk reduced forms of disc -4N in increasing leading coefficient until
    one is found with a | 4N and a not in {1,4}.  Returns
    (hit_a, forms_emitted, hit_index, capped).
    """
    if a_cap is None:
        # NOTE: a hard cap of 200000 (an earlier version) silently truncated
        # the walk above ~38 bits, because the ambiguous form sits at
        # a ~ min(p,q), which is larger than that.  That produced hit_a=None
        # -- a VACUOUS "no factor found" that read as a structural failure and
        # manufactured a bogus 'forms/h collapses with N' trend.  The cap is
        # now only a safety valve, and `capped` is checked by every caller.
        a_cap = math.isqrt(4 * N // 3) + 2
    d = desc.Descender(N)
    d._spf = desc.SegSPF(a_cap + 32)
    d.a_max = a_cap + 16
    m = 4 * N
    trivial = {1, 2, 4}
    idx = 0
    for a in range(1, a_cap + 1):
        if a == 1:
            idx += 1                      # (1,0,N)
            continue
        for y in d.roots(a):
            for yy in (y, y - a):
                b = 2 * yy
                if not (-a < b <= a):
                    continue
                t = yy * yy + N
                if t % a:
                    continue
                c = t // a
                if a > c or (a == c and b < 0):
                    continue
                # PRIMITIVITY -- see desc.py.  Emitting imprimitive forms
                # inflates the walk exactly 2x on D=-4pq.
                if math.gcd(math.gcd(a, b), c) != 1:
                    continue
                idx += 1
                # TRIVIAL-DIVISOR GUARD: 2 | 4N and 4 | 4N ALWAYS, and
                # gcd(2,N)=gcd(4,N)=1 for odd N, so an unguarded
                # "a | D" detector fires on a=2 immediately and returns
                # the vacuous gcd 1 -- a false PASS.  Require a genuine
                # non-trivial factor.
                if a not in trivial and m % a == 0:
                    g = math.gcd(a, N)
                    if 1 < g < N:
                        return a, idx, idx, False
    return None, idx, None, True


def h_of(D):
    return int(P.qfbclassno(D))


def p1_works(p, q, y=Y):
    """Pollard p-1: does either factor's p-1 factor over the y-bound?"""
    return gen.y_smooth(min(p, q) - 1, y) or gen.y_smooth(max(p, q) - 1, y)


def run_instance(p, q, tag, rho_seeds=(11, 1237, 99991)):
    N = p * q
    D = -4 * N
    h = h_of(D)
    t0 = time.time()
    hit_a, idx, hidx, capped = descent_work(N)
    t_desc = time.time() - t0
    # the factor the descent actually produced
    got = None
    if hit_a is not None:
        got = math.gcd(hit_a, N)
    # paired rho
    rho = []
    for s in rho_seeds:
        f, steps, _, ev = bqflib.pollard_rho_steps(N, s)
        rho.append((s, f, steps))
    ok_rho = [r for r in rho if r[1] and 1 < r[1] < N]
    return {
        "tag": tag, "p": p, "q": q, "N": N, "bits": N.bit_length(),
        "D": D, "h": h,
        "descent_hit_a": hit_a, "descent_gcd": got,
        "descent_forms": idx, "descent_hit_index": hidx,
        "descent_capped": capped, "descent_secs": round(t_desc, 3),
        "p1_works": p1_works(p, q),
        "rho": [{"seed": r[0], "factor": r[1], "steps": r[2]} for r in rho],
        "rho_ok": len(ok_rho), "rho_med_steps": (sorted(r[2] for r in ok_rho)[len(ok_rho) // 2]
                                                 if ok_rho else None),
        "sqrt_p": math.isqrt(min(p, q)),
    }


if __name__ == '__main__':
    print(f"SEED={SEED}  BITS={BITS}  Y={Y}   (all N < 2^40, generated locally)")
    print()
    rows = []
    print("=" * 108)
    print("PART 1 -- per-cell: descent work vs rho work vs class number")
    print("=" * 108)
    print(f"{'tag':<12} {'bits':>4} {'h(-4N)':>9} {'desc forms':>11} {'hit a':>8} "
          f"{'gcd':>8} {'rho ok/3':>9} {'rho med':>9} {'sqrt(p)':>8} {'p-1':>5}")
    print("-" * 108)
    for trial in range(3):
        for gf in (gen.gen_smooth_both, gen.gen_smooth_one, gen.gen_rough_both):
            p, q, tag = gf(bits=BITS, y=Y)
            r = run_instance(p, q, tag)
            rows.append(r)
            print(f"{tag:<12} {r['bits']:>4} {r['h']:>9} {r['descent_forms']:>11} "
                  f"{str(r['descent_hit_a']):>8} {str(r['descent_gcd']):>8} "
                  f"{r['rho_ok']:>6}/3 {str(r['rho_med_steps']):>9} "
                  f"{r['sqrt_p']:>8} {str(r['p1_works']):>5}")
    with open('results_part1.json', 'w') as f:
        json.dump(rows, f, indent=1, default=str)
    print()
    print(f"rows = {len(rows)}")
