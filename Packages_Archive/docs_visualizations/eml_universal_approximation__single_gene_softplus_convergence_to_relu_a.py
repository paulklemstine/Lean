"""Visualization: softplus -> ReLU as steepness beta increases (matplotlib)."""
import math
import matplotlib.pyplot as plt

def relu(x: float) -> float:
    return max(x, 0.0)

def softplus(beta: float, x: float) -> float:
    t = beta * x
    return (max(t, 0.0) + math.log1p(math.exp(-abs(t)))) / beta

xs = [(-3.0 + 6.0 * k / 600) for k in range(601)]
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))
ax1.plot(xs, [relu(x) for x in xs], "k--", lw=2, label="ReLU")
for beta in (0.5, 1.0, 3.0, 10.0):
    ax1.plot(xs, [softplus(beta, x) for x in xs], label=f"softplus, beta={beta}")
ax1.set_title("Softplus converges to ReLU"); ax1.legend(); ax1.grid(alpha=0.3)
betas = [0.5 * 1.3 ** k for k in range(20)]
ax2.loglog(betas, [math.log(2) / b for b in betas], "o-", label="log2 / beta (bound)")
ax2.set_xlabel("beta"); ax2.set_ylabel("uniform error")
ax2.set_title("Sharp O(1/beta) rate (attained at x=0)")
ax2.legend(); ax2.grid(alpha=0.3, which="both")
plt.tight_layout(); plt.savefig("softplus_rate.png", dpi=150)
print("wrote softplus_rate.png")
