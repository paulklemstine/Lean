from math import gcd, lcm

def factor(n):
    f={}
    d=2
    while d*d<=n:
        while n%d==0:
            f[d]=f.get(d,0)+1; n//=d
        d+=1
    if n>1: f[n]=f.get(n,0)+1
    return f

def order(a,n):
    k=1; c=a%n
    while c!=1:
        c=c*a%n; k+=1
    return k

M=lcm(*range(1,21))
print('M',M,factor(M))
for p in [1009,1019,1039]:
    print(p, factor(p-1), 'ord2', order(2,p))
N1=1009*1019; N2=1019*1039
print('N1',N1,'N2',N2)
print('gcd(2^M-1,N1)',gcd(pow(2,M,N1)-1,N1))
print('gcd(2^M-1,N2)',gcd(pow(2,M,N2)-1,N2))
print('ordN1',order(2,N1),'ordN2',order(2,N2))
print('gcd(M,1018)',gcd(M,1018),'gcd(M,1038)',gcd(M,1038))
print('M%1008',M%1008)
# window statistics m=256
for N in (N1,N2):
    w=[pow(2,x,N) for x in range(256)]
    print(N,'distinct',len(set(w)),'maxrun', 'topbit',sum(1 for v in w if v> N//2))


from math import gcd

# 4. distinct count law
bad = 0
for N in range(1, 201):
    for a in range(0, N):
        if gcd(a, N) != 1:
            continue
        # order
        d = 1
        c = a % N
        while c != 1 % N:
            c = c * a % N
            d += 1
        for m in range(0, 41):
            vals = {pow(a, x, N) for x in range(m)}
            if len(vals) != min(m, d):
                bad += 1
                print("COUNTEREXAMPLE", N, a, m, len(vals), min(m, d))
print("distinct-count law violations:", bad)

# 5. pattern word count
for m in range(1, 9):
    pats = set()
    for N in range(1, 121):
        for a in range(0, N):
            if gcd(a, N) != 1:
                continue
            d = 1
            c = a % N
            while c != 1 % N:
                c = c * a % N
                d += 1
            pats.add(tuple(x % min(m, d) for x in range(m)))
    print("m =", m, "distinct pattern words:", len(pats), "bound:", m + 1)
