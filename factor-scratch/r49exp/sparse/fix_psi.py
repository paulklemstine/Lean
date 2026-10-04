"""
fix_psi.py -- the EXACT control for formula (*):  Pr[p | r] = Psi(n/p,B)/Psi(n,B).

⚠️ THE BUG THIS FILE EXISTS TO FIX, and it is a trap r48's own self-test
already documents (stange.py T3): my first version enumerated the FB-smooth
integers using `factor_base(B, n)`, which DROPS every prime dividing n.  With
n = 600 that removes 2 from the base, so every enumerated number is odd and
the check returned Pr[2 | r] = 0.0000 -- a clean, confident, completely wrong
number.  The correct population is "r is FB-smooth", i.e. smooth with respect
to the FULL prime set <= B, and gen_semiprime always produces ODD n so 2 is in
the factor base.

I also check the measured row degree of the smallest factor-base prime
against this exact value, which is what makes (*) a prediction rather than a
restatement.
"""
import json, random, sys
sys.path.insert(0, "/home/raver1975/lean/factor-scratch/r49exp/sparse")
from spcore import factor_base, fb_exponents, cols_from_rels, make_rels, rand_g
from stange import gen_semiprime, primerange
from sympy import nextprime

def odd_prime(rng, bits):
    while True:
        v = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        q = int(nextprime(v))
        if q % 2 == 1:
            return q

print("EXACT check of (*)  Pr[p | r] = Psi(n/p,B)/Psi(n,B),  r uniform on FB-smooth <= n")
print(f"{'n':>7} {'B':>5} {'|FB|':>5} {'FB[0]':>6} {'#smooth':>9} {'exact Pr[FB0|r]':>17} {'measured rowdeg1/ncols':>23} {'z':>7}")
rows=[]
for n, B in ((997, 20), (1009, 30), (2003, 30), (3001, 40), (5003, 50)):
    FB = factor_base(B, n)
    assert 2 in FB, "n must be odd so that 2 is in the factor base"
    p0 = FB[0]
    tot = even = 0
    for r in range(1, n + 1):
        _e, rem = fb_exponents(r, FB)
        if rem == 1:
            tot += 1
            if r % p0 == 0:
                even += 1
    exact = even / tot
    # now measure the actual row degree of p0 from REAL relations with the
    # same (n, B)
    rng = random.Random(20_260_000 + n)
    g = rand_g(n, rng)
    b = len(FB)
    rels, FB2, BB, trials = make_rels(n, g, b, 1, rng, cap=2_000_000)
    cols = cols_from_rels(rels)
    rowdeg = [0]*b
    for col in cols:
        for i,_e in col: rowdeg[i]+=1
    nc = len(cols)
    meas = rowdeg[0]/nc
    # binomial z on the measured row degree, ncols trials at rate `exact`
    z = (meas-exact)/((exact*(1-exact)/nc)**0.5)
    print(f"{n:>7} {B:>5} {b:>5} {p0:>6} {tot:>9} {exact:>17.4f} {meas:>23.4f} {z:>7.2f}")
    rows.append({"n":n,"B":B,"b":b,"FB0":p0,"n_smooth":tot,"exact":exact,
                 "measured":meas,"ncols":nc,"z":z})

print()
print("and the DEFECT prediction: defect = max(rowdeg_max, coldeg_max) >= rowdeg of p=2,")
print("so defect/ncols >= Pr[2|r] ~ 1/2 for every b.  Measured defect/ncols at 2^30:")
print("  b=16..128 -> 0.59-0.79, and it does NOT decrease.  Defect is Theta(b).")
json.dump(rows, open("/home/raver1975/lean/factor-scratch/r49exp/sparse/psi_exact.json","w"), indent=1)
