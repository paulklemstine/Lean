#!/usr/bin/env python3
"""
E1: exact exponent bookkeeping for Harvey Algorithm 4.3, from the PRIMARY SOURCE.

EVERY term below is transcribed from arXiv:2010.05450v1 and was checked on a
rendered page image (pdftotext flattens exponents -- the screen term's lg power
was initially mis-read by it and by my first draft; the float path caught it).

  p.6   Lemma 3.3 hyp (3.1):   (N/r)^{1/2} <= p < N^{1/2}
  p.6   (3.2):                 0 <= aq+bp - (4abN)^{1/2} < N^{1/2}/(4r(ab)^{1/2})
  p.6   Remark 3.4:            #candidates = O(N^{1/2}/r^{1/2} + r)
  p.6   Prop 2.5:              find factor <= M in  O(M^{1/2} lg^3 N)
  p.6   Prop 2.7:              D in [N^{2/5}, N] -> cost O(D^{1/2} lg^2 N)
  p.10  Prop 4.2 (VERBATIM):
        "For r, m = O(N), its running time is
            O(( N^{1/2}/(r^{1/2}m) + r ) lg^4 N + m lg^2 N)."
  p.12  Alg 4.3 step 1:        r := ceil(N^{1/5}/lg^{4/5} N),  m := ceil(N^{1/5} lg^{6/5} N)
  p.12  Alg 4.3 step 2:        Prop 2.5 with M := ceil((N/r)^{1/2})
  p.12  Alg 4.3 step 3:        Prop 2.7 with D := ceil(N^{2/5})
  p.12  Prop 4.3:              total O(N^{1/5} lg^{16/5} N)

Each term is represented exactly as N^a * lg^b N via Fractions.

PREDICTIONS (stated before running):
  P1  The full 5-term model has max N-exponent exactly 1/5.
  P2  FOUR of the five terms co-bind at N^{1/5} lg^{16/5}; only Prop 2.7 is below.
      => the lg^{16/5} is itself overdetermined, which is why Harvey's r and m
         carry the specific lg^{4/5} and lg^{6/5} corrections.
  P3  POSITIVE CONTROL: the corpus 3-term model attains exactly 1/5 (instrument fires).
  P4  CLOSURE: the two-term subproblem max(r, (N/r)^{1/4}) ALONE has optimum 1/5,
      with Sum w = 1/4 and gamma = 1/4. It contains no m and no BSGS interior.
  P5  Harvey's (r,m) are the exact minimisers of the full model.
"""
from fractions import Fraction as F
import random, math

random.seed(20261004)


def terms_full(r_exp, r_lg, m_exp, m_lg):
    """name -> (a, b) meaning the term is N^a * lg^b N."""
    t = {}
    # Step 2, Prop 2.5 with M := ceil((N/r)^{1/2}).
    #   M^{1/2} = (N/r)^{1/4}  =>  N^{(1-r_exp)/4} * lg^{-r_lg/4};  then * lg^3
    t["screen_Prop2.5"] = ((F(1) - F(r_exp)) / 4, F(3) - F(r_lg) / 4)
    # Step 3, Prop 2.7 with D := ceil(N^{2/5});  D is FIXED (hypothesis N^{2/5} <= D)
    t["large_order_Prop2.7"] = (F(1, 5), F(2))
    # Step 4a, Prop 4.2 "+ r" inside the lg^4 bracket: enumerate (a,b), ab <= r
    t["r_floor_pairs"] = (F(r_exp), F(r_lg) + F(4))
    # Step 4b, Prop 4.2 "N^{1/2}/(r^{1/2}m)" inside the lg^4 bracket
    t["bsgs_interior"] = (F(1, 2) - F(r_exp) / 2 - F(m_exp),
                          F(4) - F(r_lg) / 2 - F(m_lg))
    # Step 4c, Prop 4.2 "+ m lg^2 N"
    t["m_floor_babystep"] = (F(m_exp), F(m_lg) + F(2))
    return t


def bal(gamma, w):
    """Exact optimum exponent of max(floor, N^gamma/floor^w)."""
    return F(gamma) / (1 + F(w))


print("=" * 78)
print("P1 / P2 : full five-term model at Harvey's Alg 4.3 settings")
print("=" * 78)
hv = dict(r_exp=F(1, 5), r_lg=F(-4, 5), m_exp=F(1, 5), m_lg=F(6, 5))
T = terms_full(**hv)
for n, (a, b) in T.items():
    print(f"  {n:22s} N^{str(a):>6s} * lg^{str(b):>6s} N")
print()
amax = max(a for a, b in T.values())
bmax = max(b for a, b in T.values())
print(f"  max N-exponent  (P1, predicted 1/5)   = {amax}   ok={amax == F(1,5)}")
print(f"  max lg-exponent (predicted 16/5)      = {bmax}  ok={bmax == F(16,5)}")
co = sorted(n for n, (a, b) in T.items() if a == amax and b == bmax)
print(f"  co-binding at N^(1/5) lg^(16/5) (P2)  = {co}")
print(f"  predicted: 4 co-binding terms, only Prop 2.7 strictly below")
print(f"  below it  = {sorted(n for n,(a,b) in T.items() if (a,b)!=(amax,bmax))}")

