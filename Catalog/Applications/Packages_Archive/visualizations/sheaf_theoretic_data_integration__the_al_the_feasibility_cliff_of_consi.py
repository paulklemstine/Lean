import numpy as np
import matplotlib.pyplot as plt

def consistency_prob(r: np.ndarray, n: int) -> np.ndarray:
    """P(consistent) = (1 - r) ** N, the feasibility model."""
    return (1.0 - r) ** n

r = np.linspace(0, 1, 400)
fig, ax = plt.subplots(figsize=(8, 5))
for n in (1, 3, 8, 15, 30):
    ax.plot(r, consistency_prob(r, n), label=f"N = {n}")
    rstar = 1 - n ** (-1.0 / n)  # conjectured threshold
    ax.axvline(rstar, color="grey", ls=":", lw=0.6)
ax.set_xlabel("missing / corruption rate  r")
ax.set_ylabel("P(consistent imputation) = (1-r)^N")
ax.set_title("The feasibility cliff: P(sheaf) = (1-r)^N")
ax.legend(title="overlapping constraints")
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("feasibility_cliff.png", dpi=150)
print("saved feasibility_cliff.png")
