import numpy as np
import matplotlib.pyplot as plt

def fisher_form(p, v, w):
    return sum(vi * wi / pi for pi, vi, wi in zip(p, v, w))

# barycentric grid over the 2-simplex (p0, p1, p2), tangent v = (1, -1, 0)
N = 200
vals = np.full((N, N), np.nan)
v = [1.0, -1.0, 0.0]
for i, a in enumerate(np.linspace(0.01, 0.98, N)):
    for j, b in enumerate(np.linspace(0.01, 0.98, N)):
        c = 1 - a - b
        if c <= 0.01:
            continue
        p = [a, b, c]
        vals[j, i] = fisher_form(p, v, v)

plt.figure(figsize=(7, 6))
plt.imshow(np.log10(vals), origin="lower", extent=[0, 1, 0, 1], aspect="auto")
plt.colorbar(label=r"$\log_{10} g_p(v,v)$,  $v=(1,-1,0)$")
plt.xlabel(r"$p_0$")
plt.ylabel(r"$p_1$")
plt.title("Fisher length of a fixed direction over the 2-simplex")
plt.tight_layout()
plt.savefig("fisher_heatmap.png", dpi=150)
print("saved fisher_heatmap.png")
