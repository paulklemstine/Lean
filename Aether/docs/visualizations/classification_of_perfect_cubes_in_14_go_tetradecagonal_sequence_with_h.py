import matplotlib.pyplot as plt


def tetradecagonal(n: int) -> int:
    return 6 * n * n - 5 * n


def is_cube(x: int) -> bool:
    if x < 0:
        return False
    t = round(x ** (1.0 / 3.0))
    return any(c >= 0 and c ** 3 == x for c in (t - 1, t, t + 1))


def main() -> None:
    ns = list(range(0, 26))
    vals = [tetradecagonal(n) for n in ns]
    cube_ns = [n for n in ns if is_cube(tetradecagonal(n))]
    cube_vals = [tetradecagonal(n) for n in cube_ns]

    fig, ax = plt.subplots(figsize=(9, 5))
    ax.plot(ns, vals, "o-", color="#4477aa", label="P_14(n) = 6n^2 - 5n")
    ax.scatter(cube_ns, cube_vals, s=160, color="#cc3311", zorder=5,
               label="perfect cube")
    for n, v in zip(cube_ns, cube_vals):
        ax.annotate(f"n={n}, {v}={round(v**(1/3))}^3", (n, v),
                    textcoords="offset points", xytext=(8, -4))
    ax.set_xlabel("n")
    ax.set_ylabel("tetradecagonal number")
    ax.set_title("Tetradecagonal numbers and the three perfect cubes")
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("tetradecagonal_cubes.png", dpi=150)
    print("saved tetradecagonal_cubes.png")


if __name__ == "__main__":
    main()
