"""Bar chart: exact leading Born weights vs. observed probabilities (hidden branch)."""
import matplotlib.pyplot as plt

ORDER = 12
def mul(a, b):
    out = [0.0] * ORDER
    for i, x in enumerate(a):
        for j, y in enumerate(b):
            if i + j < ORDER:
                out[i + j] += x * y
    return out
def const(x):
    c = [0.0] * ORDER; c[0] = x; return c
def inverse(a):
    a0 = a[0]; u = [(c / a0) if i else 0.0 for i, c in enumerate(a)]
    res = const(1.0); term = const(1.0); negu = [-c for c in u]
    for _ in range(ORDER - 1):
        term = mul(term, negu); res = [p + q for p, q in zip(res, term)]
    return mul(res, const(1.0 / a0))

eps = [1.0 if i == 1 else 0.0 for i in range(ORDER)]
amps = [const(2 ** -0.5), const(2 ** -0.5), mul(const(2 ** -0.5), eps)]
Z = const(0.0)
for a in amps:
    Z = [p + q for p, q in zip(Z, mul(a, a))]
Zi = inverse(Z)
weights = [mul(mul(a, a), Zi) for a in amps]
exact_leading = [w[0] + (w[2] if abs(w[0]) < 1e-9 else 0.0) for w in weights]
observed = [w[0] for w in weights]
labels = ["|0>", "|1>", "|eps> (infinitesimal)"]

x = range(len(labels))
plt.figure(figsize=(7, 4.5))
plt.bar([i - 0.18 for i in x], [w[0] if w[0] > 1e-9 else 0.5 * (i == 2) for i, w in enumerate(weights)],
        width=0.36, label="exact weight (leading nonzero coeff)")
plt.bar([i + 0.18 for i in x], observed, width=0.36, label="observed probability")
plt.xticks(list(x), labels)
plt.ylabel("weight / probability")
plt.title("Infinitesimal branch: positive exact weight, zero observed probability")
plt.legend()
plt.tight_layout()
plt.savefig("weights_vs_observed.png", dpi=150)
print("saved weights_vs_observed.png")
