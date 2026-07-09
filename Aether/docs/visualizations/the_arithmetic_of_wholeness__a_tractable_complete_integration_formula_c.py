"""Visualize the Complete Integration Formula Phi(K_n) = floor(n^2/4)."""
import matplotlib.pyplot as plt

def floor_quarter_square(n: int) -> int:
    return (n * n) // 4

ns = list(range(1, 13))
phi_vals = [floor_quarter_square(n) for n in ns]
parabola = [n * n / 4 for n in ns]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(ns, parabola, "--", color="gray", label=r"$n^2/4$ (continuous bound)")
ax.plot(ns, phi_vals, "o-", color="crimson", label=r"$\Phi(K_n)=\lfloor n^2/4\rfloor$")
for n, p in zip(ns, phi_vals):
    ax.annotate(str(p), (n, p), textcoords="offset points", xytext=(0, 8), ha="center")
ax.set_xlabel("number of variables $n$")
ax.set_ylabel("surrogate integrated information $\\Phi$")
ax.set_title("Complete Integration Formula: maximal $\\Phi$ vs. system size")
ax.legend()
ax.grid(alpha=0.3)
plt.tight_layout()
plt.savefig("phi_formula.png", dpi=150)
print("wrote phi_formula.png")
