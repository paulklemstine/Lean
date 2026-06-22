"""Tropical iteration stability vs classical L^n amplification."""
import matplotlib.pyplot as plt

n = list(range(1, 21))
tropical = [3 for _ in n]            # min-plus: exponent invariant
classical = [2 ** k for k in n]     # L=2 worst-case product

plt.figure(figsize=(8, 5))
plt.semilogy(n, classical, "o-", label="classical amplification L^n (L=2)")
plt.semilogy(n, tropical, "s--", label="tropical exponent (stable = 3)")
plt.xlabel("number of composed / iterated layers n")
plt.ylabel("effective Lipschitz amplification (log scale)")
plt.title("Tropical composition tames depth-dependent blow-up")
plt.legend()
plt.grid(True, which="both", alpha=0.3)
plt.tight_layout()
plt.savefig("lipschitz_stability.png", dpi=150)
print("wrote lipschitz_stability.png")
