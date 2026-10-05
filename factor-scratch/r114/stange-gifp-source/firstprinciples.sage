#!/usr/bin/env sage
# r114 / stange-gifp-source / firstprinciples.sage
#
# DELIVERABLE 3: derive from FIRST PRINCIPLES why a small factor can be read off.
# DELIVERABLE 5: is the campaign anywhere near the paper's threshold?
#
# No attack is run here. This evaluates an algebraic identity and does bit
# accounting, so the vacuous-evidence rule (FANOUT_BRIEF r113 addendum) does not
# apply: there is no success count. The n=800 baseline comparison is baseline.sage.

from sage.all import *

# ---------------------------------------------------------------- grid helper
# EXPONENT GRID. The reference gifp.sage computes the shift as int(n*b2 - n*b1)
# (a DIFFERENCE OF PRODUCTS). Writing it as int((b2-b1)*n) is OFF BY ONE at
# 87/234 measured parameter points and silently breaks the GIFP identity.
def grid(n, gamma, b1, b2, alpha):
    e_g   = int(gamma*n)
    e_b1  = int(b1*n)
    e_b2  = int(b2*n)
    sh    = e_b2 - e_b1                    # snapped shift
    e_hi1 = e_b1 + e_g
    e_hi2 = e_b2 + e_g
    beta  = RR(1) - alpha - gamma
    e_x2  = int((beta-b1)*n)
    e_x4  = int((beta-b2)*n)
    e_q   = int(alpha*n)
    assert e_b1 + sh == e_b2, "grid must close"
    return dict(e_g=e_g, e_b1=e_b1, e_b2=e_b2, sh=sh, e_hi1=e_hi1, e_hi2=e_hi2,
                e_x2=e_x2, e_x4=e_x4, e_q=e_q)

def instance(n, alpha, gamma, b1, b2, seed):
    """Build a GIFP instance FROM THE PAPER's definition (arXiv:2304.08718v3 p.7),
    not by importing gifp.sage. Ground truth verified by multiply-back."""
    set_random_seed(seed)
    G = grid(n, gamma, b1, b2, alpha)
    M0 = ZZ(randint(2^(G['e_g']-1)+1, 2^G['e_g']-1))
    x1 = ZZ(randint(0, 2^G['e_b1']-1))
    x2 = ZZ(randint(0, 2^G['e_x2']-1))
    x3 = ZZ(randint(0, 2^G['e_b2']-1))
    x4 = ZZ(randint(0, 2^G['e_x4']-1))
    p1 = x1 + M0*2^G['e_b1'] + x2*2^G['e_hi1']
    p2 = x3 + M0*2^G['e_b2'] + x4*2^G['e_hi2']
    # Do NOT use prime_range over a 2^(alpha*n)-wide interval: it enumerates and
    # hangs (measured >100 s at alpha*n=80). random_prime picks in-window.
    q1 = random_prime(2^(G['e_q']-1), 2^G['e_q'])
    q2 = random_prime(2^(G['e_q']-1), 2^G['e_q'])
    N1 = p1*q1; N2 = p2*q2
    assert p1*q1 == N1 and p2*q2 == N2     # ground truth by multiplication
    return dict(N1=N1,N2=N2,p1=p1,p2=p2,q1=q1,q2=q2,M0=M0,
                x1=x1,x2=x2,x3=x3,x4=x4,G=G)

print("="*130)
print("D3 -- FIRST-PRINCIPLES RECOVERY.  Why does a SMALL factor fall out?")
print("="*130)
print(r"""
The paper's decomposition (arXiv:2304.08718v3, p.7):
    p1 = x1 + M0*2^(b1 n)     + x2*2^((b1+g)n)
    p2 = x3 + M0*2^(b2 n)     + x4*2^((b2+g)n)
Multiply p1 by 2^((b2-b1)n).  This SHIFTS p1's shared block M0 from position b1 n
up to position b2 n, where it LANDS ON TOP OF p2's shared block.  Hence
    2^((b2-b1)n) p1 - p2 = (x1*2^((b2-b1)n) - x3) + (x2-x4)*2^((b2+g)n)
Multiply by q2 and use p2*q2 = N2:
    N2 + (x1*2^((b2-b1)n) - x3)*q2 + (x2-x4)*q2*2^((b2+g)n)
        = 2^((b2-b1)n) * p1 * q2
i.e. with  f(x,y,z) = x*z + 2^((b2+g)n) y*z + N2 :
    f( x1*2^((b2-b1)n) - x3 ,  x2 - x4 ,  q2 )  ==  0  mod  2^((b2-b1)n) * p1 .

THE POINT NOBODY IN THE CAMPAIGN STATED: the third unknown z IS q2.
The small factor is not a byproduct, not a lucky residue, not read off a gcd of
noise -- z0 = q2 BY CONSTRUCTION.  |q2| = alpha*n is the DEFINITION of the
problem (Definition 3, p.6: "q1 and q2 are alpha n-bit").
So "GIFP recovers a small factor" is not a factoring-power claim.  It is the
STATEMENT of the problem.  The lattice is solving FOR the small factor.""")
print()

