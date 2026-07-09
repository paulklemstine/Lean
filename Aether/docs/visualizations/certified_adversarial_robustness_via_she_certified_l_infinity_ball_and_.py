"""Visualize the L-infinity certified region of a linear score and the
cyclic cohomology obstruction. Requires matplotlib and numpy."""
import numpy as np
import matplotlib.pyplot as plt


def score(w, x):
    return float(np.dot(w, x))


def weight_l1(w):
    return float(np.sum(np.abs(w)))


def main():
    w = np.array([2.0, -1.0])
    x0 = np.array([1.0, 0.5])
    R = abs(score(w, x0)) / weight_l1(w)

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # (a) certified L-infinity ball vs decision boundary
    ax = axes[0]
    xs = np.linspace(-2, 4, 400)
    ys = np.linspace(-3, 3, 400)
    X, Y = np.meshgrid(xs, ys)
    S = w[0] * X + w[1] * Y
    ax.contourf(X, Y, np.sign(S), levels=[-2, 0, 2], alpha=0.25,
                colors=["#4477aa", "#ee6677"])
    ax.contour(X, Y, S, levels=[0], colors="k", linewidths=2)
    sq = plt.Rectangle((x0[0] - R, x0[1] - R), 2 * R, 2 * R,
                       fill=False, edgecolor="green", linewidth=2)
    ax.add_patch(sq)
    ax.plot(*x0, "ko")
    ax.set_title(f"Certified L-inf ball, R = {R:.3f}")
    ax.set_aspect("equal")

    # (b) holonomy of the unit cochain grows with loop size
    ax = axes[1]
    ns = np.arange(1, 11)
    ax.bar(ns + 1, ns + 1, color="#ee6677")
    ax.set_xlabel("regions in loop (n+1)")
    ax.set_ylabel("holonomy of unit cochain")
    ax.set_title("Cyclic obstruction never vanishes")

    plt.tight_layout()
    plt.savefig("robustness_cohomology.png", dpi=130)
    print("saved robustness_cohomology.png")


if __name__ == "__main__":
    main()
