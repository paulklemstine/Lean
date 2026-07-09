"""Draw a straight coordinate line over the four phase wedges and mark its
(at most two) crossings of the phase boundary x^2=y^2."""
import numpy as np
import matplotlib.pyplot as plt

def crossings(a, b, x0, y0):
    A, B, C = a*a-b*b, 2*(x0*a-y0*b), x0*x0-y0*y0
    if abs(A) < 1e-15:
        return [] if abs(B) < 1e-15 else [-C/B]
    d = B*B-4*A*C
    if d < 0:
        return []
    r = np.sqrt(d)
    return sorted({(-B+r)/(2*A), (-B-r)/(2*A)})

a, b, x0, y0 = 1.0, 0.3, -2.0, 0.5
ts = np.linspace(-1, 6, 400)
xs, ys = x0 + ts*a, y0 + ts*b

plt.figure(figsize=(6, 5))
g = np.linspace(-4, 4, 10)
plt.plot(g, g, "k--", lw=1); plt.plot(g, -g, "k--", lw=1)
plt.fill_between(g, g, 4, where=(g <= 0), color="#d6e6ff")
plt.plot(xs, ys, "r-", lw=2, label="coordinate line")
for t in crossings(a, b, x0, y0):
    plt.plot(x0+t*a, y0+t*b, "ko", ms=8)
plt.title("A line crosses the phase boundary at most twice")
plt.xlabel("x"); plt.ylabel("y"); plt.legend(); plt.gca().set_aspect("equal")
plt.xlim(-4, 4); plt.ylim(-4, 4)
plt.tight_layout()
plt.savefig("split_line_crossings.png", dpi=150)
print("wrote split_line_crossings.png")
