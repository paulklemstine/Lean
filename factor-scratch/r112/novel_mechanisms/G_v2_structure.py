#!/usr/bin/env python3
"""
CANDIDATE G -- Can a v2(ord_p g) != v2(ord_q g) mismatch be turned into a
FACTOR by something cheaper than birthday?

The Stange analysis (memory: stange-q-kernel-method-works, self-test T7)
established that Stange's method succeeds exactly when
v2(ord_p g) != v2(ord_q g), with probability 8/9 for random g.  That is a
RATE.  The candidate claim is strictly stronger and is the real question:
mismatch is a TRIGGER for an O(polylog) factoring step, not just a coin flip.

MECHANISM (the multiplicative group directly, a different algebraic object
from f(x,y)=0 or f(x)=a+x).  Write ord_p(g) = 2^a * m_p and ord_q(g) = 2^b * m_q
with m odd, and suppose a > b.  Then g^(2^b * m_p) = 1 mod p but
g^(2^b * m_p) != 1 mod q (its order mod q is 2^(a-b) > 1).  So
h = g^(2^b * m_p) - 1 satisfies p | h and q | h, and gcd(h, N) = p.
The ATTRACTOR is that m_p, m_q, a, b are all unknown without factoring --
so the "cheap" step needs the odd parts, which is exactly the expensive
part.  Stange supplies m via the Q-kernel at the cost of the b^4 rational
linear algebra and the 4.3-order regime gap.

FALSIFIER (sharp and cheap): measure how many extra group operations a
mismatched g costs under the BEST stripping available.  If the answer is
still ~sqrt(ord), the mismatch is a probability and not a mechanism.

METHOD NOTE / DEFECT: the first version repeatedly squared g and took
gcd(a-1, N), which found 0/78 mismatches factor.  That is VOID, not a null:
naive squaring drives a to an element of odd order, where gcd(a-1,N) is 1
by construction.  Replaced by the correct construction, and the CONTROL is
now that we KNOW p, so we can verify each claimed factor by multiplication.
"""
import json, random, time
from math import gcd
from sympy.ntheory import n_order
from common112 import gen_semiprime, verified_factor


def v2(n):
    k = 0
    while n % 2 == 0:
        n //= 2
        k += 1
    return k


def factor_via_known_orders(g, n, op, oq):
    """Given the TRUE orders (an oracle this factoring does not have), build a
    factor in O(1) modular exponentiations.  This is the upper bound on what
    the v2 structure can possibly buy.

    a = v2(op), b = v2(oq), a != b.  Take the larger, say a > b.
    h = g^(2^b * m_p) where m_p = odd part of op.  Then ord_p(g^(...)) = 1 so
    h == 1 mod p, and ord_q = 2^(a-b) * m_q/m_q-part so it is != 1 mod q.
    gcd(g^(2^b * m_p) - 1, n) = p.
    """
    a, b = v2(op), v2(oq)
    if a == b:
        return None, None
    # DEFECT FIXED: the first version swapped a,b but NOT the matching
    # (order, valuation) pair, so it used the wrong prime's odd part and
    # factored 0/177.  Swapping a,b without swapping op,oq is the bug --
    # the pairing is the whole content.  Now e is a multiple of whichever
    # order has the SMALLER 2-adic valuation, and strictly not a multiple of
    # the other, so g^e - 1 is divisible by exactly one prime factor.
    odd_p, odd_q = op >> a, oq >> b
    if a < b:
        e = (1 << a) * odd_p      # multiple of op, not of oq
    else:
        e = (1 << b) * odd_q      # multiple of oq, not of op
    h = (pow(g, e, n) - 1) % n
    return gcd(h, n), 1


def main():
    out = dict(cells=[], note="upper bound; uses the TRUE orders, which a "
                              "real attack does not have")
    tot_mismatch = tot_ok = 0
    for bits, seed in [(56, 1), (56, 2), (60, 1), (60, 2)]:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(bits, seed, beta=0.5)
        assert p * q == N
        mism = ok = 0
        for _ in range(60):
            g = rng.randrange(2, N)
            op, oq = n_order(g, p), n_order(g, q)
            if v2(op) == v2(oq):
                continue
            mism += 1
            f, _ = factor_via_known_orders(g, N, op, oq)
            if verified_factor(N, p, q, f):
                ok += 1
        tot_mismatch += mism
        tot_ok += ok
        out["cells"].append(dict(bits=bits, seed=seed, mismatch=mism,
                                 factored=ok, cost_modular_exps=1))
        print("N=%d seed=%d: mismatch %d/60 -> factored %d in 1 mod exp"
              % (bits, seed, mism, ok), flush=True)
    out["total_mismatch"] = tot_mismatch
    out["total_factored"] = tot_ok
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_G_v2.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("TOTAL mismatch %d, factored %d" % (tot_mismatch, tot_ok))
    print("wrote", fn)


if __name__ == "__main__":
    main()
