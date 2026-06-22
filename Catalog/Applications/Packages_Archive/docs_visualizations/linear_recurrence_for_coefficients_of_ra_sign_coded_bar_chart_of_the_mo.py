import matplotlib.pyplot as plt
from fractions import Fraction
from typing import List

def f_coefficients(N: int) -> List[int]:
    def mul(a, b):
        r = [Fraction(0)] * N
        for i, ai in enumerate(a):
            if ai:
                for j, bj in enumerate(b):
                    if i + j < N and bj:
                        r[i + j] += ai * bj
        return r
    def inv(a):
        r = [Fraction(0)] * N
        r[0] = 1 / a[0]
        for n in range(1, N):
            r[n] = -sum((a[k] if k < len(a) else 0) * r[n - k]
                        for k in range(1, n + 1)) / a[0]
        return r
    f = [Fraction(0)] * N
    n = 0
    while n * n < N:
        t = [Fraction(0)] * N
        t[n * n] = Fraction(1)
        d = [Fraction(0)] * N
        d[0] = Fraction(1)
        for k in range(1, n + 1):
            fac = [Fraction(0)] * N
            fac[0] = Fraction(1)
            if k < N:
                fac[k] = Fraction(1)
            d = mul(mul(d, fac), fac)
        t = mul(t, inv(d))
        f = [f[i] + t[i] for i in range(N)]
        n += 1
    return [int(c) for c in f]

N = 40
a = f_coefficients(N)
xs = list(range(N))
colors = ["tab:blue" if v >= 0 else "tab:red" for v in a]
fig, ax = plt.subplots(figsize=(11, 5))
ax.bar(xs, a, color=colors)
ax.axhline(0, color="black", lw=0.8)
ax.set_title("Coefficients a_n of Ramanujan's mock theta f(q) "
             "(blue >= 0, red < 0): alternating sign from n=2")
ax.set_xlabel("n")
ax.set_ylabel("a_n")
plt.tight_layout()
plt.savefig("fq_coefficients.png", dpi=150)
print("saved fq_coefficients.png")
