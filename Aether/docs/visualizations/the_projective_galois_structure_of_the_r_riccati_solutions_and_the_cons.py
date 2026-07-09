"""Visualize the constancy of the Riccati cross-ratio across x."""
import math
import matplotlib.pyplot as plt

def riccati_solution(A, B):
    def v(x):
        ex, emx = math.exp(x), math.exp(-x)
        return (A * ex - B * emx) / (A * ex + B * emx)
    return v

def cross_ratio(a, b, c, d):
    return ((a - c) * (b - d)) / ((a - d) * (b - c))

xs = [(-3 + 0.05 * i) for i in range(121)]
vs = [riccati_solution(1, 0), riccati_solution(0, 1),
      riccati_solution(1, 1), riccati_solution(2, 0.5)]

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
for (A, B), name in zip([(1, 0), (0, 1), (1, 1), (2, 0.5)],
                        ["v1", "v2", "v3", "v4"]):
    v = riccati_solution(A, B)
    ax1.plot(xs, [v(x) for x in xs], label=name)
ax1.set_title("Four Riccati solutions v(x) of v' + v^2 = 1")
ax1.set_xlabel("x"); ax1.set_ylabel("v(x)"); ax1.legend(); ax1.grid(True)

cr = [cross_ratio(vs[0](x), vs[1](x), vs[2](x), vs[3](x)) for x in xs]
ax2.plot(xs, cr, color="crimson", linewidth=2)
ax2.set_title("Cross-ratio [v1,v2;v3,v4] is constant (PGL2 invariant)")
ax2.set_xlabel("x"); ax2.set_ylabel("cross-ratio")
ax2.set_ylim(min(cr) - 1, max(cr) + 1); ax2.grid(True)

plt.tight_layout()
plt.savefig("cross_ratio_invariance.png", dpi=150)
print("Saved cross_ratio_invariance.png")
