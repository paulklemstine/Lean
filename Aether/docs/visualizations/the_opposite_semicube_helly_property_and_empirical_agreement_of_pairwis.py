"""Bar chart: pairwise vs global feasibility agree on random families in Q(n)."""
import random
from itertools import combinations, product
import matplotlib.pyplot as plt


def all_vertices(n):
    return [frozenset(i for i, b in enumerate(bits) if b)
            for bits in product((False, True), repeat=n)]


def pairwise(n, fam, V):
    for (i, b), (j, c) in combinations(fam, 2):
        if not any((i in v) == b and (j in v) == c for v in V):
            return False
    return True


def globally(fam, V):
    return any(all((i in v) == b for i, b in fam) for v in V)


def run(n=5, trials=2000):
    V = all_vertices(n)
    agree = mismatch = 0
    for _ in range(trials):
        k = random.randint(1, 6)
        fam = [(random.randrange(n), random.random() < 0.5) for _ in range(k)]
        if pairwise(n, fam, V) == globally(fam, V):
            agree += 1
        else:
            mismatch += 1
    plt.bar(["pairwise == global", "mismatch"], [agree, mismatch],
            color=["seagreen", "crimson"])
    plt.title(f"Helly number 2 on Q({n}): {trials} random families")
    plt.ylabel("count"); plt.tight_layout()
    plt.savefig("helly_agreement.png", dpi=150)
    print("wrote helly_agreement.png; mismatches =", mismatch)


if __name__ == "__main__":
    run()
