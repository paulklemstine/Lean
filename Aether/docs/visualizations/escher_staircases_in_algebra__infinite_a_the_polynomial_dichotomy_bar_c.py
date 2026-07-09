"""Visualize the polynomial dichotomy: staircase height vs. number of variables."""
import matplotlib.pyplot as plt

def plot_dichotomy(max_vars: int = 8) -> None:
    fig, ax = plt.subplots(figsize=(8, 5))
    xs = list(range(1, max_vars + 1))
    # finitely many variables: no staircase (height 0); infinite: staircase (mark high)
    ys = [0 for _ in xs]
    ax.bar(xs, ys, color="steelblue", label="finite # variables: no staircase")
    ax.bar([max_vars + 2], [max_vars], color="crimson",
           label="infinitely many variables: staircase")
    ax.set_xticks(xs + [max_vars + 2])
    ax.set_xticklabels([str(n) for n in xs] + ["infinity"])
    ax.set_xlabel("number of variables in k[x_1, ..., x_m]")
    ax.set_ylabel("staircase present (bar height, schematic)")
    ax.set_title("Polynomial dichotomy: a staircase exists iff variables are infinite")
    ax.legend()
    plt.tight_layout()
    plt.savefig("escher_dichotomy.png", dpi=150)
    print("wrote escher_dichotomy.png")

if __name__ == "__main__":
    plot_dichotomy()
