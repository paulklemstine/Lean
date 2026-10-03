"""
exp_h1.py -- H1, tested against a prediction DERIVED FROM THEORY, not from a
guess.

exp_order.py showed P(success) = P(v2(ord_p g) != v2(ord_q g)) = 20/27 exactly,
and that this quantity depends ONLY on g -- never on the relation set.  So the
honest H1 question is not "does biasing the alpha_t help" (it cannot: the alpha_t
are erased by the stripper) but "does biasing anything that changes the ORDER
STEP help".

The sharpest version is a NON-RESIDUE BIAS, and it has a closed-form prediction:

  conditioning on ord(g) EVEN raises P(success) from 20/27 to
      (20/27 - P(v2=0 both)) / (1 - P(v2=0 both))
      = (20/27 - 1/9) / (8/9) = 0.70833...

i.e. conditioning on higher 2-adic order LOWERS the success rate, because
v2(ord)=0 is a *mixture* of (0,0) FAILURE and (0,>=1) SUCCESS; conditioning on
"ord even" removes the (0,0) failures but the remaining mass still contains the
(1,1),(2,2),... collisions.  PREREGISTERED: 0.7083, NOT above 0.7407.

Biasing toward SMALL-order-divisibility of g is therefore predicted to be
strictly COUNTERPRODUCTIVE -- the exact opposite of the task's opening
hypothesis, and the reason is structural, not empirical.

Also tested: a genuine relation-level bias (preferring relations whose residue
carries a large v_2), which must leave the success rate at 20/27.
"""
from __future__ import annotations

import json
import math
import random
import sys
import time
from math import gcd
from collections import defaultdict

from s2core import attempt, bbound_for_b, factor_base, order_mod_n, rand_g, v_p
from stange import fb_exponents, find_relations, gen_semiprime

P_TRUE = 20.0 / 27.0
P_COND_ORD_EVEN = (20.0 / 27.0 - 1.0 / 9.0) / (8.0 / 9.0)   # = 0.708333


def trial(nbits, b, c, seed, gmode="any", vmod=None):
    rng = random.Random(seed)
    n, p, q = gen_semiprime(nbits, rng)
    FB = factor_base(bbound_for_b(b), n)
    if len(FB) != b:
        return None
    if gmode == "any":
        g = rand_g(n, rng)
    elif gmode == "nonresidue":
        # g with Jacobi symbol (g/n) = -1  <=>  ord(g) is even
        while True:
            gg = rng.randrange(2, n)
            if gcd(gg, n) == 1 and pow(gg, (n - 1) // 2, n) == n - 1:
                g = gg
                break
    elif gmode == "residue":
        while True:
            gg = rng.randrange(2, n)
            if gcd(gg, n) == 1 and pow(gg, (n - 1) // 2, n) == 1:
                g = gg
                break
    else:
        raise ValueError(gmode)
    r = attempt(n, p, q, g, FB, c, rng, strip="bounded", vmod=vmod)
    r["gmode"] = gmode
    if r["factor"] is not None:
        assert n % r["factor"] == 0 and 1 < r["factor"] < n
    return r


def run(label, nt, nbits, b, c, seed0, **kw):
    t0 = time.time()
    rs = [trial(nbits, b, c, seed0 + k, **kw) for k in range(nt)]
    rs = [r for r in rs if r]
    f = sum(1 for r in rs if r["factor"] is not None)
    rate = f / max(len(rs), 1)
    se = math.sqrt(rate * (1 - rate) / max(len(rs), 1))
    ordeven = sum(1 for r in rs if r["ord_g"] % 2 == 0)
    h1 = sum(1 for r in rs if (r["h"] or 1) == 1)
    print(f"{label:<42} {f:>4}/{len(rs):<4} = {rate:.4f} (+-{1.96*se:.4f}) "
          f"ord even {ordeven}/{len(rs)}  h=1 {h1}/{len(rs)}  "
          f"({time.time()-t0:.1f}s)", flush=True)
    return {"label": label, "N": len(rs), "f": f, "rate": rate,
            "ord_even": ordeven, "h1": h1, "rels": (b + c),
            "rels_per_succ": (b + c) / max(rate, 1e-9),
            "secs": round(time.time() - t0, 1)}


def bias_vprime(k):
    """The implementable relation-level bias.  A relation is
    g^x == prod p_i^{f_i} mod n, so v_k(r) == f_k exactly, and f_k is known
    the instant the relation is accepted -- this is the only per-relation
    handle on 'prefer high small-prime valuation' that exists BEFORE the
    kernel is formed (the alpha_t themselves cannot be scored until then).
    Returning -f_k makes the sampler REJECT relations with low f_k and keep
    the ones with the highest power of p_k in them."""
    def score(rel):
        return -rel[0][k]
    return score


if __name__ == "__main__":
    NT = int(sys.argv[1]) if len(sys.argv) > 1 else 150
    print(f"PREREG-1 target: >= 0.85.   Exact P = 20/27 = {P_TRUE:.6f}.")
    print(f"PREREG-1b (theory): conditioning on ord(g) EVEN gives "
          f"{P_COND_ORD_EVEN:.6f}, NOT an improvement.\n")
    out = []
    out.append(run("H0 unbiased (control)", NT, 30, 12, 10, 610000))
    out.append(run("H1-B1 g = QUADRATIC NON-RESIDUE mod n", NT, 30, 12, 10,
                   620000, gmode="nonresidue"))
    out.append(run("H1-B2 g = QUADRATIC RESIDUE mod n", NT, 30, 12, 10,
                   630000, gmode="residue"))
    out.append(run("H1-B3 relation bias: keep only max-v_2 relations", NT, 30,
                   12, 10, 640000, vmod=bias_vprime(0)))
    out.append(run("H1-B4 relation bias: keep only max-v_3 relations", NT, 30,
                   12, 10, 650000, vmod=bias_vprime(1)))
    json.dump(out, open("h1.json", "w"), indent=1)
    print(f"\nPREREG-1 VERDICT: "
          f"{'PASSED' if max(o['rate'] for o in out) >= 0.85 else 'FALSIFIED'}"
          f"  (best {max(o['rate'] for o in out):.4f} vs target 0.85)")
    print(f"B1 vs theory {P_COND_ORD_EVEN:.4f}: see rate above.")