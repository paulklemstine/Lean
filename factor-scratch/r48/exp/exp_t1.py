"""T1 -- is any STRUCTURED leakage of p strictly below 1/2 of its bits?

Prediction stated before measuring: for the MSB and LSB models the answer is
no and the break sits at Coppersmith's N^{1/4} interval, i.e. exactly 50% of
the bits of p.  For a residue class p mod ell the leak is worth ell-1 bits of
p but the effective unknown is (p - (p mod ell))/ell, so the lattice sees a
SAME-width unknown as if those bits were the low ones -- no gain.  For p - q
the recovery is a closed form and never was a lattice problem.

For every model we report the EMPIRICAL break: the largest leaked-bit count
at which the lattice still returns p, and the smallest at which it does not,
so the boundary is bracketed at the bit, not asserted.
"""
import sys
import time

from control import make_instance
from coppersmith import univariate_small_roots, poly_eval
from rsa_instances import leak_top_bits, leak_low_bits, leak_p_minus_q


def attack(model, N):
    """Run the Coppersmith grid on a leakage model.  Returns (ok, info)."""
    if model is None:
        return False, {"err": "budget not representable"}
    f = model["f"]
    X = model["X"]
    t0 = time.time()
    roots, diag = univariate_small_roots(f, N, X, mod_is_factor=True,
                                         cross_check=False)
    ok = False
    for r in roots:
        v = poly_eval(f, r)
        if v and N % v == 0:
            ok = True
            break
    return ok, {"diag": diag, "secs": round(time.time() - t0, 2),
                "X_log2": X.bit_length() - 1}


def main():
    bits = 128
    seeds = [1, 2, 3]
    print("=" * 78)
    print("T1: structured leakage of p -- empirical break, %d-bit N" % bits)
    print("=" * 78)
    print("'leak' is the fraction of p's BITS revealed.  Coppersmith's")
    print("interval N^{1/4} = 2^{nb(N)/4} = 2^%d corresponds to leaving" % (bits // 4))
    print("2^%d unknown, i.e. leaking 50% of p's bits, and the inequality" % (bits // 4))
    print("is STRICT, so exactly 50% is the boundary and needs +1 bit.")
    print()

    for name, builder in (("MSB (top bits)", leak_top_bits),
                          ("LSB (low bits)", leak_low_bits)):
        print("--- model: %s ---" % name)
        print("  bits leaked (of 64)    per-seed success (seeds %s)   verdict"
              % seeds)
        results = {}
        fracs = [0.90, 0.75, 0.625, 0.5625, 0.53125, 0.515625,
                 0.50, 0.4844, 0.4688, 0.4375, 0.375, 0.25]
        for frac in fracs:
            row = []
            kused = None
            for seed in seeds:
                inst = make_instance(bits, seed)
                p, q, N = inst
                k = int(p.bit_length() * frac)
                kused = k
                model = builder(inst, k)
                ok, info = attack(model, N)
                row.append(ok)
            n_ok = sum(row)
            results[frac] = n_ok
            print("    %5.3f  (%3d bits)          %s   %s" % (
                frac, kused, " ".join("Y" if r else "." for r in row),
                "succeeds" if n_ok == len(seeds) else
                ("mixed" if n_ok else "FAILS on all")))
        works = [f for f in sorted(results, reverse=True) if results[f] == len(seeds)]
        fails = [f for f in sorted(results) if results[f] == 0]
        if works and fails:
            best = max(works)
            worst = min(fails)
            print("  => highest leaking fraction that ALWAYS works: %.4f (%d bits)"
                  % (best, int(64 * best)))
            print("  => lowest  leaking fraction that ALWAYS fails : %.4f (%d bits)"
                  % (worst, int(64 * worst)))
            print("  => EMPIRICAL BREAK BRACKETED IN (%.4f, %.4f) of p's bits"
                  % (worst, best))
            print("  => in bits: is any threshold BELOW 1/2 of p's bits? %s"
                  % ("NO -- break sits AT 1/2 (the Coppersmith bound)"
                     if worst >= 0.5 else "YES -- strictly below 1/2"))
        print()

    # p - q: closed form, no lattice
    inst = make_instance(bits, 1)
    m = leak_p_minus_q(inst, 0)
    print("--- model: p - q known ---")
    print("  closed-form recovery works: %s  (p = (sqrt(d^2+4N)+d)/2)"
          % m["recovered"])
    print("  This is arithmetic, not a lattice attack: it needs NO bits of p")
    print("  at all, so it is not a threshold below 1/2 but the opposite case")
    print("  -- the leak determines p outright.")


if __name__ == "__main__":
    sys.exit(main())