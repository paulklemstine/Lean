import random, math
from sympy import factorint, primerange, jacobi_symbol
random.seed(20261004)

# --- exact failure formula under Jacobi-conditioning ---
from fractions import Fraction as F
def ps(j): return F(2)**(-j)
def pk(j,k):
    if k<0 or k>j: return F(0)
    return F(1,2**j) if k==0 else F(2**(k-1),2**j)
S={j:ps(j)/sum(ps(x) for x in range(1,41)) for j in range(1,41)}
f_jac=F(0)
for j in S:
    for j2 in S:
        if j==j2: c=F(1)
        else:
            m=max(j,j2)
            c=(1-F(1,m))          # arm that always succeeds, and arm that fails w.p. 1/m
        f_jac += S[j]*S[j2]*(1-c)
print("EXACT Jacobi-conditioned failure = %s"%f_jac)
print("EXACT Jacobi-conditioned success = %.10f"%(1-f_jac))

# --- direct Monte Carlo on real primes ---
def v2(x):
    k=0
    while x%2==0: x//=2; k+=1
    return k

# pool of primes with s = v2(p-1); use SMALL primes -> truncation warning; use a controlled pool
pool=[]
P=primerange(3,400000)
for p in P:
    pool.append(p)
# measure s distribution empirically over this pool
from collections import Counter
sc=Counter(v2(p-1) for p in pool)
print("empirical s-dist (pool<400000):", {k:round(sc[k]/len(pool),5) for k in sorted(sc)})

def order_div(p,g,maxe):
    # compute v2(ord_p(g)) by checking g^( (p-1)/2^i ) != 1 for i<=v2(p-1)
    s=v2(p-1); k=0; e=(p-1)
    while e%2==0:
        e//=2
    # ord_2part = 2^s ; k = number of times we can... standard:
    # g^( (p-1)/2^i ) == 1  for all i <= s-k
    for i in range(s+1):
        if pow(g,(p-1)//2**i,p)==1: k=s-i
        else: break
    return k

# Monte Carlo over random (p,q) pairs and random g
N=30000
res_u=0; res_j=0; tried=0; jac_found=0
for _ in range(N):
    p=random.choice(pool); q=random.choice(pool)
    if p==q or (p&1)==0 or (q&1)==0: continue
    if (p-1)%(q-1)==0 or (q-1)%(p-1)==0: pass
    n=p*q
    g=random.randrange(2,n)
    if math.gcd(g,n)!=1: continue
    tried+=1
    a=order_div(p,g,0); b=order_div(q,g,0)
    if a!=b: res_u+=1
    if jacobi_symbol(g,n)==-1:
        jac_found+=1
        if a!=b: res_j+=1
print("MC uniform-g success = %d/%d = %.5f   (20/27=%.5f)"%(res_u,tried,res_u/tried,20/27))
print("MC Jacobi(-1)-conditioned success = %d/%d = %.5f  (EXACT pred %.5f)"%(res_j,jac_found,res_j/jac_found,float(1-f_jac)))
print("ratio = %.4fx"%((res_j/jac_found)/(res_u/tried)))
