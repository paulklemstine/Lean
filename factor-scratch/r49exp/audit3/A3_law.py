from fractions import Fraction as F

# v2(ord_p g) for g=a^j uniform in cyclic group of order 2^s*u.
# j uniform mod 2^s -> i = v2(j): P(i)=2^-(i+1) for i<s, P(j==0 mod 2^s)=2^-s
# T = s - min(s, i) = max(0, s-i)
def Tlaw(s):
    d = {}
    # T=0 iff i>=s  -> prob 2^-s
    d[0] = F(1,2**s)
    for i in range(s):
        d[s-i] = F(1,2**(i+1))
    return d

def uneq(s1,s2):
    a,b = Tlaw(s1), Tlaw(s2)
    keys = set(a)|set(b)
    same = sum(a.get(t,0)*b.get(t,0) for t in keys)
    return 1-same

# (a) law of s = v2(p-1) for random primes
Ps = lambda j: F(1,2**(j+1))

def average(Smax):
    tot = F(0); w = F(0)
    for i in range(1,Smax+1):
        for j in range(1,Smax+1):
            wi,wj = Ps(i),Ps(j)
            tot += wi*wj*uneq(i,j); w += wi*wj
    return tot/w

print("=== (a) table check: P(unequal | s_p=i, s_q=j) ===")
for i in range(1,4):
    print(i, [f"{float(uneq(i,j)):.4f}" for j in range(1,7)])
print("paper row1: 0.5000 0.7500 0.8750 0.9375 0.9688 0.9844")
print("paper row2: 0.7500 0.6250 0.8125 0.9062 0.9531 0.9766")
print("paper row3: 0.8750 0.8125 0.6562 0.8281 0.9141 0.9570")
print()
print("=== (b) truncated average (renormalised) ===")
for S in [6,8,10,12,14,16,20,24,30,40]:
    a = average(S)
    print(f"  Smax={S:3d}  avg={float(a):.10f}  20/27={20/27:.10f}  diff={float(a)-20/27:+.3e}")
print()
print("=== (b2) UNnormalised (mass truncated) ===")
def unnorm(S):
    tot=F(0)
    for i in range(1,S+1):
        for j in range(1,S+1):
            tot += Ps(i)*Ps(j)*uneq(i,j)
    return tot
for S in [6,8,10,12,14,16,20,24,30,40]:
    a = unnorm(S)
    print(f"  Smax={S:3d}  avg={float(a):.10f}  diff={float(a)-20/27:+.3e}")
