"""Visualization: Maslov dequantization of softmax into a hard maximum.

Plots (1/n) log sum_x exp(n g(x)) against the inverse temperature n, showing
convergence to max_x g(x), together with the uniform error band log(#X)/n.
"""
import math
import matplotlib.pyplot as plt

g = [1.0, -0.5, 2.0, 0.3, -2.0]
peak = max(g)

def scaled_log_partition(g, n):
    m = max(g)
    return m + math.log(sum(math.exp(n*(x-m)) for x in g)) / n

ns = [0.25 + 0.25*k for k in range(80)]
approx = [scaled_log_partition(g, n) for n in ns]
upper = [peak + math.log(len(g))/n for n in ns]

plt.figure(figsize=(8,5))
plt.axhline(peak, color="black", ls="--", label=r"$\max_x g(x)$")
plt.plot(ns, approx, color="C0", lw=2,
         label=r"$\frac{1}{n}\log\sum_x e^{n g(x)}$")
plt.plot(ns, upper, color="C3", ls=":", label=r"$\max_x g + \log(\#X)/n$")
plt.fill_between(ns, [peak]*len(ns), upper, color="C3", alpha=0.1)
plt.xlabel("inverse temperature n")
plt.ylabel("scaled log-partition")
plt.title("Maslov dequantization: softmax -> max-plus integral")
plt.legend()
plt.tight_layout()
plt.savefig("dequantization.png", dpi=150)
print("wrote dequantization.png")
