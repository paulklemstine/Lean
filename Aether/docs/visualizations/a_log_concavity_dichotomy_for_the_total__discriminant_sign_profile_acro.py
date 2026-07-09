"""Plot the sign of the discriminant (L a)(n) for each total Hoggatt sequence.
Zero line for d=1, strictly negative curves for d=2 and d=3."""
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

def Lop(a): return [a[n+1]**2 - a[n]*a[n+2] for n in range(len(a)-2)]

import numpy as np
N = 11
for name, seq in [("2^n (d=1)", geometric(Fraction(2), N)),
                  ("Catalan (d=2)", catalan(N)),
                  ("Baxter (d=3)", baxter(N))]:
    d = Lop(seq)
    # use signed log scale to display very different magnitudes
    y = [np.sign(float(x)) * np.log1p(abs(float(x))) for x in d]
    plt.plot(range(len(y)), y, marker="s", label=name)
plt.axhline(0, color="black", lw=0.8)
plt.xlabel("n"); plt.ylabel("sign * log(1+|L a|)")
plt.title("Discriminant sign: zero (d=1) vs negative (d>=2)")
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig("hoggatt_discriminant.png", dpi=150)
print("saved hoggatt_discriminant.png")
