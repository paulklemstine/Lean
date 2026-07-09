"""Visualize perfect zero knowledge: real vs simulated transcript distributions."""
from itertools import permutations, product
import matplotlib.pyplot as plt


def distinct_pairs():
    return [(x, y) for (x, y) in product(range(3), range(3)) if x != y]


def real_distribution(a: int, b: int):
    perms = list(permutations(range(3)))
    counts = {p: 0 for p in distinct_pairs()}
    for perm in perms:
        counts[(perm[a], perm[b])] += 1
    return [counts[p] / len(perms) for p in distinct_pairs()]


def main() -> None:
    pairs = distinct_pairs()
    labels = [f"({x},{y})" for (x, y) in pairs]
    real = real_distribution(0, 1)
    sim = [1 / 6 for _ in pairs]
    x = range(len(pairs))
    plt.bar([i - 0.2 for i in x], real, width=0.4, label="real (edge 0-1)")
    plt.bar([i + 0.2 for i in x], sim, width=0.4, label="simulator", alpha=0.7)
    plt.xticks(list(x), labels)
    plt.ylabel("probability")
    plt.title("Perfect zero knowledge: real == simulator == 1/6")
    plt.legend()
    plt.tight_layout()
    plt.savefig("zero_knowledge.png", dpi=150)
    print("wrote zero_knowledge.png")


if __name__ == "__main__":
    main()
