"""Plot Chebyshev polynomials U_k on [-1,1] against the Deligne envelope +/-(k+1)."""
import numpy as np
import matplotlib.pyplot as plt

def cheb_U(k: int, x: np.ndarray) -> np.ndarray:
    u_prev, u_curr = np.ones_like(x), 2.0 * x
    if k == 0:
        return u_prev
    if k == 1:
        return u_curr
    for _ in range(2, k + 1):
        u_prev, u_curr = u_curr, 2.0 * x * u_curr - u_prev
    return u_curr

x = np.linspace(-1, 1, 800)
fig, ax = plt.subplots(figsize=(9, 6))
for k in range(1, 6):
    ax.plot(x, cheb_U(k, x), label=f"U_{k}(x)")
    ax.hlines([k + 1, -(k + 1)], -1, 1, colors="gray", linestyles=":", linewidth=0.8)
ax.set_title("Chebyshev polynomials U_k and the Deligne envelope |U_k| <= k+1")
ax.set_xlabel("x"); ax.set_ylabel("U_k(x)")
ax.legend(loc="upper center", ncol=5)
ax.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig("chebyshev_envelope.png", dpi=150)
print("wrote chebyshev_envelope.png")
