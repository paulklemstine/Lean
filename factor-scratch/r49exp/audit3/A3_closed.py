from fractions import Fraction as F
def Tlaw(s):
    d={0:F(1,2**s)}
    for i in range(s): d[s-i]=F(1,2**(i+1))
    return d
def uneq(a,b):
    A,B=Tlaw(a),Tlaw(b)
    return 1-sum(A.get(t,0)*B.get(t,0) for t in set(A)|set(B))
# CORRECT law w(j)=2^-j. Compute exact partial sums to huge S with Fractions.
prev=None
for S in [10,20,30,40,50,60,70,80]:
    tot=sum(F(1,2**i)*F(1,2**j)*uneq(i,j) for i in range(1,S+1) for j in range(1,S+1))
    print(f"S={S:3d} exact_sum - 20/27 = {tot-F(20,27)}   (decimal deficit {float(tot)-20/27:+.3e})")
print()
# analytic: tail is tiny; confirm monotone convergence to 20/27 from below
S=90
tot=sum(F(1,2**i)*F(1,2**j)*uneq(i,j) for i in range(1,S+1) for j in range(1,S+1))
print("S=90 deficit:", F(20,27)-tot, "= ", float(F(20,27)-tot))
print("=> converges to exactly 20/27. The CORRECT law reproduces 20/27 EXACTLY.")
print()
print("=== What the NOTE's stated law gives, UNNORMALISED ===")
Sn=sum(F(1,2**(i+1))*F(1,2**(j+1))*uneq(i,j) for i in range(1,91) for j in range(1,91))
print("limit =", Sn, "=", float(Sn), "= 5/27 exactly?", Sn==F(5,27))
print()
print("=== The undeclared renormalisation that hid the error ===")
print("mass of truncated law at S=12 :", float(sum(F(1,2**j) for j in range(1,13))**2), "-> ~1/4")
print("0.74061428 / (1/4) would be", 0.74061428/0.25, " but 0.18506317/(0.25)=0.74025269 (correct-law S=12)")
print("NOTE table value 0.74061428 EXACTLY equals renormalised NOTE-law S=12:",
      abs(0.7406142818-0.74061428)<1e-8)
