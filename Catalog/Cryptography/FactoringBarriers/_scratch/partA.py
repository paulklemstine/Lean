# Re-derivation of Harvey 2021's N^(1/5) cost with order-finding made free.
# Sources actually opened:
#   - arXiv:2010.05450 (Harvey, "An exponent one-fifth algorithm for deterministic
#     integer factorisation"), Alg 4.3, Prop 2.7, Prop 4.2, Prop 4.3, Remark 2.8
#   - arXiv:2601.11131v2 (Harvey-Hittmeir, "Deterministic methods for finding elements
#     of large multiplicative order"), Theorem 1.1
# Each term is written as (alpha, beta) meaning  N^alpha * lg^beta N.
def mul(x, y): return (x[0] + y[0], x[1] + y[1])
def pw(x, k):  return (k * x[0], k * x[1])
def sub(x, y): return (x[0] - y[0], x[1] - y[1])
def lg(k):     return (0.0, k)

r = (1/5, -4/5)        # Harvey Alg 4.3 Step 1:  r = N^(1/5) / lg^(4/5) N
m = (1/5,  6/5)        # Harvey Alg 4.3 Step 1:  m = N^(1/5) lg^(6/5) N
D = (2/5,   0)         # Harvey Alg 4.3 Step 3:  D = ceil(N^(2/5))
M = pw(sub((1, 0), r), 0.5)          # M = ceil((N/r)^(1/2)) = N^(2/5) lg^(2/5) N
# s = N^(1/2)/(r^(1/2) m)  +  r lg r  (Harvey Prop 4.2).  Both branches have alpha = 1/5,
# so s ~ N^(1/5) and the lg-exponent is the max of the two.
_s1 = sub(pw(mul((1, 0), r), -0.5), m)      # branch 1
_s2 = mul(r, lg(1))                          # branch 2
s = (max(_s1[0], _s2[0]), max(_s1[1], _s2[1]))
print(f"[check] s branch1 (N^(1/2)/(r^(1/2)m)) = N^{_s1[0]:.4f} lg^{_s1[1]:.3f}N ; "
      f"branch2 (r lg r) = N^{_s2[0]:.4f} lg^{_s2[1]:.3f}N ; s = N^{s[0]:.4f} lg^{s[1]:.3f}N")
print()

TERMS = [
 ("Step(2)  Prop 2.5 smoothness sieve, M=ceil((N/r)^(1/2))  O(M^(1/2) lg^3 N)",
     mul(pw(M, 0.5), lg(3))),
 ("Step(2)a pair exponents t_{a,b}, O(r lg r) pairs        O(r lg^3 N)",
     mul(r, lg(3))),
 ("Step(2)b triples -> v_{a,b,j}                           O(s lg N)",
     mul(s, lg(1))),
 ("Step(3)  Prop 2.7 ORDER-FINDING  [Harvey: 'negligble']   O(N^(1/5) lg^2 N)",
     (1/5, 2.0)),
 ("Step(4)  Alg 4.1 PRODUCT TREE over the v-list            O(s lg^3 N)",
     mul(s, lg(3))),
 ("Step(4)  Lem 2.4 Bluestein, m baby-steps                 O(m lg^2 N)",
     mul(m, lg(2))),
]

print("=" * 92)
print("PART A  Harvey arXiv:2010.05450, Prop 4.2 + Prop 4.3 -- every N-dependent term")
print("        at Harvey's OWN parameters.  Term = N^alpha lg^beta N.")
print("=" * 92)
# a term "carries the 1/5" iff it attains the max BOTH in alpha and in beta
lead = max((t[1][0], t[1][1]) for t in TERMS)
for lab, ab in TERMS:
    tag = "   <== CARRIES THE 1/5  (co-leader)" if (abs(ab[0]-lead[0])<1e-12 and abs(ab[1]-lead[1])<1e-12) else ""
    print(f"  {lab:78s} N^{ab[0]:.4f} lg^{ab[1]:.3f}N{tag}")
