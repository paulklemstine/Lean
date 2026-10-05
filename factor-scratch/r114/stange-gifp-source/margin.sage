#!/usr/bin/env sage
# r114 / stange-gifp-source / margin.sage
#
# FIRST-PRINCIPLES derivation of the GIFP success condition and its n-scaling,
# from Feng-Nitaj-Pan, "Generalized Implicit Factorization Problem", arXiv:2304.08718v3.
#
# The exact statements used (read off PAGE IMAGES, not pdftotext):
#   p.9  "the dimension of the lattice is  omega = sum_i sum_j 1 = (m+1)(m+2)/2"
#   p.9  "det(B) = det(L) = X^eX Y^eY Z^eZ W^eW 2^{(b2-b1)n eM} N1^eN"
#   p.10 the e-exponents, verbatim:
#        eX = m(m+1)(m+2)/6
#        eY = m(m+1)(m+2)/6
#        eZ = m(m+1)(m+2)/3 + s(s+1)(s+2)/6 - s(m+1)(m+2)/2
#        eW = s(s+1)(s+2)/6
#        eN = t(t+1)(3m-t+4)/6
#        eM = m(m+1)(m+2)/3
#   p.10 the combined condition (their eq. (1)):
#        X^eX Y^eY Z^eZ W^eW 2^{(b2-b1)n eM} N1^eN
#            < 1/(2^{(w-1)/4} sqrt(w)) * (2^{(b2-b1)n})^{w m} * p1^{t w}
#        with i = 2 in the LLL bound.
#   p.5  Theorem 2 (Howgrave-Graham): h(y)=0 over Z if ||h(x_1X_1,...)|| < sqrt(M^w).
#
# THIS SCRIPT CLAIMS NOTHING ABOUT FACTING. It evaluates an algebraic inequality.
# No success count is reported here, so the vacuous-evidence rule does not apply;
# the n=800 attack baseline comparison lives in baseline.sage.

from sage.all import *   # explicit, no exec() of fragments (FANOUT_BRIEF 3)

def exponents(m, s, t):
    """The e-exponents, p.10 of arXiv:2304.08718v3. Exact integers, no floats."""
    eX = m*(m+1)*(m+2)//6
    eY = m*(m+1)*(m+2)//6
    eZ = m*(m+1)*(m+2)//3 + s*(s+1)*(s+2)//6 - s*(m+1)*(m+2)//2
    eW = s*(s+1)*(s+2)//6
    # paper: sum_i=0..t sum_j=0..m-i (t-i) = t(t+1)(3m-t+4)/6
    # direct sum check, so we are not trusting a possibly-misprinted closed form
    eN_direct = sum((t-i) for i in range(0, t+1) for j in range(0, m-i+1))
    eN = t*(t+1)*(3*m-t+4)//6
    eM = m*(m+1)*(m+2)//3
    assert eN == eN_direct, (eN, eN_direct, m, s, t)
    return dict(eX=eX, eY=eY, eZ=eZ, eW=eW, eN=eN, eM=eM)

def dimension(m):
    """omega, p.9: independent of n. Direct sum as a check on the closed form."""
    d_direct = sum(1 for i in range(0, m+1) for j in range(0, m-i+1))
    return d_direct, (m+1)*(m+2)//2

def log2_det(n, alpha, gamma, b1, b2, m, s, t):
    """log2 of det(L) = X^eX Y^eY Z^eZ W^eW 2^{(b2-b1)n eM} N1^eN,
    using the paper's own substitutions (p.10):
        X = 2^{b2 n}, Y = 2^{(beta-b1) n}, Z = 2^{alpha n}, W = 2^{(1-alpha) n},
        N1 ~ 2^n, p1 ~ 2^{(1-alpha) n},  beta = 1-alpha-gamma.
    Returned as a SYMBOLIC LINEAR FUNCTION  c*n + const  so the n-cancellation
    is visible rather than hidden inside a float."""
    beta = 1 - alpha - gamma
    e = exponents(m, s, t)
    c = (b2*e['eX'] + (beta-b1)*e['eY'] + alpha*e['eZ']
         + (1-alpha)*e['eW'] + (b2-b1)*e['eM'] + e['eN'])
    return c, e, beta

