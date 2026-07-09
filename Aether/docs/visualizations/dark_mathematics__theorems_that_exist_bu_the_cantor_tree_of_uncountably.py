"""Visualize the Cantor injection {True,False}^N -> dark statements as a binary
tree whose 2^n paths each yield a distinct dark statement. Requires matplotlib."""
import matplotlib.pyplot as plt

depth = 5
fig, ax = plt.subplots(figsize=(9, 6))
def draw(x: float, y: float, dx: float, d: int) -> None:
    if d == 0:
        ax.plot(x, y, "o", color="crimson", markersize=4)
        return
    for sign, lbl in ((-1, "T"), (1, "F")):
        nx, ny = x + sign * dx, y - 1
        ax.plot([x, nx], [y, ny], color="gray", alpha=0.5)
        draw(nx, ny, dx / 2, d - 1)
draw(0, depth, 2 ** (depth - 1), depth)
ax.set_title(f"2^{depth} = {2**depth} distinct dark statements (continuum in the limit)")
ax.axis("off")
plt.tight_layout()
plt.savefig("abundance_tree.png", dpi=150)
print("wrote abundance_tree.png")
