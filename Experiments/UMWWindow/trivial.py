# Analytic + numeric check: the TRIVIAL one-set construction (T={0}) and its
# exponent, to benchmark what "no real rank-2 structure" buys.
import math
# Trivial construction: partition [n] into m=n^beta blocks of size n^(1-beta);
# S = {product of block}; each i divides its block product. exponent=max(1-beta,beta)/2.
# minimized at beta=1/2 -> exponent 1/4.
print("TRIVIAL one-set construction (T={0}):")
for beta in [0.3,0.4,0.5,0.6,0.7]:
    alpha=1-beta
    print(f"  beta={beta:.1f} alpha={1-beta:.1f} exponent=max(a,b)/2={max(alpha,beta)/2:.3f}")
print("  -> minimized at beta=1/2: exponent=1/4  (Pollard-Strassen territory)\n")

# Numeric: verify block-product cover and its element magnitude for small n.
def lcm(a,b): return a//math.gcd(a,b)*b
def cover_blockproduct(n, beta):
    m=max(1,int(round(n**beta)))
    # partition 1..n into m near-equal blocks
    S=[]
    per=n//m
    x=1
    while x<=n:
        blk=list(range(x,min(x+per,n+1)))
        prod=1
        for i in blk: prod*=i
        S.append(prod)
        x+=per
    # cover: i divides product of its block
    covered=all(any(prod%i==0 for prod in S) for i in range(1,n+1))
    maxel=max(S)
    return m,maxel,covered

for n in [50,100,200]:
    for beta in [0.4,0.5]:
        m,maxel,cov=cover_blockproduct(n,beta)
        # magnitude ~ n^(per) ; alpha ~ (log log M)/(log n)
        alpha=math.log(math.log(maxel))/math.log(n)
        print(f"n={n} beta={beta} |S|={m} maxel={maxel} covered={cov} implied alpha={alpha:.3f} exponent=max/2={max(alpha,math.log(m)/math.log(n))/2:.3f}")
