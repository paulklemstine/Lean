"""Visualization: Hadamard orders reachable by Sylvester vs. Paley I."""
import matplotlib.pyplot as plt


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    d = 2
    while d * d <= n:
        if n % d == 0:
            return False
        d += 1
    return True


N = 64
sylvester = {2 ** k for k in range(0, 7)}                       # 1,2,4,...,64
paley1 = {q + 1 for q in range(3, N) if is_prime(q) and q % 4 == 3}
multiples_of_4 = set(range(4, N + 1, 4))

fig, ax = plt.subplots(figsize=(11, 3))
xs = list(range(1, N + 1))
for x in xs:
    color = "#dddddd"
    if x in multiples_of_4:
        color = "#bdd7e7"
    marks = []
    if x in sylvester:
        marks.append("S")
    if x in paley1:
        marks.append("P")
    ax.bar(x, 1, color=color, edgecolor="white")
    if marks:
        ax.text(x, 1.05, "".join(marks), ha="center", fontsize=7)
ax.set_title("Hadamard orders <= 64: S=Sylvester (powers of 2), "
             "P=Paley I (q+1, q=3 mod 4)")
ax.set_xlabel("order n")
ax.set_yticks([])
plt.tight_layout()
plt.savefig("hadamard_orders.png", dpi=150)
print("saved hadamard_orders.png")
