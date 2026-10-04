# #523 s4.4: "the k>=7 departure is GENERAL, not p=2-specific."
# Table claims: p=3 k=7 measured 3.67 (bracket 2), p=5 k=6 bracket 4.
# Enumerate ALL primes at k=6,7,8 and test whether the departure is general.
def ratio(p,k):
    n=p**k; c=0
    for a in range(n):
        a2=(a*a)%n
        for b in range(n):
            if (a2-b*b*b)%n==0: c+=1
    return c/(n*n)/p**(-k)
def ceil_div(a,b): return -(-a//b)
print("bracket = measured_ratio - (2-1/p)  ; formula bracket = p^(k-ceil(k/2)-ceil(k/3)) - 1")
print(f"{'p':>3} {'k':>2} {'measured':>9} {'2-1/p':>7} {'meas bracket':>13} {'formula bracket':>15} {'match':>7}")
for p in [2,3,5]:
    for k in [6,7,8]:
        m=ratio(p,k); base=2-1/p; mb=m-base
        e=k-ceil_div(k,2)-ceil_div(k,3)
        fb=p**e-1 if e>0 else 0
        print(f"{p:>3} {k:>2} {m:9.4f} {base:7.4f} {mb:13.4f} {fb:15} {'OK' if abs(mb-fb)<1e-9 else 'MISMATCH':>7}")
    print()
