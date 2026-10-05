"""(b) KNOWING HIGH BITS OF BOTH p AND q -- exact interval arithmetic + real attack.

PARAMETERISATION: k = number of UNKNOWN LOW bits (x0 = p mod 2^k, a ~k bits).
So knowing "high bits of p to precision k" == k unknown low bits. Consistent
with part (a), where the plain ceiling was ~59-60 unknown low bits at n=256.

THEORY (derived in THEORY.md, not cited):
   p-leak of kp bits  =>  p in interval of width 2^kp.
   q-leak of kq bits  =>  q in [b, b+2^kq)  =>  p = N/q in an interval of
       width  N*2^kq/b^2  ~  2^kq * (p/q).
   JOINT effective precision on p = min(kp, kq*(p/q))  -- exact interval arithmetic.
   => the two-factor leak is worth EXACTLY the better single leak, NEVER more.

FALSIFIER: any (kp,kq) whose joint effective precision is strictly better than
min(kp, kq*p/q), or any bivariate attack recovering at a k where univariate does not.
"""
import sys, json, math
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r113/aux-amplifiers")
from core import make_instance, attack, verified_factor

SEEDS = list(range(1, 13))
PBITS = 128


def intervals(p, q, N, kp, kq):
    """Exact p-interval implied by each leak, and their intersection."""
    a = (p >> kp) << kp                       # p in [a, a+2^kp)
    p_lo, p_hi = a, a + (1 << kp) - 1
    b = (q >> kq) << kq                       # q in [b, b+2^kq)
    q_lo, q_hi = b, b + (1 << kq) - 1
    # p = N/q  =>  p in (N/q_hi, N/q_lo]  (integer endpoints)
    p2_lo = N // q_hi + 1
    p2_hi = N // q_lo
    lo, hi = max(p_lo, p2_lo), min(p_hi, p2_hi)
    return lo, hi, (hi - lo + 1), (1 << kp), q_hi - q_lo + 1


def t1_exact():
    """Exact (no sampling): is q's leak implied by p's leak?"""
    rows = []
    for kp in [40, 48, 56]:
        for kq in [kp - 8, kp - 4, kp, kp + 4, kp + 8, kp + 16]:
            det = 0
            for sd in SEEDS:
                p, q, N = make_instance(PBITS, sd)
                a = (p >> kp) << kp
                # q consistent with p in [a, a+2^kp):
                q_lo, q_hi = N // (a + (1 << kp)), N // a
                # q's top bits (kq unknown low bits) determined iff q_lo,q_hi agree
                if (q_lo >> kq) == (q_hi >> kq) and (q >> kq) == (q_hi >> kq):
                    det += 1
            rows.append(dict(kp=kp, kq=kq, determined=det / len(SEEDS)))
            print(f"T1 p-leak {kp:3d} unk bits -> q-leak {kq:3d} unk bits determined "
                  f"{det/len(SEEDS):.2f}", flush=True)
    return rows


def t2_joint():
    """Exact joint precision vs the min(kp, kq*p/q) prediction."""
    rows = []
    for (kp, kq) in [(56, 40), (56, 56), (56, 72), (60, 56), (60, 60),
                     (60, 72), (60, 80), (64, 60)]:
        exact_log2, pred_log2 = [], []
        for sd in SEEDS:
            p, q, N = make_instance(PBITS, sd)
            lo, hi, width, w1, w2 = intervals(p, q, N, kp, kq)
            assert lo <= hi and lo <= p <= hi, "true p must survive the joint interval"
            exact_log2.append(math.log2(width))
            pred_log2.append(min(kp, kq + math.log2(p / q)))
        e, pr = sum(exact_log2) / 12, sum(pred_log2) / 12
        rows.append(dict(kp=kp, kq=kq, exact_log2_width=round(e, 3),
                         pred_log2=round(pr, 3)))
        print(f"T2 kp={kp} kq={kq}  exact joint width 2^{e:6.2f}  "
              f"predicted min(kp, kq+log2(p/q)) = 2^{pr:6.2f}", flush=True)
    return rows


def t3_attack():
    """Attack test: does ADDING the q-leak ever recover where univariate fails?

    Fix kp at the univariate boundary and sweep kq.  If the q-leak amplified,
    some kq would push the rate up.  Univariate baseline on the SAME instances.
    """
    from fpylll import IntegerMatrix, LLL
    rows = []
    for kp in [58, 59, 60]:
        for kq in [0, 40, 60, 80, 100]:
            uni = both = 0
            for sd in SEEDS:
                p, q, N = make_instance(PBITS, sd)
                x0 = p % (1 << kp); a = p - x0
                r, _ = attack(a, N, 1 << kp, m=6, t=12)
                if any(verified_factor(N, a + z) for z in r):
                    uni += 1
                # "both" leak: the pair (kp,kq) is used ONLY through the joint
                # interval; the honest test is whether the joint interval is ever
                # narrower than the p-interval alone in a way that changes the attack.
                lo, hi, width, w1, w2 = intervals(p, q, N, kp, kq)
                # attack with the sharpened offset: re-centre a on the joint lower bound
                a2 = lo
                r2, _ = attack(a2, N, 1 << kp, m=6, t=12)
                if any(verified_factor(N, a2 + z) for z in r2):
                    both += 1
            print(f"T3 kp={kp} kq={kq:3d}  univariate {uni/len(SEEDS):.2f}   "
                  f"+q-leak(sharpened) {both/len(SEEDS):.2f}", flush=True)
            rows.append(dict(kp=kp, kq=kq, uni=uni / len(SEEDS), both=both / len(SEEDS)))
    return rows


if __name__ == "__main__":
    out = {}
    out["T1"] = t1_exact()
    out["T2"] = t2_joint()
    out["T3"] = t3_attack()
    json.dump(out, open("out_b_both2.json", "w"), indent=1)
    print("wrote out_b_both2.json")
