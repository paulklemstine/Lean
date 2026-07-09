"""Visualization: coordinate drift of the variable Witt vector vs. a sheared one."""
import matplotlib.pyplot as plt

def main() -> None:
    ks = list(range(12))
    variable_vector = [k for k in ks]           # coord k = X_k -> stage k
    cutoff = 5
    sheared_vector = [k if k < cutoff else None for k in ks]  # zero tail

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(ks, variable_vector, "o-", color="crimson",
            label="full variable vector: coord k in stage k (drifts forever)")
    xs = [k for k in ks if sheared_vector[k] is not None]
    ys = [sheared_vector[k] for k in xs]
    ax.plot(xs, ys, "s-", color="steelblue",
            label="sheared vector (support 5): finite drift, then 0")
    ax.axhline(max(ys), color="steelblue", ls="--", alpha=0.5,
               label="single stage that lifts the sheared vector")
    ax.set_xlabel("coordinate index k")
    ax.set_ylabel("least stage of coordinate k")
    ax.set_title("Why shearing works: bounded vs. unbounded coordinate drift")
    ax.legend()
    fig.tight_layout()
    fig.savefig("drift.png", dpi=150)
    print("wrote drift.png")

if __name__ == "__main__":
    main()
