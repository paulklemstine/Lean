#!/usr/bin/env python3
"""
E2: does improving the BSGS row (row 1) move Harvey's exponent AT ALL?

The five cost terms of Harvey Alg 4.3, as exponents of N (logs suppressed),
with the screening range M := (N/r)^{1/2} forced by Lemma 3.3's hypothesis (3.1):

    (1) screen      (N/r)^{1/4}      <- Prop 2.5 at M=(N/r)^{1/2}, cost M^{1/2}
    (2) pairs       r                <- #{(a,b) : 1<=ab<=r} is Theta(r lg r)
    (3) interior    N^{1/2}/(r^{1/2} m)
    (4) m-floor     m
    (5) large-order fixed, = N^{1/5}, not an optimisation variable

Row 1 = {(2),(3),(4)}  (the corpus's model).  Row 2 = {(1),(2)} (the corpus's model
omits it entirely).  Note (2) is SHARED between the rows.

PREDICTIONS (stated before running):
  P6  Baseline (a=1/2, b=1, i.e. Sigma w = 3/2): total optimum = 1/5.
  P7  If row 1 is improved to ANY weight with 1+a+b > 3/2, the TOTAL optimum
      stays EXACTLY 1/5. Row 2 does not move. This is the closure.
  P8  NEGATIVE CONTROL for the closure: if row 2 is ALSO improved (a faster
      small-factor screen, cost M^theta with theta<1/2), the total DOES drop
      below 1/5. So the closure is specific, not an artefact of the model.
  P9  The corpus's predicted threshold (Sigma w = 2 => 1/6) is NOT attained
      when only row 1 is improved. Report the gap.
  P10 EMPIRICAL: on locally generated semiprimes (n < 2^40), the pair count
      #(1<=ab<=r) grows like r^1 * lg r (exponent 1.0), and the candidate count
      grows like N^{1/2} r^{-1/2} (exponent -1/2). Confirms weights 1 and -1/2.
"""
from fractions import Fraction as F
import math, random
from sympy import isprime, nextprime, factorint

random.seed(20261004)


def total_exponent(r_exp, m_exp, a=F(1, 2), b=F(1), theta=F(1, 2)):
    """Total N-exponent of Harvey Alg 4.3 given log_N r, log_N m, row-1 weights
    (a on r, b on m), and screen exponent theta (screen cost M^theta, M=(N/r)^{1/2}).

    BUG HISTORY (recorded, not hidden): the first draft wrote
        screen = theta/2 - theta*r_exp
    which is WRONG.  M = (N/r)^{1/2} = N^{(1-rx)/2}, so M^theta = N^{theta(1-rx)/2},
    i.e. screen = theta/2 - (theta/2)*rx.  The erroneous version gives a screen
    of N^{1/4 - rx/2} whose optimum is 1/6, which would have made the closure
    claim FALSE.  Caught by cross-checking against exp_balance.py, which had
    the correct (1-r_exp)/4 form.  exp_closure is now cross-validated against
    exp_balance by an explicit assert at the Harvey setting.
    """
    screen = F(theta, 2) - F(theta, 2) * r_exp   # = theta*(1-rx)/2
    pairs = F(r_exp)
    interior = F(1, 2) - F(a) * r_exp - F(b) * m_exp
    m_floor = F(m_exp)
    t = {"screen": screen, "pairs": pairs, "interior": interior, "m_floor": m_floor}
    return max(t.values()), t


def optimise(a, b, theta, grid=600):
    """Minimise the total exponent over (r_exp, m_exp) on a rational grid.

    Domain is r_exp, m_exp in (0, 1/2]: the true optimum sits at 1/5, so a grid
    capped at 1/10 (the first draft's bug) SILENTLY EXCLUDES the optimum and
    returns a larger, wrong value.
    """
    best = None
    for i in range(1, 2 * grid + 1):
        rx = F(i, 2 * grid)
        for j in range(1, 2 * grid + 1):
            mx = F(j, 2 * grid)
            v, terms = total_exponent(rx, mx, a, b, theta)
            if best is None or v < best[0]:
                best = (v, rx, mx, terms)
    return best


