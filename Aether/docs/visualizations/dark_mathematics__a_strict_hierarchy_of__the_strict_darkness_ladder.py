"""Bar chart of the darkness hierarchy: each B_k reaches exactly level k."""
import matplotlib.pyplot as plt


def bounded_dark_top_level(k: int) -> int:
    """B_k proves atLeast(j) iff j <= k, so its top darkness level is k."""
    return k


def main() -> None:
    ks = list(range(9))
    levels = [bounded_dark_top_level(k) for k in ks]
    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(ks, levels, color="#3b0a5c", edgecolor="black")
    ax.plot(ks, ks, "o--", color="#e15b2d", label="level = k (strict rung)")
    ax.set_xlabel("system index k  (B_k)")
    ax.set_ylabel("top darkness level attained")
    ax.set_title("The strict darkness hierarchy: B_k is dark of level k, not k+1")
    ax.legend()
    fig.tight_layout()
    fig.savefig("darkness_hierarchy.png", dpi=150)
    print("wrote darkness_hierarchy.png")


if __name__ == "__main__":
    main()
