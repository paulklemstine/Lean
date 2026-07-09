import numpy as np
import matplotlib.pyplot as plt

rng = np.random.default_rng(3)
inputs = np.sort(rng.uniform(-4, 4, 6))
labels = rng.choice([-1, 1], 6).astype(float)
phi = lambda x: 0.5 * x + np.sin(0.3 * x)
nodes = phi(inputs)
sep = min(abs(nodes[i]-nodes[j]) for i in range(6) for j in range(i+1,6))

def coeffs(t):
    return np.linalg.solve(np.vander(t, 6, increasing=True), labels)

base = coeffs(nodes)
eps_grid = np.linspace(0, 0.49*sep, 25)
moves, errs = [], []
for eps in eps_grid:
    dn = nodes + rng.uniform(-eps, eps, 6)
    c = coeffs(dn)
    moves.append(np.max(np.abs(c - base)))
    errs.append(np.max(np.abs(np.vander(dn, 6, increasing=True) @ c - labels)))
fig, ax = plt.subplots(1, 2, figsize=(11, 4))
ax[0].plot(eps_grid/sep, moves, color="purple"); ax[0].set_xlabel("drift / sep")
ax[0].set_ylabel("max coeff change"); ax[0].set_title("coefficients move continuously")
ax[1].semilogy(eps_grid/sep, np.array(errs)+1e-18, color="teal"); ax[1].set_xlabel("drift / sep")
ax[1].set_ylabel("max interpolation error"); ax[1].set_title("exactness preserved")
plt.tight_layout(); plt.savefig("viz_stability.png", dpi=140)
print("saved viz_stability.png")
