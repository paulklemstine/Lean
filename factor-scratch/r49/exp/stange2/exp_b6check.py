"""Q4 check.  cost.json showed b=6 -> exp_per_rel 23880 vs b=20 -> 452, AND
b=6 came out at rate 0.6417 (z=-2.48) vs b=20's 0.7750.  Two possibilities:
(a) a real smoothness (Dickman) effect -- BB=13 vs BB=71, so rho(u) differs;
(b) a DEFECT in the bounded stripper that only bites when c=1 and b is small.
This runs b=6, c=1 and scores EVERY attempt with BOTH strippers, so (b) would
show as a disagreement between them."""
import sys, json, math, random, time
sys.path.insert(0, '/home/raver1975/lean/factor-scratch/r49/exp/stange2')
import s2core
from s2core import attempt, bbound_for_b, factor_base, rand_g, order_mod_n
from stange import gen_semiprime, factor_from_multiple, factor_base as fb2
from s2core import factor_from_bounded

NT = int(sys.argv[1]) if len(sys.argv) > 1 else 400
for (b, c) in ((6, 1), (20, 1)):
    agree = disc = 0; fb = fbnd = 0; n = 0
    t0 = time.time()
    for k in range(NT):
        rng = random.Random(4242000 + k)
        nn, pp, qq = gen_semiprime(30, rng)
        FB = factor_base(bbound_for_b(b), nn)
        if len(FB) != b: continue
        r = attempt(nn, pp, qq, rand_g(nn, rng), FB, c, rng, strip="bounded")
        a = factor_from_multiple(r["G"], r["g"], nn) if r["G"] else None
        bb = factor_from_bounded(r["G"], r["g"], nn)
        n += 1
        fb += (a in (pp, qq)); fbnd += (bb in (pp, qq))
        if a == bb: agree += 1
        else: disc += 1
    for lbl, v in (("full stripper", fb), ("bounded stripper", fbnd)):
        se = math.sqrt(0.7407407*0.2592593/n)
        print(f"  b={b:<3d} c={c}  {lbl:<18} {v}/{n} = {v/n:.4f}  z vs 20/27 "
              f"{(v/n-0.7407407)/se:+.2f}", flush=True)
    print(f"  b={b:<3d} c={c}  strippers agree on {agree}/{n} (disagree {disc})"
          f"   [{time.time()-t0:.0f}s]", flush=True)
