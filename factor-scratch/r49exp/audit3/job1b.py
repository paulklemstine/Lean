from mpmath import mp, mpf, sqrt, ln, exp, findroot
mp.dps=40
LN2=ln(2)
def L_(bits): return mpf(bits)*LN2

print("=== JOB 1: ln k = 4*sqrt(L ln L) - L, the formula the paper PRINTS ===")
for bits,claim in ((1024,-436.7),(2048,-1013.5),(4096,-2238.1)):
    L=L_(bits); v=4*sqrt(L*ln(L))-L
    print(f"n={bits:>5}  paper={claim:>9}  exact={mp.nstr(v,12)}  rounds_to={float(v):.1f}  delta={float(v)-claim:+.3f}")

print()
print("*** BUT: which L[1/2] does the paper's OWN table use? ***")
print("caption (line 192): log2 L[1/2] = sqrt(2 lnN lnlnN)/ln2   -> L[1/2] = exp(sqrt(2 L ln L))")
print("derivation (line 21): (kN)^(1/4) = exp(sqrt(L ln L))       -> NO sqrt(2)")
print("These differ by a factor sqrt(2) in the exponent. Solving consistently with the TABLE's L[1/2]:")
print()
for bits in (1024,2048,4096):
    L=L_(bits)
    v_tab = 4*sqrt(2*L*ln(L))-L
    v_pap = 4*sqrt(L*ln(L))-L
    print(f"n={bits:>5}  paper prints {float(v_pap):9.1f}   table-consistent {float(v_tab):9.1f}   diff {float(v_tab-v_pap):+.1f}")

print()
print("=== boundary under each convention ===")
for cname,coeff in (("paper text  16 ln L < L",16),("table-consistent 32 ln L < L",32)):
    f=lambda x: coeff*ln(x)-x
    r=findroot(f, mpf(60) if coeff==16 else mpf(200))
    print(f"{cname:>32}:  L* = {mp.nstr(r,12)}   N* = exp(L*) = {mp.nstr(exp(r),8)}")
print("paper prints: L* = 67.361, N* = 1.797e29")
print()
f16=lambda x: 16*ln(x)-x
r=findroot(f16, mpf(60)); print("verify 16lnL=L root:", mp.nstr(r,12), " e^L=", mp.nstr(exp(r),8), " old 5400 -> ratio", mp.nstr(exp(r)/5400,6))