def row1_optimum(a, b):
    """Corpus row-1 prediction: gamma/(1+Sum w) with gamma=1/2."""
    return F(1, 2) / (1 + F(a) + F(b))


def row2_optimum(theta):
    """Row-2 optimum: max(r, (N/r)^{theta/2}) -> (theta/2)/(1 + theta/2)."""
    return (F(theta, 2)) / (1 + F(theta, 2))


# --- cross-validation against the independent exp_balance model -------------
_v, _terms = total_exponent(F(1, 5), F(1, 5))
assert _v == F(1, 5), f"cross-validation FAILED: {_v} != 1/5"
# All FOUR N-terms tie at 1/5: (N/r)^{1/4} = N^{1/4-1/20} = N^{1/5}, pairs = N^{1/5},
# interior = N^{1/2-1/10-1/5} = N^{1/5}, m = N^{1/5}.  (A first draft of this assert
# wrongly expected `screen` to be strictly below; it is co-binding, and this agrees
# with exp_balance.py's independent Fraction model.)
assert sorted(k for k, x in _terms.items() if x == F(1, 5)) == \
    ["interior", "m_floor", "pairs", "screen"], _terms
print("cross-validation vs exp_balance: PASS (all four N-terms tie at 1/5)")


print("=" * 78)
print("P6/P7 : CLOSURE -- improving row 1 leaves the total at 1/5")
print("=" * 78)
print(f"  {'a':>5s} {'b':>5s} {'Sum w':>6s} | {'row1 pred':>9s} | "
      f"{'row2':>6s} | {'TOTAL':>7s} | {'r*':>8s} {'m*':>8s} | binding")
print("  " + "-" * 76)
rows = [(F(1,2), F(1)),        # Harvey baseline, Sigma w = 3/2
        (F(1,2), F(3,2)),      # Sigma w = 2  -> corpus says 1/6
        (F(3,4), F(5,4)),      # Sigma w = 2  (split differently)
        (F(1),   F(1)),        # Sigma w = 2
        (F(1,2), F(2)),        # Sigma w = 5/2 -> corpus says 1/7
        (F(3,4), F(7,4))]      # Sigma w = 5/2
base = None
for (a, b) in rows:
    v, rx, mx, terms = optimise(a, b, F(1, 2))
    binding = sorted(k for k, val in terms.items() if val == v)
    if base is None:
        base = v
    flag = "   <-- STILL 1/5" if v == base else ""
    print(f"  {str(a):>5s} {str(b):>5s} {str(a+b):>6s} | {str(row1_optimum(a,b)):>9s} | "
          f"{str(row2_optimum(F(1,2))):>6s} | {str(v):>7s} | {str(rx):>8s} {str(mx):>8s} | "
          f"{','.join(binding)}{flag}")

print()
print("  Row-2 optimum is CONSTANT at", row2_optimum(F(1, 2)), "for every row-1 weight,")
print("  because row 2 = {screen (N/r)^{1/4}, pairs r} contains no m at all.")
print("  So the total exponent can never fall below 1/5 while row 2 stands.")

print()
print("=" * 78)
print("P8 : NEGATIVE CONTROL -- improve row 2 too, and the total DOES drop")
print("=" * 78)
print(f"  {'theta':>6s} {'row2 pred':>10s} | {'TOTAL at Harvey weights':>24s} | binding")
print("  " + "-" * 60)
for theta in [F(1, 2), F(5, 11), F(2, 5), F(1, 3), F(1, 4)]:
    v, rx, mx, terms = optimise(F(1, 2), F(1), theta)
    binding = sorted(k for k, val in terms.items() if val == v)
    print(f"  {str(theta):>6s} {str(row2_optimum(theta)):>10s} | {str(v):>24s} | "
          f"{','.join(binding)}")
print()
print("  theta = 1/2 is Strassen. Smaller theta = a faster small-factor screen.")
print("  The closure in P7 is therefore SPECIFIC to row 2, not a modelling artefact.")

