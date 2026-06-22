"""Visualization: affine Picard cobweb plot and geometric error decay.

Shows the staircase/cobweb convergence of x <- a*x + b to x* = b/(1-a)
(theorem affine_iterate_tendsto) and the exact |a|^n error decay (Remark 6.2).
Requires matplotlib.
"""
import math
import matplotlib.pyplot as plt

def cobweb(a: float, b: float, x0: float, steps: int = 12) -> None:
    xstar = b / (1.0 - a)
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Cobweb diagram
    xs = [min(x0, xstar) - 1, max(x0, xstar) + 1]
    ax1.plot(xs, [a * x + b for x in xs], "b-", label=f"f(x)={a}x+{b}")
    ax1.plot(xs, xs, "k--", label="y=x")
    x = x0
    for _ in range(steps):
        y = a * x + b
        ax1.plot([x, x], [x, y], "r-", lw=0.8)
        ax1.plot([x, y], [y, y], "r-", lw=0.8)
        x = y
    ax1.plot([xstar], [xstar], "go", ms=8, label=f"x*={xstar:.3f}")
    ax1.set_title("Affine Picard cobweb (Banach)")
    ax1.legend(); ax1.grid(alpha=0.3)

    # Error decay
    ns = list(range(steps + 1))
    errs = [abs(a) ** n * abs(x0 - xstar) for n in ns]
    ax2.semilogy(ns, errs, "mo-")
    ax2.set_title("Exact geometric error |a|^n |x0 - x*|")
    ax2.set_xlabel("iteration n"); ax2.set_ylabel("error")
    ax2.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig("picard_convergence.png", dpi=120)
    print("saved picard_convergence.png")

if __name__ == "__main__":
    cobweb(0.6, 2.0, 0.0, steps=14)
