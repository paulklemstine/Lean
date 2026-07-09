import matplotlib.pyplot as plt
import numpy as np
from math import comb

def gamma_basis_coeffs(n, i):
    top = n - 2 * i
    return [comb(top, k - i) if i <= k <= i + top else 0 for k in range(n + 1)]

n = 8
plt.figure(figsize=(9, 5))
for i in range(n // 2 + 1):
    c = gamma_basis_coeffs(n, i)
    plt.plot(range(n + 1), c, marker="o", label=f"B_{{{n},{i}}} = t^{i}(1+t)^{n-2*i}")
plt.title(f"Gamma-basis elements are palindromic about n/2 = {n/2}")
plt.xlabel("degree k"); plt.ylabel("coefficient")
plt.axvline(n / 2, ls="--", color="grey")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("gamma_basis.png", dpi=150)
print("saved gamma_basis.png")