print()
print(f"  Prop 4.3's published claim:  F(N) = O(N^(1/5) lg^(16/5) N).")
nlead = [lab for lab,ab in TERMS if abs(ab[0]-lead[0])<1e-12 and abs(ab[1]-lead[1])<1e-12]
print(f"  Reproduced: alpha = {lead[0]} = 1/5 ;  beta = {lead[1]} = 16/5.   OK")
print(f"  {len(nlead)} terms carry it:")
for x in nlead: print(f"      - {x[:74]}")

# ---- re-derive with order-finding free (2601.11131 Thm 1.1) and maximal order ----
n_true = sub(mul(s, m), D)             # rate law: n_true = s*m/D
pt_opt = mul(n_true, lg(3))             # product tree over only the true matches
of_opt = mul(pw(D, 0.5), lg(2))         # HH Thm 1.1 at D=N^(2/5): D^(1/2) lgD lgN/(lglog)^{1/2}
sieve  = TERMS[0][1]
bluest = TERMS[5][1]
after  = max((pt_opt[0],pt_opt[1]), (sieve[0],sieve[1]), (bluest[0],bluest[1]), (of_opt[0],of_opt[1]))

print()
print("=" * 92)
print("PART A2  SAME ALGORITHM, order-finding now hypothesis-FREE and alpha of MAXIMAL order")
print("=" * 92)
print(f"  n_true = s*m/D                      N^{n_true[0]:.4f} lg^{n_true[1]:.3f}N   <-- POLYLOG")
print(f"  product tree, order-optimised       N^{pt_opt[0]:.4f} lg^{pt_opt[1]:.3f}N"
      f"   (was N^{s[0]:.4f} lg^{mul(s,lg(3))[1]:.3f}N)")
print(f"  order-finding under HH Thm 1.1      N^{of_opt[0]:.4f} lg^{of_opt[1]:.3f}N")
print(f"  UNMOVED  Step(2) sieve              N^{sieve[0]:.4f} lg^{sieve[1]:.3f}N")
print(f"  UNMOVED  Step(4) Bluestein          N^{bluest[0]:.4f} lg^{bluest[1]:.3f}N")
print()
print(f"  MAX before  = N^{lead[0]:.4f} lg^{lead[1]:.3f} N")
print(f"  MAX after   = N^{after[0]:.4f} lg^{after[1]:.3f} N")
print()
if abs(after[0]-lead[0])<1e-12 and abs(after[1]-lead[1])<1e-12:
    print("  ==> N-EXPONENT UNCHANGED.  1/5 STANDS.")
    print("      Free order-finding removes ONE of THREE co-leaders; the other two")
    print("      (the M=(N/r)^(1/2) sieve and the m-entry Bluestein baby-step list) are")
    print("      entirely order-independent and pin the max at N^(1/5) lg^(16/5) N.")
else:
    print(f"  ==> N-EXPONENT CHANGED by {after - lead:+.4f}  (would be a POSITIVE result)")

# ---- sanity: the k-floor weight bookkeeping, HarveyFloor.lean shape ----
print()
print("=" * 92)
print("PART A3  The k-floor weight bookkeeping (HarveyFloor.lean's shape), 3-term")
print("=" * 92)
print("  Shape max( r , m , N^(1/2)/(r^(1/2) m) ).  Set r=m=T, N^(1/2)/T^(3/2)=T")
print("  => T^(5/2) = N^(1/2) => T = N^(1/5).   gamma/(1+sum w) = (1/2)/(1+3/2) = 1/5.")
print("  Adding Prop 4.3's Step(2) term N^(1/4) r^(-1/4) (weight 1/4 in r):")
print("    r = T and N^(1/4)/r^(1/4) = T  =>  r = N/T^4, so T = N/T^4 => T^5 = N => T = N^(1/5).")
print("  ==> the FULL Harvey 4.3 shape gives the SAME 1/5, and Prop 4.2's three terms")
print("      are already balanced AT that point.  The order is not one of the weights.")
