"""Bar chart: certified proportion (1/9)(1+c) vs weight dispersion c."""
import matplotlib.pyplot as plt


def cauchy_schwarz_deficit(w):
    k = len(w)
    mu = sum(w) / k
    var = sum((x - mu) ** 2 for x in w) / k
    return var / (mu * mu) if mu else 0.0


configs = {
    "uniform": [1, 1, 1, 1],
    "mild": [1.0, 1.2, 0.8, 1.5],
    "moderate": [0.5, 1.5, 1.0, 2.0],
    "heavy": [0.2, 3.0, 0.1, 2.7],
}
names = list(configs)
bounds = [(1 / 9) * (1 + cauchy_schwarz_deficit(configs[n])) for n in names]

fig, ax = plt.subplots(figsize=(8, 5))
ax.bar(names, bounds, color="#3b6ea5")
ax.axhline(1 / 9, color="crimson", ls="--", label="base bound 1/9")
ax.set_ylabel("certified proportion lower bound")
ax.set_title("Harvesting the Cauchy--Schwarz deficit")
ax.legend()
plt.tight_layout()
plt.savefig("deficit_bounds.png", dpi=150)
print("wrote deficit_bounds.png")
