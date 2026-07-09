"""Draw Q(3) with a chosen semicube highlighted (matplotlib)."""
from itertools import product
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D  # noqa: F401


def draw_semicube(coord: int = 0, bit: bool = True) -> None:
    verts = list(product((0, 1), repeat=3))
    fig = plt.figure(figsize=(6, 6))
    ax = fig.add_subplot(111, projection="3d")
    # edges of the cube
    for u in verts:
        for k in range(3):
            v = list(u); v[k] ^= 1; v = tuple(v)
            if u < v:
                xs, ys, zs = zip(u, v)
                ax.plot(xs, ys, zs, color="lightgray", lw=1)
    # vertices, colored by membership in the semicube (coord == bit)
    for u in verts:
        inside = (u[coord] == int(bit))
        ax.scatter(*u, s=90, color="crimson" if inside else "steelblue")
        ax.text(u[0], u[1], u[2], "".join(map(str, u)), fontsize=8)
    ax.set_title(f"Q(3): semicube (coordinate {coord} = {int(bit)}) in red")
    plt.tight_layout(); plt.savefig("semicube_q3.png", dpi=150)
    print("wrote semicube_q3.png")


if __name__ == "__main__":
    draw_semicube(coord=0, bit=True)
