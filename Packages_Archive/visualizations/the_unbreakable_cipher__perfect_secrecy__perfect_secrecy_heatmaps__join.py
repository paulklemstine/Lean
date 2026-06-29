"""Heatmaps witnessing perfect secrecy of the OTP over Z/n.

Left:  joint P(M=m, C=c)         -- each ROW is prior[m]/n (rank-1 structure).
Mid:   ciphertext marginal P(C=c) -- flat at 1/n.
Right: posterior P(M=m | C=c)    -- every COLUMN equals the prior.
Requires matplotlib + numpy.  Saves otp_perfect_secrecy.png.
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt

n = 6
prior = np.array([10., 1., 1., 5., 0.5, 2.])[:n]
prior = prior / prior.sum()

joint = np.zeros((n, n))
for m in range(n):
    for k in range(n):
        c = (k + m) % n
        joint[m, c] += prior[m] * (1.0 / n)
marginal = joint.sum(axis=0)
posterior = joint / marginal[None, :]

fig, axes = plt.subplots(1, 3, figsize=(15, 4.5))
im0 = axes[0].imshow(joint, cmap="viridis", aspect="auto")
axes[0].set_title("Joint  P(M=m, C=c)")
axes[0].set_xlabel("ciphertext c"); axes[0].set_ylabel("message m")
fig.colorbar(im0, ax=axes[0])

axes[1].bar(range(n), marginal, color="#3b7dd8")
axes[1].axhline(1.0 / n, color="crimson", ls="--", label="1/n")
axes[1].set_title("Ciphertext marginal  P(C=c)")
axes[1].set_xlabel("ciphertext c"); axes[1].legend()

im2 = axes[2].imshow(posterior, cmap="magma", aspect="auto", vmin=0, vmax=prior.max())
axes[2].set_title("Posterior  P(M=m | C=c)  (cols == prior)")
axes[2].set_xlabel("ciphertext c"); axes[2].set_ylabel("message m")
fig.colorbar(im2, ax=axes[2])

fig.suptitle("Perfect secrecy of the one-time pad over Z/%d" % n, fontsize=14)
fig.tight_layout()
fig.savefig("otp_perfect_secrecy.png", dpi=130)
print("saved otp_perfect_secrecy.png")
