from math import log, exp, sqrt
def bisect(f,a,b,it=300):
    fa=f(a)
    for _ in range(it):
        m=(a+b)/2; fm=f(m)
        if fa*fm<=0: b=m
        else: a=m; fa=fm
    return (a+b)/2
print("=== #522 uses TWO conventions for L[1/2] ===")
for bits in [256,1024]:
    L=bits*log(2)
    print(f"  n=2^{bits:5d}:  sqrt(L ln L)/ln2 = {sqrt(L*log(L))/log(2):8.2f}   [NO sqrt2 - used by the derivation]")
    print(f"              sqrt(2L ln L)/ln2 = {sqrt(2*L*log(L))/log(2):8.2f}   [WITH sqrt2 - used by the s2.2 table]")
print()
print("Derivation  (kN)^(1/4) = exp(sqrt(L ln L)):")
print("   ln k + L < 4 sqrt(L ln L)   -> at ln k=0:  L < 4 sqrt(L ln L) -> L^2 < 16 L ln L -> L < 16 ln L")
L1=bisect(lambda L: 16*log(L)-L, 60, 80)
print(f"   16 ln L < L  -> L* = {L1:.4f}   N* = e^L* = {exp(L1):.4e}   <- paper prints 1.8e29")
print()
print("Table convention (kN)^(1/4) = exp(sqrt(2 L ln L)):")
print("   ln k + L < 4 sqrt(2 L ln L) -> at ln k=0:  L^2 < 32 L ln L -> L < 32 ln L")
L2=bisect(lambda L: 32*log(L)-L, 100, 300)
print(f"   32 ln L < L  -> L* = {L2:.4f}   N* = e^L* = {exp(L2):.4e}   <- the CONSISTENT answer under the paper's own table")
print()
print(f"  Ratio: {exp(L2)/exp(L1):.3e}  = {log10(exp(L2)/exp(L1)):.1f} orders of magnitude")
print()
print("  The paper's TABLE is internally correct (61.85/139.27/306.55/664.40 = WITH sqrt2).")
print("  The paper's HEADLINE threshold 1.8e29 uses the NO-sqrt2 derivation.")
print("  Under the paper's own table convention the threshold is ~%.1fe70." % exp(L2))