def margin(n, alpha, gamma, b1, b2, m, s, t):
    """log2 of (LHS of eq.(1)) - log2(RHS of eq.(1)).
    NEGATIVE margin => the paper's sufficient condition HOLDS.
    Uses the LLL bound with i=2, so the exponent on det(L) is 1/(w-1)."""
    c, e, beta = log2_det(n, alpha, gamma, b1, b2, m, s, t)
    w, _ = dimension(m)
    w = Integer(w)
    # log2 LHS = n*c
    logLHS = n*c
    # log2 RHS = -(w-1)/4 - log2(sqrt(w)) + w*m*(b2-b1)*n + t*w*(1-alpha)*n
    logRHS = (-(w-1)/4 - log(w,2)/2
              + n*(w*m*(b2-b1) + t*w*(1-alpha)))
    return logLHS - logRHS, c, w, e

def report(label, n, alpha, gamma, b1, b2, m, s, t):
    mg, c, w, e = margin(n, alpha, gamma, b1, b2, m, s, t)
    holds = "HOLDS " if mg < 0 else "FAILS "
    print("%-26s n=%-6s m=%-3s s=%-3s t=%-3s  omega=%-4s log2det/n=%-10s margin=%-14s %s"
          % (label, n, m, s, t, w, n and N(c) and float(c), float(mg), holds))
    return mg, c, w

print("="*130)
print("PART 1 -- dimension is INDEPENDENT of n.  (paper p.9: omega = (m+1)(m+2)/2)")
print("="*130)
for m in range(2, 11):
    d, closed = dimension(m)
    print("  m=%-3d omega_direct=%-4d omega_closed_form=%-4d  match=%s   (n plays no role)"
          % (m, d, closed, d == closed))
