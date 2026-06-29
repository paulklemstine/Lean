"""Visualization: exponential-polynomial approximation on [0,1] (matplotlib)."""
import math
import matplotlib.pyplot as plt

def fit(target, k, n=400):
    grid = [i / (n - 1) for i in range(n)]
    m = k + 1
    A = [[0.0] * m for _ in range(m)]; y = [0.0] * m
    for x in grid:
        b = [math.exp(j * x) for j in range(m)]; t = target(x)
        for r in range(m):
            y[r] += b[r] * t
            for c in range(m): A[r][c] += b[r] * b[c]
    aug = [A[i][:] + [y[i]] for i in range(m)]
    for col in range(m):
        p = max(range(col, m), key=lambda r: abs(aug[r][col]))
        aug[col], aug[p] = aug[p], aug[col]; d = aug[col][col]
        for c in range(col, m + 1): aug[col][c] /= d
        for r in range(m):
            if r != col:
                f = aug[r][col]
                for c in range(col, m + 1): aug[r][c] -= f * aug[col][c]
    return [aug[r][m] for r in range(m)]

def ev(coef, x): return sum(c * math.exp(j * x) for j, c in enumerate(coef))

target = lambda x: math.sin(2 * math.pi * x)
xs = [i / 400 for i in range(401)]
plt.figure(figsize=(9, 5))
plt.plot(xs, [target(x) for x in xs], "k-", lw=2.5, label="target sin(2 pi x)")
for k in (2, 4, 8):
    c = fit(target, k)
    plt.plot(xs, [ev(c, x) for x in xs], "--", label=f"degree {k} in e^x")
plt.title("Density: polynomials in e^x approximate any continuous f on [0,1]")
plt.legend(); plt.grid(alpha=0.3)
plt.tight_layout(); plt.savefig("exp_density.png", dpi=150)
print("wrote exp_density.png")
