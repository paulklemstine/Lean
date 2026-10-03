from mpmath import mp, mpf, sqrt, ln, exp, findroot
mp.dps=40
LN2=ln(2)
def Ln_of_N(bits): return mpf(bits)*LN2
def L12(bits):  # log2 L[1/2] with the sqrt(2...) convention the paper's caption states
    L=Ln_of_N(bits); return sqrt(2*L*ln(L))/LN2
def L13(bits):
    L=Ln_of_N(bits); return mpf('1.9229994')*L**(mpf(1)/3)*ln(L)**(mpf(2)/3)/LN2
def fmt(x): return mp.nstr(x,12)

print("=== JOB 2: #522 sec 2.2 table (caption formulas) ===")
paper={256:(64.00,61.85,46.66,2.15,17.34),
       1024:(256.00,139.27,86.77,116.73,169.23),
       4096:(1024.00,306.55,156.50,717.45,867.50),
       16384:(4096.00,664.40,276.52,3431.60,3819.48)}
for bits,(pa,pb,pc,pd,pe) in paper.items():
    a=mpf(bits)/4; b=L12(bits); c=L13(bits); d=a-b; e=a-c
    print(f"n={bits}")
    for nm,mine,pv in (("N^1/4",a,pa),("L[1/2]",b,pb),("L[1/3]",c,pc),("N^1/4-L12",d,pd),("N^1/4-L13",e,pe)):
        r=round(float(mine),2)
        flag="OK " if abs(r-pv)<0.005 else "**MISMATCH**"
        print(f"   {nm:>10} paper={pv:>9} mine={r:>9} exact={fmt(mine):>18} {flag}")
    print(f"   ordering: L13<L12<N^1/4 ? {c<b<a}")

print()
print("=== old L[1/2] column 21.87/49.24/108.38/234.90: what formula? ===")
for bits,old in ((256,21.87),(1024,49.24),(4096,108.38),(16384,234.90)):
    L=Ln_of_N(bits)
    h1=sqrt(L*ln(L))/LN2        # no sqrt2
    print(f"n={bits:>5} old={old:>7}  sqrt(LlnL)/ln2={float(h1):.2f}  half-of-that={float(h1/2):.2f}  ratio old/L12={old/float(L12(bits)):.4f}")

print()
print("=== IS L[1/3] < L[1/2] < N^(1/4) at EVERY size? crossover search ===")
import sys
def cross(eq):
    return float(findroot(lambda x: eq(x), 100, 2000))
c1=cross(lambda x: (1.9229994*mpf(x)**(mpf(1)/3)*ln(x)**(mpf(2)/3)/LN2) - sqrt(2*x*ln(x))/LN2)
c2=cross(lambda x: (mpf(x)/4) - sqrt(2*x*ln(x))/LN2)
print(f"L[1/3] = L[1/2] first at  log2 N = {c1:.1f}  (N = 2^{c1:.1f})")
print(f"N^(1/4) = L[1/2] first at log2 N = {c2:.1f}")
print("paper says a sub-agent claimed 'crossover at 40000 bits'; 40000 bits is where?")
L=mpf(40000)*LN2
print(f"   at 40000 bits: L13={float(L13(40000)):.2f} L12={float(L12(40000)):.2f} N^1/4={10000.0}")
