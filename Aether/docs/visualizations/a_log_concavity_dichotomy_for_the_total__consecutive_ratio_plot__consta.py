"""Plot consecutive ratios a(n+1)/a(n) for the three total Hoggatt sequences.
Nonincreasing ratios => log-concave; increasing ratios => log-convex."""
import matplotlib.pyplot as plt
from fractions import Fraction
from math import comb

def geometric(r, L): return [r ** n for n in range(L)]
def catalan(L):
    out = [Fraction(1)]
    for n in range(L - 1): out.append(Fraction(2*(2*n+1), n+2) * out[-1])
    return out
def baxter(L):
    out = []
    for n in range(L):
        if n == 0: out.append(Fraction(1)); continue
        d = comb(n+1,1)*comb(n+1,2)
        t = sum(comb(n+1,k-1)*comb(n+1,k)*comb(n+1,k+1) for k in range(1,n+1))
        out.append(Fraction(t, d))
    return out

def ratios(seq): return [float(seq[i+1]/seq[i]) for i in range(len(seq)-1)]

N = 12
for name, seq in [("2^n (d=1)", geometric(Fraction(2), N)),
                  ("Catalan (d=2)", catalan(N)),
                  ("Baxter (d=3)", baxter(N))]:
    plt.plot(range(N-1), ratios(seq), marker="o", label=name)
plt.xlabel("n"); plt.ylabel("a(n+1)/a(n)")
plt.title("Consecutive ratios: constant (d=1) vs increasing (d>=2)")
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("hoggatt_ratios.png", dpi=150)
print("saved hoggatt_ratios.png")
