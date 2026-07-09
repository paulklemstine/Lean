"""Bar chart of information content for the three thought archetypes."""
import cmath
import math
import matplotlib.pyplot as plt


def info(jones):
    t = cmath.exp(1j * math.pi / 3)
    m = abs(jones(t))
    return math.log(m) if m > 0 else 0.0


knots = {
    "trivial": lambda t: 1 + 0j,
    "trefoil (creative)": lambda t: -t**-4 + t**-3 + t**-1,
    "figure-eight (confused)": lambda t: t**-2 - t**-1 + 1 - t + t**2,
}
names = list(knots)
vals = [info(knots[k]) for k in names]
plt.figure(figsize=(7, 4))
plt.bar(names, vals, color=["#999999", "#dd8452", "#55a868"])
plt.axhline(0.5 * math.log(3), ls="--", color="k", label="(1/2) log 3")
plt.title("Information content of thought archetypes")
plt.ylabel("I = log|V(e^{i pi/3})|")
plt.legend()
plt.tight_layout()
plt.savefig("information_bar.png", dpi=150)
print("saved information_bar.png")
