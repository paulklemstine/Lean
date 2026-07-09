import math
import numpy as np
import matplotlib.pyplot as plt

def bin_entropy_nats(q):
    q = np.asarray(q, dtype=float)
    out = np.zeros_like(q)
    m = (q > 0) & (q < 1)
    out[m] = -q[m]*np.log(q[m]) - (1-q[m])*np.log(1-q[m])
    return out

def secure_key_rate(q):
    return math.log(2.0) - 2.0*bin_entropy_nats(q)

Q = np.linspace(0, 0.5, 1000)
R = secure_key_rate(Q)
fig, ax = plt.subplots(figsize=(9, 5.5))
ax.plot(Q, R, lw=2.2, color="#1b3b6f", label=r"$secureKeyRate(Q)=\log 2 - 2\,binEntropy(Q)$")
ax.axhline(0, color="gray", lw=1)
ax.axvline(0.110028, color="#c1121f", ls="--", lw=1.6, label=r"$p^\star\approx 0.110$ (~11%)")
ax.axvspan(1/16, 1/8, color="#ffd166", alpha=0.25, label=r"integer-certified bracket $(1/16,1/8)$")
ax.axvline(0.25, color="#2a9d8f", ls=":", lw=1.6, label=r"intercept-resend QBER $=1/4$")
ax.set_xlabel("QBER  $Q$"); ax.set_ylabel("secret-key rate (nats)")
ax.set_title("BB84 one-way secret-key rate and the ~11% threshold")
ax.legend(loc="upper right", fontsize=9); ax.grid(alpha=0.3)
plt.tight_layout(); plt.savefig("bb84_keyrate.png", dpi=150)
print("wrote bb84_keyrate.png")
