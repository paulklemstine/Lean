import numpy as np
import matplotlib.pyplot as plt
from math import comb

# A 1-D data manifold (parabola) in a 2-D ambient plane and the resulting bound.
t = np.linspace(-2, 2, 200)
curve = np.stack([t, t**2], axis=1)
pts_t = np.array([-2, -1, 0, 1, 2.0])
pts = np.stack([pts_t, pts_t**2], axis=1)

fig, ax = plt.subplots(1, 2, figsize=(11, 4.5))
ax[0].plot(curve[:, 0], curve[:, 1], "b-", alpha=0.6, label="data manifold (d=1)")
ax[0].scatter(pts[:, 0], pts[:, 1], c="red", zorder=5, label="N=5 samples")
ax[0].set_title("Low-dimensional structure in ambient space")
ax[0].legend(); ax[0].set_xlabel("x1"); ax[0].set_ylabel("x2")

def C(N: int, d: int) -> int:
    return 2 * sum(comb(N-1, k) for k in range(d))
Ns = list(range(1, 11)); p = 1 + 2 + 1
ax[1].plot(Ns, [2**N for N in Ns], "k--", label="2^N (unconstrained)")
ax[1].plot(Ns, [C(N, p) for N in Ns], "g-o", label=f"C(N, d+M'+1), p={p}")
ax[1].set_yscale("log"); ax[1].set_xlabel("sample size N"); ax[1].legend()
ax[1].set_title("Bound set by intrinsic d, not ambient M")
plt.tight_layout(); plt.savefig("manifold_bound.png", dpi=150)
print("saved manifold_bound.png")
