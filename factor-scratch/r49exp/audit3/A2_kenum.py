# Exhaustively verify #523's ratio tables: ratio = P(p^k | a^2-b^3) / p^-k over ALL (a,b) mod p^k
def ratio(p,k):
    n=p**k; c=0
    for a in range(n):
        a2=(a*a)%n
        for b in range(n):
            if (a2-b*b*b)%n==0: c+=1
    return c/(n*n)/p**(-k)
print("paper #523 s2 table (claims 2-1/p for k=2..4):")
print(f"{'p':>3} {'k=1':>8} {'k=2':>8} {'k=3':>8} {'k=4':>8}   2-1/p")
for p in [3,5,7,11,13]:
    row=[ratio(p,k) for k in [1,2,3,4]]
    print(f"{p:>3} "+" ".join(f"{v:8.4f}" for v in row)+f"   {2-1/p:.4f}")
print()
print("paper #523 s4.1 table (k=6 departure = +(p-1)):")
for p in [3,5]:
    r=[ratio(p,k) for k in [4,5,6]]
    print(f"  p={p}: k=4 {r[0]:.4f}  k=5 {r[1]:.4f}  k=6 {r[2]:.4f}   paper: 1.6667/1.6667/3.6667" if p==3 else f"  p={p}: k=4 {r[0]:.4f}  k=5 {r[1]:.4f}  k=6 {r[2]:.4f}   paper: 1.8000/1.8000/5.8000")
print(f"  deviation at k=6: p=3 -> {ratio(3,6)-(2-1/3):.4f} (paper +2.0 = p-1=2)   p=5 -> {ratio(5,6)-(2-1/5):.4f} (paper +4.0 = p-1=4)")