print()
print("=" * 78)
print("P3 : POSITIVE CONTROL -- corpus three-term model must attain 1/5")
print("=" * 78)
gB, wB = F(1, 2), F(1, 2) + 1
print(f"  corpus: max(r, m, N^(1/2)/(r^(1/2) m));  gamma=1/2, w_r=1/2, w_m=1, Sum w={wB}")
print(f"  optimum = (1/2)/(1+3/2) = {bal(gB, wB)}   ok={bal(gB,wB)==F(1,5)}")
re_ = me_ = F(1, 5)
print(f"  at r=m=N^(1/5): r={re_}, m={me_}, interior={F(1,2)-F(re_)/2-me_}, "
      f"all equal? {re_==me_==F(1,2)-F(re_)/2-me_}")
print("  -> instrument fires: it DOES reproduce 1/5. So a miss on the full")
print("     model would be a real signal, not a broken instrument.")

print()
print("=" * 78)
print("P4 : CLOSURE -- an INDEPENDENT second balance, omitted by the corpus")
print("=" * 78)
gA, wA = F(1, 4), F(1, 4)
print("  row 2 of the cost: Prop 2.5 screen (N/r)^{1/4} versus the pair floor r.")
print(f"     max( r , N^(1/4) / r^(1/4) ) :  gamma = 1/4, w_r = 1/4, Sum w = {wA}")
print(f"     optimum exponent = gamma/(1+Sum w) = {bal(gA, wA)}   "
      f"ok={bal(gA,wA)==F(1,5)}")
best = min(((F(k, 200000), max(F(k, 200000), F(1, 4) - F(k, 200000) / 4))
            for k in range(1, 200001)), key=lambda z: z[1])
print(f"     brute-force min_r = {best[1]} at r = N^{best[0]}  (grid step 1/200000)")
print("  THIS BALANCE CONTAINS NO m AND NO BSGS INTERIOR. It is untouched by any")
print("  reweighting of the BSGS side. So 1/5 is OVERDETERMINED.")

print()
print("=" * 78)
print("THE WEIGHT STRUCTURE, mechanically (the deliverable)")
print("=" * 78)
print("            |  w_r   w_m  | gamma | Sum w | exponent")
print("  ----------+--------------+-------+-------+---------")
print(f"  row 1 BSGS|  {F(1,2)}    1   |  1/2  |  {wB}  | {bal(gB,wB)}")
print(f"  row 2 scrn|  {F(1,4)}    -   |  1/4  |  {wA}  | {bal(gA,wA)}")
print()
print("  => Sum w = 3/2 is TWO floors: weight 1/2 on r and weight 1 on m.")
print("     It is NOT three floors of 1/2 and NOT two of 3/4.")
print("  => but 3/2 is ROW 1 ONLY. The corpus models one row; Harvey has two.")

print()
print("=" * 78)
print("CONSEQUENCE: raising row 1 alone does NOT reach 1/6")
print("=" * 78)
print(f"  {'target':>7s} | {'row1 Sum w needed':>18s} | {'row2 Sum w needed':>18s}")
print("  " + "-" * 50)
for e, lbl in [(F(1, 5), "1/5"), (F(1, 6), "1/6"), (F(1, 8), "1/8")]:
    print(f"  {lbl:>7s} | {str(F(1,2)/e - 1):>18s} | {str(F(1,4)/e - 1):>18s}")
print()
print("  Harvey has row1=3/2, row2=1/4. Both rows must move:")
print("     1/6 needs 3/2 -> 2   AND   1/4 -> 1/2")
print("     1/8 needs 3/2 -> 3   AND   1/4 -> 1")
print("  The corpus's `beating_one_fifth_requires` (Sum w > 3/2 OR gamma < 1/2)")
print("  is INCOMPLETE: it prices only row 1.")

print()
print("=" * 78)
print("P5 : FLOATING-POINT CONFIRMATION (independent of the Fraction path)")
print("=" * 78)
for bits in [128, 256, 512, 1024, 2048, 4096]:
    LN = float(bits)                       # lg N for N = 2^bits
    log2N = bits * math.log(2)
    # everything computed in log-space to dodge float overflow
    l_r = log2N / 5 - 0.8 * math.log(LN)          # log r   = N^{1/5} lg^{-4/5}
    l_m = log2N / 5 + 1.2 * math.log(LN)          # log m   = N^{1/5} lg^{6/5}
    l_M = (log2N - l_r) / 2                        # log M   = (N/r)^{1/2}
    l_D = 0.4 * log2N                              # log D   = N^{2/5}
    terms = {
        "screen":      l_M / 2 + 3 * math.log(LN),
        "large_order": l_D / 2 + 2 * math.log(LN),
        "r_floor":     l_r + 4 * math.log(LN),
        "interior":    (log2N / 2 - l_r / 2 - l_m) + 4 * math.log(LN),
        "m_floor":     l_m + 2 * math.log(LN),
    }
    l_tot = max(terms.values())
    l_tgt = log2N / 5 + 3.2 * math.log(LN)
    win = sorted(k for k, v in terms.items() if abs(v - l_tot) < 1e-9)
    print(f"  N=2^{bits:<5d} log(total) - log(N^(1/5)lg^(16/5)) = {l_tot-l_tgt:+.2e}  "
          f"co-attainers={win}")
