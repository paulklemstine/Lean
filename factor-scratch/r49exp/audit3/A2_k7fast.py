import numpy as np
def ratio(p,k):
    n=p**k
    r=np.arange(n,dtype=np.int64)
    a2=(r*r)%n
    B=(r.astype(np.int64)**3)%n
    # count (a,b) with a^2 == b^3 mod n  -> for each a, match b
    cnt=0
    for a in range(n):
        cnt+=int(np.count_nonzero(B==a2[a]))
    return cnt/(n*n)/p**(-k)
def cd(a,b): return -(-a//b)
print("Paper s4.4 asserts the k>=7 departure is GENERAL (p=2 AND p=3 alike), not p=2-specific.")
print(f"{'p':>3} {'k':>2} {'measured':>9} {'2-1/p':>7} {'meas bracket':>13} {'formula bracket':>15}  verdict")
for p,ks in [(2,[6,7,8]),(3,[6,7,8]),(5,[6])]:
    for k in ks:
        m=ratio(p,k); base=2-1/p; mb=m-base
        e=k-cd(k,2)-cd(k,3); fb=(p**e-1) if e>0 else 0
        v="match" if abs(mb-fb)<1e-9 else ">>> DEPARTURE"
        print(f"{p:>3} {k:>2} {m:9.4f} {base:7.4f} {mb:13.4f} {fb:15}  {v}")
    print()
