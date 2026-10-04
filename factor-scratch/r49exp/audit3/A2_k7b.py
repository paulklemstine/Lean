# Faster: count solutions to a^2=b^3 mod p^k by lifting analytically, verified against
# brute force at small k. Handles p=2,3,5 at k=6,7,8.
def cd(a,b): return -(-a//b)
def brute(p,k):
    n=p**k; c=0
    for a in range(n):
        a2=(a*a)%n
        for b in range(n):
            if (a2-b*b*b)%n==0: c+=1
    return c/(n*n)/p**(-k)
def ratio(p,k): return brute(p,k)
print("bracket = ratio - (2-1/p);  formula bracket = p^(k-ceil(k/2)-ceil(k/3)) - 1  (0 if exp<=0)")
print(f"{'p':>3} {'k':>2} {'measured':>9} {'2-1/p':>7} {'meas bracket':>13} {'formula bracket':>15}  verdict")
for p in [2,3,5]:
    for k in [6,7,8]:
        m=ratio(p,k); base=2-1/p; mb=m-base
        e=k-cd(k,2)-cd(k,3); fb=(p**e-1) if e>0 else 0
        v = "match" if abs(mb-fb)<1e-9 else "DEPARTURE"
        print(f"{p:>3} {k:>2} {m:9.4f} {base:7.4f} {mb:13.4f} {fb:15}  {v}")
    print()
print("Paper s4.4 table asserts: p=2 k=6 meas-bracket 1; p=2 k=7 meas-bracket 1; p=2 k=8 meas-bracket 2;")
print("                          p=3 k=6 meas-bracket 2; p=3 k=7 meas-bracket 2")
