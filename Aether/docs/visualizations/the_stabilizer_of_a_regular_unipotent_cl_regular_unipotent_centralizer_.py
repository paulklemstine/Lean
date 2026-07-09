"""Scatter: size of the regular unipotent centralizer in SL_2(F_p) vs 2(p-1)."""
import matplotlib.pyplot as plt
from itertools import product

def centralizer_size(p: int) -> int:
    u = (1, 1, 0, 1)
    def mul(A, B):
        a00,a01,a10,a11 = A; b00,b01,b10,b11 = B
        return ((a00*b00+a01*b10)%p,(a00*b01+a01*b11)%p,
                (a10*b00+a11*b10)%p,(a10*b01+a11*b11)%p)
    def det(A):
        a00,a01,a10,a11=A; return (a00*a11-a01*a10)%p
    G=[M for M in product(range(p),repeat=4) if det(M)==1]
    return sum(1 for M in G if mul(M,u)==mul(u,M))

primes=[2,3,5,7,11]
sizes=[centralizer_size(p) for p in primes]
theory=[len({a for a in range(p) if (a*a)%p==1})*p for p in primes]  # |mu_2|*|F_p|
plt.figure(figsize=(8,5))
plt.plot(primes,sizes,"o-",label="measured |Z(u)|")
plt.plot(primes,theory,"x--",label=r"$|\mu_2|\cdot p$ (predicted)")
plt.title("Regular unipotent centralizer size in SL_2(F_p)")
plt.xlabel("p"); plt.ylabel("centralizer order"); plt.legend()
plt.tight_layout(); plt.savefig("centralizer_size.png", dpi=150)
print("wrote centralizer_size.png")
