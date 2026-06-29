"""Visualize the Bernoulli Fisher information 1/(s(1-s)) and KL valleys.

Saves 'fisher_bernoulli.png'. Requires matplotlib + numpy.
"""
import numpy as np
import matplotlib.pyplot as plt

def bernoulli_fisher(s):
    return 1.0/(s*(1.0-s))

def kl_bernoulli(s, t):
    return s*np.log(s/t) + (1-s)*np.log((1-s)/(1-t))

s = np.linspace(0.02, 0.98, 400)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

ax1.plot(s, bernoulli_fisher(s), lw=2, color="crimson")
ax1.set_title("Fisher information of a coin:  G(s) = 1/(s(1-s))")
ax1.set_xlabel("success probability s"); ax1.set_ylabel("Fisher information")
ax1.axvline(0.5, ls="--", color="gray"); ax1.set_ylim(0, 60)
ax1.annotate("flattest at s=1/2", (0.5, 4), (0.55, 20),
             arrowprops=dict(arrowstyle="->"))

t = np.linspace(0.02, 0.98, 400)
for s0, c in [(0.5, "navy"), (0.9, "darkorange")]:
    ax2.plot(t, kl_bernoulli(s0, t), lw=2, color=c, label=f"KL(s0={s0} || t)")
ax2.set_title("KL valleys: steeper where Fisher info is larger")
ax2.set_xlabel("t"); ax2.set_ylabel("KL(s0 || t)"); ax2.legend()
ax2.set_ylim(0, 3)

plt.tight_layout(); plt.savefig("fisher_bernoulli.png", dpi=130)
print("saved fisher_bernoulli.png")
