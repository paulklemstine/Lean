"""Bar chart of exact Cusick densities for reversal pairs vs the DKS bound."""
from fractions import Fraction
import matplotlib.pyplot as plt

def s2(n: int) -> int:
    return bin(n).count("1")

def cusick_period(t: int) -> int:
    return 2 ** (t.bit_length() + s2(t))

def cusick_count(t: int, N: int) -> int:
    return sum(1 for n in range(N) if s2(n) <= s2(n + t))

def density(t: int) -> float:
    P = cusick_period(t)
    return cusick_count(t, P) / P

def dks(t: int) -> float:
    return float(Fraction(1, 2) + Fraction(1, 2 ** (2 * s2(t) + 1)))

shifts = [19, 25, 23, 29]
labels = [f"{t}\n({t:b})" for t in shifts]
vals = [density(t) for t in shifts]
bounds = [dks(t) for t in shifts]

fig, ax = plt.subplots(figsize=(8, 5))
x = range(len(shifts))
ax.bar(x, vals, color=["#1f77b4", "#1f77b4", "#ff7f0e", "#ff7f0e"], label="exact c_t")
ax.plot(x, bounds, "k--o", label="DKS lower bound")
ax.axhline(0.5, color="gray", lw=0.8)
ax.set_xticks(list(x)); ax.set_xticklabels(labels)
ax.set_ylabel("density")
ax.set_title("Cusick densities: reversal pairs (19,25)=41/64, (23,29)=75/128")
ax.legend()
plt.tight_layout()
plt.savefig("cusick_reversal_densities.png", dpi=150)
print("saved cusick_reversal_densities.png")
