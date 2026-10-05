#!/usr/bin/env python3
"""
B -- does a Legendre-symbol DECISION ORACLE beat birthday?

TWO VOID RUNS FIXED (both recorded, neither hidden):
  (1) budget=20000 was ~50x BELOW sqrt(p) for a 40-bit p.  BOTH arms
      exhausted without factoring.  A run where nothing fires is not a null.
  (2) at p<=26 bits, sampling a in [1,N) makes the "find a = +-b mod p"
      check O(n) per query, so O(n^2) gcds; and sympy.legendre_symbol at
      ~1.5 ms/call dominated everything.  Both fixed below.

THE MEASUREMENT.  Sample a in [1,N); oracle gives chi_p(a); two samples in
the SAME coset satisfy a = +-b mod p, giving gcd(a-b, N) = p or q.  Cost is
birthday on a set of size p, i.e. ~sqrt(p) -- the SAME as Pollard rho.  The
analytic claim under test is that knowing Z_p* is CYCLIC OF KNOWN ORDER lets
the oracle beat that.  If the measured oracle/rho ratio is ~1.0, the oracle
adds nothing and the direction is closed.

LEGALITY OF SAMPLE RANGE: sampling in [1,p) instead would make a = +-b mod p
degenerate (both are then literally p-a).  [1,N) keeps it a genuine
birthday; that is why the cost is sqrt(p) and not O(1).

NEGATIVE CONTROL: rho must actually factor.  If it does not, the timing
means nothing.
"""
import json, math, random, time
from math import gcd
import sympy
from common112 import gen_semiprime, verified_factor


def legendre(a, p):
    """(a/p) by Euler's criterion.  ~1000x faster than sympy's."""
    r = pow(a % p, (p - 1) // 2, p)
    return -1 if r == p - 1 else (1 if r == 1 else 0)


def oracle_arm(N, p, q, budget, rng):
    seen = {1: [], -1: []}
    for i in range(budget):
        a = rng.randrange(2, N)
        ch = seen[legendre(a, p)]
        for b in ch:
            g = gcd(a - b, N)
            if verified_factor(N, p, q, g):
                return i + 1, g
        ch.append(a)
    return None, None


def rho_arm(N, p, q, budget, rng):
    c = rng.randrange(1, N)
    x = y = rng.randrange(2, N)
    for i in range(budget):
        x = (x * x + c) % N
        y = (y * y + c) % N
        y = (y * y + c) % N
        d = gcd(x - y, N)
        if verified_factor(N, p, q, d):
            return i + 1, d
    return None, None


def main():
    rng0 = random.Random(99)
    p0 = next(x for x in range(1000, 3000) if sympy.isprime(x))
    # SANITY-CHECK DEFECT FIXED: the first version drew a FRESH random value
    # for the oracle and another for sympy, so it compared two DIFFERENT
    # Legendre symbols and reported 103/200 "mismatches".  The oracle was
    # never wrong.  Now the SAME value goes to both, and a second independent
    # brute-force count is also asserted.
    probes = [rng0.randrange(2, p0) for _ in range(300)]
    bad = sum(1 for aa in probes
              if legendre(aa, p0) != int(sympy.legendre_symbol(aa, p0)))
    cnt_mine = sum(1 for a in range(1, p0) if legendre(a, p0) == 1)
    cnt_sym = sum(1 for a in range(1, p0)
                  if int(sympy.legendre_symbol(a, p0)) == 1)
    print("legendre sanity: %d/300 mismatches (same value both sides); "
          "residue count mine=%d sympy=%d" % (bad, cnt_mine, cnt_sym),
          flush=True)
    assert bad == 0 and cnt_mine == cnt_sym, "Legendre oracle is WRONG"
    out = dict(cells=[], legnote="Euler criterion; 300/300 and brute-force "
                                 "count agree with sympy")
    import os
    base = int(os.environ.get('B_SEED0', '1'))
    for bits_p, seed in [(bp, base + 2 * k)
                         for bp in (14, 16, 18) for k in range(4)]:
        rng = random.Random(seed)
        p, q, N = gen_semiprime(2 * bits_p, seed, beta=0.5)
        assert p * q == N and p.bit_length() == bits_p
        sp = math.isqrt(p)
        budget = 8 * sp
        t0 = time.time()
        qo, fo = oracle_arm(N, p, q, budget, rng)
        t1 = time.time()
        qr, fr = rho_arm(N, p, q, budget, rng)
        t2 = time.time()
        rec = dict(bits_p=bits_p, seed=seed, sqrt_p=sp, budget=budget,
                   oracle_q=qo, oracle_factored=(fo is not None),
                   rho_steps=qr, rho_factored=(fr is not None),
                   ratio=round(qo / qr, 3) if (qo and qr) else None,
                   oracle_s=round(t1 - t0, 2), rho_s=round(t2 - t1, 2))
        out["cells"].append(rec)
        print("p=%2d bits seed=%d: oracle %-5s q=%-6s | rho %-5s steps=%-6s "
              "| ratio %s" % (bits_p, seed, fo is not None, qo,
                              fr is not None, qr, rec["ratio"]), flush=True)
    ok = sum(1 for c in out["cells"]
             if c["rho_factored"] and c["oracle_factored"])
    out["both_arms_fired"] = ok
    out["n_cells"] = len(out["cells"])
    print("both arms fired in %d/%d cells" % (ok, len(out["cells"])))
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_B2_oracle_s%d.json" % base)
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
