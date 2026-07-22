import matplotlib.pyplot as plt
from itertools import permutations


def visualize_univalence_gap(max_n: int = 5) -> None:
    """
    Plot |Aut(A)| = n! against |A == A| = 1 (proof-irrelevant), highlighting the
    growing univalence gap. The obstruction begins at n = 2 (Bool).
    """
    ns = list(range(1, max_n + 1))
    aut = [len(list(permutations(range(n)))) for n in ns]
    ident = [1 for _ in ns]

    plt.figure(figsize=(8, 5))
    plt.plot(ns, aut, "o-", label="|Aut(A)| = n!  (equivalences)")
    plt.plot(ns, ident, "s--", label="|A == A| = 1  (proof-irrelevant identity)")
    plt.axvline(2, color="red", linestyle=":", label="Bool: minimal obstruction")
    plt.yscale("log")
    plt.xlabel("cardinality of the type A")
    plt.ylabel("number of elements (log scale)")
    plt.title("The univalence gap: equivalences vs. identifications")
    plt.legend()
    plt.tight_layout()
    plt.savefig("univalence_gap.png", dpi=150)
    print("saved univalence_gap.png")


if __name__ == "__main__":
    visualize_univalence_gap()
