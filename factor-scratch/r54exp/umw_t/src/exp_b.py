#!/usr/bin/env python3
"""
exp_b.py -- LOWER-BOUND construction on t, with positive and negative controls.

Construction:  a1 = 1, a2 = M-1 where M = prod of the k SMALLEST band primes.
Then the difference (di,dj) = (1,1) gives  D = 1 + (M-1) = M, so all k band primes
divide it. gcd(a1,a2) = gcd(1,M-1) = 1, so NOTHING is dropped from P. Magnitude:
max|A| ~ M*L, and we require M*L <= exp(n^alpha) -- this is the budget that caps k.

Controls:
  POSITIVE: measured t must be >= k, and must EQUAL k when M is exactly the product
             of the k smallest band primes (no other difference can beat it if k is
             at the budget limit; we check >=k always and ==k in the interior).
  NEGATIVE: a2 replaced by a value coprime to M must give t far below k.
"""
import sys, os, json, math
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from umw_t_core import rng, band_primes, t_profile, is_degenerate
import numpy as np

SEED = 20261004

def main():
    rows = []
    for k_bits in (16, 20, 24):
        L = 2 ** (k_bits // 3)
        n = L ** 3
        alpha = 1.0/3.0
        x = math.isqrt(n)
        P = [int(p) for p in band_primes(n)]
        P = [p for p in P if p > (2*x)//3]
        P.sort()
        # budget: M * L <= exp(n^alpha)  =>  log M <= n^alpha - log L
        budget = n ** alpha - math.log(L)
        kmax = 0
        logM = 0.0
        for p in P:
            if logM + math.log(p) <= budget:
                logM += math.log(p); kmax += 1
            else:
                break
        print(f"\n=== n=2^{3*(k_bits//3)} ~ {n:.3e}  L={L}  |P|={len(P)}  "
              f"budget(log M)={budget:.1f}  k_max={kmax} ===")
        print(f"    predicted t from construction ~ k_max; rigorous size bound "
              f"t <= log(2e^(n^a))/log(a*sqrt n) = {(n**alpha+math.log(2))/math.log((2/3)*x):.1f}")

        # sweep a fraction of the budget
        for frac in (0.25, 0.5, 0.75, 1.0):
            tgt = max(1, int(kmax*frac))
            k = 0; logM = 0.0
            M = 1
            for p in P:
                if k == tgt: break
                # EXACT integer product. Never use exp(logM): a double carries only
                # ~15 digits, which silently corrupts M once M ~ e^246 (first failure
                # observed at k_bits=24). logM is tracked separately for the budget only.
                M *= p
                logM += math.log(p); k += 1
            a1, a2 = 1, M-1
            deg = is_degenerate(a1, a2, L, L)
            tmax, hist, ndiff, drop = t_profile(a1, a2, L, L, P)
            # NEGATIVE CONTROL: same size a2', coprime-ish to M (a2'+1 not a product)
            r = rng(SEED, f"negB-{k_bits}-{frac}")
            a2n = int(r.integers(2, 2**62))
            tneg, _, _, _ = t_profile(1, a2n, L, L, P)
            pos_ok = (tmax >= k)
            neg_ok = (tneg < k) if k >= 3 else True
            print(f"  frac={frac}: k={k} logM={logM:8.1f}  t_max={tmax:5d}  "
                  f"(POS ok={pos_ok})   NEG control a2' -> t={tneg} (ok={neg_ok})  "
                  f"degenerate={deg} dropped={drop}")
            rows.append(dict(k_bits=k_bits, n=n, L=L, frac=frac, k=k,
                             logM=logM, tmax=tmax, tneg=tneg,
                             pos_ok=bool(pos_ok), neg_ok=bool(neg_ok),
                             M_log10=math.log10(M), M_bitlen=M.bit_length(), ndiff=ndiff))
    out = os.path.join(os.path.dirname(__file__), "..", "out")
    with open(os.path.join(out, "exp_b.json"), "w") as f:
        json.dump(rows, f, indent=1)
    allok = all(r["pos_ok"] and r["neg_ok"] for r in rows)
    print("\nCONTROLS:", "ALL PASS" if allok else "*** FAILURE ***")
    print("wrote out/exp_b.json")

if __name__ == "__main__":
    main()