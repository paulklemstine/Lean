import matplotlib.pyplot as plt
from functools import lru_cache

def poly_add(a, b):
    out = [0]*max(len(a), len(b))
    for i,c in enumerate(a): out[i]+=c
    for i,c in enumerate(b): out[i]+=c
    return out

@lru_cache(maxsize=None)
def q_binomial(m, n):
    if m == 0 or n == 0:
        return (1,)
    return tuple(poly_add(list(q_binomial(m, n-1)), [0]*n + list(q_binomial(m-1, n))))

m, n = 5, 5
coeffs = q_binomial(m, n)
plt.figure(figsize=(8, 4))
plt.bar(range(len(coeffs)), coeffs, color="#3b82f6")
plt.xlabel("area (power of q)")
plt.ylabel("number of paths")
plt.title(f"Area distribution of paths to ({m},{n}) = coefficients of [{m+n} choose {n}]_q "
          f"(palindromic, sum = {sum(coeffs)})")
plt.tight_layout()
plt.savefig("q_binomial_area_distribution.png", dpi=150)
print("wrote q_binomial_area_distribution.png")
