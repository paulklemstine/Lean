import numpy as np
import matplotlib.pyplot as plt

n = 8
A = list(range(-n, n + 1))
outputs = sorted({a * a for a in A})
out_index = {v: j for j, v in enumerate(outputs)}
M = np.zeros((len(A), len(outputs)))
for i, a in enumerate(A):
    M[i, out_index[a * a]] = 1

plt.figure(figsize=(6, 8))
plt.imshow(M, aspect="auto", cmap="Blues")
plt.yticks(range(len(A)), A)
plt.xticks(range(len(outputs)), outputs, rotation=90)
plt.xlabel("output value  a^2")
plt.ylabel("input value  a")
plt.title("Fiber structure of f(x)=x^2 on {-8,...,8}")
plt.tight_layout()
plt.savefig("fiber_heatmap.png", dpi=150)
print("wrote fiber_heatmap.png")
