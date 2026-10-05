"""(a) MULTIPLIER u: does working mod u*N enlarge the recoverable region?

DESIGN FIX vs the first attempt: x0 = p mod 2^k is a GENUINE ~k-bit target
(the first attempt used unk=8, so x0 was 53 bits and every X trivially won --
exactly the vacuous-evidence trap).  We report RATES over >=12 seeds at each k.

FALSIFIER: if rate(u=1,k) >= rate(u,k) for all u>1 and all k, the multiplier
cannot enlarge the region, and the theoretical mechanism is the beta shrink:
    X_ceiling(u) = (n/4) * n/(n+w),  w = log2(u)   [strictly SMALLER than n/4]
"""
import sys, json, math, time
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r113/aux-amplifiers")
from core import make_instance, attack, verified_factor

SEEDS = list(range(1, 13))
PBITS = 128
M, T = 6, 12
KS = list(range(54, 69))


def trial(u, sd, k):
    p, q, N = make_instance(PBITS, sd)
    x0 = p % (1 << k)
    a = p - x0
    X = 1 << k
    Mod = u * N
    roots, _ = attack(a, Mod, X, m=M, t=T)
    return any(verified_factor(N, a + r) for r in roots), x0.bit_length()


def cell(u, k):
    hits, bl = 0, []
    for sd in SEEDS:
        g, b = trial(u, sd, k)
        hits += g
        bl.append(b)
    return hits / len(SEEDS), sum(bl) / len(bl)


def main():
    p, q, N = make_instance(PBITS, 1)
    n = N.bit_length()
    US = [1, 2, 4, 16, 256, 65536, 1 << 20]
    out = {"n": n, "pbits": PBITS, "seeds": len(SEEDS), "plain_ceiling_n_over_4": n / 4,
           "rows": []}

    # POSITIVE CONTROL: k well below the ceiling must succeed.
    r_lo, _ = cell(1, 50)
    print(f"POSITIVE CONTROL u=1 k=50: rate={r_lo:.2f} (must be ~1.0)", flush=True)
    # LEAK CONTROL: wrong instance's a must never recover.
    pA, _, NA = make_instance(PBITS, 3)
    pB, _, _ = make_instance(PBITS, 999)
    x0 = pA % (1 << 60); aW = pA - x0
    roots, _ = attack(aW, pB * (NA // pA) if False else NA, 1 << 60, m=M, t=T)
    lk = any(verified_factor(NA, aW + r) for r in roots)
    print(f"LEAK CONTROL (a from other instance): recovered={lk} (must be False)", flush=True)

    for u in US:
        w = math.log2(u)
        pred = (n / 4.0) * n / (n + w)
        row = []
        for k in KS:
            r, bl = cell(u, k)
            row.append((k, round(r, 3)))
        print(f"u={u:<8} w={w:<6.2f} pred_ceiling={pred:7.3f}  " +
              " ".join(f"k{k}:{r:.2f}" for k, r in row), flush=True)
        out["rows"].append(dict(u=u, w=w, pred_ceiling=pred, rates=row))

    json.dump(out, open("out_a_mult2.json", "w"), indent=1)
    print("wrote out_a_mult2.json")


if __name__ == "__main__":
    main()
