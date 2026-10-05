"""(a) The Coron-Maynard MULTIPLIER: does working mod u*N enlarge the recoverable region?

Hypothesis under test: X_ceiling(u) > X_ceiling(1) for some u > 1.
Prediction derived in THEORY.md: X_ceiling(u) = (n/4)*n/(n+w), w=log2(u)  ->  STRICTLY SMALLER.
Per-seed binary search on log2(X) gives the achieved ceiling; >=12 seeds per u.
Every success is checked by multiplying back to N.
"""
import sys, json, math, time
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r113/aux-amplifiers")
from core import make_instance, attack, verified_factor

SEEDS = list(range(1, 13))          # 12 seeds
PBITS = 128                          # |p| = |q| = 128 bits  (>> 2^40, generic factoring hopeless)
M, T = 6, 12


def succeeds(p, q, N, a, ybits):
    """Try X = floor(2^ybits).  Returns (ok, ceiling_of_candidate)."""
    if ybits >= p.bit_length():
        return False, None
    X = int(2.0 ** ybits)
    if X < 1:
        return False, None
    x0 = p - a
    if x0 >= X:
        return False, None
    roots, _ = attack(a, N, X, m=M, t=T)
    for r in roots:
        cand = a + r
        if verified_factor(N, cand):
            return True, cand
    return False, None


def ceiling_for(p, q, N, a, lo, hi, tol=0.05):
    """Binary search the achieved log2(X) ceiling.  Success monotone decreasing in y."""
    assert succeeds(p, q, N, a, lo)[0], "positive control failed at lo"
    if succeeds(p, q, N, a, hi)[0]:
        return hi
    while hi - lo > tol:
        mid = (lo + hi) / 2.0
        if succeeds(p, q, N, a, mid)[0]:
            lo = mid
        else:
            hi = mid
    return lo


def main():
    p, q, N = make_instance(PBITS, SEEDS[0])
    n = N.bit_length()
    lo, hi = n / 4.0 - 6.0, n / 4.0 + 1.0        # search window in log2(X) bits
    out = []
    US = [1, 2, 3, 5, 7, 16, 256, 65536, 1 << 20]
    print(f"PBITS={PBITS} n={n} plain ceiling n/4={n/4:.3f} window=[{lo},{hi}]", flush=True)

    # POSITIVE CONTROL: harness must fire at a point where we know it is present.
    p, q, N = make_instance(PBITS, SEEDS[0])
    a = (p >> 8) << 8
    okc, _ = succeeds(p, q, N, a, lo)
    print(f"POSITIVE CONTROL (u=1, y={lo}, x0 tiny): success={okc}", flush=True)
    # LEAK CONTROL: a taken from an UNRELATED instance must NOT recover p.
    _, _, N2 = make_instance(PBITS, 999)
    p3, _, _ = make_instance(PBITS, 777)
    a_leak = (p3 >> 8) << 8
    okl, _ = succeeds(p3, None, N, a_leak, n / 4.0 - 1.0)
    print(f"LEAK CONTROL (wrong a vs N, y=n/4-1): success={okl} (must be False)", flush=True)

    for u in US:
        w = math.log2(u)
        pred = (n / 4.0) * n / (n + w)
        ceil = []
        for sd in SEEDS:
            p, q, N = make_instance(PBITS, sd)
            a = (p >> 8) << 8
            Mmod = u * N
            # attack on the ENLARGED modulus; factor still verified against N
            X_lo = int(2.0 ** lo); X_hi = int(2.0 ** hi)

            def suc(y):
                if y >= p.bit_length():
                    return False
                X = int(2.0 ** y)
                if x0_ge(a, p, X):
                    return False
                roots, _ = attack(a, Mmod, X, m=M, t=T)
                return any(verified_factor(N, a + r) for r in roots)

            a_, b_ = lo, hi
            assert suc(a_), f"positive control failed u={u} seed={sd}"
            if not suc(b_):
                while b_ - a_ > 0.05:
                    mid = (a_ + b_) / 2.0
                    if suc(mid):
                        a_ = mid
                    else:
                        b_ = mid
                ceil.append(a_)
            else:
                ceil.append(b_)
        mean_c = sum(ceil) / len(ceil)
        out.append(dict(u=u, w=round(w, 3), pred_ceiling=round(pred, 4),
                        mean_ceiling=round(mean_c, 4), n=len(ceil),
                        per_seed=[round(c, 3) for c in ceil],
                        loss_vs_pred=round(pred - mean_c, 4)))
        print(f"u={u:<9} w={w:<7.3f} pred={pred:8.4f} achieved={mean_c:8.4f} "
              f"(pred-ach={pred-mean_c:+.4f}) seeds={len(ceil)}", flush=True)

    json.dump(out, open("out_a_mult.json", "w"), indent=1)
    print("wrote out_a_mult.json")


def x0_ge(a, p, X):
    return (p - a) >= X


if __name__ == "__main__":
    main()
