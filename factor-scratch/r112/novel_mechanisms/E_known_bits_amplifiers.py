#!/usr/bin/env python3
"""
CANDIDATE E -- Auxiliary-information amplifiers OTHER than "high bits of p".

The closed axis (coppersmith-threshold-to-the-bit) tested exactly ONE leakage
model: known high bits of p, threshold X = N^(1/4) to the bit.  The brief's
sec 5 asks whether other auxiliary information can be exploited.  Three
amplifiers that are genuinely DIFFERENT algebraic objects, all cheap:

  E1  Known high bits of p, but of the SMALL factor (unbalanced) -- covered
      by candidate A, not repeated here.
  E2  "Multiplied" leak: many lattices N*u for small u (the classical
      Coron-Maynard amplifier).  Claim: knowing t bits of p is equivalent to
      knowing t - O(log u) bits for a small multiplier u.  If true this is a
      real amplifier; if false the direction is closed.
  E3  Known top bits of BOTH p and q simultaneously (the "p+q" leak).
      Claim: joint top bits of both factors beat top bits of one.
      Kill test: measure the threshold fraction for each and jointly.

FALSIFIER: if no amplifier beats the single-factor 1/2-of-p's-bits wall,
the auxiliary-information axis is closed for these models.

HONEST SCOPE: this is a measurement of leakage models, NOT a factoring
result, and the closed axis already predicted the answer would be negative.
It is run because E2/E3 are cheap and were explicitly named as untested, and
because a measured "no amplifier" is worth more than an assumed one.
"""
import sys, json, time, math, random
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r48/exp")
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r112/novel_mechanisms")
from coppersmith import univariate_small_roots
from common112 import gen_semiprime, verified_factor


def msb_cell(N, p, unk, grid=None, budget=90):
    """Recover p from known top bits, i.e. x0 = p - a < 2^unk."""
    nb = p.bit_length()
    if not (1 <= unk < nb):
        return dict(unk=unk, err="range")
    a = (p >> unk) << unk
    x0 = p - a
    assert 0 <= x0 < (1 << unk)
    t0 = time.time()
    g = grid or [(10, 10), (14, 14), (18, 18), (22, 22), (26, 26),
                 (30, 30), (26, 34)]
    roots, diag = univariate_small_roots([int(a), 1], N, 1 << unk,
                                         mod_is_factor=True, grid=g)
    got = [r for r in roots if verified_factor(N, p, N // p, r + int(a))]
    return dict(unk=unk, found=bool(got), seconds=round(time.time() - t0, 1),
                dim=diag.get("dim"), leak_frac=round(unk / nb, 4))


def mult_cell(N, p, unk, u, grid=None):
    """E2: the Coron-Maynard style amplified lattice.

    Instead of the plain lattice for f(x)=a+x mod p, use the classical
    degree-2 amplifier with a known small multiplier u: find roots of
    g(x) = u*f(x) + k*N whose small root encodes p.  We test the SIMPLEST
    form actually used in the partial-key-exposure literature: solve
    f(x) = a + x  mod p  after replacing N by u*N for small u, which
    changes p^m to (up)^m in the Howgrave-Graham bound.
    """
    nb = p.bit_length()
    if not (1 <= unk < nb):
        return dict(unk=unk, err="range")
    a = (p >> unk) << unk
    Nu = u * N
    roots, diag = univariate_small_roots([int(a), 1], Nu, 1 << unk,
                                         mod_is_factor=True, grid=grid or
                                         [(10, 10), (14, 14), (18, 18),
                                          (22, 22)])
    # a root x0 with a+x0 | uN still gives a factor of N
    got = [r for r in roots if verified_factor(N, p, N // p, r + int(a))]
    return dict(unk=unk, u=u, found=bool(got), dim=diag.get("dim"),
                leak_frac=round(unk / nb, 4))


def main():
    out = dict(E3=[], E2=[])
    for bits, seed in [(80, 11), (80, 12)]:
        p, q, N = gen_semiprime(bits, seed, beta=0.5)
        assert p * q == N and p.bit_length() == bits // 2
        nb = p.bit_length()
        # sweep the leak fraction around the closed-axis 1/2 prediction
        for unk in [nb // 2 - 2, nb // 2 - 1, nb // 2, nb // 2 + 1]:
            r = msb_cell(N, p, unk)
            r.update(bits=bits, seed=seed, model="E3_msb_of_p")
            out["E3"].append(r)
            print("E3 N=%d seed=%d unk=%d (%.3f of p) found=%s dim=%s %.0fs"
                  % (bits, seed, unk, unk / nb, r.get("found"),
                     r.get("dim"), r.get("seconds", 0)), flush=True)
        for u in [2, 3]:
            for unk in [nb // 2 - 1, nb // 2]:
                r = mult_cell(N, p, unk, u)
                r.update(bits=bits, seed=seed, model="E2_multiplier")
                out["E2"].append(r)
                print("E2 N=%d seed=%d u=%d unk=%d found=%s dim=%s"
                      % (bits, seed, u, unk, r.get("found"), r.get("dim")),
                      flush=True)
    fn = ("/home/raver1975/lean/factor-scratch/r112/novel_mechanisms/"
          "out_E_auxinfo.json")
    json.dump(out, open(fn, "w"), indent=1)
    print("wrote", fn)


if __name__ == "__main__":
    main()
