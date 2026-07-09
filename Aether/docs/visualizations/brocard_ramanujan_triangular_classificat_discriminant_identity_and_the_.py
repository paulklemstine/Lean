import matplotlib.pyplot as plt
from math import factorial, isqrt


def is_square(s: int) -> bool:
    r = isqrt(s)
    return r * r == s


def triangular(y: int) -> int:
    return y * (y + 1) // 2


# Visualize the discriminant identity 8*T_y + 1 = (2y+1)^2 and mark the
# three Brown indices y = 2, 5, 35.
ys = list(range(0, 40))
lhs = [8 * triangular(y) + 1 for y in ys]
rhs = [(2 * y + 1) ** 2 for y in ys]
brown_y = [2, 5, 35]

fig, ax = plt.subplots(figsize=(9, 6))
ax.plot(ys, lhs, "o-", label=r"$8\,T_y + 1$", alpha=0.7)
ax.plot(ys, rhs, "x--", label=r"$(2y+1)^2$", alpha=0.7)
for y in brown_y:
    ax.axvline(y, color="crimson", ls=":", alpha=0.5)
    ax.annotate(f"Brown y={y}", (y, (2 * y + 1) ** 2),
                textcoords="offset points", xytext=(5, 8), color="crimson")
ax.set_xlabel("triangular index y")
ax.set_ylabel("value")
ax.set_title("Figurate discriminant identity  8*T_y + 1 = (2y+1)^2")
ax.legend()
ax.set_yscale("log")
plt.tight_layout()
plt.savefig("brocard_identity.png", dpi=150)
print("saved brocard_identity.png")
