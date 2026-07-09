"""Visualization: the unsheared 'all variables' vector escapes every stage.
Plots, for each candidate stage i, whether x_i is contained in S_i (never)."""
from __future__ import annotations
import matplotlib.pyplot as plt

def main() -> None:
    depth = 10
    stages = list(range(depth))
    contained = [0 for _ in stages]          # x_i in S_i is always False
    required = [i + 1 for i in stages]       # x_i needs stage i+1
    fig, ax = plt.subplots(figsize=(8, 4))
    ax.plot(stages, required, "o-", color="#dd6b20", label="stage required by x_i (= i+1)")
    ax.plot(stages, stages, "--", color="#718096", label="candidate stage i")
    ax.fill_between(stages, stages, required, color="#feb2b2", alpha=0.5,
                    label="gap: x_i escapes S_i")
    ax.set_xlabel("candidate stage i")
    ax.set_ylabel("stage index")
    ax.set_title("Necessity of shearing: X = (x_0, x_1, ...) descends nowhere")
    ax.legend()
    fig.tight_layout()
    fig.savefig("necessity.png", dpi=150)
    print("wrote necessity.png")

if __name__ == "__main__":
    main()
