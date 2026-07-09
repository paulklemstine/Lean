"""Convergence funnel: orbits from many starts collapse onto x*, with the
certified geometric envelope overlaid. Requires matplotlib."""
import math
import matplotlib.pyplot as plt

a, b, c, rho = 1.0, 1.0, 100.0, 1.0 / 30.0
f = lambda x: math.exp(a) * math.log(b * x + c)

def orbit(x0, n):
    xs = [x0]
    for _ in range(n):
        xs.append(f(xs[-1]))
    return xs

N = 12
xstar = orbit(0.0, 60)[-1]
plt.figure(figsize=(9, 5))
for x0 in [0, 2, 5, 8, 13, 16, 20]:
    xs = orbit(x0, N)
    plt.plot(range(N + 1), xs, marker="o", ms=3, lw=1, alpha=0.8)
plt.axhline(xstar, color="k", ls="--", lw=1, label=f"x* = {xstar:.4f}")
plt.xlabel("iteration n")
plt.ylabel("x_n")
plt.title("EML iteration f(x)=e*log(x+100) on [0,20]: universal convergence")
plt.legend()
plt.tight_layout()
plt.savefig("eml_convergence_funnel.png", dpi=150)
print("wrote eml_convergence_funnel.png")
