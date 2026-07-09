"""Growth of the residual R_t = A_t/q on a log scale for several bases."""
import matplotlib.pyplot as plt
from math import comb, log10

def R(q, t):
    return (comb(q ** (t + 1), q ** t) - q ** (q ** t)) // q

fig, ax = plt.subplots(figsize=(9, 5))
for q in (2, 3, 5):
    ts = range(1, 6)
    ys = [log10(max(R(q, t), 1)) for t in ts]
    ax.plot(list(ts), ys, marker="o", label=f"q={q}")
ax.set_xlabel("t"); ax.set_ylabel("log10(R_t)")
ax.set_title("Super-exponential growth of the residual R_t = A_t / q")
ax.legend(); plt.tight_layout(); plt.savefig("residual_growth.png", dpi=150)
print("wrote residual_growth.png")