alpha, gamma, b1, b2 = RR(0.1), RR(0.7), RR(0.1), RR(0.15)
for n in [200, 400, 800, 1600]:
    I = instance(Integer(n), alpha, gamma, b1, b2, seed=12345+n)
    G = I['G']
    x0 = I['x1']*2^G['sh'] - I['x3']; y0 = I['x2']-I['x4']; z0 = I['q2']
    lhs = I['N2'] + x0*I['q2'] + y0*I['q2']*2^G['e_hi2']
    rhs = 2^G['sh']*I['p1']*I['q2']
    mod  = 2^G['sh']*I['p1']
    fv  = x0*z0 + 2^G['e_hi2']*y0*z0 + I['N2']
    print("  n=%-5d identity over Z: %-6s | f(x0,y0,q2)==0 mod 2^sh*p1: %-6s | z0==q2: %-6s | |q2|=%-4d (a*n=%d)"
          % (n, lhs==rhs, fv % mod == 0, z0==I['q2'], I['q2'].nbits(), G['e_q']))
    assert lhs==rhs and z0==I['q2'] and fv % mod == 0
print()
print("  => CONFIRMED at n=200,400,800,1600: the recovered unknown z0 IS the small")
print("     factor q2, by construction. The lattice is not finding a factor; it is")
print("     solving a polynomial whose THIRD COORDINATE WAS DEFINED TO BE one.")
print()

print("="*130)
print("D3b -- THE BIT-BUDGET ACCOUNTING.  This is what actually reframes n=800.")
print("="*130)
print("GIFP is a SIDE-INFORMATION problem, not a factoring problem. Count the bits:")
print()
for n in [200, 800, 8000, 80000]:
    beta = 1-alpha-gamma
    side    = gamma*n
    unk_x3  = b2*n; unk_x4 = (beta-b2)*n; unk_q2 = alpha*n
    unk_tot = unk_x3+unk_x4+unk_q2
    print("  n=%-7d SIDE INFO GIVEN = g*n = %-9.0f bits (the shared block M0)" % (n, side))
    print("            UNKNOWNS SOLVED = %-20.0f bits (x3 %.0f + x4 %.0f + q2 %.0f)"
          % (unk_tot, unk_x3, unk_x4, unk_q2))
    print("            OVERDETERMINED  = %+9.0f bits  <-- side info EXCEEDS unknowns" % (side-unk_tot))
    print("            p2 bits NOT supplied = %-9.0f bits  (the actual secret)" % ((1-alpha)*n - side))
    print()
print("  At n=800, gamma=0.7: e_g = int(0.7*800) = %d bits of side information are" % grid(Integer(800),gamma,b1,b2,alpha)['e_g'])
print("  HANDED to the attacker in order to solve for 240 bits of unknown")
print("  (x3 120 + x4 40 + q2 80). Overdetermined by 320 bits.")
print()
print("  CONSEQUENCE FOR THE 'n=800 IS THE FIRST NON-VACUOUS GIFP SIZE' CLAIM:")
print("   PARI failing on N2 in >4 min says an 80-bit factor is hard for GNFS.")
print("   It does NOT say GIFP and PARI face the same problem. PARI is given N2")
print("   ALONE. GIFP is given N2 PLUS 560 bits of p2's own content, leaked into p1.")
print("   Different problems. GIFP's win measures the LEAK, not a factoring exponent.")
print("   The n=800 result's real value is that it is a CORRECTNESS TEST of the")
print("   pipeline at a size where the answer is not free -- a smaller claim than")
print("   'first non-vacuous factoring result', and the correct one to publish.")
print()

