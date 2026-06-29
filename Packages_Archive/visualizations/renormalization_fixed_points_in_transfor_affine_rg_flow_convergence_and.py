"""Visualization: convergence and universality of the affine RG flow.

Shows several trajectories x -> g*x + b from different initializations all
converging to the unique fixed point b/(1-g), illustrating universality
(initialization independence). Requires matplotlib.
"""
import matplotlib.pyplot as plt


def main() -> None:
    g, b, n = 0.6, 4.0, 20
    xstar = b / (1.0 - g)
    plt.figure(figsize=(8, 5))
    for x0 in [-10.0, -3.0, 0.0, 7.0, 15.0]:
        traj = [x0]
        x = x0
        for _ in range(n):
            x = g * x + b
            traj.append(x)
        plt.plot(range(n + 1), traj, "-o", ms=3, label=f"x0 = {x0}")
    plt.axhline(xstar, color="k", ls="--", lw=2,
                label=f"fixed point b/(1-g) = {xstar:.2f}")
    plt.xlabel("RG step n")
    plt.ylabel("error x_n")
    plt.title("Affine RG flow: every initialization converges (universality)")
    plt.legend()
    plt.grid(True, ls=":")
    plt.tight_layout()
    plt.savefig("affine_rg_flow.png", dpi=150)
    print("wrote affine_rg_flow.png")


if __name__ == "__main__":
    main()
