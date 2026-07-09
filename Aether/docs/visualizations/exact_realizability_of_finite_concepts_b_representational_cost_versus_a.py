import numpy as np
import matplotlib.pyplot as plt

nodes = np.array([-3.0, -1.7, -0.4, 0.6, 1.9, 2.5, 3.1])

def lstsq_degree(y, d):
    V = np.vander(nodes, d + 1, increasing=True)
    c, *_ = np.linalg.lstsq(V, y.astype(float), rcond=None)
    return c

def min_class_degree(y):
    for d in range(len(nodes)):
        c = lstsq_degree(y, d)
        pred = np.sign(np.vander(nodes, d + 1, increasing=True) @ c)
        if np.all(pred == np.sign(y)):
            return d
    return len(nodes) - 1

labelings = {
    "all +1": np.ones(7, int),
    "one block": np.array([-1,-1,-1,1,1,1,1]),
    "two blocks": np.array([-1,-1,1,1,-1,-1,-1]),
    "three blocks": np.array([-1,1,-1,1,-1,1,-1]).clip(-1,1)[:7],
    "alternating": np.array([(-1)**k for k in range(7)]),
}
A = [sum(l[k] != l[k+1] for k in range(6)) for l in labelings.values()]
D = [min_class_degree(l) for l in labelings.values()]
plt.figure(figsize=(8, 5))
plt.plot(A, D, "o-", color="darkorange")
for name, a, d in zip(labelings, A, D):
    plt.annotate(name, (a, d), textcoords="offset points", xytext=(6, 4))
plt.xlabel("alternation count A"); plt.ylabel("minimal classifying degree")
plt.title("Representational cost tracks alternation count")
plt.grid(alpha=0.3); plt.tight_layout(); plt.savefig("viz_degree.png", dpi=140)
print("saved viz_degree.png")
