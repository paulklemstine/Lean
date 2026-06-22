"""Visualize Hodge-Betti: harmonic dimension vs (dim ker d - rank e) across complexes."""
import numpy as np
import matplotlib.pyplot as plt

def nrank(M, tol=1e-9):
    return 0 if M.size == 0 else int(np.sum(np.linalg.svd(M, compute_uv=False) > tol))
def dimker(M, tol=1e-9):
    return M.shape[1] - nrank(M, tol)

D = np.array([[-1.,0.,-1.],[1.,-1.,0.],[0.,1.,1.]])
E_filled = np.array([[1.],[1.],[-1.]])
E_hollow = np.zeros((3, 0))

cases = {"filled triangle": E_filled, "hollow triangle": E_hollow}
harm, betti, labels = [], [], []
for name, E in cases.items():
    Delta = D.T @ D + E @ E.T
    harm.append(dimker(Delta))
    betti.append(dimker(D) - nrank(E))
    labels.append(name)

x = np.arange(len(labels)); w = 0.35
fig, ax = plt.subplots(figsize=(7, 5))
ax.bar(x - w/2, harm, w, label="dim ker Delta (harmonic)")
ax.bar(x + w/2, betti, w, label="dim ker d - rank e (Betti)")
ax.set_xticks(x); ax.set_xticklabels(labels)
ax.set_ylabel("dimension"); ax.set_title("Hodge-Betti identity holds case by case")
ax.legend(); fig.tight_layout(); plt.savefig("hodge_betti.png", dpi=150)
print("wrote hodge_betti.png")
