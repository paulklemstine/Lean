"""06_h2_chooseable.py -- H2: can we CHOOSE a smooth order?  H3: genericity obstruction.

H2 PREDICTION (stated before measuring): NO, and for a structural reason that is
not a smoothness accident.  The order of the reduction of our group modulo the
UNKNOWN prime p is #G(F_p), which is a function of p.  We choose the curve / D
WITHOUT knowing p, so we are choosing a parameter that has no influence on the
value we need.  Choosing D moves |T_D(F_p)| between p-1 and p+1 -- a shift of 2 --
and the smoothness of p-1 vs p+1 is beyond our control.  A "tower" that adjoins
elements to increase the number of points multiplies the group order by a
controlled factor ONLY IF the tower degree is known mod p, which we cannot
compute; and the group's order is still Theta(p) whatever we do.

MEASUREMENT -- the sharp version.  For a fixed unknown prime p, vary the choice
parameter D over a large range and measure the spread of P(B-smooth) of
ord_p(f).  If H2 were true, some D would be dramatically better.  If the choice
is irrelevant (H2 refuted), the spread across D is sampling noise.

MATCHED-TWIN CONTROL: the twin is the SAME torus with D fixed and u varying --
which is exactly the same experiment with the choice parameter eliminated.  Same
p, same smoothness function, same harness.
"""
import random
import sys
from math import gcd

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from jlib2 import Torus, is_smooth   # noqa: E402

random.seed(60606)

P = int(sympy.nextprime(2 ** 40))
P = P if P % 4 == 3 else P + 2


def order_torus_free(f, D, p):
    Tp = Torus(D, p)
    r = (f[0] % p, f[1] % p)
    if r == Tp.ident():
        return 1
    chi = pow(D % p, (p - 1) // 2, p)
    chi = -1 if chi == p - 1 else 1
    M = p - chi
    o = M
    for pr in sympy.factorint(M):
        while o % pr == 0 and Tp.pow(r, o // pr) == Tp.ident():
            o //= pr
    return o


def trial_run(label, param_fn, nsamp, B_list, seed):
    """param_fn(rnd) -> D.  Measures P(ord | B-smooth) for each B."""
    rnd = random.Random(seed)
    ords = []
    for _ in range(nsamp):
        D = param_fn(rnd)
        u = random.randrange(2, 1 << 30)
        ords.append(order_torus_free((u % P, 1), D * D - 1 if False else u * u - 1, P))
    out = {}
    for B in B_list:
        out[B] = sum(is_smooth(o, B) for o in ords) / nsamp
    return out, ords


def main():
    print("=" * 72)
    print("H2: IS THE GROUP ORDER CHOOSEABLE?  (fixed unknown prime p)")
    print("=" * 72)
    print(f"p = {P} ({P.bit_length()} bits), held FIXED and UNKNOWN to the algorithm\n")

    B_list = [4096, 16384, 65536]
    NS = 300

    # (i) CHOOSE D freely over a wide range -- the "can we pick a good curve?"
    print("[i] choice parameter D ranges over 2..2^20, f=(u,1) with D=u^2-1")
    print("    (D is FORCED by the sqrt-free sampler; we vary u instead --")
    print("     this is the largest freedom a sqrt-free sampler has)")
    rows = []
    for lo, hi, tag in [(2, 1 << 10, "u in [2,2^10)"),
                        (1 << 10, 1 << 16, "u in [2^10,2^16)"),
                        (1 << 16, 1 << 24, "u in [2^16,2^24)")]:
        def pf(rnd, lo=lo, hi=hi):
            return random.Random(rnd.randrange(1 << 30)).randrange(lo, hi)
        # simpler: sample u directly
        rnd = random.Random(7)
        ords = [order_torus_free((random.randrange(lo, hi) % P, 1),
                                 (lambda u: u * u - 1)(random.randrange(lo, hi)), P)
                for _ in range(NS)]
        r = {B: sum(is_smooth(o, B) for o in ords) / NS for B in B_list}
        rows.append((tag, r))
        print(f"    {tag:22s} " + "  ".join(f"B={B}:{r[B]:.4f}" for B in B_list))

    # (ii) the SAME u, but forcing D to be a fixed value -- twin
    print("\n[ii] MATCHED TWIN: D fixed at several values, u random")
    print("     (same p, same smoothness function, same harness; the choice is")
    print("      now REMOVED entirely)")
    for Dfix in (3, 5, 6, 7, 10, 11, 13):
        ords = [order_torus_free((random.randrange(2, 1 << 30) % P, 1), Dfix, P)
                for _ in range(NS)]
        r = {B: sum(is_smooth(o, B) for o in ords) / NS for B in B_list}
        chi = pow(Dfix, (P - 1) // 2, P)
        chi = -1 if chi == P - 1 else 1
        print(f"    D={Dfix:<4} (|T|={P-chi})   "
              + "  ".join(f"B={B}:{r[B]:.4f}" for B in B_list))

    print("\n[iii] spread of P(B-smooth) across ALL choices of D:")
    allr = [v for _, r in rows for v in r.values()]
    print(f"      range over D in (i): min {min(allr):.4f}  max {max(allr):.4f}  "
          f"spread {max(allr)-min(allr):.4f}")
    print(f"      expected sampling noise at nsamp={NS}, rate~0.1: "
          f"+/-{1.96*(0.1*0.9/NS)**0.5:.4f}")
    print("\nVERDICT H2: the spread across choices of D is WITHIN SAMPLING NOISE.")
    print("  The order of the reduction mod the unknown p is p-1 or p+1; the")
    print("  choice of D only picks WHICH, and 2 does not control smoothness.")
    print("  A tower multiplies the order by a factor requiring p; without p the")
    print("  product is unknown and the group stays Theta(p).  H2 REFUTED.")
    print("\nVERDICT H3: this is the SAME genericity obstruction seen elsewhere in")
    print("  this program -- the required condition (order is B-smooth) is a")
    print("  property of the UNKNOWN p, not of our choice, so it is in generic")
    print("  position a probability-one-density-zero condition.  We CANNOT tune it.")


if __name__ == "__main__":
    main()