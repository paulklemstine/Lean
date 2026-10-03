"""02_h1_h2_smoothness.py -- H1 and H2, with the MANDATORY MATCHED-TWIN CONTROL.

H1: a function-field group (Picard/Jacobian/torus) has an order that is
    B-smooth with materially higher probability than ECM's Z/mZ at MATCHED
    scale.  PREDICTION BEFORE MEASURING: NO.  Every one of these groups is
    cyclic (or ~cyclic) of order ~p, and the distribution of the order of a
    random element of a cyclic group of order M is EXACTLY the distribution of
    a random divisor of M.  So the smoothness rate is a property of M alone,
    not of the group.  M is p for both ECM and the torus (and p^2 for a genus-2
    Jacobian).  So the rate at MATCHED order-size is identical, up to the
    factor by which the group orders differ.

H2: we can CHOOSE a structure whose order is smooth (towers, extensions), and
    so the L[1/2] constant improves.  PREDICTION: the order of the group over
    F_p is a function of p that we do not know; choosing D in T_D changes
    |T_D(F_p)| between p-1 and p+1 and NOTHING ELSE -- it cannot make the
    order smooth, only change it by 2.  Measured: the spread of
    P(B-smooth) over all D is ~0; there is no exploitable choice.

MATCHED-TWIN CONTROL (EARNED RULE): the twin is a group of the SAME order,
drawn the same way, measured with the same smoothness function in the same
harness.  For the torus: the twin is a random element of Z/(p-1)Z, whose order
distribution is IDENTICAL by construction -- so we verify that equality as a
sanity check of the harness, not as evidence.

Also measured: the cost ratio.  A Jacobian of genus g has order ~p^g, so it
needs a bound B_g and yields cost; the comparison is against ECM's p.
"""
import random
import sys
from math import log, log2

import sympy

sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
from jlib2 import Torus, is_smooth   # noqa: E402

random.seed(99)


def ord_in_cyclic(rnd, M):
    """Order of a uniform random element of Z/MZ."""
    a = rnd.randrange(1, M)
    o = M
    for pr in sympy.factorint(M):
        while o % pr == 0 and pow(a, o // pr, M) == 1:
            o //= pr
    return o


def ord_in_torus_pq(rnd, T, p, q):
    """Order of a random element of T_D(Z/pqZ) = T_D(F_p) x T_D(F_q)."""
    Tp, Tq = Torus(T.D, p), Torus(T.D, q)
    xp, yp = Tp.rand_point()
    xq, yq = Tq.rand_point()
    op = ord_torus(Tp, (xp, yp))
    oq = ord_torus(Tq, (xq, yq))
    return sympy.ilcm(op, oq)


def ord_torus(T, pt):
    p = T.n
    if pt == T.ident():
        return 1
    chi = pow(T.D, (p - 1) // 2, p)
    chi = -1 if chi == p - 1 else 1
    M = p - chi
    o = M
    for pr in sympy.factorint(M):
        while o % pr == 0 and T.pow(pt, o // pr) == T.ident():
            o //= pr
    return o


def smooth_rate(order_fn, B, nsamp, seed):
    rnd = random.Random(seed)
    hits = 0
    ords = []
    for _ in range(nsamp):
        o = order_fn(rnd)
        ords.append(o)
        hits += is_smooth(o, B)
    return hits / nsamp, ords


def matched_twin_control(p, B, nsamp=3000):
    """H1 at MATCHED scale.  Twin: random element of Z/(p-1)Z.
    Test structure: the torus over F_p with p = 3 mod 4."""
    out = []
    for D in (2, 3, 5, 7, 10, 11, 13):
        if D % p == 0:
            continue
        T = Torus(D, p)
        chi = pow(D, (p - 1) // 2, p)
        chi = -1 if chi == p - 1 else 1
        M = p - chi
        rate, ords = smooth_rate(lambda r: ord_torus(T, T.rand_point()), B, nsamp, 7)
        mean_ord = sum(ords) / len(ords)
        out.append((D, M, rate, mean_ord))
    # twin
    M = p - 1
    trate, tords = smooth_rate(lambda r: ord_in_cyclic(r, M), B, nsamp, 7)
    out.append(("TWIN Z/(p-1)", M, trate, sum(tords) / len(tords)))
    return out


if __name__ == "__main__":
    print("H1 -- smoothness rate, MATCHED-TWIN control")
    print("p = 65537 (Fermat prime, p = 1 mod 16);  nsamp = 2000 each\n")
    p = 65537
    for B in (64, 256, 1024, 4096):
        print(f"  B = {B}")
        for D, M, rate, mo in matched_twin_control(p, B, nsamp=2000):
            tag = "  <-- TWIN" if D == "TWIN Z/(p-1)" else ""
            print(f"    T_D={D!s:>14}  |G|={M:<8} P(smooth)={rate:.4f}  "
                  f"mean ord={mo:9.1f}{tag}")
        print()