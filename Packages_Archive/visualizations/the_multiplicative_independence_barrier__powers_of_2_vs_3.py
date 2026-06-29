"""Visualization: the lattice of powers of 2 vs powers of 3, showing they never meet."""
import matplotlib.pyplot as plt


def main() -> None:
    A = range(1, 13)
    p2 = [2 ** a for a in A]
    p3 = [3 ** b for b in A]
    fig, ax = plt.subplots(figsize=(9, 5))
    ax.scatter(A, p2, label="2**a (powers of 2)", color="#1f77b4")
    ax.scatter(A, p3, label="3**b (powers of 3)", color="#d62728")
    ax.set_yscale("log")
    ax.set_xlabel("exponent")
    ax.set_ylabel("value (log scale)")
    ax.set_title("Powers of 2 and 3 never coincide: 2 and 3 are multiplicatively independent")
    ax.legend()
    ax.grid(True, which="both", alpha=0.3)
    fig.tight_layout()
    fig.savefig("powers_2_vs_3.png", dpi=130)
    print("wrote powers_2_vs_3.png")


if __name__ == "__main__":
    main()
