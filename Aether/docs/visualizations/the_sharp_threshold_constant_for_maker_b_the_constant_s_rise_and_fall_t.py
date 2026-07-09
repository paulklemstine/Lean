import math
import matplotlib.pyplot as plt


def threshold_const(k: int) -> float:
    lb = math.log(k - 1.0) + (k - 2) * math.log(2.0 * (k - 1.0) / k)
    return math.exp(lb / (k - 1.0))


ks = list(range(4, 200))
cs = [threshold_const(k) for k in ks]
peak = max(ks, key=threshold_const)
plt.figure(figsize=(8, 5))
plt.plot(ks, cs, lw=2, label=r"$c_k$")
plt.axhline(2.0, ls="--", color="gray", label="limit = 2")
plt.scatter([peak], [threshold_const(peak)], color="red", zorder=5,
            label=f"peak at k={peak}")
plt.xlabel("cycle length k")
plt.ylabel("threshold constant c_k")
plt.title("Non-monotone threshold constant with limit 2")
plt.legend(); plt.grid(alpha=0.3); plt.tight_layout()
plt.savefig("constant_rise_fall.png", dpi=150)
