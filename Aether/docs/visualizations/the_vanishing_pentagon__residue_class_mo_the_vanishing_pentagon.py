"""Draw the regular pentagon of fifth roots and the vanishing balanced block."""
import cmath, math
import matplotlib.pyplot as plt

ZETA = cmath.exp(2j * math.pi / 5)
roots = [ZETA ** i for i in range(5)]

plt.figure(figsize=(6, 6))
# unit circle
theta = [2 * math.pi * t / 400 for t in range(401)]
plt.plot([math.cos(a) for a in theta], [math.sin(a) for a in theta],
         color="gray", lw=0.6)
# roots as arrows from origin
for i, z in enumerate(roots):
    plt.annotate("", xy=(z.real, z.imag), xytext=(0, 0),
                 arrowprops=dict(arrowstyle="->", color="C0"))
    plt.text(1.12 * z.real, 1.12 * z.imag, f"zeta^{i}", ha="center")
# tip-to-tail closed pentagon (sums to zero)
acc = 0 + 0j
path = [acc]
for z in roots:
    acc += z
    path.append(acc)
plt.plot([p.real for p in path], [p.imag for p in path],
         color="crimson", lw=1.5, label="tip-to-tail: closes to 0")
plt.gca().set_aspect("equal")
plt.title("1 + zeta + zeta^2 + zeta^3 + zeta^4 = 0")
plt.legend(); plt.savefig("pentagon_zero.png", dpi=150)
