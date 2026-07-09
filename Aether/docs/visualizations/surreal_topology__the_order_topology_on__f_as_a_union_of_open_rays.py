"""Visualize F as a union of open rays Iio(n) and its clopen complement."""
import matplotlib.pyplot as plt


def main() -> None:
    fig, ax = plt.subplots(figsize=(11, 4))
    for i, n in enumerate([1, 2, 3, 5, 10]):
        y = i * 0.6
        ax.plot([-0.2, n / 12], [y, y], color="#4C72B0", lw=3)
        ax.plot(n / 12, y, ">", color="#4C72B0")
        ax.text(n / 12 + 0.02, y, f"Iio({n})", va="center", fontsize=9)
    ax.plot([1.0, 1.6], [3.0, 3.0], color="#C44E52", lw=3)
    ax.plot(1.0, 3.0, "<", color="#C44E52")
    ax.text(1.62, 3.0, "Ioi(x-1): infinite part (open)", va="center", color="#7a1f28")
    ax.set_title("F = union_n Iio(n) is open;  its complement is open too => F clopen")
    ax.set_xlim(-0.3, 2.4); ax.set_ylim(-0.4, 3.4); ax.axis("off")
    plt.tight_layout(); plt.savefig("surreal_rays.png", dpi=150)
    print("wrote surreal_rays.png")


if __name__ == "__main__":
    main()
