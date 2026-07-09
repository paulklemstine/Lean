"""Visualize the affine-torsor picture: the kernel (all-crossing directions)
and its translate by t (bipartite partial duals) as two parallel cosets."""
from itertools import product
import matplotlib.pyplot as plt

def cross(J, x):
    n = len(J)
    return tuple(sum(J[e][k] * x[k] for k in range(n)) % 2 for e in range(n))

J = [[0, 1, 1], [1, 0, 1], [1, 1, 0]]
t = (1, 0, 0)
zero = (0, 0, 0)
ker = [x for x in product((0, 1), repeat=3) if cross(J, x) == zero]
duals = [tuple((a + b) % 2 for a, b in zip(k, t)) for k in ker]

def to_int(v):
    return v[0] * 4 + v[1] * 2 + v[2]

plt.figure(figsize=(8, 4))
plt.scatter([to_int(v) for v in ker], [0] * len(ker), s=200, c="#1f77b4",
            label="all-crossing directions (ker)")
plt.scatter([to_int(v) for v in duals], [1] * len(duals), s=200, c="#d62728",
            label="bipartite partial duals (t + ker)")
for k, d in zip(ker, duals):
    plt.plot([to_int(k), to_int(d)], [0, 1], "k--", alpha=0.4)
plt.yticks([0, 1], ["ker", "t + ker"])
plt.xlabel("subset encoded as integer 0..7")
plt.title("Affine bijection C(phi) = phi + t")
plt.legend(); plt.tight_layout(); plt.savefig("affine_torsor.png", dpi=150)
print("wrote affine_torsor.png")
