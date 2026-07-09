import numpy as np
import matplotlib.pyplot as plt

def phi(x: np.ndarray) -> np.ndarray:
    return np.tanh(x) + 0.31 * x  # injective feature map

inputs = np.array([-4.0, -2.5, -1.0, 0.5, 2.0, 3.5])
labels = np.array([1, -1, -1, 1, -1, 1])
nodes = phi(inputs)

def lagrange(t):
    total = np.zeros_like(t)
    for i in range(len(nodes)):
        term = np.full_like(t, float(labels[i]))
        for j in range(len(nodes)):
            if j != i:
                term *= (t - nodes[j]) / (nodes[i] - nodes[j])
        total += term
    return total

xs = np.linspace(inputs.min() - 0.5, inputs.max() + 0.5, 800)
plt.figure(figsize=(9, 5))
plt.axhline(0, color="gray", lw=0.8)
plt.axhline(1, color="green", ls="--", lw=0.7)
plt.axhline(-1, color="red", ls="--", lw=0.7)
plt.plot(xs, lagrange(phi(xs)), color="navy", label="N(x) = p(phi(x))")
plt.scatter(inputs, labels, c=["green" if y > 0 else "red" for y in labels],
            zorder=5, s=70, edgecolor="k", label="labeled samples")
plt.title("Exact realizability: network hits every label with unit margin")
plt.xlabel("input x"); plt.ylabel("output")
plt.legend(); plt.tight_layout(); plt.savefig("viz_readout.png", dpi=140)
print("saved viz_readout.png")
