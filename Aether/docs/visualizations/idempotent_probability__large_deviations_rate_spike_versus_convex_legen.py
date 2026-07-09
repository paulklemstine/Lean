"""Visualization: the non-convex rate spike and its convex (Legendre) envelope."""
import matplotlib.pyplot as plt

def idempotent_cgf(val, w, lam):
    return max(lam * v + wx for v, wx in zip(val, w))

def lf_biconjugate(val, w, v, lo=-50.0, hi=50.0, steps=100001):
    return max(lam * v - idempotent_cgf(val, w, lam)
               for lam in (lo + (hi - lo) * k / (steps - 1) for k in range(steps)))

val = [0.0, 1.0, 2.0]
w = [0.0, -2.0, 0.0]
rate = [-x for x in w]
env = [lf_biconjugate(val, w, v) for v in val]

fig, ax = plt.subplots(figsize=(7, 5))
ax.plot(val, rate, "o-", color="crimson", lw=2, ms=10, label="rate function I(x)")
ax.plot(val, env, "s--", color="navy", lw=2, ms=8, label="biconjugate (convex envelope)")
ax.annotate("duality gap = 2", xy=(1, 1), xytext=(1.15, 1.4),
            arrowprops=dict(arrowstyle="<->", color="black"), fontsize=12)
ax.vlines(1.0, 0.0, 2.0, colors="gray", linestyles=":", lw=1.5)
ax.set_xlabel("value  val(x)")
ax.set_ylabel("cost")
ax.set_title("Idempotent Cramer duality gap: spike vs. convex envelope")
ax.legend()
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("duality_gap.png", dpi=150)
print("saved duality_gap.png")