print()
print("=" * 78)
print("P9 : the gap against the corpus's 1/6 claim")
print("=" * 78)
v_base, *_ = optimise(F(1, 2), F(1), F(1, 2))
v_2, rx, mx, terms = optimise(F(1, 2), F(3, 2), F(1, 2))
print(f"  corpus claims  Sigma w = 2  =>  exponent 1/6 = {F(1,6)}")
print(f"  actual total at Sigma w = 2, Strassen screen:  {v_2}")
print(f"  binding terms: {sorted(k for k,val in terms.items() if val==v_2)}")
print(f"  GAP = {F(1,6) - v_2}  (the claim is missed by exactly this much)")
print(f"  to actually reach 1/6, theta must fall to {2*F(1,6)/(1-F(1,6))} = "
      f"{F(2,6)/(F(5,6))*2}")
t_needed = 2 * F(1, 6) / (1 - F(1, 6))
print(f"    = theta <= {t_needed}")
print(f"  i.e. a small-factor screen of cost M^{str(t_needed)}, against Strassen's M^{1/2}.")

print()
print("=" * 78)
print("P10 : EMPIRICAL -- do the weights 1 (pairs) and -1/2 (candidates) hold?")
print("=" * 78)
print("  Locally generated semiprimes only, n < 2^40. No RSA-scale factoring.")
print()
print(f"  {'n (bits)':>9s} {'r':>8s} | {'#pairs':>9s} {'exp(#pairs vs r)':>18s} | "
      f"{'#cands':>12s} {'exp(#cands vs N)':>18s}")
print("  " + "-" * 74)
cells = 0
rows_emp = []
for bits in [28, 30, 32, 34, 36, 38, 40]:
    for _ in range(6):
        p = nextprime(random.getrandbits(bits // 2))
        q = nextprime(random.getrandbits(bits - bits // 2))
        while q == p:
            q = nextprime(random.getrandbits(bits - bits // 2))
        n = p * q
        assert n.bit_length() == bits or n.bit_length() <= bits
        assert isprime(p) and isprime(q) and factorint(n) == {p: 1, q: 1}  # ground truth
        # r per Harvey's exponent r = N^{1/5}, lg ignored at this scale
        r = max(2, int(round(n ** 0.2)))
        # pair count
        npair = sum(1 for a in range(1, r + 1) for b in range(1, r // a + 1))
        # candidate count per Remark 3.4: sum_k ceil(N^{1/2}/(4 r k^{1/2}))
        sq = math.isqrt(n)
        ncand = sum(max(0, int(sq / (4 * r * math.sqrt(k)))) for k in range(1, r + 1))
        ep = math.log(npair) / math.log(r)
        ec = math.log(max(ncand, 1)) / math.log(n)
        rows_emp.append((bits, r, npair, ep, ncand, ec))
        cells += 1
# report per-cell, never only a pooled mean
for bits in [28, 30, 32, 34, 36, 38, 40]:
    sel = [x for x in rows_emp if x[0] == bits]
    print(f"  {bits:>9d} {sel[0][1]:>8d} | {sel[0][2]:>9d} {sel[0][3]:>18.4f} | "
          f"{sel[0][4]:>12d} {sel[0][5]:>18.4f}   ({len(sel)} cells)")
print(f"  TOTAL CELLS = {cells}   (nonzero check: {'OK' if cells>0 else 'VACUOUS!!'})")
print()
allpairs = sorted(x[3] for x in rows_emp)
print(f"  pair-count exponent vs r:  min={allpairs[0]:.4f}  max={allpairs[-1]:.4f}  "
      f"(predicted -> 1.0, weight 1)")
allc = sorted(x[5] for x in rows_emp)
print(f"  cand-count exponent vs N:  min={allc[0]:.4f}  max={allc[-1]:.4f}  "
      f"(predicted ~ 2/5 = 0.4 at r=N^{1/5})")
print()
print("  NOTE the honest scope: the candidate exponent 2/5 is the TOTAL count at")
print("  fixed r=N^{1/5}. The WEIGHT on r is what Remark 3.4's r^{-1/2} gives,")
print("  which is a symbolic fact about the paper's own displayed sum, not a")
print("  measured slope here. No measurement is extrapolated to the NFS regime.")