print("="*130)
print("D3c -- THE EXPONENT-GRID TRAP I HIT AND MEASURED (a real, quantified bug)")
print("="*130)
bad=0; tot=0; good=0
for n in [200,400,600,800,1000,2000,3000,5000,8000]:
    for u in [0.1,0.15,0.2,0.25,0.05,0.3]:
        for v in [0.15,0.2,0.25,0.3,0.35,0.4]:
            if v<=u: continue
            tot+=1
            if int(u*n) + int((v-u)*n) != int(v*n): bad+=1
            if int(u*n) + int(n*v-n*u) == int(v*n): good+=1
print("  The GIFP identity FAILED on my first run. Root cause was NOT the algebra.")
print("  It was the exponent grid. Measured over %d parameter points:" % tot)
print("    int(b1*n) + int((b2-b1)*n) != int(b2*n)   at %d / %d   (off by one)" % (bad,tot))
print("    int(b1*n) + int(n*b2 - n*b1) == int(b2*n) at %d / %d   (CLOSES)" % (good,tot))
print()
print("  => The REFERENCE gifp.sage form is correct and grid-closed.")
print("     The bug was in MY generator. This is a negative result about my own")
print("     code, NOT a defect in the paper or the reference implementation.")
print("     It is the same class as the brief's 'bit budgets must land on exact")
print("     integers' trap, and it is SILENT: no exception, just a wrong instance.")
print()

print("="*130)
print("D5 -- THE PAPER'S THRESHOLD vs WHERE THE CAMPAIGN IS.  Theorem 3 (p.7):")
print("        gamma > 4*alpha*(1 - sqrt(alpha)),   provided alpha + gamma <= 1.")
print("="*130)
print("  %-7s %-16s %-11s %-9s %-14s %-9s" % ("alpha","thr 4a(1-sqrt a)","camp gamma","g/thr","2a-2a^2","a+g<=1"))
g=RR(0.7)
for a_ in [0.05,0.10,0.15,0.17,0.20,0.25,0.30,0.40]:
    a_=RR(a_); thr=4*a_*(1-a_.sqrt())
    print("  %-7.2f %-16.5f %-11.2f %-9.3f %-14.5f %-9s"
          % (a_,thr,g,g/thr,2*a_-2*a_^2,"OK" if a_+g<=1 else "VIOLATED"))
r10=g/(4*RR(0.1)*(1-RR(0.1).sqrt())); r15=g/(4*RR(0.15)*(1-RR(0.15).sqrt()))
print()
print("  Campaign alpha=0.10: gamma/threshold = %.3f. gamma=0.7 is %.2fx the paper's own" % (r10,r10))
print("  required threshold. THE CAMPAIGN IS NOT NEAR THE WALL -- it sits well INSIDE")
print("  the region where the paper PROMISES success. Same at alpha=0.15: %.2fx." % r15)
print()
print("  => The r111c 'alpha >= 0.15 wall' is NOT Theorem 3. Theorem 3's threshold at")
print("     alpha=0.15 is only %.4f and gamma=0.7 clears it by %.2fx."
      % (4*RR(0.15)*(1-RR(0.15).sqrt()), r15))
print("     The real constraint is a FEASIBILITY condition, and it reproduces 0.15")
print("     EXACTLY. The construction needs x4 >= 0, i.e. beta-b2 >= 0 with")
print("     beta = 1-alpha-gamma, i.e.  alpha <= 1 - gamma - b2 = 1 - 0.7 - 0.15 = 0.15:")
print()
print("  %-8s %-12s %-11s %-14s %-9s" % ("alpha","beta=1-a-g","beta-b2","x4 room(bits)","feasible?"))
for a_ in [0.05,0.10,0.14,0.15,0.16,0.20,0.25,0.30]:
    a_=RR(a_); beta=1-a_-RR(0.7); d=beta-RR(0.15)
    print("  %-8.2f %-12.4f %-11.4f %-14.0f %-9s"
          % (a_,beta,d,max(0,float(d*800)),"OK" if d>=0 else "NO BITS -> IMPOSSIBLE"))
print()
print("  => EXACT MATCH to the observed 0.15 boundary. At gamma=0.7, b2=0.15 the")
print("     instances are UNBUILDABLE for alpha > 0.15: x4 has no bits to sample, so")
print("     the 'lattice decay at alpha in (0.15,0.17]' that r111c measured at n=200")
print("     is not a lattice phenomenon at these parameters. Any alpha>0.15 point the")
print("     campaign measured used DIFFERENT b2/gamma and must be re-checked against")
print("     this feasibility line before any decay is claimed.")
