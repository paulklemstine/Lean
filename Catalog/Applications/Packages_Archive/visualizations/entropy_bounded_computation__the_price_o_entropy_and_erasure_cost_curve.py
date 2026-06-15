import math
import matplotlib.pyplot as plt

def entropy(card: int) -> float:
    return math.log2(card)

# Entropy vs. number of states, and the Landauer erasure cost it represents.
cards = list(range(1, 65))
ents = [entropy(c) for c in cards]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(cards, ents, lw=2, color="#1f77b4", label="H(S) = log2(|S|)  (= erasure cost)")
ax.scatter([1, 2, 4, 8, 16, 32, 64],
           [entropy(c) for c in (1, 2, 4, 8, 16, 32, 64)],
           color="#d62728", zorder=5, label="powers of two")
ax.axhline(0, color="gray", lw=0.8)
ax.set_xlabel("number of states |S|")
ax.set_ylabel("entropy (bits)")
ax.set_title("Entropy of a finite state space and the Landauer cost of erasing it")
ax.legend()
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("ebc_entropy.png", dpi=150)
print("saved ebc_entropy.png")
