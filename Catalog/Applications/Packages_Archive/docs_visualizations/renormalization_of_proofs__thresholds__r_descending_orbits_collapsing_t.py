import matplotlib.pyplot as plt


def visualize(N: int = 31) -> None:
    halve = lambda x: x // 2
    plt.figure(figsize=(8, 5))
    for start in range(1, N + 1, 3):
        orbit = [start]
        while halve(orbit[-1]) != orbit[-1]:
            orbit.append(halve(orbit[-1]))
        plt.plot(range(len(orbit)), orbit, marker="o", label=f"x0={start}")
    plt.axhline(0, color="black", lw=1)
    plt.xlabel("iteration step"); plt.ylabel("state value")
    plt.title(f"Descending orbits of floor(x/2) on {{0,...,{N}}} reach fixed point 0")
    plt.legend(fontsize=7, ncol=2)
    plt.tight_layout()
    plt.savefig("descent_orbits.png", dpi=130)
    print("saved descent_orbits.png")


if __name__ == "__main__":
    visualize(31)
