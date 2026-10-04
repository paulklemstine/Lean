from math import log, exp
def bisect(f,a,b,it=300):
    fa=f(a)
    for _ in range(it):
        m=(a+b)/2; fm=f(m)
        if fa*fm<=0: b=m
        else: a=m; fa=fm
    return (a+b)/2
f=lambda L: 16*log(L)-L
Lstar=bisect(f,60,80)
print(f"large root of 16 ln L = L : L* = {Lstar:.6f}   paper says 67.361 -> {'MATCH' if abs(Lstar-67.361)<5e-3 else 'MISMATCH'}")
print(f"N* = e^L* = {exp(Lstar):.4e}  paper says 1.797e29 -> {'MATCH' if abs(exp(Lstar)/1.797e29-1)<3e-3 else 'MISMATCH'}")
print()
print("SELF-TEST (must return null where null is correct): the OLD formula's boundary")
g=lambda L: 4*log(L)-L
Lold=bisect(g,6,20)
print(f"  old 2 sqrt(L ln L) law -> 4 ln L = L -> L* = {Lold:.4f}, N* = e^L* = {exp(Lold):.4e}")
print(f"  paper's withdrawn claim was L<8.6 -> e^8.6 = {exp(8.6):.4e}  (order of magnitude check: 4lnL=L at L~8.6? {abs(g(8.6)):.4f})")
print()
print("ln k at RSA sizes (formula ln k = 4 sqrt(L ln L) - L):")
for bits in [256,512,1024,2048,4096]:
    L=bits*log(2); lk=4*(L*log(L))**0.5-L
    print(f"  n=2^{bits:5d}: L={L:9.3f}  ln k={lk:12.1f}  -> {'k<1 (excluded)' if lk<0 else 'k>1'}")