print()
print("  Paper Table 3 reports dim(L)=28 at m=6 -> (m+1)(m+2)/2 =", (6+1)*(6+2)//2)
print("  Paper Table 4 reports dim(L)=21 at m=5 -> (m+1)(m+2)/2 =", (5+1)*(5+2)//2)
print()

print("="*130)
print("PART 2 -- the e-exponents agree with DIRECT SUMS (not trusting the closed forms)")
print("="*130)
for (m, s, t) in [(3,2,2), (4,2,3), (6,2,4), (6,3,4), (6,4,3), (8,3,5), (10,4,6)]:
    e = exponents(m, s, t)
    eX_d = sum(i       for i in range(0,m+1) for j in range(0,m-i+1))
    eY_d = sum(j       for i in range(0,m+1) for j in range(0,m-i+1))
    eZ_d = sum(i+j-min(s,i+j) for i in range(0,m+1) for j in range(0,m-i+1))
    eW_d = sum(s-min(s,i+j) for i in range(0,m+1) for j in range(0,m-i+1))
    eM_d = sum(m-i     for i in range(0,m+1) for j in range(0,m-i+1))
    ok = (e['eX']==eX_d and e['eY']==eY_d and e['eZ']==eZ_d and e['eW']==eW_d and e['eM']==eM_d)
    print("  m=%-3d s=%-2d t=%-2d  eX=%-5d eY=%-5d eZ=%-5d eW=%-5d eN=%-5d eM=%-5d  all_match=%s"
          % (m, s, t, e['eX'], e['eY'], e['eZ'], e['eW'], e['eN'], e['eM'], ok))
    assert ok
print()

print("="*130)
print("PART 3 -- THE SCALING QUESTION.  log2(det) = c*n  with c INDEPENDENT of n,")
print("            and log2(RHS) is ALSO linear in n.  So the margin's n-slope is")
print("            a CONSTANT: there is no asymptotic n-barrier, only a finite slack.")
print("="*130)
# campaign parameters: r110-r113 used n=200 and n=800, alpha=0.1, gamma=0.7,
# beta1/beta2 = 0.1/0.15 (see gifp.sage README usage line). beta = 1-0.1-0.7 = 0.2.
ALPHA, GAMMA, B1, B2 = RR(0.1), RR(0.7), RR(0.1), RR(0.15)
print("  alpha=%s gamma=%s beta1=%s beta2=%s  ->  beta = 1-alpha-gamma = %s"
      % (ALPHA, GAMMA, B1, B2, 1-ALPHA-GAMMA))
print("  NOTE beta must satisfy beta1 <= beta <= beta2 ordering per paper (b1 <= b2).")
print()
print("  The paper's threshold, Theorem 3:  gamma > 4*alpha*(1 - sqrt(alpha))")
thr = 4*ALPHA*(1-ALPHA.sqrt())
print("  at alpha=%s : 4*alpha*(1-sqrt(alpha)) = %.6f ;  campaign gamma = %.6f ; ratio gamma/thr = %.3fx"
      % (ALPHA, thr, GAMMA, GAMMA/thr))
print()
print("  n-scan at fixed (alpha,gamma,beta1,beta2,m,s,t) -- the ONLY thing changing is n:")
for n in [200, 800, 2000, 8000, 20000, 100000]:
    report("  n-scan", n, ALPHA, GAMMA, B1, B2, 6, 2, 4)
print()
print("  Same, but the SLACK (how much room, in bits) -- this is the number that matters:")
for n in [200, 800, 2000, 8000, 20000, 100000]:
    mg, c, w, e = margin(Integer(n), ALPHA, GAMMA, B1, B2, 6, 2, 4)
    print("    n=%-7s margin=%-16s  (margin * n = %s  <- should be the n-constant)"
          % (n, float(mg), float(mg*n)))
print()

print("="*130)
print("PART 4 -- n-CANCELLATION, stated exactly.  margin(n) = A + B/n is FALSE;")
print("            rather  margin(n) = n*C + D  with C,D n-free, so margin/n -> C.")
print("="*130)
for n in [800, 8000, 80000]:
    mg, c, w, e = margin(Integer(n), ALPHA, GAMMA, B1, B2, 6, 2, 4)
    print("  n=%-7d  margin=%-18s  margin/n=%-16s" % (n, float(mg), float(mg/n)))
print()
print("  Derivation of the n-dependence, from p.10 eq.(1) with i=2:")
print("    n*c/(w-1)  +  w(w-1)/4   <   (m/sqrt(w)) * n * [ (b2-b1) + t(1-alpha) ]")
print("  Divide by n:")
print("    c/(w-1)    +  w(w-1)/(4n)  <  (m/sqrt(w)) * [ (b2-b1) + t(1-alpha) ]")
print("  The left side is  [n-independent]  +  [O(1/n) POSITIVE].")
print("  => SMALL n is EASIER. The condition is a FIXED SLACK, not an n-asymptote.")
print("  => There is NO n beyond which GIFP stops working. n=800 -> n=8000 is")
print("     predicted to hold with the SAME margin, by this derivation.")
print()

print("="*130)
print("PART 5 -- verify at the PAPER'S OWN Table 3 parameters (n=1000 row), i.e.")
print("            does the paper's own successful experiment satisfy its own bound?")
print("="*130)
# Table 3 last row: n=1000, alpha*n=100, beta*n=200, beta1*n=100, beta2*n=150, gamma*n=700, m=6
# so alpha=0.1, beta=0.2, beta1=0.1, beta2=0.15, gamma=0.7  (identical to campaign!)
# and s,t are not reported in Table 3 -> use the paper's own optima sigma=sqrt(alpha),
# tau=1-sqrt(alpha):  s=sigma*m, t=tau*m.
a_s = (ALPHA.sqrt()*6).round()
a_t = ((1-ALPHA.sqrt())*6).round()
print("  paper Table 3 last row: n=1000, alpha=0.1, gamma=0.7, beta1=0.1, beta2=0.15, m=6")
print("  Table 3 does NOT report s,t. Paper's own optima (p.11): sigma=sqrt(alpha),")
print("  tau=1-sqrt(alpha)  ->  s=sqrt(0.1)*6=%.3f, t=(1-sqrt(0.1))*6=%.3f" % (ALPHA.sqrt()*6, (1-ALPHA.sqrt())*6))
print("  nearest integers: s=%d, t=%d  (NOTE: this rounding is a choice, not a derivation)"
      % (a_s, a_t))
for (s_, t_) in [(a_s, a_t), (2,4), (2,3), (1,4), (3,3), (2,5), (4,2)]:
    mg, c, w, e = margin(Integer(1000), ALPHA, GAMMA, B1, B2, 6, s_, t_)
    print("    n=1000 m=6 s=%-2d t=%-2d  omega=%-3s margin=%-16s %s"
          % (s_, t_, w, float(mg), "HOLDS" if mg < 0 else "FAILS"))
print()
print("="*130)
print("PART 6 -- the OTHER branch the paper mentions (p.12): no 'w' variable,")
print("            bound degrades from 4a(1-sqrt(a)) to 2a(2-sqrt(a)).  Check the")
print("            n-scaling is the same shape (c*n, n-free slope) in that branch too.")
print("="*130)
# 3-variable version: no w, so eW = 0 and eZ is the full sum.
def log2_det3(alpha, gamma, b1, b2, m, t):
    beta = 1 - alpha - gamma
    eX = m*(m+1)*(m+2)//6
    eY = m*(m+1)*(m+2)//6
    eZ = sum(i+j for i in range(0,m+1) for j in range(0,m-i+1))
    eN = t*(t+1)*(3*m-t+4)//6
    eM = m*(m+1)*(m+2)//3
    c = b2*eX + (beta-b1)*eY + alpha*eZ + (b2-b1)*eM + eN
    return c
for m in [4,6,8,10]:
    t_ = int(round((1-ALPHA.sqrt())*m))
    c3 = log2_det3(ALPHA, GAMMA, B1, B2, m, t_)
    print("  3-var branch m=%-3d t=%-3d  log2(det)/n = %s   (still linear in n, slope n-free)"
          % (m, t_, float(c3)))
print()
print("="*130)
print("PART 7 -- WHAT ACTUALLY GROWS WITH n: the BIT SIZE of lattice entries.")
print("            Dimension is FIXED; entry bit-length is Theta(n).  That is the")
print("            only place n enters the cost.  Measure it, do not assume it.")
print("="*130)
for n in [200, 800, 2000, 8000]:
    c, e, beta = log2_det(Integer(n), ALPHA, GAMMA, B1, B2, 6, 2, 4)
    # a typical entry is X*Y*Z*W-scaled monomial; its bit length is O(n) with
    # constant (b2 + (beta-b1) + alpha + (1-alpha)) = b2 + beta - b1 + 1
    per_entry = B2 + (beta-B1) + ALPHA + (1-ALPHA)
    w,_ = dimension(6)
    print("  n=%-6s  dim=%-4s  log2(det)=n*%.3f  ~2^(%.1f)  bit-length of det=%.0f  entry-bitlen~n*%.3f"
          % (n, w, float(c), float(n*c), float(n*c), float(per_entry)))
print()
print("  LLL cost model: dim is CONSTANT (=28 at m=6). Only the integer bit-length")
print("  grows, linearly in n. So recovery cost is ~ O(dim^3) big-int ops on")
print("  Theta(n)-bit integers  =>  quasi-linear in n, NOT exponential in n.")
print("  This is the structural reason to expect n=800 -> n=8000 to hold.")
